
-------------------------------------------
----------LDE Weapon Functions-------------
-------------------------------------------

//Line Trace function.
LDE.Weapons.DoTrace = function(self,Data)
	local tr = {}
	
	local ShootPos = self:GetPos()
	local Direction = self:GetForward()
	if(Data.ShootPos)then ShootPos = self:LocalToWorld(Data.ShootPos) end
	if(Data.ShootDir)then Direction = Vector(Data.ShootDir.X,Data.ShootDir.Y,Data.ShootDir.Z) Direction:Rotate(self:GetAngles()) end
	local GunSize = Data.BarrelLength or 15
	local TraceDist = Data.TraceLength or 30000
	
	tr.start = ShootPos+(Direction*GunSize)
	if(self.TraceTarg)then
		tr.endpos = self.TraceTarg
	else
		tr.endpos = ShootPos+(Direction*TraceDist)
	end	
	
	tr.filter = self
	self.TraceStart=tr.start --So we can call it down the line :p
	self.TraceEnd=tr.endpos
	return util.TraceLine( tr )
end

LDE.Weapons.BeamEffect = function(self,Data,trace)
	local effectdata = EffectData()
		effectdata:SetOrigin( trace.HitPos or (self.TraceEnd))
		effectdata:SetStart(self.TraceStart)
		effectdata:SetEntity( self )
	util.Effect( Data.Effect.Beam, effectdata )
	
	--[[if(Data.Effect.Hit)then
		local effectdata = EffectData()
			effectdata:SetOrigin( trace.HitPos )
			effectdata:SetNormal( trace.HitNormal )
			effectdata:SetEntity( self )
		util.Effect( Data.Effect.Hit , effectdata )		
	end]]
end

//Laser Type Entity Base
LDE.Weapons.FireLaser = function(self,Data)
	local trace = LDE.Weapons.DoTrace(self,Data)
	local ent = trace.Entity
	if(LDE:IsInSafeZone(ent)) then return end

	if(not Data.NoHeat)then
		LDE.LifeSupport.ApplyHeat(self,Data)--Dat heat function.
	end
	if (ent and ent:IsValid()) then
		if(Data.BulletFunc)then
			Data.BulletFunc(self,Data,Data.Damage,trace)
		else			
			LDE:DealDamage(ent,Data.Damage,self,self)
			LDE.HeatSim.ApplyHeat(ent,Data.Damage*Data.heat)
		end
	end
	
	LDE.Weapons.BeamEffect(self,Data,trace)
	
	if(Data.FireSound)then
		self:EmitSound(Data.FireSound)--Make the PEW sound
	end
	
	return trace --Return where we hit n stuff.
end

//Charge up function
LDE.Weapons.ChargeDamage = function(self,Data,tr)
	if(Data.Explosive)then
		--util.BlastDamage(self.Entity, self.LDEOwner, tr.HitPos, self.Charge*Data.Radius, self.Charge*Data.Dpc) -- Git outta hurr hairy man
		local NewData = { 
		Pos 					=		tr.HitPos,							--Required--		--Position of the Explosion, World vector
		--ShrapDamage	=		0,										--Optional--		--Amount of Damage dealt by each Shrapnel that hits, if 0 or nil then other Shap vars are not required
		--ShrapCount	=		0,																--Number of Shrapnel, 0 to not use Shrapnel
		--ShrapDir			=		vec(0,0,0),												--Direction of the Shrapnel, Direction vector, Example: Missile:GetForward()
		--ShrapCone		=		0,																--Cone Angle the Shrapnel is randomly fired into, 0-180, 0 for all to be released directly forward, 180 to be released in a sphere
		--ShrapRadius	=		0,																--How far the Shrapnel travels
		ShockDamage	=		self.Charge*Data.Dpc,		--Optional--		--Amount of Shockwave Damage, if 0 or nil then other Shock vars are not required
		ShockRadius		=		self.Charge*Data.Radius,							--How far the Shockwave travels in a sphere
		--Ignore			=		Entity,								--Optional--		--Entity that Shrapnel and Shockwaves ignore, Example: A missile entity so that Shrapnel doesn't hit it before it's removed
		Inflictor				=		self,							--Required--		--The weapon or player that is dealing the damage
		Owner				=		self.LDEOwner					--Required--		--The player that owns the weapon, or the Player if the Inflictor is a player
		}
		LDE:BlastDamage(NewData)
		local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetStart(tr.HitPos)
		util.Effect( "explosion", effectdata )
	end
