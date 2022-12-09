local dns = require("dns")

local autostartup = {}

function autostartup.dependencySatisfied(dependency)
	if dependency.type == "dns" then
		return dns.resolve(dependency.address)
	else
		error(string.format("Unknown dependency type: %s", dependency.type))
	end
end

function autostartup.dependenciesSatisfied(dependencies)
	for _, dependency in pairs(dependencies) do
		if not autostartup.dependencySatisfied(dependency) then
			return false
		end
	end
	return true
end

function autostartup.waitForDependencies(dependencies)
	repeat
		os.sleep(math.random(5) + 5)
	until autostartup.dependenciesSatisfied(dependencies)
end

return autostartup
