include('shared.lua')

function ENT:Initialize()
	self.resources = {}
	self.resources["energy"] = 0
	self.resources["water"] = 0
	
	self.maxresources = {}
	self.maxresources["energy"] = 0
	self.maxresources["water"] = 0
end