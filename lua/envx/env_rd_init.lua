//Creates Tools
AddCSLuaFile("weapons/gmod_tool/environments_tool_base.lua")

local scripted_ents = scripted_ents
local table = table
local util = util
local timer = timer
local ents = ents
local duplicator = duplicator
local math = math
local tostring = tostring
local MeshQuad = MeshQuad
local Vector = Vector
local type = type
local tonumber = tonumber
local pairs = pairs

if not Environments then
	Environments = {}
end


if SERVER then
	//Load Main Luas
	AddCSLuaFile("environments/cl_init.lua")

	include("environments/init.lua")

	include("environments/shared.lua")
	AddCSLuaFile("environments/shared.lua")

	include("environments/EntRegister.lua")
	AddCSLuaFile("environments/EntRegister.lua")
	
	include("environments/resources.lua")
	AddCSLuaFile("environments/resources.lua")
	
	include("environments/userinterface.lua")
	AddCSLuaFile("environments/userinterface.lua")
	
	include("environments/easecreation.lua")
	AddCSLuaFile("environments/easecreation.lua")
else
	include("environments/userinterface.lua")
	
	include("environments/cl_init.lua")
	
	include("environments/shared.lua")
	
	include("environments/easecreation.lua")
	
	include("environments/EntRegister.lua")
	
	include("environments/resources.lua")
end


print("==============================================")
print("== Environments Life Support Ents Installed ==")
print("==============================================")

//Load devices and stuff from addons
local Files
if file.FindInLua then
	Files = file.FindInLua( "environments/lifesupport/*.lua" )
else//gm13
	Files = file.Find("environments/lifesupport/*.lua", "LUA")
end

for k, File in ipairs(Files) do
	Msg("Loading: "..File.."...\n")
	local ErrorCheck, PCallError = pcall(include, "environments/lifesupport/"..File)
	ErrorCheck, PCallError = pcall(AddCSLuaFile, "environments/lifesupport/"..File)
	if !ErrorCheck then
		Msg(PCallError.."\n")
	else
		Msg("Loaded: Successfully\n")
	end
end
