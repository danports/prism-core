local net = require("net")
local serializer = require("serializer")
local messagebus = {}

local subscriptions

function messagebus.messagebus.getSubscribersFor(msgType)
	local subscribers = subscriptions[msgType]
	if subscribers == nil then
		return {}
	end
	return subscribers
end

function messagebus.publish(msgType, msg)
	for _, subscriber in pairs(messagebus.getSubscribersFor(msgType)) do
		net.sendMessage(subscriber.computerId, msgType, msg)
	end
end

function messagebus.subscribe(target, msgType)
	net.sendMessage(target, "subscribe", {computerId = os.computerID(), 
		messageType = msgType})
end

function messagebus.findSubscription(subscription)
	for _, subscriber in pairs(messagebus.getSubscribersFor(subscription.messageType)) do
		if subscriber.computerId == subscription.computerId then
			return subscriber
		end
	end
	return nil
end

function messagebus.addSubscription(subscription)
	-- TODO: Option to add a subscription and also send an initial update.
	-- Maybe that should be considered a different type of subscription?
	local existing = messagebus.findSubscription(subscription)
	if existing ~= nil then
		return
	end
	print(string.format("Adding %i as subscriber for %s", subscription.computerId,
		subscription.messageType))
	local subscribers = messagebus.getSubscribersFor(subscription.messageType)
	table.insert(subscribers, subscription)
	subscriptions[subscription.messageType] = subscribers
	serializer.writeToFile("subscriptions", subscriptions)
end

function messagebus.onStartup()
	net.registerMessageHandler("subscribe", messagebus.addSubscription)
	subscriptions = serializer.readFromFile("subscriptions")
end

return messagebus
