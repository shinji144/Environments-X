------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

ENT.Base                = "base_brush"
ENT.Type                = "brush"
ENT.Debugging   		= true
ENT.Enabled             = true

include("core/base.lua")

//fixes stargate stuff
ENT.IgnoreStaff = true
ENT.IgnoreTouch = true
ENT.NotTeleportable = true

function ENT:Initialize()
	if not self.Initialized then
		self:InitEnvBrush()
	end

	if Init_Debugging_Override or self.Debugging then
		Msg("Initialized a new brush env: ", self, "\n")
		Msg("ID is: ", self.name, "\n")
	end
end

function ENT:StartTouch(ent)
	if not ent:GetPhysicsObject():IsValid() then return end	--only physics stuff 
	if ent:GetClass() == "func_door" or ent:IsWorld() then return end --no world stuff
	
	if ent.NoGrav then return end --let missiles,ect do their thang
	
	if not self.Enabled then 
		if self.Debugging then Msg("Entity ", ent, " tried to enter but ", self.name, " wasn't on.\n") end
		
		return
	elseif self.Debugging then 
		Msg("Entity ", ent, " has started touching ", self.name, " in unusual places....\n")
	end
	
	self.Entities[ent:EntIndex()] = ent
	//Set Planet
	ent:SetGravity( self.gravity )
	ent:GetPhysicsObject():EnableDrag( true )
	ent:GetPhysicsObject():EnableGravity( true )
	ent.environment = self
	if( ent:IsPlayer() ) then
		ent:SetNWBool( "inspace", false )
	end
end

function ENT:EndTouch(ent)
	if ent:IsWorld() then return end
	
	if self.Debugging then
		Msg("Entity ", ent, " has stopped touching ", self.name, " in unusual places....\n")
	end
	
	self.Entities[ent:EntIndex()] = nil

	if not ent:GetPhysicsObject():IsValid() then return end

	if ent.environment == self then
		if ent:IsPlayer() then
			ent:SetGravity( 0.00001 )
			if GetConVarNumber("env_noclip") != 1 then
				if not ent:IsAdmin() then
					ent:SetMoveType( MOVETYPE_WALK )
					if math.abs(ent:GetVelocity():Length()) > 50 then
						ent:SetLocalVelocity(Vector(0,0,0))
					end
				end
			end
			
			ent:SetNWBool( "inspace", true )
		else
			ent:GetPhysicsObject():EnableDrag( false )
			ent:GetPhysicsObject():EnableGravity( false )
		end
		if not ent.NoSpaceAfterEndTouch then
			ent.environment = Space()
		end
		if self.Debugging then Msg("...and has decided to get spaced.\n") end
	else
		--if self.Debugging then Msg("...and has decided to not get spaced.\n") end
	end
end

function ENT:AcceptInput(name, activator, caller, data)
	print("INPUT ACCEPTED")
	if not self.Initialized then
		self:InitEnvBrush()
	end
        
	if name == "SpaceEnv" then
		self:Space()

		return true
	elseif name == "RestoreEnv" then
		self.Enabled = true
 
		return true
	elseif name == "SetPressure" then
		if not (data and (type(data) == "number")) then return Error("Invalid parameter for new pressure in env brush ID" .. self.ID .. "\n") end
                
		if data < 0 then
			data = 0
		elseif data > 1 then
			data = 1
		end

		if self.atmosphere ~= 0 then
			self.pressure = self.pressure * (data / self.atmosphere)
		else
			self.pressure = self.pressure * data
		end
                
		if data > self.sbenvironment.atmosphere then
			local tmp = self.sbenvironment.air.max - (self.sbenvironment.air.o2 + self.sbenvironment.air.co2 + self.sbenvironment.air.n + self.sbenvironment.air.h)

			self.sbenvironment.air.max = math.Round(100 * data * 5)

			self.sbenvironment.air.empty = tmp
			self.sbenvironment.air.emptyper = self:GetOtherGasPercentage()
		else
			self.sbenvironment.air.o2               = math.Round(self:GetO2Percentage() * data * 5)
			self.sbenvironment.air.co2              = math.Round(self:GetCO2Percentage() * data * 5)
			self.sbenvironment.air.n                = math.Round(self:GetNPercentage() * data * 5)
			self.sbenvironment.air.h                = math.Round(self:GetHPercentage() * data * 5)
			self.sbenvironment.air.empty    		= math.Round(self:GetOtherGasPercentage() * data * 5)
			self.sbenvironment.air.max              = math.Round(100 * data * 5)
		end
  
		self.atmosphere = data

		return true
	elseif name == "SetTemp" then
		self.temperature = tonumber(data)
		
		return true
	elseif name == "SetGravity" then
		if (not data) and (type(data) == "number") then return Error("Invalid parameter for new gravity in env brush ID" .. self.ID .. "\n") end
		print("Gravity Set: "..data)
		if self.gravity ~= 0 then
			self.pressure = self.pressure * (data/self.gravity)
		else
			self.pressure = self.pressure * newgravityz
		end
  
		self.gravity = data
		
		if self.Entities then
			for k,v in pairs(self.Entities) do
				v:SetGravity(data)
				
				if v:IsPlayer() and data == 0 then
					v:SetGravity(0.00001)
				end
			end
		end

		return true
	elseif name == "SetUnstable" then
		self.unstable = (tonumber(data) == 1)

		return true
	end
        
	return false
