local input = {}

function input.request(params)
	while true do
		if params.prompt then
			print(params.prompt)
		end
		local data = read()
		if data == "" then
			return nil
		end
		if params.validator == nil then
			return data
		end
		local parsed, parseError = params.validator(data)
		if parsed ~= nil then
			return parsed
		end
		if parseError then
			print(parseError)
		elseif type(params.invalidPrompt) == "function" then
			params.invalidPrompt(data)
		elseif type(params.invalidPrompt) == "string" then
			print(params.invalidPrompt)
		end
	end
end

function input.menu(params)
	print(params.prompt)
	for id, item in ipairs(params.items) do
		print(string.format("[%i] %s", id, params.formatter(item)))
	end
	return input.request({
		validator = function(data)
			local id = tonumber(data)
			if id == nil then
				return
			end
			return params.items[id]
		end,
		invalidPrompt = "Please enter the number of one of the items above."
	})
end
