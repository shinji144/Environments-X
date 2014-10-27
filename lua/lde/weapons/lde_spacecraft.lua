
LDE.Weapons.SpaceCraft = {}

function LDE.Weapons.SpaceCraft.SpaceCThink(self)

end

function LDE.Weapons.SpaceCraft.HandleWing(self,WingAngle)
	if(self and self:IsValid())then
		self:SetLocalAngles(WingAngle)
	end
end

function LDE.Weapons.SpaceCraft.CreateWing(self,Body,Model,Pos,Angles)
	local Wing = ents.Create( "prop_physics" )
	Wing:SetModel( Model ) 
	Wing:SetPos( Body:GetPos()+Pos )
	Wing:Spawn()
	Wing:Activate()
	Wing:SetParent(Body)
	Wing:SetLocalPos(Pos)
	Wing:SetLocalAngles(Angles)
	Wing:SetSolid( 0 )
	Wing.IsSpaceCraft = true
	table.insert(self.Parts,Wing)
	
	local phys = Wing:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(false)
		phys:SetMass( 1 )
	end
	
	return Wing
end

//Base Code for ships.
function LDE.Weapons.SpaceCraft.MakeSpaceC(Data)
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_gmodentity"
	ENT.PrintName = Data.name
	ENT.Spawnable			= true
	ENT.AdminSpawnable		= true
	ENT.Category = "Environments"
	ENT.Data = Data
	ENT.IsSpaceCraft = true

	if SERVER then

		function ENT:Initialize()   

			self:SetModel( "models/props_junk/PopCan01a.mdl" ) 
			self:SetName(Data.name)
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( 0 )
			
			local phys = self:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:Wake()
				phys:EnableGravity(true)
				phys:EnableDrag(true)
				phys:EnableCollisions(false)
				phys:SetMass(1)
			end
			self:SetKeyValue("rendercolor", "255 255 255")
			self.PhysObj = self:GetPhysicsObject()
			self.LDE = {CoreHealth=10000,CoreMaxHealth=10000,CoreShield=15000,CoreMaxShield=15000,CanRecharge=1,Flashing=1,CoreTemp=0,CoreMaxTemp=1,Core=self}
			
			self.LDE.PowerCellMax = 10000
			self.LDE.PowerCell = 1000
			self.LDE.PowerGen = 120
			self.LDE.ShieldTime = CurTime()
			
			self.Parts = {}
			self.CPLsuit = {}
			self.CPLsuitcheck = true
			
			self.LDE.Move = {
			Turn={Roll=0,Pitch=0,Yaw=0},
			DTurn={Roll=0,Pitch=0,Yaw=0},
			DFwd=0,Fwd=0,DThrust=0,Thrust=0,
			DVThrust=0,VThrust=0,TMul=0,
			AMul=0,Strafe=0,Strafe=0
			}

			local SpawnPos = self:GetPos()
			
			
			Body = ents.Create( "prop_vehicle_prisoner_pod" )
			Body:SetModel( self.Data.model ) 
			Body:SetPos( self:GetPos() + self:GetForward() * 150 + self:GetUp() * -50 )
			Body:SetAngles(self:GetAngles())
			Body:Spawn()
			Body:Activate()
			Body:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
			Body:SetKeyValue("limitview", 0)
			local TB = Body:GetTable()
				TB.HandleAnimation = function (vec, ply)
				return ply:SelectWeightedSequence( ACT_HL2MP_SIT ) 
			end 
			Body:SetLocalPos(Vector(-55,0,38))
			Body:SetLocalAngles(Angle(0,0,0))
			Body.LDE = {Core=self}
			Body.IsSpaceCraft = true
			self.Body = Body
			table.insert(self.Parts,Body)
			self:SetParent(Body)
			local Weld = constraint.Weld(self,Body)
			
			local phys = Body:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:Wake()
				phys:EnableGravity(true)
				phys:EnableDrag(true)
				phys:EnableCollisions(true)
				phys:SetMass( 1000 )
			end

			self:SetNetworkedEntity("Pod",self.Body,true)			
									
			if WireAddon then
				local V,N,A,E = "VECTOR","NORMAL","ANGLE","ENTITY"
				Body.Outputs = WireLib.CreateSpecialOutputs( Body, 
					{ "CPos", "Pos", "Vel", "Ang","Health", "Total Health" ,"Shields" ,"Max Shields" , "Temperature",  "Melting Point", "OverHeating", "Attacker" },
					{V,V,V,A,N,N,N,N,N,N,N,E})
			end
			WireLib.TriggerOutput( Body, "Health", self.LDE.CoreHealth or 0 )
			WireLib.TriggerOutput( Body, "Total Health", self.LDE.CoreMaxHealth or 0 )
			WireLib.TriggerOutput( Body, "Shields", self.LDE.CoreShield or 0 )
			WireLib.TriggerOutput( Body, "Max Shields", self.LDE.CoreMaxShield or 0 )
			WireLib.TriggerOutput( Body, "Temperature", self.LDE.CoreTemp or 0)	
			WireLib.TriggerOutput( Body, "Melting Point", self.LDE.CoreMaxTemp or 0 )	
			
			self.Data.Setup(self,Body)
		end
		
		function ENT:RechargeCell(Amount)
			Amount=math.abs(Amount or 0)
			if(Amount>0)then
				self.LDE.PowerCell = math.Clamp(self.LDE.PowerCell+Amount,0,self.LDE.PowerCellMax)
			end
		end
		
		function ENT:DrainCell(Amount)
			Amount=math.abs(Amount or 0)
			if(Amount>0)then
				local Power = self.LDE.PowerCell
				if(Power>Amount)then
					self.LDE.PowerCell = Power-Amount
					return Amount
				else
					self.LDE.PowerCell=0
					return Power
				end
			else
				return 0
			end
			return 0
		end
		
		function ENT:SpaceCraftDeath()
			if(not self.IsDead)then
				self.IsDead = true
				for key,Prop in pairs(self.Parts) do
					LDE:BreakOff(Prop)
				end
			end
		end
		
		function ENT:HurtHealth(amount)
			if self.LDE.CoreHealth >= amount then
				self.LDE.CoreHealth = math.Clamp(self.LDE.CoreHealth-math.abs(amount),0,self.LDE.CoreMaxHealth)
				WireLib.TriggerOutput( self.Body, "Health", self.LDE.CoreHealth or 0 )
			else
				self:SpaceCraftDeath()
			end
		end
		
		function ENT:HurtShields(amount)
			if self.LDE.CoreShield >= amount then
				LDE:ShieldDamageEffect(self.Body)
				self.LDE.CoreShield = math.Clamp(self.LDE.CoreShield-math.abs(amount),0,self.LDE.CoreMaxShield)
				WireLib.TriggerOutput( self.Body, "Shields", self.LDE.CoreShield or 0 )
			else
				self:HurtHealth(amount-self.LDE.CoreShield)
				self.LDE.CoreShield = 0
			end
		end
		
		function ENT:Think()
			--self.Entity:SetColor( 0, 0, 255, 255)
			local Phys = self.Body:GetPhysicsObject()

			if self.Body and self.Body:IsValid() then
			
				self.Body.LDE.Core = self --Tell the props who is protecting them
				self.LDE.Core = self
				
				self.CPL = self.Body:GetPassenger(1)
				if self.CPL and self.CPL:IsValid() then
					if(self.IsDead)then
						self.CPL:Kill()
						self.CPLsuitcheck = true
						return
					end
					if(type(self.CPL.suit) == "table") then
						if(self.CPLsuitcheck)then
							self.CPLsuit = table.Copy(self.CPL.suit)
							self.CPLsuitcheck = false
						else
							if(self.CPL.suit.air ~= self.CPLsuit.air) then self.CPL.suit.air = self.CPLsuit.air end
							if(self.CPL.suit.energy ~= self.CPLsuit.energy) then self.CPL.suit.energy = self.CPLsuit.energy end
							if(self.CPL.suit.coolant ~= self.CPLsuit.coolant) then self.CPL.suit.coolant = self.CPLsuit.coolant end
						end
					end
					self.LDE.AMul = 1
					self.Active = true

					self.Data.flythink(self)--Call the fly think function inside our data class
				else
					self.LDE.Move.DThrust = 0
					self.LDE.Move.DTurn.Pitch = 0
					self.LDE.Move.DTurn.Roll = 0
					self.LDE.Move.DTurn.Yaw = 0
					self.LDE.Move.DFwd = 0
					self.LDE.Move.AMul = 0
					self.OPAng = nil
					self.Active = false
					self.CPLsuitcheck = true
				end
			else
				
				self:Remove()
			end
				
			
			local TSpeed = 1
			if self.LDE.Move.Thrust > self.LDE.Move.DThrust then
				TSpeed = 50
			end
			--self.VThrust = math.Approach(self.VThrust, self.DVThrust * self.TMul, VTSpeed)
			--self.Strafe = math.Approach(self.Strafe, self.DStrafe, 1.5)

			--This is where we do the speed up and slow down logic.
			self.LDE.Move.Thrust = math.Approach(self.LDE.Move.Thrust, self.LDE.Move.DThrust * self.LDE.Move.TMul, TSpeed)
			self.LDE.Move.Turn.Pitch = math.Approach(self.LDE.Move.Turn.Pitch, self.LDE.Move.DTurn.Pitch, 2)
			self.LDE.Move.Turn.Yaw = math.Approach(self.LDE.Move.Turn.Yaw, self.LDE.Move.DTurn.Yaw, 2)
			self.LDE.Move.Turn.Roll = math.Approach(self.LDE.Move.Turn.Roll, self.LDE.Move.DTurn.Roll, 2)
			self.LDE.Move.Fwd = math.Approach(self.LDE.Move.Fwd, self.LDE.Move.DFwd, 2)		
			
			local RAng = {} RAng.r,RAng.y,RAng.p = self.LDE.Move.Turn.Yaw * 0.2,self.LDE.Move.Turn.Pitch * 0.2,self.LDE.Move.Turn.Roll * 0.2
			--Had to convert a angle into a vector.
			
			if Phys:IsValid() then
				if self.Active then
					if Phys and Phys:IsValid() then
						Phys:EnableGravity(false)
					end
					Phys:SetVelocity(Phys:GetVelocity() * .96)
					if self.Data.EngineCheck(self) then
						Phys:ApplyForceCenter(self.Body:GetRight() * (self.LDE.Move.Thrust * Phys:GetMass()) )
						Phys:AddAngleVelocity((Phys:GetAngleVelocity() * -0.1) + Vector(RAng.p,RAng.y,RAng.r))
					end
				else
					if Phys and Phys:IsValid() then
						Phys:EnableGravity(true)
					end
				end
			end
			
			if(self.LDE.ShieldTime<CurTime())then
				self.LDE.ShieldTime=CurTime()+1
				LDE:RechargeCoreShields(self,self:DrainCell(100)*5)
				
				WireLib.TriggerOutput( Body, "Health", self.LDE.CoreHealth or 0 )
				WireLib.TriggerOutput( Body, "Total Health", self.LDE.CoreMaxHealth or 0 )
				WireLib.TriggerOutput( Body, "Shields", self.LDE.CoreShield or 0 )
				WireLib.TriggerOutput( Body, "Max Shields", self.LDE.CoreMaxShield or 0 )
				WireLib.TriggerOutput( Body, "Temperature", self.LDE.CoreTemp or 0)	
				WireLib.TriggerOutput( Body, "Melting Point", self.LDE.CoreMaxTemp or 0 )	
			end
			
			self:RechargeCell(self.LDE.PowerGen)
			--[[if(self.CPL and self.CPL:IsValid())then
				self.CPL:PrintMessage( HUD_PRINTCENTER, ""..self.LDE.PowerCell)
			end]]
			
			self:NextThink( CurTime() + 0.01 )
			return true	
		end
		
		function ENT:OnRemove()
			if self.Body and self.Body:IsValid() then
				self.Body:Remove()
			end
		end

	else
		ENT.RenderGroup = RENDERGROUP_OPAQUE

		--Client stuff ;)
	end
	scripted_ents.Register(ENT, Data.class.."_spacecraft", true, false)
	print("SpaceShip Class Registered: "..Data.class)
