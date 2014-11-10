module( "LDEplystats", package.seeall )

LDE.Cash = {}
LDE.Cash.Market = {}
LDE.Mutations	= {}

--------------------Market------------------------------
LDE.Cash.Market.Resources = {}
//nickame = {startingamount=1,starting cost=1,name="name",description="blah"}


LDE.Cash.Resources = {
energy = {E=true,S=5000000000,C=0.000003,O="energy",name="Energy",desc={"","","Energy is the base form of everything in the universe.","It is used to power nearly everything.","",""}},
water = {E=true,S=3000000000,C=0.000005,O="water",name="Water",desc={"","","Water is a combination of an Oxygen molecule and 2 Hydrogen.","It is used for cooling, or split in to H and O2.","",""}},
oxygen = {E=true,S=5000000000,C=0.000006,O="oxygen",name="Oxygen",desc={"","","Oxygen is a requirement for habitation. You breathe it,","and your muscles use it for power.","",""}},
hydrogen = {E=true,S=5000000000,C=0.000006,O="hydrogen",name="Hydrogen",desc={"","","Hydrogen is a very volatile, flammable element.","It is part of the makeup for water, and is used for jetpacks.","",""}},
nitrogen = {E=true,S=1000000000,C=0.000001,O="nitrogen",name="Nitrogen",desc={"","","Nitrogen is one of the most efficient coolants,","much more so than water. It is also harder to produce.","",""}},
steam = {E=true,S=5000000000,C=0.000005,O="steam",name="Steam",desc={"","","Steam is a different form of water, one with more energy.","It is used to make ","",""}},
carbondioxide = {E=true,S=3000000000,C=0.000002,O="carbon dioxide",name="Carbon Dioxide",desc={"","","Carbon Dioxide, or CO2, is exhaled by humans.","It is used to make nitrogen, or split in to Carbon and Oxygen.","",""}},
Electromium = {S=800000000,C=0.1,O="Electromium",name="Electromium",desc={"","","Electromium is a resource first created in science labs,","synthesized from pure energy.","It is refinable in to Liquid Polylodarium.","",""}},
Carbon = {S=600000000,C=0.8,O="Carbon",name="Carbon",desc={"","","Used for armor, or to produce CO2, carbon is a base element.","",""}},
RawOre = {S=400000000,C=0.2,O="Raw Ore",name="Raw Ore",desc={"","","Raw ore is produced by drilling deep within a planet or asteroids'","core, and extracting the ores from the dirt and rock.","",""}},
RefinedOre = {S=300000000,C=0.4,O="Refined Ore",name="Refined Ore",desc={"","","Refined ore is made by refining raw ore, by taking out impurities.","",""}},
HardenedOre = {S=250000000,C=0.8,O="Hardened Ore",name="Hardened Ore",desc={"","","Hardened ore is made by hardening refined ore", "with crystal polylodarium.","",""}},
BasicRounds = {S=1000000000,C=0.6,O="Basic Rounds",name="Basic Rounds",desc={"","","Basic rounds are self-contained oxidizing explosive charges,","thrown out of a gun at very, very high speeds by their explosion.","",""}},
Shells = {S=800000000,C=1,O="Shells",name="Shells",desc={"","","A larger form of bullets, shells are generally used in ordnance.","",""}},
Plasma = {S=800000000,C=0.8,O="Plasma",name="Plasma",desc={"","","Super Heated Polylodarium, Most commonly used as ammunition.","",""}},
HeavyShells = {S=250000000,C=2,O="Heavy Shells",name="Heavy Shells",desc={"","","An even larger form of shells,", "heavy shells are generally used in superordnance.","",""}},
MissileParts = {S=1000000000,C=0.9,O="Missile Parts",name="Missile Parts",desc={"","","Missile parts are used by missile launchers to", "assemble missiles and fire them.","",""}},
Casings = {S=5000000000,C=0.5,O="Casings",name="Casings",desc={"","","Casings are used to create ammunition,", "and store the explosive arm and payload before firing.","",""}},
CrystalisedPolylodarium = {S=800000000,C=0.8,O="Crystalised Polylodarium",name="Crystalised Polylodarium",desc={"","","Is a form of alien fauna that stablises","antimatter in extremely heated enviroments.",""}},
LiquidPolylodarium = {S=500000000,C=1.2,O="Liquid Polylodarium",name="Liquid Polylodarium",desc={"","","Liquid Polylodarium is the stablised antimatter particles","from refined Crystalised Polylodarium.",""}},
Blackholium = {S=1000,C=800,O="Blackholium",name="Blackholium",desc={"","","First discovered by scientists in a freak accident", " involving a research ship, ","scientists have no idea what blackholium is,", " or how it works, or even what it does.","",""}}
}

