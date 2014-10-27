AddCSLuaFile( "base_air_exchanger.lua" )

ENT.Type 		= "anim"
ENT.Base 		= "base_rd3_entity"
ENT.PrintName 	= "Air Exchanger"

list.Set("LSEntOverlayText" , "base_air_exchanger", {HasOOO = true, num = -1})

if(SERVER)then

	function ENT:Initialize() self:Remove() end
	function ENT:IsActive() end
	function ENT:SetStartSound(sound) end
	function ENT:SetStopSound(sound) end
	function ENT:SetAlarmSound(sound) end
	function ENT:SetDefault() end
	function ENT:SetRange(amount) end
	function ENT:GetRange() end
	function ENT:SetAirGiven(amount) end
	function ENT:UsePerson() end
	function ENT:UsePersonPressure(pressure) end
	function ENT:GetLSClass() end
	function ENT:AddBaseResource(resource, amount) end
	function ENT:AddUseResource(resource, amount) end
	function ENT:GetBaseResource() end
	function ENT:GetResources() end
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
