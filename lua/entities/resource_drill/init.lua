AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

util.PrecacheModel("models/Slyfo/drillplatform.mdl")
util.PrecacheModel("models/Slyfo/drillbase_basic.mdl")
util.PrecacheModel("models/Slyfo/rover_drillbase.mdl")
util.PrecacheModel("models/Slyfo/rover_drillshaft.mdl")
util.PrecacheModel("models/Slyfo/rover_drillbit.mdl")
--#  SETUP! GO!
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self.DrillType = 0
	self.Body = self
	--self.Shaft
	--self.Bit
	--self.ResEnt
	self.ShaftBasePos = Vector(0,0,0)
	self.BitBasePos = Vector(0,0,0)
	self.Set = false
	self.Drillset = 0
	self.Frozen = false
	self.LastResource = "none"
	
	self.Status = {"Idle","Drilling","Extracting","Shutting Down","OverHeating"}
	self.Resource = ""
	self.LockedPos = Vector(0,0,0)
	self.LockedAngles = Angle(0,0,0)
	self.NextSound = CurTime()
	self.NextWorldSound = CurTime()
	self.dt.Depth = 0
	self.dt.Locked = 0
	self.dt.ExtractionRate = 0
	self.dt.Shaftspeed = 0
	self.dt.Phase = 1
	self.dt.Heat = 0
	
	if WireAddon then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, {"On"})
		self.Outputs = WireLib.CreateSpecialOutputs(self,
			{"On","Depth","Locked","ExtractionRate","Heat","Status","Resource","LastResource"},
			{"NORMAL","NORMAL","NORMAL","NORMAL","NORMAL","STRING","STRING","STRING"}
		)
	end
	
end

--# Used to set the Drilltype
function ENT:SetDrillType(drilltype)
	if not drilltype or type(drilltype) ~= "number" then return end
	self.DrillType = drilltype
	self:SetupDrill()
	self.Set = true
end

--#  Sets the Drill shaft Z position in relation to the Drill.
function ENT:SetDrillPos(ZOffset)
	if not ZOffset or type(ZOffset) ~= "number" then return end
	if ZOffset < 0 then ZOffset = 0
	elseif ZOffset >190 then ZOffset = 190
	end
	if not self.DrillType or self.DrillType == 0 then return end 
	
	local Pos = Vector(0,0,0)
	if self.DrillType == 1 then	-- "models/Slyfo/rover_drillbase.mdl"
		Pos = self:GetPos() + self:GetUp() * (120 - ZOffset )+ self:GetForward() * -40.356 
	elseif self.DrillType == 2 then -- "models/Slyfo/drillplatform.mdl"
		Pos = self:GetPos() + self:GetUp() * (160 - ZOffset )
	elseif self.DrillType == 3 then -- "models/Slyfo/drillbase_basic.mdl"
		Pos = self:GetPos() + self:GetUp() * (50 - ZOffset )
	end
	return Pos
end

