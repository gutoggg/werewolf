--//Roblox Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage.packages.knit)

--//Constants
local SHARED_FOLDER = ReplicatedStorage.src
local CLASSES_FOLDER = SHARED_FOLDER.classes

--//Modules
local Scheduler = require(CLASSES_FOLDER:WaitForChild('Scheduler'))

local SchedulerController = Knit.CreateController {
	Name = "SchedulerController",
	Client = {
	}
}

function SchedulerController:KnitInit()
end

function SchedulerController:KnitStart()
    self.Scheduler = Scheduler.new()
end

function SchedulerController:ConnectToHeartbeat(func, tag : string)
    return self.Scheduler:BindFunction(func, "Heartbeat", tag)
end

function SchedulerController:ConnectToStepped(func, tag : string)
    return self.Scheduler:BindFunction(func, "RenderStepped", tag)
end
 
function SchedulerController:PauseTagged(tag : string)
    self.Scheduler:PauseTagged(tag)
end

function SchedulerController:ResumeTagged(tag : string)
    self.Scheduler:ResumeTagged(tag)
end

function SchedulerController:DisconnectTagged(tag : string)
    self.Scheduler:CancelTagged(tag)
end

function SchedulerController:DisconnectById(id : string)
    self.Scheduler:DisconnectById(id)
end

function SchedulerController:DisconnectAll()
   self.Scheduler:DisconnectAll()
end

return SchedulerController
