--!strict

local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local CarryConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("CarryConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local PrototypeVisualConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PrototypeVisualConfig"))
local SupplyConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("SupplyConfig"))

local ItemService = {}

local rng = Random.new()
local itemFolder: Folder? = nil
local spawnFolder: Folder? = nil
local lostVisualFolder: Folder? = nil
local prototypeRoot: Folder? = nil

local activeBySpawn: {[string]: BasePart} = {}
local sectorSpawns: {[string]: {BasePart}} = {}
local sectorItemPools: {[string]: {[number]: {string}}} = {}
local spawnStates: {[string]: any} = {}
local sectorBandNextAt: {[string]: {[string]: number}} = {}
local controllerGeneration = 0

local metrics = {
	StartedAt = os.clock(),
	Consumed = 0,
	Replenished = 0,
	HighValueConsumed = 0,
	HighValueReplenished = 0,
	TotalVacancySeconds = 0,
	VacanciesFilled = 0,
	LastSummaryAt = os.clock(),
}

local function playerAlpha(): number
	local count = math.max(1, #Players:GetPlayers())
	return math.clamp((count - 1) / math.max(1, SupplyConfig.FullServerPlayers - 1), 0, 1)
end

local function lerpNumber(a: number, b: number, alpha: number): number
	return a + (b - a) * alpha
end

local function targetPerSector(): number
	local population = SupplyConfig.InitialPopulationPerSector
	return math.floor(lerpNumber(population.Solo, population.FullServer, playerAlpha()) + 0.5)
end

local function restockBudget(): number
	local budget = SupplyConfig.RestocksPerTick
	return math.max(1, math.floor(lerpNumber(budget.Solo, budget.FullServer, playerAlpha()) + 0.5))
end

local function valueBandName(itemId: string): string
	local definition = ItemConfig[itemId]
	local value = if definition then definition.Value else 0
	if value <= SupplyConfig.ValueBands.Ordinary.MaxSellValue then
		return "Ordinary"
	elseif value <= SupplyConfig.ValueBands.Strong.MaxSellValue then
		return "Strong"
	end
	return "High"
end

local function bandConfig(itemId: string): any
	return SupplyConfig.ValueBands[valueBandName(itemId)]
end

local function vacancyDelay(itemId: string): number
	local band = bandConfig(itemId)
	local base = rng:NextNumber(band.MinVacancySeconds, band.MaxVacancySeconds)
	local scale = lerpNumber(1, SupplyConfig.FullServerCooldownScale, playerAlpha())
	return base * scale
end

local function makeWorldItem(itemId: string, cframe: CFrame, spawnName: string?, ownerUserId: number?): Part
	assert(itemFolder, "ItemService.Start must run first")
	local definition = ItemConfig[itemId]
	local visual = PrototypeVisualConfig.Items[itemId]
	assert(definition and visual, ("Unknown prototype item %s"):format(itemId))

	local item = Instance.new("Part")
	item.Name = itemId
	item.Size = visual.Size
	item.CFrame = cframe + Vector3.new(0, visual.Size.Y * 0.5 + 0.15, 0)
	item.Anchored = true
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = true
	item.Material = Enum.Material.SmoothPlastic
	item.Color = visual.Color
	item:SetAttribute("ItemId", itemId)
	item:SetAttribute("WorldItemId", HttpService:GenerateGUID(false))
	item:SetAttribute("Available", true)
	item:SetAttribute("ReservedByUserId", 0)
	item:SetAttribute("SpawnName", spawnName or "")
	item:SetAttribute("OwnerUserId", ownerUserId or 0)
	item:SetAttribute("ProtectedUntil", 0)
	item.Parent = itemFolder

	local gui = Instance.new("BillboardGui")
	gui.Name = "PrototypeLabel"
	gui.Adornee = item
	gui.Size = UDim2.fromOffset(160, 40)
	gui.StudsOffset = Vector3.new(0, visual.Size.Y * 0.5 + 1.25, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 42
	gui.Parent = item

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = definition.Name
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.3
	label.Parent = gui
	return item
end

local function spawnAtMarker(spawnPart: BasePart, itemId: string, isReplenishment: boolean): boolean
	if not itemFolder or not ItemConfig[itemId] then
		return false
	end
	local spawnName = spawnPart.Name
	local existing = activeBySpawn[spawnName]
	if existing and existing.Parent then
		return false
	end

	local item = makeWorldItem(itemId, spawnPart.CFrame, spawnName, nil)
	item:SetAttribute("ZoneName", spawnPart:GetAttribute("ZoneName") or "")
	item:SetAttribute("ZoneDepth", spawnPart:GetAttribute("ZoneDepth") or 0)
	item:SetAttribute("SectorName", spawnPart:GetAttribute("SectorName") or "")
	item:SetAttribute("OpportunityName", spawnPart:GetAttribute("OpportunityName") or "")
	item:SetAttribute("OpportunityKind", spawnPart:GetAttribute("OpportunityKind") or "")
	activeBySpawn[spawnName] = item

	local state = spawnStates[spawnName]
	if state then
		if isReplenishment and typeof(state.VacantSince) == "number" then
			metrics.TotalVacancySeconds += math.max(0, os.clock() - state.VacantSince)
			metrics.VacanciesFilled += 1
		end
		state.VacantSince = nil
		state.NextEligibleAt = 0
		state.LastSpawnedItemId = itemId
	end

	if isReplenishment then
		metrics.Replenished += 1
		if valueBandName(itemId) == "High" then
			metrics.HighValueReplenished += 1
		end
	end

	item.Destroying:Connect(function()
		if activeBySpawn[spawnName] == item then
			activeBySpawn[spawnName] = nil
		end
	end)
	return true
end

local function desiredInitialMarkers(markers: {BasePart}, target: number): {[string]: boolean}
	local byDepth: {[number]: {BasePart}} = { [1] = {}, [2] = {}, [3] = {} }
	for _, marker in markers do
		local depth = marker:GetAttribute("ZoneDepth")
		if typeof(depth) ~= "number" or not byDepth[depth] then
			depth = 1
		end
		table.insert(byDepth[depth], marker)
	end
	for _, group in byDepth do
		table.sort(group, function(a, b)
			return a.Name < b.Name
		end)
	end

	local desired: {[string]: boolean} = {}
	local cursors = { [1] = 1, [2] = 1, [3] = 1 }
	local selected = 0
	while selected < math.min(target, #markers) do
		local added = false
		for depth = 1, 3 do
			local group = byDepth[depth]
			local marker = group[cursors[depth]]
			if marker and selected < target then
				desired[marker.Name] = true
				cursors[depth] += 1
				selected += 1
				added = true
			end
		end
		if not added then
			break
		end
	end
	return desired
end

local function activeCountForSector(sectorName: string): number
	local count = 0
	for _, marker in sectorSpawns[sectorName] or {} do
		local item = activeBySpawn[marker.Name]
		if item and item.Parent then
			count += 1
		end
	end
	return count
end

local function healthForSector(sectorName: string, target: number): string
	local ratio = activeCountForSector(sectorName) / math.max(1, target)
	if ratio >= SupplyConfig.Health.HealthyRatio then
		return "Healthy"
	elseif ratio >= SupplyConfig.Health.ReducedRatio then
		return "Reduced"
	elseif ratio >= SupplyConfig.Health.LowRatio then
		return "Low"
	end
	return "SeverelyDepleted"
end

local function weightedChoice(options: {{Value: any, Weight: number}}): any?
	local total = 0
	for _, option in options do
		total += math.max(0, option.Weight)
	end
	if total <= 0 then
		return nil
	end
	local roll = rng:NextNumber(0, total)
	local cursor = 0
	for _, option in options do
		cursor += math.max(0, option.Weight)
		if roll <= cursor then
			return option.Value
		end
	end
	return options[#options] and options[#options].Value or nil
end

local function chooseItemForMarker(sectorName: string, marker: BasePart, now: number, health: string): string?
	local state = spawnStates[marker.Name]
	if not state then
		return nil
	end
	local depth = state.Depth
	local poolByDepth = sectorItemPools[sectorName]
	local pool = poolByDepth and poolByDepth[depth]
	if not pool or #pool == 0 then
		return nil
	end

	local bandGate = sectorBandNextAt[sectorName] or {}
	local options = {}
	for _, itemId in pool do
		local bandName = valueBandName(itemId)
		local band = SupplyConfig.ValueBands[bandName]
		if bandName == "Ordinary" or now >= (bandGate[bandName] or 0) then
			local weight = band.SelectionWeight
			if itemId == state.LastItemId then
				weight *= SupplyConfig.SameItemAtSameSpawnWeight
			end
			if health == "SeverelyDepleted" then
				if bandName == "Ordinary" then
					weight *= SupplyConfig.SevereDepletionOrdinaryWeightMultiplier
				elseif bandName == "Strong" then
					weight *= SupplyConfig.SevereDepletionStrongWeightMultiplier
				else
					weight *= SupplyConfig.SevereDepletionHighWeightMultiplier
				end
			end
			table.insert(options, { Value = itemId, Weight = weight })
		end
	end
	return weightedChoice(options)
end

local function eligibleMarkersForSector(sectorName: string, now: number): {BasePart}
	local result = {}
	for _, marker in sectorSpawns[sectorName] or {} do
		local current = activeBySpawn[marker.Name]
		local state = spawnStates[marker.Name]
		if (not current or not current.Parent) and state and typeof(state.VacantSince) == "number" and now >= (state.NextEligibleAt or 0) then
			table.insert(result, marker)
		end
	end
	return result
end

local function chooseVacancy(markers: {BasePart}, now: number): BasePart?
	local options = {}
	for _, marker in markers do
		local state = spawnStates[marker.Name]
		local age = if state and typeof(state.VacantSince) == "number" then math.max(0, now - state.VacantSince) else 0
		table.insert(options, {
			Value = marker,
			Weight = 1 + math.min(age / 45, 2.5),
		})
	end
	return weightedChoice(options)
end

local function refillOneInSector(sectorName: string, now: number, target: number): boolean
	if activeCountForSector(sectorName) >= target then
		return false
	end
	local health = healthForSector(sectorName, target)
	local candidates = eligibleMarkersForSector(sectorName, now)
	while #candidates > 0 do
		local marker = chooseVacancy(candidates, now)
		if not marker then
			return false
		end
		local itemId = chooseItemForMarker(sectorName, marker, now, health)
		if itemId and spawnAtMarker(marker, itemId, true) then
			return true
		end
		for index, candidate in candidates do
			if candidate == marker then
				table.remove(candidates, index)
				break
			end
		end
	end
	return false
end

local function chooseSectorForRefill(now: number, target: number): string?
	local options = {}
	for sectorName in sectorSpawns do
		local active = activeCountForSector(sectorName)
		if active < target and #eligibleMarkersForSector(sectorName, now) > 0 then
			local deficit = target - active
			local ratio = active / math.max(1, target)
			local weight = 1 + deficit * 1.6 + (1 - ratio) * 4
			if healthForSector(sectorName, target) == "SeverelyDepleted" then
				weight *= 1.7
			end
			table.insert(options, { Value = sectorName, Weight = weight })
		end
	end
	return weightedChoice(options)
end

local function sanitizedAttributeName(sectorName: string): string
	return string.gsub(sectorName, "[^%w_]", "")
end

local function updateTelemetry(now: number)
	local root = prototypeRoot
	if not root then
		return
	end
	local target = targetPerSector()
	local activeTotal = 0
	local severe = 0
	for sectorName in sectorSpawns do
		local active = activeCountForSector(sectorName)
		local health = healthForSector(sectorName, target)
		activeTotal += active
		if health == "SeverelyDepleted" then
			severe += 1
		end
		local prefix = "Supply_" .. sanitizedAttributeName(sectorName) .. "_"
		root:SetAttribute(prefix .. "Active", active)
		root:SetAttribute(prefix .. "Target", target)
		root:SetAttribute(prefix .. "Health", health)
	end

	local elapsedMinutes = math.max((now - metrics.StartedAt) / 60, 1 / 60)
	root:SetAttribute("SupplyActiveObjects", activeTotal)
	root:SetAttribute("SupplyTargetPerSector", target)
	root:SetAttribute("SupplyConsumed", metrics.Consumed)
	root:SetAttribute("SupplyReplenished", metrics.Replenished)
	root:SetAttribute("SupplyConsumedPerMinute", metrics.Consumed / elapsedMinutes)
	root:SetAttribute("SupplyReplenishedPerMinute", metrics.Replenished / elapsedMinutes)
	root:SetAttribute("SupplyHighValueConsumed", metrics.HighValueConsumed)
	root:SetAttribute("SupplyHighValueReplenished", metrics.HighValueReplenished)
	root:SetAttribute("SupplyAverageVacancySeconds", if metrics.VacanciesFilled > 0 then metrics.TotalVacancySeconds / metrics.VacanciesFilled else 0)
	root:SetAttribute("SupplySeverelyDepletedSectors", severe)

	if root:GetAttribute("SupplyDebugPrintEnabled") == true and now - metrics.LastSummaryAt >= SupplyConfig.TelemetrySummarySeconds then
		metrics.LastSummaryAt = now
		print(string.format(
			"[ONE TRIP][M4.1 SUPPLY] active=%d target/sector=%d consumed=%.1f/min replenished=%.1f/min high %d/%d avg vacancy %.1fs",
			activeTotal,
			target,
			metrics.Consumed / elapsedMinutes,
			metrics.Replenished / elapsedMinutes,
			metrics.HighValueConsumed,
			metrics.HighValueReplenished,
			if metrics.VacanciesFilled > 0 then metrics.TotalVacancySeconds / metrics.VacanciesFilled else 0
		))
	end
end

local function runSupplyTick()
	local now = os.clock()
	local target = targetPerSector()
	local budget = restockBudget()
	for sectorName in sectorSpawns do
		if healthForSector(sectorName, target) == "SeverelyDepleted" then
			budget += SupplyConfig.SevereDepletionBonusRestocks
			break
		end
	end

	for _ = 1, budget do
		local sectorName = chooseSectorForRefill(now, target)
		if not sectorName then
			break
		end
		if not refillOneInSector(sectorName, now, target) then
			break
		end
	end
	updateTelemetry(now)
end

local function markVacantAfterPickup(spawnName: string, itemId: string)
	local state = spawnStates[spawnName]
	if not state then
		return
	end
	local now = os.clock()
	local delay = vacancyDelay(itemId)
	state.VacantSince = now
	state.NextEligibleAt = now + delay
	state.LastItemId = itemId

	metrics.Consumed += 1
	local bandName = valueBandName(itemId)
	if bandName == "High" then
		metrics.HighValueConsumed += 1
	end

	if bandName ~= "Ordinary" then
		local sectorName = state.SectorName
		sectorBandNextAt[sectorName] = sectorBandNextAt[sectorName] or {}
		local gate = sectorBandNextAt[sectorName]
		-- Strong/high removal affects more than one exact location, preventing a
		-- same-value opportunity from trivially hopping to the next vacancy.
		gate[bandName] = math.max(gate[bandName] or 0, now + delay * 0.85)
	end
end

local function spawnLostVisual(itemId: string, startCFrame: CFrame, offsetIndex: number, lostKind: string, ownerUserId: number?, scatterSeconds: number, lifetimeSeconds: number, fadeSeconds: number)
	if not lostVisualFolder then return end
	local visual = PrototypeVisualConfig.Items[itemId]
	if not visual then return end
	local angle = offsetIndex * 1.73
	local radius = 3.0 + (offsetIndex % 3) * 1.05
	local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
	local destinationPosition = Vector3.new(startCFrame.Position.X + offset.X, visual.Size.Y * 0.5 + 0.06, startCFrame.Position.Z + offset.Z)

	local lost = Instance.new("Part")
	lost.Name = ("%s_%s"):format(lostKind, itemId)
	lost.Size = visual.Size
	lost.CFrame = startCFrame
	lost.Anchored = true
	lost.CanCollide = false
	lost.CanTouch = false
	lost.CanQuery = false
	lost.Material = Enum.Material.SmoothPlastic
	lost.Color = visual.Color
	lost:SetAttribute("ItemId", itemId)
	lost:SetAttribute("Available", false)
	lost:SetAttribute("TripLossKind", lostKind)
	lost:SetAttribute("AbandonedByUserId", ownerUserId or 0)
	lost.Parent = lostVisualFolder

	local spin = CFrame.Angles(math.rad(24 + offsetIndex * 11), math.rad(offsetIndex * 43), math.rad(30 - offsetIndex * 7))
	TweenService:Create(lost, TweenInfo.new(scatterSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = CFrame.new(destinationPosition) * spin }):Play()
	task.delay(math.max(0.15, lifetimeSeconds - fadeSeconds), function()
		if not lost.Parent then return end
		TweenService:Create(lost, TweenInfo.new(fadeSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1,
			Size = lost.Size * 0.82,
		}):Play()
	end)
	Debris:AddItem(lost, lifetimeSeconds)
end

function ItemService.Start(root: Folder)
	controllerGeneration += 1
	local generation = controllerGeneration
	table.clear(activeBySpawn)
	table.clear(sectorSpawns)
	table.clear(sectorItemPools)
	table.clear(spawnStates)
	table.clear(sectorBandNextAt)
	metrics.StartedAt = os.clock()
	metrics.Consumed = 0
	metrics.Replenished = 0
	metrics.HighValueConsumed = 0
	metrics.HighValueReplenished = 0
	metrics.TotalVacancySeconds = 0
	metrics.VacanciesFilled = 0
	metrics.LastSummaryAt = os.clock()

	prototypeRoot = root
	if root:GetAttribute("SupplyDebugPrintEnabled") == nil then
		root:SetAttribute("SupplyDebugPrintEnabled", false)
	end

	itemFolder = Instance.new("Folder")
	itemFolder.Name = "Items"
	itemFolder.Parent = root
	spawnFolder = root:WaitForChild("ItemSpawns") :: Folder
	lostVisualFolder = Instance.new("Folder")
	lostVisualFolder.Name = "LostTripItems"
	lostVisualFolder.Parent = root

	for _, spawnPart in spawnFolder:GetChildren() do
		if spawnPart:IsA("BasePart") then
			local sectorName = spawnPart:GetAttribute("SectorName")
			if typeof(sectorName) ~= "string" or sectorName == "" then
				sectorName = "Unassigned"
			end
			local depth = spawnPart:GetAttribute("ZoneDepth")
			if typeof(depth) ~= "number" then
				depth = 1
		end
			local originalItemId = spawnPart:GetAttribute("ItemId")
			if typeof(originalItemId) ~= "string" or not ItemConfig[originalItemId] then
				continue
			end

			sectorSpawns[sectorName] = sectorSpawns[sectorName] or {}
			table.insert(sectorSpawns[sectorName], spawnPart)
			sectorItemPools[sectorName] = sectorItemPools[sectorName] or {}
			sectorItemPools[sectorName][depth] = sectorItemPools[sectorName][depth] or {}
			table.insert(sectorItemPools[sectorName][depth], originalItemId)
			sectorBandNextAt[sectorName] = sectorBandNextAt[sectorName] or {}
			spawnStates[spawnPart.Name] = {
				SectorName = sectorName,
				Depth = depth,
				OriginalItemId = originalItemId,
				VacantSince = nil,
				NextEligibleAt = 0,
				LastItemId = nil,
				LastSpawnedItemId = nil,
			}
		end
	end

	local target = targetPerSector()
	for _, markers in sectorSpawns do
		local desired = desiredInitialMarkers(markers, target)
		for _, marker in markers do
			local state = spawnStates[marker.Name]
			if desired[marker.Name] and state then
				spawnAtMarker(marker, state.OriginalItemId, false)
			elseif state then
				state.VacantSince = os.clock()
				state.NextEligibleAt = os.clock() + vacancyDelay(state.OriginalItemId)
			end
		end
	end
	updateTelemetry(os.clock())

	task.spawn(function()
		while controllerGeneration == generation and itemFolder and itemFolder.Parent do
			task.wait(SupplyConfig.SupplyTickSeconds)
			if controllerGeneration ~= generation then
				break
			end
			runSupplyTick()
		end
	end)
end

function ItemService.GetAvailableCount(): number
	if not itemFolder then return 0 end
	local count = 0
	for _, candidate in itemFolder:GetChildren() do
		if candidate:IsA("BasePart") and candidate:GetAttribute("Available") == true then count += 1 end
	end
	return count
end

function ItemService.TryTake(player: Player, candidate: Instance): (boolean, string?, CFrame?)
	if not itemFolder or not candidate:IsA("BasePart") or candidate.Parent ~= itemFolder then return false, nil, nil end
	if candidate:GetAttribute("Available") ~= true or candidate:GetAttribute("ReservedByUserId") ~= 0 then return false, nil, nil end
	local itemId = candidate:GetAttribute("ItemId")
	if typeof(itemId) ~= "string" or not ItemConfig[itemId] then return false, nil, nil end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then return false, nil, nil end
	if (root.Position - candidate.Position).Magnitude > CarryConfig.GrabDistance then return false, nil, nil end

	candidate:SetAttribute("ReservedByUserId", player.UserId)
	candidate:SetAttribute("Available", false)
	local pickupCFrame = candidate.CFrame
	local spawnName = candidate:GetAttribute("SpawnName")
	if typeof(spawnName) == "string" and spawnName ~= "" and activeBySpawn[spawnName] == candidate then
		activeBySpawn[spawnName] = nil
		markVacantAfterPickup(spawnName, itemId)
	end
	candidate:Destroy()
	updateTelemetry(os.clock())
	return true, itemId, pickupCFrame
end

function ItemService.SpawnCollapseLoss(itemId: string, startCFrame: CFrame, offsetIndex: number)
	spawnLostVisual(itemId, startCFrame, offsetIndex, "Collapse", nil, CarryConfig.Failure.CollapseScatterSeconds, CarryConfig.Failure.LostVisualLifetimeSeconds, 0.40)
end

function ItemService.SpawnDropped(itemId: string, startCFrame: CFrame, ownerUserId: number, offsetIndex: number)
	spawnLostVisual(itemId, startCFrame, offsetIndex, "Ditch", ownerUserId, CarryConfig.Ditch.ScatterSeconds, CarryConfig.Ditch.VisualLifetimeSeconds, CarryConfig.Ditch.FadeSeconds)
end

return ItemService
