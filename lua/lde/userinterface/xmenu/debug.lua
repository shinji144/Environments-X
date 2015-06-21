local Utl = LDE.Utl --Makes it easier to read the code.

if(SERVER)then
	util.AddNetworkString('Jupiter_Debug_MSG')

	function SendDebugTypes(ply)
		for k, log in pairs(LDE.DebugLogs) do
			net.Start( "Jupiter_Debug_MSG" )
				net.WriteString("Types")
				net.WriteString(k)
			net.Send( ply )		
		end
	end
	
	function SendDebugLogs(ply,Type)
		local num = 1
		for k, log in pairs(LDE.DebugLogs[Type] or {}) do
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

	--The actual panel generation....
	hook.Add("LDEFillCatagorys","Debug", function()
		if not LocalPlayer():IsAdmin() then print("Not a admin!") return end
		Super = LDE.UI.SuperMenu.Menu.Catagorys
		
		local base = vgui.Create( "DPanel", Super )
		base:SizeToContents()
		base.Paint = function() end
		Super:AddSheet( "Logging", base, "icon16/application_view_list.png", false, false, "Check the Debug Logs!" ) 
		
		local menupage = LDE.MenuCore.CreateList(base,{x=150,y=520},{x=5,y=5},false,SelectType)
		menupage:AddColumn("LogType") -- Add column
		Super.LogTypes = menupage
		
		local menupage = LDE.MenuCore.CreateList(base,{x=600,y=520},{x=160,y=5},false,function() end)
		menupage:AddColumn("Time") -- Add column
		menupage:AddColumn("Logs") -- Add column
		Super.LogDisplay = menupage
				
		net.Start('Jupiter_Debug_MSG')
			net.WriteString("Types")
		net.SendToServer()
	end)
end		
	