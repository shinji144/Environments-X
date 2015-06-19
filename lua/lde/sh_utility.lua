--[[----------------------------------------------------
Shared Utility LUA -Holds all the utility functions for the mod.
----------------------------------------------------]]--

local LDE = LDE --Localise the global table for speed.
LDE.Utl = {} --Make a Utility Table.
local Utl = LDE.Utl --Makes it easier to read the code.

Utl.ThinkLoop = Utl.ThinkLoop or {} --Create the think loop table.
Utl.DebugTable = Utl.DebugTable or {} --Create the debug output storage.
Utl.Hooks = Utl.Hooks or {} --Create the hook table.
Utl.Effect = Utl.Effect or {} --Create a table to store effect data in.

local DTable = Utl.DebugTable --Localise the debug storage.
local HTable = Utl.Hooks --Localise the hook table for speed.

function Utl:TableRand(Table)
	local Rand = math.random(1,table.Count(Table))
	local I = 1
	for n, v in pairs( Table ) do	
		if I == Rand then
			return v,I
		end
		I=I+1
	end
end

--[[----------------------------------------------------
Debugging Functions.
----------------------------------------------------]]--

--The Debug function, allows us to easily enable/disable debugging.
function Utl:Debug(Source,String,Type)
	LDE.Debug(String,2,"["..Type.."]"..Source)--Redirect this to use the debug.lua debug functions.
	--print("["..Type.."]: "..Source..": "..String)
end

--[[----------------------------------------------------
Hook Management -Hook Management, allows for easily adding/killing hooks aswell as viewing them and debugging.
----------------------------------------------------]]--

function Utl:RunHooks(Name,a1,a2,a3,a4,a5)--Run the HookHooks and return the most important return we get.
	local ReturnTable = {}
	local Hook = HTable[Name]
	
	for I, H in pairs( Hook ) do --Loop all the HookHooks.
		xpcall(function()
			local R = H.F(a1,a2,a3,a4,a5) --Call the HookHook.
			if(R~=nil)then --Did we get a return?
				local RS=tostring(R) --Localise a string version of the return.
				if(not ReturnTable[RS])then ReturnTable[RS]={N=0,R=R}end
				local RT = ReturnTable[RS]
				RT.N=RT.N+H.I --Add the HookHook's importance to the return.
			end
		end,ErrorNoHalt)
	end 
	 
	if(table.Count(ReturnTable)>0)then --We got anything to return?
		local N = 0
		for I, H in pairs( ReturnTable ) do
			if(H.N>N)then
				Return = H.R
			end
		end
		
		return Return --Return the most important return.
	end
end

function Utl:HookHook(Hook,Name,Func,Impo) --Makes the HookHook in the hook table.
	--[[
		Hook: The Name of the hook we are HookHooking.
		Name: The Name of the HookHook.
		Func: The function called when the hook is called.
		Impo: The Importance of the HookHook, this is for figuring out what we return to the hook from all HookHooks.
	]]
	if(HTable[Hook][Name])then
		Utl:Debug("Hooks","There already is a HookHook in "..Hook.." for "..Name.." overwriting!","Error")
	end
	HTable[Hook][Name]={N=Name,F=Func,I=Impo}
end

function Utl:KillHook(Name,Func) end --When we want to remove hooks from the table.

function Utl:MakeHook(Name) --Make the hookhook storage.
	if(not HTable[Name])then
		HTable[Name]={}
		local Func = function(a1,a2,a3,a4,a5)
			Utl:RunHooks(Name,a1,a2,a3,a4,a5)
		end
		hook.Add(Name,"SingHookMake",Func)
	else
		Utl:Debug("Hooks","There already is a Hook table for "..Name,"Error")
	end
end	

--[[----------------------------------------------------
MasterThink Loop
----------------------------------------------------]]--

local Thinks = Utl.ThinkLoop --Faster Access to the think loop table.

--Our Think Loop, Processes all the functions in one place.
hook.Add("Think","SingularityMainLoop",function()
	xpcall(function()
		for I, T in pairs( Thinks ) do --Loop all the think functions.
			if(T.S+T.D<CurTime())then --Check if its time to run the function.
				T.S=CurTime()--Sets the time for the next run (If we have one) 
				local Remove,TR = false,T.R --Define some variables.
				if(TR>0)then if(TR>1)then T.R=TR-1 else Remove=true end end --Repeat check.
				xpcall(function()
					if(T.F)then
						T.F()
					else
						Utl:Debug("ThinkLoop",T.N.." has no function!","Error")
					end
				end,ErrorNoHalt) --Running the function.
				if(Remove)then Thinks[I]=nil end --Removing ended functions.
			end
		end
	end,ErrorNoHalt)
end)

--Function for easily adding into the main think loop.
function Utl:SetupThinkHook(Name,Delay,Repeat,Function)
	--[[
		Name: Name of the function.
		Delay: The time it waits before being ran. (Resets after each run.)
		Repeat: How many times the function repeats before being removed.
		Function: The function thats called.
	]]
	Thinks[Name]={N=Name,S=CurTime(),D=Delay,R=Repeat,F=Function}
end

function Utl:RemoveThinkHook(Name)
	Thinks[Name]=nil
end

