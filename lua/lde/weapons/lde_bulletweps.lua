--------------------------------------
------------Machine Guns--------------
--------------------------------------

local Func = function(self,CanFire) 
	if self.Active==1 and CanFire then 
		if LDE.LifeSupport.ManageResources(self,1) then 
			LDE.Weapons.ShootBullet(self,self.Data.Bullet)
			return true
		end 
	end 
	return false
end
local Base = {Tool="Weapon Systems",Type="MachineGuns"}

--Heavy Machine Gun
local Bullet = {Number=1,Spread=5,Speed=150,Damage=500,Explodes=0,Recoil=500,FireSound="npc/strider/strider_minigun.wav",MuzzleFlash=3}
local Data={name="Heavy Machine Gun",class="heavy_machine_weapon",In={"Basic Rounds"},Out={"Casings"},MountType="Medium",MVO=Vector(60,0,0),shootfunc=Func,Points=1200,heat=33,firespeed=0.33,InUse={10},OutMake={4},Bullet=Bullet}
local Makeup = {name={"Heavy Machine Gun"},model={"models/Slyfo/howitzer.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Basic Machine Gun
local Bullet = {Number=1,Spread=7.5,Speed=200,Damage=200,Explodes=0,Recoil=200,FireSound="npc/turret_floor/shoot1.wav",MuzzleFlash=2}
local Data={name="Basic Machine Gun",class="basic_machine_weapon",In={"Basic Rounds"},Out={"Casings"},shootfunc=Func,Points=800,heat=15,firespeed=0.2,InUse={5},OutMake={2},Bullet=Bullet}
local Makeup = {name={"Simple Machine Gun"},model={"models/Slyfo/rover1_backgun.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Light Machine Gun
local Bullet = {Number=1,Spread=10,Speed=150,Damage=100,Explodes=0,Recoil=50,FireSound="weapons/ar2/fire1.wav"}
local Data={name="Light Machine Gun",class="light_machine_weapon",In={"Basic Rounds"},Out={"Casings"},MountType="Small",MVO=Vector(13,0,0),shootfunc=Func,Points=500,heat=10,firespeed=0.2,InUse={4},OutMake={2},Bullet=Bullet}
local Makeup = {name={"Light Machine Gun"},model={"models/Slyfo/rover1_sidegun.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--------------------------------------
------------Ship Rifles---------------
--------------------------------------

local BulletFunc =  function(self,Data,attacker,tr)
	local core = function(ent,data) LDE.AdvDamage:ShieldPiercing(ent,data.damage,data.extra.Peirce,data.attacker,data.inflictor) end
	local ply = function(ent,data) LDE:DealDamage(ent,data.damage,data.attacker,data.inflictor) end
	local dam={
		Player = ply, --The function called when a player is hit.
		Core = core, --The function called when a Cored entity is hit.
		Prop = ply, --The function called when a non cored entity is hit.
		extra = {Peirce=0.70}, --A extra data table that can be used by the defined functions.
		damage = Data.Damage, --The amount of damage being done.
		inflictor = self, --The entity dealing the damage (the weapon)
		attacker = attacker, --The player that owns the weapon
		ignoresafe = false --Does the damage ignore safe zones
	}
	LDE:DealAdvDamage(tr.Entity,dam)
end

local Func = function(self,CanFire) 
	if(self.Active==1 and CanFire)then 
		if(LDE.LifeSupport.ManageResources(self,1))then 
			LDE.Weapons.ShootBullet(self,self.Data.Bullet)
			return true
		end 
	end 
	return false
end
local Base = {Tool="Weapon Systems",Type="Rifles"}

--Anti Ship rifle
local Bullet = {BulletFunc=BulletFunc,Number=1,Spread=1,Speed=500,Damage=1000,Explodes=0,Recoil=900,FireSound="npc/sniper/sniper1.wav",MuzzleFlash=2}
local Data={name="Anti-Ship Rifle",class="basic_sniper_rifle",In={"Basic Rounds","Crystalised Polylodarium"},MountType="Medium",shootfunc=Func,Points=1000,heat=500,firespeed=5,InUse={20,20},Bullet=Bullet}
local Makeup = {name={"Simple Ship Rifle"},model={"models/Slyfo/rover_snipercannon.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class,Unlock=true,UnlockCost=15000,UnlockType="Rifles"}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Automatic Ship rifle
local Bullet = {BulletFunc=BulletFunc,Number=1,Spread=2,Speed=500,Damage=1200,Explodes=0,Recoil=1800,FireSound="npc/sniper/sniper1.wav",MuzzleFlash=3}
local Data={name="Automatic Ship Rifle",class="huge_sniper_rifle",In={"Basic Rounds","Crystalised Polylodarium"},shootfunc=Func,Points=2600,heat=1000,firespeed=2.5,InUse={30,30},Bullet=Bullet}
local Makeup = {name={"Automatic Ship Rifle"},model={"models/Spacebuild/Nova/flak1.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class,Unlock=true,UnlockCost=18000,UnlockType="Rifles"}
LDE.Weapons.CompileWeapon(Data,Makeup)

--------------------------------------
------------Ship ShotGuns-------------
--------------------------------------

local Func = function(self,CanFire) 
	if(self.Active==1 and CanFire)then 
		if(LDE.LifeSupport.ManageResources(self,1))then 
			LDE.Weapons.ShootBullet(self,self.Data.Bullet)
			return true
		end 
	end
	return false
end
local Base = {Tool="Weapon Systems",Type="Shotguns"}

--Tiny Shot Gun
local Bullet = {Number=10,Spread=20,Speed=100,Damage=50,Explodes=0,Recoil=200,FireSound="weapons/shotgun/shotgun_fire6.wav",TrailStartW=5}
local Data={name="Tiny ShotGun",class="tiny_shotgun_weapon",In={"Basic Rounds"},Out={"Casings"},MountType="Small",shootfunc=Func,Points=350,heat=30,firespeed=1,InUse={20},OutMake={5},Bullet=Bullet}
local Makeup = {name={"Tiny Shotgun"},model={"models/Slyfo_2/mini_turret_shotgun.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Basic Shot Gun
local Bullet = {Number=15,Spread=15,Speed=125,Damage=150,Explodes=0,Recoil=500,FireSound="weapons/shotgun/shotgun_fire6.wav",MuzzleFlash=2,TrailStartW=5}
local Data={name="Basic ShotGun",class="basic_shotgun_weapon",In={"Basic Rounds"},Out={"Casings"},MountType="Small",shootfunc=Func,Points=700,heat=160,firespeed=1.6,InUse={50},OutMake={12},Bullet=Bullet}
local Makeup = {name={"Basic Shotgun"},model={"models/Slyfo_2/weap_prover_cannonlarge.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class,Unlock=true,UnlockCost=8000,UnlockType="ShotGuns"}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Huge Shot Gun
local Bullet = {Number=20,Spread=20,Speed=150,Damage=300,Explodes=0,Recoil=2000,FireSound="weapons/shotgun/shotgun_dbl_fire.wav",MuzzleFlash=4,TrailStartW=5}
local Data={name="Huge ShotGun",class="huge_shotgun_weapon",In={"Basic Rounds"},Out={"Casings"},shootfunc=Func,Points=1400,heat=360,firespeed=2.4,InUse={120},OutMake={20},Bullet=Bullet}
local Makeup = {name={"Huge Shotgun"},model={"models/Stat_Turrets/st_turretheavy.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class,Unlock=true,UnlockCost=30000,UnlockType="ShotGuns"}
LDE.Weapons.CompileWeapon(Data,Makeup)

--------------------------------------
------------Ship ChainGuns------------
--------------------------------------

local Client = function(self) LDE.Weapons.ShowCharge(self,self.Data.Bullet) end --Clientside
local Func = function(self,CanFire) 
	LDE.Weapons.ManageCharge(self,self.Data.Bullet) 
	return true
end --Charge function
local Base = {Tool="Weapon Systems",Type="MachineGuns"}

--Basic ChainGun
local Shot = {Number=1,Spread=15,Speed=250,Damage=40,Explodes=0,Recoil=100,FireSound="npc/strider/strider_minigun.wav",MuzzleFlash=2}
local Fire = function(self) self.Data.firespeed=0.02+((self.Data.Bullet.MaxCharge-self.Charge)*0.001) LDE.Weapons.ShootBullet(self,self.Data.Shot) end
local Bullet = {Spread=15,Speed=250,Damage=40,Number=1,Recoil=100,CoolDown=2,ChargeRate=10,Radius=5,MinCharge=5,MaxCharge=400,Single=false,Heats=false,Explosive=false,ChargeShoot=Fire,Direction=1}
local Data={name="Basic ChainGun",class="basic_chaingun_weapon",WireOut={"Charge","CanFire"},In={"Basic Rounds","energy"},shootfunc=Func,Client=Client,Points=1600,heat=5,firespeed=0.42,InUse={1,40},Bullet=Bullet,Shot=Shot}
local Makeup = {name={"Heavy Chaingun"},model={"models/Spacebuild/medbridge2_gatling_cannon.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class,Unlock=true,UnlockCost=22000,UnlockType="ChainGuns"}
LDE.Weapons.CompileWeapon(Data,Makeup)
