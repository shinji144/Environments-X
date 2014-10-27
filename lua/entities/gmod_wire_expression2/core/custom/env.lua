
//function PropCore.ValidAction(self, entity, cmd)
//	local ply = self.player
//	if(cmd=="spawn" or cmd=="Tdelete") then return true end
//	if(!validPhysics(entity)) then return false end
//	if(!isOwner(self, entity)) then return false end
//	if entity:IsPlayer() then return false end
//	if(!IsValid(entity)) then return false end
//	return sbox_E2_PropCore:GetInt()==2 or (sbox_E2_PropCore:GetInt()==1 and ply:IsAdmin())
//end
//if not PropCore.ValidAction(self, nil, "spawn") then return nil end

EnvExp = {}

local function TellPlayers(Text,printer)
	local plys = player.GetAll()
	for k,v in pairs(plys) do
		v:ChatPrint(Text)
	end
	printer.CanGlobalPrint=0
	timer.Destroy("CanPrint "..printer:Name())
	timer.Create("CanPrint "..printer:Name(),1,1,function() if(printer and printer:IsValid())then printer.CanGlobalPrint=1 end end)
end

function EnvExp.ValidAction(self, entity, cmd)
	local ply = self.player
	if(cmd=="findcore" or cmd=="isnode" or cmd=="canlink" or cmd=="resources") then return true end
	if(cmd=="printall")then if(ply.CanGlobalPrint==1)then return true else return ply:IsAdmin() end end
	if(entity and entity:IsValid())then
		if(!isOwner(self, entity))then 
			return ply:IsAdmin()
		else
			return true
		end
	end
	return ply:IsAdmin()
end

function EnvExp.AdminAction(self)
	local ply = self.player
	return ply:IsAdmin()
end

e2function void link(entity ent, entity ent2)
	if not EnvExp.ValidAction(self, ent, "link") then return void end
	if not EnvExp.ValidAction(self, ent2, "link") then return void end
	if !IsValid(ent) or !IsValid(ent2) then return void end
		if not ent.IsNode and ent2.IsNode then
			if ent.Link and ent2.Link then
				ent:Link(ent2)
				ent2:Link(ent)
			end
		end
	return void
end

e2function void entity:envlink(entity ent)
	if not EnvExp.ValidAction(self, ent, "link") then return end
	if not EnvExp.ValidAction(self, this, "link") then return end
	if not IsValid(this) or not IsValid(ent) then return end
	if !IsValid(ent) or !IsValid(this) then return void end
		if ent.IsNode and not this.IsNode then
			if ent.Link and this.Link then
				this:Link(ent)
				ent:Link(this)
			end
		end
	return void
end

e2function void unlink(entity ent, entity ent2)
	if not EnvExp.ValidAction(self, ent, "unlink") then return nil end
	if !IsValid(ent) then return void end
		if not ent.IsNode and ent.Link then
			ent:Unlink()
		else
			if !IsValid(ent2) then
				ent:Unlink(ent2)
			end
		end
	return void
end

e2function void entity:envunlink(entity ent)
	if not EnvExp.ValidAction(self, this, "unlink") then return nil end
	if !IsValid(this) then return void end
		if not this.IsNode and this.Link then
			this:Unlink()
		else
			if !IsValid(ent) then
				this:Unlink(ent)
			end
		end
	return void
end

e2function entity entity:getCore()
	if not EnvExp.ValidAction(self, this, "findcore") then return nil end
	if not IsValid(this) then return end
	if(not this.LDE)then return end
	if(not this.LDE.Core or not this.LDE.Core:IsValid())then return end
	return this.LDE.Core
end

e2function entity entity:getCoreAttacker()
	if not EnvExp.ValidAction(self, this, "findcore") then return nil end
	if not IsValid(this) then return end
	if(not this.LDE)then return end
	if(not this.LDE.Core or not this.LDE.Core:IsValid())then return end
	return this.LDE.Core.attacker
end

e2function string entity:getCoreClass()
	if not EnvExp.ValidAction(self, this, "findcore") then return nil end
	if not IsValid(this) then return end
	if(not this.LDE)then return end
	if(not this.LDE.Core or not this.LDE.Core:IsValid())then return end
	return this.LDE.Core.ShipClass
