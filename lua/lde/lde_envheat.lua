LDE.HeatSim = {}
LDE.HeatSim.Burning = {}
LDE.Simheat = true

function ApplyTemperatureEffect(Ent)
	local waterlevel = Ent:WaterLevel() or 0
	local toocold = Ent.LDE.FreezingPoint or 0
	local toohot = Ent.LDE.MeltingPoint or 0
	--Msg(" Checking ")
	if(toocold==0 or toohot==0 or not Ent.LDE.Temperature)then return end
	--Msg(" Acting ")
	if(Ent.LDE.Temperature>toocold and not Ent.LDE.IsFroze)then
		--Msg("not Frozen")
		//Environments.DamageLS(Ent,200)
		if(Ent.LDE.Temperature>=toohot and not Ent:IsOnFire() and waterlevel==0) then
			Ent:Ignite(1000,100)
		elseif(Ent.LDE.Temperature<toohot or waterlevel>0) then
			Ent:Extinguish()	
			if(waterlevel>0)then
				local vOffset = Ent:GetPos()
				local vNormal = (vOffset - Ent:GetPos()):GetNormalized()
				local effectdata = EffectData()
					effectdata:SetOrigin( vOffset )
					effectdata:SetNormal( vNormal )
					effectdata:SetRadius( 30 )
					effectdata:SetScale( 30 )
				util.Effect( "watersplash", effectdata )
			end
		end
	else
		--Msg(" Am Froze! ")
		if(Ent.TurnOff)then
			Ent:TurnOff()
		end
	end
end

function LDE.CanHeat(ent)
	local str = ent:GetClass()
	if(ent.NoLDEHeat)then return false end
	for _,b in pairs(LDE.Blocked) do
		if(string.find(str,b))then
			for _,v in pairs(LDE.Always) do
				if(string.find(str,v))then
					return true
				end
			end
			return false
		end
	end
	return true
end

function LDE.HeatSim.HeatDamage(Ent)
	if(not LDE.CanHeat(Ent))then return end
	if(Ent.IsCore or string.find(Ent:GetClass(),"wire") or Ent:IsPlayer() or Ent:IsNPC())then return end
	
	--Only run heat damage so many times a second (This prevents pulse lasers getting OP)
	if(not Ent.LastHeat)then 
		Ent.LastHeat = CurTime()+1
	else
		if(Ent.LastHeat<CurTime())then
			Ent.LastHeat=CurTime()+1
		else
			return
		end
	end	
	
	local damage = Ent.LDE.Temperature-Ent.LDE.MeltingPoint
	--print("Dealing "..damage.." damage.")
	Ent:Ignite(2,100)
	LDE:DealDamage(Ent,damage,Ent,Ent,true)		--Use the damage systems damage function.
end

function LDE.HeatSim.ManageBurning()
	--print("Running heat damages")
	for id,ent in pairs(LDE.HeatSim.Burning) do
		if(ent and ent:IsValid() and ent.LDE.OverHeating)then
			LDE.HeatSim.HeatCheck(ent)
		else
			--print("Ent is no longer valid/burning")
			table.remove( LDE.HeatSim.Burning, id )
		end
	end
end
timer.Create("LDEManageBurning",1,0, function() LDE.HeatSim.ManageBurning() end)

function LDE.HeatSim.HeatCheck(Ent)
	if(not Ent or not Ent:IsValid())then return end
	local temp = Ent.LDE.Temperature
	local toohot = Ent.LDE.MeltingPoint
	local toocold = Ent.LDE.FreezingPoint
	if(toohot)then --Check if the entity has a melthing point.
		if(temp>=toohot)then
			LDE.HeatSim.HeatDamage(Ent)
			local Over = Ent.LDE.OverHeating or false
			if(not Over or Over == false)then
				Ent.LDE.OverHeating = true
				table.insert( LDE.HeatSim.Burning, Ent ) --Add the entity to the master burning table :-)
			end
		else
			Ent.LDE.OverHeating = false
			if(temp<toocold or Ent.LDE.IsFroze)then
				if(Ent.TurnOff)then
					Ent:TurnOff()
				end
			end
		end
	end
end

function LDE.HeatSim.SetTemperture(Ent,Amount)
	Ent.LDE.Temperature=Amount
	cont = Ent:GetNWInt("LDEEntTemp")
	if (!cont or cont != Ent.LDE.Temperature) then
		Ent:SetNWInt("LDEEntTemp", Ent.LDE.Temperature)
	end
end

function LDE.HeatSim.CoolTemperture(Ent,Amount)
	LDE.HeatSim.SetTemperture(Ent,Ent.LDE.Temperature-(Amount))
end

function LDE.HeatSim.HeatTemperture(Ent,Amount)
	LDE.HeatSim.SetTemperture(Ent,Ent.LDE.Temperature+(Amount))
end

function LDE.HeatSim.ApplyHeat(Ent,Amount,Spread)
	if(Ent:IsPlayer() or Ent:IsNPC())then return end
	if(not Ent.LDE)then Ent.LDE = {} end
	if(Ent.LDE.Temperature)then
		if(Ent.LDE.Core and Ent.LDE.Core:IsValid())then
			
			HotEnt = Ent
			Ent = Ent.LDE.Core

			LDE.HeatSim.HeatTemperture(HotEnt,0)
			--LDE.HeatSim.HeatTemperture(Ent,Amount)
			Ent:ChangeTemp(Amount)
			
			WireLib.TriggerOutput( Ent, "Temperature", Ent.LDE.CoreTemp)	
		else
			LDE.HeatSim.HeatTemperture(Ent,Amount)
		end
	else
		LDE.HeatSim.SetTemperture(Ent,0)--Set the Temperature of the entity.
	end
	LDE.HeatSim.HeatCheck(Ent)
	//end
end

function LDE.HeatSim.HeatThink(Ent)
	--if Ent.environment then
	if(not Ent.node)then return end
	if(not Ent.Active)then return end
	
	local TimeSinceLast = Ent.LastHeatThink or CurTime()
	Ent.LastHeatThink = CurTime()
	
	local Active = Ent.Active
	if type(Active)=="boolean" then if Active then Active = 1 else Active = 0 end end
	local activeheat = ((Active*(0.005*(LDE:CalcHealth(Ent)/100)))*Ent:GetSizeMultiplier())*(CurTime()-TimeSinceLast)
	--print(tostring(Ent).." "..activeheat)
	--Msg("Heat Think!")
	--if (not Ent.LDE.Core or not Ent.LDE.Core:IsValid()) then --Check if the entity has a core attached.	
	local IsFroze = Ent.LDE.IsFroze or false
	--Msg(" "..tostring(IsFroze).." ")
	if(Ent.LDE.Temperature>=Ent.LDE.MeltingPoint or Ent.LDE.Temperature<=Ent.LDE.FreezingPoint or Ent.LDE.IsFroze) then
		--Msg(" Temp Effect! ")
		ApplyTemperatureEffect(Ent,Size)
	end
	LDE.HeatSim.ApplyHeat(Ent,activeheat,1) --Change the entitys Temperature
	--Msg("Done! \n")
	--else
	--	Ent.LDE.Core:ChangeTemp(activeheat)--Send the core the heat.				
	--end
	--end
end

LDE.HeatSim.Installed = 1