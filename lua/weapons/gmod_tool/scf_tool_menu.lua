
local SCF = LDE

function PANEL:Init()
	print("VGUI Init!")
	local VGE = SCF.MenuCore
	
	scfomnitool = self.Panel	
	self:SetTall( surface.ScreenHeight() - 120 )
	
	local C = vgui.Create( "DPanel" )
	self.PSheet = VGE.CreatePSheet(self,{x=200,y=300},{x=0,y=0})
	self.PSheet:AddSheet( "Life Support" , C , "icon16/shield.png" , false, false, "Life Support" )
	
	self:CreateLsTab(C)
end

function PANEL:Think()

end

function PANEL:PerformLayout()
	--Starting positions
	local vspacing = 10
	local ypos = 0
	
	--Selection Tree panel
	self.PSheet:SetPos( 0, ypos )
	self.PSheet:SetSize( scfomnitool:GetWide(), 300 )
	ypos = self.PSheet.Y + self.PSheet:GetTall() + vspacing
end

function PANEL:CreateLsTab(Panel)
	local list = vgui.Create( "DPanelList",Panel )
	list:SetSize( self.PSheet:GetWide(), self.PSheet:GetTall() )
	list:SetPadding( 1 )
	list:SetSpacing( 1 )
	list:EnableVerticalScrollbar(true)
	
	self.LsList = list
	
	for cat,tab in pairs(Environments.Tooldata["Life Support"]) do
		local c = vgui.Create("DCollapsibleCategory")
		c:SetLabel(cat)
		c:SetExpanded(false)
		
		local CategoryList = vgui.Create( "DPanelList" )
		CategoryList:SetAutoSize( true )
		CategoryList:SetSpacing( 6 )
		CategoryList:SetPadding( 3 )
		CategoryList:EnableHorizontal( true )
		CategoryList:EnableVerticalScrollbar( true )
		
		for k,v in pairs(tab) do
			local icon = vgui.Create("SpawnIcon")
			
			util.PrecacheModel(v.model)
			icon:SetModel(v.model, v.skin or 0)
			icon.tool = self
			icon.model = v.model
			icon.class = v.class
			icon.skin = v.skin
			icon.devname = k
			icon.devtype = cat
			icon.description = v.description
			if v.tooltip then
				icon:SetTooltip(v.tooltip)
			else
				icon:SetTooltip(k)
			end
			icon.DoClick = function(self)
				self.tool.Model = self.model
				self.tool.description_label:SetText(icon.description or icon.devname)
			end
			
			CategoryList:AddItem(icon)
		end
		
		c:SetContents(CategoryList)
		list:AddItem(c)
	end
end