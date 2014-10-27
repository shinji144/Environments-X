
local scripted_ents = scripted_ents
local table = table
local util = util
local player = player
local umsg = umsg
local list = list
local timer = timer
local ents = ents
local duplicator = duplicator
local math = math
local tostring = tostring
local MeshQuad = MeshQuad
local Vector = Vector
local type = type
local tonumber = tonumber
local pairs = pairs

	
/*local function e2hook(ent)
	if ent and ent:IsValid() then
		if ent:GetClass() == "sent_anim" then
			if ent.Execute then
				RD_Register(ent)
				
				ent.override_ops = 50
				ent.oldExecute = ent.Execute or function() end
				ent.Execute = function(self)
					if self:GetResourceAmount("energy") >= self.override_ops then
						self:ConsumeResource("energy", self.override_ops)
						self.oldExecute(self)//execute
						print("counter: ",self.context.prfcount, "prf: ", self.context.prf, "prfbench: ", self.context.prfbench)
						self.override_ops = self.context.prfcount or 0
					end
				end
			end
		end
	end
end
hook.Add("OnEntityCreated", "E2OVERRIDES", e2hook)*/

if SERVER then
	local function CheckRD() --make not call for update all the time
		for k,ply in pairs(player.GetAll()) do
			local ent = ply:GetEyeTrace().Entity
			if ent and ent:IsValid() then
				if ent.node and ent.node:IsValid() then --its a RD entity, send the message!
					--list.Set( "LSEntOverlayText" , class, {HasOOO = true, resnames = In, genresnames = Out} )
					local dat = list.Get("LSEntOverlayText")[ent:GetClass()] --get the resources
					if dat then
						ent.node:DoUpdate(dat.resnames, dat.genresnames, ply)
					else --no list data? SG? CAP?
					
					end
				elseif ent.maxresources and !ent.IsNode then
					if !ent.client_updated then
						for res,amt in pairs(ent.maxresources) do
							umsg.Start("EnvStorageUpdate")
								umsg.Entity(ent)
								umsg.String(res)
								if ent.resources then
									umsg.Long(ent.resources[res] or 0)
								else
									umsg.Long(0)
								end
								umsg.Long(amt)
							umsg.End()
						end
						ent.client_updated = true
					end
				end
			end
		end
	end
	timer.Create("RDChecker", 0.5, 0, CheckRD) --adjust rate perhaps?
end

local function SaveGravPlating( Player, Entity, Data )
	if not SERVER then return end
	if Data.GravPlating and Data.GravPlating == 1 then
		Entity.grav_plate = 1
		if ( SERVER ) then
			Entity.EntityMods = Entity.EntityMods or {}
			Entity.EntityMods.GravPlating = Data
		end
	else
		Entity.grav_plate = nil
		if ( SERVER ) then
			if Entity.EntityMods then Entity.EntityMods.GravPlating = nil end
		end	
	end
	duplicator.StoreEntityModifier( Entity, "gravplating", Data )
end
//duplicator.RegisterEntityModifier( "gravplating", SaveGravPlating )

//need to add dupe support
local function RegisterVehicle(ply, ent)
	RD_Register(ent, false)
end
hook.Add( "PlayerSpawnedVehicle", "ENV_vehicle_spawn", RegisterVehicle )

function Environments.BuildDupeInfo( ent ) --need to add duping for cables
	local info = {}
	if ent.IsNode then
		--local nettable = ent.connected
		--local info = {}
		--info.resources = table.Copy(ent.maxresources)

		--duplicator.StoreEntityModifier( ent, "EnvDupeInfo", info )
		return
	elseif ent:GetClass() == "env_pump" then
		local info = {}
		info.pump = ent.pump_active
		info.rate = ent.pump_rate
		info.hoselength = ent.hose_length
	end
	
	if ent.node then
		info.Node = ent.node:EntIndex()
	end
	
	info.extra = ent.env_extra
	
	info.LinkMat = ent:GetNWString("CableMat", nil)
	info.LinkPos = ent:GetNWVector("CablePos", nil)
	info.LinkForw = ent:GetNWVector("CableForward", nil)
	info.LinkColor = ent:GetNWVector("CableColor", nil)
	
	duplicator.StoreEntityModifier( ent, "EnvDupeInfo", info )
end

