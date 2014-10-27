AddCSLuaFile( "base_gravity_control.lua" )

ENT.Type 		= "anim"
ENT.Base 		= "base_rd3_entity"
ENT.PrintName 	= "Gravity Regulator"

list.Set( "LSEntOverlayText" , "base_gravity_control", {HasOOO = true, resnames ={"energy"} } )

if(SERVER)then
	function ENT:Initialize() self:Remove() end
	function ENT:TurnOn() end
	function ENT:TurnOff() end
	function ENT:TriggerInput(iname, value) end
	function ENT:Damage() end
	function ENT:Repair() end
	function ENT:Destruct() end
	function ENT:OnRemove() end
	function ENT:Think() end
end		
