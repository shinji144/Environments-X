include('shared.lua')

function ENT:Initialize()
	self.resources = {}
	self.resources["oxygen"] = 0
	self.resources["water"] = 0
	
	self.maxresources = {}
	self.maxresources["water"] = 0
	self.maxresources["oxygen"] = 0
end