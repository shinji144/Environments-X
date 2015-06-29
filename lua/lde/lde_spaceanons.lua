LDE.Anons = {}
LDE.Anons.Anomalys = {}
LDE.Anons.Events = {}
LDE.Anons.Monitor = {}
LDE.Anons.PlanetScore = {}
LDE.Anons.ResourcePools = {}
LDE.Anons.Resources = {}
LDE.Anons.RefinedResoruces = {}

LDE.Anons.Resources["Raw Ore"] = { name = "Raw Ore", unit = " kg", base_density = 5.5, rarity = 3}
LDE.Anons.Resources["Crystalised Polylodarium"] = { name = "Crystalised Polylodarium", unit = " kg", base_density = 19.5, rarity = 15}

LDE.Anons.RefinedResoruces["Refined Ore"]= { name = "Refined Ore", unit = " kg" }
LDE.Anons.RefinedResoruces["Liquid Polylodarium"]= { name = "Liquid Polylodarium", unit = " L" }

local function MiningRegistration() 
	local function RegisterMiningResources(tbl)
		if not Environments.RegisterResource or not LDE.Anons.Resources or not tbl then return end -- uhm yeah.
			for k,v in pairs(tbl) do
			--Environments.RegisterResourceInfo(k,v.name,v.unit) -- register the resource info
			Environments.RegisterResource(k) -- register the Resource Name
		end
	end


	RegisterMiningResources(LDE.Anons.Resources)
	RegisterMiningResources(LDE.Anons.RefinedResoruces)
end
hook.Add("InitPostEntity","envMiningRegister",MiningRegistration)

function LDE.Anons.GetPlanetScores()
	for pid, planet in pairs(environments) do

		local pscore = 10 -- base planet score for resource rarity allowed
		-- run it through a filter increasing and decreasing score ( favor hostile environments )
		if (planet.air.o2per or 0) > 10 then pscore = pscore - 4 end
		if (planet.pressure or 0) < 1 then pscore = pscore + 2 end
		if (planet.gravity > 1) then pscore = pscore + planet.gravity end
		if (planet.air.co2per or 0) > 60 then pscore = pscore + 1 end
		if (planet.air.nper or 0) > 60 then pscore = pscore - 0.5 end
		if (planet.atmosphere or 0) < 1 then pscore = pscore + 2.5 end
		if (planet.temperature or 0) > 310 then pscore = pscore + 8 else pscore = pscore - 1 end
		if pscore < 1 then pscore = 1 end
		
		print(planet.name.." Score: "..pscore)
		LDE.Anons.PlanetScore[planet]=pscore
	end
end

local MaxPools = 4
function LDE.Anons:ManageUndergroundMinables()
	for pid, planet in pairs(environments) do
		LDE.Anons.ResourcePools[planet.name] = LDE.Anons.ResourcePools[planet.name] or {}
		
		--print("Checking Planet: "..planet.name)
		
		if table.Count(LDE.Anons.ResourcePools[planet.name])<MaxPools then
			local center = planet:GetPos() -- Get the center of it
			local radius = planet.radius -- get it's radius/size
			
			local pscore = LDE.Anons.PlanetScore[planet] or 0
			
			local tries,respos = 200,center
			while tries > 0 do -- attempt to find an open spot but don't waste too much time
				local tracedata = {} -- setup and perform a trace to find some open ground.
				local r = radius * 0.65
				local x,y = math.random(-r,r),math.random(-r,r)
				
				tracedata.start = center + Vector( x ,y ,0) + Vector(0,0,1) * 6e3
				tracedata.endpos = tracedata.start - Vector(0,0,1) * 1e6
				traceres = util.TraceLine(tracedata)
				
				-- Todo: modify this below to also handle certain material types if displacements aren't used on planets.
				if (traceres.HitTexture == "**displacement**") then -- oh good found a spot
					respos = traceres.HitPos
					break
				end
				-- try try again.
				tries = tries - 1
			end
			
			-- Looks like we found a valid point spawn a resource pool.
			if tries > 0 and respos ~= center then
				
				Distance = respos:Distance(center) -- our distance from the core of the planet
				Depth =  72 + math.random(1, math.Round( ( math.pi^2*radius) / math.sqrt( Distance ),0) ) -- semirandom depth based on distance
				Size =  math.random(5, math.Clamp( Depth * radius / Distance*0.25,0,math.sqrt(radius * 500 + Distance) ) )
				respos = respos - Vector(0,0,Depth) -- Set final resource position.
				
				--Attempt to find a mineral within rarity tollerences.
				
				local Res = ""
				for res,dat in pairs(LDE.Anons.Resources) do
					if pscore >= dat.rarity then
						Res = res
					end
				end
				
				-- If we found one that is allowed here go ahead and spawn it, otherwise abort
				if Res~="" then
					-- don't spawn on top of each other!!!
					proximity = ents.FindByClass("resource_pool")
					for k,v in pairs(proximity) do
						local rad,dist = v.radius, respos:Distance(v:GetPos())
						if (dist <= rad * 6) or (dist <= Size * 6)  then return end 
					end
					print("spawning resource pool "..Res.." on planet: "..tostring(planet.name))
					-- create a resource pool.
					pool = ents.Create("resource_pool")
					pool:SetPoolSize(Size)
					pool:SetDepth(Depth)
					pool:SetPoolVolume()
					pool:SetResource(Res)
					pool:CalcResource()
					pool.planetname = planet.name
					pool:SetPos(respos)
					pool:Spawn()
					
					LDE.Anons.ResourcePools[planet.name][pool] = pool
				end
			else
				--print(planet.name.." no a valid spawn point found....")
			end
		else
		--	print(planet.name.." has too many resource pools!")
		end
	end
