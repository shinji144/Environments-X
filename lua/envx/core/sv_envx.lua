------------------------------------------
//   Environments  //
//   CmdrMatthew   //
------------------------------------------

--localize
--loser xD http://steamcommunity.com/id/AlauraLoveless/
local math = math
local hook = hook
local game = game
local util = util
local file = file
local table = table
local timer = timer
local umsg = umsg
local ents = ents
local string = string
local os = os
local tonumber = tonumber
local pcall = pcall
local print = print
local type = type
local pairs = pairs
local Angle = Angle
local Vector = Vector
local SysTime = SysTime

//Custom Locals
local Environments = Environments

UseEnvironments = false

local EnvironmentDebugCount = 0 --used to check if a planet is missing

local AllowNoClip = CreateConVar( "env_noclip", "0", FCVAR_NOTIFY )

//Table of all Environments
environments = {}
stars = {}

//Planet Default Atmospheres
default = {}
default.atmosphere = {}
default.atmosphere.o2 = 30
default.atmosphere.co2 = 5
default.atmosphere.ch4 = 0
default.atmosphere.n = 50
default.atmosphere.h = 15
default.atmosphere.ar = 0

//add a new Environments "Lite" mode that only checks players and stuff in a method similar to SB3, should be able to be turned on and off at will
//USE THIS TO MAKE SURE THE PLAYER'S EVN IS A VALID ONE
local meta = {} 
local function NewEnvironment(ent) --new metatable based environments, should have fewer problems than entities alone
	local tab = {}
	
	
	setmetatable(tab, meta)
end

function Environments.ShutDown() --wip, add a new system for hook creation, a table filled with the hooks that gets created at startup, or destroyed at shutdown
	if not ply:IsAdmin() then return end
	for k,v in pairs(environments) do
		if v and v:IsValid() then
			v:Remove()
			v = nil
		else
			v = nil
		end
	end
	environments = {}
	
	//Remove Hooks
	hook.Remove("PlayerNoClip","EnvNoClip")
	hook.Remove("PlayerInitialSpawn","CreateLS")
	hook.Remove("PlayerInitialSpawn","CreateEnvironemtns")
	hook.Remove("PlayerSpawn", "SpawnLS")
	hook.Remove("PlayerDeath", "ZgRagdoll")
end

local function LoadEnvironments()
	local start = SysTime()
	print("/////////////////////////////////////")
	print("//       Loading Environments      //")
	print("/////////////////////////////////////")
	print("// Adding Environments..           //")
	local status, error = pcall(function() --log errors
	--Get All Planets Loaded
	if INFMAP then print("INFINITE MAP SYSTEM DETECTED!") --detect our map/system
		print("LOADING ENVIRONMENTS AS SUCH") 
	end
	Environments.RegisterEnvironments() 
	if UseEnvironments then --It is a spacebuild map
		//Add Hooks
		hook.Add("PlayerNoClip","EnvNoClip", Environments.Hooks.NoClip)
		hook.Add("PlayerInitialSpawn","CreateLS", Environments.Hooks.LSInitSpawn)
		hook.Add("PlayerInitialSpawn","CreateEnvironemtns", Environments.SendInfo)
		hook.Add("PlayerSpawn", "SpawnLS", Environments.Hooks.LSSpawn)
		hook.Add("PlayerDeath", "ZgRagdoll", Environments.Hooks.PlayerDeath)

		hook.Add( "OnEntityCreated", "EnvEntSpawn", Environments.Hooks.OnEntitySpawned)
		
		//Fixes cleanup breaking everything :D
		local o = game.CleanUpMap
		function game.CleanUpMap(b, filters)
			if filters then
				table.insert(filters, "environment")
				table.insert(filters, "star")
			else
				filters = {"environment", "star"}
			end
			o(b, filters)
		end
			
		print("// Registering Sun..               //")
		Environments.RegisterSun()
			
		print("// Starting Periodicals..          //")
		timer.Create("EnvEvents", 15, 0, Environments.EventChecker)
		timer.Create("EnvSpecial", 10, 0, Environments.SpecialEvents)
		print("//   Event System Started          //")
		timer.Create("LSCheck", 1, 0, Environments.LSCheck)
		print("//   LifeSupport Checker Started   //")
	else --Not a spacebuild map
		print("//   This is not a valid space map //")
		if GAMEMODE.IsSandboxDerived and Environments.ForceLoad then
			print("//     Doing Partial Startup       //")
			--hook.Add("PlayerNoClip","EnvNoClip", Environments.Hooks.NoClip)
			hook.Add("PlayerInitialSpawn","CreateLS", Environments.Hooks.LSInitSpawnDry)
			--hook.Add("PlayerInitialSpawn","CreateEnvironemtns", Environments.SendInfo)
			hook.Add("PlayerSpawn", "SpawnLS", Environments.Hooks.LSSpawn)
			timer.Create("LSCheck", 1, 0, Environments.LSCheck)
		else
			print("//     Startup Aborted             //")
		end
	end end)--ends the error checker
	
	if not error then
		print("/////////////////////////////////////")
		print("//       Environments Loaded       //")
		print("/////////////////////////////////////")
	else
		print("/////////////////////////////////////")
		print("//    Environments Load Failed     //")
		print("/////////////////////////////////////")
		print("ERROR: "..error)
	end
	if Environments.Debug then
		print("Environments Server Startup Time: "..(SysTime() - start))
	end
