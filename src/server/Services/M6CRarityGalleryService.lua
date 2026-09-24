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

local function addLabel(root: BasePart, text: string, color: Color3)
	local gui = Instance.new("BillboardGui")
	gui.Name = "M6CGalleryLabel"
	gui.Adornee = root
	gui.Size = UDim2.fromOffset(150, 48)
	gui.StudsOffset = Vector3.new(0, root.Size.Y * 0.5 + 2.2, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 180
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

local function resolveBaseItemId(): string
	local requested = Workspace:GetAttribute("M6CGalleryBaseItemId")
	if typeof(requested) == "string" and LootCatalog.ById[requested] then return requested end
	return DEFAULT_ITEM
end

local function build(world: Folder)
	if not RunService:IsStudio() then return end
	if Workspace:GetAttribute("M6CBuildRarityGallery") ~= true then return end

	local baseItemId = resolveBaseItemId()
	local base = LootCatalog.ById[baseItemId]
	if not base then return end

	local old = world:FindFirstChild("M6CRarityGallery")
	if old then old:Destroy() end

	local folder = Instance.new("Folder")
	folder.Name = "M6CRarityGallery"
	folder:SetAttribute("BaseItemId", baseItemId)
	folder.Parent = world

	local origin = DEFAULT_ORIGIN
	local attrOrigin = Workspace:GetAttribute("M6CGalleryOrigin")
	if typeof(attrOrigin) == "Vector3" then origin = attrOrigin end

	local baseSize = base.Size
	local spacing = math.max(8.5, baseSize.X + 4.6)
	local totalWidth = spacing * (#RarityConfig.Order - 1)
	local firstX = origin.X - totalWidth * 0.5

	for index, rarity in RarityConfig.Order do
		local variantId = RarityConfig.MakeVariantId(baseItemId, rarity)
		local visual = PrototypeVisualConfig.Items[variantId]
		if visual then
			local root = Instance.new("Part")
			root.Name = ("%02d_%s_%s"):format(index, rarity, baseItemId)
			root.Size = visual.Size
			root.CFrame = CFrame.new(firstX + (index - 1) * spacing, origin.Y + visual.Size.Y * 0.5, origin.Z)
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
			root.Parent = folder
			addLabel(root, rarity:upper() .. "\n" .. base.Name:upper(), RarityConfig.Tiers[rarity].Color)
		end
	end

	world:SetAttribute("M6CGalleryBuilt", true)
	world:SetAttribute("M6CGalleryBaseItemId", baseItemId)
end

function Service.Start(world: Folder)
	build(world)
end

return Service
