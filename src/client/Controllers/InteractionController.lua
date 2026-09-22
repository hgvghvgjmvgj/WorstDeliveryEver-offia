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

	ContextActionService:BindAction("OneTripGrab", grabAction, true, Enum.KeyCode.E, Enum.KeyCode.ButtonX)
	ContextActionService:SetTitle("OneTripGrab", "GRAB")
	ContextActionService:SetPosition("OneTripGrab", UDim2.new(1, -150, 1, -180))

	ContextActionService:BindAction("OneTripDrop", dropAction, false, Enum.KeyCode.Q, Enum.KeyCode.ButtonB)

	RunService.RenderStepped:Connect(function(dt)
		scanAccumulator += dt
		if scanAccumulator < 0.10 then
			return
		end
		scanAccumulator = 0

		nearestItem = getNearest()

		if nearestItem then
			local itemId = nearestItem:GetAttribute("ItemId")
			local definition = if typeof(itemId) == "string" then ItemConfig[itemId] else nil
			uiController.SetNearbyItem(definition and definition.Name or nearestItem.Name)
		else
			uiController.SetNearbyItem(nil)
		end

		local touchButton = ContextActionService:GetButton("OneTripGrab")
		if touchButton then
			touchButton.Visible = nearestItem ~= nil
			touchButton.Size = UDim2.fromOffset(92, 92)
		end
	end)
end

return Controller
