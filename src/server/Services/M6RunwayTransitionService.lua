--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MacroLayoutConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("MacroLayoutConfig"))

local Service = {}

function Service.Apply(root: Folder)
	if root:GetAttribute("MacroLayoutMode") ~= "D" then return end
	local gameplay = root:FindFirstChild("WarehouseGameplay")
	local sections = gameplay and gameplay:FindFirstChild("Sections")
	local routes = gameplay and gameplay:FindFirstChild("RouteNetwork")
	if not sections or not routes then return end

	local folder = Instance.new("Folder")
	folder.Name = "TransitionCrossAisles"
	folder.Parent = routes
	local config = MacroLayoutConfig.OptionD

	for orderIndex, sectionId in MacroLayoutConfig.SectionOrder do
		if orderIndex == 1 then continue end
		local section = sections:FindFirstChild(sectionId)
		local frontZ = section and section:GetAttribute("FrontZ")
		if typeof(frontZ) ~= "number" then continue end

		local part = Instance.new("Part")
		part.Name = sectionId .. "TransitionCrossAisle"
		part.Size = Vector3.new(config.RunwayWidth - 10, 0.09, config.CrossAisleWidth)
		part.CFrame = CFrame.new(0, 0.16, frontZ)
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.Material = Enum.Material.SmoothPlastic
		part.Color = Color3.fromRGB(132, 138, 148)
		part.Transparency = 0.52
		part:SetAttribute("RouteType", "TransitionCrossAisle")
		part:SetAttribute("SectorName", sectionId)
		part.Parent = folder
	end
end

return Service
