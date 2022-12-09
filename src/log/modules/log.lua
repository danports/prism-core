local net = require("net")
local dns = require("dns")
local log = {}

-- TODO: Refactor with multiple log appenders - console and network
-- TODO: Add dependencies on net, dns

local hasResolvedServer = false
local server

function log.log.sendToServer(level, text)
	if not hasResolvedServer then
		server = dns.resolve("log://")
		hasResolvedServer = true
	end
	if server == nil then
		return
	end
	net.sendMessage(server, "newEvents", {{
		source = {id = os.computerID(), name = os.computerLabel()}, 
		level = level,
		text = text
	}})
end

function log.debug(text)
	if isDebugEnabled then
		print(text)
	end
end

function log.info(text)
	log.sendToServer("info", text)
	print(text)
end

function log.warn(text)
	log.sendToServer("warn", text)
	print("WARN: " .. text)
end

function log.err(text)
	log.sendToServer("error", text)
	print("ERROR: " .. text)
end

function log.fatal(text)
	log.sendToServer("fatal", text)
	print("FATAL: " .. text)
end

function log.panic(text)
	log.fatal(text)
	error(text, 2)
end

return log
