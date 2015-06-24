AddCSLuaFile( "envx_mobilitycore.lua" )

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Ship Drive Systems"
ENT.Author			= "Ludsoe"
ENT.Category		= "Environments"

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
	
		self.MoveInputs = {MoveUp=0,MoveDown=0,MoveLeft=0,MoveRight=0,MoveForward=0,MoveBackward=0,PitchUp=0,PitchDown=0,YawLeft=0,YawRight=0,RollLeft=0,RollRight=0}
		self.Times = {LastCheck=0}
		self.HoverPos = Vector(0,0,0)
		
		self.MoveMult = {MoveUp=0,MoveDown=0,MoveLeft=0,MoveRight=0,MoveForward=0,MoveBackward=0}
		
		self.Props = {}
		self.MassCenter = Vector(0,0,0)
		self.Mass = self:GetPhysicsObject():GetMass()
		self.ForceProp = self
		
		self.Inputs = Wire_CreateInputs(self, { 
			"Activate", 
			"Move Up",
			"Move Down", 
			"Move Forward", 
			"Move BackWard", 
			"Move Left", 
			"Move Right", 
			"Pitch Up (Nose Up)", 
			"Pitch Down (Nose Down)",
			"Yaw Left (Turn Left)",
			"Yaw Right (Turn Right)",
			"Roll Left (Flip Left)",
			"Roll Right (Flip Right)"
		})
		
		local InputTran = {}
			InputTran["Move Up"] = "MoveUp"
			InputTran["Move Down"] = "MoveDown"
			InputTran["Move Forward"] = "MoveForward"
			InputTran["Move BackWard"] = "MoveBackward"
			InputTran["Move Left"] = "MoveLeft"
			InputTran["Move Right"] = "MoveRight"
		self.InputTrans = InputTran
		
		local InputTran = {}
			InputTran["Pitch Up"] = "PitchUp"
			InputTran["Pitch Down"] = "PitchDown"
			InputTran["Yaw Left"] = "YawLeft"
			InputTran["Yaw Right"] = "YawRight"
			InputTran["Roll Left"] = "RollLeft"
			InputTran["Roll Right"] = "RollRight"
		self.InputTransSpecial = InputTran
	end
	
	function ENT:TriggerInput(iname, value)
		if (iname == "Activate") then
			if value~=0 then
				self:TurnOn()
			else
				self:TurnOff()
			end
		else
			local Trans = self.InputTrans[iname]
			if Trans then
				if value~= 0 then
					self.MoveInputs[Trans] = 1
				else
					self.MoveInputs[Trans] = 0
				end
			end
			
			local Transpecial = self.InputTransSpecial[iname]
			if Transpecial then
				if value>= 0 then
					self.MoveInputs[Transpecial] = value
				else
					self.MoveInputs[Transpecial] = 0
				end
			end
		end
	end
	
	function ENT:FindStats()
		local Mass = self:GetPhysicsObject():GetMass()
		local MCV = self:GetPhysicsObject():GetMassCenter()
		local MassCenter = Vector(MCV.x*Mass,MCV.y*Mass,MCV.z*Mass)
		
		self:SetPropGravity(true)
		
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
		
		self:SetPropGravity(false)
		--print("Mass: "..Mass.." MassCenter: "..tostring(self.MassCenter).." ForceProp: "..tostring(self.ForceProp))
	end
	
	function ENT:SetPropGravity(bool)
		--self:GetPhysicsObject():EnableGravity(bool)
		for _, ent in pairs( self.Props ) do
			if not bool then
			--	ent:GetPhysicsObject():EnableGravity(bool)
			end
			ent.NoGrav = not bool
		end	
	end
	
	function ENT:TurnOn()
		if not self.Active then
			self:FindStats()
			self.Active = true
			
			self.HoverPos = self:GetPos()
			self.Times.LastCheck = CurTime()
			
			self.HighEngineSound = CreateSound(self.ForceProp, Sound("ambient/atmosphere/outdoor2.wav"))
			self.LowDroneSound = CreateSound(self.ForceProp, Sound("ambient/atmosphere/indoor1.wav"))
			self.HighEngineSound:Play()
			self.LowDroneSound:Play()
			self.ForceProp:EmitSound( "buttons/button1.wav" )
			
			self:SetPropGravity(false)
		end
	end
	
	function ENT:TurnOff()
		if self.Active then
			self.Active = false
			
			self.LowDroneSound:Stop()
			self.HighEngineSound:Stop()
				
			self:SetPropGravity(true)
		end
	end
	
	function ENT:OnRemove()
		self:SetPropGravity(true)
	end
	
	function ENT:GetMoveInputs()
		local In,Mm = self.MoveInputs,self.MoveMult
		local Inputs = {}
		
		local MaxMult = 20
		
		for i, v in pairs( In ) do
			if self.MoveMult[i] then
				if v ~= 0 then
					if MaxMult > self.MoveMult[i] then
						self.MoveMult[i] = self.MoveMult[i]+1
					end
				else
					self.MoveMult[i] = 0
				end
			end
		end
		
		Inputs["MoveZ"] = ((In.MoveUp*Mm.MoveUp)-(In.MoveDown*Mm.MoveDown))*10
		Inputs["MoveX"] = ((In.MoveForward*Mm.MoveForward)-(In.MoveBackward*Mm.MoveBackward))*10
		Inputs["MoveY"] = ((In.MoveLeft*Mm.MoveLeft)-(In.MoveRight*Mm.MoveRight))*10
		
		Inputs["RotateY"] = ((In.PitchDown)-(In.PitchUp))*5
		Inputs["RotateZ"] = ((In.YawLeft)-(In.YawRight))*5
		Inputs["RotateX"] = ((In.RollLeft)-(In.RollRight))*5
		
		return Inputs
	end
	
	function ENT:Think()
		if self.Active then
			if self.Times.LastCheck+1 < CurTime() then
			--	self.Times.LastCheck=CurTime()
				self:FindStats()
			end
			
			local PhysObj = self.ForceProp:GetPhysicsObject()
		
			local MyVel,MyAngVel = PhysObj:GetVelocity(),PhysObj:GetAngleVelocity()
			
			local TurnMax = 10
			local MoveWant,TurnWant = Vector(),Vector()
			
			local Inputs = self:GetMoveInputs()
			
			MoveWant = Vector(Inputs.MoveX,Inputs.MoveY,Inputs.MoveZ)
			MoveWant:Rotate(self:GetAngles())

			TurnWant = Vector(Inputs.RotateX,Inputs.RotateY,Inputs.RotateZ)
			
			local Force = (MyVel*-0.3)+MoveWant
			local AForce = (MyAngVel*-0.8)+TurnWant
						
			--print(tostring(Force).." "..tostring(AForce))
			
			PhysObj:ApplyForceOffset( Force*self.Mass, self:LocalToWorld(self.MassCenter) )
			PhysObj:AddAngleVelocity( AForce )
			
			--Sound Part
			local speedmph = math.Round(MyVel:Length() / 17.6) 
			if speedmph > 80 then  --changing sounds based on speed
				self.HighEngineVolume = math.Clamp(((speedmph * 0.035)-2.6), 0, 1)
			else
				self.HighEngineVolume = speedmph * 0.0025
			end
			self.HighEnginePitch = (speedmph * 1.2) + 60
			self.LowDronePitch = 35+(speedmph * 0.2)
			self.HighEngineSound.ChangeVolume(self.HighEngineSound, self.HighEngineVolume, 0)
			self.HighEngineSound.ChangePitch(self.HighEngineSound, math.Clamp(self.HighEnginePitch, 0, 255), 0)
			self.LowDroneSound.ChangePitch(self.LowDroneSound, math.Clamp(self.LowDronePitch, 0, 255), 0)
		end
		
		self:NextThink( CurTime() + 0.01 )
	end
	
	function ENT:SetActive( value, caller )
		
	end
else

end		