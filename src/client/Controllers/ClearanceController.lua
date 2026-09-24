--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ClearanceConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ClearanceConfig"))

local Controller = {}
local player = Players.LocalPlayer
local prompt: Frame
local promptTitle: TextLabel
local promptBody: TextLabel
local toast: Frame
local toastTitle: TextLabel
local toastBody: TextLabel
local lastTier: number? = nil
local scanAccumulator = 0
local toastToken = 0

local LOCKED = Color3.fromRGB(214, 70, 70)
local CLEARED = Color3.fromRGB(75, 211, 118)

local function roundCorner(instance: GuiObject, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local function text(parent: Instance, value: string, size: UDim2, fontSize: number): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = size
	label.Font = Enum.Font.GothamBold
	label.Text = value
	label.TextSize = fontSize
	label.TextWrapped = true
	label.TextColor3 = Color3.new(1,1,1)
	label.Parent = parent
	return label
end

local function currentTier(): number
	return math.clamp(math.floor((tonumber(player:GetAttribute("HandlingRigTier")) or 0) + 0.5), 0, 5)
end

local function gateFolder(): Folder?
	local world = workspace:FindFirstChild("OneTripPrototype")
	local gameplay = world and world:FindFirstChild("WarehouseGameplay")
	local folder = gameplay and gameplay:FindFirstChild("ClearanceCheckpoints")
	return if folder and folder:IsA("Folder") then folder else nil
end

local function paintGate(model: Model, tier: number)
	local required = tonumber(model:GetAttribute("RequiredRig")) or 1
	local cleared = tier >= required
	local color = if cleared then CLEARED else LOCKED
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") and descendant:GetAttribute("ClearanceVisual") == true then
			descendant.Color = color
			if descendant.Name == "BarrierField" then
				descendant.LocalTransparencyModifier = if cleared then 0.18 else 0
			end
		elseif descendant:IsA("TextLabel") and descendant.Name == "ClearanceText" then
			local sectionId = tostring(model:GetAttribute("BeforeSection") or "")
			descendant.Text = if cleared
				then ("%s — CLEARED\n%s"):format(ClearanceConfig.RigName(required), ClearanceConfig.SectionName(sectionId))
				else ("%s REQUIRED\n%s"):format(ClearanceConfig.RigName(required), ClearanceConfig.SectionName(sectionId))
			descendant.TextColor3 = color
			descendant.BackgroundColor3 = if cleared then Color3.fromRGB(18,54,31) else Color3.fromRGB(54,18,18)
		end
	end
end

local function repaintAll()
	local folder = gateFolder()
	if not folder then return end
	local tier = currentTier()
	for _, child in folder:GetChildren() do
		if child:IsA("Model") then paintGate(child, tier) end
	end
end

local function showToast(tier: number)
	if tier <= 0 then return end
	toastToken += 1
	local token = toastToken
	local names = {}
	for _, sectionId in ClearanceConfig.NewSectionsForTier(tier) do
		table.insert(names, ClearanceConfig.SectionName(sectionId))
	end
	toastTitle.Text = ClearanceConfig.RigName(tier) .. " UNLOCKED!"
	toastBody.Text = "NEW WAREHOUSE ACCESS:\n" .. table.concat(names, "  •  ")
	toast.Visible = true
	toast.BackgroundTransparency = 0.06
	toast.Position = UDim2.new(0.5,0,0,78)
	TweenService:Create(toast, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position=UDim2.new(0.5,0,0,96)}):Play()
	task.delay(3.2, function()
		if token ~= toastToken or not toast.Parent then return end
		local tween = TweenService:Create(toast, TweenInfo.new(0.20), {BackgroundTransparency=1})
		tween:Play()
		tween.Completed:Wait()
		if token == toastToken then toast.Visible = false end
	end)
end

local function nearestLockedGate(): (Model?, number)
	local folder = gateFolder()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not folder or not root or not root:IsA("BasePart") then return nil, math.huge end
	local tier = currentTier()
	local best: Model? = nil
	local bestDistance = math.huge
	for _, child in folder:GetChildren() do
		if child:IsA("Model") then
			local required = tonumber(child:GetAttribute("RequiredRig")) or 1
			if required > tier then
				local z = tonumber(child:GetAttribute("GateZ"))
				if z then
					local distance = math.abs(root.Position.Z - z)
					if distance < bestDistance then
						bestDistance = distance
						best = child
					end
				end
			end
		end
	end
	return best, bestDistance
