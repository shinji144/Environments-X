ENT.Type 		= "anim"
ENT.Base 		= "base_env_entity"
ENT.PrintName 	= "Resource Drill"

list.Set( "LSEntOverlayText" , "resource_drill", {HasOOO = true, resnames = {"energy"} } )

function ENT:SetupDataTables()
	self:DTVar("Int",0,"Depth")
	self:DTVar("Int",1,"Locked")
	self:DTVar("Int",2,"Shaftspeed")
	self:DTVar("Int",3,"Phase")
	self:DTVar("Float",0,"ExtractionRate")
	self:DTVar("Float",1,"Heat")
end