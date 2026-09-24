--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local Controller = {}
local player = Players.LocalPlayer
local frame: Frame
local titleLabel: TextLabel
local bodyLabel: TextLabel
local objectiveBillboard: BillboardGui?
local objectiveHighlight: Highlight?
local beam: Beam?
local rootAttachment: Attachment?
local targetAttachment: Attachment?
local targetPart: BasePart? = nil
local step = "WAIT"
local stepStartedAt = 0
local latestCarry: any = nil
local latestEconomy: any = nil
local reviewSeen = false
local running = false
local loopAccumulator = 0
local tutorialAction: RemoteEvent

local function roundCorner(gui: GuiObject, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = gui
end

local function makeText(parent: Instance, value: string, size: UDim2, textSize: number): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = size
	label.Font = Enum.Font.GothamBold
	label.Text = value
	label.TextSize = textSize
	label.TextWrapped = true
	label.TextColor3 = Color3.fromRGB(245,247,250)
	label.Parent = parent
	return label
end

local function clearTarget()
	if objectiveBillboard then
		objectiveBillboard:Destroy()
		objectiveBillboard = nil
	end
	if objectiveHighlight then
		objectiveHighlight:Destroy()
		objectiveHighlight = nil
	end
	if beam then
		beam:Destroy()
		beam = nil
	end
	if rootAttachment then
		rootAttachment:Destroy()
		rootAttachment = nil
	end
	if targetAttachment then
		targetAttachment:Destroy()
		targetAttachment = nil
	end
	targetPart = nil
end

local function setTarget(part: BasePart?)
	if part == targetPart then return end
	clearTarget()
	if not part then return end
	targetPart = part

	local marker = Instance.new("BillboardGui")
	marker.Name = "TutorialObjectiveMarker"
	marker.Adornee = part
	marker.Size = UDim2.fromOffset(150,52)
	marker.StudsOffset = Vector3.new(0,4.5,0)
	marker.AlwaysOnTop = true
	marker.MaxDistance = 500
	marker.Parent = part
	local label = makeText(marker,"▼ OBJECTIVE",UDim2.fromScale(1,1),16)
	label.TextColor3 = Color3.fromRGB(255,226,91)
	label.TextStrokeTransparency = 0.25
	objectiveBillboard = marker

	if part.Transparency < 0.95 then
		local highlight = Instance.new("Highlight")
		highlight.Name = "TutorialObjectiveHighlight"
		highlight.Adornee = part
		highlight.FillColor = Color3.fromRGB(255,226,91)
		highlight.OutlineColor = Color3.new(1,1,1)
		highlight.FillTransparency = 0.78
		highlight.OutlineTransparency = 0.10
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = workspace
		objectiveHighlight = highlight
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		rootAttachment = Instance.new("Attachment")
		rootAttachment.Name = "TutorialBeamOrigin"
		rootAttachment.Parent = root
		targetAttachment = Instance.new("Attachment")
		targetAttachment.Name = "TutorialBeamTarget"
		targetAttachment.Parent = part
		beam = Instance.new("Beam")
		beam.Name = "TutorialGuideBeam"
		beam.Attachment0 = rootAttachment
		beam.Attachment1 = targetAttachment
		beam.FaceCamera = true
		beam.Width0 = 0.10
		beam.Width1 = 0.28
		beam.Color = ColorSequence.new(Color3.fromRGB(255,226,91))
		beam.Transparency = NumberSequence.new(0.35)
		beam.Parent = rootAttachment
	end
end

local function message(title: string, body: string?)
	titleLabel.Text = title
	bodyLabel.Text = body or ""
	frame.Visible = true
end

local function world(): Folder?
	local instance = workspace:FindFirstChild("OneTripPrototype")
	return if instance and instance:IsA("Folder") then instance else nil
end

local function ownBay(): Model?
	local root = world()
	local bays = root and root:FindFirstChild("Bays")
	if not bays then return nil end
	for _, bay in bays:GetChildren() do
		if bay:IsA("Model") and tonumber(bay:GetAttribute("OwnerUserId")) == player.UserId then
			return bay
		end
	end
	return nil
end

local function receivingSection(): Model?
	local root = world()
	local gameplay = root and root:FindFirstChild("WarehouseGameplay")
	local sections = gameplay and gameplay:FindFirstChild("Sections")
	local receiving = sections and sections:FindFirstChild("Receiving")
	return if receiving and receiving:IsA("Model") then receiving else nil
end

local function receivingAnchor(): BasePart?
	local section = receivingSection()
	local identity = section and section:FindFirstChild("SectionIdentity")
	local anchor = identity and identity:FindFirstChild("SectionSignAnchor")
	return if anchor and anchor:IsA("BasePart") then anchor else nil
end

local function firstGateAnchor(): BasePart?
	local root = world()
	local gameplay = root and root:FindFirstChild("WarehouseGameplay")
	local gates = gameplay and gameplay:FindFirstChild("ClearanceCheckpoints")
	if not gates then return nil end
	for _, gate in gates:GetChildren() do
		if gate:IsA("Model") and tonumber(gate:GetAttribute("RequiredRig")) == 1 then
			local anchor = gate:FindFirstChild("ClearanceLabelAnchor")
			if anchor and anchor:IsA("BasePart") then return anchor end
		end
	end
	return nil
end

local function rootPart(): BasePart?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

local function isInReceiving(): boolean
	local section = receivingSection()
	local root = rootPart()
	if not section or not root then return false end
	local front = tonumber(section:GetAttribute("FrontZ"))
	local back = tonumber(section:GetAttribute("BackZ"))
	if not front or not back then return false end
	return root.Position.Z <= front + 6 and root.Position.Z >= back - 6 and math.abs(root.Position.X) <= 90
end

local function nearestReceivingItem(): BasePart?
	local root = world()
	local items = root and root:FindFirstChild("Items")
	local playerRoot = rootPart()
	if not items or not playerRoot then return nil end
	local best: BasePart? = nil
	local bestDistance = math.huge
	for _, item in items:GetChildren() do
		if item:IsA("BasePart") and item:GetAttribute("Available") == true and item:GetAttribute("SectorName") == "Receiving" then
			local distance = (playerRoot.Position - item.Position).Magnitude
			if distance < bestDistance then
				bestDistance = distance
				best = item
			end
		end
	end
	return best
end

local function setStep(nextStep: string)
	step = nextStep
	stepStartedAt = os.clock()
	if nextStep == "BAY" then
		local bay = ownBay()
		local pad = bay and bay:FindFirstChild("BayPad")
		setTarget(if pad and pad:IsA("BasePart") then pad else nil)
		message("YOUR BAY", "This is where every trip comes home.")
	elseif nextStep == "RECEIVING" then
		setTarget(receivingAnchor())
		message("GO TO RECEIVING", "Follow the objective into the warehouse.")
	elseif nextStep == "GRAB_ONE" then
		setTarget(nearestReceivingItem())
		message("GRAB SOMETHING", "E / X / GRAB on touch")
	elseif nextStep == "ONE_MORE" then
		setTarget(nearestReceivingItem())
		message("CAN YOU CARRY ONE MORE?", "Build a pile. Bigger trips are the point.")
	elseif nextStep == "MOVEMENT" then
		setTarget(nil)
		message("SHARP MOVES MAKE YOUR PILE SWAY", "MOVE SMOOTHLY")
	elseif nextStep == "RETURN" then
		local bay = ownBay()
		local unload = bay and bay:FindFirstChild("UnloadZone")
		setTarget(if unload and unload:IsA("BasePart") then unload else nil)
		message("BRING IT BACK", "Return to YOUR bay without losing the pile.")
	elseif nextStep == "REVIEW" then
		setTarget(nil)
		message("FIRST TRIP COMPLETE!", "SELL = cash now    •    KEEP = Stock income")
	elseif nextStep == "UPGRADES" then
		setTarget(nil)
		message("UPGRADE YOUR RIG TO CARRY MORE AND GO DEEPER.", "Strength • Carry Space • Control • Speed\nCheck UPGRADES, then close it when ready.")
		local playerGui = player:FindFirstChild("PlayerGui")
		local gui = playerGui and playerGui:FindFirstChild("OneTripProgressionUI")
		local panel = gui and gui:FindFirstChild("ProgressionPanel")
		if panel and panel:IsA("GuiObject") then panel.Visible = true end
		local folder = ReplicatedStorage:FindFirstChild(RemoteNames.Folder)
		local action = folder and folder:FindFirstChild(RemoteNames.ProgressionAction)
		if action and action:IsA("RemoteEvent") then action:FireServer("RequestState", {}) end
	elseif nextStep == "FIRST_LOCK" then
		setTarget(firstGateAnchor())
		message("APPLIANCES — RIG I REQUIRED", "BUILD RIG I TO GO DEEPER.")
	elseif nextStep == "DONE" then
		clearTarget()
		frame.Visible = false
	end
end

local function progressionPanelVisible(): boolean
	local playerGui = player:FindFirstChild("PlayerGui")
	local gui = playerGui and playerGui:FindFirstChild("OneTripProgressionUI")
	local panel = gui and gui:FindFirstChild("ProgressionPanel")
	return panel ~= nil and panel:IsA("GuiObject") and panel.Visible
end

local function complete()
	if not running then return end
	running = false
	tutorialAction:FireServer("Complete")
	setStep("DONE")
end

local function updateTutorial()
	if not running then return end
	local count = if latestCarry then tonumber(latestCarry.itemCount) or 0 else 0
	if step == "BAY" then
		local bay = ownBay()
		if not bay then return end
		if not targetPart then
			local pad = bay:FindFirstChild("BayPad")
			if pad and pad:IsA("BasePart") then setTarget(pad) end
		end
		if targetPart and os.clock() - stepStartedAt >= 1.4 then setStep("RECEIVING") end
	elseif step == "RECEIVING" then
		if not targetPart then setTarget(receivingAnchor()) end
		if isInReceiving() then setStep("GRAB_ONE") end
	elseif step == "GRAB_ONE" then
		if not targetPart or not targetPart.Parent then setTarget(nearestReceivingItem()) end
		if count >= 1 then setStep("ONE_MORE") end
	elseif step == "ONE_MORE" then
		if not targetPart or not targetPart.Parent then setTarget(nearestReceivingItem()) end
		if count >= 2 then setStep("MOVEMENT") end
	elseif step == "MOVEMENT" then
		if count <= 0 then
			setStep("GRAB_ONE")
			return
		end
		local sway = if latestCarry then tonumber(latestCarry.currentSway) or 0 else 0
		local danger = if latestCarry then tostring(latestCarry.dangerState or "Stable") else "Stable"
		if (sway >= 0.18 or danger == "Dangerous" or danger == "Near Collapse") and os.clock() - stepStartedAt >= 1.0 then
			message("STOP OR IT MAY FALL!", "Stopping reduces movement sway. Your load itself can still be risky.")
		end
		if os.clock() - stepStartedAt >= 4.5 then setStep("RETURN") end
	elseif step == "RETURN" then
		if not targetPart then
			local bay = ownBay()
			local unload = bay and bay:FindFirstChild("UnloadZone")
			if unload and unload:IsA("BasePart") then setTarget(unload) end
		end
		if count <= 0 and not reviewSeen then
			setStep("GRAB_ONE")
			return
		end
		local reviewId = latestEconomy and latestEconomy.reviewId
		if typeof(reviewId) == "string" and reviewId ~= "" then
			reviewSeen = true
			setStep("REVIEW")
		end
	elseif step == "REVIEW" then
		local reviewId = latestEconomy and latestEconomy.reviewId
		if reviewSeen and (typeof(reviewId) ~= "string" or reviewId == "") then setStep("UPGRADES") end
	elseif step == "UPGRADES" then
		if os.clock() - stepStartedAt >= 3.0 and not progressionPanelVisible() then setStep("FIRST_LOCK") end
	elseif step == "FIRST_LOCK" then
		if not targetPart then setTarget(firstGateAnchor()) end
		if os.clock() - stepStartedAt >= 6.0 then complete() end
	end
end

local function beginIfNeeded()
	if running or player:GetAttribute("TutorialReady") ~= true or player:GetAttribute("TutorialCompleted") == true then return end
	running = true
	reviewSeen = false
	setStep("BAY")
end

function Controller.Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "OneTripTutorialUI"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 30
	gui.IgnoreGuiInset = false
	gui.Parent = player:WaitForChild("PlayerGui")

	frame = Instance.new("Frame")
	frame.Name = "TutorialObjective"
	frame.AnchorPoint = Vector2.new(0.5,0)
	frame.Position = UDim2.new(0.5,0,0,18)
	frame.Size = UDim2.new(0.88,0,0,82)
	frame.BackgroundColor3 = Color3.fromRGB(24,29,36)
	frame.BackgroundTransparency = 0.05
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = gui
	roundCorner(frame,10)
	local constraint = Instance.new("UISizeConstraint")
	constraint.MinSize = Vector2.new(290,82)
	constraint.MaxSize = Vector2.new(570,82)
	constraint.Parent = frame
	titleLabel = makeText(frame,"ONE TRIP",UDim2.new(1,-18,0,32),20)
	titleLabel.Position = UDim2.fromOffset(9,7)
	titleLabel.TextColor3 = Color3.fromRGB(255,226,91)
	bodyLabel = makeText(frame,"",UDim2.new(1,-18,0,36),13)
	bodyLabel.Position = UDim2.fromOffset(9,40)
	bodyLabel.TextColor3 = Color3.fromRGB(214,221,230)

	local folder = ReplicatedStorage:WaitForChild(RemoteNames.Folder)
	local carryState = folder:WaitForChild(RemoteNames.CarryState) :: RemoteEvent
	local economyState = folder:WaitForChild(RemoteNames.EconomyState) :: RemoteEvent
	tutorialAction = folder:WaitForChild(RemoteNames.TutorialAction) :: RemoteEvent
	carryState.OnClientEvent:Connect(function(snapshot)
		if typeof(snapshot) == "table" then latestCarry = snapshot end
	end)
	economyState.OnClientEvent:Connect(function(snapshot)
		if typeof(snapshot) == "table" then latestEconomy = snapshot end
	end)
	player:GetAttributeChangedSignal("TutorialReady"):Connect(beginIfNeeded)
	player:GetAttributeChangedSignal("TutorialCompleted"):Connect(function()
		if player:GetAttribute("TutorialCompleted") == true and running then
			running = false
			setStep("DONE")
		end
	end)

	RunService.RenderStepped:Connect(function(dt)
		loopAccumulator += dt
		if loopAccumulator < 0.10 then return end
		loopAccumulator = 0
		beginIfNeeded()
		updateTutorial()
	end)
end

return Controller
