AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
ENT.IsLDEC = 1

local Water_Increment = 8 --40 before  --randomize for weather
local Cool_Rate = -50

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.damaged = 0
	self.thinkcount = 0
	self.LDE = {}
	self.NoLDEHeat=true
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
	end
end

function ENT:SetActive() --disable use, lol
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self:SetColor(Color(255, 255, 255, 255))
	self.damaged = 0
end

function ENT:CoolCore()
	local core = self.LDE.Core
	local water = self:GetResourceAmount("energy")
	if(core.LDE.CoreTemp<Cool_Rate)then wateruse=Cool_Rate else wateruse=0 end
	if(water>=math.abs(wateruse) and wateruse<0) then
		WireLib.TriggerOutput( core, "Temperature", core.LDE.CoreTemp)	
		self:ConsumeResource("energy", math.abs(wateruse))
		core.LDE.CoreTemp=core.LDE.CoreTemp+math.abs(wateruse)
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	local entcore = self.LDE.Core
	if (!entcore or !entcore:IsValid()) then	
		self:TurnOff()
	else
		self:TurnOn()
	end
	
	if (self.Active == 1) then
		self:CoolCore()
	end
	self:NextThink(CurTime() + 1)
	return true
end
