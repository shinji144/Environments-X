//Space Definition
local space = {}
space.air = {}
space.oxygen = 0
space.carbondioxide = 0
space.pressure = 0
space.temperature = 3
space.air.o2per = 0
space.noclip = 0
space.name = "space"
space.originalco2per = 0
space.gravity = 0
space.radius = 0

function space:UpdateGravity(ent)
	ent:SetGravity( 0 )
	local phys = ent:GetPhysicsObject()
	if phys and phys:IsValid() then
		phys:EnableDrag( false )
		phys:EnableGravity( false )
	end
	if( ent:IsPlayer() ) then
		ent:SetNWBool( "inspace", false )
	end
end

function space.UpdatePressure()

end

function space.IsOnPlanet()
	return false
end
	
function space.GetAtmosphere()
	return 0
end
	
function space.IsPlanet()
	return false
end
	
function space.IsSpace()
	return true
end
	
function space.IsStar()
	return false
end

function space.GetEnvironmentName()
	return "Space"
end

function space.GetGravity()
	return 0
end

function space.GetO2Percentage()
	return 0
end

function space.GetCO2Percentage()
	return 0
end

function space.GetNPercentage()
	return 0
end

function space.GetHPercentage()
	return 0
end

function space.GetEmptyAirPercentage()
	return 100
end

function space.GetPressure()
	return 0
end

function space.GetTemperature()
	return 3
end

function space.Convert()
	return 0
end

function Space()
	return space
end
//End Space Definition