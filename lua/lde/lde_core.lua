local function TellPlayers(Text)
	local plys = player.GetAll()
	for k,v in pairs(plys) do
		v:ChatPrint(Text)
	end
end

--[[
function LDE:Debug(Message)
	if(LDE.ChatDebug)then
		TellPlayers(Message)
	end
	if(LDE.ConDebug)then
		print(Message)
	end
	LDE.Utl:Debug("Debug",Message,2)
end
]]

--List of models we want to scan clients for.
LDERequiredModels={
	{M="models/SmallBridge/Ships/sbfrigate1.mdl",
	N="SpaceBuild Enhancement Pack",P="SBEP",
	L="https://github.com/SnakeSVx/sbep/branches/beta",
	S="http://tausc.site.nfoservers.com/HitchHikersGuide/Sbeppack.jpg",
	I="Copy the link into a svn program."
	},
	{M="models/af/AFF/USN/aesir.mdl",
	N="PreFab Ship Pack",P="PFSP",
	L="http://tausc.site.nfoservers.com/Downloads/PrefabShipModels.zip",
	S="http://tausc.site.nfoservers.com/HitchHikersGuide/PreFabModelShips.jpg",
	I="Copy the link into your browser."
	}
}
	
//Random chat adverts
if(SERVER)then

	resource.AddWorkshop( "174935590" ) --Spore Models
	resource.AddWorkshop( "160250458" ) --Wire Models
	resource.AddWorkshop( "168326910" ) --Gibmod Textures
	resource.AddWorkshop( "148070174" ) --Mandrac Models
	resource.AddWorkshop( "182803531" ) --SBEP Models
	
	--We have to create a copy of each model so we can accuratly scan for them.
	timer.Simple(1,function()
		for k,v in pairs(LDERequiredModels) do
			local ent = ents.Create("holograment")
			print("Making: "..v.M)
			ent:SetPos(Vector(0, 0, 0))
			ent:SetModel(v.M)
			ent:Spawn()	
		end
	end)
	
	function LDE:HealPlayer(ply,amount)
		if(not ply or not ply:IsValid() or not ply:IsPlayer() or not ply:Alive())then return end -- Error Checking.
		local health = ply:Health()		
		
		if health+amount < 250 then
			ply:SetHealth( health + amount )		
		elseif health+amount < 250 then
			ply:SetHealth( 250 )
		end	
	end
	
	function LDE:NotifyPlayers(Source,String,Color)
		local plys = player.GetAll()
		for k,v in pairs(plys) do
			v:SendColorChat(Source,Color,String)
		end
	end
	
	function LDE:NotifyPlayer(Ply,Source,String,Color)
		Ply:SendColorChat(Source,Color,String)
	end
		
	function LDE:ChatAdvert()
		local adcount = table.Count(LDE.Adverts)
		local message = math.random(1,adcount)
		LDE:NotifyPlayers("Advert",LDE.Adverts[message],{r=100,g=0,b=150})
		--TellPlayers(LDE.Adverts[message])
		timer.Simple(300,function() LDE:ChatAdvert() end)
	end
	--timer.Simple(180,function() LDE:ChatAdvert() end) --Disabled until further notice...
	
	function LDEFigureRole(ply)
		local oldrole = ply:GetLDERole()
		local Stats = ply:GetStats()
		
		local Roles = LDE.Rolesys.Roles
		local Role = {}
		
		for name,role in pairs(Roles) do
			if(LDE.Rolesys.CanFillRole(ply,role))then
				if(Role.name)then
					if(role.Priority>Role.Priority)then
						Role=role
					end
				else
					Role = role
				end
			end
		end

		if(Role.name~=oldrole)then
			local Text = ply:GetName().." is now a "..Role.name.."."
			LDE:NotifyPlayers("Stats",Text,{r=0,g=100,b=255})
			ply:SetLDERole(Role.name)
			ply:SetLDEStat("Moral",Role.Moral)
			
			LDE.Debug(Text,2,"Player Related")
		end

		LDE.Cash:UpdatePerson(ply)
	end
	
	function LDEPlayDeath(victim, weapon, killer)
		if(not victim:IsValid())then return end --Idk This is wierd

		LDE.Mutations.HandleMutations(victim,"OnDeath",{weapon=weapon,attacker=attacker}) --Call the ondeath hook for mutations.
		LDE.Mutations.HandleMutations(killer,"OnKill",{weapon=weapon,victim=victim}) --Call the ondeath hook for mutations.
		victim:ClearMutations()	--Clear all mutations.
		
		if(not killer:IsPlayer())then killer = killer.LDEOwner end
		if(victim==killer or not killer or not killer:IsValid() or not killer.GiveLDEStat)then 
			local Text = victim:GetName().." has died through their own means."
			--LDE.Logger.LogEvent( Text )
			return 
		end
		
		killer:GiveLDEStat("Kills",1)
		LDEFigureRole(killer)
		local Text = victim:GetName().." was killed by "..killer:GetName()
		--LDE.Logger.LogEvent( Text )
		LDE:NotifyPlayers("Stats",Text,{r=255,g=0,b=0})
	end
	hook.Add("PlayerDeath","ldeplayerdeath",LDEPlayDeath)
	
	function LDEFirstSpawn(ply)
		ply.dbReady = false
		ply.Stats = {} --Our Stats Table
		ply.SStrings = {} --Our Strings Table
		LDE.Cash.getstats( ply )
		local Text = ply:GetName().." has spawned."
		
		--TellPlayers(Text)
		LDE:NotifyPlayers("Server",Text,{r=150,g=150,b=150})

		net.Start( "PlyRequestModel" )
		net.WriteString( ply:GetName() )
		net.Send( ply )

		LDE.Debug(Text,3,"Player Related")
	end
	hook.Add("PlayerInitialSpawn","ldeplayerispawn",LDEFirstSpawn)
	
	function LDELeftServ(ply)
		local Text = ply:GetName().." has disconnected from the server. (SteamID: "..ply:SteamID().." )"
		--TellPlayers(Text) --Fixed
		LDE:NotifyPlayers("Server",Text,{r=150,g=150,b=150})
		LDE.Debug(Text,3,"Player Related")
		
		hook.Call("LDEPlyLeft",nil,ply)
	end
	hook.Add("PlayerDisconnected","ldedisconnected",LDELeftServ)
	
	function LDEPlayConnect( name, address )
		local Text = name .. " has connected from IP: " .. address
		--TellPlayers( Text )
		LDE:NotifyPlayers("Server",Text,{r=150,g=150,b=150})
		LDE.Debug(Text,3,"Player Related")
	end
	hook.Add("PlayerConnect","ldeconnected",LDEPlayConnect)	
	
	function LDESetOwner(ply,ent) --So we dont have to rely on any prop protection mods.
		if !IsValid(ent) or !IsValid(ply) or ent:IsPlayer() or !ply:IsPlayer() then return end
		ent.LDEOwner = ply
	end
	
	hook.Add("PlayerSpawnedSENT", "LDE.PlayerSpawnedSENT", LDESetOwner)
	hook.Add("PlayerSpawnedVehicle", "LDE.PlayerSpawnedVehicle", LDESetOwner)
	hook.Add("PlayerSpawnedSWEP", "LDE.PlayerSpawnedSWEP", LDESetOwner)

	net.Receive( "PlyRequestModel", function( len )
		local Stat = net.ReadString()
		local PlyName = net.ReadString()
		
		--MsgAll("Scanning model packs! ")
		--MsgAll(Stat)
		
		if(Stat=="True")then
			LDE:NotifyPlayers("Server","Validated! "..PlyName.." has the Model Packs!",{r=0,g=255,b=0})
		else
			LDE:NotifyPlayers("Server", "Error! "..PlyName.." is Missing: "..Stat,{r=255,g=0,b=0})
		end
	end )
   
	util.AddNetworkString( "PlyRequestModel" )
	
