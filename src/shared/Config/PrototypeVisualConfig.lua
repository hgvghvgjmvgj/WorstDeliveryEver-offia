--!strict

local LootCatalog = require(script.Parent:WaitForChild("LootCatalog"))
local RarityConfig = require(script.Parent:WaitForChild("RarityConfig"))

local items = {}
local order = {}

for _, sectionId in LootCatalog.SectionOrder do
	for _, baseItemId in LootCatalog.CoreBySection[sectionId] do
		table.insert(order, baseItemId)
	end
	for _, baseItemId in LootCatalog.HeroBySection[sectionId] do
		table.insert(order, baseItemId)
	end
end

-- M6B art rule: rarity must preserve the identity of the base object. Common is
-- the normal polished object, Uncommon is only subtly nicer, and the stronger
-- visual escalation increasingly comes from modular geometry/details rather
-- than turning the whole object into a rarity-colored glowing block.
local COLOR_BLEND_BY_RANK = table.freeze({
	[1] = 0.00,
	[2] = 0.04,
	[3] = 0.12,
	[4] = 0.20,
	[5] = 0.27,
	[6] = 0.33,
	[7] = 0.40,
	[8] = 0.44,
})

local function baseMaterialForRank(rank: number): Enum.Material
	-- Neon is reserved for rarity accent pieces, never the entire cargo body.
	if rank >= 5 then
		return Enum.Material.Metal
	end
	return Enum.Material.SmoothPlastic
end

for baseItemId, base in LootCatalog.ById do
	for _, rarity in RarityConfig.Order do
		local tier = RarityConfig.Tiers[rarity]
		local variantId = RarityConfig.MakeVariantId(baseItemId, rarity)
		local blend = COLOR_BLEND_BY_RANK[tier.Rank] or 0
		items[variantId] = table.freeze({
			Size = base.Size,
			Color = base.Color:Lerp(tier.Color, blend),
			BaseColor = base.Color,
			RarityColor = tier.Color,
			Material = baseMaterialForRank(tier.Rank),
			ModelKind = base.ModelKind,
			Rarity = rarity,
			RarityRank = tier.Rank,
		})
	end
end

-- Legacy presentation compatibility.
local legacy = {
	Box = { Size = Vector3.new(3.2, 3.2, 3.2), Color = Color3.fromRGB(202,151,93) },
	Lamp = { Size = Vector3.new(1.5, 8.5, 1.5), Color = Color3.fromRGB(242,214,100) },
	Chair = { Size = Vector3.new(5.2, 5.3, 4.2), Color = Color3.fromRGB(167,112,77) },
	Tire = { Size = Vector3.new(3.8, 3.8, 2.1), Color = Color3.fromRGB(52,54,59) },
	TV = { Size = Vector3.new(7.2, 4.5, 1.6), Color = Color3.fromRGB(58,68,83) },
}
for itemId, visual in legacy do
	if not items[itemId] then
		items[itemId] = table.freeze({
			Size = visual.Size,
			Color = visual.Color,
			BaseColor = visual.Color,
			RarityColor = Color3.fromRGB(205,210,218),
			Material = Enum.Material.SmoothPlastic,
			ModelKind = "Legacy",
			Rarity = "Common",
			RarityRank = 1,
		})
	end
end

return table.freeze({
	Order = table.freeze(order),
	Items = table.freeze(items),
})
