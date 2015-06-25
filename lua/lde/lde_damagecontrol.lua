
LDE.DamageSystem = true

--####	Basic Health Stuff	####--
local MaxHealth,MinHealth = 1000000,100	-- Max Health Allowed

local sounds = {Sound("tech/sga_impact_01.wav"),Sound("tech/sga_impact_02.wav"),Sound("tech/sga_impact_03.wav"),Sound("tech/sga_impact_04.wav")}
for k,v in pairs(sounds) do util.PrecacheSound(v) end
function Environments.DamageLS(ent, dam) end

function DebugPrint(str)
	if false then
		print(str)
	end
end


function LDE_EntityTakeDamage( ent, dmginfo )
	if(not dmginfo)then --LDE:Debug("ERROR NO DAMAGE INFO!") 
		return 
	end
    if not IsValid(ent) then return false end
	if not ent.LDEHealth and not ent:IsPlayer() and not ent:IsNPC() then
   		LDE:CalcHealth(ent)
	end
	if(not ent.LDE)then ent.LDE = {} end
    local inflictor = dmginfo:GetInflictor()
	local attacker = dmginfo:GetAttacker()
	local amount = dmginfo:GetDamage()
	
	if ent:IsOnFire() then
		local waterlevel = ent:WaterLevel() or 0
		if(waterlevel>0)then ent:Extinguish() end	
	end
	
    if ent.LDEHealth then
		local damage = {}
		if dmginfo:IsBulletDamage() then
			amount = amount*2
			if amount > 50 then
				amount = 50	
			end
			damage= {EM = 0,EXP = 0,KIN = amount,THERM = 0} 			
		elseif dmginfo:IsExplosionDamage() then
		    damage= {EM = 0,EXP = amount,KIN = 0,THERM = 0}
		else
			if ent.LDE.Core != nil then
				if dmginfo:GetInflictor():GetClass() == "prop_combine_ball" then
				 	amount = amount / 10
				else
					amount = amount * 2.0
				end
			else
				amount = amount / 2
			end
			damage= {EM = 0,EXP = 0,KIN = amount,THERM = 0}
		end
		LDE:ApplyDamage(ent, damage, attacker, inflictor)
	elseif (ent:IsPlayer() or ent:IsNPC()) then
		LDE:ApplyPlayerDamage(ent,dmginfo)
	else
	    return false  
	end
end
hook.Add( "EntityTakeDamage", "LDE_EntityTakeDamage", LDE_EntityTakeDamage)

function LDE:ApplyPlayerDamage(ent,dmginfo,amount)
	if(not dmginfo)then  ent:TakeDamage(amount) return end
	if(ent.environment)then
		//print("Environment Detected.")
		if(ent.environment.EnvZone and ent.environment.EnvZone>0)then dmginfo:SetDamage(0) return true end
		//print("Its not a safe zone.")
	end
	if not IsValid(ent) or (ent:IsPlayer() and not ent:Alive()) then return false end
	local inflictor = dmginfo:GetInflictor()
	local attacker = dmginfo:GetAttacker()
	local amount = dmginfo:GetDamage()
	if(inflictor:IsWorld() or attacker:IsWorld())then return false end
	if dmginfo:IsFallDamage() then
		amount = amount/10
	end
	dmginfo:SetDamage(amount)
	
	if(ent:IsPlayer() and attacker)then
		--print("Attacker ent: "..tostring(attacker))
		if(not attacker:IsPlayer())then attacker=attacker.LDEOwner end
		if(attacker and attacker:IsPlayer())then
			--print("Attacker "..attacker:Name().." \n")
			local Text = ent:GetName().." was damaged by "..attacker:GetName().." for "..amount
			----LDE.Logger.LogEvent( Text )
		end
	end
	
	return true
end

function LDE:ApplyDamage(ent, damage, attacker, inflictor, override) --Attacker is the player, inflictor is the weapon)
	//print("Attacker: "..tostring(attacker))
	if not IsValid(ent) then return false end 	
	
	local amount = damage.EM+damage.EXP+damage.KIN+damage.THERM
	
	LDE:DealDamage(ent,amount,attacker,inflictor)
end

-- Health

function GetVolume(ent)

	local min = ent:OBBMins()
	local max = ent:OBBMaxs()
	local dif = max - min
	local volume = dif.x * dif.y * dif.z
	
	return volume
	
end

