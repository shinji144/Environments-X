
--Raw Ore Storage
local Base = {Tool="Mining Storage",Type="Raw Ore"}
local Names = {"Large Raw Ore Crate","Raw Ore Barrel","Raw Ore Outer Cache","Raw Ore Huge Mandrac","Raw Ore Medium Mandrac"}
local Models = {"models/Slyfo/nacshuttleleft.mdl","models/Slyfo/barrel_unrefined.mdl","models/SmallBridge/Life Support/sbwallcachee.mdl","models/mandrac/ore_container/ore_large.mdl","models/mandrac/ore_container/ore_medium.mdl"}
local Data={name="Raw Ore Storage",class="lde_ore_storage",storage={"Raw Ore"},Rates={[100] = "Raw Ore"}}
local Makeup = {name=Names,model=Models,Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileStorage(Data,Makeup)

--Refined Ore Storage
local Base = {Tool="Mining Storage",Type="Refined Ore"}
local Names = {"Refined Ore Outer Cache","Refined Ore Large Mandrac","Refined Ore Small Mandrac"}
local Models = {"models/SmallBridge/Life Support/sbwallcachee.mdl","models/mandrac/hw_tank/hw_tank_large.mdl","models/mandrac/hw_tank/hw_tank_small.mdl"}
local Data={name="Refined Ore Storage",class="lde_refined_ore_storage",storage={"Refined Ore"},Rates={[80] = "Refined Ore"}}
local Makeup = {name=Names,model=Models,Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileStorage(Data,Makeup)

--Hardend Ore Storage
local Base = {Tool="Mining Storage",Type="Hardend Ore"}
local Names = {"Hardened Ore Outer Cache","Hardened Ore Crate","Hardened Ore Huge Mandrac","Hardened Ore Medium Mandrac","Hardened Ore Small Mandrac"}
local Models = {"models/SmallBridge/Life Support/sbwallcachee.mdl","models/Slyfo/nacshuttleleft.mdl","models/mandrac/oxygen_tank/oxygen_tank_large.mdl","models/mandrac/oxygen_tank/oxygen_tank_medium.mdl","models/mandrac/oxygen_tank/oxygen_tank_small.mdl"}
local Data={name="Hardened Ore Storage",class="lde_hardend_ore_storage",storage={"Hardened Ore"},Rates={[60] = "Hardened Ore"}}
local Makeup = {name=Names,model=Models,Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileStorage(Data,Makeup)

--Carbon Storage
local Base = {Tool="Mining Storage",Type="Carbon"}
local Names = {"Large Carbon Mandrac","Small Carbon Mandrac"}
local Models = {"models/mandrac/hydrogen_tank/hydro_tank_large.mdl","models/mandrac/hydrogen_tank/hydro_tank_small.mdl"}
local Data={name="Carbon Storage",class="lde_carbon_storage",storage={"Carbon"},Rates={[20] = "Carbon"}}
local Makeup = {name=Names,model=Models,Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileStorage(Data,Makeup)

--Crystalised Polylodarium Storage
local Base = {Tool="Mining Storage",Type="Polylodarium"}
local Names = {"Crystalised Polylodarium Cache","Crystalised Polylodarium Huge Mandrac","Crystalised Polylodarium Medium Mandrac"}
local Models = {"models/SmallBridge/Life Support/sbwallcachee.mdl","models/mandrac/ore_container/ore_large.mdl","models/mandrac/ore_container/ore_medium.mdl"}
local Data={name="Crystalised Polylodarium Storage",class="lde_crys_poly_storage",storage={"Crystalised Polylodarium"},Rates={[40] = "Crystalised Polylodarium"}}
local Makeup = {name=Names,model=Models,Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileStorage(Data,Makeup)

--Liquid Polylodarium Storage
local Names = {"Liquid Polylodarium Barrel","Liquid Polylodarium Huge Mandrac"}
local Models = {"models/Slyfo/barrel_unrefined.mdl","models/mandrac/hydrogen_tank/hydro_tank_small.mdl"}
local Data={name="Liquid Polylodarium Storage",class="lde_liqu_poly_storage",storage={"Liquid Polylodarium"},Rates={[70] = "Liquid Polylodarium"}}
local Makeup = {name=Names,model=Models,Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileStorage(Data,Makeup)

--Electromium Storage
local Base = {Tool="Mining Storage",Type="Electromium"}
local Names = {"Electromium Storage Huge","Electromium Storage Large","Electromium Storage Medium","Electromium Storage Small"}
local Models = {"models/ce_ls3additional/energy_cells/energy_cell_huge.mdl","models/ce_ls3additional/energy_cells/energy_cell_large.mdl","models/ce_ls3additional/energy_cells/energy_cell_medium.mdl","models/ce_ls3additional/energy_cells/energy_cell_small.mdl"}
local Data={name="Electromium Storage",class="lde_electrom_storage",storage={"Electromium"},Rates={[10] = "Electromium"}}
local Makeup = {name=Names,model=Models,Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileStorage(Data,Makeup)

--Casings Storage
local Base = {Tool="Ammo Production",Type="Casings"}
local Names = {"Casing Cache","Casing Barrel"}
local Models = {"models/SmallBridge/Life Support/sbwallcaches05.mdl","models/Slyfo/barrel_refined.mdl"}
local Data={name="Casings Storage",class="lde_casings_storage",storage={"Casings"},Rates={[120] = "Casings"}}
local Makeup = {name=Names,model=Models,Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileStorage(Data,Makeup)

--Basic Shells Storage
local Base = {Tool="Ammo Production",Type="Basic Shells"}
local Names = {"Shell Wall Storage","Small Shell Storage"}
local Models = {"models/SmallBridge/Life Support/sbwallcaches05.mdl","models/slyfo_2/rocketpod_turbo_full.mdl"}
local Data={name="Basic Shells Storage",class="lde_shells_storage",storage={"Shells"},Rates={[30] = "Shells"}}
local Makeup = {name=Names,model=Models,Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileStorage(Data,Makeup)

--Basic Rounds Storage
local Base = {Tool="Ammo Production",Type="Basic Rounds"}
local Names = {"Basic Round Storage","Basic Round Box"}
local Models = {"models/SmallBridge/Life Support/sbwallcaches05.mdl","models/Items/BoxMRounds.mdl"}
local Data={name="Basic Rounds Storage",class="lde_brounds_storage",storage={"Basic Rounds"},Rates={[3000] = "Basic Rounds"}}
local Makeup = {name=Names,model=Models,Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileStorage(Data,Makeup)

--Heavy Shells Storage
local Base = {Tool="Ammo Production",Type="Heavy Shells"}
local Names = {"Wall Storage","Turret Stockpile"}
local Models = {"models/SmallBridge/Life Support/sbwallcaches05.mdl","models/mandrac/projectile/cap_autocannon_gunbase.mdl"}
local Data={name="Heavy shells Storage",class="lde_hshells_storage",storage={"Heavy Shells"},Rates={[15] = "Heavy Shells"}}
local Makeup = {name=Names,model=Models,Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileStorage(Data,Makeup)

--Missile Parts Storage
local Base = {Tool="Ammo Production",Type="Missile Parts"}
local Names = {"Missile Parts Storage"}
local Models = {"models/SmallBridge/Life Support/sbwallcaches05.mdl"}
local Data={name="Missile Parts Storage",class="lde_mparts_storage",storage={"Missile Parts"},Rates={[20] = "Missile Parts"}}
local Makeup = {name=Names,model=Models,Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileStorage(Data,Makeup)

--Plasma Storage
local Base = {Tool="Ammo Production",Type="Plasma"}
local Names = {"Basic Plasma Storage","Quantom Plasma Storage"}
local Models = {"models/SmallBridge/Life Support/sbfusiongen.mdl","models/Slyfo/powercrystal.mdl"}
local Data={name="Plasma Storage",class="lde_plasma_storage",storage={"Plasma"},Rates={[4] = "Plasma"}}
local Makeup = {name=Names,model=Models,Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileStorage(Data,Makeup)

--BlackHolium
local Base = {Tool="Mining Storage",Type="BlackHolium"}
local Names = {"BlackHolium Storage"}
local Models = {"models/SBEP_community/d12siesmiccharge.mdl"}
local Data={name="BlackHolium Storage",class="lde_blackhole_storage",storage={"Blackholium"},Rates={[5] = "Blackholium"}}
local Makeup = {name=Names,model=Models,Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileStorage(Data,Makeup)

--[[
--LSCharge
local Base = {Tool="Storages",Type="LS Charge"}
local Names = {"Large LS Charge Storage","Medium LS Charge Storage","Portable LS Charge Storage"}
local Models = {"models/slyfo/t-eng.mdl","models/spacebuild/smallairtank.mdl","models/slyfo_2/acc_oxygenpaste.mdl"}
local Data={name="LS Charge Storage",class="lde_lscharge_storage",storage={"LS Charge"},Rates={[19000] = "LS Charge"}}
local Makeup = {name=Names,model=Models,Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileStorage(Data,Makeup)
]]

