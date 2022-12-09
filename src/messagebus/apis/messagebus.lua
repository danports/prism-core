os.loadAPI("apis/net")
os.loadAPI("apis/serializer")

local subscriptions

function getSubscribersFor(msgType)
	local subscribers = subscriptions[msgType]	
	if subscribers == nil then
		return {}
	end
	return subscribers
end

function publish(msgType, msg)
	for _, subscriber in pairs(getSubscribersFor(msgType)) do
		net.sendMessage(subscriber.computerId, msgType, msg)
	end
end

function subscribe(target, msgType)
	net.sendMessage(target, "subscribe", {computerId = os.computerID(), 
		messageType = msgType})
end

function findSubscription(subscription)
	for _, subscriber in pairs(getSubscribersFor(subscription.messageType)) do
		if subscriber.computerId == subscription.computerId then
			return subscriber
		end
	end
	return nil
end

function addSubscription(subscription)
	-- TODO: Option to add a subscription and also send an initial update.
	-- Maybe that should be considered a different type of subscription?
	local existing = findSubscription(subscription)
	if existing ~= nil then
		return
	end
	print(string.format("Adding %i as subscriber for %s", subscription.computerId,
		subscription.messageType))
	local subscribers = getSubscribersFor(subscription.messageType)
	table.insert(subscribers, subscription)
	subscriptions[subscription.messageType] = subscribers
	serializer.writeToFile("subscriptions", subscriptions)
end

function onStartup()
	net.registerMessageHandler("subscribe", addSubscription)
	subscriptions = serializer.readFromFile("subscriptions")
end