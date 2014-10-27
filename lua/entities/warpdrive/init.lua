
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

ENT.WireDebugName = "Warp Drive"

function ENT:SpawnFunction( ply, tr )
	local ent = ents.Create("WarpDrive") 		-- Create the entity
	ent:SetPos(tr.HitPos + Vector(0, 0, 20)) 	-- Set it to spawn 20 units over the spot you aim at when spawning it
	ent:Spawn() 								-- Spawn it
	return ent 									-- You need to return the entity to make it work
end 

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	util.PrecacheModel( "models/props_c17/consolebox03a.mdl" )
	util.PrecacheSound( "warpdrive/warp.wav" )
	util.PrecacheSound( "warpdrive/error2.wav" )
	
	--self.Entity:SetModel( "models/props_c17/consolebox03a.mdl" )
	self:SetModel( "models/Slyfo/ftl_drive.mdl" )
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self:DrawShadow(false)
	
	local phys = self:GetPhysicsObject()
	
	self.NTime = 0

	if ( phys:IsValid() ) then 
		phys:SetMass( 100 )
		phys:EnableGravity( true )
		phys:Wake() 
	end
	self.Entities = {}
	self.LocalPos = {}
	self.LocalAng = {}
	self.LocalVel = {}
	
	self.JumpCoords = {}
	self.JumpCoords.Dest = Vector(0,0,0)
	self.SearchRadius = 512
	self.Constrained = 1
	self.WarpInterupted = false
	self.Inputs = WireLib.CreateSpecialInputs( self, { "Radius", "UnConstrained", "Destination X", "Destination Y", "Destination Z", "Destination", "Warp" }, { [6] = "VECTOR"} );
end

function ENT:TriggerInput(iname, value)
	if(iname == "Radius") then
		self.SearchRadius = value
		if self.SearchRadius > 5000 then self.SearchRadius = 5000 end
	elseif(iname == "UnConstrained") then
		self.Constrained = value
	elseif(iname == "Destination X") then
		self.JumpCoords.x = value
		self.UseWhich = 1
	elseif(iname == "Destination Y") then
		self.JumpCoords.y = value
		self.UseWhich = 1
	elseif(iname == "Destination Z") then
		self.JumpCoords.z = value
		self.UseWhich = 1
	elseif(iname == "Destination") then
		self.JumpCoords.Vec = value
		self.UseWhich = 2
	elseif(iname == "Warp" and value > 0) then
		if(self.UseWhich == 1) then
			self.JumpCoords.Dest = Vector(self.JumpCoords.x, self.JumpCoords.y, self.JumpCoords.z)
		else
			self.JumpCoords.Dest = self.JumpCoords.Vec
		end
	--[[	print( timer.IsTimer( "warpdrivewaittime" ) ) ]]
		print(CurTime().." "..self.NTime)
		if (CurTime()>self.NTime) and self.JumpCoords.Dest~=self:GetPos() and util.IsInWorld(self.JumpCoords.Dest) and self.LDE.Core then
			self.NTime=CurTime()+50
			self:EmitSound("WarpDrive/warp.wav", 450, 70)
			timer.Create( "warpdrivewaittime "..self:GetCreationID(), 1, 1, function() self:Go() timer.Destroy("warpdrivewaittime "..self:GetCreationID()) end )
		else
			self:EmitSound("WarpDrive/error2.wav", 450, 70)
		end
	--[[	print( self.NTime )
		print( timer.IsTimer( "warpdrivewaittime" ) )
		print( self.JumpCoords.Dest ~= self.Entity:GetPos() )
		print( util.IsInWorld( self.JumpCoords.Dest ) ) ]]
	end
end

function ENT:JumpSafe(WarpDrivePos,props)
	local trace = {}
		trace.start = WarpDrivePos --Gotta change this to work with DH as well
		trace.endpos = self.JumpCoords.Dest
		trace.filter = props
	local tr = util.TraceLine( trace )
	if(tr.Hit and not tr.HitSky )then
		local core = self.LDE.Core
		self.WarpInterupted = true --We go bye bye.
		self.JumpCoords.Dest = tr.HitPos --Uh oh we hit something!
		util.BlastDamage(self, self, tr.HitPos, core.LDE.CoreMaxHealth/100, core.LDE.CoreMaxHealth/50)
	end
end