function LDE:GetHealthMultiplier(ent)
	return 2	
end

function LDE:CalcHealth( ent )
	if(ent.LDEMaxHealth)then return ent.LDEMaxHealth end
	
	local volume = GetVolume(ent)	
	local multiplier = LDE:GetHealthMultiplier(ent)
	local health = math.Round(((volume)^(0.515))*multiplier)
	
	if(not ent.LDEHealth)then ent.LDEHealth=health end
	
	ent.LDEMaxHealth=health
	return health
end

-- Returns the health of the entity without setting it
function LDE:GetHealth( ent )
	if(ent.InfHealth)then return 99999999 end
	if(not self:CheckValid( ent )) then return 0 end
	if(not ent.LDE) then ent.LDE = {} end
	local phys = ent:GetPhysicsObject()
	if (not IsValid(phys)) then return 0 end
	local Max = LDE:GetMaxHealth(ent)
	if (ent.LDEHealth) then
		-- Check if the entity has too much health (if the player changed the mass to something huge then back again)
		if (ent.LDEHealth > Max) then
			return Max
		end
		return ent.LDEHealth
	else
		return Max
	end
end

-- Returns the maximum health of the entity without setting it
function LDE:GetMaxHealth( ent )
	local Hp = 0
	if(ent.LDEMaxHealth)then
		Hp = ent.LDEMaxHealth
	else
		Hp = LDE:CalcHealth(ent)
	end 
	return Hp
end

function table.Random(t) --darn you garry
	local rk = math.random(1,table.Count(t))
	local i = 1
	for k,v in pairs(t) do
		if i == rk then return v, k end
		i = i + 1
	end
end

function LDE:ExplodeCoreEffect(ent,scale)
	local effectdata = EffectData()
	effectdata:SetMagnitude( 1 )
		
	local Pos = ent:GetPos()
	effectdata:SetOrigin( Pos )
	effectdata:SetScale( scale ) --Scale the size based on health.
		
	util.Effect( "LDE_coredeath", effectdata )
end

function LDE:DestroyDeathCluster(ent)
	--print("Death Func Called!")
	if(not IsValid(ent))then return end
	if(ent.Ents)then
		for key,found in pairs(ent.Ents) do
			if(IsValid(found))then
				LDE:BreakOff(found)
			end
		end
		LDE:ExplodeCoreEffect(ent,ent.ClumpWeight/10)
	end
	LDE:BreakOff(ent)
	--print("AM BROKE IT!")
end

function LDE:CoreKillProp(Prop,mass)
	local delay = (math.random(300, 800) / 100)
	timer.Create("Kill "..Prop:EntIndex(),delay+5,1,function() LDE:DestroyDeathCluster(Prop) end) --Kill the clump after some time has passed.
	local physobj = Prop:GetPhysicsObject()
	if(physobj:IsValid()) then
	physobj:Wake()
	physobj:EnableMotion(true)
	local Mult= 100
		physobj:ApplyForceCenter(Vector(math.random(mass*-Mult,mass*Mult),math.random(mass*-Mult,mass*Mult),math.random(mass*-Mult,mass*Mult)))				
	end
end