if SERVER then

function LDE.Cash.Market.UpResource(Resource,Amount,Cost)
	local row = sql.Query( "SELECT amount, value FROM ldemarket WHERE resource = '" .. Resource .. "';" ) //Check for the resource
	if row then//IF Data found.
		MsgAll("Updating "..Resource.." to "..Amount.." at cost "..Cost.." \n") //To console!
		sql.Query( "UPDATE ldemarket SET value = ".. Cost ..", amount = " .. Amount .. " WHERE resource = '" .. Resource .. "';" )//Update the current data
	else
		MsgAll("Inserting '"..Resource.."' to "..Amount.." at cost "..Cost.." \n")
		sql.Query( "INSERT into ldemarket ( resource, amount, value ) VALUES ( '" .. Resource .. "', " .. Amount .. ", " .. Cost .. " );" )//Add the new data
	end
	LDE.Cash.Market.Resources[Resource] = {Amount=Amount,CPU=Cost} //Update the server table. (This is for devices to read from.)
end

function LDE.Cash.Market.ResetAll()
	for k,v in pairs(LDE.Cash.Resources) do
		LDE.Cash.Market.UpResource(v.O,v.S,v.C)
	end
end
concommand.Add("LDE_tradenetworkreset",LDE.Cash.Market.ResetAll)

//Check of the LDE Market table exists
if not sql.TableExists("ldemarket") then
	local query = "CREATE TABLE ldemarket (resource varchar(255), amount int, value int);" //Format the query
	local result = sql.Query(query) //Send the query in
	if (sql.TableExists("ldemarket")) then
		Msg("Succes! market table created \n") //Woo!
		LDE.Cash.Market.ResetAll() //Fill the new table with the base data.
	else
		Msg("Somthing went wrong with the ldemarket query ! \n")
		Msg( sql.LastError( result ) .. "\n" ) // Dam
	end
end

//Sell Resource Function
function LDE.Cash.Market.AddResource(Resource,Mount)
	local RTab = LDE.Cash.Market.Resources[Resource]
	local RValue = RTab.CPU
	local Rmount=RTab.Amount
	local Amount = Mount+Rmount
	local PerChange = (((Rmount/(Amount))*100)-100)*-1
	local Value = RValue-((RValue*(PerChange*100)))
	local profit = (RValue*Mount)*0.9
	MsgAll("PerChange: "..PerChange.." Amount: "..Amount.." SV: "..RValue.." V: "..Value.." Money: "..profit)
	LDE.Cash.Market.UpResource(Resource,Amount,Value)
	return profit
end

//Buy Resource Function
function LDE.Cash.Market.TakeResource(Resource,Mount,ply)
	local RTab = LDE.Cash.Market.Resources[Resource]
	local RValue = RTab.CPU
	local Rmount=RTab.Amount
	local Amount = Rmount-Mount
	local PerChange = (((Rmount/(Amount))*100)-100)*-1
	local Value = RValue-((RValue*(PerChange)))
	local profit = (RValue)*Mount
	
	if(tonumber(ply:GetLDEStat("Cash"))<tonumber(profit))then --Dont edit the trade market if we cant afford it.
		return 0
	end
	
	MsgAll("PerChange: "..PerChange.." Amount: "..Amount.." SV: "..RValue.." V: "..Value.." Money: "..profit)
	LDE.Cash.Market.UpResource(Resource,Amount,Value)
	return profit
end

function LDE.Cash.Market.GetResource(Resource)
	local row = sql.Query( "SELECT amount, value FROM ldemarket WHERE resource = '" .. Resource .. "';" ) //Check for the resource
	if row then//IF Data found.
		local Amount = tonumber(sql.QueryValue("SELECT amount FROM ldemarket WHERE resource = '" .. Resource .. "';"))
		local Cost = tonumber(sql.QueryValue("SELECT value FROM ldemarket WHERE resource = '" .. Resource .. "';"))
		if(Amount>=0)then
			MsgAll("Syncing "..Resource.." A "..Amount.." C "..Cost.." \n")
			LDE.Cash.Market.Resources[Resource] = {Amount=Amount,CPU=Cost} //Update the server table.
		else
			MsgAll("Corrupted resource detected. Reseting it. "..Resource.." \n")
			local v =  LDE.Cash.Market.FindResourceSData(Resource)
			LDE.Cash.Market.UpResource(v.O,v.S,v.C)
		end
	end
