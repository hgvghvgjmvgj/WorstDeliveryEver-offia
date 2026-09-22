local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService:WaitForChild("Services")
local PrototypeMap = require(Services:WaitForChild("PrototypeMap"))
local ObjectControlService = require(Services:WaitForChild("ObjectControlService"))

PrototypeMap.Build()
ObjectControlService.Start()

print("[GET IT IN] Prototype Zero object-control test started")
