--!strict

local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService:WaitForChild("Services")

local RemoteService = require(Services:WaitForChild("RemoteService"))
local WorldService = require(Services:WaitForChild("WorldService"))
local CollisionService = require(Services:WaitForChild("CollisionService"))
local BayService = require(Services:WaitForChild("BayService"))
local ItemService = require(Services:WaitForChild("ItemService"))
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
CarryService.Start(ItemService)

-- Register profile consumers before loading profiles so restored progression and
-- Stock are hydrated exactly once when PlayerDataService fires OnLoaded.
ProgressionService.Start()
EconomyService.Start()
PlayerDataService.Start()

UnloadService.Start(world, CarryService, EconomyService)

print("[ONE TRIP] M4 persistence + progression foundation loaded")
