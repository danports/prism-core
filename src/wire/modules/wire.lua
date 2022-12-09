local wire = {}

function wire.setOutput(id, state)
	if id.invert then
		state = not state
	end
	if id.wire == nil then
		redstone.setOutput(id.side, state)
	else
		local signal = redstone.getBundledOutput(id.side)
		if state then
			signal = colors.combine(signal, id.wire)
		else
			signal = colors.subtract(signal, id.wire)
		end
		redstone.setBundledOutput(id.side, signal)
	end
end

function wire.getInput(id)
	local state
	if id.wire == nil then
		state = redstone.getInput(id.side)
	else
		state = redstone.testBundledInput(id.side, id.wire)
	end
	if id.invert then
		state = not state
	end
	return state
end

function wire.format(id)
	if id.wire == nil then
		return id.side
	else
		return string.format("%s:%i", id.side, id.wire)
	end
end

return wire
