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

local function addRarity(root: BasePart, itemId: string, playCue: boolean)
	local definition = ItemConfig[itemId]
	if not definition then return end
	local rarity = definition.Rarity or "Common"
	local tier = RarityConfig.Tiers[rarity]
	if not tier then return end

	if tier.Rank >= 3 then
		local highlight = Instance.new("Highlight")
		highlight.Name = "RarityHighlight"
		highlight.Adornee = root
		highlight.FillColor = tier.Color
		highlight.OutlineColor = tier.Color:Lerp(Color3.new(1,1,1),0.35)
		highlight.FillTransparency = if tier.Rank >= 7 then 0.48 elseif tier.Rank >= 5 then 0.62 else 0.78
		highlight.OutlineTransparency = if tier.Rank >= 5 then 0.08 else 0.28
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.Parent = root
	end

	if tier.Rank >= 5 then
		local light = Instance.new("PointLight")
		light.Name = "RarityLight"
		light.Color = tier.Color
		light.Brightness = math.min(2.4, 0.45 + tier.Rank * 0.18)
		light.Range = math.min(18, 6 + tier.Rank * 1.3)
		light.Shadows = false
		light.Parent = root
	end

	if tier.Rank >= 6 then
		local attachment = Instance.new("Attachment")
		attachment.Name = "RarityAttachment"
		attachment.Parent = root
		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = "RarityParticles"
		emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		emitter.Color = ColorSequence.new(tier.Color)
		emitter.LightEmission = 0.65
		emitter.Rate = if tier.Rank >= 8 then 8 elseif tier.Rank == 7 then 5 else 2
		emitter.Lifetime = NumberRange.new(0.45, 0.90)
		emitter.Speed = NumberRange.new(0.6, 1.6)
		emitter.SpreadAngle = Vector2.new(180,180)
		emitter.Parent = attachment
	end

	if tier.Rank >= 7 then
		local folder = root:FindFirstChild("LootDetails")
		if folder and folder:IsA("Folder") then
			local size = root.Size
			local accent = tier.Color
			detail(root, folder, "RareFinL", Vector3.new(0.24,size.Y*0.78,0.24), CFrame.new(-size.X*0.60,0,0) * CFrame.Angles(0,0,math.rad(18)), accent, Enum.Material.Neon)
			detail(root, folder, "RareFinR", Vector3.new(0.24,size.Y*0.78,0.24), CFrame.new(size.X*0.60,0,0) * CFrame.Angles(0,0,math.rad(-18)), accent, Enum.Material.Neon)
			if tier.Rank >= 8 then
				detail(root, folder, "EternalCrown", Vector3.new(size.X*0.72,0.22,0.22), CFrame.new(0,size.Y*0.67,0), accent, Enum.Material.Neon)
			end
		end
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
