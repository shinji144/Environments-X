//Core Environments LS Entities/Devices

--Register the storage types.
Environments.RegisterLSStorage("Steam Storage", "env_steam_storage", {[3600] = "steam"}, 4084, 300, 50)
Environments.RegisterLSStorage("Water Storage", "env_water_storage", {[3600] = "water"}, 4084, 400, 500)
Environments.RegisterLSStorage("Energy Storage", "env_energy_storage", {[3600] = "energy"}, 6021, 200, 50)
Environments.RegisterLSStorage("Oxygen Storage", "env_oxygen_storage", {[4600] = "oxygen"}, 4084, 100, 20)
Environments.RegisterLSStorage("Hydrogen Storage", "env_hydrogen_storage", {[4600] = "hydrogen"}, 4084, 100, 20)
Environments.RegisterLSStorage("Nitrogen Storage", "env_nitrogen_storage", {[4600] = "nitrogen"}, 4084, 100, 20)
Environments.RegisterLSStorage("CO2 Storage", "env_co2_storage", {[4600] = "carbon dioxide"}, 4084, 100, 20)
Environments.RegisterLSStorage("Resource Cache", "env_cache_storage", {[1601] = "carbon dioxide",[1600] = "oxygen",[1602] = "hydrogen",[1603] = "nitrogen",[1599] = "water",[1598] = "steam",[1604] = "energy"}, 4084, 100, 10)

Environments.RegisterLSEntity("Water Heater","env_water_heater",{"water","energy"},{"steam"},
function(self) 
	local mult = self:GetMultiplier()*self.multiplier 
	local amt = self:ConsumeResource("water", 200) or 0 
	amt = self:ConsumeResource("energy",amt*1.5)  
	self:SupplyResource("steam", amt) 
end, 70000, 300, 300)

//Generator Tool

--Fusion Reactors
Environments.RegisterDevice("Generators", "Fusion Generator", "Small SBEP Reactor", "generator_fusion", "models/punisher239/punisher239_reactor_small.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Large SBEP Reactor", "generator_fusion", "models/punisher239/punisher239_reactor_big.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Small Pallet Reactor", "generator_fusion", "models/slyfo/forklift_reactor.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Large Crate Reactor", "generator_fusion", "models/slyfo/crate_reactor.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Classic Reactor", "generator_fusion", "models/props_c17/substation_circuitbreaker01a.mdl")

--Fission Reactor
Environments.RegisterDevice("Generators", "Fission Generator", "Basic Fission Reactor", "generator_fission", "models/SBEP_community/d12siesmiccharge.mdl")

--WaterPumps
Environments.RegisterDevice("Generators", "Water Pump", "Small Water Pump", "generator_water", "models/props_phx/life_support/gen_water.mdl")

--Atmospheric Water Generator
Environments.RegisterDevice("Generators", "Atmospheric Water Generator", "Atmospheric Water Generator Basic", "generator_water_tower", "models/Slyfo/moisture_condenser.mdl")
Environments.RegisterDevice("Generators", "Atmospheric Water Generator", "Atmospheric Water Generator", "generator_water_tower", "models/props_phx/life_support/rau_small.mdl")

