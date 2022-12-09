local util = require("util")
local dns = {}

local cache = util.initializeGlobalTable("dnsCache")

function dns.resolve(url)
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

function dns.getHostname()
	local hostname = os.getComputerLabel()
	if hostname == nil then
		hostname = tostring(os.computerID())
	end
	return hostname
end

function dns.register(protocol, hostname)
	if hostname == nil then
		hostname = dns.getHostname()
	end
	rednet.host(protocol, hostname)
end
