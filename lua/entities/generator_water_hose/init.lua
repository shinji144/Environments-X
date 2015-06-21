AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "Airboat_engine_idle" )
util.PrecacheSound( "Airboat_engine_stop" )
util.PrecacheSound( "apc_engine_start" )
include('shared.lua')
local Pressure_Increment = 80
local Energy_Increment = 10

util.PrecacheSound( "Buttons.snd17" )

ENT.OverlayDelay = 0

local Ground = 1 + 0 + 2 + 8 + 32
local PLUG_IN_SOCKET_CONSTRAINT_POWER = 1000
local PLUG_IN_ATTACH_RANGE = 13
local Energy_Increment = 10

local PUMP_NONE = 0			--no pump installed
local PUMP_NO_POWER = 1		--pump has no power
local PUMP_READY = 2		--pump ready for connection
local PUMP_ACTIVE = 3		--pump on
local PUMP_RECEIVING = 4	--not used

local REEL_STOP = 0	--do no reeling
local REEL_OUT = 1	--let plug hose out
local REEL_IN = 2	--pull plug hose back in

local pstatus = {}
	pstatus[PUMP_NONE] = "None"
	pstatus[PUMP_NO_POWER] = "Needs Energy!"
	pstatus[PUMP_READY] = "Ready"
	pstatus[PUMP_ACTIVE] = "Active"
	pstatus[PUMP_RECEIVING] = "Receiving"
	
/*function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.overdrive = 0
	self.damaged = 0
	self.lastused = 0
	self.sequence = -1
	self.thinkcount = 0
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self.Mute = 0
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On", "Overdrive", "Mute", "Multiplier" })
		self.Outputs = Wire_CreateOutputs(self, {"On", "Overdrive", "EnergyUsage", "WaterProduction" })
	else
		self.Inputs = {{Name="On"},{Name="Overdrive"}}
	end

	self.ropelength = 500
	self.ropemax = 10000
	self.OtherSocket = nil
	self.MyPlug = nil
	self.Weld = nil
	
	self.DeployedPlug = 0
	self.PumpOn = 0
	self.Connected = 0
	self.reel_status = REEL_STOP
	self.pump_status = PUMP_NONE
end*/

function ENT:TurnOn()
	if (self.Active == 0) then
		if (self.Mute == 0) then
			self:EmitSound( "Airboat_engine_idle" )
		end
		self.Active = 1
		if WireAddon then Wire_TriggerOutput(self, "On", self.Active) end
		--self.sequence = self.Entity:LookupSequence("walk")
		if self.sequence and self.sequence != -1 then
			self:SetSequence(self.sequence)
			self:ResetSequence(self.sequence)
			self:SetPlaybackRate( 1 )
		end
		self:SetOOO(1)
	elseif ( self.overdrive == 0 ) then
		self:TurnOnOverdrive()
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		if (self.Mute == 0) then
			self:StopSound( "Airboat_engine_idle" )
			self:EmitSound( "Airboat_engine_stop" )
			self:StopSound( "apc_engine_start" )
		end
		self.Active = 0
		self.overdrive = 0
		if WireAddon then Wire_TriggerOutput(self, "On", self.Active) end
		self:SetOOO(0)
		--self.sequence = self.Entity:LookupSequence("idle")
		if self.sequence and self.sequence != -1 then
			self:SetSequence(self.sequence)
			self:ResetSequence(self.sequence)
			self:SetPlaybackRate( 1 )
		end
	end
end

function ENT:TurnOnOverdrive()
	if ( self.Active == 1 ) then
		if (self.Mute == 0) then
			self:StopSound( "Airboat_engine_idle" )
			self:EmitSound( "Airboat_engine_idle" )
			self:EmitSound( "apc_engine_start" )
		end
		self:SetOOO(2)
		self.overdrive = 1
		if WireAddon then Wire_TriggerOutput(self, "Overdrive", self.overdrive) end
	end
end

function ENT:TurnOffOverdrive()
	if ( self.Active == 1 and self.overdrive == 1) then
		if (self.Mute == 0) then
			self:StopSound( "Airboat_engine_idle" )
			self:EmitSound( "Airboat_engine_idle" )
			self:StopSound( "apc_engine_start" )
		end
		self:SetOOO(1)
		self.overdrive = 0
		if WireAddon then Wire_TriggerOutput(self, "Overdrive", self.overdrive) end
	end	
end

