include('shared.lua')
ENT.RenderGroup = RENDERGROUP_OPAQUE

local function StoreStat( length, client )
	Ent = net.ReadEntity()
	if(not Ent or not Ent:IsValid())then return end --Derp
	Ent.Pylons=Ent.Pylons or {}
	Ent.Pylons[table.Count(Ent.Pylons)]=net.ReadEntity()
end
net.Receive("base_pylons", StoreStat)

function ENT:Initialize()
	self.Pylons = {}
	local nettable = Environments.GetNetTable(self:EntIndex()) --yay synced table
	self.resources = nettable.resources
	self.maxresources = nettable.maxresources
	//self.data = nettable.data
	self.resources_last = nettable.resources_last
	self.last_update = nettable.last_update
end

function ENT:Think()
	if(not self.Pylons)then return end
	for I, Py in pairs(self.Pylons) do
		if(not Py or not Py:IsValid())then
			table.remove(self.Pylons,I)
		else
			local Condition = Py:GetNWInt("LDERechargeCondition") or 0
			if(Condition>0)then
				local trace = {}
				trace.start = Py:LocalToWorld(Vector(0,0,80))
				trace.endpos = self:LocalToWorld(Vector(0,0,40))
				trace.filter = Py
				tr = util.TraceLine( trace )
				
				local dist = (tr.HitPos - trace.start):Length()
				
				local effectdata = EffectData()
				effectdata:SetColor(Condition)
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetStart(trace.start)
				effectdata:SetMagnitude(0.2)
				effectdata:SetScale(dist)
				util.Effect( "ion_beam", effectdata )
			end
		end
	end
end
 
function ENT:Draw()      
	self:DrawDisplayTip()
	self:DrawModel()
end

local ResourceUnits = {}
local ResourceNames = {}


local TipColor = Color( 250, 250, 200, 255 )

surface.CreateFont("GModWorldtip", {font = "coolvetica", size = 24, weight = 500})
	
function ENT:DrawDisplayTip()
	if ( LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance( self:GetPos() ) < 512) then
		local node = self
		local OverlaySettings = list.Get( "LSEntOverlayText" )[self:GetClass()] --replace this
		local resnames = OverlaySettings.resnames
		
		local text = "Modular Base Node \n"
		
		temp = self:GetPlayerName() or "Null"
		text = text.."Owner: "..temp.."\n"
		
		local Attack = self:GetNWInt("LDEUndrAttack") or 0
		if(Attack>0)then
			temp=self:GetNWInt("LDEWave") or 1
			text= text.."Wave: "..temp.."\n"
		else
			temp=math.floor(self:GetNWInt("LDENxtAttack")-CurTime()) or 0
			if(temp<0)then temp=0 end
			text= text.."NextWave: "..temp.."\n"
		end
		
		temp = self:GetNWInt("LDEHealth") or 0
		temp2 = self:GetNWInt("LDEMaxHealth") or 0
		text = text.."Health: "..math.Round(temp).." / "..math.Round(temp2).."\n"
		
		temp = self:GetNWInt("LDEShield") or 0
		temp2 = self:GetNWInt("LDEMaxShield") or 0
		text = text.."Shields: "..math.Round(temp).." / "..math.Round(temp2).."\n"
		
		temp = self:GetNWInt("LDETechLevel") or 1
		text = text.."Tech Level: "..math.Round(temp).."\n"
		
		text = text.."Resources \n"
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
		AddWorldTip( self:EntIndex(), text, 0.5, self:GetPos(), self  )
	end
end