include('shared.lua')

local OOO = {}
OOO[0] = "Off"
OOO[1] = "Firing"

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.boxmax = self:OBBMaxs() - self:OBBMins()
	self.LastResource ="none"
end

function ENT:DoNormalDraw(bDontDrawModel)

	if LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance( self:GetPos() ) < 256 then
		local trace = LocalPlayer():GetEyeTrace()

		if not bDontDrawModel then self:DrawModel() end

		local owner = self:GetPlayerName()
		if owner == "" then owner = "World" end

		local OverlayText = ""
		OverlayText	= OverlayText.."["..self.PrintName.."]\n"

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
		OverlayText = OverlayText.."Last Resource: [ "..self.LastResource.." ]\n"
		if mode == 1 then
			local EMR = LDE.Anons.Resources[self:GetNetworkedString("MiningLaserResource")]
			local resname,resunit = "none",""
			if EMR and EMR.name then
				resname,resunit = EMR.name,EMR.unit
				self.LastResource = EMR.name
			end
			OverlayText = OverlayText.."Efficiency: "..math.Round(self.dt.Efficiency,2).." %\n"
			OverlayText = OverlayText.."Resource: [ "..resname.." ]\n"
			OverlayText = OverlayText.."Flowrate: "..self.dt.Flowrate.." "..resunit.."/sec\n"
		end
			OverlayText = OverlayText.."Overheat: "..math.Round(self.dt.Heat,1).." %\n"
		AddWorldTip( self:EntIndex(), OverlayText, 0.5, self:GetPos(), self )
	else
		if not bDontDrawModel then self:DrawModel() end
	end
	
	--# I'm Firin Mah Lazor!!!
	if self:GetOOO() > 0 then
		local Pos,Fore = self:GetPos(), self:GetForward()
		local LaserStart = Pos + Fore * ( self.boxmax.x *0.62)
		local LaserOrigin = Pos + Fore * 768
		self:SetRenderBoundsWS(LaserStart,LaserOrigin)
		local tracedata = {}
		tracedata.start = LaserStart
		tracedata.endpos = LaserOrigin
		tracedata.filter = self
		local trace = util.TraceLine(tracedata)
		-- Draw laserbeam.
		local LaserHitPos,LaserTarget = trace.HitPos,trace.Entity
		local Ed = EffectData()
		Ed:SetOrigin(LaserHitPos)
		Ed:SetStart(LaserStart)
		util.Effect("eff_laserbeam",Ed)
		
		if self.dt.LaserMine == true then -- Do rocky effect if we are getting resources
			local edata = EffectData()
			edata:SetOrigin(LaserHitPos )
			edata:SetNormal( -Fore )
			edata:SetMagnitude( trace.Fraction )
			util.Effect( "eff_laserhit" , edata )	
		end
	end
end

function ENT:Think()
	self:NextThink(CurTime() + 0.1)
end
