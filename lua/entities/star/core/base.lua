local SB_AIR_EMPTY = -1
local SB_AIR_O2 = 0
local SB_AIR_CO2 = 1
local SB_AIR_N = 2
local SB_AIR_H = 3
local SB_AIR_CH4 = 4
local SB_AIR_AR = 5

///////////////////////////////////////////////
//       Meta Table Stuff For Planets        //
///////////////////////////////////////////////

function ENT:Convert(air1, air2, value)
	
	--if not air1 or not air2 or not value then return 0 end
	--if type(air1) != "number" or type(air2) != "number" or type(value) != "number" then return 0 end 
	air1 = math.Round(air1)
	air2 = math.Round(air2)
	value = math.Round(value)
	if air1 < -1 or air1 > 4 then return 0 end
	if air2 < -1 or air2 > 4 then return 0 end
	if air1 == air2 then return 0 end
	if value < 1 then return 0 end
	/*if server_settings.Bool( "SB_StaticEnvironment" ) then
		return value;
		//Don't do anything else anymore
	end*/
	/*if air1 == -1 then
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
		self.air[k.."per"] = self:GetResourcePercentage(k)
	end
	if air1 or air2 == 1 then
		self.temperature = self.temperature + (( self.temperature * ((self.air.co2per - self.original.air.co2per)/100))/2)
	end
	if air1 or air2 == 4 then
		self.temperature = self.temperature + (( self.temperature * ((self.air.ch4per - self.original.air.ch4per)/100))/2)
	end*/
	return value
end

function ENT:GetBreathable()
	if self.air.arper >= 5 then
		return false
	end
	return true
end

function ENT:GetResourcePercentage(res)
	--if not res or type(res) == "number" then return 0 end
	if self.air.max == 0 then
		return 0
	end
	--local ignore = {"o2per", "co2per", "nper", "hper", "emptyper", "max", "nhper"}
	--if table.HasValue(ignore, res) then return 0 end
	return ((self.air[res] / self.air.max) * 100)
end

//Basic LS3 Compatibility
function ENT:IsOnPlanet()
	return self
end

function ENT:GetAtmosphere()
	return self.atmosphere or 1
end

function ENT:IsSpace()
	return false
end

function ENT:IsStar()
	return true
end

function ENT:IsEnvironment()
	return true
end

function ENT:IsPlanet()
	return false
end

function ENT:GetGravity()
	return self.gravity
end
