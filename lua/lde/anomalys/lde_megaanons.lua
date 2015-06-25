
------------------Nebula---------------------
local Spawn = function() 		
	rock = ents.Create("event_nebula")
	rock:SetPos(LDE.Anons:PointInSpace(rock.Data))
	rock:Spawn()
end
local Int = function(self)			
	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false)
		phys:EnableCollisions(false)
	end
	self:SetColor(0,0,0,0)
end
local Client = function(ENT)
	function ENT:Think() --hackhackhackhackhackhackhackhackhackhackhackhackhackhackhack D:
		if self.lol == nil then
			self:Cloud()
			self.lol = true
		end
	end

	function ENT:Cloud()
	  local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
			effectdata:SetScale( 6 )
			effectdata:SetMagnitude( 100 ) --75
			//The starting color for the particles. Needed a vector, and I found one.
			effectdata:SetStart( Vector(math.random(0,255),math.random(0,255),math.random(0,255)))
			//The color variance of particles. Needed another 3 part datatype, lol. So I cheated.
			effectdata:SetAngles( Angle(math.random(0,255),math.random(0,255),math.random(0,255)) )
			util.Effect( "env_nebula" , effectdata )
	end
end
local Data={name="Nebula",class="event_nebula",Type="Space",Initial=true,Mega=true,Client=Client,Startup=Int,ThinkSpeed=1,SpawnMe=Spawn}
LDE.Anons.GenerateAnomaly(Data)

-----------HyperMass--------------
local Spawn = function() 	
	rock = ents.Create("hypermass")
	rock:SetPos(LDE.Anons:PointInSpace(rock.Data))
	rock:Spawn()	
end
local Int = function(self)	
	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMaterial("debug/env_cubemap_model")
	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:EnableMotion(false)
	end
end
local Client = function(ENT)
	function ENT:Think()
		if self.lol == nil then
			self:Streams()
			self.lol = true
		end
	end

	function ENT:Streams()
		local JetColor = math.random(1,5)
		local RingColor = math.random(1,4)
		
		local effect = EffectData()
		effect:SetEntity(self)
		util.Effect("hypermass_pinch",effect)
		effect:SetScale(RingColor)
		util.Effect("hypermass_centerring",effect)
		
		effect:SetMagnitude(1)
		effect:SetScale(RingColor)
		util.Effect("hypermass_ring",effect)
			
		effect:SetScale(JetColor)
		util.Effect("hypermass_jet",effect)
		
		effect:SetMagnitude(0)
		effect:SetScale(RingColor)
		util.Effect("hypermass_ring",effect)

		effect:SetScale(JetColor)
		util.Effect("hypermass_jet",effect)
		
	end
end
local Touch = function(self,activator) self:Blackhole(activator) end
local Think = function(self)
	local ent = self
	local pos = ent:GetPos()
	local ents = ents.FindInSphere(pos,self.Radius)
	--Msg(" \n Thinking: ")
	for _,v in pairs(ents) do
		--Msg("Entity Pull! ")
		if IsValid(v) and v:GetCreationID()~=self:GetCreationID() then
			--Msg("IsUsable! ")
			local range = v:GetPos():Distance(ent:GetPos())
			if(not LDE:IsImmune(v) and not LDE:IsInSafeZone(v))then
				--Msg("NOT IMMUNE! ")
				local dir = (v:GetPos()-ent:GetPos()) --LDE:Normalise(v:GetPos()-ent:GetPos())
				dir:Normalize()
				local phys = v:GetPhysicsObject()
				if math.random(1,15) == 1 then
					if (phys:IsValid()) then 
						phys:EnableMotion(true)
						phys:Wake()	
					end
				end
				if(range<80)then self:Blackhole(v) end
				if(v:GetClass()=="player")then
					if(range<1000 and v:Alive())then
						v:SetDSP( 29, false )
					else
						v:SetDSP( 0, false )
					end
					
					local pow= (self.Power*phys:GetMass()/range+1^2)
					local force = ((v:GetPos()-self:GetPos())*Vector(-pow,-pow,-pow))*(range/self.Radius)
					v:SetVelocity(force)
				else
					if(IsValid(phys)) then
						local dir = (v:GetPos()-self:GetPos())
						local pow= (self.Power*phys:GetMass()/range+1^2)
						local force = (dir*Vector(-pow,-pow,-pow))*(range/self.Radius)
						phys:ApplyForceCenter(force)
						--Msg("Applying force! \n")
					end
				end
			end
		end
	end
