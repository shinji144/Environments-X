AddCSLuaFile( "gas_cloud.lua" )

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName			= "gas cloud"
ENT.Author			= "CmdrMatthew"

if(SERVER)then
	function ENT:Initialize()
		self:SetModel("models/Items/BoxSRounds.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		
		self:SetColor(Color(255,255,255,0))
		
		self:SetAmount(1)
		self.ResourceName = ""
	end

	function ENT:SetResource(res)
		self.ResourceName = res
	end

	function ENT:SetAmount(x)
		self.ResourceAmount = x
		self:SetNWInt("resourceamt", x)
	end

	function ENT:OnTakeDamage(dmg)
		self:SetHealth(self:Health() - dmg:GetDamage())
		if self:Health() < 1 then
			self:EmitSound("Weapon_Mortar.Impact")
			self:Remove()
		end
	end

	function ENT:Suck(amt)//dont forget to add effects
		if amt > self.ResourceAmount then
			amt = self.ResourceAmount
		end
		
		self:SetAmount(self.ResourceAmount - amt)
		return amt
	end

	function ENT:Think()
		if self.ResourceAmount < 1 then
			self:Remove()
		end
		self:NextThink(CurTime()+1)
		return true
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
else
	function ENT:Draw()            
		--self:DrawModel()
	end  

	function ENT:Initialize()
		local ed = EffectData()
		ed:SetEntity(self)
		util.Effect("gas_cloud", ed)
	end
end		
