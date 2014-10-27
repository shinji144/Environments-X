AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "apc_engine_stop" )

include('shared.lua')

local Water_Increment = 250
local Generator_Effect = 1 //Less than one means that this generator "leak" resources

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.overdrive = 0
	self.damaged = 0
	self.lastused = 0
	self.Mute = 0
	self.Locked = false
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "Lock" })
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "Lock") then
		if (value > 0) then
			self.Locked = true
		else
			self.Locked = false
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
	self.Entity:StopSound( "apc_engine_start" )
end 

function ENT:AcceptInput(name,activator,caller)
	--No gui thing :u
end
	
--Below Here Deals With Healing--
function ENT:Use( activator, caller )
	local water = self:GetResourceAmount("water")
	local oxygen = self:GetResourceAmount("oxygen")
	local energy = self:GetResourceAmount("energy")
	if(self.Locked)then return end

	if ( activator:IsPlayer() and water >10 and oxygen >10 and energy >30 ) then
		local health = activator:Health()
		local armor = activator:Armor() 
		
		
		

		if health < 250 then
			activator:SetHealth( health + 1 )
			self:ConsumeResource("oxygen",5)
			self:ConsumeResource("water",5)
			self:ConsumeResource("energy",15)
			self:SupplyResource("carbon dioxide",10)
			self:SetOOO(1)
		
			elseif health < 300 then
			activator:SetHealth( 250 )
			
			end
		if armor < 250 then
			activator:SetArmor( armor + 1 )
			self:ConsumeResource("oxygen",5)
			self:ConsumeResource("water",5)
			self:ConsumeResource("energy",15)
			self:SupplyResource("carbon dioxide",10)
			self:SetOOO(1)
			
		elseif armor < 300 then
			activator:SetArmor( 250 )
			end
	else self:SetOOO(0)
	end
	local IsActive=1
	end
if IsActive==1 then
	self:SetOOO(0)
	IsActive=0
end