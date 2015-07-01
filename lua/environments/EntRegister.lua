/*                        Environments Life Support System SDK
Environments.RegisterLSStorage(name, class, res, basevolume, basehealth, basemass)
   This function creates a new storage entity and registers its multipliers
	-name: the name of the new storage
	-class: the entity class of the new storage
	-res: a table in the format of {[amt] = "resource"} of the resources stored inside
	-basevolume: the volume used to calculate the multiplier
	-basehealth: the health given to the device at base volume
	-basemass: the mass of the storages at base volume
   
Environments.RegisterTool(name, filename, category, description, cleanupgroup, limit)
   This function creates a new tool.
    -name: this is the name of the tool you are creating
	-filename: this is the technical name of the tool used by the toolgun system
	-category: the name of the subtab the tool is added to
	-description: a description of what the tool does
	-cleanupgroup: the cleanup group used by the tool
	-limit: the max number of devices a user can spawn from this tool/cleanupgroup
   
Environments.RegisterDevice(toolname, genname, devname, class, model, skin, extra)
   This function adds a device to the tool specified with the specified model.
    -toolname: the name of the tool to add the device to
	-genname: the name of the type of generator
	-devname: the actual name of the generator you are adding
	-class: the class of the generator's entity
	-model: the model of the generator
	-skin: a number for its skin (if needed)
	-extra: any extra variable you need to pass on to the ent as ent.env_extra, can be any value
   */
   
local list = list
local scripted_ents = scripted_ents
local table = table
local math = math
local cleanup = cleanup
local language = language
local util = util
local constraint = constraint
local pairs = pairs
local CurTime = CurTime

local Environments = Environments --yay speed boost!

Environments.MakeData = {}

local default = {}
default.basevolume = 4096
default.basehealth = 200
default.basemass = 200
function Environments.MakeFunc(ent)
	local data = ""
	if !Environments.MakeData[ent:GetClass()] then
		ErrorNoHalt("MakeFunc WARNING: No MakeData found for "..ent:GetClass().."! Defaulting!\n") 
		data = default
	else
		data = Environments.MakeData[ent:GetClass()]
	end
	
	local base_volume = data.basevolume
	local volume_mul = 1 //Change to be 0 by default later on
	
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() and phys.GetVolume then
		local vol = phys:GetVolume()
		vol = math.Round(vol)
		volume_mul = vol/base_volume
	end
	
	if data == default then
		volume_mul = 1
	end
	
	if data.resources then
		for k,v in pairs(data.resources) do
			ent:AddResource(v, math.PlaceRound(k*volume_mul, 4))
		end
	end
	
	ent:SetMaxHealth(math.Round(data.basehealth*volume_mul))
	ent:SetHealth(math.Round(data.basehealth*volume_mul))
	
	ent:SetSizeMultiplier(volume_mul)
	
	ent:GetPhysicsObject():SetMass(math.Round(data.basemass*volume_mul))
end

local log10 = math.log(10) --yay for optimization
function math.PlaceRound(num, sigfigs)
	local pow = math.ceil(math.log(num)/log10) 
	return math.Round(num, -(pow - sigfigs)) 
end

/*GENERATOR_1_TO_1 = 1
GENERATOR_2_TO_1 = 2
GENERATOR_1_TO_2 = 3
function GetGenerateFunc(type, res1, res2, res3)
	if type == 1 then
		CompileString([[func = function(self)
			local mult = self:GetSizeMultiplier() 
			local amt = self:ConsumeResource(]]..res1..[[, 200) 
			amt = self:ConsumeResource(]]..res2..[[,amt*1.5)  
			self:SupplyResource(]]..res3..[[, amt)
		end]], "asdadjlkj")()
	elseif type == 2 then
		func = function(self)
		
		end
	end
	return func
end*/

function Environments.RegisterEnt(class, basevolume, basehealth, basemass, res)
	Environments.MakeData[class] = {}
	Environments.MakeData[class].basevolume = basevolume
	if res then
		Environments.MakeData[class].resources = table.Copy(res)
	end
	Environments.MakeData[class].basehealth = basehealth
	Environments.MakeData[class].basemass = basemass
end

