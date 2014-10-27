
--Hull Repairer
local Func = function(self) if(self.Active==1)then
	local core = self.LDE.Core
	if(not core or not core:IsValid())then self.LDE.Core = nil return end
	local ore = self:GetResourceAmount("Refined Ore")
	local needed = core.LDE.CoreMaxHealth-core.LDE.CoreHealth
	if(needed>=100)then oreuse=100 else oreuse=needed end
	if(ore>=math.abs((oreuse)*(self:GetMultiplier() or 1)) and oreuse>0) then
		self:ConsumeResource("Refined Ore", math.abs((oreuse)*(self:GetMultiplier() or 1)))
		LDE:RepairCoreHealth( core, (oreuse*10)*(self:GetMultiplier() or 1) )
		WireLib.TriggerOutput( core, "Health", core.LDE.CoreHealth)	
	end end end
local Data={name="Hull Repairer",class="lde_repair",In={"Refined Ore"},shootfunc=Func,InUse={0}}
LDE.LifeSupport.RegisterDevice(Data)

--Shield Recharger
local Func = function(self) if(self.Active==1)then
	if(not self.LDE)then return end
	local core = self.LDE.Core
	if(not core or not core:IsValid())then self.LDE.Core = nil return end
	local energy = self:GetResourceAmount("energy")
	local needed = core.LDE.CoreMaxShield-core.LDE.CoreShield
	if(core.LDE.CanRecharge==0)then return end
	if(needed>=100)then energyuse=100 else energyuse=needed end
	if(energy>=math.abs((energyuse*2)*(self:GetMultiplier() or 1)) and energyuse>0) then
		WireLib.TriggerOutput( core, "Shields", core.LDE.CoreShield)	
		self:ConsumeResource("energy", math.abs((energyuse*2)*(self:GetMultiplier() or 1)))
		core.LDE.CoreShield = math.Clamp(core.LDE.CoreShield+math.abs(energyuse*(self:GetMultiplier() or 1)),0,core.LDE.CoreMaxShield)
		core:SetNWInt("LDEShield", core.LDE.CoreShield)
		WireLib.TriggerOutput( core, "Shields", core.LDE.CoreShield or 0 )
	end end end
local Data={name="Shield Recharger",class="lde_recharge",In={"energy"},shootfunc=Func,InUse={0}}
LDE.LifeSupport.RegisterDevice(Data)

Environments.RegisterDevice("Core Upgrades", "Regenerators","Hull Repairer", "lde_repair", "models/gibs/airboat_broken_engine.mdl")
Environments.RegisterDevice("Core Upgrades", "Regenerators","Shield Recharger", "lde_recharge", "models/slyfo_2/acc_sci_coolerator.mdl")
