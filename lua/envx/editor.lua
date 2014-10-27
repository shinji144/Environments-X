------------------------------------------
//     SpaceRP     //
//   CmdrMatthew   //
------------------------------------------

local PANEL = {}

function PANEL:Init()
	local tree = vgui.Create("DTree", self)
	
end

function PANEL:PerformLayout()
	
end

function PANEL:ApplySchemeSettings()
end

vgui.Register("admin_editor", PANEL, "DPanel")

local function showeditor()
	local s = vgui.Create("admin_editor")
	s:MakePopup()
end
concommand.Add("srp_editor", showeditor)