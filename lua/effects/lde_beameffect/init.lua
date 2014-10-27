/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )
	self.StartPos 	= data:GetStart()	
	self.EndPos 	= data:GetOrigin()
	self.Ent	 	= data:GetEntity()
	self.BeamType	= data:GetColor()
	self.Mag		= data:GetMagnitude()
	
	if (!self.Ent:IsValid()) then return false end
	
	self.Dir 		= self.EndPos - self.StartPos
	self.LocalStartPos   = self.Ent:WorldToLocal(self.StartPos)
	self.LocalEndPos = self.Ent:WorldToLocal(self.EndPos)
	
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	// Die when it reaches its target
	self.DieTime = CurTime() + self.Mag or 1
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )

	if(not self or not self.DieTime)then return false end
	if ( CurTime() > self.DieTime ) then
		return false 
	end
	
	return true

end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )
	local Pos = self.StartPos
	local EPos = self.EndPos
	if (self.Ent:IsValid()) then
		Pos = self.Ent:LocalToWorld(self.LocalStartPos)
		EPos = self.Ent:LocalToWorld(self.LocalEndPos)
	end
	
	render.SetMaterial( Material("cable/redlaser") )
	render.DrawBeam( Pos, EPos, 20, 1, 10,Color(255,255,255,255))		
	--render.DrawLine(Pos,EPos,Color(255,255,255,255),false)
	
end
