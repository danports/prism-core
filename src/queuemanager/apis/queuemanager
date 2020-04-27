-- Handlers:
-- onIsJobRunnable: function that takes a job and returns whether it is runnable. [optional]
-- onFormatJob: function that takes a job and returns a formatted version of it. [optional]
-- onBeginJob: function that takes a job and starts running it.

os.loadAPI("apis/serializer")
os.loadAPI("apis/util")
os.loadAPI("apis/events")

local currentJob
local handlers = {}

function getCurrentJob()
	return currentJob
end

function getQueue()
	return queue
end

function setHandler(name, handler)
	handlers[name] = handler
end

function isJobRunnable(job)
	return handlers.onIsJobRunnable == nil or handlers.onIsJobRunnable(job)
end

function formatJob(job)
	if handlers.onFormatJob == nil then
		return textutils.serialize(job)
	end
	return handlers.onFormatJob(job)
end

function finishJob()
	print(string.format("Job completed: %s", formatJob(currentJob)))
	currentJob = nil
	fs.delete("currentJob")
	startQueue()
end

function dequeueNextRunnableJob()
	local highestPriority
	local index
	for i, job in ipairs(queue) do
		if isJobRunnable(job) and (index == nil or (job.priority ~= nil and 
			(highestPriority == nil or job.priority > highestPriority))) then
			highestPriority = job.priority
			index = i
		end
	end
	
	if index == nil then
		return nil
	end
	local job = table.remove(queue, index)
	serializer.writeToFile("queue", queue)
	return job
end

function currentJobUpdated()
	serializer.writeToFile("currentJob", currentJob)
end

function startQueue()
	if currentJob ~= nil then
		return
	end
	currentJob = dequeueNextRunnableJob()
	if currentJob == nil then
		return
	end
	beginJob(currentJob)
	currentJobUpdated()
end

function onStartup()
	queue = serializer.readFromFile("queue")
	if fs.exists("currentJob") then
		currentJob = serializer.readFromFile("currentJob")
	end
	startQueue()
end

function beginJob(job)
	if handlers.onBeginJob == nil then
		print("ERROR: onBeginJob handler not defined")
		return
	end
	print(string.format("Starting job: %s", formatJob(job)))
	handlers.onBeginJob(job)
end

function queueJob(job)
	insertJob(job)
	startQueue()
end

function cancelJobs(test)
	util.removeWhere(queue, test)
	serializer.writeToFile("queue", queue)
end

function insertJob(job)
	print(string.format("Queueing job: %s", formatJob(job)))
	table.insert(queue, job)
	serializer.writeToFile("queue", queue)
end