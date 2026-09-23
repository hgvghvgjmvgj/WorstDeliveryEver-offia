--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NumberFormat = require(ReplicatedStorage:WaitForChild("NumberFormat"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local Controller = {}
local player = Players.LocalPlayer
local economyAction: RemoteEvent
local latestSnapshot: any = nil
local selected: {[string]: boolean} = {}
local activeReviewId: string? = nil

local cashLabel: TextLabel
local stockLabel: TextLabel
local passiveLabel: TextLabel
local reviewFrame: Frame
local reviewTitle: TextLabel
local reviewStockLabel: TextLabel
local itemList: ScrollingFrame
local keepSelectedButton: TextButton
local sellRestButton: TextButton
local sellAllButton: TextButton
local manageButton: TextButton
local manageFrame: Frame
local manageList: ScrollingFrame

local function roundCorner(instance: GuiObject, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local function makeText(parent: Instance, name: string, text: string, size: UDim2, position: UDim2, textSize: number): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Text = text
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.fromRGB(240, 243, 247)
	label.TextSize = textSize
	label.TextWrapped = true
	label.Parent = parent
	return label
end

local function makeButton(parent: Instance, name: string, text: string, size: UDim2, position: UDim2, background: Color3): TextButton
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = background
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 16
	button.TextWrapped = true
	button.Parent = parent
	roundCorner(button, 8)
	return button
end

local function clearRows(parent: Instance, rowName: string)
	for _, child in parent:GetChildren() do
		if child:IsA("GuiObject") and child.Name == rowName then
			child:Destroy()
		end
	end
end

local function selectedCount(): number
	local count = 0
	for _, enabled in selected do
		if enabled then
			count += 1
		end
	end
	return count
end

local function sendReviewAction(action: string, extra: {[string]: any}?)
	if not latestSnapshot or typeof(latestSnapshot.reviewId) ~= "string" then
		return
	end
	local payload: {[string]: any} = { reviewId = latestSnapshot.reviewId }
	if extra then
		for key, value in extra do
			payload[key] = value
		end
	end
	economyAction:FireServer(action, payload)
end

local function refreshKeepButton()
	if not latestSnapshot then
		return
	end
	local count = selectedCount()
	local free = tonumber(latestSnapshot.stockFree) or 0
	if count <= 0 then
		keepSelectedButton.Text = "SELECT ITEMS TO KEEP"
		keepSelectedButton.BackgroundColor3 = Color3.fromRGB(83, 91, 104)
		keepSelectedButton.Active = false
	elseif count > free then
		keepSelectedButton.Text = "STOCK FULL — MANAGE FIRST"
		keepSelectedButton.BackgroundColor3 = Color3.fromRGB(153, 76, 70)
		keepSelectedButton.Active = false
	else
		keepSelectedButton.Text = ("KEEP SELECTED (%d)"):format(count)
		keepSelectedButton.BackgroundColor3 = Color3.fromRGB(67, 142, 101)
		keepSelectedButton.Active = true
	end
end

local function rebuildReview(snapshot)
	local reviewId = snapshot.reviewId
	if reviewId ~= activeReviewId then
		table.clear(selected)
		activeReviewId = reviewId
	end
	if typeof(reviewId) ~= "string" or reviewId == "" then
		reviewFrame.Visible = false
		clearRows(itemList, "ReviewItem")
		return
	end

	reviewFrame.Visible = true
	local items = if typeof(snapshot.reviewItems) == "table" then snapshot.reviewItems else {}
	local free = tonumber(snapshot.stockFree) or 0
	local capacity = tonumber(snapshot.stockCapacity) or 0
	local occupied = tonumber(snapshot.stockOccupied) or 0
	reviewTitle.Text = ("DELIVERY COMPLETE  •  %d ITEMS"):format(#items)
	reviewStockLabel.Text = ("STOCK: %d / %d  •  %d FREE"):format(occupied, capacity, free)

	local stillPresent: {[string]: boolean} = {}
	for _, item in items do
		if typeof(item) == "table" and typeof(item.id) == "string" then
			stillPresent[item.id] = true
		end
	end
	for id in selected do
		if not stillPresent[id] then
			selected[id] = nil
		end
	end

	clearRows(itemList, "ReviewItem")
	for _, item in items do
		if typeof(item) == "table" and typeof(item.id) == "string" then
			local id = item.id
			local name = tostring(item.name or item.itemId or "ITEM")
			local sell = tonumber(item.sellValue) or 0
			local passive = tonumber(item.passiveRate) or 0
			local row = Instance.new("TextButton")
			row.Name = "ReviewItem"
			row.Size = UDim2.new(1, -12, 0, 62)
			row.BackgroundColor3 = if selected[id] then Color3.fromRGB(57, 116, 84) else Color3.fromRGB(42, 47, 56)
			row.BorderSizePixel = 0
			row.Font = Enum.Font.GothamBold
			row.TextColor3 = Color3.fromRGB(243, 245, 248)
			row.TextSize = 15
			row.TextWrapped = true
			row.TextXAlignment = Enum.TextXAlignment.Left
			row.Text = string.format(
				"  %s%s\n  SELL %s NOW    •    KEEP %s",
				if selected[id] then "✓ " else "",
				string.upper(name),
				NumberFormat.Cash(sell),
				NumberFormat.Rate(passive)
			)
			row.Parent = itemList
			roundCorner(row, 7)
			row.Activated:Connect(function()
				selected[id] = not selected[id]
				rebuildReview(latestSnapshot)
			end)
		end
	end
	refreshKeepButton()
end

local function rebuildManage(snapshot)
	clearRows(manageList, "StockRow")
	local stockItems = if typeof(snapshot.stockItems) == "table" then snapshot.stockItems else {}
	if #stockItems == 0 then
		local label = makeText(manageList, "StockRow", "NO STOCK KEPT YET", UDim2.new(1, -12, 0, 48), UDim2.new(), 15)
		label.TextColor3 = Color3.fromRGB(180, 189, 201)
		return
	end

	for _, stock in stockItems do
		if typeof(stock) == "table" then
			local row = Instance.new("Frame")
			row.Name = "StockRow"
			row.Size = UDim2.new(1, -12, 0, 70)
			row.BackgroundColor3 = Color3.fromRGB(42, 47, 56)
			row.BorderSizePixel = 0
			row.Parent = manageList
			roundCorner(row, 7)

			local slotIndex = tonumber(stock.slotIndex) or 0
			local name = string.upper(tostring(stock.name or "ITEM"))
			local passive = tonumber(stock.passiveRate) or 0
			local salvage = tonumber(stock.salvageValue) or 0
			local info = makeText(
				row,
				"Info",
				("SLOT %d — %s\n%s"):format(slotIndex, name, NumberFormat.Rate(passive)),
				UDim2.new(0.62, -8, 1, 0),
				UDim2.fromOffset(10, 0),
				14
			)
			info.TextXAlignment = Enum.TextXAlignment.Left

			local sellButton = makeButton(
				row,
				"Liquidate",
				("LIQUIDATE\n%s"):format(NumberFormat.Cash(salvage)),
				UDim2.new(0.36, -8, 0, 50),
				UDim2.new(0.64, 0, 0.5, -25),
				Color3.fromRGB(156, 101, 58)
			)
			sellButton.TextSize = 13
			sellButton.Activated:Connect(function()
				if typeof(stock.stockId) == "string" then
					economyAction:FireServer("SellStock", {
						slotIndex = slotIndex,
						stockId = stock.stockId,
					})
				end
			end)
		end
	end
end

local function refreshSummary(snapshot)
	cashLabel.Text = "CASH  " .. NumberFormat.Cash(tonumber(snapshot.cash) or 0)
	local occupied = tonumber(snapshot.stockOccupied) or 0
	local capacity = tonumber(snapshot.stockCapacity) or 0
	local free = tonumber(snapshot.stockFree) or 0
	stockLabel.Text = ("STOCK  %d / %d   •   %d FREE"):format(occupied, capacity, free)
	passiveLabel.Text = "PASSIVE INCOME  " .. NumberFormat.Rate(tonumber(snapshot.totalPassiveRate) or 0)
end

function Controller.Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "OneTripEconomyUI"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 20
	gui.Parent = player:WaitForChild("PlayerGui")

	local summary = Instance.new("Frame")
	summary.Name = "EconomySummary"
	summary.Size = UDim2.fromOffset(330, 112)
	summary.Position = UDim2.new(1, -348, 0, 18)
	summary.BackgroundColor3 = Color3.fromRGB(24, 27, 32)
	summary.BackgroundTransparency = 0.10
	summary.BorderSizePixel = 0
	summary.Parent = gui
	roundCorner(summary, 9)

	cashLabel = makeText(summary, "Cash", "CASH  $0", UDim2.new(1, -20, 0, 28), UDim2.fromOffset(10, 7), 21)
	cashLabel.TextXAlignment = Enum.TextXAlignment.Left
	cashLabel.TextColor3 = Color3.fromRGB(130, 238, 160)
	stockLabel = makeText(summary, "Stock", "STOCK  0 / 3   •   3 FREE", UDim2.new(1, -20, 0, 20), UDim2.fromOffset(10, 39), 13)
	stockLabel.TextXAlignment = Enum.TextXAlignment.Left
	passiveLabel = makeText(summary, "Passive", "PASSIVE INCOME  +$0/min", UDim2.new(1, -20, 0, 20), UDim2.fromOffset(10, 61), 13)
	passiveLabel.TextXAlignment = Enum.TextXAlignment.Left
	passiveLabel.TextColor3 = Color3.fromRGB(128, 232, 164)
	manageButton = makeButton(summary, "Manage", "MANAGE STOCK", UDim2.new(1, -20, 0, 24), UDim2.fromOffset(10, 84), Color3.fromRGB(73, 88, 111))
	manageButton.TextSize = 12

	reviewFrame = Instance.new("Frame")
	reviewFrame.Name = "DeliveryReview"
	reviewFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	reviewFrame.Position = UDim2.fromScale(0.5, 0.53)
	reviewFrame.Size = UDim2.fromScale(0.86, 0.78)
	reviewFrame.BackgroundColor3 = Color3.fromRGB(23, 26, 31)
	reviewFrame.BackgroundTransparency = 0.03
	reviewFrame.BorderSizePixel = 0
	reviewFrame.Visible = false
	reviewFrame.Parent = gui
	roundCorner(reviewFrame, 12)
	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MinSize = Vector2.new(300, 330)
	sizeConstraint.MaxSize = Vector2.new(680, 540)
	sizeConstraint.Parent = reviewFrame

	reviewTitle = makeText(reviewFrame, "Title", "DELIVERY COMPLETE", UDim2.new(1, -24, 0, 34), UDim2.fromOffset(12, 10), 22)
	reviewTitle.TextXAlignment = Enum.TextXAlignment.Left
	reviewStockLabel = makeText(reviewFrame, "StockInfo", "STOCK: 0 / 3", UDim2.new(1, -24, 0, 24), UDim2.fromOffset(12, 44), 13)
	reviewStockLabel.TextXAlignment = Enum.TextXAlignment.Left
	reviewStockLabel.TextColor3 = Color3.fromRGB(183, 205, 225)

	itemList = Instance.new("ScrollingFrame")
	itemList.Name = "Items"
	itemList.Size = UDim2.new(1, -24, 1, -188)
	itemList.Position = UDim2.fromOffset(12, 74)
	itemList.BackgroundColor3 = Color3.fromRGB(31, 35, 42)
	itemList.BackgroundTransparency = 0.18
	itemList.BorderSizePixel = 0
	itemList.ScrollBarThickness = 6
	itemList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	itemList.CanvasSize = UDim2.new()
	itemList.Parent = reviewFrame
	roundCorner(itemList, 8)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.PaddingLeft = UDim.new(0, 6)
	padding.Parent = itemList
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.Parent = itemList

	keepSelectedButton = makeButton(reviewFrame, "KeepSelected", "SELECT ITEMS TO KEEP", UDim2.new(0.48, -8, 0, 48), UDim2.new(0, 12, 1, -104), Color3.fromRGB(83, 91, 104))
	sellRestButton = makeButton(reviewFrame, "SellRest", "SELL REST", UDim2.new(0.52, -16, 0, 48), UDim2.new(0.48, 8, 1, -104), Color3.fromRGB(173, 119, 59))
	sellAllButton = makeButton(reviewFrame, "SellAll", "SELL ALL — START NEXT RUN", UDim2.new(1, -24, 0, 44), UDim2.new(0, 12, 1, -50), Color3.fromRGB(80, 126, 171))

	manageFrame = Instance.new("Frame")
	manageFrame.Name = "ManageStock"
	manageFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	manageFrame.Position = UDim2.fromScale(0.5, 0.5)
	manageFrame.Size = UDim2.fromOffset(470, 390)
	manageFrame.BackgroundColor3 = Color3.fromRGB(23, 26, 31)
	manageFrame.BorderSizePixel = 0
	manageFrame.Visible = false
	manageFrame.Parent = gui
	roundCorner(manageFrame, 12)
	makeText(manageFrame, "Title", "MANAGE STOCK", UDim2.new(1, -90, 0, 36), UDim2.fromOffset(14, 10), 21)
	local closeManage = makeButton(manageFrame, "Close", "CLOSE", UDim2.fromOffset(70, 32), UDim2.new(1, -84, 0, 10), Color3.fromRGB(92, 99, 112))
	closeManage.TextSize = 12
	manageList = Instance.new("ScrollingFrame")
	manageList.Name = "StockList"
	manageList.Size = UDim2.new(1, -28, 1, -64)
	manageList.Position = UDim2.fromOffset(14, 52)
	manageList.BackgroundColor3 = Color3.fromRGB(31, 35, 42)
	manageList.BackgroundTransparency = 0.14
	manageList.BorderSizePixel = 0
	manageList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	manageList.CanvasSize = UDim2.new()
	manageList.ScrollBarThickness = 6
	manageList.Parent = manageFrame
	roundCorner(manageList, 8)
	local managePadding = Instance.new("UIPadding")
	managePadding.PaddingTop = UDim.new(0, 6)
	managePadding.PaddingLeft = UDim.new(0, 6)
	managePadding.PaddingBottom = UDim.new(0, 6)
	managePadding.Parent = manageList
	local manageLayout = Instance.new("UIListLayout")
	manageLayout.Padding = UDim.new(0, 6)
	manageLayout.Parent = manageList

	keepSelectedButton.Activated:Connect(function()
		if not keepSelectedButton.Active then return end
		local ids = {}
		for id, enabled in selected do
			if enabled then table.insert(ids, id) end
		end
		sendReviewAction("KeepSelected", { itemIds = ids })
	end)
	sellRestButton.Activated:Connect(function() sendReviewAction("SellRest", nil) end)
	sellAllButton.Activated:Connect(function() sendReviewAction("SellAll", nil) end)
	manageButton.Activated:Connect(function()
		manageFrame.Visible = not manageFrame.Visible
		if latestSnapshot then rebuildManage(latestSnapshot) end
	end)
	closeManage.Activated:Connect(function() manageFrame.Visible = false end)

	local remoteFolder = ReplicatedStorage:WaitForChild(RemoteNames.Folder)
	local economyState = remoteFolder:WaitForChild(RemoteNames.EconomyState) :: RemoteEvent
	economyAction = remoteFolder:WaitForChild(RemoteNames.EconomyAction) :: RemoteEvent
	economyState.OnClientEvent:Connect(function(snapshot)
		if typeof(snapshot) ~= "table" then return end
		latestSnapshot = snapshot
		refreshSummary(snapshot)
		rebuildReview(snapshot)
		if manageFrame.Visible then rebuildManage(snapshot) end
	end)
	economyAction:FireServer("RequestState", {})
end

return Controller
