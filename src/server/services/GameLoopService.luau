--//ROBLOX SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--//KNIT IMPORT
local Knit = require(ReplicatedStorage.packages.knit)

--//KNIT PLACEHOLDERS
local SchedulerService, PlayerService, MatchService

--//CONSTANTS
local SERVER_SRC = ServerScriptService.src
local SHARED_SRC = ReplicatedStorage.src
local PACKAGES = ReplicatedStorage.packages
local ENUMS_FOLDER = ReplicatedStorage.src.enums

--//MODULES
local PlayerStates = require(ENUMS_FOLDER:WaitForChild("PlayerStates"))
local GameConfig = require(SHARED_SRC:WaitForChild("metadata"):WaitForChild("GameConfig"))

--//SERVICE
local GameLoopService = Knit.CreateService {
	Name = "GameLoopService",
	Client = {

	}
}

function GameLoopService:KnitInit()
    self.Timer = 0
end

function GameLoopService:KnitStart()
    SchedulerService = Knit.GetService("SchedulerService")
    PlayerService = Knit.GetService("PlayerService")
    MatchService = Knit.GetService("MatchService")

    task.wait(.1) -- to avoid starting before other services
    self:StartGameLoop()
end

function GameLoopService:SetGameState(newState)
    assert(typeof(newState) == "string", "Invalid state")
    local playerState = PlayerStates[newState]
    assert(playerState ~= nil, "Invalid state")
    self.CurrentState = playerState
    self.Timer = 0
    workspace:SetAttribute("GameState", PlayerStates[newState])
    workspace:SetAttribute("MaxTimer", GameConfig.GameStateDuration[newState])
    workspace:SetAttribute("Timer", self.Timer)
    print("Game state changed to", newState)
end

function GameLoopService:GetGameState()
    return self.CurrentState
end

function GameLoopService:StartGameLoop()
    self:SetGameState(PlayerStates.Lobby)
    self.GameConnection = SchedulerService:ConnectToHeartbeat(function(...) 
        self:Update(...)
    end)
end

function GameLoopService:PauseGameLoop()
    self.GameConnection:Pause()
end

function GameLoopService:Update(dt)
    if self.CurrentState == PlayerStates.Lobby then
        if self.Timer >= GameConfig.GameStateDuration.Lobby then
            local playersOnLobby = PlayerService:GetPlayersOnLobby()
            if #playersOnLobby >= GameConfig.Match.MinPlayerQuantity then
                self:SetGameState(PlayerStates.Game)
                local match = MatchService:StartMatch(playersOnLobby)
                match.Events.MatchEnded:Once(function()
                    self:SetGameState(PlayerStates.Lobby)
                end)
            end

            self.Timer = 0
            return

        end

        self.Timer += dt
        workspace:SetAttribute("Timer", self.Timer)
    end
end

function GameLoopService:GetCurrentTimer()
    return self.Timer
end

return GameLoopService
