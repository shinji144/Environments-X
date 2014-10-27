AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )
ENT.LDEC =1
ENT.LinkX = 0
ENT.ModBaseCore = true
util.AddNetworkString('base_pylons')

function ENT:Initialize()
	//self.BaseClass.Initialize(self) --use this in all ents
	timer.Simple(0.1,function()
		if(self.LDEOwner.Base and self.LDEOwner.Base:IsValid())then
			self:Remove()
			print("Player already owns a base!!!")
		else
			self.LDEOwner.Base = self
			print("Im now the owners base!! :)")
		end
	end)
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	//rd table
	self.resources = {}
	self.connected = {}
	self.maxresources = {}
	self:AddStorage("Power",50000)
	self:AddStorage("Refined Mass",50000)
	self:AddStorage("Scrap",100000)
	self.node = self
	
	timer.Simple(0.1,function()
		self:GenerateResource("Power",50000)
		self:GenerateResource("Refined Mass",20000)
		self:GenerateResource("Scrap",500)
	end)
	
	self.Targets = {}
	self.Pylons = {}
	self.CoreLinked={}
	self.Incoming = 3
	
	self.LDE = {Wave=1,NextAttack=0,WaveInProgress=0,CoreHealth=200000,CoreMaxHealth=200000,CoreShield=20000,CoreMaxShield=20000,CoreTemp=0,CoreMinTemp=-300,CoreMaxTemp=500,Core=self}
	self.Data={BaseShield=20000,ArmorRate=1}
	self:SetNWInt("LDETechLevel",1)
	self:Think()
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

function ENT:LinkConstrained()
	-- Get all constrained props
	local Props = constraint.GetAllWeldedEntities(self)

	for _, ent in pairs( Props ) do
		if (ent and LDE:CheckValid( ent ) )then
			if (!ent.LDE) then ent.LDE = {} end
			
			LDE.HeatSim.SetTemperture(ent,0)
			
			if string.find(ent:GetClass(),"spore") then 
				continue
				--health,enthealth,entshield,entpoints=0,0,0,0  --Spores dont get any treatment
			else
				if (!entcore or !entcore:IsValid()) then -- if the entity has no core
					ent.LDE.Core = self
					ent.Shield = self --Environments Damage Override Compatability
					self:CoreLink(ent) --Link it to our core :)
				end
			end
		end
	end
end

function ENT:CoreLink(Entity)
	Entity.LDE=Entity.LDE or {}
	if(Entity.LDE.Core and not Entity.LDE.Core == self)then
		Entity.LDE.Core:CoreUnLink(Entity)
	end
	if(Entity:GetClass()=="base_shieldrecharge")then
		local IsLinked = false
		for key, ent in pairs( self.Pylons ) do
			if(ent==Entity)then
				IsLinked = true
			end
		end
		if(not IsLinked)then
			self.Pylons[table.Count(self.Pylons)+1]=Entity
			Entity.IsPylon=true
			net.Start('base_pylons')
				net.WriteEntity(self)
				net.WriteEntity(Entity)
			net.Broadcast()
		end
	end
	self.CoreLinked[Entity:EntIndex()]=Entity
	Entity.LDE.Core = self
end

function ENT:CoreUnLink( Entity )
	for key, ent in pairs( self.CoreLinked ) do
		if (Entity == ent) then
			table.remove( self.CoreLinked, key )
			Entity.LDE.Core = nil
			return --Stop the loop there.
		end
	end
end

function ENT:AddStorage(Resource,Amount)
	local curmax = self.maxresources[Resource]
	if curmax then
		self.maxresources[Resource] = curmax + Amount
	else
		self.maxresources[Resource] = Amount
	end
	if delay then
		timer.Simple(0.1, function()
			umsg.Start("Env_UpdateMaxRes")
				umsg.Short(self:EntIndex())
				umsg.String(Resource)
				umsg.Long(self.maxresources[Resource])
			umsg.End()
		end)
	else
		umsg.Start("Env_UpdateMaxRes")
			umsg.Short(self:EntIndex())
			umsg.String(Resource)
			umsg.Long(self.maxresources[Resource])
		umsg.End()
	end
end

function ENT:HasNeededResources(List)
	for I,b in pairs(List) do  
		if(self:GetResourceAmount(I)<b)then
			return false
		end
	end
	return true
end

function ENT:UseResources(List)
	for I,b in pairs(List) do
		self:ConsumeResource(I,b)
	end
