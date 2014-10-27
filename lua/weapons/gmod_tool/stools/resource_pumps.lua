
TOOL.Category = "Tools"
TOOL.Name = "Resource Pumps"
TOOL.ClientConVar[ "model" ] = "models/props_lab/tpplugholder_single.mdl"
TOOL.ClientConVar[ "Weld" ] = 1
TOOL.ClientConVar[ "AllowWorldWeld" ] = 0
TOOL.ClientConVar[ "NoCollide" ] = 0
TOOL.ClientConVar[ "Freeze" ] = 1
TOOL.ClientConVar[ "Rate" ] = 256

TOOL.Tab = "Environments"

local EntityName = "env_pump"
local toolname = "resource_pumps"
local offset = Vector(0,0,0)//Vector(-12, 13, 0)

cleanup.Register("generators")

local GenModels = { 	["models/props_lab/tpplugholder_single.mdl"] = {} }


-- This needs to be shared...
function TOOL:GetDeviceModel()
	local mdl = self:GetClientInfo("model")
	if (!util.IsValidModel(mdl) or !util.IsValidProp(mdl)) then return "models/props_lab/tpplugholder_single.mdl" end
	return mdl
end

if (SERVER) then
	CreateConVar("sbox_maxpump", 6)
	
	function TOOL:CreateDevice(ply, trace, Model)
		if (!ply:CheckLimit("pump")) then return end
		local ent = ents.Create( EntityName )
		if (!ent:IsValid()) then return end
		
		-- Pos/Model/Angle
		ent:SetModel( Model )
		ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z)
		ent:SetAngles( trace.HitNormal:Angle() )
		ent:SetPlayer(ply)
		ent:Spawn()
		ent:Activate()
		--pump  rate  length
		ent:Setup(1,tonumber(self:GetClientInfo("Rate")),1024)
		return ent
	end
	
	function TOOL:LeftClick( trace )
		if (!trace) then return end
		local ply = self:GetOwner()
		local traceent = trace.Entity
		
		-- Get the model
		local model = self:GetDeviceModel()
		if (!model) then return end

		-- else create a new one
			
		local ent = self:CreateDevice( ply, trace, model )
		if (!ent or !ent:IsValid()) then return end
		local phys = ent:GetPhysicsObject()
		if (!traceent:IsWorld() and !traceent:IsPlayer()) then
			if self:GetClientInfo("Weld") == "1" then
				local weld = constraint.Weld( ent, trace.Entity, 0, trace.PhysicsBone, 0 )
			end
			if self:GetClientInfo("NoCollide") == "1" then
				local nocollide = constraint.NoCollide( ent, trace.Entity, 0, trace.PhysicsBone )
			end
		end
		if self:GetClientInfo("Freeze") == "1" then
			phys:EnableMotion( false ) 
			ply:AddFrozenPhysicsObject( ent, phys )
		end
				
		ply:AddCount( "pump", ent)
		ply:AddCleanup( "pump", ent )

		undo.Create( "pump" )
			undo.AddEntity( ent )
			if weld then
				undo.AddEntity( weld )
			end
			if nocollide then
				undo.AddEntity( nocollide )
			end
			undo.SetPlayer( ply )
		undo.Finish()
			
		return true
	end
	
	function TOOL:RightClick( trace )
		if (!trace) then return end
		local ply = self:GetOwner()
		
		-- Get the model
		local model = self:GetDeviceModel()
		if (!model) then return end

		-- If the trace hit an entity
		local traceent = trace.Entity
		if (traceent and traceent:IsValid() and traceent.Repair) then
			traceent:Repair()
		end
	end
else
	language.Add( "tool."..toolname..".name", "Resource Pumps" )
	language.Add( "tool."..toolname..".desc", "Used to spawn resource pumps." )
	language.Add( "tool."..toolname..".0", "Primary: Spawn a Resource Pump" )
	language.Add( "undone_pump", "Undone Pump" )
	language.Add( "Cleanup_pump", "Pumps" )
	language.Add( "Cleaned_pump", "Cleaned up all Pumps" )
	language.Add( "SBoxLimit_pump", "You've reached the pump limit!" )
	
	
	function TOOL.BuildCPanel( CPanel )
		-- Header stuff
		CPanel:ClearControls()

		CPanel:AddControl("Header", { Text = "#tool.resource_pumps.name", Description = "#tool.resource_pumps.desc" })
		
		CPanel:AddControl("ComboBox", {
			Label = "#Presets",
			MenuButton = "1",
			Folder = "Storages",

			Options = {
				Default = {
					resource_pumps_model = "models/props_lab/tpplugholder_single.mdl",
				}
			},

			CVars = {
				[0] = "resource_pumps_model",
			}
		})
		
		CPanel:AddControl("Slider", {Label = "Rate",Type = "Float",Min = "0",Max = "1024",Command = toolname.."_Rate"})
		
		CPanel:AddControl("PropSelect", {
			Label = "#Models",
			ConVar = toolname.."_model",
			Category = "Storages",
			Models = GenModels
		})
		CPanel:AddControl("CheckBox", { Label = "Weld", Command = toolname.."_Weld" })
		CPanel:AddControl("CheckBox", { Label = "Nocollide", Command = toolname.."_NoCollide" })
		CPanel:AddControl("CheckBox", { Label = "Freeze", Command = toolname.."_Freeze" })
	end

	-- Ghost functions (Thanks to Grocel for making the base. I changed it a bit)
	function TOOL:UpdateGhostCannon( ent, player )
		if (!ent or !ent:IsValid()) then return end
		local trace = player:GetEyeTrace()
		
		ent:SetAngles( trace.HitNormal:Angle() )
		ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z - offset )
		
		ent:SetNoDraw( false )
	end
	
	function TOOL:Think()
		local model = self:GetDeviceModel()
		if (!self.GhostEntity or !self.GhostEntity:IsValid() or self.GhostEntity:GetModel() != model) then
			local trace = self:GetOwner():GetEyeTrace()
			self:MakeGhostEntity( Model(model), trace.HitPos - offset, trace.HitNormal:Angle())
		end
		self:UpdateGhostCannon( self.GhostEntity, self:GetOwner() )
	end
end