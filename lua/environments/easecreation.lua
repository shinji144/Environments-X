
local Environments = Environments --yay speed boost!

Environments.Devices = {}

//Needed resource check
Environments.Devices.HasNeeded = function(self, List)
	for I,b in pairs(List) do  
		if(self:GetResourceAmount(b)<self.Data.InUse[I]*self:GetMultiplier())then
			self:TurnOff()
			return false
		end
	end
	return true
end

//Maxed Resource check
Environments.Devices.MaxedResources = function(self,List)
	if(not List)then return false end
	for I,b in pairs(List) do
		if(self:GetResourceAmount(b)>=self:GetNetworkCapacity(b))then
			return true --Whoa stop the line we have too much junk
		end
	end
	return false --Its good carry on.
end

//Use Resource loop
Environments.Devices.UseResources = function(self, List)
	for I,b in pairs(List) do
		self:ConsumeResource(b, self.Data.InUse[I]*self:GetMultiplier())
	end
end

//Make Resource loop
Environments.Devices.MakeResources = function(self, List)
	for I,b in pairs(List) do
		self:SupplyResource(b, self.Data.OutMake[I]*self:GetMultiplier())
	end
end

//Function that manages all the resources to a device.
Environments.Devices.ManageResources = function(self,Override)
	if(Environments.Devices.HasNeeded(self,self.Data.In))then --Do we have the needed resources?
		if(Environments.Devices.MaxedResources(self,self.Data.Out) and not Override)then return end --Dont run the device if were maxed out.
		if(self.Data.In)then --Check if we have required resources.
			for I,b in pairs(self.Data.In) do --For all the required resources...
				self:ConsumeResource(b, self.Data.InUse[I]*self:GetMultiplier()) --Nom dem.
			end
		end
		if(self.Data.Out)then --Check if we make stuff.
			for I,b in pairs(self.Data.Out) do --For all the outputed resources
				self:SupplyResource(b, self.Data.OutMake[I]*self:GetMultiplier())--Pump dat shit out
			end
		end
		return true --Everything went perfectly...
	end
	return false --Didnt have the needed resources :(
end

//Device compiling function.
function Environments.Devices.CompileDevice(Data,Inner)
	for k,v in pairs(Inner.model) do
		Environments.RegisterDevice(Inner.Tool, Inner.Type, Inner.name[k], Inner.class, v)
	end
	Environments.Devices.RegisterDevice(Data)
end

//Base Device Code we will inject the functions into.
function Environments.Devices.RegisterDevice(Data)
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = Data.BaseClass or "base_env_entity"
	ENT.PrintName = Data.name
	ENT.Data = Data
	ENT.CanRun=1
	ENT.Mult = 1
	
	if(Data.RunSound)then
		util.PrecacheSound(Data.RunSound)
	end
	
	if(not Data.NoList)then
		list.Set( "LSEntOverlayText" , Data.class, {HasOOO = true, resnames = Data.In, genresnames = Data.Out} )
	end
	
	if SERVER then
		if(Data.ServerSide)then
			Data.ServerSide(ENT)
		else
			function ENT:Initialize()
				self.BaseClass.Initialize(self)
				self:PhysicsInit( SOLID_VPHYSICS )
				self:SetMoveType( MOVETYPE_VPHYSICS )
				self:SetSolid( SOLID_VPHYSICS )
				self.Active = 0
				self.multiplier = 1
				self.LastTime = 0
				if WireAddon then
					self.WireDebugName = self.PrintName
					if(Data.WireIn)then
						self.Inputs = WireLib.CreateInputs(self, Data.WireIn)
					else
						self.Inputs = WireLib.CreateInputs(self, { "On","Mult" })
					end
					if(Data.WireOut)then
						self.Outputs = WireLib.CreateOutputs(self, Data.WireOut)
					end
				end
				
				if(Data.Initial)then
					Data.Initial(self)
				end
			end
			
			function ENT:OnTakeDamage(DmgInfo)
				--LDE_EntityTakeDamage( self, DmgInfo )
				if(Data.OnDamage)then
					Data.OnDamage(self)
				end
			end
			
			function ENT:TurnOn()
				if self.Active == 0 then
					self.Active = 1
					self:SetOOO(1)
				end
			end
			
			function ENT:TriggerInput(iname, value)
				if(Data.WireTrigger)then
					Data.WireTrigger(self,iname,value)
				else
					if iname == "On" then
						if value > 0 then
							if self.Active <= 0 then
								self:TurnOn()
							end
						else
							if self.Active >= 1 then
								self:TurnOff()
							end
						end
					elseif iname == "Mult" then
						if(value<=1)then
							self:SetMultiplier(1)
						else
							self:SetMultiplier(value)
						end
					end
				end
			end

			function ENT:TurnOff()
				if self.Active == 1 then
					self.Active = 0
					self:SetOOO(0)
				end
			end

			function ENT:SetActive(value)
				if not (value == nil) then
					if (value != 0 and self.Active == 0 ) then
						self:TurnOn()
					elseif (value == 0 and self.Active == 1 ) then
						self:TurnOff()
					end
				else
					if ( self.Active == 0 ) then
						self:TurnOn()
					else
						self:TurnOff()
					end
				end
			end
			
			ENT.Generate = Data.thinkfunc

			function ENT:Think()
				if(CurTime()>=self.LastTime+1)then
					self.LastTime=CurTime()
					self.Mult = self:GetMultiplier() or 1
					self:Generate(self)
				end
				self:NextThink(CurTime() + 1)
				return true
			end
		end
	else
		--client
	end
	
	scripted_ents.Register(ENT, Data.class, true, true)
	print("Device Registered: "..Data.class)
end

//Storage compiling function.
function Environments.Devices.CompileStorage(Data,Inner)
	if(Inner)then
		for k,v in pairs(Inner.model) do
			Environments.RegisterDevice(Inner.Tool, Inner.Type, Inner.name[k], Inner.class, v)
		end
	end
	Environments.RegisterLSStorage(Data.name, Data.class, Data.Rates, 4084, 100, 10)
	Environments.Devices.RegisterStorage(Data)
end

//Base storage Code we will inject the functions into.
function Environments.Devices.RegisterStorage(Data)
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_env_storage"
	ENT.PrintName = Data.name
	ENT.Data = Data
	
	list.Set( "LSEntOverlayText" , Data.class, {HasOOO = false, resnames = Data.storage} )

	if SERVER then
		function ENT:Initialize()
			self.BaseClass.Initialize(self)
			self.Entity:PhysicsInit( SOLID_VPHYSICS )
			self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
			self.Entity:SetSolid( SOLID_VPHYSICS )
			self.Active = 0
			self.damaged = 0

			self.vent = false
			if not (WireAddon == nil) then
				self.WireDebugName = self.PrintName
				self.Inputs = Wire_CreateInputs(self.Entity, { "Vent" })
				local tab = {}
				local i = 1
				for k,res in pairs(Data.storage) do
					//local v = self.res[i]
					tab[i] = res
					tab[i+1] = "Max "..res
					i = i + 2
				end
				//PrintTable(tab)
				self.Outputs = Wire_CreateOutputs(self, tab)
			end
			self:SetColor(Color(255,255,255,255))
		end
		
		function ENT:Damage()
			if (self.damaged == 0) then self.damaged = 1 end
		end
		
		function ENT:Repair()
			self.BaseClass.Repair(self)
			self:SetColor(Color(255, 255, 255, 255))
			self.damaged = 0
		end

		function ENT:TriggerInput(iname, value)
			if (iname == "Vent") then
				if (value != 1) then
					self.vent = false
				else
					self.vent = true
				end
			end
		end
		
		function ENT:Leak()
			for I,b in pairs(Data.storage) do
				local air = self:GetResourceAmount(B)
				local mul = air/self.maxresources[B]
				local am = math.Round(mul * 1000);
				if (air >= am) then
					self:ConsumeResource(B, am)
					if self.environment then
						self.environment:Convert(-1, B, am)
					end
				else
					self:ConsumeResource(B, air)
					if self.environment then
						self.environment:Convert(-1, B, air)
					end
					self.Entity:StopSound( "PhysicsCannister.ThrusterLoop" )
				end
			end
		end
		
		function ENT:OnTakeDamage(DmgInfo)
			--LDE_EntityTakeDamage( self, DmgInfo )
		end
		
		function ENT:OnRemove()
			self.BaseClass.OnRemove(self)
			for I,b in pairs(Data.storage) do
				local air = self:GetResourceAmount(B)
				if self.environment then
					self.environment:Convert(-1, B, air)
				end
			end
			self.Entity:StopSound( "PhysicsCannister.ThrusterLoop" )
		end
		
		function ENT:Think()
			self.BaseClass.Think(self)
			if (self.damaged == 1 or self.vent) then
				self:Leak()
			end
			
			if WireAddon then
				for k,v in pairs(Data.storage) do
					Wire_TriggerOutput(self, v, self:GetResourceAmount(v))
					Wire_TriggerOutput(self, "Max "..v, self:GetNetworkCapacity(v))
				end
			end
			
			self:NextThink( CurTime() +  1 )
			return true
		end
	else
		--client
	end
	
	scripted_ents.Register(ENT, Data.class, true, true)
	print("Storage Registered: "..Data.class)
end
