--!strict

local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService:WaitForChild("Services")

local RemoteService = require(Services:WaitForChild("RemoteService"))
local WorldService = require(Services:WaitForChild("WorldService"))
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

local world = WorldService.Build()
WarehouseAccessService.Start(world)

BayService.Start(world)
ItemService.Start(world)
LootRarityService.Start(world)
LootPresentationService.Start(world)
CarryService.Start(ItemService)
HandlingRuntimeService.Start(world, CarryService)

-- PlayerData owns persistence/session lifecycle. The later services register
-- OnLoaded callbacks; OnLoaded safely replays profiles that already completed.
PlayerDataService.Start()
ProgressionService.Start()
EconomyService.Start()
TrophyService.Start()
CollectionService.Start()

UnloadService.Start(world, CarryService, EconomyService, CollectionService)

print("[ONE TRIP] M5C collection + section mastery + rare finds loaded")
