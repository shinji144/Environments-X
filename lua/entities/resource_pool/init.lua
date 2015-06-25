AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
		self:PhysicsInitSphere(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
		self:DrawShadow(false)

		self.radius = self.radius or 1
		self.base_volume = self.base_volume or 0
		self.density = self.density or 0
		self.rarity = self.rarity or 0
		self.depth = self.depth or 1
		self.resource_amount = self.resource_amount or 0
		self.resource_type = self.resource_type or ""
		
		-- for brevitys sake incase I want to model actual ents touching the resource pool somehow?
		-- In the future I'd like to make the pools more oblique in shape perhaps a flattened disk instead of a sphere.
		self:SetCollisionBounds( Vector(-self.radius,-self.radius,-self.radius),Vector(self.radius,self.radius,self.radius) )
end

-- sets the radius of the resource pool
function ENT:SetPoolSize(radius)
	if not radius or type(radius) ~= "number" then return end
	radius = math.Clamp(radius,0,2048)
	self.radius = radius
end

function ENT:SetDepth(depth)
	if not depth or type(depth) ~= "number" then return end
	self.depth = math.floor(depth)
	return self.depth
end

-- calculate the volume of the resource pool
function ENT:SetPoolVolume()
	if not self.radius then return end
	self.base_volume = (4/3) * math.pi * self.radius^3
end

-- Is the position within the pool?
function ENT:InPoolRadius(position)
	if not position or type(position) ~= "Vector" then return end
	local pos = self:GetPos()
	if position:Distance(pos) <= self.radius then return true end
	return false
end

--  Return the base volume of the resource pool
function ENT:Get_Volume()
	return self.base_volume or 0
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

-- Calculates Total Resources in the pool 
function ENT:CalcResource()
	self.resource_amount = math.Round( (self.base_volume / ( self.density + self.rarity ) ) * 0.2, 0 )
	return self.resource_amount
end

-- Empty ourself of resources when we are being mined out.. :(
function ENT:Drain(amount)
	if not amount or type(amount) ~= "number" then return 0 end
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

-- Cleanup on Remove.
function ENT:OnRemove()
	for k,v in pairs(LDE.Anons.ResourcePools[self.planetname]) do
		if v == self then
			LDE.Anons.ResourcePools[self.planetname][k]=nil
		end
	end
end

--  Returns the total remaining amount of a resource in the pool
function ENT:GetResourceAmount(name)
	return self.resource_amount
end

--  Usual restrictions to prevent naughtiness
function ENT:CanTool()
	return false
end

function ENT:GravGunPunt()
	return false
end

function ENT:GravGunPickupAllowed()
	return false
end