end

function LDE.Cash.Market.FindResourceSData(Resource)
	for k,v in pairs(LDE.Cash.Resources) do
		if(v.O==Resource)then
			return v
		end
	end
end

function LDE.Cash.Market.UpdateAll()
	for k,v in pairs(LDE.Cash.Resources) do
		LDE.Cash.Market.GetResource(v.O)
	end	
end

timer.Simple(4,function() LDE.Cash.Market.UpdateAll() end)
concommand.Add("LDE_tradenetworkupdate",LDE.Cash.Market.UpdateAll)


function LDE.GetRealCost(ent)
	return 0
end

local ErrorCheck, PCallError = pcall(include, "lde/cashsystem/lde_globalDB.lua") --Include the database, it will override the functions if it actually runs.
if !ErrorCheck then
	Msg(PCallError.."\n")
end
end

function LDE.Cash:UpdatePerson(ply)
	updatePlayer(ply)
end

function LDE.GiveMoney(ply,amount)
	ply:GiveLDEStat("Cash",amount)
	updatePlayer(ply)
end

function LDE.TakeMoney(ply,amount)
	ply:TakeLDEStat("Cash",amount)
	updatePlayer(ply)
end

if(SERVER)then
	util.AddNetworkString('LDE_Stat')
	util.AddNetworkString('LDE_Strings')
	util.AddNetworkString('LDE_SyncBuff')
	
	function LDE.FindByNamePly(name)
		name = string.lower(name);
		for _,v in ipairs(player.GetHumans()) do
			if(string.find(string.lower(v:Name()),name,1,true) != nil)
				then return v;
			end
		end
	end

	function setstatcon(ply,cmd,args)
			
		local Stat = args[1] -- Grab the stat name were gonna use
		local Data = args[2] or 0 --Grab the variable for the stat if possible
			
		ply:SetLDEStat(Stat,Data)
			
	end
	concommand.Add("LDE_setstat", setstatcon)
	
	function playergivecash(ply,cmd,args)
	
		if (not args[1] or not args[2]) then return end
		
		local target = LDE.FindByNamePly(args[1])
		local amounts = tonumber(args[2]) or 0

		ply:TransferCash(target,amounts)
			
	end
	concommand.Add("LDE_sendfunds", playergivecash)
	
	function LDE.Mutations.HandleMutations(Ply,Event,Extra)
		if(not Ply or not Ply:IsValid() or not Ply:IsPlayer())then return end --Y U DO THIS!
		for _, mutation in pairs( Ply.Mutations ) do
			if(mutation.start+mutation.time<=CurTime()and not mutation.Removed)then
				if(mutation.Data["OnTimeEnd"])then
					mutation.Data["OnTimeEnd"](Ply)
				end
				Ply:RemoveMutation(mutation.name)
			else
				if(mutation.Data[Event])then
					mutation.Data[Event](Ply,Extra)
				end
			end
		end
	end
	
	function LDE.Mutations.ManagePlayers()
		local players = player.GetAll()
		
		for _, ply in ipairs( players ) do
			if ply and ply:IsConnected() then
				if(not ply.Mutations)then ply.Mutations = {} end
				LDE.Mutations.HandleMutations(ply,"Tick")
			end
		end		
	end
	timer.Create("LDEPlayerMutations", 1,0, LDE.Mutations.ManagePlayers)
end

local function StoreMutations( length, client )
	Ent = net.ReadEntity()
	if(not Ent or not Ent:IsValid())then return end --Derp
	Ent.Mutations = util.JSONToTable(net.ReadString()) or {}
	--print("Storing stats.")
end
net.Receive("LDE_SyncBuff", StoreMutations)

local function StoreStat( length, client )
	Ent = net.ReadEntity()
	if(not Ent or not Ent:IsValid())then return end --Derp
	Ent.Stats = util.JSONToTable(net.ReadString()) or {}
	--print("Storing stats.")
end
net.Receive("LDE_Stat", StoreStat)

local function StoreStrings( length, client )
	Ent = net.ReadEntity()
	if(not Ent or not Ent:IsValid())then return end --Derp
	Ent.SStrings = util.JSONToTable(net.ReadString()) or {}
	--print("Storing stats.")
end
net.Receive("LDE_Strings", StoreStrings)

---Player functions	
local meta = FindMetaTable( "Player" )
if not meta then return end

function meta:GetStats()
	return self.Stats or {}
end

