local BulletFunc=function(self,Data,attacker,tr)
	local NewData = { 
		Pos 					=		tr.HitPos,							--Required--		--Position of the Explosion, World vector
		ShrapDamage	=		Data.SD,			--Optional--		--Amount of Damage dealt by each Shrapnel that hits, if 0 or nil then other Shap vars are not required
		ShrapCount		=		Data.SC,										--Number of Shrapnel, 0 to not use Shrapnel
		ShrapDir			=		Vector(0,0,0),											--Direction of the Shrapnel, Direction vector, Example: Missile:GetForward()
		ShrapCone		=		180,															--Cone Angle the Shrapnel is randomly fired into, 0-180, 0 for all to be released directly forward, 180 to be released in a sphere
		ShrapRadius		=		Data.Radius*2,											--How far the Shrapnel travels
		ShockDamage	=		Data.Damage,					--Optional--		--Amount of Shockwave Damage, if 0 or nil then other Shock vars are not required
		ShockRadius		=		Data.Radius,												--How far the Shockwave travels in a sphere
		Ignore			=		self,									--Optional--		--Entity that Shrapnel and Shockwaves ignore, Example: A missile entity so that Shrapnel doesn't hit it before it's removed
		Inflictor				=		self,							--Required--		--The weapon or player that is dealing the damage
		Owner				=		self.LSSOwner					--Required--		--The player that owns the weapon, or the Player if the Inflictor is a player
	}
	LDE:BlastDamage(NewData)
	
	if Data.Nuclear then
		LDE.Weapons.NuclearEffect(self,tr.HitPos)
	else
		local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetStart(tr.HitPos)
		util.Effect( Data.Effect or "explosion", effectdata )	
	end
end

local MissileBase = {TrailColor=Color(210,210,210,200),TrailStartW=20,TrailLifeTime=1,TrailTexture="trails/smoke.vmt",BulletFunc=BulletFunc}

local Func = function(self,CanFire)

	self.Missiles = self.Missiles or {}

	if self.Active==1 and CanFire then 
		--if LDE.LifeSupport.ManageResources(self,1) then
			local Missile = LDE.Weapons.ShootMissile(self,self.Data.Bullet)
			if Missile.Multi then
				for n, missile in pairs( Missile.Bullets ) do
					table.insert(self.Missiles,{A=CurTime(),E=missile})
				end
			else
				table.insert(self.Missiles,{A=CurTime(),E=Missile})
			end
			
			return true
		--end
	end
	
	for n, missile in pairs( self.Missiles ) do
		local Data = missile.E.Data
		if Data then
			if self.Homing then
				Data.HomingPos = self.HomePos
			else
				--Add auto lock on logic here.
			end
		else
			table.remove(self.Missiles,n)
			return
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
	elseif iname == "GPS" then
		self.Homing = value > 0
	elseif iname == "Vector" then
		self.HomePos = value
	end		
end

local WireSetup = function(self)
	self.Inputs = WireLib.CreateSpecialInputs( self, { "Fire","GPS","Vector" }, { [3] = "VECTOR"} );
end

local Base = {Tool="Weapon Systems",Type="Missiles"}

local Missiles = {}
Missiles["Basic"]={Model="models/Punisher239/punisher239_rocket.mdl",Damage=800,Radius=600,SD=200,SC=4,Speed=50,DumbTime=5,HomingSpeed=30}
Missiles["Stinger"]={Model="models/Slyfo_2/pss_netprojectile.mdl",Damage=400,Radius=500,SD=200,SC=2,Speed=80,DumbTime=3,HomingSpeed=50,Number=4}
Missiles["Heavy"]={Model="models/Punisher239/punisher239_missile_light.mdl",Damage=3400,Radius=1300,SD=30,SC=18,Speed=120,DumbTime=10,HomingSpeed=60}
Missiles["Nuclear"]={Model="models/Punisher239/punisher239_missile_cruise.mdl",Nuclear=true,Damage=32000,Radius=3000,SD=2000,SC=20,Speed=40,DumbTime=180,HomingSpeed=20}

