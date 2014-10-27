-- 0 Client 1 Shared 2 Server
function EnvX.LoadFile(Path,Mode)
	if SERVER then
		if Mode >= 1 then
			include(Path)
			if Mode == 1 then
				AddCSLuaFile(Path)
			end
		else
			AddCSLuaFile(Path)
		end
	else
		if Mode <= 1 then
			include(Path)
		end
	end
end