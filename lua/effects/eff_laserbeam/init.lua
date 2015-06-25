EFFECT.Mat1 = Material( "cable/redlaser" )

function EFFECT:Init( data )
	self.StartPos 	= data:GetStart()	
	self.EndPos 	= data:GetOrigin()

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )
	self.DieTime = CurTime() + 0.1
end

function EFFECT:Think( )

	if ( CurTime() > self.DieTime ) then
		return false 
	end
	
	return true

end

function EFFECT:Render( )
	local Pos = self.StartPos
	local EPos = self.EndPos

	render.SetMaterial( self.Mat1 )
	render.DrawBeam(Pos,EPos,20,0,0,Color( 255, 255, 255, 255 ))
end