Environments.RegisterEnt("generator_fusion", 339933 * 3, 600, 1000)
Environments.RegisterEnt("generator_solar", 1982, 50, 10)
Environments.RegisterEnt("generator_water", 18619, 200, 60)
Environments.RegisterEnt("env_air_compressor", 284267, 600, 200)
Environments.RegisterEnt("generator_water_to_air", 49738, 350, 120)
Environments.RegisterEnt("generator_hydrogen_fuel_cell", 27929, 200, 60)
Environments.RegisterEnt("generator_wind", 64586, 200, 200)

function Environments.RegisterLSEntity(name,class,In,Out,generatefunc,basevolume,basehealth,basemass) --simple quick entity creation
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_env_entity"
	ENT.PrintName = name
	
	list.Set( "LSEntOverlayText" , class, {HasOOO = true, resnames = In, genresnames = Out} )
	
	if SERVER then
		function ENT:Initialize()
			self.BaseClass.Initialize(self)
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )
			self.Active = 0
			self.multiplier = 1
			if WireAddon then
				self.WireDebugName = self.PrintName
				self.Inputs = WireLib.CreateInputs(self, { "On", "Multiplier" })
				self.Outputs = WireLib.CreateOutputs(self, { "On" })
			end
		end
		
		function ENT:TurnOn()
			if self.Active == 0 then
				self.Active = 1
				self:SetOOO(1)
				if WireLib then 
					WireLib.TriggerOutput(self, "On", 1)
				end
			end
		end
		
		function ENT:TriggerInput(iname, value)
			if iname == "On" then
				if value > 0 then
					if self.Active == 0 then
						self:TurnOn()
					end
				else
					if self.Active == 1 then
						self:TurnOff()
					end
				end
			elseif iname == "Multiplier" then
				if value > 0 then
					self:SetMultiplier(value)
				else
					self:SetMultiplier(1)
				end
			end
		end

		function ENT:TurnOff()
			if self.Active == 1 then
				self.Active = 0
				self:SetOOO(0)
				if WireLib then 
					WireLib.TriggerOutput(self, "On", 0)
				end
			end
		end

		function ENT:SetActive(value)
			if not (value == nil) then
				if (value != 0 and self.Active == 0 ) then
					self:TurnOn()
				elseif (value == 0 and self.Active == 1 ) then
					self:TurnOff()
				end
			else
				if ( self.Active == 0 ) then
					self:TurnOn()
				else
					self:TurnOff()
				end
			end
		end
		
		ENT.Generate = generatefunc

		function ENT:Think()
			if self.Active == 1 then
				self:Generate()
			end
			
			self:NextThink(CurTime() + 1)
			return true
		end
	else
		--client
	end
	
	scripted_ents.Register(ENT, class, true, true)
	Environments.MakeData[class] = {}
	Environments.MakeData[class].basevolume = basevolume
	Environments.MakeData[class].basehealth = basehealth
	Environments.MakeData[class].basemass = basemass
	print("Entity Registered: "..class)
end

