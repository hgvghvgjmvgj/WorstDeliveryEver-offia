--!strict

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))
local RemoteService = require(script.Parent:WaitForChild("RemoteService"))

local TutorialService = {}

-- Kept separate during the M6A.3 structural proof so onboarding can be tested
-- without another migration of the already-active gameplay profile namespace.
-- This stores only one boolean; clearance itself remains fully derived/live.
local store = DataStoreService:GetDataStore("OneTripTutorial_M6A3_v1")
local actionRemote: RemoteEvent
local loaded: {[Player]: boolean} = {}
local completing: {[Player]: boolean} = {}

local function keyFor(player: Player): string
	return "tutorial_" .. tostring(player.UserId)
end

local function setState(player: Player, completed: boolean)
	player:SetAttribute("TutorialCompleted", completed)
	player:SetAttribute("TutorialReady", true)
	loaded[player] = true
end

local function loadPlayer(player: Player)
	if loaded[player] or not player.Parent then return end
	player:SetAttribute("TutorialReady", false)
	local ok, result = pcall(function()
		return store:GetAsync(keyFor(player))
	end)
	if not player.Parent then return end
	if ok then
		setState(player, result == true)
	else
		-- Studio without API access should still be able to run the onboarding
		-- every session; completion remains true for the rest of that session.
		if RunService:IsStudio() then
			warn("[ONE TRIP] tutorial persistence unavailable in Studio; using session-only state:", result)
			setState(player, false)
		else
			warn("[ONE TRIP] tutorial persistence load failed; onboarding will run safely:", result)
			setState(player, false)
		end
	end
end

local function complete(player: Player)
	if not loaded[player] or completing[player] or player:GetAttribute("TutorialCompleted") == true then return end
	completing[player] = true
	setState(player, true)
	task.spawn(function()
		local ok, err = pcall(function()
			store:UpdateAsync(keyFor(player), function(_old)
				return true
			end)
		end)
		if not ok then
			warn("[ONE TRIP] tutorial completion save failed:", err)
		end
		completing[player] = nil
	end)
end

function TutorialService.Start()
	actionRemote = RemoteService.Get(RemoteNames.TutorialAction)
	actionRemote.OnServerEvent:Connect(function(player: Player, action: any)
		if action == "Complete" then complete(player) end
	end)
	Players.PlayerAdded:Connect(function(player)
		task.spawn(loadPlayer, player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		loaded[player] = nil
		completing[player] = nil
	end)
	for _, player in Players:GetPlayers() do task.spawn(loadPlayer, player) end
end

return TutorialService
