if(SERVER)then


else

	function ECDTab()
		local SuperMenu = LDE.UI.SuperMenu.Menu.Catagorys

		local base = vgui.Create( "DPanel", SuperMenu )
		base:SizeToContents()
		base.Paint = function() end
		SuperMenu:AddSheet( "Transfer", base, "icon16/group_go.png", false, false, "Transfer Resources" ) 
		
		CreateClientConVar( "cashtransfer_amount", "200",false,false)

		local cashamount = LDE.UI.CreateSlider(base,{x=0,y=0},{Min=0,Max=2000000,Dec=0},1000)
		cashamount:SetText( "Amount of Taus \n That get sent." )
		cashamount:SetValue( 0 )
		cashamount:SetConVar( "cashtransfer_amount" )
		
		local PlayerSelect = vgui.Create( "DTextEntry", base )	-- create the form as a child of frame
		PlayerSelect:SetPos( 5, 35 )
		PlayerSelect:SetSize( 200, 30 )
		PlayerSelect:SetText( "PlayerName" )
		PlayerSelect.OnEnter = function( self )	end

		local dotransfer = vgui.Create( "DButton", base )
		dotransfer:SetSize( 75, 30 )
		dotransfer:SetPos( 5, 70 )
		dotransfer:SetText( "TransferFunds" )
		dotransfer.DoClick = function()
			RunConsoleCommand( "LDE_sendfunds", PlayerSelect:GetValue(), GetConVarNumber( "cashtransfer_amount" )  )
		end
		
	end

	--hook.Add("LDEFillCatagorys","Resource Transfer",ECDTab)	
end		
		
		
		
		
		
		
		
