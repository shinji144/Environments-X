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
	{120,80,80,140},
	{120,0,200,140},
	{0,80,80,140},
	{0,0,200,140},	
	{255,255,255,140}
	}
end

function EFFECT:emit()
	local X = self.ang:Right()
	local Y = self.ang:Up()
	local Z = self.ang:Forward()
	--for i=1,2 do
		local ang = math.random()*pi*2
		local pos = (math.cos(ang)*X*10)+(math.sin(ang)*Y*10)+10*Z
		local particle = self.emtr:Add("effects/combinemuzzle2",self.pos + pos)
		if particle then
			local Col = self.Colors[self.Rand]
			particle:SetColor(Col[1],Col[2],Col[3],Col[4])
			particle:SetVelocity(-(pos*-0.8)+Z*500)
			particle:SetLifeTime(0)
			particle:SetDieTime(1.7)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(5)
			particle:SetEndSize(60)
			//particle:SetGravity(Z*-60)
		end
	--end
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