--//ROBLOX SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//CONSTANTS
local PACKAGE_FOLDER = ReplicatedStorage:WaitForChild("packages")
local SHARED_FOLDER = ReplicatedStorage:WaitForChild("src")
local SERVER_SRC = ServerScriptService:WaitForChild("src")

--//DEPENDENCIES
local Maid = require(PACKAGE_FOLDER:WaitForChild("maid"))
local Signal = require(PACKAGE_FOLDER:WaitForChild("signal"))
local Caster = require(SERVER_SRC:WaitForChild("classes"):WaitForChild("Caster"))

--//CLASS
local Match = {}
Match.__index = Match
Match._instances = {}

function Match.new(players, _spellService, _teleportService)
    local self  = setmetatable({}, Match)

    self.SpellService = _spellService
    self.TeleportService = _teleportService
    self.Players = players
    self.Casters = {}
    self.Stats = {
        Time = 0
    }

    self.Events = {
        MatchStarted = Signal.new(),
        MatchEnded = Signal.new(),
        PlayerRemoved = Signal.new(),
        PlayerDamaged = Signal.new()
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
    self.Events.MatchStarted:Fire()
    for i, player : Player in self.Players do
        self:SetupPlayer(player)
    end
    --self:TurnOnPlayersCasts()
end

function Match:SetupPlayer(player : Player)
    self.Casters[player] = Caster.new(player)
    self._maid:GiveTask(self.Casters[player].Events.Damaged:Connect(function(damage)
        self.Events.PlayerDamaged:Fire(player, damage)
     end))
    self:SetupPlayerRemoveEvents(player)
end

function Match:SetupPlayerRemoveEvents(player : Player)
    self.Casters[player]._maid:GiveTask(self.Casters[player].Events.Died:Once(function()
        self:RemovePlayer(player)
    end))

    self._maid:GiveTask(player.AncestryChanged:Once(function()
        self:RemovePlayer(player)
    end))

    self._maid:GiveTask(function()
        if self.Casters[player] then
            self.Casters[player]:Destroy()
        end
    end)
end

function Match:CheckFallingPlayers()
    for i, j : Player in self.Players do
        if j.Character then
            local character = j.Character
            local rootPart = character:WaitForChild("HumanoidRootPart")
            if rootPart then
                local rootPartPosition = rootPart.Position
                if rootPartPosition.Y <= workspace:WaitForChild("MapAnchor").Position.Y - 25 then
                    self:RemovePlayer(j)
                    self.TeleportService:TeleportPlayerListToLobby({j})
                end
            end
        end
    end
end

function Match:Update(dt)
    if self.Ended then return end
    self.Stats.Time += dt
    local playerCount = self:GetRemainingPlayers()
    if playerCount <= 1 then
        if playerCount == 1 then
            local winner = self.Players[1]
            self.Winner = winner
        end
        self.Ended = true
        self:End()
        return 0
    end
    self:CheckFallingPlayers()
    return self.Stats.Time
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
        self.Casters[removedPlayer]:Destroy()
        self.Casters[removedPlayer] = nil
        self.Events.PlayerRemoved:Fire(removedPlayer)
        self.SpellService.Client.TurnOffCasts:Fire(player)
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
