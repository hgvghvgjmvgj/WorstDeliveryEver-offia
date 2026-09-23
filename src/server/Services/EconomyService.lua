--!strict

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local EconomyConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("EconomyConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local PrototypeVisualConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PrototypeVisualConfig"))
local NumberFormat = require(ReplicatedStorage:WaitForChild("NumberFormat"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local BayService = require(script.Parent:WaitForChild("BayService"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local RemoteService = require(script.Parent:WaitForChild("RemoteService"))

local EconomyService = {}

type DeliveredEntry = {
	ReviewItemId: string,
	ItemId: string,
	State: string,
}

type StockEntry = {
	StockId: string,
	ItemId: string,
	SourceReviewItemId: string,
	SlotIndex: number,
	StockedAtUnix: number,
	PassiveRatePerMinute: number,
	OriginalSellValue: number,
	SalvageValue: number,
}

type EconomyState = {
	ReviewId: string?,
	Delivered: {DeliveredEntry},
	Stock: {[number]: StockEntry},
	LastActionAt: number,
	Bay: Model?,
	PassiveRemainder: number,
	LastPassiveServerTime: number,
}

local states: {[Player]: EconomyState} = {}
local economyStateRemote: RemoteEvent
local economyActionRemote: RemoteEvent
local noticeRemote: RemoteEvent
local heartbeatAccumulator = 0

local function economyFor(itemId: string)
	return EconomyConfig.Items[itemId]
end

local function passiveRate(itemId: string): number
	local tuning = economyFor(itemId)
	if not tuning then
		return 0
	end
	return math.max(0, tuning.PassivePerMinute)
end

local function sellValue(itemId: string): number
	local tuning = economyFor(itemId)
	if tuning then
		return math.max(0, math.floor(tuning.PassivePerMinute * tuning.TargetBreakEvenMinutes + 0.5))
	end
	local definition = ItemConfig[itemId]
	return if definition then math.max(0, math.floor(definition.Value * 100 + 0.5)) else 0
end

local function salvageValue(itemId: string): number
	local tuning = economyFor(itemId)
	local ratio = EconomyConfig.DefaultSalvageRatio
	if tuning and typeof(tuning.SalvageRatio) == "number" then
		ratio = tuning.SalvageRatio
	end
	return math.max(0, math.floor(sellValue(itemId) * math.clamp(ratio, 0, 1) + 0.5))
end

local function stockCapacity(player: Player): number
	local raw = player:GetAttribute(EconomyConfig.StockSlotCapacityAttribute)
	if typeof(raw) ~= "number" then
		return EconomyConfig.DefaultStockSlots
	end
	return math.clamp(math.floor(raw + 0.5), 1, EconomyConfig.MaxStockSlots)
end

local function passiveIncomeMultiplier(player: Player): number
	local raw = player:GetAttribute(EconomyConfig.PassiveIncomeMultiplierAttribute)
	if typeof(raw) ~= "number" then
		return EconomyConfig.DefaultPassiveIncomeMultiplier
	end
	return math.clamp(raw, EconomyConfig.MinPassiveIncomeMultiplier, EconomyConfig.MaxPassiveIncomeMultiplier)
end

local function totalPassiveRate(state: EconomyState): number
	local total = 0
	for _, stock in state.Stock do
		total += stock.PassiveRatePerMinute
	end
	return total
end

local function occupiedCount(state: EconomyState): number
	local count = 0
	for _ in state.Stock do
		count += 1
	end
	return count
end

local function syncStockProfile(player: Player, state: EconomyState)
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return
	end
	local slots = {}
	for slotIndex, stock in state.Stock do
		slots[tostring(slotIndex)] = {
			StockId = stock.StockId,
			ItemId = stock.ItemId,
			SlotIndex = slotIndex,
			StockedAtUnix = stock.StockedAtUnix,
			PassiveRatePerMinute = stock.PassiveRatePerMinute,
			OriginalSellValue = stock.OriginalSellValue,
			SalvageValue = stock.SalvageValue,
		}
	end
	profile.Stock = { Slots = slots }
	profile.PassiveRemainder = state.PassiveRemainder
	PlayerDataService.MarkDirty(player)
end

local function settlePassive(player: Player, state: EconomyState, nowServer: number): number
	local elapsed = math.max(0, nowServer - state.LastPassiveServerTime)
	state.LastPassiveServerTime = nowServer
	if elapsed <= 0 then
		return 0
	end

	local rate = totalPassiveRate(state)
	if rate <= 0 then
		return 0
	end

	state.PassiveRemainder += (rate / 60) * elapsed * passiveIncomeMultiplier(player)
	local whole = math.floor(state.PassiveRemainder + 0.000001)
	if whole > 0 then
		state.PassiveRemainder -= whole
		PlayerDataService.AddCash(player, whole)
	end
	local profile = PlayerDataService.GetProfile(player)
	if profile then
		profile.PassiveRemainder = state.PassiveRemainder
		if whole > 0 then
			PlayerDataService.MarkDirty(player)
		end
	end
	return whole
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
		gui.Size = UDim2.fromOffset(155, 44)
		gui.StudsOffset = Vector3.new(0, 2.5, 0)
		gui.AlwaysOnTop = true
		gui.MaxDistance = 48
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
	local bay = state.Bay
	local folder = bay and bay:FindFirstChild("StockDisplays")
	local existing = folder and folder:FindFirstChild(("StockDisplay%02d"):format(slotIndex))
	if existing then
		existing:Destroy()
	end
end

local function createDisplay(state: EconomyState, stock: StockEntry)
	local bay = state.Bay
	local folder = displayFolderFor(state)
	if not bay or not folder then
		return
	end
	local slots = bay:FindFirstChild("StockSlots")
	local marker = slots and slots:FindFirstChild(("StockSlot%02d"):format(stock.SlotIndex))
	if not marker or not marker:IsA("BasePart") then
		return
	end

	destroyDisplay(state, stock.SlotIndex)
	local visual = PrototypeVisualConfig.Items[stock.ItemId]
	local definition = ItemConfig[stock.ItemId]
	if not visual or not definition then
		return
	end

	local part = Instance.new("Part")
	part.Name = ("StockDisplay%02d"):format(stock.SlotIndex)
	part.Size = visual.Size
	part.CFrame = marker.CFrame * CFrame.new(0, visual.Size.Y * 0.5 + 0.15, 0)
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = visual.Color
	part:SetAttribute("ItemId", stock.ItemId)
	part:SetAttribute("StockId", stock.StockId)
	part:SetAttribute("StockSlotIndex", stock.SlotIndex)
	part:SetAttribute("PassiveRatePerMinute", stock.PassiveRatePerMinute)
	part:SetAttribute("PresentationOnly", true)
	part.Parent = folder

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "StockedLabel"
	billboard.Adornee = part
	billboard.Size = UDim2.fromOffset(180, 44)
	billboard.StudsOffset = Vector3.new(0, visual.Size.Y * 0.5 + 1.15, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 55
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = string.format("%s\n%s", string.upper(definition.Name), NumberFormat.Rate(stock.PassiveRatePerMinute))
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
	bay:SetAttribute("TotalPassivePerMinute", totalPassiveRate(state))
	for index = 1, EconomyConfig.MaxStockSlots do
		local marker = slots:FindFirstChild(("StockSlot%02d"):format(index))
		if marker and marker:IsA("BasePart") then
			local stock = state.Stock[index]
			local active = index <= capacity or stock ~= nil
			marker.Transparency = if active then 0.45 else 1
			marker.CanCollide = false
			marker.CanTouch = false
			marker.CanQuery = false
			marker:SetAttribute("StockActive", active)
			marker:SetAttribute("Occupied", stock ~= nil)
			marker:SetAttribute("StockId", if stock then stock.StockId else "")
			local label = ensureSlotLabel(marker, index)
			local gui = label.Parent
			if gui and gui:IsA("BillboardGui") then
				gui.Enabled = active
			end
			if active then
				if stock then
					local definition = ItemConfig[stock.ItemId]
					label.Text = string.format("STOCK %d\n%s %s", index, if definition then string.upper(definition.Name) else "KEPT", NumberFormat.Rate(stock.PassiveRatePerMinute))
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
					sellValue = sellValue(entry.ItemId),
					passiveRate = passiveRate(entry.ItemId),
				})
			end
		end
	end

	local stockItems = {}
	for slotIndex, stock in state.Stock do
		local definition = ItemConfig[stock.ItemId]
		table.insert(stockItems, {
			slotIndex = slotIndex,
			stockId = stock.StockId,
			itemId = stock.ItemId,
			name = if definition then definition.Name else stock.ItemId,
			passiveRate = stock.PassiveRatePerMinute,
			salvageValue = stock.SalvageValue,
			originalSellValue = stock.OriginalSellValue,
			stockedAtUnix = stock.StockedAtUnix,
		})
	end
	table.sort(stockItems, function(a, b)
		return a.slotIndex < b.slotIndex
	end)

	local capacity = stockCapacity(player)
	local occupied = occupiedCount(state)
	return {
		cash = PlayerDataService.GetCash(player),
		reviewId = state.ReviewId,
		reviewItems = reviewItems,
		stockCapacity = capacity,
		stockOccupied = occupied,
		stockFree = math.max(0, capacity - occupied),
		stockItems = stockItems,
		totalPassiveRate = totalPassiveRate(state),
		offlineEarnings = PlayerDataService.GetOfflineAward(player),
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
		if not state.Stock[index] then
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

local function sellDeliveredEntries(player: Player, state: EconomyState): number
	local payout = 0
	for index = #state.Delivered, 1, -1 do
		local entry = state.Delivered[index]
		if entry.State == "Delivered" then
			entry.State = "Sold"
			payout += sellValue(entry.ItemId)
			table.remove(state.Delivered, index)
		end
	end
	if payout > 0 then
		PlayerDataService.AddCash(player, payout)
		PlayerDataService.RequestSave(player)
	end
	closeReviewIfEmpty(state)
	return payout
end

local function createStockEntry(state: EconomyState, entry: DeliveredEntry, slotIndex: number)
	local stock: StockEntry = {
		StockId = HttpService:GenerateGUID(false),
		ItemId = entry.ItemId,
		SourceReviewItemId = entry.ReviewItemId,
		SlotIndex = slotIndex,
		StockedAtUnix = os.time(),
		PassiveRatePerMinute = passiveRate(entry.ItemId),
		OriginalSellValue = sellValue(entry.ItemId),
		SalvageValue = salvageValue(entry.ItemId),
	}
	entry.State = "Stocked"
	state.Stock[slotIndex] = stock
	createDisplay(state, stock)
end

local function keepSelected(player: Player, state: EconomyState, ids: {string}): boolean
	local unique: {[string]: boolean} = {}
	local ordered = {}
	for _, id in ids do
		if typeof(id) == "string" and not unique[id] then
			unique[id] = true
			table.insert(ordered, id)
		end
	end
	if #ordered == 0 then
		return false
	end
	local slots = freeSlots(player, state)
	if #ordered > #slots then
		noticeRemote:FireClient(player, "STOCK FULL - SELL OR MANAGE STOCK FIRST.")
		return false
	end

	local validated: {{Entry: DeliveredEntry, Index: number}} = {}
	for _, id in ordered do
		local entry, index = findDelivered(state, id)
		if not entry or not index then
			return false
		end
		table.insert(validated, { Entry = entry, Index = index })
	end

	settlePassive(player, state, Workspace:GetServerTimeNow())
	for listIndex, record in validated do
		createStockEntry(state, record.Entry, slots[listIndex])
	end
	table.sort(validated, function(a, b)
		return a.Index > b.Index
	end)
	for _, record in validated do
		table.remove(state.Delivered, record.Index)
	end
	closeReviewIfEmpty(state)
	refreshSlots(player, state)
	syncStockProfile(player, state)
	PlayerDataService.RequestSave(player)
	return true
end

local function sellStock(player: Player, state: EconomyState, slotIndex: number, stockId: string): boolean
	local stock = state.Stock[slotIndex]
	if not stock or stock.StockId ~= stockId then
		return false
	end
	settlePassive(player, state, Workspace:GetServerTimeNow())
	state.Stock[slotIndex] = nil
	destroyDisplay(state, slotIndex)
	PlayerDataService.AddCash(player, stock.SalvageValue)
	refreshSlots(player, state)
	syncStockProfile(player, state)
	PlayerDataService.RequestSave(player)
	local definition = ItemConfig[stock.ItemId]
	noticeRemote:FireClient(player, ("%s LIQUIDATED +%s"):format(if definition then string.upper(definition.Name) else "STOCK", NumberFormat.Cash(stock.SalvageValue)))
	return true
end

local function handleAction(player: Player, action: any, payload: any)
	if typeof(action) ~= "string" or typeof(payload) ~= "table" then
		return
	end
	local state = states[player]
	if not state or not PlayerDataService.IsLoaded(player) then
		return
	end
	if action == "RequestState" then
		sendState(player, state)
		return
	end

	local now = os.clock()
	if now - state.LastActionAt < EconomyConfig.Review.ActionCooldownSeconds then
		return
	end
	state.LastActionAt = now

	if action == "SellStock" then
		local slotIndex = payload.slotIndex
		local stockId = payload.stockId
		if typeof(slotIndex) == "number" and typeof(stockId) == "string" and sellStock(player, state, math.floor(slotIndex), stockId) then
			sendState(player, state)
		end
		return
	end

	local reviewId = payload.reviewId
	if typeof(reviewId) ~= "string" or not state.ReviewId or reviewId ~= state.ReviewId then
		return
	end
	if action == "SellAll" or action == "SellRest" then
		local payout = sellDeliveredEntries(player, state)
		if payout > 0 then
			noticeRemote:FireClient(player, ("SOLD! +%s"):format(NumberFormat.Cash(payout)))
		end
		sendState(player, state)
	elseif action == "KeepSelected" then
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
		if keepSelected(player, state, cleanIds) then
			noticeRemote:FireClient(player, "KEPT IN STOCK. SELL THE REST OR KEEP CHOOSING.")
			sendState(player, state)
		end
	end
end

local function hydrateStock(profile: any): {[number]: StockEntry}
	local result: {[number]: StockEntry} = {}
	local slots = profile.Stock and profile.Stock.Slots
	if typeof(slots) ~= "table" then
		return result
	end
	for key, raw in slots do
		local slotIndex = tonumber(key)
		if slotIndex and typeof(raw) == "table" and typeof(raw.ItemId) == "string" and ItemConfig[raw.ItemId] then
			local index = math.clamp(math.floor(slotIndex + 0.5), 1, EconomyConfig.MaxStockSlots)
			result[index] = {
				StockId = if typeof(raw.StockId) == "string" and raw.StockId ~= "" then raw.StockId else HttpService:GenerateGUID(false),
				ItemId = raw.ItemId,
				SourceReviewItemId = "RESTORED",
				SlotIndex = index,
				StockedAtUnix = tonumber(raw.StockedAtUnix) or os.time(),
				PassiveRatePerMinute = tonumber(raw.PassiveRatePerMinute) or passiveRate(raw.ItemId),
				OriginalSellValue = tonumber(raw.OriginalSellValue) or sellValue(raw.ItemId),
				SalvageValue = tonumber(raw.SalvageValue) or salvageValue(raw.ItemId),
			}
		end
	end
	return result
end

local function initializeLoadedPlayer(player: Player, profile: any)
	if states[player] then
		return
	end
	if player:GetAttribute(EconomyConfig.PassiveIncomeMultiplierAttribute) == nil then
		player:SetAttribute(EconomyConfig.PassiveIncomeMultiplierAttribute, EconomyConfig.DefaultPassiveIncomeMultiplier)
	end

	local state: EconomyState = {
		ReviewId = nil,
		Delivered = {},
		Stock = hydrateStock(profile),
		LastActionAt = -math.huge,
		Bay = BayService.GetBayModel(player),
		PassiveRemainder = tonumber(profile.PassiveRemainder) or 0,
		LastPassiveServerTime = Workspace:GetServerTimeNow(),
	}
	states[player] = state

	for _, stock in state.Stock do
		createDisplay(state, stock)
	end
	refreshSlots(player, state)
	syncStockProfile(player, state)
	sendState(player, state)

	player:GetAttributeChangedSignal(EconomyConfig.StockSlotCapacityAttribute):Connect(function()
		if states[player] == state then
			refreshSlots(player, state)
			sendState(player, state)
		end
	end)
	player:GetAttributeChangedSignal(EconomyConfig.PassiveIncomeMultiplierAttribute):Connect(function()
		if states[player] == state then
			settlePassive(player, state, Workspace:GetServerTimeNow())
			sendState(player, state)
		end
	end)
end

function EconomyService.CanAcceptDelivery(player: Player): boolean
	local state = states[player]
	return state ~= nil and state.ReviewId == nil
end

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
	noticeRemote:FireClient(player, "DELIVERY COMPLETE - SELL OR KEEP.")
	sendState(player, state)
	return true
end

function EconomyService.RefreshPlayer(player: Player)
	local state = states[player]
	if state then
		refreshSlots(player, state)
		sendState(player, state)
	end
end

function EconomyService.Start()
	economyStateRemote = RemoteService.Get(RemoteNames.EconomyState)
	economyActionRemote = RemoteService.Get(RemoteNames.EconomyAction)
	noticeRemote = RemoteService.Get(RemoteNames.PrototypeNotice)
	economyActionRemote.OnServerEvent:Connect(handleAction)

	PlayerDataService.OnLoaded(initializeLoadedPlayer)
	PlayerDataService.RegisterBeforeSave(function(player, profile)
		local state = states[player]
		if state then
			settlePassive(player, state, Workspace:GetServerTimeNow())
			syncStockProfile(player, state)
			profile.PassiveRemainder = state.PassiveRemainder
		end
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

	RunService.Heartbeat:Connect(function(dt)
		heartbeatAccumulator += dt
		if heartbeatAccumulator < EconomyConfig.Passive.CalculationIntervalSeconds then
			return
		end
		heartbeatAccumulator = 0
		local nowServer = Workspace:GetServerTimeNow()
		for player, state in states do
			if settlePassive(player, state, nowServer) > 0 then
				sendState(player, state)
			end
		end
	end)
end

return EconomyService
