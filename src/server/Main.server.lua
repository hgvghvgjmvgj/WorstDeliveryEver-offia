local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService:WaitForChild("Services")
local PrototypeMap = require(Services:WaitForChild("PrototypeMap"))
local ObjectControlService = require(Services:WaitForChild("ObjectControlService"))

PrototypeMap.Build()
ObjectControlService.Start()

print("[GET IT IN] M5 saving + reliability test started")
