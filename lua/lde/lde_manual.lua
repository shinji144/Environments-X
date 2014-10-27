LDE.Manual = {}
LDE.Manual.Documents = {}
LDE.Manual.Formatting = {}
LDE.Manual.Formatting.Decompose={}
LDE.Manual.Formatting.Compile={}

function LDE.Manual.CreateManual()
	
	LDE.Manual.Menu = LDE.UI.CreateFrame({x=ScrW()-100,y=ScrH()-100 },true,true,false,true)
		LDE.Manual.Menu:SetPos( 50,50 )
		LDE.Manual.Menu:SetTitle( "Environments Help Manual" )
		LDE.Manual.Menu:MakePopup()
		LDE.Manual.Menu.btnClose.DoClick = function( button ) 
			LDE.Manual.CloseManual()
		end

	//LDE.Manual.ReloadDocs()
	
	LDE.Manual.Menu.Sheet = LDE.UI.CreatePSheet(LDE.Manual.Menu,{x=ScrW()-110,y=ScrH()-133},{x=5,y=28}) 
		LDE.Manual.Menu.Sheet:SetFadeTime( 0 )
end

function LDE.Manual.CreatePages()
	print("Dirs: "..table.Count(LDE.Manual.Documents))
	for n,D in pairs( LDE.Manual.Documents) do
		print("Page: "..D.PageName)
		local T = vgui.Create( "DPanel" )
		LDE.Manual.Menu.Tabs[ D.PageName] = T

		LDE.Manual.Menu.Pages[D.PageName]=LDE.Manual.Menu.Sheet:AddSheet( D.PageName , T , D.Icon or "gui/silkicons/box" , false, false, D.Desc or D.PageName )
		
		T.Panel = vgui.Create( "DPanelList" , T )
			T.Panel:SetPos( 130 , 5 )
			T.Panel:SetSize(ScrW() - 255, ScrH() - 10)-- 545 , 426 
			T.Panel:EnableHorizontal( true )
			T.Panel:EnableVerticalScrollbar(true)
		
		T.Form = vgui.Create( "DPanelList" )
			T.Form:SetPos( 0, 0 )
			T.Form:SetSize(ScrW() - 255, ScrH() - 164)-- 545 , 426 
			T.Form:SetSpacing( 15 )
			T.Form:SetPadding( 5 )
		T.Form.Text = {}
		T.Panel:AddItem( T.Form )
		
		--T.Form:SetName( "Environments User Manual" )		
		T.Panel:PerformLayout()
		
		T.ListB = vgui.Create( "DPanelList" , T )
			T.ListB:SetPos( 5 , 5 )
			T.ListB:SetSize( 120 , 426 )
			T.ListB:SetSpacing( 5 )
			T.ListB:SetPadding( 5 )
		T.Btns = {}
		for i,F in pairs( D.Pages ) do
			print("Tab: "..F.TabName)
			local B = vgui.Create( "DButton" )
				T.Btns[ F.TabName ] = B
				B:SetText( F.TabName )
				B.DoClick = function( button )
					LDE.Manual.ClickPage( F , F.TabName , T.Form )
					T.Panel:PerformLayout()
					T.Form:PerformLayout()
				end
			T.ListB:AddItem( B )
		end
	end
end

