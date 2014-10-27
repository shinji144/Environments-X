AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

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

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	if not (WireAddon == nil) then
		self.Inputs = Wire_CreateInputs(self, { "Deploy", "ReelInPlug", "EjectPlug", "FlowRate" })
		self.Outputs = Wire_CreateOutputs(self, { "InUse", "Rate" })
	end
	self:SetModel("models/props_lab/tpplugholder_single.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self.damaged = 0
	self.ropelength = 500
	self.ropemax = 10000
	self.OtherSocket = nil
	self.MyPlug = nil
	self.Weld = nil
	self.HoseStep = CurTime()
	self.IsConnecting = false
	
	self.DeployedPlug = 0
	self.PumpOn = 0
	self.Connected = 0
	self.reel_status = REEL_STOP
	self.pump_status = PUMP_NONE
end

function ENT:Setup( pump, rate, hoselength )
	self.pump_active = pump or true
	self.pump_rate = rate or 256
	self.hose_length = hoselength or 512
	
	if (pump == 1) then 
		self.pump_status = PUMP_READY
	end
	
	self:SupplyResource("energy", 0)
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
	if WireAddon then Wire_TriggerOutput(self, "Rate", self.pump_rate) end
	
	if (self.Weld and !self.Weld:IsValid()) or (self.MyPlug and !self.MyPlug:IsValid()) or (self.OtherSocket and !self.OtherSocket:IsValid()) or (self.plug and !self.plug:IsValid()) then
		-- If we were unplugged, reset the plug and socket to accept new ones.
		self:ResetPlug()
	end
	
	if (self.DeployedPlug == 0) then --no plug deployed
		if (self.Connected == 0) then --no plug connected
			local sockCenter = self:LocalToWorld( Vector(5,13,10) )
			local local_ents = ents.FindInSphere( sockCenter, PLUG_IN_ATTACH_RANGE )
			for key, plug in pairs(local_ents) do
				// If we find a plug, try to attach it to us
				if ( plug:IsValid() and plug.is_plug) and (plug.MySocket == nil) and (plug:IsPlayerHolding() == false) then --found a plug and not it's not in another socket --player isn't holding the plug spamming connections
						--print("Attempting Attach - "..tostring(plug:IsPlayerHolding()))
					--if plug:GetPos():Distance(self) < 2048 then
						self:AttachPlug(plug)
					--end
				end
			end
		end
		
	elseif (self.reel_status > REEL_STOP) then --plug deployed and we need to do something with the reel
		if IsValid(self.plug) then
			local ephys = self.plug:GetPhysicsObject()
			if ephys:IsValid() then
				if ephys:IsMoveable() == false then
					ephys:EnableMotion(true)
					ephys:Wake()
				end
			end
		end
		if ((type(self.Hose) ~= "Entity" or type(self.rope) ~= "Entity") and IsValid(self.plug) and self.HoseStep <= CurTime()) then	--recreate the hose if something removes it
			--print("No Rope - "..type(self.Hose))
			self:EmitSound( "Buttons.snd17" )
	
			local LPos1 = Vector(5,13,10)
			local LPos2 = Vector(10,0,0)
			local width = 3
			local material = "cable/cable2"
			local plug = self.plug

			local dist = (self:GetPos() - self.plug:GetPos()):Length()
			self.Hose, self.rope = constraint.Elastic( self, plug, 0, 0, LPos1, LPos2, 500, 0, 0, material, width, true )
			local ctable = {
				Type 		= "LSWinch",
				pl				= self:GetPlayer(),
				Ent1			= self,
				Ent2			= plug,
				Bone1		= Bone1,
				Bone2		= Bone2,
				LPos1		= LPos1,
				LPos2		= LPos2,
				width		= width,
				material	= material
			}
			self.rope.Type = "" --prevents the duplicator from making this weld
			self.Hose:SetTable( ctable )
	
			plug:DeleteOnRemove( self.Hose )
			self:DeleteOnRemove( self.Hose )
			self:DeleteOnRemove( self.plug )
			self.Hose:DeleteOnRemove( self.rope )
	
			self.ropemax = (self.hose_length*100)
			self.ropelength = math.min(dist+100,self.ropemax)
		end
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
	
	if self.PumpOn == 1 then -- If we are connected, transfer resources
		if (self.OtherSocket and self.OtherSocket:IsValid()) then
			if self.pump_active == 1 then --pump it
				local energyneeded = math.abs(math.floor(256 / 100 * Energy_Increment))
				if (energyneeded >= 0) then
					if (self:GetResourceAmount("energy") >= energyneeded) then
						local used = self:ConsumeResource( "energy", energyneeded )
						self.OtherSocket.pump_status = PUMP_ACTIVE
					elseif (energyneeded > 0) then
						self.OtherSocket.pump_status = PUMP_NO_POWER
						rate = 0
					end
				end
			end
			if rate == 0 then return end
			for res,v in pairs(self.node.resources) do --actually send it
				if self.OtherSocket:GetNetworkCapacity(res) > (self.OtherSocket:GetResourceAmount(res) + self.pump_rate) then
					local amt = self:ConsumeResource(res, self.pump_rate)
					self.OtherSocket:SupplyResource(res, amt)	
				else
					local amt = self.OtherSocket:GetNetworkCapacity(res) - self.OtherSocket:GetResourceAmount(res)
					amt = self:ConsumeResource(res, amt)
					self.OtherSocket:SupplyResource(res, amt)	
				end	
			end
		end
	end
	
	self:ShowOutput()
	if (self.PumpOn == 1) or (self.DeployedPlug == 0 and self.Connected == 0) then
		self:NextThink( CurTime() + 1 )
		return true
	end
end

function ENT:ReelInPlug()
	if !(self.DeployedPlug == 1) then return end
	self:EmitSound( "Buttons.snd17" )
	self.ropemax = 0
	self.reel_status = REEL_IN
	constraint.RemoveConstraints( self.plug, "Weld")
	local phys = self.plug:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion( true )
		phys:Wake()
	end
	self.plug.MySocket = self
end

function ENT:EjectPlug()
	if !(self.Connected == 1) then return end
	if (self.OtherSocket == nil) then return end
	self:EmitSound( "Buttons.snd17" )
	constraint.RemoveConstraints( self.OtherSocket.plug, "Weld")
end

function ENT:AcceptInput(name,activator,caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
		if (self.DeployedPlug == 0 and self.Connected == 0) then
			self:Deploy()
		elseif (self.DeployedPlug == 1) then
			self:ReelInPlug()
		elseif (self.Connected == 1) then
			self:EjectPlug()
		end
	end
end

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
	elseif(iname=="FlowRate")then
		if(value>0)then
			self.pump_rate = value
		end
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	--if (self.plug and self.plug:IsValid()) then self.plug:Remove() end
	if (self.MyPlug and self.MyPlug:IsValid()) then self.MyPlug.MySocket = nil end
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

function ENT:AttachPlug( plug )
	if not plug or not plug.socket then return end
	
	--if IsValid(plug.socket:GetParent()) then		--parent checking, not really needed so we'll leave it commented so people can't hax the elastic
		if (type(plug.socket.Hose) == "Entity") then		--Remove the Elastic so parented pumps don't go batshit insane, Elastic will remake itself.
			plug.socket.Hose:Remove()
			plug.socket.HoseStep = CurTime() + 0.5
			plug.socket:NextThink( CurTime() + 0.5 )
			--print("Removing Hose")
		else 
			--print(type(plug.Hose))
		end
	
		if (type(plug.socket.rope) == "Entity") then
			plug.socket.rope:Remove()
			plug.socket.HoseStep = CurTime() + 0.5
			plug.socket:NextThink( CurTime() + 0.5 )
			--print("Removing Rope")
		else 
			--print(type(plug.rope))
		end
		
	
		if self.IsConnecting == false then
			self.IsConnecting = true
			plug.socket.Hose = nil
			plug.socket.rope = nil
			self.HoseStep = CurTime() + 0.5
			self:NextThink( CurTime() + 0.5 )
			timer.Simple(0.25,function() self:AttachPlug(plug) end)
			return
		elseif self.IsConnecting == true then
			self.IsConnecting = false
		end
	--end
	
	// Set references between them
	plug.MySocket = self
	self.MyPlug = plug
	self.OtherSocket = plug.socket
	plug.socket.OtherSocket = self
	
	// Position plug
	local phys = plug:GetPhysicsObject()
		phys:EnableMotion( true )
		plug:SetPos( self:LocalToWorld( Vector(5,13,10) ) )
		plug:SetAngles( self:GetAngles() )
	phys:Wake() --force plug to update
	
	// Constrain together
	self.Weld = constraint.Weld( self, plug, 0, 0, PLUG_IN_SOCKET_CONSTRAINT_POWER, true, false )
	self.Weld.Type = "" --prevents the duplicator from making this weld
	if (not self.Weld) then
		self.MyPlug = nil
		plug.MySocket = nil
		return
	end
	
	-- Prepare clearup incase one is removed
	plug:DeleteOnRemove( self.Weld )
	self:DeleteOnRemove( self.Weld )
	
	self.Connected = 1 --we has plug

	self.OtherSocket.pump_status = PUMP_ACTIVE --start their pump
	
	self.OtherSocket.PumpOn = 1 --use their pump instead
	self.PumpOn = 0
	
	if WireAddon then Wire_TriggerOutput(self, "InUse", 1) end
end

function ENT:Deploy()
	self:EmitSound( "Buttons.snd17" )
	
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
	self.rope.Type = "" --prevents the duplicator from making this weld
	self.nocollide.Type = "" --prevents the duplicator from making this weld
	self.Hose:SetTable( ctable )
	
	plug:DeleteOnRemove( self.Hose )
	plug:DeleteOnRemove( self.nocollide )
	self:DeleteOnRemove( self.Hose )
	self:DeleteOnRemove( self.plug )
	self.Hose:DeleteOnRemove( self.nocollide )
	self.Hose:DeleteOnRemove( self.rope )
	
	self.ropelength = 50
	self.ropemax = (self.hose_length*100)
	self.DeployedPlug = 1
	self.reel_status = REEL_OUT
	--print(type(self.Hose).." "..type(self.rope))
	if WireAddon then Wire_TriggerOutput(self, "InUse", 1) end
end