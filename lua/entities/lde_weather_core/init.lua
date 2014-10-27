AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create("lde_weather_core")
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false)
		phys:EnableCollisions(true)
	end
	self.Entity:SetColor(0,0,0,255)
	self.Dtime = 0
end

function ENT:Start(radius,death,effect,mag,planet)
	self.radius = radius
	self.active = true
	self.Dtime = CurTime()+death
	local e = EffectData()
	e:SetMagnitude(mag)
	e:SetEntity(self)
	e:SetOrigin(planet)
	e:SetRadius(radius/10)
	util.Effect(effect,e)
end

function ENT:Think()
	if self.Dtime < CurTime() then
		self:Remove()
	//	print("KILL ME")
	end
	self:NextThink(CurTime() + 1)
	return true
end