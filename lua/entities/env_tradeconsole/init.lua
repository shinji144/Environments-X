AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--sound effects!


util.PrecacheSound( "k_lab.teleport_malfunction_sound" )
util.PrecacheSound( "k_lab.teleport_discharge" )
util.PrecacheSound( "WeaponDissolve.Beam" )
util.PrecacheSound( "WeaponDissolve.Dissolve" )
 
include('shared.lua')


function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("env_tradeconsole")
	ent:SetPos( tr.HitPos + Vector(0, 0, 10))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()			
	return ent

end
 
function ENT:Initialize()
 		
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
		
	self.Active = 0
	
	------------------------
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end	
    
end

function ENT:TriggerInput(iname, value)  

end

function ENT:AcceptInput( name, activator, caller )
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then

		umsg.Start("envmarketTrigger",caller)
		umsg.String(self:GetCreationID())
		umsg.Entity(self.Entity);
		umsg.End()
		self.Player = caller;
		
	end
end

function ENT:HasNeeded(List)
	for I,b in pairs(List.materials) do  
		if(self:GetResourceAmount(b)<List.matamount[I])then 
			return false
		end
	end
	return true
end

function ENT:UseNeeded(List)
	for I,b in pairs(List.materials) do
		self:ConsumeResource(b, List.matamount[I])
	end
end


 