end
hook.Add("InitPostEntity","EnvLoad", LoadEnvironments)

function Environments.Hooks.OnEntitySpawned(ent)--Entity Spawn hook.
	if ent:IsValid() and not ent:IsWeapon() then
		timer.Simple( 0.25, function()  
			if(not ent or not ent:IsValid())then return end 
			Environments.SpawnedFilter( ent ) 
		end)  --Need the timer or the ent will be detect as the base class and with no model.
	end
end 

function Environments.SpawnedFilter(ent) --Because the hook finds EVERYTHING, lets filter out some usless junk 	
	if not ent:IsValid() then return false end
    if ent:GetClass() == "gmod_ghost" then return false end	
    if ent:GetSolid() == SOLID_NONE then return false end
    if ent:IsNPC() then return false end
	if ent.IsEnvironment then return false end
	
	Environments.EntSpawned( ent ) --Anything not filtered goes to the spawned function,
end

function Environments.EntSpawned(ent)	
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end
	
	local Planet = Environments.FindEnvironmentOnPos(ent:GetPos())
	if Planet and Planet:IsValid() then 
		Planet:StartTouch(ent)
	else
		EnvX.SpaceEntity(ent)
	end
	ent.environment = Planet or Space()
end

function Environments.GetMapEntities() --use this rather than whats in Environments.LoadFromMap()
	local entities = ents.FindByClass( "logic_case" )
	Environments.MapEntities = {}
	Environments.MapEntities.Color = {}
	Environments.MapEntities.Bloom = {}
	for k,ent in pairs(entities) do
		local values = ent:GetKeyValues()
		local tab = ent:GetKeyValues()
		if( tab.Case01 == "planet_color" ) then
			table.insert( Environments.MapEntities.Color, {
				addcol = Vector( tab.Case02 ),
				mulcol = Vector( tab.Case03 ),
				brightness = tonumber( tab.Case04 ),
				contrast = tonumber( tab.Case05 ),
				color = tonumber( tab.Case06 ),
				id = tab.Case16
			} )
		elseif( tab.Case01 == "planet_bloom" ) then
			table.insert(  Environments.MapEntities.Bloom, {
				color = Vector( tab.Case02 ),
				x = tonumber( string.Explode( " ", tab.Case03 )[1] ),
				y = tonumber( string.Explode( " ", tab.Case03 )[2] ),
				passes = tonumber( tab.Case04 ),
				darken = tonumber( tab.Case05 ),
				multiply = tonumber( tab.Case06 ),
				colormul = tonumber( tab.Case07 ),
				id = tab.Case16
			} )
		end
	end
end

