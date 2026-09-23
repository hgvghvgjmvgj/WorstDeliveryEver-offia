--!strict

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CarryConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("CarryConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local Controller = {}

local player = Players.LocalPlayer
local nearestItem: BasePart? = nil
local scanAccumulator = 0
local highlight: Highlight? = nil

local function ensureHighlight(): Highlight
	if highlight and highlight.Parent then
		return highlight
	end

	local created = Instance.new("Highlight")
	created.Name = "OneTripGrabHighlight"
	created.FillTransparency = 0.88
	created.OutlineTransparency = 0.18
	created.DepthMode = Enum.HighlightDepthMode.Occluded
	created.Enabled = false
	created.Parent = workspace
	highlight = created
	return created
end

local function getNearest(): BasePart?
	local world = workspace:FindFirstChild("OneTripPrototype")
	local items = world and world:FindFirstChild("Items")
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not items or not root or not root:IsA("BasePart") then
		return nil
	end

	local best: BasePart? = nil
	local bestDistance = CarryConfig.GrabDistance

	for _, candidate in items:GetChildren() do
		if candidate:IsA("BasePart") and candidate:GetAttribute("Available") == true then
			local distance = (root.Position - candidate.Position).Magnitude
			if distance <= bestDistance then
				bestDistance = distance
				best = candidate
			end
		end
	end

	return best
end

local function updateHighlight()
	local currentHighlight = ensureHighlight()
	currentHighlight.Adornee = nearestItem
	currentHighlight.Enabled = nearestItem ~= nil
end

function Controller.Start(uiController: any)
	local remoteFolder = ReplicatedStorage:WaitForChild(RemoteNames.Folder)
	local requestGrab = remoteFolder:WaitForChild(RemoteNames.RequestGrab) :: RemoteEvent
	local requestDrop = remoteFolder:WaitForChild(RemoteNames.RequestDrop) :: RemoteEvent

	local function grabAction(_: string, inputState: Enum.UserInputState): Enum.ContextActionResult
		if inputState == Enum.UserInputState.Begin and nearestItem then
			requestGrab:FireServer(nearestItem)
		end
		return Enum.ContextActionResult.Sink
	end

	local function dropAction(_: string, inputState: Enum.UserInputState): Enum.ContextActionResult
		if inputState == Enum.UserInputState.Begin then
			requestDrop:FireServer()
		end
		return Enum.ContextActionResult.Sink
	end

	ContextActionService:BindAction(
		"OneTripGrab",
		grabAction,
		true,
		Enum.KeyCode.E,
		Enum.KeyCode.ButtonX
	)
	ContextActionService:SetTitle("OneTripGrab", "GRAB")
	ContextActionService:SetPosition("OneTripGrab", UDim2.new(1, -150, 1, -180))

	-- Ditching the top item is an intentional emergency-sacrifice mechanic, so
	-- touch players need the same control as keyboard/controller players.
	ContextActionService:BindAction(
		"OneTripDrop",
		dropAction,
		true,
		Enum.KeyCode.Q,
		Enum.KeyCode.ButtonB
	)
	ContextActionService:SetTitle("OneTripDrop", "DITCH")
	ContextActionService:SetPosition("OneTripDrop", UDim2.new(1, -255, 1, -180))

	RunService.RenderStepped:Connect(function(dt)
		scanAccumulator += dt
		if scanAccumulator < 0.08 then
			return
		end
		scanAccumulator = 0

		nearestItem = getNearest()
		updateHighlight()

		if nearestItem then
			local itemId = nearestItem:GetAttribute("ItemId")
			local definition = if typeof(itemId) == "string"
				then ItemConfig[itemId]
				else nil

			uiController.SetNearbyItem(
				definition and definition.Name or nearestItem.Name
			)
		else
			uiController.SetNearbyItem(nil)
		end

		local grabButton = ContextActionService:GetButton("OneTripGrab")
		if grabButton then
			grabButton.Visible = nearestItem ~= nil
			grabButton.Size = UDim2.fromOffset(96, 96)
		end

		local ditchButton = ContextActionService:GetButton("OneTripDrop")
		if ditchButton then
			-- CarryState remains server-authoritative; keeping the emergency button
			-- available avoids a second client-side source of truth for item count.
			ditchButton.Size = UDim2.fromOffset(78, 78)
		end
	end)
end

return Controller
