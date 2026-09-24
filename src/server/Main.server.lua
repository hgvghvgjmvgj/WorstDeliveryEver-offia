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
local M6A3IdentityService = require(Services:WaitForChild("M6A3IdentityService"))
local M6BStorageService = require(Services:WaitForChild("M6BStorageService"))
local M6BRestockPresentationService = require(Services:WaitForChild("M6BRestockPresentationService"))
local WarehouseAccessService = require(Services:WaitForChild("WarehouseAccessService"))
local CollisionService = require(Services:WaitForChild("CollisionService"))
local ClearanceService = require(Services:WaitForChild("ClearanceService"))
local BayService = require(Services:WaitForChild("BayService"))
local ItemService = require(Services:WaitForChild("ItemService"))
local LootRarityService = require(Services:WaitForChild("LootRarityService"))
local LootPresentationService = require(Services:WaitForChild("LootPresentationService"))
local CarryService = require(Services:WaitForChild("CarryService"))
local HandlingRuntimeService = require(Services:WaitForChild("HandlingRuntimeService"))
local PlayerDataService = require(Services:WaitForChild("PlayerDataService"))
local ProgressionService = require(Services:WaitForChild("ProgressionService"))
local TutorialService = require(Services:WaitForChild("TutorialService"))
local EconomyService = require(Services:WaitForChild("EconomyService"))
local TrophyService = require(Services:WaitForChild("TrophyService"))
local CollectionService = require(Services:WaitForChild("CollectionService"))
local UnloadService = require(Services:WaitForChild("UnloadService"))

RemoteService.Initialize()
CollisionService.Start()

local requestedMode = MacroLayoutConfig.ResolveMode(Workspace:GetAttribute("M6LayoutMode"))
local world = if requestedMode == "D" then M6A2WorldService.Build() else ComparisonWorldService.Build()
if requestedMode == "D" then
	M6A3IdentityService.Apply(world)
	M6BStorageService.Build(world)
end
WarehouseAccessService.Start(world)

BayService.Start(world)
ItemService.Start(world)
LootRarityService.Start(world)
if requestedMode == "D" then M6BRestockPresentationService.Start(world) end

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
if requestedMode == "D" then ClearanceService.Start(world, ItemService) end
CarryService.Start(ItemService)
HandlingRuntimeService.Start(world, CarryService)

PlayerDataService.Start()
ProgressionService.Start()
TutorialService.Start()
EconomyService.Start()
TrophyService.Start()
CollectionService.Start()

UnloadService.Start(world, CarryService, EconomyService, CollectionService)

print(("[ONE TRIP] M6B stylized storage foundation loaded - mode %s"):format(tostring(world:GetAttribute("M6A_Mode") or "?")))
