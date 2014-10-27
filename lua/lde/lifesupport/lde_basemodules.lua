

//Make our table
LDE.LifeSupport.Bases={}


//Check if a base can afford that shiny new module players want.
function LDE.LifeSupport.Bases.AffordModule(self,Core)
	local Costs = self.Data.Costs
	if(Core:HasNeededResources(Costs))then
		Core:UseResources(Costs)
		return true
	end
	return false --They couldnt afford it.
end

LDE.LifeSupport.Bases.WeaponStats = {
	Clip="Clip",
	ReloadTime="ReloadTime",
	Range="Range",
	FireRate="firespeed"
}
LDE.LifeSupport.Bases.SecondaryStats = {
	DroneCount="Drones",
	ShieldRegen="Regen",
	SaftyRange="SafeR",
	Range="Range",
	Damage="Damage",
	Speed="Speed",
	Spread="Spread"
}

local GStats={}
GStats["Power"]="Power"
GStats["Refined Mass"]="Refined Mass"
GStats["Raw Mass"]="Raw Mass"
GStats["Ammunition"]="Ammunition"

LDE.LifeSupport.Bases.GeneratorStats = GStats
	


//Function that compiles a modules tool tip.
function LDE.LifeSupport.Bases.CreateBaseToolTip(Data)
	local ToolTip=Data.name
	
	if(Data.Desc)then
		ToolTip=ToolTip.." \n"..Data.Desc
	end
	
	ToolTip=ToolTip.."\nPrice:"
	for k,v in pairs(Data.Costs) do
		ToolTip=ToolTip.."\n"..k..": "..v
	end
	
	ToolTip=ToolTip.." \nBuildTime: "..Data.BuildTime.." \nHealth: "..Data.Health
	
	if(Data.IsTurret)then
		for k,v in pairs(LDE.LifeSupport.Bases.WeaponStats) do
			if(Data[v])then
				ToolTip=ToolTip.."\n"..k..": "..Data[v]
			end
		end
		for k,v in pairs(LDE.LifeSupport.Bases.SecondaryStats) do
			if(Data.Bullet[v])then
				ToolTip=ToolTip.."\n"..k..": "..Data.Bullet[v]
			end
		end
	else
		for k,v in pairs(LDE.LifeSupport.Bases.SecondaryStats) do
			if(Data.Extra[v])then
				ToolTip=ToolTip.."\n"..k..": "..Data.Extra[v]
			end
		end
	end
	
	if(Data.Extra.Make)then
		ToolTip=ToolTip.."\nGenerates:"
		for k,v in pairs(LDE.LifeSupport.Bases.GeneratorStats) do
			if(Data.Extra.Make[v])then
				ToolTip=ToolTip.."\n"..k..": "..Data.Extra.Make[v]
			end
		end
	end
	if(Data.Extra.Need)then
		ToolTip=ToolTip.."\nConsumes:"
		for k,v in pairs(LDE.LifeSupport.Bases.GeneratorStats) do
			if(Data.Extra.Need[v])then
				ToolTip=ToolTip.."\n"..k..": "..Data.Extra.Need[v]
			end
		end
	end
		
	return ToolTip
end

