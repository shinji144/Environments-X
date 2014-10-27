
function EFFECT:Init( data )
	local Pos = data:GetOrigin()
	local Size = math.Round(data:GetScale())
	local emitter = ParticleEmitter( Pos )
	local clr=math.Rand(200,255) * 255
	local nr = math.Clamp(math.max(math.Round(Size/50),4),0,100)
	for I=1, nr do
		local pos = VectorRand() * Size / 10
		local vel = pos:GetNormal() * Size / 3
		local smoke = emitter:Add( "particles/smokey", Pos + pos )
			smoke:SetVelocity( vel * math.Rand(1,5) )
			smoke:SetAirResistance( 250 )
			smoke:SetDieTime( math.Rand(3,5) )
			smoke:SetStartAlpha( 150 )
			smoke:SetEndAlpha( 0 )
			local clr = math.Rand(20,100)
			smoke:SetColor( clr,clr,clr )
			smoke:SetStartSize( math.max(Size/5,20) )
			smoke:SetEndSize( math.max(Size/4.8,50) )
		
		if (I>nr/10) then
			pos = VectorRand() * 2
			vel = pos:GetNormal() * Size / 10
			local flame = emitter:Add( "particles/fire_glow", Pos + pos )
				flame:SetVelocity( vel * math.Rand(3,6) )
				flame:SetAirResistance( 10 )
				flame:SetDieTime( math.Rand(1.8,2) )
				flame:SetStartAlpha( 100 )
				flame:SetEndAlpha( 0 )
				local clr = math.Rand(100,200)
				flame:SetColor( clr/2,clr/10,clr )
				flame:SetStartSize( math.max(Size/5,10) )
				flame:SetEndSize( 10 )
		end
		

	end
	emitter:Finish()
end

function EFFECT:Think() return false end
function EFFECT:Render() end