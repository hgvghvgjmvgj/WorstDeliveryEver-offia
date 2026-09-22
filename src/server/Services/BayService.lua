--!strict

local Players = game:GetService("Players")

local BayService = {}

local worldRoot: Folder? = nil
local baysFolder: Folder? = nil

local bayOwners: {[number]: Player} = {}
local playerBays: {[Player]: number} = {}
local characterConnections: {[Player]: RBXScriptConnection} = {}

local function getBay(index: number): Model?
	if not baysFolder then
		return nil
	end
	local bay = baysFolder:FindFirstChild(("Bay%02d"):format(index))
	if bay and bay:IsA("Model") then
		return bay
	end
	return nil
end

local function updateBayPresentation(index: number, player: Player?)
	local bay = getBay(index)
	if not bay then
		return
	end

	local ownerUserId = if player then player.UserId else 0
	local ownerName = if player then player.DisplayName else ""

	bay:SetAttribute("OwnerUserId", ownerUserId)
	bay:SetAttribute("OwnerName", ownerName)

	local anchor = bay:FindFirstChild("OwnerLabelAnchor")
	local billboard = anchor and anchor:FindFirstChild("OwnerLabel")
	local label = billboard and billboard:FindFirstChild("Text")

	if label and label:IsA("TextLabel") then
		if player then
			label.Text = string.format("%s\nBAY %02d", player.DisplayName, index)
			label.TextColor3 = Color3.fromRGB(236, 241, 248)
		else
			label.Text = string.format("OPEN BAY %02d", index)
			label.TextColor3 = Color3.fromRGB(185, 193, 207)
		end
	end
end

local function placeCharacterAtBay(player: Player, character: Model)
	local index = playerBays[player]
	if not index then
		return
	end

	local bay = getBay(index)
	if not bay then
		return
	end

	local marker = bay:FindFirstChild("SpawnMarker")
	if not marker or not marker:IsA("BasePart") then
		return
	end

	local root = character:WaitForChild("HumanoidRootPart", 8)
	local humanoid = character:WaitForChild("Humanoid", 8)
	if not root or not humanoid or not root:IsA("BasePart") or not humanoid:IsA("Humanoid") then
		return
	end

	task.defer(function()
		if character.Parent and player.Parent and playerBays[player] == index then
			character:PivotTo(marker.CFrame)
		end
	end)
end

local function firstAvailableBay(): number?
	for index = 1, 12 do
		if not bayOwners[index] then
			return index
		end
	end
	return nil
end

local function assignPlayer(player: Player)
	if playerBays[player] then
		return
	end

	local index = firstAvailableBay()
	if not index then
		warn(("[ONE TRIP] No bay available for %s"):format(player.Name))
		player:SetAttribute("BayIndex", nil)
		return
	end

	bayOwners[index] = player
	playerBays[player] = index
	player:SetAttribute("BayIndex", index)
	updateBayPresentation(index, player)

	if characterConnections[player] then
		characterConnections[player]:Disconnect()
	end

	characterConnections[player] = player.CharacterAdded:Connect(function(character)
		placeCharacterAtBay(player, character)
	end)

	if player.Character then
		task.spawn(placeCharacterAtBay, player, player.Character)
	end
end

local function releasePlayer(player: Player)
	local index = playerBays[player]
	if index and bayOwners[index] == player then
		bayOwners[index] = nil
		updateBayPresentation(index, nil)
	end

	playerBays[player] = nil
	player:SetAttribute("BayIndex", nil)

	local connection = characterConnections[player]
	if connection then
		connection:Disconnect()
		characterConnections[player] = nil
	end
end

function BayService.GetBayIndex(player: Player): number?
	return playerBays[player]
end

function BayService.GetBayModel(player: Player): Model?
	local index = playerBays[player]
	if not index then
		return nil
	end
	return getBay(index)
end

function BayService.Start(root: Folder)
	worldRoot = root
	baysFolder = root:WaitForChild("Bays") :: Folder

	for index = 1, 12 do
		updateBayPresentation(index, nil)
	end

	Players.PlayerAdded:Connect(assignPlayer)
	Players.PlayerRemoving:Connect(releasePlayer)

	for _, player in Players:GetPlayers() do
		assignPlayer(player)
	end
end

return BayService