end

function ENT:MakeResources(List)
	for I,b in pairs(List) do
		self:GenerateResource(I,b)
	end
end
		
function ENT:GenerateResource(name, amt)
	amt = math.Round(amt) -- :(
	--print("Gening Resources!")
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
		--print("MadeResources")
		return 0//amt
	end
	return amt
end

function ENT:Link(ent, delay)
	if ent == self then return end
	
	self.connected[ent:EntIndex()] = ent
	self.CoreLinked[ent:EntIndex()]=ent
	
	self:CoreLink(ent)
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
			ent.LDE.Core = nil
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

function ENT:SetMultiplier()
	return
end

function ENT:LinkCheck()
	local curpos = self:GetPos()
	for k,v in pairs(self.connected) do
		if v and v:IsValid() then
			if v:GetPos():Distance(curpos) > 20000 then
				v:Unlink()
				self:EmitSound( Sound( "weapons/stunstick/spark" .. tostring( math.random( 1, 3 ) ) .. ".wav" ) )
				v:EmitSound( Sound( "weapons/stunstick/spark" .. tostring( math.random( 1, 3 ) ) .. ".wav" ) )
			end
		else
			self.connected[k] = nil
		end
	end
end

function ENT:ChangeTemp(Amount)
	if(Amount==0)then return end
	self.LDE.CoreTemp=self.LDE.CoreTemp+Amount
end

function ENT:ShieldDamage(DmgInfo) --Environments Damage Override Hack
//	LDE:DamageCore( self, DmgInfo )
end
		
		
function ENT:ManageBaseModules()
	for k,v in pairs(self.connected) do
		if(v and v:IsValid())then
			if(v.BaseModuleThink and v.LDE.Core == self)then
				v:BaseModuleThink(self)
			end
		end
	end
end

function ENT:UpgradeCore()
	local Level = self:GetNWInt("LDETechLevel")
	local Cost = 100+((Level/2)*100)
	if(self:GetResourceAmount("Scrap")>=Cost)then
		self:ConsumeResource("Scrap", Cost)
		self:SetNWInt("LDETechLevel",Level+1)
		self.LDE.CoreMaxShield=20000+(10000*(Level))
	end
end

function ENT:Think()
	if(self.LinkX>=5)then
		self.LinkX=0
		self:LinkCheck()
		self:LinkConstrained()
	else
		self.LinkX=self.LinkX+1
	end
		
	local Targets = ents.FindByClass("basictarget")
	local TCount = table.Count(Targets)
	if(table.Count(self.connected)>=10)then
		if(self.Incoming>0)then
			if(TCount<50 and self.LDE.NextAttack<CurTime())then
				LDE.TD.RequestAttackAI(self)
				self.LDE.WaveInProgress = 1
			else
				--Do something
			end
		else
			if(TCount==0)then
				self.LDE.Wave=self.LDE.Wave+1
				self.Incoming = 3*self.LDE.Wave
				self.LDE.NextAttack=CurTime()+120
				self.LDE.WaveInProgress=0
			end
		end
	end

	if(self.LDE.CoreHealth<self.LDE.CoreMaxHealth)then
		self.LDE.CoreHealth=self.LDE.CoreHealth+50
	else
		self.LDE.CoreHealth=self.LDE.CoreMaxHealth
	end
	
	self.Targets = Targets
	self.Scrap = ents.FindByClass("resource_clump")
	self:ManageBaseModules()
	
	local Networked = {
		CoreMaxHealth 	= "LDEMaxHealth",
		CoreHealth		= "LDEHealth",
		CoreMaxShield	= "LDEMaxShield",
		CoreShield		= "LDEShield",
		CoreMaxTemp		= "LDEMaxTemp",
		CoreMinTemp		= "LDEMinTemp",
		CoreTemp		= "LDETemp",
		Wave			= "LDEWave",
		NextAttack		= "LDENxtAttack",
		WaveInProgress	= "LDEUndrAttack"
	}
		
	-- Set NW ints
	for DV, NW in pairs(Networked) do
		local hp = self:GetNWInt(NW)
		if (!hp or hp != self.LDE[DV]) then
			--   print("Synced "..NW.." as "..DV.." for "..self.LDE[DV])
			self:SetNWInt(NW, self.LDE[DV])
		end				
	end

	self:NextThink(CurTime() + 1)
	return true
end