--Compressors
--Environments.RegisterDevice("Generators", "Oxygen Compressor", "Oxygen Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "oxygen")
--Environments.RegisterDevice("Generators", "Nitrogen Compressor", "Nitrogen Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "nitrogen")
--Environments.RegisterDevice("Generators", "Hydrogen Compressor", "Hydrogen Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "hydrogen")
--Environments.RegisterDevice("Generators", "CO2 Compressor", "CO2 Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "carbon dioxide")

--SolarPanels
Environments.RegisterDevice("Generators", "Solar Panel", "Large Nasa Solar Panel", "generator_solar", "models/props_phx/life_support/panel_large.mdl")
Environments.RegisterDevice("Generators", "Solar Panel", "Medium Nasa Solar Panel", "generator_solar", "models/props_phx/life_support/panel_medium.mdl")
Environments.RegisterDevice("Generators", "Solar Panel", "Small Nasa Solar Panel", "generator_solar", "models/props_phx/life_support/panel_small.mdl")
Environments.RegisterDevice("Generators", "Solar Panel", "Dish Solar Panel", "generator_solar", "models/props_phx/life_support/rau_small.mdl")
Environments.RegisterDevice("Generators", "Solar Panel", "Mounted Solar Panels", "generator_solar", "models/Slyfo_2/miscequipmentsolar.mdl")
Environments.RegisterDevice("Generators", "Solar Panel", "Small Mounted Solar Panel", "generator_solar", "models/Slyfo_2/acc_sci_spaneltanks.mdl")

--Hydroponics
Environments.RegisterDevice("Life Support", "HydroPonics","Hydroponics Bush", "generator_plant", "models/props_foliage/tree_deciduous_03b.mdl",1)
Environments.RegisterDevice("Life Support", "HydroPonics","Hydroponics Tree", "generator_plant", "models/props_foliage/tree_deciduous_03a.mdl",1)
Environments.RegisterDevice("Life Support", "HydroPonics","Hydroponics Large Tree", "generator_plant", "models/props_foliage/tree_deciduous_01a.mdl",1)
Environments.RegisterDevice("Life Support", "HydroPonics","Hydroponics Potted plant", "generator_plant", "models/props/cs_office/plant01.mdl")

--WaterSplitters
Environments.RegisterDevice("Generators", "Water Splitter", "Electrolysis Generator", "generator_water_to_air", "models/slyfo/electrolysis_gen.mdl")
Environments.RegisterDevice("Generators", "Water Splitter", "Electrolysis Generator Compact", "generator_water_to_air", "models/sbep_community/d12airscrubber.mdl")

--HydrogenFuel Cells
Environments.RegisterDevice("Generators", "Hydrogen Fuel Cell", "Small Fuel Cell", "generator_hydrogen_fuel_cell", "models/slyfo/electrolysis_gen.mdl")
Environments.RegisterDevice("Generators", "Hydrogen Fuel Cell","Tiny Fuel Cell", "generator_hydrogen_fuel_cell", "models/Slyfo/crate_watersmall.mdl")

--Microwave Emitters
Environments.RegisterDevice("Generators", "Microwave Emitter", "Emitter", "generator_microwave", "models/props_phx/life_support/crylaser_small.mdl")
Environments.RegisterDevice("Generators", "Microwave Emitter", "Small Reciever", "reciever_microwave", "models/slyfo_2/miscequipmentradiodish.mdl")
Environments.RegisterDevice("Generators", "Microwave Emitter", "Large Reciever", "reciever_microwave", "models/spacebuild/nova/recieverdish.mdl")
Environments.RegisterDevice("Generators", "Microwave Emitter", "Massive Reciever", "reciever_microwave", "models/props_spytech/satellite_dish001.mdl")

--SpaceGas Collectors
Environments.RegisterDevice("Generators", "Space Gas Collectors", "Gas Collector", "generator_space_gas", "models/spacebuild/medbridge2_missile_launcher.mdl")

//Life Support Tool
--Suit Dispener
Environments.RegisterDevice("Life Support", "Suit Dispenser", "Suit Dispenser", "suit_dispenser", "models/props_combine/combine_emitter01.mdl")
Environments.RegisterDevice("Life Support", "Suit Dispenser", "Flat Dispenser", "suit_dispenser", "models/resourcepump/resourcepump.mdl")

--Medical Dispenser
Environments.RegisterDevice("Life Support", "Medical Dispenser", "Flat Dispenser", "env_health", "models/resourcepump/resourcepump.mdl")
Environments.RegisterDevice("Life Support", "Medical Dispenser", "Delux Dispenser", "env_health", "models/Items/HealthKit.mdl")

--LS Cores
Environments.RegisterDevice("Life Support", "LS Core", "LS Core", "env_lscore", "models/sbep_community/d12airscrubber.mdl")
Environments.RegisterDevice("Life Support", "LS Core","SmallBridge LS Core", "env_lscore","models/smallbridge/life support/sbclimatereg.mdl")

--AtmosProbe
Environments.RegisterDevice("Life Support", "Atmospheric Probe", "Atmospheric Probe", "env_probe", "models/props_combine/combine_mine01.mdl")

--Trade Console
--Environments.RegisterDevice("Life Support", "TradeConsoles","Deluxe TradeConsole", "env_tradeconsole", "models/SBEP_community/errject_smbwallcons.mdl")
--Environments.RegisterDevice("Life Support", "TradeConsoles","Compact TradeConsole", "env_tradeconsole", "models/props_lab/reciever_cart.mdl")

--Item Fabricator
Environments.RegisterDevice("Life Support", "Fabricators","Item Materialiser", "env_factory", "models/slyfo/swordreconlauncher.mdl")


//Storage Tool
--Water
Environments.RegisterDevice("Storages", "Water Storage", "Massive Water Tank", "env_water_storage", "models/props/de_nuke/storagetank.mdl")
Environments.RegisterDevice("Storages", "Water Storage", "Water Shipping Tank", "env_water_storage", "models/slyfo/crate_resource_large.mdl")

--Energy
Environments.RegisterDevice("Storages", "Energy Storage", "Large Battery", "env_energy_storage", "models/props_phx/life_support/battery_large.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Medium Battery", "env_energy_storage", "models/props_phx/life_support/battery_medium.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Small Battery", "env_energy_storage", "models/props_phx/life_support/battery_small.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Substation Capacitor", "env_energy_storage", "models/props_c17/substation_stripebox01a.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Substation Backup Battery", "env_energy_storage", "models/props_c17/substation_transformer01a.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Large Capacitor", "env_energy_storage", "models/mandrac/energy_cell/large_cell.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Medium Capacitor", "env_energy_storage", "models/mandrac/energy_cell/medium_cell.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Small Capacitor", "env_energy_storage", "models/mandrac/energy_cell/small_cell.mdl")

--Oxygen 
Environments.RegisterDevice("Storages", "Oxygen Storage", "Large Oxygen Storage", "env_oxygen_storage", "models/props_wasteland/coolingtank02.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Large Oxygen Canister", "env_oxygen_storage", "models/props_phx/life_support/canister_large.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Medium Oxygen Canister", "env_oxygen_storage", "models/props_phx/life_support/canister_medium.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Small Oxygen Canister", "env_oxygen_storage", "models/props_phx/life_support/canister_small.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Small Oxygen Tank", "env_oxygen_storage", "models/props_phx/life_support/tank_small.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Medium Oxygen Tank", "env_oxygen_storage", "models/props_phx/life_support/tank_medium.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Large Oxygen Tank", "env_oxygen_storage", "models/props_phx/life_support/tank_large.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Oxygen Shipping Tank", "env_oxygen_storage", "models/slyfo/crate_resource_large.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Large Compressed Oxygen Crate", "env_oxygen_storage", "models/mandrac/oxygen_tank/oxygen_tank_large.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Medium Compressed Oxygen Crate", "env_oxygen_storage", "models/mandrac/oxygen_tank/oxygen_tank_medium.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Small Compressed Oxygen Crate", "env_oxygen_storage", "models/mandrac/oxygen_tank/oxygen_tank_small.mdl")

--Nitrogen 
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Large Nitrogen Storage", "env_nitrogen_storage", "models/props_wasteland/coolingtank02.mdl")
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Large Nitrogen Canister", "env_nitrogen_storage", "models/props_phx/life_support/canister_large.mdl", 1)
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Medium Nitrogen Canister", "env_nitrogen_storage", "models/props_phx/life_support/canister_medium.mdl", 1)
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Small Nitrogen Canister", "env_nitrogen_storage", "models/props_phx/life_support/canister_small.mdl", 1)
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Small Nitrogen Tank", "env_nitrogen_storage", "models/props_phx/life_support/tank_small.mdl", 1)
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Medium Nitrogen Tank", "env_nitrogen_storage", "models/props_phx/life_support/tank_medium.mdl", 1)
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Large Nitrogen Tank", "env_nitrogen_storage", "models/props_phx/life_support/tank_large.mdl", 1)
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Nitrogen Shipping Tank", "env_nitrogen_storage", "models/slyfo/crate_resource_large.mdl")

--Hydrogen 
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Large Hydrogen Storage", "env_hydrogen_storage", "models/props_wasteland/coolingtank02.mdl")
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Large Hydrogen Canister", "env_hydrogen_storage", "models/props_phx/life_support/canister_large.mdl", 2)
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Medium Hydrogen Canister", "env_hydrogen_storage", "models/props_phx/life_support/canister_medium.mdl", 2)
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Small Hydrogen Canister", "env_hydrogen_storage", "models/props_phx/life_support/canister_small.mdl", 2)
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Small Hydrogen Tank", "env_hydrogen_storage", "models/props_phx/life_support/tank_small.mdl", 2)
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Medium Hydrogen Tank", "env_hydrogen_storage", "models/props_phx/life_support/tank_medium.mdl", 2)
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Large Hydrogen Tank", "env_hydrogen_storage", "models/props_phx/life_support/tank_large.mdl", 2)
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Hydrogen Shipping Tank", "env_hydrogen_storage", "models/slyfo/crate_resource_large.mdl")

--Co2
Environments.RegisterDevice("Storages", "CO2 Storage", "Large CO2 Storage", "env_co2_storage", "models/props_wasteland/coolingtank02.mdl")
Environments.RegisterDevice("Storages", "CO2 Storage", "Large CO2 Canister", "env_co2_storage", "models/props_phx/life_support/canister_large.mdl", 3)
Environments.RegisterDevice("Storages", "CO2 Storage", "Medium CO2 Canister", "env_co2_storage", "models/props_phx/life_support/canister_medium.mdl", 3)
Environments.RegisterDevice("Storages", "CO2 Storage", "Small CO2 Canister", "env_co2_storage", "models/props_phx/life_support/canister_small.mdl", 3)
Environments.RegisterDevice("Storages", "CO2 Storage", "Small CO2 Tank", "env_co2_storage", "models/props_phx/life_support/tank_small.mdl", 3)
Environments.RegisterDevice("Storages", "CO2 Storage", "Medium CO2 Tank", "env_co2_storage", "models/props_phx/life_support/tank_medium.mdl", 3)
Environments.RegisterDevice("Storages", "CO2 Storage", "Large CO2 Tank", "env_co2_storage", "models/props_phx/life_support/tank_large.mdl", 3)

--Resource Cache
Environments.RegisterDevice("Storages", "Resource Cache","Modular Unit X-01","env_cache_storage","models/Spacebuild/milcock4_multipod1.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","Slyfo Tank 1","env_cache_storage","models/slyfo/t-eng.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","Slyfo Power Crystal","env_cache_storage","models/Slyfo/powercrystal.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge Small Wall Cache","env_cache_storage","models/SmallBridge/Life Support/SBwallcacheS.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge Large Wall Cache","env_cache_storage","models/SmallBridge/Life Support/SBwallcacheL.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge External Wall Cache","env_cache_storage","models/SmallBridge/Life Support/SBwallcacheE.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge Small Wall Cache (half length)","env_cache_storage","models/smallbridge/Life Support/SBwallcacheS05.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge Large Wall Cache (half length)","env_cache_storage","models/smallbridge/Life Support/SBwallcacheL05.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge Hull Cache","env_cache_storage","models/smallbridge/life support/sbhullcache.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Mandrac Cargo Cache", "env_cache_storage", "models/mandrac/resource_cache/cargo_cache.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Mandrac Huge Cache", "env_cache_storage", "models/mandrac/resource_cache/colossal_cache.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Mandrac Hanger Container", "env_cache_storage", "models/mandrac/resource_cache/hangar_container.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Mandrac Large Cache", "env_cache_storage", "models/mandrac/resource_cache/huge_cache.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Mandrac Medium Cache", "env_cache_storage", "models/mandrac/resource_cache/large_cache.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Mandrac Small Cache", "env_cache_storage", "models/mandrac/resource_cache/medium_cache.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Mandrac Tiny Cache", "env_cache_storage", "models/mandrac/resource_cache/small_cache.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Mandrac Levy Cache", "env_cache_storage", "models/mandrac/nitrogen_tank/nitro_large.mdl")
--Admin Cache
Environments.RegisterDevice("Storages", "Admin Cache", "Admin Cache", "environments_admincache", "models/sbep_community/d12siesmiccharge.mdl")

//Core Upgrades
--Radiators
Environments.RegisterDevice("Core Upgrades", "Heat Management","Basic Radiator", "lde_radiator", "models/props_c17/furnitureradiator001a.mdl")
Environments.RegisterDevice("Core Upgrades", "Heat Management","Cyclic Radiator", "lde_radiator", "models/Slyfo/sat_rfg.mdl")
Environments.RegisterDevice("Core Upgrades", "Heat Management","Singularity Radiator", "lde_radiator", "models/Slyfo/crate_reactor.mdl")

--Heater
Environments.RegisterDevice("Core Upgrades", "Heat Management","Basic Heater", "lde_heater", "models/gibs/airboat_broken_engine.mdl")

--Extra
Environments.RegisterDevice("Core Upgrades", "Extra","Vehicle Exit Point", "EPoint", "models/jaanus/wiretool/wiretool_range.mdl")
Environments.RegisterDevice("Core Upgrades", "Extra","Matter Teleporter", "wep_transporter", "models/SBEP_community/d12shieldemitter.mdl")
Environments.RegisterDevice("Core Upgrades", "Extra","WarpDrive", "WarpDrive", "models/Slyfo/ftl_drive.mdl")
Environments.RegisterDevice("Core Upgrades", "Extra","Cloning Device", "envx_clonetube", "models/TwinbladeTM/cryotubemkii.mdl")

//BaseBuilding Prototype
Environments.RegisterDevice("Base Construction", "CoreModules","Base Node", "lde_basecore", "models/Cerus/Modbridge/Misc/LS/ls_gen11a.mdl")