end

---Random Point in space spawn function.
function LDE.Anons:PointInSpace(Data)
	local Point = VectorRand()*16384
	local Min = 12000
	if(Data.Dist)then
		Min = Data.Dist.Min or Min
	end
	while true do	
		local inplanet = false
		if environments then
			inplanet = false
			for _, p in pairs(environments) do
				local Distance = Point:Distance(p:GetPos())
				if ( Distance < Min) then
					inplanet = true
				end
			end
		end
		if util.IsInWorld(Point) and not inplanet then
			return Point
		else
			Point = VectorRand()*16384
		end
	end
end

---Random Point around a planet.
function LDE.Anons:PointInSpecificOrbit(planet,Data,Ent)
	local center = planet:GetPos() -- Get the center of it
	local radius = planet.radius -- get it's radius/size
	local Min,Max = 400,800
	if(Data.Dist)then
		Min = Data.Dist.Min or Min
		Max = Data.Dist.Max or Max
	end
	local Trys = 500
	while Trys > 0 do --Only try so many times in one go.
		local inorbit = false
		local r = radius+math.random(Min,Max)
		local x,y = math.random(-r,r),math.random(-r,r)
		Point = center + Vector( x ,y ,math.random(-100,100))
		
		local Distance = Point:Distance(center)
		
		if ( Distance > radius+Min) then
			inorbit = true
		end
		
		if(Data.PlanetNeeds)then
			if(not Data.PlanetNeeds(planet))then --Check if the anomaly were spawning likes the planet were using.
				inorbit = false
			end
		end
		
		if util.IsInWorld(Point) and inorbit then
			if(Ent and Ent:IsValid())then
				Ent.Planet = planet
			end
			return Point
		end
		Trys=Trys-1
	end	
end

