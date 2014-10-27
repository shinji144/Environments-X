
--Shell production factory
local Base = {Tool="Ammo Production",Type="Basic Shells"}
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Shell Factory",class="generator_shell_small",In={"Casings","energy"},Out={"Shells"},shootfunc=Func,InUse={10,400},OutMake={1}}
local Makeup = {name={"Basic Shell Factory"},model={"models/SmallBridge/Life Support/sbclimatereg.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

--Heavy Shell production factory
local Base = {Tool="Ammo Production",Type="Heavy Shells"}
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Heavy Shell Factory",class="generator_heavyshell_small",In={"Hardened Ore","Casings","energy"},Out={"Heavy Shells"},shootfunc=Func,InUse={10,50,800},OutMake={7}}
local Makeup = {name={"Heavy Shell Factory"},model={"models/SmallBridge/Life Support/sbclimatereg.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

--Bullet production factory
local Base = {Tool="Ammo Production",Type="Basic Rounds"}
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Bullet Factory",class="generator_bullets_small",In={"Casings","energy"},Out={"Basic Rounds"},shootfunc=Func,InUse={10,1000},OutMake={10}}
local Makeup = {name={"Basic Rounds Factory"},model={"models/SmallBridge/Life Support/sbclimatereg.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)


--Missile parts production factory
local Base = {Tool="Ammo Production",Type="Missile Parts"}
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Missile Parts Factory",class="generator_mparts_small",In={"nitrogen","Refined Ore","hydrogen","energy"},Out={"Missile Parts"},shootfunc=Func,InUse={200,50,500,2000},OutMake={4}}
local Makeup = {name={"Missile Parts Factory"},model={"models/SmallBridge/Life Support/sbclimatereg.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)


--Casing factory
local Base = {Tool="Ammo Production",Type="Casings"}
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Casing Factory",class="generator_casing_small",In={"Refined Ore","energy"},Out={"Casings"},shootfunc=Func,InUse={5,100},OutMake={5}}
local Makeup = {name={"Casing Factory"},model={"models/SmallBridge/Life Support/sbclimatereg.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

--Customisable lamps
local Func = function(self) if(self.Active==1)then self.RunLight=1 LDE.LifeSupport.ManageResources(self) else self.RunLight=0 end LDE.LifeSupport.RunLight(self,self.LightData) end
local Data={name="High Tech Light",class="lifesupport_lamp",In={"energy"},shootfunc=Func,InUse={1}}
LDE.LifeSupport.RegisterDevice(Data)
