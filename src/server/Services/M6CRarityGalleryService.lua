--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LootCatalog = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LootCatalog"))
local PrototypeVisualConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PrototypeVisualConfig"))
local RarityConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("RarityConfig"))

local Service = {}

local DEFAULT_ITEM = "ShippingBox"
local DEFAULT_ORIGIN = Vector3.new(0, 4.5, 470)
local PROOF_SET = table.freeze({
	"ShippingBox",
	"Refrigerator",
	"Couch",
	"GamingPC",
	"ArcadeCabinet",
	"ShowCarEngine",
	"EngineBlock",
	"DesignerFragranceTrunk",
	"PaintingTransportCrate",
	"JewelrySafe",
	"BlackProjectContainmentUnit",
})

local function addLabel(root: BasePart, text: string, color: Color3)
	local gui = Instance.new("BillboardGui")
	gui.Name = "M6CGalleryLabel"
	gui.Adornee = root
	gui.Size = UDim2.fromOffset(150, 48)
	gui.StudsOffset = Vector3.new(0, root.Size.Y * 0.5 + 2.2, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 250
	gui.Parent = root

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1,1)
	label.BackgroundColor3 = Color3.fromRGB(24,27,32)
	label.BackgroundTransparency = 0.12
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextSize = 13
	label.TextWrapped = true
	label.TextColor3 = color
	label.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,8)
	corner.Parent = label
end

local function parseList(text: string): {string}
	local result = {}
	for token in string.gmatch(text,"[^,%s]+") do
		if LootCatalog.ById[token] and not table.find(result,token) then table.insert(result,token) end
	end
	return result
end

local function resolveBaseItemIds(): {string}
	local explicit = Workspace:GetAttribute("M6CGalleryBaseItemIds")
	if typeof(explicit) == "string" and explicit ~= "" then
		local parsed = parseList(explicit)
		if #parsed > 0 then return parsed end
	end

	local mode = Workspace:GetAttribute("M6CGalleryMode")
	if typeof(mode) ~= "string" then mode = "PROOF" end
	mode = string.upper(mode)
	if mode == "SINGLE" then
		local requested = Workspace:GetAttribute("M6CGalleryBaseItemId")
		if typeof(requested) == "string" and LootCatalog.ById[requested] then return {requested} end
		return {DEFAULT_ITEM}
	end

	local result = {}
	for _, baseItemId in PROOF_SET do
		if LootCatalog.ById[baseItemId] then table.insert(result,baseItemId) end
	end
	return result
end

local function buildRow(parent: Folder, baseItemId: string, rowOrigin: Vector3, rowIndex: number): (number, number)
	local base = LootCatalog.ById[baseItemId]
	if not base then return 0,0 end

	local rowFolder = Instance.new("Folder")
	rowFolder.Name = ("Row_%02d_%s"):format(rowIndex,baseItemId)
	rowFolder:SetAttribute("BaseItemId",baseItemId)
	rowFolder.Parent = parent

	local baseSize = base.Size
	local spacing = math.max(9.0, baseSize.X + 5.2)
	local totalWidth = spacing * (#RarityConfig.Order - 1)
	local firstX = rowOrigin.X - totalWidth * 0.5
	local maxHeight = baseSize.Y

	for index, rarity in RarityConfig.Order do
		local variantId = RarityConfig.MakeVariantId(baseItemId, rarity)
		local visual = PrototypeVisualConfig.Items[variantId]
		if visual then
			maxHeight = math.max(maxHeight,visual.Size.Y)
			local root = Instance.new("Part")
			root.Name = ("%02d_%s_%s"):format(index, rarity, baseItemId)
			root.Size = visual.Size
			root.CFrame = CFrame.new(firstX + (index - 1) * spacing, rowOrigin.Y + visual.Size.Y * 0.5, rowOrigin.Z)
			root.Anchored = true
			root.CanCollide = false
			root.CanTouch = false
			root.CanQuery = false
			root.Color = visual.Color
			root.Material = visual.Material
			root:SetAttribute("ItemId", variantId)
			root:SetAttribute("BaseItemId", baseItemId)
			root:SetAttribute("Rarity", rarity)
			root:SetAttribute("M6CGalleryPreview", true)
			root.Parent = rowFolder
			addLabel(root, rarity:upper() .. "\n" .. base.Name:upper(), RarityConfig.Tiers[rarity].Color)
		end
	end
	return totalWidth,maxHeight
end

local function build(world: Folder)
	if not RunService:IsStudio() then return end
	if Workspace:GetAttribute("M6CBuildRarityGallery") ~= true then return end

	local baseItemIds = resolveBaseItemIds()
	if #baseItemIds == 0 then return end

	local old = world:FindFirstChild("M6CRarityGallery")
	if old then old:Destroy() end

	local folder = Instance.new("Folder")
	folder.Name = "M6CRarityGallery"
	folder:SetAttribute("Mode",if #baseItemIds == 1 then "SINGLE" else "MULTI_ROW")
	folder:SetAttribute("RowCount",#baseItemIds)
	folder.Parent = world

	local origin = DEFAULT_ORIGIN
	local attrOrigin = Workspace:GetAttribute("M6CGalleryOrigin")
	if typeof(attrOrigin) == "Vector3" then origin = attrOrigin end
	local requestedRowSpacing = tonumber(Workspace:GetAttribute("M6CGalleryRowSpacing"))
	local rowSpacing = requestedRowSpacing or 19

	local widest = 0
	for rowIndex, baseItemId in baseItemIds do
		local rowOrigin = Vector3.new(origin.X,origin.Y,origin.Z + (rowIndex - 1) * rowSpacing)
		local width = buildRow(folder,baseItemId,rowOrigin,rowIndex)
		widest = math.max(widest,width)
	end

	world:SetAttribute("M6CGalleryBuilt", true)
	world:SetAttribute("M6CGalleryRowCount", #baseItemIds)
	world:SetAttribute("M6CGalleryMode", if #baseItemIds == 1 then "SINGLE" else "MULTI_ROW")
	world:SetAttribute("M6CGalleryWidth",widest)
end

function Service.Start(world: Folder)
	build(world)
end

return Service
