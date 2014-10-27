
if(SERVER)then


else
	local VGUI = {}
	function VGUI:Init()
		
		local BuildList = LDE.Factorys.BuildList
		
		local FactoryMenu = LDE.UI.CreateFrame({x=700,y=400},true,true,false,true)
		FactoryMenu:Center()
		FactoryMenu:SetTitle( "Vending Machine" )
		FactoryMenu:MakePopup()
		
		local schematicBox = LDE.UI.CreateList(FactoryMenu,{x=150,y=350},{x=10,y=35},false)
		schematicBox:SetParent(FactoryMenu)
		schematicBox:AddColumn("Consumables.") -- Add column
		
		--Schematic Items--
		//schematicBox:AddLine("Basic Bomb")
		for k,v in pairs(BuildList) do
			schematicBox:AddLine(v.name)
		end
		------------------
		local ModelDisplay = LDE.UI.DisplayModel(FactoryMenu,180,{x=520,y=0},"models/Slyfo_2/acc_food_fooddispenser.mdl",80)
		
		local infoBox = vgui.Create( "DPanel", DermaFrame ) 
		infoBox:SetPos( 170, 35 )
		infoBox:SetSize( 350, 350)
		infoBox:SetParent(FactoryMenu)
		infoBox.Paint = function()    
			surface.SetDrawColor( 50, 50, 50, 255 )
			surface.DrawRect( 0, 0, infoBox:GetWide(), infoBox:GetTall() )
			
			if schematicBox:GetSelected() and schematicBox:GetSelected()[1] then 
			local selectedValue = schematicBox:GetSelected()[1]:GetValue(1) 
			local curselected = {}
			-- Get description data ----------------------
			for k,v in pairs(BuildList) do
				if(selectedValue==v.name)then
					curselected = v
					itemDesc=v.desc
					break
				end
			end
			if(curselected.model)then
				local View = curselected.CamDist or 80
				ModelDisplay:SetCamPos(Vector(View,View,View))
				ModelDisplay:SetModel(curselected.model)
				if(curselected.Look)then
					ModelDisplay:SetLookAt(Vector(0,0,Look))
				end
			end
			-- End description data calls ----------------
					
			--surface.SetFont( "default" )
			surface.SetTextColor( 255, 255, 255, 255 )
			posy = 10
				surface.SetTextPos( 15, posy )
				surface.DrawText(curselected.name)
				posy = posy + 10
				surface.SetTextPos( 15, posy )
				surface.DrawText("------------------")
				posy = posy + 20
				for _, textLine in pairs (itemDesc) do
					surface.SetTextPos( 15, posy )
					surface.DrawText(textLine)
					posy = posy + 10
				end
				posy = posy + 20
				surface.SetTextPos( 15, posy )
				surface.DrawText("Required Resources:")
				posy = posy + 10
				for k, textLine in pairs (curselected.materials) do
					surface.SetTextPos( 15, posy )
					surface.DrawText(textLine..": ["..curselected.matamount[k].."]")
					posy = posy + 10
				end
			end	
			
			surface.SetTextColor( 255, 255, 255, 255 )
					
		end
		
		local cancelButton = LDE.UI.CreateButton(FactoryMenu,{x=180,y=60},{x=520,y=325})
		cancelButton:SetText( "Cancel" )
		cancelButton.DoClick = function ()
			FactoryMenu:Remove()
		end
		
		local okButton = LDE.UI.CreateButton(FactoryMenu,{x=180,y=40},{x=520,y=285})
		okButton:SetText( "Vend Item" )
		okButton.DoClick = function ()
			if schematicBox:GetSelected() and schematicBox:GetSelected()[1] then
				RunConsoleCommand( "builditem", schematicBox:GetSelected()[1]:GetValue(1), entID  )
				FactoryMenu:Remove()
			end
		end
		
	end
	 
	vgui.Register( "VendingMenu", VGUI )
			
end		
		
		
		
		
		
		
		