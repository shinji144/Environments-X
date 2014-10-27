
if(SERVER)then
	function builditem(ply, cmd, args)
		local BuildList = LDE.Factorys.BuildList
		--Get self info
		for _, ent in pairs(ents.FindByClass("env_factory")) do
			if ent:GetCreationID() == tonumber(args[2]) then
				for k,v in pairs(BuildList) do
					if(args[1]==v.name)then
						LDE.LifeSupport.BeginReplication(ent,v.Class, v, ply)
						break
					end
				end
				break
			end
		end
	end

	concommand.Add("builditem", builditem)
	   
else
	local VGUI = {}
	function VGUI:Init()
		
		local BuildList = LDE.Factorys.BuildList
		
		local FactoryMenu = LDE.UI.CreateFrame({x=700,y=400},true,true,false,true)
		FactoryMenu:Center()
		FactoryMenu:SetTitle( "Item Materialiser" )
		FactoryMenu:MakePopup()
		
		local schematicBox = LDE.UI.CreateList(FactoryMenu,{x=150,y=350},{x=10,y=35},false)
		schematicBox:SetParent(FactoryMenu)
		schematicBox:AddColumn("Schematics") -- Add column
		
		--Schematic Items--
		//schematicBox:AddLine("Basic Bomb")
		for k,v in pairs(BuildList) do
			schematicBox:AddLine(v.name)
		end
		------------------
		local ModelDisplay = LDE.UI.DisplayModel(FactoryMenu,180,{x=520,y=0},"models/Slyfo/swordreconlauncher.mdl",80)
		
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
		okButton:SetText( "Fabricate" )
		okButton.DoClick = function ()
			if schematicBox:GetSelected() and schematicBox:GetSelected()[1] then
				RunConsoleCommand( "builditem", schematicBox:GetSelected()[1]:GetValue(1), entID  )
				FactoryMenu:Remove()
			end
		end
		
	end
	 
	vgui.Register( "FactoryMenu", VGUI )
	
	function envFactoryTrigger(um)
		local Window = vgui.Create( "FactoryMenu")
		Window:SetMouseInputEnabled( true )
		Window:SetVisible( true )
		
		entID = um:ReadString()
		e = um:ReadEntity()	
	end
	usermessage.Hook("envFactoryTrigger", envFactoryTrigger)

end		

LDE.Factorys = {} --Factorys Global Table

LDE.Factorys.BuildList = {} --Factory Buildlist global table

LDE.Factorys.BuildList.BBomb = {
name="Basic Bomb", --Name That shows up
Class="basic_bomb", --Entity class thats made
model="models/Slyfo/missile_smallmissile.mdl",
CamDist=50,Look=10,
materials={"energy","Refined Ore"}, --Needed Resource names
matamount={200,80},
Time=3,
desc={
"The N-X23 Basic Chemical Bomb is often used for its cheap",
"and destructive nature."
},
}

LDE.Factorys.BuildList.LBomb = {
name="Large Bomb", --Name That shows up
Class="large_bomb", --Entity class thats made
model="models/Slyfo/torpedo2.mdl",
CamDist=80,Look=10,
materials={"energy","Refined Ore"}, --Needed Resource names
matamount={1000,250},
Time=6,
desc={
"The N-B36 Plasma Bomb is loved for its high power yet",
"its affordable price."
},
}

LDE.Factorys.BuildList.PBomb = {
name="Photon Torpedo", --Name That shows up
Class="photon_bomb", --Entity class thats made
model="models/Slyfo/torpedo.mdl",
CamDist=90,Look=10,
materials={"energy","Refined Ore","Liquid Polylodarium"}, --Needed Resource names
matamount={800,180,30},
Time=10,
desc={
"The E-M35 Photon Torpedo is a new design made to exploit",
"the rare qualitys of Polylodarium when infused with light."
},
}

