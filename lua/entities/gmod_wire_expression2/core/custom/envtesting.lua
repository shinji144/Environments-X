
EnvExpTest = {}

function EnvExpTest.AdminAction(self)
	local ply = self.player
	return ply:IsAdmin()
end

---------------------------------
------Real time Balancers--------
---------------------------------

------Bullet Stats------
e2function number entity:envgetweaponbulletnumber(string stat)
	if not EnvExpTest.AdminAction(self) then return 0 end
	if not IsValid(this) then return 0 end
	if(not this.IsLDEWeapon)then return 0 end
	return this.Data.Bullet[stat] or 0
end

e2function string entity:envgetweaponbulletstring(string stat)
	if not EnvExpTest.AdminAction(self) then return "" end
	if not IsValid(this) then return "" end
	if(not this.IsLDEWeapon)then return "" end
	return this.Data.Bullet[stat] or ""
end

e2function vector entity:envgetweaponbulletvector(string stat)
	if not EnvExpTest.AdminAction(self) then return Vector() end
	if not IsValid(this) then return Vector() end
	if(not this.IsLDEWeapon)then return Vector() end
	return this.Data.Bullet[stat] or Vector()
end

e2function table entity:envgetweaponbullettable(string stat)
	if not EnvExpTest.AdminAction(self) then return {} end
	if not IsValid(this) then return {} end
	if(not this.IsLDEWeapon)then return {} end
	return this.Data.Bullet[stat] or {}
end

--------Weapon Base Stats-------

e2function number entity:envgetweaponnumber(string stat)
	if not EnvExpTest.AdminAction(self) then return 0 end
	if not IsValid(this) then return 0 end
	if(not this.IsLDEWeapon)then return 0 end
	return this.Data[stat] or 0
end

e2function string entity:envgetweaponstring(string stat)
	if not EnvExpTest.AdminAction(self) then return "" end
	if not IsValid(this) then return "" end
	if(not this.IsLDEWeapon)then return "" end
	return this.Data[stat] or ""
end

e2function vector entity:envgetweaponvector(string stat)
	if not EnvExpTest.AdminAction(self) then return Vector() end
	if not IsValid(this) then return Vector() end
	if(not this.IsLDEWeapon)then return Vector() end
	return this.Data[stat] or Vector()
end

e2function table entity:envgetweapontable(string stat)
	if not EnvExpTest.AdminAction(self) then return {} end
	if not IsValid(this) then return {} end
	if(not this.IsLDEWeapon)then return {} end
	return this.Data[stat] or {}
end

------Bullet Stats------

e2function void entity:envsetweaponbulletstat(string stat, number new)
	if not EnvExpTest.AdminAction(self) then return nil end
	if not IsValid(this) then return void end
	if(not this.IsLDEWeapon)then return end
	this.Data.Bullet[stat]=new
	return void
end

e2function void entity:envsetweaponbulletstat(string stat, vector new)
	if not EnvExpTest.AdminAction(self) then return nil end
	if not IsValid(this) then return void end
	if(not this.IsLDEWeapon)then return end
	this.Data.Bullet[stat]=new
	return void
end

e2function void entity:envsetweaponbulletstat(string stat, string new)
	if not EnvExpTest.AdminAction(self) then return nil end
	if not IsValid(this) then return void end
	if(not this.IsLDEWeapon)then return end
	this.Data.Bullet[stat]=new
	return void
end

e2function void entity:envsetweaponbulletstat(string stat, table new)
	if not EnvExpTest.AdminAction(self) then return nil end
	if not IsValid(this) then return void end
	if(not this.IsLDEWeapon)then return end
	this.Data.Bullet[stat]=new
	return void
end

--------Weapon Base Stats-------

e2function void entity:envsetweaponstat(string stat, number new)
	if not EnvExpTest.AdminAction(self) then return nil end
	if not IsValid(this) then return void end
	if(not this.IsLDEWeapon)then return end
	this.Data[stat]=new
	return void
end

e2function void entity:envsetweaponstat(string stat, vector new)
	if not EnvExpTest.AdminAction(self) then return nil end
	if not IsValid(this) then return void end
	if(not this.IsLDEWeapon)then return end
	this.Data[stat]=new
	return void
end

e2function void entity:envsetweaponstat(string stat, string new)
	if not EnvExpTest.AdminAction(self) then return nil end
	if not IsValid(this) then return void end
	if(not this.IsLDEWeapon)then return end
	this.Data[stat]=new
	return void
end

e2function void entity:envsetweaponstat(string stat, table new)
	if not EnvExpTest.AdminAction(self) then return nil end
	if not IsValid(this) then return void end
	if(not this.IsLDEWeapon)then return end
	this.Data[stat]=new
	return void
end

--------Bomb Stats-------

e2function void entity:envsetbombstat(string stat, number new)
	if not EnvExpTest.AdminAction(self) then return nil end
	if not IsValid(this) then return void end
	if(not this.IsLDEWeapon)then return end
	this.Data.Boom[stat]=new
	return void
end

e2function void entity:envsetbombstat(string stat, vector new)
	if not EnvExpTest.AdminAction(self) then return nil end
	if not IsValid(this) then return void end
	if(not this.IsLDEWeapon)then return end
	this.Data.Boom[stat]=new
	return void
end

e2function void entity:envsetbombstat(string stat, string new)
	if not EnvExpTest.AdminAction(self) then return nil end
	if not IsValid(this) then return void end
	if(not this.IsLDEWeapon)then return end
	this.Data.Boom[stat]=new
	return void
end

e2function void entity:envsetbombstat(string stat, table new)
	if not EnvExpTest.AdminAction(self) then return nil end
	if not IsValid(this) then return void end
	if(not this.IsLDEWeapon)then return end
	this.Data.Boom[stat]=new
	return void
end
---------------------------------


