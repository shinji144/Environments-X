
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.NoSpaceAfterEndTouch = true

ENT.IsNode = true


function ENT:Initialize()
	//self.BaseClass.Initialize(self) --use this in all ents
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	//rd table
	self.resources = {}
	self.connected = {}
	self.maxresources = {}
	
	self:Think()
end

function ENT:TriggerInput(iname, value)
	
end

function ENT:Link(ent, delay)
	if ent == self then return end
	
	self.connected[ent:EntIndex()] = ent
	if ent.maxresources then
		for name,max in pairs(ent.maxresources) do
			local curmax = self.maxresources[name]
			if curmax then
				self.maxresources[name] = curmax + max
			else
				self.maxresources[name] = max
			end
			if delay then
				timer.Simple(0.1, function()
					umsg.Start("Env_UpdateMaxRes")
						umsg.Short(self:EntIndex())
						umsg.String(name)
						umsg.Long(self.maxresources[name])
					umsg.End()
				end)
			else
				umsg.Start("Env_UpdateMaxRes")
					umsg.Short(self:EntIndex())
					umsg.String(name)
					umsg.Long(self.maxresources[name])
				umsg.End()
			end
		end
	end
	if ent.resources then
		for name,amt in pairs(ent.resources) do
			local curmax = self.maxresources[name]
			if self.resources[name] then
				local cur = self.resources[name].value
				if cur and (cur + amt) <= curmax then
					self.resources[name].value = cur + amt
				elseif cur then
					self.resources[name].value = curmax
				end
			else
				self.resources[name] = {}
				self.resources[name].value = amt
			end
			self.resources[name].haschanged = true
		end
	end
end

function ENT:Unlink(ent)
	if ent then
		self.connected[ent:EntIndex()] = nil
		if ent.maxresources then
			for name,max in pairs(ent.maxresources) do
				local curmax = self.maxresources[name]
				if curmax then
					self.maxresources[name] = curmax - max
					if self.resources[name] then
						self.resources[name].haschanged = true
					end
					umsg.Start("Env_UpdateMaxRes")
						umsg.Short(self:EntIndex())
						umsg.String(name)
						umsg.Long(self.maxresources[name])
					umsg.End()
				end
				
			end
		end
	end
end

function ENT:Repair()
	self:SetHealth( self:GetMaxHealth())
	self:SetColor(Color(255,255,255,255))
end

function ENT:LinkCheck()
	local curpos = self:GetPos()
	for k,v in pairs(self.connected) do
		if v and v:IsValid() then
			if v:GetPos():Distance(curpos) > 2048 then
				v:Unlink()
				self:EmitSound( Sound( "weapons/stunstick/spark" .. tostring( math.random( 1, 3 ) ) .. ".wav" ) )
				v:EmitSound( Sound( "weapons/stunstick/spark" .. tostring( math.random( 1, 3 ) ) .. ".wav" ) )
			end
		else
			self.connected[k] = nil
		end
	end
end

function ENT:Think()
	self:LinkCheck()
	
	self:NextThink(CurTime() + 5)
	return true
end

function ENT:DoUpdate(res1, res2, ply) --todo make cheaper
	if res1 then
		for k,name in pairs(res1) do
			local v = self.resources[name]
			if v and v.haschanged then
				umsg.Start("Env_UpdateResAmt")
					//umsg.Entity(self)
					umsg.Short(self:EntIndex())
					local old = name
					name = Environments.Resources[name] or name
						--print("Sending "..old.." as "..name)
					umsg.String(name)
					umsg.Long(v.value)
				umsg.End()
				v.haschanged = false
			end
		end
	end
	
	if !res2 then return end
	for k,name in pairs(res2) do
		local v = self.resources[name]
		if v and v.haschanged then
			umsg.Start("Env_UpdateResAmt")
				//umsg.Entity(self)
				umsg.Short(self:EntIndex())
				local old = name
				name = Environments.Resources[name] or name
					--print("Sending "..old.." as "..name)
				umsg.String(name)
				umsg.Long(v.value)
			umsg.End()
			v.haschanged = false
		end
	end
end

function ENT:GenerateResource(name, amt)
	amt = math.Round(amt) -- :(
	
	local max = self.maxresources[name]
	if not max then return 0 end
	if self.resources[name] then
		local res = self.resources[name].value
		if res + amt < max then
			self.resources[name].value = self.resources[name].value + amt
			self.resources[name].haschanged = true
			return 0//amt
		else
			self.resources[name].value = max
			self.resources[name].haschanged = true
			return amt - (max - res)
		end
	else
		self.resources[name] = {}
		self.resources[name].value = amt
		self.resources[name].haschanged = true
		return 0//amt
	end
	return amt
end

function ENT:ConsumeResource(name, amt)
	amt = math.Round(amt) -- :(
	if self.resources[name] then
		local res = self.resources[name].value
		if res >= amt then
			self.resources[name].value = res - amt
			self.resources[name].haschanged = true
			return amt
		elseif res != 0 then
			res = self.resources[name].value
			self.resources[name].value = 0
			self.resources[name].haschanged = true
			return res
		else
			return 0
		end
	else
		return 0
	end
end

function ENT:OnTakeDamage(DmgInfo)//should make the damage go to the shield if the shield is installed(CDS)
	if self.Shield then
		self.Shield:ShieldDamage(DmgInfo:GetDamage())
		CDS_ShieldImpact(self:GetPos())
		return
	end
	Environments.DamageLS(self, DmgInfo:GetDamage())
end

function ENT:OnRemove()	
	if self.connected then
		for k,v in pairs(self.connected) do
			if v and v:IsValid() then
				v:Unlink()
			end
		end
	end
	if WireAddon then Wire_Remove(self) end
end

function ENT:GetResourceAmount(resource)
	if self.resources[resource] then
		return self.resources[resource].value
	end
	return 0
end

function ENT:OnRestore()
	//self.BaseClass.OnRestore(self) --use this if you have to use OnRestore
	if WireAddon then Wire_Restored(self) end
end

function ENT:PreEntityCopy()
	//self.BaseClass.PreEntityCopy(self) --use this if you have to use PreEntityCopy
	Environments.BuildDupeInfo(self)
	if WireAddon then
		local DupeInfo = WireLib.BuildDupeInfo(self)
		if DupeInfo then
			duplicator.StoreEntityModifier( self, "WireDupeInfo", DupeInfo )
		end
	end
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	//self.BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities ) --use this if you have to use PostEntityPaste
	Environments.ApplyDupeInfo(Ent, CreatedEntities)
	if WireAddon and Ent.EntityMods and Ent.EntityMods.WireDupeInfo then
		WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end
