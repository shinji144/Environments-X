ENT.Type 			= "anim"
ENT.Base 			= "resource_node_env"
ENT.PrintName		= "Base Core"
ENT.Author			= "Ludsoe"
ENT.Category		= "Other"

ENT.Spawnable		= false
ENT.AdminSpawnable	= true
ENT.Owner			= nil
ENT.SPL				= nil 

list.Set( "LSEntOverlayText" , "lde_basecore", {HasOOO = true, resnames = {"Power","Refined Mass","Scrap"}, genresnames = {}} )

if(SERVER)then
	
	local T = {} --Create a empty Table
	
	T.Upgrade = function(Device,ply,Data)
		Device:UpgradeCore()
	end

	ENT.Panel=T --Set our panel functions to the table.
	
else 

	function ENT:PanelFunc(um,e,entID)

		e.Functions={}
		
		e.DevicePanel = [[
		@<Button>Upgrade Core</Button><N>UpgradeButton</N><Func>Upgrade</Func>
		@<Custom>Display</Custom><N>CostDisplay</N><Func>GetCost</Func><SetText>Loading</SetText>
		]]

		e.Functions.Upgrade = function()
			RunConsoleCommand( "envsendpcommand",entID,"Upgrade")
		end

		e.Functions.GetCost = function()
			local Level = self:GetNWInt("LDETechLevel") or 1
			
			return "Current Level: "..Level.." NextCost: "..100+((Level/2)*100).." \nShields "..20000+(10000*(Level-1)).." => "..20000+(10000*(Level))
		end		
	end

end
