AddCSLuaFile( "envx_mobilitycore.lua" )

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Ship Drive Systems"
ENT.Author			= "Ludsoe"
ENT.Category		= "Other"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.Owner			= nil
ENT.SPL				= nil

if(SERVER)then

	function ENT:Initialize()
		self:SetModel("models/spacebuild/nova/drone2.mdl")
		--self:SetModel("models/slyfo/tenginesm.mdl")
	
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
	
		self.MoveInputs = {MoveUp=0,MoveDown=0,MoveLeft=0,MoveRight=0,MoveForward=0,MoveBackward=0}
		self.Times = {LastCheck=0}
		self.HoverPos = Vector(0,0,0)
	
		self.Props = {}
		self.MassCenter = Vector(0,0,0)
		self.Mass = self:GetPhysicsObject():GetMass()
		self.ForceProp = self
		
		self.Inputs = Wire_CreateInputs(self, { "Activate", "Move Up","Move Down" })
	end
	
	function ENT:TriggerInput(iname, value)
		if (iname == "Activate") then
			if value~=0 then
				self:TurnOn()
			else
				self:TurnOff()
			end
		end
	end
	
	function ENT:FindStats()
		local Mass = self:GetPhysicsObject():GetMass()
		local MCV = self:GetPhysicsObject():GetMassCenter()
		local MassCenter = Vector(MCV.x*Mass,MCV.y*Mass,MCV.z*Mass)
		
		self.Props = constraint.GetAllWeldedEntities(self.Entity)
		for _, ent in pairs( self.Props ) do
			if ent==self then continue end
			local EntMass = (ent:GetPhysicsObject():GetMass() or 1)
			Mass = Mass + EntMass
			local Vec = self:WorldToLocal((ent:GetPos()+ent:GetPhysicsObject():GetMassCenter()))
			MassCenter = MassCenter + Vector(Vec.x*EntMass,Vec.y*EntMass,Vec.z*EntMass)
		end
		
		self.MassCenter = Vector(MassCenter.x/Mass,MassCenter.y/Mass,MassCenter.z/Mass)
		self.Mass = Mass
		
		self.ForceProp = self
		for _, ent in pairs( self.Props ) do
			local EntMass = (ent:GetPhysicsObject():GetMass() or 1)
			if EntMass-ent:GetPos():Distance(self.MassCenter)>self.ForceProp:GetPhysicsObject():GetMass()-self.ForceProp:GetPos():Distance(self.MassCenter) then
				self.ForceProp = ent
			end
		end
		
		--print("Mass: "..Mass.." MassCenter: "..tostring(self.MassCenter).." ForceProp: "..tostring(self.ForceProp))
	end
	
	function ENT:SetPropGravity(bool)
		--self:GetPhysicsObject():EnableGravity(bool)
		for _, ent in pairs( self.Props ) do
			ent:GetPhysicsObject():EnableGravity(bool)
			ent.NoGrav = not bool
		end	
	end
	
	function ENT:TurnOn()
		if not self.Active then
			self:FindStats()
			self.Active = true
			
			self.HoverPos = self:GetPos()
			self.Times.LastCheck = CurTime()
			
			self:SetPropGravity(false)
		end
	end
	
	function ENT:TurnOff()
		if self.Active then
			self.Active = false
			
			self:SetPropGravity(true)
		end
	end
	
	function ENT:Think()
		if self.Active then
			if self.Times.LastCheck+1 < CurTime() then
			--	self.Times.LastCheck=CurTime()
				self:FindStats()
			end
			
			local Direction,Rotate = Vector(0,0,0),Angle(0,0,0)
			local MyPos,MyVel = self:GetPos(),self:GetVelocity()
			local PhysObj = self.ForceProp:GetPhysicsObject()
			
			
			local Force = ((MyVel*-0.3))
			local AForce = PhysObj:GetAngleVelocity()*-0.8
			
			--print(tostring(Force).." "..tostring(AForce))
			
			PhysObj:ApplyForceOffset( Force*self.Mass, self:LocalToWorld(self.MassCenter) )
			PhysObj:AddAngleVelocity( AForce )
		end
		
		self:NextThink( CurTime() + 0.01 )
	end
	
	function ENT:SetActive( value, caller )
		
	end
else

end		