function LDE:CoreDeathWeld(ent)
	--print("DeathWeld")
	ent.Clumps = ent.Clumps or {}
	ent.Looped = ent.Looped+1
	if(ent.Looped >= ent.ExplodeLoop)then
		--print("Cores Dead!")
		for key,Prop in pairs(ent.Clumps) do
			if(Prop and Prop:IsValid())then
				if(Prop.Cluster == Prop)then
					local mass = Prop.ClumpWeight
					LDE:CoreKillProp(Prop,mass)
				end
			end
		end
		for key,Prop in pairs(ent.CoreLinked) do
			if(Prop and Prop:IsValid())then
				local Parent = Prop:GetParent()
				if(not Parent or not Parent:IsValid())then
					local physobj = Prop:GetPhysicsObject()
					if(physobj:IsValid()) then
						LDE:CoreKillProp(Prop,physobj:GetMass())
					end
				end
			end
		end
		LDE:CoreDeath(ent)
	else
		for I=1, 4 do
			local Prop,ID = table.Random(ent.CoreLinked)
			table.remove( ent.CoreLinked, ID ) --Remove the prop from the corelinked table.
			if(Prop and Prop:IsValid())then
				local TMass = 0
				local physobj = Prop:GetPhysicsObject()
				if(physobj:IsValid()) then
					TMass = TMass+physobj:GetMass()
				end
				if(not Prop.Cluster)then
					--print("Searching for nearby props!")
					Prop.Cluster = Prop
					Prop.NoLDEDamage = true
					Prop.Ents = {}
					local PRad = Prop:BoundingRadius()
					for key,found in pairs(ents.FindInSphere(Prop:GetPos(),PRad*2.2)) do
						--print("Looking at a "..tostring(found))
						if(found and found:IsValid() and not LDE:IsImmune(found) and not found:IsPlayer() and found.LDE and found.LDE.Core and found.LDE.Core==Prop.LDE.Core)then
							--print("Prop is usable!")
							if(not found.Cluster and table.Count(Prop.Ents)<=10)then
								local FRad = found:BoundingRadius()
								local Dist = Prop:GetPos():Distance(found:GetPos())
								--print("Checking Distance: "..(Dist-PRad-FRad))
								if((Dist-PRad-FRad)+70<=0 and PRad>=FRad)then
									found.Cluster = Prop
									local physobj = found:GetPhysicsObject()
									if(physobj:IsValid()) then
										TMass = TMass+ physobj:GetMass()
									end
									found:SetParent(Prop)
									found.weld =constraint.Weld(found,Prop,0,0,0,0,true)
									table.insert(Prop.Ents,found)
								end
							end
						end
					end
					--print("I weigh "..TMass.." , and I have "..table.Count(Prop.Ents).." props.")	
				end
				Prop.ClumpWeight = TMass
				table.insert(ent.Clumps,Prop)
			end
		end
	end
end

-------------Core death effect ---------------
function LDE:ExplodeCore(ent)
	
	if(not IsValid(ent))then return end
	
	--Redundant core death check here.
	if(ent.NoLDEDamage)then return end
	
	--Tell the damage system it cant hurt this core anymore.
	ent.NoLDEDamage = true
	
	--This is how many times we will repeat the weld search loop.
	ent.ExplodeLoop = table.Count(ent.CoreLinked)/4
	ent.Looped = 0
	
	--print("CoreDead")
	
	for _,i in pairs( ent.CoreLinked ) do 
		if(i and i:IsValid())then
			i:SetParent(nil) --Break the dead part off from the ship.
			constraint.RemoveAll( i )
			i:SetCollisionGroup(COLLISION_GROUP_PROJECTILE) 
			i:DrawShadow( false )
			if(math.random(1,6)==3)then
				i:Ignite(1000,100)--So only a fraction of the props burn.
			end
			i:Fire("enablemotion","",0)
			timer.Create("Cleanup "..i:EntIndex(),10,1,function() LDE:BreakOff(i) end)
			local physobj = i:GetPhysicsObject()
			if(physobj:IsValid()) then
				physobj:Wake()
				physobj:EnableMotion(true)
			end
		end
	end
	
	timer.Create("CoreDeathWeld "..ent:GetCreationID(),0.01,ent.ExplodeLoop, function() LDE:CoreDeathWeld(ent) end)	
end

function LDE:CoreDeath(ent)
	
	//Role system stuff
	--print("A core just died.")
	local owner = ent.LDEOwner
	if(owner)then
		local ownername = owner:GetName() or "ERROR"
		local Text = ownername.."'s Ship core was destroyed." 
		local OStats = owner:GetStats()
		local attacker = ent.Attacker
		if(attacker)then
			--print("Attacker ent: "..tostring(attacker))
			if(not attacker:IsPlayer())then attacker=attacker.LDEOwner end
				if(attacker and attacker:IsPlayer())then
					local AStats=attacker:GetStats()
					--print("Attacker "..attacker:Name().." \n")
					if(OStats.Bounty>0)then
						if(AStats.Bounty>0)then
							//print("Pirate on Pirate attack.")
						else
							//owner.Bounty=owner.Bounty-(ent.LDE.CoreMaxHealth/100)
							owner:TakeLDEStat("Bounty",ent.LDE.CoreMaxHealth/100)
						end
					else
					//print("Pirate attacking a civilian.")
						//attacker.Bounty=attacker.Bounty+(ent.LDE.CoreMaxHealth/100)
					attacker:GiveLDEStat("Bounty",ent.LDE.CoreMaxHealth/100)
				end
				--print("Bounty: "..AStats.Bounty)
				if(attacker==owner)then
					Text = ownername.." Destroyed their own ship core."
				else
					Text = ownername.."'s Ship core was destroyed by "..attacker:GetName() 
				end
				LDEFigureRole(attacker)
				LDEFigureRole(owner)
			end
		end
		--LDE.Logger.LogEvent( Text )
	end
	//End
	
	if(table.Count(ent.CoreLinked)>3)then
		local effectdata = EffectData()
		effectdata:SetMagnitude( 1 )
		
		local Pos = ent:GetPos()
		effectdata:SetOrigin( Pos )
		effectdata:SetScale( ent.LDE.TotalHealth/100 ) --Scale the size based on health.
		
		util.Effect( "LDE_coredeath", effectdata )
		
		ent:EmitSound( "explode_9" )
	end
						
	LDE:KillEnt(ent)
