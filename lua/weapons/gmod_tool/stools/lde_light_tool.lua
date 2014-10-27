
TOOL.Tab = "Environments"
TOOL.Category = "Life Support"
TOOL.Name = "Powered Lamps"
TOOL.Description = "Used to spawn Powered Lamps"
TOOL.AddToMenu = true -- Tell gmod not to add it. We will do it manually later!
TOOL.Description = ""
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.ClientConVar[ "model" ] = "models/ce_ls3additional/solar_generator/solar_generator_giant.mdl"
TOOL.ClientConVar[ "Weld" ] = 1
TOOL.ClientConVar[ "NoCollide" ] = 0
TOOL.ClientConVar[ "Freeze" ] = 1
TOOL.ClientConVar[ "Red"] = 255
TOOL.ClientConVar[ "Blue"] = 255
TOOL.ClientConVar[ "Green"] = 255
TOOL.ClientConVar[ "LightSpread"] = 30

TOOL.CleanupGroup = "ldelights"

TOOL.Entity = {
	Angle=Angle(90,0,0), -- Angle offset?
	Keys={}, -- These keys will be saved by the duplicator on a copy, NOT!
	Class="prop_physics", -- Default SENT to spawn
	Limit=1000, -- Limits?
};

TOOL.Topic = {}
TOOL.Language = {}
TOOL.Models = { 	
["models/props_wasteland/light_spotlight01_lamp.mdl"] = {},
["models/Slyfo/searchlight.mdl"] = {},
["models/props_wasteland/prison_cagedlight001a.mdl"] = {} 		
}
					
local Models = TOOL.Models --fixes stuph		

TOOL.Entity.Class = "lifesupport_lamp";
TOOL.Entity.Keys = 0
TOOL.Entity.Limit = 40
TOOL.Entity.Angle = Angle(90,0,0)
local name = TOOL.Mode

TOOL.CleanupGroup = "environmentslamp" --sets what this things count adds from
TOOL.Language["Undone"] = "Powered Lamp Undone";
TOOL.Language["Cleanup"] = "Powered Lamp";
TOOL.Language["Cleaned"] = "Removed all Powered Lamp";
TOOL.Language["SBoxLimit"] = "Hit the Powered Lamp limit";

function TOOL.BuildCPanel( CPanel )
	-- Header stuff
	CPanel:ClearControls()
	CPanel:AddControl("Header", { Text = "#tool."..name..".name", Description = "#tool."..name..".desc" })
	
	CPanel:AddControl( "PropSelect", {
		Label = "#Lamp Models",
		ConVar = name.."_model",
		Category = "Lamps",
		Models = Models
	})
	
	CPanel:AddControl("CheckBox", { Label = "Weld", Command = name.."_Weld" })
	CPanel:AddControl("CheckBox", { Label = "Nocollide", Command = name.."_NoCollide" })
	CPanel:AddControl("CheckBox", { Label = "Freeze", Command = name.."_Freeze" })
	CPanel:AddControl( "Slider", {Label = "Light Angle:",Type = "Float",Min = "1",Max = "300",Command	= name.."_LightSpread" }  )
	CPanel:AddControl( "Slider", {Label = "Red:",Type = "Float",Min = "0",Max = "255",Command	= name.."_Red" }  )
	CPanel:AddControl( "Slider", {Label = "Blue:",Type = "Float",Min = "0",Max = "255",Command	= name.."_Blue" }  )
	CPanel:AddControl( "Slider", {Label = "Green:",Type = "Float",Min = "0",Max = "255",Command	= name.."_Green" }  )
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
		local ent = ents.Create( self.Class )
		if !ent:IsValid() then return end
			
		-- Pos/Model/Angle
		ent:SetModel( Model )
		ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )
		ent:SetAngles( trace.HitNormal:Angle() + self.Angle )
		ent:SetPlayer(ply)
		ent:Spawn()
		ent:Activate()
		local Data = {LightRed=self:GetClientInfo("Red"),LightBlue=self:GetClientInfo("Blue"),LightGreen=self:GetClientInfo("Green"),FOV=self:GetClientInfo("LightSpread")}
		ent.LightData=Data
		
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

function TOOL:Register()
	local class = self.Class -- Quick reference
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

TOOL:Register()