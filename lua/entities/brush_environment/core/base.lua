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

--self.air.max = total volume
--self.air.total = amount filled
function ENT:Convert(res1, res2, value)
	value = math.Round(value)

	if res1 == res2 then return 0 end
	if value < 1 then return 0 end
	
	//LS3 Compatability
	if res1 == nil then res1 = "-1" end
	if res2 == nil then res2 = "-1" end
	if Conversions[tostring(res1)] then
		res1 = Conversions[tostring(res1)]
	end
	if Conversions[tostring(res2)] then
		res2 = Conversions[tostring(res2)]
	end
	
	--local before1 = self.air[res1]
	--local before2 = self.air[res2]
	
	if res1 != "empty" then
		if self.air[res1] < value then
			value = self.air[res1]
		end
	else
		if value + self.air.total > self.air.max then
			value = self.air.max - self.air.total
		end
	end
	--print("Value: "..value)
	
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
	--print(tostring(res1).." "..tostring(before1).." ===> "..tostring(self.air[res1]), "Difference: "..(self.air[res1] - before1))
	--print(tostring(res2).." "..tostring(before2).." ===> "..tostring(self.air[res2]), "Difference: "..(self.air[res2] - before2))
	
	//Get Value Calculations
	self.pressure = self.atmosphere * self.gravity * (self.air.total/self.air.max)
	
	--print("Pressure: "..self.pressure)
	return value
end

