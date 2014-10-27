AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Energy_Increment = 6 --40 before  --randomize for weather

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.damaged = 0
	if WireAddon then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "On" })
		self.Outputs = Wire_CreateOutputs(self, { "Out" })
	end
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self.Active = 1
		self:SetOOO(1)
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		if (value > 0) then
			self:TurnOn()
		else
			self:TurnOff()
		end
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self.Active = 0
		self:SetOOO(0)
		if WireAddon then Wire_TriggerOutput(self, "Out", 0) end
	end
end

function ENT:SetActive( value )
	if (value) then
		if (value != 0 and self.Active == 0 ) then
			self:TurnOn()
		elseif (value == 0 and self.Active == 1 ) then
			self:TurnOff()
		end
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

function ENT:Extract_Energy()
	local inc = 0
	if self.environment then
		local planet = self.environment:IsOnPlanet()
		if planet and planet:GetAtmosphere() > 0.2 then
			inc = math.random(1, (4 * planet:GetAtmosphere()))
		end
	else
		inc = 1
	end
	if (inc > 0) then
		local einc = math.floor(inc * Energy_Increment)
		local nitro = self:GetResourceAmount("nitrogen")
		if(nitro>=(einc*2))then return end
		einc = math.ceil(einc * self:GetMultiplier())
		
		self:ConsumeResource("nitrogen", einc*2)
		self:SupplyResource("water", einc)
		if WireAddon then Wire_TriggerOutput(self, "Out", einc) end
	else
		if WireAddon then Wire_TriggerOutput(self, "Out", 0) end
	end
end

function ENT:GenEnergy()
	local waterlevel = self:WaterLevel() or 0
	if (waterlevel > 1) then
		self:TurnOff()
	//	self:Destruct()
	else
		self:Extract_Energy()
	end
end

function ENT:Think()
	self.BaseClass.Think(self)	
	if self.environment then		
		local planet = self.environment:IsOnPlanet()
		if (planet and planet:GetAtmosphere() > 0) then
	//		self:TurnOn()
		else
			self:TurnOff()
		end
	end
	
	if (self.Active == 1) then
		self:GenEnergy()
	end
	self:NextThink(CurTime() + 1)
	return true
end
