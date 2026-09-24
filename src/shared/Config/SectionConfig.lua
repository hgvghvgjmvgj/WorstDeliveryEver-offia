--!strict

local function frozen<T>(value: T): T
	return table.freeze(value)
end

local ORDER = frozen({
	"Receiving",
	"HomeBasics",
	"Appliances",
	"Furniture",
	"Electronics",
	"Recreation",
	"GarageAuto",
	"Construction",
	"HeavyGoods",
	"Industrial",
	"PremiumInteriors",
	"LuxuryGoods",
	"ArtCollectibles",
	"Secure",
	"RestrictedPrototype",
})

local SECTIONS = frozen({
	Receiving = frozen({ Index = 1, DisplayName = "RECEIVING & RETURNS", Length = 60, Depth = 1, EconomicScale = 1.00, CargoTheme = "ordinary warehouse intake", StructureKind = "Pallets", FallbackItemId = "Box", SupplySolo = 11, SupplyFull = 15 }),
	HomeBasics = frozen({ Index = 2, DisplayName = "HOME BASICS", Length = 60, Depth = 1, EconomicScale = 1.45, CargoTheme = "cheap common household goods", StructureKind = "HomeRows", FallbackItemId = "Chair", SupplySolo = 11, SupplyFull = 15 }),
	Appliances = frozen({ Index = 3, DisplayName = "APPLIANCES", Length = 65, Depth = 1, EconomicScale = 2.20, CargoTheme = "large desirable household machines", StructureKind = "ApplianceRows", FallbackItemId = "TV", SupplySolo = 10, SupplyFull = 14 }),
	Furniture = frozen({ Index = 4, DisplayName = "FURNITURE", Length = 70, Depth = 1, EconomicScale = 4.80, CargoTheme = "bulky household cargo", StructureKind = "FurnitureBays", FallbackItemId = "Chair", SupplySolo = 10, SupplyFull = 14 }),
	Electronics = frozen({ Index = 5, DisplayName = "ELECTRONICS", Length = 72, Depth = 1, EconomicScale = 6.00, CargoTheme = "high-demand modern technology", StructureKind = "ElectronicsRows", FallbackItemId = "TV", SupplySolo = 10, SupplyFull = 14 }),
	Recreation = frozen({ Index = 6, DisplayName = "RECREATION", Length = 75, Depth = 2, EconomicScale = 7.00, CargoTheme = "fun expensive recreation equipment", StructureKind = "RecreationFloor", FallbackItemId = "Chair", SupplySolo = 9, SupplyFull = 13 }),
	GarageAuto = frozen({ Index = 7, DisplayName = "GARAGE & AUTO", Length = 80, Depth = 2, EconomicScale = 8.00, CargoTheme = "garage tools, vehicle parts and workshop goods", StructureKind = "GarageRacks", FallbackItemId = "Tire", SupplySolo = 9, SupplyFull = 13 }),
	Construction = frozen({ Index = 8, DisplayName = "CONSTRUCTION", Length = 85, Depth = 2, EconomicScale = 9.00, CargoTheme = "commercial job-site equipment", StructureKind = "ConstructionStaging", FallbackItemId = "Tire", SupplySolo = 8, SupplyFull = 12 }),
	HeavyGoods = frozen({ Index = 9, DisplayName = "HEAVY EQUIPMENT", Length = 90, Depth = 2, EconomicScale = 10.00, CargoTheme = "physically intimidating heavy cargo", StructureKind = "HeavyPads", FallbackItemId = "Tire", SupplySolo = 8, SupplyFull = 12 }),
	Industrial = frozen({ Index = 10, DisplayName = "INDUSTRIAL MACHINERY", Length = 95, Depth = 2, EconomicScale = 21.00, CargoTheme = "major industrial hardware", StructureKind = "MachineBays", FallbackItemId = "Tire", SupplySolo = 8, SupplyFull = 11 }),
	PremiumInteriors = frozen({ Index = 11, DisplayName = "PREMIUM INTERIORS", Length = 100, Depth = 3, EconomicScale = 24.00, CargoTheme = "expensive designer living spaces", StructureKind = "PremiumShowrooms", FallbackItemId = "Chair", SupplySolo = 7, SupplyFull = 10 }),
	LuxuryGoods = frozen({ Index = 12, DisplayName = "LUXURY GOODS", Length = 105, Depth = 3, EconomicScale = 28.00, CargoTheme = "fictional designer and prestige goods", StructureKind = "LuxuryDisplays", FallbackItemId = "Box", SupplySolo = 7, SupplyFull = 10 }),
	ArtCollectibles = frozen({ Index = 13, DisplayName = "ART & COLLECTIBLES", Length = 110, Depth = 3, EconomicScale = 34.00, CargoTheme = "rare collector property and museum cargo", StructureKind = "GalleryStorage", FallbackItemId = "Box", SupplySolo = 6, SupplyFull = 9 }),
	Secure = frozen({ Index = 14, DisplayName = "SECURE VAULT", Length = 120, Depth = 3, EconomicScale = 45.00, CargoTheme = "extreme-value protected goods", StructureKind = "VaultCells", FallbackItemId = "TV", SupplySolo = 6, SupplyFull = 9 }),
	RestrictedPrototype = frozen({ Index = 15, DisplayName = "RESTRICTED / PROTOTYPE STORAGE", Length = 130, Depth = 3, EconomicScale = 55.00, CargoTheme = "experimental and strange one-of-one cargo", StructureKind = "PrototypeContainment", FallbackItemId = "Box", SupplySolo = 5, SupplyFull = 8 }),
})

local totalLength = 0
for _, sectionId in ORDER do
	totalLength += SECTIONS[sectionId].Length
end

return table.freeze({
	Order = ORDER,
	Sections = SECTIONS,
	TotalLength = totalLength,
	LaunchSectionCount = #ORDER,
})
