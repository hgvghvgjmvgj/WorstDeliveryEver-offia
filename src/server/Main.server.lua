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
local PlayerDataService = require(Services:WaitForChild("PlayerDataService"))
local ProgressionService = require(Services:WaitForChild("ProgressionService"))
local EconomyService = require(Services:WaitForChild("EconomyService"))
local UnloadService = require(Services:WaitForChild("UnloadService"))

RemoteService.Initialize()
CollisionService.Start()

local world = WorldService.Build()
WarehouseAccessService.Start(world)

BayService.Start(world)
ItemService.Start(world)
-- M5B supersedes the old M4.2 TV/Couch/Safe-specific overlay with a generalized
-- section catalog + rarity supply layer. M4.1's central replenishment cadence is
-- still ItemService-owned and remains unchanged underneath this layer.
LootRarityService.Start(world)
LootPresentationService.Start(world)
CarryService.Start(ItemService)

-- PlayerData owns the earliest PlayerRemoving connection. Progression/Economy
-- register OnLoaded callbacks immediately afterward; OnLoaded also replays any
-- profile that happened to finish loading during this startup window.
PlayerDataService.Start()
ProgressionService.Start()
EconomyService.Start()

UnloadService.Start(world, CarryService, EconomyService)

print("[ONE TRIP] M5B loot catalog + rarity foundation loaded")
