--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ArtConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("M6BArtConfig"))

local Service = {}
local generation = 0

local function slotFor(root: Folder, spawnName: string): Model?
	local folder = root:FindFirstChild("M6BStorageSlots")
	local slot = folder and folder:FindFirstChild(spawnName)
	return if slot and slot:IsA("Model") then slot else nil
end

local function lightFor(root: Folder, spawnName: string): BasePart?
	local slot = slotFor(root, spawnName)
	local light = slot and slot:FindFirstChild("StatusLight")
	return if light and light:IsA("BasePart") then light else nil
end

local function styleForSlot(slot: Model?): any?
	if not slot then return nil end
	local sectionId = slot:GetAttribute("SectionId")
	if typeof(sectionId) ~= "string" then return nil end
	return ArtConfig.SectionStyles[sectionId]
end

local function setVacant(root: Folder, spawnName: string)
	local slot = slotFor(root, spawnName)
	local light = lightFor(root, spawnName)
	if not slot or not light then return end
	slot:SetAttribute("SlotState", "Vacant")
	light:SetAttribute("SlotState", "Vacant")
	light.Color = ArtConfig.SlotStatus.VacantColor
	TweenService:Create(light, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = ArtConfig.SlotStatus.VacantTransparency,
	}):Play()
end

local function setOccupied(root: Folder, spawnName: string, pulse: boolean)
	local slot = slotFor(root, spawnName)
	local light = lightFor(root, spawnName)
	if not slot or not light then return end
	local style = styleForSlot(slot)
	if not style then return end
	slot:SetAttribute("SlotState", "Occupied")
	light:SetAttribute("SlotState", "Occupied")
	light.Color = style.Accent
	if pulse then
		light.Transparency = ArtConfig.SlotStatus.RestockFlashTransparency
		TweenService:Create(light, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = ArtConfig.SlotStatus.OccupiedTransparency,
		}):Play()
	else
		light.Transparency = ArtConfig.SlotStatus.OccupiedTransparency
	end
end

local function bindItem(root: Folder, item: Instance, pulse: boolean)
	if not item:IsA("BasePart") then return end
	local spawnName = item:GetAttribute("SpawnName")
	if typeof(spawnName) ~= "string" or spawnName == "" then return end
	setOccupied(root, spawnName, pulse)
	item.Destroying:Connect(function()
		task.defer(function()
			if root.Parent then setVacant(root, spawnName) end
		end)
	end)
end

function Service.Start(root: Folder)
	generation += 1
	local currentGeneration = generation
	local items = root:FindFirstChild("Items")
	local slots = root:FindFirstChild("M6BStorageSlots")
	if not items or not items:IsA("Folder") or not slots or not slots:IsA("Folder") then return end

	for _, slot in slots:GetChildren() do
		if slot:IsA("Model") then
			setVacant(root, slot.Name)
		end
	end
	for _, item in items:GetChildren() do
		bindItem(root, item, false)
	end

	items.ChildAdded:Connect(function(item)
		if generation ~= currentGeneration then return end
		-- ItemService sets SpawnName before parenting, so this can remain purely
		-- presentational and does not need access to supply internals.
		bindItem(root, item, true)
	end)

	root:SetAttribute("M6BRestockPresentation", true)
end

return Service
