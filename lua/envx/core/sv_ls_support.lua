------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

LS = {}

//Thank you guy who wrote LS3, this fixes stuff not exploding
CreateConVar( "LS_AllowNukeEffect", "1" ) //Update to something changeable later on 

local function LS_Reg_Veh(ply, ent)
	if CAF then
		local RD = CAF.GetAddon("Resource Distribution")
		RD.RegisterNonStorageDevice(ent)
	end
end
hook.Add( "PlayerSpawnedVehicle", "LS_vehicle_spawn", LS_Reg_Veh )

local function RemoveEntity( ent )
	if (ent:IsValid()) then
		ent:Remove()
	end
end

local function Explode1( ent )
	if ent:IsValid() then
		local Effect = EffectData()
			Effect:SetOrigin(ent:GetPos() + Vector( math.random(-60, 60), math.random(-60, 60), math.random(-60, 60) ))
			Effect:SetScale(1)
			Effect:SetMagnitude(25)
		util.Effect("Explosion", Effect, true, true)
	end
end

local function Explode2( ent )
	if ent:IsValid() then
		local Effect = EffectData()
			Effect:SetOrigin(ent:GetPos())
			Effect:SetScale(3)
			Effect:SetMagnitude(100)
		util.Effect("Explosion", Effect, true, true)
		RemoveEntity( ent )
	end
end

function LS.ZapMe(pos, magnitude)
	if not (pos and magnitude) then return end
	zap = ents.Create("point_tesla")
	zap:SetKeyValue("targetname", "teslab")
	zap:SetKeyValue("m_SoundName" ,"DoSpark")
	zap:SetKeyValue("texture" ,"sprites/physbeam.spr")
	zap:SetKeyValue("m_Color" ,"200 200 255")
	zap:SetKeyValue("m_flRadius" ,tostring(magnitude*80))
	zap:SetKeyValue("beamcount_min" ,tostring(math.ceil(magnitude)+4))
	zap:SetKeyValue("beamcount_max", tostring(math.ceil(magnitude)+12))
	zap:SetKeyValue("thick_min", tostring(magnitude))
	zap:SetKeyValue("thick_max", tostring(magnitude*8))
	zap:SetKeyValue("lifetime_min" ,"0.1")
	zap:SetKeyValue("lifetime_max", "0.2")
	zap:SetKeyValue("interval_min", "0.05")
	zap:SetKeyValue("interval_max" ,"0.08")
	zap:SetPos(pos)
	zap:Spawn()
	zap:Fire("DoSpark","",0)
	zap:Fire("kill","", 1)
end

function LS.ColorDamage(ent, HP, Col)
	if not ent or not HP or not Col or not IsValid(ent) then return end
	if (ent:Health() <= (ent:GetMaxHealth( ) / HP)) then
		ent:SetColor(Col, Col, Col, 255)
	end
end

function LS.DamageLS(ent, dam)
	if not (ent and ent:IsValid() and dam) then return end
	if ent:GetMaxHealth( ) == 0 then return end
	dam = math.floor(dam / 2)
	if (ent:Health( ) > 0) then
		local HP = ent:Health( ) - dam
		ent:SetHealth( HP )
		if (ent:Health( ) <= (ent:GetMaxHealth( ) / 2)) then
			if ent.Damage then
				ent:Damage()
			end
		end
		LS.ColorDamage(ent, 2, 200)
		LS.ColorDamage(ent, 3, 175)
		LS.ColorDamage(ent, 4, 150)
		LS.ColorDamage(ent, 5, 125)
		LS.ColorDamage(ent, 6, 100)
		LS.ColorDamage(ent, 7, 75)
		if (ent:Health( ) <= 0) then
			ent:SetColor(50, 50, 50, 255)
			if ent.Destruct then
				ent:Destruct()
			else
				LS.Destruct( ent, true )
			end
		end
	end
end

function LS.Destruct( ent, Simple )
	if (Simple) then
		Explode2( ent )
	else
		timer.Simple(1, function() Explode1( ent) end )
		timer.Simple(1.2, function() Explode1( ent) end )
		timer.Simple(2, function() Explode1( ent) end )
		timer.Simple(2, function() Explode2( ent) end )
	end
end

function LS.RemoveEnt( ent )
	constraint.RemoveAll( ent )
	timer.Simple( 1, function() RemoveEntity(ent) end)
	ent:SetNotSolid( true )
	ent:SetMoveType( MOVETYPE_NONE )
	ent:SetNoDraw( true )
end
