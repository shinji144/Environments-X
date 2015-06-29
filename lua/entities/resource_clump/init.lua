AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	
	self.Active=0
	self.Resources = {}
	self:CPPISetOwnerless(true)
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end
end
 
function ENT:Think()

end

 function ENT:Touch(activator)
	if(activator:IsWorld())then return end
	local ActClass = activator:GetClass()
	if( ActClass == "generator_scrap_collect" or ActClass=="lde_basecore")then
		for k,e in pairs(self.Resources) do
			if(e.amount>0)then
				if(activator.SupplyResource)then
					activator:SupplyResource(e.name,e.amount)
				else
					activator:GenerateResource(e.name,e.amount)
				end
				e.amount=0 -- So we cant give more then we were given
			end
		end
		self:Remove()
	end
end