LDE.Weapons = {}

//Function that locks weapons to the models they are allowed to.
function LDE.Weapons.WeaponModelCheck(self,Models)
	if(not self or not self:IsValid())then return false end
		
	local mymodel =self:GetModel() --Optimise the function by making a local copy of the model name.
		
	for k,v in pairs(Models) do
		if(mymodel==string.lower(v))then
			return true
		end
	end
		
	return false
end

LDE.Weapons.PrimaryStats = {
Damage="Damage",
ProjectileSpeed="Speed",
ProjectileCount="Number",
ProjectileSpread="Spread",
HeatDamage="heat",
BurnTime="BurnTime",
Radius="Radius",
Recoil="Recoil",
CoolDown="CoolDown",
MinimalCharge="MinCharge",
MaximumCharge="MaxCharge",
ChargeRate="ChargeRate",
DamagePerCharge="Dpc",
ShrapnelCount="ShrapCount",
ShrapnelDamage="ShrapDamage"
}

//Function that compiles a weapons tool tip.
function LDE.Weapons.CreateToolTip(Data)
	local ToolTip=Data.name
	
	if(Data.Desc)then
		ToolTip=ToolTip.." \n "..Data.Desc
	end
	
	ToolTip=ToolTip.." \n MountType: "..(Data.MountType or "None")
	
	ToolTip=ToolTip.." \n Heat: "..Data.heat.." \n FireRate: "..Data.firespeed.." \n Processes: "..Data.Points
	
	Data.Bullet = Data.Bullet or {}
	
	for k,v in pairs(LDE.Weapons.PrimaryStats) do
		if(Data.Bullet[v])then
			ToolTip=ToolTip.."\n "..k..": "..Data.Bullet[v]
		end
	end
	
	return ToolTip
end

//Function to compile a weapon into the system.
function LDE.Weapons.CompileWeapon(Data,Inner)
	local ToolTip = LDE.Weapons.CreateToolTip(Data)
	for k,v in pairs(Inner.model) do
		Environments.RegisterDevice(Inner.Tool, Inner.Type, Inner.name[k], Inner.class, v,1,1,Inner.name[k],ToolTip)
	end
	LDE.Weapons.RegisterWeapon(Data,Inner.model)
end

//Custom Weapon Think - Cuz they were thinking too slow >_<
function LDE.Weapons.NewThink(Ent)
	if IsValid(Ent) then Ent:FireWeapon() end
end

LDE.Weapons.CanFireTab = {}

LDE.Weapons.CanFireTab.Status = function(self)
	local CanFire=self:GetNWInt("WepCanFire") or 0
	local Core=self:GetNWInt("WepNoCore") or 0
	local Points=self:GetNWInt("WepNeedPoints") or 0
	local Safe=self:GetNWInt("WepSafeZone") or 0
	local Text = "Cant Fire"
	if(CanFire>0)then 
		Text = "Can Fire" 
	else 
		if(Core>0)then
			Text=Text.." No Core"
		end
		if(Points>0)then
			Text=Text.." Not Enough Processor"
		end
		if(Safe>0)then
			Text=Text.." Inside SafeZone"
		end
	end
	return Text
end

