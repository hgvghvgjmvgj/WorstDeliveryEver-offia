--!strict

local Players = game:GetService("Players")

local LootPresentation = require(script.Parent:WaitForChild("LootPresentation"))

local LootPresentationService = {}
local worldRoot: Folder? = nil

local function itemIdFromPart(part: BasePart): string?
	local attr = part:GetAttribute("ItemId")
	if typeof(attr) == "string" and attr ~= "" then return attr end
	local itemId = string.match(part.Name, "^Carry_(.+)_%d+$")
	if itemId and itemId ~= "" then return itemId end
	return nil
end

local function applyPart(part: BasePart)
	local itemId = itemIdFromPart(part)
	if not itemId then return end
	if part:GetAttribute("PresentationAppliedItemId") == itemId then return end
	LootPresentation.Apply(part, itemId, false)
end

local function deferredApply(instance: Instance)
	if not instance:IsA("BasePart") then return end
	task.defer(function()
		if instance.Parent then applyPart(instance) end
	end)
end

local function watchCharacter(character: Model)
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then applyPart(descendant) end
	end
	character.DescendantAdded:Connect(deferredApply)
end

local function watchPlayer(player: Player)
	player.CharacterAdded:Connect(watchCharacter)
	if player.Character then watchCharacter(player.Character) end
end

function LootPresentationService.Start(root: Folder)
	worldRoot = root
	for _, player in Players:GetPlayers() do watchPlayer(player) end
	Players.PlayerAdded:Connect(watchPlayer)

	-- Stock displays and any presentation-only loot under the warehouse inherit
	-- the same rarity/model treatment as carried objects.
	for _, descendant in root:GetDescendants() do
		if descendant:IsA("BasePart") then applyPart(descendant) end
	end
	root.DescendantAdded:Connect(deferredApply)
end

return LootPresentationService