LDE.Factorys.BuildList.ShockBomb = {
name="ShockWave Bomb", --Name That shows up
Class="shock_bomb", --Entity class thats made
model="models/SBEP_community/d12siesmiccharge.mdl",
CamDist=80,Look=10,
materials={"energy","Refined Ore","Liquid Polylodarium"}, --Needed Resource names
matamount={1200,400,60},
Time=12,
desc={
"The S-K64 ShockWave bomb causes a gravity shockwave,",
"that while weak causes damage over a large amount of area."
},
}

LDE.Factorys.BuildList.NukeBomb = {
name="Nuclear Bomb", --Name That shows up
Class="nuke_bomb", --Entity class thats made
model="models/Slyfo/goldfish.mdl",
CamDist=80,Look=10,
materials={"energy","Refined Ore","Liquid Polylodarium"}, --Needed Resource names
matamount={5000,2000,600},
Time=30,
desc={
"The Zues Nuclear Bomb is based off old Human weaponry,",
"its immense damage output and large blast radius make it",
"a deadly bomb."
},
}

LDE.Factorys.BuildList.SNugs = {
name="Strider Nuggets", --Name That shows up
Class="food_snuggets", --Entity class thats made
model="models/Slyfo_2/acc_food_snckstridernugs.mdl",
CamDist=10,Look=7,
materials={"energy"}, --Needed Resource names
matamount={1200},
Time=1,
desc={
"Gives 5-Seconds Health Regen."
},
}

LDE.Factorys.BuildList.oneuf = {
name="One Unit Food", --Name That shows up
Class="food_1uf", --Entity class thats made
model="models/Slyfo_2/acc_food_snckfoodbag.mdl",
CamDist=10,Look=7,
materials={"energy"}, --Needed Resource names
matamount={1200},
Time=1,
desc={
"Heals 50 Health."
},
}

LDE.Factorys.BuildList.SMix = {
name="Space Mix", --Name That shows up
Class="food_smix", --Entity class thats made
model="models/Slyfo_2/acc_food_snckspacemix.mdl",
CamDist=10,Look=7,
materials={"energy"}, --Needed Resource names
matamount={1200},
Time=1,
desc={
"Heals 100 Health."
},
}

LDE.Factorys.BuildList.sbeptos = {
name="Sbeptos", --Name That shows up
Class="food_sbeptos", --Entity class thats made
model="models/Slyfo_2/acc_food_sbeptos.mdl",
CamDist=10,Look=7,
materials={"energy"}, --Needed Resource names
matamount={1200},
Time=1,
desc={
"Heals 20 Health."
},
}

LDE.Factorys.BuildList.CON = {
name="Cup-O-Noodle", --Name That shows up
Class="food_cuponood", --Entity class thats made
model="models/Slyfo/cup_noodle.mdl",
CamDist=10,Look=7,
materials={"energy"}, --Needed Resource names
matamount={1200},
Time=1,
desc={
"Heals 200 Health."
},
}

LDE.Factorys.BuildList.SporeCure = {
name="S-Vaccine", --Name That shows up
Class="food_sporecure", --Entity class thats made
model="models/Slyfo_2/acc_ndl3.mdl",
CamDist=10,Look=7,
materials={"energy"}, --Needed Resource names
matamount={1200},
Time=1,
desc={
"Cures Sporefections."
},
}
--[[
LDE.Factorys.BuildList.BHole = {
name="BlackHole Bomb", --Name That shows up
Class="sent_spaceanon_hypermass", --Entity class thats made
model="models/SBEP_community/d12fusionbomb.mdl",
CamDist=80,Look=20,
materials={"energy","Blackholium"}, --Needed Resource names
matamount={5000,100},
Time=15,
desc={
"After a mad scientist develped the S^N Fusion Beam",
"he started work on his greatest and final project,",
"the Tau BlackHole Bomb. During testing the scientist",
"vanished without a trace."
},
}

LDE.Factorys.BuildList.Test = {
name="Test Bomb", --Name That shows up
Class="basic_bomb", --Entity class thats made
model="models/Slyfo/missile_smallmissile.mdl",
CamDist=50,Look=10,
materials={"energy","Refined Ore"}, --Needed Resource names
matamount={0,0},
Time=0,
desc={
"TEST",
""
},
}
]]	
		
		
		