--!strict

local LootCatalog = require(script.Parent:WaitForChild("LootCatalog"))
local RarityConfig = require(script.Parent:WaitForChild("RarityConfig"))

local LootEconomy = {}

-- M4.2 break-even philosophy carried forward: early/common Stock can repay
-- relatively quickly, while later-section and higher-rarity Stock asks for a
-- longer commitment. SELL and KEEP scale together instead of diverging.
function LootEconomy.BreakEvenMinutes(sectionIndex: number, rarityRank: number): number
	return 3.0 + math.max(0, sectionIndex - 1) * 1.2 + math.max(0, rarityRank - 1) * 0.6
end

function LootEconomy.For(baseItemId: string, rarity: string)
	local base = LootCatalog.ById[baseItemId]
	local tier = RarityConfig.Tiers[rarity]
	if not base or not tier then
		return nil
	end
	local sectionScale = base.SectionEconomicScale
	local rarityScale = tier.EconomicScale
	local sellValue = math.max(1, math.floor(base.BaseSell * sectionScale * rarityScale + 0.5))
	local breakEven = LootEconomy.BreakEvenMinutes(base.SectionIndex, tier.Rank)
	local passive = math.max(1, math.floor(sellValue / breakEven + 0.5))
	return {
		BaseItemId = baseItemId,
		SectionId = base.SectionId,
		SectionIndex = base.SectionIndex,
		Rarity = rarity,
		RarityRank = tier.Rank,
		SectionMultiplier = sectionScale,
		RarityMultiplier = rarityScale,
		SellValue = sellValue,
		PassivePerMinute = passive,
		BreakEvenMinutes = sellValue / passive,
	}
end

return table.freeze(LootEconomy)
