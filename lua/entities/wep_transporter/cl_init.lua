include('shared.lua')

 function ENT:DoNormalDraw( bDontDrawModel )
	if !bDontDrawModel then
	self:DrawModel()
	end
end