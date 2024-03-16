--//Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(game:GetService("ReplicatedStorage").packages.knit)

--//Constants
local LOCAL_PLAYER : Player = game:GetService("Players").LocalPlayer
local PLAYER_SCRIPTS : PlayerScripts = LOCAL_PLAYER:WaitForChild("PlayerScripts")
local CONTROLLER_FOLDER : Folder = PLAYER_SCRIPTS:WaitForChild("controllers")

--//Knit Setup
Knit.AddControllers(CONTROLLER_FOLDER)

Knit.Start():andThen(function()
    warn("Client started")
end):catch(warn)
