--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Controller = {}
local player = Players.LocalPlayer
local accumulator = 0

local function viewport(): Vector2
	local camera = Workspace.CurrentCamera
	return if camera then camera.ViewportSize else Vector2.new(1280, 720)
end

local function compactMobile(): boolean
	local size = viewport()
	return UserInputService.TouchEnabled and (size.Y <= 650 or size.X <= 950)
end

local function gui(name: string): ScreenGui?
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return nil end
	local value = playerGui:FindFirstChild(name)
	return if value and value:IsA("ScreenGui") then value else nil
end

local function textButtonByText(root: Instance?, wanted: string): TextButton?
	if not root then return nil end
	for _, descendant in root:GetDescendants() do
		if descendant:IsA("TextButton") and descendant.Text == wanted then
			return descendant
		end
	end
	return nil
end

local function setConstraint(frame: GuiObject, min: Vector2, max: Vector2)
	local constraint = frame:FindFirstChildOfClass("UISizeConstraint")
	if constraint then
		constraint.MinSize = min
		constraint.MaxSize = max
	end
end

local function applyPrototype(tutorialActive: boolean)
	local root = gui("OneTripPrototypeUI")
	if not root then return end
	local status = root:FindFirstChild("Status")
	if status and status:IsA("TextLabel") then
		status.Visible = not tutorialActive
		status.Size = UDim2.fromOffset(190, 58)
		status.Position = UDim2.fromOffset(10, 54)
		status.TextSize = 11
		status.BackgroundTransparency = 0.28
	end
	local pressure = root:FindFirstChild("LoadPressure")
	if pressure and pressure:IsA("Frame") then
		pressure.Size = UDim2.fromOffset(185, 44)
		pressure.Position = UDim2.fromOffset(10, 116)
		local title = pressure:FindFirstChild("Title")
		if title and title:IsA("TextLabel") then
			title.Size = UDim2.fromOffset(112, 18)
			title.Position = UDim2.fromOffset(8, 2)
			title.TextSize = 10
		end
		local state = pressure:FindFirstChild("State")
		if state and state:IsA("TextLabel") then
			state.Size = UDim2.fromOffset(60, 18)
			state.Position = UDim2.new(1, -68, 0, 2)
			state.TextSize = 9
		end
		local track = pressure:FindFirstChild("Track")
		if track and track:IsA("Frame") then
			track.Size = UDim2.new(1, -16, 0, 9)
			track.Position = UDim2.fromOffset(8, 27)
		end
	end
	local prompt = root:FindFirstChild("Prompt")
	if prompt and prompt:IsA("TextLabel") then
		prompt.Size = UDim2.fromOffset(205, 38)
		prompt.Position = UDim2.new(0.5, -102, 1, -82)
		prompt.TextSize = 13
		prompt.BackgroundTransparency = 0.25
	end
	local notice = root:FindFirstChild("Notice")
	if notice and notice:IsA("TextLabel") then
		notice.Size = UDim2.fromOffset(280, 38)
		notice.Position = UDim2.new(0.5, -140, 0, 104)
		notice.TextSize = 13
	end
	local debug = root:FindFirstChild("Debug")
	if debug and debug:IsA("GuiObject") then debug.Visible = false end
	local burst = root:FindFirstChild("Burst")
	if burst and burst:IsA("TextLabel") then
		burst.Size = UDim2.fromOffset(300, 68)
		burst.Position = UDim2.new(0.5, -150, 0.40, -34)
		burst.TextSize = 27
	end
end

local function applyEconomy(tutorialActive: boolean)
	local root = gui("OneTripEconomyUI")
	if not root then return end
	local summary = root:FindFirstChild("EconomySummary")
	if summary and summary:IsA("Frame") then
		summary.Visible = not tutorialActive
		summary.Size = UDim2.fromOffset(148, 62)
		summary.Position = UDim2.new(1, -158, 0, 54)
		summary.BackgroundTransparency = 0.22
		local cash = summary:FindFirstChild("Cash")
		if cash and cash:IsA("TextLabel") then
			cash.Size = UDim2.new(1, -12, 0, 25)
			cash.Position = UDim2.fromOffset(6, 3)
			cash.TextSize = 16
		end
		local stock = summary:FindFirstChild("Stock")
		if stock and stock:IsA("GuiObject") then stock.Visible = false end
		local passive = summary:FindFirstChild("Passive")
		if passive and passive:IsA("GuiObject") then passive.Visible = false end
		local manage = summary:FindFirstChild("Manage")
		if manage and manage:IsA("TextButton") then
			manage.Text = "STOCK"
			manage.Size = UDim2.new(1, -12, 0, 25)
			manage.Position = UDim2.fromOffset(6, 32)
			manage.TextSize = 11
		end
	end

	local review = root:FindFirstChild("DeliveryReview")
	if review and review:IsA("Frame") then
		review.Size = UDim2.fromScale(0.94, 0.82)
		review.Position = UDim2.fromScale(0.5, 0.54)
		setConstraint(review, Vector2.new(280, 220), Vector2.new(620, 430))
	end
	local manageFrame = root:FindFirstChild("ManageStock")
	if manageFrame and manageFrame:IsA("Frame") then
		manageFrame.Size = UDim2.fromScale(0.90, 0.82)
		manageFrame.Position = UDim2.fromScale(0.5, 0.54)
	end
