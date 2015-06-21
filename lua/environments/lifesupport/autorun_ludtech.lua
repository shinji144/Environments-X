AddCSLuaFile("environments/lifesupport/autorun_ludtech.lua") 

LDE = LDE or {}

LDE.EnableMenu = false

--local DebugTypes = {Verbose=3,Basic=2,None=1}
LDE.DebugMode="Verbose"

print("=========================")
print("LDE Starting up.")
print("=========================")

local LoadFile = EnvX.LoadFile --Lel Speed.
local P = "lde/"

LoadFile(P.."lde_variables.lua",2)
LoadFile(P.."sh_constraints.lua",1)

LoadFile(P.."sh_debug.lua",1)
LoadFile(P.."sh_utility.lua",1)
LoadFile(P.."sh_networking.lua",1)

LoadFile(P.."lde_userinterface.lua",1)
LoadFile(P.."sh_vguiease.lua",1)
LoadFile(P.."lde_core.lua",1)
LoadFile(P.."lde_unlocksystem.lua",1)
LoadFile(P.."lde_weaponcore.lua",1)
LoadFile(P.."lde_shipcore.lua",1)
LoadFile(P.."lde_lifecore.lua",1)
LoadFile(P.."lde_statsystem.lua",1)
LoadFile(P.."lde_variables.lua",1)
LoadFile(P.."lde_spaceanons.lua",1)
LoadFile(P.."lde_sporeai.lua",1)
LoadFile(P.."lde_overrides.lua",1)
LoadFile(P.."lde_effectcore.lua",1)

LoadFile(P.."lde_damagecontrol.lua",2)
LoadFile(P.."lde_sporeai.lua",2)
LoadFile(P.."lde_envheat.lua",2)

if(SERVER)then

	resource.AddFile("materials/Space_Combat/Shield/shield_01.vmt")
	resource.AddFile("sound/tech/sga_impact_01.wav")
	resource.AddFile("sound/tech/sga_impact_02.wav")
	resource.AddFile("sound/tech/sga_impact_03.wav")
	resource.AddFile("sound/tech/sga_impact_04.wav")

	LDE.Installed = true

else
	language.Add( "env_explosion", "Meteor" )
end

print("=========================")
print("LDE Installed, Have fun. :)")
print("=========================")
	
hook.Add("AddTools", "environments tool lud", function()
	--Environments.RegisterTool("Generators Advanced", "Energy_Gens_Lud", "Life Support", "Used to spawn various LS devices", "generator", 30)
	Environments.RegisterTool("Core Upgrades", "Life_Support_lde", "Ship Cores", "Used to spawn Core Module upgrades", "heatman", 30)
	Environments.RegisterTool("Ship Core", "shipcore_lde", "Ship Cores", "Used to spawn Ship Cores.", "heatcore", 3)
	--Environments.RegisterTool("Base Construction", "base_building", "Base Building", "Used to build bases.", "basebuild", 100)
	Environments.RegisterTool("Mining Devices", "Energy_Gens_Mining", "Life Support", "Used to spawn Mining devices", "miningdevice", 30)
	Environments.RegisterTool("Mining Storage", "Energy_Storage_Mining", "Life Support", "Used to spawn Mining storages", "miningstorage", 30)
	Environments.RegisterTool("Weapon Systems", "Life_Support_weapons", "Ship Cores", "Used to spawn dangerous weapons", "ldeweapons", 20)
	Environments.RegisterTool("Ammo Production", "Life_Support_ammo_prod", "Ship Cores", "Used to spawn devices that make dangerus ammo", "ldeammoprod", 80)
end)