end

local function updatePrompt()
	local gate, distance = nearestLockedGate()
	if not gate or distance > 38 then
		prompt.Visible = false
		return
	end
	local required = tonumber(gate:GetAttribute("RequiredRig")) or 1
	promptTitle.Text = ClearanceConfig.RigName(required) .. " REQUIRED"
	promptBody.Text = ("CURRENT: %s     REQUIRED: %s\nUpgrade Strength + Carry Space + Control to continue."):format(
		ClearanceConfig.RigName(currentTier()), ClearanceConfig.RigName(required)
	)
	prompt.Visible = true
end

function Controller.Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "OneTripClearanceUI"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 24
	gui.Parent = player:WaitForChild("PlayerGui")

	prompt = Instance.new("Frame")
	prompt.AnchorPoint = Vector2.new(0.5,1)
	prompt.Position = UDim2.new(0.5,0,1,-105)
	prompt.Size = UDim2.new(0.88,0,0,84)
	prompt.BackgroundColor3 = Color3.fromRGB(38,23,25)
	prompt.BackgroundTransparency = 0.08
	prompt.BorderSizePixel = 0
	prompt.Visible = false
	prompt.Parent = gui
	roundCorner(prompt,10)
	local pc = Instance.new("UISizeConstraint")
	pc.MinSize = Vector2.new(290,84)
	pc.MaxSize = Vector2.new(560,84)
	pc.Parent = prompt
	promptTitle = text(prompt,"RIG REQUIRED",UDim2.new(1,-18,0,31),18)
	promptTitle.Position = UDim2.fromOffset(9,7)
	promptTitle.TextColor3 = LOCKED
	promptBody = text(prompt,"",UDim2.new(1,-18,0,40),13)
	promptBody.Position = UDim2.fromOffset(9,38)
	promptBody.TextColor3 = Color3.fromRGB(229,215,216)

	toast = Instance.new("Frame")
	toast.AnchorPoint = Vector2.new(0.5,0)
	toast.Position = UDim2.new(0.5,0,0,96)
	toast.Size = UDim2.new(0.88,0,0,84)
	toast.BackgroundColor3 = Color3.fromRGB(24,50,34)
	toast.BackgroundTransparency = 0.06
	toast.BorderSizePixel = 0
	toast.Visible = false
	toast.Parent = gui
	roundCorner(toast,10)
	local tc = Instance.new("UISizeConstraint")
	tc.MinSize = Vector2.new(290,84)
	tc.MaxSize = Vector2.new(560,84)
	tc.Parent = toast
	toastTitle = text(toast,"RIG UNLOCKED!",UDim2.new(1,-18,0,31),18)
	toastTitle.Position = UDim2.fromOffset(9,7)
	toastTitle.TextColor3 = CLEARED
	toastBody = text(toast,"",UDim2.new(1,-18,0,40),12)
	toastBody.Position = UDim2.fromOffset(9,38)

	lastTier = currentTier()
	player:GetAttributeChangedSignal("HandlingRigTier"):Connect(function()
		local nextTier = currentTier()
		local old = lastTier
		lastTier = nextTier
		repaintAll()
		-- ProgressionService writes the derived tier before setting ProgressionReady.
		-- Suppress a fake "unlock" celebration when an existing profile first loads.
		if player:GetAttribute("ProgressionReady") == true and old ~= nil and nextTier > old then
			showToast(nextTier)
		end
	end)
	player:GetAttributeChangedSignal("ProgressionReady"):Connect(function()
		if player:GetAttribute("ProgressionReady") == true then
			lastTier = currentTier()
			repaintAll()
		end
	end)

	RunService.RenderStepped:Connect(function(dt)
		scanAccumulator += dt
		if scanAccumulator < 0.15 then return end
		scanAccumulator = 0
		repaintAll()
		updatePrompt()
	end)
end

return Controller