end

local function applyProgression(tutorialActive: boolean)
	local root = gui("OneTripProgressionUI")
	if not root then return end
	local open = textButtonByText(root, "UPGRADES")
	if open then
		open.Visible = not tutorialActive
		open.Size = UDim2.fromOffset(92, 29)
		open.Position = UDim2.new(1, -10, 0, 122)
		open.TextSize = 11
	end
	local panel = root:FindFirstChild("ProgressionPanel")
	if panel and panel:IsA("Frame") then
		panel.Size = UDim2.fromScale(0.94, 0.86)
		panel.Position = UDim2.fromScale(0.5, 0.54)
		setConstraint(panel, Vector2.new(280, 220), Vector2.new(620, 440))
	end
end

local function applyCollection(tutorialActive: boolean)
	local root = gui("OneTripCollectionUI")
	if not root then return end
	local open = textButtonByText(root, "COLLECTION")
	if open then
		open.Visible = not tutorialActive
		open.Size = UDim2.fromOffset(92, 29)
		open.Position = UDim2.new(1, -10, 0, 156)
		open.TextSize = 10
	end
	local panel = root:FindFirstChild("CollectionPanel")
	if panel and panel:IsA("Frame") then
		panel.Size = UDim2.fromScale(0.96, 0.88)
		panel.Position = UDim2.fromScale(0.5, 0.54)
		setConstraint(panel, Vector2.new(280, 220), Vector2.new(680, 450))
	end
end

local function applyHandling()
	local root = gui("OneTripHandlingUI")
	if not root then return end
	local rig = root:FindFirstChild("RigSummary")
	if rig and rig:IsA("Frame") then
		-- Rig requirements are available in UPGRADES and at clearance gates. Keeping
		-- the desktop card here would consume the center of a phone landscape view.
		rig.Visible = false
	end
	local preview = root:FindFirstChild("HandlingPreview")
	if preview and preview:IsA("Frame") then
		preview.Size = UDim2.fromOffset(245, 48)
		preview.Position = UDim2.new(0.5, 0, 1, -112)
		local label = preview:FindFirstChildWhichIsA("TextLabel")
		if label then label.TextSize = 11 end
	end
end

local function applyTutorial(): boolean
	local root = gui("OneTripTutorialUI")
	if not root then return false end
	local objective = root:FindFirstChild("TutorialObjective")
	if not objective or not objective:IsA("Frame") then return false end
	objective.Size = UDim2.new(0.82, 0, 0, 64)
	objective.Position = UDim2.new(0.5, 0, 0, 54)
	setConstraint(objective, Vector2.new(270, 64), Vector2.new(430, 64))
	for _, child in objective:GetChildren() do
		if child:IsA("TextLabel") then
			child.TextSize = if child.Name == "TextLabel" then 12 else math.min(child.TextSize, 15)
		end
	end
	return objective.Visible
end

local function applyClearance()
	local root = gui("OneTripClearanceUI")
	if not root then return end
	for _, child in root:GetChildren() do
		if child:IsA("Frame") then
			child.Size = UDim2.new(0.82, 0, 0, 66)
			setConstraint(child, Vector2.new(270, 66), Vector2.new(430, 66))
			for _, descendant in child:GetDescendants() do
				if descendant:IsA("TextLabel") then descendant.TextSize = math.min(descendant.TextSize, 13) end
			end
		end
	end
end

local function applyWorldLabels()
	for _, descendant in Workspace:GetDescendants() do
		if descendant:IsA("BillboardGui") then
			if descendant.Name == "PrototypeLabel" then
				descendant.Size = UDim2.fromOffset(118, 34)
				descendant.MaxDistance = 30
				local label = descendant:FindFirstChildWhichIsA("TextLabel", true)
				if label then
					label.TextScaled = false
					label.TextSize = 10
					label.TextStrokeTransparency = 0.42
				end
			elseif descendant.Name == "Label" and descendant.Parent and descendant.Parent.Name == "SectionSignAnchor" then
				descendant.Size = UDim2.fromOffset(220, 56)
				descendant.MaxDistance = 80
				local label = descendant:FindFirstChildWhichIsA("TextLabel", true)
				if label then
					label.TextScaled = false
					label.TextSize = 12
				end
			elseif descendant.Name == "ClearanceBillboard" then
				descendant.Size = UDim2.fromOffset(220, 54)
				descendant.MaxDistance = 70
				local label = descendant:FindFirstChildWhichIsA("TextLabel", true)
				if label then
					label.TextScaled = false
					label.TextSize = 12
				end
			end
		end
	end
end

local function applyCompact()
	if not compactMobile() then return end
	local tutorialActive = applyTutorial()
	applyPrototype(tutorialActive)
	applyEconomy(tutorialActive)
	applyProgression(tutorialActive)
	applyCollection(tutorialActive)
	applyHandling()
	applyClearance()
	applyWorldLabels()
end

function Controller.Start()
	if not UserInputService.TouchEnabled then return end
	task.defer(applyCompact)
	task.delay(0.5, applyCompact)
	task.delay(1.5, applyCompact)

	local camera = Workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyCompact)
	end

	RunService.RenderStepped:Connect(function(dt)
		accumulator += dt
		if accumulator < 0.75 then return end
		accumulator = 0
		applyCompact()
	end)
end

return Controller
