--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local NumberFormat = require(ReplicatedStorage:WaitForChild("NumberFormat"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local Controller = {}
local player = Players.LocalPlayer
local latestSnapshot: any = nil
local selectedId = "Receiving"
local panel: Frame
local tabs: ScrollingFrame
local list: ScrollingFrame
local headerLabel: TextLabel
local progressLabel: TextLabel
local collectionAction: RemoteEvent
local toastQueue = {}
local toastRunning = false
local toastFrame: Frame
local toastTitle: TextLabel
local toastBody: TextLabel

local RARITY_COLORS = {
	Common = Color3.fromRGB(205, 210, 218),
	Uncommon = Color3.fromRGB(92, 211, 122),
	Rare = Color3.fromRGB(77, 154, 255),
	Epic = Color3.fromRGB(176, 90, 255),
	Legendary = Color3.fromRGB(255, 184, 57),
	Mythic = Color3.fromRGB(255, 77, 126),
	Cosmic = Color3.fromRGB(87, 231, 255),
	Eternal = Color3.fromRGB(255, 244, 151),
}

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
	button.TextSize = 14
	button.TextWrapped = true
	button.TextColor3 = Color3.new(1,1,1)
	button.AutoButtonColor = true
	button.Parent = parent
	roundCorner(button, 8)
	return button
end

local function clearNamed(parent: Instance, name: string)
	for _, child in parent:GetChildren() do
		if child.Name == name then child:Destroy() end
	end
end

local function selectedSection(snapshot: any): any?
	if selectedId == "RareFinds" then return nil end
	if typeof(snapshot.sections) ~= "table" then return nil end
	for _, section in snapshot.sections do
		if section.id == selectedId then return section end
	end
	return nil
end

local function addItemRow(entry: any, index: number)
	local row = Instance.new("Frame")
	row.Name = "CollectionRow"
	row.Size = UDim2.new(1, -12, 0, 54)
	row.BackgroundColor3 = if index % 2 == 0 then Color3.fromRGB(38, 43, 50) else Color3.fromRGB(34, 39, 46)
	row.BorderSizePixel = 0
	row.Parent = list
	roundCorner(row, 7)

	local discovered = entry.discovered == true
	local name = makeText(row, if discovered then ("✓ " .. tostring(entry.name or "ITEM")) else "?  ???", UDim2.new(0.62, -12, 1, 0), 15)
	name.Position = UDim2.fromOffset(10, 0)
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.TextColor3 = if discovered then Color3.fromRGB(229, 235, 242) else Color3.fromRGB(126, 136, 149)

	local rarity = if discovered then tostring(entry.bestRarity or "Common") else "UNDISCOVERED"
	local best = makeText(row, if discovered then ("BEST\n" .. string.upper(rarity)) else "NOT\nDELIVERED", UDim2.new(0.35, -10, 1, -8), 12)
	best.Position = UDim2.new(0.64, 0, 0, 4)
	best.TextXAlignment = Enum.TextXAlignment.Right
	best.TextColor3 = RARITY_COLORS[rarity] or Color3.fromRGB(126, 136, 149)
end

local function addRareRow(entry: any, index: number)
	local row = Instance.new("Frame")
	row.Name = "CollectionRow"
	row.Size = UDim2.new(1, -12, 0, 66)
	row.BackgroundColor3 = if index % 2 == 0 then Color3.fromRGB(45, 39, 50) else Color3.fromRGB(40, 35, 46)
	row.BorderSizePixel = 0
	row.Parent = list
	roundCorner(row, 7)
	local discovered = entry.discovered == true
	local nameText = if discovered then tostring(entry.name or "RARE FIND") else "???"
	local name = makeText(row, nameText, UDim2.new(0.62, -12, 0, 30), 15)
	name.Position = UDim2.fromOffset(10, 5)
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.TextColor3 = if discovered then Color3.fromRGB(242, 232, 250) else Color3.fromRGB(137, 124, 145)
	local section = makeText(row, tostring(entry.sectionName or "UNKNOWN SECTION"), UDim2.new(0.62, -12, 0, 24), 11)
	section.Position = UDim2.fromOffset(10, 34)
	section.TextXAlignment = Enum.TextXAlignment.Left
	section.TextColor3 = Color3.fromRGB(168, 157, 177)
	local rarity = if discovered then tostring(entry.bestRarity or "Common") else "UNDISCOVERED"
	local best = makeText(row, if discovered then ("BEST\n" .. string.upper(rarity)) else "NOT\nDELIVERED", UDim2.new(0.35, -10, 1, -8), 12)
	best.Position = UDim2.new(0.64, 0, 0, 4)
	best.TextXAlignment = Enum.TextXAlignment.Right
	best.TextColor3 = RARITY_COLORS[rarity] or Color3.fromRGB(137, 124, 145)
end

local function rebuildList()
	if not latestSnapshot then return end
	clearNamed(list, "CollectionRow")
	if selectedId == "RareFinds" then
		headerLabel.Text = "RARE FINDS"
		local rareFinds = if typeof(latestSnapshot.rareFinds) == "table" then latestSnapshot.rareFinds else {}
		local discovered = 0
		for _, entry in rareFinds do if entry.discovered == true then discovered += 1 end end
		progressLabel.Text = ("%d DISCOVERED  •  PRESTIGE LIST - NOT REQUIRED FOR MASTERY"):format(discovered)
		for index, entry in rareFinds do addRareRow(entry, index) end
		return
	end
	local section = selectedSection(latestSnapshot)
	if not section then return end
	headerLabel.Text = string.upper(tostring(section.name or section.id or "COLLECTION"))
	local discovered = tonumber(section.discovered) or 0
	local total = tonumber(section.total) or 0
	local mastery = math.floor((tonumber(section.mastery) or 0) * 100 + 0.5)
	progressLabel.Text = ("%d / %d DISCOVERED   •   %d%% MASTERY"):format(discovered, total, mastery)
	local entries = if typeof(section.entries) == "table" then section.entries else {}
	for index, entry in entries do addItemRow(entry, index) end
end

local function rebuildTabs()
	if not latestSnapshot then return end
	clearNamed(tabs, "CollectionTab")
	local ordered = {}
	if typeof(latestSnapshot.sections) == "table" then
		for _, section in latestSnapshot.sections do
			table.insert(ordered, { id = section.id, name = section.name })
		end
	end
	table.insert(ordered, { id = "RareFinds", name = "Rare Finds" })
	for _, entry in ordered do
		local button = makeButton(
			tabs,
			string.upper(tostring(entry.name or entry.id)),
			UDim2.fromOffset(132, 42),
			if selectedId == entry.id then Color3.fromRGB(87, 106, 139) else Color3.fromRGB(49, 56, 67)
		)
		button.Name = "CollectionTab"
		button.Activated:Connect(function()
			selectedId = tostring(entry.id)
			rebuildTabs()
			rebuildList()
		end)
	end
end

local function rebuild(snapshot: any)
	latestSnapshot = snapshot
	local exists = selectedId == "RareFinds"
	if not exists and typeof(snapshot.sections) == "table" then
		for _, section in snapshot.sections do if section.id == selectedId then exists = true break end end
	end
	if not exists then selectedId = "Receiving" end
	rebuildTabs()
	rebuildList()
end

local function enqueueToast(title: string, body: string, color: Color3, duration: number?)
	table.insert(toastQueue, { title = title, body = body, color = color, duration = duration or 2.1 })
	if toastRunning then return end
	toastRunning = true
	task.spawn(function()
		while #toastQueue > 0 do
			local toast = table.remove(toastQueue, 1)
			toastTitle.Text = toast.title
			toastBody.Text = toast.body
			toastTitle.TextColor3 = toast.color
			toastFrame.BackgroundTransparency = 0.08
			toastFrame.Visible = true
			toastFrame.Position = UDim2.new(0.5, 0, 0, 86)
			TweenService:Create(toastFrame, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0, 100) }):Play()
			task.wait(toast.duration)
			local fade = TweenService:Create(toastFrame, TweenInfo.new(0.20), { BackgroundTransparency = 1 })
			fade:Play()
			fade.Completed:Wait()
			toastFrame.Visible = false
		end
		toastRunning = false
	end)
