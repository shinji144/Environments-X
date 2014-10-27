
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
end


function ENT:Climate_Control()
end

function ENT:Think()
	self:NextThink(CurTime() + 10)
	return true
end

