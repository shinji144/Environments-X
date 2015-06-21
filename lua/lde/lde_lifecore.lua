LDE.LifeSupport = {}

//Needed resource check
LDE.LifeSupport.HasNeeded = function(self, List)
	for I,b in pairs(List) do  
		if(self:GetResourceAmount(b)<self.Data.InUse[I]*self:GetSizeMultiplier())then
			if(self.TurnOff)then
				self:TurnOff()
			end
			return false
		end
	end
	return true
end

//Maxed Resource check
LDE.LifeSupport.MaxedResources = function(self,List)
	if(not List)then return false end
	for I,b in pairs(List) do
		if(self:GetResourceAmount(b)>=self:GetNetworkCapacity(b))then
			return true --Whoa stop the line we have too much junk
		end
	end
	return false --Its good carry on.
end

//Use Resource loop
LDE.LifeSupport.UseResources = function(self, List)
	for I,b in pairs(List) do
		self:ConsumeResource(b, self.Data.InUse[I]*self:GetSizeMultiplier())
	end
end

//Make Resource loop
LDE.LifeSupport.MakeResources = function(self, List)
	for I,b in pairs(List) do
		self:SupplyResource(b, self.Data.OutMake[I]*self:GetSizeMultiplier())
	end
end

//Function that manages all the resources to a device.
LDE.LifeSupport.ManageResources = function(self,Override)
	if(LDE.LifeSupport.HasNeeded(self,self.Data.In))then --Do we have the needed resources?
		if(LDE.LifeSupport.MaxedResources(self,self.Data.Out) and not Override)then return end --Dont run the device if were maxed out.
		if(self.Data.In)then --Check if we have required resources.
			for I,b in pairs(self.Data.In) do --For all the required resources...
				self:ConsumeResource(b, self.Data.InUse[I]*self:GetSizeMultiplier()) --Nom dem.
			end
		end
		if(self.Data.Out)then --Check if we make stuff.
			for I,b in pairs(self.Data.Out) do --For all the outputed resources
				self:SupplyResource(b, self.Data.OutMake[I]*self:GetSizeMultiplier())--Pump dat shit out
			end
		end
		return true --Everything went perfectly...
	end
	return false --Didnt have the needed resources :(
end

//Heat Application function
function LDE.LifeSupport.ApplyHeat(ent,Data)
	heatchange = Data.heat or 0
	LDE.HeatSim.ApplyHeat(ent,heatchange*ent:GetSizeMultiplier())
	return true
end

//Drill Effect function to save lines.
function LDE.LifeSupport.DrillEffect(self,Start,End)
	local effectdata = EffectData()
	effectdata:SetEntity( self )
	effectdata:SetOrigin( Start )
	effectdata:SetStart( End )
	effectdata:SetAngles( self:GetAngles() )--Never changes
	util.Effect( "LDE_mining_beam", effectdata, true, true )
end

//Manage Light
function LDE.LifeSupport.RunLight(self,Data)
	if self.RunLight == 1 and not self.flashlight then
		//self:SetOn(true)
		local angForward = self:GetAngles() +- Angle( 0, 0, 0 )

		self.flashlight = ents.Create( "env_projectedtexture" )
		self.flashlight:SetParent( self )

		// The local positions are the offsets from parent..
		self.flashlight:SetLocalPos( Vector( 0, 0, 0 ) )
		self.flashlight:SetLocalAngles( Angle(0,0,0)+(Data.LightAngle or Angle(0,0,0)) )

		// Looks like only one flashlight can have shadows enabled!
		self.flashlight:SetKeyValue( "enableshadows", 0 )
		self.flashlight:SetKeyValue( "farz", 8096 )
		self.flashlight:SetKeyValue( "nearz", 8 )

		//the size of the light
		self.flashlight:SetKeyValue( "lightfov", Data.FOV or 30 )

		// Color.. white is default
		--print(Data.LightRed.." "..Data.LightGreen.." "..Data.LightBlue)
		self.flashlight:SetKeyValue( "lightcolor", (Data.LightRed or 255).." "..(Data.LightGreen or 255).." "..(Data.LightBlue or 255) )
		self.flashlight:Spawn()
		self.flashlight:Input( "SpotlightTexture", NULL, NULL, "effects/flashlight001" )
	elseif self.RunLight == 0 and self.flashlight then
		SafeRemoveEntity( self.flashlight )
		self.flashlight = nil
	end
end

//Check if the world is withen the a drills range.
function LDE.LifeSupport.DrillWorld(self)
	LDE.LifeSupport.DrillEffect(self,self:GetPos(),self:GetPos()+self:GetUp()*-150)--Saves lines.
	local trace = {} --Create a trace data table.
		trace.start = self:GetPos()
		trace.endpos = self:GetPos() + (self:GetUp() * -90)
		trace.filter = self
    local tr = util.TraceLine( trace )
    if tr.Hit then --Does the trace have a hit?
		if tr.HitWorld then --Is the trace hitting world?
			return true --Its hitting world.
		end
	end
	return false --Sadly, we got no hits.
end

//Entity checking function.
function LDE.LifeSupport.DrillEnt(self,Class,Rate)
	LDE.LifeSupport.DrillEffect(self,self:GetPos(),self:GetPos()+self:GetForward()*-500)--Saves lines.
	for _,v in pairs(ents.FindInBox(self:GetPos()+Vector(10,10,0),self:GetPos()+self:GetForward()*-500 +Vector(-10,-10,0) )) do
		if v:GetClass()==Class then --Make sure the entity is the right class.
			ore = LDE:GetHealth(v) --Get its health
			if(v and v:IsValid() and ore and ore>0)then
				--Owner=self.LDEOwner Owner:GiveLDEStat("Mined", (Rate*self:GetSizeMultiplier()))
				if(ore>=Rate)then
					if(not v.LDEHealth)then return end --Make sure the entity has health.
					v.LDEHealth=v.LDEHealth-(Rate) --Harvest some of the entitys health.
					return Rate
				else
					local R = v.LDEHealth
					LDE:KillEnt(v) --Cant be mined anymore, so lets kill it. **Replace with something else.
					return R
				end
			end
		end
	end
	return 0 --We couldnt find the entity we needed.
end

//Device compiling function.
function LDE.LifeSupport.CompileDevice(Data,Inner)
	for k,v in pairs(Inner.model) do
		Environments.RegisterDevice(Inner.Tool, Inner.Type, Inner.name[k], Inner.class, v)
	end
	LDE.LifeSupport.RegisterDevice(Data)
end

//Base Device Code we will inject the functions into.
function LDE.LifeSupport.RegisterDevice(Data)
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_env_entity"
	ENT.PrintName = Data.name
	ENT.Data = Data
	ENT.CanRun=1
	ENT.Mult = 1
	
	if(Data.RunSound)then
		util.PrecacheSound(Data.RunSound)
	end
	
	list.Set( "LSEntOverlayText" , Data.class, {HasOOO = true, resnames = Data.In, genresnames = Data.Out} )
	
	if SERVER then
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
					self.Inputs = WireLib.CreateInputs(self, { "On","Multiplier" })
				end
				if(Data.WireOut)then
					self.Outputs = WireLib.CreateOutputs(self, Data.WireOut)
				else
					self.Outputs = WireLib.CreateOutputs(self, "On")
				end
			end
			if(self.Data.Initialize)then
				self.Data.Initialize(self)
			end
		end
		
		function ENT:OnTakeDamage(DmgInfo)
			LDE_EntityTakeDamage( self, DmgInfo )
		end
		
		function ENT:TurnOn()
			if self.Active == 0 then
				self.Active = 1
				self:SetOOO(1)
				WireLib.TriggerOutput(self, "On", 1)
			end
		end
		
		function ENT:TriggerInput(iname, value)
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
			elseif iname == "Multiplier" then
				if(value<=1)then
					self:SetMultiplier(1)
				else
					self:SetMultiplier(value)
				end
			end
			//self.Inputs[iname]=value
		end

		function ENT:TurnOff()
			if self.Active == 1 then
				self.Active = 0
				self:SetOOO(0)
				WireLib.TriggerOutput(self, "On", 0)
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
		
		ENT.Generate = Data.shootfunc

		function ENT:Think()
			if(CurTime()>=self.LastTime+1)then
				self.LastTime=CurTime()
				self.Mult = self:GetSizeMultiplier() or 1
				self:Generate()
			end
			self:NextThink(CurTime() + 1)
			return true
		end
	else
		--client
	end
	
	scripted_ents.Register(ENT, Data.class, true, true)
	print("Device Registered: "..Data.class)
end

//Storage compiling function.
function LDE.LifeSupport.CompileStorage(Data,Inner)
	for k,v in pairs(Inner.model) do
		Environments.RegisterDevice(Inner.Tool, Inner.Type, Inner.name[k], Inner.class, v)
	end
	Environments.RegisterLSStorage(Data.name, Data.class, Data.Rates, 4084, 100, 10)
	LDE.LifeSupport.RegisterStorage(Data)
end

//Base storage Code we will inject the functions into.
function LDE.LifeSupport.RegisterStorage(Data)
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_env_storage"
	ENT.PrintName = Data.name
	ENT.Data = Data
	if(!CLIENT)then
		if(self)then
			list.Set( "LSEntOverlayText" , Data.class, {HasOOO = false, resnames = self.Data.storage} )
		end
	end
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
			LDE_EntityTakeDamage( self, DmgInfo )
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

	local Files
	if file.FindInLua then
		Files = file.FindInLua( "lde/lifesupport/*.lua" )
	else//gm13
		Files = file.Find("lde/lifesupport/*.lua", "LUA")
	end

	--Get the weapon data from the lifesupport folder.
	for k, File in ipairs(Files) do
		Msg("*LDE LifeSupport Loading: "..File.."...\n")
		local ErrorCheck, PCallError = pcall(include, "lde/lifesupport/"..File)
		ErrorCheck, PCallError = pcall(AddCSLuaFile, "lde/lifesupport/"..File)
		if !ErrorCheck then
			Msg(PCallError.."\n")
		end
	end
	Msg("LDE LifeSupport Loaded: Successfully\n")



