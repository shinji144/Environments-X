------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

--localize
local math = math
local table = table
local ents = ents
local pairs = pairs
local tonumber = tonumber
local type = type

//Custom Locals
local Environments = Environments
local Space = Space

local SB_AIR_EMPTY = -1
local SB_AIR_O2 = 0
local SB_AIR_CO2 = 1
local SB_AIR_N = 2
local SB_AIR_H = 3
local SB_AIR_CH4 = 4
local SB_AIR_AR = 5


local function Extract_Bit(bit, field)
	if not bit or not field then return false end
	local retval = 0
	if ((field <= 7) and (bit <= 4)) then
		if (field >= 4) then
			field = field - 4
			if (bit == 4) then return true end
		end
		if (field >= 2) then
			field = field - 2
			if (bit == 2) then return true end
		end
		if (field >= 1) then
			field = field - 1
			if (bit == 1) then return true end
		end
	end
	return false
end

local function GetFlags(flags)
	if not flags or type(flags) != "number" then return end
	local habitat = Extract_Bit(1, flags)
	local unstable = Extract_Bit(2, flags)
	local sunburn = Extract_Bit(3, flags) 
	--print(habitat, unstable, sunburn)
	return habitat, unstable, sunburn
end

local function GetSB3Flags(flags)
	if not flags or type(flags) != "number" then return end
	local unstable = Extract_Bit(1, flags)
	local sunburn = Extract_Bit(2, flags) 
	return unstable, sunburn
end

local function GetVolume(radius)
	return (4/3) * math.pi * radius * radius
end

local function GetTotalPercent(atm)
	local total = 0
	for k,v in pairs(atm) do
		if k != "total" then
			total = total + v
		end
	end
	return total
end

function Environments.ParseSaveData(planet)	--only really checks the atmosphere
	local self = {}
	self.atmosphere = planet.atm
	self.air = {}
	
	self.total = planet.atmosphere.total
	
	for k,v in pairs(planet.atmosphere) do
		self.air[k] = math.Round(tonumber(v) or 0, 2)
	end
	
	local total = GetTotalPercent(self.air)
	if total < 1 then --bug fixed, should get rid of
		print("LESS THAN 1% on "..planet.name)
	elseif total > 100 then
		print("MORE THAN 100% on "..planet.name)
	elseif total < 100 then
		print("LESS THAN 100% on "..planet.name)
	else
		print("OK on "..planet.name)
	end
	
	return self
end

//Actually creates it
function Environments.CreatePlanet(d)
	local planet = nil
	
	//Different Type Support
	if d.typeof == "SB3" then
		planet = ents.Create("Environment")
		planet:Spawn()
		planet:SetPos(d.position)
		planet:Configure(d.radius, d.gravity, d.name, d)
		planet:Create(d.gravity, d.atmosphere, d.pressure, d.temperature, d.air, d.name, d.total, d.originalco2per)
	elseif d.typeof == "SB2" then
		planet = ents.Create("Environment")
		planet:Spawn()
		planet:SetPos(d.position)
		planet:Configure(d.radius, d.gravity, d.name, d)
		planet:Create(d.gravity, d.atmosphere, d.pressure, d.temperature, d.air, d.name, d.total, d.originalco2per)
	else
		if d.typeof then
			print("NOT A VALID TYPE: "..d.typeof)
		else
			print("ENVIRONMENT TYPE IS NIL!")
		end
	end
	
	if planet then
		//stop it from getting removed
		planet.Delete = planet.Remove
		planet.Remove = function(d) 
			Environments.Log("Something Attempted to Remove Planet "..d.name)
		end
		
		table.insert(environments, planet)
	else
		print("CREATED PLANET WAS NIL, OR PLANET WAS NOT CREATED!")
	end
end

