--//Roblox Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage.packages.knit)

--//Constants
local SHARED_FOLDER = ReplicatedStorage.src
local CLASSES_FOLDER = SHARED_FOLDER.classes

--//Modules
local Scheduler = require(CLASSES_FOLDER:WaitForChild('Scheduler'))

local SchedulerService = Knit.CreateService {
	Name = "SchedulerService",
	Client = {
        
	}
}

function SchedulerService:KnitInit()
end

function SchedulerService:KnitStart()
    self.Scheduler = Scheduler.new()
end

function SchedulerService:ConnectToHeartbeat(func, tag : string)
   return self.Scheduler:BindFunction(func, "Heartbeat", tag)
end

function SchedulerService:ConnectToStepped(func, tag : string)
    return self.Scheduler:BindFunction(func, "Stepped", tag)
end

function SchedulerService:PauseTagged(tag : string)
    self.Scheduler:PauseTagged(tag)
end

function SchedulerService:ResumeTagged(tag : string)
    self.Scheduler:ResumeTagged(tag)
end

function SchedulerService:DisconnectTagged(tag : string)
    self.Scheduler:CancelTagged(tag)
end

function SchedulerService:DisconnectById(id : string)
    self.Scheduler:DisconnectById(id)
end

function SchedulerService:DisconnectAll()
   self.Scheduler:DisconnectAll()
end

return SchedulerService