end


local SetupFunc = function(self,Body)
	self.LWing = LDE.Weapons.SpaceCraft.CreateWing(self,Body,"models/props_junk/PopCan01a.mdl",Vector(-100,50,27),Angle(0,0,0))
	self.RWing = LDE.Weapons.SpaceCraft.CreateWing(self,Body,"models/props_junk/PopCan01a.mdl",Vector(-100,-50,27),Angle(0,0,0))
	self.LWingE = LDE.Weapons.SpaceCraft.CreateWing(self,Body,"models/Slyfo/arwing_engineleft.mdl",Vector(-100,100,-54),Angle(0,0,0))
	self.RWingE = LDE.Weapons.SpaceCraft.CreateWing(self,Body,"models/Slyfo/arwing_engineright.mdl",Vector(-100,-100,-54),Angle(0,0,0))
end

local FlyThink = function(self)
	if self.CPL:KeyDown( IN_MOVELEFT ) then
		self.LDE.Move.DTurn.Roll = -30
	elseif self.CPL:KeyDown( IN_MOVERIGHT ) then
		self.LDE.Move.DTurn.Roll = 30
	else
		self.LDE.Move.DTurn.Roll = 0
	end
	
	if self.Alt then
		self.LDE.Move.DStrafe = 90
	else
		self.LDE.Move.DStrafe = 0
	end
	
	if self.CPL:KeyDown( IN_BACK ) then
		self.LDE.Move.DThrust = -10 ---math.Clamp(self:GetUp():DotProduct( Phys:GetVelocity() ) , -5 , -1.2 ) * -4
	elseif self.CPL:KeyDown( IN_FORWARD ) then
		self.LDE.Move.DThrust = 60
	else
		self.LDE.Move.DThrust = 0
	end
	
	if self.CPL:KeyDown( IN_JUMP ) then
		self.LDE.Move.TMul = 0.1
		if self.LDE.Move.Thrust < 0 then
			self.LDE.Move.TMul = 1
		end
		self.LDE.Move.DFwd = -90
	else
		self.LDE.Move.TMul = 1
		self.LDE.Move.DFwd = 0
	end

	if self.OPAng then
	--	self.CPL:SetEyeAngles(self:WorldToLocalAngles(self.OPAng):Forward():Angle())
	else
		self.OPAng = self.CPL:EyeAngles()
	end

	if self.CPL:KeyDown( IN_SPEED ) then
		self.LDE.Move.DTurn.Pitch = 0
		self.LDE.Move.DTurn.Yaw = 0
	else
		local AAng = self.Body:WorldToLocalAngles(self.CPL:EyeAngles())
		self.LDE.Move.DTurn.Pitch = AAng.p
		self.LDE.Move.DTurn.Yaw = (AAng.y)
	end
end

local enginecheck = function(self)
	if(self.RWingE and self.RWingE:IsValid() and self.LWingE and self.LWingE:IsValid())then
		return true
	else
		return false
	end
end

local Stats = {}
local Data = {name="Arwing",class="ship_arwing",model="models/Slyfo/arwing_body.mdl",Stats=Stats,flythink=FlyThink,Setup=SetupFunc,EngineCheck=enginecheck}
LDE.Weapons.SpaceCraft.MakeSpaceC(Data)

local SetupFunc = function(self) end
local enginecheck = function(self) return true end
local Stats = {}
local Data = {name="Sword",class="ship_sword",model="models/Slyfo/sword.mdl",Stats=Stats,flythink=FlyThink,Setup=SetupFunc,EngineCheck=enginecheck}
LDE.Weapons.SpaceCraft.MakeSpaceC(Data)

local SetupFunc = function(self) end
local enginecheck = function(self) return true end
local Stats = {}
local Data = {name="StingRay",class="ship_stingray",model="models/Cerus/Fighters/stingray.mdl",Stats=Stats,flythink=FlyThink,Setup=SetupFunc,EngineCheck=enginecheck}
LDE.Weapons.SpaceCraft.MakeSpaceC(Data)