//Base Weapon Code we will inject the shooting functions into.
function LDE.Weapons.RegisterWeapon(Data,Models)
	local Data = table.Copy(Data)
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_env_entity"
	ENT.PrintName = Data.name
	ENT.Data = Data
	ENT.Models = Models
	ENT.MountType = Data.MountType or "None"
	ENT.MountAngleOffSet = Data.MAO or Angle(0,0,0)
	ENT.MountVectorOffSet = Data.MVO or Vector(0,0,0)
	ENT.IsLDEWeapon = true
	ENT.PointCost = Data.Points or 0
	ENT.HasPoints = false	
	ENT.LDETools = table.Copy(LDE.Weapons.CanFireTab)
	
	if(Data.FireSound)then
		util.PrecacheSound(Data.FireSound)
	end
	if(Data.Shared)then
		Data.Shared(ENT) -- Call any initial functions.
	end
	list.Set( "LSEntOverlayText" , Data.class, {HasOOO = true, resnames = Data.In, genresnames = Data.Out} )
	
	if SERVER then
		if(Data.EnvPanelFuncs)then
			Data.EnvPanelFuncs(self)
		else
			local T = {} --Create a empty Table
			
			T.Power = function(Device,ply,Data)
				Device:SetActive( nil, ply )
			end
			
			ENT.Panel=T --Set our panel functions to the table.
		end
		
		function ENT:Initialize()
			self.BaseClass.Initialize(self)
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )

			if(self.Data.Intial)then
				self.Data.Intial(self)
			end
			
			--Create Think Timer
			local ID = self:EntIndex() 
			timer.Create( "NewThink"..tostring(ID), 0.02, 0, function() LDE.Weapons.NewThink(self) end )
			--
			
			if WireAddon then
				self.WireDebugName = self.PrintName
				if(Data.WireSpecial)then
					self.Data.WireSpecial(self)
				else
					if(Data.WireIn)then
						self.Inputs = WireLib.CreateInputs(self, Data.WireIn)
					else
						self.Inputs = WireLib.CreateInputs(self, { "Fire" })
					end
					if(Data.WireOut)then
						self.Outputs = WireLib.CreateOutputs(self, Data.WireOut)
					else
						self.Outputs = WireLib.CreateOutputs(self,  { "CanFire" })
					end
				end
			end
			
			if(LDE.Weapons.WeaponModelCheck(self,self.Models)) then 
				print("Model Check is correct!")
			else
				print("Error Model Wrong")
				self:SetModel(self.Models[1])
				self:PhysicsInit( SOLID_VPHYSICS )
				self:SetSolid( SOLID_VPHYSICS )
			end
			
			self.Active = 0
			self.Mult = 1
			self.CanFire=1
			self.Charge=0
			self.LastTime=CurTime()	
			self:SetCanFire(0)
		end
		
		function ENT:OnRemove()
			--Kill the Think Timer
			local ID = self:EntIndex() 
			if timer.Exists("NewThink"..tostring(ID)) then
				timer.Destroy("NewThink"..tostring(ID))
			end
			--
			
			--If the cores valid, unlink ourself from it to free up some points.
			if(self.LDE.Core and self.LDE.Core:IsValid())then
				self.LDE.Core:CoreUnLink( self )
			end
			
			if(self.Data.Removal)then
				self.Data.Removal(self)
			end
		end
		
		function ENT:TurnOn()
			if self.Active == 0 then
				self.Active = 1
				self:SetOOO(1)
			end
		end
		
		function ENT:Touch( ent )
			if(self.Data.Touch)then
				self.Data.Touch(self,ent)
			end
		end
		
		function ENT:TriggerInput(iname, value)
			if(self.Data.WireFunc)then
				self.Data.WireFunc(self,iname,value)
			else
				if iname == "Fire" then
					if value > 0 then
						if self.Active == 0 then
							self:TurnOn()
						end
					else
						if self.Active == 1 then
							self:TurnOff()
						end
					end
				end
			end
		end

		function ENT:TurnOff()
			if self.Active == 1 then
				self.Active = 0
				self:SetOOO(0)
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
		
		ENT.FireWep = Data.shootfunc --Define our fire function.
		
		function ENT:SetNetVar(Name,Var)
			local hp = self:GetNWInt(Name)
			if (!hp or hp != Bool) then
				self:SetNWInt(Name, Var)
			end			
		end
		
		function ENT:SetCanFire(Bool)
			self:SetNetVar("WepCanFire",Bool)
		end
		
		function ENT:CantFire()
			if(WireLib)then
				WireLib.TriggerOutput(self, "CanFire", 0) 
			end
			self:SetCanFire(0)
		end
		
		function ENT:FireWeapon()
			self.SPL = self.LDEOwner
			self.Active=self.Active or 0
			self.LDE = self.LDE or {}
			if(not self.LDE.Core or not self.LDE.Core:IsValid())then
				self:CantFire() 
				self:SetNetVar("WepNoCore",1) 
				return
			else
				self:SetNetVar("WepNoCore",0) 
			end
			if(not self.HasPoints)then 
				self:CantFire() 
				self:SetNetVar("WepNeedPoints",1) 
				return
			else
				self:SetNetVar("WepNeedPoints",0) 
			end
			if(LDE:IsInSafeZone(self) and not self.Data.SafeAllow)then 
				self:CantFire() 
				self:SetNetVar("WepSafeZone",1) 
				return
			else
				self:SetNetVar("WepSafeZone",0) 
			end
			
			if(CurTime()>=self.LastTime+self.Data.firespeed)then
				WireLib.TriggerOutput(self, "CanFire", 1)
				self:SetCanFire(1)
				if(not self.Data.ChargeType)then
					if(self.Active>0)then
						self.LastTime=CurTime()
						self:FireWep()
					end
				else
					self.LastTime=CurTime()
					self:FireWep()					
				end
			else
				if(self.Data.firespeed>1)then
					self:CantFire()
				end
			end 
		end

		function ENT:NewThink(ID)
			self:FireWeapon()
		end
		
	else
		
		if(Data.ClientSetup)then
			Data.ClientSetup(ENT)
		end
		
		function ENT:PanelFunc(um,e,entID)
			if(self.Data.EnvPanel)then
				self.Data.EnvPanel(um,e,entID) --Call any defined env panel functions.
			else
				e.Functions={}
				
				e.DevicePanel = [[
				@<Button>Fire</Button><N>PowerButton</N><Func>Power</Func>
				]]

				e.Functions.Power = function()
					RunConsoleCommand( "envsendpcommand",entID,"Power")
				end
			end
		end
		
		function ENT:LDEToolTips()
			if(not self.LDETools)then self.LDETools={} end
			if(not self.ExtraOverlayData)then self.ExtraOverlayData={} end --Make sure we have a table to add to.
			
			for i, t in pairs(self.LDETools) do
				local S=t(self)
				self.ExtraOverlayData[i]=S
			end
		end
		
		function ENT:Think()
			if(self.Data.Client)then
				self.Data.Client(self)
			end
			
			self:LDEToolTips()--Call the tooltip function.
		end
	end
	
	scripted_ents.Register(ENT, Data.class, true, true)
	print("Weapon Registered: "..Data.class)
