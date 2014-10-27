--[[
	Resources API
		Last Update: April 2012

		file: resources_api.lua
		
	Use this in your Life Support devices. Using these function names will
	insure they are compatibile with other systems that use this API.

	This will be called as a shared file as it contains both SERVER and
	CLIENT functions.

	Client Side Functions:
		ent:ResourcesDraw()

	Server Side Functions:
		ent:ResourcesConsume( resourcename, amount )
		ent:ResourcesSupply( resourcename, amount )
		ent:ResourcesGetCapacity( resourcename )
		ent:ResourcesSetDeviceCapacity( resourcename, amount )
		ent:ResourcesGetAmount( resourcename )
		ent:ResourcesGetDeviceAmount( resourcename )
		ent:ResourcesGetDeviceCapacity( resourcename )
		ent:ResourcesLink( entity )
		ent:ResourcesUnLink( entity )
		ent:ResourcesCanLink( entity )
]]
print("RESOURCES API INSTALLED")

RESOURCES = {}
RESOURCES.Version = 1 --only changes when something major gets changed
RESOURCES.Tools = {}

--register the device clientside
function RESOURCES:Setup( ent )
	--[[
		your shared code here
	]]
	
	--client functions
	if CLIENT then
		--[[
			your client side code here
		]]
		
		//load network data/setup variables
		local tab = Environments.GetEntTable(ent:EntIndex())
		ent.maxresources = tab.maxresources
		ent.resources = tab.resources
		ent.node = Entity(tab.network) or NULL
		
		--Used do draw any connections, "beams", info huds, etc for the devices.
		--this would be placed within the ENT:Draw() function
		function ent:ResourcesDraw( ent )
			-- your code here
		end

	--server functions
	elseif SERVER then
		--[[
			your server side code here
		]]
		
		//setup variables
		ent.node = nil
		ent.resources = {}
		ent.maxresources = {}
		
		--Can be negitive or positive (for consume and generate)
		-- supply: resource name or resource table
		-- returns: amount not consumed
		function ent:ResourcesConsume( res, amount )
			if type(res) == "table" then
				local consume = {}
				for n, v in pairs( res ) do
					consume[n] = self:ResourcesConsume( n,v )
				end
				return consume
			end

			if self.node then
				return self.node:ConsumeResource(res, amount)
			end
			
			return 0 --0 = success. Anything larger and it couldnt consume the amount
		end

		--Supplies the resource to the connected network
		-- supply: resource name or resource table
		-- returns:
		function ent:ResourcesSupply( res, amount )
			if type(res) == "table" then
				local supply = {}
				for n, v in pairs( res ) do
					supply[n] = self:ResourcesGenerate( n,v )
				end
				return supply
			end

			if self.node then
				return self.node:GenerateResource(res, amount)
			end
			
			return 0 --0 = success. Anything larger and it couldnt supply the amount (insufficient storage)
		end

		--Gets the devices networks total storage for the resource
		-- supply: resource name
		-- returns: number
		-- note: If passed in nothing (nil), return the capity for each resource
		function ent:ResourcesGetCapacity( res )
			if (res) then
				if self.node then
					return self.node.maxresources[res] or 0
				end
				
				return 0
			else
				return self.node.maxresources --table of resources
			end
		end

		--Sets the device max storage capacity
		-- supply: resource name or resource table
		-- returns:
		function ent:ResourcesSetDeviceCapacity( res, amount )
			if type(res) == "table" then
				for n, v in pairs( res ) do self:ResourcesSetDeviceCapacity( n,v ) end
			return end

			//needs work/testing
			if not self.maxresources then self.maxresources = {} end
			self.maxresources[name] = amt
		end

		--  Gets the devices stored amount of resource from the connected network
		--  supply: resource name
		--  returns: number
		function ent:ResourcesGetAmount( res )
			if (res) then
				if self.node then
					if self.node.resources[resource] then
						return self.node.resources[res].value
					else
						return 0
					end
				end
				return self.resources[res] or 0
			else
				if self.node then
					local t = {}
					for k,v in pairs(self.node.resources) do
						t[k] = v.value
					end
					return t
				end
				return self.resources --table of resources
			end
		end

		--how much this devive is holding
		-- supply: resource name
		-- returns: number
		function ent:ResourcesGetDeviceAmount( res )
			if (res) then
				return self.resources[res] or 0
			else
				return self.resources --table of resources
			end
		end

		--how much this devives network is holding
		-- supply: resource name
		-- returns: number
		function ent:ResourcesGetDeviceCapacity( res )
			if (res) then
				return self.maxresources[res] or 0
			else
				return self.maxresources --table of max resources
			end
		end

		--link to another device/network
		-- supply: entity
		-- returns:
		function ent:ResourcesLink( entity )
			if self.node then
				self:Unlink()
			end
			if entity and entity:IsValid() then
				self.node = entity
				
				umsg.Start("Env_SetNodeOnEnt")
					umsg.Short(self:EntIndex())
					umsg.Short(entity:EntIndex())
				umsg.End()
			end
		end

		--removes all link from a network
		-- supply: entity or table of entities (all optional)
		-- returns:
		-- note: if an entity is passed in then unlink with that entity, otherwise unlink all
		function ent:ResourcesUnLink( entity )
			if type(entity) == "table" then
				for _, v in pairs( res ) do self:ResourcesUnLink( v ) end
			return end

			if (!entity) then --unlink all
				if self.node then
					self.resources = {}
					if self.maxresources then
						for k,v in pairs(self.maxresources) do
							--print("Resource: "..k, "Amount: "..v)
							local amt = self:GetResourceAmount(k)
							if amt > v then
								amt = v
							end
							if self.node.resources[k] then
								self.node.resources[k].value = self.node.resources[k].value - amt
							end
							--print("Recovered: "..amt)
							self.resources[k] = amt
							--self:UpdateStorage(k)
						end
					end
					self.node.updated = true
					self.node:Unlink(self)
					self.node = nil
					self.client_updated = false

					umsg.Start("Env_SetNodeOnEnt")
						umsg.Short(self:EntIndex())
						umsg.Short(0)
					umsg.End()
				end
			else
				--your code here, unlink with entity
			end
		end

		--determains if two devices can be linked
		-- supply: entity or table of entities
		-- returns: boolean (if entity passed in), or table (if table of entities passed in)
		function ent:ResourcesCanLink( entity )
			if type(ent) == "table" then
				local links = {}
				for _, v in pairs( ent ) do
					links[ent] = self:ResourcesCanLink( v )
				end
				return links
			end

			--your code here
			return false
		end
		
		--Returns a list of connected entities
		function ent:ResourcesGetConnected()
			return {} --returns a table of all connected entities
		end

		--This function is called to save any resource info so it can be saved using the duplicator
		--this goes into ENT:PreEntityCopy
		function ent:ResourcesBuildDupeInfo()
			--your code here
		end

		--This function is called to store any resource info after a dup
		--this goes into ENT:PostEntityPaste
		function ent:ResourcesApplyDupeInfo( ply, ent, CreatedEntities )
			--your code here
		end
	end
