LDE=LDE or {}
LDE.TD = {}
LDE.TD.Ships = {}
LDE.TD.AI = {}
LDE.TD.AI.Weapons={}
LDE.TD.Scrap={}

if(SERVER)then
	function LDE.TD.RequestAttackAI(self)
		print("Shiprequested")
		if(self.environment)then
			local Money = self.Incoming
			local Targets = ents.FindByClass("basictarget")
			local TCount = table.Count(Targets)
			while(Money>0 and TCount<50)do
				print("Money: "..Money)
				Money=self.Incoming
				Targets = ents.FindByClass("basictarget")
				TCount = table.Count(Targets)
				local BluePrint = LDE.TD.AI.BuyBiggest(Money)
				if(not BluePrint or not BluePrint.Class)then return end
				print("Gonna Buy "..BluePrint.Amount.." ... "..BluePrint.Class.."'s" )
				local Data = {Dist={min=3000,max=5000}}
				local Point=LDE.Anons:PointInSpecificOrbit(self.environment,Data)
				if(Point)then
					local ent = ents.Create("basictarget")
					ent:SetPos( Point+Vector(0,0,self.environment.radius/2) )
					ent:Spawn()
					ent:SetupShip(BluePrint.Class,BluePrint)
					if(ent and ent:IsValid())then
						self.Incoming=self.Incoming-BluePrint.Cost
						BluePrint.Amount=BluePrint.Amount-1
					end
				end
			end
		end
	end
else

end		

-------Scrap Related Things------

LDE.TD.Scrap["Small"]={
"models/props_debris/metal_panelchunk02e.mdl","models/props_debris/metal_panelchunk01d.mdl",
"models/props_debris/metal_panelchunk01a.mdl","models/props_debris/metal_panelchunk01b.mdl",
"models/props_debris/rebar002c_64.mdl","models/props_debris/rebar003c_64.mdl",
"models/props_debris/rebar_cluster002a.mdl","models/props_debris/rebar_smallnorm01c.mdl",
"models/props_debris/rebar_medthin02c.mdl","models/props_debris/rebar_medthin01a.mdl"
}

LDE.TD.Scrap["Medium"]={
"models/props_debris/concrete_floorpile01a.mdl","models/props_debris/concrete_debris128pile001a.mdl",
"models/props_debris/concrete_cornerpile01a.mdl","models/props_debris/concrete_section128wall001b.mdl",
"models/props_debris/concrete_wallpile01a.mdl"
}

LDE.TD.Scrap["Huge"]={}

function LDE.TD.Scrap.SpawnScrap(ent,Size,Amount,Value)
	if(Amount<=0)then return end
	local Scrap = LDE.TD.Scrap[Size] or {}
	local Scount = table.Count(Scrap)
	if(Scount<=0)then return end --We got a invalid size!!!!
	
	local Resources = {}
	Resources["Scrap"]={name="Scrap",amount=Value}
	
	local Count = Amount
	local Var = ent:GetVelocity()
	while Count>0 do
		local scrap = ents.Create("resource_clump")
		scrap:SetPos(ent:GetPos()+Vector(math.random(-100,100),math.random(-100,100),math.random(-100,100)))
		scrap:SetModel( table.Random(Scrap) )
		scrap:SetColor(Color(0,0,0))
		scrap:Spawn()
		local phys = scrap:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
			phys:EnableMotion(true)
		end
		timer.Simple(0.05,function() scrap:SetVelocity(Var) end)
		scrap.Resources=Resources
		--PrintTable(Resources)
		if(math.random(1,6)==3)then
			scrap:Ignite(1000,100)--So only a fraction of the props burn.
		end
		local delay = (math.random(450, 900))
		scrap:Fire("break","",tostring(delay + 10))
		scrap:Fire("kill","",tostring(delay + 10))
		Count=Count-1
	end
	
	ent:Remove()
end

