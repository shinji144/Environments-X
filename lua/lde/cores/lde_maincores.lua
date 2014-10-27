
------------------------------------
-----------Simple Cores-------------
------------------------------------

local Think = function(self)
	LDE.CoreSys.ShieldAge(self,self.Data)
end

--Basic Core
local Data={name="Basic Core",class="lde_core",Think=Think,ShieldRate=0.7,ShieldAge=0.005,HealthRate=1.3,ArmorRate=1,TempResist=1,CoolBonus=2,CPSRate=0.04}
LDE.CoreSys.RegisterCore(Data)

--Armor Core
local Data={name="Armor Core",class="lde_core_armor",Think=Think,ShieldRate=0.2,ShieldAge=0.01,HealthRate=1.8,ArmorRate=2,TempResist=2,CoolBonus=3,CPSRate=0.06}
LDE.CoreSys.RegisterCore(Data)

--Shield Core
local Data={name="Shield Core",class="lde_core_shield",Think=Think,ShieldRate=1.8,ShieldAge=0.003,HealthRate=0.2,ArmorRate=0.5,TempResist=0.8,CoolBonus=1,CPSRate=0.06}
LDE.CoreSys.RegisterCore(Data)

--Trade Core
local Data={name="Trade Core",class="lde_core_trade",Think=Think,ShieldRate=1.3,ShieldAge=0.004,HealthRate=0.7,ArmorRate=0.75,TempResist=2,CoolBonus=1,CPSRate=0.03}
LDE.CoreSys.RegisterCore(Data)

--OverClocked Core
local Data={name="OverClocked Core",class="lde_core_over",Think=Think,ShieldRate=3.9,ShieldAge=0.03,HealthRate=0.1,ArmorRate=0.25,TempResist=0.1,CoolBonus=0.5,CPSRate=0.03}
LDE.CoreSys.RegisterCore(Data)

--Bricked Core
local Data={name="Bricked Core",class="lde_core_brick",Think=Think,ShieldRate=0,ShieldAge=0,HealthRate=4,ArmorRate=3,TempResist=3,CoolBonus=2,CPSRate=0.03}
LDE.CoreSys.RegisterCore(Data)

------------------------------------
-----------Special Cores------------
------------------------------------

--Thorium Core
local Data={name="Thorium Core",class="lde_core_thor",Think=Think,ShieldRate=0.3,ShieldAge=-0.1,HealthRate=0.05,ArmorRate=0.5,TempResist=0.1,CoolBonus=0.8,CPSRate=0.02}
LDE.CoreSys.RegisterCore(Data)

local Think = function(self)
	LDE.CoreSys.ShieldAge(self,self.Data)
	LDE.CoreSys.Radiate(self,self.Data)
end

--HeatSink Core
local Data={name="HeatSink Core",class="lde_core_sink",Think=Think,ShieldRate=0.005,ShieldAge=0.004,HealthRate=0.1,ArmorRate=3,TempResist=1.5,CoolBonus=3,CPSRate=0.05}
LDE.CoreSys.RegisterCore(Data)