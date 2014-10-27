

local Base = {Tool="Generators Advanced",Type="Nitrogen Fuser"}


--Nitrogen Fuser
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Nitrogen Fuser",class="generator_nitrogen_fuser",In={"carbon dioxide","hydrogen"},Out={"nitrogen"},shootfunc=Func,InUse={70,70},OutMake={50}}
local Makeup = {name={"Nitrogen Fuser Small","Nitrogen Fuser Medium","Nitrogen Fuser Large"},model={"models/SnakeSVx/resource_node_small.mdl","models/SnakeSVx/resource_node_medium.mdl","models/SnakeSVx/resource_node_large.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)


local Base = {Tool="Generators Advanced",Type="Power Generation"}

--Alternater
local Func = function(self)
	local supplyO2 = math.Round(self:GetPhysicsObject():GetAngleVelocity():Length()/10)
	self:SupplyResource("energy", supplyO2)
end
local Data={name="Alternater",class="lde_ang_power",Out={"energy"},shootfunc=Func,OutMake={0}}
local Makeup = {name={"Alternater"},model={"models/Slyfo/sat_sat1.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

local Base = {Tool="Generators Advanced",Type="Ls Charge Compresser"}

--Ls Charge
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Ls Charge Compresser",class="generator_ls_compresser",In={"energy","water","oxygen"},Out={"LS Charge"},shootfunc=Func,InUse={50,5,10},OutMake={5}}
local Makeup = {name={"LS Charge Compressor"},model={"models/SnakeSVx/resource_node_small.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)