else
	Missing = {}
	function HasModelPacks()
		local State = "True"
		for _,v in pairs(LDERequiredModels) do
			if(not util.IsValidProp(Model(v.M)))then
				if(State=="True")then
					State = v.N
				else
					State = State..", "..v.N
				end
				Missing[v.N]=v
			end
		end		
		return State
	end
	
	function ScanModels(Num,Name)
		if(Num>3)then
			net.Start( "PlyRequestModel" )
			net.WriteString( HasModelPacks() )
			net.WriteString( Name )
			net.SendToServer()
			--LDE.UI.MissingModelsPanel(Missing)--Open up the missing models panel.
		else
			if(HasModelPacks()=="True")then
				net.Start( "PlyRequestModel" )
				net.WriteString( "True" )
				net.WriteString( Name )
				net.SendToServer()			
			else
				timer.Simple(0.1,function()
					ScanModels(Num+1,Name)
				end)
			end
		end
	end
	
    net.Receive( "PlyRequestModel", function( len )
		local Name =  net.ReadString()
		timer.Simple(0.3,function()
			ScanModels(1,Name)
		end)
    end )
end

function LDE:IsLifeSupport(ent)
	if(not ent or not ent:IsValid())then return end
	if(ent.IsLS and not ent.IsNode)then
		return true
	else
		return false
	end