---Random Point around a random planet.
function LDE.Anons:PointInOrbit(Data,Ent)
	local planet = environments[math.random(1,#environments)]
	if not planet or not IsValid(planet) then return false end
	local center = planet:GetPos() -- Get the center of it
	local radius = planet.radius -- get it's radius/size
	local Min,Max = 400,800
	if(Data.Dist)then
		Min = Data.Dist.Min or Min
		Max = Data.Dist.Max or Max
	end
	local Trys = 500
	while Trys > 0 do --Only try so many times in one go.
		local inorbit = false
		local r = radius+math.random(Min,Max)
		local x,y = math.random(-r,r),math.random(-r,r)
		Point = center + Vector( x ,y ,math.random(-100,100))
		
		local Distance = Point:Distance(center)
		
		if ( Distance > radius+Min) then
			inorbit = true
		end
		
		if(Data.PlanetNeeds)then
			if(not Data.PlanetNeeds(planet))then --Check if the anomaly were spawning likes the planet were using.
				inorbit = false
			end
		end
		
		if util.IsInWorld(Point) and inorbit then
			if(Ent and Ent:IsValid())then
				Ent.Planet = planet
			end
			return Point
		else
			planet = environments[math.random(1,#environments)]
			center = planet:GetPos() -- Get the center of it
			radius = planet.radius -- get it's radius/size
		end
		Trys=Trys-1
	end	
end

--Random Point on a planet.
function LDE.Anons:PointOnPlanet(planet,Data)
	if(not planet)then return end
	--local planet = environments[math.random(1,#environments)]
	local center = planet:GetPos() -- Get the center of it
	local radius = planet.radius -- get it's radius/size

	local tracedata = {} -- setup and perform a trace to find some open ground.
	local r = radius * 0.65
	local x,y = math.random(-r,r),math.random(-r,r)
	
	tracedata.start = center + Vector( x ,y ,0) + Vector(0,0,1) * 3e3 --Used to be 6e3 but that caused minor problems involving planets close to the top of a map.
	tracedata.endpos = tracedata.start - Vector(0,0,1) * 1e6
	traceres = util.TraceLine(tracedata)
	
	return traceres.HitPos
end

--For those who want "special" planets
function LDE.Anons:FindPlanetClass(Data)
	--print("Searching Planets.")
	for pid, p in pairs(environments) do
		--print("Scanning "..pid)
		if(Data(p))then
			--print("Planet Located.")
			return p
		end
	end
	--print("Planet not found!")
end

--Incase you want a table of valid planets.
function LDE.Anons:FindPlanetsClass(Data)
	--print("Searching Planets.")
	local Planets = {}
	for pid, p in pairs(environments) do
		--print("Scanning "..pid)
		if(Data(p))then
			--print("Adding Planet to valid list.")
			table.insert( Planets, p )
		end
	end
	
	return Planets
	--print("Planet not found!")
end

------------One time spawn functions-----------

--Lets spawn all our initial anomalys here.
function LDE.Anons:SpawnStartAnons()
	print("Spawning starter anomaly.")
	for pid, p in pairs(LDE.Anons.Anomalys) do
		print("-------Dealing with "..pid)
		for cid, c in pairs(p) do
			print("Anomaly of "..cid)
			if(c.Initial)then
				print(cid.." is a initial spawned anomaly, spawning it now.")
				c.SpawnMe()
			end
		end
	end
end

----------------------------------------------

function LDE.Anons:RegisterEvent(Data)

end

function LDE.Anons:RegisterAnomaly(Data)
	if(!Data or !Data.Type)then return end
	if(Data.minimal and Data.minimal>0)then
		LDE.Anons.Monitor[Data.name]=Data
	end
	print("Space Anons: Registered "..Data.name.." as an "..Data.Type)
	if(!LDE.Anons.Anomalys[Data.Type])then LDE.Anons.Anomalys[Data.Type] ={} end
	LDE.Anons.Anomalys[Data.Type][Data.name]=Data
end

function LDE.Anons:RandomEventManger()

end

function LDE.Anons:MonitorAnomalyCounts()
	for _, anon in pairs( LDE.Anons.Monitor ) do
		--print("Space Anon: Monitoring "..anon.name)
		if(table.Count(ents.FindByClass(anon.class))<anon.minimal)then
			--print("Spawning a "..anon.name)
			anon.SpawnMe()
		end
	end
end

//Base Code for anomalys.
function LDE.Anons.GenerateAnomaly(Data)
	LDE.Anons:RegisterAnomaly(Data)
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_gmodentity"
	ENT.PrintName = Data.name
	ENT.Spawnable			= false
	ENT.AdminSpawnable		= true
	
	ENT.Data = Data
	
	if SERVER then
		if(Data.Server)then
			Data.Server(ENT)
		end
		function ENT:Initialize()   
		
			if(self.Data.Startup)then
				self.Data.Startup(self)
			end
			
			self:CPPISetOwnerless(true)
			
			self.LastTime=0
		end		
		
		function ENT:SpawnSetup(Data)
			self.Data.SpawnMe(self,Data)
		end
		
		function ENT:OnTakeDamage(dmg)
			if(self.Data.OnDmg)then
				self.Data.OnDmg(self,dmg)
			end
		end	
		
		function ENT:Touch(activator)
			if(self.Data.Touch)then
				self.Data.Touch(self,activator)
			end
		end
		
		function ENT:PhysicsCollide(ent)
			if(self.Data.Collide)then
				self.Data.Collide(self,activator)
			end
		end

		function ENT:Think()
			if(self.Data.Think)then
				local Time = self.LastTime or 0
				if(CurTime()>=Time+self.Data.ThinkSpeed)then
					self.LastTime=CurTime()
					self.Data.Think(self)
				end
			end
			self:NextThink(CurTime() + 0.05)
			return true
		end
		
	else
		if(Data.Client)then
			Data.Client(ENT)
		end
		--Client stuff ;)
	end
	scripted_ents.Register(ENT, Data.class, true, false)
end

local Files
if file.FindInLua then
	Files = file.FindInLua( "lde/anomalys/*.lua" )
else//gm13
	Files = file.Find("lde/anomalys/*.lua", "LUA")
end

--Get the weapon data from the lifesupport folder.
for k, File in ipairs(Files) do
	Msg("*LDE Space Anomaly System Loading: "..File.."...\n")
	local ErrorCheck, PCallError = pcall(include, "lde/anomalys/"..File)
	ErrorCheck, PCallError = pcall(AddCSLuaFile, "lde/anomalys/"..File)
	if !ErrorCheck then
		Msg(PCallError.."\n")
	end
end
Msg("LDE Space Anomaly System Loaded: Successfully\n")

local NT = 0
if(SERVER)then
	function AnonThink()
		--print("Space Anons Thinking")
		LDE.Anons:MonitorAnomalyCounts()
		LDE.Anons:ManageUndergroundMinables()
	end
	timer.Create("AnonThink", 5,0, AnonThink)--5
	
	local StartupAnons = function() 
		LDE.Anons.GetPlanetScores() 
		LDE.Anons:SpawnStartAnons() 
	end 
	
	timer.Create("AnonInitialSpawn", 5,1, StartupAnons)--1
end


LDE.Anons.Installed = 1
