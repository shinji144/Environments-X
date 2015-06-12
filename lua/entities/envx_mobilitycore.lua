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
	
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMaterial("spacebuild/SBLight5");
	
		self.MoveInputs = {MoveUp=0,MoveDown=0,MoveLeft=0,MoveRight=0,MoveForward=0,MoveBackward=0}
		self.HoverPos = Vector(0,0,0)
	
		self.Props = {}
		self.MassCenter = Vector(0,0,0)
		self.Mass = self:GetPhysicsObject():GetMass()
		
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
		local MassCenter = Vector(0,0,0)
		
		self.Props = constraint.GetAllWeldedEntities(self.Entity)
		for _, ent in pairs( self.Props ) do
			if ent==self then continue end
			local EntMass = (ent:GetPhysicsObject():GetMass() or 1)
			Mass = Mass + EntMass
			MassCenter = MassCenter + (self:WorldToLocal(ent:GetPos())*EntMass)
		end
		
		self.MassCenter = MassCenter/Mass
		self.Mass = Mass
		print("Mass: "..Mass.." "..tostring(self.MassCenter))
	end
	
	function ENT:TurnOn()
		if not self.Active then
			self:FindStats()
			self.Active = true
			
			self.HoverPos = self:GetPos()
		end
	end
	
	function ENT:TurnOff()
		if self.Active then
			self.Active = false
		end
	end
	
	function ENT:Think()
		if self.Active then
			local Direction = Vector(0,0,0)
			local MyPos,MyVel = self:GetPos(),self:GetVelocity()
			
			if Direction == Vector(0,0,0) then
				local HoverDistance = self.HoverPos:Distance(MyPos)
				if HoverDistance>100 then
					self.HoverPos = MyPos
					HoverDistance = 0
				end
				
				Direction = self.HoverPos-MyPos
				Direction:Normalize()
				Direction=Direction*(HoverDistance*5)
			end
			
			self:GetPhysicsObject():ApplyForceOffset( (Direction+(MyVel*-0.1))*self.Mass, self.MassCenter )
		end
	end
	
	function ENT:SetActive( value, caller )
		
	end
else

end		