/*function ENT:Convert(air1, air2, value) --old one
	--print(air1,air2,value)
	--if not air1 or not air2 or not value then return 0 end
	--if type(air1) != "number" or type(air2) != "number" or type(value) != "number" then return 0 end 
	air1 = math.Round(air1)
	air2 = math.Round(air2)
	value = math.Round(value)
	if air1 < -1 or air1 > 5 then return 0 end
	if air2 < -1 or air2 > 5 then return 0 end
	if air1 == air2 then return 0 end
	if value < 1 then return 0 end

	if air1 == -1 then
		--print("empty")
		if self.air.empty < value then
			value = self.air.empty
		end
		self.air.empty = self.air.empty - value
		if air2 == SB_AIR_CO2 then
			self.air.co2 = self.air.co2 + value
		elseif air2 == SB_AIR_N then
			self.air.n = self.air.n + value
		elseif air2 == SB_AIR_H then
			self.air.h = self.air.h + value
		elseif air2 == SB_AIR_CH4 then
			self.air.ch4 = self.air.ch4 + value
		elseif air2 == SB_AIR_AR then
			self.air.ar = self.air.ar + value
		elseif air2 == SB_AIR_O2 then
			self.air.o2 = self.air.o2 + value
		end
	elseif air1 == SB_AIR_O2 then
		--print("o2")
		if self.air.o2 < value then
			value = self.air.o2
		end
		self.air.o2 = self.air.o2 - value
		if air2 == SB_AIR_CO2 then
			self.air.co2 = self.air.co2 + value
		elseif air2 == SB_AIR_N then
			self.air.n = self.air.n + value
		elseif air2 == SB_AIR_H then
			self.air.h = self.air.h + value
		elseif air2 == SB_AIR_CH4 then
			self.air.ch4 = self.air.ch4 + value
		elseif air2 == SB_AIR_AR then
			self.air.ar = self.air.ar + value
		elseif air2 == -1 then
			self.air.empty = self.air.empty + value
		end
	elseif air1 == SB_AIR_CO2 then
		--print("co2")
		if self.air.co2 < value then
			value = self.air.co2
		end
		self.air.co2 = self.air.co2 - value
		if air2 == SB_AIR_O2 then
			self.air.o2 = self.air.o2 + value
		elseif air2 == SB_AIR_N then
			self.air.n = self.air.n + value
		elseif air2 == SB_AIR_H then
			self.air.h = self.air.h + value
		elseif air2 == SB_AIR_AR then
			self.air.ar = self.air.ar + value
		elseif air2 == SB_AIR_CH4 then
			self.air.ch4 = self.air.ch4 + value
		elseif air2 == -1 then
			self.air.empty = self.air.empty + value
		end
	elseif air1 == SB_AIR_N then
		--print("n")
		if self.air.n < value then
			value = self.air.n
		end
		self.air.n = self.air.n - value
		if air2 == SB_AIR_O2 then
			self.air.o2 = self.air.o2 + value
		elseif air2 == SB_AIR_CO2 then
			self.air.co2 = self.air.co2 + value
		elseif air2 == SB_AIR_H then
			self.air.h = self.air.h + value
		elseif air2 == SB_AIR_AR then
			self.air.ar = self.air.ar + value
		elseif air2 == SB_AIR_CH4 then
			self.air.ch4 = self.air.ch4 + value
		elseif air2 == -1 then
			self.air.empty = self.air.empty + value
		end
	elseif air1 == SB_AIR_CH4 then
		print("Ch4")
		if self.air.ch4 < value then
			value = self.air.ch4
		end
		self.air.ch4 = self.air.ch4 - value
		if air2 == SB_AIR_O2 then
			self.air.o2 = self.air.o2 + value
		elseif air2 == SB_AIR_CO2 then
			self.air.co2 = self.air.co2 + value
		elseif air2 == SB_AIR_H then
			self.air.h = self.air.h + value
		elseif air2 == SB_AIR_N then
			self.air.n = self.air.n + value
		elseif air2 == SB_AIR_AR then
			self.air.ar = self.air.ar + value
		elseif air2 == -1 then
			self.air.empty = self.air.empty + value
		end
	elseif air1 == SB_AIR_AR then
		--print("AR")
		if self.air.ar < value then
			value = self.air.ar
		end
		self.air.ar = self.air.ar - value
		if air2 == SB_AIR_O2 then
			self.air.o2 = self.air.o2 + value
		elseif air2 == SB_AIR_CO2 then
			self.air.co2 = self.air.co2 + value
		elseif air2 == SB_AIR_H then
			self.air.h = self.air.h + value
		elseif air2 == SB_AIR_N then
			self.air.n = self.air.n + value
		elseif air2 == SB_AIR_AR then
			self.air.ar = self.air.ar + value
		elseif air2 == -1 then
			self.air.empty = self.air.empty + value
		end
	else
		--print("else")
		if self.air.h < value then
			value = self.air.h
		end
		self.air.h = self.air.h - value
		if air2 == SB_AIR_O2 then
			self.air.o2 = self.air.o2 + value
		elseif air2 == SB_AIR_CO2 then
			self.air.co2 = self.air.co2 + value
		elseif air2 == SB_AIR_N then
			self.air.n = self.air.n + value
		elseif air2 == SB_AIR_CH4 then
			self.air.ch4 = self.air.ch4 + value
		elseif air2 == SB_AIR_AR then
			self.air.ar = self.air.ar + value
		elseif air2 == -1 then
			self.air.empty = self.air.empty + value
		end
	end
	for k,v in pairs(self.air) do
		if k == "o2per" or k == "co2per" or k == "emptyper" or k == "nper" or k == "hper" or k == "max" or k =="ch4per" or k=="arper" then
		else
			self.air[k.."per"] = self:GetResourcePercentage(k)
		end
	end
	self.pressure = self.atmosphere * self.gravity * (1 - (self.air.emptyper/100))

	--self:GetBreathable()
	--print(value)
	return value
end*/

/*function ENT:GetBreathable()
	if self.air.arper >= 5 then
		self.breathable = false
		return false
	end
	self.breathable = true
	return true
end*/

/*function ENT:GetResourcePercentage(res) --old
	--if not res or type(res) == "number" then return 0 end
	if self.air.max == 0 then
		return 0
	end
	--local ignore = {"o2per", "co2per", "nper", "hper", "emptyper", "max", "nhper"}
	--if table.HasValue(ignore, res) then return 0 end
	return ((self.air[res] / self.air.max) * 100)
end*/

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
	return 512--self.radius
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
