AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()	
	local rockmodels = {
	"models/props_canal/rock_riverbed01d.mdl","models/props_wasteland/rockgranite04b.mdl","models/props_wasteland/rockcliff01g.mdl","models/props_wasteland/rockgranite01c.mdl",
	"models/props_wasteland/rockcliff01c.mdl","models/props_wasteland/rockcliff01j.mdl","models/props_wasteland/rockgranite04c.mdl","models/props_wasteland/rockcliff01e.mdl",
	"models/mandrac/asteroid/crystal1.mdl","models/mandrac/asteroid/crystal3.mdl","models/mandrac/asteroid/crystal4.mdl","models/props_wasteland/rockgranite01a.mdl",
	"models/props_wasteland/rockcliff01b.mdl","models/props_wasteland/rockcliff01f.mdl","models/props_wasteland/rockgranite01b.mdl","models/props_wasteland/rockgranite04a.mdl",
	"models/props_wasteland/rockcliff01g.mdl","models/mandrac/asteroid/rock2.mdl","models/mandrac/asteroid/rock4.mdl"} 
	for _,v in pairs( rockmodels ) do util.PrecacheModel(v) end
	self:SetModel(rockmodels[math.random(1,table.Count(rockmodels))])
	
	local Skin = math.floor(math.random(0,self:SkinCount()))--Pick a random skin.
	self:SetSkin(Skin)
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	--self:SetOwner(GetWorldEntity())
	self.resource_type = self.resource_type or ""
	self.resource_amount = self_resource_amount or 0
	self.rarity = self.rarity or 1
	self.density = self.density or 1
	self.base_volume = self.base_volume or 1
	self.radius = self.radius or self:BoundingRadius()
	
	local entmeta = FindMetaTable("Entity")
	if entmeta.CPPISetOwnerless then self:CPPISetOwnerless(true) end
end

function ENT:SetClusterID(id)
	if not id or type(id) ~= "number" then return end
	self.clusterid = id
end

function ENT:SetVolume()
	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then
		self.base_volume = phys:GetVolume() * 1e-5
	else -- no physbox use bounding radius then :(
		self.base_volume = ( (4/3) * math.pi * self:BoundingRadius()^3 ) * 1e-5
	end
end

--  Sets what type of resource we contain and how much
function ENT:SetResource(name)
	if not name or type(name) ~= "string" then return end
	
	local EMR = LDE.Anons.Resources
	for k,v in pairs(EMR) do
		if k == name then
			self.resource_type = k
			self.rarity = v.rarity
			self.density = v.base_density
		end
	end
	
end

function ENT:CalcResource()
	if self.base_volume and self.resource_type ~= "" then
		self.resource_amount = math.Round( self.base_volume / ( self.density + self.rarity ), 0 ) + math.random(1,1e4)
		return self.resource_amount
	end
end

-- Drain resources when getting mind
function ENT:Drain(amount)
	if not amount or type(amount) ~= "number" then return end
	if amount <0 then amount = 0 end
	
	local supplyamount = amount
	
	if self.resource_amount - amount < 0 then -- zero out if asking for more than we have.
		supplyamount = amount + (self.resource_amount - amount)
	end
	
	self.resource_amount = self.resource_amount - amount
	-- empty?  
	if self.resource_amount < 1 then
		self:Remove()
	end
	return supplyamount
end

--[[
--# Cleanup on Remove...
function ENT:OnRemove()
	Ac = LDE.Anons.AsteroidClusters
	cr = Ac[self.clusterid]
	for k,v in pairs(cr.roids) do
		if v == self then 
		table.remove(cr.roids,k) 
		end
	end
	if #cr.roids < 1 then Ac[self.clusterid] = nil end
end

--# Do some Rock like stuff.
function ENT:Think()
	-- Stay on target!
	if self:GetPos() ~= self.pos or self:GetAngles() ~= self.angle then
		constraint.RemoveAll(self) -- so NAUGHTY!
		self:SetPos(self.pos)
		self:SetAngles(self.angle)
	end
	self:NextThink( CurTime() + 0.5 )
end

-- No touching D:
local function NoRoidPhys(ply,ent)
	if ent:GetClass() == "resource_asteroid" then return false end
end
hook.Add("PhysgunPickup","NoRoidTouching",NoRoidPhys)

--# Keep it safe...
function ENT:CanTool()
	return false
end

function ENT:GravGunPunt()
	return false
end

function ENT:GravGunPickupAllowed()
	return false
end
]]