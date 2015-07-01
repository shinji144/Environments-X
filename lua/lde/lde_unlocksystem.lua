local LDE = LDE
local Utl = LDE.Utl
local NDat = Utl.NetMan

if(SERVER)then
	function LDE:CheckUnlocked(ply,ent)
		print("Checking! "..tostring(ply).." "..tostring(ent))
		if ent == nil or !ent:IsValid() then print("Null Ent") return false end
		local str = ent:GetClass()
		local unlocked = ply:GetUnlocks()
		--PrintTable(unlocked)
		for t,v in pairs(LDE.Unlocks) do
			for i,u in pairs(v) do
				if i == str and not unlocked[str] then
					return true
				end
			end
		end
		return false
	end

	--[[
	function LDE.UnlockCreateCheck(ply,ent)--Entity Spawn hook.
		if(LDE:CheckUnlocked(ply,ent))then 
			ent:Remove()
			LDE:NotifyPlayer(ply,"Unlocks","Sorry you don't have that unlocked yet!",Color(255,80,80,255))
			return 
		end --Add print telling player they dont have unlock.
	end ]]
	--hook.Add( "PlayerSpawnedSENT", "UnlockCheck", LDE.UnlockCreateCheck)
	
	function UnlockUnlockable(ply, cmd, args)
		local Type,Class = args[1],args[2]
		local unlocked = ply:GetUnlocks()
		if unlocked[Class] == true then LDE:NotifyPlayer(ply,"Unlocks","You already Unlocked: "..Class,Color(80,80,255,255)) return end
		local Data = LDE.Unlocks[Type][Class]
		if Data.Cost <= ply:GetLDEStat("Cash") then
			LDE:NotifyPlayer(ply,"Unlocks","You have Successfully Unlocked: "..Class,Color(80,255,80,255))
			ply:UnlockItem(Class)
			ply:SetLDEStat("Cash",ply:GetLDEStat("Cash")-Data.Cost)
		else
			LDE:NotifyPlayer(ply,"Unlocks","You don't have enough Cash to Unlock: "..Class,Color(255,80,80,255))
		end
	end
	concommand.Add("unlockentity", UnlockUnlockable)
else

end

LDE.Unlocks = LDE.Unlocks or {}
local Unlocks = LDE.Unlocks

function LDE:CreateUnlockable(Data)
	Unlocks[Data.Type]=Unlocks[Data.Type] or {}
	Unlocks[Data.Type][Data.Class]={Name=Data.Name,Type=Data.Type,Class=Data.Class,Model=Data.Model,Cost=Data.Cost,Stats=Data.Stats,ToolTip=Data.ToolTip}
end

print("Unlock Core Loaded")