end

function LDE:BreakOff(ent)
	if(not ent or not ent:IsValid())then
		return
	end
	if(not ent.LDE)then ent.LDE = {} end
	if(ent.LDE.Core and ent.LDE.Core:IsValid() and not ent.LDE.Core.IsSpaceCraft)then
		if(ent.LDE.Core.CoreUnlink)then
			ent.LDE.Core:CoreUnLink( ent )
		end
	end
	
	--print("Breaking off.")
	
	ent.NoLDEDamage=true
	ent.IsDead = true
	if(ent.LDEBreakOff)then
		ent:LDEBreakOff()
	else
		if(math.random(1,6)==3)then
			ent:Ignite(1000,100)--So only a fraction of the props burn.
		end
		ent:SetParent(nil) --Break the dead part off from the ship.
		constraint.RemoveAll( ent )
		ent:SetSolid( SOLID_VPHYSICS )
		ent:SetCollisionGroup(COLLISION_GROUP_PROJECTILE) 
		ent:DrawShadow( false )
		ent:Fire("enablemotion","",0)


		local delay = (math.random(300, 800) / 100)
		timer.Create("Kill "..ent:EntIndex(),delay+10,1,function() LDE:KillEnt(ent) end) --Kill the ent after some time has passed.
		local physobj = ent:GetPhysicsObject()
		if(physobj:IsValid()) then
			physobj:Wake()
			physobj:EnableMotion(true)
			local mass = physobj:GetMass()
			physobj:ApplyForceCenter(Vector(math.random(mass*-250,mass*250),math.random(mass*-250,mass*250),math.random(mass*-250,mass*250)))				
		end
	end	
end

function LDE:DamageRegenDelay(ent)
	if ent.LDE.CanRecharge == 1 then
		timer.Destroy("DamageDelayLDE "..ent:GetCreationID())
		timer.Create("DamageDelayLDE "..ent:GetCreationID(),5,1, function() if (ent and ent:IsValid())then ent.LDE.CanRecharge = 1 end end)
	end
	ent.LDE.CanRecharge = 0
end

function LDE:ShieldDamageEffect(ent)
	if(not IsValid(ent) or not ent.LDE)then return end
	if not ent.LDE.ShieldSound then 				
		ent:EmitSound( sounds[math.random(1,4)], 100, math.Rand(90,110) )
		--WorldSound( sounds[math.random(1,4)], hitent:GetPos(), 100, 100 )
		ent.LDE.ShieldSound = true
 		timer.Simple( 0.2, function() if(not ent or not ent:IsValid())then return end ent.LDE.ShieldSound = false end )					
	end
	if not ent.LDE.Shieldglowing and ent.LDE.Core.LDE.CoreShield>100 then --Limit effect spam!!!
		local ed = EffectData()
 		ed:SetEntity( ent )
 		--util.Effect( "sc_shield_hit", ed, true, true)
		util.Effect( "LDE_shield_hit", ed, true, true)
		ent.LDE.Shieldglowing = true
		timer.Simple( 0.8, function() if(not ent or not ent:IsValid())then return end ent.LDE.Shieldglowing = false end )	
 	end
end

