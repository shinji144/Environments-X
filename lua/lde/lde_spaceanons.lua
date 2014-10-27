LDE.Anons = {}
LDE.Anons.Anomalys = {}
LDE.Anons.Events = {}
LDE.Anons.Monitor ={}

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
			
			if(NADMOD)then
				NADMOD.SetOwnerWorld(self)
			end
			
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
	end
	timer.Create("AnonThink", 5,0, AnonThink)
	
	local StartupAnons = function() LDE.Anons:SpawnStartAnons() end 
	
	timer.Create("AnonInitialSpawn", 10,1, StartupAnons)
end


LDE.Anons.Installed = 1
