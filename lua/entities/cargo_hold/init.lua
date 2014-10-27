AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

cvar_cargohold_maxdist = CreateConVar("cargohold_maxdropdist", "1000")
util.AddNetworkString( "CrateMatrix" )

function ENT:Initialize()
	self.Entity:SetModel("models/slyfo/topless.mdl") 
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetTrigger( true )
	self.Entity:SetSolid(SOLID_VPHYSICS)
    self.Entity:SetUseType(SIMPLE_USE)
	
	local phy = self.Entity:GetPhysicsObject()
	if phy:IsValid() then phy:Wake() end
    
    self.Unit = 40
    local dimVec = 0.95 * (self.Entity:OBBMaxs()-self.Entity:OBBMins()) / self.Unit
    self.Dims = Vector(math.floor(dimVec.x),math.floor(dimVec.y),math.floor(dimVec.z))
    self.Origin = self.Entity:OBBCenter() - self.Dims*self.Unit/2
    
    self.Space = {}
    self.Crates = {}
    self.droppoint = Vector(0,0,0)
    self.locked = 0
    self.takenspace = 0
    
    for x=1, self.Dims.x do
        self.Space[x] = {}
        for y=1, self.Dims.y do
            self.Space[x][y] = {}
            for z=1, self.Dims.z do
                self.Space[x][y][z] = 0
            end
        end
    end
    
    self.totalspace = self.Dims.x*self.Dims.y*self.Dims.z
    
    self.sort = 0

    self.Inputs = WireLib.CreateSpecialInputs( self, { "Sort", "Drop by ID", "Drop by Model", "Drop Point" , "Lock"}, { [3] = "STRING",[4] = "VECTOR"} )
    self.Outputs = WireLib.CreateSpecialOutputs( self, { "Contents","Space","Used" } , {"ARRAY","NORMAL","NORMAL"})
    WireLib.TriggerOutput( self.Entity, "Space", self.totalspace )
    
end

function ENT:TriggerInput(iname, value)
    if (iname == "Sort" and value>0) then
		self.Entity:SortCargo()
    elseif (iname == "Drop Point") then
		self.droppoint = value
	elseif (iname == "Drop by ID" and value>0) then
		self.Entity:RemoveById( value )
	elseif (iname == "Drop by Model") then
		self.Entity:RemoveByModel( value )
	elseif (iname == "Lock") then
		self.locked = value
	end
end

function ENT:CheckSpace( pos, new )

    local dimVec = (new:OBBMaxs()-new:OBBMins()) / self.Unit
    volume = Vector( math.max(1,math.Round(dimVec.x)) , math.max(1,math.Round(dimVec.y)) , math.max(1,math.Round(dimVec.z)) )
    
    if(volume.x>self.Dims.x or volume.y>self.Dims.y or volume.z>self.Dims.z) then return false end

    for z=0, volume.z-1 do
        for x=0, volume.x-1 do
            for y=0, volume.y-1 do
                if(x+pos.x>self.Dims.x or y+pos.y>self.Dims.y or z+pos.z>self.Dims.z ) then return false end
                if(self.Space[x+pos.x][y+pos.y][z+pos.z]>0) then return false end
            end
        end
    end
    
    if( new.CargoInserted==true ) then
        local cubescale = Vector( volume.x/dimVec.x , volume.y/dimVec.y , volume.z/dimVec.z )
        local offset = new:OBBCenter()*cubescale
        local Pos = self.Entity:LocalToWorld( self.Origin + (Vector(pos.x-1,pos.y-1,pos.z-1) + volume/2 )*self.Unit - offset )
        new:SetParent()
        new:SetPos(Pos)
        new:SetAngles( self.Entity:GetAngles() )
        new:SetParent( self.Entity )
        local ent = new
    else
        ent = ents.Create("prop_physics")
        ent:SetModel(new:GetModel())
        local cubescale = Vector( volume.x/dimVec.x , volume.y/dimVec.y , volume.z/dimVec.z )
        local offset = new:OBBCenter()*cubescale
        local Pos = self.Entity:LocalToWorld( self.Origin + (Vector(pos.x-1,pos.y-1,pos.z-1) + volume/2 )*self.Unit - offset )
        ent:SetPos(Pos)
        ent:SetAngles( self.Entity:GetAngles() )
        ent:SetParent( self.Entity )
        ent:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
        ent:Spawn()
        ent.vol = volume
        ent.myspace = {}
        ent.CargoInserted = true
            net.Start( "CrateMatrix" )
            net.WriteInt( ent:EntIndex(),32)
            net.WriteVector( cubescale )
            net.Broadcast()             
        table.insert(self.Crates, ent)
        new:Remove()
    end
    
    //Set the space to reserved and tell the entity what space it occupies
    table.Empty(ent.myspace)
    for z=0, volume.z-1 do
        for x=0, volume.x-1 do
            for y=0, volume.y-1 do
                self.Space[x+pos.x][y+pos.y][z+pos.z] = 1
                table.insert(ent.myspace,0,Vector(x+pos.x,y+pos.y,z+pos.z))
                self.takenspace = self.takenspace+1
            end
        end
    end
    
    WireLib.TriggerOutput( self.Entity, "Contents", self.Crates )
    WireLib.TriggerOutput( self.Entity, "Used", self.takenspace )
    
    return true
    
