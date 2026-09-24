--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local PrototypeVisualConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PrototypeVisualConfig"))

local Service = {}

local applied = 0

local function itemIdFromPart(part: BasePart): string?
	local attr = part:GetAttribute("ItemId")
	if typeof(attr) == "string" and attr ~= "" then return attr end
	local carry = string.match(part.Name, "^Carry_(.+)_%d+$")
	return carry
end

local function visualPart(root: BasePart, folder: Folder, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material?, transparency: number?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = Vector3.new(math.max(0.08,size.X),math.max(0.08,size.Y),math.max(0.08,size.Z))
	p.CFrame = root.CFrame * offset
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Transparency = transparency or 0
	p.Anchored = false
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.CastShadow = true
	p:SetAttribute("M6C1ModelOverrideVisual", true)
	p.Parent = folder
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = p
	weld.Parent = p
	return p
end

local function ball(root: BasePart, folder: Folder, name: string, diameter: number, offset: CFrame, color: Color3, material: Enum.Material?, transparency: number?): Part
	local p = visualPart(root,folder,name,Vector3.new(diameter,diameter,diameter),offset,color,material,transparency)
	p.Shape = Enum.PartType.Ball
	return p
end

local function cylinder(root: BasePart, folder: Folder, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material?, transparency: number?): Part
	local p = visualPart(root,folder,name,size,offset,color,material,transparency)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function hideOldVisuals(root: BasePart)
	root.Transparency = 1
	for _, folderName in {"M6CArt","M6CIdentity"} do
		local folder = root:FindFirstChild(folderName)
		if folder then
			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("BasePart") then descendant.Transparency = 1 end
			end
		end
	end
end

local function buildCouch(root: BasePart, folder: Folder, visual: any)
	local size = root.Size
	local base = visual.BaseColor or visual.Color or Color3.fromRGB(87,139,184)
	local cushion = base:Lerp(Color3.new(1,1,1),0.10)
	local dark = base:Lerp(Color3.new(0,0,0),0.26)
	local trim = visual.RarityColor or base:Lerp(Color3.new(1,1,1),0.20)

	-- A real readable sofa silhouette: low seat, tall back, thick arms, separate cushions.
	visualPart(root,folder,"CouchSeatBase",Vector3.new(size.X*0.84,size.Y*0.28,size.Z*0.76),CFrame.new(0,-size.Y*0.18,0),dark,Enum.Material.SmoothPlastic,0)
	visualPart(root,folder,"CouchBack",Vector3.new(size.X*0.88,size.Y*0.62,size.Z*0.20),CFrame.new(0,size.Y*0.18,size.Z*0.34)*CFrame.Angles(math.rad(-7),0,0),base,Enum.Material.SmoothPlastic,0)
	for _, x in {-size.X*0.45,size.X*0.45} do
		visualPart(root,folder,"CouchArm",Vector3.new(size.X*0.12,size.Y*0.46,size.Z*0.76),CFrame.new(x,-size.Y*0.02,0),base,Enum.Material.SmoothPlastic,0)
	end

	for index, x in {-size.X*0.27,0,size.X*0.27} do
		visualPart(root,folder,"SeatCushion"..index,Vector3.new(size.X*0.25,size.Y*0.18,size.Z*0.62),CFrame.new(x,-size.Y*0.06,-size.Z*0.03),cushion,Enum.Material.SmoothPlastic,0)
		visualPart(root,folder,"BackCushion"..index,Vector3.new(size.X*0.25,size.Y*0.40,size.Z*0.15),CFrame.new(x,size.Y*0.18,size.Z*0.25)*CFrame.Angles(math.rad(-8),0,0),cushion,Enum.Material.SmoothPlastic,0)
	end

	for _, x in {-size.X*0.37,size.X*0.37} do
		for _, z in {-size.Z*0.25,size.Z*0.25} do
			visualPart(root,folder,"CouchLeg",Vector3.new(size.X*0.045,size.Y*0.18,size.Z*0.06),CFrame.new(x,-size.Y*0.48,z),Color3.fromRGB(60,53,47),Enum.Material.Metal,0)
		end
	end

	local rank = tonumber(visual.RarityRank) or 1
	if rank >= 4 then
		visualPart(root,folder,"CouchPrestigeRail",Vector3.new(size.X*0.72,math.max(0.10,size.Y*0.035),0.10),CFrame.new(0,size.Y*0.47,size.Z*0.43),trim,Enum.Material.Neon,0.18)
	end
end

local function buildGamingPC(root: BasePart, folder: Folder, visual: any)
	local size = root.Size
	local rarity = visual.RarityColor or Color3.fromRGB(67,205,221)
	local chassis = Color3.fromRGB(30,35,44)
	local frame = Color3.fromRGB(67,74,86)
	local glassColor = Color3.fromRGB(106,145,166)

	-- Full PC-tower silhouette instead of a generic cabinet.
	visualPart(root,folder,"PCChassis",Vector3.new(size.X*0.90,size.Y*0.94,size.Z*0.88),CFrame.new(),chassis,Enum.Material.Metal,0)
	local sideGlass = visualPart(root,folder,"PCGlassSide",Vector3.new(0.10,size.Y*0.78,size.Z*0.70),CFrame.new(size.X*0.46,0,0),glassColor,Enum.Material.Glass,0.48)
	sideGlass.CastShadow = false
	visualPart(root,folder,"PCMotherboard",Vector3.new(0.09,size.Y*0.56,size.Z*0.50),CFrame.new(size.X*0.39,size.Y*0.02,0),Color3.fromRGB(48,78,69),Enum.Material.Metal,0)
	visualPart(root,folder,"PCGPU",Vector3.new(size.X*0.48,size.Y*0.12,size.Z*0.22),CFrame.new(size.X*0.12,-size.Y*0.10,0),Color3.fromRGB(67,72,83),Enum.Material.Metal,0)
	visualPart(root,folder,"PCPSUShroud",Vector3.new(size.X*0.66,size.Y*0.18,size.Z*0.64),CFrame.new(0,-size.Y*0.37,0),Color3.fromRGB(24,27,34),Enum.Material.Metal,0)

	-- Three obvious front intake fans make the object read instantly as a gaming PC.
	for index, y in {size.Y*0.25,0,-size.Y*0.25} do
		local fan = cylinder(root,folder,"PCFrontFan"..index,Vector3.new(0.12,size.X*0.42,size.X*0.42),CFrame.new(0,y,-size.Z*0.47)*CFrame.Angles(0,0,math.rad(90)),rarity,Enum.Material.Neon,0.10)
		fan.CastShadow = false
		ball(root,folder,"PCFanHub"..index,math.max(0.10,size.X*0.08),CFrame.new(0,y,-size.Z*0.52),Color3.fromRGB(29,34,42),Enum.Material.Metal,0)
	end

	visualPart(root,folder,"PCTopVent",Vector3.new(size.X*0.68,0.10,size.Z*0.52),CFrame.new(0,size.Y*0.48,0),frame,Enum.Material.Metal,0)
	visualPart(root,folder,"PCIOGlow",Vector3.new(size.X*0.36,0.11,0.10),CFrame.new(0,size.Y*0.36,-size.Z*0.49),rarity,Enum.Material.Neon,0.08)
	for _, x in {-size.X*0.34,size.X*0.34} do
		visualPart(root,folder,"PCFoot",Vector3.new(size.X*0.10,size.Y*0.07,size.Z*0.20),CFrame.new(x,-size.Y*0.50,0),frame,Enum.Material.Metal,0)
	end
end

local function apply(root: BasePart)
	local itemId = itemIdFromPart(root)
	if not itemId then return end
	local definition = ItemConfig[itemId]
	local visual = PrototypeVisualConfig.Items[itemId]
	if not definition or not visual then return end
	local baseId = tostring(definition.BaseItemId or itemId)
	if baseId ~= "Couch" and baseId ~= "GamingPC" then return end
	if root:GetAttribute("M6C1ModelCorrectionItemId") == itemId and root:FindFirstChild("M6C1ModelCorrection") then return end

	local old = root:FindFirstChild("M6C1ModelCorrection")
	if old then old:Destroy() end
	hideOldVisuals(root)

	local folder = Instance.new("Folder")
	folder.Name = "M6C1ModelCorrection"
	folder.Parent = root
	root:SetAttribute("M6C1ModelCorrectionItemId",itemId)

	if baseId == "Couch" then buildCouch(root,folder,visual) else buildGamingPC(root,folder,visual) end
	applied += 1
end

local function deferred(instance: Instance)
	if not instance:IsA("BasePart") then return end
	-- Wait until M6C base + identity layers have created their old visual parts.
	task.defer(function() task.defer(function() task.defer(function()
		if instance.Parent then apply(instance) end
	end) end) end)
end

local function watchCharacter(character: Model)
	for _, descendant in character:GetDescendants() do if descendant:IsA("BasePart") then deferred(descendant) end end
	character.DescendantAdded:Connect(deferred)
end

local function watchPlayer(player: Player)
	player.CharacterAdded:Connect(watchCharacter)
	if player.Character then watchCharacter(player.Character) end
end

function Service.Start(world: Folder)
	applied = 0
	for _, player in Players:GetPlayers() do watchPlayer(player) end
	Players.PlayerAdded:Connect(watchPlayer)
	for _, descendant in world:GetDescendants() do if descendant:IsA("BasePart") then deferred(descendant) end end
	world.DescendantAdded:Connect(deferred)
	task.delay(1.4,function()
		if world.Parent then world:SetAttribute("M6C1ModelCorrectionsApplied",applied) end
	end)
end

return Service
