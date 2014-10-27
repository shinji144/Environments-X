LDE.Logger = {}


local Folder = "lde_logs"


if(SERVER)then
	 
	if !ConVarExists( "eventlog_maxlogs" ) then CreateConVar( "eventlog_maxlogs", "50", FCVAR_SERVER_CAN_EXECUTE ) end
	if !ConVarExists( "eventlog_maxbuffer" ) then CreateConVar( "eventlog_maxbuffer", "100", FCVAR_SERVER_CAN_EXECUTE ) end

	
	LDE.Logger.EventLog = {}
	LDE.Logger.LogStart = CurTime()
	LDE.Logger.LogBuffer = 0
	LDE.Logger.LogSaves = 0
	
	local fname = Folder.."/log"..tostring( os.date( "%d%m%y%H%M", os.time()))..".txt"
	local fcontents = ""

	--function LDE.Logger.OpenLog( ply )
	--	ply:ConCommand( "eventlogmenu" )
	--end
	--hook.Add( "ShowSpare1", "bindtoSpare1", OpenLog )
	--hook.Add( "ShowSpare2", "bindtoSpare2", LDE.Logger.OpenLog )
	
	function LDE.Logger.FolderSetup()
		--First, check for our storage directory and make it if needed
		if not file.IsDir(Folder,"data") then
			print(Folder.." not found, creating.")
			file.CreateDir(Folder)
		end
	end
	LDE.Logger.FolderSetup()
	
	function LDE.Logger.SaveAlert()
		umsg.Start("ldeLOGGERsaved")
		umsg.End()
	end
	
	function LDE.Logger.Refresh()
		LDE.Logger.QuickSave()
		local logs = file.Find( Folder.."/log*.txt","data" )
		for num, log in pairs( logs ) do
			if #logs - num >= GetConVar( "eventlog_maxlogs" ):GetInt() then file.Delete( log ) end
		end
		LDE.Logger.LogBuffer = 0
		fname = Folder.."/log"..tostring( os.date( "%d%m%y%H%M", os.time()))..".txt"
		LDE.Logger.EventLog = {}
		LDE.Logger.LogStart = CurTime()
		LDE.Logger.SaveAlert()
	end
	--LDE.Logger.Refresh()

	function LDE.Logger.QuickSave()
		if #LDE.Logger.EventLog == 0 then LDE.Logger.EventLog = {} fcontents = "" return end
		file.Write( fname, "" )
		for _, k in pairs( LDE.Logger.EventLog ) do
			if _ == #LDE.Logger.EventLog then
				appendstr = k.."\\n"
			else
				appendstr = k.."\\n\n"
			end
			file.Append( fname, appendstr )
		end
		fcontents = ""
		appendstr = ""
		print("Saved Logs.")
		umsg.Start("ldeLOGmessage")
		umsg.String("save")
		umsg.End()
	end
	
	function timequicksave()
		LDE.Logger.QuickSave()
	end
	timer.Create( "LDELOGGERStartTimer", 60, 1, timequicksave )
	timer.Create( "LDELOGGERTimer", 120, 0, timequicksave )

	function LDE.Logger.timeToStr( time )
		local tmp = time
		local s = tmp % 60
		tmp = math.floor( tmp / 60 )
		local m = tmp % 60
		tmp = math.floor( tmp / 60 )
		local h = tmp % 24
		
		return string.format( "%02ih %02im %02is", h, m, s )
	end

	function LDE.Logger.LogEvent( str )
		LDE.Logger.LogBuffer=LDE.Logger.LogBuffer+1
		if(LDE.Logger.LogBuffer>=GetConVar( "eventlog_maxbuffer" ):GetInt())then 
			LDE.Logger.Refresh()
		end
		str = os.date( "H:%H M:%M S:%S", os.time()).." "..str
		table.insert( LDE.Logger.EventLog, str )
		print("Log Added: "..str)
	end
	
	function LDE.Logger.LogDamage(attacker,victom,damage)
		--Put damage logging here.
	end
	
	function LDE.Logger.RequestLogs( ply )
		print(ply:GetName().." requesting logs.")
		local logs = file.Find( Folder.."/log*.txt","data" )
		print(table.Count(logs).." logs found.")
		for num, log in pairs( logs ) do
			if #logs - num >= GetConVar( "eventlog_maxlogs" ):GetInt() then 
				file.Delete( log )
				print("Deleting: "..log)
			else
				print("Log: "..log)
				timer.Simple((num*0.1)+0.01, function() 
					print("Sending log: "..log)
					umsg.Start("ldeLOGmessage",ply)
					umsg.String("log")
					umsg.String(log)
					umsg.End() 
				end)
			end
		end
	end
	concommand.Add("lderequestlogs", LDE.Logger.RequestLogs,function()end,"DERP",0)
	
	function LDE.Logger.RequestLogData( ply,Cmd,Args )
		local Log = Args[1]
		print(ply:GetName().." requesting log: "..Log.." , Data.")
		local str = file.Read(Log,"data")
		if(not str)then return end
		local lines = string.Explode("\n",str)
		local linecount = table.Count(lines)
		local curline = 1
		for k, line in pairs (lines) do
			curline=curline+1
			umsg.Start("ldeLOGmessage",ply)
			umsg.String("data")
			umsg.String(line)
			umsg.String(curline)
			umsg.String(linecount)
			umsg.End()
		end
	end
	concommand.Add("lderequestdata", LDE.Logger.RequestLogData,function()end,"DERP",0)
	
