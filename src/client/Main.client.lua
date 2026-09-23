--!strict

local Controllers = script.Parent:WaitForChild("Controllers")

local InteractionController = require(Controllers:WaitForChild("InteractionController"))
local PrototypeUIController = require(Controllers:WaitForChild("PrototypeUIController"))
local CameraProtectionController = require(Controllers:WaitForChild("CameraProtectionController"))
local FeelFeedbackController = require(Controllers:WaitForChild("FeelFeedbackController"))
local BayController = require(Controllers:WaitForChild("BayController"))

PrototypeUIController.Start()
InteractionController.Start(PrototypeUIController)
CameraProtectionController.Start()
FeelFeedbackController.Start()
BayController.Start()

print("[ONE TRIP] M2.3 client loaded")
