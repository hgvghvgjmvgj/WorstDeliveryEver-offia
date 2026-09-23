--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local Controller = {}

local player = Players.LocalPlayer
local economyAction: RemoteEvent
local latestSnapshot: any = nil
local selected: {[string]: boolean} = {}
local activeReviewId: string? = nil
local manageOpen = false

local cashLabel: TextLabel
local passiveLabel: TextLabel
local stockLabel: TextLabel
local summaryManageButton: TextButton

local reviewFrame: Frame
local reviewTitle: TextLabel
local reviewStockLabel: TextLabel
local itemList: ScrollingFrame
local keepSelectedButton: TextButton
local sellRestButton: TextButton
local sellAllButton: TextButton
local reviewManageButton: TextButton

local manageFrame: Frame
local manageTitle: TextLabel
local managePassiveLabel: TextLabel
local stockList: ScrollingFrame

local function roundCorner(instance: GuiObject, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local function makeText(
	parent: Instance,
	name: string,
	text: string,
	size: UDim2,
	position: UDim2,
	textSize: number
): TextLabel
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

local function makeButton(
	parent: Instance,
	name: string,
	text: string,
	size: UDim2,
	position: UDim2,
	background: Color3
): TextButton
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

local function clearNamedRows(parent: Instance, rowName: string)
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
		clearNamedRows(itemList, "ReviewItem")
		return
	end

	if manageOpen then
		reviewFrame.Visible = false
		return
	end

	reviewFrame.Visible = true
	local items = if typeof(snapshot.reviewItems) == "table" then snapshot.reviewItems else {}
	local free = tonumber(snapshot.stockFree) or 0
	local capacity = tonumber(snapshot.stockCapacity) or 0
	local occupied = tonumber(snapshot.stockOccupied) or 0

	reviewTitle.Text = ("DELIVERY COMPLETE  •  %d ITEMS"):format(#items)
	reviewStockLabel.Text = ("STOCK: %d / %d  •  %d FREE"):format(
		occupied,
		capacity,
		free
	)

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

	clearNamedRows(itemList, "ReviewItem")

	for _, item in items do
		if typeof(item) == "table" and typeof(item.id) == "string" then
			local id = item.id
			local name = tostring(item.name or item.itemId or "ITEM")
			local sell = tonumber(item.sellValue) or 0
			local passive = tonumber(item.passiveRate) or 0

			local row = Instance.new("TextButton")
			row.Name = "ReviewItem"
			row.Size = UDim2.new(1, -12, 0, 62)
			row.BackgroundColor3 = if selected[id]
				then Color3.fromRGB(57, 116, 84)
				else Color3.fromRGB(42, 47, 56)
			row.BorderSizePixel = 0
			row.AutoButtonColor = true
			row.Font = Enum.Font.GothamBold
			row.TextColor3 = Color3.fromRGB(243, 245, 248)
			row.TextSize = 15
			row.TextWrapped = true
			row.TextXAlignment = Enum.TextXAlignment.Left
			row.Text = string.format(
				"  %s%s\n  SELL $%d NOW    •    KEEP +$%g/min",
				if selected[id] then "✓ KEEP  " else "",
				string.upper(name),
				sell,
				passive
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

local function refreshAlwaysVisible(snapshot)
	cashLabel.Text = ("CASH  $%d"):format(tonumber(snapshot.cash) or 0)
	passiveLabel.Text = ("PASSIVE INCOME  +$%g/min"):format(
		tonumber(snapshot.totalPassiveRate) or 0
	)

	local occupied = tonumber(snapshot.stockOccupied) or 0
	local capacity = tonumber(snapshot.stockCapacity) or 0
	local free = tonumber(snapshot.stockFree) or 0
	stockLabel.Text = ("STOCK  %d / %d   •   %d FREE"):format(occupied, capacity, free)
end

local function rebuildStockManagement(snapshot)
	if not manageOpen then
		manageFrame.Visible = false
		return
	end

	manageFrame.Visible = true
	local capacity = tonumber(snapshot.stockCapacity) or 0
	local totalPassive = tonumber(snapshot.totalPassiveRate) or 0
	manageTitle.Text = ("CURRENT STOCK  •  %d SLOTS"):format(capacity)
	managePassiveLabel.Text = ("TOTAL PASSIVE INCOME  +$%g/min"):format(totalPassive)

	local bySlot: {[number]: any} = {}
	local stockItems = if typeof(snapshot.stockItems) == "table" then snapshot.stockItems else {}
	for _, item in stockItems do
		if typeof(item) == "table" and typeof(item.slotIndex) == "number" then
			bySlot[item.slotIndex] = item
		end
	end

	clearNamedRows(stockList, "StockRow")

	for slotIndex = 1, capacity do
		local item = bySlot[slotIndex]
		local row = Instance.new("TextButton")
		row.Name = "StockRow"
		row.Size = UDim2.new(1, -12, 0, 64)
		row.BorderSizePixel = 0
		row.Font = Enum.Font.GothamBold
		row.TextColor3 = Color3.fromRGB(243, 245, 248)
		row.TextSize = 15
		row.TextWrapped = true
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.Parent = stockList
		roundCorner(row, 7)

		if item then
			local name = string.upper(tostring(item.name or item.itemId or "ITEM"))
			local passive = tonumber(item.passiveRate) or 0
			local sell = tonumber(item.sellValue) or 0
			local stockId = tostring(item.stockId or "")

			row.BackgroundColor3 = Color3.fromRGB(62, 78, 70)
			row.AutoButtonColor = true
			row.Active = true
			row.Text = ("  SLOT %d  —  %s\n  +$%g/min     •     SELL STOCK FOR $%d"):format(
				slotIndex,
				name,
				passive,
				sell
			)
			row.Activated:Connect(function()
				if stockId ~= "" then
					economyAction:FireServer("SellStock", {
						slotIndex = slotIndex,
						stockId = stockId,
					})
				end
			end)
		else
			row.BackgroundColor3 = Color3.fromRGB(42, 47, 56)
			row.AutoButtonColor = false
			row.Active = false
			row.Text = ("  SLOT %d  —  EMPTY\n  Available for a kept delivery item"):format(slotIndex)
		end
	end
end

local function sendReviewAction(action: string, extra: {[string]: any}?)
	if not latestSnapshot or typeof(latestSnapshot.reviewId) ~= "string" then
		return
	end

	local payload: {[string]: any} = {
		reviewId = latestSnapshot.reviewId,
	}
	if extra then
		for key, value in extra do
			payload[key] = value
		end
	end
	economyAction:FireServer(action, payload)
end

local function openStockManagement()
	manageOpen = true
	reviewFrame.Visible = false
	if latestSnapshot then
		rebuildStockManagement(latestSnapshot)
	end
end

local function closeStockManagement()
	manageOpen = false
	manageFrame.Visible = false
	if latestSnapshot then
		rebuildReview(latestSnapshot)
	end
end

function Controller.Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "OneTripEconomyUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.DisplayOrder = 20
	gui.Parent = player:WaitForChild("PlayerGui")

	local summary = Instance.new("Frame")
	summary.Name = "EconomySummary"
	summary.Size = UDim2.fromOffset(330, 126)
	summary.Position = UDim2.new(1, -348, 0, 18)
	summary.BackgroundColor3 = Color3.fromRGB(24, 27, 32)
	summary.BackgroundTransparency = 0.10
	summary.BorderSizePixel = 0
	summary.Parent = gui
	roundCorner(summary, 9)

	cashLabel = makeText(
		summary,
		"Cash",
		"CASH  $0",
		UDim2.new(1, -20, 0, 28),
		UDim2.fromOffset(10, 7),
		21
	)
	cashLabel.TextXAlignment = Enum.TextXAlignment.Left
	cashLabel.TextColor3 = Color3.fromRGB(130, 238, 160)

	passiveLabel = makeText(
		summary,
		"Passive",
		"PASSIVE INCOME  +$0/min",
		UDim2.new(1, -20, 0, 22),
		UDim2.fromOffset(10, 36),
		14
	)
	passiveLabel.TextXAlignment = Enum.TextXAlignment.Left
	passiveLabel.TextColor3 = Color3.fromRGB(128, 212, 232)

	stockLabel = makeText(
		summary,
		"Stock",
		"STOCK  0 / 3   •   3 FREE",
		UDim2.new(1, -20, 0, 20),
		UDim2.fromOffset(10, 61),
		13
	)
	stockLabel.TextXAlignment = Enum.TextXAlignment.Left

	summaryManageButton = makeButton(
		summary,
		"ManageStock",
		"MANAGE STOCK",
		UDim2.new(1, -20, 0, 30),
		UDim2.fromOffset(10, 88),
		Color3.fromRGB(72, 91, 119)
	)
	summaryManageButton.TextSize = 13
	summaryManageButton.Activated:Connect(openStockManagement)

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

	local reviewConstraint = Instance.new("UISizeConstraint")
	reviewConstraint.MinSize = Vector2.new(300, 330)
	reviewConstraint.MaxSize = Vector2.new(650, 520)
	reviewConstraint.Parent = reviewFrame

	reviewTitle = makeText(
		reviewFrame,
		"Title",
		"DELIVERY COMPLETE",
		UDim2.new(1, -24, 0, 34),
		UDim2.fromOffset(12, 10),
		22
	)
	reviewTitle.TextXAlignment = Enum.TextXAlignment.Left

	reviewStockLabel = makeText(
		reviewFrame,
		"StockInfo",
		"STOCK: 0 / 3",
		UDim2.new(0.60, -12, 0, 24),
		UDim2.fromOffset(12, 44),
		13
	)
	reviewStockLabel.TextXAlignment = Enum.TextXAlignment.Left
	reviewStockLabel.TextColor3 = Color3.fromRGB(183, 205, 225)

	reviewManageButton = makeButton(
		reviewFrame,
		"ManageStock",
		"MANAGE STOCK",
		UDim2.new(0.36, -12, 0, 28),
		UDim2.new(0.64, 0, 0, 42),
		Color3.fromRGB(72, 91, 119)
	)
	reviewManageButton.TextSize = 12
	reviewManageButton.Activated:Connect(openStockManagement)

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

	local listPadding = Instance.new("UIPadding")
	listPadding.PaddingTop = UDim.new(0, 6)
	listPadding.PaddingBottom = UDim.new(0, 6)
	listPadding.PaddingLeft = UDim.new(0, 6)
	listPadding.Parent = itemList

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = itemList

	keepSelectedButton = makeButton(
		reviewFrame,
		"KeepSelected",
		"SELECT ITEMS TO KEEP",
		UDim2.new(0.48, -8, 0, 48),
		UDim2.new(0, 12, 1, -104),
		Color3.fromRGB(83, 91, 104)
	)

	sellRestButton = makeButton(
		reviewFrame,
		"SellRest",
		"SELL REST",
		UDim2.new(0.52, -16, 0, 48),
		UDim2.new(0.48, 8, 1, -104),
		Color3.fromRGB(173, 119, 59)
	)

	sellAllButton = makeButton(
		reviewFrame,
		"SellAll",
		"SELL ALL — START NEXT RUN",
		UDim2.new(1, -24, 0, 44),
		UDim2.new(0, 12, 1, -50),
		Color3.fromRGB(80, 126, 171)
	)

	keepSelectedButton.Activated:Connect(function()
		if not keepSelectedButton.Active then
			return
		end
		local ids = {}
		for id, enabled in selected do
			if enabled then
				table.insert(ids, id)
			end
		end
		sendReviewAction("KeepSelected", { itemIds = ids })
	end)

	sellRestButton.Activated:Connect(function()
		sendReviewAction("SellRest", nil)
	end)

	sellAllButton.Activated:Connect(function()
		sendReviewAction("SellAll", nil)
	end)

	manageFrame = Instance.new("Frame")
	manageFrame.Name = "StockManagement"
	manageFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	manageFrame.Position = UDim2.fromScale(0.5, 0.53)
	manageFrame.Size = UDim2.fromScale(0.82, 0.68)
	manageFrame.BackgroundColor3 = Color3.fromRGB(23, 26, 31)
	manageFrame.BackgroundTransparency = 0.02
	manageFrame.BorderSizePixel = 0
	manageFrame.Visible = false
	manageFrame.Parent = gui
	roundCorner(manageFrame, 12)

	local manageConstraint = Instance.new("UISizeConstraint")
	manageConstraint.MinSize = Vector2.new(300, 300)
	manageConstraint.MaxSize = Vector2.new(570, 450)
	manageConstraint.Parent = manageFrame

	manageTitle = makeText(
		manageFrame,
		"Title",
		"CURRENT STOCK",
		UDim2.new(1, -110, 0, 34),
		UDim2.fromOffset(12, 10),
		22
	)
	manageTitle.TextXAlignment = Enum.TextXAlignment.Left

	local closeManageButton = makeButton(
		manageFrame,
		"Close",
		"BACK",
		UDim2.fromOffset(82, 32),
		UDim2.new(1, -94, 0, 10),
		Color3.fromRGB(82, 89, 101)
	)
	closeManageButton.TextSize = 13
	closeManageButton.Activated:Connect(closeStockManagement)

	managePassiveLabel = makeText(
		manageFrame,
		"Passive",
		"TOTAL PASSIVE INCOME  +$0/min",
		UDim2.new(1, -24, 0, 24),
		UDim2.fromOffset(12, 50),
		14
	)
	managePassiveLabel.TextXAlignment = Enum.TextXAlignment.Left
	managePassiveLabel.TextColor3 = Color3.fromRGB(128, 212, 232)

	stockList = Instance.new("ScrollingFrame")
	stockList.Name = "StockItems"
	stockList.Size = UDim2.new(1, -24, 1, -92)
	stockList.Position = UDim2.fromOffset(12, 80)
	stockList.BackgroundColor3 = Color3.fromRGB(31, 35, 42)
	stockList.BackgroundTransparency = 0.18
	stockList.BorderSizePixel = 0
	stockList.ScrollBarThickness = 6
	stockList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	stockList.CanvasSize = UDim2.new()
	stockList.Parent = manageFrame
	roundCorner(stockList, 8)

	local stockPadding = Instance.new("UIPadding")
	stockPadding.PaddingTop = UDim.new(0, 6)
	stockPadding.PaddingBottom = UDim.new(0, 6)
	stockPadding.PaddingLeft = UDim.new(0, 6)
	stockPadding.Parent = stockList

	local stockLayout = Instance.new("UIListLayout")
	stockLayout.Padding = UDim.new(0, 6)
	stockLayout.SortOrder = Enum.SortOrder.LayoutOrder
	stockLayout.Parent = stockList

	local remoteFolder = ReplicatedStorage:WaitForChild(RemoteNames.Folder)
	local economyState = remoteFolder:WaitForChild(RemoteNames.EconomyState) :: RemoteEvent
	economyAction = remoteFolder:WaitForChild(RemoteNames.EconomyAction) :: RemoteEvent

	economyState.OnClientEvent:Connect(function(snapshot)
		if typeof(snapshot) ~= "table" then
			return
		end
		latestSnapshot = snapshot
		refreshAlwaysVisible(snapshot)
		if manageOpen then
			rebuildStockManagement(snapshot)
		else
			rebuildReview(snapshot)
		end
	end)

	-- Request current server state after the LocalScript has connected its listener.
	economyAction:FireServer("RequestState", {})
end

return Controller
