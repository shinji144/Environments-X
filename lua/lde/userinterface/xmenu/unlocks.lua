if(SERVER)then


else

	function UnlockTab()
		local SuperMenu = LDE.UI.SuperMenu.Menu.Catagorys

		local base = vgui.Create( "DPanel", SuperMenu )
		base:SizeToContents()
		base.Paint = function() end
		SuperMenu:AddSheet( "Unlocks", base, "icon16/cart.png", false, false, "Unlock new things!" ) 
		
	end

	hook.Add("LDEFillCatagorys","Unlocks",UnlockTab)	
end		
	