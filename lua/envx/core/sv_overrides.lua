------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

function table.Sanitise(tab)
	for k,v in pairs(tab) do
		local t = type(v)
		if t == "boolean" then
			tab[k] = {}
			tab[k].__type = "bool"
			tab[k]["1"] = tostring(v)
		elseif t == "table" then
			tab[k] = table.Sanitise(v)
		elseif t == "Vector" then
			tab[k] = {}
			tab[k].__type = "vector"
			tab[k].x = v.x
			tab[k].y = v.y
			tab[k].z = v.z
		elseif t == "Angle" then
			tab[k] = {}
			tab[k].__type = "angle"
			tab[k].p = v.p
			tab[k].y = v.y
			tab[k].r = v.r
		end
	end
	return tab
end

function table.DeSanitise(tab)
	for k,v in pairs(tab) do
		local t = type(v)

		if t == "table" then
			if v.__type then
				if v.__type == "bool" then
					if v["1"] == "true" then
						tab[k] = true
					else
						tab[k] = false
					end
				elseif v.__type == "vector" then
					tab[k] = Vector(v.x, v.y, v.z)
				elseif v.__type == "angle" then
					tab[k] = Angle(a.p, a.y, a.r)
				end
			else
				tab[k] = table.DeSanitise(v)
			end
		end
	end
	return tab
end

//Override CAF to fix issues with tools
timer.Create("registerCAFOverwrites", 5, 1, function()
	if CAF then
		local old = CAF.GetAddon
		local SB = {}
		
		function SB.GetStatus()
			return true
		end
		
		//PewPew Compatibility
		function SB.PerformEnvironmentCheckOnEnt(ent)
			for k,v in pairs(environments) do
				local distance = v:GetPos():Distance(ent:GetPos())
				if distance <= v.radius then
					ent.environment = v
					return
				end
			end
			ent.environment = Space()
		end
		
		function SB.OnEnvironmentChanged(ent)
		
		end
		//End PewPew Compatibility

		function LS.GetStatus()
			return true
		end
		
		function LS.DamageLS()
		
		end
		
		function CAF.GetAddon(name)
			if name == "Spacebuild" then
				return SB
			elseif name == "Life Support" then
				return LS
			end
			return old(name)
		end
	end
end)