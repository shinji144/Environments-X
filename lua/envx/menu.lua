
CreateClientConVar("env_suit_color_r",255,true,true)
CreateClientConVar("env_suit_color_g",255,true,true)
CreateClientConVar("env_suit_color_b",255,true,true)

CreateClientConVar("env_suit_model", "models/player/combine_super_soldier.mdl", true, true)

Environments.EffectsCvar = CreateClientConVar("env_effects_enable","1",true,true)

local function AddToolTab()
	-- Add Tab
	local logo;
	--if(file.Exists("..logo")) then logo = "logo" end;
	spawnmenu.AddToolTab("Environments","Environments",logo)
	-- Add Config Category
	spawnmenu.AddToolCategory("Environments","Config"," Config");
	-- Add the entry for config
	spawnmenu.AddToolMenuOption("Environments","Config","EnvOptions","Settings","","",Environments.ConfigMenu,{});
	-- Add the admin menu
	spawnmenu.AddToolMenuOption("Environments","Config","Admin Tools","Admin Tools","","",Environments.AdminMenu,{});
	-- Add the entry for Credits and Bugreporting!
	--spawnmenu.AddToolMenuOption("Environments","Config","Credits","Credits and Bugs","","",Environments.Credits);
	-- Add our tools to the tab
	/*local toolgun = weapons.Get("gmod_tool");
	if(toolgun and toolgun.Tool) then
		for k,v in pairs(toolgun.Tool) do
			if(not v.AddToMenu and v.Tab == "Environments") then
				spawnmenu.AddToolMenuOption(
					v.Tab,
					v.Category or "",
					k,
					v.Name or "#"..k,
					v.Command or "gmod_tool "..k,
					v.ConfigName or k,
					v.BuildCPanel
				);
			end
		end
	end*/
end
hook.Add("AddToolMenuTabs", "EnvironmentsAddTabs", AddToolTab);

hook.Add( "PopulateMenuBar", "EnvironmentsAddMenubar", function( menubar )
    local m = menubar:AddOrGetMenu( "Environments" )
	
	//local sub = m:AddSubMenu( "Admin Options")
	
	m:AddOption("Reload Environments", function() RunConsoleCommand("env_server_reload") end)
	m:AddOption("Fully Reload Environments", function() RunConsoleCommand("env_server_full_reload") end)
	
    m:AddSpacer()
    
    m:AddCVar( "Enable HUD", "env_hud_enabled", "1", "0" )
    local option = m:AddCVar( "Use 3D HUD?", "env_hud_mode", "1", "0" )
	m:AddCVar( "Draw Planet Effects", "env_effects_enable", "1", "0" )
    m:AddCVar( "Enable Breathing Effects", "env_breathing_sound_enabled", "1", "0" )
	
	m:AddSpacer()
	
	m:AddOption("Reload HUD", function() RunConsoleCommand("env_reload_hud") end)
end )

SuitModels = {
	["models/player/combine_super_soldier.mdl"] = {},
	["models/SBEP Player Models/bluehevsuit.mdl"] = {},
	["models/SBEP Player Models/orangehevsuit.mdl"] = {},
	["models/SBEP Player Models/redhevsuit.mdl"] = {},
	["models/Combine_Soldier_PrisonGuard.mdl"] = {},
	["models/Combine_Soldier.mdl"] = {}
}

local function Bool2Num(b)
	if b == true then
		return "1"
	else
		return "0"
	end
end

local Menu = {}
local PlanetData = {}
local function GetData(msg)
	PlanetData["name"] = msg:ReadString()
	PlanetData["gravity"] = msg:ReadFloat()
	PlanetData["unstable"] = msg:ReadBool()
	PlanetData["sunburn"] = msg:ReadBool()
	PlanetData["temperature"] = msg:ReadFloat()
	PlanetData["suntemperature"] = msg:ReadFloat()
	
	Menu.List:Clear()
	for k,v in pairs(PlanetData) do
		Menu.List:AddLine(k,tostring(v))
	end
end
usermessage.Hook("env_planet_data", GetData)

