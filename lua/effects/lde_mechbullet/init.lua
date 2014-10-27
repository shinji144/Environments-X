--Bullet effect testing
local Created = CurTime()
local LifeTime = 10

function EFFECT:Init(data)

	--self.Entity:SetModel(data:GetMaterial())
	self.Entity:SetModel("models/Items/AR2_Grenade.mdl")
	--self.Entity:SetAngles(data:GetAngles())
	self.Entity:SetPos(data:GetOrigin())
	--self.Entity:SetRenderMode( RENDERMODE_GLOW ) --RENDERMODE_TRANSALPHA

	Created = CurTime()
	LifeTime = 10.16
	
end

function EFFECT:Think()
	return (Created+LifeTime) > CurTime()
end

function EFFECT:Render()
	
end
