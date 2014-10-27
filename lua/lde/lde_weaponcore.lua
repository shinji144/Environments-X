LDE.Weapons = {}

//Function that locks weapons to the models they are allowed to.
function LDE.Weapons.WeaponModelCheck(self,Models)
	if(not IsValid(self))then return false end
		
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
			if(IsValid(self.LDE.Core))then
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
				if (value ~= 0 and self.Active == 0 ) then
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
			if (not hp or hp ~= Bool) then
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
			if(not IsValid(self.LDE.Core))then
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
			
			local CF = CurTime()>=self.LastTime+self.Data.firespeed
			if CF then
				WireLib.TriggerOutput(self, "CanFire", 1)
				self:SetCanFire(1)
			else
				if(self.Data.firespeed>=1)then
					self:CantFire()
				end
			end 
			
			if self:FireWep(CF) then
				self.LastTime=CurTime()
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
		self:SetNetworkedBool("ClArmed",val,true)
	end

	function ENT:GetArmed()
		return self:GetNetworkedBool("ClArmed")
	end
	
	if SERVER then
		function ENT:Initialize()
			self:SetName(Data.name)
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )

			local phys = self:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:Wake()
				phys:EnableGravity(true)
				phys:EnableDrag(true)
				phys:EnableCollisions(true)
				phys:SetMass(Data.Mass)
			end
			
			if WireAddon then
				self.Inputs = Wire_CreateInputs( self, { "Arm", "Detonate" } )
			end
			
			self.PhysObj = self:GetPhysicsObject()
			self.CAng = self:GetAngles()
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
			if(not IsValid(self))then return false end --Kill it if its not valid.
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
				render.DrawSprite( self:GetPos() + self:GetForward() * 30, 300, 300, color )
				render.DrawSprite( self:GetPos() + self:GetForward() * -40, 300, 300, color )
			end
		end
		
		function ENT:Think()
			if self:GetArmed() then

			end
		end
		
		killicon.AddFont("seeker_missile", "CSKillIcons", "C", Color(255,80,0,255))
	end
	scripted_ents.Register(ENT, Data.class, true, false)
	print("Bomb Registered: "..Data.class)
end

local LoadFile = EnvX.LoadFile --Lel Speed.
local P = "lde/weapons/"

LoadFile(P.."lde_advdamagefuncs.lua",1)
LoadFile(P.."lde_weaponfunctions.lua",1)
LoadFile(P.."lde_turretcore.lua",1)
LoadFile(P.."lde_spacecraft.lua",1)
LoadFile(P.."lde_launchers.lua",1)
LoadFile(P.."lde_laserweps.lua",1)
LoadFile(P.."lde_exoticweps.lua",1)
LoadFile(P.."lde_cannonsweps.lua",1)
LoadFile(P.."lde_bombs.lua",1)
LoadFile(P.."lde_bulletweps.lua",1)







