AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
ENT.IsLDEC = 1

local Water_Increment = 8 --40 before  --randomize for weather
local Cool_Rate = 40

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.damaged = 0
	self.thinkcount = 0
	self.LDE = {}
	
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

function ENT:CoolNode()
	local water = self:GetResourceAmount("water")
	local Rate = (Cool_Rate*(LDE:GetHealth(self)/100))
	for k,v in pairs(self.node.connected) do
		if v and v:IsValid() then
			if(not v.LDE)then return end --Wot.... why isnt there a lde
			v.LDE.Temperature = v.LDE.Temperature or 0
			if(v.LDE.Temperature>0)then
				if(v.LDE.Temperature<Rate) then
					Rate=v.LDE.Temperature
				end
				if(water>=Rate and Rate>0) then
					self:ConsumeResource("water", Rate)
					self:SupplyResource("steam",math.Round(Rate/2.5))
					LDE.HeatSim.CoolTemperture(v,Rate)
					--v.LDE.Temperature=v.LDE.Temperature-Rate
					--v:SetNWInt("LDEEntTemp", v.LDE.Temperature)
				end
				//return 
			end
		end
	end
end

function ENT:CoolCore()
	local core = self.LDE.Core
	local water = self:GetResourceAmount("water")
	local Rate = (Cool_Rate*(LDE:GetHealth(self)/100))*core.Data.CoolBonus
	if(core.LDE.CoreTemp<Rate) then
		Rate=core.LDE.CoreTemp
	end
	if(water>=Rate and Rate>0) then
		self:TurnOn()
		WireLib.TriggerOutput( core, "Temperature", core.LDE.CoreTemp or 0 )	
		self:ConsumeResource("water", Rate)
		self:SupplyResource("steam",math.Round(Rate/2.5))
		core.LDE.CoreTemp=core.LDE.CoreTemp-Rate
	else
		self:TurnOff()
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	local entcore = self.LDE.Core
	local node = self.node
	if (!entcore or !entcore:IsValid()) then
		if(node and node:IsValid())then
			self:TurnOn()
			self:CoolNode()
		else
			self:TurnOff()
		end
	else
		self:CoolCore()
	end
	
	self:NextThink(CurTime() + 1)
	return true
end
