AddCSLuaFile( "event_asteroid_storm.lua" )

ENT.Type = "anim"  
ENT.Base = "base_gmodentity"     
ENT.PrintName = "Asteroid Storm Event"  
ENT.Author = "CmdrMatthew" 

ENT.exploding			= true


if(SERVER)then

	local maxrocks = 100
	local currocks = 0

	function ENT:Initialize()   
		self:SetModel("models/props_junk/watermelon01.mdl")  	
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		self.maxrocks = math.random(10,20)
		self.rocks = 0
	end

	function ENT:Start(radius)
		self.radius = radius
		self.active = true
	end

	function ENT:Think()
		if self.active then
			if self.rocks < self.maxrocks then
				local rad = self.radius - 500
				local pos = self:GetPos()+Vector(math.cos(math.random(0,360))*rad,math.sin(math.random(0,360))*rad,0)
				if util.IsInWorld(pos) then
					rock = ents.Create("event_asteroid")
					rock:SetPos(pos)
					rock:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
					rock:Spawn()
					if rock:IsInWorld() then
						rock:GetPhysicsObject():EnableGravity(false)
						rock:GetPhysicsObject():SetMass(2500)
						rock:GetPhysicsObject():SetVelocity(Vector(0,0,-700))
					end
				end
				self.rocks = self.rocks + 1
			else
				self:Remove()
			end
		end
		self:NextThink(CurTime() + 1)
		return true
	end
else
	function ENT:Draw() end
end		
