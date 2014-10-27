AddCSLuaFile( "envx_clonetube.lua" )

ENT.Type 			= "anim"
ENT.Base 			= "base_env_entity"
ENT.PrintName			= "Cloning Machine"
ENT.Author			= "Ludsoe"

ENT.Spawnable			= true
ENT.AdminSpawnable		= true
ENT.NoEnvPanel			= true
ENT.PointCost			= 3000

list.Set( "LSEntOverlayText" , "envx_clonetube", {HasOOO = true ,resnames = {"energy","Carbon","water"}, genresnames={}} )

if(SERVER)then
	function ENT:Initialize()
		self:SetModel("models/TwinbladeTM/cryotubemkii.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
	end

	function ENT:Use(activator, caller)
		if(self.HasPoints)then
			if activator.SpawnPoint and activator.SpawnPoint == self then
				activator.SpawnPoint = nil
				activator:PrintMessage(4, "Spawn point reset.")
			else
				activator.SpawnPoint = self
				activator:PrintMessage(4, "Spawn point set.")
				
				self:EmitSound( "fvox/vitalsigns_on.wav" )
			end
		else
			activator:PrintMessage(4, "SpawnPoint Not valid. Link a core with 3000 points.")
		end
	end 

	local function SpawnerHook(pl)
		if pl.SpawnPoint and pl.SpawnPoint:IsValid() then 
			local Ent = pl.SpawnPoint
			if(Ent.HasPoints)then
				pl:SetPos(pl.SpawnPoint:LocalToWorld(Vector(50,0,16)))
				local ed = EffectData()
				ed:SetEntity(pl)
				ed:SetScale(5)
				util.Effect("PlayerSpawnEffect", ed, true, true)
				pl:EmitSound( "fvox/medical_repaired.wav" )
			end
		end
	end
	hook.Add("PlayerSpawn", "SpawnerHook", SpawnerHook) 
end		
