include("shared.lua")

local OOO = {}
OOO[0] = "Off"
OOO[1] = "Scanning"

-- ToDo:  Add fancy drawing stuff for mode2  -_-
function ENT:DoNormalDraw(bDontDrawModel)
	-- You lookin at me?
	if LocalPlayer():GetEyeTrace().Entity == self.Entity and EyePos():Distance( self.Entity:GetPos() ) < 256 then
		local trace = LocalPlayer():GetEyeTrace()
		if not bDontDrawModel then self:DrawModel() end
		local owner = self:GetPlayerName()
		if owner == "" then owner = "World" end
		
		local OverlayText = ""
		OverlayText	= OverlayText..self.PrintName.."\n"
		if not self.node then
			OverlayText = OverlayText.."Not connected to a network."
		else
			OverlayText = OverlayText.."Network: "..tostring( self.node:EntIndex() ) .. "\n"
		end
		OverlayText = OverlayText.."Owner: ( "..owner.." )\n"
		local status,mode = "unknown",self:GetOOO()
		if mode >= 0 and mode <2 then status = OOO[mode] end
		OverlayText = OverlayText.."Status: "..status.."\n\n"
		if not self.node or not self.node.resources or not self.node.resources.energy then
			OverlayText = OverlayText.."Energy Needed!\n"
		elseif self.node and self.node.resources and self.node.resources.energy then
			OverlayText = OverlayText.."Energy: "..self.node.resources.energy.." kJ\n"
		end
		if mode == 1 then
			OverlayText = OverlayText.."Resource Density: "..math.Round( self.dt.Density,2).."\n"
			OverlayText = OverlayText.."Resource Pool Volume: "..math.Round( ( ( ( self.dt.Size ) * 0.75 ) * 2.54 ) *1e-2,2).." cubic m\n"
			OverlayText = OverlayText.."Scanner Range: "..self.dt.Range.."\n"
			OverlayText = OverlayText.."Scanner Beam Angle: "..self.dt.ScanAngle.." deg.\n"
			OverlayText = OverlayText.."Resource Depth: "..math.Round( ( ( ( self.dt.Depth ) * 0.75) * 2.54) * 1e-2,2).." m\n"
			OverlayText = OverlayText.."Resource Distance: "..tostring( math.Round(self.dt.Distance,2) ).." m\n"
			OverlayText = OverlayText.."Relative Angle: ("..tostring(self.dt.TargetAngle)..")\n"
			OverlayText = OverlayText.."Resource Count: "..self.dt.Quantity.."\n"
		end
		AddWorldTip( self:EntIndex(), OverlayText, 0.5, self:GetPos(), self )
	else
		if not bDontDrawModel then self:DrawModel() end
	end
	
end