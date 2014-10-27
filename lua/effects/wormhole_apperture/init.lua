EFFECT.emtr = nil
EFFECT.ent = nil
local pi = math.pi
function EFFECT:Init(data)
	self.ent = data:GetEntity()
	self.ang = self.ent:GetAngles()
	self.pos = self.ent:GetPos()
	self.emtr = ParticleEmitter(self.pos)
end

function EFFECT:emit()
	local X = self.ang:Right()
	local Y = self.ang:Up()
	local Z = self.ang:Forward()
	local times = 6
	if math.random(1,20) < 3 then --ring
		times = 60
	end
	for i=1,times do
		local ang = math.random()*pi*2
		local pos = (math.cos(ang)*X*250)+(math.sin(ang)*Y*250)+100*Z
		local particle = self.emtr:Add("effects/combinemuzzle2",self.ent:GetPos()+ pos)
		if particle then
			particle:SetColor(math.random(150,255),0,math.random(150,255),255)
			particle:SetVelocity(pos*-0.4+Z*70)
			particle:SetLifeTime(0)
			particle:SetDieTime(2.5)
			particle:SetStartAlpha(0)
			particle:SetEndAlpha(255)
			particle:SetStartSize(4)
			particle:SetEndSize(0.1)
			particle:SetGravity(Z*-60)
		end
	end
end

function EFFECT:Think()
	if not self.ent:IsValid() then
		self.emtr:Finish()
		return false
	else
		self.ang = self.ent:GetAngles()
		self.pos = self.ent:GetPos()
		self:emit()
		return true
	end
end

function EFFECT:Render()
end