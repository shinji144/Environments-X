local LDE = LDE
local Debug = function(MSG) LDE.Debug(MSG,3,"LSSOwner") end

function LoadPP()
	if CPPI and CPPI.GetName then
		Debug("Prop Protection Detected! Using its functions.")
		--Oh good we have a CPPI prop protection installed, we can use it.
		function LDE.GivePlyProp(owner,prop)
			prop:CPPISetOwner(owner)
			if not owner or not IsValid(owner) then return end --Fail safe incase owner is invalid
			if owner:IsPlayer() then
				Debug("Entity: "..tostring(prop).." Given to "..owner:Nick())
			end
		end
		
		function LDE.GetPropOwner(prop)
			return prop:CPPIGetOwner()
		end	
	else
		--Code better failsafe prop protections later.
		Debug("No Prop Protections Detected! Defaulting to built in functions.")
		--Use failsafe ownership detections by running own "prop protection" code.
		local metaent = FindMetaTable("Entity")
		local metaply = FindMetaTable("Player")

		function LDE.GivePlyProp(owner,prop)
			if type(owner) == "string" then
				prop.LSSOwner = nil
				Debug("Entity: "..tostring(prop).." Is now Ownerless ")
			else
				prop.LSSOwner = owner
				if owner:IsPlayer() then
					Debug("Entity: "..tostring(prop).." Given to "..owner:Nick())
				end
			end
		end

		function LDE.GetPropOwner(prop)
			if prop.LSSOwner and IsValid(prop.LSSOwner) then
				return prop.LSSOwner
			end
			return game.GetWorld()
		end

		CPPI={}
		function CPPI:GetName() return "LDE FailSafe" end
		function CPPI:GetVersion() return LDE.Version end
		function metaent:CPPIGetOwner() return LDE.GetPropOwner(self) end
		function metaent:CPPISetOwner(ply) return LDE.GivePlyProp(ply,self) end
		function metaent:CPPISetOwnerless(bool) return LDE.GivePlyProp("Ownerless",self) end
		function metaply:CPPIGetFriends() return {} end
		function metaent:CPPICanTool(ply,mode) return true end
		function metaent:CPPICanPhysgun(ply) return true end
		function metaent:CPPICanPickup(ply) return true end
		function metaent:CPPICanPunt(ply) return true end

		hook.Add("PlayerSpawnedSENT","LSSOwnerGive", LDE.GivePlyProp)
		hook.Add("PlayerSpawnedVehicle","LSSOwnerGive", LDE.GivePlyProp)
		hook.Add("PlayerSpawnedSWEP", "LSSOwnerGive", LDE.GivePlyProp)
		hook.Add("PlayerSpawnedProp","LSSOwnerGive", function(p,m,e) LDE.GivePlyProp(p,e) end)
	end
end

hook.Add("InitPostEntity","Envx OwnerShip", LoadPP)