end

local meta = FindMetaTable( "Entity" )

--sets up the functions to be used on the "Life Support" devices
-- supply: entity
function meta:InitResources( )
	RESOURCES:Setup( self )
end






if (CLIENT) then
	local meta = FindMetaTable("Entity")

	--- Used to draw any connections, "beams", info huds, etc for the devices.
	-- This should go into ENT:Draw() or any other draw functions.
	-- @param ent The entity. Does this really need explanation?
	-- @return nil
	function meta:ResourcesDraw(ent)

    end
end

---Note: limit may be a function, value, or nil. So within tool make sure to check against function if type(limit)=="function"
--Optional: categories
function RESOURCES:ToolRegister(name, description, limit)
	self.Tools[toolname] = self.Tools[toolname] or {}
	self.Tools[toolname].limit = limit or 30
	self.Tools[toolname].description = description or ""
end
 
---adds a category row to the tool
function RESOURCES:ToolRegisterCategory( toolname, categoryname, categorydescription, limit )
	self.Tools[toolname] = self.Tools[toolname] or {}
	self.Tools[toolname].categories = self.Tools[toolname].categories or {}
	self.Tools[toolname].categories[categoryname] = {
		description = categorydescription,
		limit = limit
	}
end
 
---This function will make it so custom devices could be added to your tool system.
--This call would be placed in the entities shared.lua file
--example: RESOURCES:ToolRegisterDevice("Life Support", "Storage Devices", "Air Tank", "air_tank", "models/props_c17/canister01a.mdl")
--makefunc is for backwards compatibility. This really should just but in the ENT:Initalize function
--@params toolname The name of the Tools EG: 'Cdsweapons'
--@params categoryname The Name of the category
--@params name The print name of the entity to be added
--@params class No idea
--@params model The model 
--@params makefunc Backwards Compatibilty really
function RESOURCES:ToolRegisterDevice(toolname, categoryname, name, class, model, makefunc)
	if type(name) == "table" then
		for _, v in pairs(name) do 
			//CAF_AddStoolItem(toolname, categoryname, v.name, v.class, v.model, v.makefunc) 
			Environments.RegisterDevice(toolname, categoryname, v.name, v.class, v.model, 0, nil)
		end
		return
	end
 
	self.Tools[toolname] = self.Tools[toolname] or {}
	self.Tools[toolname].categories = self.Tools[toolname].categories or {}
	self.Tools[toolname].categories[categoryname] = self.Tools[toolname].categories[categoryname] or {}
	self.Tools[toolname].categories[categoryname].devices = self.Tools[toolname].categories[categoryname].devices or {}
	self.Tools[toolname].categories[categoryname].devices[name] = {
                class = class,
                model = model,
                makefunc = makefunc
	}
 
	Environments.RegisterDevice(toolname, categoryname, name, class, model, 0, nil)
	//Environments.RegisterDevice(toolname, genname, devname, class, model, skin, extra)
	//CAF_AddStoolItem( category, name, model, class, makefunc )