---------Weapon Functions--------
LDE.TD.AI.Weapons["Bullet"]=function(self,Data,Target)

	local MyPos = self:GetPos()
	local Dir=(Target:GetPos()-MyPos)
	
	local Bullet = {}
	Bullet.Count = Data.Count or 1
	Bullet.ShootPos = MyPos
	Bullet.Direction = Dir
	Bullet.Spread = Data.Spread or 4
	Bullet.Attacker = self
	Bullet.ProjSpeed = Data.Speed or 150
	Bullet.Drop=0
	Bullet.Model = Data.Model or "models/Items/AR2_Grenade.mdl"
	Bullet.TrailColor = Data.TrailColor or Color(255,255,120)
	Bullet.TrailLifeTime = Data.TrailLength or 0.4
	Bullet.TrailStartW = Data.TrailStartW or 10
	Bullet.TrailTexture = Data.TrailTexture or "trails/laser.vmt"
	Bullet.Ignore = self
	Bullet.Data=Data
	Bullet.Inflictor = self
	Bullet.OnHit = function (tr, Bullet)
		if(Bullet.Data.BullHit)then
			Bullet.Data.BullHit(tr,Bullet)
		else
			LDE:DealDamage(tr.Entity,Bullet.Data.Damage,Bullet.Attacker,Bullet.Inflictor)
		end
	end
	--self:FireBullets(Bullet)
	LDE:FireProjectile(Bullet)
	self:EmitSound(Data.FireSound or "npc/turret_floor/shoot1.wav")
end

---------Flight Functions------
function LDE.TD.AI.PointAboveTarget(self,TargetPos,Data)
	if(self.VPoint)then return self.VPoint end
	local Trys = 500
	while Trys > 0 do --Only try so many times in one go.
		local Min = Data.Min or 1000
		local Max = Data.Max or 1500
		local Rad = Data.Rad or 2500
		local Hgt = Data.Hgt or 3000
		local r = Rad+math.random(Min,Max)
		local x,y = math.random(-r,r),math.random(-r,r)
		local Point = TargetPos+Vector(x,y,Hgt)
		local Distance = Point:Distance(TargetPos)
		if ( Distance > 2000) then
			self.VPoint = Point
			return Point
		end
	end
		
	return TargetPos+Vector(0,0,2000)--We couldnt get a vantage point, lets come from above
end

function LDE.TD.AI.DiveRoutine(self,Distance,TargetPos)	
	if(Distance>3000)then--We gotta get closer...
		self.TargetPos=TargetPos
		self.VPoint=nil
	elseif(Distance<1800)then--Fall Back for another run!!!
		self.TargetPos=self:VantagePoint(TargetPos)
	end
	
	if(self.TargetPos)then
		local Phys=self:GetPhysicsObject()
		if Phys:IsValid() then
			Phys:SetVelocity(Phys:GetVelocity() * .5)
			Phys:ApplyForceCenter((self:GetForward() * self.Data.Speed) * Phys:GetMass())
			Phys:AddAngleVelocity(-self:GetAngAim(Phys)*Vector(0.3,0.3,0.3))
		end
	end
	
	if(Distance<4000 and not self.VPoint and self.TargetPos)then
		if(self.Target.IsDead)then self.Target=nil return end
		self:FireGuns()
	end	
end

function LDE.TD.AI.HoverRoutine(self,Distance,TargetPos)
	if(Distance>4000)then--We gotta get closer...
		self.TargetPos=TargetPos
		self.VPoint=nil
	elseif(Distance<4000)then--Lets get into position to start gunning!
		self.TargetPos=LDE.TD.AI.PointAboveTarget(self,TargetPos,{Min=500,Max=1000,Rad=1500,Hgt=1500})
		
		if(self.Target.IsDead)then self.VPoint=nil self.Target=nil return end
		self:FireGuns()
		
		if(self.VPoint)then
			local VDist = self:GetPos():Distance(self.VPoint)
			if(VDist<100)then
				self.Hover=self.Hover or 10
				if(self.Hover<=1)then
					self.VPoint=nil
					self.Hover=10
				else
					self.Hover=self.Hover-1
				end
			end
		end
	end
		
	if(self.TargetPos)then
		local Phys=self:GetPhysicsObject()
		if Phys:IsValid() then
			
			if(self.VPoint)then
				local Direction =self.VPoint-self:GetPos()
				Direction:Normalize()
				local VDist = self:GetPos():Distance(self.VPoint)
				local SpeedMult=0.8
				local Drag = 0.5
				if(VDist<100)then SpeedMult=0.2 Drag=0.8 end 
				Phys:SetVelocity(Phys:GetVelocity() * Drag)
				Phys:ApplyForceCenter(( Direction * (self.Data.Speed)*SpeedMult) * Phys:GetMass())
				Phys:AddAngleVelocity(-self:GetAngAim(Phys,self.Target:GetPos(),true)*Vector(1,1,1))
			else
				Phys:SetVelocity(Phys:GetVelocity() * .5)
				Phys:ApplyForceCenter((self:GetForward() * self.Data.Speed) * Phys:GetMass())
				Phys:AddAngleVelocity(-self:GetAngAim(Phys)*Vector(0.3,0.3,0.3))
			end
		end
	end
