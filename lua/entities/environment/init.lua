AddCSLuaFile( "shared.lua" )
AddCSLuaFile("core/base.lua")
------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------
local Space = Space
local math = math
local util = util
local ents = ents
local table = table
local pairs = pairs
local CurTime = CurTime
local Vector = Vector
local Msg = Msg

PlayerGravity = true

local CompatibleEntities = {"func_precipitation", "env_smokestack", "func_dustcloud", "func_smokevolume"}

include("shared.lua")
include("core/base.lua")

//fixes stargate stuff
ENT.IgnoreStaff = true
ENT.IgnoreTouch = true
ENT.NotTeleportable = true

function ENT:Initialize()
	self:SetModel( "models/combine_helicopter/helicopter_bomb01" ) --setup stuff
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:PhysicsInitSphere(1)
	self:SetCollisionBounds(Vector(-1,-1,-1),Vector(1,1,1))
	self:SetTrigger( true )
    self:GetPhysicsObject():EnableMotion( false )
	self:DrawShadow(false)
//	self:SetAlpha(0) 
	self.gravity = 0
	self.Debugging = false
	self.IsEnvironment =  true
	
	local phys = self:GetPhysicsObject() --reset physics
	if phys:IsValid() then
		phys:Wake()
	end
	self:SetNotSolid( true )
	
	self:SetColor(Color(255,255,255,0)) --Make invis
	
	//Important Tables
	self.Entities = {}
end

local notouch = {}
notouch["func_door"] = 1

function ENT:StartTouch(ent)
	if not ent:GetPhysicsObject():IsValid() then return end	--only physics stuff 
	if notouch[ent:GetClass()] or ent:IsWorld() then return end --no world stuff
	
	if ent.NoGrav then return end --let missiles,ect do their thang
	
	if not self.Enabled then 
		if self.Debugging then Msg("Entity ", ent, " tried to enter but ", self.name, " wasn't on.\n") end
		
		return
	elseif self.Debugging then 
		Msg("Entity ", ent, " has started touching ", self.name, " in unusual places....\n")
	end
	
	self.Entities[ent:EntIndex()] = ent
end

function ENT:EndTouch(ent)
	if ent:IsWorld() then return end
	
	if self.Debugging then
		Msg("Entity ", ent, " has stopped touching ", self.name, " in unusual places....\n")
	end
	
	self.Entities[ent:EntIndex()] = nil

	if not ent:GetPhysicsObject():IsValid() then return end

	if ent.environment == self then
		EnvX.SpaceEntity(ent)
	else
		--if self.Debugging then Msg("...and has decided to not get spaced.\n") end
	end
end
	
function ENT:GravNDrag(ent,g,d)
	if ent:IsRagdoll() then
		for i = 0, ent:GetPhysicsObjectCount() do	
			local phys = ent:GetPhysicsObjectNum( i );
			if( phys and phys:IsValid() ) then
				phys:EnableGravity( g )
				phys:EnableDrag( d )
			end
		end
	else
		ent:GetPhysicsObject():EnableDrag( d )
		ent:GetPhysicsObject():EnableGravity( g )		
	end
end

function ENT:UpdateGravity(ent)
	ent.environment = self
	ent:SetGravity( self.gravity )

	if ent:IsPlayer()  then
		ent:SetNWBool( "inspace", false )
	else
		self:GravNDrag(ent,true,true)
	end
end

function ENT:UpdatePressure(ent)

end

function ENT:Check()
	//local start = SysTime()
	local radius = self.radius
	for k,ent in pairs(self.Entities) do
		if(ent and ent:IsValid())then
			if ent:GetPhysicsObject():IsValid() then
				/*if ent.environment and ent.environment != self and ent.environment != Space() and (ent.environment.radius or 0) < (self.radius or 0) then --try and fix planets in each other
					continue --breaks LS Core
				end*/
				if ent:GetPos():Distance(self:GetPos()) <= radius then
					//Set Planet
					ent:SetGravity( self.gravity )
					
					self:GravNDrag(ent,self.gravity > 0.01,self.pressure > 0.1)
					
					ent.environment = self
					if( ent:IsPlayer() ) then
						ent:SetNWBool( "inspace", false )
					end
				else --space
					//Set Space
					if ent.environment == self then
						EnvX.SpaceEntity(ent)
					else --they teleported out
						--if self.Debugging then Msg("...and has decided to not get spaced.\n") end
					end
				end
			end
		else
			table.remove(self.Entities,k)
		end
	end
	//print(self.name, SysTime()-start, table.Count(self.Entities))
end

function ENT:Think()
	if not self:GetPos() == self.position then
		self:SetPos(self.position)
	end
	
	if self.Entities then
		self:Check()
	end
	
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:Configure(rad, gravity, name, env)
	self:PhysicsInitSphere(rad)
	self:SetCollisionBounds(Vector(-rad,-rad,-rad),Vector(rad,rad,rad))
	self:SetTrigger( true )
    self:GetPhysicsObject():EnableMotion( false )
	self:SetMoveType( MOVETYPE_NONE )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetNotSolid( true )
	
	self.OldData = {}
	for k,v in pairs(env) do
		self[k] = v
		self.OldData[k] = v
	end
	
	self.radius = rad
	self.Enabled = true
	self.gravity = gravity
	
	self.Env = {}
	self.Env.sbenvironment = self:GetTable() --reverse compat
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

