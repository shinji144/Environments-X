AddCSLuaFile("environments/lifesupport/autorun_ludtech.lua") 

LDE = LDE or {}

if(SERVER)then

	resource.AddFile("materials/Space_Combat/Shield/shield_01.vmt")
	resource.AddFile("sound/tech/sga_impact_01.wav")
	resource.AddFile("sound/tech/sga_impact_02.wav")
	resource.AddFile("sound/tech/sga_impact_03.wav")
	resource.AddFile("sound/tech/sga_impact_04.wav")

	print("=========================")
	print("LDE Starting up.")
	print("=========================")

	local Files
	if file.FindInLua then
		Files = file.FindInLua( "lde/*.lua" )
	else//gm13
		Files = file.Find("lde/*.lua", "LUA")
	end

	for k, File in ipairs(Files) do
		Msg("LDE Loading: "..File.."...\n")
		local ErrorCheck, PCallError = pcall(include, "lde/"..File)
		ErrorCheck, PCallError = pcall(AddCSLuaFile, "lde/"..File)
		if !ErrorCheck then
			Msg(PCallError.."\n")
		end
	end

	Msg("LDE Loaded: Successfully\n")

	LDE.Installed = true
	print("=========================")
	print("LDE Installed, Have fun. :)")
	print("=========================")
else
	include("lde/lde_weaponcore.lua")
	include("lde/lde_shipcore.lua")
	include("lde/lde_core.lua")
	include("lde/lde_userinterface.lua")
	include("lde/lde_lifecore.lua")
	include("lde/lde_statsystem.lua")
	include("lde/lde_variables.lua")
	include("lde/lde_spaceanons.lua")
	include("lde/lde_sporeai.lua")
	include("lde/lde_overrides.lua")
	include("lde/lde_manual.lua")
	include("lde/lde_logsystem.lua")
	include("lde/lde_effectcore.lua")
end

hook.Add("AddTools", "environments tool lud", function()
	Environments.RegisterTool("Generators Advanced", "Energy_Gens_Lud", "Life Support", "Used to spawn various LS devices", "generator", 30)
	Environments.RegisterTool("Core Upgrades", "Life_Support_lde", "Ship Cores", "Used to spawn Core Module upgrades", "heatman", 30)
	Environments.RegisterTool("Ship Core", "shipcore_lde", "Ship Cores", "Used to spawn Ship Cores.", "heatcore", 3)
--	Environments.RegisterTool("Base Construction", "base_building", "Base Building", "Used to build bases.", "basebuild", 100)
	Environments.RegisterTool("Mining Devices", "Energy_Gens_Mining", "Life Support", "Used to spawn Mining devices", "miningdevice", 30)
	Environments.RegisterTool("Mining Storage", "Energy_Storage_Mining", "Life Support", "Used to spawn Mining storages", "miningstorage", 30)
	Environments.RegisterTool("Weapon Systems", "Life_Support_weapons", "Ship Cores", "Used to spawn dangerous weapons", "ldeweapons", 20)
	Environments.RegisterTool("Ammo Production", "Life_Support_ammo_prod", "Ship Cores", "Used to spawn devices that make dangerus ammo", "ldeammoprod", 80)
end)

--Fixes the crazy death notices
if CLIENT then
	language.Add( "env_explosion", "Meteor" )
	language.Add( "env_laser", "Lightning" )
end
