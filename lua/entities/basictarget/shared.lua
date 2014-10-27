ENT.Type 			= "anim"
ENT.Base 			= "base_env_entity"
ENT.PrintName		= "TargetEntity"
ENT.Author			= "Ludsoe"
ENT.Category		= "Other"

ENT.Spawnable		= false
ENT.AdminSpawnable	= true
ENT.Owner			= nil
ENT.SPL				= nil


function ENT:SetupShip(Name,BaseData)
	local Data = table.Copy(BaseData)--Create a local copy of it.
	self.PrintName=Name
	self.Data=Data
	self.Weapons = Data.Weapons
	--self.LDEHealth = Data.Hull
	--self.LDE={Core=Self,CoreShield=Data.Shields,Data=BaseData.Shields,CoreHealth=Data.Hull,CoreMaxHealth=Data.Hull}
	self.LDE["CoreShield"]=Data.Shields
	self.LDE["CoreMaxShield"]=BaseData.Shields
	self.LDE["CoreHealth"]=Data.Hull
	self.LDE["CoreMaxHealth"]=Data.Hull
	self.Data.ArmorRate = 1
	if(SERVER)then
		self:SetModel( BaseData.Model )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
			phys:EnableMotion(true)
			phys:EnableGravity(false)
		end
	else
		--Clientside shits
	end
end
