local matRefraction	= Material( "refract_ring" )

function EFFECT:Init(data)
	self.vec = data:GetNormal()
	self.Position = data:GetOrigin()
	self.time = CurTime() + 30
	self.refract = .5
	self.RingRad = 0
	if render.GetDXLevel() <= 81 then
		matRefraction = Material( "effects/strider_pinch_dudv" )
	end
end

function EFFECT:Think()
	if (self.time-CurTime()) > 0 then 
		local ftime = 0
		self.RingRad = self.RingRad+2e4*FrameTime()
		self.refract = self.refract-0.06*FrameTime()
		return true
	else
		return false	
	end
end

function EFFECT:Render()
	if self.RingRad < 32768 then
		matRefraction:SetFloat("$refractamount", math.sin( self.refract * math.pi )*0.2)
		render.SetMaterial(matRefraction)
		render.UpdateRefractTexture()
		render.DrawQuadEasy(self.Position,self.vec,self.RingRad, self.RingRad)
	end
end



