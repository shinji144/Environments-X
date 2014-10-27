include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.resources = {}
	self.resources["energy"] = 0
	
	self.maxresources = {}
	self.maxresources["energy"] =0
end

