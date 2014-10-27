
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Environment"
ENT.Author = "CmdrMatthew"
/*ENT.Purpose = "To Test"
ENT.Instructions = "Eat up!" 
ENT.Category = "Environments"*/

/*ENT.Spawnable = true
ENT.AdminSpawnable = true*/
  
if CLIENT then
	function ENT:Draw()
		return false
	end
end