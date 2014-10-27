LDE.SporeAI = {}
LDE.SporeAI.GeneSplices = {}
LDE.SporeAI.GeneSplices.Attach = {}
LDE.SporeAI.GeneSplices.Touch = {}
LDE.SporeAI.GeneSplices.Death = {}
LDE.SporeAI.GeneSplices.Damage = {}

LDE.SporeAI.Evolutions = {}
LDE.SporeAI.Evolutions.Models = {"models/env_spore/spore_ev1.mdl","models/env_spore/spore_ev2.mdl","models/env_spore/spore_ev3.mdl","models/env_spore/spore_ev4.mdl","models/env_spore/spore_ev5.mdl"}


//Function to create new gene splices for spores.
function LDE.SporeAI.MakeGeneSlice(Type,Name,Col,Gene)
	LDE.SporeAI.GeneSplices[Type][Name]={Id=Name,Dna=Gene,Col=Col}
end

//Picks a random gene out of a table.
function LDE.SporeAI.PickRandGene(Splice)
	local Gene = table.Random(LDE.SporeAI.GeneSplices[Splice])
	if(not Gene)then Gene ={Id="Error",Dna=function()end,Col=Color(255,255,255,255)} end
	return Gene
end

function LDE.SporeAI.CombineColor(Col1,Col2)
	local Col3 = Color(0,0,0,255)
	Col3.r = math.floor((Col1.r+Col2.r)/2)
	Col3.g = math.floor((Col1.g+Col2.g)/2)
	Col3.b = math.floor((Col1.b+Col2.b)/2)
	return Col3
end

//Creates a new random genetics table for spores to use.
function LDE.SporeAI.GetNewGenes()
	local Tab={}
	local Gene = LDE.SporeAI.PickRandGene("Attach")
	Tab.Think,BID,C1 	= Gene.Dna,Gene.Id,Gene.Col
	
	local Gene = LDE.SporeAI.PickRandGene("Touch")
	Tab.Touch,TID,C2 	= Gene.Dna,Gene.Id,Gene.Col
	
	local Gene = LDE.SporeAI.PickRandGene("Death")
	Tab.Death,DID,C3 	= Gene.Dna,Gene.Id,Gene.Col
	
	local Gene = LDE.SporeAI.PickRandGene("Damage")
	Tab.OnDmg,OID,C4	= Gene.Dna,Gene.Id,Gene.Col
	
	NC1=LDE.SporeAI.CombineColor(C1,C2)
	NC2=LDE.SporeAI.CombineColor(C3,C4)
	NewColor=LDE.SporeAI.CombineColor(NC1,NC2)
	
	Tab.Color 	= NewColor--Color(math.random(150,255),math.random(150,255),math.random(150,255),255)
	Tab.Genes={BID,TID,DID,OID}
	
	local DNA = BID.." "..TID.." "..DID.." "..OID
	MsgAll("Spore Dna: "..DNA)
	
	return Tab
end

if(SERVER)then
	
	function SporeThink(swarm,sporecount,num) --This allows all the spores to get a chance at thinking.
		local number = math.Round(math.random(1,sporecount))
		local spore = swarm[number]
		if(not spore.BrainWait)then
			spore.BrainWait = true
			timer.Simple(0.3+(math.random(10,30)*0.1), function() if(IsValid(spore) and spore.Brain)then spore.BrainWait=false spore:Brain() end end)
		else
			if(num<5)then
				SporeThink(swarm,sporecount,num+1)
			end
		end
	end
	
	function SporeMaster()
		local swarm = ents.FindByClass("lde_spore")
		local sporecount = table.Count(swarm) or 0
		if(sporecount==0)then return end
		for I=1, math.Round(sporecount*0.4) do
			SporeThink(swarm,sporecount,0)
		end
		LDE:Debug("Spore Main Ai Thread Ran.")
	end

	timer.Create("SporeAIThread",1.5,0, function() SporeMaster() end)

end

function SporeDebug(string)
	--print(string)
end

