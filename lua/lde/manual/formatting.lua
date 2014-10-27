
---Page Decomposing---
local Table = {}

Table.Bold=function(String,Table)
	for i in string.gmatch( String , "%<B%>(.*)%</B%>") do
		print("Bold Text Located.")
		--table.insert( Table ,  {Type="Bold",Text=i}  )
		Table.Type="Bold"
		Table.Text=i
	end
end

Table.Paragraph=function(String,Table)	
	local DFont = "Default"	
	for i in string.gmatch( String , "%<P%>(.*)%</P%>") do
		print("Paragraph Located.")
		for d in string.gmatch( i , "%<F%>(.*)%</F%>") do
			DFont=d
			i=string.sub(i, string.len(d)+8)
		end
		--table.insert( Table ,  {Type="Paragraph",Text=i,Font=DFont or ""}  )
		Table.Type="Paragraph"
		Table.Text=i
		Table.Font=DFont
	end
end	

Table.Font=function(String,Table)	
	for i in string.gmatch( String , "%<Font%>(.*)%</Font%>") do
		print("Font Set Located.")
		Table.Font=i
	end
end	

Table.HTML=function(String,Table)	
	for i in string.gmatch( String , "%<HTML%>(.*)%</HTML%>") do
		print("Html Request Located.")
		--table.insert( Table ,  {Type="HTML",Text=i}  )
		Table.Type="HTML"
		Table.Link=i
	end
end

Table.WebPage=function(String,Table)	
	for i in string.gmatch( String , "%<WEB%>(.*)%</WEB%>") do
		print("WebPage Request Located.")
		--table.insert( Table ,  {Type="HTML",Text=i}  )
		Table.Type="Web"
		Table.Link=i
	end
end

Table.ModelView=function(String,Table)
	local Dist = 50
	for i in string.gmatch( String , "%<MDL%>(.*)%</MDL%>") do
		print("Model Display Request Located.")
		for d in string.gmatch( i , "%<D%>(.*)%</D%>") do
			Dist=tonumber(d)
			i=string.sub(i, string.len(d)+8)
		end
		--table.insert( Table ,  {Type="MDL",Text=i,Dist=Dist}  )
		Table.Type="MDL"
		Table.Model=i
		Table.Dist=Dist
	end
end

Table.Distance=function(String,Table)
	for i in string.gmatch( String , "%<Dist%>(.*)%</Dist%>") do
		print("Distance Set Located.")
		--table.insert( Table ,  {Type="HTML",Text=i}  )
		Table.Dist=i
	end
end

Table.RightSide=function(String,Table)
	for i in string.gmatch( String , "%<Right%>(.*)%</Right%>") do
		print("RightSide Text Located.")
		--table.insert( Table ,  {Type="HTML",Text=i}  )
		Table.RText=i
	end
end

LDE.Manual.Formatting.Decompose = Table
		
	
---Page Compiling---
local Table = {}

Table.Bold=function(label,D)
	label = LDE.Manual.MakeLabel(D.Text)
	label:SetFont( "BigBoldFont" )
	return label
end

Table.Paragraph=function(label,D)
	label = LDE.Manual.MakeLabel(D.Text)
	if(D.Font and D.Font~="")then
		label:SetFont( D.Font )
	end
	return label
end

Table.Web=function(label,D)
	local Size = {x=ScrW() - 255, y=ScrH() - 164}
	label = LDE.UI.LoadWebpage(nil,Size,D.Link)
	return label
end

function RightSideText(label,D)
	label.RText=nil
	if(D.RText)then
		label.RText = LDE.Manual.MakeLabel(D.RText)
		if(D.Font and D.Font~="")then
			label.RText:SetFont( D.Font )
		end
		return label.RText
	end
end

Table.HTML=function(label,D)
	label = LDE.Manual.LoadHtml(D.Link)
	RightSideText(label,D)
	return label
end

Table.MDL=function(label,D)
	label = vgui.Create( "DPanel" )
	label:SetPos( 10, 10 )
    label:SetSize( 200, 200 )
	label.Icon = LDE.UI.DisplayModel(label,200,{0,0},D.Model,D.Dist)
	RightSideText(label,D)
	return label
end

LDE.Manual.Formatting.Compile = Table
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		