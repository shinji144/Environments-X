--Things that shouldnt be effected.
LDE.Blocked = {"phygun_beam",
"predicted_viewmodel",
"func",
"func_physbox",
"info_",
"point_",
"path_",
"node",
"Environment",
"environment",
"sent_spaceanon",
"env_",
"star",
"wire",
"gyro",
"hypermass"
}

--If its blocked, allow anyways.
LDE.Always = {"resource",
"storage",
"asteroid",
"generator",
"lde",
"lifesupport",
"environments",
"dispenser",
"weapon",
"probe",
"lscore",
"factory",
"pump",
"health",
"trade"
}

--Banned Entity classes.
LDE.BannedClasses = {"edit_sun",
"edit_sky",
"edit_fog",
"sent_ball",
"combine_mine",
"item_healthcharger",
"item_healthkit",
"item_healthvial",
"grenade_helicopter",
"item_suit",
"item_battery",
"item_suitcharger",
"prop_thumper",
--"environments_admincache",
"gmod_wire_simple_explosive",
"gmod_wire_explosive",
"gmod_wire_igniter",
"gmod_wire_nailer",
"gmod_wire_turret",
"gmod_wire_dupeport",
"gmod_wire_field_device",
"gmod_wire_hoverdrivecontroler",
"hoverdrive",
"npc_tf2_ghost",
"livable_module"
}

---------------------ADVERTS-------------------------

LDE.Adverts = {
"Don't Forget that you can sell and buy resources using a Trade console.",
--"Missing Models? Read the !xmotd.",
"Found a bug? Report it on the TauSC group discussions.",
"Devices overheating? Weld them to a ship core with a radiator.",
"Space is full of interesting things, go explore it.",
"Got a suggestion? Post it on the TauSC group discussions.",
"This server is running a mod made by the TauSC group.",
"Run out of Jetpack fuel? Gather some Hydrogen, and use a suit dispenser to refuel.",
"Remember Spawn planet is a safe zone, No damage can happen in safe zones.",
"Join the TauSC, We have Science!",
"See those rocks in space? They are minable with mining lasers.",
"Space Holds a terrible secret! We must protect you.",
"Watch out for space spores, An infection is very dangeruss.",
"Dont use Air Compressers, use a water splitter instead."
}

--------------------Role System---------------
LDE.Rolesys = {} --Create a empty Roles table.
LDE.Rolesys.Roles = {} --We will store the Role data in here.

function LDE.Rolesys.CanFillRole(ply,role)
	for name,data in pairs(role.Above) do --Check the stats we need above a number
		local Stat = ply:GetLDEStat(name)
		if(Stat<data)then
			return false
		end
	end
	
	for name,data in pairs(role.Below) do --Check the stats we need below a number
		local Stat = ply:GetLDEStat(name)
		if(Stat>data)then
			return false
		end
	end
	
	return true --Its good, we can return true! :)
end

function LDE.Rolesys.CreateRole(Name,Above,Below,Moral,Priority,Extra)
	local Data = {} 
	Data.name = Name --The Name of the role and what displays
	
	Data.Moral = Moral --The Moral of the role, This tells what side its on
	
	Data.Above = Above --All the stats we need above a number
	Data.Below = Below --All the stats we need below a number
	
	Data.Priority = Priority --The priority of a role, the higher the priority the more important it is when the system picks a role
	
	Data.Extra = Extra --Extra Table Data. (For extra check types)
	
	table.insert(LDE.Rolesys.Roles, Data)
end

--Worker Roles
local Bad = {Bounty=2000}

LDE.Rolesys.CreateRole("Petty Trader",{Traded=1000},Bad,1,4)
LDE.Rolesys.CreateRole("Trader",{Traded=10000},Bad,1,6)
LDE.Rolesys.CreateRole("Great Trader",{Traded=40000},Bad,1,8)
LDE.Rolesys.CreateRole("Grand Trader",{Traded=100000},Bad,1,10)

LDE.Rolesys.CreateRole("Dirt Miner",{Mined=2000},Bad,1,5)
LDE.Rolesys.CreateRole("Ore Miner",{Mined=4000},Bad,1,7)
LDE.Rolesys.CreateRole("Gold Miner",{Mined=6000},Bad,1,9)
LDE.Rolesys.CreateRole("Polylodarium Miner",{Mined=9000},Bad,1,11)

LDE.Rolesys.CreateRole("Blackholium Miner",{Mined=40000000},{},1,18)
LDE.Rolesys.CreateRole("StarLord",{Mined=10000,Traded=200000},{},1,20)

--Pirate Roles
LDE.Rolesys.CreateRole("Pirate",{Bounty=1},{},2,13)
LDE.Rolesys.CreateRole("CrimeBoss",{Bounty=1000},{},2,14)
LDE.Rolesys.CreateRole("WarLord",{Bounty=5000},{},2,18)

LDE.Rolesys.CreateRole("Hunter",{Kills=1},{},2,13.4)
LDE.Rolesys.CreateRole("Mass Slayer",{Kills=10},{},2,14.1)
LDE.Rolesys.CreateRole("Soul Collector",{Kills=100},{},2,18.5)

LDE.Rolesys.CreateRole("Evil Genius",{Bounty=10000,Kills=200},{},2,20.5)

--Misc Roles
LDE.Rolesys.CreateRole("Civilian",{},Bad,0,1)


--Extra Roles
LDE.Rolesys.CreateRole("Developer",{Developer=1},{},0,9001)
LDE.Rolesys.CreateRole("Therapist",{Rapes=1},{},2,9001) --This is for xkiarofl
LDE.Rolesys.CreateRole("Turbo Nerd",{TNT=1},{},0,9001)

