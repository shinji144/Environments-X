if(SERVER)then


else

	function ECDTab()
		local SuperMenu = LDE.UI.SuperMenu.Menu.Catagorys

		local base = vgui.Create( "DPanel", SuperMenu )
		base:SizeToContents()
		base.Paint = function() end
		SuperMenu:AddSheet( "Help", base, "icon16/book_open.png", false, false, "Complete Missions" ) 
		
		local List = LDE.UI.CreateList(base,{x=300,y=200},{x=0,y=0},false,function() end)
		List:AddColumn("Topic") -- Add column

		--[[for k,v in pairs(LocalPlayer():GetStats()) do
			List:AddLine(k,v)
		end]]
	end

	hook.Add("LDEFillCatagorys","Missions",ECDTab)	
end		
	