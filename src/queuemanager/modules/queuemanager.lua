-- Handlers:
-- onIsJobRunnable: function that takes a job and returns whether it is runnable. [optional]
-- onFormatJob: function that takes a job and returns a formatted version of it. [optional]
-- onBeginJob: function that takes a job and starts running it.

local serializer = require("serializer")
local util = require("util")
local queuemanager = {}

local currentJob
local handlers = {}

function queuemanager.getCurrentJob()
	return currentJob
end

function queuemanager.getQueue()
	return queue
end

function queuemanager.setHandler(name, handler)
	handlers[name] = handler
end

function queuemanager.isJobRunnable(job)
	return handlers.onIsJobRunnable == nil or handlers.onIsJobRunnable(job)
end

function queuemanager.formatJob(job)
	if handlers.onFormatJob == nil then
		return textutils.serialize(job)
	end
	return handlers.onFormatJob(job)
end

function queuemanager.finishJob()
	print(string.format("Job completed: %s", queuemanager.formatJob(currentJob)))
	currentJob = nil
	fs.delete("currentJob")
	queuemanager.startQueue()
end

function queuemanager.dequeueNextRunnableJob()
	local highestPriority
	local index
	for i, job in ipairs(queue) do
		if queuemanager.isJobRunnable(job) and (index == nil or (job.priority ~= nil and 
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

function queuemanager.currentJobUpdated()
	serializer.writeToFile("currentJob", currentJob)
end

function queuemanager.startQueue()
	if currentJob ~= nil then
		return
	end
	currentJob = queuemanager.dequeueNextRunnableJob()
	if currentJob == nil then
		return
	end
	queuemanager.beginJob(currentJob)
	queuemanager.currentJobUpdated()
end

function queuemanager.onStartup()
	queue = serializer.readFromFile("queue")
	if fs.exists("currentJob") then
		currentJob = serializer.readFromFile("currentJob")
	end
	queuemanager.startQueue()
end

function queuemanager.beginJob(job)
	if handlers.onBeginJob == nil then
		print("ERROR: onBeginJob handler not defined")
		return
	end
	print(string.format("Starting job: %s", queuemanager.formatJob(job)))
	handlers.onBeginJob(job)
end

function queuemanager.queueJob(job)
	queuemanager.insertJob(job)
	queuemanager.startQueue()
end

function queuemanager.cancelJobs(test)
	util.removeWhere(queue, test)
	serializer.writeToFile("queue", queue)
end

function queuemanager.insertJob(job)
	print(string.format("Queueing job: %s", queuemanager.formatJob(job)))
	table.insert(queue, job)
	serializer.writeToFile("queue", queue)
end

return queuemanager