//apply the DupeInfo
function Environments.ApplyDupeInfo( ent, CreatedEntities, Player ) --add duping for cables
	if ent.EntityMods and ent.EntityMods.EnvDupeInfo then
		if ent.AdminOnly and !Player:IsAdmin() then //stops people from pasting admin only stuff
			ent:Remove()
			Player:ChatPrint("This device is admin only!")
		else
			local DupeInfo = ent.EntityMods.EnvDupeInfo
			if ent.IsNode then
				return
			elseif ent:GetClass() == "env_pump" then
				ent:Setup( DupeInfo.pump, DupeInfo.rate, DupeInfo.hoselength )
			end
			Environments.MakeFunc(ent) --yay
			if DupeInfo.Node then
				local node = CreatedEntities[DupeInfo.Node]
				ent:Link(node, true)
				node:Link(ent, true)
			end
			
			ent.env_extra = DupeInfo.extra
			
			local mat = DupeInfo.LinkMat
			local pos = DupeInfo.LinkPos
			local forward = DupeInfo.LinkForw
			local color = DupeInfo.LinkColor
			if mat and pos and forward then
				Environments.Create_Beam(ent, pos, forward, mat, color) --make work
			end
			ent.EntityMods.EnvDupeInfo = nil
			
			//set the player/owner
			ent:SetPlayer(Player)
		end
	end
end

function Environments.Create_Beam(ent, localpos, forward, mat, color)
	ent:SetNWVector("CableForward", forward)
	ent:SetNWVector("CablePos", localpos)
	ent:SetNWString("CableMat",  mat)
	if color then
		ent:SetNWVector("CableColor", Vector(color.r or 255, color.g or 255, color.b or 255))
	else
		ent:SetNWVector("CableColor", Vector(255,255,255,255))
	end
end

if SERVER then
	function Environments.RDPlayerUpdate(ply)--CRAPPY!!! FIX!
		for k,ent in pairs(ents.FindByClass("resource_node_env")) do
			for name,tab in pairs(ent.resources) do
				umsg.Start("Env_UpdateResAmt")
					//umsg.Entity(ent)
					umsg.Short(ent:EntIndex())
					name = Environments.Resources[name] or name
					umsg.String(name)
					umsg.Long(tab.value)
				umsg.End()
			end
			for name,amount in pairs(ent.maxresources) do
				umsg.Start("Env_UpdateMaxRes")
					umsg.Short(ent:EntIndex())
					umsg.String(name)
					umsg.Long(amount)
				umsg.End()
			end
		end
		for k,v in pairs(ents.GetAll()) do
			if v and v.node and v.node:IsValid() then
				umsg.Start("Env_SetNodeOnEnt")
					umsg.Short(v:EntIndex())
					umsg.Short(v.node:EntIndex())
				umsg.End()
			end
		end
	end
	hook.Add("PlayerInitialSpawn", "EnvRDPlayerUpdate", Environments.RDPlayerUpdate)
	
	function Environments.DamageLS(ent, dam) 
		if !ent or !ent:IsValid() or !dam then return end
		if ent:GetMaxHealth() == 0 then return end
		dam = math.floor(dam / 2)
		if (ent:Health() > 0) then
			local HP = ent:Health() - dam
			ent:SetHealth( HP )
			if ent:Health() <= (ent:GetMaxHealth() / 2) then
				if ent.Damage then
					ent:Damage()
				end
			end
			
			if ent:Health() <= 0 then
				ent:SetColor(Color(50, 50, 50, 255))
				if ent.Destruct then
					ent:Destruct()
				else
					Environments.LSDestruct( ent, true )
				end
				return
			end
			
			local health = ent:Health()
			local max = ent:GetMaxHealth()
			if health <= max/7 then
				ent:SetColor(Color(75,75,75,255))
			elseif health <= max/6 then
				ent:SetColor(Color(100,100,100,255))
			elseif health <= max/5 then
				ent:SetColor(Color(125,125,125,255))
			elseif health <= max/4 then
				ent:SetColor(Color(150,150,150,255))
			elseif health <= max/3 then
				ent:SetColor(Color(175,175,175,255))
			elseif health <= max/2 then
				ent:SetColor(Color(200,200,200,255))
			end
		end
	end
	
	function Environments.ZapMe(pos, magnitude)
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
	
	function Environments.LSDestruct( ent, Simple )
		if Simple then
			Explode2( ent )
		else
			timer.Simple(1, function() Explode1( ent) end)
			timer.Simple(1.2, function() Explode1( ent) end)
			timer.Simple(2, function() Explode1( ent) end)
			timer.Simple(2,function()  Explode2( ent) end)
		end
	end
	
	function Explode1( ent )
		if ent:IsValid() then
			local Effect = EffectData()
				Effect:SetOrigin(ent:GetPos() + Vector( math.random(-60, 60), math.random(-60, 60), math.random(-60, 60) ))
				Effect:SetScale(1)
				Effect:SetMagnitude(25)
			util.Effect("Explosion", Effect, true, true)
		end
	end

	function Explode2( ent )
		if ent:IsValid() then
			local Effect = EffectData()
				Effect:SetOrigin(ent:GetPos())
				Effect:SetScale(3)
				Effect:SetMagnitude(100)
			util.Effect("Explosion", Effect, true, true)
			ent:Remove()
		end
	end
end
