/*local matRefraction	= Material( "refract_ring" )

local tMats = {}

tMats.Glow1 = Material("sprites/light_glow02")
--tMats.Glow1 = Material("models/roller/rollermine_glow")
tMats.Glow2 = Material("sprites/yellowflare")
tMats.Glow3 = Material("sprites/redglow2")

for _,mat in pairs(tMats) do
	mat:SetMaterialInt("$spriterendermode",9)
	mat:SetMaterialInt("$ignorez",1)
	mat:SetMaterialInt("$illumfactor",8)
end*/

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )
	self.Position = data:GetEntity():GetPos() or Vector(0,0,0)
	self.Position.z = self.Position.z + 4
	self.TimeLeft = CurTime() + 100000
	
	self.lastsize = 1
	
	self.Entity = data:GetEntity()
	
	local Pos = self.Position
	
	self.smokeparticles = {}
	self.Emitter = ParticleEmitter( Pos )
		
	for k=5,26 do
		self.smokeparticles[k] = self.Emitter:Add( "particles/flamelet"..math.random(1,5), Pos + Vector(math.random(1,500),math.random(1,500),math.random(1,500)))
		//particle:SetVelocity(vecang*math.Rand(2,3))
		self.smokeparticles[k]:SetDieTime( 50000 )
		self.smokeparticles[k]:SetStartAlpha( math.Rand(230, 250) )
		local size = k*math.Rand(13,15)
		self.smokeparticles[k]:SetStartSize( size )
		self.smokeparticles[k]:SetEndSize( size )
		self.smokeparticles[k]:SetRoll( math.Rand( 1, 10 ) )
		//self.smokeparticles[k]:SetRollDelta( math.random( -1, 1 ) )
		self.smokeparticles[k]:SetColor(100, math.random(100,128), math.random(230,255))
		--self.smokeparticles[k]:VelocityDecay( true )
		self.smokeparticles[k].size = size
	end
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	if self.Entity and self.Entity:IsValid() then
		local size = self.Entity:GetNWInt("resourceamt", 0)/10000
		if size != self.lastsize then
			for k,v in pairs(self.smokeparticles) do
				local size = v.size*size
				v:SetEndSize(size)
				v:SetStartSize(size)
			end
			self.lastsize = size
		end
		
		return true
	else
		for k,v in pairs(self.smokeparticles) do
			v:SetDieTime(1)
			self.smokeparticles[k] = nil
		end
		self.Emitter:Finish()
		return false
	end
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )

end