end

//Base Weapon Code we will inject the shooting functions into.
function LDE.Weapons.RegisterLauncher(Data)
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_env_entity"
	ENT.PrintName = Data.name
	ENT.Data = Data
	ENT.HPType = Data.MountType or "None"
	ENT.IsLDEWeapon = true	
	ENT.PointCost = Data.Points or 0
	ENT.HasPoints = true
	
	ENT.Owner			= nil
	ENT.SPL				= nil
	ENT.MCDown			= 0
	ENT.CDown1			= true
	ENT.CDown1			= 0
	ENT.CDown2			= true
	ENT.CDown2			= 0
	ENT.HPType			= "Small"
	ENT.APPos			= Vector(-10,0,17)

	function ENT:SetShots( val )
		local CVal = self.Entity:GetNetworkedInt( "Shots" )
		if CVal ~= val then
			self.Entity:SetNetworkedInt( "Shots", val )
		end
	end

	list.Set( "LSEntOverlayText" , Data.class, {HasOOO = true, resnames = Data.In, genresnames = Data.Out} )
	
	if SERVER then
		function ENT:Initialize()
			self.BaseClass.Initialize(self)
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )
			self.Active = 0
			self.Mult = 1
			self.CanFire=1
			self.Charge=0
			self.LastTime=0
			
			if WireAddon then
				local V,N,A,E = "VECTOR","NORMAL","ANGLE","ENTITY"
				self.Inputs = WireLib.CreateSpecialInputs( self,
					{"Arm","Fire","GuidanceType","LockTime","X","Y","Z","Vector","WireGuidanceOnly","TargetEntity","Detonate","ManualPitch","ManualYaw","ManualRoll","ManualAngle"},
					{N,N,N,N,N,N,N,V,N,E,N,N,N,N,A}
				)
				self.Outputs = WireLib.CreateSpecialOutputs( self, 
					{ "ShotsLeft", "CanFire", "PrimaryMissileActive", "PrimaryMissilePos", "PrimaryMissileAngle", "PrimaryMissileVelocity","PrimaryMissile" },
					{N,N,N,V,A,V,E})
			end

			local phys = self.Entity:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:Wake()
				phys:EnableGravity(true)
				phys:EnableDrag(true)
				phys:EnableCollisions(true)
			end
			self:SetKeyValue("rendercolor", "255 255 255")
			self:SetNetworkedInt( "Shots", 4 )
			self.PhysObj = self:GetPhysicsObject()

			self.CDL = {}
			self.Shots = Data.Shots
			for x = 1,self.Shots do
				self.CDL[x] = 0
			end
			self.Rows = Data.Rows
			self.Cols = Data.Cols
			self.BLength = Data.BLength
			self.Lid = Data.HasLid or false
			self.Closed = self.Lid
			self.XCo = 0
			self.YCo = 0
			self.ZCo = 0
			self.GType = 0
			self.WireG = false
			self.TEnt = nil
			self.MAngle = Angle(0,0,0)
			self.LTime = 0
		end
		
		function ENT:TurnOn()
			if self.Active == 0 then
				self.Active = 1
				self:SetOOO(1)
				self:HPFire()
				self:TurnOff()
			end
		end
		
		function ENT:Touch( ent )
			if ent.HasHardpoints then
				if ent.Cont and ent.Cont:IsValid() then HPLink( ent.Cont, ent.Entity, self.Entity ) end
			end
		end
		
		function ENT:TriggerInput(iname, value)		
			if (iname == "Fire") then
				if (value > 0) then
					self:HPFire()
				end
				
			elseif (iname == "Arm") then
				if(self.Lid)then
					self.Closed = !tobool(value)
					if(self.Closed)then
						self:SetModel(Data.ClosedModel)	
					else
						self:SetModel(Data.OpenModel)	
					end
				end
				
			elseif (iname == "GuidanceType") then
				self.GType = value
			
			elseif (iname == "X") then
				self.XCo = value
				
			elseif (iname == "Y") then
				self.YCo = value
			
			elseif (iname == "Z") then
				self.ZCo = value
			
			elseif (iname == "Vector") then
				self.XCo = value.x
				self.YCo = value.y
				self.ZCo = value.z
				
			elseif (iname == "WireGuidanceOnly") then
				if (value > 0) then
					self.WireG = true
				else
					self.WireG = false
				end
			
			elseif (iname == "TargetEntity") then	
				self.TEnt = value
				
			elseif (iname == "LockTime") then
				self.LTime = value
				
			elseif (iname == "Detonate") then
				self.Detonating = value > 0
				
			elseif (iname == "ManualPitch") then
				self.MAngle.p = value
				
			elseif (iname == "ManualYaw") then
				self.MAngle.y = value
			
			elseif (iname == "ManualRoll") then
				self.MAngle.r = value
				
			elseif (iname == "ManualAngle") then
				self.MAngle = value
			
			end
		end

		function ENT:TurnOff()
			if self.Active == 1 then
				self.Active = 0
				self:SetOOO(0)
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
		
		function ENT:HPFire()
			if (CurTime() >= self.MCDown) then
				for n = 1, self.Shots do
					if (CurTime() >= self.CDL[n]) then
						if(LDE.LifeSupport.ManageResources(self,1))then
							if(not self.Closed)then
								self.Entity:FFire(n)
							end
						end
						return
					end
				end
			end
		end

		function ENT:FFire( CCD )
			if(LDE:IsInSafeZone(self) or not self.HasPoints)then return end
			local NewShell = ents.Create( self.Data.ammoclass )
			if ( !NewShell:IsValid() ) then return end
			local CVel = self.Entity:GetPhysicsObject():GetVelocity()
			local Row = table.Random(self.Rows)
			local Col = table.Random(self.Cols)
			if(self.Data.AimVec)then
				if(self.Data.AimVec=="Up")then
					NewShell:SetPos(self:GetPos() + (self:GetForward() * Row) + (self:GetRight() * Col) + (self.Entity:GetUp() * self.BLength) + CVel )
					NewShell:SetAngles( self:GetUp():Angle() )
				elseif(self.Data.AimVec=="Left")then
					NewShell:SetPos(self:GetPos() + (self:GetUp() * Row) + (self:GetForward() * Col) + (self.Entity:GetRight() * self.BLength) + CVel )
					NewShell:SetAngles( self:GetRight():Angle() )
				end
			else
				NewShell:SetPos( self.Entity:GetPos() + (self:GetUp() * Row) + (self:GetRight() * Col) + (self.Entity:GetForward() * self.BLength) + CVel )
				NewShell:SetAngles( self.Entity:GetAngles() )
			end
			NewShell.SPL = self.LDEOwner
			NewShell:Spawn()
			NewShell:Initialize()
			NewShell:Activate()
			NewShell:SetOwner(self)
			if(self.Data.AimVec)then
				if(self.Data.AimVec=="Up")then
					NewShell.PhysObj:SetVelocity(self.Entity:GetUp() * 1000)
				elseif(self.Data.AimVec=="Left")then
					NewShell.PhysObj:SetVelocity(self.Entity:GetRight() * 1000)			
				end
			else
				NewShell.PhysObj:SetVelocity(self.Entity:GetForward() * 1000)
			end
			//NewShell:Fire("kill", "", 30)
			NewShell.TEnt = self.TEnt
			local Trace = nil
			if self.Pod and self.Pod:IsValid() and self.Pod:IsVehicle() then
				local CPL = self.Pod:GetPassenger()
				if CPL and CPL:IsValid() then
					--CPL.CamCon = true
					--CPL:SetViewEntity( NewShell )
				end
				
				if self.Trace then
					Trace = self.Pod.CTrace
					NewShell.TEnt = Trace.HitEnt
				end
				NewShell.Pod = self.Pod
			end
			
			NewShell.ParL = self.Entity
			NewShell.XCo = self.XCo
			NewShell.YCo = self.YCo
			NewShell.ZCo = self.ZCo
			NewShell.GType = self.GType
			NewShell.LTime = self.LTime

			if !self.Primary or !self.Primary:IsValid() then
				self.Primary = NewShell
			end
			--RD_ConsumeResource(self, "Munitions", 1000)
			self.Entity:EmitSound("Weapon_RPG.Single")
			self.MCDown = CurTime() + 0.1 + math.Rand(0,0.2)
			self.CDL[CCD] = CurTime() + 7
		end
		
		function ENT:Think()
			local MCount = 0
			for n = 1, self.Shots do
				if CurTime() >= self.CDL[n] then
					if self.CDL[n] ~= 0 then
						self.CDL[n] = 0
						self.Entity:EmitSound("Buttons.snd26")
					end
					MCount = MCount + 1
				end
			end
			
			Wire_TriggerOutput(self.Entity, "ShotsLeft", MCount)
			self.Entity:SetShots(MCount)
			if MCount > 0 and not self.Closed then 
				Wire_TriggerOutput(self.Entity, "CanFire", 1) 
			else
				Wire_TriggerOutput(self.Entity, "CanFire", 0) 
			end
			
			if self.Pod and self.Pod:IsValid() and !self.WireG and self.Pod.Trace then
				local HPos = self.Pod.Trace.HitPos
				self.XCo = HPos.x
				self.YCo = HPos.y
				self.ZCo = HPos.z
			end
			
			if self.Primary and self.Primary:IsValid() then
				Wire_TriggerOutput(self.Entity, "PrimaryMissileActive", 1)
				Wire_TriggerOutput(self.Entity, "PrimaryMissilePos", self.Primary:GetPos() )
				Wire_TriggerOutput(self.Entity, "PrimaryMissileAngle", self.Primary:GetAngles())
				Wire_TriggerOutput(self.Entity, "PrimaryMissileVelocity", self.Primary:GetPhysicsObject():GetVelocity())
				Wire_TriggerOutput(self.Entity, "PrimaryMissile", self.Primary)
				
			else
				Wire_TriggerOutput(self.Entity, "PrimaryMissileActive", 0)
			end
			
			self.Entity:NextThink( CurTime() + 0.01 )
			return true
		end
	else
		--client
	end
	
	scripted_ents.Register(ENT, Data.class, true, true)
	print("Launcher Registered: "..Data.class)
