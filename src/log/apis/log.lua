os.loadAPI("apis/net")
os.loadAPI("apis/dns")

-- TODO: Refactor with multiple log appenders - console and network
-- TODO: Add dependencies on net, dns

local hasResolvedServer = false
local server

function sendToServer(level, text)
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

function debug(text)
	if isDebugEnabled then
		print(text)
	end
end

function info(text)
	sendToServer("info", text)
	print(text)
end

function warn(text)
	sendToServer("warn", text)
	print("WARN: " .. text)
end

function err(text)
	sendToServer("error", text)
	print("ERROR: " .. text)
end

function fatal(text)
	sendToServer("fatal", text)
	print("FATAL: " .. text)
end

function panic(text)
	fatal(text)
	error(text, 2)
end