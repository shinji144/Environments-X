
//Polylodarium
local Base = {Tool="Mining Devices",Type="Polylodarium"}

--Crystalised Polylodarium Refinery
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Crystalised Polylodarium Refinery",class="generator_crys_poly_refine",In={"Crystalised Polylodarium","energy"},Out={"Liquid Polylodarium"},shootfunc=Func,InUse={30,2000},OutMake={10}}
local Makeup = {name={"Crystalised Polylodarium Refinery"},model={"models/Cerus/Modbridge/Misc/LS/ls_gen11a.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

--Liquid Polylodarium dehydrator
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Liquid Polylodarium Dehydrator",class="generator_poly_dehydrator",In={"Liquid Polylodarium","energy"},Out={"Crystalised Polylodarium"},shootfunc=Func,InUse={10,2000},OutMake={20}}
local Makeup = {name={"Polylodarium Dehydrator"},model={"models/Slyfo_2/acc_sci_coolerator.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

--Polylodarium Hydrator
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Polylodarium Rehydrator",class="generator_poly_hydrator",In={"Liquid Polylodarium","energy"},Out={"water"},shootfunc=Func,InUse={10,800},OutMake={300}}
local Makeup = {name={"Polylodarium Rehydrator"},model={"models/Slyfo_2/acc_sci_coolerator.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

//Electromium
local Base = {Tool="Mining Devices",Type="Electromium"}

--[[
--Electromium Materialiser
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Electromium Materialiser",class="generator_electrom_mat",In={"energy"},Out={"Electromium"},shootfunc=Func,InUse={2000},OutMake={2}}
local Makeup = {name={"Electromium Materialiser"},model={"models/ce_ls3additional/fusion_generator/fusion_generator_large.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)
]]

--Electromium Converter
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Electromium Converter",class="generator_electrom_con",In={"Electromium"},Out={"Liquid Polylodarium"},shootfunc=Func,InUse={20},OutMake={2}}
local Makeup = {name={"Electromium Converter"},model={"models/chipstiks_ls3_models/NitrogenLiquifier/nitrogenliquifier.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

//Plasma
local Base = {Tool="Mining Devices",Type="Plasma"}

--Plasma Heater
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Plasma Heater",class="generator_plasma_heat",In={"energy","hydrogen",},Out={"Plasma"},shootfunc=Func,InUse={800,100},OutMake={10}}
local Makeup = {name={"Plasma Heater","Micro Heater"},model={"models/Punisher239/punisher239_reactor_small.mdl","models/SBEP_community/d12fusionbomb.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

//Ore
local Base = {Tool="Mining Devices",Type="Ore"}

--Ore refinery
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Ore Refinery",class="generator_ore_refinery",In={"Raw Ore","energy"},Out={"Refined Ore","carbon dioxide"},shootfunc=Func,InUse={10,300},OutMake={8,40}}
local Makeup = {name={"Ore Refinery"},model={"models/Slyfo/refinery_small.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

--Ore hardener
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Ore Hardener",class="generator_ore_hardener",In={"Refined Ore","Crystalised Polylodarium","energy"},Out={"Hardened Ore"},shootfunc=Func,InUse={50,40,1000},OutMake={30}}
local Makeup = {name={"Small Ore Hardener","Large Ore Hardener"},model={"models/slyfo_2/acc_sci_coolerator.mdl","models/Cerus/Modbridge/Misc/LS/ls_gen11a.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

//Carbon
local Base = {Tool="Mining Devices",Type="Carbon"}

--Carbon Extractor
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Carbon Extractor",class="generator_carbon_extract",In={"Raw Ore","energy"},Out={"Carbon"},shootfunc=Func,InUse={10,400},OutMake={2}}
local Makeup = {name={"Carbon Extractor"},model={"models/Slyfo_2/acc_sci_hoterator.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

--Carbon Oxidizer
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Carbon Oxidizer",class="generator_carbon_oxidizer",In={"Carbon","oxygen","energy"},Out={"carbon dioxide"},shootfunc=Func,InUse={3,30,600},OutMake={25}}
local Makeup = {name={"Carbon Oxidizer"},model={"models/SBEP_community/d12airscrubber.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

//Drills
local Base = {Tool="Mining Devices",Type="Mining Drills"}

--Poly Drill
local Func = function(self) if(self.Active==1)then
if(LDE.LifeSupport.HasNeeded(self,self.Data.In))then LDE.LifeSupport.UseResources(self,self.Data.In)
if(LDE.LifeSupport.DrillWorld(self))then rand = math.random(0,3) --self:SupplyResource("Raw Ore",(2+rand)*self.Mult) No more mining ore with drills. >:(
if self.environment:GetTemperature(self) > 300 then self:SupplyResource("Crystalised Polylodarium",(1+rand)*self.Mult)
Owner=self.LDEOwner
Owner:GiveLDEStat("Mined", (4+rand*self.Mult))
end end end end end
local Data={name="Polylodarium Drill",class="lde_ore_drill",In={"energy"},Out={"Crystalised Polylodarium"},shootfunc=Func,InUse={600},OutMake={0}}
local Makeup = {name={"Rover Drill","Compact Drill","Stand Alone Drill"},model={"models/Slyfo/rover_drillbase.mdl","models/Slyfo/drillbase_basic.mdl","models/Slyfo/drillplatform.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

//Lasers
local Base = {Tool="Mining Devices",Type="Mining Lasers"}

--Ore Harvester
local Func = function(self) if(self.Active==1)then
if(LDE.LifeSupport.HasNeeded(self,self.Data.In))then LDE.LifeSupport.UseResources(self,self.Data.In)
self:SupplyResource("Raw Ore",(LDE.LifeSupport.DrillEnt(self,"space_asteroid",(math.random(5,10)+10)*self:GetMultiplier())))
end end end
local Data={name="Ore Laser",class="lde_ore_harvester",In={"energy"},Out={"Raw Ore"},shootfunc=Func,InUse={300},OutMake={0}}
local Makeup = {name={"Basic Laser"},model={"models/mandrac/laser5.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

--Scrap Collector
local Base = {Tool="Life Support",Type="Scrap Collection"}
local Func = function(self) end
local Data={name="Scrap Collector",class="generator_scrap_collect",In={"Scrap Bits"},Out={"Recycled Resources"},shootfunc=Func,InUse={0},OutMake={0}}
local Makeup = {name={"Scrap Collector"},model={"models/Slyfo/finfunnel.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)


-------------I will decide if i want to keep this or not later.---------------------
--Spore Harvester
--[[
local Func = function(self) if(self.Active==1)then
if(LDE.LifeSupport.HasNeeded(self,self.Data.In))then LDE.LifeSupport.UseResources(self,self.Data.In)
if(LDE.LifeSupport.DrillEnt(self,"lde_spore"))then rand = math.random(1,3) self:SupplyResource("Liquid Polylodarium",(1+rand)*self.Mult)
Owner=self.LDEOwner
Owner:GiveLDEStat("Mined", (4+rand*self.Mult))
end end end end
local Data={name="Spore Laser",class="lde_spore_harvester",In={"energy"},Out={"Liquid Polylodarium"},shootfunc=Func,InUse={300},OutMake={0}}
local Makeup = {name={"Spore Laser"},model={"models/mandrac/laser2.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)]]


