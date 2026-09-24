--!strict

local function frozen<T>(value: T): T
	return table.freeze(value)
end

local ORDER = frozen({
	"Receiving", "HomeBasics", "Appliances", "Furniture", "Electronics",
	"Recreation", "GarageAuto", "Construction", "HeavyGoods", "Industrial",
	"PremiumInteriors", "LuxuryGoods", "ArtCollectibles", "Secure", "RestrictedPrototype",
})

-- M6A.3 economy correction: EconomicScale is a compensating catalog multiplier,
-- not a visual/progression index. It is intentionally non-monotonic in a few
-- places because authored BaseSell values differ sharply by section. What must
-- rise smoothly is the actual resulting cargo value, not the raw multiplier.
local SECTIONS = frozen({
	Receiving = frozen({ Index=1, DisplayName="RECEIVING & RETURNS", Length=60, Depth=1, EconomicScale=1.00, CargoTheme="ordinary warehouse intake", StructureKind="Pallets", FallbackItemId="Box", SupplySolo=11, SupplyFull=15, Color=Color3.fromRGB(76,92,104) }),
	HomeBasics = frozen({ Index=2, DisplayName="HOME BASICS", Length=60, Depth=1, EconomicScale=1.60, CargoTheme="cheap common household goods", StructureKind="HomeRows", FallbackItemId="Chair", SupplySolo=11, SupplyFull=15, Color=Color3.fromRGB(101,91,79) }),
	Appliances = frozen({ Index=3, DisplayName="APPLIANCES", Length=65, Depth=1, EconomicScale=1.90, CargoTheme="large desirable household machines", StructureKind="ApplianceRows", FallbackItemId="TV", SupplySolo=10, SupplyFull=14, Color=Color3.fromRGB(70,91,116) }),
	Furniture = frozen({ Index=4, DisplayName="FURNITURE", Length=70, Depth=1, EconomicScale=2.90, CargoTheme="bulky household cargo", StructureKind="FurnitureBays", FallbackItemId="Chair", SupplySolo=10, SupplyFull=14, Color=Color3.fromRGB(104,83,68) }),
	Electronics = frozen({ Index=5, DisplayName="ELECTRONICS", Length=72, Depth=1, EconomicScale=3.20, CargoTheme="high-demand modern technology", StructureKind="ElectronicsRows", FallbackItemId="TV", SupplySolo=10, SupplyFull=14, Color=Color3.fromRGB(65,82,108) }),
	Recreation = frozen({ Index=6, DisplayName="RECREATION", Length=75, Depth=2, EconomicScale=4.60, CargoTheme="fun expensive recreation equipment", StructureKind="RecreationFloor", FallbackItemId="Chair", SupplySolo=9, SupplyFull=13, Color=Color3.fromRGB(91,72,108) }),
	GarageAuto = frozen({ Index=7, DisplayName="GARAGE & AUTO", Length=80, Depth=2, EconomicScale=5.25, CargoTheme="garage tools, vehicle parts and workshop goods", StructureKind="GarageRacks", FallbackItemId="Tire", SupplySolo=9, SupplyFull=13, Color=Color3.fromRGB(91,82,72) }),
	Construction = frozen({ Index=8, DisplayName="CONSTRUCTION", Length=85, Depth=2, EconomicScale=6.85, CargoTheme="commercial job-site equipment", StructureKind="ConstructionStaging", FallbackItemId="Tire", SupplySolo=8, SupplyFull=12, Color=Color3.fromRGB(105,94,66) }),
	HeavyGoods = frozen({ Index=9, DisplayName="HEAVY EQUIPMENT", Length=90, Depth=2, EconomicScale=14.50, CargoTheme="physically intimidating heavy cargo", StructureKind="HeavyPads", FallbackItemId="Tire", SupplySolo=8, SupplyFull=12, Color=Color3.fromRGB(93,89,73) }),
	Industrial = frozen({ Index=10, DisplayName="INDUSTRIAL MACHINERY", Length=95, Depth=2, EconomicScale=18.50, CargoTheme="major industrial hardware", StructureKind="MachineBays", FallbackItemId="Tire", SupplySolo=8, SupplyFull=11, Color=Color3.fromRGB(82,86,78) }),
	PremiumInteriors = frozen({ Index=11, DisplayName="PREMIUM INTERIORS", Length=100, Depth=3, EconomicScale=16.00, CargoTheme="expensive designer living spaces", StructureKind="PremiumShowrooms", FallbackItemId="Chair", SupplySolo=7, SupplyFull=10, Color=Color3.fromRGB(105,92,86) }),
	LuxuryGoods = frozen({ Index=12, DisplayName="LUXURY GOODS", Length=105, Depth=3, EconomicScale=17.80, CargoTheme="fictional designer and prestige goods", StructureKind="LuxuryDisplays", FallbackItemId="Box", SupplySolo=7, SupplyFull=10, Color=Color3.fromRGB(103,85,75) }),
	ArtCollectibles = frozen({ Index=13, DisplayName="ART & COLLECTIBLES", Length=110, Depth=3, EconomicScale=20.70, CargoTheme="rare collector property and museum cargo", StructureKind="GalleryStorage", FallbackItemId="Box", SupplySolo=6, SupplyFull=9, Color=Color3.fromRGB(91,80,78) }),
	Secure = frozen({ Index=14, DisplayName="SECURE VAULT", Length=120, Depth=3, EconomicScale=50.00, CargoTheme="extreme-value protected goods", StructureKind="VaultCells", FallbackItemId="TV", SupplySolo=6, SupplyFull=9, Color=Color3.fromRGB(79,73,70) }),
	RestrictedPrototype = frozen({ Index=15, DisplayName="RESTRICTED / PROTOTYPE STORAGE", Length=130, Depth=3, EconomicScale=28.50, CargoTheme="experimental and strange one-of-one cargo", StructureKind="PrototypeContainment", FallbackItemId="Box", SupplySolo=5, SupplyFull=8, Color=Color3.fromRGB(61,75,80) }),
})

local totalLength = 0
for _, sectionId in ORDER do totalLength += SECTIONS[sectionId].Length end

return table.freeze({ Order=ORDER, Sections=SECTIONS, TotalLength=totalLength, LaunchSectionCount=#ORDER })
