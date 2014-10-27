include('shared.lua')
---------------------
--MADE BY INFINITY7--
---------------------
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )



--Variable Localization And Defualt Declaration--

-------------------------------------------------





function ENT:SpawnFunction( ply, tr )

        local ent = ents.Create("wep_transporter")
                ent:Spawn()
                ent:SetPos(tr.HitPos + tr.HitNormal * 1 +Vector(0,0,20))
                ent:DropToFloor()
                ent:SetColor(254,254,254,255)
                
        return ent
end


-------------------------------

function ENT:Initialize()

        self.Entity:SetModel( "models/SBEP_community/d12shieldemitter.mdl" )
        self.Entity:PhysicsInit( SOLID_VPHYSICS )
        self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
        self.Entity:SetSolid( SOLID_VPHYSICS )
        self.Entity:DrawShadow( false )
        RD_Register(self, true)--For Environments Compatibility
		self.CoolDown = CurTime()


        
        
        
                if WireAddon then
                        local V,N,A,E = "VECTOR","NORMAL","ANGLE","ENTITY"
                        self.Inputs = WireLib.CreateSpecialInputs( self,
                                {"Send","Target","Destination"},
                                {N,E,V}
                                )
                end
        
        

        
        local phys = self.Entity:GetPhysicsObject()
        if (phys:IsValid()) then
                phys:Wake()
        end
end
-----------------------------------------------Wire Inputs-------------------------------------------
function ENT:TriggerInput(iname, value)         
        if (iname == "Send") then
                if (value > 0) then
                        self:Send()
                
                end
        end
        if (iname == "Target") then
                if (value) then
                        self.Target = value
                end
        end
		if (iname == "Destination") then
                if (value) then
                        self.Destination = value
                end
        end
end

------------------------------------------------FUNCTIONS-------------------------------------------
function ENT:Send()
	local e = self.Target
	if((CurTime()-self.CoolDown) < 1.5)then return end
	if(!IsEntity(e) or LDE:IsImmune(e))then return end
	local constraints = constraint.GetAllConstrainedEntities(e)
	if(table.Count(constraints)>1)then return end
	local start = e:GetPos()
	local dest = self.Destination + Vector(0,0,1)
	local energy = self:GetResourceAmount("energy")
	local dist = start:Distance(dest)
	local dist2 = self:GetPos():Distance(start)
	local consume = 1
	if(e:IsPlayer())then
		consume = ((dist/100)*dist2/100)*20
	else
		consume = ((dist/100)*dist2/100)*(e:GetPhysicsObject():GetMass()*6)
	end
	if(energy<consume)then return end
	self:ConsumeResource("energy",consume)
	e:SetPos(self.Destination)--The Acual Teleport
	e:GetPhysicsObject():SetVelocityInstantaneous(Vector(0,0,0))
	self.CoolDown = CurTime()
end



/*
function ENT:Think()
self.BaseClass.Think(self)
        


self.Entity:NextThink( CurTime() + 0.6 )
return true
end
*/
