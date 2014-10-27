local matRefraction	= Material( "refract_ring" )

local function NORM(Vec)
	local Length = Vec:Length()
	return Vec/Length
end

function EFFECT:Init(data)
	self.vec = NORM(data:GetNormal())
	self.Position = data:GetOrigin()
	self.time = CurTime() + 0.1
	self.refract = .5
	self.RingRad = 0
	if render.GetDXLevel() <= 81 then
		matRefraction = Material( "effects/strider_pinch_dudv" )
	end
end

function EFFECT:Think()
	if (self.time-CurTime()) > 0 then 
		local ftime = 0
		self.RingRad = 500+math.random(0,100)
		self.refract = self.refract-0.06*FrameTime()
		return true
	else
		return false	
	end
end

function EFFECT:Render()
	if self.RingRad < 5000 then
		matRefraction:SetFloat("$refractamount", math.sin( self.refract * math.pi )*0.2)
		render.SetMaterial(matRefraction)
		render.UpdateRefractTexture()
		render.DrawQuadEasy(self.Position,self.vec,self.RingRad, self.RingRad)
	end
end



