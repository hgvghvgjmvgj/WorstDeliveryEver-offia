local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotes = ReplicatedStorage:WaitForChild("GetItInRemotes")
local actionRemote = remotes:WaitForChild("Action")
local stateRemote = remotes:WaitForChild("State")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GetItInPrototypeUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.Parent = playerGui

local title = Instance.new("TextLabel")
title.Size = UDim2.fromOffset(260, 48)
title.Position = UDim2.new(0.5, -130, 0, 14)
title.BackgroundTransparency = 0.16
title.BackgroundColor3 = Color3.fromRGB(28, 29, 36)
title.TextColor3 = Color3.new(1, 1, 1)
title.Text = "GET IT IN!"
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.Parent = screenGui

local roundLabel = Instance.new("TextLabel")
roundLabel.Size = UDim2.fromOffset(230, 34)
roundLabel.Position = UDim2.new(0.5, -115, 0, 66)
roundLabel.BackgroundTransparency = 0.22
roundLabel.BackgroundColor3 = Color3.fromRGB(28, 29, 36)
roundLabel.TextColor3 = Color3.fromRGB(255, 222, 86)
roundLabel.Text = "OBJECT 1/3"
roundLabel.TextScaled = true
roundLabel.Font = Enum.Font.GothamBlack
roundLabel.Parent = screenGui

local objective = Instance.new("TextLabel")
objective.Size = UDim2.new(0.72, 0, 0, 54)
objective.Position = UDim2.new(0.14, 0, 0, 108)
objective.BackgroundTransparency = 0.18
objective.BackgroundColor3 = Color3.fromRGB(28, 29, 36)
objective.TextColor3 = Color3.new(1, 1, 1)
objective.TextWrapped = true
objective.TextScaled = true
objective.Font = Enum.Font.GothamBold
objective.Text = "Get the object through the doorway."
objective.Parent = screenGui

local controls = Instance.new("Frame")
controls.Name = "CarryControls"
controls.Size = UDim2.new(0.94, 0, 0, 72)
controls.Position = UDim2.new(0.03, 0, 1, -92)
controls.BackgroundTransparency = 1
controls.Visible = false
controls.Parent = screenGui

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0.015, 0)
layout.Parent = controls

local function makeButton(name, text, action)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(0.225, 0, 1, 0)
	button.BackgroundColor3 = Color3.fromRGB(52, 109, 235)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Text = text
	button.TextScaled = true
	button.Font = Enum.Font.GothamBlack
	button.AutoButtonColor = true
	button.Parent = controls

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button

	button.Activated:Connect(function()
		actionRemote:FireServer(action)
	end)

	return button
end

makeButton("RotateLeft", "LEFT", "RotateLeft")
makeButton("Tilt", "TILT", "Tilt")
makeButton("RotateRight", "RIGHT", "RotateRight")
local dropButton = makeButton("Drop", "DROP", "Release")
dropButton.BackgroundColor3 = Color3.fromRGB(231, 79, 79)

local desktopHint = Instance.new("TextLabel")
desktopHint.Size = UDim2.fromOffset(500, 30)
desktopHint.Position = UDim2.new(0.5, -250, 1, -126)
desktopHint.BackgroundTransparency = 1
desktopHint.TextColor3 = Color3.fromRGB(235, 235, 235)
desktopHint.TextStrokeTransparency = 0.55
desktopHint.Text = "WALK NORMALLY   |   Q/E rotate   |   R tilt   |   F drop"
desktopHint.TextScaled = true
desktopHint.Font = Enum.Font.GothamBold
desktopHint.Visible = false
desktopHint.Parent = screenGui

local holding = false

local function send(action)
	if holding then
		actionRemote:FireServer(action)
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not holding then
		return
	end

	if input.KeyCode == Enum.KeyCode.Q then
		send("RotateLeft")
	elseif input.KeyCode == Enum.KeyCode.E then
		send("RotateRight")
	elseif input.KeyCode == Enum.KeyCode.R then
		send("Tilt")
	elseif input.KeyCode == Enum.KeyCode.F then
		send("Release")
	end
end)

stateRemote.OnClientEvent:Connect(function(snapshot)
	holding = snapshot.holding == true
	controls.Visible = holding
	desktopHint.Visible = holding and UserInputService.KeyboardEnabled

	local index = snapshot.roundIndex or 1
	local count = snapshot.roundCount or 1
	local objectName = snapshot.objectName or "Object"
	roundLabel.Text = string.format("OBJECT %d/%d — %s", index, count, string.upper(objectName))

	if snapshot.message and snapshot.message ~= "" then
		objective.Text = snapshot.message
	end
end)