end

local function handleEvent(kind: string, data: any)
	if typeof(data) ~= "table" then data = {} end
	if kind == "NewDiscovery" then
		enqueueToast(
			"NEW DISCOVERY!",
			("%s\n%s  %d / %d"):format(string.upper(tostring(data.name or "ITEM")), tostring(data.sectionName or "COLLECTION"), tonumber(data.discovered) or 0, tonumber(data.total) or 0),
			Color3.fromRGB(117, 228, 154),
			2.2
		)
	elseif kind == "BestRarity" then
		local rarity = tostring(data.newRarity or "Common")
		enqueueToast(
			"NEW BEST RARITY!",
			("%s\n%s → %s"):format(string.upper(tostring(data.name or "ITEM")), string.upper(tostring(data.oldRarity or "COMMON")), string.upper(rarity)),
			RARITY_COLORS[rarity] or Color3.new(1,1,1),
			2.2
		)
	elseif kind == "RareFind" then
		local rarity = tostring(data.rarity or "Common")
		enqueueToast(
			"RARE FIND DISCOVERED!",
			("%s\n%s  •  %s"):format(string.upper(tostring(data.name or "RARE FIND")), string.upper(rarity), tostring(data.sectionName or "")),
			RARITY_COLORS[rarity] or Color3.fromRGB(235, 186, 255),
			2.8
		)
	elseif kind == "MasteryMilestone" then
		local percent = tonumber(data.percent) or 0
		local title = if percent >= 100 then (string.upper(tostring(data.sectionName or "SECTION")) .. " MASTERED!") else (("%d%% SECTION MASTERY"):format(percent))
		local extras = {}
		if tonumber(data.cash) and tonumber(data.cash) > 0 then table.insert(extras, NumberFormat.Cash(tonumber(data.cash) or 0) .. " REWARD") end
		if data.cosmetic then table.insert(extras, tostring(data.cosmetic) .. " UNLOCKED") end
		if data.trophy == true then table.insert(extras, "MASTERY TROPHY UNLOCKED") end
		enqueueToast(title, table.concat(extras, "  •  "), Color3.fromRGB(255, 218, 102), if percent >= 100 then 3.2 else 2.4)
	elseif kind == "ServerAnnouncement" then
		local rarity = tostring(data.rarity or "Cosmic")
		enqueueToast(
			"SERVER RARE DELIVERY",
			("%s DELIVERED AN %s %s!"):format(string.upper(tostring(data.playerName or "PLAYER")), string.upper(rarity), string.upper(tostring(data.itemName or "RARE ITEM"))),
			RARITY_COLORS[rarity] or Color3.fromRGB(101, 230, 255),
			3.1
		)
	end