end

function LDE.TD.AI.CircleRoutine()

end


-------------------------------

function LDE.TD.AI.BuyBiggest(Currency)
	if(not Currency or Currency<=0)then return end
	local Biggest = {Cost=0,Value=0,Amount=0}
	for k,v in pairs(LDE.TD.Ships) do
		print("Looking at "..v.Class.." worth "..v.Cost)
		if(v.Cost<=Currency)then --v.Cost>Biggest.Cost and 
			if(Biggest.Cost>0)then
				local Amt = math.floor((Currency/v.Cost)/2)
				print(Amt*v.Value.." vs "..Biggest.Amount*Biggest.Value)
				if(Biggest.Amount*Biggest.Value>Amt*v.Value)then
					Biggest=v
					Biggest.Amount=Amt
				end
			else
				Biggest=v
				Biggest.Amount=math.floor((Currency/v.Cost)/2)
			end
		end
	end
	return Biggest --Biggest Class
end

function LDE.TD.CreateAIClass(Name,Data)
	LDE.TD.Ships[Name]=Data
end

function LDE.TD.AddWeapon(Name,Data)
	LDE.TD.Ships[Name].Weapons=LDE.TD.Ships[Name].Weapons or {}
	LDE.TD.Ships[Name].Weapons[Data.WepName]=Data
end

local BaseData = {
	Pathing=LDE.TD.AI.DiveRoutine,
	OnDeath=function(self) end,
	Amount=0,
	Model="",
	Cost=1,
	Value=1,
	ScrapAmount=1,
	ScrapSize="Small",
	ScrapValue=10,
	Speed=100,
	Hull=4000,
	Shields=0
}
 
local GunData = {
	WepName = "Gun",
	FireAngle = 15,
	AngElevOffset=0,
	AngBearOffset=0,
	FireRate = 1,
	Range=4000,
	Damage = 100,
	Type = "Bullet",
	Count=1,
	Spread=4,
	Speed=100,
	LastShot=0,
	FireSound="npc/turret_floor/shoot1.wav",
	TrailColor=Color(30,180,255),
	TrailLifeTime=0.4,
	TrailStartW=10,
	TrailTexture="trails/laser.vmt"
}

--------------------------------
---------AI CLASS TYPES---------
--------------------------------

------Scout------
local Name = "Scout"
local Data = table.Copy(BaseData)
Data["Class"]=Name
Data["Cost"]=1
Data["Value"]=1.5
Data["Speed"]=500
Data["Model"]="models/af/AFF/USN/daphne.mdl"
LDE.TD.CreateAIClass(Name,Data)

local Data = table.Copy(GunData)
Data["WepName"]="MainWep"
Data["Count"]=1
Data["FireRate"]=0.4
Data["FireAngle"]=15
Data["Spread"]=4
Data["Speed"]=150
Data["Damage"]=180
Data["Type"]="Bullet"
LDE.TD.AddWeapon(Name,Data)

------Small Fighter-------
local Name = "Small Fighter"
local Data = table.Copy(BaseData)
Data["Class"]=Name
Data["Cost"]=5
Data["ScrapAmount"]=2
Data["Value"]=4
Data["Speed"]=400
Data["Hull"]=6000
Data["Shields"]=2000
Data["Model"]="models/af/AFF/USN/sword.mdl"
LDE.TD.CreateAIClass(Name,Data)

