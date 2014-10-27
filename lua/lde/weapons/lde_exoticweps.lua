
-------------------------------------
-----------RailGun-------------------
-------------------------------------

local Client = function(self) return LDE.Weapons.ShowCharge(self,self.Data.Bullet) end --Clientside
local ClientSetup = function(ENT) ENT.LDETools.Charge = Client end
local Func = function(self,CanFire) 
	LDE.Weapons.ManageCharge(self,self.Data.Bullet)
	return true
end --Charge function
local Base = {Tool="Weapon Systems",Type="Chargers"}
local Effects = {Beam="LDE_laserbeam_long",Hit="LDE_laserhiteffect"}

--Basic RailGun
local Fire = function(self) LDE.Weapons.SingleBurst(self,self.Data.Bullet) end
local Bullet = {Recoil=200,CoolDown=2,ChargeRate=5,Radius=1,MinCharge=50,MaxCharge=150,Dpc=4,ChargeType=true,ChargeShoot=Fire,Effect=Effects}
local Data={name="Basic RailGun",class="basic_railgun_weapon",WireOut={"Charge","CanFire"},In={"energy"},shootfunc=Func,ClientSetup=ClientSetup,Points=220,heat=5,firespeed=0.5,InUse={500},Bullet=Bullet}
local Makeup = {name={"Small RailGun"},model={"models/Slyfo_2/drone_railgun.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Large RailGun
local Fire = function(self) LDE.Weapons.SingleBurst(self,self.Data.Bullet) end
local Bullet = {Recoil=2000,CoolDown=20,ChargeRate=50,Radius=0.5,MinCharge=500,MaxCharge=1500,Dpc=6,ShootDir=Vector(0,0,1),ShootPos=Vector(0,0,120),ChargeType=true,ChargeShoot=Fire,Effect=Effects}
local Data={name="Large RailGun",class="large_railgun_weapon",WireOut={"Charge","CanFire"},In={"energy"},MountType="CapRailGun",shootfunc=Func,ClientSetup=ClientSetup,Points=2000,heat=1000,firespeed=0.8,InUse={10000},Bullet=Bullet}
local Makeup = {name={"Large RailGun"},model={"models/mandrac/hybride/cap_railgun_gun1.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

-------------------------------------
-----------Plasma--------------------
-------------------------------------
local Base = {Tool="Weapon Systems",Type="Plasma"}

--Hyper Rift Beam
local wire = function(self)
	self.Inputs = Wire_CreateInputs( self, { "Fire", "Multiplier" } ) 
	self.Outputs = Wire_CreateOutputs( self, { "Multiplier", "Energy/Sec", "DPS" } )
end

local Intial = function(self)
	self.multiplier = 1 
	Wire_TriggerOutput(self,"Multiplier",self.multiplier) 	
	
	self.playedcharge,self.playedfire,self.playedfiring,self.wirefire,self.chargetime 	= false,false,false,false,CurTime()	
	
	self.Sound = CreateSound( self, Sound("ambient/atmosphere/noise2.wav") )

	self:SetNWFloat( "multiplier", self.multiplier )  --Need this set or in some cases.. like advanced dupes, it can be nil and draw no effect (until the multiplier is changed)
	self:SetNWBool( "hit_eh", false )
	self:SetNWBool( "imp_eh", false )
	self:SetNWEntity( "ent_eh", nil)
	
	Msg(tostring(self:GetOwner()).."\n")
end

local wirefunc = function(self,iname,value)
	if (iname == "Fire") then
		if value == 1 then
			self.chargetime = CurTime() + 6			
			self.Active,self.wirefire = 1,true
		else 			
			self.Active,self.wirefire = 0,false

			self:StopSound(Sound("ambient.whoosh_huge_incoming1"))
			self:StopSound(Sound("explode_7"))
			self:StopSound(Sound("ambient/atmosphere/noise2.wav"))
			self:StopLoopingSound(1,Sound("ambient/atmosphere/noise2.wav"))
			
			if self.playedfiring == true then
				self.Sound:Stop()
				self.playedfiring = false
			end
   			self.playedcharge 	= false
			self.playedfire 	= false

			self:StopSound(Sound( "npc/strider/fire.wav" ))
			self:SetNWBool( "charging", false )
		end
	elseif (iname == "Multiplier") then
		if value < 1 then
			self.multiplier = 1
			self:SetNWFloat( "multiplier", self.multiplier )
		else
			if value > 3 then
				self.multiplier = 3
				self:SetNWFloat( "multiplier", self.multiplier )
			else 			
				self.multiplier = value
				self:SetNWFloat( "multiplier", self.multiplier )
			end 	  		
		end
		Wire_TriggerOutput(self,"Multiplier",self.multiplier)
	end
end

local Func = function(self,CanFire) 
	if self.Active == 1 and CanFire then
		if(self.wirefire == false)then self.wirefire=true self.chargetime=CurTime()+6 end
		
		self:DoRes(self.multiplier)
		
		if self.playedcharge == false and self.energytofire then
			self:EmitSound(Sound("ambient.whoosh_huge_incoming1"))
			self:SetNWBool( "charging", true )
			self.playedcharge = true 				
		elseif not self.energytofire then
			self:StopSound(Sound("ambient.whoosh_huge_incoming1"))
			self.Sound:Stop()
			self.playedcharge = false
		end	
		
		if not self.energytofire then  --stop it from holding charge when energy breaks
			self:SetNWBool( "charging", false )
			self.chargetime = CurTime() + 6	
		end	
		
		if	self.energytofire and CurTime() > self.chargetime  then
			if self.playedfire == false and self.energytofire then
				self:EmitSound(Sound("explode_7"))
				self:EmitSound(Sound( "npc/strider/fire.wav" ))
				self.playedfire = true 				
			elseif not self.energytofire then  				
				self:StopSound(Sound("explode_7"))
				self:StopSound(Sound( "npc/strider/fire.wav" ))
				self.playedfire = false 			
			end 
			if self.playedfiring == false and self.energytofire then
				--self:EmitSound(Sound("ambient/atmosphere/noise2.wav"))
				self.Sound:Play()
				self.playedfiring = true 				
			elseif not self.energytofire then   				
				self:StopSound(Sound("ambient/atmosphere/noise2.wav"))
				self.playedfiring = false 			
			end  			
			self:WeaponFiring()	
		else
			self:WeaponIdle()	
		end		
	else
		self.wirefire =  false
		self:StopSound(Sound("ambient.whoosh_huge_incoming1"))
		self:StopSound(Sound("explode_7"))
		self:StopSound(Sound("ambient/atmosphere/noise2.wav"))
		self:StopSound(Sound( "npc/strider/fire.wav" ))
		if self.playedfiring == true then
			self.Sound:Stop()
			self.playedfiring 	= false
		end
		self:WeaponIdle()
		self:SetNWBool( "charging", false )
	end
	self:SetNWFloat( "multiplier", self.multiplier )
	local energyneedsec = (self.energybase * self.multiplier)*10
	local damagesec = (self.damagebase * self.multiplier)*10
	Wire_TriggerOutput(self,"Plasma/Sec",energyneedsec)
	Wire_TriggerOutput(self,"DPS",damagesec)
	return true
end --Charge function

local shared = function(ENT)

	ENT.damagebase	= 200
	ENT.energybase 	= 2 --was 25 (10x for 1 second)
	ENT.energytofire = true
	ENT.chargetime = CurTime()

	if(SERVER)then
	
		function ENT:OnRemove()
			self.BaseClass.OnRemove(self)
			Wire_Remove(self)
			self:StopSound(Sound("ambient.whoosh_huge_incoming1"))
			self:StopSound(Sound("explode_7"))
			self:StopSound(Sound("ambient/atmosphere/noise2.wav"))
			self:StopSound(Sound( "npc/strider/fire.wav" ))
			--if self.playedfiring == true then
				self.Sound:Stop()
			--end
		end
		
		function ENT:WeaponFiring()
			local trace = {}
				trace.start = self:GetPos() + (self:GetForward() * 147.5) + (self:GetUp() * 9.25)
				trace.endpos = self:GetPos() + self:GetForward() * 100000
				trace.filter = self
					 
				tr = util.TraceLine( trace )

			self:SetNWBool( "drawbeam", true )
			self:SetNWBool( "charging", false )
			
			LDE.HeatSim.ApplyHeat(self,(1000*self.multiplier),false)
			
			if(tr.Entity and tr.Entity:IsValid())then
				LDE.AdvDamage:BudderEffect(tr.Entity,(self.damagebase * self.multiplier),10,self,self)
				--LDE:DealDamage(tr.Entity,(self.damagebase * self.multiplier))
			end
		end
		
		function ENT:DoRes(multi)
			local energy = self:GetResourceAmount("Plasma")
			local energyneed = self.energybase * multi
		   
			if (energy >= energyneed) then
				self.energytofire = true
				self:ConsumeResource("Plasma",energyneed)
				return true            
			else
				self.energytofire = false
				return false
			end
		end

		function ENT:WeaponIdle()
			self:SetNWBool( "drawbeam", false )
			self:SetNWBool( "hit_eh", false )
			self:SetNWBool( "imp_eh", false )
			self:SetNWEntity( "ent_eh", nil)
			
			if self.playedfiring == true then
				self.Sound:Stop()
				self.playedfiring 	= false
			end
		end
	else

	end
end

local client = function(self)
	local drawbeam = self:GetNWBool("drawbeam")
	local charging = self:GetNWBool("charging")
	local hit_eh = self:GetNWBool("hit_eh")
	local imp_eh = self:GetNWBool("imp_eh")
	local ent = self:GetNWEntity("ent_eh")
	local multi = self:GetNWFloat( "multiplier")
	local muzzel = self:GetPos() + (self:GetForward() * 147.5) + (self:GetUp() * 9.25) 
	
	if charging == true then
   		local effectdata = EffectData()
			effectdata:SetOrigin(muzzel)
			effectdata:SetMagnitude(multi)
			util.Effect( "ion_charge", effectdata )  	
			
		local effectdata = EffectData()
			effectdata:SetOrigin(muzzel)
			effectdata:SetNormal(self:GetForward())
			util.Effect( "ion_refract", effectdata )
   	end 	
	if drawbeam == true then
	
		local trace = {}
				trace.start = self:GetPos() + (self:GetForward() * 147.5) + (self:GetUp() * 9.25)
				trace.endpos = self:GetPos() + self:GetForward() * 100000
				trace.filter = self
				
				tr = util.TraceLine( trace )
				
		local dist = (tr.HitPos - trace.start):Length()
		local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetNormal(tr.HitNormal)
				util.Effect( "ion_refract", effectdata )
				
		local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetStart(trace.start)
				effectdata:SetMagnitude(multi)
				effectdata:SetScale(dist)
				util.Effect( "ion_beam", effectdata )
		if imp_eh == false then 			
				util.Effect( "ion_impact", effectdata )		
		end
   	end
end

local Data={name="Hyper Rift Beam",class="hyper_rift_laser_weapon",Client=client,Shared=shared,Intial=Intial,WireFunc=wirefunc,WireSpecial=wire,In={"Plasma"},MountType="Titan",shootfunc=Func,Client=client,Points=3000,heat=0,firespeed=0.1,InUse={0}}
local Makeup = {name={"Hyper Rift Beam"},model={"models/Spacebuild/Nova/machuge.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)

--Winch
local Base = {Tool="Weapon Systems",Type="Non-Lethal"}

local Func = function(self,CanFire)
	if(self.Active==1 and CanFire)then
		if (CurTime() >= self.MCDown) then
			if(LDE.LifeSupport.ManageResources(self,1))then
				local NewShell = ents.Create( "SF-GrappleH" )
				if ( !NewShell:IsValid() ) then return end
				NewShell:SetPos( self:GetPos() + (self:GetForward() * 50) )
				NewShell:SetAngles( self:GetAngles() )
				NewShell.SPL = self.SPL
				NewShell:Spawn()
				NewShell:Initialize()
				NewShell:Activate()
				local NC = constraint.NoCollide(self, NewShell, 0, 0)
				NC.Type = ""
				NewShell.PhysObj:SetVelocity(self:GetForward() * 5000)
				NewShell.Active = true
				NewShell.ATime = 0
				NewShell:Fire("kill", "", 120)
				NewShell.ParL = self
				NewShell:Think()
				if(NADMOD)then
					NADMOD.SetOwnerWorld(NewShell)
				end
				self.MCDown = CurTime() + 1
				self:TurnOff()
				return true
			end
		end
	end
	return false
end

local WireFunc = function(self,iname,value)
	if (iname == "Launch") then
		if value > 0 then
			if self.Active == 0 then
				self:TurnOn()
			end
		else
			if self.Active == 1 then
				self:TurnOff()
			end
		end
	elseif (iname == "Length") then
		self.DLength = math.Clamp(value, 100, 5000)
		self.LChange = CurTime()
		
	elseif (iname == "Disengage") then
		if value > 0 then
			self.Disengaging = true
		else
			self.Disengaging = false
		end
		
	elseif (iname == "Speed") then
		self.ReelRate = math.Clamp(value, 0.01, 20)
		
	end
end

local WireSetup = function(self)
	self.Inputs = Wire_CreateInputs( self, { "Launch", "Length", "Disengage", "Speed" } )
	self.Outputs = Wire_CreateOutputs( self, { "CanLaunch", "CurrentLength","CanFire" })
	self.DLength = 0
	self.LChange = 0
	self.ReelRate = 5
	self.MCDown = 0
end

local Data={name="Winch",class="winch_weapon",In={"energy"},SafeAllow=true,shootfunc=Func,WireSpecial=WireSetup,WireFunc=WireFunc,Points=350,heat=5,firespeed=1,InUse={500}}
local Makeup = {name={"Winch"},model={"models/Slyfo/sat_grappler.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.Weapons.CompileWeapon(Data,Makeup)