local BulletFunc=function(self,Data,attacker,tr)
	local NewData = { 
		Pos 					=		tr.HitPos,							--Required--		--Position of the Explosion, World vector
		ShrapDamage	=		Data.ShrapDamage,			--Optional--		--Amount of Damage dealt by each Shrapnel that hits, if 0 or nil then other Shap vars are not required
		ShrapCount		=		Data.ShrapCount,										--Number of Shrapnel, 0 to not use Shrapnel
		ShrapDir			=		Vector(0,0,0),											--Direction of the Shrapnel, Direction vector, Example: Missile:GetForward()
		ShrapCone		=		180,															--Cone Angle the Shrapnel is randomly fired into, 0-180, 0 for all to be released directly forward, 180 to be released in a sphere
		ShrapRadius		=		Data.Radius/2,											--How far the Shrapnel travels
		ShockDamage	=		Data.Damage,					--Optional--		--Amount of Shockwave Damage, if 0 or nil then other Shock vars are not required
		ShockRadius		=		Data.Radius,												--How far the Shockwave travels in a sphere
		--Ignore			=		self,									--Optional--		--Entity that Shrapnel and Shockwaves ignore, Example: A missile entity so that Shrapnel doesn't hit it before it's removed
		Inflictor				=		self,							--Required--		--The weapon or player that is dealing the damage
		Owner				=		self.LDEOwner					--Required--		--The player that owns the weapon, or the Player if the Inflictor is a player
	}
	LDE:BlastDamage(NewData)
	local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetStart(tr.HitPos)
	util.Effect( Data.Effect or "explosion", effectdata )
end

local Func = function(self,CanFire) 
	if(self.Active==1 and CanFire)then 
		if(LDE.LifeSupport.ManageResources(self,1))then 
			LDE.Weapons.ShootShell(self,self.Data.Bullet)
			return true
		end 
	end
	return false
end
local Base = {Tool="Weapon Systems",Type="Cannons"}