function LDE.Manual.OpenManual()

	if LDE.Manual.Menu then return false end
	
	--Create The Manual.
	LDE.Manual.CreateManual()
	
	
	LDE.Manual.Menu.Tabs = {}
	LDE.Manual.Menu.Pages = {}
	
	if !LDE.Manual.Tags then LDE.Manual.Tags = {} end
	if !LDE.Manual.Icons then LDE.Manual.Icons = {} end
	
	LDE.Manual.CreatePages()
	LDE.Manual.RefreshTags()
	
	local SearchTab = vgui.Create( "DPanelList" )
		LDE.Manual.Menu.Search = SearchTab
		SearchTab:SetPadding( 5 )
		SearchTab:SetSpacing( 15 )
		SearchTab:EnableVerticalScrollbar(true)
	LDE.Manual.Menu.Sheet:AddSheet( "Search" , SearchTab , "gui/silkicons/magnifier" , false, false, "Search for relevant topics." )
		
	local Form = vgui.Create( "DForm" )
		LDE.Manual.Menu.Search.Form = Form
		Form:SetName( "Search" )
		Form:SetSize( 680 , 10 )
		Form:SetSpacing( 5 )
		Form:SetPadding( 5 )
	LDE.Manual.Menu.Search:AddItem( Form )
	
	local SearchEntry = vgui.Create( "DTextEntry" )
	LDE.Manual.Menu.Search.TEntry = SearchEntry
	SearchEntry:SetWide( 590 )
	SearchEntry.OnEnter = function()
		local R, ser = LDE.Manual.SearchWiki( SearchEntry:GetValue() )
		--PrintTable( R )
		for k,L in ipairs( LDE.Manual.Menu.Search.Items ) do
			if k > 1 then
				L:Remove()
			end
		end
		if R then
			for fil,T in pairs( R ) do
				local P = vgui.Create( "DPanel" )
				P:SetSize( 600, 85 )
				LDE.Manual.Menu.Search:AddItem( P )
												
				local LinkBtn = vgui.Create( "DButton" , P)
				LinkBtn:SetText( T.TabName )
				LinkBtn:SetPos( 20, 20 )
				LinkBtn:SetSize( 500, 40 )
				--LinkBtn:SizeToContentsX( true )
				LinkBtn.DoClick = function()
					local Page = LDE.Manual.PageFromTab(T.TabName)
					LDE.Manual.OpenPage( Page , T )
				end
			end
		else
			local P = vgui.Create( "DPanel" )
			P:SetSize( 600, 85 )
			LDE.Manual.Menu.Search:AddItem( P )
												
			local LinkBtn = vgui.Create( "DLabel" , P)
			LinkBtn:SetText( "No results found for '"..ser.."'." )
			LinkBtn:SetPos( 20, 20 )
			LinkBtn:SetSize( 500, 40 )
		end
	end
	
	local SearchBtn = vgui.Create( "DButton" )
	LDE.Manual.Menu.Search.Btn = SearchBtn
	SearchBtn:SetText( "Search" )
	SearchBtn.DoClick = function()
		SearchEntry:OnEnter()
	end
	Form:AddItem( SearchEntry , SearchBtn )
	
end
usermessage.Hook( "LDEOpenManual" , LDE.Manual.OpenManual )
concommand.Add( "lde_doc_openmanual" , LDE.Manual.OpenManual )

function LDE.Manual.MakeLabel(Text)
	local label = vgui.Create( "DLabel" )
	label:SetText( Text )
	label:SetMultiline( true )
	label:SetSize( 430 , 10 )
	label:SizeToContentsY( true )
	label:SetWrap(true)
	label:SetDark(true)
	label:SetAutoStretchVertical(true)
	return label
end

function LDE.Manual.LoadHtml(Text)
	print("Opening Url: "..Text)
	local label = vgui.Create("HTML")
	label:SetSize(200, 200)
	label:OpenURL(Text)
	return label
end

function LDE.Manual.CompilePage(File,Form,Data)
	if(Data)then
		for i,D in pairs( Data ) do
			local label = nil
			local func=LDE.Manual.Formatting.Compile[D.Type]
			
			if(func)then
				label=func(label,D)
				Form:AddItem( label,label.RText )
			else
				local Type = D.Type or "Error"
				print("Error Compiling page... "..Type.." is not a valid format.")
			end
		end
	else
		local label = LDE.Manual.MakeLabel(File.Text)
		Form:AddItem( label )
	end
end

function LDE.Manual.DecomposePage(File)
	print("------Decomposing Page------")
	local Data = {}

	local explode = string.Explode("@",File.Text)
	
	for t,s in pairs(explode) do
		local Table = {}
		for num,form in pairs(LDE.Manual.Formatting.Decompose) do
			form(s,Table)
		end
		if(Table.Type)then
			print("Sucessfully Added.")
			table.insert( Data , Table )
		end
	end
	
	print("-----------Done-----------")
	return Data
end

function LDE.Manual.ClickPage( File , name , Form )
	Form:Clear()
	Form:SetName( name )
	Form.Text = {}
	local Results = LDE.Manual.DecomposePage(File)
	if table.Count( Results ) == 0 then 
		LDE.Manual.CompilePage(File,Form)
	else
		LDE.Manual.CompilePage(File,Form,Results)
	end
end

function LDE.Manual.PageFromTab(Tab)
	print("Getting Page for "..Tab.."...")
	for n,D in pairs( LDE.Manual.Documents) do
		for i,F in pairs( D.Pages ) do
			if(F.TabName==Tab)then
				return D
			end
		end
	end
	print("Error Page Not Found.")
	return nil
end

