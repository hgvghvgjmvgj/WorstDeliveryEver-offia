--!strict

local Controllers = script:WaitForChild("Controllers")

local InteractionController = require(Controllers:WaitForChild("InteractionController"))
local PrototypeUIController = require(Controllers:WaitForChild("PrototypeUIController"))
local CameraProtectionController = require(Controllers:WaitForChild("CameraProtectionController"))

PrototypeUIController.Start()
InteractionController.Start(PrototypeUIController)
CameraProtectionController.Start()

print("[ONE TRIP] M1 client loaded")
