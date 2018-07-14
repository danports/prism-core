os.loadAPI("apis/net")
os.loadAPI("apis/serializer")
os.loadAPI("apis/graph")

local myGraph

function getGraph()
	return myGraph
end

function onStartup()
	net.registerMessageHandler("insertNode", insertNode)
	net.registerMessageHandler("insertEdge", insertEdge)
	net.registerMessageHandler("updateEdge", updateEdge)
	net.registerMessageHandler("deleteEdge", deleteEdge)
	net.registerMessageHandler("deleteNode", deleteNode)
	
	myGraph = serializer.readFromFile("graph")
end

function insertNode(request)
	print(string.format("Inserting node: %s", request.node))
	graph.insertNode(myGraph, request.node, request.contents)
	graphChanged()
end

function insertEdge(request)
	print(string.format("Inserting edge: %s => %s", request.node, request.edge.destination))
	graph.insertEdge(myGraph, request.node, request.edge)
	graphChanged()
end

function graphChanged()
	serializer.writeToFile("graph", myGraph)
end

function deleteEdge(request)
	print(string.format("Deleting edge: %s => %s", request.origin, request.destination))
	if graph.deleteEdge(myGraph, request.origin, request.destination) == nil then
		print(string.format("ERROR: Requested edge not found: %s => %s", 
			request.origin, request.destination))
	else
		graphChanged()
	end
end

function deleteNode(request)
	print(string.format("Deleting node %s", request.node))
	if graph.deleteNode(myGraph, request.node) == nil then
		print(string.format("ERROR: Node %s not found", request.node))
	else
		graphChanged()
	end
end

function updateEdge(request)
	print(string.format("Updating edge %s => %s with new destination %s", 
		request.origin, request.destination, request.newDestination))
	if graph.updateEdge(myGraph, request.origin, request.destination, 
		request.newDestination) == nil then
		print(string.format("ERROR: Requested edge not found: %s => %s", 
			request.origin, request.destination))
		return
	else
		graphChanged()
	end
end