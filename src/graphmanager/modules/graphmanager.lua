local net = require("net")
local serializer = require("serializer")
local graph = require("graph")
local graphmanager = {}

local myGraph

function graphmanager.getGraph()
	return myGraph
end

function graphmanager.onStartup()
	net.registerMessageHandler("insertNode", graphmanager.insertNode)
	net.registerMessageHandler("insertEdge", graphmanager.insertEdge)
	net.registerMessageHandler("updateEdge", graphmanager.updateEdge)
	net.registerMessageHandler("deleteEdge", graphmanager.deleteEdge)
	net.registerMessageHandler("deleteNode", graphmanager.deleteNode)

	myGraph = serializer.readFromFile("graph")
end

function graphmanager.insertNode(request)
	print(string.format("Inserting node: %s", request.node))
	graph.insertNode(myGraph, request.node, request.contents)
	graphmanager.graphChanged()
end

function graphmanager.insertEdge(request)
	print(string.format("Inserting edge: %s => %s", request.node, request.edge.destination))
	graph.insertEdge(myGraph, request.node, request.edge)
	graphmanager.graphChanged()
end

function graphmanager.graphChanged()
	serializer.writeToFile("graph", myGraph)
end

function graphmanager.deleteEdge(request)
	print(string.format("Deleting edge: %s => %s", request.origin, request.destination))
	if graph.deleteEdge(myGraph, request.origin, request.destination) == nil then
		print(string.format("ERROR: Requested edge not found: %s => %s",
			request.origin, request.destination))
	else
		graphmanager.graphChanged()
	end
end

function graphmanager.deleteNode(request)
	print(string.format("Deleting node %s", request.node))
	if graph.deleteNode(myGraph, request.node) == nil then
		print(string.format("ERROR: Node %s not found", request.node))
	else
		graphmanager.graphChanged()
	end
end

function graphmanager.updateEdge(request)
	print(string.format("Updating edge %s => %s with new destination %s",
		request.origin, request.destination, request.newDestination))
	if graph.updateEdge(myGraph, request.origin, request.destination,
		request.newDestination) == nil then
		print(string.format("ERROR: Requested edge not found: %s => %s",
			request.origin, request.destination))
		return
	else
		graphmanager.graphChanged()
	end
end

return graphmanager
