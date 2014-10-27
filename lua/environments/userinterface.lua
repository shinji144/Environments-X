
local Environments = Environments --yay speed boost!

Environments.UI = {}
Environments.UI.Panel ={}

if(CLIENT)then

	local VGUI = {}
		function VGUI:Init()
		
			self.GBase = Environments.UI.CreateFrame({x=300,y=200},true,true,true,true)
			self.GBase:Center()
			self.GBase:SetTitle( "Device Interface" )
			self.GBase:MakePopup()
			
			self.GForm = vgui.Create( "DPanelList", self.GBase )
			self.GForm:SetPos(0,20)
			self.GForm:SetSize(300, 200)-- 545 , 426 
			self.GForm:SetSpacing( 15 )
			self.GForm:SetPadding( 5 )
		end
		
		function VGUI:CompilePanel() --Where the magic happens.
			print("------Compiling Panel------")
			local Data = {}
			
			if(not e.DevicePanel)then print("Error No Panel Data.") return end
			if(e.NoEnvPanel)then print("Whoa... This ent doesnt want a panel :/") self.GBase:Remove() return end
			local explode = string.Explode("@",e.DevicePanel)--Grab our Data out of the string.
			
			for t,s in pairs(explode) do
				--Loop all the data.
				local Table = {}
				for num,form in pairs(Environments.UI.Panel.Compile) do
					form(s,Table) ----Adds instructions to the table.
				end
				if(Table.Type)then
					table.insert( Data ,  Table )
				end
			end
			
			print("-----------Done-----------")
			
			Environments.UI.PopulatePanel(self.GForm,Data,e)
			
			self.GBase.Device = entID
			self.GBase:SizeToContents()--Resize our Base to hold the new stuff :p
		end
		
	vgui.Register( "EnvDeviceGUI", VGUI ) --Register our custom VGui so devices can use it.
	
	--Populate the Panel itself with buttons and stuff.
	function Environments.UI.PopulatePanel(self,Data,Device)
		for i,D in pairs( Data ) do
			local label = nil
			
			local func=Environments.UI.Panel.Populate[D.Type]
			
			if(func)then
				if(D.name)then
					label = self[D.name]
				end
				label=func(label,D,self,Device)
				self:AddItem( label )
			else
				local Type = D.Type or "Error"
				print("Error Compiling page... "..Type.." is not a valid format.")
			end
		end
	end
		
	function Environments.UI.CreateFrame(Size,Visible,XButton,Draggable,CloseDelete)
		local Derma = vgui.Create( "DFrame" )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetVisible( Visible )
			Derma:ShowCloseButton( XButton )
			Derma:SetDraggable( Draggable )
			Derma:SetDeleteOnClose( CloseDelete )
			Derma.OldClose = Derma.Close
			Derma.Close = function(self)
				if(self.Device)then
					RunConsoleCommand( "envclosepanel",entID)
				end
				Derma:OldClose()
			end
		return Derma
	end

	function Environments.UI.CreateSlider(Parent,Spot,Values,Width)
		local Derma = vgui.Create( "DNumSlider", Parent )
			Derma:SetMinMax( Values.Min, Values.Max )
			Derma:SetDecimals( Values.Dec )
			Derma:SetWide( Width )
			Derma:SetPos( Spot.x, Spot.y )
		return Derma
	end
	
	function Environments.UI.CreatePSheet(Parent,Size,Spot)
		local Derma = vgui.Create( "DPropertySheet", Parent )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetPos( Spot.x, Spot.y )
		return Derma
	end
	
	function Environments.UI.DisplayModel(Parent,Size,Spot,Model,View,Look)
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
	
	function Environments.UI.CreatePBar(Parent,Size,Spot,Progress)
		local Derma = vgui.Create( "DProgress", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetFraction( Progress )
		return Derma
	end
	
	function Environments.UI.CreateList(Parent,Size,Spot,Multi)
		local Derma = vgui.Create( "DListView", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )
			Derma:SetMultiSelect(Multi)
		return Derma
	end	
	
	function Environments.UI.CreateButton(Parent,Size,Spot)
		local Derma = vgui.Create( "DButton", Parent )
			Derma:SetPos( Spot.x, Spot.y )
			Derma:SetSize( Size.x, Size.y )
		return Derma
	end	
	
	function Environments.UI.CreateLabel(Text,Parent)
		local label = vgui.Create( "DLabel", Parent )
		label:SetText( Text )
		label:SetMultiline( true )
		--label:SetSize( 430 , 10 )
		label:SizeToContents()
		label:SetWrap(true)
		label:SetDark(true)
		label:SetAutoStretchVertical(true)
		return label
	end
	
	function Environments.UI.CreateCheckbox(Text, Parent)
		local CheckBoxThing = vgui.Create( "DCheckBoxLabel", Parent )
		//CheckBoxThing:SetPos( 10,50 )
		CheckBoxThing:SetText( Text )
		//CheckBoxThing:SetConVar( "sbox_godmode" ) -- ConCommand must be a 1 or 0 value
		CheckBoxThing:SetValue( 0 )
		CheckBoxThing:SizeToContents() -- Make its size to the contents. Duh?
		return CheckBoxThing
	end

	---------Page Compilation Functions----------
	local Table = {}

	Table.Custom=function(String,Table)
		for i in string.gmatch( String , "%<Custom%>(.*)%</Custom%>") do
			print("Custom Located.")
			Table.Type=i
		end
	end
	
	Table.SetText=function(String,Table)
		for i in string.gmatch( String , "%<SetText%>(.*)%</SetText%>") do
			print("Text Located.")
			Table.Text=i
		end
	end
	
	Table.Label=function(String,Table)
		for i in string.gmatch( String , "%<L%>(.*)%</L%>") do
			print("Label Located.")
			Table.Type="Label"
			Table.Text=i
		end
	end
	
	Table.Namer=function(String,Table)
		for i in string.gmatch( String , "%<N%>(.*)%</N%>") do
			print("Name Located.")
			Table.name=i
		end
	end
	
	Table.Function=function(String,Table)
		for i in string.gmatch( String , "%<Func%>(.*)%</Func%>") do
			print("Function Located.")
			Table.Func=i
		end
	end
	
	Table.Variable=function(String,Table)
		for i in string.gmatch( String , "%<Var%>(.*)%</Var%>") do
			print("Variable Located.")
			Table.Variable=i
		end
	end
	
	Table.SetupF=function(String,Table)
		for i in string.gmatch( String , "%<Set%>(.*)%</Set%>") do
			print("Setup Function Located.")
			Table.SetupF=i
		end
	end
	
	Table.Buttoner=function(String,Table)
		for i in string.gmatch( String , "%<Button%>(.*)%</Button%>") do
			print("Button Located.")
			Table.Type="Button"
			Table.Text=i
		end
	end
	
	Table.Slider=function(String,Table)
		for i in string.gmatch( String , "%<Slider%>(.*)%</Slider%>") do
			print("Slider Located.")
			Table.Type="Slider"
			Table.Text=i
		end
	end	
	
	Table.Checkbox = function(String, Table)
		for i in string.gmatch(String, "%<Checkbox%>(.*)%</Checkbox%>") do
			print("Checkbox Located.")
			Table.Type = "Checkbox"
			Table.Text = i
		end
	end
	
	Environments.UI.Panel.Compile = Table

	---------Page Population Functions----------
	local Table = {}

	Table.Label=function(label,D,Parent)
		label = Environments.UI.CreateLabel(D.Text,Parent)
		return label
	end
	
	Table.Display=function(label,D,Parent,Device)
		label = Environments.UI.CreateLabel(D.Text,Parent)
		label.Think = function(self)
			self:SetText(Device.Functions[D.Func]())
		end
		return label
	end
	
	Table.Button=function(label,D,Parent,Device)
		label = Environments.UI.CreateButton(Parent,{x=90,y=30},{x=0,y=0})
		label:SetText(D.Text)					
		label.DoClick = function()
			Device.Functions[D.Func]()
		end
		return label
	end
	
	Table.Slider=function(label,D,Parent,Device)
		label = Environments.UI.CreateSlider(Parent,{x=0,y=0},{Min=0,Max=100,Dec=0},300)
		label:SetText(D.Text)
		label.OnValueChanged = function(self,Value)
			Device.Functions[D.Func](Value)
		end
		if(D.SetupF)then Device.Functions[D.SetupF](label,D,Device) end
		return label
	end
	
	Table.Checkbox = function(label,D,Parent,Device)
		label = Environments.UI.CreateCheckbox(D.Text, Parent)
		label.OnChange = function(self, value)
			if value then
				Device.Functions[D.Func](1)
			else
				Device.Functions[D.Func](0)
			end
		end
		return label
	end
	
	Environments.UI.Panel.Populate = Table

	--------------------------------
else
----Server side-----

	function EnvPanCommand(ply,cmd,args)
		---Put Clientside panel disable check here---
		
		local Device = Entity( tonumber(args[1]) ) --Get the device out of the command
		if(not Device or not Device:IsValid())then return end --Is the device valid?
		---Put can run check here---
		
		local Command = args[2] -- Grab the command were gonna send the device.
		local Data = args[3] --Grab the variable for the command if possible
		
		if(Device.Panel[Command])then --Does the device have the needed function?
			Device.Panel[Command](Device,ply,Data)--Send the command through to the device.
		else
			print("Error: "..Command.." is Invalid on Device "..args[1]) --Somethings wrong here.
		end
	end
	concommand.Add("envsendpcommand", EnvPanCommand)

	function EnvClosePan(ply,cmd,args)
		local Device = Entity( tonumber(args[1]) ) --Get the device out of the command
		if(not Device or not Device:IsValid())then return end --Is the device valid?
		---Put can run check here---
		if(ply == Device.PanelUser)then --Make sure the command sender is the person using the panel.
			Device.PanelUser = nil --Clear the Panel user since they closed their panel.
		end
	end
	concommand.Add("envclosepanel", EnvClosePan)

end