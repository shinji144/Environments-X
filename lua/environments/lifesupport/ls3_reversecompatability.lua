

----------------------------------------------------------------------
--------------------------Solar Panels--------------------------------
----------------------------------------------------------------------

function Environments.Devices.SolarExtract(self,mul)
	mul = mul or 0
	if mul == 0 then
		return
	end
	local inc = 0

	if not self.environment then return end
	inc = math.ceil(8 / ((self.environment:GetAtmosphere()) + 1))

	if (self.damaged == 1) then inc = math.ceil(inc / 2) end
	if (inc > 0) then
		inc = math.ceil(inc * self:GetMultiplier() * mul)
		self:SupplyResource("energy", inc)
	end
	if not (WireAddon == nil) then Wire_TriggerOutput(self, "Out", inc) end
end

local Func = function(self)
	local waterlevel = self:WaterLevel() or 0

	if (waterlevel > 1) then
		self:TurnOff()
	else
		local entpos = self:GetPos()
		local trace = {}
		local lit = false
		local SunAngle2 = SunAngle or Vector(0, 0 ,1)
		local SunAngle = nil
		if TrueSun and table.Count(TrueSun) > 0 then
			local output = 0
			for k,SUN_POS in pairs(TrueSun) do
				trace = util.QuickTrace(SUN_POS, entpos-SUN_POS, nil)
				if trace.Hit then 
					if trace.Entity == self then
						local v = self:GetUp() + trace.HitNormal
						local n = v.x*v.y*v.z
						if n > 0 then
							output = output + n
							--solar panel produces energy
						end
					else
						local n = math.Clamp(1-SUN_POS:Distance(trace.HitPos)/SUN_POS:Distance(entpos),0,1)
						output = output + n
						--solar panel is being blocked
					end
				end
				if output >= 1 then
					break
				end
			end
			if output > 1 then 
				output = 1
			end
			if output > 0 then
				self:TurnOn()
				Environments.Devices.SolarExtract(self,output)
				return
			end
		end
		local SUN_POS = (entpos - (SunAngle2 * 4096))
		trace = util.QuickTrace(SUN_POS, entpos-SUN_POS, nil)
		if trace.Hit then 
			if trace.Entity == self then
				local v = self:GetUp() + trace.HitNormal
				local n = v.x*v.y*v.z
				if n > 0 then
					self:TurnOn()
					Environments.Devices.SolarExtract(self,n)
					return
				end
			else
				local n = math.Clamp(1-SUN_POS:Distance(trace.HitPos)/SUN_POS:Distance(entpos),0,1)
				if n > 0 then
					self:TurnOn()
					Environments.Devices.SolarExtract(self,n)
					return
				end
			end
		end
		self:TurnOff() //No Sunbeams in sight so turn Off
	end
end

local Data={name="Outdated Solar Panel",class="generator_energy_solar",Out={"energy"},WireOut={"Out"},thinkfunc=Func,OutMake={0}}
Environments.Devices.RegisterDevice(Data)


----------------------------------------------------------------------
-------------------------Water Pumps----------------------------------
----------------------------------------------------------------------

local Func = function(self)
	if(self.Active~=1)then return end
	local energy = self:GetResourceAmount("energy")
	local einc = 500
	local waterlevel = self:WaterLevel()

	einc = (math.ceil(einc * self:GetMultiplier()))
	if WireAddon then Wire_TriggerOutput(self, "EnergyUsage", math.Round(einc)) end
	if (waterlevel > 0 and energy >= einc) then
		local winc = (math.ceil(80 * (waterlevel / 3)))
		winc = math.ceil(winc * self:GetMultiplier())
		self:ConsumeResource("energy", einc)
		self:SupplyResource("water", winc)
		if WireAddon then Wire_TriggerOutput(self, "WaterProduction", math.Round(winc)) end
	else
		self:TurnOff()
	end
end

local Data={name="Outdated Water Pump",class="generator_liquid_water",In={"energy"},Out={"water"},WireOut={"EnergyUsage","WaterProduction"},thinkfunc=Func,InUse={0},OutMake={0}}
Environments.Devices.RegisterDevice(Data)

----------------------------------------------------------------------
-------------------------Fusion Generator-----------------------------
----------------------------------------------------------------------

local Func = function(self)
	if(self.Active~=1)then return end
	local Energy_Increment = 3000
	local Coolant_Increment = 40 --WATER NOW -- 15 nitrogen produced per 150 energy, so 45 is about 450 energy , 2000 - 450 = 1550 energy left - the requirements to generate the N
	local HW_Increment = 1
	
	local inc = Energy_Increment
	
	if (self:GetResourceAmount("water") < math.ceil(Coolant_Increment * self:GetMultiplier())) then
		Environments.DamageLS(self, math.Round(15 - (15 * ( self:GetResourceAmount("water")/math.ceil(Coolant_Increment * self:GetMultiplier())))))
		--only supply 5-25% of the normal amount
		if (inc > 0) then inc = math.ceil(inc/math.random(12 - math.ceil(8 * ( self:GetResourceAmount("water")/math.ceil(Coolant_Increment * self:GetMultiplier()))),20)) end
	else
		local consumed = self:ConsumeResource("water", math.ceil(Coolant_Increment * self:GetMultiplier()))
		--self:SupplyResource("steam", math.ceil(consumed * 0.92))
		self:SupplyResource("water", math.ceil(consumed * 0.08))
	end

	--the money shot!
	if (inc > 0) then 
		inc = math.ceil(inc)
		self:SupplyResource("energy", inc)
	end
	if WireLib then WireLib.TriggerOutput(self, "Output", inc) end
end

