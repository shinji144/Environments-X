--[[----------------------------------------------------
Jupiter Debug Core -Allows Easy Debugging.
----------------------------------------------------]]--

local LDE = LDE --Localise the global table for speed.
LDE.DebugLogs = LDE.DebugLogs or {}

local DebugLogging = LDE.EnableMenu
local DebugTypes = {Verbose=3,Basic=2,None=1}
local DebugMode = DebugTypes["None"]
local DebugLogs = LDE.DebugLogs

function LDE.SetDebugMode(Mode)
	if not DebugTypes[Mode] then 
		print("Error! Debug Mode is Invalid! Defaulting to 'None'.") 
		LDE.DebugMode="None"
		DebugMode = DebugTypes["None"]
		return
	end
	
	LDE.DebugMode=Mode
	DebugMode = DebugTypes[Mode]
end
LDE.SetDebugMode(LDE.DebugMode)

function LDE.Debug(MSG,Type,Source)
	--print("T: "..tostring(Type).." D: "..tostring(DebugMode))
	if Type <= DebugMode then
		if SERVER then
			print("SD["..tostring(Source or "Error").."]: "..tostring(MSG))
			MsgAll("SD["..tostring(Source or "Error").."]: "..tostring(MSG).."\n")
		else
			print("SD["..tostring(Source or "Error").."]: "..tostring(MSG))
		end
	end
	if DebugLogging then
		if not SERVER then return end --Add client to server logging later.
		local Log = {C=math.floor(CurTime()),M=MSG}
		if not DebugLogs[Source] then 
			DebugLogs[Source] = {}
		end
		table.insert(DebugLogs[Source],Log)
	end
end

if not DebugLogging then return end

if SERVER then
	util.AddNetworkString('Jupiter_Debug_MSG')

	function LDE.MenuCore.OpenPanel( ply )
		ply:ConCommand( "opendebugmenu" )
	end
	--hook.Add( "ShowSpare2", "bindtoSpare2", LDE.MenuCore.OpenPanel )

	function SendDebugTypes(ply)
		for k, log in pairs(DebugLogs) do
			net.Start( "Jupiter_Debug_MSG" )
				net.WriteString("Types")
				net.WriteString(k)
			net.Send( ply )		
		end
	end
	
	function SendDebugLogs(ply,Type)
		local num = 1
		for k, log in pairs(DebugLogs[Type] or {}) do
			timer.Simple((num*0.1)+0.01, function() 
				net.Start( "Jupiter_Debug_MSG" )
					net.WriteString("Logs")
					net.WriteString(log.C)
					net.WriteString(log.M)
					net.WriteString(Type)
				net.Send( ply )		
			end)
			num=num+1
		end
	end
	
	net.Receive("Jupiter_Debug_MSG", function(length, client)
		local Type = net.ReadString()
		if Type == "Types" then
			SendDebugTypes(client)
		elseif Type == "Logs" then
			SendDebugLogs(client,net.ReadString())
		end
	end)
else
	local RecievedLogs = 0
	local Logs = {}
	local Super = {}
	
	function SelectType(Type)
		net.Start('Jupiter_Debug_MSG')
			net.WriteString("Logs")
			net.WriteString(Type)
		net.SendToServer()
		
		Super.Selected = Type
		Super.LogDisplay:Clear()
	end
	
	function LDE.MenuCore.SuperMenu.MenuOpen()
		--Add a check so multiple menus cant open at once.
		Super = {}
		Super.Base = LDE.MenuCore.CreateFrame({x=700,y=500},true,true,false,true)
		Super.Base:Center()
		Super.Base:SetTitle( "LDE Debug Logger" )
		Super.Base:MakePopup()
		
		local menupage = LDE.MenuCore.CreateList(Super.Base,{x=150,y=460},{x=10,y=30},false,SelectType)
		menupage:AddColumn("LogType") -- Add column
		Super.LogTypes = menupage
		
		local menupage = LDE.MenuCore.CreateList(Super.Base,{x=520,y=460},{x=170,y=30},false,function() end)
		menupage:AddColumn("Time") -- Add column
		menupage:AddColumn("Logs") -- Add column
		Super.LogDisplay = menupage
		
		net.Start('Jupiter_Debug_MSG')
			net.WriteString("Types")
		net.SendToServer()
	
		LDE.MenuCore.SuperMenu.Menu = Super
	end
	concommand.Add( "opendebugmenu", LDE.MenuCore.SuperMenu.MenuOpen )
	
	function AddType(Type)
		if Super.LogTypes and IsValid(Super.LogTypes) then
			Super.LogTypes:AddLine(Type)
		end
	end
	
	function AddLog(Time,MSG,Type)
		if Super.Selected == Type then
			if Super.LogDisplay and IsValid(Super.LogDisplay) then
				Super.LogDisplay:AddLine(Time,MSG)
			end
		end
	end
	
	net.Receive("Jupiter_Debug_MSG", function(length, client)
		local Type = net.ReadString()
		if Type == "Types" then
			AddType(net.ReadString())
		elseif Type == "Logs" then
			AddLog(net.ReadString(),net.ReadString(),net.ReadString())
		end
	end)
end







