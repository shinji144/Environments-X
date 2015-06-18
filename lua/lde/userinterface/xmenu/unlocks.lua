if(SERVER)then


else
		
	function UnlockTab()
		local SuperMenu = LDE.UI.SuperMenu.Menu.Catagorys

		local base = vgui.Create( "DPanel", SuperMenu )
		base:SizeToContents()
		base.Paint = function() end
		SuperMenu:AddSheet( "Unlocks", base, "icon16/cart.png", false, false, "Unlock new things!" ) 
		
		--Unlocks List.
		local ListContainer = vgui.Create( "DPanel", base )
		ListContainer:SetSize(300,525)
		ListContainer.base = base
		
		function ListContainer:RefreshList()
			local list = vgui.Create( "DPanelList",ListContainer )
			list:SetSize(300,525)
			list:SetPadding( 1 )
			list:SetSpacing( 1 )
			list:EnableVerticalScrollbar(true)
			self.List = list
			
			for k,v in pairs(LDE.Unlocks) do
				local c = vgui.Create("DCollapsibleCategory")
				c:SetLabel(k)
				c:SetExpanded(false)
				
				local CategoryList = vgui.Create( "DPanelList" )
				CategoryList:SetAutoSize( true )
				CategoryList:SetSpacing( 6 )
				CategoryList:SetPadding( 3 )
				CategoryList:EnableHorizontal( true )
				CategoryList:EnableVerticalScrollbar( true )
				
				for e,d in pairs(v) do
					local icon = vgui.Create("SpawnIcon")
					
					util.PrecacheModel(d.Model)
					icon:SetModel(d.Model, 0)
					icon:SetTooltip(d.ToolTip)
					icon.base = self.base
					icon.data = d
					icon.DoClick = function(self)						
						self.base.UnlockButton:SetText("Unlock: "..self.data.Cost)
						self.base.UnlockButton.Selected = self.data
						self.base.UnlockStats:SetStats(self.data.Stats)
					end
					
					CategoryList:AddItem(icon)
				end
				
				c:SetContents(CategoryList)
				list:AddItem(c)
			end
		end
		
		ListContainer:RefreshList()
		
		local UnlockStats = LDE.UI.CreateList(base,{x=200,y=270},{x=305,y=255},false,function() end)
		--Unlock Stats
		UnlockStats:AddColumn("Stat") -- Add column
		UnlockStats:AddColumn("Value") -- Add colum		
		base.UnlockStats = UnlockStats
				
		function UnlockStats:SetStats(Stats)
			self:Clear()
			
			for k,v in pairs(Stats) do
				self:AddLine(k,v)
			end
		end
		
		--Interface
		local StatContainer = vgui.Create( "DPanel", base )
		StatContainer:SetSize(200,250)
		StatContainer:SetPos(305,0)
		base.StatContainer = StatContainer
		
		local Text = LDE.UI.CreateText(StatContainer,{x=5,y=10},"Cash: 0",Color(0,0,0,255))
		Text.Think = function(self) 
			self:SetText("Cash: "..LocalPlayer():GetLDEStat("Cash"))
		end
		
		local Butt = LDE.UI.CreateButton(StatContainer,{x=200,y=60},{x=0,y=190},"Unlock: (Select Something)",function() end)
		base.UnlockButton = Butt
		
		Butt.DoClick = function(self)
			if self.Selected~=nil then
				RunConsoleCommand( "unlockentity", self.Selected.Type ,self.Selected.Class  )
			end
		end
		
	end

	hook.Add("LDEFillCatagorys","Unlocks",UnlockTab)	
end		
	