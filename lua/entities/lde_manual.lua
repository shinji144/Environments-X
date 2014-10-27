AddCSLuaFile( "lde_manual.lua" )

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName	= "Environments Manual"
ENT.Author		= "Ludsoe"
ENT.Contact		= ""
ENT.Information	= "The Help Book!"
ENT.Category	= "Environments"

ENT.Spawnable = true
ENT.AdminSpawnable = true

if(SERVER)then
	function ENT:Initialize()
		self:SetModel( "models/Spacebuild/sbepmanual.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )							
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		self:SetPos( self:GetPos() + Vector( 0, 0, self:OBBMins().z ) )

		local phys = self:GetPhysicsObject()
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
else
	function ENT:Draw()	
	   self:DrawModel() 					
	end
	   
	local function OpenMenu( um )
		SBEPDoc.OpenManual()
	end
	usermessage.Hook("OpenSBEPManual", OpenMenu )
end		