--#  Initialize the drill and spawn it's component parts
function ENT:SetupDrill()
	local ply = self:GetPlayer()
	drillbit = ents.Create("prop_physics")
	drillbit:SetModel("models/Slyfo/rover_drillbit.mdl")
	--drillbit:PhysicsInit(SOLID_VPHYSICS)
	drillbit:SetSolid(SOLID_NONE)
	drillbit:SetMoveType(MOVETYPE_NONE)
	if drillbit and drillbit:IsValid() then self.Bit = drillbit end
	
	shaft = ents.Create("prop_physics")
	shaft:SetModel("models/Slyfo/rover_drillshaft.mdl")
	--shaft:PhysicsInit(SOLID_VPHYSICS)
	shaft:SetSolid(SOLID_NONE)
	shaft:SetMoveType(MOVETYPE_NONE)
	if shaft and shaft:IsValid() then self.Shaft = shaft end

	--todo:  setup aborts if creation fails
	
	local shaftpos = self:SetDrillPos(0)
	self.ShaftBasePos = shaftpos
	
	shaft:SetPos(shaftpos)
	shaft:SetAngles(self:GetAngles())
	bitpos = shaft:GetPos() + shaft:GetUp() * -128
	self.BitBasePos = bitpos
	drillbit:SetAngles(shaft:GetAngles())
	drillbit:SetPos(bitpos)
	
	shaft:Spawn()
	shaft:Activate()
	shaft:SetNotSolid(true)
	sPhys = shaft:GetPhysicsObject()
	if sPhys:IsValid() then
		sPhys:SetMass(1)
	end
	
	drillbit:Spawn()
	drillbit:Activate()
	drillbit:SetNotSolid(true)
	dPhys = drillbit:GetPhysicsObject()
	if dPhys:IsValid() then
		dPhys:SetMass(1)
	end
	
	--constraint.Weld(drillbit,shaft,0,0,0,true)
	--constraint.Weld(shaft,self,0,0,0,true)
	drillbit:SetParent(shaft)
	shaft:SetParent(self)
	if self.CPPISetOwner then 
		shaft:CPPISetOwner(ply)
		drillbit:CPPISetOwner(ply)
	end
	
	self.IsLDEC=true
end

--#  Prevention from others messing with our constraints.
function ENT:CheckConstraints()
	-- Should check for welds/etc too
	local shaftparent = self.Shaft:GetParent()
	local bitparent = self.Bit:GetParent()
	
	-- Wrong parent bitches
	if bitparent ~= self.Shaft then self.Bit:SetParent(nil) end
	if shaftparent ~= self then self.Shaft:SetParent(nil) end
	
	-- No parent set? WTF?
	if not bitparent:IsValid() then self.Bit:SetParent(self.Shaft) end
	if not shaftparent:IsValid() then self.Shaft:SetParent(self) end
end

--# Cleanup on removal
function ENT:OnRemove() 
	if self.Bit then self.Bit:Remove() end
	if self.Shaft then self.Shaft:Remove() end
	
end

--# Hacky function to rotate the drill shaft ( do clientside for smother look :S )
function ENT:ShaftRotate(speed)
	if not speed or type(speed) ~= "number" then return end
	if speed < -100 then speed = -100
	elseif speed > 100 then speed = 100
	end

	local SAng = self.Shaft:GetAngles()
	local Rot = SAng
	Rot:RotateAroundAxis(self:GetUp(),speed)
	local ang = LerpAngle(0.25,SAng,Rot)
	self.Shaft:SetAngles( ang  )
end

--# Sets/Unsets the Drill lockdown mode ( immoble while active )
function ENT:Lockdown(lock)
	if not lock or type(lock) ~= "number" then return end
	if lock > 1 then lock = 1 
	elseif lock < 0 then lock = 0
	end
	
	if lock == 1 then
	
		self.LockedPos = self:GetPos()
		self.LockedAngles = self:GetAngles()

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
		end

	end
	self.dt.Locked = lock
end

--# Power On
function ENT:TurnOn()
	self.Active = 1
	self:SetOOO(1)
	self.LockedPos = self:GetPos()
	self:SetParent()
	self:SetPos(self.LockedPos)
	self.LockedAngles = self:GetAngles()
	local physobj = self:GetPhysicsObject()
	if physobj:IsValid() then
		self.Frozen = physobj:IsMoveable()
	end
	self:EmitSound("/ambient/machines/thumper_dust.wav",90,120)
	self:TriggerWireOutputs()
end

--# Power Off
function ENT:TurnOff()
	if self.dt.Phase >1 or self.Drillset > 1 then 
		self:Shutdown() 
		return
	end
	self.Active = 0
	self.dt.Depth = 0
	self:SetOOO(0)
	self.Resource =""
	self.ResEnt = nil
	if self.Frozen ~= false then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(true)
			phys:Wake()
		end
	end
	self:SetNetworkedString("ResourceDrillResource",self.Resource)
	self:Lockdown(0)
	self:EmitSound("/ambient/atmosphere/arena_lights_off_0"..tostring(math.random(1,6))..".wav",self:GetPos(),45,110)
	self:TriggerWireOutputs()
