--!strict

local Controllers = script.Parent:WaitForChild("Controllers")

local InteractionController = require(Controllers:WaitForChild("InteractionController"))
local PrototypeUIController = require(Controllers:WaitForChild("PrototypeUIController"))
local CameraProtectionController = require(Controllers:WaitForChild("CameraProtectionController"))
local FeelFeedbackController = require(Controllers:WaitForChild("FeelFeedbackController"))

PrototypeUIController.Start()
InteractionController.Start(PrototypeUIController)
CameraProtectionController.Start()
FeelFeedbackController.Start()

print("[ONE TRIP] M1.1 client loaded")
