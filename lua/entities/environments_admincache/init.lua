AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Resources = {"energy", "oxygen", "nitrogen", "water", "steam", "hydrogen", "carbon dioxide"}
ENT.MaxAmount = 500000
ENT.AdminOnly = true

function ENT:Initialize()
        self.BaseClass.Initialize(self)

        self:SetColor(Color(0, 0, 0, 255))
        self:SetMaterial("models/shiny")
        
        for k, res in pairs(self.Resources) do
            self:AddResource(res, self.MaxAmount)
        end
        
        local Phys = self:GetPhysicsObject()
        if(Phys:IsValid()) then
            Phys:Wake()
        end
        
    if(WireAddon != nil) then
        self.WireDebugName = self.PrintName
        self.Outputs = Wire_CreateOutputs(self, {"Resource Amount"})
        Wire_TriggerOutput(self, "Resource Amount", self.MaxAmount)
    end
end

function ENT:Think()
	self:SetColor(Color(0, 0, 0, 255))
    for k, res in pairs(self.Resources) do
        if self:GetResourceAmount(res) < self.MaxAmount then
            self:SupplyResource(res, self.MaxAmount)
        end
    end
    self:NextThink(CurTime() + 1)
    return true
end