function Environments.RegisterEnvironments()
	local planets = {}
	local i = 0
	local map = game.GetMap()
	
	if file.Exists( "environments/" .. map ..".txt" ) then
		Environments.GetMapEntities()
		print("//   Attempting to Load From File  //")
		local contents = file.Read( "environments/" .. map .. ".txt" )
		local starscontents = file.Read( "environments/" .. map .. "_stars.txt")
		if contents and starscontents then
			local status, error = pcall(function()
				planets = table.DeSanitise(util.KeyValuesToTable(contents))
				stars = table.DeSanitise(util.KeyValuesToTable(starscontents))
				if planets.version == Environments.FileVersion then
					print("//     " .. table.Count(planets) - 1 .. " Planets Loaded From File  //")
					print("//     " .. table.Count(stars) .. " Stars Loaded From File    //")
				else --Incorrect File Version
					print("//    Files Are Of An Old Version  //")
					file.Delete("environments/"..map..".txt")
					file.Delete("environments/"..map.."_stars.txt")
					Environments.RegisterEnvironments()
					return
				end
			end)
			if error then --Read Error
				print("//    A File Read Error Has Occured//")
				file.Delete("environments/"..map..".txt")
				file.Delete("environments/"..map.."_stars.txt")
				Environments.RegisterEnvironments()
				return
			end
		else --Empty File
			print("//    The File Has No Content       //")
			file.Delete("environments/"..map..".txt")
			file.Delete("environments/"..map.."_stars.txt")
			Environments.RegisterEnvironments()
			return
		end
		planets.version = nil
		for k,v in pairs(planets) do --clean this up, the parsing only does atmosphere
			v.air = Environments.ParseSaveData(v).air --get air data from atmosphere data
			v.atmosphere = v.atm
			v.total = v.air.total
			Environments.CreatePlanet(v)
		end  
		for k,v in pairs(stars) do
			local star = Environments.ParseStar(v)
			Environments.CreateStar(star)
		end
	else --load it from the map
		local rawdata, rawstars = Environments.CreateEnvironmentsFromMap()

		file.Write( "environments/" .. map .. "_stars.txt", util.TableToKeyValues( table.Sanitise(rawstars) ) )
	end
	if table.Count(environments) > 0 then
		UseEnvironments = true
		EnvironmentDebugCount = table.Count(environments)
	end
	Environments.SaveMap()
end

function Environments.CreateEnvironmentsFromMap()
	local rawdata, rawstars = Environments.LoadFromMap()
	rawdata.version = nil
	for k,v in pairs(rawdata) do
		local planet = Environments.ParsePlanet(v)
		Environments.CreatePlanet(planet)
	end
	Stars = {}
	for k,v in pairs(rawstars) do
		local star = Environments.ParseStar(v)
		Environments.CreateStar(star)
		table.insert(stars, star)
	end
	return rawdata, rawstars
end

