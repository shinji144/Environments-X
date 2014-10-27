local SB_AIR_EMPTY = -1
local SB_AIR_O2 = 0
local SB_AIR_CO2 = 1
local SB_AIR_N = 2
local SB_AIR_H = 3
local SB_AIR_CH4 = 4
local SB_AIR_AR = 5

local Conversions = {}
Conversions["-1"] = "empty"
Conversions["0"] = "o2"
Conversions["1"] = "co2"
Conversions["2"] = "n"
Conversions["3"] = "h"

///////////////////////////////////////////////
//       Meta Table Stuff For Planets        //
///////////////////////////////////////////////

--localize
local math = math
local print = print
local pairs = pairs
local tostring = tostring

local function GetTotalPercent(atm)
	local total = 0
	for k,v in pairs(atm) do
		if k != "total" and k != "totalper" and k != "max" then
			total = total + v
		end
	end
	return total
end

function ENT:Create(gravity, atmosphere, pressure, temperature, gasses, name, total, originalco2per)
	//set Gravity if one is given
	self.gravity = gravity or 0
	
	//set atmosphere if given
	self.atmosphere = atmosphere or 1

	//set pressure if given
	self.pressure = pressure or math.Round(self.atmosphere * self.gravity)
	//print("ent:Create()", name, pressure, self.pressure)
	
	//set temperature if given
	self.temperature = temperature or 15
	
	local volume = (4/3) * math.pi * self.radius * self.radius
	self.atmosphere = atmosphere
	self.air = {}
	
	self.air.max = math.Round(100 * 5 * (volume/1000) * self.atmosphere)
	if !total then
		self.air.total = math.Round(self.air.max * (GetTotalPercent(gasses)/100)) --should set the total as the percent of max full, to fix empty planets from SB3
	else
		self.air.total = total
	end
	
	for k,v in pairs(gasses) do
		if v and type(v) == "number" and v > 0 then
			if v < 0 then v = 0 end
			if v > 100 then v = 100 end
			self.air[k.."per"] = v
			self.air[k] = math.Round((v/100)*self.air.total)
		else
			self.air[k.."per"] = 0
			self.air[k] = 0
		end
	end
	
	self.originalco2per = originalco2per or self.air.co2per
	
	self.name = name or "un-named"
	self.OldData.air = self.air
	self.OldData.originalco2per = self.originalco2per
	
	if self.Debugging then
		Msg("Initialized a new entity env: ", self, "\n")
		Msg("ID is: ", self.name, "\n")
		Msg("Dumping stats:\n")
		Msg("------------ START DUMP ------------\n")
		PrintTable(self.OldData)
		Msg("------------- END DUMP -------------\n\n")
	end
end


--self.air.max = total volume
--self.air.total = amount filled
function ENT:Convert(res1, res2, value)
	value = math.Round(value)

	if res1 == res2 then return 0 end
	if value < 1 then return 0 end
	if not value then return 0 end
	
	//LS3 Compatability
	if res1 == nil then res1 = "-1" end
	if res2 == nil then res2 = "-1" end
	if Conversions[tostring(res1)] then
		res1 = Conversions[tostring(res1)]
	end
	if Conversions[tostring(res2)] then
		res2 = Conversions[tostring(res2)]
	end
	
	--local before1 = self.air[res1] or 0
	--local before2 = self.air[res2] or 0
	
	if res1 != "empty" then
		if self.air[res1] < value then
			value = self.air[res1]
		end
	else
		//if value + self.air.total > self.air.max then
		//	value = self.air.max - self.air.total
		//end
	end
	--print("\nValue: "..value)
	
	//take out
	local ResourcePer1 = res1.."per"
	if res1 != "empty" then
		self.air[res1] = self.air[res1] - value --amount of resource
	else --we are adding stuff to the atmosphere
		self.air.total = self.air.total + value
	end
	
	//put in
	local ResourcePer2 = res2.."per"
	if res2 != "empty" then
		self.air[res2] = self.air[res2] + value --amount of resource
	else --we are pumping stuff out of the atmosphere
		self.air.total = self.air.total - value
	end
	
	for k,v in pairs(self.air) do --get percents
		if k == "o2per" or k == "co2per" or k == "emptyper" or k == "nper" or k == "hper" or k == "max" or k =="ch4per" or k=="arper" or k=="totalper" or k=="total" then
		else
			self.air[k.."per"] = self:GetResourcePercentage(k)
		end
	end
	--print(tostring(res1).." "..tostring(before1).." ===> "..tostring(self.air[res1] or 0), "Difference: "..((self.air[res1] or 0) - before1))
	--print(tostring(res2).." "..tostring(before2).." ===> "..tostring(self.air[res2] or 0), "Difference: "..((self.air[res2] or 0) - before2))
	
	//Get Value Calculations
	self.pressure = self.atmosphere * self.gravity * (self.air.total/self.air.max)
	
	//print("Pressure: "..self.pressure)
	return value
end

function ENT:GetResourcePercentage(res)
	if self.air.max == 0 then
		return 0
	end

	return ((self.air[res] / self.air.total) * 100)
end

//Basic LS3 Compatibility
function ENT:IsOnPlanet()
	return self
end

function ENT:GetAtmosphere()
	return self.atmosphere
end

function ENT:GetSize()
	return self.radius
end

function ENT:IsSpace()
	return false
end

function ENT:IsStar()
	return false
end

function ENT:IsEnvironment()
	return true
end

function ENT:IsPlanet()
	return true
end

function ENT:GetGravity()
	return self.gravity
end

function ENT:GetO2Percentage()
	return self.air.o2per
end

function ENT:GetCO2Percentage()
	return self.air.co2per
end

function ENT:GetNPercentage()
	return self.air.nper
end

function ENT:GetHPercentage()
	return self.air.hper
end

function ENT:GetEmptyAirPercentage()
	return self.air.emptyper
end

function ENT:GetPressure()
	return self.pressure
end

function ENT:GetTemperature()
	return self.temperature + ((self.temperature * (((self.air.co2/self.air.max)*100 - self.originalco2per)/100))/2)
end

function ENT:GetGravity()
	return self.gravity
end

function ENT:GetEnvironmentName()
	return self.name
end

function ENT:UpdateGravity(ent)

end

function ENT:UpdatePressure(ent)

end