function ENT:Jump()
	-- Get the localized positions
	local JumpEnts = constraint.GetAllConstrainedEntities_B( self )

	local WarpDrivePos = self:GetPos()
	if(self.Constrained > 0) then
		local DoneList = {self}
		self.ConstrainedEnts = ents.FindInSphere( WarpDrivePos , self.SearchRadius)
		for _, v in pairs(self.ConstrainedEnts) do
			if v:IsValid() and not DoneList[v] then
				self.ToTele = constraint.GetAllConstrainedEntities_B(v)
				for ent,_ in pairs(self.ToTele)do
					if ent:IsValid() and not DoneList[ent] then
						DoneList[ent]=ent
					end
				end
			end
		end
		table.Add(JumpEnts,DoneList)
	end
	
	self:JumpSafe(WarpDrivePos,JumpEnts)

	-- Check world
	self.Entities = {}
	self.OtherEntities = {}
	for _, ent in pairs( JumpEnts ) do

		-- Calculate the position after teleport, without actually moving the entity
		local pos = self:WorldToLocal( ent:GetPos() )
		pos = pos + self.JumpCoords.Dest

		local b = util.IsInWorld( pos )
		if not b then -- If an entity will be outside the world after teleporting..
			self:EmitSound("WarpDrive/error2.wav", 450, 70)
			self.NTime=CurTime()
			timer.Destroy("warpdrivewaittime "..self:GetCreationID())
			return
		elseif ent ~= self then -- if the entity is not equal to self`
			if not self:WarpImmune(ent) then -- If the entity can be teleported
				self.Entities[#self.Entities+1] = ent
			else -- If the entity can't be teleported
				self.OtherEntities[#self.OtherEntities+1] = ent
			end
		end
	end

	timer.Simple( 0.05, function() self:Jump_Part2() end )
end

function ENT:Jump_Part2()
	local OldPos = self:GetPos()

	self.LocalPos = {}
	self.LocalAng = {}
	self.LocalVel = {}
	for _, ent in pairs( self.Entities ) do

		-- Save the localized position
		self.LocalPos[ent] = self:WorldToLocal( ent:GetPos() )

		-- Save the localized velocity
		self.LocalVel[ent] = self:WorldToLocal( ent:GetVelocity() + ent:GetPos() )

		ent:SetVelocity( ent:GetVelocity() * -1 )
	end
	
	local Peeps = player.GetAll()
	for _, k in pairs(Peeps) do
		if(k:GetPos():Distance(self:GetPos()) <= self.SearchRadius ) then
			self:SharedJump(k)
		end
	end
		
	local oldvel = self:WorldToLocal( self:GetVelocity() + self:GetPos() ) -- Velocity
	self:SetPos( self.JumpCoords.Dest ) -- Position
	self:GetPhysicsObject():SetVelocity( self:LocalToWorld( oldvel ) - self:GetPos() ) -- Set new velocity

	for _, ent in pairs( self.Entities ) do
		if(not ent:GetParent():IsValid())then--Only warp unparented props
			local oldPos = ent:GetPos() -- Remember old position

			ent:SetPos( self:LocalToWorld(self.LocalPos[ent]) ) -- Position

			-- Set new velocity
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocity( self:LocalToWorld( self.LocalVel[ent] ) - ent:GetPos() )
				phys:Wake()
			else
				ent:SetVelocity( self:LocalToWorld( self.LocalVel[ent] ) )
			end
		end
	end
		
	if(self.WarpInterupted == true)then
		local core = self.LDE.Core
		LDE:ExplodeCore(core)
	end
end

function ENT:Go()	
	self:Jump()
end

function ENT:SharedJump(ent)
	local WarpDrivePos = self:GetPos()
	local phys = ent:GetPhysicsObject()
	ent:SetPos(self.JumpCoords.Dest + (ent:GetPos() - WarpDrivePos) + Vector(0,0,10))
end

function ENT:WarpImmune(ent)
	local Blocked = {"phygun_beam","predicted_viewmodel","func","func_physbox","info_","point_","path_","node","Environment","environment","sent_spaceanon","env_","shell","missle","star"}
	local Always = {"resource","storage","asteroid","generator","lde","lifesupport","environments","dispenser","weapon","probe","lscore","factory","pump","health","trade"}
	if(not ent:IsValid())then return true end
	local str = ent:GetClass()
	for _,b in pairs(Blocked) do
		if(string.find(str,b))then
			for _,v in pairs(Always) do
				if(string.find(str,v))then
					return false
				end
			end
			return true
		end
	end
	return false
end

function ENT:PreEntityCopy()
	if WireAddon then
		duplicator.StoreEntityModifier(self,"WireDupeInfo",WireLib.BuildDupeInfo(self.Entity))
	end
end

function ENT:PostEntityPaste(ply, ent, createdEnts)
	if WireAddon then
		local emods = ent.EntityMods
		if not emods then return end
		WireLib.ApplyDupeInfo(ply, ent, emods.WireDupeInfo, function(id) return createdEnts[id] end)
	end
end