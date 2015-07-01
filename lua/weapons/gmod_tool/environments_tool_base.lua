
TOOL.Tab = "Environments"
TOOL.AddToMenu = true -- Tell gmod not to add it. We will do it manually later!
TOOL.Description = ""
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.ClientConVar[ "model" ] = "models/ce_ls3additional/solar_generator/solar_generator_giant.mdl"
TOOL.ClientConVar[ "Weld" ] = 1
TOOL.ClientConVar[ "NoCollide" ] = 0
TOOL.ClientConVar[ "Freeze" ] = 1

TOOL.CleanupGroup = "generator"

TOOL.Entity = {
	Angle=Angle(90,0,0), -- Angle offset?
	Keys={}, -- These keys will be saved by the duplicator on a copy, NOT!
	Class="prop_physics", -- Default SENT to spawn
	Limit=1000, -- Limits?
};

TOOL.Topic = {}
TOOL.Language = {}
TOOL.Models = {}

function TOOL:Register()
	-- Register language clientside
	local class = self.Entity.Class -- Quick reference
	if(self.Language["Cleanup"]) then
		cleanup.Register(self.CleanupGroup)
	end
	if CLIENT then
		//Yay, simplified titles
		language.Add( "tool."..self.Mode..".name", self.Name )
		language.Add( "tool."..self.Mode..".desc", self.Description )
		language.Add( "tool."..self.Mode..".0", "Primary: Spawn a "..self.Name.. " Secondary: Repair LS Device" )
		
		for k,v in pairs(self.Language) do
			language.Add(k.."_"..self.CleanupGroup,v);
		end
	else
		if(class) then
			CreateConVar("sbox_max"..self.CleanupGroup,self.Entity.Limit);
		end
	end
end

function TOOL:GetDeviceModel()
	local mdl = self:GetClientInfo("model")
	if (!util.IsValidModel(mdl) or !util.IsValidProp(mdl)) then return "models/ce_ls3additional/solar_generator/solar_generator_giant.mdl" end
	return mdl
end

if SERVER then
	function TOOL:GetMults(ent) --filler
		return 1
	end
	
	function TOOL:CreateDevice(ply, trace, Model)
		if !ply:CheckLimit(self.CleanupGroup) then return end
		local ent = ents.Create( self.Entity.Class )
		if !ent:IsValid() then return end
			
		-- Pos/Model/Angle
		ent:SetModel( Model )
		ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )
		ent:SetAngles( trace.HitNormal:Angle() + self.Entity.Angle )

		ent:SetPlayer(ply)
		ent:Spawn()
		ent:Activate()
		ent:GetPhysicsObject():Wake()
			
		local mul = self:GetMults(ent) or 1
		if mul then 
			ent:SetMaxHealth(mul*500)
			ent:SetHealth(mul*500)
		end
		
		return ent
	end

	function TOOL:LeftClick( trace )
		if !trace then return end
		local traceent = trace.Entity
		local ply = self:GetOwner()
			
		-- Get the model
		local model = self:GetDeviceModel()
		if !model then return end
	
		//create it
		local ent = self:CreateDevice( ply, trace, model )
		--	LDE.UnlockCreateCheck(ply,ent) --Check if unlocked!
		if !ent or !ent:IsValid() then return end
		
		//effect :D
		if DoPropSpawnedEffect then
			DoPropSpawnedEffect(ent)
		end
		
		//constraints
		local weld = nil
		local nocollide = nil
		local phys = ent:GetPhysicsObject()
		if (!traceent:IsWorld() and !traceent:IsPlayer()) then
			if self:GetClientInfo("Weld") == "1" then
				weld = constraint.Weld( ent, trace.Entity, 0, trace.PhysicsBone, 0 )
			end
			if self:GetClientInfo("NoCollide") == "1" then
				nocollide = constraint.NoCollide( ent, trace.Entity, 0, trace.PhysicsBone )
			end
		end
		if self:GetClientInfo("Freeze") == "1" then
			phys:EnableMotion( false ) 
			ply:AddFrozenPhysicsObject( ent, phys )
		end
		
		//Counts and undos
		ply:AddCount( self.CleanupGroup, ent)
		ply:AddCleanup( self.CleanupGroup, ent )

		self:AddUndo(ply, ent, weld, nocollide)

		return true
	end
	
	function TOOL:RightClick( trace )
		if !trace then return end
		if trace.Entity and trace.Entity:IsValid() then
			if trace.Entity.Repair then
				trace.Entity:Repair()
				self:GetOwner():ChatPrint("Device Repaired!")
			end
		end
	end
	
	//Cleanups and stuff
	function TOOL:AddUndo(p,...)
		undo.Create(self.CleanupGroup)
		for k,v in pairs({...}) do
			if(k ~= "n") then
				undo.AddEntity(v)
			end
		end
		undo.SetPlayer(p)
		undo.Finish()
	end
end

if SinglePlayer() and SERVER or !SinglePlayer() and CLIENT then
	// Ghosts, scary
	function TOOL:UpdateGhostEntity( ent, player )
		if !ent or !ent:IsValid() then return end
		local trace = player:GetEyeTrace()
			
		ent:SetAngles( trace.HitNormal:Angle() + self.Entity.Angle )
		ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )
			
		ent:SetNoDraw( false )
	end
		
	function TOOL:Think()
		local model = self:GetDeviceModel()
		if !self.GhostEntity or !self.GhostEntity:IsValid() or self.GhostEntity:GetModel() != model then
			local trace = self:GetOwner():GetEyeTrace()
			self:MakeGhostEntity( Model(model), trace.HitPos, trace.HitNormal:Angle() + self.Entity.Angle )
		end
		self:UpdateGhostEntity( self.GhostEntity, self:GetOwner() )
	end
end

