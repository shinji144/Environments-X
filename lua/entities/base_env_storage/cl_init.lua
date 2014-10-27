include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

--ENT.ScreenAngles = Angle(0,0,0)
--ENT.ScreenAngles.r = 270
--ENT.ScreenAngles.y = 30
/*] dev_setentvar ScreenAngles.Y 0
] dev_setentvar ScreenAngles.R 45 
] dev_setentvar ScreenAngles.P 270*/

--ENT.ScreenPos = Vector(-110,0,50)

local OOO = {}
OOO[0] = "Off"
OOO[1] = "On"
OOO[2] = "Overdrive"

local ResourceUnits = {}
ResourceUnits["energy"] = " kJ"
ResourceUnits["water"] = " L"
ResourceUnits["oxygen"] = " L"
ResourceUnits["hydrogen"] = " L"
ResourceUnits["nitrogen"] = " L"
ResourceUnits["carbon dioxide"] = " L"
ResourceUnits["steam"] = " L"

local ResourceNames = {}
ResourceNames["energy"] = "Energy"
ResourceNames["water"] = "Water"
ResourceNames["oxygen"] = "Oxygen"
ResourceNames["hydrogen"] = "Hydrogen"
ResourceNames["nitrogen"] = "Nitrogen"
ResourceNames["carbon dioxide"] = "CO2"
ResourceNames["steam"] = "Steam"

function ENT:Initialize()
	local info = nil
	if Environments.GetScreenInfo then
		info = Environments.GetScreenInfo(self:GetModel())
	end
	if info then
		self.ScreenMode = true
		self.ScreenAngles = info.Angle
		self.ScreenPos = info.Offset
	end
	
	local tab = Environments.GetEntTable(self:EntIndex())
	self.maxresources = tab.maxresources
	self.resources = tab.resources
	self.node = Entity(tab.network) or NULL
end

function ENT:Draw( bDontDrawModel )
	self:DoNormalDraw()
	
	if tobool(GetConVarNumber("env_draw_cables")) then
		local node = self.node
		if node and node:IsValid() and self:GetNWVector("CablePos") != Vector(0,0,0) then
			if self:GetPos() != self.LastPos or node:GetPos() != node.LastPos then
				local fwd = self:LocalToWorld(self:GetNWVector("CableForward", Vector(0,1,0)))
				fwd:Normalize()
				Environments.DrawCable(self, self:LocalToWorld(self:GetNWVector("CablePos", Vector(0,0,0))), fwd, node:GetPos(), node:GetAngles():Forward())
				node.LastPos = node:GetPos()
				self.LastPos = self:GetPos()
			end
			
			if self.mesh then
				if !self.material or self.Rcolor != self:GetNWVector("CableColor", Vector(255,255,255)) then 
					self.Rcolor = self:GetNWVector("CableColor", Vector(255,255,255))
					local colorstr = "{"..self.Rcolor.x.." "..self.Rcolor.y.." "..self.Rcolor.z.."}"
					local params = {
						["$basetexture"] = "models/debug/debugwhite",
						["$vertexcolor"] = 1,
						["$model"] = 1,
						["$color"] = colorstr,
					}
					self.material = CreateMaterial("3DCableMaterial"..math.random(1,2578846),"VertexLitGeneric",params);
				end
				
				//render.SuppressEngineLighting(true)
					render.SetMaterial( self.material )
					//render.MaterialOverride( self.material )
					
						self.mesh:Draw()
					//render.MaterialOverride( 0 )
				//render.SuppressEngineLighting(false)
			end
		end
	end

	if (Wire_Render) then
		Wire_Render(self)
	end
end

function ENT:DrawTranslucent( bDontDrawModel )
	if bDontDrawModel then return end
	self:Draw()
end

function ENT:OnRemove()
	Environments.GetEntTable()[self:EntIndex()] = nil
end

function ENT:GetOOO()
	return self:GetNetworkedInt("OOO") or 0
end

