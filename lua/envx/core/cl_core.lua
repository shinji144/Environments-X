------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

--localize :D
local hook = hook
local timer = timer
local ents = ents
local LocalPlayer = LocalPlayer
local pairs = pairs
local print = print
local DrawBloom = DrawBloom
local DrawColorModify = DrawColorModify

local breathing = CreateConVar( "env_breathing_sound_enabled", "0", { FCVAR_ARCHIVE, }, "Enable/Disable the breathing sound." )

local planets = {} --Planetary Data Table :D updated from server usermessages
local stars = {} --Star data table updated from server usmg
local blooms = {}
local colors = {}

//This is the planet the client is currently on, used for effects and such
planet = nil

Environments.suit = table.Copy(EnvX.DefaultSuitData)

local function NoclipPredict(ply)
	if ply:GetMoveType() == MOVETYPE_NOCLIP then return true end
	if ply:IsAdmin() then return true end
	
	if ply:GetNWBool("inspace") then
		return false
	end
	return true
end

local function EnvironmentCheck() --Whoah! What planet I am on?!
	local ply = LocalPlayer()
	if not ply:IsValid() then return end
	for k, p in pairs( planets ) do
		if ply:GetPos():Distance(p.position) <= p.radius then
			//Record the name of the planet
			planet = p
			return
		end
	end
	planet = nil --space
end
timer.Create("EnvironmentCheck", 1, 0, EnvironmentCheck )

local iris = surface.GetTextureID("effects/lensflare/iris");
local flare = surface.GetTextureID("effects/lensflare/flare");
local color_ring = surface.GetTextureID("effects/lensflare/color_ring");
local bar = surface.GetTextureID("effects/lensflare/bar");
local sDrawTexturedRect = surface.DrawTexturedRect;
local sSetDrawColor = surface.SetDrawColor;
local sSetTexture = surface.SetTexture;
 
local ScrW, ScrH = ScrW, ScrH;
function DrawLensFlare(mul,sunx,suny,colr,colg,colb,cola)
	if mul == 0 then return end
	local w,h = ScrW(), ScrH();
	local w2, h2 = w/2, h/2;
	mul = mul +math.Rand(0,0.0001);
	local sz = w * 0.15*mul;
	   
	local val = sunx - w2;
	local val2 = suny - h2;
 
	local alpha = 255 * math.pow(cola,3);
	   
	sSetTexture(flare);
	sSetDrawColor(255*colr,230*colg,180*colb,255 * cola);
	local csz, csz2 = sz*25, sz*12.5;
	sDrawTexturedRect(sunx - csz2, suny - csz2, csz, csz);
 
	sSetTexture(color_ring);
	sSetDrawColor(255*colr,255*colg,255*colb,alpha * 3.137);
	csz, csz2 = sz*1.5, sz* 0.75;
	sDrawTexturedRect(val*0.5+w2-csz2, val2*0.5+h2 - csz2,csz,csz);
 
	sSetTexture(bar);
	sSetDrawColor(255*colr,230*colg,180*colb,alpha);
	csz, csz2 = sz*10, sz* 0.5;
	sDrawTexturedRect(val*-0.5+w2-csz2,val2*-0.5+h2-csz2,csz,csz);
	   
	sSetTexture(iris);
	sSetDrawColor(255*colr,230*colg,180*colb,alpha)
	csz, csz2 = sz*1.5, sz* 0.75;
	sDrawTexturedRect(val*1.8+w2-csz2,val2*1.8+h2-csz2,csz,csz);
	csz, csz2 = sz*0.15, sz* 0.075;
	sDrawTexturedRect(val*1.82+w2-csz2,val2*1.82+h2-csz2,csz,csz);
	csz, csz2 = sz*0.1, sz* 0.5;
	sDrawTexturedRect(val*1.5+w2-csz2,val2*1.5+h2-csz2,csz,csz);
	csz, csz2 = sz*0.05, sz* 0.025;
	sDrawTexturedRect(val*0.6+w2-csz2,val2*0.6+h2-csz2,csz,csz);
	csz, csz2 = sz*0.05, sz* 0.025;
	sDrawTexturedRect(val*0.59+w2-csz2,val2*0.59+h2-csz2,csz,csz);
	csz, csz2 = sz*0.15, sz* 0.075;
	sDrawTexturedRect(val*0.3+w2-csz2,val2*0.3+h2-csz2,csz,csz);
	csz, csz2 = sz*0.1, sz* 0.05;
	sDrawTexturedRect(val*-0.7+w2-csz2,val2*-0.7+h2-csz2,csz,csz);
	csz, csz2 = sz*0.1, sz* 0.05;
	sDrawTexturedRect(val*-0.72+w2-csz2,val2*-0.72+h2-csz2,csz,csz);
	csz, csz2 = sz*0.15, sz* 0.075;
	sDrawTexturedRect(val*-0.73+w2-csz2,val2*-0.73+h2-csz2,csz,csz);
	csz, csz2 = sz*0.05, sz* 0.025;
	sDrawTexturedRect(val*-0.9+w2-csz2,val2*-0.9+h2-csz2,csz,csz);
	csz, csz2 = sz*0.1, sz* 0.05;
	sDrawTexturedRect(val*-0.92+w2-csz2,val2*-0.92+h2-csz2,csz,csz);
	csz, csz2 = sz*0.05, sz* 0.025;
	sDrawTexturedRect(val*-1.3+w2-csz2,val2*-1.3+h2-csz2,csz,csz);
	csz2 = sz* 0.5;
	sDrawTexturedRect(val*-1.5+w2-csz2,val2*-1.5+h2-csz2,sz,sz);
	csz, csz2 = sz*0.15, sz* 0.075;
	sDrawTexturedRect(val*-1.7+w2-csz2,val2*-1.7+h2-csz2,csz,csz);
