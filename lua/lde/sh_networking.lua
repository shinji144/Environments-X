local LDE = LDE --Localise the global table for speed.
LDE.Utl = LDE.Utl or {}
local Utl = LDE.Utl --Makes it easier to read the code.

Utl.NetMan = Utl.NetMan or {} --Where we store the queued up data to sync.

local NDat = Utl.NetMan --Ease link to the netdata table.
NDat.Data = NDat.Data or {} -- The actual table we store data in.
NDat.NHook = NDat.NHook or {} --The table we store net hooks in.

local NumBool = function(V) if V then return 1 else return 0 end end --Bool to number.
local BoolNum = function(V) if V>0 then return true else return false end end --Number to bool.

NDat.NetDTWrite = {S=net.WriteString,E=function(V) net.WriteFloat(V:EntIndex()) end,F=net.WriteFloat,V=net.WriteVector,A=net.WriteAngle,B=function(V) net.WriteFloat(NumBool(V)) end,T=function(T) net.WriteString(util.TableToJSON(T)) end}
NDat.NetDTRead = {S=net.ReadString,E=function(V) return Entity(net.ReadFloat()) end,F=net.ReadFloat,V=net.ReadVector,A=net.ReadAngle,B=function() return BoolNum(net.ReadFloat()) end,T=function() return util.JSONToTable(net.ReadString()) or {} end}

--Actually sends the data out.
function NDat.SendData(Data,Name,ply)
	net.Start("sing_basenetmessage")
		net.WriteString(Name)
		net.WriteFloat(table.Count(Data.Dat))
		for I, S in pairs( Data.Dat ) do --Loop all the variables.
			net.WriteString(S.N)--Get the variable name.
			net.WriteString(S.T)
			NDat.NetDTWrite[S.T](S.V)
		end
	if SERVER then
		net.Send(ply)
	else
		net.SendToServer()
	end
end

function Utl:HookNet(MSG,ID,Func) NDat.NHook[MSG] = Func end
function NDat:InNetF(MSG,Data,ply) 
	if(NDat.NHook[MSG])then
		NDat.NHook[MSG](Data,ply) 
	else 
		print("Unhandled message... "..MSG) 
	end 
end

--Function that receives the netmessage.
net.Receive( "sing_basenetmessage", function( length, ply )
	local Name = net.ReadString() --Gets the name of the message.
	local Count = net.ReadFloat() --Get the amount of variables were recieving.
	
	local D = {}
	for I=1,Count do --Read all the variables.
		local VN = net.ReadString()
		local Ty = net.ReadString()
		D[VN]=NDat.NetDTRead[Ty]()
	end
	NDat:InNetF(Name,D,ply)	
end)

if(SERVER)then	
	--[[----------------------------------------------------
	Serverside Networking Handling.
	----------------------------------------------------]]--

	util.AddNetworkString( "sing_basenetmessage" )

	--Loops the players and prepares to send their data.
	function NDat.CyclePlayers()
		for nick, pdat in pairs( NDat.Data ) do
			local Max = 200
			for id, Data in pairs( pdat.Data ) do
				if(Max<=0)then return end--We reached the maximum amount of data for this player.
				Max=Max-Data.Val
				NDat.SendData(Data,Data.Name,pdat.Ent)
				table.remove(pdat.Data,id)
			end
		end
	end

	--[[
		Data={Name="example",Val=1,Dat={{N="D",T="S",V="example"}}}
	]]	
	function NDat.AddData(Data,ply)
		local T=NDat.Data[ply:Nick()]
		if not T then return end
		for I, S in pairs( Data.Dat ) do
			if S.V == nil or S.T == nil or S.N == nil then 
				Data.Dat[I]=nil
			end
		end
		table.insert(T.Data,Data)
	end
	
	function NDat.AddDataAll(Data)
		Utl:LoopValidPlayers(function(ply) NDat.AddData(Data,ply) end)
	end
	
	--Creates the table we will use for each player.
	function NDat.AddPlay(ply)
		NDat.Data[ply:Nick()]={Data={},Ent=ply}
	end
	
	Utl:SetupThinkHook("SyncNetData",0.1,0,NDat.CyclePlayers)	
	Utl:HookHook("PlayerInitialSpawn","NetDatHook",NDat.AddPlay,1)	
	
else
	function NDat.AddData(Data) table.insert(NDat.Data,Data) end
	
	function NDat.SendToServer()
		local Max = 50
		for id, Data in pairs( NDat.Data ) do
			if(Max<=0)then break end--We reached the maximum amount of data we can send this tick.
			Max=Max-Data.Val
			NDat.SendData(Data,Data.Name)
			table.remove(NDat.Data,id)
		end
	end
	
	Utl:SetupThinkHook("SendToServer",0.1,0,NDat.SendToServer)	
	
end














