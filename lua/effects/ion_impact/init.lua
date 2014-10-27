local bMats = {}
bMats.Glow1 =  Material("effects/blueflare1")

bMats.Glow2 =  Material("effects/blueflare1")

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.StartPos 	= data:GetStart()	
	self.EndPos 	= data:GetOrigin()
	self.Multi 		= data:GetMagnitude( )*10
	self.rad 		= 16
	self.MultiBeam	= data:GetScale()
	
	self.emitter = ParticleEmitter(self.EndPos)  	
	
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
local function NORM(Vec)
	local Length = Vec:Length()
	return Vec/Length
end

function EFFECT:Think( )
    for i=0,2 do
		local a = math.random(9999)
		local b = math.random(1,180)
		local X = math.sin(b)*math.sin(a)*self.rad
		local Y = math.sin(b)*math.cos(a)*self.rad
		local Z = math.cos(b)*self.rad
		local Pos = Vector(X,Y,Z)
		local bPos = Pos+self.EndPos
		if(not self.emitter)then return false end
		local particle = self.emitter:Add("effects/blueflare1",self.EndPos+Pos)
		if particle then
			particle:SetDieTime(0.2 * (self.Multi^0.2))
			particle:SetStartLength(0)
			particle:SetEndLength(250 * (self.Multi^0.325))
			particle:SetStartAlpha(255 * (self.Multi^0.325))
			particle:SetEndAlpha(0)
			particle:SetStartSize(32 * (self.Multi^0.325))
			particle:SetEndSize(8 * (self.Multi^0.325))
			particle:SetGravity(NORM((Pos+self.EndPos)-self.EndPos))
			particle:SetColor(math.random(200,255),math.random(200,255),255)
		end  
	end 	
	self.emitter:Finish()
	return false 
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( ) 
	   	
   	local scale =  (50*self.Multi)
   	render.SetMaterial(	bMats.Glow1 )
   	render.DrawSprite(self.EndPos, scale,scale, Color(255, 255, 255, 255))
   	
	return false
					 
end
