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
	local energy,water,oxygen,fuel = self:GetResourceAmount("energy"),self:GetResourceAmount("water"),self:GetResourceAmount("oxygen"),self:GetResourceAmount("hydrogen")
	
	local Res_needed = math.ceil((MaxAmount - caller.suit.energy) * Divider)
	
	local MaxEng,MaxWat,MaxAir = math.floor(energy/10),math.floor(water/1),math.floor(oxygen/2)
	
	local MaxCharge = MaxEng
	if MaxCharge<MaxWat then MaxCharge = MaxWat end
	if MaxCharge<MaxAir then MaxCharge = MaxAir end
	
	if ( Res_needed < MaxCharge ) then
		self:ConsumeResource("energy", Res_needed/10)
		self:ConsumeResource("water", Res_needed/1)
		self:ConsumeResource("oxygen", Res_needed/2)
		
		caller.suit.energy = MaxAmount
	elseif (energy > 0) then
		caller.suit.energy = caller.suit.energy + math.floor(MaxCharge * Multiplier)
		self:ConsumeResource("energy", energy)
		self:ConsumeResource("water", water)
		self:ConsumeResource("oxygen", oxygen)
	end
	
	local fuel_needed = math.ceil(((MaxAmount) - caller.suit.fuel) * Divider)
	if ( fuel_needed < fuel ) then
		self:ConsumeResource("hydrogen", fuel_needed)
		caller.suit.fuel = MaxAmount
	elseif (fuel > 0) then
		caller.suit.fuel = caller.suit.fuel + math.floor(fuel * Multiplier)
		self:ConsumeResource("hydrogen", fuel)
	end
	
	caller:EmitSound( "ambient.steam01" )
	local temp = function() quiet_steam(caller) end
	timer.Simple(3, temp) 
end