--Basic missile luancher 4X
local Bullet=table.Merge(Missiles["Basic"],MissileBase)
local Data={name="BML X4",class="bml_x4_weapon",shootfunc=Func,WireSpecial=WireSetup,WireFunc=WireFunc,Bullet=Bullet,In={"Missile Parts"},InUse={1},MountType="Medium",heat=5,firespeed=4,Points=800}
local Makeup = {name={"BML X4"},model={"models/slyfo/smlmissilepod.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Basic missile luancher 8X
local Bullet=table.Merge(Missiles["Basic"],MissileBase)
local Data={name="BML X8",class="bml_x8_weapon",In={"Missile Parts"},shootfunc=Func,WireSpecial=WireSetup,WireFunc=WireFunc,Bullet=Bullet,InUse={1},MountType="Medium",MAO=Angle(0,0,90),heat=5,firespeed=2,Points=1200}
local Makeup = {name={"BML X8"},model={"models/slyfo/missile_pod_8.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Basic missile luancher 10X
local Bullet=table.Merge(Missiles["Basic"],MissileBase)
local Data={name="BML X10",class="bml_x10_weapon",In={"Missile Parts"},shootfunc=Func,WireSpecial=WireSetup,WireFunc=WireFunc,Bullet=Bullet,InUse={1},heat=5,firespeed=1,Points=1600}
local Makeup = {name={"BML X10"},model={"models/slyfo/missile_pod_10.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Stinger luancher 16X
local Bullet=table.Merge(Missiles["Stinger"],MissileBase)
local Data={name="Stinger Launcher",class="stinger_missile_weapon",In={"Missile Parts"},shootfunc=Func,WireSpecial=WireSetup,WireFunc=WireFunc,Bullet=Bullet,heat=3,InUse={1},firespeed=3,Points=1600}
local Makeup = {name={"Stinger Launcher"},model={"models/spacebuild/medbridge2_missile_launcher.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Heavy missile luancher 3X
local Bullet=table.Merge(Missiles["Heavy"],MissileBase)
local Data={name="Torpedo Launcher",class="heavy_missile_weapon",In={"Missile Parts","Liquid Polylodarium"},shootfunc=Func,WireSpecial=WireSetup,WireFunc=WireFunc,Bullet=Bullet,heat=50,InUse={3,10},firespeed=8,Points=2400}
local Makeup = {name={"Torpedo Launcher"},model={"models/punisher239/punisher239_missilebay_light.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)


--Nuclear luancher 1X
local Bullet=table.Merge(table.Merge(Missiles["Nuclear"],{ShootDir = Vector(0,-1,0),ShootPos=Vector(0,0,50)}),MissileBase)
local Data={name="Nuclear Launcher",class="nuclear_missile_weapon",In={"Missile Parts","Liquid Polylodarium"},shootfunc=Func,WireSpecial=WireSetup,WireFunc=WireFunc,Bullet=Bullet,heat=400,InUse={10,100},firespeed=1,Points=0}
local Makeup = {name={"Nuclear Launcher"},model={"models/mandrac/missile/cap_torpedolauncher_tube.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--[[
--Double Needle Launcher 21X
local Data={name="Large Needle missile Launcher",class="lrg_needle_missile_weapon",In={"Missile Parts"},ammoclass="needle_missile",heat=1,InUse={1},HasLid=true,Shots = 21,BLength = 40,Rows = { -12 , -12, 0, 12, 12 },Cols = { -4 , 4 },ClosedModel = "models/Slyfo_2/rocketpod_lg_closed.mdl",OpenModel="models/Slyfo_2/rocketpod_lg_open.mdl",AimVec = "Up"}
LDE.Weapons.RegisterLauncher(Data)
]]