end

--#  Input triggers
function ENT:TriggerInput(iname,value)
	if iname == "On" then
		if value >= 1 and self.dt.Phase < 2 then self:SetActive(value) end
		if value < 1 and self.dt.Phase > 1 then self:Shutdown() end
	end
end

--# update wire outputs.
function ENT:TriggerWireOutputs()
	if WireAddon then
		Wire_TriggerOutput(self,"On",self.Active)
		Wire_TriggerOutput(self,"Depth",self.dt.Depth)
		Wire_TriggerOutput(self,"Locked",self.dt.Locked)
		Wire_TriggerOutput(self,"ExtractionRate",self.dt.ExtractionRate)
		Wire_TriggerOutput(self,"Heat",self.dt.Heat)
		Wire_TriggerOutput(self,"Status",self.Status[self.dt.Phase])
		Wire_TriggerOutput(self,"Resource",self.Resource)
		Wire_TriggerOutput(self,"LastResource",self.LastResource)
	end
end

--# Damage stuffs
function ENT:Damage()
	if self.damaged == 0 then self.damaged = 1 end
end

--# Shutdown the drill by bringing the drillshaft up and stopping.
function ENT:Shutdown()
	if self.dt.Phase == 1 then 
		self:TurnOff() 
		return 
	end
	
	self.dt.Phase,self.dt.Drillspeed = 4,-5
	if self.dt.Heat < 70 then
		self.dt.Shaftspeed = -5
		if self.Drillset > 0 then self.Drillset = math.Clamp(self.Drillset - 1,0,150)
		elseif self.Drillset <= 0 then 
			self.dt.Phase = 1
			self:TurnOff()
			return
		end
		
		self.Shaft:SetParent(nil)
		self.Shaft:SetPos(self:SetDrillPos(self.Drillset) )
		self.Shaft:SetParent(self)
	else
		self.dt.Shaftspeed = -1
		self.dt.Phase = 5
		if self.NextSound < CurTime() then
			self:EmitSound("/ambient/materials/rustypipes"..tostring(math.random(1,3))..".wav",60,80)
			self.NextSound = CurTime()+math.random(5,15)
		end
		self.dt.Heat = math.Clamp(self.dt.Heat - 0.002,0,100)
		self:TriggerWireOutputs()
	end
	timer.Simple(0.01,function() if IsValid(self) and self.Shutdown then self:Shutdown() end end)
end