end

//Single Burst shot
LDE.Weapons.SingleBurst = function(self,Data)
	local tr = LDE.Weapons.DoTrace(self,Data)
	if tr.Hit and !tr.HitSky then
						
		LDE.Weapons.ChargeDamage(self,Data,tr)
						
		local effectdata = EffectData()
			effectdata:SetOrigin( tr.HitPos or (self:GetPos()+((self:GetForward()*300000)*Data.Direction)))
			effectdata:SetStart(self:GetPos()+((self:GetForward() *15)*Data.Direction))
			effectdata:SetEntity( self )
		util.Effect( Data.Effect, effectdata )
						
		LDE.Weapons.ApplyRecoil(self,Data.Recoil)--:U recoil
	end
end

//Manage Charge
LDE.Weapons.ManageCharge = function(self,Data)
	LDE.LifeSupport.ApplyHeat(self,Data)
	if(self.Active==1)then
		self.CanFire=LDE.LifeSupport.ManageResources(self,1)
	else
		self.CanFire=false
	end
	if(self.CanFire==true)then
		self.Charge = math.Clamp(self.Charge+Data.ChargeRate,0,Data.MaxCharge)
		if(Data.Single==false)then
			if(self.Charge>=Data.MinCharge)then 
				Data.ChargeShoot(self,Data) --Constant firing
			end
		end
	else
		if(Data.Single==true and self.Charge>=Data.MinCharge)then
			Data.ChargeShoot(self,Data) --Fire our single shot.
			timer.Simple(Data.CoolDown, function() if(self and self:IsValid())then self.CanFire=1 end end)
			self.CanFire = 0
			self.Charge = 0
		else
			self.Charge = math.Clamp(self.Charge-Data.ChargeRate*2,0,Data.MaxCharge) ---Decrease in charge
		end
	end				
	cha = self:GetNWInt("charge")
	if (!cha or cha != self.Charge) then
		self:SetNWInt("charge", self.Charge)
	end
	WireLib.TriggerOutput(self, "Charge", self.Charge)--Set the charge wire output.
end

LDE.Weapons.ShowCharge = function(self,Data)
	return self:GetNWInt("charge").."/"..Data.MaxCharge
end


//Base Recoil Code
LDE.Weapons.ApplyRecoil = function(self,Force)
	local phys = self:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:ApplyForceCenter( self:GetForward() * -Force ) 
	end 
end

LDE.Weapons.NuclearEffect = function(self,Data)
	local effectdata = EffectData()
	effectdata:SetMagnitude( 1 )
	effectdata:SetOrigin( self:GetPos() )
	effectdata:SetScale( 23000 )
					
	util.Effect( "LDE_nukeflash", effectdata )
					
	self:EmitSound( "explode_9" )
					
	local ShakeIt = ents.Create( "env_shake" )
	ShakeIt:SetName("Shaker")
	ShakeIt:SetKeyValue("amplitude", "200" )
	ShakeIt:SetKeyValue("radius", "200" )
	ShakeIt:SetKeyValue("duration", "5" )
	ShakeIt:SetKeyValue("frequency", "255" )
	ShakeIt:SetPos( self:GetPos() )
	ShakeIt:Fire("StartShake", "", 0);
	ShakeIt:Spawn()
	ShakeIt:Activate()

	ShakeIt:Fire("kill", "", 6)
end

