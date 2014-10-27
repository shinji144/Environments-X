AddCSLuaFile( "event_meteor.lua" )

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName			= "Asteroid"
ENT.Author			= "CmdrMatthew"

if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/props_wasteland/rockgranite04c.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:EnableGravity(false)
			phys:SetMass(50000)
		end
		self:SetHealth(math.Clamp((self:GetPhysicsObject():GetVolume()/900)-100,50,10000))
		self:SetColor(Color(150,150,150,255))
		self.firstthink = true
	end

	function ENT:PhysicsCollide(ent)
		if not self.Burn then return end
		
		local expl = ents.Create("env_explosion")
		expl:SetPos(self:GetPos())
		expl:SetParent(self)
		expl:SetOwner(self:GetOwner())
		expl:SetKeyValue("iMagnitude","1000");
		expl:SetKeyValue("iRadiusOverride", 2000)
		expl:Spawn()
		expl:Activate()
		
		util.ScreenShake(self:GetPos(), 14, 255, 6, 5000)
		
		expl:Fire("explode", "", 0)	
		expl:Fire("kill", "", .5)
		
		for k,v in pairs(ents.FindInSphere(self:GetPos(),500)) do
			if v:IsValid() then
				constraint.RemoveAll(v)
			end
		end
		
		local tr = util.QuickTrace(self:GetPos(), self:GetPos()+(self:GetVelocity()*100), self)
		if tr.Entity then
			if tr.Entity:IsValid() then
				constraint.RemoveAll(tr.Entity)
			end
		end
		self:Remove()
	end

	function ENT:Start(planet)
		self.target = planet.position or Vector(0,0,0)
		local dir = self.target - self:GetPos()
		dir:Normalize()
		self:GetPhysicsObject():SetVelocity( dir * 700 ) 
	end

	function ENT:OnTakeDamage(dmg)
		self:SetHealth(self:Health() - dmg:GetDamage())
		if self:Health() < 1 then
			self:EmitSound("Weapon_Mortar.Impact")
			self:Remove()
		end
	end

	function ENT:Think()
		if not self.firstthink then
			if self.Burn ~= true then
				self.Burn = true
				self:Ignite(100,100)
				self.flame = ents.Create("env_fire_trail")
				self.flame:SetAngles(self:GetAngles())
				self.flame:SetPos(self:GetPos())
				self.flame:SetParent(self)
				self.flame:Spawn()
				self.flame:Activate()
			end
			local phys = self:GetPhysicsObject()
			if phys and phys:IsValid() then
				local diff = self.target - self:GetPos()
				diff:Normalize()
				phys:SetVelocity( diff * 700 ) 
			end
		else
			self.firstthink = false
		end
		self:NextThink(CurTime()+1)
		return true
	end

	function ENT:CanTool()
		return false
	end

	function ENT:GravGunPunt()
		return false
	end

	function ENT:GravGunPickupAllowed()
		return false
	end
else
	function ENT:Draw()            
		self.Entity:DrawModel()
	end  
end		
