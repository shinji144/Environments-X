AddCSLuaFile( "dummyent.lua" )

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Dummyent"
ENT.Author			= "Ludsoe"
ENT.Category		= "Other"

ENT.Spawnable		= false
ENT.AdminSpawnable	= true
ENT.Owner			= nil
ENT.SPL				= nil
ENT.IsDummyEnd 		= true

if(SERVER)then
	ENT.LDEC =1
	 
	function ENT:Initialize()
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )
		self:DrawShadow(false)
		self:SetNotSolid( true )
	end

	function ENT:GravGunPunt()
		return false
	end

	function ENT:GravGunPickupAllowed()
		return false
	end
else
	ENT.RenderGroup = RENDERGROUP_OPAQUE

	function ENT:Draw()
		self.Entity:DrawModel()
	end
end		