//Base Code for shooting entitys.
LDE.Weapons.ShootEntity = function(self,Data)
	LDE.LifeSupport.ApplyHeat(self,Data)
	local NewShell = ents.Create(Data.Class)	
	if ( !NewShell:IsValid() ) then LDE:Debug("Error, Creating Bullet. "..Data.Class) return end
	Data.CVel = self:GetPhysicsObject():GetVelocity():Length()
	local Offset = self:GetPos() + (Data.Offset or (self:GetUp() * 10) + (self:GetForward() * (160 + Data.CVel)))
	local Angles = self:GetForward():Angle()
	if(Data.Angles and Data.Angles=="Right")then
		Angles = self:GetRight():Angle()
	end
	
	NewShell:SetPos(Offset)
	NewShell:SetAngles(Angles)
	
	
	NewShell.SPL = self.SPL
	NewShell:Spawn() 
	NewShell:Initialize()
	NewShell:Activate()
	NewShell:SetOwner(self)
	NewShell.PhysObj:SetVelocity(NewShell:GetForward()*Data.Speed)
	NewShell:Fire("kill", "", Data.LifeTime or 1)
	NewShell.ParL = self
	if(Data.FireSound)then
		self:EmitSound(Data.FireSound)
	end
	LDE.Weapons.ApplyRecoil(self,Data.Recoil)
end

//Base Code for shooting bullets
LDE.Weapons.ShootBullet = function(self, Data)
	LDE.LifeSupport.ApplyHeat(self,Data)
	local maxs = self:OBBMaxs()
	local mins = self:OBBMins()
	local lengthadd = (maxs.X - mins.X)*0.5 + 5
	local vStart = self:LocalToWorld(self:OBBCenter()+Vector(lengthadd,0,0))--self.Entity:GetPos()
	local vForward = self:GetForward()
	
	if(Data.ShootPos)then vStart = self:LocalToWorld(Data.ShootPos) end
	if(Data.ShootDir)then vForward = Vector(Data.ShootDir.X,Data.ShootDir.Y,Data.ShootDir.Z) vForward:Rotate(self:GetAngles()) end
	
	local Bullet = {}
	Bullet.Count = Data.Number or 1
	Bullet.ShootPos = vStart
	Bullet.Direction = vForward --Position * -1
	Bullet.Spread = Data.Spread or 0
	Bullet.Attacker = self.SPL
	Bullet.ProjSpeed = Data.Speed or 50
	Bullet.Drop=0
	Bullet.Model = Data.Model or "models/Items/AR2_Grenade.mdl"
	Bullet.Ignore = self
	Bullet.Data=Data
	Bullet.Inflictor = self
	Bullet.OnHit = function (tr, Bullet)
		local Data = Bullet.Data
		if(Data.BulletFunc)then
			Data.BulletFunc(Bullet.Inflictor,Data,Data.Damage,tr)
		else
			LDE:DealDamage(tr.Entity,Data.Damage,Bullet.Attacker,Bullet.Inflictor)
		end
	end
	--self:FireBullets(Bullet)
	LDE:FireProjectile(Bullet)
	if(Data.FireSound)then
		self:EmitSound(Data.FireSound)
	end
	LDE.Weapons.ApplyRecoil(self,Data.Recoil)
end
LDE.Weapons.ShootShell = LDE.Weapons.ShootBullet

--Winch Code
LDE.Weapons.WinchLatch = function( self, Hook, Vec, Ent )
	local minMass = self:GetPhysicsObject():GetMass() +Ent:GetPhysicsObject():GetMass()
	local const = minMass * 30
	local length = self:GetPos():Distance(Hook:GetPos())
	
	Hook.Elastic, Hook.Rope = constraint.Rope( self, Ent, 0, 0, Vector(33,0,0), Vec, length, 0, const, 10 ,"cable/rope", false)
	Hook.Rope.Type = "" --prevents the duplicator from making this weld
	Hook.Elastic.Type = "" --prevents the duplicator from making this weld
	
	Hook.CLength = length
end