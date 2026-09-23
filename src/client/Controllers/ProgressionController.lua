--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NumberFormat = require(ReplicatedStorage:WaitForChild("NumberFormat"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local Controller = {}
local player = Players.LocalPlayer
local progressionAction: RemoteEvent
local latestSnapshot: any = nil
local panel: Frame
local list: ScrollingFrame
local cashLabel: TextLabel
local openButton: TextButton
local offlineShown = false

local function roundCorner(instance: GuiObject, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local function makeText(parent: Instance, text: string, size: UDim2, textSize: number): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = size
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextSize = textSize
	label.TextColor3 = Color3.fromRGB(240, 243, 247)
	label.TextWrapped = true
	label.Parent = parent
	return label
end

local function makeButton(parent: Instance, text: string, size: UDim2, background: Color3): TextButton
	local button = Instance.new("TextButton")
	button.Size = size
	button.BackgroundColor3 = background
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 15
	button.TextWrapped = true
	button.AutoButtonColor = true
	button.Parent = parent
	roundCorner(button, 8)
	return button
end

local function clearRows()
	for _, child in list:GetChildren() do
		if child:IsA("Frame") and child.Name == "UpgradeRow" then
			child:Destroy()
		end
	end
end

local function benefitText(track: any): string
	local current = tonumber(track.currentValue) or 0
	local nextValue = tonumber(track.nextValue) or current
	local id = tostring(track.id or "")
	if id == "StockSlots" then
		return ("%d → %d Stock Slots"):format(math.floor(current + 0.5), math.floor(nextValue + 0.5))
	elseif id == "Mobility" then
		return ("Search speed %.1f → %.1f"):format(current, nextValue)
	elseif id == "Control" then
		return "Handle increasingly unstable stacks"
	elseif id == "CarrySpace" then
		return "Carry larger / bulkier piles"
	elseif id == "Strength" then
		return "Carry heavier loads"
	end
	return tostring(track.description or "Upgrade")
end

local function rebuild(snapshot: any)
	latestSnapshot = snapshot
	cashLabel.Text = "CASH  " .. NumberFormat.Cash(tonumber(player:GetAttribute("Cash")) or tonumber(snapshot.cash) or 0)
	clearRows()
	local tracks = if typeof(snapshot.tracks) == "table" then snapshot.tracks else {}
	for _, track in tracks do
		if typeof(track) == "table" then
			local row = Instance.new("Frame")
			row.Name = "UpgradeRow"
			row.Size = UDim2.new(1, -12, 0, 96)
			row.BackgroundColor3 = Color3.fromRGB(39, 44, 52)
			row.BorderSizePixel = 0
			row.Parent = list
			roundCorner(row, 8)

			local name = string.upper(tostring(track.name or "UPGRADE"))
			local level = tonumber(track.level) or 1
			local maxLevel = tonumber(track.maxLevel) or level
			local isMax = track.isMax == true
			local title = makeText(row, ("%s   LEVEL %d/%d"):format(name, level, maxLevel), UDim2.new(0.60, -14, 0, 28), 16)
			title.Position = UDim2.fromOffset(10, 7)
			title.TextXAlignment = Enum.TextXAlignment.Left

			local description = makeText(row, if isMax then "MAXED" else benefitText(track), UDim2.new(0.60, -14, 0, 48), 13)
			description.Position = UDim2.fromOffset(10, 36)
			description.TextXAlignment = Enum.TextXAlignment.Left
			description.TextColor3 = Color3.fromRGB(187, 198, 211)

			local cost = tonumber(track.nextCost) or 0
			local buy = makeButton(
				row,
				if isMax then "MAX" else ("BUY\n%s"):format(NumberFormat.Cash(cost)),
				UDim2.new(0.36, -8, 0, 58),
				if isMax then Color3.fromRGB(72, 79, 90) else Color3.fromRGB(72, 126, 89)
			)
			buy.Position = UDim2.new(0.63, 0, 0.5, -29)
			buy.Active = not isMax
			buy.Activated:Connect(function()
				if not isMax and typeof(track.id) == "string" then
					progressionAction:FireServer("PurchaseUpgrade", { trackId = track.id })
				end
			end)
		end
	end
end

local function showOffline(gui: ScreenGui)
	if offlineShown then
		return
	end
	local amount = tonumber(player:GetAttribute("OfflineEarnings")) or 0
	if amount <= 0 then
		return
	end
	offlineShown = true
	local banner = Instance.new("Frame")
	banner.Name = "OfflineEarnings"
	banner.AnchorPoint = Vector2.new(0.5, 0)
	banner.Position = UDim2.new(0.5, 0, 0, 18)
	banner.Size = UDim2.fromOffset(330, 82)
	banner.BackgroundColor3 = Color3.fromRGB(31, 54, 41)
	banner.BorderSizePixel = 0
	banner.Parent = gui
	roundCorner(banner, 10)
	local title = makeText(banner, "WHILE YOU WERE AWAY", UDim2.new(1, -20, 0, 28), 16)
	title.Position = UDim2.fromOffset(10, 9)
	local earned = makeText(banner, "YOUR STOCK EARNED  " .. NumberFormat.Cash(amount), UDim2.new(1, -20, 0, 28), 19)
	earned.Position = UDim2.fromOffset(10, 41)
	earned.TextColor3 = Color3.fromRGB(132, 239, 163)
	task.delay(6, function()
		if banner.Parent then
			banner:Destroy()
		end
	end)
end

function Controller.Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "OneTripProgressionUI"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 21
	gui.Parent = player:WaitForChild("PlayerGui")

	openButton = makeButton(gui, "UPGRADES", UDim2.fromOffset(150, 38), Color3.fromRGB(61, 79, 105))
	openButton.AnchorPoint = Vector2.new(1, 0)
	openButton.Position = UDim2.new(1, -18, 0, 140)

	panel = Instance.new("Frame")
	panel.Name = "ProgressionPanel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.52)
	panel.Size = UDim2.fromScale(0.86, 0.80)
	panel.BackgroundColor3 = Color3.fromRGB(23, 26, 31)
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = gui
	roundCorner(panel, 12)
	local constraint = Instance.new("UISizeConstraint")
	constraint.MinSize = Vector2.new(310, 360)
	constraint.MaxSize = Vector2.new(610, 600)
	constraint.Parent = panel

	local title = makeText(panel, "UPGRADES", UDim2.new(1, -120, 0, 40), 24)
	title.Position = UDim2.fromOffset(14, 8)
	title.TextXAlignment = Enum.TextXAlignment.Left
	cashLabel = makeText(panel, "CASH  $0", UDim2.new(1, -28, 0, 24), 15)
	cashLabel.Position = UDim2.fromOffset(14, 49)
	cashLabel.TextXAlignment = Enum.TextXAlignment.Left
	cashLabel.TextColor3 = Color3.fromRGB(132, 239, 163)

	local close = makeButton(panel, "CLOSE", UDim2.fromOffset(86, 34), Color3.fromRGB(91, 70, 70))
	close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.new(1, -12, 0, 10)

	list = Instance.new("ScrollingFrame")
	list.Name = "UpgradeList"
	list.Position = UDim2.fromOffset(12, 80)
	list.Size = UDim2.new(1, -24, 1, -92)
	list.BackgroundColor3 = Color3.fromRGB(31, 35, 42)
	list.BackgroundTransparency = 0.15
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 6
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Parent = panel
	roundCorner(list, 8)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.PaddingLeft = UDim.new(0, 6)
	padding.Parent = list
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 7)
	layout.Parent = list

	openButton.Activated:Connect(function()
		panel.Visible = not panel.Visible
		if panel.Visible then
			progressionAction:FireServer("RequestState", {})
		end
	end)
	close.Activated:Connect(function()
		panel.Visible = false
	end)

	local remoteFolder = ReplicatedStorage:WaitForChild(RemoteNames.Folder)
	local progressionState = remoteFolder:WaitForChild(RemoteNames.ProgressionState) :: RemoteEvent
	progressionAction = remoteFolder:WaitForChild(RemoteNames.ProgressionAction) :: RemoteEvent
	progressionState.OnClientEvent:Connect(function(snapshot)
		if typeof(snapshot) == "table" then
			rebuild(snapshot)
			showOffline(gui)
		end
	end)

	player:GetAttributeChangedSignal("Cash"):Connect(function()
		if cashLabel then
			cashLabel.Text = "CASH  " .. NumberFormat.Cash(tonumber(player:GetAttribute("Cash")) or 0)
		end
	end)
	player:GetAttributeChangedSignal("OfflineEarnings"):Connect(function()
		showOffline(gui)
	end)

	progressionAction:FireServer("RequestState", {})
	showOffline(gui)
end

return Controller
