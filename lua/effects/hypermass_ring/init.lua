EFFECT.pos = nil
EFFECT.ang = nil --to be set by effect
EFFECT.emtr = nil
EFFECT.ent = nil
local pi = 3.141593 --incase pi changes lol

function EFFECT:Init(data)
	if data:GetMagnitude() > 0 then
		self.ang = Angle(270, 180, 180)
	else
		self.ang = Angle(90, 180, 180)
	end
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
	local Z = self.ang:Forward()
	for i=1,5 do
		local ang = math.random()*pi*2
		local pos = (math.cos(ang)*X*500)+(math.sin(ang)*Y*500)+160*Z
		local particle = self.emtr:Add("effects/combinemuzzle2",self.pos + pos)
		if particle then
			//particle:SetColor(math.random(1,255),math.random(1,255),math.random(1,255),255)
			local Col = self.Colors[self.Rand]
			particle:SetColor(Col[1],Col[2],Col[3],Col[4])
			particle:SetVelocity(pos*-0.4+Z*70)
			particle:SetLifeTime(0)
			particle:SetDieTime(2.5)
			particle:SetStartAlpha(0)
			particle:SetEndAlpha(255)
			particle:SetStartSize(20)
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
		self.pos = self.ent:GetPos()
		self:emit()
		return true
	end
end

function EFFECT:Render()
end