function LDE.SporeAI.Evolve(self)
	if(not self.FullyEvolved or self.FullyEvolved==false)then
		self.NextEvolve=CurTime()+(20*self.SporeStage)
		if(self.SporeStage<4)then
			SporeDebug("Next Evolve in "..self.NextEvolve)
			self.SporeStage=self.SporeStage+1
			self:SetModel(LDE.SporeAI.Evolutions.Models[self.SporeStage])--NewModel
			self.LDEHealth=(200*self.SporeStage)
			self.LDEMaxHealth=self.LDEHealth
		elseif(self.SporeStage==4)then
			local Nearby=LDE.SporeAI.GetNearby(self:GetPos())
			if(self.CanFlower or Nearby==1)then
				self.SporeStage=5
				self.FullyEvolved=true			
				self:SetModel(LDE.SporeAI.Evolutions.Models[self.SporeStage])--NewModel
				self:EmitSound( "npc/antlion_grub/squashed.wav",100,math.Rand(90,110) )
				self.LDEHealth=4000
				self.LDEMaxHealth=self.LDEHealth
				if(math.Rand(1,15)==3)then
					self.Genetics = LDE.SporeAI.GetNewGenes()
				end
			end
		end
	end
end

function LDE.SporeAI.GetNearby(pos)
	local nearby = 0
	for k,e in pairs(ents.FindInSphere(pos,1000)) do
		if(e.IsSpore)then
			nearby=nearby+1
		end
	end
	return nearby
end

function LDE.SporeAI.Attach(self,ent)
	if(not ent or not ent:IsValid())then return end
	if(not self.Attached)then
		self.Attached = ent
		self.Host = ent
		constraint.Weld(self, ent, 0, 0, 0, true)
		self:SetParent(ent)
		self.NextEvolve=CurTime()+20
	end
end

function LDE.SporeAI.Stickto(self,ent)
	if(not ent or not ent:IsValid())then return end
	if(not self.Attached or not self.Attached:IsValid())then
		local trace={}
		trace.start = self:GetPos()
		trace.endpos = ent:GetPos()
		trace.filter = self
		local Tr=util.TraceLine( trace )
		
		local Norm = Tr.HitNormal
		local RA = Norm:Angle()+Angle(90,0,0)
		RA:RotateAroundAxis(Norm,math.Rand(0,360))
		self:SetAngles(RA)
		
		self.Attached = ent
		self.Host = ent
		self.CanFlower = true
		constraint.Weld(self, ent, 0, 0, 0, true)
		self:SetParent(ent)
		self.NextEvolve=CurTime()+20
	end
end

function ZoneCheck(self,Pos,Size)  
    local XB, YB, ZB = Size * 0.5, Size * 0.5, Size * 0.5
    local Results = {}
    local Clear = true
    for k,e in pairs(ents.FindInSphere(Pos,Size)) do
		if(e.IsSpore)then
			local EP = e:GetPos()
					   
			local EPL = WorldToLocal( EP, Angle(0,0,0), Pos, Angle(0,0,0))
			local X,Y,Z = EPL.x, EPL.y, EPL.z
					   
			if X <= XB and X >= -XB and Y <= YB and Y >= -YB and Z <= ZB and Z >= -ZB then
				Clear = false
				break
			end
		end
    end
    return Clear
end

function LDE.SporeAI.SpreadTrace(self,OldTr)
	local n = math.Rand(0,360)
	local d = math.Rand(10,140)
	local SPos = self:GetPos()
	if(OldTr)then SPos=OldTr.HitPos end
	local trace = {}
	trace.start = SPos
	trace.endpos = SPos + (self:GetForward() * 50) + (self:GetRight() * (math.cos(n) * d)) + (self:GetUp() * (math.sin(n) * d))
	trace.filter = self

	return util.TraceLine( trace )
end

