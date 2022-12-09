local graph = {}

function graph.formatPath(path)
	local result = path.origin
	for k, v in ipairs(path.edges) do
		result = result .. " == " .. tostring(v.weight) .. " ==> " .. v.edge.destination
	end
	return result
end

function graph.getUnvisitedEdgesOf(nodes, pathData, current)
	local result = {}
	for k, edge in pairs(nodes[current].edges) do
		if not pathData[edge.destination].visited then
			table.insert(result, edge)
		end
	end
	return result
end

function graph.getClosestUnvisitedNode(pathData)
	local minDistance = math.huge
	local minNode = nil
	for k, v in pairs(pathData) do
		if v.distance < minDistance and (not v.visited) then
			minNode = k
			minDistance = v.distance
		end
	end
	return minNode
end

function graph.shortestPath(nodes, route, edgeWeight)
	if nodes[route.origin] == nil then
		return nil
	end
	edgeWeight = edgeWeight or function() return 1 end
	
	local pathData = {}
	for k, _ in pairs(nodes) do
		pathData[k] = {
			visited = false,
			distance = math.huge,
		}
	end
	
	pathData[route.origin].visited = true
	pathData[route.origin].distance = 0
	local current = route.origin
	while true do
		local currentDistance = pathData[current].distance
		for k, edge in pairs(getUnvisitedEdgesOf(nodes, pathData, current)) do
			local weight = edgeWeight(edge)
			local newDistance = currentDistance + weight
			if (newDistance < pathData[edge.destination].distance) then
				local thisPathData = pathData[edge.destination]
				thisPathData.distance = newDistance
				thisPathData.weight = weight
				thisPathData.edgeUsed = edge
				thisPathData.previousNode = current
			end
		end
		pathData[current].visited = true
		if (current == route.destination) then
			local path = {
				origin = route.origin,
				destination = route.destination,
				edges = {}
			}
			while current ~= route.origin do
				table.insert(path.edges, 1, {
					edge = pathData[current].edgeUsed,
					weight = pathData[current].weight
				})
				current = pathData[current].previousNode
			end
			return path
		end
		current = getClosestUnvisitedNode(pathData)
		if current == nil then
			return nil -- No path exists.
		end
	end
end

function graph.checkNode(graph, node)
	if graph[node] == nil then
		graph[node] = {edges = {}}
	end
end

function graph.insertNode(graph, node, contents)
	if contents.edges == nil then
		contents.edges = {}
	end
	graph[node] = contents
end

function graph.insertEdge(graph, node, edge)
	checkNode(graph, node)
	checkNode(graph, edge.destination)
	table.insert(graph[node].edges, edge)
end

function graph.deleteEdge(graph, origin, destination)
	if graph[origin] == nil then
		return nil
	end
	for k, edge in pairs(graph[origin].edges) do
		if edge.destination == destination then
			graph[origin].edges[k] = nil
			return edge
		end
	end
	return nil
end

function graph.deleteNode(graph, node)
	local toDelete = graph[node]
	graph[node] = nil
	return toDelete
end

function graph.updateEdge(graph, origin, destination, newDestination)
	if graph[origin] == nil then
		return nil
	end
	for k, edge in pairs(graph[origin].edges) do
		if edge.destination == destination then
			edge.destination = newDestination
			return edge
		end
	end
	return nil
end

return graph
