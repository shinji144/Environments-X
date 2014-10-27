AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "apc_engine_stop" )

include('shared.lua')

local Water_Increment = 40
local Generator_Effect = 1 //Less than one means that this generator "leak" resources

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.Flood = 0
	self.damaged = 0
	self.lastused = 0
	self.Mute = 0
	self.Multiplier = 1
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "Water", "Flood", "Mute", "Multiplier" })
	else
		self.Inputs = {{Name="Water"},{Name="Flood"}}
	end
end

function ENT:TurnOn()
	if (self.Active == 0) then
		if (self.Mute == 0) then
			
		end
		self.Active = 1
		self:SetOOO(1)
	elseif ( self.Flood == 0 ) then
		self:TurnOnFlood()
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		if (self.Mute == 0) then
			
		end
		self.Active = 0
		self.Flood = 0
		self:SetOOO(0)
	end
end

function ENT:TurnOnFlood()
	if ( self.Active == 1 ) then
		if (self.Mute == 0) then
			
		end
		self:SetOOO(2)
		self.Flood = 1
	end
end

function ENT:TurnOffFlood()
	if ( self.Active == 1 and self.Flood == 1) then
		if (self.Mute == 0) then
			
		end
		self:SetOOO(1)
		self.Flood = 0
	end	
end

function ENT:SetActive( value )
	if (value) then
		if (value != 0 and self.Active == 0 ) then
			self:TurnOn()
		elseif (value == 0 and self.Active == 1 ) then
			self:TurnOff()
		end
	else
		if ( self.Active == 0 ) then
			self.lastused = CurTime()
			self:TurnOn()
		else
			if ((( CurTime() - self.lastused) < 2 ) and ( self.Flood == 0 )) then
				self:TurnOnFlood()
			else
				self.Flood = 0
				self:TurnOff()
			end
		end
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "Water") then
		self:SetActive(value)
	elseif (iname == "Flood") then
		if (value ~= 0) then
			self:TurnOnFlood()
		else
			self:TurnOffFlood()
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
		if (value > 0) then
			self.Multiplier = value
		else
			self.Multiplier = 1

		end	
	end
end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
	end
	if ((self.Active == 1) and (math.random(1, 10) <= 4)) then
		self:TurnOff()
	end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self.Entity:SetColor(Color(255, 255, 255, 255))
	self.damaged = 0
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct( self.Entity, true )
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self.Entity:StopSound( "apc_engine_start" )
end

function ENT:Proc_Water()
	local water = self:GetResourceAmount("water")
//	local co2 = self:GetResourceAmount("hydrogen")
	local winc = Water_Increment + (self.Flood*Water_Increment)
	winc = (math.Round(winc * self:GetMultiplier())) * self.Multiplier

	if (water >= winc) then
		if ( self.Flood == 1 ) then
			if CAF and CAF.GetAddon("Life Support") then
				CAF.GetAddon("Life Support").DamageLS(self, math.random(2, 3))
			else
				self:SetHealth( self:Health( ) - math.random(2, 3))
				if self:Health() <= 0 then
					self:Remove()
				end
			end
		end
		self:ConsumeResource("water", winc)
//		self:ConsumeResource("hydrogen", winc)

		winc = math.Round(winc * Generator_Effect)
		
		local supplyO2 = math.Round(winc/2)
		local leftO2 = self:SupplyResource("oxygen", supplyO2)
		
//		local supplyH = winc*2
//		local leftH = self:SupplyResource("oxygen",supplyH)
		
		if self.environment then
			self.environment:Convert(1, 0, leftO2)
//			self.environment:Convert(-1, 3, leftH)
		end
	else
		self:TurnOff()
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if ( self.Active == 1 ) then self:Proc_Water() end
	if((self.damaged==1) and (math.random(1, 20) <= 2) ) then self:Repair() end
	
	self.Entity:NextThink( CurTime() + 1 )
	return true
end