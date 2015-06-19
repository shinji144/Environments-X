LDE.UI = {}
LDE.UI.SuperMenu = {}

local Utl = LDE.Utl
local NDat = Utl.NetMan

if(CLIENT)then

	function LDE.UI.SuperMenu.MenuOpen()
		local Super = {}
		Super.Base = LDE.UI.CreateFrame({x=800,y=600},true,true,false,true)
		Super.Base:Center()
		Super.Base:SetTitle( "Environments X PDA" )
		Super.Base:MakePopup()
		
		Super.Catagorys = LDE.UI.CreatePSheet(Super.Base,{x=790,y=565 },{x=5,y=30})
		
		LDE.UI.SuperMenu.Menu = Super
		hook.Call("LDEFillCatagorys")
	end
	concommand.Add( "ldesupermenuopen", LDE.UI.SuperMenu.MenuOpen )
	
	function LDE.UI.CreateFrame(Size,Visible,XButton,Draggable,CloseDelete)
		local Derma = vgui.Create( "DFrame" )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetVisible( Visible )
			Derma:ShowCloseButton( XButton )
			Derma:SetDraggable( Draggable )
			Derma:SetDeleteOnClose( CloseDelete )
		return Derma
	end

	function LDE.UI.CreateSlider(Parent,Spot,Values,Width)
		local Derma = vgui.Create( "DNumSlider", Parent )
			Derma:SetMinMax( Values.Min, Values.Max )
			Derma:SetDecimals( Values.Dec )
			Derma:SetWide( Width )
			Derma:SetPos( Spot.x, Spot.y )
		return Derma
	end
	
	function LDE.UI.CreatePSheet(Parent,Size,Spot)
		local Derma = vgui.Create( "DPropertySheet", Parent )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetPos( Spot.x, Spot.y )
		return Derma
	end
	
	function LDE.UI.DisplayModel(Parent,Size,Spot,Model,View,Look)
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
	
	function LDE.UI.CreateText(Parent,Spot,Text,Color)
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
	
	function LDE.UI.CreatePBar(Parent,Size,Spot,Progress)
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
	
	function LDE.UI.CreateList(Parent,Size,Spot,Multi,Func)
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
	
	function LDE.UI.CreateButton(Parent,Size,Spot,Text,OnClick)
		local Derma = vgui.Create( "DButton", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetText( Text or "" )
			Derma.DoClick = OnClick or function() end
		return Derma
	end
	
	function LDE.UI.LoadWebpage(Parent,Size,Link)
		local label = vgui.Create("HTML",Parent)
		label:SetSize(Size.x, Size.y)
		label:OpenURL(Link)
		return label		
	end
	
	function LDE.UI.LoadHtml(Parent,Text)
		print("Opening Url: "..Text)
		local label = vgui.Create("HTML",Parent)
		label:SetSize(800, 200)
		label:OpenURL(Text)
		return label
	end
	
else
----Server side-----
	print("UserInterface Loading!")
	
	function LDE.UI.OpenPanel( ply )
		ply:ConCommand( "ldesupermenuopen" )
	end
	hook.Add( "ShowSpare1", "bindtoSpare1", LDE.UI.OpenPanel )

	function chatCommand( ply, text, public )
		local Chat = string.Explode(" ",text)
		if Chat[1] == "/pda" then
			LDE.UI.OpenPanel( ply )
		end
	end
	hook.Add( "PlayerSay", "OpenInterface", chatCommand )
	
end

local LoadFile = EnvX.LoadFile --Lel Speed.
local P = "lde/userinterface/"
LoadFile(P.."xmenu/stats.lua",1)
LoadFile(P.."xmenu/account.lua",1)
LoadFile(P.."xmenu/rttab.lua",1)
LoadFile(P.."xmenu/help.lua",1)
LoadFile(P.."xmenu/unlocks.lua",1)

LoadFile(P.."factorymenu.lua",1)
LoadFile(P.."missingmodels.lua",1)
LoadFile(P.."motd.lua",1)
LoadFile(P.."trademarkmenu.lua",1)
LoadFile(P.."vendingmenu.lua",1)




