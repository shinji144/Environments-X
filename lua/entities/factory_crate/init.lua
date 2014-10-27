AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

function ENT:Initialize()
 
	//self:SetModel( "models/props_junk/wood_crate001a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	
	self.Active=0
	self.Constructed = false

	if(NADMOD)then
		NADMOD.SetOwnerWorld(self)
	end
end
 
function ENT:Think()
	if(not self.Constructed)then return end
   local ent = ents.Create(self.product)
	ent:SetModel(self.productmodel)
	ent:SetPos( self.factory:LocalToWorld(Vector(0,0,60)) )
	ent:Spawn()

	NADMOD.PlayerMakePropOwner(self.LDEOwner,ent)
	ent.WasMade=true
	local phys = ent:GetPhysicsObject()
	
	self:Remove()
	
	return ent
end



 