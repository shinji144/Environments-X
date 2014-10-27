if(SERVER)then

	function requestmarket(ply, cmd, args)
		print("Market Request from: "..ply:Name().." for "..args[1])
		local Resource = LDE.Cash.Market.Resources[args[1]]
		if(not Resource)then Resource=LDE.Cash.Market.Resources[string.lower(args[1])]  end
		umsg.Start("envmarketupdate",ply)
		umsg.String(Resource.Amount)
		umsg.String(Resource.CPU);
		umsg.End()
		print("Request sent out.")
	end
	concommand.Add("requestmarket", requestmarket)

	function findvalue(find)
		for k,v in pairs(LDE.Cash.Resources) do
			if(find==v.O)then
				return LDE.Cash.Market.Resources[v.O]
			end
		end
	end


	function sellstuff(ply, cmd, args)
	//	Msg("Attempting to sell "..args[1].." A: "..args[2].."\n")
		for _, ent in pairs(ents.FindByClass("env_tradeconsole")) do
			if ent:GetCreationID() == tonumber(args[3]) then
				if(ent:GetResourceAmount(args[1])>=tonumber(args[2]))then
					if(LDE.Cash.Market.Resources[args[1]].Amount>=tonumber(args[2]))then
						local stuff = findvalue(args[1])
						if(not stuff)then return end
						ent:ConsumeResource(args[1], tonumber(args[2]))
						local profit = LDE.Cash.Market.AddResource(args[1],tonumber(args[2]))
						//Msg(profit.."\n")
						LDE.GiveMoney(ply,profit)
						ply:GiveLDEStat("Trades", tonumber(args[2]))
					end
				end
				break
			end
		end
	end

	concommand.Add("sellstuff", sellstuff)
	   
	function buystuff(ply, cmd, args)
	//	Msg("Attempting to buy "..args[1].." A: "..args[2].."\n")
		for _, ent in pairs(ents.FindByClass("env_tradeconsole")) do
			if ent:GetCreationID() == tonumber(args[3]) then
				local stuff = findvalue(args[1])
				if(not stuff)then return end
				local profit = LDE.Cash.Market.TakeResource(args[1],tonumber(args[2]),ply)
				//Msg(profit.."\n")
				if(profit==0)then return end
				LDE.TakeMoney(ply,profit)
				ent:SupplyResource(args[1], tonumber(args[2]))
				break
			end
		end
	end

	concommand.Add("buystuff", buystuff)

