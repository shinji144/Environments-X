AddCSLuaFile( "base_temperature_exchanger.lua" )

ENT.Type 		= "anim"
ENT.Base 		= "base_rd3_entity"
ENT.PrintName 	= "Temperature Exchanger"

list.Set("LSEntOverlayText" , "base_temperature_exchanger", {HasOOO = true, num = -1})

if(SERVER)then
	function ENT:Initialize() self:Remove() end
	function ENT:IsActive() end
	function ENT:SetStartSound(sound) end
	function ENT:SetStopSound(sound) end
	function ENT:SetAlarmSound(sound) end
	function ENT:SetDefault() end
	function ENT:SetRange(amount) end
	function ENT:GetRange() end
	function ENT:SetTempGiven(amount) end
	function ENT:CoolDown(temp) end
	function ENT:GetLSClass() end
	function ENT:TurnOn() end
	function ENT:TurnOff() end
	function ENT:TriggerInput(iname, value) end
	function ENT:Think() end
	function ENT:ConsumeBaseResources() end
	function ENT:CheckResources() end
	function ENT:Damage() end
	function ENT:Repair() end
	function ENT:Destruct() end
	function ENT:OnRemove() end
end		
