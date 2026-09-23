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

local pressureFrame: Frame
local pressureFill: Frame
local pressureStateLabel: TextLabel
local pressureScale: UIScale
local lastPressureState = "LOW"

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

local PRESSURE_COLORS = {
	LOW = Color3.fromRGB(112, 199, 137),
	BUILDING = Color3.fromRGB(225, 190, 84),
	HIGH = Color3.fromRGB(242, 137, 67),
	CRITICAL = Color3.fromRGB(255, 70, 70),
}

local function makeLabel(
	parent: Instance,
	name: string,
	size: UDim2,
	position: UDim2,
	textSize: number
): TextLabel
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

local function pressureDisplayState(internalStage: string?): string
	if internalStage == "Critical" then
		return "CRITICAL"
	elseif internalStage == "High" then
		return "HIGH"
	elseif internalStage == "Moderate" then
		return "BUILDING"
	end
	return "LOW"
end

local function pulseCriticalPressure()
	pressureScale.Scale = 1

	local grow = TweenService:Create(
		pressureScale,
		TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Scale = 1.045 }
	)
	grow:Play()

	grow.Completed:Once(function()
		TweenService:Create(
			pressureScale,
			TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
	end)
end

local function updatePressure(snapshot)
	local itemCount = tonumber(snapshot.itemCount) or 0
	local strain = math.clamp(tonumber(snapshot.strain) or 0, 0, 1)
	local displayState = pressureDisplayState(snapshot.strainStage)

	-- M2.3: residual fatigue remains readable even after the last carried item
	-- is intentionally ditched. Hide only once both load and pressure are gone.
	pressureFrame.Visible = itemCount > 0 or strain > 0.001
	pressureFill.Size = UDim2.new(strain, 0, 1, 0)
	pressureFill.BackgroundColor3 = PRESSURE_COLORS[displayState]
	pressureStateLabel.Text = displayState
	pressureStateLabel.TextColor3 = PRESSURE_COLORS[displayState]

	if displayState == "CRITICAL" and lastPressureState ~= "CRITICAL" then
		pulseCriticalPressure()
	end

	lastPressureState = displayState
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

	statusLabel = makeLabel(
		gui,
		"Status",
		UDim2.fromOffset(350, 88),
		UDim2.fromOffset(18, 18),
		18
	)
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Text = "BAY --\nRUN VALUE 0    SESSION 0\nStable"

	pressureFrame = Instance.new("Frame")
	pressureFrame.Name = "LoadPressure"
	pressureFrame.Size = UDim2.fromOffset(300, 62)
	pressureFrame.Position = UDim2.fromOffset(18, 114)
	pressureFrame.BackgroundColor3 = Color3.fromRGB(24, 27, 32)
	pressureFrame.BackgroundTransparency = 0.14
	pressureFrame.BorderSizePixel = 0
	pressureFrame.Visible = false
	pressureFrame.Parent = gui

	pressureScale = Instance.new("UIScale")
	pressureScale.Scale = 1
	pressureScale.Parent = pressureFrame

	local pressureTitle = Instance.new("TextLabel")
	pressureTitle.Name = "Title"
	pressureTitle.Size = UDim2.fromOffset(180, 26)
	pressureTitle.Position = UDim2.fromOffset(12, 3)
	pressureTitle.BackgroundTransparency = 1
	pressureTitle.Font = Enum.Font.GothamBold
	pressureTitle.Text = "LOAD PRESSURE"
	pressureTitle.TextColor3 = Color3.fromRGB(240, 243, 247)
	pressureTitle.TextSize = 15
	pressureTitle.TextXAlignment = Enum.TextXAlignment.Left
	pressureTitle.Parent = pressureFrame

	pressureStateLabel = Instance.new("TextLabel")
	pressureStateLabel.Name = "State"
	pressureStateLabel.Size = UDim2.fromOffset(100, 26)
	pressureStateLabel.Position = UDim2.new(1, -112, 0, 3)
	pressureStateLabel.BackgroundTransparency = 1
	pressureStateLabel.Font = Enum.Font.GothamBold
	pressureStateLabel.Text = "LOW"
	pressureStateLabel.TextColor3 = PRESSURE_COLORS.LOW
	pressureStateLabel.TextSize = 14
	pressureStateLabel.TextXAlignment = Enum.TextXAlignment.Right
	pressureStateLabel.Parent = pressureFrame

	local pressureTrack = Instance.new("Frame")
	pressureTrack.Name = "Track"
	pressureTrack.Size = UDim2.new(1, -24, 0, 14)
	pressureTrack.Position = UDim2.fromOffset(12, 36)
	pressureTrack.BackgroundColor3 = Color3.fromRGB(54, 58, 66)
	pressureTrack.BorderSizePixel = 0
	pressureTrack.ClipsDescendants = true
	pressureTrack.Parent = pressureFrame

	pressureFill = Instance.new("Frame")
	pressureFill.Name = "Fill"
	pressureFill.Size = UDim2.fromScale(0, 1)
	pressureFill.BackgroundColor3 = PRESSURE_COLORS.LOW
	pressureFill.BorderSizePixel = 0
	pressureFill.Parent = pressureTrack

	promptLabel = makeLabel(
		gui,
		"Prompt",
		UDim2.fromOffset(310, 54),
		UDim2.new(0.5, -155, 1, -92),
		20
	)
	promptLabel.Visible = false

	noticeLabel = makeLabel(
		gui,
		"Notice",
		UDim2.fromOffset(440, 52),
		UDim2.new(0.5, -220, 0, 100),
		20
	)
	noticeLabel.Visible = false

	debugLabel = makeLabel(
		gui,
		"Debug",
		UDim2.fromOffset(310, 196),
		UDim2.new(1, -328, 0, 18),
		15
	)
	debugLabel.TextXAlignment = Enum.TextXAlignment.Left
	debugLabel.TextYAlignment = Enum.TextYAlignment.Top
	debugLabel.Visible = false

	burstLabel = makeLabel(
		gui,
		"Burst",
		UDim2.fromOffset(520, 110),
		UDim2.new(0.5, -260, 0.43, -55),
		42
	)
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

		updatePressure(snapshot)
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
			local score = if typeof(data) == "table"
				then tonumber(data.score) or 0
				else 0

			showBurst(
				("MADE IT!  +%d"):format(score),
				Color3.fromRGB(116, 255, 157)
			)
		elseif kind == "Collapse" then
			local dropped = if typeof(data) == "table"
				then tonumber(data.droppedCount) or 1
				else 1

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
