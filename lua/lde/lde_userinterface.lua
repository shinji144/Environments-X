LDE.UI = {}
LDE.UI.SuperMenu = {}

if(CLIENT)then

	function LDE.UI.SuperMenu.MenuOpen()
		local Super = {}
		Super.Base = LDE.UI.CreateFrame({x=ScrW()-100,y=ScrH()-100},true,true,false,true)
		Super.Base:Center()
		Super.Base:SetTitle( "Environments Extended Menu System" )
		Super.Base:MakePopup()
		
		Super.Catagorys = LDE.UI.CreatePSheet(Super.Base,{x=ScrW()-110,y=ScrH()-133 },{x=5,y=30})
		
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
	
	function LDE.UI.CreatePBar(Parent,Size,Spot,Progress)
		local Derma = vgui.Create( "DProgress", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetFraction( Progress )
		return Derma
	end
	
	function LDE.UI.CreateList(Parent,Size,Spot,Multi)
		local Derma = vgui.Create( "DListView", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetMultiSelect(Multi)
		return Derma
	end	
	
	function LDE.UI.CreateButton(Parent,Size,Spot)
		local Derma = vgui.Create( "DButton", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )
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
	function LDE.UI.OpenPanel( ply )
		ply:ConCommand( "ldesupermenuopen" )
	end
	hook.Add( "ShowSpare1", "bindtoSpare1", LDE.UI.OpenPanel )


end

function LDE.UI.Interfaces()
	local Files
	if file.FindInLua then
		Files = file.FindInLua( "lde/userinterface/*.lua" )
	else//gm13
		Files = file.Find("lde/userinterface/*.lua", "LUA")
	end

	for k, File in ipairs(Files) do
		Msg("*LDE User Interface Loading: "..File.."...\n")
		local ErrorCheck, PCallError = pcall(include, "lde/userinterface/"..File)
		ErrorCheck, PCallError = pcall(AddCSLuaFile, "lde/userinterface/"..File)
		if !ErrorCheck then
			Msg(PCallError.."\n")
		end
	end
	Msg("LDE User Interface Loaded: Successfully\n")
end

LDE.UI.Interfaces()