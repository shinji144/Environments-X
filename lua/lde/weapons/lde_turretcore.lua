
//Function to compile a turret into the system.
function LDE.Weapons.CompileTurret(Data,Inner)
	for k,v in pairs(Inner.model) do --Loop the base models.
		Environments.RegisterDevice(Inner.Tool, Inner.Type, Inner.name[k], Inner.class, v)
	end
	LDE.Weapons.RegisterTurret(Data)--Send forth the data!!!
end

//The turret entity creation function
function LDE.Weapons.RegisterTurret(Data)
	local ENT = {} -- This defiine the entity as a table.
	ENT.Type = "anim"
	ENT.Base = "base_env_entity" --We want to use the environments base
	ENT.PrintName = Data.name --Set the entity name
	ENT.Data = Data --Give the entity its Data table.
	--ENT.TDat = Data.Turret

	list.Set( "LSEntOverlayText" , Data.class, {HasOOO = true, resnames = Data.In, genresnames = Data.Out} )
	
	
	if SERVER then--Same thing as init.lua
		function ENT:Initialize()
			self.BaseClass.Initialize(self)
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )
			
			self.Weapons = {}
			self.TurretBits = {}
			
			self.Bits = false
			self.Active = false
			
			self.TDat = table.Copy(self.Data.Turret)
			
			local O = {}
			for i,w in pairs(self.TDat.T) do
				O[w.I or i]=table.Copy(w)
			end
			self.TDat.T = O
			
			self.Mounts = table.Copy(self.TDat.M)
			self.AimOff = self.TDat.AO or Vector(0,0,0)
			self.TBDat = {}
			for i,w in pairs(self.TDat.T) do
				self.TBDat[w.I]=w
			end
			
			timer.Simple(0.3,function()
				self:CompileTurret()
			end)
			self.Inputs = WireLib.CreateSpecialInputs( self, { "Active", "Fire", "Vector" }, { [3] = "VECTOR"} );
		end
		
		function ENT:CreateDumbEnt(M,P)
			if IsValid(M.DE) then
				Dumb = M.DE
			else
				Dumb = ents.Create( "prop_physics" )
				Dumb:SetModel("models/cheeze/wires/cpu.mdl")
				Dumb:SetColor(Color(0,0,0,0))
				Dumb:Spawn() Dumb:Activate()
				constraint.NoCollide(self, Dumb, 0, 0)
				
				Dumb:SetRenderMode(RENDERMODE_TRANSALPHA)
			end
			
			Dumb:SetPos(P:LocalToWorld(M.V)) 
			Dumb:SetAngles(P:LocalToWorldAngles(M.A))
			Dumb:SetParent(P)	
			
			M.DE = Dumb
			
			return Dumb
		end
		
		function ENT:AttachBit(M,E,D,Dumb)
			E.Mounted = self
			
			local Parent = self
			if self.TurretBits[D.P] and IsValid(self.TurretBits[D.P].E) then
				Parent = self.TurretBits[D.P].E
			end
			local Dumb = Dumb or self:CreateDumbEnt(D,Parent)
			
			self.TurretBits[M] = {E=E,DE=Dumb}

			E:SetPos(Parent:LocalToWorld(D.V+D.VO))
			E:SetAngles(Parent:LocalToWorldAngles(D.A+D.AO)	)
			E:SetParent(Dumb)		
		end
		
		function ENT:SpawnBits()
			for i,w in pairs(self.TDat.T) do
				local tbit = ents.Create( "prop_physics" )
				if not tbit then return end -- what why did it fail?
				tbit:SetModel(w.M)
				tbit:SetPos(self:LocalToWorld(w.V))
				tbit:SetAngles(self:LocalToWorldAngles(w.A))
				local Parent = self
				if self.TurretBits[w.P] and IsValid(self.TurretBits[w.P].E) then
					Parent = self.TurretBits[w.P].E
				end
				tbit:SetParent(Parent)
				tbit:Spawn() tbit:Activate()
				tbit:GetPhysicsObject():Wake()
				
				constraint.NoCollide(self, tbit, 0, 0)
				
				--self.TurretBits[w.I or i]=tbit
				self:AttachBit(w.I or i,tbit,w)
			end
		end
		
		function ENT:MountTurret(M,E,D,Dumb)
			D.E = E 
			E.Mounted = self
			
			local Parent = self.TurretBits[D.P].E or self
			local Dumb = Dumb or self:CreateDumbEnt(D,self.TurretBits[D.P].E or self)
			
			self.Weapons[M] = {E=E,DE=Dumb}

			E:SetPos(Parent:LocalToWorld(D.V+E.MountVectorOffSet))
			E:SetAngles(Parent:LocalToWorldAngles(D.A+E.MountAngleOffSet)	)
			E:SetParent(Dumb)		
		end

		function ENT:CompileTurret()
			if not self.Bits then
				self:SpawnBits()
				self.Bits = true
			end
		end
		
		function ENT:TurretValid()
			for i,w in pairs(self.TurretBits) do
				if not IsValid(w.E) then
					return false
				end	
			end
			return true
		end
		
		function ENT:Touch( ent )
			if self:TurretValid() then
				if ent.MountType and not IsValid(ent.Mounted) then
					for i,w in pairs(self.Mounts) do	
						if self.TurretBits[w.P] and not IsValid(self.TurretBits[w.P].E) then continue end
						if not IsValid(w.E) and w.T == ent.MountType then
							self:MountTurret(i,ent,w)
							constraint.NoCollide(self, ent, 0, 0)
							return
						end
					end
				end
			end
		end
		
		function ENT:TriggerInput(iname, value)
			if iname == "Active" then
				self.Active = value > 0
			elseif iname == "Fire" then
				self.FireGuns = value > 0
			elseif iname=="Vector" then
				self.TargetPos = value
			end
		end

		function ENT:MixAngles(Ang1,Ang2,Ratio)
			return Angle((Ang1.p*ratio)+(Ang2.p*(1-ratio)),(Ang1.y*ratio)+(Ang2.y*(1-ratio)),(Ang1.r*ratio)+(Ang2.r*(1-ratio)))
		end
		
		function ENT:Think()
			if not self:TurretValid() then return false end
			local AB = self
			local Ang = Angle(0,0,0)
			
			if self.Active and self.TargetPos then
				Ang = AB:WorldToLocalAngles((self.TargetPos-AB:LocalToWorld(self.AimOff)):Angle())
			end
			
			for i,w in pairs(self.TurretBits) do
				if not self.TBDat[i] then continue end
				local R = self.TBDat[i].G
				w.DE:SetAngles(AB:LocalToWorldAngles(Angle(Ang.Pitch*R.P,Ang.Yaw*R.Y,Ang.Roll*R.R)))
			end
			
			if not self.Mounts then return end
			for i,w in pairs(self.Weapons) do
				if IsValid(w.E) and self.Mounts[i] then
					local R = self.Mounts[i].G
					
					if not IsValid(w.DE) then continue end
					w.DE:SetAngles(AB:LocalToWorldAngles(Angle(Ang.Pitch*R.P,Ang.Yaw*R.Y,Ang.Roll*R.R)))
					
					if self.FireGuns then
						w.E:TurnOn()
					else
						w.E:TurnOff()
					end
				end
			end
		end
		
		function ENT:OnRemove() end --Make the turret unparent its guns.
	
		function ENT:EnvxOnPaste(Ply,ent,cents)
			local DupeInfo = ent.EntityMods.EnvxDupeInfo
			
			if DupeInfo.TBits then
				for i,w in pairs(DupeInfo.TBits) do
					local DE = cents[w.DE]
					self:AttachBit(i,cents[w.E],self.TDat.T[i],DE)
					DE:SetRenderMode(RENDERMODE_TRANSALPHA)
					DE:SetColor(Color(0,0,0,0))
				end
			end
			
			if DupeInfo.Weapons then
				for i,w in pairs(DupeInfo.Weapons) do
					local Ent = cents[w.E]
					if not IsValid(Ent) then continue end
					local DE = cents[w.DE]
					self:MountTurret(i,Ent,self.Mounts[i],DE)
					DE:SetRenderMode(RENDERMODE_TRANSALPHA)
					DE:SetColor(Color(0,0,0,0))
				end
			end
			
			self.Bits = true
		end
		
		function ENT:EnvxOnDupe()
			local Info = {}
			
			Info.TBits = {}
			for i,w in pairs(self.TurretBits) do
				Info.TBits[i] = {
					E=w.E:EntIndex(),
					DE=w.DE:EntIndex()
				}
			end
						
			Info.Weapons = {}
			for i,w in pairs(self.Weapons) do
				Info.Weapons[i]={
					E=w.E:EntIndex(),
					DE=w.DE:EntIndex()
				}
			end
			
			return Info
		end
	else 
		--client side same as cl_init.lua
	end
	
	scripted_ents.Register(ENT, Data.class, true, true) --REgister the entity as a real one.
	print("Turret Registered: "..Data.class)
