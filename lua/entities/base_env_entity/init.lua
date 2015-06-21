
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.IsLS = true

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetNetworkedInt( "OOO", 0 )
	self.Active = 0
	self.Multiplier = 1
	
	self.maxresources = {}
end
   
function ENT:SetActive( value, caller )
	if ((not(value == nil) and value != 0) or (value == nil)) and self.Active == 0 then
		if self.TurnOn then self:TurnOn( nil, caller ) end
	elseif ((not(value == nil) and value == 0) or (value == nil)) and self.Active == 1 then
		if self.TurnOff then self:TurnOff( nil, caller ) end
	end
end

function ENT:SetOOO(value)
	self:SetNetworkedInt( "OOO", value )
end

function ENT:GetSizeMultiplier()
	return self.SizeMultiplier or 1
end

function ENT:GetMultiplier()
	return self.Multiplier or 1
end

function ENT:SetSizeMultiplier(num)
	if num < 0.1 then num = 0.1 end
	self.SizeMultiplier = tonumber(num) or 1
end

function ENT:SetMultiplier(num)
	if num < 1 then num = 1 end
	self.Multiplier = tonumber(num) or 1
	self:SetNetworkedInt( "EnvMultiplier", self.Multiplier )
end

function ENT:Repair()
	self:SetHealth( self:GetMaxHealth())
	--self:SetColor(Color(255,255,255,255))
end

function ENT:AcceptInput(name,activator,caller)
	--if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
	--	self:SetActive( nil, caller )
	--end
	
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
		if(not self.PanelUser)then
			umsg.Start("EnvODMenu",caller)
				umsg.String(self:EntIndex( ))
				umsg.Entity(self.Entity);
			umsg.End()
			
			self.PanelUser = caller 
		end
	end
end

function ENT:OnRemove()
	if self.node and self.node:IsValid() then
		self.node:Unlink(self)
	end
	if WireLib then WireLib.Remove(self) end
end

function ENT:ConsumeResource( resource, amount)
	if self.node then
		return self.node:ConsumeResource(resource, amount)
	else
		return 0
	end
end

function ENT:SupplyResource(resource, amount)
	if self.node then
		return self.node:GenerateResource(resource, amount)
	end
end

function ENT:Link(ent, delay)
	if self.node then
		self.node:Unlink(self)
	end
	if ent and ent:IsValid() then
		self.node = ent
		
		if delay then
			local func = function() 
				umsg.Start("Env_SetNodeOnEnt")
					umsg.Short(self:EntIndex())
					umsg.Short(ent:EntIndex())
				umsg.End()
			end
			timer.Simple(0.1, func)
		else
			umsg.Start("Env_SetNodeOnEnt")
				umsg.Short(self:EntIndex())
				umsg.Short(ent:EntIndex())
			umsg.End()
		end
	end
end

function ENT:Unlink()
	if self.node then
		self.node:Unlink(self)
		self.node = nil
		umsg.Start("Env_SetNodeOnEnt")
			umsg.Short(self:EntIndex())
			umsg.Short(0)
		umsg.End()
	end
end

function ENT:GetResourceAmount(resource)
	if self.node then
		if self.node.resources and self.node.resources[resource] then
			return self.node.resources[resource].value
		else
			return 0
		end
	else
		return 0
	end
end

function ENT:GetUnitCapacity(resource)
	return self.maxresources[resource] or 0
end

function ENT:GetNetworkCapacity(resource)
	if self.node then
		return self.node.maxresources[resource] or 0
	end
	return 0
end

function ENT:GetStorageLeft(res)
	if self.node then
		if self.node.resources[res] then
			local max = self.node.maxresources[res]
			local cur = self.node.resources[res].value or 0
			if max then
				return max - cur
			end
		else
			local max = self.node.maxresources[res]
			if max then
				return max
			end
		end
	end
	return 0
end

ENT.GetSpaceLeft = ENT.GetStorageLeft

function ENT:OnRestore()
	if WireLib then WireLib.Restored(self) end
end

function ENT:PreEntityCopy()
	Environments.BuildDupeInfo(self)
	if self.EnvxOnDupe then
		local DI = self:EnvxOnDupe()
		if DI then
			duplicator.StoreEntityModifier( self, "EnvxDupeInfo", DI )
		end
	end
	if WireLib then
		local DupeInfo = WireLib.BuildDupeInfo(self)
		if DupeInfo then
			duplicator.StoreEntityModifier( self, "WireDupeInfo", DupeInfo )
		end
	end
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	Environments.ApplyDupeInfo(Ent, CreatedEntities, Player)
	
	if Ent.EntityMods and Ent.EntityMods.EnvxDupeInfo then
		if self.EnvxOnPaste then
			self:EnvxOnPaste(Player,Ent,CreatedEntities)
		end
	end
	
	if WireLib and (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
		WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end