function Environments.LoadFromMap()
	local i = 0
	local planets, stars = {}, {}
	print("//   Loading From Map              //")
	Environments.GetMapEntities()
	local entities = ents.FindByClass( "logic_case" )
	for k,ent in pairs(entities) do
		local values = ent:GetKeyValues()
		local tab = ent:GetKeyValues()
			
		local Type = tab.Case01
		local planet = {}
		planet.position = {}
		
		if Type == "env_rectangle" then
			planet.typeof = "cube"

			//KEYS
			planet.radius = tonumber(tab.Case02) --Get Radius
			planet.gravity = tonumber(tab.Case03) --Get Gravity
			//END KEYS
	
			planet.position = ent:GetPos()
			
			--Add Defaults
			planet.atmosphere = {}
			planet.atmosphere = table.Copy(default.atmosphere)
			planet.unstable = "false"
			planet.temperature = 288
			planet.pressure = 1
	
			i=i+1
			planet.name = i

			table.insert(planets, planet)
			print("//     Spacebuild Cube Added       //")
		elseif Type == "cube" then --need to fix in the future
			planet.typeof = "cube"
			
			//KEYS
			planet.radius = tonumber(tab.Case02) --Get Radius
			planet.gravity = tonumber(tab.Case03) --Get Gravity
			//END KEYS
	
			planet.position = ent:GetPos()
			
			--Add Defaults
			planet.atmosphere = {}
			planet.atmosphere = table.Copy(default.atmosphere)
			planet.unstable = "false"
			planet.temperature = 288
			planet.pressure = 1
			
			i=i+1
			planet.name = i

			table.insert(planets, planet)
			print("//     Spacebuild Cube Added       //")
		elseif Type == "planet" then
			--Add Defaults
			planet.atmosphere = {}
			planet.atmosphere = table.Copy(default.atmosphere)
			planet.unstable = "false"
			planet.temperature = 288
			planet.pressure = 1
			planet.typeof = "SB2"
			
			//KEYS
			planet.radius = tonumber(tab.Case02) --Get Radius
			planet.gravity = tonumber(tab.Case03) --Get Gravity
			planet.atm = tonumber(tab.Case04)
			planet.temperature = tonumber(tab.Case05)
			planet.suntemperature = tonumber(tab.Case06)
			planet.colorid = tostring(tab.Case07)
			planet.bloomid = tostring(tab.Case08)
			planet.flags = tonumber(tab.Case16)
			//END KEY

			planet.position = ent:GetPos()
		
			if planet.atm == 0 then
				planet.atm = 1
			end
			i=i+1
			planet.name = i
			
			local planet = Environments.ParseSB2Environment(planet)
			table.insert(planets, planet)
			print("//     Spacebuild 2 Planet Added   //")
		elseif Type == "planet2" then
			--Defaults
			planet.atmosphere = {}
			planet.atmosphere = table.Copy(default.atmosphere)
			planet.unstable = "false"
			planet.temperature = 288
			planet.pressure = 1
			
			planet.typeof = "SB3"
			
			planet.radius = tonumber(tab.Case02) --Get Radius
			planet.gravity = tonumber(tab.Case03) --Get Gravity
			planet.atm = tonumber(tab.Case04) --What does this mean?
			planet.pressure = tonumber(tab.Case05)
			planet.temperature = tonumber(tab.Case06)
			planet.suntemperature = tonumber(tab.Case07)
			planet.flags = tonumber(tab.Case08) --can be 0, 1, 2
			planet.atmosphere.o2 = tonumber(tab.Case09)
			planet.atmosphere.co2 = tonumber(tab.Case10)
			planet.atmosphere.n = tonumber(tab.Case11)
			planet.atmosphere.h = tonumber(tab.Case12)
			planet.name = tostring(tab.Case13) --Get Name
			planet.colorid = tostring(tab.Case15)
			planet.bloomid = tostring(tab.Case16)
			
			//print("MapLoad: ",planet.name, "'"..tab.Case05.."'", planet.pressure)
			
			planet.originalco2per = planet.atmosphere.co2
			
			if planet.atm == 0 then
				planet.atm = 1
			end
		
			planet.position = ent:GetPos()
		
			i=i+1
			table.insert(planets, planet)
			print("//     Spacebuild 3 Planet Added   //")
		elseif Type == "star" then
			planet.radius = tonumber(tab.Case02) --Get Radius
			planet.gravity = tonumber(tab.Case03) --Get Gravity
		
			planet.position = ent:GetPos()
		
			planet.temperature = 10000
			planet.solaractivity = "med"
			planet.baseradiation = "1000"
		
			i=i+1	
			table.insert(stars, planet)
			print("//     Spacebuild 2 Star Added     //")
		elseif Type == "star2" then				
			planet.radius = tonumber(tab.Case02) --Get Radius
			planet.gravity = tonumber(tab.Case03) --Get Gravity
			planet.name = tostring(tab.Case06)
			
			if not planet.name then
				planet.name = "Star"
			end
			
			planet.position = ent:GetPos()
			
			planet.temperature = 5000
			planet.solaractivity = "med"
			planet.baseradiation = "1000"

			i=i+1
			table.insert(stars, planet)
			print("//     Spacebuild 3 Star Added     //")
		else --not a normal ent

		end
	end
	planets.version = Environments.FileVersion
	//Environments.PlanetSaveData = {}
	//Environments.PlanetSaveData = planets
	
	return planets, stars
end

function Environments.SaveMap() --plz work :)
	local map = game.GetMap()
	local planets = {}
	for k,v in pairs(environments) do
		if !v:IsValid() then continue end
		if not v:IsStar() then
			local planet = {}
			--print("Gravity: "..v.gravity)
			planet.gravity = v.gravity
			--print("Pressure: "..v.pressure)
			planet.pressure = v.pressure
			planet.typeof = v.typeof
			planet.radius = v.radius
			planet.name = v.name 
			planet.temperature = v.temperature
			planet.atm = v.atmosphere
			planet.suntemperature = v.suntemperature
			planet.atmosphere = {}
			--planet.atmosphere = table.Copy(v.air) --need to get only percentage values
			planet.atmosphere.o2 = v.air.o2per
			planet.atmosphere.co2 = v.air.co2per
			planet.atmosphere.h = v.air.hper
			planet.atmosphere.n = v.air.nper
			planet.atmosphere.ar = v.air.arper
			planet.atmosphere.ch4 = v.air.ch4per
			planet.bloomid = v.bloomid
			planet.colorid = v.colorid
			planet.unstable = v.unstable
			planet.sunburn = v.sunburn
			planet.position = v.position
			planet.originalco2per = v.originalco2per
			planet.atmosphere.total = v.air.total
			table.insert(planets, planet)
		end
	end
	planets.version = Environments.FileVersion
	--print("Environments: Map Saved "..CurTime())
	file.Write( "environments/" .. map .. ".txt", util.TableToKeyValues( table.Sanitise(planets) ) )
