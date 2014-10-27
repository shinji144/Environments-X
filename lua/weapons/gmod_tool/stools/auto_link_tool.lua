

TOOL.Category       = "Tools"
TOOL.Name           = "Auto Link Tool"
TOOL.Command        = nil
TOOL.ConfigName     = nil
TOOL.Tab = "Environments"

if ( CLIENT ) then
	language.Add( "tool.auto_link_tool.name", "Auto Link Tool" )
	language.Add( "tool.auto_link_tool.desc", "Links Resource-Carrying Devices together to a Resource Node." )
	language.Add( "tool.auto_link_tool.0", "Left Click: Link All Devices in Range of Node. Reload: Unlink Device from All." )
end

TOOL.ClientConVar[ "material" ] = "models/debug/debugwhite"
TOOL.ClientConVar[ "width" ] = "2"
TOOL.ClientConVar[ "color_r" ] = "255"
TOOL.ClientConVar[ "color_g" ] = "255"
TOOL.ClientConVar[ "color_b" ] = "255"
TOOL.ClientConVar[ "color_a" ] = "255"
TOOL.ClientConVar[ "cable" ] = "1"

if SERVER then
	AddCSLuaFile("auto_link_tool.lua")
end

function TOOL:LeftClick( trace )
	//if not valid or player, exit
	if !trace.Entity:IsValid() or trace.Entity:IsPlayer() or trace.HitWorld then return end
	//if client exit
	if CLIENT then return true end
	
	if trace.Entity.IsNode then
		local es = ents.FindInSphere(trace.Entity:GetPos(), 2000)
		for k,v in pairs(es) do
			if v.Link and !v.IsNode then
				if v:GetPlayer() == self:GetOwner() then//only the owner can do this
					v:Link(trace.Entity)
					trace.Entity:Link(v)
					if tonumber(self:GetClientInfo("cable")) == 1 then
						Environments.Create_Beam(v, Vector(0,1,0), Vector(1,0,0), "", Color(200,200,200,255))
					else
						v:SetNWVector("CablePos", Vector(0,0,0))
					end
				else
					//print("not owner", v:GetPlayer(), self:GetOwner())
				end
			end
		end
	else
		self:GetOwner():SendLua( "GAMEMODE:AddNotify('That is not a valid node!', NOTIFY_GENERIC, 7);" )
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

	return true
end

function TOOL.BuildCPanel( panel )
	panel:AddControl( "Header", { Text = "#tool.auto_link_tool_name", Description	= "#tool.auto_link_tool.desc" }  )
	
	panel:AddControl("CheckBox", { Label = "Use Cables? DO NOT USE ON MOVING STRUCTURES", Command = "auto_link_tool_cable" })

	/*panel:AddControl( "MatSelect", {
		Height = "7",
		Label = "#link_tool_material",
		ItemWidth = 64,
		ItemHeight = 64,
		ConVar = "link_tool_material",
		Options = list.Get( "OverrideMaterials" )
	})*/
end