end

function LDE_EntCreated(ent)--Entity Spawn hook.
	if(LDE:CheckBanned(ent))then --LDE:Debug("Illegal Entity spawned. Removing it.") 
		ent:Remove() return 
	end
	if ent:IsValid() and not ent:IsWeapon() and CurTime() > 5 then
		timer.Simple( 0.25, function()  if(not ent or not ent:IsValid())then return end LDE_Filter( ent ) end)  --Need the timer or the ent will be detect as the base class and with no model.
	end
end 
hook.Add( "OnEntityCreated", "LDE_EntCreated", LDE_EntCreated)

function LDE_Filter(ent) --Because the hook finds EVERYTHING, lets filter out some usless junk 	
	if not ent:IsValid() then return false end
    if ent:GetClass() == "gmod_ghost" then return false end	
    if ent:GetSolid() == SOLID_NONE then return false end
    if ent:IsNPC() then return false end
	
	LDE:Spawned( ent ) --Anything not filtered goes to the spawned function,
end 

hook.Add( "CanDrive","FUCKCANDRIVE", function( ply, ent ) return false end)

function LDE:CheckBanned(ent)
	if ent == nil or !ent:IsValid() then print("Null LDE CheckBanned Ent") return false end
	local str = ent:GetClass()
	for _,v in pairs(LDE.BannedClasses) do
		if(string.find(str,v))then
			return true
		end
	end
	return false
end