function LDE.SporeAI.GenerateSpore(self)
	SporeDebug("Reproducing")
	local tr = LDE.SporeAI.SpreadTrace(self)
	local SpreadDist = 70--70
	if tr.Hit and not tr.HitSky and not tr.HitWorld then
		if not ZoneCheck(self,tr.HitPos,SpreadDist) then SporeDebug("Spores are too close!") return end
		SporeDebug("First trace is success!")
		LDE.SporeAI.GenerateSporeFinal(self,tr.HitPos,tr.HitNormal,tr.Entity)
	else
		SporeDebug("First trace failed")
		local tr2 = LDE.SporeAI.SpreadTrace(self,tr)
		if tr2.Hit and not tr2.HitSky and not tr2.HitWorld then
			if not ZoneCheck(self,tr2.HitPos,SpreadDist) then SporeDebug("Spores are too close!") return end
			SporeDebug("SecondTrace Success!")
			LDE.SporeAI.GenerateSporeFinal(self,tr2.HitPos,tr2.HitNormal,tr2.Entity)
		end
	end
end

function LDE.SporeAI.GenerateSporeFinal(self,Pos,Norm,HEnt)
	if HEnt.IsSpore or HEnt:GetClass() == "player" then return end
	SporeDebug("Generating Spore now!")
    local P1 = Pos + Norm
    local P2 = Pos - Norm
    local ent = ents.Create( "lde_spore" )
    local RA = Norm:Angle()+Angle(90,0,0)
    RA:RotateAroundAxis(Norm,math.Rand(0,360))
    ent:SetAngles(RA)
    ent:SetPos( Pos + Norm * 2 )
    ent:Spawn()
    ent:Initialize()
    ent:Activate()
	LDE.SporeAI.Attach(ent,HEnt)
	ent.Genetics = self.Genetics
	ent:SetColor(self.Genetics.Color)
	if(NADMOD)then
		NADMOD.SetOwnerWorld(ent)
	end
	SporeDebug("made a spore!")
end

function LDE.SporeAI.TakeDam(self,dmg,attacker,inflictor)
	self.Genetics.OnDmg(self,dmg,attacker,inflictor)
	if(self.LDEHealth>dmg)then
		self.LDEHealth=self.LDEHealth-dmg
	else
		self.Genetics.Death(self,dmg,attacker,inflictor)
		self:EmitSound( "npc/antlion_grub/squashed.wav",100,math.Rand(90,110) )
		self:Remove()
	end
end

