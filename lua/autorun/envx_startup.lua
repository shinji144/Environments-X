------------------------------------------
//  Jupiter Engine GameMode System      //
------------------------------------------
local start = SysTime()

EnvX = EnvX or {}
local EnvX = EnvX --MAH SPEED

EnvX.Version = "InDev V:68"
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
	hook.Add("GetGameDescription", "EnvironmentsGamemode", function() 
		return "Environments X"
	end)
	
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

print("==============================================")
print("==        Environments X    Installed       ==")
print("==============================================")
print("EnvironmentsX Load Time: "..(SysTime() - start))
