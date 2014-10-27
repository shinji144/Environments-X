
//Device compiling function.
function LDE.LifeSupport.CompileSDevice(Data,Inner)
	for k,v in pairs(Inner.model) do
		Environments.RegisterDevice(Inner.Tool, Inner.Type, Inner.name[k], Inner.class, v)
	end
	LDE.LifeSupport.RegisterSDevice(Data)
end

function LDE.LifeSupport.CompleteCrate(self)
	self:StopSound( "k_lab.teleport_malfunction_sound" )
	
	print("Fab Complete!")
	
	if(not self.activeEntity or not self.activeEntity:IsValid())then return end
	self.activeEntity:SetSolid( SOLID_VPHYSICS )
	self.activeEntity:SetMaterial(self.activeEntity.Material )
	self.activeEntity:SetParent(nil)
	self.activeEntity.Constructed = true
	
	local phys = self.activeEntity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(true)
		phys:Wake()
	end
	
	self:EmitSound( "k_lab.teleport_discharge" )

	self.active = 0
	if WireAddon then Wire_TriggerOutput(self, "InUse", 0) end
end
		
function LDE.LifeSupport.BeginReplication(self, product, data, ply )
		if(not self:HasNeeded(data) or self.activeEntity and self.activeEntity:IsValid())then return end
		print("Beginning fab.")
		self:UseNeeded(data)
		self.BuildTime = data.Time
		local ent = ents.Create("factory_crate")
		ent:SetPos( self:LocalToWorld(Vector(0,0,60)) )
		ent:SetModel( data.model )
		ent:SetMaterial("models/props_combine/com_shield001a")
		ent:Spawn()
		ent.product = product
		ent.productmodel = data.model
		ent.factory = self
		ent:SetParent(self)
		ent.LDEOwner=ply

		self.activeEntity = ent
		self:EmitSound( "k_lab.teleport_malfunction_sound" )		
			
		self.timeAtStart = CurTime()
		self.active = 1
		if WireAddon then Wire_TriggerOutput(self, "InUse", 1) end	
			
	return ent

end
		
//Base Device Code we will inject the functions into.
function LDE.LifeSupport.RegisterSDevice(Data)
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_env_entity"
	ENT.PrintName = Data.name
	ENT.Data = Data
	ENT.CanRun=1
	ENT.Mult = 1
	
	if(Data.Sounds)then
		for I,b in pairs(Data.Sounds) do
			util.PrecacheSound( b )
		end
	end
	
	if(Data.Shared)then
		Data.Shared(ENT)
	end
	
	list.Set( "LSEntOverlayText" , Data.class, {HasOOO = true, resnames = Data.In or {}, genresnames = Data.Out or {}} )

	if SERVER then
		function ENT:Initialize()
			self.BaseClass.Initialize(self)
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )
			self.Active = 0
			self.multiplier = 1
			self.LastTime = 0
			if WireAddon then
				self.WireDebugName = self.PrintName
				if(Data.WireIn)then
					self.Inputs = WireLib.CreateInputs(self, Data.WireIn)
				end
				if(Data.WireOut)then
					self.Outputs = WireLib.CreateOutputs(self, Data.WireOut)
				end
			end
			if(self.Data.Initialize)then
				self.Data.Initialize(self)
			end
		end
		
		function ENT:HasNeeded(List)
			for I,b in pairs(List.materials) do  
				if(self:GetResourceAmount(b)<List.matamount[I])then 
					return false
				end
			end
			return true
		end

		function ENT:UseNeeded(List)
			for I,b in pairs(List.materials) do
				self:ConsumeResource(b, List.matamount[I])
			end
		end
	
		function ENT:TriggerInput(iname, value)
			if(self.Data.TrigIn)then
				self.Data.TrigIn(self,iname,value)
			end
		end

		function ENT:AcceptInput( name, activator, caller )
			if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then			
				if(self.Data.PlyUse)then
					self.Data.PlyUse(self,name,activator,caller)
				end			
			end
		end

		function ENT:Think()
			if(CurTime()>=self.LastTime+1)then
				self.LastTime=CurTime()
				if(self.Data.Think)then
					self.Data.Think(self)
				end
			end
			self:NextThink(CurTime() + 1)
			return true
		end
	else
		if(Data.Client)then
			Data.Client(ENT)
		end
	end
	
	scripted_ents.Register(ENT, Data.class, true, true)
	print("Device Registered: "..Data.class)
end

--Materialiser Factory
local Base = {Tool="Life Support",Type="Fabricators"}

local PlyUse = function(self,name,activator,caller)
	if(not self.Create)then
		umsg.Start("envFactoryTrigger",caller)
		umsg.String(self:GetCreationID())
		umsg.Entity(self);
		umsg.End()
		self.Player = caller;
	end
end

