------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
util.PrecacheSound( "buttons/combine_button_locked.wav" )
util.PrecacheSound( "warpdrive/error2.wav" )
util.PrecacheSound( "common/warning.wav" )

--localize
local math = math
local ents = ents
local constraint = constraint
local CurTime = CurTime

include("shared.lua")
AddCSLuaFile("shared.lua")
	
function ENT:SpawnFunction(ply, tr) -- Spawn function needed to make it appear on the spawn menu
	local ent = ents.Create("env_autogen") -- Create the entity
	ent:SetPos(tr.HitPos + Vector(0, 0, 1) ) -- Set it to spawn 50 units over the spot you aim at when spawning it
	ent:Spawn() -- Spawn it
 
	return ent -- You need to return the entity to make it work
end
 
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:SetModel( "models/rawr/minispire.mdl" ) --setup stuff
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	self.ActAnim = self.Entity:LookupSequence("activate") -- Activate
	self.DeactAnim = self.Entity:LookupSequence("deactivate") -- Deactivate
	self.IdleAnim = self.Entity:LookupSequence("idle") -- Idle ( do nothin? )
	self.RunAnim = self.Entity:LookupSequence("run") -- simple pumping animation
	
	self:SetSequence(self.DeactAnim) -- Sets the Item as deactivated first :o
	self:SetPlaybackRate(1) -- half speed.
	self:SetCycle(0.6) -- play from Animtion frame 80 :S
	self.AnimTimer=CurTime()+1
	self.Animate=0
	self.Status = -1
	self:SetNWString( "status", "Idle" )
	self.StatusUpdate=CurTime()+3
	self.Timeout = 0
	self.First = 0
	
	self.think = 0
	
	self.Generators = {}
	self.GenSearch = 0
	self.EnergyType = 0
	self.Mute = 0
	
	self.gravity = 1
	self.Debugging = false
	self.Active = 0
	self.env = {}
	
	local phys = self:GetPhysicsObject() --reset physics
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On", "MuteDevices" })
		self.Outputs = Wire_CreateOutputs(self, { "On", "Status", "StatusCode" })
	else
		self.Inputs = {{Name="On"}}
	end
	
	self:NextThink(CurTime() + 1)
	
	--functions to remember for later
	--self:GetResourceAmount("energy")
	--self:ConsumeResource("energy", 100)
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self:EmitSound( "buttons/combine_button_locked.wav" )
		self.Active = 1
		--self.gravity = 1
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", self.Active) end
		self:SetOOO(1)
		
		self.Animate=1
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self:StopSound( "buttons/combine_button_locked.wav" )
		self:EmitSound( "common/warning.wav" )
		self.Active = 0
		self.Status = 0
		self.First = 0
		--self.EnergyType = 0
		self.Timeout = 0
		--self.gravity = 0.00001
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", self.Active) end
		self:SetOOO(0)
		
		if CurTime() - self.AnimTimer > 2 then self.Animate=11 else self.Animate=12 end
		
		
		local gen = self.Generators["Energy"]
		if IsValid(gen) then
			if IsValid(gen.node) and self.node == gen.node then
				if gen.Active==1 then gen:SetActive(0) end
			end
		end
		local gen = self.Generators["Water"]
		if IsValid(gen) then
			if IsValid(gen.node) and self.node == gen.node then
				if gen.Active==1 then gen:SetActive(0) end
			end
		end
		local gen = self.Generators["Oxygen"]
		if IsValid(gen) then
			if IsValid(gen.node) and self.node == gen.node then
				if gen.Active==1 then gen:SetActive(0) end
			end
		end
	end
end

function ENT:SetActive( value )
	if not (value == nil) then
		if (value != 0 and self.Active == 0 ) then
			if IsValid(self.node) then
				self:TurnOn()
			else
				self:EmitSound( "warpdrive/error2.wav" )
				self.Status=2
			end
		elseif (value == 0 and self.Active == 1 ) then
			self:TurnOff()
		end
	else
		if ( self.Active == 0 ) then
			if IsValid(self.node) then
				self:TurnOn()
			else
				self:EmitSound( "warpdrive/error2.wav" )
				self.Status=2
			end
		else
			self:TurnOff()
		end
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	elseif (iname == "MuteDevices") then
		self.Mute = value
	end
end