function Environments.RegisterLSStorage(name, class, res, basevolume, basehealth, basemass) --in process of adding venting
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_env_storage"
	ENT.PrintName = name
	
	list.Set( "LSEntOverlayText", class, {HasOOO = false, resnames = res} )
	
	if SERVER then
		function ENT:Initialize()
			self.BaseClass.Initialize(self)
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )
			self.damaged = 0
			self.res = res
			self.ventamt = 1000
			if WireAddon then
				self.WireDebugName = self.PrintName
				self.Inputs = WireLib.CreateInputs(self, { "Vent", "Vent Amount" })

				local tab = {}
				local i = 1
				for k,res in pairs(self.res) do
					local v = self.res[i]
					tab[i] = res
					tab[i+1] = "Max "..res
					i = i + 2
				end
				//PrintTable(tab)
				self.Outputs = Wire_CreateOutputs(self, tab)
			end
		end
		
		function ENT:AddResource(name,amt)--adds to storage
			if not self.maxresources then self.maxresources = {} end
			self.maxresources[name] = (self.maxresources[name] or 0) + amt
		end

		function ENT:Damage()
			if (self.damaged == 0) then self.damaged = 1 end
		end
		
		function ENT:TriggerInput(iname, value)
			if iname == "Vent" then
				if value > 0 then
					self.Vent = 1
				else
					self.Vent = 0
				end
			elseif iname == "Vent Amount" then
				if value > 0 then
					self.ventamt = value
				else
					self.ventamt = 1000
				end
			end
		end
		
		function ENT:OnRemove()
			if self.environment then
				for v,k in pairs(self.res) do
					if k == "oxygen" or k == "nitrogen" or k == "hydrogen" or k == "carbon dioxide" then
						self.environment:Convert(nil, k, self:GetResourceAmount(k) or self.resources[k])
					end
				end
			end
			self.BaseClass.OnRemove(self)
		end
		
		function ENT:Think()
			if self.Vent == 1 and self.environment then
				if self.node then
					for v,k in pairs(self.res) do
						if k == "oxygen" then
							local amt = self:ConsumeResource(k, self.ventamt)
							self.environment:Convert(nil, "o2", amt)
						elseif k == "nitrogen" then
							local amt = self:ConsumeResource(k, self.ventamt)
							self.environment:Convert(nil, "n", amt)
						elseif k == "hydrogen" then
							local amt = self:ConsumeResource(k, self.ventamt)
							self.environment:Convert(nil, "h", amt)
						elseif k == "carbon dioxide" then
							local amt = self:ConsumeResource(k, self.ventamt)
							self.environment:Convert(nil, "co2", amt)
						end
					end
				else --no node
					--for k,v in pairs(self.maxresources) do
						--if k == "oxygen" then
							--self.environment:Convert(nil, k, self:GetResourceAmount(k) or self.resources[k])
						--end
					--end
				end
			end
			
			if WireAddon then
				for k,v in pairs(self.res) do
					Wire_TriggerOutput(self, v, self:GetResourceAmount(v))
					Wire_TriggerOutput(self, "Max "..v, self:GetNetworkCapacity(v))
				end
			end
			
			self:NextThink(CurTime() + 1)
			return true
		end
	else
	
	end
	
	scripted_ents.Register(ENT, class, true, true)
	Environments.MakeData[class] = {}
	Environments.MakeData[class].basevolume = basevolume
	Environments.MakeData[class].resources = table.Copy(res)
	Environments.MakeData[class].basehealth = basehealth
	Environments.MakeData[class].basemass = basemass
	print("Storage Registered: "..class)
end