local TrigIn = function(self,iname,value)
	if (iname == "Item") then
		self.WireItem = value
	end       
	if (iname == "Materialise") then
		if (value > 0) then
			local BuildList = LDE.Factorys.BuildList
			for k,v in pairs(BuildList) do
				if(self.WireItem==v.name)then
					LDE.LifeSupport.BeginReplication(self,v.Class, v)
					break
				end
			end
		end
	end
end

local Think = function(self)
	if self.active == 1 then		
		if CurTime() >= (self.timeAtStart + self.BuildTime) then
			LDE.LifeSupport.CompleteCrate(self)
		end
	end
end

local Sounds = {"k_lab.teleport_malfunction_sound","k_lab.teleport_discharge","WeaponDissolve.Beam","WeaponDissolve.Dissolve"}
local Data={name="Item Materialiser",class="env_factory",PlyUse=PlyUse,TrigIn=TrigIn,Think=Think,Sounds=Sounds}
local Makeup = {name={"Item Materialiser"},model={"models/slyfo/swordreconlauncher.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileSDevice(Data,Makeup)

--Edible Foods
local Initialize = function(self) self:SetNWInt("LDEFoodType", self.Data.name) self:SetNWInt("LDEFoodEffect", self.Data.Effect) end
local Client = function(ENT)
	function ENT:Draw()      
		self:DrawDisplayTip()
		self:DrawModel()
	end

	local TipColor = Color( 250, 250, 200, 255 )

	surface.CreateFont("GModWorldtip", {font = "coolvetica", size = 24, weight = 500})
		
	function ENT:DrawDisplayTip()
		if ( LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance( self:GetPos() ) < 512) then
		
			local temp = self:GetNWString("LDEFoodType")
			local text = "Food: "..temp.."\n"
			
			temp = self:GetNWString("LDEFoodEffect")
			text = text.."Effect: "..temp
			
			AddWorldTip( self:EntIndex(), text, 0.5, self:GetPos(), self  )
		end
	end
end

--StriderNuggets
local PlyUse = function(self,name,Activator,caller)
	if(Activator:IsPlayer())then
		local Debuff = {
			Tick 		= function(ply) LDE:HealPlayer(ply,30) end,
			OnDeath 	= function(ply,Ext) end,
			OnStart 	= function(ply) ply:SendColorChat("Alert",{r=0,g=255,b=0},"You've Been Given Regeration!") end, --Add notification that players got infected.
			OnTimeEnd 	= function(ply) end,
			OnRemove 	= function(ply) ply:SendColorChat("Alert",{r=255,g=0,b=0},"You are no longer being regenerated!") end, --Add notification that its done.
			OnDamage 	= function(ply,Ext) end,
			OnKill 		= function(ply,Ext) end
		}
		Activator:GiveMutation("Regeneration",5,Debuff,false,true)
	end
	self:Remove()
end
local Effect = "Gives 5-Seconds Health Regen."
local Data={name="Strider Nuggets",class="food_snuggets",Effect=Effect,PlyUse=PlyUse,Think=Think,Initialize=Initialize,Client=Client}
LDE.LifeSupport.RegisterSDevice(Data)

--One Unit Food
local PlyUse = function(self,name,activator,caller) LDE:HealPlayer(activator,50) self:Remove() end
local Effect = "Heals 50 Health."
local Data={name="One Unit Food",class="food_1uf",Effect=Effect,PlyUse=PlyUse,Think=Think,Initialize=Initialize,Client=Client}
LDE.LifeSupport.RegisterSDevice(Data)

--SpaceMix
local PlyUse = function(self,name,activator,caller) LDE:HealPlayer(activator,100) self:Remove() end
local Effect = "Heals 100 Health."
local Data={name="SpaceMix",class="food_smix",Effect=Effect,PlyUse=PlyUse,Think=Think,Initialize=Initialize,Client=Client}
LDE.LifeSupport.RegisterSDevice(Data)

--Sbeptos
local PlyUse = function(self,name,activator,caller) LDE:HealPlayer(activator,20) self:Remove() end
local Effect = "Heals 20 Health."
local Data={name="Sbeptos",class="food_sbeptos",Effect=Effect,PlyUse=PlyUse,Think=Think,Initialize=Initialize,Client=Client}
LDE.LifeSupport.RegisterSDevice(Data)

--Cup-O-Noodle
local PlyUse = function(self,name,activator,caller) LDE:HealPlayer(activator,200) self:Remove() end
local Effect = "Heals 200 Health."
local Data={name="Cup-O-Noodle",class="food_cuponood",Effect=Effect,PlyUse=PlyUse,Think=Think,Initialize=Initialize,Client=Client}
LDE.LifeSupport.RegisterSDevice(Data)

--Spore Vaccine
local PlyUse = function(self,name,activator,caller) activator:RemoveMutation("Sporefection") self:Remove() end
local Effect = "Cures Sporefections."
local Data={name="S-Vaccine",class="food_sporecure",Effect=Effect,PlyUse=PlyUse,Think=Think,Initialize=Initialize,Client=Client}
LDE.LifeSupport.RegisterSDevice(Data)


