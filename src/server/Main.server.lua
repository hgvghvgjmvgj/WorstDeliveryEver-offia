--!strict

local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService:WaitForChild("Services")
local RemoteService = require(Services:WaitForChild("RemoteService"))
local WorldService = require(Services:WaitForChild("WorldService"))

RemoteService.Initialize()
WorldService.Build()

print("[ONE TRIP] M0 foundation loaded")