function LDE:Spawned( ent )
	if(not ent or not IsValid(ent))then print("LDE: Error Invalid Entity Spawn Report!") return end
	if (!ent.LDE) then ent.LDE = {} end--Format the entity to be LDE friendly.	

	if(SERVER)then
	
		if(ent:IsPlayer())then
			ent.CanGlobalPrint=1
			return
		end

		--Heat Simulation Spawn Function
		if LDE:IsLifeSupport(ent) then 
			if(not ent.IsLDEC and not ent.UpdateStorage and not ent.quiet_steam)then
				if(ent.Think)then
					ent.OldThink = ent.Think or function() end
					ent.Think = function(self) --Overwrite think function
						LDE.HeatSim.HeatThink(self) --Run Heat Sim Code
						self:OldThink()--Run old think Function
					end
				end
			end
		end
		--HeatSimulation Variables
		ent.LDE.Temperature=0
		ent:SetNWInt("LDEEntTemp", ent.LDE.Temperature) --Network the current temperture, 0
		ent.LDE.MeltingPoint=LDE:CalcHealth(ent)/10
		ent:SetNWInt("LDEMaxTemp", ent.LDE.MeltingPoint) --Network the max temperture
		ent.LDE.FreezingPoint=(LDE:CalcHealth(ent)/20)*-1
		ent:SetNWInt("LDEMinTemp", ent.LDE.FreezingPoint)
		ent.LDE.OverHeating = false

		--Damage Control Spawn function
		local MaxHealth = LDE:MaxHealth()
		local MinHealth = LDE:MinHealth()
		local Health = LDE:CalcHealth( ent )	
		if Health < MaxHealth and Health > MinHealth then
			ent.LDEHealth = Health
			ent.LDEMaxHealth = Health
			//Msg("I am: "..tostring(ent).."	My Health is: "..tostring(Health))
		elseif Health >= MaxHealth then
			ent.LDEHealth = MaxHealth
			ent.LDEMaxHealth = MaxHealth
			//Msg("I am: "..tostring(ent).."	My Health is Max at: "..tostring(MaxHealth))
		elseif Health <= MinHealth then
			ent.LDEHealth = MinHealth
			ent.LDEMaxHealth = MinHealth
			//Msg("I am: "..tostring(ent).."	My Health is Min at: "..tostring(MinHealth).." from: "..tostring(Health))
		else
			//Msg("You Broke Somthing... in the part where health is figured out")
		end
	else --Client related things
		ent.UpdateEnvOverlay = function(self) --My overlay modification.
			if(not self.ExtraOverlayData)then self.ExtraOverlayData={} end --Make sure we have a table to add to.
			if(self:GetNWInt("LDEMaxTemp")==0)then return end
			self.ExtraOverlayData.Heat=math.Round(self:GetNWInt("LDEMinTemp")).."/("..math.Round(self:GetNWInt("LDEEntTemp"))..")/"..math.Round(self:GetNWInt("LDEMaxTemp")) --Add heat to the extras table.
		end
		ent.OldNormDraw = ent.DoNormalDraw --Copy the entitys draw function.
		ent.DoNormalDraw = function(blah) --Replace the entitys draw function.
			ent.UpdateEnvOverlay(ent) --Run our overlay modification code
			ent.OldNormDraw(blah) --Run the old draw function.
		end
	end
end

--Winch Compatability code.
function GravyPunt( ply, ent )
	
	if ent.Puntable then
		return ent:Punt( ply )
	end
	return true
end
 
hook.Add( "GravGunPunt", "GravyPunt", GravyPunt )

local function GravyGrab( ply, ent )
	if ent.GravyGrab then
		return ent:GravyGrab( ply )
	end	
	return true
end

hook.Add("GravGunPickupAllowed", "GravyGrab", GravyGrab)

local function GravyDrop( ply, ent )
	if ent.GravyDrop then
		return ent:GravyGrab( ply )
	end	
	return true
end

hook.Add("GravGunOnDropped", "GravyDrop", GravyDrop)

-- This function basically deals with stuff that happens when a player hops out of a vehicle
function SetExPoint(player, vehicle)
	if vehicle.ExitPoint and vehicle.ExitPoint:IsValid() then
		local EPP = vehicle.ExitPoint:GetPos()
		local VP = vehicle:GetPos()
		local Dist = EPP:Distance(VP)
		if Dist <= 500 then
			player:SetPos(vehicle.ExitPoint:GetPos() + vehicle.ExitPoint:GetUp() * 10)
			player:SetSubSpace( vehicle:GetSubSpace() )
			vehicle.ExitPoint.CDown = CurTime() + 0.5
		end
	end
	
	if player.CamCon then
		player.CamCon = false
		player:SetViewEntity()
	end
end

hook.Add("PlayerLeaveVehicle", "PlayerRepositioning", SetExPoint)
LDE.SetExPoint = SetExPoint



