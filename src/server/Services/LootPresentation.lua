--!strict

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local PrototypeVisualConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PrototypeVisualConfig"))
local RarityConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("RarityConfig"))

local LootPresentation = {}

local function detail(root: BasePart, folder: Folder, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = root.CFrame * offset
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.Anchored = false
	part.Parent = folder
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = part
	weld.Parent = part
	return part
end

local function clearPresentation(root: BasePart)
	local old = root:FindFirstChild("LootDetails")
	if old then old:Destroy() end
	local highlight = root:FindFirstChild("RarityHighlight")
	if highlight then highlight:Destroy() end
	local attachment = root:FindFirstChild("RarityAttachment")
	if attachment then attachment:Destroy() end
	local light = root:FindFirstChild("RarityLight")
	if light then light:Destroy() end
end

local function addModelDetails(root: BasePart, itemId: string)
	local definition = ItemConfig[itemId]
	local visual = PrototypeVisualConfig.Items[itemId]
	if not definition or not visual then return end

	local folder = Instance.new("Folder")
	folder.Name = "LootDetails"
	folder.Parent = root
	local size = visual.Size
	local c = visual.Color:Lerp(Color3.new(1,1,1), 0.12)
	local dark = visual.Color:Lerp(Color3.new(0,0,0), 0.28)
	local kind = definition.ModelKind or "Legacy"

	if kind == "Crate" or kind == "Bundle" then
		detail(root, folder, "BandA", Vector3.new(math.max(0.18,size.X*0.09), size.Y*1.02, size.Z*1.03), CFrame.new(-size.X*0.23,0,0), dark, Enum.Material.Metal)
		detail(root, folder, "BandB", Vector3.new(math.max(0.18,size.X*0.09), size.Y*1.02, size.Z*1.03), CFrame.new(size.X*0.23,0,0), dark, Enum.Material.Metal)
	elseif kind == "Case" or kind == "Chest" then
		detail(root, folder, "Handle", Vector3.new(size.X*0.34, math.max(0.18,size.Y*0.09), math.max(0.18,size.Z*0.12)), CFrame.new(0,size.Y*0.55,0), dark, Enum.Material.Metal)
		detail(root, folder, "Latch", Vector3.new(math.max(0.22,size.X*0.12), math.max(0.22,size.Y*0.18), 0.18), CFrame.new(0,0,-size.Z*0.52), c, Enum.Material.Metal)
	elseif kind == "Chair" then
		detail(root, folder, "Back", Vector3.new(size.X*0.84, size.Y*0.55, math.max(0.25,size.Z*0.18)), CFrame.new(0,size.Y*0.33,size.Z*0.38), c)
		detail(root, folder, "Seat", Vector3.new(size.X*0.86, math.max(0.25,size.Y*0.14), size.Z*0.75), CFrame.new(0,-size.Y*0.10,0), dark)
	elseif kind == "Cart" then
		detail(root, folder, "Handle", Vector3.new(size.X*0.72, math.max(0.22,size.Y*0.10), 0.24), CFrame.new(0,size.Y*0.58,size.Z*0.34), dark, Enum.Material.Metal)
		detail(root, folder, "LowerShelf", Vector3.new(size.X*0.88, 0.22, size.Z*0.82), CFrame.new(0,-size.Y*0.36,0), c, Enum.Material.Metal)
	elseif kind == "Screen" then
		detail(root, folder, "ScreenFace", Vector3.new(size.X*0.86,size.Y*0.78,0.16), CFrame.new(0,0,-size.Z*0.54), Color3.fromRGB(18,24,31), Enum.Material.Glass)
		detail(root, folder, "Stand", Vector3.new(size.X*0.24,size.Y*0.24,0.35), CFrame.new(0,-size.Y*0.54,0), dark, Enum.Material.Metal)
	elseif kind == "Appliance" or kind == "TallAppliance" or kind == "Washer" then
		detail(root, folder, "Door", Vector3.new(size.X*0.72,size.Y*0.68,0.18), CFrame.new(0,0,-size.Z*0.51), dark, Enum.Material.Metal)
		detail(root, folder, "Control", Vector3.new(size.X*0.55,math.max(0.22,size.Y*0.09),0.20), CFrame.new(0,size.Y*0.35,-size.Z*0.53), c, Enum.Material.Neon)
	elseif kind == "Speaker" then
		detail(root, folder, "SpeakerFace", Vector3.new(size.X*0.72,size.Y*0.82,0.18), CFrame.new(0,0,-size.Z*0.52), Color3.fromRGB(25,27,31), Enum.Material.Metal)
	elseif kind == "Lamp" then
		detail(root, folder, "Shade", Vector3.new(size.X*1.8,size.Y*0.18,size.Z*1.8), CFrame.new(0,size.Y*0.47,0), c, Enum.Material.SmoothPlastic)
	elseif kind == "Table" then
		detail(root, folder, "Top", Vector3.new(size.X*1.02,math.max(0.24,size.Y*0.15),size.Z*1.02), CFrame.new(0,size.Y*0.30,0), c)
		detail(root, folder, "Support", Vector3.new(math.max(0.30,size.X*0.10),size.Y*0.70,math.max(0.30,size.Z*0.10)), CFrame.new(0,-size.Y*0.15,0), dark)
	elseif kind == "Sofa" then
		detail(root, folder, "Back", Vector3.new(size.X*0.92,size.Y*0.58,math.max(0.30,size.Z*0.18)), CFrame.new(0,size.Y*0.30,size.Z*0.38), c)
		detail(root, folder, "LeftArm", Vector3.new(size.X*0.10,size.Y*0.55,size.Z*0.75), CFrame.new(-size.X*0.47,0,0), dark)
		detail(root, folder, "RightArm", Vector3.new(size.X*0.10,size.Y*0.55,size.Z*0.75), CFrame.new(size.X*0.47,0,0), dark)
	elseif kind == "Mattress" then
		detail(root, folder, "Seam", Vector3.new(size.X*1.02,0.16,size.Z*1.02), CFrame.new(0,size.Y*0.38,0), dark)
	elseif kind == "Cabinet" then
		detail(root, folder, "DoorSeam", Vector3.new(0.16,size.Y*0.78,0.18), CFrame.new(0,0,-size.Z*0.52), dark, Enum.Material.Metal)
		detail(root, folder, "Handle", Vector3.new(size.X*0.12,size.Y*0.18,0.20), CFrame.new(size.X*0.12,0,-size.Z*0.55), c, Enum.Material.Metal)
	elseif kind == "Piano" then
		detail(root, folder, "Keyboard", Vector3.new(size.X*0.76,size.Y*0.15,size.Z*0.24), CFrame.new(0,-size.Y*0.05,-size.Z*0.55), Color3.fromRGB(226,223,212))
		detail(root, folder, "Top", Vector3.new(size.X*0.90,0.20,size.Z*0.76), CFrame.new(0,size.Y*0.50,0), c)
	elseif kind == "Safe" then
		detail(root, folder, "VaultDoor", Vector3.new(size.X*0.72,size.Y*0.70,0.24), CFrame.new(0,0,-size.Z*0.52), dark, Enum.Material.Metal)
		detail(root, folder, "Dial", Vector3.new(size.X*0.18,size.Y*0.18,0.28), CFrame.new(size.X*0.18,0,-size.Z*0.58), c, Enum.Material.Metal)
	elseif kind == "Cylinder" or kind == "Fan" then
		local disk = detail(root, folder, "RoundFace", Vector3.new(0.32,size.Y*0.72,size.Z*0.72), CFrame.new(-size.X*0.52,0,0) * CFrame.Angles(0,0,math.rad(90)), dark, Enum.Material.Metal)
		disk.Shape = Enum.PartType.Cylinder
	elseif kind == "Engine" then
		detail(root, folder, "Head", Vector3.new(size.X*0.70,size.Y*0.32,size.Z*0.72), CFrame.new(0,size.Y*0.43,0), c, Enum.Material.Metal)
		detail(root, folder, "SideBlock", Vector3.new(size.X*0.24,size.Y*0.42,size.Z*0.50), CFrame.new(size.X*0.52,0,0), dark, Enum.Material.Metal)
	elseif kind == "Machine" then
		detail(root, folder, "ControlBox", Vector3.new(size.X*0.30,size.Y*0.38,size.Z*0.24), CFrame.new(size.X*0.44,size.Y*0.15,-size.Z*0.42), c, Enum.Material.Metal)
		detail(root, folder, "BaseSkid", Vector3.new(size.X*1.04,0.24,size.Z*1.04), CFrame.new(0,-size.Y*0.52,0), dark, Enum.Material.Metal)
	elseif kind == "Core" then
		local core = detail(root, folder, "Core", Vector3.new(size.X*0.40,size.Y*0.40,size.Z*0.40), CFrame.new(), c, Enum.Material.Neon)
		core.Shape = Enum.PartType.Ball
	elseif kind == "Display" then
		detail(root, folder, "Glass", Vector3.new(size.X*0.82,size.Y*0.58,size.Z*0.72), CFrame.new(0,size.Y*0.18,0), c, Enum.Material.Glass)
	end
end

local function addRarityGeometry(root: BasePart, tier: any)
	local folder = root:FindFirstChild("LootDetails")
	if not folder or not folder:IsA("Folder") then return end
	local rank = tier.Rank
	local size = root.Size
	local accent = tier.Color
	local pale = accent:Lerp(Color3.new(1,1,1), 0.42)

	-- Uncommon: intentionally close to normal. One small quality badge only.
	if rank == 2 then
		detail(root, folder, "UncommonBadge", Vector3.new(math.max(0.22,size.X*0.14), math.max(0.18,size.Y*0.08), 0.16), CFrame.new(size.X*0.25, size.Y*0.25, -size.Z*0.53), accent, Enum.Material.Metal)
		return
	end
	if rank < 3 then return end

	-- Rare: visible upgraded trim, still recognizably the ordinary object.
	detail(root, folder, "RareTrimTop", Vector3.new(size.X*0.68, math.max(0.16,size.Y*0.055), 0.18), CFrame.new(0,size.Y*0.48,-size.Z*0.53), accent, Enum.Material.Neon)
	if rank == 3 then return end

	-- Epic: silhouette starts changing with a top cap + side accent plates.
	detail(root, folder, "EpicCap", Vector3.new(size.X*0.76, math.max(0.20,size.Y*0.08), size.Z*0.36), CFrame.new(0,size.Y*0.54,0), accent, Enum.Material.Metal)
	detail(root, folder, "EpicSideL", Vector3.new(math.max(0.18,size.X*0.06), size.Y*0.46, size.Z*0.46), CFrame.new(-size.X*0.53,0,0), accent, Enum.Material.Metal)
	detail(root, folder, "EpicSideR", Vector3.new(math.max(0.18,size.X*0.06), size.Y*0.46, size.Z*0.46), CFrame.new(size.X*0.53,0,0), accent, Enum.Material.Metal)
	if rank == 4 then return end

	-- Legendary: a structural premium frame rather than a gold recolor.
	detail(root, folder, "LegendaryHeader", Vector3.new(size.X*0.94, math.max(0.22,size.Y*0.07), 0.24), CFrame.new(0,size.Y*0.62,0), accent, Enum.Material.Metal)
	detail(root, folder, "LegendaryRailL", Vector3.new(math.max(0.20,size.X*0.055), size.Y*0.82, 0.24), CFrame.new(-size.X*0.55,0,-size.Z*0.46), accent, Enum.Material.Metal)
	detail(root, folder, "LegendaryRailR", Vector3.new(math.max(0.20,size.X*0.055), size.Y*0.82, 0.24), CFrame.new(size.X*0.55,0,-size.Z*0.46), accent, Enum.Material.Metal)
	if rank == 5 then return end

	-- Mythic: floating-looking energy nodes and a stronger central construction.
	local nodeL = detail(root, folder, "MythicNodeL", Vector3.new(math.max(0.32,size.X*0.12), math.max(0.32,size.X*0.12), math.max(0.32,size.X*0.12)), CFrame.new(-size.X*0.62,size.Y*0.18,0), accent, Enum.Material.Neon)
	nodeL.Shape = Enum.PartType.Ball
	local nodeR = detail(root, folder, "MythicNodeR", nodeL.Size, CFrame.new(size.X*0.62,size.Y*0.18,0), accent, Enum.Material.Neon)
	nodeR.Shape = Enum.PartType.Ball
	detail(root, folder, "MythicSpine", Vector3.new(math.max(0.20,size.X*0.05), size.Y*0.72, math.max(0.20,size.Z*0.08)), CFrame.new(0,0,size.Z*0.54), accent, Enum.Material.Neon)
	if rank == 6 then return end

	-- Cosmic: object is redesigned around energy containment, not just painted cyan.
	detail(root, folder, "CosmicFinL", Vector3.new(0.26,size.Y*0.86,0.26), CFrame.new(-size.X*0.64,0,0) * CFrame.Angles(0,0,math.rad(18)), accent, Enum.Material.Neon)
	detail(root, folder, "CosmicFinR", Vector3.new(0.26,size.Y*0.86,0.26), CFrame.new(size.X*0.64,0,0) * CFrame.Angles(0,0,math.rad(-18)), accent, Enum.Material.Neon)
	detail(root, folder, "CosmicBridge", Vector3.new(size.X*0.72,0.20,size.Z*0.72), CFrame.new(0,-size.Y*0.58,0), accent, Enum.Material.Neon)
	if rank == 7 then return end

	-- Eternal: clean white-gold prestige geometry. No rainbow particle wall.
	detail(root, folder, "EternalCrown", Vector3.new(size.X*0.80,0.26,0.26), CFrame.new(0,size.Y*0.72,0), pale, Enum.Material.Neon)
	detail(root, folder, "EternalPillarL", Vector3.new(math.max(0.20,size.X*0.06),size.Y*0.92,math.max(0.20,size.Z*0.07)), CFrame.new(-size.X*0.58,0,size.Z*0.46), pale, Enum.Material.Metal)
	detail(root, folder, "EternalPillarR", Vector3.new(math.max(0.20,size.X*0.06),size.Y*0.92,math.max(0.20,size.Z*0.07)), CFrame.new(size.X*0.58,0,size.Z*0.46), pale, Enum.Material.Metal)
end

local function addRarity(root: BasePart, itemId: string, playCue: boolean)
	local definition = ItemConfig[itemId]
	if not definition then return end
	local rarity = definition.Rarity or "Common"
	local tier = RarityConfig.Tiers[rarity]
	if not tier then return end

	addRarityGeometry(root, tier)

	if tier.Rank >= 3 then
		local highlight = Instance.new("Highlight")
		highlight.Name = "RarityHighlight"
		highlight.Adornee = root
		highlight.FillColor = tier.Color
		highlight.OutlineColor = tier.Color:Lerp(Color3.new(1,1,1),0.35)
		highlight.FillTransparency = if tier.Rank >= 7 then 0.70 elseif tier.Rank >= 5 then 0.78 else 0.88
		highlight.OutlineTransparency = if tier.Rank >= 5 then 0.16 else 0.38
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.Parent = root
	end

	if tier.Rank >= 5 then
		local light = Instance.new("PointLight")
		light.Name = "RarityLight"
		light.Color = tier.Color
		light.Brightness = math.min(1.35, 0.30 + tier.Rank * 0.11)
		light.Range = math.min(13, 4 + tier.Rank * 1.0)
		light.Shadows = false
		light.Parent = root
	end

	-- Particles are reserved for the truly extraordinary tiers and kept subtle.
	if tier.Rank >= 7 then
		local attachment = Instance.new("Attachment")
		attachment.Name = "RarityAttachment"
		attachment.Parent = root
		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = "RarityParticles"
		emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		emitter.Color = ColorSequence.new(tier.Color)
		emitter.LightEmission = 0.55
		emitter.Rate = if tier.Rank >= 8 then 3 else 2
		emitter.Lifetime = NumberRange.new(0.40, 0.75)
		emitter.Speed = NumberRange.new(0.35, 0.9)
		emitter.SpreadAngle = Vector2.new(150,150)
		emitter.Parent = attachment
	end

	if playCue and tier.Rank >= 3 then
		local sound = Instance.new("Sound")
		sound.Name = "RarityCue"
		sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
		sound.Volume = math.clamp(0.12 + tier.Rank * 0.035, 0.18, 0.42)
		sound.PlaybackSpeed = 0.85 + tier.Rank * 0.05
		sound.RollOffMaxDistance = if tier.Rank >= 7 then 90 else 55
		sound.Parent = root
		sound:Play()
		Debris:AddItem(sound, 4)
	end
end

function LootPresentation.Apply(root: BasePart, itemId: string, playCue: boolean?)
	local definition = ItemConfig[itemId]
	local visual = PrototypeVisualConfig.Items[itemId]
	if not definition or not visual then return end
	clearPresentation(root)
	root.Size = visual.Size
	root.Color = visual.Color
	root.Material = visual.Material or Enum.Material.SmoothPlastic
	root:SetAttribute("ItemId", itemId)
	root:SetAttribute("BaseItemId", definition.BaseItemId or itemId)
	root:SetAttribute("SectionName", definition.SectionId or "Legacy")
	root:SetAttribute("Rarity", definition.Rarity or "Common")
	root:SetAttribute("RarityRank", definition.RarityRank or 1)
	root:SetAttribute("SellValue", definition.Value)
	root:SetAttribute("PresentationAppliedItemId", itemId)
	addModelDetails(root, itemId)
	addRarity(root, itemId, playCue == true)

	local gui = root:FindFirstChild("PrototypeLabel")
	local label = gui and gui:FindFirstChildWhichIsA("TextLabel")
	if label then
		local rarity = definition.Rarity or "Common"
		local tier = RarityConfig.Tiers[rarity]
		label.Text = string.format("%s\n%s", string.upper(rarity), definition.Name)
		label.TextColor3 = if tier then tier.Color else Color3.new(1,1,1)
	end
end

return LootPresentation