end
local Server = function(ENT)
	
	ENT.StartingPower = 500
	ENT.StartingRadius = 2500
	ENT.MaximumPower = 1000000
	ENT.MaximumRadius = 7000
	ENT.Power = 500
	ENT.Radius = 2500	
	ENT.NoLDEDamage = true
	ENT.Exploded = false
	
	function ENT:Explode()
		if(self.Exploded)then return end
		self.Exploded = true
		local effectdata = EffectData()
		effectdata:SetMagnitude( 1 )
		
		local Pos = self:GetPos()
		
		effectdata:SetOrigin( Pos )
		effectdata:SetScale( self.Radius )
		util.Effect( "LDE_coredeath", effectdata )
		local players = player.GetAll()
		for _, ply in pairs( players ) do
			ply:EmitSound( "explode_9" )
		end
		self:EmitSound( "explode_9" )
		
		local Boom = { 
			Pos 					=		Pos,	--Required--		--Position of the Explosion, World vector
			ShrapDamage	=		self.Power,										--Amount of Damage dealt by each Shrapnel that hits, if 0 or nil then other Shap vars are not required
			ShrapCount		=		10,										--Number of Shrapnel, 0 to not use Shrapnel
			ShrapDir			=		self:GetForward(),							--Direction of the Shrapnel, Direction vector, Example: Missile:GetForward()
			ShrapCone		=		180,										--Cone Angle the Shrapnel is randomly fired into, 0-180, 0 for all to be released directly forward, 180 to be released in a sphere
			ShrapRadius		=		self.Radius,										--How far the Shrapnel travels
			ShockDamage	=		self.Power,				--Required--		--Amount of Shockwave Damage, if 0 or nil then other Shock vars are not required
			ShockRadius		=		self.Radius,										--How far the Shockwave travels in a sphere
			Ignore				=		self,									--Optional Entity that Shrapnel and Shockwaves ignore, Example: A missile entity so that Shrapnel doesn't hit it before it's removed
			Inflictor				=		self,			--Required--		--The weapon or player that is dealing the damage
			Owner				=		self		--Required--		--The player that owns the weapon, or the Player if the Inflictor is a player
		}
		LDE:BlastDamage(Boom)
		local Resources = {Blackholium={amount=10,name="Blackholium"}}
		local scrap = ents.Create("resource_clump")
			scrap:SetPos(self:GetPos()+Vector(math.random(-10,10),math.random(-10,10),math.random(-10,10)))
			scrap:SetModel( self:GetModel() )
			scrap:Spawn()
			scrap.Resources=Resources
			scrap.NoLDEDamage=true
			scrap:SetMaterial("debug/env_cubemap_model")
			local delay = (math.random(900, 1800))
			scrap:Fire("break","",tostring(delay + 10))
			scrap:Fire("kill","",tostring(delay + 10))
		self:Remove()
	end
	
	function ENT:Blackhole(ent)
		if(not IsValid(ent))then return end
		if(not LDE:IsImmune(ent) and not LDE:IsInSafeZone(v))then
			local phyx = ent:GetPhysicsObject()
			str = ent:GetClass()
			if(IsValid(phyx))then
				mass =(phyx:GetMass()/10)
			else
				mass = 0
			end
			if ent:GetClass() == "player" then
				if(ent:Alive())then--Only kill living players.
					ent:Kill()
				end
			else
				self.Power=self.Power+mass
				self.Radius=math.Clamp(self.Radius+mass,self.StartingRadius,self.MaximumRadius)
				ent:Remove()
			end
		end
		if(self.Power>=self.MaximumPower)then self:Explode() end
	end
end
local Data={name="BlackHole",class="hypermass",Type="Space",Touch=Touch,Think=Think,Server=Server,Client=Client,Startup=Int,ThinkSpeed=0.05,SpawnMe=Spawn,minimal=1}
LDE.Anons.GenerateAnomaly(Data)