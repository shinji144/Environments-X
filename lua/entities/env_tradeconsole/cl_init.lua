include('shared.lua')

 
function ENT:Draw( )

	entFactoryEnt = self
	
	if entID == nil then
		entID = 0
	end
		
	self:DrawModel();

end

function envMarketTrigger(um)

	local Window = vgui.Create( "MarketMenu")
	Window:SetMouseInputEnabled( true )
	Window:SetVisible( true )
	
	entID = um:ReadString()
	e = um:ReadEntity()	
	
	--if(not ValidEntity(e)) then return end;
	print("Gui open recieved.")
end
usermessage.Hook("envmarketTrigger", envMarketTrigger)