function ENT:SetActive( value )
	if (value) then
		if (value != 0 and self.DeployedPlug == 0 ) then
			self:Deploy()
		elseif (value == 0 and self.DeployedPlug == 1 ) then
			self:ReelInPlug()
		end
	else
		if ( self.DeployedPlug == 0 ) then
			self.lastused = CurTime()
			self:Deploy()
		else
			if ((( CurTime() - self.lastused) < 2 ) and ( self.overdrive == 0 )) then
				self:TurnOnOverdrive()
			else
				self.overdrive = 0
				self:ReelInPlug()
			end
		end
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	elseif (iname == "Overdrive") then
		if (value ~= 0) then
			self:TurnOnOverdrive()
		else
			self:TurnOffOverdrive()
		end
	end
	if (iname == "Mute") then
		if (value > 0) then
			self.Mute = 1
		else
			self.Mute = 0
		end
	end
	if (iname == "Multiplier") then
		self:SetMultiplier(value)
	end
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	if not (WireAddon == nil) then
		self.Inputs = Wire_CreateInputs(self, { "Deploy", "ReelInPlug", "EjectPlug" })
		self.Outputs = Wire_CreateOutputs(self, { "InUse" })
	end
	self.overdrive = 0

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self.damaged = 0
	self.hose_length = 500
	self.ropelength = 500
	self.ropemax = 1000
	self.OtherSocket = nil
	self.MyPlug = nil
	self.Weld = nil
	
	self.DeployedPlug = 0
	self.PumpOn = 0
	self.Connected = 0
	self.reel_status = REEL_STOP
	self.pump_status = PUMP_NONE
end

function ENT:ResetPlug()
	if (self.DeployedPlug == 1) then
		if (self.plug:IsValid()) then
			constraint.RemoveConstraints( self.plug, "Weld")
			self.plug.MySocket = nil
		elseif (self.DeployedPlug == 1 and !self.plug:IsValid()) then
			self.ropelength = 0
			self.ropemax = 0
			self.Hose = nil
			self.rope = nil
			self.plug = nil
			self.reel_status = REEL_STOP
		end
		self.OtherSocket = nil
		self.DeployedPlug = 0
		
	elseif (self.Connected == 1) then
		
		if (self.MyPlug:IsValid() and self.MyPlug.MySocket == self) then
			self.MyPlug.MySocket = nil
		end
		if (self.OtherSocket:IsValid()) then
			self.OtherSocket.pump_status = PUMP_READY
			self.OtherSocket.PumpOn = 0
			self.OtherSocket.OtherSocket = nil
		end
		if (self.pump_active == 1) then
			self.pump_status = PUMP_READY
		end	
		
		self.MyPlug = nil
		self.Weld = nil
		self.OtherSocket = nil
		self.Connected = 0
	end
	
	self.PumpOn = 0
	if WireAddon then Wire_TriggerOutput(self, "InUse", 0) end
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if (self.Weld and !self.Weld:IsValid()) or (self.MyPlug and !self.MyPlug:IsValid()) or (self.OtherSocket and !self.OtherSocket:IsValid()) or (self.plug and !self.plug:IsValid()) then
		-- If we were unplugged, reset the plug and socket to accept new ones.
		self:ResetPlug()
	end
	
	if (self.DeployedPlug == 0) then --no plug deployed
		
	elseif (self.reel_status > REEL_STOP) then --plug deployed and we need to do something with the reel
		if (self.reel_status == REEL_OUT) then
			local dist = (self:GetPos() - self.plug:GetPos()):Length()
			if (self.ropelength <= self.ropemax) and (dist > self.ropelength - 32 ) then
				self.ropelength = self.ropelength + 50
				if (self.Hose and self.Hose:IsValid()) then
					self.Hose:Fire("SetSpringLength", self.ropelength, 0)
				else
					self.ropemax = 0
					self.ropelength = 0
				end
				if (self.rope and self.rope:IsValid()) then
					self.rope:Fire("SetLength", self.ropelength, 0)
				else
					self.ropemax = 0
					self.ropelength = 0
				end
			end
		elseif (self.reel_status == REEL_IN) then
			if (self.ropelength > 0) then
				if (self.ropelength > 200) then --reel in faster
					self.ropelength = self.ropelength - 20
				elseif (self.ropelength > 0) then
					self.ropelength = self.ropelength - 10
				else
					self.ropelength = 0
				end
				if (self.Hose:IsValid() and self.rope:IsValid())then
					self.Hose:Fire("SetSpringLength", self.ropelength, 0)
					self.rope:Fire("SetLength", self.ropelength, 0)
				else
					self.ropelength = 0
				end
			else
				if (self.plug and self.plug:IsValid()) then self.plug:Remove() end
				self.Hose = nil
				self.rope = nil
				self.plug = nil
				self.DeployedPlug = 0
				self.reel_status = REEL_STOP
				if WireAddon then Wire_TriggerOutput(self, "InUse", 0) end
			end
		end
	end
	
	if self.DeployedPlug == 1 then -- If we are connected, transfer resources
		self:Pump_Water(self.plug:WaterLevel())
	end
	
	if (self.Active == 1) or (self.DeployedPlug == 0 and self.Connected == 0) then
		self:NextThink( CurTime() + 1 )
		return true
	end
end

function ENT:ReelInPlug()
	if !(self.DeployedPlug == 1) then return end
	self:EmitSound( "Buttons.snd17" )
	self:StopSound( "Airboat_engine_idle" )
	self:StopSound( "apc_engine_start" )
	self:EmitSound( "Airboat_engine_stop" )
	self.ropemax = 0
	self.reel_status = REEL_IN
	constraint.RemoveConstraints( self.plug, "Weld")
	local phys = self.plug:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion( true )
		phys:Wake()
	end
	self.plug.MySocket = self
	
	self:SetOOO(0)
