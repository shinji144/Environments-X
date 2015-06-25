 
 function EFFECT:Init( data ) 

	self.vOffset = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.Dist = data:GetMagnitude()
 
	self.Time = 5*self.Dist
 	self.LifeTime = CurTime() + self.Time
	self.RockScale = math.Rand(1,3)/2
	local RandVec = VectorRand():GetNormalized()
	self.Speed = math.Rand(1,2)
	self.emitter = ParticleEmitter( self.vOffset )
		
			local particle = self.emitter:Add( "particles/flamelet"..tostring(math.random(1,5)), self.vOffset + RandVec * math.Rand(1,10) )
				if (particle) then
				particle:SetVelocity( self.Normal + VectorRand() *math.Rand(15,100) )
				particle:SetLifeTime(0)
				particle:SetDieTime( math.Rand(0.3,2) )
				particle:SetStartAlpha( math.Rand(128,225) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 6 )
				particle:SetEndSize( 15 )
				particle:SetColor(225,math.Rand(150,225),0)
				particle:SetAirResistance(0)
				end
		
			local particle = self.emitter:Add( "particles/smokey", self.vOffset + RandVec * math.Rand(10,50) )
				if (particle) then
				particle:SetVelocity( RandVec*math.Rand(20,50) )
				particle:SetLifeTime(0)
				particle:SetDieTime( math.Rand(1,3) )
				particle:SetStartAlpha( math.Rand(32,64) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 20 )
				particle:SetEndSize( 10 )
				particle:SetRoll( math.Rand(0,360) )
				particle:SetRollDelta( math.Rand(-0.2,0.2) )
				particle:SetColor(140,128,128)
				particle:SetAirResistance(50)
				end
		
	self.emitter:Finish()
	
	self:SetPos(self.vOffset + RandVec * math.Rand(0,30))
	self:SetModel( "models/props_junk/Rock001a.mdl" )
	self:SetAngles( VectorRand():Angle() )
	
 end 
   
 function EFFECT:Think( ) 
   
   self:SetPos( self.Entity:GetPos()+self.Normal*self.Speed )
 	return ( self.LifeTime > CurTime() )  
 	 
 end 
 
  function EFFECT:Render() 
 	 
 	local Fraction = (self.LifeTime - CurTime()) / self.Time 
 	Fraction = math.Clamp(Fraction,0,1) 
 	
	self:SetModelScale( Vector() * Fraction * self.RockScale )
 	self:DrawModel() 
   
 end  