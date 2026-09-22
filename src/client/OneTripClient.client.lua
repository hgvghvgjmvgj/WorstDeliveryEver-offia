local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotes = ReplicatedStorage:WaitForChild("OneTripRemotes")
local stateChanged = remotes:WaitForChild("StateChanged")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OneTripPrototypeUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.Parent = playerGui

local title = Instance.new("TextLabel")
title.Size = UDim2.fromOffset(360, 54)
title.Position = UDim2.new(0.5, -180, 0, 18)
title.BackgroundTransparency = 0.18
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.TextColor3 = Color3.new(1, 1, 1)
title.Text = "ONE TRIP!"
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.Parent = screenGui

local info = Instance.new("TextLabel")
info.Size = UDim2.fromOffset(260, 120)
info.Position = UDim2.fromOffset(18, 86)
info.BackgroundTransparency = 0.18
info.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
info.TextColor3 = Color3.new(1, 1, 1)
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.TextSize = 22
info.Font = Enum.Font.GothamBold
info.Text = "Items: 0\nWeight: 0\nPossible payout: $0\nCash: $0"
info.Parent = screenGui

local message = Instance.new("TextLabel")
message.Size = UDim2.new(0.72, 0, 0, 70)
message.Position = UDim2.new(0.14, 0, 0.72, 0)
message.BackgroundTransparency = 0.18
message.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
message.TextColor3 = Color3.new(1, 1, 1)
message.TextWrapped = true
message.TextScaled = true
message.Font = Enum.Font.GothamBold
message.Text = "Take groceries. More items = more cash."
message.Parent = screenGui

local balanceContainer = Instance.new("Frame")
balanceContainer.Size = UDim2.new(0.52, 0, 0, 42)
balanceContainer.Position = UDim2.new(0.24, 0, 0.88, 0)
balanceContainer.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
balanceContainer.BorderSizePixel = 0
balanceContainer.Visible = false
balanceContainer.Parent = screenGui

local balanceFill = Instance.new("Frame")
balanceFill.Size = UDim2.fromScale(0, 1)
balanceFill.BackgroundColor3 = Color3.fromRGB(238, 90, 77)
balanceFill.BorderSizePixel = 0
balanceFill.Parent = balanceContainer

local balanceLabel = Instance.new("TextLabel")
balanceLabel.Size = UDim2.fromScale(1, 1)
balanceLabel.BackgroundTransparency = 1
balanceLabel.TextColor3 = Color3.new(1, 1, 1)
balanceLabel.TextScaled = true
balanceLabel.Font = Enum.Font.GothamBlack
balanceLabel.Text = "BALANCE 0%"
balanceLabel.Parent = balanceContainer

local lastMessage = ""

stateChanged.OnClientEvent:Connect(function(snapshot)
	info.Text = string.format(
		"Items: %d\nWeight: %d\nPossible payout: $%d\nCash: $%d",
		snapshot.count or 0,
		snapshot.weight or 0,
		snapshot.possiblePayout or 0,
		snapshot.cash or 0
	)

	local balance = math.clamp(snapshot.balance or 0, 0, 100)
	balanceFill.Size = UDim2.fromScale(balance / 100, 1)
	balanceLabel.Text = string.format("BALANCE %d%%", balance)
	balanceContainer.Visible = snapshot.phase == "Carrying"

	if snapshot.message and snapshot.message ~= "" then
		lastMessage = snapshot.message
	end

	if snapshot.phase == "Loading" and (not lastMessage or lastMessage == "") then
		lastMessage = "Take groceries. More items = more cash."
	end

	message.Text = lastMessage
end)
