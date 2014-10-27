include('shared.lua')

function ENT:Initialize()
    self.ScaleTimer = CurTime()
    self.ToScale = {}
    
    net.Receive( "CrateMatrix", function( len )
        data = {}
        data.index = net.ReadInt(32)
        data.scale = net.ReadVector()
        table.insert(self.ToScale,0,data)
        self.ScaleTimer = CurTime()
    end)
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
    
    if(self.ScaleTimer<CurTime()) then
        for n, data in pairs(self.ToScale) do
            ent = ents.GetByIndex( data.index )
            if(ent:IsValid()) then
                local mat = Matrix()
                mat:Scale( data.scale )
                ent:EnableMatrix("RenderMultiply", mat)
                table.remove( self.ToScale, n)
            end
        end
        self.ScaleTimer = CurTime()+1
    end
    
end