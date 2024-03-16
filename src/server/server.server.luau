--//Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

--//Knit Import
local Knit = require(ReplicatedStorage.packages.knit)

Players.CharacterAutoLoads = false

--//Constants
local SERVER_SRC_FOLDER = ServerScriptService:WaitForChild("src")
local SERVICES_FOLDER = SERVER_SRC_FOLDER:WaitForChild("services")

--//Knit Setup
Knit.AddServices(SERVICES_FOLDER)

Knit.Start():andThen(function()
    warn("Server started")
end):catch(warn)
