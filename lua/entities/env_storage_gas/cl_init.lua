include('shared.lua')

function ENT:Initialize()
	self.maxresources = {}
	self.maxresources["energy"] = 10000
end