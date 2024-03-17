--//Roblox Services
local RunService = game:GetService("RunService")

local SteppedConnection = {}
SteppedConnection.__index = SteppedConnection
SteppedConnection._objects = {}

local count = 0

function SteppedConnection.new(func, connectionType : string)
    local self = setmetatable({}, SteppedConnection)
    if not connectionType then
        connectionType = "Heartbeat"
    end
    count += 1
    self.Id = "connection_"..count
    self.func = func
    self.connection = RunService[connectionType]:Connect(function(dt)
        if not self.paused then
            self.func(dt)
        end
    end)
    self.paused = false
    self.destroyed = false
    SteppedConnection._objects[self.Id] = self
    return self
end

function SteppedConnection:GetConnectionById(connectionId : string)
    return SteppedConnection._objects[connectionId]
end

function SteppedConnection:Pause()
    self.paused = true
end

function SteppedConnection:Resume()
    self.paused = false
end

function SteppedConnection:Destroy()
    if self.destroyed then
        warn("Attempted to destroy stepped connection that was already destroyed")
        return
    end

    self.connection:Disconnect()
    self.func = nil
    self.connection = nil
    self.paused = nil
    SteppedConnection._objects[self.Id] = nil
    self.Id = nil
    self.destroyed = true
end

-- Destroy alias
function SteppedConnection:Cancel()
    self:Destroy()
end

-- Destroy alias
function SteppedConnection:Disconnect()
    self:Destroy()
end

return SteppedConnection