end

--------------------------------------------------------
--              Environments Usermessages             --
--------------------------------------------------------
local function LSUpdate(msg) --recieves life support update packet
	Environments.suit = table.Merge(EnvX.DefaultSuitData,{fuel = net.ReadFloat(),energy=net.ReadFloat()})
	Environments.suit.temperature = net.ReadFloat()
	Environments.suit.o2per = net.ReadFloat()
	Environments.suit.temp = net.ReadFloat()
end
net.Receive( "LSUpdate", LSUpdate)

local function PlanetUmsg( msg )
	local ent = msg:ReadShort()
	local hash  = {}
	hash.ent = ents.GetByIndex(ent)
	hash.position = msg:ReadVector()
	hash.radius = msg:ReadShort()
	hash.name = msg:ReadString()
	hash.colorid = msg:ReadString()
	hash.bloomid = msg:ReadString()
	
	planets[ent] = hash
	--print("Recieved Planet: ".. hash.colorid)
end
usermessage.Hook( "AddPlanet", PlanetUmsg )

local function PlanetColor(msg)
	local hash = {}
	hash.addcol = msg:ReadVector()
		
	hash.mulcol = msg:ReadVector()
		
	hash.brightness = msg:ReadFloat()
	hash.contrast = msg:ReadFloat()
	hash.color = msg:ReadFloat()
	hash.ID = msg:ReadString()
	colors[hash.ID] = hash
	--print("Recieved Color: ".. hash.ID)
end
usermessage.Hook("PlanetColor", PlanetColor)

local function PlanetBloom(msg)
	local hash = {}
	
	hash.color = msg:ReadVector()

	hash.x = msg:ReadFloat()
	hash.y = msg:ReadFloat()
		
	hash.passes = msg:ReadFloat()
	hash.darken = msg:ReadFloat()
	hash.multiply = msg:ReadFloat()
	hash.colormul = msg:ReadFloat()
	hash.ID = msg:ReadString()
	blooms[hash.ID] = hash
	--print("Recieved Bloom: ".. hash.ID)
end
usermessage.Hook("PlanetBloom", PlanetBloom)

local function ZeroGravRagdoll( msg )
	local ply = msg:ReadEntity();
	timer.Create("ZGR", 0.1, 1, function() ZGR(ply) end)
end
usermessage.Hook( "ZGRagdoll", ZeroGravRagdoll );

function ZGR(ply)
	local ent = ply:GetRagdollEntity();
	
	if( ent and ent:IsValid() ) then
		for i = 0, ent:GetPhysicsObjectCount() do	
			local phys = ent:GetPhysicsObjectNum( i );
			if( phys and phys:IsValid() ) then
				phys:EnableGravity( false )
			end
		end
	end
end

local function OnEntityCreated( e )
	if( e == LocalPlayer() ) then
		timer.Simple( 0, function()
			RunConsoleCommand( "ragdoll_sleepaftertime", "9999.9" )
		end )
	end
end
hook.Add("OnEntityCreated", "Ragdoll checker", OnEntityCreated)

local function StarUmsg( msg )
	local ent = msg:ReadShort()
	local tmpname = msg:ReadString()
	local position = msg:ReadVector()
	local radius = msg:ReadFloat()
	stars[ent] = {
		Ent = ents.GetByIndex(ent),
		name = tmpname,
		Position = position,
		Radius = radius, // * 2
		BeamRadius = radius * 1.5, //*3
	}
end
--usermessage.Hook( "AddStar", StarUmsg )

local function Supernova(msg)
	PrintTable(engine)
	//engine.LightStyle(0, "aaaaa");
	render.RedownloadAllLightmaps();
end
usermessage.Hook("supernova", Supernova);

//Load it depending on the server setup
if CAF and CAF.GetAddon("Spacebuild") then --sb installed
	print("Spacebuild is active on the server")
	LoadHud()
	HUD.Show = true
else --No sb installed
	hook.Add("PlayerNoClip", "EnvPredict", NoclipPredict)
end
