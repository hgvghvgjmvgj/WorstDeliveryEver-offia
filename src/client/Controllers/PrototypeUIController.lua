--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local Controller = {}

local player = Players.LocalPlayer
local promptLabel: TextLabel
local statusLabel: TextLabel
local noticeLabel: TextLabel
local debugLabel: TextLabel
local debugVisible = false
local latestSnapshot: any = nil
local noticeToken = 0

local function makeLabel(parent: Instance, name: string, size: UDim2, position: UDim2, textSize: number): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.BackgroundColor3 = Color3.fromRGB(24, 27, 32)
	label.BackgroundTransparency = 0.18
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = textSize
	label.TextWrapped = true
	label.Parent = parent
	return label
end

local function refreshDebug()
	if not debugVisible or not latestSnapshot then
		debugLabel.Visible = false
		return
	end

	debugLabel.Visible = true
	debugLabel.Text = string.format(
		"DEV DEBUG [F3]\nPreset: %s\nItems: %d\nWeight: %.1f\nBulk: %.1f\nBase Instability: %.3f\nCurrent Sway: %.3f",
		latestSnapshot.preset or "?",
		latestSnapshot.itemCount or 0,
		latestSnapshot.weight or 0,
		latestSnapshot.bulk or 0,
		latestSnapshot.baseInstability or 0,
		latestSnapshot.currentSway or 0
	)
end

function Controller.SetNearbyItem(name: string?)
	if name then
		promptLabel.Text = ("E / GRAB  %s"):format(string.upper(name))
		promptLabel.Visible = true
	else
		promptLabel.Visible = false
	end
end

function Controller.Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "OneTripPrototypeUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.Parent = player:WaitForChild("PlayerGui")

	statusLabel = makeLabel(gui, "Status", UDim2.fromOffset(330, 70), UDim2.fromOffset(18, 18), 18)
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Text = "RUN VALUE 0    SESSION 0\nStable"

	promptLabel = makeLabel(gui, "Prompt", UDim2.fromOffset(300, 54), UDim2.new(0.5, -150, 1, -92), 20)
	promptLabel.Visible = false

	noticeLabel = makeLabel(gui, "Notice", UDim2.fromOffset(420, 52), UDim2.new(0.5, -210, 0, 100), 20)
	noticeLabel.Visible = false

	debugLabel = makeLabel(gui, "Debug", UDim2.fromOffset(310, 150), UDim2.new(1, -328, 0, 18), 15)
	debugLabel.TextXAlignment = Enum.TextXAlignment.Left
	debugLabel.TextYAlignment = Enum.TextYAlignment.Top
	debugLabel.Visible = false

	local remoteFolder = ReplicatedStorage:WaitForChild(RemoteNames.Folder)
	local carryState = remoteFolder:WaitForChild(RemoteNames.CarryState) :: RemoteEvent
	local notice = remoteFolder:WaitForChild(RemoteNames.PrototypeNotice) :: RemoteEvent

	carryState.OnClientEvent:Connect(function(snapshot)
		latestSnapshot = snapshot
		statusLabel.Text = string.format(
			"RUN VALUE %d    SESSION %d\n%s   -   %d items",
			snapshot.runValue or 0,
			snapshot.sessionScore or 0,
			snapshot.dangerState or "Stable",
			snapshot.itemCount or 0
		)
		refreshDebug()
	end)

	notice.OnClientEvent:Connect(function(message)
		noticeToken += 1
		local token = noticeToken
		noticeLabel.Text = tostring(message)
		noticeLabel.Visible = true

		task.delay(1.6, function()
			if token == noticeToken then
				noticeLabel.Visible = false
			end
		end)
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.F3 then
			debugVisible = not debugVisible
			refreshDebug()
		end
	end)
end

return Controller
