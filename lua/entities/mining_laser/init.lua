AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	-- set datatable variables
	self.dt.Efficiency = 0
	self.dt.Flowrate = 0
	self.dt.Heat = 0
	self.dt.LaserMine = false
	
	self.Resource = "none"
	self.LastResource = "none"
	self.LastPos = Vector(0,0,0)
	
	self.Extraction_Types = {"resource_asteroid"}
	self.boxmax = self:OBBMaxs() - self:OBBMins()
	
	-- WireMod Ports
	if WireAddon then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On" })
		self.Outputs = WireLib.CreateSpecialOutputs(self, 
			{"On","Efficiency","Heat","Flowrate","Resource","LastResource"},
			{"NORMAL","NORMAL","NORMAL","NORMAL","STRING","STRING"}
		)
	else
		self.Inputs = {{Name="On"}}
	end
end


function ENT:TurnOn()
	self.Active = 1
	self:SetOOO(1)
	self:Extract()
	self.dt.Efficiency = 0
	self.dt.Flowrate = 0
	self.Resource = "none"
	self:SetNetworkedString("MiningLaserResource",self.Resource)
	self:WireOutput()
	self:EmitSound("/vehicles/crane/crane_magnet_switchon.wav",80,45)
end

function ENT:TurnOff()
	self.Active = 0
	self:SetOOO(0)
	self.dt.Efficiency = 0
	self.dt.Flowrate = 0
	self.Resource = "none"
	self:SetNetworkedString("MiningLaserResource",self.Resource)
	self:WireOutput()
end

function ENT:TriggerInput(iname,value)
	if iname == "On" then
		self:SetActive(value)
	end
end

function ENT:WireOutput()
	if WireAddon then 
		Wire_TriggerOutput(self,"On",self.Active)
		Wire_TriggerOutput(self,"Efficiency",self.dt.Efficiency)
		Wire_TriggerOutput(self,"Heat",self.dt.Heat)
		Wire_TriggerOutput(self,"Flowrate",self.dt.Flowrate)
		Wire_TriggerOutput(self,"Resource",self.Resource)
		Wire_TriggerOutput(self,"LastResource",self.LastResource)
	end
end

function ENT:Damage()
	if self.damaged == 0 then self.damaged = 1 end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self:SetColor(Color(255, 255, 255, 255))
	self.damaged = 0
end

function ENT:Extract()

	if self:GetResourceAmount("energy") <= 1e3 then 	-- No juice?  
		self:TurnOff()
		return
	end
	-- Shutdown due to overheating and not enough coolant. (safety first :P )
	if self.dt.Heat > 75 and self:GetResourceAmount("water") <= 150 then
		--todo:  Chance of explosion if damaged :S
		self:EmitSound("/doors/doormove3.wav",76,100)
		self:TurnOff()
	else
		self:ConsumeResource("water",math.ceil( self.dt.Heat * 9e-1 ) )
	end

	local Pos,Fore = self:GetPos(), self:GetForward()
	LaserStart = Pos + Fore * ( self.boxmax.x *0.62)
	LaserOrigin = Pos + Fore * 768
		
	local tracedata = {} -- @$! Salmon!
	tracedata.start = LaserStart
	tracedata.endpos = LaserOrigin
	tracedata.filter = self
	local trace = util.TraceLine(tracedata)
	local HitPos, HitEnt = trace.HitPos,trace.Entity

	local heatup = 0.1
	heatup = heatup + self.environment:GetTemperature() * 1e-4
	if self:GetResourceAmount("water") > 1e3 then heatup = 0.09 end
	
	self.dt.Heat = math.Round(math.Clamp(self.dt.Heat + heatup,0,100),1)
	self:ConsumeResource("energy",100 * ( self.dt.Heat * 1e-2) )

	-- Did we hit a roid?
	if HitEnt:IsValid() and HitEnt ~= nil then
		if not table.HasValue(self.Extraction_Types,HitEnt:GetClass()) then return end
		if HitEnt:IsPlayer() then
			HitEnt:TakeDamage(1,self:GetPlayer(),self)
			if math.Rand(0,5) > 4.8 then HitEnt:Ignite() end
			return
		end
		local Res = HitEnt.resource_type
		local Dist = self.LastPos:Distance(HitPos)
		self.dt.Efficiency = math.Clamp( self.dt.Efficiency + 0.4 - ( Dist * 0.5),0,100)
		self.LastPos = HitPos
		
		if Res ~= "" and self.Resource ~= Res then
			self.Resource = Res
			self.LastResource = Res
			self:SetNetworkedString("MiningLaserResource",self.Resource)
		end
		
		-- Got someplace to put this stuff?
		if self.node and self.node.maxresources[Res] then
			local storagemax = self.node.maxresources[Res]
			local stored = 0
			if self.node.resources[Res] then 
				stored = self.node.resources[Res].value 

			end
			self.dt.LaserMine = false
			if stored < storagemax then -- not full then extract
				local ex = math.Clamp( math.floor( 15 * ( (self.dt.Efficiency - (HitEnt.density+self.dt.Heat) ) * 0.005 ) ),0,1e3)
				local extract = HitEnt:Drain(ex)
				self:SupplyResource(Res,extract)
				self.dt.Flowrate = extract * 10
				self.dt.LaserMine = false
				if math.Rand(0,3) < 1 then -- dem Chunky bits!!
					self.dt.LaserMine = true
					self:EmitSound("/ambient/atmosphere/thunder"..tostring(math.random(1,4))..".wav",HitPos,58,190)
				end
			end
		end
	else
		self.dt.Efficiency = 0
		self.dt.Flowrate = 0
		self.dt.LaserMine = false
		if self.Resource ~= "none" then
			self.Resource = "none"
			self:SetNetworkedString("MiningLaserResource",self.Resource)
		end
	end

	self:WireOutput()
end

function ENT:Think()
	self.BaseClass.Think(self)
	if self.Active == 1 then 
		self:Extract() 
	else 
		if self.dt.Heat > 0 then
			self.dt.Heat = math.Clamp(self.dt.Heat - 0.2,0,100) -- cool off
			if self:GetResourceAmount("water") > 0 then 
				self.dt.Heat = math.Clamp(self.dt.Heat - 0.4,0,100)
				self:ConsumeResource("water",math.ceil( self.dt.Heat * 2e-2 ) ) 
			end
			self:WireOutput()
		end
	end
	self:NextThink(CurTime()+0.1)
	return true
end