//Base Code for spores.
function LDE.SporeAI.MakeSpore(Data)
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_gmodentity"
	ENT.PrintName = Data.name
	ENT.Spawnable			= false
	ENT.AdminSpawnable		= false

	ENT.StartMe				= 1
	ENT.Stype				= 0
	ENT.Genetics			= {}
	ENT.SporeStage			= 1
	ENT.LDEHealth		= 200
	ENT.LDEMaxHealth	= 200
	ENT.ldedamageinsafe 	= true
	
	ENT.IsSpore				= true
	ENT.Data				= Data
	ENT.Attached			= false
	ENT.CanFlower			= false
	ENT.NextEvolve			= 0
	
	if(Data.Shared)then
		Data.Shared(ENT)
	end
		
	if SERVER then
		
		if(Data.Server)then
			Data.Server(ENT)
		end
		
		function ENT:SpawnFunction( ply, tr )
			if ( not tr.Hit ) then return end
			local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,30)
			local ent = ents.Create(Data.class)
			ent:SetPos(SpawnPos);
			ent:Spawn();
			ent:Activate();
			local Gene = LDE.SporeAI.GetNewGenes()
			ent.Genetics=Gene
			ent:SetColor(Gene.Color)
			return ent
		end
		
		function ENT:Initialize()   
			self:SetModel(LDE.SporeAI.Evolutions.Models[self.SporeStage])--NewModel
			//self:SetModel("models/Weapons/w_bugbait.mdl")--Old working model
			self:PhysicsInit(SOLID_VPHYSICS)
			self:SetMoveType(MOVETYPE_VPHYSICS)
			self:SetSolid(SOLID_VPHYSICS)
			self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)--Prevents them from self colliding.
			//self.Entity:SetMaterial("models/debug/debugwhite")
			if(NADMOD)then
				NADMOD.SetOwnerWorld(self)
			end
			
			if self:GetPhysicsObject():IsValid() then
				self:GetPhysicsObject():Wake()
				self:GetPhysicsObject():EnableGravity(false)
			end

			self.PhysObj = self:GetPhysicsObject()
			self.CAng = self:GetAngles()
			self.Attached = false
			--self.InfHealth = true --Give us infinite health damage system wise.
			
			if(math.random(1,20)<3)then
				self.CanFlower = true
			end
		end
		
		function ENT:OnTakeDamage(dmg)
			--LDE.SporeAI.TakeDam(self,dmg)
		--	LDE.SporeAI.TakeDam(self,dmg:GetDamage(),dmg:GetAttacker(),dmg:GetInflictor())
		end	
		
		function ENT:OnLDEDamage(dmg,attacker,inflictor)
			LDE.SporeAI.TakeDam(self,dmg,attacker,inflictor)
		end	
		
		function ENT:Touch(activator)
			if(activator:IsWorld() or activator==self.Attached )then return end
			if( LDE:IsImmune(activator) )then return end
			if self.Attached then
				if(self.Genetics.Touch)then
					self.Genetics.Touch(self,activator)
				end
			else
				if not activator.IsSpore and not activator:IsPlayer() then
					local pos = self:GetPos()
					if ((activator:GetVelocity()+self:GetVelocity()):Length() > 15000) then
						self:Remove()
					else
						LDE.SporeAI.Stickto(self,activator)
					end
				end 
			end
		end
		
		function ENT:Brain()
			self:SetColor(self.Genetics.Color)
			if self.Attached then
				if(self.SporeStage>=4)then
					self.Genetics.Think(self,self.Attached)
					if(self.SporeStage>=5)then
						LDE.SporeAI.GenerateSpore(self)
					end
				end
				if(self.NextEvolve<CurTime())then
					LDE.SporeAI.Evolve(self)
				end
			end 
		end
		
	else
		if(Data.Client)then
			Data.Client(ENT)
		end
	end
	scripted_ents.Register(ENT, Data.class, true, false)
	print("Spore Class Registered: "..Data.class)
end

--BaseSpore
local Spawn = function() 	
	rock = ents.Create("lde_spore_cloud")
	local Point = LDE.Anons:PointInOrbit(rock.Data)
	if(not Point)then return end	
	rock:SetPos(Point)
	rock:Spawn()
end

local Data={name="Basic Space Spore",class="lde_spore",Type="Orbit",SpawnMe=Spawn,minimal=40}
LDE.SporeAI.MakeSpore(Data)
LDE.Anons:RegisterAnomaly(Data)

--Super Spore ideas.
--Mecha Spore:
--*When attached to a ship it slowly eats parts of the ship growing larger,
--*Until it reachs critical size and it drops off the ship forming its own vessal
--*That it uses to infect other ships.


--Attached genes
--Add a gene that makes spores suck resoures out of a ships lifesupport
--Add a gene that causes the spore to direct all damage to the ship core.
--Add a gene that allows the spore to evolve a seed cannon.
--Add a gene that combines two other genes.

local Gene = function(self,Attached)
	if(Attached.LDE)then
		local Core = Attached.LDE.Core
		if(Core and Core:IsValid())then
			LDE:DamageShields(Core,50,false,self,true)
		else
			LDE:DealDamage(Attached,10,self,self)
		end
	end
end
LDE.SporeAI.MakeGeneSlice("Attach","Acidic",Color(0,150,0,255),Gene)

local Gene = function(self,Attached)
	if(Attached.LDE)then
		local Core = Attached.LDE.Core
		if(Core and Core:IsValid())then
			LDE.HeatSim.ApplyHeat(Core,400)
		else
			LDE.HeatSim.ApplyHeat(Attached,20)
		end
	end
end
LDE.SporeAI.MakeGeneSlice("Attach","Combustion",Color(255,180,0,255),Gene)