function Environments.RegisterTool(name, filename, category, description, cleanupgroup, limit)//add descriptions for devices
	local TOOL = ToolObj:Create()
	
	TOOL.Mode = filename
	TOOL.Name = name
	TOOL.Tab = "Environments"
	
	TOOL.Category = category
	TOOL.AddToMenu = true
	TOOL.Description = description
	TOOL.Command = nil
	TOOL.ConfigName = ""
	
	TOOL.ClientConVar[ "model" ] = " "
	TOOL.ClientConVar[ "type" ] = " "
	TOOL.ClientConVar[ "sub_type" ] = " "
	TOOL.ClientConVar[ "Weld" ] = 1
	TOOL.ClientConVar[ "NoCollide" ] = 0
	TOOL.ClientConVar[ "Freeze" ] = 1
	
	TOOL.CleanupGroup = cleanupgroup

	TOOL.Entity = {
		Angle=Angle(90,0,0), -- Angle offset?
		Keys={}, -- These keys will be saved by the duplicator on a copy, NOT!
		Class=class, -- Default SENT to spawn
		Limit=limit or 20, -- Limits?
	};

	TOOL.Topic = {}
	TOOL.Language = {}
	
	TOOL.Language["Undone"] = cleanupgroup.." Removed"
	TOOL.Language["Cleanup"] = cleanupgroup
	TOOL.Language["Cleaned"] = "Removed all "..cleanupgroup
	TOOL.Language["SBoxLimit"] = "Hit the "..cleanupgroup.." limit"

	function TOOL:Register()
		-- Register language clientside
		if self.Language["Cleanup"] then
			cleanup.Register(self.CleanupGroup)
		end
		if CLIENT then
			//Yay, simplified titles
			language.Add( "tool."..self.Mode..".name", self.Name )
			language.Add( "tool."..self.Mode..".desc", self.Description )
			language.Add( "tool."..self.Mode..".0", "Primary: Spawn a Device. Reload: Repair a Device." )
			
			for k,v in pairs(self.Language) do
				language.Add(k.."_"..self.CleanupGroup,v)
			end
		else
			CreateConVar("sbox_max"..self.CleanupGroup,self.Entity.Limit)
		end
	end

	function TOOL:GetDeviceModel()
		local mdl = self:GetClientInfo("model")

		return mdl
	end
	
	function TOOL:GetDeviceClass()
		if Environments.Tooldata[self.Name][self:GetClientInfo("type")] then
			if Environments.Tooldata[self.Name][self:GetClientInfo("type")][self:GetClientInfo("sub_type")] then
				return Environments.Tooldata[self.Name][self:GetClientInfo("type")][self:GetClientInfo("sub_type")].class
			end
		end
	end
	
	function TOOL:GetDeviceInfo()
		local tool = Environments.Tooldata[self.Name]
		if tool then
			local Type = tool[self:GetClientInfo("type")]
			if Type then
				return Type[self:GetClientInfo("sub_type")] or {}
			end
		end
		return {}
	end

	if SERVER then
		function TOOL:CreateDevice(ply, trace, Model, class)
			if !ply:CheckLimit(self.CleanupGroup) then return end
			if !class then return end
			local ent = ents.Create(class)
			if !ent:IsValid() then return end
			
			local info = self:GetDeviceInfo()
			
			-- Pos/Model/Angle
			ent:SetModel( Model )
			ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )
			ent:SetAngles( trace.HitNormal:Angle() + self.Entity.Angle )

			ent:SetPlayer(ply)
			ent:Spawn()
			ent:Activate()
			ent:GetPhysicsObject():Wake()
			
			if info.skin then
				ent:SetSkin(info.skin)
			end
			
			if info.extra then
				ent.env_extra = info.extra
			end
			
			print("Ent Created: Volume: "..ent:GetPhysicsObject():GetVolume())
			
			Environments.MakeFunc(ent)
			
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
			local ent = self:CreateDevice( ply, trace, model, self:GetDeviceClass() )
			--	LDE.UnlockCreateCheck(ply,ent) --Check if unlocked!
			if !ent or !ent:IsValid() then return end
			
			if ent.AdminOnly then
				if !ply:IsAdmin() then
					ent:Remove()
					ply:ChatPrint("This device is admin only!")
				end
			end
			
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
			return
		end
		
		function TOOL:Reload(trace)
			if trace.Entity and trace.Entity:IsValid() then
				if trace.Entity.Repair then
					trace.Entity:Repair()
					self:GetOwner():ChatPrint("Device Repaired!")
					return true
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
			local name = self:GetClientInfo("sub_type")
			undo.SetCustomUndoText("Undone "..name)
			undo.Finish(name)
		end
	end

	if SinglePlayer() and SERVER or !SinglePlayer() and CLIENT then
		// Ghosts, scary
		function TOOL:UpdateGhostEntity( ent, player )
			if !ent or !ent:IsValid() then return end
			local trace = player:GetEyeTrace()
			
			if trace.HitNonWorld then
				if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then
					ent:SetNoDraw( true )
					return
				end
			end
				
			ent:SetAngles( trace.HitNormal:Angle() + self.Entity.Angle )
			ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )
				
			ent:SetNoDraw( false )
		end
			
		function TOOL:Think()
			local model = self:GetDeviceModel()
			if model then
				if !self.GhostEntity or !self.GhostEntity:IsValid() or self.GhostEntity:GetModel() != model then
					local trace = self:GetOwner():GetEyeTrace()
					self:MakeGhostEntity( model, trace.HitPos, trace.HitNormal:Angle() + self.Entity.Angle, self:GetDeviceInfo().skin )
				end
			end
			self:UpdateGhostEntity( self.GhostEntity, self:GetOwner() )
		end
		
		function TOOL:MakeGhostEntity( model, pos, angle, skin ) --why do you spam so?
			// Don't allow ragdolls/effects to be ghosts
			if !model or model == " " or model == "" then return end
			
			// Release the old ghost entity
			self:ReleaseGhostEntity()
			
			if CLIENT and ents.CreateClientProp then
				self.GhostEntity = ents.CreateClientProp( model )
			else
				self.GhostEntity = ents.Create( "prop_physics" )
			end
			
			// If there's too many entities we might not spawn..
			if !self.GhostEntity:IsValid() then
				self.GhostEntity = nil
				return
			end
			
			self.GhostEntity:SetModel( model )
			self.GhostEntity:SetPos( pos )
			self.GhostEntity:SetAngles( angle )
			self.GhostEntity:Spawn()
			if skin then self.GhostEntity:SetSkin(skin) end
			
			self.GhostEntity:SetSolid( SOLID_VPHYSICS )
			self.GhostEntity:SetMoveType( MOVETYPE_NONE )
			self.GhostEntity:SetNotSolid( true )
			self.GhostEntity:SetRenderMode( RENDERMODE_TRANSALPHA )
			self.GhostEntity:SetColor( Color( 255, 255, 255, 150 ))
		end
	end
	
	local name = TOOL.Mode
	
	local self = TOOL
	function TOOL.BuildCPanel( CPanel )
		-- Header stuff
		CPanel:ClearControls()
		--CPanel:AddHeader()
		--CPanel:AddDefaultControls()
		CPanel:AddControl("Header", { Text = "#tool."..name..".name", Description = "#tool."..name..".desc" })
		
		local list = vgui.Create( "DPanelList" )
		list:SetTall( 400 )
		list:SetPadding( 1 )
		list:SetSpacing( 1 )
		list:EnableVerticalScrollbar(true)
		
		local ccv_type		= self.Mode.."_type"
		local ccv_sub_type	= self.Mode.."_sub_type"
		local ccv_model 	= self.Mode.."_model"
			
		local cur_type		= GetConVarString(ccv_type)
		local cur_sub_type	= GetConVarString(ccv_sub_type)
		local cur_model	 	= GetConVarString(ccv_model)
		
		for cat,tab in pairs(Environments.Tooldata[self.Name]) do
			local c = vgui.Create("DCollapsibleCategory")
			c:SetLabel(cat)
			c:SetExpanded(false)
			
			local CategoryList = vgui.Create( "DPanelList" )
			CategoryList:SetAutoSize( true )
			CategoryList:SetSpacing( 6 )
			CategoryList:SetPadding( 3 )
			CategoryList:EnableHorizontal( true )
			CategoryList:EnableVerticalScrollbar( true )
			
			for k,v in pairs(tab) do
				local icon = vgui.Create("SpawnIcon")
				
				util.PrecacheModel(v.model)
				icon:SetModel(v.model, v.skin or 0)
				icon.tool = self
				icon.model = v.model
				icon.class = v.class
				icon.skin = v.skin
				icon.devname = k
				icon.devtype = cat
				icon.description = v.description
				if v.tooltip then
					icon:SetTooltip(v.tooltip)
				else
					icon:SetTooltip(k)
				end
				icon.DoClick = function(self)
					self.tool.Model = self.model
					self.tool.description_label:SetText(icon.description or icon.devname)
					RunConsoleCommand( ccv_type, self.devtype )
					RunConsoleCommand( ccv_sub_type, self.devname )
					RunConsoleCommand( ccv_model, self.model )
				end
				
				CategoryList:AddItem(icon)
			end
			
			c:SetContents(CategoryList)
			list:AddItem(c)
		end
		CPanel:AddPanel(list)
		
		TOOL.description_label = CPanel:AddControl( "Label", { Text = "Hello World!" }  )//vgui.Create("DButton")
		TOOL.description_label:SetText("description goes here")

		CPanel:AddControl("CheckBox", { Label = "Weld", Command = name.."_Weld" })
		CPanel:AddControl("CheckBox", { Label = "Nocollide", Command = name.."_NoCollide" })
		CPanel:AddControl("CheckBox", { Label = "Freeze", Command = name.."_Freeze" })
	end
	
	TOOL:Register()

	TOOL:CreateConVars()
	SWEP.Tool[ name ] = TOOL --inject into stool
end

Environments.Tooldata = {}
function Environments.RegisterDevice(toolname, genname, devname, class, model, skin, extra, description, tooltip)
	if !Environments.Tooldata[toolname] then
		Environments.Tooldata[toolname] = {}
	end
	local dat = Environments.Tooldata[toolname]
	
	if !dat[genname] then
		dat[genname] = {}
	end
	dat[genname][devname] = {}
	dat[genname][devname].model = string.lower(model)//prevents crashes
	dat[genname][devname].class = class
	dat[genname][devname].skin = skin
	dat[genname][devname].extra = extra
	dat[genname][devname].description = description
	dat[genname][devname].tooltip = tooltip
end

hook.Add("AddTools", "environments tool hax", function()
	Environments.RegisterTool("Generators", "Energy_Gens", "Life Support", "Used to spawn various LS devices", "generator", 30)
	Environments.RegisterTool("Storages", "Storage_Tanks", "Life Support", "Used to spawn various resource storages", "storage", 20)
	Environments.RegisterTool("Life Support", "Life_Support", "Life Support", "Used to spawn various devices designed to keep you alive in space.", "lifesupport", 15)
end)