else
	local function Smallifynumber(Number)
		Number=tonumber(Number)
		if(Number>1000000)then return math.floor(Number/1000000).."M"
		elseif(Number>1000)then return math.floor(Number/1000).."K"
		else return math.floor(Number)
		end
	end
	
	local function GetTradeAmount()
		return math.Clamp(GetConVarNumber( "tradeamount" ),0,10000)
	end
	
	local VGUI = {}
	function VGUI:Init()
		
		local TradeList = LDE.Cash.Resources
		local curselected = {}	

		local MarketMenu = LDE.UI.CreateFrame({x=700,y=400},true,true,false,true)
		MarketMenu:Center()
		MarketMenu:SetTitle( "Trade Market" )
		MarketMenu:MakePopup()

		local schematicBox = LDE.UI.CreateList(MarketMenu,{x=150,y=350},{x=10,y=35},false)
		schematicBox:SetParent(MarketMenu)
		schematicBox:AddColumn("Resources") -- Add column
		
		--Schematic Items--
		for k,v in pairs(TradeList) do
			schematicBox:AddLine(v.name)
		end
			
		local infoBox = vgui.Create( "DPanel", DermaFrame ) 
		infoBox:SetPos( 170, 35 )
		infoBox:SetSize( 350, 350)
		infoBox:SetParent(MarketMenu)
		infoBox.Paint = function()    
			surface.SetDrawColor( 50, 50, 50, 255 )
			surface.DrawRect( 0, 0, infoBox:GetWide(), infoBox:GetTall() )
				
			if schematicBox:GetSelected() and schematicBox:GetSelected()[1] then 
				local selectedValue = schematicBox:GetSelected()[1]:GetValue(1) 
				-- Get description data ----------------------
				for k,v in pairs(TradeList) do
					if(selectedValue==v.name)then
						curselected = v
						itemDesc=v.desc
						break
					end
				end
				if(not self.Cur)then self.Cur = 0 self.Source = curselected end
				if(CurTime()>=self.Cur or self.Source.name != curselected.name)then
					self.Source = curselected
					self.Cur = CurTime()+2
					RunConsoleCommand( "requestmarket", schematicBox:GetSelected()[1]:GetValue(1), entID  )
				end
				
				surface.SetTextColor( 255, 255, 255, 255 )
				posy = 10
				surface.SetTextPos( 15, posy )
				surface.DrawText(curselected.name)
				posy = posy + 10
				surface.SetTextPos( 15, posy )
				if(cost and amount)then
					surface.DrawText("Amount: "..amount.." V.P.U: "..(cost))
				end
				posy = posy + 10
				surface.SetTextPos( 15, posy )
				surface.DrawText("-----------------")
				posy = posy + 10
				for _, textLine in pairs (itemDesc) do
					surface.SetTextPos( 15, posy )
					surface.DrawText(textLine)
					posy = posy + 10
				end
			end	
			
			surface.SetTextColor( 255, 255, 255, 255 )
					
		end

		if(not Mode)then Mode = "Buy" end

		CreateClientConVar( "tradeamount", "0",false,false)

		
		local Slide = LDE.UI.CreateSlider(MarketMenu,{x=520,y=205},{Min=0,Max=10000,Dec=0},170)
		Slide:SetText( "Amount" )
		Slide:SetConVar( "tradeamount" )
		
		local change = LDE.UI.CreateButton(MarketMenu,{x=180,y=40},{x=520,y=165})
		change.DoClick = function() end
		change.Paint = function() 
			local cost = cost or 0
			if(Mode=="Buy")then
				change:SetText( "Taus: "..Smallifynumber(cost*GetTradeAmount()) )
			else
				change:SetText( "Taus: "..Smallifynumber((cost*GetTradeAmount())*0.9) )
			end
		end
		
		local confirm = LDE.UI.CreateButton(MarketMenu,{x=180,y=40},{x=520,y=280})
		confirm:SetText( "Mode: "..Mode.." Confirm" )
		confirm.DoClick = function ()
			if schematicBox:GetSelected() and schematicBox:GetSelected()[1] then
				if(Mode=="Sell" and curselected.E)then return end
				RunConsoleCommand( string.lower(Mode).."stuff", curselected.O, GetTradeAmount(), entID  )
				RunConsoleCommand( "requestmarket", curselected.O, entID  )
			end
		end
				
		local buyButton = LDE.UI.CreateButton(MarketMenu,{x=90,y=30},{x=520,y=245})
		buyButton:SetText( "Buy" )
		buyButton.DoClick = function ()
			Mode = "Buy"
			confirm:SetText( "Mode: "..Mode.." Confirm" )
		end
				
		local sellButton = LDE.UI.CreateButton(MarketMenu,{x=90,y=30},{x=610,y=245})
		sellButton:SetText( "Sell" )
		sellButton.DoClick = function ()
			if(not curselected.E)then
				Mode = "Sell"
				confirm:SetText( "Mode: "..Mode.." Confirm" )
			end
		end
				
		local cancelButton = LDE.UI.CreateButton(MarketMenu,{x=180,y=60},{x=520,y=325})
		cancelButton:SetText( "Cancel" )
		cancelButton.DoClick = function ()
			MarketMenu:Remove()
		end
				
	end
	 
	vgui.Register( "MarketMenu", VGUI )

	function marketupdate(um)
		amount = um:ReadString()
		cost = um:ReadString()
		print("Recieved market update.")
	end
	usermessage.Hook("envmarketupdate", marketupdate)

end		
		
		
		
		
		
		
		