local Gene = function(self,Attached)
	if(Attached.LDE)then
		local Core = Attached.LDE.Core
		if(Core and Core:IsValid())then
			LDE.HeatSim.ApplyHeat(Core,-1000)
		else
			LDE.HeatSim.ApplyHeat(Attached,-1000)
		end
	end
end
LDE.SporeAI.MakeGeneSlice("Attach","FrostBite",Color(0,255,230,255),Gene)

local Gene = function(self,Attached)
	self.NextEvolve = self.NextEvolve-1
end
LDE.SporeAI.MakeGeneSlice("Attach","Darwins Whore",Color(255,100,100,255),Gene)

local Gene = function(self,Attached)
	
end
LDE.SporeAI.MakeGeneSlice("Attach","Regenerative",Color(150,255,150,255),Gene)

--OnDeath Genes.
--Add gene that causes resources to drop.
--Add a gene that causes E5 spores to spew out spores.

local Gene = function(self)	

	self.NoLDEDamage = true
	
	local NewData = { 
		Pos 					=		self:GetPos(),							--Required--		--Position of the Explosion, World vector																--How far the Shrapnel travels
		ShockDamage				=		2000,		--Optional--		--Amount of Shockwave Damage, if 0 or nil then other Shock vars are not required
		ShockRadius				=		500,							--How far the Shockwave travels in a sphere
		Ignore					=		self,								--Optional--		--Entity that Shrapnel and Shockwaves ignore, Example: A missile entity so that Shrapnel doesn't hit it before it's removed
		Inflictor				=		self,							--Required--		--The weapon or player that is dealing the damage
		Owner					=		self					--Required--		--The player that owns the weapon, or the Player if the Inflictor is a player
	}
	LDE:BlastDamage(NewData)
	
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetStart(self:GetPos())
	util.Effect( "Explosion", effectdata )
end
LDE.SporeAI.MakeGeneSlice("Death","Explosive",Color(255,0,0,255),Gene)

LDE.SporeAI.MakeGeneSlice("Death","None",Color(0,0,0,255),function()end)
LDE.SporeAI.MakeGeneSlice("Death","None2",Color(0,0,0,255),function()end)

--OnTouch Genes.
--Add a gene that causes the spore to stick to everything.

local Gene = function(self,Activator)
	LDE:DealDamage(Activator,2,self,self)
end
LDE.SporeAI.MakeGeneSlice("Touch","Spiny",Color(160,255,0,255),Gene)

local Gene = function(self,Activator)
	if(Activator:IsPlayer())then
		local Debuff = {
			Tick 		= function(ply) LDE:DealDamage(ply,5,ply,ply,true) end,
			OnDeath 	= function(ply,Ext) end, --Add exploding hook here.
			OnStart 	= function(ply) ply:SendColorChat("Alert",{r=255,g=0,b=0},"You've Been Sporefected!") end, --Add notification that players got infected.
			OnTimeEnd 	= function(ply) end,
			OnRemove 	= function(ply) ply:SendColorChat("Alert",{r=0,g=255,b=0},"You are no longer Sporefected!") end, --Add notification that its done.
			OnDamage 	= function(ply,Ext) end,
			OnKill 		= function(ply,Ext) end
		}
		Activator:GiveMutation("Sporefection",60,Debuff,false,true)
	end
end
LDE.SporeAI.MakeGeneSlice("Touch","Infectius",Color(220,0,255,255),Gene)

LDE.SporeAI.MakeGeneSlice("Touch","None",Color(0,0,0,255),function()end)
LDE.SporeAI.MakeGeneSlice("Touch","None2",Color(0,0,0,255),function()end)

--OnDamage genes.
--Add a gene that causes spores to fight back.
--Add a gene that causes a protective shield to form if the attacker is a player

LDE.SporeAI.MakeGeneSlice("Damage","None",Color(0,0,0,255),function()end)
LDE.SporeAI.MakeGeneSlice("Damage","None2",Color(0,0,0,255),function()end)




