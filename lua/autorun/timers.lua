--- Improved timers module. Checks arguments more effectively, and doesn't mess up if one of the timers errors.

if SERVER then AddCSLuaFile() end

local timers = {}

local function xpcall_callback(err)
	return debug.traceback(tostring(err),2)
end

local strict = CreateConVar("igm_stricttimers"..(CLIENT and "_cl" or ""), 0, nil, "Set to 1 to throw errors on illegal timer behavior (timer.Start on nonexistant timer, etc.)")
local function stricterror(...)
	if strict:GetBool() then error(string.format(...),3) end
end

function timer.Create(name, delay, reps, func)
	if not name then
		error("Invalid timer name: "..tostring(name),2)
	end
	if type(delay) ~= "number" or delay < 0 then
		error("Invalid timer delay: "..tostring(delay),2)
	end
	if type(reps) ~= "number" or reps < 0 or math.floor(reps) ~= reps then
		stricterror("Invalid timer reps: %s", tostring(reps))
		reps = math.ceil(reps)
	end
	if type(func) ~= "function" and not (debug.getmetatable(func) and debug.getmetatable(func).__call) then
		error("Invalid timer function: "..tostring(func),2)
	end

	timers[name] = {
		name = name,
		delay = delay,
		reps = reps == 0 and -1 or reps,
		func = func,
		on = false,
		lastExec = 0,
	}
	timer.Start(name)
end

function timer.Start(name)
	local t = timers[name]
	if not t then
		stricterror("Tried to start nonexistant timer: %s", tostring(name))
		return false
	end
	t.on = true
	t.timeDiff = nil
	t.lastExec = CurTime()
	return true
end

function timer.Stop(name)
	local t = timers[name]
	if not t then
		stricterror("Tried to stop nonexistant timer: %s", tostring(name))
		return false
	end
	t.on = false
	t.timeDiff = nil
	return true
end

function timer.Pause(name)
	local t = timers[name]
	if not t then
		stricterror("Tried to pause nonexistant timer: %s", tostring(name))
		return false
	end
	t.on = false
	t.timeDiff = CurTime() - t.lastExec
	return true
end

function timer.UnPause(name)
	local t = timers[name]
	if not t then
		stricterror("Tried to unpause nonexistant timer: %s", tostring(name))
		return false
	end
	if not t.timeDiff then
		stricterror("Tried to unpause nonpaused timer: %s", tostring(name))
		return false
	end

	t.on = true
	t.lastExec = CurTime() - t.timeDiff
	t.timeDiff = nil
	return true
end

function timer.Adjust(name, delay, reps, func)
	local t = timers[name]
	if not t then
		stricterror("Tried to adjust nonexistant timer: %s", tostring(name))
		return false
	end
	if type(delay) ~= "number" or delay < 0 then
		error("Invalid timer delay: "..tostring(delay),2)
	end
	if type(reps) ~= "number" or reps < 0 or math.floor(reps) ~= reps then
		stricterror("Invalid timer reps: %s", tostring(reps))
		reps = math.ceil(reps)
	end

	if func then
		if type(func) ~= "function" and not (debug.getmetatable(func) and debug.getmetatable(func).__call) then
			error("Invalid timer function: "..tostring(func),2)
		end
		t.func = func
	end
	t.delay = delay
	t.reps = reps
	return true
end

function timer.Destroy(name)
	timers[name] = nil
end
timer.Remove = timer.Destroy

function timer.Simple(delay, func)
	if type(delay) ~= "number" or delay < 0 then
		error("Invalid timer delay: "..tostring(delay),2)
	end
	if type(func) ~= "function" and not (debug.getmetatable(func) and debug.getmetatable(func).__call) then
		error("Invalid timer function: "..tostring(func),2)
	end

	local name = {}
	timers[name] = {
		name = name,
		delay = delay,
		reps = 1,
		func = func,
		on = false,
		lastExec = 0,
	}
	timer.Start(name)
end

function timer.Check()
	local t = CurTime()
	for name,tmr in pairs(timers) do
		if tmr.lastExec + tmr.delay <= t then
			tmr.reps = tmr.reps - 1
			local ok, err = xpcall(tmr.func, xpcall_callback)
			if not ok then
				ErrorNoHalt(err)
				timers[name] = nil
			else
				tmr.lastExec = t
				if timers[name] and timers[name].reps == 0 then
					timers[name] = nil
				end
			end
		end
	end
end

hook.Add("Think", "CheckTimers", timer.Check)