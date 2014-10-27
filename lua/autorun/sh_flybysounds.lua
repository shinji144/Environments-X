// Script by PinkFoxi
// PinkFoxi.net

CreateConVar("sv_flybysound_minspeed", 100, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Minimum speed required for sound to be heard.")
CreateConVar("sv_flybysound_maxspeed", 1000, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Volume does not increase after this speed is exceeded.")

CreateConVar("sv_flybysound_minshapevolume", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Pitch does not increase when volume (area) falls below this amount.")
CreateConVar("sv_flybysound_maxshapevolume", 300, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Pitch does not decrease when volume (area) exceeds this amount.")

CreateConVar("sv_flybysound_minvol", 30, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Object must have at least this much volume (area) to produce fly by sounds.")

--local windsound = "pink/flybysounds/fast_windloop1-louder.wav"
local windsound = "ambient/wind/wind1.wav"

if (SERVER) then

	AddCSLuaFile()
	resource.AddSingleFile("sound/" .. windsound)
	
	--hook.Add("Think", "FlyBySound_Think_Server", function()
	function flybysoundsserverscan()
		for k, v in pairs (ents.GetAll()) do
			local Planet =  false
			if(v.environment and v.environment.GetPressure)then
				if(v.environment:GetPressure()~=0)then
					Planet=true
				end
			end
			
			if(Planet)then
				if(v:GetNWBool("flybysounds")==false)then
					v:SetNWBool( "flybysounds", true )
				end
			else
				if(v:GetNWBool("flybysounds")==true)then
					v:SetNWBool( "flybysounds", false )
				end
			end
		end
	end
	
	timer.Create("Flybysoundsplanetchecks",2,0, function() flybysoundsserverscan() end)

else

	local function averageSpeed(ent)
		local vel = ent:GetVelocity()
		return math.Round((math.abs(vel.y) + math.abs(vel.x) + math.abs(vel.z))/3)
	end

	/*local function guessScale(ent)
		if (!IsValid(ent)) then return 0 end
		return math.Round(ent:BoundingRadius()*ent:GetModelScale())
	end*/

	local function guessScale(ent)
		if (!IsValid(ent)) then return 0 end
		local min, max = ent:GetCollisionBounds()
		local vecdiff = min - max
		local scaled = vecdiff*ent:GetModelScale()
		return math.Round((math.abs(scaled.x) + math.abs(scaled.y) + math.abs(scaled.z))/3)
	end
	
	local validClasses = {"prop_physics", "prop_physics_multiplayer", "prop_ragdoll", "npc_rollermine", "sent_ball"}

	hook.Add("Think", "FlyBySound_Think", function()
		local minspeed = GetConVar("sv_flybysound_minspeed"):GetInt()
		local maxspeed = GetConVar("sv_flybysound_maxspeed"):GetInt()
		local minshapevolume = GetConVar("sv_flybysound_minshapevolume"):GetInt()
		local maxshapevolume = GetConVar("sv_flybysound_maxshapevolume"):GetInt()
		local minvol = GetConVar("sv_flybysound_minvol"):GetInt()

		for k, v in pairs (ents.GetAll()) do

			if (!table.HasValue(validClasses, v:GetClass())) then continue end

			local speed = averageSpeed(v)
			local shapevolume = guessScale(v)

			if (shapevolume < minvol) then continue end
			
			local Planet =  v:GetNWBool( "flybysounds" ) or false
			
			if (v:WaterLevel() > 1 or not Planet) then
				if(v.FlyBySound)then
					v.FlyBySound:FadeOut(0.5)
					continue
				end
			end

			if (!v.FlyBySound) then
				v.FlyBySound = CreateSound(v, windsound)
			end

			if (speed > minspeed) then

				local dist = math.Round(EyePos():Distance(v:GetPos()))
				local volume = ((math.Clamp(speed, minspeed, maxspeed)-minspeed)/(maxspeed-minspeed))*100
				local pitch = ((1-((math.Clamp(shapevolume, minshapevolume, maxshapevolume)-minshapevolume)/(maxshapevolume-minshapevolume)))*200)-(dist/500)*50
				--local pitch = ((1-((math.Clamp(shapevolume, minshapevolume, maxshapevolume)-minshapevolume)/(maxshapevolume-minshapevolume)))*2)-(dist/500)

				if (pitch < 10) then
					pitch = 10
				end

				if (v.FlyBySoundPlaying) then
					v.FlyBySound:ChangeVolume(volume, 0)
					v.FlyBySound:ChangePitch(pitch, 0)
					continue
				end

				v.FlyBySoundPlaying = true

				v.FlyBySound:PlayEx(volume, pitch)

			else

				if (!v.FlyBySoundPlaying) then continue end
				v.FlyBySoundPlaying = false
				v.FlyBySound:FadeOut(0.5)

			end

		end
	end)

	hook.Add("EntityRemoved", "FlyBySound_EntityRemoved", function(ent)
		if (ent.FlyBySound) then
			ent.FlyBySound:Stop()
		end
	end)

	--[[hook.Add("HUDPaint", "DebugSpeeds", function()
		for k, v in pairs (ents.GetAll()) do

			if (!table.HasValue(validClasses, v:GetClass())) then continue end

			local speed = averageSpeed(v)
			local dist = math.Round(EyePos():Distance(v:GetPos()))
			
			local Planet =  v:GetNWBool( "flybysounds" ) or false
			
			local ts = v:GetPos():ToScreen()
			draw.SimpleTextOutlined(tostring(Planet).." - "..speed .. " - " .. dist .. " - " .. guessScale(v), "TargetID", ts.x, ts.y, Color(0, 255, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
		end
	end)]]

end

// PinkFoxi.net
