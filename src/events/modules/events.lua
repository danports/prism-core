local util = require("util")
local events = {}

local eventHandlers = util.initializeGlobalTable("eventHandlers")

function events.registerHandler(eventType, handler)
	eventHandlers[eventType] = handler
end

function events.registerLocalHandler(eventType, handler)
	util.getCoroutineTable("eventHandlers")[eventType] = handler
end

local timerHandlers = util.initializeGlobalTable("timerHandlers")

function events.handleTimer(evt, timer)
	local handler = timerHandlers[timer]
	if handler == nil then
		return
	end
	timerHandlers[timer] = nil
	return handler(timer)
end

function events.setTimer(timeout, handler)
	local id = os.startTimer(timeout)
	timerHandlers[id] = handler
	return id
end

events.registerHandler("timer", events.handleTimer)
events.registerHandler("terminate", function() return false end)

function events.getEventHandler(eventType)
	local handler = util.getCoroutineTable("eventHandlers")[eventType]
	if handler == nil then
		handler = eventHandlers[eventType]
	end
	return handler
end

function events.dispatchMessage(eventType, ...)
	local handler = events.getEventHandler(eventType)
	if handler == nil then
		return
	end
	if handler(eventType, ...) == false then
		return false
	end
end

function events.runMessageLoop()
	while true do
		if dispatchMessage(os.pullEvent()) == false then
			return
		end
	end
end

function events.runParallelMessageLoop()
	local routines = {}
    local filters = {}
    while true do
		-- TODO: We should use table.pack; see:
		-- https://github.com/dan200/ComputerCraft/commit/bd14223ea86e607bfe5e3cbeb02d33542c0c2ec9
    	local eventData = {os.pullEventRaw()}
		-- Add a new coroutine to handle the current event.
		-- TODO: How is this going to work with coroutine-specific event handlers? Not well...
		table.insert(routines, coroutine.create(dispatchMessage))

		-- Dispatch the event to all active coroutines and clean up the dead ones.
		for n = #routines, 1, -1 do
			local r = routines[n]
			if coroutine.status(r) == "dead" then
				table.remove(routines, n)
				filters[r] = nil
			elseif filters[r] == nil or filters[r] == eventData[1] or eventData[1] == "terminate" then
				-- We assume that the coroutine yielded with an os.pullEvent call.
				local ok, param = coroutine.resume(r, table.unpack(eventData))
				if coroutine.status(r) == "dead" then
					table.remove(routines, n)
					filters[r] = nil
				end
				if ok then
					-- dispatchMessage returns false to indicate that we should quit the message loop.
					if param == false then
						return
					else
						filters[r] = param
					end
				else
					error(param, 0)
				end
			end
    	end
    end
end

return events