---This is for dealing advanced damage.
---We will handle the shield peircing and other damages through this.
function LDE:DealAdvDamage(ent,data)
	--print("Dealing Advanced Damage.")
	--[[
	data={
		Player = function, --The function called when a player is hit.
		Core = function, --The function called when a Cored entity is hit.
		Prop = function, --The function called when a non cored entity is hit.
		extra = {}, --A extra data table that can be used by the defined functions.
		damage = 0, --The amount of damage being done.
		inflictor = ent, --The entity dealing the damage (the weapon)
		attacker = ent, --The player that owns the weapon
		ignoresafe = false --Does the damage ignore safe zones
	}
	]]
	if(not IsValid(ent))then return end
	if(LDE:IsImmune(ent))then return end -- Its Immune.... dont do damage.
	if (not self:CheckValid( ent )) then return end
	if(not data)then print("Damage is nil") return end
	
	--print("It passed!.")
	
	if(not inflictorowner == targetowner or not data.ignoresafe or data.ignoresafe==false)then
		if(LDE:IsInSafeZone(ent))then
			return
		end
	end
	
	if(ent:IsPlayer())then
		data.Player(ent,data)
	elseif(ent.LDE.Core and ent.LDE.Core:IsValid())then
		if(ent.LDE.Core.IsSpaceCraft)then
			data.SpaceCraft(ent,data)
		else
			data.Core(ent,data)
		end
	else
		data.Prop(ent,data)
	end
	
	--print("I should of done damage by now.")
	
end

function LDE:DealDamage(ent,amount,attacker,inflictor,ignoresafe)
	DebugPrint("Dealing damage")
	
	if not IsValid(ent) then return end
	if LDE:IsImmune(ent) then return end -- Its Immune.... dont do damage.
	if not self:CheckValid( ent ) then return end
	if not amount then DebugPrint("Damage is nil") return end
	
	DebugPrint("Damage passed basic checks!")
	ent.attacker = attacker
	ent.LastAttacked = CurTime()

	amount=math.floor(math.abs(amount))
	
	DebugPrint("Damage: "..tostring(amount))
	
	if amount<=0 then return end
	local inflictorowner = "None"
	if(inflictor and inflictor.LDEOwner)then inflictorowner = inflictor.LDEOwner or "Error" end
	
	local targetowner = ent.LDEOwner or ""
	
	if(not ignoresafe or ignoresafe==false )then
		if(LDE:IsInSafeZone(ent))then
			if(inflictorowner ~= targetowner)then
				return
			end
		end
	end
	
	if (ent:IsPlayer() or ent:IsNPC()) then LDE:DealPlyDamage(ent,amount,attacker,inflictor) return end
	
	if(ent.OnLDEDamage)then	ent:OnLDEDamage(amount,attacker,inflictor) end
	
	LDE:DamageShields(ent,amount,false,attacker)
end

function LDE:DealPlyDamage(ent,amount,attacker,inflictor)
	if(not dmginfo)then  ent:TakeDamage(amount,inflictor,attacker) return end
	if not IsValid(ent) or not ent:Alive() then return false end
	if(inflictor:IsWorld() or attacker:IsWorld())then return false end
	if dmginfo:IsFallDamage() then
		amount = amount/10
	elseif ent:IsOnFire() then
		local waterlevel = ent:WaterLevel() or 0
		if(waterlevel>0)then ent:Extinguish() end
		amount = 0
	end
	dmginfo:SetDamage(amount)
	
	LDE.Mutations.HandleMutations(victim,"OnDamage",{weapon=inflictor,attacker=attacker})
	
	if(attacker)then
		--print("Attacker ent: "..tostring(attacker))
		if(not attacker:IsPlayer())then attacker=attacker.LDEOwner end
		if(attacker and attacker:IsPlayer())then
			--print("Attacker "..attacker:Name().." \n")
			local Text = ent:GetName().." was damaged by "..attacker:GetName().." for "..amount
			----LDE.Logger.LogEvent( Text )
		end
	end
	
	return true
end

