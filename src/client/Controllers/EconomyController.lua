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
local snapshotReceivedAt = 0

local cashLabel: TextLabel
local stockLabel: TextLabel
local listingsLabel: TextLabel
local reviewFrame: Frame
local reviewTitle: TextLabel
local reviewStockLabel: TextLabel
local itemList: ScrollingFrame
local stockSelectedButton: TextButton
local quickSellRestButton: TextButton
local quickSellAllButton: TextButton

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

local function formatEta(seconds: number): string
	local value = math.max(0, math.floor(seconds + 0.5))
	if value >= 60 then
		local minutes = math.floor(value / 60)
		local remaining = value % 60
		if remaining == 0 then
			return ("~%dm"):format(minutes)
		end
		return ("~%dm %ds"):format(minutes, remaining)
	end
	return ("~%ds"):format(value)
end

local function clearItemRows()
	for _, child in itemList:GetChildren() do
		if child:IsA("GuiObject") and child.Name == "ReviewItem" then
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

local function refreshStockButton()
	if not latestSnapshot then
		return
	end

	local count = selectedCount()
	local free = tonumber(latestSnapshot.stockFree) or 0
	if count <= 0 then
		stockSelectedButton.Text = "SELECT ITEMS TO STOCK"
		stockSelectedButton.BackgroundColor3 = Color3.fromRGB(83, 91, 104)
		stockSelectedButton.Active = false
	elseif count > free then
		stockSelectedButton.Text = ("NEED %d FREE SLOTS"):format(count)
		stockSelectedButton.BackgroundColor3 = Color3.fromRGB(153, 76, 70)
		stockSelectedButton.Active = false
	else
		stockSelectedButton.Text = ("STOCK SELECTED (%d)"):format(count)
		stockSelectedButton.BackgroundColor3 = Color3.fromRGB(67, 142, 101)
		stockSelectedButton.Active = true
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
		clearItemRows()
		return
	end

	reviewFrame.Visible = true
	local items = if typeof(snapshot.reviewItems) == "table" then snapshot.reviewItems else {}
	local free = tonumber(snapshot.stockFree) or 0
	local capacity = tonumber(snapshot.stockCapacity) or 0
	local occupied = tonumber(snapshot.stockOccupied) or 0

	reviewTitle.Text = ("DELIVERY COMPLETE  •  %d ITEMS"):format(#items)
	reviewStockLabel.Text = ("AVAILABLE STOCK SLOTS: %d / %d  •  %d FREE"):format(
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

	clearItemRows()

	for _, item in items do
		if typeof(item) == "table" and typeof(item.id) == "string" then
			local id = item.id
			local name = tostring(item.name or item.itemId or "ITEM")
			local quick = tonumber(item.quickSell) or 0
			local stock = tonumber(item.stockPayout) or quick
			local eta = tonumber(item.buyerEta) or 0

			local row = Instance.new("TextButton")
			row.Name = "ReviewItem"
			row.Size = UDim2.new(1, -12, 0, 58)
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
				"  %s%s\n  $%d NOW    •    ~$%d STOCK    •    BUYER %s",
				if selected[id] then "✓ " else "",
				string.upper(name),
				quick,
				stock,
				formatEta(eta)
			)
			row.Parent = itemList
			roundCorner(row, 7)

			row.Activated:Connect(function()
				selected[id] = not selected[id]
				rebuildReview(latestSnapshot)
			end)
		end
	end

	refreshStockButton()
end

local function refreshAlwaysVisible(snapshot)
	cashLabel.Text = ("CASH  $%d"):format(tonumber(snapshot.cash) or 0)

	local occupied = tonumber(snapshot.stockOccupied) or 0
	local capacity = tonumber(snapshot.stockCapacity) or 0
	local free = tonumber(snapshot.stockFree) or 0
	stockLabel.Text = ("STOCK  %d / %d   •   %d FREE"):format(occupied, capacity, free)

	local listings = if typeof(snapshot.listings) == "table" then snapshot.listings else {}
	if #listings == 0 then
		listingsLabel.Text = "NO ACTIVE LISTINGS"
	else
		local pieces = {}
		local elapsed = os.clock() - snapshotReceivedAt
		for _, listing in listings do
			if typeof(listing) == "table" then
				local remaining = math.max(0, (tonumber(listing.remaining) or 0) - elapsed)
				table.insert(
					pieces,
					("%s %s"):format(
						string.upper(tostring(listing.name or "ITEM")),
						formatEta(remaining)
					)
				)
			end
		end
		listingsLabel.Text = table.concat(pieces, "   •   ")
	end
end

local function sendAction(action: string, extra: {[string]: any}?)
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

function Controller.Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "OneTripEconomyUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.DisplayOrder = 20
	gui.Parent = player:WaitForChild("PlayerGui")

	local summary = Instance.new("Frame")
	summary.Name = "EconomySummary"
	summary.Size = UDim2.fromOffset(310, 88)
	summary.Position = UDim2.new(1, -328, 0, 18)
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

	stockLabel = makeText(
		summary,
		"Stock",
		"STOCK  0 / 3   •   3 FREE",
		UDim2.new(1, -20, 0, 20),
		UDim2.fromOffset(10, 37),
		13
	)
	stockLabel.TextXAlignment = Enum.TextXAlignment.Left

	listingsLabel = makeText(
		summary,
		"Listings",
		"NO ACTIVE LISTINGS",
		UDim2.new(1, -20, 0, 20),
		UDim2.fromOffset(10, 60),
		11
	)
	listingsLabel.TextXAlignment = Enum.TextXAlignment.Left
	listingsLabel.TextColor3 = Color3.fromRGB(180, 189, 201)
	listingsLabel.TextTruncate = Enum.TextTruncate.AtEnd

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
	sizeConstraint.MaxSize = Vector2.new(650, 520)
	sizeConstraint.Parent = reviewFrame

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
		"AVAILABLE STOCK SLOTS: 0 / 3",
		UDim2.new(1, -24, 0, 24),
		UDim2.fromOffset(12, 44),
		13
	)
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

	local listPadding = Instance.new("UIPadding")
	listPadding.PaddingTop = UDim.new(0, 6)
	listPadding.PaddingBottom = UDim.new(0, 6)
	listPadding.PaddingLeft = UDim.new(0, 6)
	listPadding.Parent = itemList

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = itemList

	stockSelectedButton = makeButton(
		reviewFrame,
		"StockSelected",
		"SELECT ITEMS TO STOCK",
		UDim2.new(0.48, -8, 0, 48),
		UDim2.new(0, 12, 1, -104),
		Color3.fromRGB(83, 91, 104)
	)

	quickSellRestButton = makeButton(
		reviewFrame,
		"QuickSellRest",
		"QUICK SELL REST",
		UDim2.new(0.52, -16, 0, 48),
		UDim2.new(0.48, 8, 1, -104),
		Color3.fromRGB(173, 119, 59)
	)

	quickSellAllButton = makeButton(
		reviewFrame,
		"QuickSellAll",
		"QUICK SELL ALL — START NEXT RUN",
		UDim2.new(1, -24, 0, 44),
		UDim2.new(0, 12, 1, -50),
		Color3.fromRGB(80, 126, 171)
	)

	stockSelectedButton.Activated:Connect(function()
		if not stockSelectedButton.Active then
			return
		end
		local ids = {}
		for id, enabled in selected do
			if enabled then
				table.insert(ids, id)
			end
		end
		sendAction("StockSelected", { itemIds = ids })
	end)

	quickSellRestButton.Activated:Connect(function()
		sendAction("QuickSellRest", nil)
	end)

	quickSellAllButton.Activated:Connect(function()
		sendAction("QuickSellAll", nil)
	end)

	local remoteFolder = ReplicatedStorage:WaitForChild(RemoteNames.Folder)
	local economyState = remoteFolder:WaitForChild(RemoteNames.EconomyState) :: RemoteEvent
	economyAction = remoteFolder:WaitForChild(RemoteNames.EconomyAction) :: RemoteEvent

	economyState.OnClientEvent:Connect(function(snapshot)
		if typeof(snapshot) ~= "table" then
			return
		end
		latestSnapshot = snapshot
		snapshotReceivedAt = os.clock()
		refreshAlwaysVisible(snapshot)
		rebuildReview(snapshot)
	end)

	-- Harmless handshake so a LocalScript that connects after PlayerAdded still
	-- receives current Cash/listing state.
	economyAction:FireServer("RequestState", {})

	task.spawn(function()
		while gui.Parent do
			task.wait(1)
			if latestSnapshot then
				refreshAlwaysVisible(latestSnapshot)
			end
		end
	end)
end

return Controller
