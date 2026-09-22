local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService:WaitForChild("Services")
local PrototypeMap = require(Services:WaitForChild("PrototypeMap"))
local CarryService = require(Services:WaitForChild("CarryService"))

PrototypeMap.Build()
CarryService.Start()

print("[GET IT IN] Prototype Zero started")
