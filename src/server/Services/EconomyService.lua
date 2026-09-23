--!strict

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local EconomyConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("EconomyConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local PrototypeVisualConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PrototypeVisualConfig"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local BayService = require(script.Parent:WaitForChild("BayService"))
local RemoteService = require(script.Parent:WaitForChild("RemoteService"))

local EconomyService = {}

type DeliveredEntry = {
	ReviewItemId: string,
	ItemId: string,
	State: string,
}

type Listing = {
	ListingId: string,
	ItemId: string,
	SourceReviewItemId: string,
	SlotIndex: number,
	ListingStartUnix: number,
	SaleDurationSeconds: number,
	ExpectedPayout: number,
	SaleReadyServerTime: number,
}

type EconomyState = {
	Cash: number,
	ReviewId: string?,
	Delivered: {DeliveredEntry},
	Listings: {[number]: Listing},
	LastActionAt: number,
	Bay: Model?,
}

local states: {[Player]: EconomyState} = {}
local economyStateRemote: RemoteEvent
local economyActionRemote: RemoteEvent
local noticeRemote: RemoteEvent
local heartbeatAccumulator = 0

local function quickSellValue(itemId: string): number
	local definition = ItemConfig[itemId]
	if not definition then
		return 0
	end
	return math.max(0, math.floor(definition.Value + 0.5))
end

local function economyFor(itemId: string)
	return EconomyConfig.Items[itemId]
end

local function stockPayout(itemId: string): number
	local tuning = economyFor(itemId)
	if not tuning then
		return quickSellValue(itemId)
	end
	return math.max(0, math.floor(quickSellValue(itemId) * tuning.StockMultiplier + 0.5))
end

local function baseSaleDuration(itemId: string): number
	local tuning = economyFor(itemId)
	if not tuning then
		return 45
	end
	return math.max(1, tuning.BaseSaleDuration)
end

local function stockCapacity(player: Player): number
	local raw = player:GetAttribute(EconomyConfig.StockSlotCapacityAttribute)
	if typeof(raw) ~= "number" then
		return EconomyConfig.DefaultStockSlots
	end

	local rounded = math.floor(raw + 0.5)
	for _, allowed in EconomyConfig.AllowedDevStockSlots do
		if rounded == allowed then
			return math.min(allowed, EconomyConfig.MaxStockSlots)
		end
	end

	return EconomyConfig.DefaultStockSlots
end

local function saleSpeedMultiplier(player: Player): number
	local raw = player:GetAttribute(EconomyConfig.SaleSpeedAttribute)
	if typeof(raw) ~= "number" then
		return EconomyConfig.DefaultSaleSpeedMultiplier
	end
	return math.clamp(
		raw,
		EconomyConfig.MinSaleSpeedMultiplier,
		EconomyConfig.MaxSaleSpeedMultiplier
	)
end

local function occupiedCount(state: EconomyState): number
	local count = 0
	for _ in state.Listings do
		count += 1
	end
	return count
end

local function ensureSlotLabel(marker: BasePart, index: number): TextLabel
	local existingGui = marker:FindFirstChild("StockSlotLabel")
	local gui: BillboardGui
	if existingGui and existingGui:IsA("BillboardGui") then
		gui = existingGui
	else
		gui = Instance.new("BillboardGui")
		gui.Name = "StockSlotLabel"
		gui.Adornee = marker
		gui.Size = UDim2.fromOffset(130, 38)
		gui.StudsOffset = Vector3.new(0, 2.5, 0)
		gui.AlwaysOnTop = true
		gui.MaxDistance = 45
		gui.Parent = marker
	end

	local existingText = gui:FindFirstChild("Text")
	local label: TextLabel
	if existingText and existingText:IsA("TextLabel") then
		label = existingText
	else
		label = Instance.new("TextLabel")
		label.Name = "Text"
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1, 1)
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.TextWrapped = true
		label.TextStrokeTransparency = 0.35
		label.Parent = gui
	end

	label.Text = ("STOCK %d\nFREE"):format(index)
	return label
