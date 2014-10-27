AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )
ENT.LDEC =1

function ENT:Initialize()
	self:SetModel( "models/Spacebuild/Nova/drone2.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
		phys:EnableGravity(false)
	end
	self.NoGrav=true
	self.NoEnvPanel=true
	self.LastShot=CurTime()
	self.DebugBeam=0
	self.IsHome=false
end

function ENT:HarvestScrap()
	local Scrap = self.Target
	local Pad = self.Pad
	
	local effectdata = EffectData()
	effectdata:SetOrigin( Scrap:GetPos())
	effectdata:SetStart(self:GetPos())
	effectdata:SetEntity( self )
	util.Effect( "lde_spore_trace_effect", effectdata )
	
	for k,e in pairs(Scrap.Resources) do
		if(not e.amount)then continue end
		if(e.amount>0)then
			Pad:SupplyResource(e.name,e.amount)
			e.amount=0 -- So we cant give more then we were given
		end
	end
	
	self.Target:Remove()
end

function ENT:AquireTarget()
	local Core=self.LDE.Core --Grab our core.
	local Targets = Core.Scrap --Grab the targeting list.
	for k, v in pairs(Targets) do
		if(v:IsValid())then
			if(not v.LDETagged or not v.LDETagged:IsValid() or v.LDETagged == self)then
			
				self.Target=v
				v.LDETagged=self--Tag the target .
				--print("Target aquired!")
				return true
			end
		end
	end
	--print("Couldnt find a target :/")
	return false
end

function ENT:AiThink()
	if(not self.Pad or not self.Pad:IsValid() or not self.Pad.LDE)then return end
	local Targets = self.Pad.LDE.Core.Scrap
	local ScrapCount = table.Count(Targets)
	if(not self.Target or not self.Target:IsValid())then
		if(ScrapCount>0)then
			--print(ScrapCount)
			if(not self:AquireTarget(false))then
				self.Target=self.Pad
				self.IsHome=false
			end
		else
			self.Target=self.Pad
		end
	else
		if(ScrapCount>1 and self.Target.LDETagged~=self and self.Target~=self.Pad or ScrapCount>0 and self.Target==self.Pad and self.IsHome)then self.Target=nil return end
		--print("Targeting "..tostring(self.Target))
		
		local TargetPos=self.Target:GetPos()
		local Distance = self:GetPos():Distance(TargetPos)
		local PadDist = self.Pad:GetPos():Distance(TargetPos)
		
		self.TargetPos=TargetPos+Vector(0,0,10+(Distance/2))
		
		if(PadDist>10000)then self.Target=nil return end
		
		if(self.TargetPos)then
			local Phys=self:GetPhysicsObject()
			if Phys:IsValid() then
				local Direction =self.TargetPos-self:GetPos()
				Direction:Normalize()
				local SpeedMult=0.8
				local Drag = 0.5
				if(Distance<400)then SpeedMult=0.2 Drag=0.8 end 
				Phys:SetVelocity(Phys:GetVelocity() * Drag)
				Phys:ApplyForceCenter(( Direction * (300)*SpeedMult) * Phys:GetMass())
				Phys:AddAngleVelocity(-self:GetAngAim(Phys,self.TargetPos,true)*Vector(1,1,1))
			end
		end
		
		if(Distance<300)then
			if(self.Target~=self.Pad)then
				self:HarvestScrap()
			else
				self.IsHome=true
			end
		end	
	end
end

function ENT:GetBearing(rad2deg,pos)
	return rad2deg*-math.atan2(pos.y, pos.x)
end

function ENT:GetElevation(rad2deg,pos)
	local len = pos:Length()
	if len < delta then return 0 end	
	return rad2deg*math.asin(pos.z / len)
end

function ENT:GetAngAim(Phys,Targ)
	if(not self.TargetPos and not Targ)then return end
	local Ang = self:GetAngles()
	
	pos = self:WorldToLocal(self.TargetPos)
	if(Targ)then pos = self:WorldToLocal(Targ-self:GetVelocity()) end
	local rad2deg = 180 / math.pi

	elevation=self:GetElevation(rad2deg,pos)
	bearing = self:GetBearing(rad2deg,pos)

	return Vector(Ang.Roll,elevation,bearing)+Phys:GetAngleVelocity()
end

function ENT:ChangeTemp(Amount)
	return
end

function ENT:Think()

	if(not self.Pad or not self.Pad:IsValid())then 
		LDE:KillEnt(self)
	end
	
	self:AiThink()
	
	local Phys=self:GetPhysicsObject()
	if(not self.Target or not self.Target:IsValid() or not self.TargetPos)then
		if Phys:IsValid() then
			Phys:SetVelocity(Phys:GetVelocity() * .5)
			Phys:AddAngleVelocity(-Phys:GetAngleVelocity()*Vector(0.3,0.6,0.6))
		end
	end
	
	self:NextThink(CurTime()+0.1)
end