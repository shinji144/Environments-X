------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

local util = util
local ents = ents
local table = table
local os = os
local math = math
local GetWorldEntity = GetWorldEntity
local Vector = Vector
local print = print
local MsgAll = MsgAll
local pcall = pcall
local pairs = pairs

function table.Random(t) --darn you garry
	local rk = math.random(1,table.Count(t))
	local i = 1
	for k,v in pairs(t) do
		if i == rk then return v, k end
		i = i + 1
	end
end

//prototype events system
local events = {}
events["meteorstorm"] = function(planet)
	local roids = ents.Create("event_asteroid_storm")
	roids:SetPos(planet.position + Vector(0, 0, planet.radius + 2000))
	roids:Spawn()
	roids:Start(planet.radius)
	return "Meteor Storm"
end
events["meteor"] = function(planet)
	local roid = ents.Create("event_meteor")
	roid:SetPos(GetBestPath(roid, planet))
	roid:Spawn()
	roid:Start(planet)
	return "Meteor Strike"
end
events["earthquake"] = function(planet)
	util.ScreenShake(planet:GetPos(), 14, 255, 6, planet.radius)
	sound.Play(Sound("ambient/explosions/exp" .. math.random(1, 4) .. ".wav"), planet:GetPos(), 100, 100)
	return "Earthquake"
end

local function FireEvent(ply,cmd,args)
	if ply != NULL and !ply:IsAdmin() then return end
	if ply.environment.name != "space" then
		if events[args[1]] then
			events[args[1]](ply.environment)
		else
			ply:ChatPrint("You tried to call in an invalid event!")
		end
	else
		ply:ChatPrint("You can't call in a "..args[1].." in space!")
	end
end
concommand.Add("env_fire_event", FireEvent)

function Environments.EventChecker()
	local chance = math.random(1,30)
	if chance > 12 and chance < 17 then
		//call the function to run the event
		local planet = table.Random(environments)
		local event, eventname = table.Random(events)
		if !planet.air.o2per or planet.air.o2per < 10 then
			event(planet)
			MsgN("A " .. (eventname or "invalid event name") .. " Started at " .. tostring(os.date("%H:%M:%S")).." on planet ".. (planet.name or "Unnamed Planet"))
		else
			planet = table.Random(environments)
			if !planet.air.o2per or planet.air.o2per < 10  then
				event(planet)
				MsgN("A " .. (eventname or "invalid event name") .. " Started at " .. tostring(os.date("%H:%M:%S")).." on planet ".. (planet.name or "Unnamed Planet"))
			end
		end	
		//MsgN("A event should have occured")
	end
end

local resources = {}
local r = resources
r[1] = "hydrogen"
r[2] = "nitrogen"
r[3] = "carbon dioxide"
r[4] = "oxygen"
function Environments.SpecialEvents()
	local count = #(ents.FindByClass("gas_cloud") or {})
	if count < 10 then
		local notfinished = true
		local rep = 0
		while notfinished do
			rep = rep + 1
			local a = VectorRand()*16384
			if util.IsInWorld(a) then --add check to make sure they arent in something
				if !Environments.FindEnvironmentOnPos(a) then
					local cloud = ents.Create("gas_cloud")
					cloud:SetPos(a)
					//cloud:SetAngles(Angle(math.Rand(-180,180),math.Rand(-180,180),math.Rand(-180,180)))
					cloud:Spawn()
					cloud:SetResource(table.Random(resources))//use different colors for different resources eventually
					cloud:SetAmount(10000)
					return
				end
			end
			if rep > 15 then
				notfinished = false
				//print("find pos failed, continuing")
			end
		end
	end
end

function GetBestPath(ent, planet) --try for the best, most spectacular asteroid path
	--for now, lets just go with the top of the map
	local pos = Vector(0, 0, 32000)
	
	local tracedata = {}
	tracedata.start = planet.position
	tracedata.endpos = pos
	tracedata.filter = ent
	tracedata.mins = ent:OBBMins()
	tracedata.maxs = ent:OBBMaxs()
	tracedata.mask = MASK_NPCWORLDSTATIC
	 
	local trace = util.TraceHull( tracedata )
	if trace.HitWorld then
		if not trace.HitSky then
			return planet.position + Vector(0, 2000, planet.radius + 2000)
		else
			return trace.HitPos
		end
	else
		return trace.HitPos
	end
end

local function Cleanup()
	for k,v in pairs(ents.FindByClass("event_asteroid")) do
		v:Remove()
	end
end
timer.Create("EnvEventsClean", 54, 0, Cleanup)

local function physgunPickup( userid, Ent )  	
	if Ent:GetClass() == "event_meteor" or Ent:GetClass() == "event_asteroid" then  		
		return false
	end  
end     
hook.Add( "PhysgunPickup", "NOPHYSGUNNINGMETEORS!", physgunPickup )