local Data={name="Outdated Fusion Generator",class="generator_energy_fusion",In={"water"},Out={"energy"},WireOut={"Output"},thinkfunc=Func,InUse={0},OutMake={0}}
Environments.Devices.RegisterDevice(Data)

----------------------------------------------------------------------
-------------------------Hydro Fans-----------------------------------
----------------------------------------------------------------------

function Environments.Devices.HydroFanExtract(self)
    local waterlevel = self:WaterLevel()

    if (waterlevel > 0) then
        waterlevel = waterlevel / 3
    else
        waterlevel = 1 / 3
    end
    local energy = math.Round(200 * waterlevel)
    self:SupplyResource("energy", energy)
    if not (WireAddon == nil) then Wire_TriggerOutput(self, "Out", energy) end
end

local Func = function(self)
    local waterlevel = 0
	
    waterlevel = self:WaterLevel()
    if (waterlevel > 0) then
        if (self.Active == 0) then
			self:TurnOn()
        end
        if (self.damaged == 1) then
            if (math.random(1, 10) < 6) then Environments.Devices.HydroFanExtract(self) end
        else
            Environments.Devices.HydroFanExtract(self)
        end
    else
        if (self.Active == 1) then
            self:TurnOff()
            if not (WireAddon == nil) then Wire_TriggerOutput(self, "Out", 0) end
        end
    end
end

local Data={name="Outdated Hydro Turbine",class="generator_energy_hydro",Out={"energy"},WireOut={"Out"},thinkfunc=Func,OutMake={0}}
Environments.Devices.RegisterDevice(Data)

----------------------------------------------------------------------
-------------------------Water Fuser----------------------------------
----------------------------------------------------------------------

local Func = function(self) if(self.Active==1)then Environments.Devices.ManageResources(self) end end
local Data={name="Outdated Water Fuser",class="generator_liquid_water2",In={"hydrogen","oxygen","energy"},Out={"water"},thinkfunc=Func,InUse={20,10,500},OutMake={10}}
Environments.Devices.RegisterDevice(Data)

----------------------------------------------------------------------
-------------------------Water Splitter-------------------------------
----------------------------------------------------------------------

local Func = function(self) if(self.Active==1)then Environments.Devices.ManageResources(self) end end
local Data={name="Outdated Water Splitter",class="generator_gas_o2h_water",In={"energy","water"},Out={"oxygen","hydrogen"},thinkfunc=Func,InUse={100,150},OutMake={75,100}}
Environments.Devices.RegisterDevice(Data)

----------------------------------------------------------------------
-------------------------Water Heater---------------------------------
----------------------------------------------------------------------

local Func = function(self) if(self.Active==1)then Environments.Devices.ManageResources(self) end end
local Data={name="Outdated Water Heater",class="generator_gas_steam",In={"energy","water"},Out={"steam"},thinkfunc=Func,InUse={500,80},OutMake={50}}
Environments.Devices.RegisterDevice(Data)

----------------------------------------------------------------------
-------------------------Steam Turbine--------------------------------
----------------------------------------------------------------------

local Func = function(self) if(self.Active==1)then Environments.Devices.ManageResources(self) end end
local Data={name="Outdated Steam Turbine",class="generator_energy_steam_turbine",In={"steam"},Out={"energy","water"},thinkfunc=Func,InUse={50},OutMake={100,15}}
Environments.Devices.RegisterDevice(Data)

----------------------------------------------------------------------
-------------------------Resource Cache-------------------------------
----------------------------------------------------------------------

local Data={name="OutDated Resource Cache",class="storage_cache",storage={"energy","water","oxygen","hydrogen","nitrogen","carbon dioxide","steam","Heavy Water"},Rates={[1601] = "carbon dioxide",[1600] = "oxygen",[1602] = "hydrogen",[1603] = "nitrogen",[1375] = "Heavy Water",[1599] = "water",[1598] = "steam",[1604] = "energy"}}
Environments.Devices.CompileStorage(Data,Inner)

----------------------------------------------------------------------
-------------------------Energy Storage==-----------------------------
----------------------------------------------------------------------

local Data={name="OutDated Energy Storage",class="storage_energy",storage={"energy"},Rates={[3600] = "energy"}}
Environments.Devices.CompileStorage(Data,Inner)

----------------------------------------------------------------------
-------------------------Gas Storage==-------------------------------
----------------------------------------------------------------------

local Data={name="OutDated Gas Storage",class="storage_gas",storage={"oxygen","carbon dioxide","hydrogen","nitrogen"},Rates={[1601] = "carbon dioxide",[1600] = "oxygen",[1602] = "hydrogen",[1603] = "nitrogen"}}
Environments.Devices.CompileStorage(Data,Inner)

----------------------------------------------------------------------
-------------------------Steam Storage==------------------------------
----------------------------------------------------------------------

local Data={name="OutDated Steam Storage",class="storage_gas_steam",storage={"steam"},Rates={[3600] = "steam"}}
Environments.Devices.CompileStorage(Data,Inner)

----------------------------------------------------------------------
-------------------------Heavy Water Storage==------------------------
----------------------------------------------------------------------

local Data={name="OutDated Heavy Water Storage",class="storage_liquid_hvywater",storage={"Heavy Water"},Rates={[2500] = "Heavy Water"}}
Environments.Devices.CompileStorage(Data,Inner)

----------------------------------------------------------------------
-------------------------Water Storage==------------------------------
----------------------------------------------------------------------

local Data={name="OutDated Water Storage",class="storage_liquid_water",storage={"water"},Rates={[3600] = "water"}}
Environments.Devices.CompileStorage(Data,Inner)





