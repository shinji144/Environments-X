
local matRefraction	= Material( "refract_ring" )

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.Orig  		= data:GetOrigin()
	self.Multi 		= data:GetMagnitude( )*10
	self.rad		= 128 * (self.Multi^0.325)
	
	self.Entity:SetRenderBoundsWS( self.Orig - Vector(self.rad, self.rad, self.rad), self.Orig + Vector(self.rad, self.rad, self.rad) )	
	
	self.emitter = ParticleEmitter(self.Orig) 	
	
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
		local bPos = Pos+self.Orig 
		local particle = self.emitter:Add("effects/blueflare1",self.Orig +Pos)
		if particle then
			particle:SetDieTime(0.2 * (self.Multi^0.25))
			particle:SetStartLength(0 * (self.Multi^0.325))
			particle:SetEndLength(200 * (self.Multi^0.325))
			particle:SetStartAlpha(50)
			particle:SetEndAlpha(255)
			particle:SetStartSize(1 * (self.Multi^0.325))
			particle:SetEndSize(16 * (self.Multi^0.325))
			particle:SetGravity(NORM((Pos + self.Orig ) - self.Orig)*(-1))
			particle:SetColor(math.random(150,255),math.random(150,255),255)
		end  
	end 	
	self.emitter:Finish()
	--return false 
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )
						 
end