end
timer.Create("MapSavesEnv", 120, 0, Environments.SaveMap)
concommand.Add("env_save", Environments.SaveMap)

EnvX.LoadFile("envx/core/space.lua",1)

function Environments.RegisterSun()
	local status, error = pcall(function()
		TrueSun = {}
		if table.Count(stars) > 0 then
			--set as core radiation source, and sun angle(needed for solar planels) and other sun effects
			TrueSun[1] = table.Random(stars).position
			print("//   Star Registered               //")
		else
			local suns = ents.FindByClass("env_sun")
			for k,ent in pairs(suns) do
				if ent:IsValid() then
					local values = ent:GetKeyValues()
					if values.target and string.len(values.target) > 0 then
						local targets = ents.FindByName( "sun_target" )
						for _, target in pairs( targets ) do
							SunAngle = (target:GetPos() - ent:GetPos()):Normalize()
							print("target found: ".. tostring(target))
							break //Sunangle set, all that was needed
						end
					end
					
					if !SunAngle then //Sun angle still not set, but sun found
						local ang = ent:GetAngles()
						ang.p = ang.p - 180
						ang.y = ang.y - 180
						--get within acceptable angle values no matter what...
						ang.p = math.NormalizeAngle( ang.p )
						ang.y = math.NormalizeAngle( ang.y )
						ang.r = math.NormalizeAngle( ang.r )
						SunAngle = ang:Forward()
					end
					break
                end
			end
			
			if SunAngle then
				print("//   Registered Env_Sun Entity     //")
			else
				print("//   No Stars Found, Defaulting    //")
				TrueSun = {}
				TrueSun[1] = Vector(0,0,10000)
			end
		end
	end)

	if error then
		print("Star Register Error: "..error)
		print("//   No Stars Found, Defaulting      //")
		TrueSun = {}
		TrueSun[1] = Vector(0,0,0)
	end
end

Environments.IsSunAlive = true
function Environments.GetSunFraction(entpos, up)//wip
	if Environments.IsSunAlive == false then//sun is dead, no solar power
		return 0
	end
	
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
					local v = (up or Vector(0,0,1)) + trace.HitNormal
					local n = v.x*v.y*v.z
					print("truesun hit")
					if n > 0 then
						output = output + n
						--solar panel produces energy
					end
				else
					local n = math.Clamp(1-SUN_POS:Distance(trace.HitPos)/SUN_POS:Distance(entpos),0,1)
					output = output + n
					print("not hit self truesun")
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
			return output
		end
	end
	local SUN_POS = (entpos - (SunAngle2 * 4096))
	trace = util.QuickTrace(SUN_POS, entpos-SUN_POS, nil)
	if trace.Hit then 
		if trace.Entity == self then
			local v = (up or Vector(0,0,1)) + trace.HitNormal
			local n = v.x*v.y*v.z
			print("sunpos hit")
			if n > 0 then
				return n
			end
		else
			local n = math.Clamp(1-SUN_POS:Distance(trace.HitPos)/SUN_POS:Distance(entpos),0,1)
			if n > 0 then
				print("not hit sunpos")
				return n
			end
			--solar panel is being blocked
		end
	end
end

local function yay(ply, cmd, args)//temporary
	print(Environments.GetSunFraction(ply:GetPos(), ply:GetUp()))
end
concommand.Add("env_suncheck", yay)

function Environments.Hooks.NoClip( ply, on )
    return EnvX.CanNoClip(ply)   
end

local function bool(b)
	if b == "true" then 
		return true
	end
	if b == "false" then 
		return false
	end
