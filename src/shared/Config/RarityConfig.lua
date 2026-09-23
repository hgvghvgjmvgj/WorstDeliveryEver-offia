--!strict

local order = table.freeze({
	"Common",
	"Uncommon",
	"Rare",
	"Epic",
	"Legendary",
	"Mythic",
	"Cosmic",
	"Eternal",
})

local tiers = table.freeze({
	Common = table.freeze({ Rank = 1, Weight = 65.00, EconomicScale = 1.00, Color = Color3.fromRGB(205, 210, 218), Material = Enum.Material.SmoothPlastic }),
	Uncommon = table.freeze({ Rank = 2, Weight = 20.00, EconomicScale = 1.25, Color = Color3.fromRGB(92, 211, 122), Material = Enum.Material.SmoothPlastic }),
	Rare = table.freeze({ Rank = 3, Weight = 9.00, EconomicScale = 1.60, Color = Color3.fromRGB(77, 154, 255), Material = Enum.Material.Metal }),
	Epic = table.freeze({ Rank = 4, Weight = 4.00, EconomicScale = 2.20, Color = Color3.fromRGB(176, 90, 255), Material = Enum.Material.Metal }),
	Legendary = table.freeze({ Rank = 5, Weight = 1.40, EconomicScale = 3.10, Color = Color3.fromRGB(255, 184, 57), Material = Enum.Material.Neon, SoloCap = 2, FullServerCap = 4, ClaimCooldownMin = 45, ClaimCooldownMax = 75 }),
	Mythic = table.freeze({ Rank = 6, Weight = 0.45, EconomicScale = 4.50, Color = Color3.fromRGB(255, 77, 126), Material = Enum.Material.Neon, SoloCap = 1, FullServerCap = 2, ClaimCooldownMin = 75, ClaimCooldownMax = 120 }),
	Cosmic = table.freeze({ Rank = 7, Weight = 0.13, EconomicScale = 6.80, Color = Color3.fromRGB(87, 231, 255), Material = Enum.Material.Neon, SoloCap = 1, FullServerCap = 2, ClaimCooldownMin = 120, ClaimCooldownMax = 180 }),
	Eternal = table.freeze({ Rank = 8, Weight = 0.02, EconomicScale = 10.00, Color = Color3.fromRGB(255, 244, 151), Material = Enum.Material.Neon, SoloCap = 1, FullServerCap = 1, ClaimCooldownMin = 180, ClaimCooldownMax = 300 }),
})

local RarityConfig = {
	Order = order,
	Tiers = tiers,
	VariantSeparator = "__",
	FullServerPlayers = 12,

	-- M5 test values only. Debug forcing exists because Cosmic/Eternal should not
	-- be validated by waiting for natural RNG.
	HeroChanceByRarity = table.freeze({
		Legendary = 0.12,
		Mythic = 0.22,
		Cosmic = 0.38,
		Eternal = 0.55,
	}),
}

function RarityConfig.MakeVariantId(baseItemId: string, rarity: string): string
	if rarity == "Common" then
		return baseItemId
	end
	return baseItemId .. RarityConfig.VariantSeparator .. rarity
end

function RarityConfig.ParseVariantId(itemId: string): (string, string)
	local base, rarity = string.match(itemId, "^(.-)" .. RarityConfig.VariantSeparator .. "([%a]+)$")
	if base and rarity and tiers[rarity] then
		return base, rarity
	end
	return itemId, "Common"
end

function RarityConfig.Rank(rarity: string): number
	local tier = tiers[rarity]
	return if tier then tier.Rank else 1
end

return table.freeze(RarityConfig)
