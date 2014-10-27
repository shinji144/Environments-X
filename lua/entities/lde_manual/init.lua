AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )

function ENT:Initialize()

self.Entity:SetModel( "models/Spacebuild/sbepmanual.mdl" )
self.Entity:PhysicsInit( SOLID_VPHYSICS )
self.Entity:SetMoveType( MOVETYPE_VPHYSICS )							
self.Entity:SetSolid( SOLID_VPHYSICS )
self.Entity:SetUseType( SIMPLE_USE )
self.Entity:SetPos( self.Entity:GetPos() + Vector( 0, 0, self.Entity:OBBMins().z ) )

local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Think()
end 

function ENT:AcceptInput( name, activator, caller )
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then

		umsg.Start("LDEOpenManual",caller)
		umsg.End()
		self.Player = caller;
		
	end
end