end

function Environments.SendInfo(ply)
	/*timer.Simple(1, */
	local func = function()
		for _, v in pairs( environments ) do
			umsg.Start( "AddPlanet", ply )
				umsg.Short( v:EntIndex() )
				umsg.Vector( v:GetPos() )
				umsg.Short( v.radius )
				umsg.String( v.name or "" )
				if v.colorid then
					umsg.String( v.colorid )
				end
				if v.bloomid then
					umsg.String( v.bloomid )
				end
			umsg.End()
		end

		for _, v in pairs( Environments.MapEntities.Color ) do
			umsg.Start( "PlanetColor", ply )
				umsg.Vector( v.addcol )
				umsg.Vector( v.mulcol )
				umsg.Float( v.brightness )
				umsg.Float( v.contrast )
				umsg.Float( v.color )
				umsg.String( v.id )
			umsg.End()
		end
		
		for _, v in pairs( Environments.MapEntities.Bloom ) do
			umsg.Start( "PlanetBloom", ply )
				umsg.Vector( v.color )
				umsg.Float( v.x )
				umsg.Float( v.y )
				umsg.Float( v.passes )
				umsg.Float( v.darken )
				umsg.Float( v.multiply )
				umsg.Float( v.colormul )
				umsg.String( v.id )
			umsg.End()
		end 
	end
	timer.Simple(1, func)
	//end, ply)
end

function Environments.OnEnvironment(pos)
	for k,v in pairs(environments) do
		local distance = pos:Distance(ent:GetPos())
		if distance <= v.radius then
			return true
		end
	end
	return false
end

function Environments.FindEnvironmentOnPos(pos)
	for k,v in pairs(environments) do
		if pos:Distance(v:GetPos()) <= v.radius then
			return v
		end
	end
	return nil
end

function Environments.AdminCommand(ply, cmd, args)
	if ply != NULL and !ply:IsAdmin() then return end
	local cmd = args[1]
	local value = args[2]
	
	print("Admin Command Recieved From "..ply:Nick().." Command: "..cmd..", Value: "..value)
	if cmd == "noclip" then --noclip blocking
		RunConsoleCommand("env_noclip", value)
	elseif cmd == "planetconfig" then --planet editing
		local k = value
		local v = args[3]
		if tonumber(v) then 
			v = tonumber(v) 
		elseif v == "true" or v == "false" then
			v = bool(v)
		end
		if ply.environment and ply.environment != Space() then
			print("Planet Var: '"..k.."', Set to: '"..tostring(v).."', Type: "..type(v))
			ply.environment[k] = v
		end
	end
end
concommand.Add("environments_admin", Environments.AdminCommand)

local function Reload(ply,cmd,args)
	if ply != NULL and !ply:IsAdmin() then return end
	for k,v in pairs(environments) do
		if v and v:IsValid() then
			v:Remove()
			v = nil
		else
			v = nil
		end
	end
	environments = {}
	Environments.RegisterEnvironments()
	ply:ChatPrint("Environments Has Been Reset!")
end
concommand.Add("env_server_reload", Reload)

local function ComReload(ply,cmd,args)
	if ply != NULL and !ply:IsAdmin() then return end
	
	local map = game.GetMap()
	file.Delete("environments/"..map..".txt")
	file.Delete("environments/"..map.."_stars.txt")
	
	for k,v in pairs(environments) do
		if v and v:IsValid() then
			v:Remove()
			v = nil
		else
			v = nil
		end
	end
	environments = {}
	Environments.RegisterEnvironments()
	ply:ChatPrint("Environments Has Been Reloaded From Map!")
end
concommand.Add("env_server_full_reload", ComReload)

local function SendPlanetData(ply, cmd, args)
	if ply != NULL and ply:IsAdmin() then
		local env = ply.environment
	--if string.lower(type(ply.environment)) == "entity" then
		umsg.Start("env_planet_data", ply)
			umsg.String(env.name)
			umsg.Float(env.gravity)
			umsg.Bool(env.unstable)
			umsg.Bool(env.sunburn)
			umsg.Float(env.temperature)
			umsg.Float(env.suntemperature or 0)
		umsg.End()
	--end
	end
end
concommand.Add("request_planet_data", SendPlanetData)

