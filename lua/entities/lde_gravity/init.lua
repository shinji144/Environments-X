AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
ENT.IsLDEC = 1

local Water_Increment = 8 --40 before  --randomize for weather
local Cool_Rate = 40

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.damaged = 0
	self.thinkcount = 0
	self.LDE = {}
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "On", "Overdrive", "Mute", "Multiplier" })
	else
		self.Inputs = {{Name="On"},{Name="Overdrive"}}
	end
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self.Active = 1
		self:SetOOO(1)
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self.Active = 0
		self:SetOOO(0)
	end
end

function ENT:SetActive( value )
	if (value) then
		if (value != 0 and self.Active == 0 ) then
			self:TurnOn()
		elseif (value == 0 and self.Active == 1 ) then
			self:TurnOff()
		end
	else
		if ( self.Active == 0 ) then
			self.lastused = CurTime()
			self:TurnOn()
		else
			if ((( CurTime() - self.lastused) < 2 ) and ( self.overdrive == 0 )) then
				
			else
				self.overdrive = 0
				self:TurnOff()
			end
		end
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	elseif (iname == "Overdrive") then
		if (value ~= 0) then
			
		else
			self:TurnOffOverdrive()
		end
	end
	if (iname == "Mute") then
		if (value > 0) then
			self.Mute = 1
		else
			self.Mute = 0
		end
	end
	if (iname == "Multiplier") then
		self:SetMultiplier(value)
	end
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self:SetColor(Color(255, 255, 255, 255))
	self.damaged = 0
end

function ENT:Defygrav()
	local core = self.LDE.Core
	local water = self:GetResourceAmount("energy")
	local Rate = (500)
	for _,ent in pairs(  constraint.GetAllWeldedEntities( self ) ) do
		if(not ent.LDE)then ent.LDE = {} end
		if(water>=Rate and self.Active) then
			ent.LDE.Immuniser=self
			self:ConsumeResource("energy", Rate)
		else
			ent.LDE.Immuniser=ent
			self.Active=0
		end
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	self:Defygrav()
	self:NextThink(CurTime() + 1)
	return true
end
