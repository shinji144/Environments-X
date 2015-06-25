include("shared.lua")

local OOO = {}
OOO[0] = "Off"
OOO[1] = "Active"
local Drillstatus = {"Idle","Drilling","Extracting","Shutting Down","OverHeating"}

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self.LastResource = "none"
end

function ENT:DoNormalDraw(bDontDrawModel)
	if LocalPlayer():GetEyeTrace().Entity == self  and EyePos():Distance( self:GetPos() ) < 256 then
		local trace = LocalPlayer():GetEyeTrace()
		if not bDontDrawModel then self:DrawModel() end
		local owner = self:GetPlayerName()
		if owner == "" then owner = "World" end
		
		local OverlayText = ""
		OverlayText	= OverlayText.."["..self.PrintName.."]\n"
		if not self.node then
			OverlayText = OverlayText.."Not connected to a network.\n"
		else
			OverlayText = OverlayText.."Network: "..tostring( self.node:EntIndex() ) .. "\n"
		end
		OverlayText = OverlayText.."Owner: ( "..owner.." )\n"
		local mode,status = self:GetOOO(),"Idle"
		if mode >= 0 or mode <2 then status = OOO[mode] end
		OverlayText = OverlayText.."Status: "..status.."\n"
		
		if not self.node or not self.node.resources or not self.node.resources.energy then
			OverlayText = OverlayText.."Energy Needed!\n"
		elseif self.node and self.node.resources and self.node.resources.energy then
			OverlayText = OverlayText.."Energy: "..self.node.resources.energy.." kJ\n"
		end
		OverlayText = OverlayText.."Last Resource: [ "..self.LastResource.." ]\n"
		local lockstatus = "disengaged"
		if self.dt.Locked >0 then lockstatus = "enaged" end
		OverlayText = OverlayText .. "Drill Lock: ["..lockstatus.."]\n"
		OverlayText = OverlayText .. "Drill Status: [ "..Drillstatus[self.dt.Phase].." ]\n"
		if mode == 1 then
			local EMR = LDE.Anons.Resources[self:GetNetworkedString("ResourceDrillResource")]
			local resname,resunit = "none",""
			if EMR and EMR.name then
				resname,resunit = EMR.name,EMR.unit
				self.LastResource = EMR.name
			end		
			OverlayText = OverlayText.."Depth: "..math.Round( ( ( ( self.dt.Depth ) * 0.75) * 2.54) * 1e-2,2).." m\n"
			OverlayText = OverlayText.."Resource: [ "..resname.." ]\n"
			OverlayText = OverlayText.."Extraction Rate: "..self.dt.ExtractionRate.." "..resunit.."/sec\n"
		end
		OverlayText = OverlayText.."Overheat: "..math.Round(self.dt.Heat,1).." %\n"
		AddWorldTip( self:EntIndex(), OverlayText, 0.5, self:GetPos() + self:GetUp(), self )
	else
		if not bDontDrawModel then self:DrawModel() end
	end
	
end
