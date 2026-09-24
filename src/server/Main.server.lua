--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local MacroLayoutConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("MacroLayoutConfig"))
local LootCatalog = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LootCatalog"))
local Services = ServerScriptService:WaitForChild("Services")

local RemoteService = require(Services:WaitForChild("RemoteService"))
local ComparisonWorldService = require(Services:WaitForChild("M6WorldService"))
local M6A2WorldService = require(Services:WaitForChild("M6A2WorldService"))
local WarehouseAccessService = require(Services:WaitForChild("WarehouseAccessService"))
local CollisionService = require(Services:WaitForChild("CollisionService"))
local BayService = require(Services:WaitForChild("BayService"))
local ItemService = require(Services:WaitForChild("ItemService"))
local LootRarityService = require(Services:WaitForChild("LootRarityService"))
local LootPresentationService = require(Services:WaitForChild("LootPresentationService"))
local CarryService = require(Services:WaitForChild("CarryService"))
local HandlingRuntimeService = require(Services:WaitForChild("HandlingRuntimeService"))
local PlayerDataService = require(Services:WaitForChild("PlayerDataService"))
local ProgressionService = require(Services:WaitForChild("ProgressionService"))
local EconomyService = require(Services:WaitForChild("EconomyService"))
local TrophyService = require(Services:WaitForChild("TrophyService"))
local CollectionService = require(Services:WaitForChild("CollectionService"))
local UnloadService = require(Services:WaitForChild("UnloadService"))

RemoteService.Initialize()
CollisionService.Start()

local requestedMode = MacroLayoutConfig.ResolveMode(Workspace:GetAttribute("M6LayoutMode"))
local world = if requestedMode == "D" then M6A2WorldService.Build() else ComparisonWorldService.Build()
WarehouseAccessService.Start(world)

BayService.Start(world)
ItemService.Start(world)
LootRarityService.Start(world)

-- Replace obsolete six-section debug counts with actual M6A.2 catalog counts.
local coreCount = 0
local heroCount = 0
for _, sectionId in LootCatalog.SectionOrder do
	coreCount += #(LootCatalog.CoreBySection[sectionId] or {})
	heroCount += #(LootCatalog.HeroBySection[sectionId] or {})
end
world:SetAttribute("M5BBaseLootCount", coreCount)
world:SetAttribute("M5BHeroLootCount", heroCount)
world:SetAttribute("M6A2CoreBaseLootCount", coreCount)
world:SetAttribute("M6A2HeroLootCount", heroCount)

LootPresentationService.Start(world)
CarryService.Start(ItemService)
HandlingRuntimeService.Start(world, CarryService)

PlayerDataService.Start()
ProgressionService.Start()
EconomyService.Start()
TrophyService.Start()
CollectionService.Start()

UnloadService.Start(world, CarryService, EconomyService, CollectionService)

print(("[ONE TRIP] M6A.2 15-section depth + speed/carry proof loaded - mode %s"):format(tostring(world:GetAttribute("M6A_Mode") or "?")))
