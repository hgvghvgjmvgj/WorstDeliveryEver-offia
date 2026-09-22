--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local Controller = {}

local player = Players.LocalPlayer
local promptLabel: TextLabel
local statusLabel: TextLabel
local noticeLabel: TextLabel
local debugLabel: TextLabel
local burstLabel: TextLabel
local burstScale: UIScale
local debugVisible = false
local latestSnapshot: any = nil
local noticeToken = 0
local burstToken = 0

local DANGER_COLORS = {
	["Stable"] = Color3.fromRGB(235, 239, 245),
	["Slight Wobble"] = Color3.fromRGB(244, 220, 105),
	["Unstable"] = Color3.fromRGB(248, 171, 79),
	["Dangerous"] = Color3.fromRGB(247, 105, 72),
	["Near Collapse"] = Color3.fromRGB(255, 70, 70),
}

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
		"DEV DEBUG [F3]\nPreset: %s\nItems: %d\nWeight: %.1f\nBulk: %.1f\nBase Instability: %.3f\nCurrent Sway: %.3f\nStrain: %.3f (%s)\nLoad Severity: %.3f",
		latestSnapshot.preset or "?",
		latestSnapshot.itemCount or 0,
		latestSnapshot.weight or 0,
		latestSnapshot.bulk or 0,
		latestSnapshot.baseInstability or 0,
		latestSnapshot.currentSway or 0,
		latestSnapshot.strain or 0,
		latestSnapshot.strainStage or "None",
		latestSnapshot.strainLoadSeverity or 0
	)
end

local function showBurst(text: string, color: Color3)
	burstToken += 1
	local token = burstToken

	burstLabel.Text = text
	burstLabel.TextColor3 = color
	burstLabel.TextTransparency = 0
	burstLabel.Visible = true
	burstScale.Scale = 0.72

	TweenService:Create(
		burstScale,
		TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1.08 }
	):Play()

	task.delay(0.22, function()
		if token ~= burstToken then
			return
		end

		TweenService:Create(
			burstScale,
			TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
	end)

	task.delay(0.58, function()
		if token ~= burstToken then
			return
		end

		local fade = TweenService:Create(
			burstLabel,
			TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ TextTransparency = 1 }
		)
		fade:Play()
		fade.Completed:Once(function()
			if token == burstToken then
				burstLabel.Visible = false
			end
		end)
	end)
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

	statusLabel = makeLabel(gui, "Status", UDim2.fromOffset(350, 88), UDim2.fromOffset(18, 18), 18)
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Text = "BAY --\nRUN VALUE 0    SESSION 0\nStable"

	promptLabel = makeLabel(gui, "Prompt", UDim2.fromOffset(310, 54), UDim2.new(0.5, -155, 1, -92), 20)
	promptLabel.Visible = false

	noticeLabel = makeLabel(gui, "Notice", UDim2.fromOffset(440, 52), UDim2.new(0.5, -220, 0, 100), 20)
	noticeLabel.Visible = false

	debugLabel = makeLabel(gui, "Debug", UDim2.fromOffset(310, 196), UDim2.new(1, -328, 0, 18), 15)
	debugLabel.TextXAlignment = Enum.TextXAlignment.Left
	debugLabel.TextYAlignment = Enum.TextYAlignment.Top
	debugLabel.Visible = false

	burstLabel = makeLabel(gui, "Burst", UDim2.fromOffset(520, 110), UDim2.new(0.5, -260, 0.43, -55), 42)
	burstLabel.BackgroundTransparency = 1
	burstLabel.TextStrokeTransparency = 0.25
	burstLabel.Visible = false

	burstScale = Instance.new("UIScale")
	burstScale.Scale = 1
	burstScale.Parent = burstLabel

	local remoteFolder = ReplicatedStorage:WaitForChild(RemoteNames.Folder)
	local carryState = remoteFolder:WaitForChild(RemoteNames.CarryState) :: RemoteEvent
	local notice = remoteFolder:WaitForChild(RemoteNames.PrototypeNotice) :: RemoteEvent
	local feedback = remoteFolder:WaitForChild(RemoteNames.PrototypeFeedback) :: RemoteEvent

	carryState.OnClientEvent:Connect(function(snapshot)
		latestSnapshot = snapshot

		local dangerState = snapshot.dangerState or "Stable"
		local bayIndex = player:GetAttribute("BayIndex")
		local bayText = if typeof(bayIndex) == "number"
			then string.format("BAY %02d", bayIndex)
			else "BAY --"

		statusLabel.Text = string.format(
			"%s\nRUN VALUE %d    SESSION %d\n%s   -   %d items",
			bayText,
			snapshot.runValue or 0,
			snapshot.sessionScore or 0,
			dangerState,
			snapshot.itemCount or 0
		)
		statusLabel.TextColor3 = DANGER_COLORS[dangerState] or Color3.new(1, 1, 1)

		refreshDebug()
	end)

	notice.OnClientEvent:Connect(function(message)
		noticeToken += 1
		local token = noticeToken

		noticeLabel.Text = tostring(message)
		noticeLabel.Visible = true

		task.delay(1.45, function()
			if token == noticeToken then
				noticeLabel.Visible = false
			end
		end)
	end)

	feedback.OnClientEvent:Connect(function(kind: string, data)
		if kind == "Unload" then
			local score = if typeof(data) == "table" then tonumber(data.score) or 0 else 0
			showBurst(
				("MADE IT!  +%d"):format(score),
				Color3.fromRGB(116, 255, 157)
			)
		elseif kind == "Collapse" then
			local dropped = if typeof(data) == "table" then tonumber(data.droppedCount) or 1 else 1
			showBurst(
				("NOOO!  -%d ITEMS"):format(dropped),
				Color3.fromRGB(255, 92, 82)
			)
		elseif kind == "Recovered" then
			local showText = typeof(data) == "table" and data.showText == true
			if showText then
				showBurst("SAVED IT", Color3.fromRGB(122, 224, 255))
			end
		end
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