local Data = table.Copy(GunData)
Data["WepName"]="MainWep"
Data["Count"]=2
Data["FireRate"]=1.5
Data["FireAngle"]=15
Data["AngOffset"]=0
Data["Spread"]=3
Data["Speed"]=80
Data["Damage"]=300
Data["BullHit"]=function(tr,Bullet) 	
	local Boom = { 
		Pos 					=		tr.HitPos,	--Required--		--Position of the Explosion, World vector
		ShrapDamage	=		Bullet.Data.Damage*2,										--Amount of Damage dealt by each Shrapnel that hits, if 0 or nil then other Shap vars are not required
		ShrapCount		=		10,										--Number of Shrapnel, 0 to not use Shrapnel
		ShrapDir			=		Vector(0,0,1),							--Direction of the Shrapnel, Direction vector, Example: Missile:GetForward()
		ShrapCone		=		180,										--Cone Angle the Shrapnel is randomly fired into, 0-180, 0 for all to be released directly forward, 180 to be released in a sphere
		ShrapRadius		=		100,										--How far the Shrapnel travels
		ShockDamage	=		Bullet.Data.Damage,				--Required--		--Amount of Shockwave Damage, if 0 or nil then other Shock vars are not required
		ShockRadius		=		200,										--How far the Shockwave travels in a sphere
		Ignore				=		self,									--Optional Entity that Shrapnel and Shockwaves ignore, Example: A missile entity so that Shrapnel doesn't hit it before it's removed
		Inflictor				=		self,			--Required--		--The weapon or player that is dealing the damage
		Owner				=		self			--Required--		--The player that owns the weapon, or the Player if the Inflictor is a player
	}
	LDE:BlastDamage(Boom)
end
Data["Model"]="models/Slyfo/how_apfsds.mdl"
Data["TrailLength"]=1
Data["TrailStartW"]=30
Data["TrailColor"]=Color(255,255,255)
Data["TrailTexture"]="trails/smoke.vmt"
Data["FireSound"]="Weapon_RPG.Single"
Data["Type"]="Bullet"
LDE.TD.AddWeapon(Name,Data)
 
------Gunship------
local Name = "GunShip"
local Data = table.Copy(BaseData)
Data["Class"]=Name
Data["Cost"]=8
Data["Hull"]=8000
Data["Value"]=5
Data["ScrapAmount"]=4
Data["Speed"]=300
Data["Model"]="models/af/AFF/AISN/vlad.mdl"
Data["Pathing"]= LDE.TD.AI.HoverRoutine
LDE.TD.CreateAIClass(Name,Data)

local Data = table.Copy(GunData)
Data["WepName"]="MainWep"
Data["Count"]=1
Data["FireRate"]=0.1
Data["FireAngle"]=15
Data["AngOffset"]=0
Data["Spread"]=5
Data["Speed"]=150
Data["Damage"]=160
Data["Type"]="Bullet"
LDE.TD.AddWeapon(Name,Data)

------Heavy Fighter------
local Name = "Heavy Fighter"
local Data = table.Copy(BaseData)
Data["Class"]=Name
Data["Cost"]=10
Data["Value"]=9
Data["ScrapAmount"]=3
Data["Speed"]=350
Data["Hull"]=8000
Data["Shields"]=6000
Data["Model"]="models/af/AFF/USN/hind.mdl"
LDE.TD.CreateAIClass(Name,Data)

