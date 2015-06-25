

--[[

local Int = function(self)			
	local rockmodels = {
	"models/props_canal/rock_riverbed01d.mdl","models/props_wasteland/rockgranite04b.mdl","models/props_wasteland/rockcliff01g.mdl","models/props_wasteland/rockgranite01c.mdl",
	"models/props_wasteland/rockcliff01c.mdl","models/props_wasteland/rockcliff01j.mdl","models/props_wasteland/rockgranite04c.mdl","models/props_wasteland/rockcliff01e.mdl",
	"models/mandrac/asteroid/crystal1.mdl","models/mandrac/asteroid/crystal3.mdl","models/mandrac/asteroid/crystal4.mdl","models/props_wasteland/rockgranite01a.mdl",
	"models/props_wasteland/rockcliff01b.mdl","models/props_wasteland/rockcliff01f.mdl","models/props_wasteland/rockgranite01b.mdl","models/props_wasteland/rockgranite04a.mdl",
	"models/props_wasteland/rockcliff01g.mdl","models/mandrac/asteroid/rock2.mdl","models/mandrac/asteroid/rock4.mdl"} 
	self:SetModel(rockmodels[math.random(1,table.Count(rockmodels))])
	
	local Skin = math.floor(math.random(0,self:SkinCount()))--Pick a random skin.
	self:SetSkin(Skin)
	
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local PO = self:GetPhysicsObject()
	if PO then 
		PO:EnableDrag( false ) 
		PO:EnableGravity( false ) 
		PO:Wake()
	end
				
	self.Ore = LDE:CalcHealth(self)
	
end
local Data={name="Asteroid",class="space_asteroid",Type="Space",Startup=Int,ThinkSpeed=1,SpawnMe=Spawn,minimal=40}
LDE.Anons.GenerateAnomaly(Data)
]]

--Asteroid Field
local Int = function(self) 
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	if self:GetPhysicsObject():IsValid() then
		self:GetPhysicsObject():Wake()
	end
	
	local rocks = math.random(5,10)
	local i = 0
	for i=1, rocks do
		local pos = self:GetPos()+Vector(math.random(-768,768),math.random(-768,768),math.random(-768,768))
		rock = ents.Create("resource_asteroid")
		rock:SetPos(pos)
		rock:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
		rock:SetResource("Raw Ore")
		rock:Spawn()
		
		rock:SetVolume()
		rock:CalcResource()
	end
	self:Remove()
end
local Data={name="Asteroid field",class="asteroid_field",Type="Spawner",Startup=Int}
LDE.Anons.GenerateAnomaly(Data)

local Spawn = function() 		
	rock = ents.Create("asteroid_field")
	rock:SetPos(LDE.Anons:PointInSpace(rock.Data))
	rock:Spawn()
end

LDE.Anons.Monitor["resource_asteroid"]={
	class = "resource_asteroid",
	SpawnMe = Spawn,
	minimal=40
}