else
	-----CLIENT SIDE-----
	LDE.Logger.LogStart = CurTime()
	LDE.Logger.OutDated = true
	LDE.Logger.Values = {}
	
	local function EZdate( str )
	if str == tostring(os.date("%d/%m/%y")) then return "Today"
	elseif tonumber(string.Replace(str,"/","")) == tonumber(os.date("%d%m%y")) -10000 then return "Yesterday"
	else return str end
	end

	function acceptmessage(um)
		local id = um:ReadString()
		if(id=="log")then
				local List = LDE.Logger.filelist
			if(List and List:IsValid() and List:IsVisible())then
				local log = um:ReadString()
				print("Log Recieved: "..log)
				str = string.sub(log,4,-5)
				date = string.sub(str,1,2).."/"..string.sub(str,3,4).."/"..string.sub(str,5,6)
				time = " - "..string.sub(str,7,8)..":"..string.sub(str,9,10)
				List:AddLine(EZdate(date)..time,log)
				
				LDE.Logger.OutDated = false --Were getting logs, its safe to assume were updated now.
			else
				--Request the files to stop being sent.
			end
		elseif(id=="data")then
			local log = um:ReadString()
			local line = tonumber(um:ReadString())
			local max = tonumber(um:ReadString())
			print("Log Data Recieved: "..log)
			LDE.Logger.logdata:AddLine(string.sub(log,1,14),string.sub(log,15,-3))
			LDE.Logger.Values.Max = max
			LDE.Logger.Values.Line = line
			LDE.Logger.ProgressBar()
		elseif(id=="save")then
			print("Log SaveAlert Recieved")
			LDE.Logger.LogStart = CurTime()
			LDE.Logger.OutDated = true
		end
	end
	usermessage.Hook("ldeLOGmessage", acceptmessage)
	
	
	function LDE.Logger.RefreshLogs()
		RunConsoleCommand( "lderequestlogs" )
		LDE.Logger.filelist:Clear()
	end
	
	function LDE.Logger.ProgressBar()
		local ProPanel = LDE.Logger.Progress or nil
		if(not ProPanel or not ProPanel:IsValid())then
			--Make the Progress bar
			local Panel = LDE.UI.CreateFrame({x=200,y=80},true,false,true,true)
			Panel.Bar = LDE.UI.CreatePBar(Panel,{x=190,y=30},{x=5,y=30},0)
			Panel:Center()
			Panel:SetTitle( "Downloading Logs, Please Wait." )
			Panel:MakePopup()
			LDE.Logger.Progress = Panel
			Panel.Bar.Think = function(self)
				local Max = LDE.Logger.Values.Max
				local Num = LDE.Logger.Values.Line
				local percent = ((Num/Max)*100)
				LDE.Logger.Progress.Bar:SetFraction(percent*0.01)
				if(percent>=100)then
					LDE.Logger.Progress:Remove()
					LDE.Logger.Progress = nil
				end
			end
		end
	end
	
	function LDE.Logger.RefreshButton()
		local button = LDE.Logger.RefreshAll
		local SuperMenu = LDE.UI.SuperMenu.Menu.Catagorys
		
		if(not LDE.Logger.OutDated)then if(button and button:IsValid())then SuperMenu:SetMouseInputEnabled( true ) button:Remove() end return end --We arnt outdated, dont show the button.
		if(button and button:IsValid())then return end
		
		
		SuperMenu:SetMouseInputEnabled( false ) -- Make the supermenu unclickable.
		
		local base = LDE.UI.CreateFrame({x=200,y=60},true,false,false,true)
		base:Center()
		base:SetTitle( "Please Click Refresh." )
		base:MakePopup()
		LDE.Logger.RefreshAll = base
		
		local clearall = vgui.Create( "DButton", base )
		clearall:SetSize( 200, 30 )
		clearall:SetPos( 0, 25 )
		clearall:SetText( "Refresh" )
		clearall.DoClick = function()
			if(SuperMenu and SuperMenu:IsValid())then --Only Refresh if the super menu is open.
				LDE.Logger.RefreshLogs()
				SuperMenu:SetMouseInputEnabled( true ) --Make the menu clickable again.
			end
			LDE.Logger.RefreshAll:Remove() --Remove the button.
		end
	end
	--Put hook to tell players their logs are outdated.
	
	
	function LDE.Logger.LogMenu()
			local no = 0
			local log = ""
			local SuperMenu = LDE.UI.SuperMenu.Menu.Catagorys
			------- BASE --------
			--local base = LDE.UI.CreateFrame({x=ScrW()-100,y=ScrH()-100},true,true,false,true)
			local base_height, base_width = 0
			base = vgui.Create( "DPanel", SuperMenu )
			base:SizeToContents()
			base.Paint = function() end
			SuperMenu:AddSheet( "Logging", base, "gui/silkicons/box", false, false, "View the Logging System" ) 

			LDE.Logger.OutDated = true
			
			------ Sheets -------
			local menus = LDE.UI.CreatePSheet(base,{x=ScrW()-120,y=ScrH()-163 },{x=0,y=0})
				------ Page 1 ------
				page1 = LDE.UI.CreateFrame({x=10,y=10},true,false,false)
				page1:SizeToContents()
				page1.Paint = function() LDE.Logger.RefreshButton() end
					------ File List -------
					LDE.Logger.filelist = vgui.Create( "DListView", page1 )
					LDE.Logger.filelist:SetSize( 125, menus:GetTall() - page1:GetTall() - 30 )
					LDE.Logger.filelist:SetMultiSelect( false )
					LDE.Logger.filelist:AddColumn( "Logs" )
					LDE.Logger.filelist:AddColumn( "file" ):SetFixedWidth(0)
					LDE.Logger.filelist:SortByColumn( 1, true )
					
					LDE.Logger.RefreshLogs() --Should automaticly refresh logs if possible.
					
					------- Log Data ------
					LDE.Logger.logdata = vgui.Create( "DListView", page1 )
					LDE.Logger.logdata:SetMultiSelect( false )
					LDE.Logger.logdata:SetSize(ScrW()-120 - LDE.Logger.filelist:GetWide() - 31, LDE.Logger.filelist:GetTall())
					LDE.Logger.logdata:AddColumn( "Time" ):SetFixedWidth( 80 )
					LDE.Logger.logdata:AddColumn( "Event" )
					LDE.Logger.logdata:SetPos( LDE.Logger.filelist:GetWide()+5,0)
					LDE.Logger.logdata:SortByColumn( 1 , true )
					menus:AddSheet( "Eventlogs", page1, "gui/silkicons/box", false, false, "View the saved logs" )
					
					------ *READ LOG DATA* ------
					LDE.Logger.filelist.OnClickLine = function(parent, line, isselected)
						LDE.Logger.logdata:Clear()
						RunConsoleCommand( "lderequestdata",Folder.."/"..line:GetValue(2))		
					end

	--[[		if LocalPlayer():IsAdmin() or ULib.ucl.query( LocalPlayer(), "ulx rdmreport" ) then
				page2 = vgui.Create( "DFrame" )
				page2:SizeToContents()
				page2.Paint = function()
				end
				page2:ShowCloseButton( false )
				page2:SetTitle("")
				
				menus:AddSheet( "Reports", page2, "gui/silkicons/application_view_detail", false, false, "View player reports" )
			end
	--]]
			------ PAGE 3 ------		
			if LocalPlayer():IsAdmin() then

				page3 = LDE.UI.CreateFrame({x=10,y=10},true,false,false)
				page3:SizeToContents()
				page3.Paint = function()
				page3:SetTitle( "" )
				end
					------ MaxLogs ------
					local maxlogs_slider = LDE.UI.CreateSlider(page3,{x=0,y=0},{Min=0,Max=250,Dec=0},500)
					maxlogs_slider:SetText( "  Maximum number of logs\n  the server will store" )
					maxlogs_slider:SetValue( GetGlobalInt("eventlog_maxlogs") )
					maxlogs_slider:SetConVar( "eventlog_maxlogs" )
					------ MaxBuffer ------
					local maxbuff_slider = LDE.UI.CreateSlider(page3,{x=0,y=32},{Min=0,Max=1000,Dec=0},500)
					maxbuff_slider:SetText( "  Maximum number of \n events stored in each log" )
					maxbuff_slider:SetValue( GetGlobalInt("eventlog_maxbuffer") )
					maxbuff_slider:SetConVar( "eventlog_maxbuffer" )
					------ Refresh Logs Button -------
					local clearall = vgui.Create( "DButton", page3 )
					clearall:SetSize( 75, 30 )
					clearall:SetPos( 5, 64 )
					clearall:SetText( "Refresh Logs." )
					clearall.DoClick = function()
						LDE.Logger.RefreshLogs()
					end
				menus:AddSheet( "Settings", page3, "gui/silkicons/wrench", false, false, "Change settings" ) 
			end
	end
	--concommand.Add( "eventlogmenu", LogMenu )
	--hook.Add("LDEFillCatagorys","LoggingMenu",LDE.Logger.LogMenu)
	
	
end