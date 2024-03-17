--//Roblox Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--//Knit Import
local Knit = require(ReplicatedStorage.packages.knit)

--//Knit Placeholders
local TeleportService, MapService, SpellService, PlayerService

--//Constants
local SERVER_SRC = ServerScriptService.src

--//Modules
--local Match = require(SERVER_SRC.classes.Match)

--//Service Creation
local MatchService = Knit.CreateService {
	Name = "MatchService",
	Client = {
        OnMatchStarted = Knit.CreateSignal(),
        OnMatchEnded = Knit.CreateSignal(),
        OnPlayerRemovedFromMatch = Knit.CreateSignal()
	}
}

function MatchService:KnitInit()
    self.CurrentMatch = nil
end

function MatchService:KnitStart()

end

function MatchService:StartMatch(players)
    --self.CurrentMatch = Match.new(players)
    self.CurrentMatch:Start()
    print("Match Started!")
    MatchService:SetupMatchEvents()
    self.Client.OnMatchStarted:FireFor(players)
    return self.CurrentMatch
end

function MatchService:SetupMatchEvents()
    local playerRemoveConnection = self.CurrentMatch.Events.PlayerRemoved:Connect(function(player)
        self.Client.OnPlayerRemovedFromMatch:FireFor({player})
    end)
    self.CurrentMatch.Events.MatchEnded:Once(function(winner)
        print("Winner is", winner.Name, "!")
        self:EndMatch()
        playerRemoveConnection:Disconnect()
    end)
end

function MatchService:EndMatch()
    local match = self.CurrentMatch
    self.CurrentMatch = nil
    self.Client.OnMatchEnded:FireFor(match.Players)
end

function MatchService:GetCurrentMatch()
    return self.CurrentMatch
end

return MatchService
