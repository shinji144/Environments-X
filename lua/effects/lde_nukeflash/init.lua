
local matRefraction	= Material( "refract_ring" )

local tMats = {}

tMats.Glow1 = CreateMaterial("glow1", "UnlitGeneric", {["$basetexture"] = "sprites/light_glow02", ["$spriterendermode"] = 9, ["$ignorez"] = 1, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})
tMats.Glow2 = CreateMaterial("glow2", "UnlitGeneric", {["$basetexture"] = "sprites/yellowflare", ["$spriterendermode"] = 9, ["$ignorez"] = 1, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})
tMats.Glow3 = CreateMaterial("glow3", "UnlitGeneric", {["$basetexture"] = "sprites/redglow2", ["$spriterendermode"] = 9, ["$ignorez"] = 1, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})

--[[for _,mat in pairs(tMats) do
	mat:SetInt("$spriterendermode",9)
	mat:SetInt("$ignorez",1)
	mat:SetInt("$illumfactor",8)
	mat:SetInt("$additive",1)
	mat:SetInt("$vertexcolor",1)
	mat:SetInt("$vertexalpha",1)
end]]--


function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()
	self.Position.z = self.Position.z + 4
	self.Yield = data:GetMagnitude()
	self.YieldFast = self.Yield^1.4
	self.YieldSlow = self.Yield^0.75
	self.YieldSlowest = self.Yield^0.5
	self.YieldInverse = self.Yield^-1
	self.TimeLeft = CurTime() + 24
	self.FAlpha = 255
	self.GAlpha = 254
	self.GSize = 100*self.YieldSlow
	self.CloudHeight = data:GetScale()
	
	self.Refract = 0
	self.Size = 24
	if render.GetDXLevel() <= 81 then
		matRefraction = Material( "effects/strider_pinch_dudv" )
	end
	
	local Pos = self.Position
	
	self.smokeparticles = {}
	self.Emitter = ParticleEmitter( Pos )
	if not self.Emitter then return end
end

--THINK
-- Returning false makes the entity die
function EFFECT:Think( )
		local timeleft = self.TimeLeft - CurTime()
		if timeleft > 0 then 
		local ftime = FrameTime()
		
		if self.FAlpha > 0 then
			self.FAlpha = self.FAlpha - 150*ftime
		end
		
		self.GAlpha = self.GAlpha - 10.5*ftime
		self.GSize = self.GSize - 0.12*timeleft*ftime*self.YieldSlow
		
		self.Size = self.Size + 1200*ftime
		self.Refract = self.Refract + 1.3*ftime
			
		return true
	else
		return false	
	end
end


-- Draw the effect
function EFFECT:Render()
local startpos = self.Position

--Base glow
render.SetMaterial(tMats.Glow1)
render.DrawSprite(startpos, 400*self.GSize,90*self.GSize,Color(255,240,220,self.GAlpha))
render.DrawSprite(startpos, 70*self.GSize,280*self.GSize,Color(255,240,220,0.7*self.GAlpha))

--blinding flash
if self.FAlpha > 0 then
	render.DrawSprite(startpos + Vector(0,0,256),50*(self.GSize^2),35*(self.GSize^2),Color(255,245,235,self.FAlpha))
end

--outer glow
render.SetMaterial(tMats.Glow2)
render.DrawSprite(startpos, 700*self.GSize,550*self.GSize,Color(255,50,10,self.GAlpha))

--glare
render.SetMaterial(tMats.Glow3)
render.DrawSprite(startpos, 56*self.GSize,600*self.GSize,Color(130,120,240,0.5*self.GAlpha))
render.DrawSprite(startpos, 700*self.GSize,70*self.GSize,Color(80,73,255,self.GAlpha))

end



