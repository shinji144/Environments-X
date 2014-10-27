

TOOL.Category       = "Tools"
TOOL.Name           = "Link Tool"
TOOL.Command        = nil
TOOL.ConfigName     = nil
TOOL.Tab = "Environments"

if ( CLIENT ) then
	language.Add( "tool.link_tool.name", "Link Tool" )
	language.Add( "tool.link_tool.desc", "Links Resource-Carrying Devices together to a Resource Node." )
	language.Add( "tool.link_tool.0", "Left Click: Link Devices. Reload: Unlink Device from All." )
	language.Add( "tool.link_tool.1", "Click on another Resource-Carrying Device" )
	language.Add( "rd3_dev_link_width", "Width:" )
	language.Add( "link_tool_material", "Material:" )
	language.Add( "rd3_dev_link_colour", "Color:")
end

TOOL.ClientConVar[ "material" ] = "models/debug/debugwhite"
TOOL.ClientConVar[ "width" ] = "2"
TOOL.ClientConVar[ "color_r" ] = "255"
TOOL.ClientConVar[ "color_g" ] = "255"
TOOL.ClientConVar[ "color_b" ] = "255"
TOOL.ClientConVar[ "color_a" ] = "255"
TOOL.ClientConVar[ "cable" ] = "1"

if SERVER then
	AddCSLuaFile("link_tool.lua")
end

function TOOL:LeftClick( trace )
	//if not valid or player, exit
	if !trace.Entity:IsValid() or trace.Entity:IsPlayer() or trace.HitWorld then return end
	//if client exit
	if CLIENT then return true end
	// If there's no physics object then we can't constraint it!
	if ( !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end

	//how many objects stored
	local iNum = self:NumObjects() + 1

	//save clicked postion
	self:SetObject( iNum, trace.Entity, trace.HitPos, trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone ), trace.PhysicsBone, trace.HitNormal )
	self.Objects[iNum].Normal = trace.HitNormal
	
	//if finishing, run StartTouch on Resource Node to do link
	if ( iNum > 1 ) then
		local Ent1 = self:GetEnt(1) 	//get first ent
		local Ent2 = self:GetEnt(iNum) 	//get last ent
		local length = ( self:GetPos(1) - self:GetPos(iNum)):Length()

		if Ent1.IsNode or Ent2.IsNode then
			if Ent1.IsNode and Ent2.IsNode then
				self:GetOwner():SendLua( "GAMEMODE:AddNotify('You cant link two nodes!', NOTIFY_GENERIC, 7);" )
			else
				if Ent1.Link and Ent2.Link then --only let LS ents, need to fix, lets all ents with a Link() function
					Ent1:Link(Ent2)
					Ent2:Link(Ent1)
					if tonumber(self:GetClientInfo("cable")) == 1 then
						if Ent1.IsNode then
							Environments.Create_Beam(Ent2, self:GetLocalPos(iNum), self.Objects[iNum].Normal, self:GetClientInfo("material"), Color(tonumber(self:GetClientInfo("color_r")), tonumber(self:GetClientInfo("color_g")), tonumber(self:GetClientInfo("color_b")), 255))
						else
							Environments.Create_Beam(Ent1, self:GetLocalPos(1), self.Objects[1].Normal, self:GetClientInfo("material"), Color(tonumber(self:GetClientInfo("color_r")), tonumber(self:GetClientInfo("color_g")), tonumber(self:GetClientInfo("color_b")), 255))
						end
					else
						if Ent1.IsNode then
							Ent2:SetNWVector("CablePos", Vector(0,0,0))
						else
							Ent1:SetNWVector("CablePos", Vector(0,0,0))
						end
					end
				else
					self:GetOwner():SendLua( "GAMEMODE:AddNotify('Invalid Combination!', NOTIFY_GENERIC, 7);" )
				end
			end
		elseif Ent1.node or Ent2.node then
			if Ent1.node then
				Ent2:Link(Ent1.node)
				Ent1.node:Link(Ent2)
			else
				Ent1:Link(Ent2.node)
				Ent2.node:Link(Ent1)
			end
		else
			self:GetOwner():SendLua( "GAMEMODE:AddNotify('Invalid Combination!', NOTIFY_GENERIC, 7);" )
		end

		self:ClearObjects()	//clear objects
	else
		self:SetStage( iNum )
	end

	//success!
	return true
end

function TOOL:RightClick( trace )
	//if not valid or player, exit
	if ( trace.Entity:IsValid() && trace.Entity:IsPlayer() ) then return end

	return true
end

function TOOL:Reload(trace)
	//if not valid or player, exit
	if ( trace.Entity:IsValid() && trace.Entity:IsPlayer() ) then return end
	//if client exit
	if ( CLIENT ) then return true end

	if trace.Entity.IsNode then
		
	elseif trace.Entity.Unlink then
		trace.Entity:Unlink()
	end

	self:ClearObjects()	//clear objects
	return true
end

function TOOL.BuildCPanel( panel )
	panel:AddControl( "Header", { Text = "#tool.link_tool.name", Description	= "#tool.link_tool.desc" }  )
	
	panel:AddControl("CheckBox", { Label = "Use Cables? DO NOT USE ON MOVING STRUCTURES", Command = "link_tool_cable" })

	/*panel:AddControl( "MatSelect", {
		Height = "7",
		Label = "#link_tool_material",
		ItemWidth = 64,
		ItemHeight = 64,
		ConVar = "link_tool_material",
		Options = list.Get( "OverrideMaterials" )
	})*/

	panel:AddControl("Color", {
		Label = "#rd3_dev_link_colour",
		Red = "link_tool_color_r",
		Green = "link_tool_color_g",
		Blue = "link_tool_color_b",
		ShowAlpha = "0",
		ShowHSV = "0",
		ShowRGB = "1",
		Multiplier = "255"
	})
end

