 LDE.EffectSys = {}

if ( not PARTICLE_EMITTER ) then PARTICLE_EMITTER = ParticleEmitter; end
function ParticleEmitter( _pos )
	if (not _GLOBAL_PARTICLE_EMITTER or not IsValid( _GLOBAL_PARTICLE_EMITTER ) ) then 
		_GLOBAL_PARTICLE_EMITTER = PARTICLE_EMITTER( _pos );
		--print("New emitter made!")
	else
		_GLOBAL_PARTICLE_EMITTER:SetPos( _pos );
		--print("Reloading old emitter!")
	end

	return _GLOBAL_PARTICLE_EMITTER;
end

//Base Code for Effects.
function LDE.EffectSys.RegisterEffect(Data)
	if(SERVER)then return end --No server side effects here.
	local EFFECT = {}
	EFFECT.Data = Data

	function EFFECT:Init(Table)
		if(self.Data.Initialise)then
			self.Data.Initialise(self,Table)
		end
		self.DieTime = CurTime() + self.Data.Duration
	end
	
	function EFFECT:RunEmitter(Pos)
		if(not self.Emitter or not IsValid(self.Emitter))then self.Emitter = ParticleEmitter(Pos) end --Create a emitter if one isnt present.
		self.Data.Emit(self)
		self.Emitter:Finish()
	end
	
	function EFFECT:Think()
		if(self.Data.Think)then
			return self.Data.Think(self)
		end
		return false --Selfdestruct if the data doesnt keep us alive.
	end
	
	function EFFECT:Render( )
		if(self.Data.Render)then
			return self.Data.Render(self)
		end		
	end
	
	effects.Register( EFFECT, Data.name )
	print("EFFECT Registered: "..Data.name)
end

--Ease function to create beam based effects.
function LDE.EffectSys.RegisterBeamEffect(Data)

	Data.Initialise = function(self,Table)
		self.StartPos,self.EndPos,self.Ent = Table:GetStart(),Table:GetOrigin(),Table:GetEntity()
		if (!self.Ent:IsValid()) then return false end
		self.Dir,self.LocalStartPos,self.LocalEndPos = (self.EndPos-self.StartPos),self.Ent:WorldToLocal(self.StartPos),self.Ent:WorldToLocal(self.EndPos)
		self:SetRenderBoundsWS( self.StartPos, self.EndPos )
	end

	Data.Think = function(self)
		if ( CurTime() > self.DieTime or not self.Ent:IsValid()) then return false end
		return true
	end

	Data.Render = function(self)
		if(not self.Ent)then return false end
		local Pos,EPos = self.Ent:LocalToWorld(self.LocalStartPos),self.Ent:LocalToWorld(self.LocalEndPos)
			
		render.SetMaterial( Material(self.Data.Material) )
		render.DrawBeam( Pos, EPos, self.Data.Width, self.Data.TextS, self.Data.TextE)		
	end

	LDE.EffectSys.RegisterEffect(Data)
end

---------------------BeamEffects-----------------------
local Data={name="LDE_laserbeam",Duration=0.1,Material="cable/redlaser",Width=20,TextS=1,TextE=10}
LDE.EffectSys.RegisterBeamEffect(Data)

local Data={name="LDE_laserbeam_long",Duration=0.5,Material="cable/redlaser",Width=20,TextS=1,TextE=10}
LDE.EffectSys.RegisterBeamEffect(Data)

local Data={name="LDE_leechbeam",Duration=0.1,Material="cable/xbeam",Width=20,TextS=1,TextE=10}
LDE.EffectSys.RegisterBeamEffect(Data)

local Data={name="LDE_laserbeamhuge",Duration=0.5,Material="cable/physbeam",Width=200,TextS=1,TextE=10}
LDE.EffectSys.RegisterBeamEffect(Data)

--------------------ParticleEffects---------------------

--Ease function to create particle based effects.
function LDE.EffectSys.RegisterParticleEffect(Data)

	Data.Initialise = function(self,Table)
		self.Data.Setup(self,Table)
		self.Emitter = ParticleEmitter(Vector(0,0,0))
	end
	
	Data.Think = Data.Think or function(self)
		self:RunEmitter(self.vOffset)
		if ( CurTime() > self.DieTime) then self.Emitter:Finish() return false end
		return true
	end
	
	LDE.EffectSys.RegisterEffect(Data)
end

---------Laser hit effect--------

local Int = function( self,data ) 
 	self.vOffset,self.dir = data:GetOrigin(),data:GetNormal()
end 

local Emit = function(self)
	for x = 1,3 do
		vel = self.vOffset:GetNormal()+Vector(math.Rand(-2,2),math.Rand(-2,2),math.Rand(-2,2))
		
		local particle = self.Emitter:Add( "particles/fire_glow", (self.vOffset + self.dir * 2))
		particle:SetVelocity( vel * math.Rand(3,6) )
		particle:SetLifeTime( 0 )
		particle:SetDieTime( 0.15 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 50 )
		particle:SetStartSize( 8 )
		particle:SetEndSize( 0 )
		particle:SetColor( 255, 30, 30 )
	end
end

local Data={name="LDE_laserhiteffect",Duration=0.3,Emit=Emit,Setup=Int}
LDE.EffectSys.RegisterParticleEffect(Data)

