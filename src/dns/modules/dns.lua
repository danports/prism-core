os.loadAPI("apis/util")

local cache = util.initializeGlobalTable("dnsCache")

function resolve(url)
	local id = tonumber(url)
	if id ~= nil then
		return id
	end
	local entry = cache[url]
	if entry == nil then
		local protocol, hostname = string.match(url, "(.+)://(.*)")
		if hostname == "" then
			hostname = nil
		end
		entry = {rednet.lookup(protocol, hostname)}
		if next(entry) then
			cache[url] = entry
		end
	end
	return unpack(entry)
end

function getHostname()
	local hostname = os.getComputerLabel()
	if hostname == nil then
		hostname = tostring(os.computerID())
	end
	return hostname
end

function register(protocol, hostname)
	if hostname == nil then
		hostname = getHostname()
	end
	rednet.host(protocol, hostname)
end