EFFECT.ent = nil
EFFECT.ent2 = nil
local matRefraction	= Material( "refract_ring" )
--util.PrecacheModel("effects/strider_pinch_dudv")

local increment = 256
local deincrement = (increment/4)*3 --3/4

function EFFECT:Init(data)
	self.ent = data:GetEntity()
	--[[local lol = ents.Create("prop_physics")
	lol:SetModel("models/Effects/portalrift.mdl")
	lol:SetMaterial("models/Effects/portalrift.mdl")
	lol:SetPos(self.ent:GetPos())
	self.ent2 = lol]]
	self.refract = .5
	self.RingRad = 0
	self.vel = 0
	self.contract = false
end

function EFFECT:Slow()
	local ftime = FrameTime()
	local delta = 0
	if self.contract then
		delta = math.Clamp(self.vel-deincrement, -512, -128)/2
	else
		delta = math.Clamp(self.vel+deincrement, 128, 512)/2
	end
	self.RingRad = self.RingRad+delta*ftime
end

function EFFECT:Fast()
	local ftime = FrameTime()
	local delta = 0
	if self.contract then
		delta = (self.vel-increment)*2
	else
		delta = (self.vel+increment)*2
	end
	self.RingRad = self.RingRad+delta*ftime
end

function EFFECT:Think()
	if not self.ent:IsValid() then
		--self.ent2:Remove()
		return false
	else
		self:SetPos(self.ent:GetPos())
		if self.RingRad < 4000 then
			self:Fast()
		else
			self:Slow()
		end
		--[[self.ent2:SetPos(self.ent:GetPos()+((self.ent2:GetPos()-LocalPlayer():GetPos()):Normalize()*-128))--pop it towards the player
		self.ent2:SetAngles(((self.ent2:GetPos()-LocalPlayer():GetPos())):Angle()+Angle(90,0,0))]]
		return true
	end
end

function EFFECT:Render()
	if (self.RingRad > 5024) and (not self.contract) then
		self.contract = true
	elseif (self.RingRad < 3004) and self.contract then
		self.contract = false
	end
	local tmp = math.abs(self.RingRad)
	matRefraction:SetFloat("$refractamount", .1)
	render.SetMaterial(matRefraction)
	render.UpdateRefractTexture()
	render.DrawSprite(self.ent:GetPos(),tmp,tmp)
end