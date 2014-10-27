 function EFFECT:Init( data ) 

 	self.Time = 9999999 --LOL IM NOT DIEING
 	self.LifeTime = CurTime() + self.Time 
 	self.Origin = data:GetOrigin()
	self.Mult = data:GetScale()
    self.Alpha = data:GetMagnitude()
    self.PColor = data:GetStart()
    self.PColorVar = data:GetAngles()
	self.emitter = ParticleEmitter( self.Origin)
    
    for i=0, (5) do
    
        local Arm = VectorRand():GetNormalized()
        local ArmPos = self.Origin

		for i=0, (20) do
            
            local VRand = VectorRand():GetNormalized()
            ArmPos = ArmPos + ( Arm*50 + VRand*30 )*self.Mult
            
            local AlphaVar = math.Rand( -20,20 )
            local Size = ( 30 - i + math.Rand(-5,10) )*self.Mult
		
			local particle = self.emitter:Add( "particles/smokey", ArmPos )
			if (particle) then
				particle:SetVelocity( Vector(0,0,0) )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( self.Time )
				particle:SetStartAlpha( self.Alpha + AlphaVar )
				particle:SetEndAlpha( self.Alpha + AlphaVar )
				particle:SetStartSize( Size*self.Mult )
				particle:SetEndSize( Size*self.Mult )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-0.2, 0.2) )
				particle:SetColor( self.PColor.x + math.Rand(-self.PColorVar.p,self.PColorVar.p)/2 , self.PColor.y + math.Rand(-self.PColorVar.y,self.PColorVar.y)/2 , self.PColor.z + math.Rand(-self.PColorVar.r,self.PColorVar.r)/2 )
				particle:SetAirResistance(0)
			end
			
		end
        
    end
		
	self.emitter:Finish()
 	self.Entity:SetPos( self.Origin )  
 end 
   
 function EFFECT:Think( ) 
   
 	return ( self.LifeTime > CurTime() )  
 	 
 end 
 
 function EFFECT:Render() 
 end  