local Data = table.Copy(GunData)
Data["WepName"]="Main Cannon"
Data["Count"]=1
Data["FireRate"]=3
Data["FireAngle"]=15
Data["AngOffset"]=0
Data["Spread"]=0
Data["Speed"]=150
Data["Damage"]=1000
Data["Model"]="models/Slyfo_2/weap_plasmatorp2.mdl"
Data["TrailStartW"]=30
Data["TrailLength"]=1
Data["TrailColor"]=Color(255,255,120)
Data["BullHit"]=function(tr,Bullet) 	
	local Boom = { 
		Pos 					=		tr.HitPos,	--Required--		--Position of the Explosion, World vector
		ShrapDamage	=		Bullet.Data.Damage,										--Amount of Damage dealt by each Shrapnel that hits, if 0 or nil then other Shap vars are not required
		ShrapCount		=		10,										--Number of Shrapnel, 0 to not use Shrapnel
		ShrapDir			=		Vector(0,0,1),							--Direction of the Shrapnel, Direction vector, Example: Missile:GetForward()
		ShrapCone		=		180,										--Cone Angle the Shrapnel is randomly fired into, 0-180, 0 for all to be released directly forward, 180 to be released in a sphere
		ShrapRadius		=		100,										--How far the Shrapnel travels
		ShockDamage	=		Bullet.Data.Damage/2,				--Required--		--Amount of Shockwave Damage, if 0 or nil then other Shock vars are not required
		ShockRadius		=		200,										--How far the Shockwave travels in a sphere
		Ignore				=		self,									--Optional Entity that Shrapnel and Shockwaves ignore, Example: A missile entity so that Shrapnel doesn't hit it before it's removed
		Inflictor				=		self,			--Required--		--The weapon or player that is dealing the damage
		Owner				=		self			--Required--		--The player that owns the weapon, or the Player if the Inflictor is a player
	}
	LDE:BlastDamage(Boom)
end
Data["Type"]="Bullet"
Data["FireSound"]="ambient/explosions/explode_4.wav"
LDE.TD.AddWeapon(Name,Data)

local Data = table.Copy(GunData)
Data["WepName"]="Secondary Gun"
Data["Count"]=1
Data["FireRate"]=0.3
Data["FireAngle"]=15
Data["AngOffset"]=0
Data["Spread"]=4
Data["Speed"]=150
Data["Damage"]=120
Data["Type"]="Bullet"
LDE.TD.AddWeapon(Name,Data)

 
------Heavy Gunship------
local Name = "GunShip"
local Data = table.Copy(BaseData)
Data["Class"]=Name
Data["Cost"]=50
Data["Hull"]=50000
Data["Shields"]=120000
Data["Value"]=50
Data["ScrapAmount"]=4
Data["ScrapSize"]="Medium"
Data["ScrapValue"]=20
Data["Speed"]=200
Data["Model"]="models/af/AFF/USN/alfazard.mdl"
Data["Pathing"]= LDE.TD.AI.HoverRoutine
LDE.TD.CreateAIClass(Name,Data)

local Data = table.Copy(GunData)
Data["WepName"]="MainWep"
Data["Count"]=1
Data["FireRate"]=2
Data["FireAngle"]=15
Data["AngOffset"]=0
Data["Spread"]=5
Data["Speed"]=150
Data["Damage"]=1000
Data["TrailStartW"]=30
Data["BullHit"]=function(tr,Bullet) 	
	local Boom = { 
		Pos 					=		tr.HitPos,	--Required--		--Position of the Explosion, World vector
		ShrapDamage	=		Bullet.Data.Damage,										--Amount of Damage dealt by each Shrapnel that hits, if 0 or nil then other Shap vars are not required
		ShrapCount		=		10,										--Number of Shrapnel, 0 to not use Shrapnel
		ShrapDir			=		Vector(0,0,1),							--Direction of the Shrapnel, Direction vector, Example: Missile:GetForward()
		ShrapCone		=		180,										--Cone Angle the Shrapnel is randomly fired into, 0-180, 0 for all to be released directly forward, 180 to be released in a sphere
		ShrapRadius		=		500,										--How far the Shrapnel travels
		ShockDamage	=		Bullet.Data.Damage/2,				--Required--		--Amount of Shockwave Damage, if 0 or nil then other Shock vars are not required
		ShockRadius		=		700,										--How far the Shockwave travels in a sphere
		Ignore				=		self,									--Optional Entity that Shrapnel and Shockwaves ignore, Example: A missile entity so that Shrapnel doesn't hit it before it's removed
		Inflictor				=		self,			--Required--		--The weapon or player that is dealing the damage
		Owner				=		self			--Required--		--The player that owns the weapon, or the Player if the Inflictor is a player
	}
	LDE:BlastDamage(Boom)
end
Data["Model"]="models/Slyfo_2/weap_plasmatorp2.mdl"
Data["Type"]="Bullet"
Data["FireSound"]="ambient/explosions/explode_4.wav"
LDE.TD.AddWeapon(Name,Data)
