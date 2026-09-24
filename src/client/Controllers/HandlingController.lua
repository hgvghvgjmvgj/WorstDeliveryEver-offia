--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CarryConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("CarryConfig"))
local HandlingConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("HandlingConfig"))
local ProgressionConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ProgressionConfig"))
local NumberFormat = require(ReplicatedStorage:WaitForChild("NumberFormat"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local Controller = {}
local player = Players.LocalPlayer
local previewRemote: RemoteEvent
local currentNearest: BasePart? = nil
local lastRequested: BasePart? = nil
local scanAccumulator = 0
local previewRefreshAccumulator = 0
local previewFrame: Frame
local previewLabel: TextLabel
local rigFrame: Frame
local rigLabel: TextLabel

local BAND_COLORS = {
	READY = Color3.fromRGB(116, 224, 147),
	RISKY = Color3.fromRGB(242, 210, 92),
	DANGEROUS = Color3.fromRGB(247, 142, 74),
	UNMANAGEABLE = Color3.fromRGB(255, 78, 72),
}

local function rigDisplay(tier: number): string
	return HandlingConfig.RigName(tier)
end

local function roundCorner(instance: GuiObject, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local function nearestItem(): BasePart?
	local world = workspace:FindFirstChild("OneTripPrototype")
	local items = world and world:FindFirstChild("Items")
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not items or not root or not root:IsA("BasePart") then return nil end
	local best: BasePart? = nil
	local distance = CarryConfig.GrabDistance
	for _, candidate in items:GetChildren() do
		if candidate:IsA("BasePart") and candidate:GetAttribute("Available") == true then
			local current = (root.Position - candidate.Position).Magnitude
			if current <= distance then
				distance = current
				best = candidate
			end
		end
	end
	return best
end

local function nextTrackCost(trackName: string): number
	local track = ProgressionConfig.Tracks[trackName]
	local levelIndex = math.max(1, math.floor((tonumber(player:GetAttribute(track.ProfileField)) or 1) + 0.5))
	local nextIndex = levelIndex + 1
	if nextIndex > #track.Levels then return 0 end
	return track.Levels[nextIndex].Cost
end

local function requirementStatus(label: string, trackName: string, current: number, required: number): string
	if current + 1e-6 >= required then
		return label .. " ✓"
	end
	return label .. " " .. NumberFormat.Cash(nextTrackCost(trackName))
end

local function refreshRigCard()
	local tier = tonumber(player:GetAttribute("HandlingRigTier")) or 0
	local strength = tonumber(player:GetAttribute("CarryStrength")) or 15
	local space = tonumber(player:GetAttribute("CarrySpace")) or 13
	local control = tonumber(player:GetAttribute("CarryControl")) or 1
	local nextMilestone = HandlingConfig.NextRigMilestone(tier)
	if not nextMilestone then
		rigLabel.Text = ("CURRENT HANDLING: %s\nMAX CURRENT RIG MILESTONE"):format(rigDisplay(tier))
		return
	end

	local strengthStatus = requirementStatus("STRENGTH", "Strength", strength, nextMilestone.Strength)
	local spaceStatus = requirementStatus("SPACE", "CarrySpace", space, nextMilestone.CarrySpace)
	local controlStatus = requirementStatus("CONTROL", "Control", control, nextMilestone.Control)
	rigLabel.Text = string.format(
		"CURRENT %s   →   NEXT %s\n%s   |   %s   |   %s",
		rigDisplay(tier),
		nextMilestone.Name,
		strengthStatus,
		spaceStatus,
		controlStatus
	)
end

local function refreshSectionSigns()
	local world = workspace:FindFirstChild("OneTripPrototype")
	if not world then return end
	local tier = tonumber(player:GetAttribute("HandlingRigTier")) or 0
	for _, descendant in world:GetDescendants() do
		if descendant:IsA("BasePart") and descendant.Name == "SectionSignAnchor" then
			local identity = descendant.Parent
			local sectionModel = identity and identity.Parent
			local sectionId = sectionModel and sectionModel.Name or ""
			local recommendation = HandlingConfig.SectionRecommendedRig(sectionId)
			local gui = descendant:FindFirstChild("Label")
			local label = gui and gui:FindFirstChild("Text")
			if label and label:IsA("TextLabel") then
				local sectionName = sectionId
				if sectionModel then
					local display = sectionModel:GetAttribute("DisplayName")
					if typeof(display) == "string" and display ~= "" then sectionName = display end
				end
				local status = if tier >= recommendation then "READY" elseif tier + 1 >= recommendation then "CAUTION" else "HEAVY CARGO AHEAD"
				label.Text = string.format(
					"%s\nRECOMMENDED %s   |   YOUR %s\n%s",
					string.upper(sectionName),
					rigDisplay(recommendation),
					rigDisplay(tier),
					status
				)
			end
		end
	end
end

local function requestPreview(force: boolean?)
	local candidate = currentNearest
	if not candidate then
		previewFrame.Visible = false
		lastRequested = nil
		return
	end
	if force or candidate ~= lastRequested then
		lastRequested = candidate
		previewRemote:FireServer(candidate)
	end
end

local function weaknessText(weakness: string, band: string): string
	if band == "READY" then return "READY FOR YOUR CURRENT RIG" end
	if weakness == "STRENGTH" then return if band == "UNMANAGEABLE" then "STRENGTH FAR TOO LOW" else "STRENGTH LOW" end
	if weakness == "CARRY SPACE" then return if band == "UNMANAGEABLE" then "FAR TOO BULKY" else "CARRY SPACE LOW" end
	if weakness == "CONTROL" then return if band == "UNMANAGEABLE" then "FAR TOO HARD TO CONTROL" else "HARD TO CONTROL" end
	return "HANDLING LOW"
end

local function buildUi()
	local gui = Instance.new("ScreenGui")
	gui.Name = "OneTripHandlingUI"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 19
	gui.Parent = player:WaitForChild("PlayerGui")

	rigFrame = Instance.new("Frame")
	rigFrame.Name = "RigSummary"
	rigFrame.AnchorPoint = Vector2.new(0.5, 0)
	rigFrame.Position = UDim2.new(0.5, 0, 0, 16)
	rigFrame.Size = UDim2.fromOffset(470, 70)
	rigFrame.BackgroundColor3 = Color3.fromRGB(27, 31, 37)
	rigFrame.BackgroundTransparency = 0.12
	rigFrame.BorderSizePixel = 0
	rigFrame.Parent = gui
	roundCorner(rigFrame, 9)

	rigLabel = Instance.new("TextLabel")
	rigLabel.Size = UDim2.new(1, -16, 1, -8)
	rigLabel.Position = UDim2.fromOffset(8, 4)
	rigLabel.BackgroundTransparency = 1
	rigLabel.Font = Enum.Font.GothamBold
	rigLabel.TextColor3 = Color3.fromRGB(232, 237, 244)
	rigLabel.TextSize = 14
	rigLabel.TextWrapped = true
	rigLabel.Parent = rigFrame

	previewFrame = Instance.new("Frame")
	previewFrame.Name = "HandlingPreview"
	previewFrame.AnchorPoint = Vector2.new(0.5, 1)
	previewFrame.Position = UDim2.new(0.5, 0, 1, -148)
	previewFrame.Size = UDim2.fromOffset(390, 68)
	previewFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 34)
	previewFrame.BackgroundTransparency = 0.10
	previewFrame.BorderSizePixel = 0
	previewFrame.Visible = false
	previewFrame.Parent = gui
	roundCorner(previewFrame, 9)

	previewLabel = Instance.new("TextLabel")
	previewLabel.Size = UDim2.new(1, -16, 1, -8)
	previewLabel.Position = UDim2.fromOffset(8, 4)
	previewLabel.BackgroundTransparency = 1
	previewLabel.Font = Enum.Font.GothamBold
	previewLabel.TextSize = 15
	previewLabel.TextWrapped = true
	previewLabel.TextColor3 = Color3.new(1,1,1)
	previewLabel.Parent = previewFrame
end

function Controller.Start()
	buildUi()
	local remoteFolder = ReplicatedStorage:WaitForChild(RemoteNames.Folder)
	previewRemote = remoteFolder:WaitForChild(RemoteNames.HandlingPreview) :: RemoteEvent

	previewRemote.OnClientEvent:Connect(function(snapshot)
		if typeof(snapshot) ~= "table" or snapshot.clear == true then
			previewFrame.Visible = false
			return
		end
		if snapshot.instance ~= currentNearest then return end
		local band = tostring(snapshot.band or "READY")
		local rarity = string.upper(tostring(snapshot.rarity or "COMMON"))
		local name = string.upper(tostring(snapshot.name or "ITEM"))
		local value = NumberFormat.Cash(tonumber(snapshot.sellValue) or 0)
		local weakness = weaknessText(tostring(snapshot.weakness or ""), band)
		previewLabel.Text = string.format("%s  %s   SELL %s\n%s  -  %s", rarity, name, value, band, weakness)
		previewLabel.TextColor3 = BAND_COLORS[band] or Color3.new(1,1,1)
		previewFrame.Visible = true
	end)

	local function progressionChanged()
		refreshRigCard()
		refreshSectionSigns()
		lastRequested = nil
		requestPreview(true)
	end
	for _, attribute in {
		"HandlingRigTier", "CarryStrength", "CarrySpace", "CarryControl",
		"StrengthLevel", "CarrySpaceLevel", "ControlLevel",
	} do
		player:GetAttributeChangedSignal(attribute):Connect(progressionChanged)
	end

	refreshRigCard()
	task.defer(refreshSectionSigns)

	RunService.RenderStepped:Connect(function(dt)
		scanAccumulator += dt
		previewRefreshAccumulator += dt
		if scanAccumulator < 0.10 then return end
		scanAccumulator = 0
		currentNearest = nearestItem()
		local forceRefresh = previewRefreshAccumulator >= 0.45
		if forceRefresh then previewRefreshAccumulator = 0 end
		requestPreview(forceRefresh)
	end)
end

return Controller