function LDE:DamageShields(ent,amount,override,attacker,NoSounds)
	--Makesure its a valid run.
	if not self:CheckValid( ent ) then return end
	if not ent.LDE then ent.LDE = {} end
	--Check for a core.
	if IsValid(ent.LDE.Core) then
		--print("Shields: Core Detected")
		local hitent = ent
		ent = ent.LDE.Core
		if(ent.IsSpaceCraft)then ent:HurtShields(amount) return end
		ent.attacker = attacker
		WireLib.TriggerOutput( ent, "Attacker", attacker )
		if(ent.LDE.CoreShield>0 and not hitent.NoShields)then --Do damage to the shields only if they arnt projected.
			LDE:DamageRegenDelay(ent)
			if(not NoSounds)then
				LDE:ShieldDamageEffect(hitent)
			end
			if ent.LDE.CoreShield >= amount then
				--print("Shields: Shields took all the damage!")
				ent.LDE.CoreShield = math.Clamp(ent.LDE.CoreShield-math.abs(amount),0,ent.LDE.CoreMaxShield)
			else
				--print("Shields: Damage got through the shields, sending remaining to health.")
				ent.LDE.CoreShield = 0
				LDE:DamageHealth(hitent,amount-ent.LDE.CoreShield,false,attacker)
			end
			WireLib.TriggerOutput( ent, "Shields", ent.LDE.CoreShield or 0 )
			ent:SetNWInt("LDEShield", ent.LDE.CoreShield)
		else
			--print("Shields: No shields, sending damage to health.")
			if(not hitent.NoShields)then ent.LDE.CoreShield = 0 end --Prevents the basecore shield bug.
			LDE:DamageHealth(hitent,amount,false,attacker)
		end
	else
		--print("Shields: No Core sending damage directly to health!")
		LDE:DamageHealth(ent,amount,false,attacker)
	end
end

function LDE:DamageHealth(ent,amount,override,attacker)
	--Makesure its a valid run.
	if not self:CheckValid( ent ) then print("Error ent is nil!") return end
	if not ent.LDE then ent.LDE = {} end
	--Check for a core.
	if IsValid(ent.LDE.Core) and not override and not ent.NoShields then
		local hitent = ent
		ent = ent.LDE.Core
		if(ent.IsSpaceCraft)then ent:HurtHealth(amount) return end
		ent.attacker = attacker
		WireLib.TriggerOutput( ent, "Attacker", attacker )
		if ent.LDE.CoreHealth > amount then
			LDE:DamageRegenDelay(ent)--Call the damage delay timer on the core.
						
			ent.LDE.CoreHealth = math.Clamp(ent.LDE.CoreHealth-math.abs(amount),0,ent.LDE.CoreMaxHealth)
			
			if(not ent==hitent or ent~=hitent)then--Makesure the core itself isnt being hit
				local HitDamage = (amount/ent.Data.ArmorRate)
				if(hitent.OnLDEDamage)then hitent:OnLDEDamage(HitDamage,attacker,attacker) end
				LDE:DamageHealth(hitent,HitDamage,true) --Damage the entity that was hit.
			end
			
			ent:SetNWInt("LDEHealth", ent.LDE.CoreHealth)
			WireLib.TriggerOutput( ent, "Health", ent.LDE.CoreHealth or 0 )
		else	
			LDE:ExplodeCore(ent)
		end
	else
		local Health = LDE:GetHealth( ent )
		if Health > amount then
			if(ent.OnLDEDamage)then ent:OnLDEDamage(amount,attacker,attacker) end
			ent.LDEHealth = Health-amount
		else
			--print("Prop is dead now!")
			if(ent.LDE.Core and ent.LDE.Core:IsValid())then
				LDE:BreakOff(ent)
			else
				LDE:KillEnt(ent)
			end
		end
	end
end

function LDE:RepairHealth(ent,amount,Override)
	--Makesure its a valid run.
	if not self:CheckValid( ent ) then return end
	if not ent.LDE then ent.LDE = {} end
	if not amount or amount == 0 then return end
	--Check for a core.
	if IsValid(ent.LDE.Core) and not Override then
		ent=ent.LDE.Core
		LDE:RepairCoreHealth(ent,amount) --Send the repairs to the core.
	else
		ent.LDEHealth = math.Clamp(ent.LDEHealth+math.abs(amount),0,LDE:CalcHealth(ent))
	end
end

-- Repairs the entity by the set amount
function LDE:RepairCoreHealth( ent, amount )
	-- Check for errors
	if not LDE:CheckValid( ent ) then return end
	if not ent.LDE then ent.LDE = {} end
	//if (ent:GetClass() != "LDE_core") then return end
	//if (!ent.LDE.CoreHealth or !ent.LDE.CoreMaxHealth) then return end
	if not amount or amount == 0 then return end
	-- Add health
	ent.LDE.CoreHealth = math.Clamp(ent.LDE.CoreHealth+math.abs(amount),0,ent.LDE.CoreMaxHealth)
	ent:SetNWInt("LDEHealth",ent.LDE.CoreHealth or 0)
	for key,i in pairs( ent.CoreLinked ) do
		if IsValid(i) then
			i.LDEHealth = math.Clamp(i.LDEHealth+math.abs(amount),0,LDE:CalcHealth(i)) --Repair all attached props.
		else
			table.remove(ent.CoreLinked,key)
		end
	end
		-- Wire Output
	WireLib.TriggerOutput( ent, "Health", ent.LDE.CoreHealth or 0 )
