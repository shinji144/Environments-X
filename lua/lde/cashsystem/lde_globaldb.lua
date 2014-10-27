if SERVER then
	local ErrorCheck, PCallError = pcall(require,"mysqloo") --Check if theirs mysqloo
	if(!ErrorCheck)then print(PCallError) end
	GlobalDB = {}
	
	local ErrorCheck, PCallError = pcall(include,"lde/cashsystem/lde_key.lua") --Check if we have a sql database key (This is important!)
	if(!ErrorCheck)then print(PCallError) end
	
	function notifyerror(...)
		ErrorNoHalt("[", os.date(), "][Database stuff] ", ...);
		ErrorNoHalt("\n");
		local words = table.concat({"[Database stuff] ",...},"");
		LDE.Logger.LogEvent(words);
	end

	function notifymessage(...)
		local words = table.concat({"[Database stuff] ",...},"");
		--ServerLog(words);
		LDE.Logger.LogEvent(words);
	end
	
	function LDE.Cash.GetStatQuery(uid)
		return "SELECT * FROM ldeplystats WHERE SteamID = '" ..uid.. "'"
	end
	
	function LDE.Cash.GetUpdateQuery(ply)
		local Stats = util.TableToJSON(ply:GetStats())
		local Strings = util.TableToJSON(ply:GetStrings())
		updateString = "UPDATE ldeplystats SET Stats='%s', Strings='%s' WHERE SteamID ='%s'"		
		local uid = ply:SteamID()
		return string.format(updateString,Stats,Strings,uid)
	end	
	
	function LDE.Cash.GetInsertQuery(ply)
		local Stats = util.TableToJSON(ply:GetStats())
		local Strings = util.TableToJSON(ply:GetStrings())
		updateString = "INSERT INTO ldeplystats(SteamID, Stats, Strings) VALUES ( '%s', '%s', '%s' )"
		local uid = ply:SteamID()
		return string.format(updateString,uid,Stats,Strings)
	end	
	
	function LDE.Cash.SetBaseData(ply)
		ply:SetLDEStat("Cash", 100)
		ply:SetLDEStat("Bounty", 0)
		ply:SetLDEStat("Mined", 0)
		ply:SetLDEStat("Trades", 0)
		ply:SetLDERole("Civilian")
		ply:SetLDEStat("Kills", 0)
	end
	
	if(mysqloo and GlobalDB.Host)then

		GlobalDB.connected = false;


		STATUS_READY    = mysqloo.DATABASE_CONNECTED;
		STATUS_WORKING  = mysqloo.DATABASE_CONNECTING;
		STATUS_OFFLINE  = mysqloo.DATABASE_NOT_CONNECTED;
		STATUS_ERROR    = mysqloo.DATABASE_INTERNAL_ERROR;

		function connectToDatabase()

			db = mysqloo.connect(GlobalDB.Host, GlobalDB.Username, GlobalDB.Password, GlobalDB.Database_name, GlobalDB.Database_port)
			db.onConnected = function() 
				LDE.Logger.LogEvent("***********Database linked!***********") 
				GlobalDB.connected = true;
			end
			db.onConnectionFailed = function(self, err)
				GlobalDB.connected = false;
				print("[LDE Stats]Failed to connect to the database: ", err, ". Retrying in 60 seconds.");
				timer.Simple(60, function()
					db:connect()
				end);
			end	
			db:connect()
		end
		--hook.Add( "Initialize", "DBStuff - connect", connectToDatabase ); 
		timer.Simple(5, function() connectToDatabase() end);
		concommand.Add("LDE_tradeconnectdb",connectToDatabase)

		function checkQuery(query)
			local playerInfo = query:getData()
			if playerInfo[1] ~= nil then
				return true
			else
				return false
			end
		end 

		-- From Lexic's SB module.
		function CheckStatus()
			local status = db:status();
			if (status == STATUS_WORKING or status == STATUS_READY) then
				return;
			elseif (status == STATUS_ERROR) then
				GlobalDB.connected = false;
				LDE.Logger.LogEvent("[LDE Stats]The database object has suffered an internal error and will be recreated.");
				connectToDatabase();
			else
				GlobalDB.connected = false;
				db:abortAllQueries();
				LDE.Logger.LogEvent("[LDE Stats]The server has lost connection to the database. Retrying...")
				db:connect();
			end
		end
		timer.Create("DBStuff - status checker", 60, 0, CheckStatus);
		concommand.Add("LDE_tradestatus",CheckStatus)
		
		local peopleToUpdate = {}

		function LDE.Cash.getstats( ply )


			if not GlobalDB.connected then 
				
				timer.Simple( 10, loadServerStats, ply )
				LDE.Cash.SetBaseData(ply)
				ply.dbReady = true;
				
				return; 
			end
			if not ply:IsValid() then return; end

			local uid = ply:SteamID()
			local tquery1 = db:query( LDE.Cash.GetStatQuery(uid) )
			tquery1.onSuccess = function(q)
				if not checkQuery(q) then
					LDE.Cash.SetBaseData(ply)
					local tquery2 = db:query(LDE.Cash.GetInsertQuery(ply))
					tquery2.onSuccess = function(q)  
					
						notifymessage("[LDE Stats]Created: " .. ply:Nick()) 
						ply.dbReady = true;
						
						ply:SyncLDEStats()
						ply:SyncLDEStrings()
						LDEFigureRole(ply)
					end
					
					tquery2.onError = function(q,e) 
						notifymessage("[LDE Stats]Something went wrong")
						notifyerror(e)
					end
					tquery2:start()
					
				else
					
					notifymessage("[LDE Stats]Loading: " .. ply:Nick())
					local tquery3 = db:query( LDE.Cash.GetStatQuery(uid))
					
					tquery3.onSuccess = function(q, sdata)
					local row = sdata[1];			
						if (#tquery3:getData() == 1) then
						
							local Stats = util.JSONToTable(row.Stats)
							local Strings = util.JSONToTable(row.Strings)
							local Str = "GetStats: "
							for i,stat in pairs(Stats) do
								Str=Str.." "..i..": "..stat
								ply:SetLDEStat(i, stat)
							end
							for i,stat in pairs(Strings) do
								Str=Str.." "..i..": "..stat
								ply:SetLDEString(i, stat)
							end
							notifymessage(Str)
							
							ply.dbReady = true;
							
							ply:SyncLDEStats()
							ply:SyncLDEStrings()
							LDEFigureRole(ply)
						end
					end	

					tquery3.onError = function(q,e)
						notifymessage("[LDE Stats]Something went wrong")
						notifyerror(e)
					end
					tquery3:start()
				end
			end 
			tquery1.onError = function(q,e)
				notifymessage("[LDE Stats]Something went wrong")
				notifyerror(e)
			end
			tquery1:start()
		end

		 

		function updatePlayer(ply)
			if not ply.dbReady then return end
			if table.HasValue( peopleToUpdate, ply ) then return; end
			table.insert( peopleToUpdate, ply);

		end


		function updateAll()		
			local players = player.GetAll()
			
			for _, ply in ipairs( players ) do
				if ply and ply:IsConnected() then
					ply:GiveLDEStat("Cash",20)
					updatePlayer( ply )
					LDEFigureRole(ply)
				end
			end
		end
		timer.Create("LDECashTimer", 300, 0, updateAll);

		function savePlyStatsSQL()

			if #peopleToUpdate == 0 then return; end

			if not GlobalDB.connected then return; end
			
			ply = peopleToUpdate[1];
			table.remove(peopleToUpdate, 1)
			if ply:IsValid() then
				local formQ = LDE.Cash.GetUpdateQuery(ply)
				
				local updateQuery = db:query(formQ)
				updateQuery.onSuccess = function(q) end; 
				updateQuery.onError = function(q,e)
					notifymessage("[LDE Stats]Something went wrong")
					notifyerror(e)
				end
				updateQuery:start()
			end
		end
		timer.Create("StatsUpdater", 5, 0, savePlyStatsSQL);

		local function pGone( ply )
			if ply.dbReady then
				updatePlayer(ply);
			else
				LDE.Logger.LogEvent("[LDE Stats]Error: Couldnt Save to Global Database!")
			end	
		end

		local function pCome( ply )
			ply.dbReady = false
			LDE.Cash.getstats(ply);
		end

		hook.Add( "PlayerInitialSpawn", "playerComes", pCome )
		hook.Add( "PlayerDisconnected", "playerGoes", pGone )
	else
						
		if not sql.TableExists("ldeplystats") then
			local query = "CREATE TABLE ldeplystats (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, SteamID varchar(255), Stats varchar(255) , Strings varchar(255));" //Format the query
			local result = sql.Query(query) //Send the query in
			if (sql.TableExists("ldeplystats")) then
				sql.Query( "CREATE INDEX IDX_LDE_PLAYER ON ldeplystats ( player DESC );" ) 
				Msg("Succes! market table created \n") //Woo!
			else
				Msg("Somthing went wrong with the ldeplystats query ! \n")
				Msg( sql.LastError( result ) .. "\n" ) // Dam
			end
		else
			Msg("The stats table exists. \n")
		end
	
		function LDE.Cash.getstats( ply )
			local uid = ply:SteamID()
			local row = sql.QueryRow( LDE.Cash.GetStatQuery(uid))
			
			ply.LDETeam = 0
			if(row)then
				local Stats = util.JSONToTable(row.Stats)
				local Strings = util.JSONToTable(row.Strings)
				local Str = "GetStats: "
				for i,stat in pairs(Stats) do
					Str=Str.." "..i..": "..stat
					ply:SetLDEStat(i, stat)
				end
				for i,stat in pairs(Strings) do
					Str=Str.." "..i..": "..stat
					ply:SetLDEString(i, stat)
				end
				print(Str)
			else
				LDE.Cash.SetBaseData(ply)
				local SQL = sql.Query(LDE.Cash.GetInsertQuery(ply))

			end
		end

		function updatePlayer( ply )
			sql.Query( LDE.Cash.GetUpdateQuery(ply))//Update the current data
		end
		hook.Add( "PlayerDisconnected", "LDECashDisconnect", updatePlayer )
					
		function updateAll()
			local players = player.GetAll()
			
			for _, ply in ipairs( players ) do
				if ply and ply:IsConnected() then
					ply:GiveLDEStat("Cash",5)
					updatePlayer( ply )
					LDEFigureRole(ply)
				end
			end
		end
		timer.Create( "LDECashTimer", 67, 0, updateAll )
	end


end


print("GlobalDBfileLoaded")
