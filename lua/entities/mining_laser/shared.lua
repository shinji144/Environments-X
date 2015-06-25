ENT.Type = "anim"
ENT.Base = "base_env_entity"
ENT.PrintName = "Mining Laser"

list.Set( "LSEntOverlayText" , "mining_laser", {HasOOO = true, resnames ={"energy","water"} } )

function ENT:SetupDataTables()
	self:DTVar("Float",0,"Efficiency")
	self:DTVar("Int",0,"Flowrate")
	self:DTVar("Float",1,"Heat")
	self:DTVar("Bool",0,"LaserMine")
end