AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "Airboat_engine_idle" )
util.PrecacheSound( "Airboat_engine_stop" )
util.PrecacheSound( "apc_engine_start" )
include('shared.lua')

local Pressure_Increment = 80
local Energy_Increment = 10

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.overdrive = 0
	self.damaged = 0
	self.lastused = 0
	self.sequence = -1
	self.thinkcount = 0
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self.Mute = 0
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On", "Overdrive", "Mute", "Multiplier" })
		self.Outputs = Wire_CreateOutputs(self, {"On", "Overdrive", "EnergyUsage", "GasProduction" })
	else
		self.Inputs = {{Name="On"},{Name="Overdrive"}}
	end
	
	self.resources = {}
	self.resources["energy"] = 0
	self.resources["water"] = 0
	
	self.maxresources = {}
	self.maxresources["energy"] = 0
	self.maxresources["water"] = 0
end

function ENT:TurnOn()
	if (self.Active == 0) then
		if (self.Mute == 0) then
			self:EmitSound( "Airboat_engine_idle" )
		end
		self.Active = 1
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", self.Active) end

		self:SetOOO(1)
	elseif ( self.overdrive == 0 ) then
		self:TurnOnOverdrive()
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		if (self.Mute == 0) then
			self:StopSound( "Airboat_engine_idle" )
			self:EmitSound( "Airboat_engine_stop" )
			self:StopSound( "apc_engine_start" )
		end
		self.Active = 0
		self.overdrive = 0
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", self.Active) end
		self:SetOOO(0)
	end
end

function ENT:TurnOnOverdrive()
	if ( self.Active == 1 ) then
		if (self.Mute == 0) then
			self.Entity:StopSound( "Airboat_engine_idle" )
			self.Entity:EmitSound( "Airboat_engine_idle" )
			self.Entity:EmitSound( "apc_engine_start" )
		end
		self:SetOOO(2)
		self.overdrive = 1
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "Overdrive", self.overdrive) end
	end
end

function ENT:TurnOffOverdrive()
	if ( self.Active == 1 and self.overdrive == 1) then
		if (self.Mute == 0) then
			self.Entity:StopSound( "Airboat_engine_idle" )
			self.Entity:EmitSound( "Airboat_engine_idle" )
			self.Entity:StopSound( "apc_engine_start" )
		end
		self:SetOOO(1)
		self.overdrive = 0
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "Overdrive", self.overdrive) end
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
				self:TurnOnOverdrive()
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
			self:TurnOnOverdrive()
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
	if (self.damaged == 0) then
		self.damaged = 1
	end
	if ((self.Active == 1) and (math.random(1, 10) <= 4)) then
		self:TurnOff()
	end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self:SetColor(Color(255, 255, 255, 255))
	self.damaged = 0
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self:StopSound( "Airboat_engine_idle" )
end

function ENT:SuckGas()
	local energy = self:GetResourceAmount("energy")
	local einc = Energy_Increment + (self.overdrive*Energy_Increment*3)
	local waterlevel = 0
	waterlevel = self:WaterLevel()

	einc = (math.ceil(100 * self:GetSizeMultiplier())) * self:GetMultiplier()
	if WireAddon then Wire_TriggerOutput(self, "EnergyUsage", math.Round(einc)) end
	if energy >= einc then 
		local winc = 200 * self:GetMultiplier() * self:GetSizeMultiplier()
		if ( self.overdrive == 1 ) then
			winc = winc * 3
			self:SetHealth( self:Health() - math.random(2, 3))
		end
		
		local res = nil
		local clouds = ents.FindByClass("gas_cloud")
		for k,v in pairs(clouds) do
			if v:GetPos():Distance(self:GetPos()) < 1000 then
				res = v.ResourceName
				winc = v:Suck(winc)
				break
			end
		end
		
		self:ConsumeResource("energy", einc)
		if res then self:SupplyResource(res, winc) end
		if WireAddon then Wire_TriggerOutput(self, "GasProduction", math.Round(winc)) end
	else
		self:TurnOff()
	end
end

function ENT:Think()
	self.BaseClass.Think(self)

	if ( self.Active == 1 ) then self:SuckGas() end

	self:NextThink( CurTime() + 1 )
	return true
end

