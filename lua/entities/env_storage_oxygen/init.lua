AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Energy_Increment = 100 --40 before  --randomize for weather

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Active = 0
	self.damaged = 0

	self.vent = false
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "Vent" })
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "Vent") then
		if (value != 1) then
			self.vent = false
		else
			self.vent = true
		end
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	local air = self:GetResourceAmount("oxygen")
	if self.environment then
		self.environment:Convert(-1, 0, air)
	end
	self.Entity:StopSound( "PhysicsCannister.ThrusterLoop" )
end

function ENT:Leak()
	local air = self:GetResourceAmount("oxygen")
	local mul = air/self.maxresources["oxygen"]
	local am = math.Round(mul * 1000);
	if (air >= am) then
		self:ConsumeResource("oxygen", am)
		if self.environment then
			self.environment:Convert(-1, 0, am)
		end
	else
		self:ConsumeResource("oxygen", air)
		if self.environment then
			self.environment:Convert(-1, 0, air)
		end
		self.Entity:StopSound( "PhysicsCannister.ThrusterLoop" )
	end
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:Think()
	self.BaseClass.Think(self)
	if (self.damaged == 1 or self.vent) then
		self:Leak()
	end
	self:NextThink( CurTime() +  1 )
	return true
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self:SetColor(255, 255, 255, 255)
	self.damaged = 0
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct( self, true )
	end
end