function Environments.AdminMenu(Panel)
	Panel:ClearControls()
	if LocalPlayer():IsAdmin() then
		Panel:Button("Reset Environments", "env_server_reload")
		
		Panel:Help("Enable Noclip For Everyone?")
		local box = Panel:AddControl("CheckBox", {Label = "Enable Noclip?", Command = ""} )
		box:SetValue(tobool(GetConVarNumber("env_noclip")))
		box.Button.Toggle = function()
			if box.Button:GetChecked() == nil or not box.Button:GetChecked() then 
				box.Button:SetValue( true ) 
			else 
				box.Button:SetValue( false ) 
			end 
			RunConsoleCommand("environments_admin", "noclip", Bool2Num(box.Button:GetChecked()))
		end
		
		local planetmod =  vgui.Create("DCollapsibleCategory", DermaPanel)
		planetmod:SetSize( 100, 50 ) -- Keep the second number at 50
		planetmod:SetExpanded( 0 ) -- Expanded when popped up
		planetmod:SetLabel( "Planet Modification" )
		
		local p = vgui.Create( "DPanelList" )
		p:SetAutoSize( true )
		p:SetSpacing( 5 )
		p:EnableHorizontal( false )
		p:EnableVerticalScrollbar( true )
		 
		planetmod:SetContents( p )
		
		local List = vgui.Create("DListView")
		List:SetSize(100, 100)
		List:SetMultiSelect(false)
		List:AddColumn("Setting")
		List:AddColumn("Value")
		Menu.List = List
		
		for k,v in pairs(PlanetData) do
			List:AddLine(k,v)
		end
		
		List.OnRowSelected = function(self, line)
			line = self:GetLine(line)
			local setting = line:GetValue(1)
			local value = line:GetValue(2)
			Menu.Entry.line = line
			Menu.Entry:SetValue(value)
		end	

		local entry = vgui.Create( "DTextEntry" )
		entry:SetTall( 20 )
		entry:SetWide( 160 )
		entry:SetEnterAllowed( false )
		entry:SetMultiline(false)
		entry.OnTextChanged = function(self) -- Passes a single argument, the text entry object.
			if self.line then
				self.line:SetValue(2, self:GetValue())
			end
		end
		Menu.Entry = entry

		local send = vgui.Create( "DButton" )
		send:SetSize( 100, 30 )
		send:SetText( "Set Value" )
		send.DoClick = function( self )
			if Menu.Entry.line then
				RunConsoleCommand("environments_admin", "planetconfig", Menu.Entry.line:GetValue(1), Menu.Entry.line:GetValue(2))
			else
				LocalPlayer():ChatPrint("Select a value to set first!")
			end
		end
		 
		local get = vgui.Create( "DButton" )
		get:SetSize( 100, 30 )
		get:SetText( "Get Planet Info" )
		get.DoClick = function( self )
			RunConsoleCommand("request_planet_data")
		end
		
		p:AddItem(List)
		p:AddItem(entry)
		p:AddItem(send)
		p:AddItem(get)
		Panel:AddPanel(planetmod)
		
		Panel:Help("WARNING: Resets Saved Data!"):SetTextColor(Color(255,0,0,255))
		Panel:Button("Reload Environments From Map", "env_server_full_reload")
	else
		Panel:Help("You are not an admin!")
	end
end