--[[----------------------------------------------------
NonShared Utility Functions.
----------------------------------------------------]]--
if(SERVER)then	
	Utl:MakeHook("PlayerSpawnedSENT") 
	Utl:MakeHook("PlayerSpawnedNPC") 
	Utl:MakeHook("PlayerSpawnedVehicle") 
	Utl:MakeHook("PlayerSpawnedProp") 
	Utl:MakeHook("PlayerSpawnedEffect")
	Utl:MakeHook("PlayerSpawnedRagdoll") 
	Utl:MakeHook("PlayerInitialSpawn") 
	Utl:MakeHook("OnEntityCreated")
	Utl:MakeHook("PlayerSpawn")
	Utl:MakeHook("PlayerDisconnected")
	Utl:MakeHook("PlayerConnect")
	Utl:MakeHook("PlayerInitialSpawn")
	Utl:MakeHook("OnRemove")
	Utl:MakeHook("Shutdown")
	
	function Utl:LoopValidPlayers(F,A1,A2,A3,A4,A5)
		local players = player.GetAll()	
		for _, ply in ipairs( players ) do
			if ply and ply:IsConnected() then
				local Return = F(ply,A1,A2,A3,A4,A5)
				if(Return and Return~=nil)then
					return Return
				end
			end
		end
	end
	
	--[[----------------------------------------------------
	Settings and File Functions.
	----------------------------------------------------]]--
	
	--[[
	local SettingsPath = LDE.SaveDataPath..LDE.SettingsName..".txt"
	
	if(not file.Exists(LDE.SaveDataPath,"DATA"))then
		file.CreateDir(LDE.SaveDataPath)
	end
	
	function Utl:LoadSettings()
		local DSets = table.Copy(LDE.DefaultSettings)
		LDE.Settings = table.Merge(DSets,util.JSONToTable(file.Read(SettingsPath,"DATA") or "") or {})
	end
	Utl:LoadSettings()
	
	function Utl:SaveSettings()
		file.Write(SettingsPath, util.TableToJSON(LDE.Settings))
	end
	
	Utl:HookHook("Shutdown","SettingsSave",Utl.SaveSettings,1)
	
	function Utl:SyncSettings(Ply)
		local Data ={
			Name="SingSettingsSync",Val=1,
			Dat={{N="T",T="T",V=LDE.Settings}}
		}
		if Ply then
			Utl.NetMan.AddData(Data,Ply)
		else
			Utl.NetMan.AddDataAll(Data)
		end
	end
	]]
	
	--[[----------------------------------------------------
	Serverside Chat Functions.
	----------------------------------------------------]]--
	util.AddNetworkString( "sing_sendcolchat" )
	
	function Utl:NotifyPlayers(Source,String,Color)
		local plys = player.GetAll()
		for k,v in pairs(plys) do
			v:SendColorChat(Source,Color,String)
		end
	end
	
	local meta = FindMetaTable("Player")

	function meta:SendColorChat(nam,col,msg)
		net.Start("sing_sendcolchat")
			net.WriteString(nam)
			net.WriteVector(Vector(col.r,col.g,col.b))
			net.WriteString(msg)
		net.Send(self)
	end
	
	--OnJoin
	local F = function( name, address )
		local Text = name .. " has connected."
		Utl:NotifyPlayers("Server",Text,{r=150,g=150,b=150})
	end
	--Utl:HookHook("PlayerConnect","UtlChatMsg",F,1)
	
	--OnLeave
	local F = function( ply )
		--ply:SteamID()
		local Text = ply:GetName().." has disconnected from the server."
		Utl:NotifyPlayers("Server",Text,{r=150,g=150,b=150})
	end
	--Utl:HookHook("PlayerDisconnected","UtlChatMsg",F,1)	
	
	--OnIntSpawn
	local F = function( ply )
		--local Text = ply:GetName().." has spawned."
		--Utl:NotifyPlayers("Server",Text,{r=150,g=150,b=150})
		Utl:SyncSettings(ply)
	end
	Utl:HookHook("PlayerInitialSpawn","UtlChatMsg",F,1)
	
else
	--[[----------------------------------------------------
	ClientSide Chat Handling.
	----------------------------------------------------]]--
	net.Receive( "sing_sendcolchat", function( length )
		local nam = net.ReadString()
		local vcol = net.ReadVector()
		local col = Color(vcol.x,vcol.y,vcol.z)
		local msg = net.ReadString()
		
		chat.AddText(unpack({col, nam,Color(255,255,255),": "..msg}))
	end)

	function Utl:SyncSetting(Name,Value)
		Utl.NetMan.AddData({Name="SingSettingsSync",Val=1,Dat={{N="T",T="T",V={N=Name,V=Value}}}})
	end	
end

--[[----------------------------------------------------
Other Functions
----------------------------------------------------]]--

function Utl:CheckAdmin( entity )
	if not entity or not IsValid(entity)then return false end
	if not entity:IsPlayer() then return false end
	
	if entity.WarMelonDeveloper then return true end
	
	return entity:IsAdmin()
end

function Utl:CheckValid( entity )
	if (not entity or not entity:IsValid()) then return false end
	if (entity:IsWorld()) then return false end
	if (not entity:GetPhysicsObject():IsValid()) then return false end
	if (not entity:GetPhysicsObject():GetVolume()) then return false end
	if (not entity:GetPhysicsObject():GetMass()) then return false end
	return true
end