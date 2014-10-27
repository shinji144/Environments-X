------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

include("shared.lua")
AddCSLuaFile("shared.lua")
include("core/base.lua")

ENT.IgnoreStaff = true
ENT.IgnoreTouch = true
ENT.NotTeleportable = true
	
function ENT:Initialize()
	self:SetModel( "models/items/car_battery01.mdl" ) --setup stuff
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:PhysicsInitSphere(1)
	self:SetCollisionBounds(Vector(-1,-1,-1),Vector(1,1,1))
	self:SetTrigger( true )
    self:GetPhysicsObject():EnableMotion( false )
	self:DrawShadow(false)
	
	self.gravity = 0
	self.Debugging = false
	
	local phys = self:GetPhysicsObject() --reset physics
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetNotSolid( true )
	
	//self:SetColor(255,255,255,0) --Make invis
	self.Entities = {}
end

function ENT:StartTouch(ent)
	if not ent:GetPhysicsObject():IsValid() then return end
	if ent:IsWorld() then return end
	
	self.Entities[ent:EntIndex()] = ent
	
	if not self.Enabled then 
		if self.Debugging then Msg("Entity ", ent, " tried to enter but ", self, " wasn't on.\n") end
		
		return
	elseif self.Debugging then 
		Msg("Entity ", ent, " has started touching ", self, " in unusual places....\n")
	end
end

function ENT:EndTouch(ent)
	if ent:IsWorld() then return end
	
	if self.Debugging then
		Msg("Entity ", ent, " has stopped touching ", self, " in unusual places....\n")
	end
	
	self.Entities[ent:EntIndex()] = nil

	if not ent:GetPhysicsObject():IsValid() then return end
	if ent.environment == self then
		if( ent:IsPlayer() ) then
			//Set Space Stuff
			ent:SetGravity( 0.00001 )
			if not ent:IsAdmin() then
				e:SetMoveType( MOVETYPE_WALK )
			end

			ent:SetNWBool( "inspace", true )
		else
			ent:GetPhysicsObject():EnableDrag( false )
			ent:GetPhysicsObject():EnableGravity( false )
		end
		ent.environment = Space()
		if self.Debugging then Msg("...and has decided to get spaced.\n") end
	else
		--if self.Debugging then Msg("...and has decided to not get spaced.\n") end
	end
end

function ENT:Check()
	local radius = self.radius
	for k,ent in pairs(self.Entities) do
		if ent:GetPhysicsObject():IsValid() then
			if ent:GetPos():Distance(self:GetPos()) < radius then
				//Set Planet
				ent:SetGravity( 0 )
				ent:GetPhysicsObject():EnableDrag( true )
				ent:GetPhysicsObject():EnableGravity( false )
				ent.environment = self

				if( ent:IsPlayer() ) then
					ent:SetNWBool( "inspace", false )
				end
			else --space
				//Set Space
				if ent.environment == self then
					if( ent:IsPlayer() ) then
						ent:SetGravity( 0.00001 )
						if not ent:IsAdmin() then
							ent:SetMoveType( MOVETYPE_WALK )
						end
					
						ent:SetNWBool( "inspace", true )
					else
						ent:GetPhysicsObject():EnableDrag( false )
						ent:GetPhysicsObject():EnableGravity( false )
					end
					ent.environment = Space()
					if self.Debugging then Msg("...and has decided to get spaced.\n") end
				else
					--if self.Debugging then Msg("...and has decided to not get spaced.\n") end
				end
			end
		end
	end
end

function ENT:Think()
	if self.Entities == {} or nil then return end
	self:Check()
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:Configure(rad, gravity, name, env)
	self:PhysicsInitSphere(rad)
	self:SetCollisionBounds(Vector(-rad,-rad,-rad),Vector(rad,rad,rad))
	self:SetTrigger( true )
    self:GetPhysicsObject():EnableMotion( false )
	self:SetMoveType( MOVETYPE_NONE )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetNotSolid( true )
	
	for k,v in pairs(env) do
		self[k] = v
	end
	
	self.radius = rad
	self:SetNotSolid( true )
	self.Enabled = true
	self.gravity = gravity
	self.ID = name
	if Init_Debugging_Override or self.Debugging then
		Msg("Initialized a new entity env: ", self, "\n")
		Msg("ID is: ", self.ID, "\n")
		Msg("Dumping stats:\n")
		Msg("------------ START DUMP ------------\n")
		PrintTable(self.environment)
		Msg("------------- END DUMP -------------\n\n")
	end
end

function ENT:CanTool()
	return false
end

function ENT:GravGunPunt()
	return false
end

function ENT:GravGunPickupAllowed()
	return false
end

