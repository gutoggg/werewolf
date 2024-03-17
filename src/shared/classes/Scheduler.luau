--//Roblox Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--//Constants
local SHARED_FOLDER = ReplicatedStorage.src
local CLASSES_FOLDER = SHARED_FOLDER.classes

--//Modules
local SteppedConnection = require(CLASSES_FOLDER:WaitForChild('SteppedConnection'))

local Scheduler = {}
Scheduler.__index = Scheduler

function Scheduler.new()
    local self = setmetatable({}, Scheduler)
    self.TaggedConnections = {}
    self.Connections = {}
    return self
end

function Scheduler:DisconnectById(id : string)
    if self.Connections[id] ~= nil then
        self.Connections[id]:Disconnect()
        self.Connections[id] = nil
    end
end

function Scheduler:BindFunction(func : (dt : number, any : any) -> (any), connectionType : string, tag : string)
    local connectionInstance = SteppedConnection.new(func, connectionType)
    if tag then
        self.TaggedConnections[tag][connectionInstance.Id] = connectionInstance
    end
    self.Connections[connectionInstance.Id] = connectionInstance
    return connectionInstance, connectionInstance.Id
end

function Scheduler:PauseTagged(tag : string)
    if self.TaggedConnections[tag] ~= nil then
        for i, connection  in self.TaggedConnections[tag] do
            connection:Pause()
        end
    end
end

function Scheduler:ResumeTagged(tag : string)
    if self.TaggedConnections[tag] ~= nil then
        for i, connection  in self.TaggedConnections[tag] do
            connection:Resume()
        end
    end
end

function Scheduler:DisconnectTagged(tag : string)
    if self.TaggedConnections[tag] ~= nil then
        for i, connection  in self.TaggedConnections[tag] do
            local connectionId = connection.Id
            connection:Cancel()
            self.TaggedConnections[tag][connectionId] = nil
            self.Connections[connectionId] = nil
        end
    end
end

function Scheduler:DisconnectAll()
    for _, connection in self.Scheduler do
        connection:Disconnect()
        self.Connections[connection.Id] = nil
    end
    self.Connections = {}
end

return Scheduler
