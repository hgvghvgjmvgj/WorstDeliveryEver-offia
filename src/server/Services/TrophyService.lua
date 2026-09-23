--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CollectionConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("CollectionConfig"))
local LootCatalog = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LootCatalog"))

local BayService = require(script.Parent:WaitForChild("BayService"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local TrophyService = {}

local function makePart(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Color = color
	part.Material = material or Enum.Material.Metal
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function addLabel(part: BasePart, text: string)
	local gui = Instance.new("BillboardGui")
	gui.Name = "TrophyLabel"
	gui.Adornee = part
	gui.Size = UDim2.fromOffset(150, 42)
	gui.StudsOffset = Vector3.new(0, 2.8, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 58
	gui.Parent = part
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextScaled = true
	label.TextWrapped = true
	label.TextColor3 = Color3.fromRGB(245, 236, 188)
	label.TextStrokeTransparency = 0.3
	label.Parent = gui
end

local function addTrophyGeometry(model: Model, baseCFrame: CFrame, trophy)
	local pedestal = makePart(model, "Pedestal", Vector3.new(3.4, 0.65, 3.4), baseCFrame, Color3.fromRGB(56, 60, 68), Enum.Material.Metal)
	local displayCFrame = baseCFrame * CFrame.new(0, 1.55, 0)
	local display: Part
	if trophy.Shape == "Core" then
		display = makePart(model, "Award", Vector3.new(1.8, 1.8, 1.8), displayCFrame, trophy.Color, Enum.Material.Neon)
		display.Shape = Enum.PartType.Ball
	elseif trophy.Shape == "Safe" or trophy.Shape == "Case" or trophy.Shape == "Appliance" then
		display = makePart(model, "Award", Vector3.new(2.25, 2.55, 1.8), displayCFrame, trophy.Color, Enum.Material.Metal)
		local accent = makePart(model, "Accent", Vector3.new(1.25, 1.25, 0.18), displayCFrame * CFrame.new(0, 0, -1.0), trophy.Color:Lerp(Color3.new(1,1,1), 0.25), Enum.Material.Neon)
		accent.Transparency = 0.15
	elseif trophy.Shape == "Chair" then
		display = makePart(model, "Award", Vector3.new(2.2, 1.0, 2.0), displayCFrame * CFrame.new(0, -0.3, 0), trophy.Color, Enum.Material.Metal)
		makePart(model, "Back", Vector3.new(2.2, 2.0, 0.5), displayCFrame * CFrame.new(0, 0.65, 0.75), trophy.Color, Enum.Material.Metal)
	else
		display = makePart(model, "Award", Vector3.new(2.8, 0.75, 1.8), displayCFrame * CFrame.new(0, -0.2, 0), trophy.Color, Enum.Material.Metal)
		makePart(model, "Handle", Vector3.new(0.35, 2.3, 0.35), displayCFrame * CFrame.new(1.1, 0.65, 0.55) * CFrame.Angles(0, 0, math.rad(-25)), trophy.Color, Enum.Material.Metal)
	end
	addLabel(pedestal, trophy.Name)
end

local function clearShowcase(bay: Model)
	local existing = bay:FindFirstChild("MasteryShowcase")
	if existing then existing:Destroy() end
end

function TrophyService.RefreshPlayer(player: Player)
	local profile = PlayerDataService.GetProfile(player)
	local bay = BayService.GetBayModel(player)
	if not profile or not bay then return end
	clearShowcase(bay)

	local folder = Instance.new("Folder")
	folder.Name = "MasteryShowcase"
	folder.Parent = bay
	local pad = bay:FindFirstChild("BayPad")
	if not pad or not pad:IsA("BasePart") then return end

	local sectionCollection = profile.Collection and profile.Collection.Sections
	for index, sectionId in LootCatalog.SectionOrder do
		local section = sectionCollection and sectionCollection[sectionId]
		local rewards = section and section.RewardMilestones
		if typeof(rewards) == "table" and rewards["100"] == true then
			local trophy = CollectionConfig.Trophies[sectionId]
			if trophy then
				local model = Instance.new("Model")
				model.Name = sectionId .. "MasteryTrophy"
				model:SetAttribute("MasteryTrophy", true)
				model:SetAttribute("SectionId", sectionId)
				model:SetAttribute("OwnerUserId", player.UserId)
				model.Parent = folder
				local x = -15 + (index - 1) * 6
				local baseCFrame = pad.CFrame * CFrame.new(x, pad.Size.Y * 0.5 + 0.36, 13.0)
				addTrophyGeometry(model, baseCFrame, trophy)
			end
		end
	end
end

function TrophyService.Start()
	PlayerDataService.OnLoaded(function(player)
		task.defer(TrophyService.RefreshPlayer, player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		local bay = BayService.GetBayModel(player)
		if bay then clearShowcase(bay) end
	end)
end

return TrophyService
