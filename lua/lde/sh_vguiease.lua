--[[----------------------------------------------------
Jupiter Menu Core -Provides a modular menu system.
----------------------------------------------------]]--

local SCF = LDE --Localise the global table for speed.
SCF.MenuCore = {}
SCF.MenuCore.SuperMenu = {}

local MC = SCF.MenuCore

if(CLIENT)then
	---------------------------------------------------------------
	---------------Vgui Derma Related Functions--------------------
	---------------------------------------------------------------
	
	function MC.CreateFrame(Size,Visible,XButton,Draggable,CloseDelete)
		local Derma = vgui.Create( "DFrame" )
			if Derma then
				Derma:SetSize( Size.x, Size.y )
				Derma:SetVisible( Visible )
				Derma:ShowCloseButton( XButton )
				Derma:SetDraggable( Draggable )
				Derma:SetDeleteOnClose( CloseDelete )
			end
		return Derma
	end
	
	function MC.CreatePanel(Parent,Size,Spot,Draw)
		local Derma = vgui.Create( "DPanel", Parent )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetPos( Spot.x, Spot.y )
			Derma.Paint = Draw or Derma.Paint
		return Derma
	end

	function MC.CreateTextBar(Parent,Size,Spot,Text,Func)
		local Derma = vgui.Create( "DTextEntry", Parent )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetText( Text )
			Derma.OnEnter = function( self )
				Func( self:GetValue() )	
			end
		return Derma
	end

	function MC.AdvTextInput(Parent,Size,Spot,Text,Value,Func)
		local Input = MC.CreatePanel(Parent,{x=Size.x,y=Size.y},{x=Spot.x,y=Spot.y})
		Input.TextLabel = MC.CreateText(Input,{x=5,y=3},Text,Color(0,0,0,255))
		Input.InputBox = MC.CreateTextBar(Input,{x=(Size.x)/4,y=Size.y},{x=Size.x*0.75,y=0},Value,Func)
		
		Input.SetText= function(self,Text) self.TextLabel:SetText(Text) end
		Input.SetValue= function(self,Value) self.InputBox:SetText(Value) end
		
		return Input
	end

	function MC.CreateSlider(Parent,Spot,Values,Width)
		local Derma = vgui.Create( "DNumSlider", Parent )
			Derma:SetMinMax( Values.Min, Values.Max )
			Derma:SetDecimals( Values.Dec )
			Derma:SetWide( Width )
			Derma:SetPos( Spot.x, Spot.y )
		return Derma
	end
	
	function MC.CreatePSheet(Parent,Size,Spot)
		local Derma = vgui.Create( "DPropertySheet", Parent )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetPos( Spot.x, Spot.y )
		return Derma
	end
	
	function MC.DisplayModel(Parent,Size,Spot,Model,View,Look)
		local Derma = vgui.Create( "DModelPanel", Parent )
			Derma:SetModel(Model)
			Derma:SetSize( Size, Size )
			Derma:SetCamPos(Vector(View,View,View))
			if(Look)then
				Derma:SetLookAt(Vector(0,0,Look))
			end
			Derma:SetPos( Spot.x, Spot.y )
		return Derma
	end	
	
	function MC.CreatePBar(Parent,Size,Spot,Progress)
		local Derma = vgui.Create( "DProgress", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetFraction( Progress() )
			Derma.OThink=Derma.Think
			Derma.Think=function(self)
				self:SetFraction( Progress())
				--self:OThink()
			end
		return Derma
	end
	
	function MC.CreateText(Parent,Spot,Text,Color)
		local Derma = vgui.Create( "DLabel", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetText( Text or "" )
			Derma:SetTextColor( Color or Color( 255, 255, 255, 255 ) )
			Derma.OldText = Derma.SetText
			Derma.SetText = function(self,Text)
				self:OldText(Text)
				self:SizeToContents()
			end
			Derma:SizeToContents()
		return Derma
	end
	
	function MC.PropertyGrid(Parent,Size,Spot)
		local Derma = vgui.Create( "DProperties",Parent )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetPos( Spot.x, Spot.y )
			Derma.GetPParent = function() return Parent end
			Derma.GetPSize = function() return Size end
			Derma.GetPPos = function() return Spot end
		return Derma
	end
	
	function MC.CreateList(Parent,Size,Spot,Multi,Func)
		local Derma = vgui.Create( "DListView", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetMultiSelect(Multi)
			if Func then 
				Derma.OldThink = Derma.Think or function() end
				Derma.Think = function(self) 	
					if self:GetSelected() and self:GetSelected()[1] then 
						local selectedValue = self:GetSelected()[1]:GetValue(1) 
						if selectedValue ~= self.Selected then 
							self.Selected = selectedValue
							Func(selectedValue)
						end
					end 
					self:OldThink() 
				end 
			end
		return Derma
	end	
	
	function MC.CreateButton(Parent,Size,Spot,Text,OnClick)
		local Derma = vgui.Create( "DButton", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetText( Text or "" )
			Derma.DoClick = OnClick or function() end
		return Derma
	end
	
	function MC.LoadWebpage(Parent,Size,Link)
		local label = vgui.Create("HTML",Parent)
		label:SetSize(Size.x, Size.y)
		label:OpenURL(Link)
		return label		
	end
	
	function MC.LoadHtml(Parent,Text)
		SCF.Debug("Opening Url: "..Text,3,"MenuCore")
		local label = vgui.Create("HTML",Parent)
		label:SetSize(800, 200)
		label:OpenURL(Text)
		return label
	end
	
	---------------------------------------------------------------
	--------------Draw Library Related Functions-------------------
	---------------------------------------------------------------
	
	function MC.DrawRoundedBox(Size,Spot,Color,Sides)
		draw.RoundedBoxEx( Sides.R, Spot.x, Spot.y, Size.x, Size.y, Color, Sides.TL, Sides.TR, Sides.BL, Sides.BR )
	end
	
else
	----Server side-----

end