end

/*function ENT:AcceptInput(name,activator,caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
		if (self.DeployedPlug == 0 and self.Connected == 0) then
			self:Deploy()
		elseif (self.DeployedPlug == 1) then
			self:ReelInPlug()
		end
	end
end*/

function ENT:TriggerInput(iname, value)
	if (iname == "Deploy") then
		if (self.DeployedPlug == 0 and self.Connected == 0) then
			self:Deploy()
		end
	elseif (iname == "ReelInPlug") then
		if (self.DeployedPlug == 1) then
			self:ReelInPlug()
		end
	elseif (iname == "EjectPlug") then
		if (self.Connected == 1) then
			self:EjectPlug()
		end
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	--if (self.plug and self.plug:IsValid()) then self.plug:Remove() end
	if (self.MyPlug and self.MyPlug:IsValid()) then self.MyPlug.MySocket = nil end
	self:StopSound( "Airboat_engine_idle" )
end

--this needs to be done client side
function ENT:ShowOutput()
	--local resbuf = "\nResources available:\n" .. self.Entity:GetAllResourcesAmountsText()
	--if (self.pump_status > PUMP_NONE) then
		--self:SetOverlayText("Supply Connector\nHose Length: "..self.hose_length.."\nPump: "..pstatus[self.pump_status].."\nPump Rate: "..self.pump_rate.."\n"..resbuf)
	--else
		--self:SetOverlayText("Supply Connector\nHose Length: "..self.hose_length.."\nPump: "..pstatus[self.pump_status].."\n"..resbuf)
	--end
end

function ENT:Deploy()
	self:SetOOO(1)
	
	self:EmitSound( "Buttons.snd17" )
	self:EmitSound( "apc_engine_start" )
	self:EmitSound( "Airboat_engine_idle" )
	
	local LPos1 = Vector(5,13,10)
	local LPos2 = Vector(10,0,0)
	local width = 3
	local material = "cable/cable2"
	local pos = self:LocalToWorld( Vector(15,13,10) )
	local ang = self:GetAngles() + Angle(180,0,0)
	
	local plug = ents.Create( "prop_physics" )
	plug:SetModel( "models/props_lab/tpplug.mdl" )
	plug:SetPos( pos )
	plug:SetAngles( ang )
	plug:SetColor( Color(255, 255, 255, 255) )
	plug:Spawn()
		
		local phys = plug:GetPhysicsObject()
			phys:EnableGravity( true )
			phys:EnableMotion( true )
			phys:SetVelocity(self:GetForward() * 50)
		phys:Wake()
		plug.is_plug = true
		plug.MySocket = nil
		plug.socket = self
		plug:SetVar('Owner',self:GetPlayer())
		
	self.plug = plug
	
	self.nocollide = constraint.NoCollide( self, plug, 0, 0 )
	self.Hose, self.rope = constraint.Elastic( self, plug, 0, 0, LPos1, LPos2, 500, 0, 0, material, width, true )
	local ctable = {
		Type 		= "LSWinch",
		pl			= self:GetPlayer(),
		Ent1		= self,
		Ent2		= plug,
		Bone1		= Bone1,
		Bone2		= Bone2,
		LPos1		= LPos1,
		LPos2		= LPos2,
		width		= width,
		material	= material
	}
	self.Hose:SetTable( ctable )
	
	plug:DeleteOnRemove( self.Hose )
	plug:DeleteOnRemove( self.nocollide )
	self:DeleteOnRemove( self.Hose )
	self:DeleteOnRemove( self.plug )
	self.Hose:DeleteOnRemove( self.nocollide )
	self.Hose:DeleteOnRemove( self.rope )
	
	self.ropelength = 50
	self.ropemax = (self.hose_length*2)
	self.DeployedPlug = 1
	self.reel_status = REEL_OUT
	
	if WireAddon then Wire_TriggerOutput(self, "InUse", 1) end
end


function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
	end
end

function ENT:Pump_Water(waterlevel)
	local energy = self:GetResourceAmount("energy")
	local einc = Energy_Increment + (self.overdrive*Energy_Increment*3)

	einc = (math.ceil(einc * self:GetSizeMultiplier())) * self:GetMultiplier()
	if WireAddon then Wire_TriggerOutput(self, "EnergyUsage", math.Round(einc)) end
	if (waterlevel > 0 and energy >= einc) then //seems to be problem when welding(/freezing when not with CAF)
		local winc = (math.ceil(Pressure_Increment * (waterlevel / 3))) * self:GetMultiplier() --Base water generation on the amount it is in the water
		
		if ( self.overdrive == 1 ) then
			winc = winc * 3
			einc = einc * 2
			Environments.DamageLS(self, math.random(2, 3))
		end
		winc = math.ceil(winc * self:GetSizeMultiplier())
		self:ConsumeResource("energy", einc)
		self:SupplyResource("water", winc)
		if WireAddon then Wire_TriggerOutput(self, "WaterProduction", math.Round(winc)) end
	else
		self:TurnOff()
	end
end