--# Startup the drill and extract resources once we reach proper depth
--- Need optimization horribly...  some local functions to remove redundancy @#$!
function ENT:Extract()
	if self:GetResourceAmount("energy") <= 500 then
		self.dt.Phase = 6
		self:EmitSound("/ambient/levels/citadel/citadel_breakershut1.wav",40,120)
		self:Shutdown() -- Out of energy shut down.
	end
	if self.dt.Heat > 75 then
		self.dt.Shaftspeed = 4
		if self.NextSound < CurTime() then
			self:EmitSound("/ambient/materials/rustypipes"..tostring(math.random(1,3))..".wav",60,80)
			--util.ScreenShake(self:GetPos(),1,2,100)
			self.NextSound = CurTime()+math.random(8,25)
		end
	end
	if self.dt.Heat > 90 then -- Overheat Shutdown.
		self.dt.Phase = 5
		self:Shutdown()
	end
	local restypes = {"resource_pool","resource_asteroid"}
	-- Startup Phase
	if self.dt.Phase == 1 then 
		self:EmitSound("/ambient/machines/hydraulic_1.wav",50,60)
		self:Lockdown(1)
		self.dt.Phase = 2 
	end 
	-- Drill Phase
	if self.dt.Phase == 2 then
		self.dt.Shaftspeed = 8
		self.dt.Depth = self.dt.Depth + 1
		if self.Drillset < 190 then 
			self.Drillset = math.Clamp(self.Drillset + 1,0,190)
			self.Shaft:SetParent(nil)
			self.Shaft:SetPos(self:SetDrillPos(self.Drillset))
			self.Shaft:SetParent(self)
		end
		
		local underground = false
		-- Check to see if we are underground/in something
		local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = self:GetPos() + (self:GetUp() * (self:OBBMins().z - 90 ) )
		
		-- and now some dirty hax.
		All,Filtered = ents.GetAll(),{} 
		for _,v in pairs(All) do if v:GetClass() ~= "resource_asteroid" then Filtered[#Filtered+1] = v end end
		tracedata.filter = Filtered
		
		-- Check Trace results and continue drilling if we make it underground.
		local traceres = util.TraceLine(tracedata)
		if traceres.HitTexture == "**displacement**" and self.Drillset > 50 then underground = true end
		local Ent = traceres.Entity
		if  Ent:IsValid() and Ent:GetClass() == "resource_asteroid" and self.Drillset > 70 then underground = true end
		local depthpos = ( self:GetPos() + ( self:GetUp() * (self:OBBMins().z - self.dt.Depth) ) )
		util.ScreenShake(depthpos,1.5,3,1,300)
		if CurTime() > self.NextWorldSound then
			self:EmitSound("/ambient/atmosphere/thunder"..tostring(math.random(1,3))..".wav",depthpos,48,190)
			self.NextWorldSound = CurTime() + 2
		end
		local res,targs = {},ents.FindInSphere(depthpos,2000)
		for k,v in pairs(targs) do
			if table.HasValue(restypes,v:GetClass()) then res[#res+1] = v end
		end
		-- Locate nearest resource and  target that pool.
		local closest,dist = nil,2000
		if (#res > 0 ) then
			-- Find the closest target
			for k,v in pairs(res) do 
				local range = depthpos:Distance( v:GetPos() )
				if  range < dist then  closest,dist = v,range end
			end
		end		
		if closest ~= nil then
			if closest:GetClass() == "resource_pool" then
				if closest:InPoolRadius(depthpos) and underground then
					self.ResEnt = closest
					self.dt.Phase = 3 
				end
			end
			if closest:GetClass() == "resource_asteroid" then
				local dist = depthpos:Distance(closest:GetPos() ) 
				local rad = (  closest.radius * 0.38 )
				if dist < rad and underground then 
					self.ResEnt = closest
					self.dt.Phase = 3 
				end
			end
		end
		-- Mabye add other possible resource consumption hmmm
		self:ConsumeResource("energy",(1 + (self.dt.Depth * 0.005 )))

		local heatup = 0.002
		heatup = heatup + ((self.environment:GetTemperature() * 1e-6) * self.dt.Depth *  0.07)
		self.dt.Heat = math.Round(math.Clamp(self.dt.Heat + heatup,0,100),3)

		if self.dt.Depth >= 2000 then 
			self:EmitSound("buttons/button8.wav",40,90)
			self:Shutdown() 
		end -- nothing here shutdown 
		if not traceres.Hit and self.Drillset >= 150 and not underground then self:Shutdown() end -- what's going on here >_<
	end
	--  Extraction Phase
	if self.dt.Phase == 3 then
		self.dt.Shaftspeed = 1
		self.dt.ExtractionRate = 0
		if self.ResEnt ~= nil and self.ResEnt:IsValid() then
			local Res = self.ResEnt.resource_type
			
			if Res ~= "" and self.Resource ~= Res then
				self:SetNetworkedString("ResourceDrillResource",Res)
				self.Resource = Res
				self.LastResource = Res
				if Res == "radioactive_ore" and math.Rand() > 0.85 then
					self:EmitSound("/HL1/fvox/radiation_detected.wav",50,100)
				end
			end
			
			if self.node and self.node.maxresources[Res] then
				local storagemax,stored = self.node.maxresources[Res],0
				if self.node.resources[Res] then stored = self.node.resources[Res].value end		
				if stored < storagemax then -- room to extract
					local ex = math.Clamp(math.floor(5 - (self.ResEnt.density * (self.dt.Depth * 2e-3))),1,250)
					if self.ResEnt:GetClass() == "resource_asteroid" then ex = math.Clamp(ex * 0.25,1,5) end
					local extract = self.ResEnt:Drain(ex)
					self:SupplyResource(Res,extract)
					self.dt.ExtractionRate = extract * 100
					if self.ResEnt == nil and not self.ResEnt:IsValid() then 
						self:Shutdown() 
					end --Resource depleted shutdown.
				elseif stored == storagemax	then -- Full.. shutdown.
					self:EmitSound("buttons/button18.wav",90,100)
					self:Shutdown()
				end
			end
		else
			if self.Resource ~= "" then
				self.Resource = ""
				self:SetNetworkedString("ResourceDrillResource",self.Resource)
			end
			self:Shutdown()
		end
		local heatup = 0.0015
		heatup = heatup + ((self.environment:GetTemperature() * 1e-6) * self.dt.Depth * 0.05)
		self.dt.Heat = math.Round(math.Clamp(self.dt.Heat + heatup,0,100),3)
		self:ConsumeResource("energy",(2 + (self.dt.Depth * 0.005 )))
	end
	self:TriggerWireOutputs()
end

--# Doin stuff
function ENT:Think()
	self.BaseClass.Think(self)
	
	if not self.Set then self:SetDrillType(self.env_extra) end
	if self.Active == 1 then
		if self:GetPos() ~= self.LockedPos or self:GetAngles() ~= self.LockedAngles and self.dt.Locked ~= 0 then
			self:SetPos(self.LockedPos)
			self:SetParent()
			self:SetAngles(self.LockedAngles)
		end
		self:Extract()
		self:ShaftRotate(self.dt.Shaftspeed)
	else
		self.dt.Heat = math.Clamp(self.dt.Heat - 0.02,0,100)
		if self.dt.Phase ~= 1 then self:Shutdown() end
	end
	if self.dt.Phase == 1 then self:Lockdown(0) elseif self.dt.Phase >1 then self:Lockdown(1) end
	self:CheckConstraints()
	self:NextThink(CurTime() + 0.01)
	return true
end

--# On lockdown :S
function ENT:CanTool()
	if self.dt.Locked ~= 0 then return false end
	return true
end

function ENT:GravGunPunt()
	if self.dt.Locked ~= 0 then return false end
	return true
end

function ENT:GravGunPickupAllowed()
	if self.dt.Locked ~= 0 then return false end
	return true
end

--#  Dupe Code .. have to override default behavior.
function ENT:PreEntityCopy()
	Environments.BuildDupeInfo(self)
	if WireLib then
		local DupeInfo = WireLib.BuildDupeInfo(self)
		if DupeInfo then
			duplicator.StoreEntityModifier( self, "WireDupeInfo", DupeInfo )
		end
	end
	local DrillInfo = {}
	DrillInfo.Shaft = self.Shaft:EntIndex()
	DrillInfo.Bit = self.Bit:EntIndex()
	duplicator.StoreEntityModifier(self,"EnvMiningInfo",DrillInfo)
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	Environments.ApplyDupeInfo(Ent, CreatedEntities, Player)
	if WireLib and (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
		WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
	if Ent.EntityMods and Ent.EntityMods.EnvMiningInfo then -- More dirty hax.. ugh..
		EM = Ent.EntityMods.EnvMiningInfo
		CreatedEntities[EM.Shaft]:Remove()
		CreatedEntities[EM.Bit]:Remove()
	end
end