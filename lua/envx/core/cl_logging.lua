------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
local function Logging(id,handler,encoded,decoded)
	local LoggingMenu = vgui.Create( "DFrame" )
	LoggingMenu:SetSize( 534, 468 )
	LoggingMenu:Center( )
	LoggingMenu:SetTitle( "Environments Logs" ) 
	LoggingMenu:ShowCloseButton( true )
	LoggingMenu:SetVisible( true )
	LoggingMenu:SetDraggable( false )
	LoggingMenu:MakePopup( )
	
	local MenuTabs = vgui.Create("DPropertySheet")
	MenuTabs:SetParent(LoggingMenu)
	MenuTabs:SetPos(4, 30)
	MenuTabs:SetSize(526, 432)

	local EventList = vgui.Create("DPanelList")
	EventList:SetSize(475, 357)
	EventList:SetPos(5, 15)
	EventList:SetSpacing(5)
	EventList:EnableHorizontal(false)
	EventList:EnableVerticalScrollbar(true)

	local LoggingListView = vgui.Create("DListView")
	LoggingListView:SetParent(LoggingMenu)
	LoggingListView:SetPos(3, 50)
	LoggingListView:SetSize(534, 375)
	LoggingListView:SetMultiSelect(false)
	local timecol = LoggingListView:AddColumn("Time")
	LoggingListView:AddColumn("Entry")
	timecol:SetMaxWidth(130)

	for k,v in pairs(decoded[1]) do
		logrecs = string.Explode(";", v)
		LoggingListView:AddLine(  logrecs[1], logrecs[2] ) end 
		LoggingListView.OnRowSelected = function(self, row)
		local confirmation = DermaMenu()
		confirmation:AddOption("Copy to Clipboard", function() SetClipboardText(self:GetLine(row):GetValue(1).. " - "..(self:GetLine(row):GetValue(2))) end) 
		confirmation:Open()
	end
	EventList:AddItem(LoggingListView)
	
	MenuTabs:AddSheet("Event Log", EventList, "gui/silkicons/shield", false, false, nil)
end
//datastream.Hook("sendEnvLogs",Logging)