end

local function displayFolderFor(state: EconomyState): Folder?
	local bay = state.Bay
	if not bay or not bay.Parent then
		return nil
	end

	local existing = bay:FindFirstChild("StockDisplays")
	if existing and existing:IsA("Folder") then
		return existing
	end

	local folder = Instance.new("Folder")
	folder.Name = "StockDisplays"
	folder.Parent = bay
	return folder
end

local function destroyDisplay(state: EconomyState, slotIndex: number)
	local folder = displayFolderFor(state)
	if not folder then
		return
	end
	local existing = folder:FindFirstChild(("StockDisplay%02d"):format(slotIndex))
	if existing then
		existing:Destroy()
	end
end

local function createDisplay(state: EconomyState, listing: Listing)
	local bay = state.Bay
	local folder = displayFolderFor(state)
	if not bay or not folder then
		return
	end

	local slots = bay:FindFirstChild("StockSlots")
	local marker = slots and slots:FindFirstChild(("StockSlot%02d"):format(listing.SlotIndex))
	if not marker or not marker:IsA("BasePart") then
		return
	end

	destroyDisplay(state, listing.SlotIndex)

	local visual = PrototypeVisualConfig.Items[listing.ItemId]
	local definition = ItemConfig[listing.ItemId]
	if not visual or not definition then
		return
	end

	local part = Instance.new("Part")
	part.Name = ("StockDisplay%02d"):format(listing.SlotIndex)
	part.Size = visual.Size
	part.CFrame = marker.CFrame * CFrame.new(0, visual.Size.Y * 0.5 + 0.15, 0)
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = visual.Color
	part:SetAttribute("ItemId", listing.ItemId)
	part:SetAttribute("ListingId", listing.ListingId)
	part:SetAttribute("StockSlotIndex", listing.SlotIndex)
	part:SetAttribute("PresentationOnly", true)
	part.Parent = folder

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "StockedLabel"
	billboard.Adornee = part
	billboard.Size = UDim2.fromOffset(150, 38)
	billboard.StudsOffset = Vector3.new(0, visual.Size.Y * 0.5 + 1.15, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 48
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = string.format("%s\nLISTED", string.upper(definition.Name))
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(128, 232, 164)
	label.TextStrokeTransparency = 0.3
	label.Parent = billboard
end

local function refreshSlots(player: Player, state: EconomyState)
	local bay = state.Bay
	if not bay or not bay.Parent then
		state.Bay = BayService.GetBayModel(player)
		bay = state.Bay
	end
	if not bay then
		return
	end

	local slots = bay:FindFirstChild("StockSlots")
	if not slots then
		return
	end

	local capacity = stockCapacity(player)
	bay:SetAttribute("ActiveStockSlots", capacity)

	for index = 1, EconomyConfig.MaxStockSlots do
		local marker = slots:FindFirstChild(("StockSlot%02d"):format(index))
		if marker and marker:IsA("BasePart") then
			local active = index <= capacity
			local listing = state.Listings[index]
			marker.Transparency = if active then 0.45 else 1
			marker.CanCollide = false
			marker.CanTouch = false
			marker.CanQuery = false
			marker:SetAttribute("StockActive", active)
			marker:SetAttribute("Occupied", listing ~= nil)
			marker:SetAttribute("ListingId", if listing then listing.ListingId else "")

			local label = ensureSlotLabel(marker, index)
			local gui = label.Parent
			if gui and gui:IsA("BillboardGui") then
				gui.Enabled = active
			end

			if active then
				if listing then
					local definition = ItemConfig[listing.ItemId]
					label.Text = ("STOCK %d\n%s"):format(
						index,
						if definition then string.upper(definition.Name) else "LISTED"
					)
					label.TextColor3 = Color3.fromRGB(128, 232, 164)
				else
					label.Text = ("STOCK %d\nFREE"):format(index)
					label.TextColor3 = Color3.fromRGB(205, 224, 241)
				end
			end
		end
	end
end

local function snapshotFor(player: Player, state: EconomyState)
	local reviewItems = {}
	for _, entry in state.Delivered do
		if entry.State == "Delivered" then
			local definition = ItemConfig[entry.ItemId]
			if definition then
				table.insert(reviewItems, {
					id = entry.ReviewItemId,
					itemId = entry.ItemId,
					name = definition.Name,
					quickSell = quickSellValue(entry.ItemId),
					stockPayout = stockPayout(entry.ItemId),
					buyerEta = math.max(1, math.floor(baseSaleDuration(entry.ItemId) / saleSpeedMultiplier(player) + 0.5)),
				})
			end
		end
	end

	local listings = {}
	local nowServer = Workspace:GetServerTimeNow()
	for slotIndex, listing in state.Listings do
		local definition = ItemConfig[listing.ItemId]
		table.insert(listings, {
			slotIndex = slotIndex,
			listingId = listing.ListingId,
			itemId = listing.ItemId,
			name = if definition then definition.Name else listing.ItemId,
			payout = listing.ExpectedPayout,
			remaining = math.max(0, math.ceil(listing.SaleReadyServerTime - nowServer)),
		})
	end
	table.sort(listings, function(a, b)
		return a.slotIndex < b.slotIndex
	end)

	local capacity = stockCapacity(player)
	local occupied = occupiedCount(state)

	return {
		cash = state.Cash,
		reviewId = state.ReviewId,
		reviewItems = reviewItems,
		stockCapacity = capacity,
		stockOccupied = occupied,
		stockFree = math.max(0, capacity - occupied),
		listings = listings,
	}
end

local function sendState(player: Player, state: EconomyState)
	if player.Parent then
		economyStateRemote:FireClient(player, snapshotFor(player, state))
	end
end

local function freeSlots(player: Player, state: EconomyState): {number}
	local result = {}
	local capacity = stockCapacity(player)
	for index = 1, capacity do
		if not state.Listings[index] then
			table.insert(result, index)
		end
	end
	return result
end

local function findDelivered(state: EconomyState, reviewItemId: string): (DeliveredEntry?, number?)
	for index, entry in state.Delivered do
		if entry.ReviewItemId == reviewItemId and entry.State == "Delivered" then
			return entry, index
		end
	end
	return nil, nil
end

local function closeReviewIfEmpty(state: EconomyState)
	if #state.Delivered == 0 then
		state.ReviewId = nil
	end
end

local function quickSellEntries(player: Player, state: EconomyState, ids: {string}?): number
	local requested: {[string]: boolean}? = nil
	if ids then
		requested = {}
		for _, id in ids do
			requested[id] = true
		end
	end

	local payout = 0
	for index = #state.Delivered, 1, -1 do
		local entry = state.Delivered[index]
		if entry.State == "Delivered" and (not requested or requested[entry.ReviewItemId]) then
			entry.State = "Sold"
			payout += quickSellValue(entry.ItemId)
			table.remove(state.Delivered, index)
		end
	end

	if payout > 0 then
		state.Cash += payout
	end
	closeReviewIfEmpty(state)
	return payout
end

local function startListing(player: Player, state: EconomyState, entry: DeliveredEntry, slotIndex: number)
	local speed = saleSpeedMultiplier(player)
	local effectiveDuration = baseSaleDuration(entry.ItemId) / speed
	local listing: Listing = {
		ListingId = HttpService:GenerateGUID(false),
		ItemId = entry.ItemId,
		SourceReviewItemId = entry.ReviewItemId,
		SlotIndex = slotIndex,
		ListingStartUnix = os.time(),
		SaleDurationSeconds = effectiveDuration,
		ExpectedPayout = stockPayout(entry.ItemId),
		SaleReadyServerTime = Workspace:GetServerTimeNow() + effectiveDuration,
	}

	entry.State = "Stocked"
	state.Listings[slotIndex] = listing
	createDisplay(state, listing)
end

local function stockSelected(player: Player, state: EconomyState, ids: {string}): boolean
	local uniqueIds = {}
	local orderedIds = {}
	for _, id in ids do
		if typeof(id) == "string" and not uniqueIds[id] then
			uniqueIds[id] = true
			table.insert(orderedIds, id)
		end
	end

	if #orderedIds == 0 then
		return false
	end

	local slots = freeSlots(player, state)
	if #orderedIds > #slots then
		noticeRemote:FireClient(player, "NOT ENOUGH STOCK SLOTS.")
		return false
	end

	-- Validate the whole request before mutating anything. No partial stock on an
	-- invalid/spammed payload.
	local validated: {{Entry: DeliveredEntry, Index: number}} = {}
	for _, id in orderedIds do
		local entry, index = findDelivered(state, id)
		if not entry or not index then
			return false
		end
		table.insert(validated, { Entry = entry, Index = index })
	end

	-- Start listings first, then remove those exact authoritative review entries
	-- back-to-front so indexes cannot shift underneath us.
	for listIndex, record in validated do
		startListing(player, state, record.Entry, slots[listIndex])
	end
	table.sort(validated, function(a, b)
		return a.Index > b.Index
	end)
	for _, record in validated do
		table.remove(state.Delivered, record.Index)
	end

	closeReviewIfEmpty(state)
	refreshSlots(player, state)
	return true
end

local function handleAction(player: Player, action: any, payload: any)
	if typeof(action) ~= "string" or typeof(payload) ~= "table" then
		return
	end

	local state = states[player]
	if not state then
		return
	end

	local now = os.clock()
	if now - state.LastActionAt < EconomyConfig.Review.ActionCooldownSeconds then
		return
	end
	state.LastActionAt = now

	local reviewId = payload.reviewId
	if typeof(reviewId) ~= "string" or not state.ReviewId or reviewId ~= state.ReviewId then
		return
	end

	if action == "QuickSellAll" or action == "QuickSellRest" then
		local payout = quickSellEntries(player, state, nil)
		if payout > 0 then
			noticeRemote:FireClient(player, ("QUICK SOLD! +$%d"):format(payout))
		end
		sendState(player, state)
	elseif action == "StockSelected" then
		local ids = payload.itemIds
		if typeof(ids) ~= "table" then
			return
		end

		local cleanIds = {}
		for _, id in ids do
			if typeof(id) == "string" then
				table.insert(cleanIds, id)
			end
		end

		if stockSelected(player, state, cleanIds) then
			noticeRemote:FireClient(player, "ITEMS LISTED. QUICK SELL THE REST OR KEEP CHOOSING.")
			sendState(player, state)
		end
	end
end

local function completeListing(player: Player, state: EconomyState, slotIndex: number, listing: Listing)
	if state.Listings[slotIndex] ~= listing then
		return
	end

	-- Remove authoritative Stock state before granting payout. Re-entrant/spammed
	-- completion can no longer find the listing and therefore cannot pay twice.
	state.Listings[slotIndex] = nil
	state.Cash += listing.ExpectedPayout
	destroyDisplay(state, slotIndex)
	refreshSlots(player, state)

	local definition = ItemConfig[listing.ItemId]
	local name = if definition then string.upper(definition.Name) else "ITEM"
	noticeRemote:FireClient(
		player,
		("%s SOLD! +$%d"):format(name, listing.ExpectedPayout)
	)
	sendState(player, state)
end

local function initializePlayer(player: Player)
	if states[player] then
		return
	end

	if player:GetAttribute(EconomyConfig.StockSlotCapacityAttribute) == nil then
		player:SetAttribute(EconomyConfig.StockSlotCapacityAttribute, EconomyConfig.DefaultStockSlots)
	end
	if player:GetAttribute(EconomyConfig.SaleSpeedAttribute) == nil then
		player:SetAttribute(EconomyConfig.SaleSpeedAttribute, EconomyConfig.DefaultSaleSpeedMultiplier)
	end

	local state: EconomyState = {
		Cash = EconomyConfig.StartingCash,
		ReviewId = nil,
		Delivered = {},
		Listings = {},
		LastActionAt = -math.huge,
		Bay = BayService.GetBayModel(player),
	}
	states[player] = state

	player:SetAttribute("Cash", state.Cash)

	player:GetAttributeChangedSignal(EconomyConfig.StockSlotCapacityAttribute):Connect(function()
		if states[player] == state then
			refreshSlots(player, state)
			sendState(player, state)
		end
	end)

	player:GetAttributeChangedSignal(EconomyConfig.SaleSpeedAttribute):Connect(function()
		if states[player] == state then
			sendState(player, state)
		end
	end)

	refreshSlots(player, state)
	sendState(player, state)
end

function EconomyService.CanAcceptDelivery(player: Player): boolean
	local state = states[player]
	return state ~= nil and state.ReviewId == nil
end

-- The carry rig is server-created and server-controlled. M3 reads those visual
-- item records immediately before CarryService authoritatively clears the load.
-- No client value or item identity is trusted. A future carry-state refactor can
-- replace this adapter without changing EconomyService's Delivered/Stock states.
function EconomyService.CaptureCarriedItems(player: Player): {string}
	local character = player.Character
	local rig = character and character:FindFirstChild("OneTripCarry")
	if not rig then
		return {}
	end

	local found = {}
	for _, descendant in rig:GetDescendants() do
		if descendant:IsA("BasePart") then
			local itemId, indexText = string.match(descendant.Name, "^Carry_(.+)_(%d+)$")
			local index = tonumber(indexText)
			if itemId and index and ItemConfig[itemId] then
				table.insert(found, { Index = index, ItemId = itemId })
			end
		end
	end

	table.sort(found, function(a, b)
		return a.Index < b.Index
	end)

	local items = {}
	for _, record in found do
		table.insert(items, record.ItemId)
	end
	return items
end

function EconomyService.BeginDelivery(player: Player, itemIds: {string}): boolean
	local state = states[player]
	if not state or state.ReviewId ~= nil or #itemIds == 0 then
		return false
	end

	local delivered = {}
	for _, itemId in itemIds do
		if typeof(itemId) ~= "string" or not ItemConfig[itemId] then
			return false
		end
		table.insert(delivered, {
			ReviewItemId = HttpService:GenerateGUID(false),
			ItemId = itemId,
			State = "Delivered",
		})
	end

	state.ReviewId = HttpService:GenerateGUID(false)
	state.Delivered = delivered
	noticeRemote:FireClient(player, "DELIVERY COMPLETE - QUICK SELL OR STOCK.")
	sendState(player, state)
	return true
end

function EconomyService.Start()
	economyStateRemote = RemoteService.Get(RemoteNames.EconomyState)
	economyActionRemote = RemoteService.Get(RemoteNames.EconomyAction)
	noticeRemote = RemoteService.Get(RemoteNames.PrototypeNotice)

	economyActionRemote.OnServerEvent:Connect(handleAction)

	Players.PlayerAdded:Connect(function(player)
		-- BayService is started before EconomyService and assigns synchronously.
		initializePlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		local state = states[player]
		if state then
			local folder = state.Bay and state.Bay:FindFirstChild("StockDisplays")
			if folder then
				folder:Destroy()
			end
		end
		states[player] = nil
	end)

	for _, player in Players:GetPlayers() do
		initializePlayer(player)
	end

	RunService.Heartbeat:Connect(function(dt)
		heartbeatAccumulator += dt
		if heartbeatAccumulator < 0.25 then
			return
		end
		heartbeatAccumulator = 0

		local nowServer = Workspace:GetServerTimeNow()
		for player, state in states do
			for slotIndex, listing in state.Listings do
				if nowServer >= listing.SaleReadyServerTime then
					completeListing(player, state, slotIndex, listing)
				end
			end
		end
	end)
end

return EconomyService