//Base Device Code we will inject the functions into.
function LDE.LifeSupport.Bases.RegisterBaseModule(Data,Inner)
	local ToolTip = LDE.LifeSupport.Bases.CreateBaseToolTip(Data)
	for k,v in pairs(Inner.model) do
		Environments.RegisterDevice("Base Construction", Inner.Type, Inner.name[k], Inner.class, v,1,1,Inner.name[k],ToolTip)
	end
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_env_entity"
	ENT.PrintName = Data.name
	ENT.Data = table.Copy(Data)
	ENT.IsConstructed = false
	
	list.Set( "LSEntOverlayText" , Data.class, {HasOOO = true, resnames = Data.In or {}, genresnames = Data.Out or {}} )
	
	if SERVER then
	
		function ENT:OnPurchase()
			local Core = self.LDEOwner.Base
			if(Core and Core:IsValid())then
				if(LDE.LifeSupport.Bases.AffordModule(self,Core))then
					--self:Link(Core)
					Core:Link(self)
					self.Data.OnLink(Core,self)
					--print("Base Core Found!")
					
					local effectent = self.effectent
					
					effectent:SetMaterial("")
					
					local ed = EffectData()
					ed:SetEntity(effectent)
					ed:SetScale(self.Data.BuildTime)
					util.Effect("basebuildeffect", ed, true, true)
					
					self.Data.PreBuild(self)
					self.BuildStart = CurTime()
					self:SetNWInt("LDEIsDuped",0)
				end
			else
				self:SetNWInt("LDEIsDuped",1)
			end
		end
	
		function ENT:Initialize()
			self.BaseClass.Initialize(self)
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )
										
			local effectent = ents.Create("dummyent")
			effectent:SetModel(self:GetModel())
			effectent:SetMaterial("models/wireframe")
			effectent:SetPos(self:GetPos())
			effectent:SetAngles(self:GetAngles())
			effectent:SetParent(self)
			self.effectent=effectent
			self:SetNWInt("LDEIsDuped",0)

			timer.Simple(0.8,function()
				if(not self.Duped)then
					self:OnPurchase()
				end
			end)
			
			self.LDEHealth = self.Data.Health
			self.LDEMaxHealth = self.Data.Health
			
			self:SetNWInt("LDECoreType", self.Data.name)
			self:SetNWInt("LDETechLevel",1)
			self:SetNWInt("LDEIsBuilt",0)
			self.LastFire=CurTime() 
			self.Shots=0
			self.TechLevel=1
			self.IsReloading = true 
			self.IsConstructed=false
			
			self.Stats={}
			
			for name,value  in pairs(self.Data.Extra) do
				self.Stats[name]=value
			end
		end
		
		function ENT:AquireTarget(Over)
			local Core=self.LDE.Core --Grab our core.
			local Targets = Core.Targets --Grab the targeting list.
			for k, v in pairs(Targets) do
				if(v:IsValid())then
					local Distance = self:GetPos():Distance(v:GetPos())
					if(Distance<self.Data.Range)then
						self.TraceTarg=v:GetPos()
						local Trace =LDE.Weapons.DoTrace(self,self.Data.Bullet)
						local OwnerCheck = false
						if(Trace.Entity and Trace.Entity.LDEOwner==self.LDEOwner)then
							OwnerCheck = true
						end
						
						if(not Trace.HitWorld and not OwnerCheck)then
							if(not v.LDETagged or not v.LDETagged:IsValid() or Over)then
								self.Target=v
								v.LDETagged=self--Tag the target so other turrets dont shoot it.
								--print("Target aquired!")
								return true
							end
						end
					end
				end
			end
			--print("Couldnt find a target :/")
			return false
		end
		
		function ENT:HasNeededResources(List)
			if(List)then
				for I,b in pairs(List) do  
					if(self:GetResourceAmount(I)<b)then
						return false
					end
				end
			end
			return true
		end
		
		function ENT:UseResources(List)
			for I,b in pairs(List) do
				self:ConsumeResource(I,b)
			end
		end
		
		function ENT:MakeResources(List)
			for I,b in pairs(List) do
				self:SupplyResource(I,b)
			end
		end
		
		function ENT:ManageResources(Use,Make)
			if(self:HasNeededResources(Use))then
				self:UseResources(Use)
				if(Make)then
					self:MakeResources(Make)
				end
				return true --Woot
			end
			return false --NOPE.avi
		end
		
		function ENT:HandleWeapon()
			if(not self.Data.IsTurret)then return end
			if(self.LastFire+self.Data.firespeed<CurTime())then
				if(self.Shots<self.Data.Clip and not self.IsReloading)then
					if(not self.Target or not self.Target:IsValid())then
						if(not self:AquireTarget(false))then
							self:AquireTarget(true)--If we cant find our own target, lets help another turret with theirs.
						end
					else
						--self.TraceTarg=self.Target:GetPos()+(self.Target:GetVelocity()/2)
						self.TraceTarg=self.Data.WeaponAiming(self,self.Target)
						local Trace =LDE.Weapons.DoTrace(self,self.Data.Bullet)
						local Distance = self:GetPos():Distance(self.TraceTarg)
						if(not Trace.HitWorld and Distance<self.Data.Range)then
							local Data = self.Data.Bullet
							self.Data.Weapon(self,Data)

							if(self.Data.Bullet.FireSound)then
								self:EmitSound(self.Data.Bullet.FireSound)
							end
							self.LastFire=CurTime()
							self.Shots=self.Shots+1
						else
							self.Target = nil --We lost visual on our target :(
						end
					end
				else
					if(not self.IsReloading)then
						self.IsReloading = true
					else
						if(self.LastFire+self.Data.Reload<CurTime())then
							--if(LDE.LifeSupport.ManageResources(self,1))then
							if(self:ManageResources(self.Stats.Need))then
								self.Shots=0
								self.IsReloading=false
							else
								self.LastFire=CurTime()
							end
						end
					end
				end
			end	
		end
		
		function ENT:ConstructionFinish(Core)
			if(not self.IsConstructed)then
				self.IsConstructed = true
				self.effectent:Remove()
				self:SetNWInt("LDEIsBuilt",1)
				self.Data.BuildFinish(Core,self)
				
				local RND = math.random(1,10)
				local Snd = ""
				if(RND>5)then
					Snd="weapons/physcannon/energy_disintegrate5.wav"
				else
					Snd="weapons/physcannon/energy_disintegrate4.wav"
				end
				
				self:EmitSound(Snd)
				
				self:Unlink()
				
				if(self.Data.storage)then
					self.maxresources=self.Data.storage
				end
				
				self:Link(self.LDEOwner.Base)
				self.LDEOwner.Base:Link(self)
				--print("DING")
			else
				print("Error Module already built!!!")
			end
		end
		
		function ENT:HandleConstruction(Core)
			if(self.BuildStart+self.Data.BuildTime<=CurTime())then
				self:ConstructionFinish(Core)
			else
				self.Data.BuildThink(Core,self)
			end
		end
		
		function ENT:BaseModuleThink(Core)
			if(self:GetNWInt("LDEIsDuped")>0)then return end
			if(Core and Core:IsValid())then
				if(self.IsConstructed)then
					self.Data.Think(Core,self)
				else
					self:HandleConstruction(Core)
				--	print("Building")
				end
			end
		end
		
		function ENT:OnUpgrade()
			local Level = self:GetNWInt("LDETechLevel")
			local ModCost = self.Data.UpgradeCost
			local Cost = ModCost+((Level/2)*ModCost)

			if(self:GetResourceAmount("Scrap")>=Cost)then
				self:ConsumeResource("Scrap",Cost)
				self.Data.Upgrade(self,Level+1)
				self:SetNWInt("LDETechLevel",Level+1)
				self.TechLevel=Level+1
			end
		end
		
		function ENT:Think()
			if(not self.LDE or not self.LDE.Core)then return end
			local Core = self.LDE.Core
			if(not self.IsConstructed or not Core or not Core:IsValid())then return end --Make sure the module is complete before doing fast thinks.
			self.Data.FastThink(self)
			self:HandleWeapon()
		end
		
		--Override the base environments dupe function.
		function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
			Ent.Duped = true
			Ent:SetNWInt("LDEIsDuped",1)
			Environments.ApplyDupeInfo(Ent, CreatedEntities, Player)
			if WireLib and (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
				WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
			end
		end

		local T = {} --Create a empty Table
		
		T.Upgrade = function(Device,ply,Data)
			Device:OnUpgrade()
		end
		
		T.Purchase = function(Device,ply,Data)
			Device:OnPurchase()
		end
		
		ENT.Panel=T --Set our panel functions to the table.
	
	else
	
		function ENT:PanelFunc(um,e,entID)

			e.Functions={}
			
			local BuyMe = self:GetNWInt("LDEIsDuped") or 0
			
			if(BuyMe>0)then
				e.DevicePanel = [[
				@<Button>Purchase Module</Button><N>BuyButton</N><Func>Purchase</Func>
				]]			
			else
				e.DevicePanel = [[
				@<Button>Upgrade Module</Button><N>UpgradeButton</N><Func>Upgrade</Func>
				@<Custom>Display</Custom><N>CostDisplay</N><Func>GetUpCost</Func><SetText>Loading</SetText>
				]]
			end
			
			e.Functions.Upgrade = function()
				RunConsoleCommand( "envsendpcommand",entID,"Upgrade")
			end
			
			e.Functions.Purchase = function()
				RunConsoleCommand( "envsendpcommand",entID,"Purchase")
			end
			
			e.Functions.GetBuyCost = function()
				return ""
			end
			
			e.Functions.GetUpCost = function()
				local Level = self:GetNWInt("LDETechLevel") or 1
				local Cost = self.Data.UpgradeCost or 100
				
				return "Current Level: "..Level.." NextCost: "..Cost+((Level/2)*Cost).." \n"..self.Data.UpdateText(self,Level)
			end	
		end
	
		function ENT:Draw()      
			local IsBuilt = self:GetNWInt("LDEIsBuilt") or 0
			if(IsBuilt>0)then
				self:DrawDisplayTip()
				self.Data.Render(self)
				self:DrawModel()
			end
		end

		local ResourceUnits = {}
		local ResourceNames = {}

		local TipColor = Color( 250, 250, 200, 255 )

		surface.CreateFont("GModWorldtip", {font = "coolvetica", size = 24, weight = 500})
			
		function ENT:DrawDisplayTip()
			if ( LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance( self:GetPos() ) < 512) then
				local node = self.node
				local OverlaySettings = list.Get( "LSEntOverlayText" )[self:GetClass()] --replace this
				local resnames = OverlaySettings.resnames
				local genresnames = OverlaySettings.genresnames
				
				local text = "Modular Base Module \n Type: "..(self:GetNWString("LDECoreType") or "Error").." \n"
				
				temp = self:GetPlayerName() or "Null"
				text = text.."Owner: "..temp.."\n"
				
				temp = self:GetNWInt("LDETechLevel") or 1
				text = text.."Tech Level: "..temp.."\n"
				
				local resources = self.resources
				if resnames and table.Count(resnames) > 0 then
					for _, k in pairs(resnames) do
						if node and node:IsValid() then
							if(not node.resources_last or not node.resources)then return end
							if node.resources_last[k] and node.resources[k] then
								local diff = CurTime() - node.last_update[k]
								if diff > 1 then
									diff = 1
								end
								
								local amt = math.Round(node.resources_last[k] + (node.resources[k] - node.resources_last[k])*diff)
								text = text ..(ResourceNames[k] or k)..": ".. (amt) .."/".. (node.maxresources[k] or 0) .. (ResourceUnits[k] or "") .."\n"
							else
								text = text ..(ResourceNames[k] or k)..": ".. (node.resources[k] or 0) .."/".. (node.maxresources[k] or 0) .. (ResourceUnits[k] or "") .."\n"
							end
						else
							text = text ..(ResourceNames[k] or k)..": 0/".. (self.maxresources[k] or 0) .."\n"
						end
					end
				end
				if genresnames and table.Count(genresnames) > 0 then
					text = text.."\nGenerates:\n"
					for _, k in pairs(genresnames) do
						if node and node:IsValid() then
							if(not node.resources_last or not node.resources)then return end
							if node.resources_last[k] and node.resources[k] then
								local diff = CurTime() - node.last_update[k]
								if diff > 1 then
									diff = 1
								end
								
								local amt = math.Round(node.resources_last[k] + (node.resources[k] - node.resources_last[k])*diff)
								text = text ..(ResourceNames[k] or k)..": ".. (amt) .."/".. (node.maxresources[k] or 0) .. (ResourceUnits[k] or "") .."\n"
							else
								text = text ..(ResourceNames[k] or k)..": ".. (node.resources[k] or 0) .."/".. (node.maxresources[k] or 0) .. (ResourceUnits[k] or "") .."\n"
							end
						else
							text = text ..(ResourceNames[k] or k)..": 0/0\n"
						end
					end
				end
				AddWorldTip( self:EntIndex(), text, 0.5, self:GetPos(), self  )
			end
		end
	end
	
	scripted_ents.Register(ENT, Data.class, true, true)
	print("Base Module Registered: "..Data.class)
end

local BaseData = {
class = "example", 
name = "Example",
Costs = {},
UpgradeCost = 100,
Upgrade = function(self,Level) end,
UpdateText= function(self,Level) return "" end,
PreBuild = function(self) end,
Think = function(Core,self) end,
BuildThink = function(Core,self) end,
BuildFinish = function(Core,self) end,
OnDeath = function(self) end,
FastThink = function(self) end,
Render = function(self) end,
OnLink = function(self) end,
Weapon = function(self) end,
WeaponAiming =function(self,Target) return Target:GetPos() end,
Health = 100,
BuildTime = 1,
Clip=1,
Reload=1,
Range=4000,
firespeed=1,
IsTurret=false,
Bullet={},
Out={},
Weapons={},
Extra={}
}

local Arrow=" => "
local NL = " \n"

------Scrap Collection------
local Data = table.Copy(BaseData)
Data["class"] = "base_scrapcollect"
Data["name"] = "Scrap Drone Pad"
Data["Costs"]["Refined Mass"]=2000
Data["Extra"]={Drones=1}
Data["UpgradeCost"]=200
Data["Upgrade"]=function(self,Level)
	local Stats = self.Stats
	Stats.Drones=Level
	self.LDEHealth=1000+((Level-1)*500)
	self.LDEMaxHealth=1000+((Level-1)*500)
end
Data["UpdateText"]=function(self,Level)
	local L1 = "Drones: "..Level..Arrow..(Level+1)..NL
	local L2 = "Health: "..(1000)+((Level-1)*500)..Arrow..(1000)+((Level)*500)
	return L1..L2
end
Data["Health"] = 1000
Data["BuildTime"] = 10
Data["In"]={"Refined Mass"}
Data["InUse"]={2000}
Data["Out"]={"Scrap"}
Data["OutMake"]={0}
Data["storage"] = {Power=500000}
Data["PreBuild"]=function(self) self.Drones = {} end
Data["Think"]=function(Core,self) 
	local DCount = table.Count(self.Drones)
	if(DCount>0)then
		for k,v in pairs(self.Drones) do
			if(not v or not v:IsValid())then
				table.remove(self.Drones,k)
			end
		end
	end
	if(DCount<self.Stats.Drones)then
		if(LDE.LifeSupport.ManageResources(self,1))then
			local scrap = ents.Create("base_scrapdrone")
			scrap:SetPos(self:LocalToWorld(Vector(0,0,5)))
			scrap:SetModel( "models/Spacebuild/Nova/drone2.mdl" )
			scrap:Spawn()
			scrap.Pad = self
			self.Drones[DCount+1]=scrap
			self.LDE.Core:Link(scrap)
		end
	end
end
local Makeup = {name={"Scrap Drone Pad"},model={"models/SBEP_community/ssnavalbase.mdl"},Type="Resource Management",class=Data.class}
LDE.LifeSupport.Bases.RegisterBaseModule(Data,Makeup)

------Fusion Genator------
local Data = table.Copy(BaseData)
Data["class"] = "base_energygen"
Data["name"] = "Fusion Generator"
Data["Costs"]["Refined Mass"]=1000
Data["Extra"] = {HP=4000,Make={Power=4000}}
Data["Out"]={"Power"}
Data["UpgradeCost"]=40
Data["Upgrade"]=function(self,Level)
	local Stats = self.Stats
	Stats.Make.Power=4000+((Level-1)*2000)
	self.LDEHealth=4000+((Level-1)*500)
	self.LDEMaxHealth=4000+((Level-1)*500)
end
Data["UpdateText"]=function(self,Level)
	local L1= "Power Out: "..(4000+((Level-1)*2000))..Arrow..(4000+((Level)*2000))..NL
	local L2="Health: "..(4000)+((Level-1)*500)..Arrow..(4000)+((Level)*500)
	return L1..L2
end
Data["Health"] = Data.Extra.HP
Data["BuildTime"] = 5
Data["storage"] = {Power=500000}
Data["Think"]=function(Core,self)self:MakeResources(self.Stats.Make) end
local Makeup = {name={"Fusion Generator"},model={"models/ce_ls3additional/fusion_generator/fusion_generator_medium.mdl"},Type="Resource Management",class=Data.class}
LDE.LifeSupport.Bases.RegisterBaseModule(Data,Makeup)

------Mass Drill------
local Data = table.Copy(BaseData)
Data["class"] = "base_massdrill"
Data["name"] = "Mass Drill"
Data["Costs"]["Refined Mass"]=1000
local Make = {} Make["Raw Mass"]=8
Data["Extra"] = {HP=3000,Need={Power=2000},Make=Make}
Data["Health"] = Data.Extra.HP
Data["BuildTime"] = 10
Data["In"]={"Power"}
Data["Out"]={"Raw Mass"}
Data["UpgradeCost"]=50
Data["Upgrade"]=function(self,Level)
	local Stats = self.Stats
	Stats.Make["Raw Mass"]=8+(Level-1)
	Stats.Need.Power=2000+((Level-1)*100)
	self.LDEHealth=3000+((Level-1)*200)
	self.LDEMaxHealth=3000+((Level-1)*200)
end
Data["UpdateText"]=function(self,Level)
	local L1="Raw Mass Out: "..(8+(Level-1))..Arrow..(8+(Level))..NL
	local L2="Power Use: "..(2000+((Level-1)*100))..Arrow..(2000+((Level)*100))..NL
	local L3="Health: "..(3000)+((Level-1)*200)..Arrow..(3000)+((Level)*200)
	return L1..L2..L3
end
Data["storage"] = {Power=5000}
Data["storage"]["Raw Mass"]=10000
Data["Think"]=function(Core,self) self:ManageResources(self.Stats.Need,self.Stats.Make) end
local Makeup = {name={"Mass Drill"},model={"models/Slyfo/drillplatform.mdl"},Type="Resource Management",class=Data.class}
LDE.LifeSupport.Bases.RegisterBaseModule(Data,Makeup)

------Mass Refinery------
local Data = table.Copy(BaseData)
Data["class"] = "base_massrefine"
Data["name"] = "Mass Refinery"
Data["Costs"]["Refined Mass"]=5000
local Make = {} Make["Refined Mass"]=14
local Need = {Power=500} Need["Raw Mass"]=12
Data["Extra"] = {HP=14000,Need=Need,Make=Make}
Data["Health"] = Data.Extra.HP
Data["BuildTime"] = 25
Data["In"]={"Power","Raw Mass"}
Data["Out"]={"Refined Mass"}
Data["UpgradeCost"]=50
Data["Upgrade"]=function(self,Level)
	local Stats = self.Stats
	Stats.Make["Refined Mass"]=14+((Level-1)*2)
	Stats.Need["Raw Mass"]=12+((Level-1))
	Stats.Need.Power=500+((Level-1)*50)
	self.LDEHealth=14000+((Level-1)*1000)
	self.LDEMaxHealth=14000+((Level-1)*1000)
end
Data["UpdateText"]=function(self,Level)
	local L1="Refined Mass Out: "..(8+(Level-1))..Arrow..(8+(Level))..NL
	local L2="Power Use: "..(500+((Level-1)*50))..Arrow..(500+((Level)*50))..NL
	local L3="Raw Mass Use: "..(12+((Level-1)))..Arrow..(12+((Level)))..NL
	local L4="Health: "..(14000)+((Level-1)*1000)..Arrow..(14000)+((Level)*1000)
	return L1..L2..L3..L4
end
Data["storage"] = {Power=5000}
Data["storage"]["Raw Mass"]=10000
Data["storage"]["Refined Mass"]=20000
Data["Think"]=function(Core,self) self:ManageResources(self.Stats.Need,self.Stats.Make) end
local Makeup = {name={"Mass Refinery"},model={"models/Slyfo/refinery_small.mdl"},Type="Resource Management",class=Data.class}
LDE.LifeSupport.Bases.RegisterBaseModule(Data,Makeup)

------Ammunition Factory------
local Data = table.Copy(BaseData)
Data["class"] = "base_ammofact"
Data["name"] = "Ammunition Factory"
Data["Costs"]["Refined Mass"]=5000
local Make = {} Make["Ammunition"]=30
local Need = {Power=500} Need["Refined Mass"]=10
Data["Extra"] = {HP=14000,Need=Need,Make=Make}
Data["Health"] = Data.Extra.HP
Data["BuildTime"] = 25
Data["In"]={"Power","Refined Mass"}
Data["Out"]={"Ammunition"}
Data["UpgradeCost"]=50
Data["Upgrade"]=function(self,Level)
	local Stats = self.Stats
	Stats.Make["Ammunition"]=30+((Level-1)*5)
	Stats.Need["Refined Mass"]=10+((Level-1))
	Stats.Need.Power=500+((Level-1)*50)
	self.LDEHealth=14000+((Level-1)*1000)
	self.LDEMaxHealth=14000+((Level-1)*1000)
end
Data["UpdateText"]=function(self,Level)
	local L1="Ammunition Out: "..(30+((Level-1)*5))..Arrow..(8+((Level)*5))..NL
	local L2="Power Use: "..(500+((Level-1)*50))..Arrow..(500+((Level)*50))..NL
	local L3="Refined Mass Use: "..(10+((Level-1)))..Arrow..(10+((Level)))..NL
	local L4="Health: "..(14000)+((Level-1)*1000)..Arrow..(14000)+((Level)*1000)
	return L1..L2..L3..L4
end
Data["storage"] = {Power=2000}
Data["storage"]["Refined Mass"]=5000
Data["storage"]["Ammunition"]=20000
Data["Think"]=function(Core,self) self:ManageResources(self.Stats.Need,self.Stats.Make) end
local Makeup = {name={"Ammo Fabricator"},model={"models/Slyfo/refinery_small.mdl"},Type="Resource Management",class=Data.class}
LDE.LifeSupport.Bases.RegisterBaseModule(Data,Makeup)

------Laser Turret-------
local Data = table.Copy(BaseData)
Data["class"] = "base_laserturr"
Data["name"] = "LaserTurret"
Data["Costs"]["Refined Mass"]=200
Data["Extra"]={HP=1500,Need={Power=2000}}
Data["IsTurret"]=true
Data["Health"] = Data.Extra.HP
Data["BuildTime"] = 6
Data["In"]={"Power"}
Data["heat"]=50
Data["firespeed"]=1.2
Data["Range"]=3500
Data["storage"] = {Power=10000}
Data["Bullet"]={Damage=100,heat=0.5,ShootDir=Vector(0,0,1),ShootPos=Vector(0,0,80),Effect={Beam="LDE_laserbeam",Hit="LDE_laserhiteffect"},FireSound="weapons/bison_main_shot_01.wav"}
Data["Weapon"]=function(self,Data)
	LDE.Weapons.FireLaser(self,Data)
end

local Makeup = {name={"Basic Laser Turret"},model={"models/Slyfo_2/miscequipmentfieldgen.mdl"},Type="Turrets",class=Data.class}
LDE.LifeSupport.Bases.RegisterBaseModule(Data,Makeup)

------MachineGun Turret-------
local Data = table.Copy(BaseData)
Data["class"] = "base_machinegunturr"
Data["name"] = "MachineGun Turret"
Data["Costs"]["Refined Mass"]=500
local Need = {} Need["Ammunition"]=10
Data["Extra"]={HP=1500,Need=Need}
Data["IsTurret"]=true
Data["Health"] = Data.Extra.HP
Data["BuildTime"] = 10
Data["heat"]=50
Data["firespeed"]=0.05
Data["Range"]=4300
Data["Clip"]=10
Data["Reload"]=3
Data["In"]={"Ammunition"}
Data["storage"] = {}
Data["storage"]["Ammunition"]=2000
Data["Bullet"]={Number=1,Damage=300,Speed=180,Spread=2,heat=10,ShootPos=Vector(0,0,80),FireSound="npc/turret_floor/shoot1.wav"}
Data["WeaponAiming"]=function(self,Target) return Target:GetPos()+(Target:GetVelocity()/2) end
Data["Weapon"]=function(self,Data)
	vStart = self:LocalToWorld(Data.ShootPos)
	vForward = (self.TraceTarg-vStart)
	
	local Bullet = {}
	Bullet.Count = Data.Number or 1
	Bullet.ShootPos = vStart
	Bullet.Direction = vForward --Position * -1,
	Bullet.Spread = Data.Spread or 0
	Bullet.Attacker = self.LDEOwner
	Bullet.ProjSpeed = Data.Speed or 50
	Bullet.Drop=0
	Bullet.Model = Data.Model or "models/Items/AR2_Grenade.mdl"
	Bullet.Ignore = self
	Bullet.Data=Data
	Bullet.Inflictor = self
	Bullet.OnHit = function (tr, Bullet)
		local Data = Bullet.Data
		if(Data.BulletFunc)then
			Data.BulletFunc(Bullet.Inflictor,Data,Data.Damage,tr)
		else
			LDE:DealDamage(tr.Entity,Data.Damage,Bullet.Attacker,Bullet.Inflictor)
		end
	end
	LDE:FireProjectile(Bullet)
end

local Makeup = {name={"MachineGun Turret"},model={"models/Slyfo_2/miscequipmentfieldgen.mdl"},Type="Turrets",class=Data.class}
LDE.LifeSupport.Bases.RegisterBaseModule(Data,Makeup)

------Cannon Turret-------
local Data = table.Copy(BaseData)
Data["class"] = "base_cannonturr"
Data["name"] = "Cannon Turret"
Data["Costs"]["Refined Mass"]=10000
local Need = {} Need["Ammunition"]=100
Data["Extra"]={HP=3500,Need=Need}
Data["IsTurret"]=true
Data["Health"] = Data.Extra.HP
Data["BuildTime"] = 20
Data["heat"]=50
Data["firespeed"]=1
Data["Range"]=4300
Data["Clip"]=3
Data["Reload"]=5
Data["In"]={"Ammunition"}
Data["storage"] = {}
Data["storage"]["Ammunition"]=5000
Data["BullHit"]=function(Bla,Bullet,Dam,tr) 	
	local Boom = { 
		Pos 					=		tr.HitPos,	--Required--		--Position of the Explosion, World vector
		ShrapDamage	=		Bullet.Damage,										--Amount of Damage dealt by each Shrapnel that hits, if 0 or nil then other Shap vars are not required
		ShrapCount		=		10,										--Number of Shrapnel, 0 to not use Shrapnel
		ShrapDir			=		Vector(0,0,1),							--Direction of the Shrapnel, Direction vector, Example: Missile:GetForward()
		ShrapCone		=		180,										--Cone Angle the Shrapnel is randomly fired into, 0-180, 0 for all to be released directly forward, 180 to be released in a sphere
		ShrapRadius		=		100,										--How far the Shrapnel travels
		ShockDamage	=		Bullet.Damage/2,				--Required--		--Amount of Shockwave Damage, if 0 or nil then other Shock vars are not required
		ShockRadius		=		200,										--How far the Shockwave travels in a sphere
		Ignore				=		self,									--Optional Entity that Shrapnel and Shockwaves ignore, Example: A missile entity so that Shrapnel doesn't hit it before it's removed
		Inflictor				=		self,			--Required--		--The weapon or player that is dealing the damage
		Owner				=		self			--Required--		--The player that owns the weapon, or the Player if the Inflictor is a player
	}
	LDE:BlastDamage(Boom)
end
Data["Bullet"]={Number=1,Damage=800,Speed=150,Spread=2,heat=10,ShootPos=Vector(0,0,80),FireSound="ambient/explosions/explode_9.wav",BulletFunc=Data.BullHit}
Data["WeaponAiming"]=function(self,Target) return Target:GetPos()+(Target:GetVelocity()/2) end
Data["Weapon"]=function(self,Data)
	vStart = self:LocalToWorld(Data.ShootPos)
	vForward = (self.TraceTarg-vStart)
	
	local Bullet = {}
	Bullet.Count = Data.Number or 1
	Bullet.ShootPos = vStart
	Bullet.Direction = vForward --Position * -1,
	Bullet.Spread = Data.Spread or 0
	Bullet.Attacker = self.LDEOwner
	Bullet.ProjSpeed = Data.Speed or 50
	Bullet.Drop=0
	Bullet.Model = Data.Model or "models/Items/AR2_Grenade.mdl"
	Bullet.Ignore = self
	Bullet.Data=Data
	Bullet.Inflictor = self
	Bullet.OnHit = function (tr, Bullet)
		local Data = Bullet.Data
		if(Data.BulletFunc)then
			Data.BulletFunc(Bullet.Inflictor,Data,Data.Damage,tr)
		else
			LDE:DealDamage(tr.Entity,Data.Damage,Bullet.Attacker,Bullet.Inflictor)
		end
	end
	LDE:FireProjectile(Bullet)
end

local Makeup = {name={"Cannon Turret"},model={"models/Slyfo_2/miscequipmentfieldgen.mdl"},Type="Turrets",class=Data.class}
LDE.LifeSupport.Bases.RegisterBaseModule(Data,Makeup)

------Shield Recharger-------
local Data = table.Copy(BaseData)
Data["class"] = "base_shieldrecharge"
Data["name"] = "Shield Pylon"
Data["Costs"]["Refined Mass"]=8000
Data["Extra"]={HP=3000,Regen=300,SafeR=1000,Range=3500,Need={Power=5000}}
Data["Health"] = Data.Extra.HP
Data["BuildTime"] = 10
Data["In"]={"Power"}
Data["UpgradeCost"]=60
Data["Upgrade"]=function(self,Level)
	local Stats = self.Stats
	Stats.Regen = 300+((Level-1)*100)
	self.LDEHealth=3000+((Level-1)*1000)
	self.LDEMaxHealth=3000+((Level-1)*1000)
end
Data["UpdateText"]=function(self,Level)
	local L1="Regen Rate: "..(300+((Level-1)*100))..Arrow..(300+((Level)*100))..NL
	local L2="Health: "..(14000)+((Level-1)*1000)..Arrow..(14000)+((Level)*1000)
	return L1..L2
end
Data["heat"]=100
Data["storage"] = {Power=30000}
Data["Bullet"]={ShootDir=Vector(0,0,1),ShootPos=Vector(0,0,80)}
Data["PreBuild"]=function(self) self.NoShields=true end
Data["Think"]=function(Core,self)
	self.TraceTarg=Core:GetPos()
	local Trace =LDE.Weapons.DoTrace(self,self.Data.Bullet)
	if(not Trace.HitWorld and not self.IsDead)then
		if(self:ManageResources(self.Stats.Need))then
			local Distance = self:GetPos():Distance(Core:GetPos())
			if(Distance>self.Stats.SafeR and Trace.Entity==Core)then
				if(Distance<self.Stats.Range)then
					self:SetNWInt("LDERechargeCondition", 1)
					local Stats = Core.LDE
					if(Stats.CoreShield+self.Stats.Regen>=Stats.CoreMaxShield)then
						Stats.CoreShield=Stats.CoreMaxShield
					else	
						Stats.CoreShield=Stats.CoreShield+self.Stats.Regen
					end
				else
					self:SetNWInt("LDERechargeCondition", 0)
				end
			else
				self:SetNWInt("LDERechargeCondition", 2)
				if(not Trace.Entity==Core)then
					LDE:DealDamage(Core,self.Stats.SafeR-Distance,self,self)
				else
					LDE:DealDamage(Trace.Entity,800,self,self)
				end
			end
		else
			self:SetNWInt("LDERechargeCondition", 0)
		end
	else
		self:SetNWInt("LDERechargeCondition", 0)
	end
end

local Makeup = {name={"Shield Pylon"},model={"models/Slyfo_2/miscequipmentfieldgen.mdl"},Type="Defence",class=Data.class}
LDE.LifeSupport.Bases.RegisterBaseModule(Data,Makeup)
