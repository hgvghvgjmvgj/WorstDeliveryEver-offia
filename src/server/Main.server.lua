--!strict

local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService:WaitForChild("Services")

local RemoteService = require(Services:WaitForChild("RemoteService"))
local WorldService = require(Services:WaitForChild("WorldService"))
local CollisionService = require(Services:WaitForChild("CollisionService"))
local BayService = require(Services:WaitForChild("BayService"))
local ItemService = require(Services:WaitForChild("ItemService"))
local PremiumSupplyService = require(Services:WaitForChild("PremiumSupplyService"))
local CarryService = require(Services:WaitForChild("CarryService"))
local PlayerDataService = require(Services:WaitForChild("PlayerDataService"))
local ProgressionService = require(Services:WaitForChild("ProgressionService"))
local EconomyService = require(Services:WaitForChild("EconomyService"))
local UnloadService = require(Services:WaitForChild("UnloadService"))

RemoteService.Initialize()
CollisionService.Start()

local world = WorldService.Build()

BayService.Start(world)
ItemService.Start(world)
PremiumSupplyService.Start(world)
CarryService.Start(ItemService)

-- PlayerData owns the earliest PlayerRemoving connection. Progression/Economy
-- register OnLoaded callbacks immediately afterward; OnLoaded also replays any
-- profile that happened to finish loading during this startup window.
PlayerDataService.Start()
ProgressionService.Start()
EconomyService.Start()

UnloadService.Start(world, CarryService, EconomyService)

print("[ONE TRIP] M4.2 passive economy + premium opportunity tuning loaded")
