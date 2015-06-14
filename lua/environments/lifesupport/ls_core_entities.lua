//Core Environments LS Entities/Devices

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
Environments.RegisterDevice("Generators", "Fusion Generator", "Small SBEP Reactor", "generator_fusion", "models/punisher239/punisher239_reactor_small.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Large SBEP Reactor", "generator_fusion", "models/punisher239/punisher239_reactor_big.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Small Pallet Reactor", "generator_fusion", "models/slyfo/forklift_reactor.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Large Crate Reactor", "generator_fusion", "models/slyfo/crate_reactor.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Classic Reactor", "generator_fusion", "models/props_c17/substation_circuitbreaker01a.mdl")

Environments.RegisterDevice("Generators", "Fission Generator", "Basic Fission Reactor", "generator_fission", "models/SBEP_community/d12siesmiccharge.mdl")

Environments.RegisterDevice("Generators", "Water Pump", "Small Water Pump", "generator_water", "models/props_phx/life_support/gen_water.mdl")

Environments.RegisterDevice("Generators", "Oxygen Compressor", "Oxygen Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "oxygen")
Environments.RegisterDevice("Generators", "Nitrogen Compressor", "Nitrogen Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "nitrogen")
Environments.RegisterDevice("Generators", "Hydrogen Compressor", "Hydrogen Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "hydrogen")
Environments.RegisterDevice("Generators", "CO2 Compressor", "CO2 Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "carbon dioxide")

Environments.RegisterDevice("Generators", "Water Splitter", "Electrolysis Generator", "generator_water_to_air", "models/slyfo/electrolysis_gen.mdl")

Environments.RegisterDevice("Generators", "Hydrogen Fuel Cell", "Small Fuel Cell", "generator_hydrogen_fuel_cell", "models/slyfo/electrolysis_gen.mdl")

Environments.RegisterDevice("Generators", "Microwave Emitter", "Emitter", "generator_microwave", "models/props_phx/life_support/crylaser_small.mdl")

Environments.RegisterDevice("Generators", "Microwave Emitter", "Small Reciever", "reciever_microwave", "models/slyfo_2/miscequipmentradiodish.mdl")
Environments.RegisterDevice("Generators", "Microwave Emitter", "Large Reciever", "reciever_microwave", "models/spacebuild/nova/recieverdish.mdl")
Environments.RegisterDevice("Generators", "Microwave Emitter", "Massive Reciever", "reciever_microwave", "models/props_spytech/satellite_dish001.mdl")

Environments.RegisterDevice("Generators", "Space Gas Collectors", "Gas Collector", "generator_space_gas", "models/spacebuild/medbridge2_missile_launcher.mdl")

//Storage Tool
Environments.RegisterDevice("Storages", "Water Storage", "Massive Water Tank", "env_water_storage", "models/props/de_nuke/storagetank.mdl")
Environments.RegisterDevice("Storages", "Water Storage", "Water Shipping Tank", "env_water_storage", "models/slyfo/crate_resource_large.mdl")

Environments.RegisterDevice("Storages", "Energy Storage", "Large Battery", "env_energy_storage", "models/props_phx/life_support/battery_large.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Medium Battery", "env_energy_storage", "models/props_phx/life_support/battery_medium.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Small Battery", "env_energy_storage", "models/props_phx/life_support/battery_small.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Substation Capacitor", "env_energy_storage", "models/props_c17/substation_stripebox01a.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Substation Backup Battery", "env_energy_storage", "models/props_c17/substation_transformer01a.mdl")

Environments.RegisterDevice("Storages", "Oxygen Storage", "Large Oxygen Storage", "env_oxygen_storage", "models/props_wasteland/coolingtank02.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Large Oxygen Canister", "env_oxygen_storage", "models/props_phx/life_support/canister_large.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Medium Oxygen Canister", "env_oxygen_storage", "models/props_phx/life_support/canister_medium.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Small Oxygen Canister", "env_oxygen_storage", "models/props_phx/life_support/canister_small.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Small Oxygen Tank", "env_oxygen_storage", "models/props_phx/life_support/tank_small.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Medium Oxygen Tank", "env_oxygen_storage", "models/props_phx/life_support/tank_medium.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Large Oxygen Tank", "env_oxygen_storage", "models/props_phx/life_support/tank_large.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Oxygen Shipping Tank", "env_oxygen_storage", "models/slyfo/crate_resource_large.mdl")

Environments.RegisterDevice("Storages", "Nitrogen Storage", "Large Nitrogen Storage", "env_nitrogen_storage", "models/props_wasteland/coolingtank02.mdl")
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Large Nitrogen Canister", "env_nitrogen_storage", "models/props_phx/life_support/canister_large.mdl", 1)
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Medium Nitrogen Canister", "env_nitrogen_storage", "models/props_phx/life_support/canister_medium.mdl", 1)
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Small Nitrogen Canister", "env_nitrogen_storage", "models/props_phx/life_support/canister_small.mdl", 1)
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Small Nitrogen Tank", "env_nitrogen_storage", "models/props_phx/life_support/tank_small.mdl", 1)
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Medium Nitrogen Tank", "env_nitrogen_storage", "models/props_phx/life_support/tank_medium.mdl", 1)
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Large Nitrogen Tank", "env_nitrogen_storage", "models/props_phx/life_support/tank_large.mdl", 1)
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Nitrogen Shipping Tank", "env_nitrogen_storage", "models/slyfo/crate_resource_large.mdl")


Environments.RegisterDevice("Storages", "Hydrogen Storage", "Large Hydrogen Storage", "env_hydrogen_storage", "models/props_wasteland/coolingtank02.mdl")
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Large Hydrogen Canister", "env_hydrogen_storage", "models/props_phx/life_support/canister_large.mdl", 2)
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Medium Hydrogen Canister", "env_hydrogen_storage", "models/props_phx/life_support/canister_medium.mdl", 2)
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Small Hydrogen Canister", "env_hydrogen_storage", "models/props_phx/life_support/canister_small.mdl", 2)
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Small Hydrogen Tank", "env_hydrogen_storage", "models/props_phx/life_support/tank_small.mdl", 2)
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Medium Hydrogen Tank", "env_hydrogen_storage", "models/props_phx/life_support/tank_medium.mdl", 2)
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Large Hydrogen Tank", "env_hydrogen_storage", "models/props_phx/life_support/tank_large.mdl", 2)
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Hydrogen Shipping Tank", "env_hydrogen_storage", "models/slyfo/crate_resource_large.mdl")


Environments.RegisterDevice("Storages", "CO2 Storage", "Large CO2 Storage", "env_co2_storage", "models/props_wasteland/coolingtank02.mdl")
Environments.RegisterDevice("Storages", "CO2 Storage", "Large CO2 Canister", "env_co2_storage", "models/props_phx/life_support/canister_large.mdl", 3)
Environments.RegisterDevice("Storages", "CO2 Storage", "Medium CO2 Canister", "env_co2_storage", "models/props_phx/life_support/canister_medium.mdl", 3)
Environments.RegisterDevice("Storages", "CO2 Storage", "Small CO2 Canister", "env_co2_storage", "models/props_phx/life_support/canister_small.mdl", 3)
Environments.RegisterDevice("Storages", "CO2 Storage", "Small CO2 Tank", "env_co2_storage", "models/props_phx/life_support/tank_small.mdl", 3)
Environments.RegisterDevice("Storages", "CO2 Storage", "Medium CO2 Tank", "env_co2_storage", "models/props_phx/life_support/tank_medium.mdl", 3)
Environments.RegisterDevice("Storages", "CO2 Storage", "Large CO2 Tank", "env_co2_storage", "models/props_phx/life_support/tank_large.mdl", 3)

Environments.RegisterDevice("Storages", "Resource Cache","Modular Unit X-01","env_cache_storage","models/Spacebuild/milcock4_multipod1.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","Slyfo Tank 1","env_cache_storage","models/slyfo/t-eng.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","Slyfo Power Crystal","env_cache_storage","models/Slyfo/powercrystal.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge Small Wall Cache","env_cache_storage","models/SmallBridge/Life Support/SBwallcacheS.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge Large Wall Cache","env_cache_storage","models/SmallBridge/Life Support/SBwallcacheL.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge External Wall Cache","env_cache_storage","models/SmallBridge/Life Support/SBwallcacheE.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge Small Wall Cache (half length)","env_cache_storage","models/smallbridge/Life Support/SBwallcacheS05.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge Large Wall Cache (half length)","env_cache_storage","models/smallbridge/Life Support/SBwallcacheL05.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge Hull Cache","env_cache_storage","models/smallbridge/life support/sbhullcache.mdl")

Environments.RegisterDevice("Storages", "Admin Cache", "Admin Cache", "environments_admincache", "models/sbep_community/d12siesmiccharge.mdl")

//Life Support Tool
Environments.RegisterDevice("Life Support", "Suit Dispenser", "Suit Dispenser", "suit_dispenser", "models/props_combine/combine_emitter01.mdl")

Environments.RegisterDevice("Life Support", "LS Core", "LS Core", "env_lscore", "models/sbep_community/d12airscrubber.mdl")
Environments.RegisterDevice("Life Support", "LS Core","SmallBridge LS Core", "env_lscore","models/smallbridge/life support/sbclimatereg.mdl")

Environments.RegisterDevice("Life Support", "Atmospheric Probe", "Atmospheric Probe", "env_probe", "models/props_combine/combine_mine01.mdl")
