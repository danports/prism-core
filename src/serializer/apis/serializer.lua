local serializer = {}

function serializer.readFile(path)
	local file = fs.open(path, "r")
	if file == nil then
		return nil
	end
	local contents = file.readAll()
	file.close()
	return contents
end

function serializer.readFromFile(path)
	local file = serializer.readFile(path)
	if file == nil then
		return {}
	end
	return textutils.unserialize(file)
end

function serializer.writeFile(path, contents)
	local file = fs.open(path, "w")
	if file == nil then
		error(string.format("Failed to open %s for writing; is the file marked read-only?", path))
	end
	file.writeLine(contents)
	file.close()
end

function serializer.writeToFile(path, contents)
	serializer.writeFile(path, textutils.serialize(contents))
end

return serializer