//parses the data from the map loading
function Environments.ParsePlanet(planet)
	local gravity = planet.gravity
	local o2 = planet.atmosphere.o2
	local co2 = planet.atmosphere.co2
	local n = planet.atmosphere.n
	local h = planet.atmosphere.h
	local ch4 = planet.atmosphere.ch4
	local ar = planet.atmosphere.ar
	local temperature = planet.temperature
	local suntemperature = planet.suntemperature
	local atmosphere = planet.atm
	local radius = planet.radius
	local volume = GetVolume(radius)
	local unstable =  planet.unstable
	local sunburn = planet.sunburn
	
	if planet.flags then
		unstable, sunburn = GetSB3Flags(planet.flags)
	end
	
	local self = {}
	self.radius = radius
	self.position = planet.position
	self.typeof = planet.typeof

	self.unstable = unstable
	self.sunburn = sunburn
	self.bloomid = planet.bloomid
	self.colorid = planet.colorid
	
	if gravity and type(gravity) == "number" then
		if gravity < 0 then
			gravity = 0
		end
		self.gravity = gravity
	end
	//set atmosphere if given
	if atmosphere and type(atmosphere) == "number" then
		if atmosphere < 0 then
			atmosphere = 0
		elseif atmosphere > 1 then
			atmosphere = 1
		end
		self.atmosphere = atmosphere
	end
	//set pressure if given
	if pressure and type(pressure) == "number" and pressure >= 0 then
		self.pressure = pressure
	else 
		self.pressure = math.Round(self.atmosphere * self.gravity)
	end
	//set temperature if given
	if temperature and type(temperature) == "number" then
		if temperature < 35 then
			temperature = 35
		end
		self.temperature = temperature
	end
	//set suntemperature if given
	if suntemperature and type(suntemperature) == "number" then
		if suntemperature < 35 then
			suntemperature = 35
		end
		self.suntemperature = suntemperature
	end
	
	self.air = {}

	for k,v in pairs(planet.atmosphere) do
		self.air[k] = v
	end
	
	if o2 + co2 + n + h + ch4 + ar < 1 then --FIXED :D (barren planets, what to do here? this breaks venting)
		print("LESS THAN 1% on "..planet.name)
	elseif o2 + co2 + n + h + ch4 + ar > 100 then
		print("MORE THAN 100% on "..planet.name)
	elseif o2 + co2 + n + h + ch4 + ar < 100 then
		print("LESS THAN 100% on "..planet.name)
	else
		print("OK on "..planet.name)
	end
	
	if planet.name then
		self.name = planet.name
	end

	--self.pressure = self.atmosphere * self.gravity * (1 - (self.air.emptyper/100))
	self.originalco2per = self.air.co2per
	
	return self
end

//Borrowed from SB3
function Environments.ParseSB2Environment(planet)
	local habitat, unstable, sunburn = GetFlags(planet.flags)
	planet.flags = nil

	//set Radius if one is given
	if planet.radius and type(radius) == "number" then
		if planet.radius < 0 then
			planet.radius = 0
		end
	end
	//set temperature2 if given
	if habitat then //Based on values for earth
		planet.atmosphere.o2 = 21
		planet.atmosphere.co2 = 0.45
		planet.atmosphere.n = 78
		planet.atmosphere.h = 0.55
	else //Based on values for Venus
		planet.atmosphere.o2 = 0
		planet.atmosphere.co2 = 96.5
		planet.atmosphere.n = 3.5
		planet.atmosphere.h = 0
	end
	planet.sunburn = sunburn
	planet.unstable = unstable
	return planet
end
//End Borrowed code

function Environments.ParseStar(planet)
	local self = {}
	self.radius = planet.radius
	self.position = planet.position
	self.typeof = planet.typeof
	self.name = planet.name
	self.temperature = planet.temperature
	self.isstar = true
	self.gravity = 0 --planet.gravity
	self.air = {}
	self.air.o2per = 0
	return self
end

function Environments.CreateStar(planet)
	local star = ents.Create("Star")
	star:Spawn()
	star:SetPos(planet.position)
	star:Configure(planet.radius, planet.gravity, planet.name, planet)
	
	table.insert(environments, star)
end