--Huge cannon
local Bullet = {ShrapCount=15,ShrapDamage=80,Spread=2,Radius=1600,Damage=10000,Recoil=5000,Speed=150,Model="models/props_combine/headcrabcannister01a.mdl",BulletFunc=BulletFunc,FireSound="ambient/explosions/explode_6.wav"}
local Data={name="Huge Cannon",class="huge_cannon_weapon",In={"Heavy Shells"},shootfunc=Func,Points=2200,heat=500,firespeed=6,InUse={3},Bullet=Bullet}
local Makeup = {name={"Huge Cannon"},model={"models/Cerus/Modbridge/Misc/Weapons/wep_ion1.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class,Unlock=true,UnlockCost=800000,UnlockType="Cannons"}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Basic cannon
local Bullet = {ShrapCount=10,ShrapDamage=40,Spread=1,Radius=800,Damage=5000,Recoil=2000,Speed=125,BulletFunc=BulletFunc,FireSound="ambient/explosions/explode_4.wav"}
local Data={name="Basic Cannon",class="basic_cannon_weapon",In={"Shells"},Out={"Casings"},OutMake={3},shootfunc=Func,Points=600,heat=50,firespeed=5,InUse={3},Bullet=Bullet,MountType="Medium",MVO=Vector(70,0,0)}
local Makeup = {name={"Basic Cannon"},model={"models/Slyfo/mcpcannon.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class,Unlock=true,UnlockCost=16000,UnlockType="Cannons"}
LDE.Weapons.CompileWeapon(Data,Makeup)

local Data={name="Slim Basic Cannon",class="slimbasic_cannon_weapon",In={"Shells"},Out={"Casings"},OutMake={3},shootfunc=Func,Points=600,heat=50,firespeed=5,InUse={3},Bullet=Bullet,MountType="NCannon"}
local Makeup = {name={"Slim Basic Cannon"},model={"models/SBEP_community/navalgun.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class,Unlock=true,UnlockCost=16000,UnlockType="Cannons"}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Micro cannon
local Bullet = {ShrapCount=5,ShrapDamage=40,Spread=1,Radius=400,Damage=2000,Recoil=1000,Speed=100,BulletFunc=BulletFunc,FireSound="ambient/explosions/explode_1.wav"}
local Data={name="Micro Cannon",class="micro_cannon_weapon",In={"Shells"},Out={"Casings"},OutMake={6},shootfunc=Func,Points=350,heat=20,firespeed=3,InUse={1},Bullet=Bullet}
local Makeup = {name={"Micro Cannon"},model={"models/Slyfo_2/weap_prover_industrialspiker.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class,Unlock=true,UnlockCost=4000,UnlockType="Cannons"}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Thud cannon
local Bullet = {Spread=2,Damage=7500,Recoil=5000,Speed=100,FireSound="ambient/explosions/explode_9.wav"}
local Data={name="Thud Cannon",class="thud_cannon_weapon",In={"Shells"},Out={"Casings"},OutMake={1},Points=550,heat=10,shootfunc=Func,firespeed=3,InUse={2},Bullet=Bullet,MountType="Medium",MVO=Vector(70,0,0)}
local Makeup = {name={"Basic Thud Cannon"},model={"models/Slyfo/mcpcannon.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class,Unlock=true,UnlockCost=6000,UnlockType="Cannons"}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Micro Thud cannon
local Bullet = {Spread=1,Damage=1000,Recoil=2000,Speed=75,FireSound="ambient/explosions/explode_1.wav"}
local Data={name="Micro Thud Cannon",class="micro_thud_cannon_weapon",In={"Shells"},Out={"Casings"},OutMake={4},Points=300,heat=3,shootfunc=Func,firespeed=0.7,InUse={1},Bullet=Bullet,MountType="Small"}
local Makeup = {name={"Micro Thud Cannon"},model={"models/Slyfo_2/mini_turret_rocketpod.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class,Unlock=true,UnlockCost=2000,UnlockType="Cannons"}
LDE.Weapons.CompileWeapon(Data,Makeup)

-------------------------------------
-----------Plasma--------------------
-------------------------------------

local Base = {Tool="Weapon Systems",Type="Plasma"}
local FireCannon = Func
local Client = function(self) return LDE.Weapons.ShowCharge(self,self.Data.Bullet) end --Clientside
local ClientSetup = function(ENT) ENT.LDETools.Charge = Client end
local Func = function(self,CanFire) --Charge function
	LDE.Weapons.ManageCharge(self,self.Data.Bullet) 
	return true
end 

--Plasma Cannon
local Fire = function(self) self.Data.FireCannon(self) end
local Bullet = {ShrapCount=0,ShrapDamage=0,Spread=1,Radius=400,Damage=5000,Recoil=2000,Speed=60,Recoil=0,CoolDown=3,ChargeRate=10,MinCharge=50,MaxCharge=60,Single=true,ChargeShoot=Fire,BulletFunc=BulletFunc,FireSound="ambient/explosions/explode_1.wav"}
local Data={name="Plasma Cannon",class="plasma_cannon_weapon",WireOut={"Charge"},In={"Plasma"},MountType="Medium",FireCannon=FireCannon,shootfunc=Func,ClientSetup=ClientSetup,Points=500,heat=100,firespeed=0.8,InUse={5},Bullet=Bullet,Shot=Shot}
local Makeup = {name={"Plasma Cannon"},model={"models/Spacebuild/cannon1_gen.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class,Unlock=true,UnlockCost=20000,UnlockType="Plasma Weapons"}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Plasma Cannon mini
local Fire = function(self) self.Data.FireCannon(self) end
local Bullet = {ShrapCount=0,ShrapDamage=0,Spread=1,Radius=250,Damage=3400,Recoil=2000,Speed=65,Recoil=0,CoolDown=1,ChargeRate=10,MinCharge=20,MaxCharge=30,Single=true,ChargeShoot=Fire,BulletFunc=BulletFunc,FireSound="ambient/explosions/explode_1.wav"}
local Data={name="Small Plasma Cannon",class="plasma_cannon_small_weapon",WireOut={"Charge","CanFire"},In={"Plasma"},MountType="Small",FireCannon=FireCannon,shootfunc=Func,ClientSetup=ClientSetup,Points=400,heat=100,firespeed=0.8,InUse={5},Bullet=Bullet,Shot=Shot}
local Makeup = {name={"Small Plasma Cannon"},model={"models/Slyfo_2/mini_turret_pulselaser.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class,Unlock=true,UnlockCost=10000,UnlockType="Plasma Weapons"}
LDE.Weapons.CompileWeapon(Data,Makeup)







