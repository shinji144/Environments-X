AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

util.PrecacheSound( "Buttons.snd17" )

include('shared.lua')

local Energy_Increment = 4
local BeepCount = 3
local running = 0

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.damaged = 0
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On" })
		self.Outputs = Wire_CreateOutputs(self, { /*"O2 Level", "CO2 Level", "Nitrogen Level", "Hydrogen Level", "Pressure", "Temperature", "Gravity",*/ "On" })
	else
		self.Inputs = {{Name="On"}}
	end
	--self:ShowOutput()
end

function ENT:TurnOn()
	self:EmitSound( "Buttons.snd17" )
	self.Active = 1
	self:SetOOO(1)
	if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", 1) end
end

function ENT:TurnOff(warn)
	if (!warn) then self:EmitSound( "Buttons.snd17" ) end
	self.Active = 0
	self:SetOOO(0)
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive( value )
	end
end

function ENT:Terraform()
	if (self:GetResourceAmount("energy") <= 0) then
		self:EmitSound( "common/warning.wav" )
		self:TurnOff(true)
		return
	else
		if (BeepCount > 0) then
			BeepCount = BeepCount - 1
		else
			self:EmitSound( "Buttons.snd17" )
			BeepCount = 20 --30 was a little long, 3 times a minute is ok
		end
	end
	if self.environment then
		if self.environment.pressure > (self.environment.pressure*self.environment.gravity)*0.98 then --get better max pressure
			if (self.environment.air.hper or 0) > 1 then --suck out if full
				local amt = self.environment:Convert("h", nil, 100000)
				self:SupplyResource("hydrogen", amt)
				local left = self:GetSpaceLeft("hydrogen")
				if left != 0 then
					if left > 100000 then
						left = 100000
					end
					local amt = self.environment:Convert("h", nil, left)
					self:SupplyResource("hydrogen", amt)
				end
			elseif (self.environment.air.nper or 0) > 1 then
				local left = self:GetSpaceLeft("nitrogen")
				if left != 0 then
					if left > 100000 then
						left = 100000
					end
					local amt = self.environment:Convert("n", nil, left)
					self:SupplyResource("n", amt)
				end
			end
		end
		if (self.environment.air.o2per or 0) < 15 then --oxygen
			local ox = self:GetResourceAmount("oxygen")
			if ox > 100000 then
				ox = 100000
			end
			self.environment:Convert(nil, "o2", ox)
		end
		
		local temp = self.environment:GetTemperature()
		if temp > 300 then
			local left = self:GetSpaceLeft("carbon dioxide")
			if left != 0 then
				if left > 100000 then
					left = 100000
				end
				local amt = self.environment:Convert("co2", nil, left)
				self:SupplyResource("carbon dioxide", amt)
			end
		elseif temp < 275 then
			local amt = self:GetResourceAmount("carbon dioxide")
			if amt > 100000 then
				amt = 100000
			end
			self.environment:Convert(nil, "co2", amt)
		end
	end
	self:ConsumeResource("energy", Energy_Increment)
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if (self.Active == 1) then
		self:Terraform()
	end
	
	self:NextThink(CurTime() + 1)
	return true
end

