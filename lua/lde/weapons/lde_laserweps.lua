
local Func = function(self,CanFire)
	if self.Active==1 and CanFire then
		if LDE.LifeSupport.ManageResources(self,1) then 
			LDE.Weapons.FireLaser(self,self.Data.Bullet)
			return true
		end
	end
	return false
end
local Base = {Tool="Weapon Systems",Type="Pulse Lasers"}
local Desc = "Fires a instanthit beam that heats up a targets lifesupport system."

--------------------------------------
-----------Pulse Lasers---------------
--------------------------------------

--Large Pulse Laser
local Effects = {Beam="LDE_laserbeam",Hit="LDE_laserhiteffect"}
local Bullet = {Damage=200,heat=1,ShootDir=Vector(-1,0,0),Effect=Effects,FireSound="weapons/cow_mangler_explosion_normal_01.wav"}
local Data={name="Large Pulse Laser",class="pulse_laser_weapon",In={"energy"},shootfunc=Func,Desc=Desc,Points=100,heat=67,firespeed=0.5,InUse={1500},Bullet=Bullet,MountType="Medium",MAO=Angle(0,180,0),MVO=Vector(50,0,0)}
local Makeup = {name={"Large Pulse Laser"},model={"models/mandrac/laser4.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Small Pulse Laser
local Effects = {Beam="LDE_laserbeam",Hit="LDE_laserhiteffect"}
local Bullet = {Damage=100,heat=1,ShootDir=Vector(1,0,0),Effect=Effects,FireSound="weapons/bison_main_shot_01.wav"}
local Data={name="Small Pulse Laser",class="pulse_laser_weapon_small",In={"energy"},MountType="Small",shootfunc=Func,Desc=Desc,Points=10,heat=34,firespeed=0.4,InUse={500},Bullet=Bullet}
local Makeup = {name={"Small Basic Pulse Laser"},model={"models/Slyfo_2/mini_turret_surgilaser.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

local Data={name="Small Pulse Laser",class="pulse_laser_weapon_small_pirate",In={"energy"},shootfunc=Func,Desc=Desc,Points=10,heat=34,firespeed=0.4,InUse={500},Bullet=Bullet}
local Makeup = {name={"Small Pirate Pulse Laser"},model={"models/Slyfo_2/weap_prover_energyblastersml.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Ion Laser --Formally known as Leech Laser
local Desc = "Fires a instanthit beam that drains a targets shields by damage*100."
local BulletFunc =  function(self,Data,attacker,tr)
	local core = function(ent,data) LDE.AdvDamage:ShieldDrain(ent,data.damage,data.extra.Drain,data.attacker,data.inflictor) end
	local ply = function(ent,data) LDE:DealDamage(ent,data.damage,data.attacker,data.inflictor) end
	local dam={
		Player = ply, --The function called when a player is hit.
		Core = core, --The function called when a Cored entity is hit.
		Prop = ply, --The function called when a non cored entity is hit.
		extra = {Drain=100}, --A extra data table that can be used by the defined functions.
		damage = Data.Damage, --The amount of damage being done.
		inflictor = self, --The entity dealing the damage (the weapon)
		attacker = attacker, --The player that owns the weapon
		ignoresafe = false --Does the damage ignore safe zones
	}
	LDE:DealAdvDamage(tr.Entity,dam)
end

local Effects = {Beam="LDE_leechbeam"}
local Bullet = {BulletFunc=BulletFunc,Damage=10,heat=1,ShootDir=Vector(-1,0,0),Effect=Effects,FireSound="weapons/bison_main_shot_crit.wav"}
local Data={name="Ion Laser",class="leech_laser_weapon",In={"energy"},shootfunc=Func,Desc=Desc,Points=150,heat=200,firespeed=1,InUse={10000},Bullet=Bullet,MountType="Medium",MAO=Angle(0,180,0),MVO=Vector(50,0,0)}
local Makeup = {name={"Ion Laser"},model={"models/mandrac/laser.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Fusion Beam
local Client = function(self) return LDE.Weapons.ShowCharge(self,self.Data.Bullet) end --Clientside
local ClientSetup = function(ENT) ENT.LDETools.Charge = Client end
local Func = function(self) LDE.Weapons.ManageCharge(self,self.Data.Bullet) end --Charge function

local Effects = {Beam="LDE_laserbeamhuge"}
local Fire = function(self) LDE.Weapons.FireLaser(self,self.Data.Bullet) end
local Bullet = {Damage=10000,heat=0.2,CoolDown=6,ChargeRate=50,Radius=5,MinCharge=1900,MaxCharge=2000,Single=true,ChargeShoot=Fire,Effect=Effects,FireSound="npc/strider/fire.wav"}
local Data={name="Fusion Beam",class="fusion_beam_laser_weapon",WireOut={"Charge"},In={"energy"},ChargeType=true,MountType="Huge",shootfunc=Func,ClientSetup=ClientSetup,Points=1000,heat=250,firespeed=0.25,InUse={5000},Bullet=Bullet}
local Makeup = {name={"Fusion Beam"},model={"models/Spacebuild/Nova/macbig.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Phazzer 
local Desc = "Can Fire a beam in any direction."
local Func = function(self,CanFire)
	if self.Active==1 and CanFire then
		if(self.TraceTarg)then
			if(LDE.LifeSupport.ManageResources(self,1))then
				local bull = self.Data.Bullet
				local trace=LDE.Weapons.FireLaser(self,bull)
				LDE.Weapons.Blast(self,trace.HitPos,bull.Radius,bull.Damage,self.LDEOwner)
				return true
			end
		end
	end
	return false
end

local WireFunc = function(self,iname,value)
	if iname == "Fire" then
		if value > 0 then
			if self.Active == 0 then
				self:TurnOn()
			end
		else
			if self.Active == 1 then
				self:TurnOff()
			end
		end
	elseif iname=="Vector" then
		if value then
			self.TraceTarg = value
		else
			self:TurnOff()
			self.TraceTarg = nil
		end
	end
end

local WireSetup = function(self)
	self.Inputs = WireLib.CreateSpecialInputs( self, { "Fire", "Vector" }, { [2] = "VECTOR"} );
end

local Effects = {Beam="LDE_laserbeam",Hit="LDE_laserhiteffect"}
local Bullet = {Damage=100,heat=0.5,ShootDir=Vector(0,0,1),ShootPos=Vector(0,0,80),Radius=50,Effect=Effects,FireSound="weapons/bison_main_shot_01.wav"}
local Data={name="Phazzer",class="phazzer_weapon",In={"energy"},shootfunc=Func,WireSpecial=WireSetup,WireFunc=WireFunc,Desc=Desc,Points=200,heat=50,firespeed=1,InUse={500},Bullet=Bullet}
local Makeup = {name={"Phazzer"},model={"models/Slyfo_2/miscequipmentfieldgen.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--------------------------------------
------------Beam Lasers---------------
--------------------------------------

local Base = {Tool="Weapon Systems",Type="Beam Lasers"}
local Client = function(self) return LDE.Weapons.ShowCharge(self,self.Data.Bullet) end --Clientside
local ClientSetup = function(ENT) ENT.LDETools.Charge = Client end
local Func = function(self) LDE.Weapons.ManageCharge(self,self.Data.Bullet) return true end --Charge function

--Large Beam
local Effects = {Beam="LDE_laserbeam_long",Hit="LDE_laserhiteffect"}
local Fire = function(self) LDE.Weapons.FireLaser(self,self.Data.Bullet) end
local Bullet = {Damage=60,heat=1,ShootDir=Vector(-1,0,0),Recoil=0,CoolDown=1,ChargeRate=10,MinCharge=80,MaxCharge=120,ChargeShoot=Fire,Effect=Effects}
local Data={name="Large Beam",class="large_beam_laser_weapon",WireOut={"Charge","CanFire"},In={"energy"},ChargeType=true,shootfunc=Func,ClientSetup=ClientSetup,Points=180,heat=20,firespeed=0.2,InUse={200},Bullet=Bullet,Shot=Shot,MountType="Medium",MAO=Angle(0,180,0),MVO=Vector(50,0,0)}
local Makeup = {name={"Large Beam"},model={"models/mandrac/laser3.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Small Beam
local Effects = {Beam="LDE_laserbeam_long",Hit="LDE_laserhiteffect"}
local Fire = function(self) LDE.Weapons.FireLaser(self,self.Data.Bullet) end
local Bullet = {Damage=30,heat=1,ShootDir=Vector(1,0,0),Recoil=0,CoolDown=1,ChargeRate=10,MinCharge=80,MaxCharge=120,ChargeShoot=Fire,Effect=Effects}
local Data={name="Small Beam",class="small_beam_laser_weapon",WireOut={"Charge","CanFire"},In={"energy"},ChargeType=true,shootfunc=Func,ClientSetup=ClientSetup,Points=90,heat=10,firespeed=0.2,InUse={100},Bullet=Bullet,Shot=Shot,MountType="Small"}
local Makeup = {name={"Small Beam"},model={"models/slyfo_2/mini_turret_flamer.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)


