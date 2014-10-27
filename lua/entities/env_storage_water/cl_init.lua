include('shared.lua')

function ENT:Initialize()
	self.maxresources = {}
	self.maxresources["water"] = 10000
end