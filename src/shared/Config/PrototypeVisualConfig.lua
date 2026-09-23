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

for baseItemId, base in LootCatalog.ById do
	for _, rarity in RarityConfig.Order do
		local tier = RarityConfig.Tiers[rarity]
		local variantId = RarityConfig.MakeVariantId(baseItemId, rarity)
		local blend = math.clamp((tier.Rank - 1) * 0.09, 0, 0.58)
		items[variantId] = table.freeze({
			Size = base.Size,
			Color = base.Color:Lerp(tier.Color, blend),
			BaseColor = base.Color,
			RarityColor = tier.Color,
			Material = tier.Material,
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
