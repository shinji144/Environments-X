
local function VisualOptions( CPanel )
	CPanel:AddControl( "Header", { Text = "#Environments Settings" }  )

	CPanel:AddControl( "Slider", { Label = "#Net Graph",	Type = "Integer", 	Command = "net_graph", 		Min = "0", 		Max = "3" }  )
	CPanel:AddControl( "Slider", { Label = "#Show FPS",		Type = "Integer", 	Command = "cl_showfps", 	Min = "0", 		Max = "2" }  )

	CPanel:AddControl( "CheckBox", { Label = "#Show_Low_Res_Textures",	Command = "mat_showlowresimage" }  )	
	CPanel:AddControl( "CheckBox", { Label = "#Wireframe",				Command = "mat_wireframe" }  )	
end

/*
// Tool Menu
*/
local function PopulateOptionMenus()
	spawnmenu.AddToolMenuOption( "Options", "Environments",  "Settings",   "#Settings",  "", "", VisualOptions )
end
hook.Add( "PopulateToolMenu", "cmdrPopulateOptionMenus", PopulateOptionMenus )

/* 
// Categories
*/
local function CreateOptionsCategories()
	spawnmenu.AddToolCategory( "Options", 	"Environments", 	"#Environments" )
end	
hook.Add( "AddToolMenuCategories", "cmdrCreateOptionsCategories", CreateOptionsCategories )

