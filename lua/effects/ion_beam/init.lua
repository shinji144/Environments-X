local bMats = {}
bMats.Glow1 = Material("effects/blueflare1")

bMats.Glow2 = Material("effects/blueflare1")

local lMats = {}
lMats.Glow1 = Material("effects/blueflare1")

lMats.Glow2 = Material("effects/blueflare1")

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.StartPos 	= data:GetStart()	
	self.EndPos 	= data:GetOrigin()
	self.Multi 		= data:GetMagnitude( )
	self.rad 		= 16
	self.MultiBeam	= data:GetScale()
	self.BeamColor	= data:GetColor() or 1
	
	self:SetRenderBoundsWS( self.StartPos, self.EndPos ) 	
	
	self.DieTime = CurTime()+ 0.01
	self:SetPos(self.EndPos)
	
	
	self:Render()
	
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
    	
	if(not self or not self.DieTime)then return false end
	if ( CurTime() > self.DieTime ) then
		return false 
	end
	
	return false

end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )
	local Colors = Color( 255, 255, 255, 255 )
	
	if(self.BeamColor>1)then Colors = Color( 255, 0, 0, 255 ) end
	
	render.SetMaterial( Material(  "effects/blueblacklargebeam"  ) )
   	render.DrawBeam( self.StartPos, self.EndPos, (150*self.Multi), 0, 0, Colors )
	
   	render.SetMaterial( bMats.Glow2 )
	local scale =  (800*self.Multi)
   	render.DrawSprite(self.StartPos, scale,scale, Colors) 
   	
	render.SetMaterial( lMats.Glow1 )		
   	render.DrawBeam( self.EndPos, self.StartPos, 128+(80*self.Multi), (1)*((2*CurTime())-(0.005*self.MultiBeam)), (1)*(2*CurTime()), Colors )
   	
	render.SetMaterial( lMats.Glow2 )	
   	render.DrawBeam( self.EndPos, self.StartPos, 96+(80*self.Multi), (1)*((2*CurTime())-(0.001*self.MultiBeam)), (1)*(2*CurTime()), Colors )
   	
	return false
					 
end