end

//Base Code for entity missiles.
function LDE.Weapons.RegisterMissile(Data)
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_gmodentity"
	ENT.PrintName = Data.name
	ENT.Spawnable		= false
	ENT.AdminSpawnable	= false
	ENT.Armed			= false
	ENT.Exploded		= false
	ENT.MineProof		= true
	--ENT.HPType		= "Large"
	--ENT.APPos			= Vector(-100,100,-30)
	ENT.Tracking		= false
	ENT.Target			= nil
	ENT.Data = Data
	ENT.NoGrav = true
	
		function ENT:SetArmed( val )
			self.Entity:SetNetworkedBool("ClArmed",val,true)
		end

		function ENT:GetArmed()
			return self.Entity:GetNetworkedBool("ClArmed")
		end

		function ENT:SetTracking( val )
			self.Entity:SetNetworkedBool("ClTracking",val,true)
		end

		function ENT:GetTracking()
			return self.Entity:GetNetworkedBool("ClTracking")
		end
	
	if SERVER then
		function ENT:Initialize()
			self.Entity:SetModel(Data.model)
			self.Entity:SetName(Data.name)
			self.Entity:PhysicsInit( SOLID_VPHYSICS )
			self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
			self.Entity:SetSolid( SOLID_VPHYSICS )

			local phys = self.Entity:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:Wake()
				phys:EnableGravity(false)
				phys:EnableDrag(false)
				phys:EnableCollisions(true)
				phys:SetMass( 1 )
			end
			
			if(NADMOD)then
				NADMOD.SetOwnerWorld(self)
			end
			
			self.PhysObj = self.Entity:GetPhysicsObject()
			self.CAng = self.Entity:GetAngles()
			self.SpawnTime = CurTime()
			self.LTime = self.LTime or 0
			self.XCo = 0
			self.YCo = 0
			self.ZCo = 0
			self.TSClamp = 100
			self.Yaw = 0
			self.Pitch = 0
			self.Roll = 0
			self.NTT = 0
			self.DumbT = CurTime()+Data.DumbTime
			local SpreadSize = 200
			self.RSpreadX = math.Rand(-SpreadSize,SpreadSize)
			self.RSpreadY = math.Rand(-SpreadSize,SpreadSize)
			self.LeaderLastPos = Vector(0,0,0)
			self.LeaderLastAng = Angle(0,0,0)
			self.hasdamagecase = true
			util.SpriteTrail( self.Entity, 0,  Color(100,100,100,200), false, 10, 0, 1, 1, "trails/smoke.vmt" )
			self.InitSuccessful = true
		end
				
		function ENT:PhysicsUpdate()
			if(self.Exploded) then
				self.Entity:Remove()
				return
			end
		end
		
		function ENT:PhysicsCollide( data, physobj )
			if (!self.Exploded) then
				self:Splode()
			end
			self.Exploded = true
		end

		function ENT:OnTakeDamage( dmginfo )
			if (!self.Exploded) then
				self:Splode()
			end
			self.Exploded = true
		end
		
		function ENT:Splode()
			if(!self.Exploded) then
				self.Exploded = true
				util.BlastDamage(self.Entity, self.SPL, self.Entity:GetPos(), self.Data.range, self.Data.damage)
				
				if(self.Data.Nuclear and self.Data.Nuclear == true)then
					local effectdata = EffectData()
					effectdata:SetMagnitude( 1 )
					
					local Pos = self:GetPos()
					effectdata:SetOrigin( Pos )
					effectdata:SetScale( 23000 )
					
					util.Effect( "LDE_nukeflash", effectdata )
					
					self:EmitSound( "explode_9" )
					
					local ShakeIt = ents.Create( "env_shake" )
					ShakeIt:SetName("Shaker")
					ShakeIt:SetKeyValue("amplitude", "200" )
					ShakeIt:SetKeyValue("radius", "200" )
					ShakeIt:SetKeyValue("duration", "5" )
					ShakeIt:SetKeyValue("frequency", "255" )
					ShakeIt:SetPos( self:GetPos() )
					ShakeIt:Fire("StartShake", "", 0);
					ShakeIt:Spawn()
					ShakeIt:Activate()
					
					ShakeIt:Fire("kill", "", 6)
				end
				
				local effectdata = EffectData()
				effectdata:SetOrigin(self.Entity:GetPos())
				effectdata:SetStart(self.Entity:GetPos())
				util.Effect( "explosion", effectdata )
				self.Exploded = true
				
			end
			self.Exploded = true
			self:Remove()
		end

		function ENT:Think()
			if CurTime()>self.SpawnTime+self.LTime then
				local TVec = nil
				if self.GType == 1 then
					TVec = Vector(self.XCo, self.YCo, self.ZCo)
					
				elseif self.GType == 2 then
					if self.ParL and self.ParL:IsValid() then
						self.XCo = self.ParL.XCo
						self.YCo = self.ParL.YCo
						self.ZCo = self.ParL.ZCo
					end
					TVec = Vector(self.XCo, self.YCo, self.ZCo)
					
				elseif self.GType == 4 then
					if type(self.TEnt) == "Entity" and self.TEnt and self.TEnt:IsValid() then
						TVec = self.TEnt:GetPos()
					end
					
				elseif self.GType == 3 then
					if self.Target and self.Target:IsValid() then
						TVec = self.Target:GetPos()
					else
						local targets = ents.FindInCone( self.Entity:GetPos(), self.Entity:GetForward(), 5000, 65)
				
						local CMass = 0
						local CT = nil
									
						for _,i in pairs(targets) do
							if i:GetPhysicsObject() and i:GetPhysicsObject():IsValid() and !i.Autospawned then
								local IMass = i:GetPhysicsObject():GetMass()
								local IDist = (self.Entity:GetPos() - i:GetPos()):Length()
								if i.IsFlare == true then IMass = 5000 end
								local TVal = (IMass * 3) - IDist
								if TVal > CMass then
									CT = i
								end
							end
						end
						self.Target = CT
					end
					
				elseif self.GType == 5 or self.GType == 6 then
					if self.ParL and self.ParL:IsValid() then
						if self.ParL.Primary and self.ParL.Primary:IsValid() then
							if self.ParL.Primary == self then
								local Ang = self.ParL.MAngle or Angle(0,0,0)
								self.Pitch = Ang.p
								self.Yaw = Ang.y
								self.Roll = Ang.r
							else
								self.Tertiary = true
								self.LeaderLastPos = self.ParL.Primary:GetPos()
								self.LeaderLastAng = self.ParL.Primary:GetAngles()
								
								TVec = self.LeaderLastPos + (self.LeaderLastAng:Right() * self.RSpreadX ) + (self.LeaderLastAng:Up() * self.RSpreadY)
							end
						else
							self.Tertiary = true
							TVec = self.LeaderLastPos + (self.LeaderLastAng:Right() * self.RSpreadX ) + (self.LeaderLastAng:Up() * self.RSpreadY)
						end
					end
				end
				
				if(CurTime()<self.DumbT)then
				//	print(tostring(self.DumbT-CurTime()))
					if (self.GType > 0 and self.GType < 5) or (self.GType == 5 and self.Tertiary) then
						if TVec then
							local Pos = self:GetPos()
							self.Pitch = math.Clamp(self:GetUp():DotProduct( TVec - Pos ) * -0.1,-self.TSClamp,self.TSClamp)
							self.Yaw = math.Clamp(self:GetRight():DotProduct( TVec - Pos ) * -0.1,-self.TSClamp,self.TSClamp)
						else
							self.Pitch = 0
							self.Yaw = 0
						end
						
						local physi = self.Entity:GetPhysicsObject()
						physi:AddAngleVelocity((physi:GetAngleVelocity() * Vector(-1,-1,-1)) + Vector(0,self.Pitch,self.Yaw))
						physi:SetVelocity( self.Entity:GetForward() * self.Data.speed )
					elseif self.GType == 5 then
						local physi = self.Entity:GetPhysicsObject()
						physi:AddAngleVelocity((physi:GetAngleVelocity() * Vector(-1,-1,-1)) + Vector(-self.Roll * 5,-self.Pitch * 5,-self.Yaw * 5))
						physi:SetVelocity( self.Entity:GetForward() * self.Data.speed )
					elseif self.GType == 6 then
						local SAng = self:GetAngles()
						local TAng = Vector(self.Roll,self.Pitch,self.Yaw)
						local AAng = TAng - SAng
						local physi = self.Entity:GetPhysicsObject()
						physi:AddAngleVelocity((physi:GetAngleVelocity() * Vector(-1,-1,-1)) + AAng)
						physi:SetVelocity( self.Entity:GetForward() * self.Data.speed )
					end
				else
					self.NoGrav=0
				end
				
				if self.ParL and self.ParL then
					if self.ParL.Detonating then
						self:Splode()
					end
				end
				
				if CurTime() > self.NTT then
					local trace = {}
					trace.start = self.Entity:GetPos()
					trace.endpos = self.Entity:GetPos() + (self.Entity:GetVelocity())
					trace.filter = self.Entity
					local tr = util.TraceLine( trace )
					if tr.Hit and tr.HitSky then
						self.Entity:Remove()
					end
					self.NTT = CurTime() + 1
				end
			end
			
			self.Entity:NextThink( CurTime() + 0.01 )
			return true
		end
	else
		--Client stuff ;)
		killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))
	end
	scripted_ents.Register(ENT, Data.class, true, false)
	print("Missile Registered: "..Data.class)
