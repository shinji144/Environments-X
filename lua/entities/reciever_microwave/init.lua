AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

util.PrecacheSound( "explode_9" )
util.PrecacheSound( "ambient/levels/labs/electric_explosion4.wav" )
util.PrecacheSound( "ambient/levels/labs/electric_explosion3.wav" )
util.PrecacheSound( "ambient/levels/labs/electric_explosion1.wav" )
util.PrecacheSound( "ambient/explosions/exp2.wav" )
util.PrecacheSound( "k_lab.ambient_powergenerators" )
util.PrecacheSound( "ambient/machines/thumper_startup1.wav" )
util.PrecacheSound( "coast.siren_citizen" )
util.PrecacheSound( "common/warning.wav" )

include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0

	if WireLib then
		self.WireDebugName = self.PrintName
		self.Inputs = WireLib.CreateInputs(self, { "On" })
		self.Outputs = WireLib.CreateOutputs(self, { "On", "Output" })
	else
		self.Inputs = {{Name="On"}}
	end
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self.Active = 1

		if WireLib then WireLib.TriggerOutput(self, "On", 1) end
		self:SetOOO(1)
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self.Active = 0

		if WireLib then 
			WireLib.TriggerOutput(self, "On", 0)
			WireLib.TriggerOutput(self, "Output", 0)
		end
		self:SetOOO(0)
	end
end

function ENT:TriggerInput(iname, value)
	
end