end

function ENT:OnRemove()

end

function ENT:PassesTriggerFilters(entity)
    return true
end

function ENT:Think()

	if self.Entities then
		if self.unstable == true or self.unstable == "true" then
			local rand = math.random(1,40)
			if rand < 2 then
				util.ScreenShake(self:GetPos(), 14, 255, 6, 512/*self.radius*/)
			end
		end
	end
	
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:Touch(entity)
end

function ENT:InitEnvBrush()
        --SB_Brush_Environment_Load_Base_Func_Extensions1(self) -- HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ! HAKZ!
        
	self.air                = {}
    self.BloomSettings      = {}
    self.ColourModSettings  = {}

	self.Enabled            = true
    self.Entities           = self.Entities or {}
        
	self.Initialized = true or false -- for the lulz
end

function ENT:KeyValue(k, v)
	print("KEYVALUE: "..k..", "..v)
	if not self.Initialized then
		self:InitEnvBrush()
	end
        
	if k == "BrushName" then
		self.EnvName = v
		self.name = self.EnvName
		return
	end
        
	v = tonumber(v) or 0
        
	-------------------------------------------------------------------------------
	---------                       Std. Env Stuff                        ---------
	-------------------------------------------------------------------------------
          
	if k == "Gravity" then
		self.gravity = v
	elseif k == "Atmosphere" then
		self.atmosphere = v
	elseif k == "Pressure" then
		self.pressure = v
	elseif k == "Temp" then
		self.temperature = v
	elseif k == "Oxygen" then
		self.air.o2per = v
	elseif k == "Carbon_Dioxide" then
		self.air.co2per = v
	elseif k == "Nitrogen" then
		self.air.nper = v
	elseif k == "Hydrogen" then
		self.air.hper = v
	elseif k == "Stable" then
		self.unstable = (v ~= 1)

    -------------------------------------------------------------------------------
    ---------                       Bloom  Stuff                          ---------
    -------------------------------------------------------------------------------
        
	elseif k == "HasBloom" then
		self.BloomSettings.Has = (v == 1)
	elseif k == "Bloom_R" then
		self.BloomSettings.AddRed = v
	elseif k == "Bloom_G" then
		self.BloomSettings.AddGreen = v
	elseif k == "Bloom_B" then
		self.BloomSettings.AddBlue = v
	elseif k == "Bloom_X" then
		self.BloomSettings.Passes_X = v
	elseif k == "Bloom_Y" then
		self.BloomSettings.Passes_Y = v
	elseif k == "Bloom_Passes" then
		self.BloomSettings.Passes = v
	elseif k == "Bloom_Darken" then
		self.BloomSettings.Darken = v
	elseif k == "Bloom_Multiplier" then
		self.BloomSettings.Multi = v
 
	-------------------------------------------------------------------------------
	---------                       Colour Modification Stuff             ---------
	-------------------------------------------------------------------------------

	elseif k == "Colour_Mod" then
		self.ColourModSettings.Has = (v == 1)
	elseif k == "Colour_Mod_R" then
		self.ColourModSettings.AddRed = v
	elseif k == "Colour_Mod_G" then
		self.ColourModSettings.AddGreen = v
	elseif k == "Colour_Mod_B" then
		self.ColourModSettings.AddBlue = v
	elseif k == "Colour_Mod_M_R" then
		self.ColourModSettings.MultiRed = v
	elseif k == "Colour_Mod_M_G" then
		self.ColourModSettings.MultiGreen = v
	elseif k == "Colour_Mod_M_B" then
		self.ColourModSettings.MultiBlue = v
	elseif k == "Colour_Mod_Brightness" then
		self.ColourModSettings.Brightness = v
	elseif k == "Colour_Mod_Contrast" then
		self.ColourModSettings.Contrast = v
	elseif k == "Colour_Mod_Range" then
		self.ColourModSettings.Range = v
	else
		ErrorNoHalt("Unhandled KV pair!\n")
		ErrorNoHalt("Key: " .. tostring(k) .. " | Value: " .. tostring(v) .. "\n")
	end
end
