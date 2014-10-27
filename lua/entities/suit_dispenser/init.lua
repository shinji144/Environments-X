AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "ambient.steam01" )

include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.damaged = 0
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	if WireAddon then
		self.WireDebugName = self.PrintName
	end
	self.Inputs = Wire_CreateInputs(self.Entity, { "Lock" })
	self.Locked = false
	
	self.resources = {}
	self.resources["energy"] = 0
	self.resources["water"] = 0
	self.resources["air"] = 0
	
	self.maxresources = {}
	self.maxresources["energy"] = 0
	self.maxresources["water"] = 0
	self.maxresources["air"] = 0
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self.damaged = 0
end

function ENT:AcceptInput(name,activator,caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
		self:SetActive( nil, caller )
	end
end	
	
function ENT:TriggerInput(iname, value)
	if (iname == "Lock") then
		if (value > 0) then
			self.Locked= true
		else
			self.Locked = false
		end	
	end
end

local function quiet_steam(ent)
	ent:StopSound( "ambient.steam01" )
end

local MaxAmount = 4000
local Multiplier = 1.5
local Divider = 1/Multiplier

function ENT:SetActive( value, caller )
	if not self.node then return end
	if self.Locked then return end
	self.energy = self:GetResourceAmount("LS Charge")
	self.fuel = self:GetResourceAmount("hydrogen")
	
	local Res_needed = math.ceil((MaxAmount - caller.suit.energy) * Divider)

	if ( Res_needed < self.energy ) then
		self:ConsumeResource("LS Charge", Res_needed)
		caller.suit.energy = MaxAmount
	elseif (self.energy > 0) then
		caller.suit.energy = caller.suit.energy + math.floor(self.energy * Multiplier)
		self:ConsumeResource("LS Charge", self.energy)
	end
	
	local fuel_needed = math.ceil(((MaxAmount) - caller.suit.fuel) * Divider)
	if ( fuel_needed < self.fuel ) then
		self:ConsumeResource("hydrogen", fuel_needed)
		caller.suit.fuel = MaxAmount
	elseif (self.fuel > 0) then
		caller.suit.fuel = caller.suit.fuel + math.floor(self.fuel * Multiplier)
		self:ConsumeResource("hydrogen", self.fuel)
	end
	
	caller:EmitSound( "ambient.steam01" )
	local temp = function() quiet_steam(caller) end
	timer.Simple(3, temp) 
end

