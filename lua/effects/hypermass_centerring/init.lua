EFFECT.pos = nil
EFFECT.ang = Angle(270, 180, 180)
EFFECT.emtr = nil
EFFECT.ent = nil
local pi = 3.141593 --incase pi changes lol

function EFFECT:Init(data)
	self.ent = data:GetEntity()
	self.pos = self.ent:GetPos()
	self.emtr = ParticleEmitter(self.pos)
	self.Rand = data:GetScale()
	self.Colors = {
	{200,80,80,200},
	{120,0,200,200},
	{0,150,80,200},
	{0,0,200,200}	
	}
end

function EFFECT:emit()
	local X = self.ang:Right()
	local Y = self.ang:Up()
	for i=1,3 do
		local ang = math.random()*pi*2
		local pos = (math.cos(ang)*X*800)+(math.sin(ang)*Y*800)
		local particle = self.emtr:Add("effects/combinemuzzle2",self.pos + pos)
		if particle then
			local Col = self.Colors[self.Rand]
			particle:SetColor(Col[1],Col[2],Col[3],Col[4])
			particle:SetVelocity(pos*-0.7)
			particle:SetLifeTime(0)
			particle:SetDieTime(1.5)
			particle:SetStartAlpha(0)
			particle:SetEndAlpha(255)
			particle:SetStartSize(80)
			particle:SetEndSize(3)
		end
	end
end

function EFFECT:Think()
	if not self.ent:IsValid() then
		self.emtr:Finish()
		return false
	else
		self.pos = self.ent:GetPos()
		self:emit()
		return true
	end
end

function EFFECT:Render()
end