end

e2function void entity:makeresources(string name,amount)
	if not EnvExp.AdminAction(self) then return nil end
	if not IsValid(this) then return 0 end
	if this.Link and not this.IsNode then 
		this:SupplyResource(name, amount) --Nope
	end
end

e2function void entity:useresources(string name,amount)
	if not EnvExp.AdminAction(self) then return nil end
	if not IsValid(this) then return 0 end
	if this.Link and not this.IsNode then 
		this:ConsumeResource(name, amount) --Nope
	end
end

e2function number entity:getresources(string name)
if not IsValid(this) then return 0 end
if not this.Link then return 0 end
return this:GetResourceAmount(name)
end

e2function number entity:envgethealth()
	if not IsValid(this) then return 0 end
	return LDE:GetHealth( this ) or 0
end

e2function number entity:envgetmaxhealth()
	if not IsValid(this) then return 0 end
	return LDE:GetMaxHealth( this ) or 0
end

e2function number entity:getheat()
	if not IsValid(this) then return 0 end
	if(not this.LDE)then return 0 end
	return this.LDE.Temperture or 0
end

e2function number entity:getmaxheat()
	if not IsValid(this) then return 0 end
	if(not this.LDE)then return 0 end
	return this.LDE.MeltingPoint or 0
end

e2function number entity:getminheat()
	if not IsValid(this) then return 0 end
	if(not this.LDE)then return end
	return this.LDE.FreezingPoint or 0
end

e2function void transferheat(entity ent, entity ent2,amount)
	if !IsValid(ent) or !IsValid(ent2) then return void end
	if not EnvExp.ValidAction(self, ent, "link") then return void end
	if not EnvExp.ValidAction(self, ent2, "link") then return void end
	if(!ent.LDE or !ent2.LDE)then return end
	if(ent.LDE.Temperture<1)then return end 
	if(ent.LDE.Temperture<amount)then
		amount = amount - ent.LDE.Temperture
	end
	ent.LDE.Temperture = ent.LDE.Temperture-amount
	if(ent.LDE.Temperture<0)then ent.LDE.Temperture=0 end
	LDE.HeatSim.ApplyHeat(ent2,amount,0)
end

e2function void entity:createcorelink(entity ent)
	if not EnvExp.ValidAction(self, ent, "corelink") then return end
	if not EnvExp.ValidAction(self, this, "corelink") then return end
	if not IsValid(this) or not IsValid(ent) then return end
	if(!this.LDE or !ent.LDE)then return end
	if(not ent.IsCore and not ent.IsCore == true)then return end
	if(this.LDE.Core and this.LDE.Core:IsValid())then
		ent:CoreUnLink( this )
	end
	ent:CoreLink(this)
	//this.LDE.Core = ent
end

e2function number entity:getnetcapacity(string name)
if not IsValid(this) then return 0 end
if not this.Link then return 0 end
return this:GetNetworkCapacity(name)
end

e2function number entity:getcapacity(string name)
if not IsValid(this) then return 0 end
if not this.Link or this.IsNode then return 0 end
return this:GetUnitCapacity(name)
end

e2function number entity:isnode()
	if not IsValid(this) then return 0 end
	if not this.IsNode then return 0 end
	return 1
end

e2function number entity:canlink()
	if not IsValid(this) then return 0 end
	if not this.Link then return 0 end
	return 1
end

e2function number entity:iscore()
	if not IsValid(this) then return 0 end
	if not this.IsCore then return 0 end
	if not this.IsCore == true then return 0 end
	return 1
end

e2function void globalprint(string name)
	if not EnvExp.ValidAction(self, ent, "printall") then return end
	if not name then return end
	TellPlayers(name,self.player)
	return 
end

e2function void createExplosion( vector Pos, number Radius, number Damage )
        if !self.player:IsAdmin() then return end
        local Pos = Vector( Pos[1], Pos[2], Pos[3] )
        local ED = EffectData()
        ED:SetOrigin(Pos)
        ED:SetScale(Radius)
        util.Effect( "Explosion", ED, true, true )
        util.BlastDamage( self.entity, self.player, Pos, math.Clamp(Radius, 0, 5000), Damage )
end







