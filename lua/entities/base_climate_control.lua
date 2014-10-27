AddCSLuaFile( "base_climate_control.lua" )

ENT.Type 		= "anim"
ENT.Base 		= "base_rd3_entity"
ENT.PrintName 	= "Climate Regulator"

list.Set( "LSEntOverlayText" , "base_climate_control", {HasOOO = true, resnames ={ "oxygen", "energy", "water", "nitrogen"} } )

if(SERVER)then
	function ENT:Initialize() self:Remove() end
	function ENT:TurnOn() end
	function ENT:TurnOff() end
	function ENT:TriggerInput(iname, value) end
	function ENT:Damage() end
	function ENT:Repair() end
	function ENT:Destruct() end
	function ENT:OnRemove() end
	function ENT:UpdateSize(oldsize, newsize) end
	function ENT:Climate_Control() end
	function ENT:Think() end
end		
