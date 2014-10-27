AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )
ENT.LDEC =1

--[[
function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("effectspawner")
	ent:SetPos( tr.HitPos + Vector(0, 0, 60))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()			
	return ent

end]]

function ENT:Initialize()

	self.Entity:SetModel( "models/ce_ls3additional/water_pump/water_pump.mdl" )
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false)
	end
	self:Effect()
end

function ENT:Effect()
	local effectdata = EffectData()
	effectdata:SetScale(5)
	effectdata:SetEntity(self)
	util.Effect( "basebuildeffect", effectdata )
	timer.Simple(5.1, function() if(self:IsValid())then self:Effect() end end)
end

function ENT:CanTool()
	return false
end

function ENT:GravGunPunt()
	return false
end

function ENT:GravGunPickupAllowed()
	return false
end

