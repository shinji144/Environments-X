ENT.Type 		= "anim"
ENT.Base 		= "base_env_entity"
ENT.PrintName 	= "Resource Scanner"

list.Set( "LSEntOverlayText" , "resource_scanner", {HasOOO = true, resnames = {"energy"} } )

function ENT:SetupDataTables()
	self:DTVar("Float",0,"Density")
	self:DTVar("Int",0,"Size")
	self:DTVar("Int",1,"Quantity")
	self:DTVar("Int",2,"Range")
	self:DTVar("Int",3,"ScanAngle")
	self:DTVar("Float",1,"Depth")
	self:DTVar("Float",2,"Distance")
	self:DTVar("Angle",0,"TargetAngle")
end