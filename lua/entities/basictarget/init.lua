AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
--include('entities/base_wire_entity/init.lua')
include( 'shared.lua' )
ENT.LDEC =1


function ENT:SpawnFunction( ply, tr )
		
	local ent = ents.Create("basictarget")
	ent:SetPos( tr.HitPos + Vector(0, 0, 60))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()			
	return ent

end

function ENT:Initialize()
	self:SetModel( "models/af/AFF/USN/daphne.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
		phys:EnableGravity(false)
	end
	self.CoreLinked={self}
	self.Data={}
	self.LDE={Core=self}
	self.NoGrav=true
	self.NoEnvPanel=true
	self.LastShot=CurTime()
	self.DebugBeam=0
	
	if(NADMOD)then
		NADMOD.SetOwnerWorld(self)
	end
end

function ENT:VantagePoint(TargetPos)

	if(self.VPoint)then return self.VPoint end
	local Trys = 500
	while Trys > 0 do --Only try so many times in one go.
		local r = 2500+math.random(1000,1500)
		local x,y = math.random(-r,r),math.random(-r,r)
		local Point = TargetPos+Vector(x,y,3000)
		local Distance = Point:Distance(TargetPos)
		if ( Distance > 2000) then
			self.VPoint = Point
			return Point
		end
	end
		
	return TargetPos+Vector(0,0,2000)--We couldnt get a vantage point, lets come from above
end

function ENT:FireGuns()	
	if(not self.Weapons)then return end
	
	local Target = self.Target
	
	for I,Weapon in pairs(self.Weapons) do
		if(Weapon.LastShot+Weapon.FireRate<CurTime())then
			pos = self:WorldToLocal(Target:GetPos())
			local rad2deg = 180 / math.pi		
			
			elevation=math.abs(self:GetElevation(rad2deg,pos))
			bearing = math.abs(self:GetBearing(rad2deg,pos))
			--print("Firing gun: "..Weapon.WepName.." E: "..elevation.." B: "..bearing)
			
			if(elevation-Weapon.AngElevOffset<Weapon.FireAngle and bearing-Weapon.AngBearOffset<Weapon.FireAngle)then
				--print("PEW")
				LDE.TD.AI.Weapons[Weapon.Type](self,Weapon,Target)
				Weapon.LastShot=CurTime()
			end
		end
	end
end

function ENT:AiThink()
	if(not self.Target or not self.Target:IsValid())then
		local Targets = ents.FindByClass("lde_basecore")
		local Count = table.Count(Targets)
		if(Count>=1)then
			local Target=Targets[math.Round(math.random(1,Count))]
			local Connected = table.Count(Target.connected)
			if(Connected>=1)then
				local Rand = math.random(1,10)
				if(Rand>=3)then
					--print("picking none core target")
					self.Target=table.Random(Target.connected)
					--print(self.Target:IsValid())
				else
					self.Target=Target
				end
			else
				self.Target=Target
			end
		end
	else
		local TargetPos=self.Target:GetPos()
		local Distance = self:GetPos():Distance(TargetPos)
		
		self.Data.Pathing(self,Distance,TargetPos)
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

function ENT:OnLDEKilled()
	self.Data.OnDeath(self)
	local Data = self.Data
	LDE.TD.Scrap.SpawnScrap(self,Data.ScrapSize,Data.ScrapAmount,Data.ScrapValue)
end

function ENT:ChangeTemp(Amount)
	return
end

function ENT:Think()

	if(self.IsDead)then 
		return 
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