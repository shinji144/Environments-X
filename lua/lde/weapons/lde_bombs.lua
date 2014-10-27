
local Func = function(self) if(!self.Exploded and self.Armed) then 
	local dat = self.Data.Stats
	local Boom = { 
			Pos 					=		self:GetPos(),	--Required--		--Position of the Explosion, World vector
			ShrapDamage	=		dat.ShrapDam,										--Amount of Damage dealt by each Shrapnel that hits, if 0 or nil then other Shap vars are not required
			ShrapCount		=		dat.Shrap,										--Number of Shrapnel, 0 to not use Shrapnel
			ShrapDir			=		self:GetForward(),							--Direction of the Shrapnel, Direction vector, Example: Missile:GetForward()
			ShrapCone		=		180,										--Cone Angle the Shrapnel is randomly fired into, 0-180, 0 for all to be released directly forward, 180 to be released in a sphere
			ShrapRadius		=		dat.SharpDis,										--How far the Shrapnel travels
			ShockDamage	=		dat.Damage,				--Required--		--Amount of Shockwave Damage, if 0 or nil then other Shock vars are not required
			ShockRadius		=		dat.Range,										--How far the Shockwave travels in a sphere
			Ignore				=		self,									--Optional Entity that Shrapnel and Shockwaves ignore, Example: A missile entity so that Shrapnel doesn't hit it before it's removed
			Inflictor				=		self,			--Required--		--The weapon or player that is dealing the damage
			Owner				=		self.LDEOwner			--Required--		--The player that owns the weapon, or the Player if the Inflictor is a player
		}
		LDE:BlastDamage(Boom)
		self.Exploded = true 
		
		self:EmitSound("explode_9")
		local effectdata = EffectData() effectdata:SetOrigin(self:GetPos()) effectdata:SetStart(self:GetPos()) effectdata:SetMagnitude(3)
		util.Effect( "WhomphSplode", effectdata )

		local ShakeIt = ents.Create( "env_shake" ) 
		ShakeIt:SetName("Shaker")
		ShakeIt:SetKeyValue("amplitude", "200" )
		ShakeIt:SetKeyValue("radius", ""..dat.Range*1.5 )
		ShakeIt:SetKeyValue("duration", "5" )
		ShakeIt:SetKeyValue("frequency", "255" )
		ShakeIt:SetPos( self.Entity:GetPos() )
		ShakeIt:Fire("StartShake", "", 0);
		ShakeIt:Spawn() ShakeIt:Activate()
		ShakeIt:Fire("kill", "", 6)
			
		self:Remove() 
	end 
end

/*
Bombs
Boom={
Damage=100, 	--ShockWave Damage In a sphere around the bomb.
Range=10,		--ShockWave Range How far the shockwave travels.
Shrap=3,		--How Many Shrapnel are in a bomb.
SharpDis=600,	--How Far the Shrapnel Travel
ShrapDam=500	--How much damage Shrapnel do when they hit something.
}
*/

--Basic Bomb
local Boom = {Damage=2000,Range=1000,Shrap=30,SharpDis=800,ShrapDam=200}
local Data={name="Basic Bomb",class="basic_bomb",Mass=300,touchfunc=Func,Stats=Boom}
LDE.Weapons.RegisterBomb(Data)

--Large Bomb
local Boom = {Damage=5000,Range=1400,Shrap=20,SharpDis=800,ShrapDam=400}
local Data={name="Large Bomb",class="large_bomb",Mass=1000,touchfunc=Func,Stats=Boom}
LDE.Weapons.RegisterBomb(Data)

--Photon Torpedo
local Boom = {Damage=8000,Range=2200,Shrap=10,SharpDis=1400,ShrapDam=800}
local Data={name="Photon Torpedo",class="photon_bomb",Mass=200,touchfunc=Func,Stats=Boom}
LDE.Weapons.RegisterBomb(Data)

--Shock Bomb
local Boom = {Damage=3000,Range=5000,Shrap=0,SharpDis=0,ShrapDam=0}
local Data={name="ShockWave Bomb",class="shock_bomb",Mass=600,touchfunc=Func,Stats=Boom}
LDE.Weapons.RegisterBomb(Data)


local NukeFunc = function(self) 
	if(!self.Exploded and self.Armed) then 
		LDE.Weapons.NuclearEffect(self,Data)
		Func(self)
	end
 end

--Nuclear Bomb
local Boom = {Damage=62000,Range=5000,Shrap=0,SharpDis=0,ShrapDam=0}
local Data={name="Nuclear Bomb",class="nuke_bomb",Mass=600,touchfunc=NukeFunc,Stats=Boom}
LDE.Weapons.RegisterBomb(Data)