end

--EXAMPLE
local Base = {Tool="Weapon Systems",Type="Turrets"}--Base code for the compiler table.

local Turret = {
	T = {
		{
			M="models/slyfo_2/mini_turret_swivel.mdl",
			A=Angle(0,0,0),V=Vector(0,0,0),VO=Vector(0,0,0),AO=Angle(0,0,0),
			G={P=0,Y=1,R=0},I="Swivel"
		},
		{
			M="models/slyfo_2/mini_turret_mount1.mdl",
			A=Angle(0,0,0),V=Vector(0,0,10),VO=Vector(0,0,0),AO=Angle(0,0,0),
			G={P=1,Y=1,R=0},P="Swivel",I="Mount"
		}
	},
	M = {
	{T="Small",A=Angle(0,0,0),V=Vector(5,10,5),G={P=1,Y=1,R=0},P="Mount"},
	{T="Small",A=Angle(0,0,0),V=Vector(5,-10,5),G={P=1,Y=1,R=0},P="Mount"}
	},
	AO = Vector(0,0,10)
}
local Data={name="Micro Turret",class="envx_micro_turret",In={"energy"},InUse={0},Turret=Turret}--Base Data for your entity
local Makeup = {name={"Micro Turret"},model={"models/slyfo_2/mini_turret_base.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}--So the compiler knows what to do.
LDE.Weapons.CompileTurret(Data,Makeup)--Send it in

local Turret = {
	T = {
		{
			M="models/slyfo/smlturrettop.mdl",
			A=Angle(0,0,0),V=Vector(0,0,30),VO=Vector(0,0,0),AO=Angle(0,0,0),
			G={P=0,Y=1,R=0},I="Swivel"
		}
	},
	M = {
	{T="Medium",A=Angle(0,0,0),V=Vector(0,0,10),G={P=1,Y=1,R=0},P="Swivel"}
	},
	AO = Vector(0,0,30)
}
local Data={name="Medium Turret",class="envx_med_turret",In={"energy"},InUse={0},Turret=Turret}--Base Data for your entity
local Makeup = {name={"Medium Turret"},model={"models/slyfo/smlturretbase.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}--So the compiler knows what to do.
LDE.Weapons.CompileTurret(Data,Makeup)--Send it in

local Turret = {
	T = {
		{
			M="models/sbep_community/ssnavalmid.mdl",
			A=Angle(0,0,0),V=Vector(0,0,0),VO=Vector(0,0,0),AO=Angle(0,0,0),
			G={P=0,Y=1,R=0},I="Swivel"
		}
	},
	M = {
	{T="NCannon",A=Angle(0,0,0),V=Vector(0,0,0),G={P=1,Y=1,R=0},P="Swivel"},
	{T="NCannon",A=Angle(0,0,0),V=Vector(0,35,0),G={P=1,Y=1,R=0},P="Swivel"},
	{T="NCannon",A=Angle(0,0,0),V=Vector(0,-35,0),G={P=1,Y=1,R=0},P="Swivel"}
	}
}
local Data={name="Navel Turret",class="envx_nav_turret",In={"energy"},InUse={0},Turret=Turret}--Base Data for your entity
local Makeup = {name={"Navel Turret"},model={"models/sbep_community/ssnavalbase.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}--So the compiler knows what to do.
LDE.Weapons.CompileTurret(Data,Makeup)--Send it in
