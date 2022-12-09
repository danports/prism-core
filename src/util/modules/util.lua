local util = {}

-- The problem is that we call os.loadAPI multiple times, and CC loads and overwrites the API every time.
-- We can either stash API variables in a global table like this or patch CC to load each API once.
function util.initializeGlobalTable(name)
	return util.getTable(_G, name)
end

function util.getCoroutineTable(name)
	return util.getTable(getTable(initializeGlobalTable("coroutineStorage"), coroutine.running()), name)
end

function util.getTable(obj, key)
	local value = obj[key]
	if value == nil then
		value = {}
		obj[key] = value
	end
	return value
end

function util.getNextUnusedIndex(obj)
	local id = 1
	while obj[id] ~= nil do
		id = id + 1
	end
	return id
end

function util.insertRange(obj, items)
	for _, item in pairs(items) do
		table.insert(obj, item)
	end
end

function util.removeWhere(obj, test)
	local position = 1
	while position <= #obj do
		if test(obj[position]) then
			table.remove(obj, position)
		else
			position = position + 1
		end
	end
end

function util.deepClone(obj)
	if type(obj) ~= "table" then
		return obj
	end
	local clone = {}
	for k, v in pairs(obj) do
		clone[k] = util.deepClone(v)
	end
	return clone
end

return util
