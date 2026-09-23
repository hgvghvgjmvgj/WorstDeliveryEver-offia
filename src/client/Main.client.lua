--!strict

local Controllers = script.Parent:WaitForChild("Controllers")

local InteractionController = require(Controllers:WaitForChild("InteractionController"))
local PrototypeUIController = require(Controllers:WaitForChild("PrototypeUIController"))
local CameraProtectionController = require(Controllers:WaitForChild("CameraProtectionController"))
local FeelFeedbackController = require(Controllers:WaitForChild("FeelFeedbackController"))
local BayController = require(Controllers:WaitForChild("BayController"))
local EconomyController = require(Controllers:WaitForChild("EconomyController"))
local ProgressionController = require(Controllers:WaitForChild("ProgressionController"))
local HandlingController = require(Controllers:WaitForChild("HandlingController"))
local EconomyTelemetryController = require(Controllers:WaitForChild("EconomyTelemetryController"))

PrototypeUIController.Start()
EconomyController.Start()
ProgressionController.Start()
HandlingController.Start()
EconomyTelemetryController.Start()
InteractionController.Start(PrototypeUIController)
CameraProtectionController.Start()
FeelFeedbackController.Start()
BayController.Start()

print("[ONE TRIP] M5B.1 handling progression client loaded")
