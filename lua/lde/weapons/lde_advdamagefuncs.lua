LDE.AdvDamage = {}

function LDE.AdvDamage:ShieldPiercing(ent,amount,pierce,attacker,inflictor)
	--Makesure its a valid run.
	if (not LDE:CheckValid( ent )) then return end
	if (!ent.LDE) then ent.LDE = {} end
	--Check for a core.
	if(ent.LDE.Core and ent.LDE.Core:IsValid())then
		--print("Shields: Core Detected")
		local hitent = ent
		ent = ent.LDE.Core
		if(ent.LDE.CoreShield>0)then --Do damage to the shields only if they arnt charged.
			local damage = amount*pierce
			local damage2 = amount-damage
		--	print("D: "..damage.." D2: "..damage2)
			if ent.LDE.CoreShield >= damage then
				LDE:DamageShields(hitent,damage,false,attacker)
				LDE:DamageHealth(hitent,damage2,true)
			else
				LDE:DamageHealth(hitent,amount-ent.LDE.CoreShield)
			end
		else
			--print("Shields: No shields, sending damage to health.")
			LDE:DamageHealth(hitent,amount)
		end
	else
		--print("Shields: No Core sending damage directly to health!")
		LDE:DealDamage(ent,amount,attacker,inflictor)
	end
end

function LDE.AdvDamage:BudderEffect(ent,amount,mult,attacker,inflictor)
	--Makesure its a valid run.
	if (not LDE:CheckValid( ent )) then return end
	if (!ent.LDE) then ent.LDE = {} end
	--Check for a core.
	if(ent.LDE.Core and ent.LDE.Core:IsValid())then
		--print("Shields: Core Detected")
		local hitent = ent
		ent = ent.LDE.Core
		if(ent.LDE.CoreShield>0)then --Do damage to the shields only if they arnt charged.
		--	print("D: "..damage.." D2: "..damage2)
			if ent.LDE.CoreShield >= amount/2*mult then
				LDE:DamageShields(hitent,amount/2*mult,false,attacker)
			else
				LDE:DamageHealth(hitent,((amount*mult)-ent.LDE.CoreShield))
			end
		else
			--print("Shields: No shields, sending damage to health.")
			LDE:DamageHealth(hitent,amount*mult)
		end
	else
		--print("Shields: No Core sending damage directly to health!")
		LDE:DealDamage(ent,amount*mult,attacker,inflictor)
	end
end

function LDE.AdvDamage:ShieldDrain(ent,amount,drain,attacker,inflictor)
	--Makesure its a valid run.
	if (not LDE:CheckValid( ent )) then return end
	if (!ent.LDE) then ent.LDE = {} end
	--Check for a core.
	if(ent.LDE.Core and ent.LDE.Core:IsValid())then
		--print("Shields: Core Detected")
		local hitent = ent
		ent = ent.LDE.Core
		if(ent.LDE.CoreShield>0)then --Do damage to the shields only if they arnt charged.
			local ShieldDamage = amount*drain
			local shield = ent.LDE.CoreShield
			if  shield >= ShieldDamage then
				ent.LDE.CoreShield = ent.LDE.CoreShield - ShieldDamage
			else
				ent.LDE.CoreShield = 0
			end
		else
			--print("Shields: No shields, sending damage to health.")
			LDE:DamageHealth(hitent,amount)
		end
	else
		--print("Shields: No Core sending damage directly to health!")
		LDE:DealDamage(ent,amount,attacker,inflictor)
	end
end














