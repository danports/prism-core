package.path = package.path .. ";/modules/?;/modules/?.lua;/modules/?/init.lua"

local old_loadapi = os.loadAPI

--- Modified version of os.loadAPI() that tries require() first.
-- @param path Full file path to the wanted API.
-- @see require
-- @see os.loadAPI
local function loadAPIlocal(path)
	local clean_name = fs.getName(path)
	if require(clean_name) then
		rawset("_G", clean_name, require(clean_name))
	else
		old_loadapi(path)
	end
end

_G.os.loadAPI = loadAPIlocal
