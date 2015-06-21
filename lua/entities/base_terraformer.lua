AddCSLuaFile( "base_terraformer.lua" )

ENT.Type 		= "anim"
ENT.Base 		= "base_rd3_entity"

ENT.PrintName	= "Planet Terraformer"
ENT.Author		= "PortalCake"
ENT.Purpose		= "Terraformes Planets"
ENT.Instructions	= ""

list.Set("LSEntOverlayText" , "base_terraformer", {HasOOO = true, num = -1})

if(SERVER)then
	util.PrecacheSound( "Airboat_engine_idle" )
	util.PrecacheSound( "Airboat_engine_stop" )
	util.PrecacheSound( "apc_engine_start" )
		
	local Pressure_Increment = 80
	local Energy_Increment = 10

	function ENT:Initialize()
		self.BaseClass.Initialize(self)
		self.Active = 0
		self.overdrive = 0
		self.damaged = 0
		self.lastused = 0
		self.Mute = 0
		if not (WireAddon == nil) then
			self.WireDebugName = self.PrintName
			self.Inputs = Wire_CreateInputs(self.Entity, { "On", "Overdrive", "Mute", "Multiplier" })
			self.Outputs = Wire_CreateOutputs(self.Entity, {"On", "Overdrive", "EnergyUsage", "GasProduction" })
		else
			self.Inputs = {{Name="On"},{Name="Overdrive"}}
		end
		self.caf = self.caf or {}
		self.caf.custom = self.caf.custom or {}
		self.caf.custom.resource = "oxygen"
		
		self.IsTF = true
		
	end

	local function TurnOnPump(ply, com, args)
		local id = args[1]
		if not id then return end
		local ent = ents.GetByIndex( id )
		if not ent then return end
		if ent.IsTF and ent.TurnOn then
			ent:TurnOn()
		end
	end
	concommand.Add( "TFTurnOn", TurnOnPump )  

	local function TurnOffPump(ply, com, args)
		local id = args[1]
		if not id then return end
		local ent = ents.GetByIndex( id )
		if not ent then return end
		if ent.IsTF and ent.TurnOff then
			ent:TurnOff()
		end
	end
	concommand.Add( "TFTurnOff", TurnOffPump )  

	function ENT:TurnOn()
		if (self.Active == 0) then
			if (self.Mute == 0) then
				self.Entity:EmitSound( "Airboat_engine_idle" )
			end
			self.Active = 1
			if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "On", self.Active) end
			self:SetOOO(1)
		elseif ( self.overdrive == 0 ) then
			self:TurnOnOverdrive()
		end
	end

	function ENT:TurnOff()
		if (self.Active == 1) then
			if (self.Mute == 0) then
				self.Entity:StopSound( "Airboat_engine_idle" )
				self.Entity:EmitSound( "Airboat_engine_stop" )
				self.Entity:StopSound( "apc_engine_start" )
			end
			self.Active = 0
			self.overdrive = 0
			if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "On", self.Active) end
			self:SetOOO(0)
		end
	end

	function ENT:TurnOnOverdrive()
		if ( self.Active == 1 ) then
			if (self.Mute == 0) then
				self.Entity:StopSound( "Airboat_engine_idle" )
				self.Entity:EmitSound( "Airboat_engine_idle" )
				self.Entity:EmitSound( "apc_engine_start" )
			end
			self:SetOOO(2)
			self.overdrive = 1
			if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "Overdrive", self.overdrive) end
		end
	end

	function ENT:TurnOffOverdrive()
		if ( self.Active == 1 and self.overdrive == 1) then
			if (self.Mute == 0) then
				self.Entity:StopSound( "Airboat_engine_idle" )
				self.Entity:EmitSound( "Airboat_engine_idle" )
				self.Entity:StopSound( "apc_engine_start" )
			end
			self:SetOOO(1)
			self.overdrive = 0
			if not (WireAddon == nil) then Wire_TriggerOutput(self.Entity, "Overdrive", self.overdrive) end
		end	
	end

	function ENT:SetActive( value, caller )
		umsg.Start("TF_Open_Menu", caller)
			umsg.Entity(self)
		umsg.End()
	end

	function ENT:TriggerInput(iname, value)
		if (iname == "On") then
			self:SetActive(value)
		elseif (iname == "Overdrive") then
			if (value > 0) then
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

	function ENT:Damage()
		if (self.damaged == 0) then self.damaged = 1 end
		if ((self.Active == 1) and (math.random(1, 10) <= 4)) then
			self:TurnOff()
		end
	end

	function ENT:Repair()
		self.BaseClass.Repair(self)
		self.Entity:SetColor(255, 255, 255, 255)
		self.damaged = 0
	end

	function ENT:Destruct()
		if CAF and CAF.GetAddon("Life Support") then
			CAF.GetAddon("Life Support").Destruct( self.Entity, true )
		end
	end

	function ENT:OnRemove()
		self.BaseClass.OnRemove(self)
		self.Entity:StopSound( "Airboat_engine_idle" )
	end

	function ENT:Think()
		self.BaseClass.Think(self)
		if ( self.Active == 1 ) then

		end
		self.Entity:NextThink( CurTime() + 1 )
		return true
	end

else
	language.Add("base_terraformer", "Base Terraformer")

	local OOO = {}
	OOO[0] = "Off"
	OOO[1] = "On"
	OOO[2] = "Overdrive"

	local MainFrames = {}

	local function OpenMenu(um)
		local ent = um:ReadEntity()
		if not ent then return end
		if MainFrames[ent:EntIndex()] and MainFrames[ent:EntIndex()]:IsActive() and MainFrames[ent:EntIndex()]:IsVisible() then MainFrames[ent:EntIndex()]:Close() end
		
		local MainFrame= vgui.Create("DFrame")
		MainFrames[ent:EntIndex()] = MainFrame
		MainFrame:SetDeleteOnClose() 
		MainFrame:SetDraggable( false ) 
		MainFrame:SetTitle("Terraformer "..tostring(ent:EntIndex()).."'s Control Panel")
		MainFrame:SetSize(600, 350)
		MainFrame:Center()
		
		local button = vgui.Create("DButton", MainFrame)
		button:SetPos(225, 290)
		button:SetSize(180, 30)
		if ent:GetOOO() == 1 then
			button:SetText("Turn off")
			function button:DoClick()
				RunConsoleCommand("TFTurnOff", ent:EntIndex())
			end
		else
			button:SetText("Turn on")
			function button:DoClick()
				RunConsoleCommand("TFTurnOn", ent:EntIndex())
			end
		end

		MainFrame:MakePopup()
	end
	usermessage.Hook("TF_Open_Menu", OpenMenu)
end		
