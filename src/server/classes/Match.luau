--//ROBLOX SERVICES
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//CONSTANTS
local PACKAGE_FOLDER = ReplicatedStorage:WaitForChild("packages")
local SHARED_FOLDER = ReplicatedStorage:WaitForChild("src")
local METADATA_FOLDER = SHARED_FOLDER:WaitForChild("metadata")
local SERVER_SRC = ServerScriptService:WaitForChild("src")

--//DEPENDENCIES
local Maid = require(PACKAGE_FOLDER:WaitForChild("maid"))
local Signal = require(PACKAGE_FOLDER:WaitForChild("signal"))
local GameConfig = require(METADATA_FOLDER:WaitForChild("GameConfig"))

--//CLASS
local Match = {}
Match.__index = Match
Match._instances = {}

function Match.new(players)
    local self  = setmetatable({}, Match)

    self.Players = players
    self.Stats = {
        Time = 0
    }

    self.Events = {
        MatchStarted = Signal.new(),
        MatchEnded = Signal.new(),
        PlayerRemoved = Signal.new(),
        RoundEnded = Signal.new()
    }

    self._maid = Maid.new()

    self._maid:GiveTask(function()
        Match._instances[self] = nil
        for i, j in self.Events do
            j:Destroy()
        end
        self.Players = nil
        self.Stats = nil
        self.Events = nil
        self._maid = nil
    end)

    self.Ended = false

    return self
end

function Match:Start()
    self:DistributeRoles(#self.Players)
    self:SetupMatchEvents()
    self.Events.MatchStarted:Fire()
    self:StartGameLoop()
    self:End()
end

function Match:DistributeRoles()
	local roleDistribution = self:SortRolesByPlayerQuantity()

    local roleList = {}
    for role, count in roleDistribution do
        for i = 1, count do
            table.insert(roleList, role)
        end
    end

    for i = #roleList, 2, -1 do
        local j = math.random(i)
        roleList[i], roleList[j] = roleList[j], roleList[i]
    end

    for i, player in self.Players do
        player:SetAttribute("Role", roleList[i])
    end
end

function Match:SetupMatchEvents()
    local playerRemoveConnection = Players.PlayerRemoving:Once(function(player)
        self:RemovePlayer(player)
    end)

    self.Events.MatchEnded:Once(function(winner)
        playerRemoveConnection:Disconnect()
    end)
end

function Match:StartGameLoop()
    --GetCurrentRoundType, if doesnt exist create it
    --Check win conditions for villagers and werewolfs
    --Exevute round routine
    --Sent round results
    --Toggle round type
    --Repeat
end

function Match:SortRolesByPlayerQuantity()
	local playerQuantity = #self.Players
	local roles = {}

    local minRolesSum = 0
    local nonWerewolfCount = 0
    for i, role in GameConfig.Match.AllowedRoles do
        roles[i] = role.Min
        minRolesSum += role.Min
        if i ~= "Werewolf" then
            nonWerewolfCount += 1
        end
    end
    
	local remainingPlayers = playerQuantity - minRolesSum

	while remainingPlayers > 0 do
        if nonWerewolfCount > roles.Werewolf + 1 and roles.Werewolf < GameConfig.Match.AllowedRoles.Werewolf.Max then
            roles.Werewolf += 1
            remainingPlayers -= 1
            continue
        end
        
        for i, role in GameConfig.Match.AllowedRoles do
            if i ~= "Werewolf" and roles[i] < role.Max then
                roles[i] += 1
                nonWerewolfCount += 1
                remainingPlayers -= 1
            end
        end
    end

	return roles
end

function Match:End()
    self.Events.MatchEnded:Fire(self.Winner)
    self:Destroy()
end

function Match:RemovePlayer(player : Player)
    assert(player, "Player must be passed to be removed from match player list.")
    local playerIndexPosition = self:GetPlayerIndexInMatchPlayerList(player)
    if playerIndexPosition then
        local removedPlayer = table.remove(self.Players, playerIndexPosition)
        self.Events.PlayerRemoved:Fire(removedPlayer)
    else
        error("This player is not in the match list!")
    end
end

function Match:IsPlayerOnMatch(player : Player) : boolean
    return self:GetPlayerIndexInMatchPlayerList(player) and true or false
end

function Match:GetPlayerIndexInMatchPlayerList(player : Player) : number | nil
    return table.find(self.Players, player)
end

function Match:GetRemainingPlayers()
    return #self.Players
end

function Match:Destroy()
    self._maid:Destroy()
end

return Match