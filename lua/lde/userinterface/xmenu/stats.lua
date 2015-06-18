if(SERVER)then


else	
	local function OnSelect(B,N)
		B.SL:Clear() B.PI:Clear()
		local ply = B.Players[N]
		
		
		B.PI:AddLine("Name",N)
		B.PI:AddLine("Team",team.GetName(ply:Team()))
		B.PI:AddLine("IsAdmin",tostring(ply:IsAdmin() or ply:IsSuperAdmin()))
		
		for k,v in pairs(ply:GetStrings()) do
			B.PI:AddLine(k,v)
		end
		
		for k,v in pairs(ply:GetStats()) do 
			B.SL:AddLine(k,v) 
		end
	end
	
	hook.Add("LDEFillCatagorys","Stats", function()
		local SuperMenu = LDE.UI.SuperMenu.Menu.Catagorys

		local base = vgui.Create( "DPanel", SuperMenu )
		base:SizeToContents()
		base.Paint = function() end
		SuperMenu:AddSheet( "Stats", base, "icon16/chart_bar.png", false, false, "View your stats." ) 
		base.Players = {}
		
		
		local PL = LDE.UI.CreateList(base,{x=160,y=525},{x=0,y=0},false,function(V) OnSelect(base,V) end)
		PL:AddColumn("Player") -- Add column
		for k,v in pairs(player.GetAll()) do base.Players[v:Name()]=v PL:AddLine(v:Name()) end
		
		base.PL = PL
		
		local PI = LDE.UI.CreateList(base,{x=250,y=140},{x=170,y=0},false,function() end)
		PI:AddColumn("Item") -- Add column
		PI:AddColumn("Value") -- Add colum		
		
		base.PI = PI
		
		local SL = LDE.UI.CreateList(base,{x=250,y=375},{x=170,y=150},false,function() end)
		SL:AddColumn("Item") -- Add column
		SL:AddColumn("Amount") -- Add column
		
		base.SL = SL
		
		OnSelect(base,LocalPlayer():Name())
	end)
end		
	