end

function ENT:InsertCrate( new )
    
    //Check each space in the hold until the new entity can be inserted
    for z=1, self.Dims.z do
        for x=1, self.Dims.x do
            for y=1, self.Dims.y do
            
                if(self.Space[x][y][z]==0) then
                    local ret = self.Entity:CheckSpace( Vector(x,y,z), new )
                    if(ret==true) then return true end
                end
                
            end
        end
    end
    
    return false
end

function ENT:StartTouch( ent )
    if(self.sort>0) then return false end
    if(self.locked==2 and ent.Owner!=self.Owner) then return false end
    if(self.locked==1) then return false end

    if(ent:GetClass()=="prop_physics") then
        self.Entity:InsertCrate( ent )
    end

end

function ENT:Think()

    //Cycle through all the crates in the hold and insert them back into their new spots
    if(self.sort>0) then
    
        self.Entity:InsertCrate( self.Crates[self.sort] )
        
        self.sort = self.sort+1
        if(self.sort>table.Count(self.Crates)) then self.sort=0 end
    end
    
    self.Entity:NextThink( CurTime()+0.2 )
    
    return true

end

function ENT:SortCargo()

    if( self.sort==0 ) then
        self.takenspace = 0
        //Clear the space table
        for x=1, self.Dims.x do
            for y=1, self.Dims.y do
                for z=1, self.Dims.z do
                    self.Space[x][y][z] = 0
                end
            end
        end
        //Sort the crates by size
        table.sort(self.Crates, function(a, b) return a.vol:Length() > b.vol:Length() end)
        
        self.sort = 1
    end
end

function ENT:RemoveById( id )
    if(self.sort>0) then return false end
    
    local Pos = self.droppoint
    if(Pos==Vector(0,0,0)) then Pos = self.Entity:GetPos() + self.Entity:GetUp()*(self.Entity:OBBMins().z - 64) end
    if( (Pos-self.Entity:GetPos()):Length() > cvar_cargohold_maxdist:GetInt() ) then return false end
    
    new = self.Crates[id]
    if(new:IsValid()) then
        for n,vec in pairs( new.myspace ) do
            self.Space[vec.x][vec.y][vec.z] = 0
            self.takenspace = self.takenspace-1
        end
        
        ent = ents.Create("prop_physics")
        ent:SetModel(new:GetModel())
        ent:SetPos( Pos )
        ent:SetAngles( self.Entity:GetAngles() )
        ent:Activate()
        ent:Spawn()
        
        new:Remove()
        table.remove(self.Crates,id)
        
        WireLib.TriggerOutput( self.Entity, "Contents", self.Crates )
        WireLib.TriggerOutput( self.Entity, "Used", self.takenspace )
        
        return true
    end
    
    return false
end

function ENT:RemoveByModel( model )
    if(self.sort>0) then return false end
    if(model=="") then return false end
    
    for n,ent in pairs(self.Crates) do
        if(ent:GetModel()==model) then
            self.Entity:RemoveById( n )
            return true
        end
    end
    return false
end

function ENT:SpawnFunction( ply, tr )
	local ent = ents.Create( "cargo_hold" )
    ent:SetPos( tr.HitPos + tr.HitNormal*300)
    ent:SetAngles( Angle(0,0,0) )
	ent:Spawn()
    ent:Activate()
	
	return ent
end

function ENT:OnRestore()
if WireLib then WireLib.Restored(self) end
end

function ENT:PreEntityCopy()
    if WireLib then
    local DupeInfo = WireLib.BuildDupeInfo(self)
        if DupeInfo then
            duplicator.StoreEntityModifier( self, "WireDupeInfo", DupeInfo )
        end
    end
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
    Ent.Owner = Player
    if WireLib and (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
        WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
    end
end