end

function Controller.Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "OneTripCollectionUI"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 22
	gui.Parent = player:WaitForChild("PlayerGui")

	local open = makeButton(gui, "COLLECTION", UDim2.fromOffset(150, 38), Color3.fromRGB(79, 65, 104))
	open.AnchorPoint = Vector2.new(1, 0)
	open.Position = UDim2.new(1, -18, 0, 184)

	panel = Instance.new("Frame")
	panel.Name = "CollectionPanel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.52)
	panel.Size = UDim2.fromScale(0.92, 0.84)
	panel.BackgroundColor3 = Color3.fromRGB(22, 25, 30)
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = gui
	roundCorner(panel, 12)
	local constraint = Instance.new("UISizeConstraint")
	constraint.MinSize = Vector2.new(300, 350)
	constraint.MaxSize = Vector2.new(720, 650)
	constraint.Parent = panel

	local title = makeText(panel, "DELIVERY COLLECTION", UDim2.new(1, -120, 0, 42), 23)
	title.Position = UDim2.fromOffset(14, 8)
	title.TextXAlignment = Enum.TextXAlignment.Left
	local close = makeButton(panel, "CLOSE", UDim2.fromOffset(84, 34), Color3.fromRGB(91, 70, 70))
	close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.new(1, -12, 0, 10)

	tabs = Instance.new("ScrollingFrame")
	tabs.Name = "SectionTabs"
	tabs.Position = UDim2.fromOffset(12, 54)
	tabs.Size = UDim2.new(1, -24, 0, 48)
	tabs.BackgroundTransparency = 1
	tabs.BorderSizePixel = 0
	tabs.ScrollBarThickness = 4
	tabs.ScrollingDirection = Enum.ScrollingDirection.X
	tabs.AutomaticCanvasSize = Enum.AutomaticSize.X
	tabs.CanvasSize = UDim2.new()
	tabs.Parent = panel
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 7)
	tabLayout.Parent = tabs

	headerLabel = makeText(panel, "COLLECTION", UDim2.new(1, -24, 0, 32), 19)
	headerLabel.Position = UDim2.fromOffset(12, 108)
	headerLabel.TextXAlignment = Enum.TextXAlignment.Left
	progressLabel = makeText(panel, "0 / 0 DISCOVERED", UDim2.new(1, -24, 0, 26), 13)
	progressLabel.Position = UDim2.fromOffset(12, 138)
	progressLabel.TextXAlignment = Enum.TextXAlignment.Left
	progressLabel.TextColor3 = Color3.fromRGB(178, 190, 207)

	list = Instance.new("ScrollingFrame")
	list.Name = "EntryList"
	list.Position = UDim2.fromOffset(12, 170)
	list.Size = UDim2.new(1, -24, 1, -182)
	list.BackgroundColor3 = Color3.fromRGB(29, 33, 39)
	list.BackgroundTransparency = 0.08
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
	layout.Padding = UDim.new(0, 6)
	layout.Parent = list

	toastFrame = Instance.new("Frame")
	toastFrame.Name = "CollectionToast"
	toastFrame.AnchorPoint = Vector2.new(0.5, 0)
	toastFrame.Position = UDim2.new(0.5, 0, 0, 100)
	toastFrame.Size = UDim2.new(0.86, 0, 0, 74)
	toastFrame.BackgroundColor3 = Color3.fromRGB(28, 32, 39)
	toastFrame.BackgroundTransparency = 0.08
	toastFrame.BorderSizePixel = 0
	toastFrame.Visible = false
	toastFrame.Active = false
	toastFrame.Parent = gui
	roundCorner(toastFrame, 10)
	local toastConstraint = Instance.new("UISizeConstraint")
	toastConstraint.MinSize = Vector2.new(280, 74)
	toastConstraint.MaxSize = Vector2.new(500, 74)
	toastConstraint.Parent = toastFrame
	toastTitle = makeText(toastFrame, "NEW DISCOVERY!", UDim2.new(1, -18, 0, 29), 17)
	toastTitle.Position = UDim2.fromOffset(9, 6)
	toastBody = makeText(toastFrame, "", UDim2.new(1, -18, 0, 34), 13)
	toastBody.Position = UDim2.fromOffset(9, 34)

	local folder = ReplicatedStorage:WaitForChild(RemoteNames.Folder)
	local collectionState = folder:WaitForChild(RemoteNames.CollectionState) :: RemoteEvent
	collectionAction = folder:WaitForChild(RemoteNames.CollectionAction) :: RemoteEvent
	local collectionEvent = folder:WaitForChild(RemoteNames.CollectionEvent) :: RemoteEvent
	collectionState.OnClientEvent:Connect(function(snapshot)
		if typeof(snapshot) == "table" then rebuild(snapshot) end
	end)
	collectionEvent.OnClientEvent:Connect(handleEvent)

	open.Activated:Connect(function()
		panel.Visible = not panel.Visible
		if panel.Visible then collectionAction:FireServer("RequestState", {}) end
	end)
	close.Activated:Connect(function() panel.Visible = false end)
	collectionAction:FireServer("RequestState", {})
end

return Controller