function ENT:GeneratorSearch()
	self.GenSearch = CurTime()+30
	if not IsValid(self.Generators["Energy"]) or not IsValid(self.Generators["Water"]) or not IsValid(self.Generators["Oxygen"]) then
		print("starting generator search")
		self.EnergyType = 0
		local FusionGens = {}
		local SolarGens = {}
		local WaterGens = {}
		local OxyGens = {}
		for I, v in pairs(self.node.connected) do
			if IsValid(v) then
				local ent = v
				local class = ent:GetClass() print(class)
				if class == "generator_fusion" then FusionGens[I]=ent print("fusion found") end
				if class == "generator_solar" then SolarGens[I]=ent print("solar found") end
				if class == "generator_water" then WaterGens[I]=ent print("water pump found") end
				if class == "generator_water_to_air" then OxyGens[I]=ent print("water splitter found") end
			else
				print("not valid?")
			end
		end
					
		if table.Count(FusionGens) > 0 then
			local biggestF = self
			local volume = 0
			for I, v in pairs(FusionGens) do
				if IsValid(v) then
					local ent = v
					local phys = ent:GetPhysicsObject()
					if (phys:IsValid()) then
						if phys:GetVolume() > volume then
							biggestF = ent
							volume = phys:GetVolume()
						end
					end
				end
			end
			if IsValid(biggestF) then
				if biggestF ~= self then
					self.Generators["Energy"]=biggestF
					self.EnergyType=1
				end
			end
		end
					
		if not IsValid(self.Generators["Energy"]) then
			if self.EnergyType==0 and table.Count(SolarGens) > 0 then self.EnergyType=2 else self.EnergyType=3 end
		end
					
		if table.Count(WaterGens) > 0 then
			local biggestW = self
			local volume = 0
			for I, v in pairs(WaterGens) do
				if IsValid(v) then
					local ent = v
					local phys = ent:GetPhysicsObject()
					if (phys:IsValid()) then
						if phys:GetVolume() > volume then
							biggestW = ent
							volume = phys:GetVolume()
						end
					end
				end
			end
			if IsValid(biggestW) then
				self.Generators["Water"]=biggestW
			end
		end
					
		if table.Count(OxyGens) > 0 then
			local biggestO = self
			local volume = 0
			for I, v in pairs(OxyGens) do
				if IsValid(v) then
					local ent = v
					local phys = ent:GetPhysicsObject()
					if (phys:IsValid()) then
						if phys:GetVolume() > volume then
							biggestO = ent
							volume = phys:GetVolume()
						end
					end
				end
			end
			if IsValid(biggestO) then
				self.Generators["Oxygen"]=biggestO
			end
		end
	end
end