function Environments.ConfigMenu(Panel)
	Panel:ClearControls()
	Environments.ConfigPanel = Panel
	if(Environments.CurrentVersion > Environments.Version) then
		local RED = Color(255,0,0,255)
		Panel:Help("Your build of Environments is out of date"):SetTextColor(RED)
		Panel:Help("LATEST BUILD: "..Environments.CurrentVersion):SetTextColor(RED)
		Panel:Help("If you are getting this message on an internet server, tell the admin to update.")
	elseif(Environments.CurrentVersion == 0) then
		local ORANGE = Color(255,128,0,255)
		Panel:Help("Couldn't determine latest BUILD. Make sure, you are connected to the Internet."):SetTextColor(ORANGE)
	else
		local GREEN = Color(0,255,0,255)
		Panel:Help("Your Environments BUILD is up-to-date."):SetTextColor(GREEN)
	end
	Panel:Help("Current BUILD: "..Environments.Version)
	
	Panel:Help("Suit Color")
	Panel:AddControl("Color", {
		Label = "#suit_color",
		Red = "env_suit_color_r",
		Green = "env_suit_color_g",
		Blue = "env_suit_color_b",
		ShowAlpha = "0",
		ShowHSV = "1",
		ShowRGB = "1",
		Multiplier = "255"
	})
	
	Panel:Help("HUD Temperature Unit")
	local options = {}
	options["Fahrenheit"] = {env_hud_unit = "f"}
	options["Kelvin"] = {env_hud_unit = "k"}
	options["Celcius"] = {env_hud_unit = "c"}
	Panel:AddControl("ComboBox", { Label = "Hud Temperature Unit", MenuButton = 0, Options = options})
	
	Panel:Help("Enable Planet Effects")
	Panel:AddControl("CheckBox", {Label = "Enable Planet Effects?", Command = "env_effects_enable"} )
	
	Panel:Help("Enable HUD")
	Panel:AddControl("CheckBox", {Label = "Enable HUD?", Command = "env_hud_enabled"} )
	
	Panel:Help("Use Cool HUD?")
	local check = Panel:AddControl("CheckBox", {Label = "Use Cool HUD?", Command = "env_hud_mode"} )
	
	check.OnChange = function(self)
		LoadHud()
	end
	
	Panel:Help("Enable Breathing Sound")
	Panel:AddControl("CheckBox", {Label = "Enable Breathing Sound?", Command = "env_breathing_sound_enabled"} )
	
	Panel:Help("Suit Model")
	Panel:AddControl( "PropSelect", {
		Label = "#Models",
		ConVar = "env_suit_model",
		Category = "Storages",
		Models = SuitModels
	})
	
	Panel:Help("HUD Adjustment")
	Panel:NumSlider("HUD Y Scale", "env_hud_scale_x", 0, 3, 2) 
	Panel:NumSlider("HUD Vertical Scale", "env_hud_scale_y", 0, 3, 2) 
	Panel:NumSlider("HUD X Scale", "env_hud_scale_z", 0, 3, 2) 
	
	Panel:NumSlider("HUD Right Offset", "env_hud_offset_x", -10, 10, 2) 
	Panel:NumSlider("HUD Forward Offset", "env_hud_offset_y", -70, 70, 2) 
	Panel:NumSlider("HUD Up Offset", "env_hud_offset_z", -70, 70, 2)
	
	/*Panel:Button( "Open Help Page", "pp_superdof" )
	-- The HELP Button
	if(Environments.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/visual");
		VGUI:SetTopic("Help:  Visual Settings");
		Panel:AddPanel(VGUI);
	end*/
end

/*function Environments.Credits(Panel)
	-- The Credits Button
	if(Enviroments.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("credits");
		VGUI:SetTopic("Credits");
		VGUI:SetText("Credits");
		VGUI:SetImage("gui/silkicons/star");
		Panel:AddPanel(VGUI);
		Panel:Help("Here, you can report bugs. If you can't type in the HTML-Formulars, visit "..Environments.HTTP.BUGS.." with your webbrowser");
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetTopic("Bugs");
		VGUI:SetText("Bugs");
		VGUI:SetImage("gui/silkicons/exclamation");
		VGUI:SetURL(Environments.HTTP.BUGS);
		Panel:AddPanel(VGUI);
		Panel:Help("");
		
		local HTML = vgui.Create("HTML",self);
		-- Crappy Quicks-HTML for a crappy browser (Internet-Explorer)
		HTML:SetHTML([[
			<html>
				<body margin="0" padding="0">
					<center><img margin="0" padding="0" border="0" alt="Latest Environments BUILD" src="]]..Environments.HTTP.VERSION_LOGO..[["/ ></center>
				</body>
			</html>
		]]);
		HTML:SetSize(128,164);
		Panel:AddPanel(HTML);
		
		-- Tells, if he is out-of-date
		if(Environments.CurrentVersion > Environments.Version) then
			HasLatestVersion(Panel);
		elseif(Environments.CurrentVersion == 0) then
			local ORANGE = Color(255,128,0,255);
			Panel:Help("Couldn't determine latest BUILD. Make sure, you are connected to the Internet."):SetTextColor(ORANGE);
		else
			local GREEN = Color(0,255,0,255);
			Panel:Help("Your Environments BUILD is up-to-date."):SetTextColor(GREEN);
		end
		Panel:Help("BUILD: "..Environments.Version)
	else
		Panel:Help("It seems like, you are not connected to the Internet. Therefore, the Credits and Bugreport can't be shown. If you are sure, you are connected and have receive this message accidently, you can manually enable the online help below.");
		Panel:CheckBox("Manual Override","cl_has_internet"):SetToolTip("Changes apply after you restarted GMod");
	end
end*/
