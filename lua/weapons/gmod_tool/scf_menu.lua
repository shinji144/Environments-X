TOOL.Category		= "Construction"
TOOL.Name			= "SCF OmniTool"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Tab = "Environments"

if CLIENT then
	local MyName = "Tool."..TOOL.Mode.."."
	language.Add( MyName.."listname", "SCF Menu" )
	language.Add( MyName.."name", "Space Combat Framework" )
	language.Add( MyName.."desc", "Wip" )
	language.Add( MyName.."0", "ToDo" )

	/*------------------------------------
		BuildCPanel
	------------------------------------*/
	function TOOL.BuildCPanel( CPanel )
		print("Building CPanel")
		local DPanel = vgui.CreateFromTable( vgui.RegisterFile( "weapons/gmod_tool/scf_tool_menu.lua" ) )
		CPanel:AddPanel( DPanel )
	end
end

function TOOL:LeftClick( trace )
end

function TOOL:RightClick( trace )
end