function LDE.Manual.PageFromName(PName)
	print("Getting SubPage for "..PName.."...")
	for n,D in pairs( LDE.Manual.Documents) do
		for i,F in pairs( D.Pages ) do
			if(F.TabName==PName)then
				return F
			end
		end
	end
	print("Error SubPage Not Found.")
	return nil
end

function LDE.Manual.RefreshTags()
	print("Refreshing Tags.")
	LDE.Manual.Tags = {}
	for n,D in pairs( LDE.Manual.Documents) do
		LDE.Manual.Tags[D.PageName]={PageName=D.PageName,Tabs={}}
		for i,F in pairs( D.Pages ) do
			print("Page: "..D.PageName.." Tab: "..F.TabName.." Tags: "..F.Tags)
			LDE.Manual.Tags[D.PageName].Tabs[F.TabName]={TabName=F.TabName,Tags=F.Tags}
		end
	end
end

function LDE.Manual.CloseManual()
	if LDE.Manual.Menu then
		LDE.Manual.Menu:Close()
		LDE.Manual.Menu = nil
	end
end
usermessage.Hook( "LDECloseManual" , LDE.Manual.CloseManual )
concommand.Add( "lde_doc_closemanual" , LDE.Manual.CloseManual )

function LDE.Manual.ToggleManual( um )
	if LDE.Manual.Menu then
		LDE.Manual.CloseManual()
	else
		LDE.Manual.OpenManual()
	end
end
usermessage.Hook( "LDEToggleManual" , LDE.Manual.ToggleManual )
concommand.Add( "lde_doc_togglemanual" , LDE.Manual.ToggleManual )

function LDE.Manual.OpenPage( Dtab , page )

	if Dtab == "Search" then
		if !LDE.Manual.Menu then LDE.Manual.OpenManual() end
		LDE.Manual.Menu.Sheet:SetActiveTab( LDE.Manual.Menu.Pages[Dtab.PageName].Tab )
	end

	if !LDE.Manual.Menu then LDE.Manual.OpenManual() end
	
	LDE.Manual.Menu.Sheet:SetActiveTab( LDE.Manual.Menu.Pages[Dtab.PageName].Tab )
	LDE.Manual.Menu.Tabs[ Dtab.PageName ].Btns[ page.TabName ]:DoClick()	

end

local function UMOpenPage( um )
	Dtab = um:ReadString()
	page = um:ReadString()
	LDE.Manual.OpenPage( Dtab , page )
end
usermessage.Hook( "LDEOpenPage" , UMOpenPage )
concommand.Add( "LDEManual_OpenPage" , UMOpenPage )

function LDE.Manual.SearchWiki( search )

	if !LDE.Manual.Menu then return {} end

	local SerTab = {}
	for i in string.gmatch( search , "%S+") do
		table.insert( SerTab , string.lower( i ) )
	end

	local Results = {}
	print("Search Query: "..search)
	for D,fl in pairs( LDE.Manual.Tags ) do
		print("Searching Page: "..fl.PageName)
		for S,sl in pairs( fl.Tabs ) do
			print("Searching SubPage: "..sl.TabName)
			if(string.find(sl.Tags,search))then
				local Tab = LDE.Manual.PageFromName(sl.TabName)
				if(Tab)then
					table.insert( Results , Tab )
				end
			end
		end
	end
	
	--PrintTable( Results )
	if table.Count( Results ) == 0 then 
		print( "No results." )
		return nil, search
	end
	
	return Results, search
end

function LDE.Manual.OpenSearch( search )

	LDE.Manual.OpenPage( "Search" )
	LDE.Manual.Menu.Search.TEntry:SetValue( search )
	LDE.Manual.Menu.Search.TEntry:OnEnter()

end

local function UMOpenSearch( um )
	LDE.Manual.OpenSearch( um:ReadString() )
end
usermessage.Hook( "LDEOpenSearch" , UMOpenSearch )

function LDE.Manual.LoadDocs()
	
	LDE.Manual.Documents = {}
	local Files
	if file.FindInLua then
		Files = file.FindInLua( "lde/manual/*.lua" )
	else//gm13
		Files = file.Find("lde/manual/*.lua", "LUA")
	end

	for k, File in ipairs(Files) do
		Msg("*LDE Manual Loading: "..File.."...\n")
		local ErrorCheck, PCallError = pcall(include, "lde/manual/"..File)
		ErrorCheck, PCallError = pcall(AddCSLuaFile, "lde/manual/"..File)
		if !ErrorCheck then
			Msg(PCallError.."\n")
		end
	end
	Msg("LDE Manual Loaded: Successfully\n")
end

LDE.Manual.LoadDocs()

