local events = require("events")
local util = require("util")
local dns = require("dns")
local net = {}

-- Modems
function net.detectModem()
	local sides = peripheral.getNames()
	for _, side in ipairs(sides) do
		if peripheral.getType(side) == "modem" and peripheral.call(side, "isWireless") then
			return side
		end
	end
	return nil
end

function net.openModem(side)
	if side == nil then
		side = net.detectModem()
		if side == nil then
			error("Unable to automatically detect modem -- did you attach one?")
		end
	end
	rednet.open(side)
	return side
end

-- Message delivery
function net.sendRawMessage(destination, msg)
	local address = dns.resolve(destination)
	if address == nil then
		return false, string.format("Unable to resolve %s", tostring(destination))
	end
	return rednet.send(address, msg)
end

function net.createMessage(msgType, data)
	return {msgType, data}
end

function net.sendMessage(destination, msgType, data)
	return net.sendRawMessage(destination, net.createMessage(msgType, data))
end

function net.sendMessages(destination, messages)
	return net.sendRawMessage(destination, messages)
end

function net.broadcastMessage(destination, msgType, data)
	local recipients = {dns.resolve(destination)}
	for _, recipient in ipairs(recipients) do
		net.sendMessage(recipient, msgType, data)
	end
end

-- Message handlers
local rednetHandlers = util.initializeGlobalTable("rednetHandlers")

function net.pullMessage(msgType)
	-- TODO: Better to implement this with protocols, which weren't supported when this library was first written.
	while true do
		local senderId, msg = rednet.receive()
		if msg[1] == msgType then
			return msg[2]
		end
	end
end

function net.registerRawMessageHandler(msgType, handler)
	rednetHandlers[msgType] = handler
end

function net.registerRawLocalMessageHandler(msgType, handler)
	util.getCoroutineTable("rednetHandlers")[msgType] = handler
end

function net.registerMessageHandler(msgType, handler)
	net.registerRawMessageHandler(msgType, function(data) return handler(data[2]) end)
end

function net.registerLocalMessageHandler(msgType, handler)
	net.registerRawLocalMessageHandler(msgType, function(data) return handler(data[2]) end)
end

function net.removeHandler(msgType)
	rednetHandlers[msgType] = nil
end

function net.removeLocalHandler(msgType)
	util.getCoroutineTable("rednetHandlers")[msgType] = nil
end

function net.getRednetHandler(msgType)
	local handler = util.getCoroutineTable("rednetHandlers")[msgType]
	if handler == nil then
		handler = rednetHandlers[msgType]
	end
	return handler
end

function net.dispatchMessage(msg, sender, distance)
	local handler = net.getRednetHandler(msg[1])
	if handler ~= nil then
		return handler(msg, sender, distance)
	end
end

function net.handleRednetMessage(msgType, sender, msg, distance)
	if msg == nil then
		return
	end
	if type(msg[1]) == "table" then
		for _, subMessage in ipairs(msg) do
			if net.dispatchMessage(subMessage, sender, distance) == false then
				return false
			end
		end
	else
		return net.dispatchMessage(msg, sender, distance)
	end
end

events.registerHandler("rednet_message", net.handleRednetMessage)

net.registerRawMessageHandler("ping", function(data, sender)
	print(string.format("Ping received; sending reply to %i", sender))
	net.sendMessage(sender, "pingReply", {position = {gps.locate(5)}})
end)

return net
