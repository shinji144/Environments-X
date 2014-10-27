EFFECT.pos = nil
EFFECT.emtr = nil
EFFECT.ent = nil

function EFFECT:Init(data)
	self.ent = data:GetEntity()
	self.Ion = data:GetMagnitude()
	self.pos = self.ent:GetPos()
	self.emtr = ParticleEmitter(self.pos)
	self.CloudColor = {Red=100+math.random(0,155),Green=100+math.random(0,155),Blue=100+math.random(0,155)}
end

function EFFECT:emit(pos)
	local particle = self.emtr:Add( "particles/smokey", self.pos+pos)
	if particle then
		particle:SetDieTime(10)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(150)
		particle:SetStartSize(512)
		particle:SetEndSize(512)
		particle:SetRoll(math.Rand(-4,4))
		particle:SetRollDelta(math.Rand(-1,1))
		if self.Ion > 0 then
			if math.random(1,5) == 1 then
				if math.random(1,3) == 1 then
					particle:SetColor(0, 255, 0)
				else
					particle:SetColor(255, 0, 0)
				end
			else
				particle:SetColor(0, 0, 255)
			end
		else
			particle:SetColor(self.CloudColor.Red+math.random(-10,10), self.CloudColor.Green+math.random(-10,10), self.CloudColor.Blue+math.random(-10,10))
		end
	end
end

function EFFECT:Think()
	if not self.ent:IsValid() then
		self.emtr:Finish()
		return false
	else
		for I=1,3 do
			self.pos = self.ent:GetPos()
			local a = math.random(9999)
			local b = math.random(1,180)
			local dist = math.random(1,3048)
			local X = math.sin(b)*math.sin(a)*dist
			local Y = math.sin(b)*math.cos(a)*dist
			local Z = math.cos(b)*dist
			self:emit(Vector(X,Y,Z))
		end
		return true
	end
end

function EFFECT:Render()
end