function ENT:DoNormalDraw( bDontDrawModel )
	if LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance( self:GetPos() ) < 512 then
		--overlaysettings
		local node = self.node --self:GetNWEntity("node")
		local OverlaySettings = list.Get( "LSEntOverlayText" )[self:GetClass()] --replace this
		local HasOOO = OverlaySettings.HasOOO
		local resnames = OverlaySettings.resnames
		local genresnames = OverlaySettings.genresnames
		--End overlaysettings

		if ( !bDontDrawModel ) then self:DrawModel() end
		
		local playername = self:GetPlayerName()
		if playername == "" then
			playername = "World"
		end
		
		if not self.ScreenMode then
			local OverlayText = self.PrintName.."\n"
			
			if !node or !node:IsValid() then
				OverlayText = OverlayText .. "Not Connected\n"
			else
				OverlayText = OverlayText .. "Network " .. tostring(node:EntIndex()) .."\n"
			end
			if HasOOO then
				local runmode = "UnKnown"
				if self:GetOOO() >= 0 and self:GetOOO() <= 2 then
					runmode = OOO[self:GetOOO()]
				end
				OverlayText = OverlayText .. "Mode: " .. runmode .."\n"
			end
			OverlayText = OverlayText.."\n"
			if !node or !node:IsValid() then
				if self.resources and table.Count(self.resources) > 0 then
					for k, v in pairs(self.resources) do
						OverlayText = OverlayText ..(ResourceNames[k] or k)..": ".. v .."/".. self.maxresources[k] .. (ResourceUnits[k] or "") .."\n"
					end
				else
					OverlayText = OverlayText .. "No Resources Connected\n"
				end
			else
				if resnames and table.Count(resnames) > 0 then
					for _, k in pairs(resnames) do
						if node then
							if node.resources_last[k] and node.resources[k] then
								local diff = CurTime() - node.last_update[k]
								if diff > 1 then
									diff = 1
								end
								
								local amt = math.Round(node.resources_last[k] + (node.resources[k] - node.resources_last[k])*diff)
								OverlayText = OverlayText ..(ResourceNames[k] or k)..": ".. (amt) .."/".. (node.maxresources[k] or 0) .. (ResourceUnits[k] or "") .."\n"
							else
								OverlayText = OverlayText ..(ResourceNames[k] or k)..": ".. (node.resources[k] or 0) .."/".. (node.maxresources[k] or 0) .. (ResourceUnits[k] or "") .."\n"
							end
							//OverlayText = OverlayText ..(ResourceNames[k] or k)..": ".. (node.resources[k] or 0) .."/".. (node.maxresources[k] or 0) .. (ResourceUnits[k] or "") .."\n"
						else
							OverlayText = OverlayText ..(ResourceNames[k] or k)..": ".. 0 .."/".. self.maxresources[k] .."\n"
						end
					end
				end
				if genresnames and table.Count(genresnames) > 0 then
					OverlayText = OverlayText.."\nGenerates:\n"
					for _, k in pairs(genresnames) do
						if node then
							if node.resources_last[k] and node.resources[k] then
								local diff = CurTime() - node.last_update[k]
								if diff > 1 then
									diff = 1
								end
								
								local amt = math.Round(node.resources_last[k] + (node.resources[k] - node.resources_last[k])*diff)
								OverlayText = OverlayText ..(ResourceNames[k] or k)..": ".. (amt) .."/".. (node.maxresources[k] or 0) .. (ResourceUnits[k] or "") .."\n"
							else
								OverlayText = OverlayText ..(ResourceNames[k] or k)..": ".. (node.resources[k] or 0) .."/".. (node.maxresources[k] or 0) .. (ResourceUnits[k] or "") .."\n"
							end
							//OverlayText = OverlayText ..(ResourceNames[k] or k)..": ".. (node.resources[k] or 0) .."/".. (node.maxresources[k] or 0).. (ResourceUnits[k] or "") .."\n"
						else
							OverlayText = OverlayText ..(ResourceNames[k] or k)..": ".. 0 .."/".. 0 .."\n"
						end
					end
				end
			end
			if self.ExtraOverlayData then
				for k,v in pairs(self.ExtraOverlayData) do
					OverlayText = OverlayText..k..": "..v.."\n"
				end
			end
			OverlayText = OverlayText .. "(" .. playername ..")"
			AddWorldTip( self:EntIndex(), OverlayText, 0.5, self:GetPos(), self  )
		else
			local rot = Vector(0,0,90)
			local TempY = 0
			local maxvector = self:OBBMaxs()
			local getpos = self:GetPos()

			//SetPosition
			local pos = getpos + (self:GetRight() * self.ScreenPos.y) //y-axis
			pos = pos + (self:GetUp() * self.ScreenPos.z) //z-axis
			pos = pos + (self:GetForward() * self.ScreenPos.x) //x-axis
			
			//Set Angles
			local angle = self:GetAngles()
			angle:RotateAroundAxis(self:GetRight(),self.ScreenAngles.p)
			angle:RotateAroundAxis(self:GetForward(),self.ScreenAngles.y)
			angle:RotateAroundAxis(self:GetUp(),self.ScreenAngles.r)

			local textStartPos = -625 --used for centering
			local stringUsage = ""
			cam.Start3D2D(pos,angle,0.03)
				local status, error = pcall(function()
				surface.SetDrawColor(0,0,0,255)
				surface.DrawRect( textStartPos, 0, 1250, 500 )

				surface.SetDrawColor(155,155,155,255)
				surface.DrawRect( textStartPos, 0, -5, 500 )
				surface.DrawRect( textStartPos, 0, 1250, -5 )
				surface.DrawRect( textStartPos, 500, 1250, -5 )
				surface.DrawRect( textStartPos+1250, 0, 5, 500 )
				
				--local x, y = GetMousePos(LocalPlayer():GetEyeTrace().HitPos, pos, 0.03, angle) --test cursor
				--surface.DrawRect( x, y, 50,50)
				
				TempY = TempY + 10
				surface.SetFont("ConflictText")
				surface.SetTextColor(255,255,255,255)
				surface.SetTextPos(textStartPos+15,TempY)
				surface.DrawText(self.PrintName)
				TempY = TempY + 70
				
				if HasOOO then
					local runmode = "UnKnown"
					if self:GetOOO() >= 0 and self:GetOOO() <= 2 then
						runmode = OOO[self:GetOOO()]
					end
					surface.SetFont("Flavour")
					surface.SetTextColor(155,155,255,255)
					surface.SetTextPos(textStartPos+15,TempY)
					surface.DrawText("Mode: "..runmode)
					TempY = TempY + 50
				end
				
				if #genresnames == 0 and #resnames == 0 then
					surface.SetFont("Flavour")
					surface.SetTextColor(200,200,255,255)
					surface.SetTextPos(textStartPos+15,TempY)
					surface.DrawText("No resources connected")
					TempY = TempY + 70
				else
					surface.SetFont("Flavour")
					surface.SetTextColor(200,200,255,255)
					surface.SetTextPos(textStartPos+15,TempY)
					surface.DrawText("Resources: ")
					TempY = TempY + 50
				end
		
				if table.Count(resnames) > 0 then		
					for k, v in pairs(resnames) do
						stringUsage = stringUsage.."["..ResourceNames[v]..": "..node:GetNWInt(v, 0) .."/".. node:GetNWInt("max"..v, 0).."] "
						surface.SetTextPos(textStartPos+15,TempY)
						surface.DrawText("   "..stringUsage)
						TempY = TempY + 50
						stringUsage = ""
					end
				end
				if table.Count(genresnames) > 0 then
					surface.SetFont("Flavour")
					surface.SetTextColor(200,200,255,255)
					surface.SetTextPos(textStartPos+15,TempY)
					surface.DrawText("Generates: ")
					TempY = TempY + 50
					for k, v in pairs(genresnames) do
						stringUsage = stringUsage.."["..ResourceNames[v]..": "..node:GetNWInt(v, 0) .."/".. node:GetNWInt("max"..v, 0).."] "
						surface.SetTextPos(textStartPos+15,TempY)
						surface.DrawText("   "..stringUsage)
						TempY = TempY + 50
						stringUsage = ""
					end
				end end)
				if error then print(error) end
			cam.End3D2D()
		end
	else
		if ( !bDontDrawModel ) then self:DrawModel() end
	end
end

function GetMousePos(vWorldPos,vPos,vScale,aRot)
    local vWorldPos=vWorldPos-vPos;
    vWorldPos:Rotate(Angle(0,-aRot.y,0));
    vWorldPos:Rotate(Angle(-aRot.p,0,0));
    vWorldPos:Rotate(Angle(0,0,-aRot.r));
    return vWorldPos.x/vScale,(-vWorldPos.y)/vScale;
end

if Wire_UpdateRenderBounds then
	function ENT:Think()
		Wire_UpdateRenderBounds(self)
		self:NextThink(CurTime() + 3)
	end
end

local function UpdateStorage(msg)
	local ent = msg:ReadEntity()
	local res = msg:ReadString()
	if(not ent or not ent:IsValid())then return end
	if not ent.resources then
		ent.resources = {}
	end
	if not ent.maxresources then
		ent.maxresources = {}
	end
	ent.resources[res] = msg:ReadLong() //this errors if ent isnt valid
	ent.maxresources[res] = msg:ReadLong()
end
usermessage.Hook("EnvStorageUpdate", UpdateStorage)