end

hook.Add("AddTools", "environments resources tool hax", function()
	for k,v in pairs(RESOURCES.Tools) do
		Environments.RegisterTool(k, k.."_tool"/* actual tool name */, "Addons"/*toolmenu category tab*/, v.description, k/*limit identifier*/, v.limit or 30)
	end
end)

/*if (SERVER) then
	function RS:Link(ent,ent1)
		RD.Link(ent,ent1)
	end
	
	
	--Start of Entity: Functions 
	local meta = FindMetaTable("Entity")
	
	function meta:Register(typeEnt)
		if (type(typeEnt) == "string") then
			if (typeEnt == "NonStorage") then
			RD.RegisterNonStorageDevice(self)
			//eslif (typeEnt == "
		end
	end
	
	--- Used to Consume Resources.
	-- Call it with ENT:ResConsume()
	--@param res The String or table of the resource(s) you want to consume
	--@param amt The amount you want to consume. Can be negative or positive.
	--@returns Amount Consumed.. If it is coded by Developers to.
	function meta:ResConsume( res, amt )
		if (type(res) == "table") then
			for k,v in pairs(res) do 
				local amtTotal = amtTotal + RD.Consume(self,v,amt)
			end
		elseif (type(res) == "string") then
			return RD.Consume(self,res,amt)
		end
	end
	
	--- Supplies the Resource to the connected network.
	-- Call it with ENT:ResourcesSupply()
	--@param res The string or table of the resource(s) you want to supply to the connected network.
	--@param amt The amount you want to supply
	--@returns Amount that could not be supplied.
	function meta:ResourcesSupply( res, amt )
		if (type(res) == "table") then
			for k,v in pairs(res) do 
				local amtTotal = amtTotal + RD.SupplyResource(self,v,amt)
			end
			return amtTotal
		elseif (type(res) == "string") then
			return RD.SupplyResource(self,res,amt)
		end	
	end
	
	--- Get's the network capacity of the entity.
	--@returns The Capcity of the network attached to the entity. This is the maximum amount of res it can have.
	--@param res The resource you want it to return the capacity of.
	function meta:ResourcesGetCapacity( res )
		RD.GetNetworkCapacity(self,res)
	end

	--- Set's the Capacity of the entity.
	--@param amt The capacity you want to set
	--@param res The resource (string or table) you want to set the capacity (amt) of
	--@param def The default amount you want the entity to contain.
	function meta:ResourcesSetDeviceCapacity( res, amt, def  )
		if (type(res) == "table") then
			for k,v in pairs(res) do 
				RD.AddResource(self, v, amt, def)
			end
		elseif (type(res) == "string") then
			RD.AddResource(self,res,amt,def) 
		end
	end
	
	--- Get's the amount of the entity.
	--@returns The amount contained
	--@params res The resource you want the amount of. (String or Table)
	function meta:ResourcesGetAmount( res )
		if (type(res) == "table") then
			resources = {}
			for _,v in pairs(res) do
				resources[v] = RD.GetResourceAmount(self, v)
			end
			return resources
		else
			return RD.GetResourceAmount(self, res )
		end
	end
	
	--- Get's how much of the resource is contained in the netowrk attached to this entity.
	--@returns The amount stored in the device's network
	--@params res The resource you want to return the amount of. (String or Table)
	function meta:ResourceGetDeviceCapaciy( res )
		if (type(res) == "table") then
			resources = {}
			for _,v in pairs(res) do
				resources[v] = RD.GetUnitCapacity(self, v)
			end
			return resources
		else
			return RD.GetUnitCapacity(self, res )
		end
	end

	--- Custom Link. Not needed for RD3 or RD2
	function ResourcesLink( ent, ent1)

	end
	-- No idea how this works.
	function meta:ResourcesGetConnected()
		local ent = self
		
	end

	function meta:ResourcesApplyDupeInfo( ply, entity, CreatedEntities )
		RD.ApplyDupeInfo(self, CreatedEntities)
	end

	function meta:ResourceBuildDupeInfo()
		RD.BuildDupeInfo(self)
	end
end*/
