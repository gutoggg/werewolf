--//Roblox Services
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--//Knit Import
local Knit = require(ReplicatedStorage.packages.knit)

--//Knit Placeholders

--//Constants
local ENUMS_FOLDER = ReplicatedStorage.src.enums

--//Dependencies
local PlayerStates = require(ENUMS_FOLDER:WaitForChild("PlayerStates"))

--//Service Creation
local PlayerService = Knit.CreateService {
	Name = "PlayerService",
	Client = {
	}
}

function PlayerService:KnitInit()
    for i, player in Players:GetPlayers() do
        self:OnPlayerAdded(player)
    end

    Players.PlayerAdded:Connect(function(player)
        self:OnPlayerAdded(player)
    end)
end

function PlayerService:KnitStart()
end

function PlayerService:PlayerIsInState(player : Player, state)
    return self:GetPlayerState(player) == state
end

function PlayerService:OnPlayerAdded(player : Player)
    player:SetAttribute("State", PlayerStates.Lobby)
end

function PlayerService:SetPlayerListState(playerList : {Player}, state)
    assert(PlayerStates[state], `State {state} not found in PlayerStates`)
    for i, player in playerList do
        self:SetPlayerState(player, state)
    end
end

function PlayerService:SetPlayerState(player : Player, state)
    assert(PlayerStates[state], `State {state} not found in PlayerStates`)
    player:SetAttribute("State", state)
end

function PlayerService:GetPlayerState(player : Player)
    return player:GetAttribute("State")
end

function PlayerService:GetPlayersOnLobby()
    local players = Players:GetPlayers()
    local playersOnLobby = {}
    for i, player in players do
        if self:GetPlayerState(player) == PlayerStates.Lobby then
            table.insert(playersOnLobby, player)
        end
    end
    return playersOnLobby
end

return PlayerService