end

//Base Code for entity bombs.
function LDE.Weapons.RegisterBomb(Data)
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_env_entity"
	ENT.PrintName = Data.name
	ENT.Armed			= false
	ENT.Exploded		= false
	ENT.Active = 0
	ENT.Data = Data
	ENT.WasMade=false
	
	function ENT:SetArmed( val )
		self.Entity:SetNetworkedBool("ClArmed",val,true)
	end

	function ENT:GetArmed()
		return self.Entity:GetNetworkedBool("ClArmed")
	end
	
	if SERVER then
		util.PrecacheSound( "explode_9" )
		util.PrecacheSound( "explode_8" )
		util.PrecacheSound( "explode_5" )
		
		function ENT:Initialize()
			self.Entity:SetName(Data.name)
			self.Entity:PhysicsInit( SOLID_VPHYSICS )
			self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
			self.Entity:SetSolid( SOLID_VPHYSICS )

			local phys = self.Entity:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:Wake()
				phys:EnableGravity(true)
				phys:EnableDrag(true)
				phys:EnableCollisions(true)
				phys:SetMass(Data.Mass)
			end
			
			if WireAddon then
				self.Inputs = Wire_CreateInputs( self.Entity, { "Arm", "Detonate" } )
			end
			
			self.PhysObj = self.Entity:GetPhysicsObject()
			self.CAng = self.Entity:GetAngles()
		end
		
		function ENT:TriggerInput(iname, value)		
			if (iname == "Arm") then
				if (value > 0) then
					self:Arm()
				end
				
			elseif (iname == "Detonate") then	
				if (value > 0) then
					if(not self.Data.touchfunc) then
						if(!self.Exploded) then
							self:ExplodeME({Range=500,Damage=100})
						end
					else
						self.Data.touchfunc(self,Data,physobj)
					end
				end
			end	
		end		
		
		function ENT:Arm()
			self.Armed = true
			self:SetArmed( true )
		end
		
		function ENT:ExplodeME(Data)
			if(not self.Armed)then return end
			self.Exploded = true
			util.BlastDamage(self.Entity, self.LDEOwner, self.Entity:GetPos(), Data.Range, Data.Damage)
		
			self:EmitSound("explode_9")
			local effectdata = EffectData() effectdata:SetOrigin(self:GetPos()) effectdata:SetStart(self:GetPos()) effectdata:SetMagnitude(3)
			util.Effect( "WhomphSplode", effectdata )
			
			local ShakeIt = ents.Create( "env_shake" ) ShakeIt:SetName("Shaker")
			ShakeIt:SetKeyValue("amplitude", "200" )
			ShakeIt:SetKeyValue("radius", "500" )
			ShakeIt:SetKeyValue("duration", "5" )
			ShakeIt:SetKeyValue("frequency", "255" )
			ShakeIt:SetPos( self.Entity:GetPos() )
			ShakeIt:Fire("StartShake", "", 0);
			ShakeIt:Spawn() ShakeIt:Activate()
			ShakeIt:Fire("kill", "", 6)
			
			self:Remove()
		end
		
		function ENT:PhysicsCollide( data, physobj )
			if(not self.Data.touchfunc) then
				if(!self.Exploded) then
					self:ExplodeME({Range=500,Damage=100})
				end
			else
				self.Data.touchfunc(self,data,physobj)
			end
		end

		function ENT:OnTakeDamage( dmginfo )
			if(not self.Data.touchfunc) then
				if(!self.Exploded) then
					self:ExplodeME({Range=500,Damage=100})
				end
			else
				self.Data.touchfunc(self,data,physobj)
			end
		end
		
		function ENT:Think()
			if(not self or not self:IsValid())then return false end --Kill it if its not valid.
			if(not self.WasMade)then self:Remove() end
			if (self.Exploded ~= true) then
				self.CAng = self:GetAngles()
			end
			
			if(self.Data.FlightFunc)then self.Data.FlightFunc(self,self.Data) end
			
			self:NextThink( CurTime() + 0.01 )
			return true
		end
	else
		--Client stuff ;)
		function ENT:Initialize()
			self.WInfo = Data.name
			self.Matt = Material( "sprites/light_glow02_add" )
		end
		
		function ENT:Draw()
			self.Entity:DrawModel()
			render.SetMaterial( self.Matt )	
			local color = Color( 200, 200, 60, 200 )
			if self:GetArmed() then
				render.DrawSprite( self.Entity:GetPos() + self.Entity:GetForward() * 30, 300, 300, color )
				render.DrawSprite( self.Entity:GetPos() + self.Entity:GetForward() * -40, 300, 300, color )
			end
		end
		
		function ENT:Think()
			if self:GetArmed() then
				local dlight = DynamicLight( self:EntIndex() )
				if ( dlight ) then
					--local r, g, b, a = self:GetColor()
					dlight.Pos = self:GetPos() + self:GetRight() * 50
					dlight.r = 200
					dlight.g = 200
					dlight.b = 60
					dlight.Brightness = 10
					dlight.Decay = 500 * 5
					dlight.Size = 400
					dlight.DieTime = CurTime() + 1
				end	
			end
		end
		
		killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))
	end
	scripted_ents.Register(ENT, Data.class, true, false)
	print("Bomb Registered: "..Data.class)
end

	local Files
	if file.FindInLua then
		Files = file.FindInLua( "lde/weapons/*.lua" )
	else//gm13
		Files = file.Find("lde/weapons/*.lua", "LUA")
	end

	--Get the weapon data from the weapons folder.
	for k, File in ipairs(Files) do
		Msg("*LDE Weapons Loading: "..File.."...\n")
		local ErrorCheck, PCallError = pcall(include, "lde/weapons/"..File)
		ErrorCheck, PCallError = pcall(AddCSLuaFile, "lde/weapons/"..File)
		if !ErrorCheck then
			Msg(PCallError.."\n")
		end
	end
	Msg("LDE Weapons Loaded: Successfully\n")
