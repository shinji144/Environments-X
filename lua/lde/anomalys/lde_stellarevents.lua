
--Spore Cloud
local Int = function(self) 
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	if self:GetPhysicsObject():IsValid() then
		self:GetPhysicsObject():Wake()
	end
	
	local spores = math.random(5,10)
	local Genes = LDE.SporeAI.GetNewGenes()
	local i = 0
	for i=1, spores do
		local pos = self:GetPos()+Vector(math.random(-768,768),math.random(-768,768),math.random(-768,768))
		spore = ents.Create("lde_spore")
		spore:SetPos(pos)
		spore:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
		spore:Spawn()
		while true do
			if spore:IsInWorld() then
				spore:GetPhysicsObject():Sleep()
				spore.Genetics=Genes
				spore:CPPISetOwnerless(true)
				break
			end
			pos = self:GetPos()+Vector(math.random(-512,512),math.random(-512,512),math.random(-512,512))
			spore:SetPos(pos)
		end
	end
	self:Remove()
end
local Data={name="SporeCloud Spawner",class="lde_spore_cloud",Type="Spawner",Startup=Int,Dist={Min=800,Max=1200}}
LDE.Anons.GenerateAnomaly(Data)

--Secret satalight
local Spawn = function() 		
	rock = ents.Create("space_satalight")
	local Point = LDE.Anons:PointInOrbit(rock.Data,rock)
	if(not Point)then return end	
	rock:SetPos(Point)
	rock:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
	rock:Spawn()
end

local Think = function(self)
	local R = math.random(1,10)
	local Beep = self.Beep or 0
	if(R<5 and Beep<CurTime())then
		self.Beep=CurTime()+0.3
		self:EmitSound( self.Sounds[math.random(1,table.Count(self.Sounds))],80,math.Rand(90,110) )
	end
	
	if(self.Bumped)then return end --We got bumped / stop applying orbital forces.
	local Planet = self.Planet
	
	if(not Planet or not Planet:IsValid())then print("No Planet") self:Remove() end --An error has occured.
	
	//The entity to be forced
	//Local axis that will be aligned with the aim vector (x value means facing forward)
	local ent,axis,aim,ang = self,Vector(100,0,0),Planet:GetPos(),Angle( -30 , CurTime()*10 , 0 )

	phys = ent:GetPhysicsObject()
	if(phys:IsValid()) then

		local mass = phys:GetMass()

		local orbit = Vector(Planet.radius+500,0,0)
		orbit:Rotate(ang)
		phys:AddAngleVelocity((phys:GetAngleVelocity() * -0.1))
		phys:ApplyForceCenter(( (aim+orbit) - phys:GetPos() - phys:GetVelocity()/100)*mass)

	end

end

local Int = function(self)			
	local models = {"models/Slyfo/probe1.mdl","models/Slyfo/sat_platform.mdl","models/Slyfo/sat_relay.mdl"} 
	self.Sounds = {"RD/pump/beep-2.wav","RD/pump/beep-3.wav","RD/pump/beep-4.wav","RD/pump/beep-5.wav"}
	self:SetModel(models[math.random(1,table.Count(models))])
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	if self:GetPhysicsObject():IsValid() then
		self:GetPhysicsObject():Wake()
	end
	
end
local Data={name="Satalight",class="space_satalight",Type="Orbit",Think=Think,Startup=Int,ThinkSpeed=0.01,SpawnMe=Spawn,minimal=1}
LDE.Anons.GenerateAnomaly(Data)
