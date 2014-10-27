AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


function ENT:Initialize()		
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )   
    self:SetSolid( SOLID_VPHYSICS )
	
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	if(NADMOD)then
		NADMOD.SetOwnerWorld(self)
	end
end
 	
--[[
function ENT:PhysicsCollide( data, physobj )	
	-- sound
	math.randomseed( math.random() )
	local rand = math.random(1,5)
	local sound = "physics/flesh/flesh_squishy_impact_hard1.wav"
	
	if rand >= 1 and rand <= 4 then
		sound = "physics/flesh/flesh_squishy_impact_hard"..math.random(1,4)..".wav"
	elseif rand == 5 then
		sound = "physics/flesh/flesh_bloody_break.wav"
	end
	
	self:EmitSound( sound, 100, math.Clamp( math.Clamp( (self:BoundingRadius() * 10), 1, 5000 ) * -1 + 255 + math.random(-5, 5), 50, 255 )  )
	
	-- blood spurt
	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
	util.Effect( "BloodImpact", effectdata )
	
	-- decal
	local tr = util.TraceLine{ start = self:GetPos(),
								endpos = physobj:GetPos() + self:GetPhysicsObject():GetVelocity(),
								filter = self.Entity }
	util.Decal( "Blood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal )
end
]]

function ENT:Think()

end