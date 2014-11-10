if(SERVER)then


else

	function ECDTab()
		local SuperMenu = LDE.UI.SuperMenu.Menu.Catagorys

		local base = vgui.Create( "DPanel", SuperMenu )
		base:SizeToContents()
		base.Paint = function() end
		SuperMenu:AddSheet( "Stats", base, "icon16/book_open.png", false, false, "View your stats." ) 
		
	end

	--hook.Add("LDEFillCatagorys","Stats",ECDTab)	
end		
	