end

function LDE:RechargeCoreShields(ent,amount)
	-- Check for errors
	if not self:CheckValid( ent ) then return end
	if not ent.LDE then ent.LDE = {} end
	if ent.LDE.Core~=ent then ent = ent.LDE.Core end
	if not amount or amount == 0 then return end

	if(ent.LDE.CanRecharge==0)then return end
	
	ent.LDE.CoreShield = math.Clamp(ent.LDE.CoreShield+math.abs(amount),0,ent.LDE.CoreMaxShield)
	ent:SetNWInt("LDEShield",ent.LDE.CoreShield or 0)
		-- Wire Output
	WireLib.TriggerOutput( ent, "Shields", ent.LDE.CoreShield or 0 )
end

--####	Kill A Destroyed Entity  ####--
function LDE:KillEnt(ent)
	if(not IsValid(ent) or ent:IsPlayer())then
		if(ent:IsPlayer())then ent:Kill() end
		return
	end
	
	if(ent.OnLDEKilled)then
		ent:OnLDEKilled(ent)
	end
	
	if(not ent.Killed)then
		ent.Killed = true
		--[[local effectdata = EffectData()
			effectdata:SetOrigin(ent:GetPos())
			effectdata:SetStart(ent:GetPos())
			util.Effect( "Explosion", effectdata )]]
		
		if(ent.IsLS)then 
			ent:Unlink() --So we know whats in it.
			if(ent.resources)then
			--	print("Entity has resources")
				local Resources={}
				local total=0
				for n,i in pairs( ent.resources ) do 
				//	print("n: "..tostring(n).." i: "..tostring(i))
					total=total+i
					if(i>0)then
						Resources[n]={}
						Resources[n].amount=i
						Resources[n].name=n
					end
				end
				if(total>0)then
					local scrap = ents.Create("resource_clump")
					scrap:SetPos(ent:GetPos()+Vector(math.random(-10,10),math.random(-10,10),math.random(-10,10)))
					scrap:SetModel( ent:GetModel() )
					scrap:Spawn()
					scrap.Resources=Resources
					scrap:SetVelocity(ent:GetVelocity())
					local delay = (math.random(900, 1800))
					scrap:Fire("break","",tostring(delay + 10))
					scrap:Fire("kill","",tostring(delay + 10))
				end
			end
		end
	end
	ent:Remove()
end

------------------------------------------------------------------------------------------------------------
-- Checks

--Checks if the entity is in a war zone.
function LDE:IsInPirateZone(ent)
	if(not IsValid(ent))then return false end
	if(ent.environment)then
		if(ent.environment.EnvZone and ent.environment.EnvZone==2)then 
			return true
		else
			return false
		end
	else
		return false
	end
end

--Checks if a entity is in a safe zone.
function LDE:IsInSafeZone(ent)
	if(not IsValid(ent))then return false end
	if(ent.ldedamageinsafe)then return false end
	if(ent.environment)then
		if(ent.environment.EnvZone and ent.environment.EnvZone>=1)then 
			return true
		else
			return false
		end
	else
		return false
	end
end

--####	Global functions to return some values so other stuff can read ####--
function LDE:MaxHealth()	-- Get the MaxHealth
	return MaxHealth
end

function LDE:MinHealth()	-- Get the MinHealth
	return MinHealth
end

function LDE:CheckValid( entity )
	if not entity:IsValid(entity)then return false end
	if (entity:IsWorld()) then return false end
	if (not entity:GetPhysicsObject():IsValid()) then return false end
	if (not entity:GetPhysicsObject():GetVolume()) then return false end
	if (not entity:GetPhysicsObject():GetMass()) then return false end
	return true
end

function LDE:IsImmune(ent)
	if not IsValid(ent) then return true end
	if(ent.jailWall or ent.NoLDEDamage)then return true end
	local str = ent:GetClass()
	for _,b in pairs(LDE.Blocked) do
		if(string.find(str,b))then
			for _,v in pairs(LDE.Always) do
				if(string.find(str,v))then
					return false
				end
			end
			return true
		end
	end
	return false
end