function ENT:Think()
	if self.think >= 10 then
		self.think = 0
		self.BaseClass.Think(self)
		if self.Active == 1 then
			if not IsValid(self.node) then
				self:SetActive(0) Status=2
			else
				if not IsValid(self.Generators["Energy"]) or not IsValid(self.Generators["Water"]) or not IsValid(self.Generators["Oxygen"]) then
					if self.GenSearch < CurTime() then self:GeneratorSearch()	end
				end
				
				if not IsValid(self.Generators["Water"]) then
					--self:SetActive(0)
					self.Status=4
				end
				if not IsValid(self.Generators["Oxygen"]) then
					--self:SetActive(0)
					self.Status=5
				end
				if self.EnergyType == 1 then
					local gen = self.Generators["Energy"]
					if IsValid(gen) then
						if IsValid(gen.node) and self.node == gen.node then
							local energy_ratio = self:GetResourceAmount("energy") / self:GetNetworkCapacity("energy")
							if gen.Active==0 and (energy_ratio <= 0.5 or self.First == 0) then
								gen.Mute = self.Mute
								gen:SetActive(1)
							elseif gen.Active==1 and energy_ratio >= 0.99 then 
								gen:SetActive(0)
							end
						end
					end
				end
				
				
				
				if self:ConsumeResource("energy", 100) == 100 then
					
					local energyleft = math.floor(self:GetResourceAmount("energy")/3)
					
					local gen = self.Generators["Water"]
					if IsValid(gen) then
						if IsValid(gen.node) and self.node == gen.node then
							local energyused = 10 * gen.SizeMultiplier
							local watergained = 80 * gen.SizeMultiplier
							local maxmult = math.floor(2000/energyused)
							if maxmult < 1 then maxmult = 1 end
							local water_ratio = self:GetResourceAmount("water") / self:GetNetworkCapacity("water")
							local mult = math.min(math.floor(energyleft/energyused),maxmult)
							
							if gen.Active==0 and (water_ratio <= 0.5 or self.First == 0)and mult >= 1 then
								gen.Mute = self.Mute
								gen.Multiplier = mult print("set water mult to "..gen.Multiplier)
								gen:SetNetworkedInt( "EnvMultiplier", mult )
								gen:SetActive(1)
							elseif gen.Active==1 and water_ratio >= 0.95 then
								gen.Multiplier = 1
								gen:SetActive(0)
							elseif gen.Active==1 and water_ratio < 0.95 then
								gen.Multiplier = mult
								gen:SetNetworkedInt( "EnvMultiplier", mult )
							end
						end
					end
					
					local gen = self.Generators["Oxygen"]
					if IsValid(gen) then
						if IsValid(gen.node) and self.node == gen.node then
							local energyused = 75 * gen.SizeMultiplier
							local waterused = 250 * gen.SizeMultiplier
							local maxmult = math.floor(2000/energyused)
							if maxmult < 1 then maxmult = 1 end
							local waterleft = math.floor(self:GetResourceAmount("water")*0.5)
							local oxy_ratio = self:GetResourceAmount("oxygen") / self:GetNetworkCapacity("oxygen")
							local floor1 = math.floor(energyleft/energyused)
							local floor2 = math.floor(waterleft/waterused)
							local mult = math.min(floor1,floor2,10)
							
							if gen.Active==0 and (oxy_ratio <= 0.5 or self.First == 0) and mult >= 1 then
								gen.Mute = self.Mute
								gen.Multiplier = mult print("set oxy mult to "..gen.Multiplier)
								gen:SetNetworkedInt( "EnvMultiplier", mult )
								gen:SetActive(1)
							elseif gen.Active==1 and oxy_ratio >= 0.95 then
								gen.Multiplier = 1
								gen:SetActive(0) print("oxygen off")
							elseif gen.Active==1 and oxy_ratio < 0.95 then
								gen.Multiplier = mult
								gen:SetNetworkedInt( "EnvMultiplier", mult )
							end
						end
					end
					
					if self.First == 0 then
						self.First = 1
						self.Status = 1
					end
				elseif self.EnergyType ~= 3 and self.Timeout < 5 then
					self.Status=3
					self.Timeout = self.Timeout + 1
				else
					self:SetActive(0)
					self.Status=3
				end
			end
		else
			--self:Affect()
		end
		
		if self.StatusUpdate < CurTime() and self.Status>-1 then
			if WireAddon == nil then return end
			local message = ""
			if self.Status==0 then message = "Idle"
			elseif self.Status==1 then message = "Activated"
			elseif self.Status==2 then message = "Node not detected."
			elseif self.Status==3 then message = "Insufficient Energy"
			elseif self.Status==4 then message = "Water Pump not detected."
			elseif self.Status==5 then message = "Water Splitter not detected."
			elseif self.Status==6 then message = "Lost Connection with Fusion Generator"
			end
		
			Wire_TriggerOutput(self, "Status", message)
			Wire_TriggerOutput(self, "StatusCode", self.Status)
			self:SetNWString( "status", message )
			self.Status=-1
			self.StatusUpdate = CurTime()+3
		end
	else self.think = self.think + 1 end
	
	if self.Animate>0 then
		if self.AnimTimer < CurTime() then
			local selection = -1
			local cycle = 0
			local rate = 1
			local timer = 2
			if self.Animate==1 then selection=self.ActAnim timer=0.5
			elseif self.Animate==11 then selection=self.DeactAnim cycle=0 timer=2
			elseif self.Animate==12 then selection=self.DeactAnim cycle=0.6 timer=1
			elseif self.Animate==21 then selection=self.RunAnim
			elseif self.Animate==31 then selection=self.IdleAnim
			end
			if selection != -1 then
				self:SetSequence(selection)
				self:ResetSequence(selection)
				self:SetPlaybackRate(rate)
				self:SetCycle(cycle)
				self.AnimTimer=CurTime()+timer
				self.Animate=0
			end
		end
	end
	
	self:NextThink(CurTime() + 0.1)
	return true
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
	if ((self.Active == 1) and (math.random(1, 10) <= 4)) then
		self:TurnOff()
	end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self.damaged = 0
end