local function PrintData(ply, cmd, args)
	local self = ply.environment
	if !self then return end
	Msg("ID is: ", self.name, "\n")
	Msg("Dumping stats:\n")
	Msg("------------ START DUMP ------------\n")
	PrintTable(self.OldData)
	Msg("------------- END DUMP -------------\n\n")
end
concommand.Add("print_planet", PrintData)

local function PlanetCheck()
	local original = EnvironmentDebugCount
	local num = 0
	for k,v in pairs(environments) do
		if v:IsValid() then
			num = num + 1
		end
	end
	if num < original then --planet missing
		MsgAll("Environments: Planet Discrepancy Detected, Reloading!")
		for k,v in pairs(environments) do
			if v and v:IsValid() then
				v:Remove()
				v = nil
			else
				v = nil
			end
		end
		environments = {}
		Environments.RegisterEnvironments()
	end
end
timer.Create("ThinkCheckPlanetIssues", 1, 0, PlanetCheck)

//add magnetic plasma shields to repel explosion and protect stuff underneath
//after supernova have gradual recovery, so it can happen again without complete reset
local function SuperNova(ply, cmd, args)//have sun model that expands and breaks into an explosion, then turns darker
	if ply:IsAdmin() or ply == NULL then
		NovaData = {}
		local nd = NovaData
		nd.messages = 0
		nd.death_time = CurTime() + 360 //360
		for k,v in pairs(player.GetAll()) do
			v:ChatPrint("The sun appears as if its going to go supernova!!!! Get ready!")
		end
		local function Nova()
			local timeleft = nd.death_time - CurTime()
			if timeleft < 300 and nd.messages < 1 then
				for k,v in pairs(player.GetAll()) do
					v:ChatPrint("5 minutes till sun goes supernova!!!! Get ready!")
				end
				nd.messages = 1
			elseif timeleft < 60 and nd.messages < 2 then
				for k,v in pairs(player.GetAll()) do
					v:ChatPrint("Only 1 minute till sun goes supernova!!!! Get ready!")
				end
				nd.messages = 2
			elseif timeleft < 20 and nd.messages < 3 then
				for k,v in pairs(player.GetAll()) do
					v:ChatPrint("Only 20 seconds remaining till sun goes supernova!!!! Get ready!")
				end
				nd.messages = 3
			elseif timeleft < 0 then
				//kill the sun and other stuff here
				
				//drain atmospheres
				for k,v in pairs(environments) do
					//drain here
				end
				
				//kill players/props not protected
				for k,v in pairs(player.GetAll()) do
					//if not in cover kill player and ignite
					local trace = {}
					local pos = v:GetPos() + Vector(0,0,200)
					trace.start = pos
					trace.endpos = v:GetPos()
					trace.filter = { v }
					
					local tr = util.TraceLine( trace )
					if tr.Hit and tr.Entity:IsValid() then
						//player is "protected"
						v:ChatPrint("You Survived the Supernova Explosion!")
					else
						v:Ignite()
						v:Kill()
						v:ChatPrint("You were killed by the Supernova Explosion.")
					end
				end
				
				engine.LightStyle(0, "aaaa");
				local function p()
					for k,v in pairs(player.GetAll()) do
						umsg.Start("supernova", v)
						umsg.End();
					end
				end
				timer.Create("nova client update", 0.5, 1, p)
				
				timer.Destroy("Supernova timer")//kill the timer, we are done counting down
			end

		end
		timer.Create("Supernova timer", 1, 0, Nova)
				
		local function clear()
			engine.LightStyle(0, "mmmmmm");
			local function p()
				for k,v in pairs(player.GetAll()) do
					umsg.Start("supernova", v)
					umsg.End();
				end
			end
			timer.Create("nova client update2", 0.5, 1, p)
		end
		timer.Create("supernova clear timer", 20*60, 1, clear)
	end
end
concommand.Add("env_supernova", SuperNova)

local function clearnova(ply, cmd, args)
	if ply:IsAdmin() or ply == NULL then
		engine.LightStyle(0, "mmmmmm");
		local function p()
			for k,v in pairs(player.GetAll()) do
				umsg.Start("supernova", v)
				umsg.End();
			end
		end
		timer.Create("nova client update3", 0.5, 1, p)
	end
end
concommand.Add("env_clearnova", clearnova)