function meta:GetStrings()
	return self.SStrings or {}
end

function meta:SyncMutations()
	net.Start('LDE_SyncBuff')
		net.WriteEntity(self)
		net.WriteString(util.TableToJSON(self.Mutations))
	net.Broadcast()
end

function meta:ClearMutations()
	for _, mutation in pairs( self.Mutations ) do
		self:RemoveMutation(mutation.name)
	end
	self.Mutations={}	--Clear the mutations table.
	self:SyncMutations() --Sync the mutations changes.
end

function meta:RemoveMutation(Name)
	self.Mutations=self.Mutations or {}
	if(self.Mutations[Name])then
		self.Mutations[Name].Removed = true
		LDE.Mutations.HandleMutations(self,"OnRemove")
		self.Mutations[Name]=nil	--Remove the mutation from the table.
		self:SyncMutations() --Sync the mutations changes.
	end
end

function meta:GiveMutation(Name,Duration,Data,Stacks,Lock)
	self.Mutations=self.Mutations or {}
	local Table = {name = Name,time = Duration,start=CurTime(),Data = Data}--Format the mutation.
	local mutation = self.Mutations[Name]
	if(Stacks and mutation and mutation.start+mutation.time<=CurTime())then
		Table = {name = Name,time = mutation.time+Duration,start=mutation.start,Data = Data}--Merge the mutation tables.
	elseif(mutation)then
		if(Stacks or Lock)then
			return
		end
	end
	self.Mutations[Name]=Table --Add it to the players mutations list.
	self:SyncMutations() --Sync the mutations we got out.	
	LDE.Mutations.HandleMutations(self,"OnStart") --Call the startup hook for mutations.
end

function meta:SetLDERole(role)
	self:SetLDEString("Role",role)
	self.Role = role
end

function meta:GetLDERole()
	return self:GetLDEString("Role")
end

----Cash Transferance Systems---

function meta:TakeCash(num)
	local stat = "Cash"
	local cash = self:GetLDEStat(stat)
	if(cash>=num)then
		self:SetLDEStat( stat, cash-tonumber(num) or 0)
		return true
	else
		return false
	end
end

function meta:GiveCash(num)
	local stat = "Cash"
	local cash = self:GetLDEStat(stat)
	self:SetLDEStat( stat, cash+tonumber(num) or 0)
end

function meta:TransferCash(ply,num)
	local stat = "Cash"
	local cash = self:GetLDEStat(stat)
	if(not ply or not ply:IsValid() or not ply:IsPlayer())then return false end
	if(num<=100)then return false end
	if(self:TakeCash(num))then
		--self:ChatPrint("You sent "..ply:Name().." "..num.." Taus.")
		self:SendColorChat("Stats",{r=255,g=0,b=0},"You sent "..ply:Name().." "..num.." Taus.")
		self:SendColorChat("Stats",{r=0,g=255,b=0},self:Name().." sent you "..num.." Taus.")
		--ply:ChatPrint(self:Name().." sent you "..num.." Taus.")
		ply:GiveCash(num)
	end
end

-----Modular Stat system--------

function meta:GiveLDEStat(stat,num)
	self:SetLDEStat( stat, self:GetLDEStat(stat)+tonumber(num) or 0 )
end

function meta:TakeLDEStat(stat,num)
	self:SetLDEStat( stat, self:GetLDEStat(stat)-tonumber(num) or 0)
end

function meta:SyncLDEStats()
	net.Start('LDE_Stat')
		net.WriteEntity(self)
		net.WriteString(util.TableToJSON(self.Stats))
	net.Broadcast()
end

function meta:SetLDEStat(stat,num) --Modular stat system.
	self:SetNWInt( "LDE"..stat, tonumber(num) or 0 )
	self.Stats[stat]=tonumber(num) or 0
	self:SyncLDEStats()
end

function meta:GetLDEStat(stat) --Modular stat system.
	local Stat = self:GetNWInt( "LDE"..stat ) 
	if(not Stat)then
		Stat=0
		self:SetLDEStat(stat,0)
	end
	return Stat
end

function meta:SyncLDEStrings()
	net.Start('LDE_Strings')
		net.WriteEntity(self)
		net.WriteString(util.TableToJSON(self.SStrings))
	net.Broadcast()
end

function meta:SetLDEString(name,str)
	self:SetNWString("LDES"..name, str or "")
	self.SStrings[name]=str or ""
	self:SyncLDEStrings()
end

function meta:GetLDEString(name)
	return self:GetNWString("LDES"..name) or "Error"
end


