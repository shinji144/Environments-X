AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self.Active = 0
	self.damaged = 0
	self.sequence = -1
	self.thinkcount = 0
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = WireLib.CreateInputs(self, { "On", "Multiplier" })
		self.Outputs = Wire_CreateOutputs(self, { "Out" })
	end
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self.Active = 1
		self:SetOOO(1)
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self.Active = 0
		self:SetOOO(0)
		if WireAddon then Wire_TriggerOutput(self, "Out", 0) end
	end
end

function ENT:SetActive(value) --disable use, lol
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

function ENT:TriggerInput(iname, value)
	if iname == "On" then
		if value > 0 then
			if self.Active == 0 then
				self:TurnOn()
			end
		else
			if self.Active == 1 then
				self:TurnOff()
			end
		end
	elseif iname == "Multiplier" then
		self:SetMultiplier(value)
	end
end

function ENT:Generate()
	local needed = self:GetSizeMultiplier()*50
	local amt = self:ConsumeResource("steam", needed)
	self:SupplyResource("energy", amt)
	self:SupplyResource("water", amt*0.4)
end

function ENT:Think()
	if self.Active == 1 then
		self:Generate()
	end
	
	self:NextThink(CurTime() + 1)
	return true
end