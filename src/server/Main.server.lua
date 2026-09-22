local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService:WaitForChild("Services")
local PrototypeMap = require(Services:WaitForChild("PrototypeMap"))
local GameService = require(Services:WaitForChild("GameService"))

PrototypeMap.Build()
GameService.Start()

print("[ONE TRIP] Milestone 1 prototype started")
