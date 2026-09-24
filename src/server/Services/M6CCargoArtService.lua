--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local ItemArtManifest = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemArtManifest"))
local LootCatalog = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LootCatalog"))
local PrototypeVisualConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PrototypeVisualConfig"))
local RarityConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("RarityConfig"))

local Service = {}

local generation = 0
local appliedCount = 0
local appliedBaseIds: {[string]: boolean} = {}

local WHITE_GOLD = Color3.fromRGB(249, 236, 184)
local PALE_GOLD = Color3.fromRGB(227, 196, 112)
local DARK_METAL = Color3.fromRGB(48, 54, 62)
local GLASS_DARK = Color3.fromRGB(46, 62, 76)

local function itemIdFromPart(part: BasePart): string?
	local attr = part:GetAttribute("ItemId")
	if typeof(attr) == "string" and attr ~= "" then return attr end
	local fromName = string.match(part.Name, "^Carry_(.+)_%d+$")
	if fromName and fromName ~= "" then return fromName end
	return nil
end

local function newDetail(
	root: BasePart,
	folder: Folder,
	name: string,
	size: Vector3,
	offset: CFrame,
	color: Color3,
	material: Enum.Material?,
	transparency: number?
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = Vector3.new(math.max(0.08, size.X), math.max(0.08, size.Y), math.max(0.08, size.Z))
	part.CFrame = root.CFrame * offset
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Transparency = transparency or 0
	part.Anchored = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.CastShadow = false
	part:SetAttribute("M6CVisual", true)
	part.Parent = folder
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = part
	weld.Parent = part
	return part
end

local function cylinder(root: BasePart, folder: Folder, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material?): Part
	local part = newDetail(root, folder, name, size, offset, color, material, 0)
	part.Shape = Enum.PartType.Cylinder
	return part
end

local function ball(root: BasePart, folder: Folder, name: string, diameter: number, offset: CFrame, color: Color3, material: Enum.Material?, transparency: number?): Part
	local part = newDetail(root, folder, name, Vector3.new(diameter, diameter, diameter), offset, color, material, transparency)
	part.Shape = Enum.PartType.Ball
	return part
end

local function clearOld(root: BasePart)
	for _, name in { "M6CArt", "LootDetails", "RarityHighlight", "RarityAttachment", "RarityLight" } do
		local old = root:FindFirstChild(name)
		if old then old:Destroy() end
	end
end

local function palette(root: BasePart, visual: any)
	local base = visual.BaseColor or root.Color
	return {
		base = base,
		light = base:Lerp(Color3.new(1,1,1), 0.25),
		dark = base:Lerp(Color3.new(0,0,0), 0.34),
		deeper = base:Lerp(Color3.new(0,0,0), 0.48),
		metal = Color3.fromRGB(74, 82, 91),
		rarity = visual.RarityColor or Color3.fromRGB(205,210,218),
	}
end

local function addFourLegs(root: BasePart, folder: Folder, size: Vector3, color: Color3, material: Enum.Material)
	local leg = Vector3.new(math.max(0.22,size.X*0.07), math.max(0.35,size.Y*0.50), math.max(0.22,size.Z*0.07))
	for _, x in {-size.X*0.38, size.X*0.38} do
		for _, z in {-size.Z*0.34, size.Z*0.34} do
			newDetail(root, folder, "Leg", leg, CFrame.new(x,-size.Y*0.38,z), color, material, 0)
		end
	end
end

local function buildKindBase(root: BasePart, folder: Folder, definition: any, visual: any)
	local size = root.Size
	local p = palette(root, visual)
	local kind = tostring(definition.ModelKind or "Legacy")

	if kind == "Crate" or kind == "Bundle" then
		for _, x in {-size.X*0.31, size.X*0.31} do
			newDetail(root, folder, "CargoBand", Vector3.new(math.max(0.16,size.X*0.07),size.Y*1.02,size.Z*1.03), CFrame.new(x,0,0), p.dark, Enum.Material.Metal, 0)
		end
		newDetail(root, folder, "TopSeam", Vector3.new(size.X*0.72,0.12,math.max(0.12,size.Z*0.06)), CFrame.new(0,size.Y*0.51,0), p.light, Enum.Material.SmoothPlastic, 0)
	elseif kind == "Case" or kind == "Chest" then
		newDetail(root, folder, "CaseLid", Vector3.new(size.X*1.01,math.max(0.16,size.Y*0.12),size.Z*1.01), CFrame.new(0,size.Y*0.48,0), p.light, Enum.Material.Metal, 0)
		newDetail(root, folder, "CarryHandle", Vector3.new(size.X*0.42,math.max(0.18,size.Y*0.08),math.max(0.18,size.Z*0.10)), CFrame.new(0,size.Y*0.61,0), p.deeper, Enum.Material.Metal, 0)
		for _, x in {-size.X*0.28, size.X*0.28} do
			newDetail(root, folder, "Latch", Vector3.new(math.max(0.18,size.X*0.09),math.max(0.20,size.Y*0.16),0.14), CFrame.new(x,0,-size.Z*0.51), p.light, Enum.Material.Metal, 0)
		end
	elseif kind == "Chair" then
		newDetail(root, folder, "Seat", Vector3.new(size.X*0.86,math.max(0.25,size.Y*0.13),size.Z*0.74), CFrame.new(0,-size.Y*0.09,0), p.light, Enum.Material.SmoothPlastic, 0)
		newDetail(root, folder, "Back", Vector3.new(size.X*0.82,size.Y*0.50,math.max(0.24,size.Z*0.16)), CFrame.new(0,size.Y*0.31,size.Z*0.36), p.light, Enum.Material.SmoothPlastic, 0)
		addFourLegs(root, folder, size, p.dark, Enum.Material.Metal)
	elseif kind == "Cart" then
		newDetail(root, folder, "LowerDeck", Vector3.new(size.X*0.88,0.22,size.Z*0.78), CFrame.new(0,-size.Y*0.34,0), p.light, Enum.Material.Metal, 0)
		newDetail(root, folder, "PushHandle", Vector3.new(size.X*0.72,0.24,0.24), CFrame.new(0,size.Y*0.58,size.Z*0.34), p.dark, Enum.Material.Metal, 0)
		for _, x in {-size.X*0.35,size.X*0.35} do
			for _, z in {-size.Z*0.30,size.Z*0.30} do
				ball(root,folder,"Wheel",math.max(0.28,math.min(size.X,size.Z)*0.10),CFrame.new(x,-size.Y*0.52,z),DARK_METAL,Enum.Material.Metal,0)
			end
		end
	elseif kind == "Screen" then
		newDetail(root, folder, "DisplayGlass", Vector3.new(size.X*0.86,size.Y*0.76,0.14), CFrame.new(0,0,-size.Z*0.52), Color3.fromRGB(18,24,32), Enum.Material.Glass, 0.06)
		newDetail(root, folder, "BezelBottom", Vector3.new(size.X*0.88,math.max(0.16,size.Y*0.07),0.18), CFrame.new(0,-size.Y*0.40,-size.Z*0.53), p.dark, Enum.Material.Metal, 0)
		for _, x in {-size.X*0.24,size.X*0.24} do
			newDetail(root, folder, "DisplayFoot", Vector3.new(size.X*0.16,math.max(0.16,size.Y*0.08),size.Z*0.36), CFrame.new(x,-size.Y*0.52,0), p.dark, Enum.Material.Metal, 0)
		end
	elseif kind == "Appliance" or kind == "TallAppliance" then
		newDetail(root, folder, "FrontPanel", Vector3.new(size.X*0.78,size.Y*0.76,0.14), CFrame.new(0,-size.Y*0.03,-size.Z*0.51), p.light, Enum.Material.SmoothPlastic, 0)
		newDetail(root, folder, "ControlPanel", Vector3.new(size.X*0.52,math.max(0.22,size.Y*0.09),0.17), CFrame.new(0,size.Y*0.36,-size.Z*0.53), p.dark, Enum.Material.Metal, 0)
		newDetail(root, folder, "DoorHandle", Vector3.new(math.max(0.18,size.X*0.06),size.Y*0.46,0.18), CFrame.new(size.X*0.31,0,-size.Z*0.55), p.metal, Enum.Material.Metal, 0)
	elseif kind == "Washer" then
		local door = cylinder(root, folder, "RoundDoor", Vector3.new(0.22,size.Y*0.54,size.Y*0.54), CFrame.new(0,-size.Y*0.05,-size.Z*0.52) * CFrame.Angles(0,0,math.rad(90)), GLASS_DARK, Enum.Material.Glass)
		door.Transparency = 0.12
		newDetail(root, folder, "WasherControls", Vector3.new(size.X*0.66,math.max(0.24,size.Y*0.11),0.18), CFrame.new(0,size.Y*0.37,-size.Z*0.53), p.dark, Enum.Material.Metal, 0)
	elseif kind == "Speaker" then
		newDetail(root, folder, "SpeakerFace", Vector3.new(size.X*0.78,size.Y*0.84,0.16), CFrame.new(0,0,-size.Z*0.51), p.deeper, Enum.Material.Metal, 0)
		for _, y in {-size.Y*0.22,size.Y*0.22} do
			local woofer = cylinder(root,folder,"Woofer",Vector3.new(0.18,size.X*0.46,size.X*0.46),CFrame.new(0,y,-size.Z*0.55)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(24,27,31),Enum.Material.Metal)
			woofer.Transparency = 0.02
		end
	elseif kind == "Lamp" then
		newDetail(root, folder, "LampBase", Vector3.new(size.X*1.45,0.28,size.Z*1.45), CFrame.new(0,-size.Y*0.48,0), p.dark, Enum.Material.Metal, 0)
		newDetail(root, folder, "LampStem", Vector3.new(math.max(0.18,size.X*0.16),size.Y*0.72,math.max(0.18,size.Z*0.16)), CFrame.new(0,-size.Y*0.04,0), p.metal, Enum.Material.Metal, 0)
		newDetail(root, folder, "Shade", Vector3.new(size.X*1.70,math.max(0.22,size.Y*0.12),size.Z*1.70), CFrame.new(0,size.Y*0.47,0), p.light, Enum.Material.SmoothPlastic, 0)
	elseif kind == "Table" then
		newDetail(root, folder, "TableTop", Vector3.new(size.X*1.03,math.max(0.22,size.Y*0.14),size.Z*1.03), CFrame.new(0,size.Y*0.34,0), p.light, Enum.Material.WoodPlanks, 0)
		addFourLegs(root, folder, size, p.dark, Enum.Material.WoodPlanks)
	elseif kind == "Sofa" then
		newDetail(root, folder, "SofaBack", Vector3.new(size.X*0.92,size.Y*0.52,math.max(0.28,size.Z*0.18)), CFrame.new(0,size.Y*0.29,size.Z*0.37), p.light, Enum.Material.SmoothPlastic, 0)
		for _, x in {-size.X*0.31,0,size.X*0.31} do
			newDetail(root, folder, "Cushion", Vector3.new(size.X*0.28,math.max(0.24,size.Y*0.14),size.Z*0.64), CFrame.new(x,-size.Y*0.06,-size.Z*0.05), p.light:Lerp(Color3.new(1,1,1),0.08), Enum.Material.SmoothPlastic, 0)
		end
		for _, x in {-size.X*0.48,size.X*0.48} do
			newDetail(root, folder, "SofaArm", Vector3.new(size.X*0.10,size.Y*0.50,size.Z*0.72), CFrame.new(x,0,0), p.dark, Enum.Material.SmoothPlastic, 0)
		end
	elseif kind == "Mattress" then
		newDetail(root, folder, "MattressTop", Vector3.new(size.X*0.96,0.18,size.Z*0.96), CFrame.new(0,size.Y*0.46,0), p.light, Enum.Material.SmoothPlastic, 0)
		for _, x in {-size.X*0.32,0,size.X*0.32} do
			newDetail(root, folder, "QuiltLine", Vector3.new(0.10,0.12,size.Z*0.90), CFrame.new(x,size.Y*0.53,0), p.dark, Enum.Material.SmoothPlastic, 0)
		end
	elseif kind == "Cabinet" then
		newDetail(root, folder, "CabinetFace", Vector3.new(size.X*0.84,size.Y*0.82,0.14), CFrame.new(0,0,-size.Z*0.51), p.light, Enum.Material.SmoothPlastic, 0)
		newDetail(root, folder, "DoorSplit", Vector3.new(0.12,size.Y*0.76,0.16), CFrame.new(0,0,-size.Z*0.53), p.dark, Enum.Material.Metal, 0)
		for _, x in {-size.X*0.13,size.X*0.13} do
			newDetail(root, folder, "CabinetHandle", Vector3.new(0.16,size.Y*0.18,0.18), CFrame.new(x,0,-size.Z*0.55), p.metal, Enum.Material.Metal, 0)
		end
	elseif kind == "Piano" then
		newDetail(root, folder, "Keyboard", Vector3.new(size.X*0.76,math.max(0.20,size.Y*0.14),size.Z*0.24), CFrame.new(0,-size.Y*0.05,-size.Z*0.55), Color3.fromRGB(232,229,218), Enum.Material.SmoothPlastic, 0)
		newDetail(root, folder, "PianoTop", Vector3.new(size.X*0.94,0.22,size.Z*0.78), CFrame.new(0,size.Y*0.49,0), p.light, Enum.Material.SmoothPlastic, 0)
		addFourLegs(root, folder, size, p.dark, Enum.Material.Metal)
	elseif kind == "Safe" then
		newDetail(root, folder, "SafeDoor", Vector3.new(size.X*0.78,size.Y*0.76,0.26), CFrame.new(0,0,-size.Z*0.52), p.dark, Enum.Material.Metal, 0)
		local wheel = cylinder(root,folder,"VaultWheel",Vector3.new(0.30,size.X*0.28,size.X*0.28),CFrame.new(0,0,-size.Z*0.62)*CFrame.Angles(0,0,math.rad(90)),p.light,Enum.Material.Metal)
		wheel.Transparency = 0
		for _, x in {-size.X*0.42,size.X*0.42} do
			for _, y in {-size.Y*0.38,size.Y*0.38} do
				newDetail(root,folder,"ReinforcedCorner",Vector3.new(size.X*0.10,size.Y*0.16,0.30),CFrame.new(x,y,-size.Z*0.54),p.metal,Enum.Material.Metal,0)
			end
		end
	elseif kind == "Cylinder" or kind == "Fan" then
		local disk = cylinder(root,folder,"RoundBody",Vector3.new(math.max(0.28,size.X*0.10),size.Y*0.78,size.Z*0.78),CFrame.new(-size.X*0.50,0,0)*CFrame.Angles(0,0,math.rad(90)),p.dark,Enum.Material.Metal)
		disk.Transparency = 0
	elseif kind == "Engine" then
		newDetail(root, folder, "EngineHead", Vector3.new(size.X*0.72,size.Y*0.30,size.Z*0.70), CFrame.new(0,size.Y*0.38,0), p.light, Enum.Material.Metal, 0)
		for _, x in {-size.X*0.34,size.X*0.34} do
			for _, z in {-size.Z*0.27,size.Z*0.27} do
				cylinder(root,folder,"CylinderBank",Vector3.new(size.X*0.12,size.Y*0.35,size.Y*0.35),CFrame.new(x,0,z),p.metal,Enum.Material.Metal)
			end
		end
		newDetail(root, folder, "EngineSkid", Vector3.new(size.X*1.05,0.24,size.Z*1.02), CFrame.new(0,-size.Y*0.52,0), p.dark, Enum.Material.Metal, 0)
	elseif kind == "Machine" then
		newDetail(root, folder, "MachineSkid", Vector3.new(size.X*1.05,0.25,size.Z*1.05), CFrame.new(0,-size.Y*0.52,0), p.dark, Enum.Material.Metal, 0)
		newDetail(root, folder, "ControlBox", Vector3.new(size.X*0.30,size.Y*0.34,size.Z*0.22), CFrame.new(size.X*0.42,size.Y*0.14,-size.Z*0.43), p.light, Enum.Material.Metal, 0)
		newDetail(root, folder, "ControlScreen", Vector3.new(size.X*0.18,size.Y*0.12,0.12), CFrame.new(size.X*0.42,size.Y*0.18,-size.Z*0.56), Color3.fromRGB(75,180,201), Enum.Material.Neon, 0.10)
	elseif kind == "Core" then
		local core = ball(root,folder,"EnergyCore",math.min(size.X,size.Y,size.Z)*0.44,CFrame.new(),p.rarity,Enum.Material.Neon,0.08)
		for _, y in {-size.Y*0.34,size.Y*0.34} do
			newDetail(root,folder,"ContainmentBrace",Vector3.new(size.X*0.72,0.22,size.Z*0.72),CFrame.new(0,y,0),p.dark,Enum.Material.Metal,0)
		end
		core:SetAttribute("M6CAnimatedCandidate",true)
	elseif kind == "Display" then
		local glass = newDetail(root, folder, "DisplayGlass", Vector3.new(size.X*0.82,size.Y*0.64,size.Z*0.72), CFrame.new(0,size.Y*0.10,0), p.light, Enum.Material.Glass, 0.42)
		glass.CastShadow = false
		newDetail(root, folder, "DisplayBase", Vector3.new(size.X*0.92,math.max(0.20,size.Y*0.15),size.Z*0.86), CFrame.new(0,-size.Y*0.42,0), p.dark, Enum.Material.Metal, 0)
	else
		-- Unknown/legacy kinds still get a clean readable final pass instead of a
		-- naked cube: face panel + base skid + corner caps.
		newDetail(root, folder, "IdentityPanel", Vector3.new(size.X*0.64,size.Y*0.46,0.14), CFrame.new(0,0,-size.Z*0.51), p.light, Enum.Material.SmoothPlastic, 0)
		newDetail(root, folder, "BaseSkid", Vector3.new(size.X*0.90,0.18,size.Z*0.86), CFrame.new(0,-size.Y*0.50,0), p.dark, Enum.Material.Metal, 0)
	end
end

local function hasToken(text: string, token: string): boolean
	return string.find(string.lower(text), string.lower(token), 1, true) ~= nil
end

local function addItemSpecific(root: BasePart, folder: Folder, baseId: string, baseDef: any, visual: any)
	local size = root.Size
	local p = palette(root, visual)
	local name = tostring(baseDef.Name or baseId)
	local lower = string.lower(baseId .. " " .. name)

	-- Fridges/appliances: unmistakable door split and oversized handles.
	if hasToken(lower,"fridge") or hasToken(lower,"refrigerator") then
		newDetail(root,folder,"FridgeDoorSplit",Vector3.new(0.13,size.Y*0.76,0.17),CFrame.new(0,-size.Y*0.02,-size.Z*0.56),p.dark,Enum.Material.Metal,0)
		for _, x in {-size.X*0.18,size.X*0.18} do
			newDetail(root,folder,"ChunkyFridgeHandle",Vector3.new(math.max(0.16,size.X*0.05),size.Y*0.40,0.18),CFrame.new(x,0,-size.Z*0.59),p.metal,Enum.Material.Metal,0)
		end
		newDetail(root,folder,"FridgeDisplay",Vector3.new(size.X*0.26,size.Y*0.10,0.13),CFrame.new(size.X*0.20,size.Y*0.27,-size.Z*0.60),Color3.fromRGB(63,160,194),Enum.Material.Neon,0.12)
	end

	if hasToken(lower,"arcade") then
		newDetail(root,folder,"ArcadeMarquee",Vector3.new(size.X*0.88,size.Y*0.16,size.Z*0.32),CFrame.new(0,size.Y*0.45,-size.Z*0.38),p.light,Enum.Material.SmoothPlastic,0)
		newDetail(root,folder,"ArcadeScreen",Vector3.new(size.X*0.68,size.Y*0.34,0.16),CFrame.new(0,size.Y*0.12,-size.Z*0.54),Color3.fromRGB(27,37,52),Enum.Material.Glass,0.05)
		newDetail(root,folder,"ControlDeck",Vector3.new(size.X*0.76,size.Y*0.12,size.Z*0.30),CFrame.new(0,-size.Y*0.18,-size.Z*0.45),p.dark,Enum.Material.Metal,0)
	end

	if hasToken(lower,"gamingpc") or hasToken(lower,"gaming pc") then
		local glass = newDetail(root,folder,"PCGlassSide",Vector3.new(size.X*0.78,size.Y*0.72,0.12),CFrame.new(size.X*0.18,0,-size.Z*0.51),Color3.fromRGB(36,48,65),Enum.Material.Glass,0.34)
		glass.CastShadow = false
		for _, y in {-size.Y*0.20,size.Y*0.20} do
			ball(root,folder,"PCFan",math.max(0.30,size.X*0.22),CFrame.new(-size.X*0.28,y,-size.Z*0.54),Color3.fromRGB(64,150,196),Enum.Material.Neon,0.20)
		end
	end

	if hasToken(lower,"bicycle") or hasToken(lower,"exercisebike") or hasToken(lower,"exercise bike") then
		for _, z in {-size.Z*0.30,size.Z*0.30} do
			local wheel = cylinder(root,folder,"BikeWheel",Vector3.new(0.16,size.Y*0.48,size.Y*0.48),CFrame.new(0,-size.Y*0.18,z)*CFrame.Angles(0,0,math.rad(90)),DARK_METAL,Enum.Material.Metal)
			wheel.Transparency = 0
		end
		newDetail(root,folder,"BikeFrame",Vector3.new(math.max(0.16,size.X*0.08),size.Y*0.48,math.max(0.16,size.Z*0.08)),CFrame.new(0,0,0)*CFrame.Angles(0,0,math.rad(28)),p.light,Enum.Material.Metal,0)
	end

	if hasToken(lower,"treadmill") then
		newDetail(root,folder,"TreadDeck",Vector3.new(size.X*0.84,0.28,size.Z*0.66),CFrame.new(0,-size.Y*0.35,0),Color3.fromRGB(48,52,58),Enum.Material.Metal,0)
		for _, x in {-size.X*0.33,size.X*0.33} do
			newDetail(root,folder,"TreadUpright",Vector3.new(0.22,size.Y*0.72,0.22),CFrame.new(x,0,size.Z*0.28),p.metal,Enum.Material.Metal,0)
		end
	end

	if hasToken(lower,"engine") then
		newDetail(root,folder,"Intake",Vector3.new(size.X*0.34,size.Y*0.22,size.Z*0.40),CFrame.new(0,size.Y*0.56,0),p.light,Enum.Material.Metal,0)
		for _, x in {-size.X*0.38,size.X*0.38} do
			newDetail(root,folder,"EnginePipe",Vector3.new(size.X*0.10,size.Y*0.58,size.Z*0.12),CFrame.new(x,0,0)*CFrame.Angles(0,0,math.rad(if x < 0 then -12 else 12)),p.metal,Enum.Material.Metal,0)
		end
	end

	if hasToken(lower,"mixer") or hasToken(lower,"concrete") then
		local drum = cylinder(root,folder,"MixerDrum",Vector3.new(size.X*0.46,size.Y*0.62,size.Y*0.62),CFrame.new(0,size.Y*0.08,0)*CFrame.Angles(0,0,math.rad(90)),p.light,Enum.Material.Metal)
		drum.Transparency = 0
	end

	if hasToken(lower,"fan") then
		for angle = 0, 270, 90 do
			newDetail(root,folder,"FanBlade",Vector3.new(size.X*0.32,0.14,size.Z*0.10),CFrame.new(0,0,-size.Z*0.54)*CFrame.Angles(0,0,math.rad(angle)),p.light,Enum.Material.Metal,0)
		end
	end

	if hasToken(lower,"piano") and baseId == "RoyalGrandPiano" then
		newDetail(root,folder,"GrandLid",Vector3.new(size.X*0.82,0.18,size.Z*0.84),CFrame.new(size.X*0.07,size.Y*0.58,size.Z*0.05)*CFrame.Angles(0,0,math.rad(-6)),Color3.fromRGB(48,43,44),Enum.Material.SmoothPlastic,0)
		for _, x in {-size.X*0.36,0,size.X*0.36} do
			newDetail(root,folder,"GoldPianoLeg",Vector3.new(size.X*0.07,size.Y*0.62,size.Z*0.07),CFrame.new(x,-size.Y*0.38,size.Z*0.15),PALE_GOLD,Enum.Material.Metal,0)
		end
	end

	if baseId == "GoldenPalletJack" then
		for _, x in {-size.X*0.28,size.X*0.28} do
			newDetail(root,folder,"GoldenFork",Vector3.new(size.X*0.18,0.24,size.Z*1.45),CFrame.new(x,-size.Y*0.36,-size.Z*0.38),Color3.fromRGB(214,170,61),Enum.Material.Metal,0)
		end
		newDetail(root,folder,"JackColumn",Vector3.new(size.X*0.20,size.Y*0.78,size.Z*0.20),CFrame.new(0,size.Y*0.10,size.Z*0.36),Color3.fromRGB(189,143,47),Enum.Material.Metal,0)
	end

	if baseId == "CreatorCommandCenter" then
		for _, x in {-size.X*0.28,0,size.X*0.28} do
			newDetail(root,folder,"CommandMonitor",Vector3.new(size.X*0.24,size.Y*0.30,0.16),CFrame.new(x,size.Y*0.18,-size.Z*0.54),Color3.fromRGB(26,35,51),Enum.Material.Glass,0.04)
		end
		newDetail(root,folder,"CommandDesk",Vector3.new(size.X*0.86,0.28,size.Z*0.40),CFrame.new(0,-size.Y*0.24,-size.Z*0.22),p.dark,Enum.Material.Metal,0)
	end

	if hasToken(lower,"fragrance") or hasToken(lower,"parfum") or hasToken(lower,"perfumer") or hasToken(lower,"oud") or hasToken(lower,"atomizer") then
		local caseGlass = newDetail(root,folder,"FragranceDisplayGlass",Vector3.new(size.X*0.82,size.Y*0.62,0.14),CFrame.new(0,size.Y*0.05,-size.Z*0.53),Color3.fromRGB(202,225,232),Enum.Material.Glass,0.42)
		caseGlass.CastShadow = false
		for index, x in {-size.X*0.27,-size.X*0.09,size.X*0.09,size.X*0.27} do
			local h = size.Y*(0.20 + 0.025*(index%2))
			newDetail(root,folder,"FragranceBottle",Vector3.new(size.X*0.12,h,size.Z*0.16),CFrame.new(x,-size.Y*0.12,-size.Z*0.58),Color3.fromRGB(119+index*16,87+index*10,145+index*7),Enum.Material.Glass,0.16)
			newDetail(root,folder,"BottleCap",Vector3.new(size.X*0.07,size.Y*0.06,size.Z*0.09),CFrame.new(x,-size.Y*0.12+h*0.60,-size.Z*0.58),PALE_GOLD,Enum.Material.Metal,0)
		end
	end

	if hasToken(lower,"painting") or hasToken(lower,"art crate") or hasToken(lower,"fine art") then
		newDetail(root,folder,"ArtFrameOuter",Vector3.new(size.X*0.88,size.Y*0.78,0.18),CFrame.new(0,0,-size.Z*0.53),Color3.fromRGB(91,66,111),Enum.Material.Metal,0)
		newDetail(root,folder,"FictionalArtwork",Vector3.new(size.X*0.72,size.Y*0.62,0.13),CFrame.new(0,0,-size.Z*0.56),Color3.fromRGB(166,92,132),Enum.Material.SmoothPlastic,0)
	end

	if hasToken(lower,"gem") or hasToken(lower,"jewel") then
		local glass = newDetail(root,folder,"SecureDisplayGlass",Vector3.new(size.X*0.72,size.Y*0.58,size.Z*0.60),CFrame.new(0,size.Y*0.10,0),Color3.fromRGB(183,221,239),Enum.Material.Glass,0.48)
		glass.CastShadow = false
		ball(root,folder,"Gemstone",math.min(size.X,size.Y,size.Z)*0.22,CFrame.new(0,size.Y*0.02,-size.Z*0.12),Color3.fromRGB(81,191,230),Enum.Material.Neon,0.08)
	end

	if baseDef.SectionId == "RestrictedPrototype" then
		for _, y in {-size.Y*0.30,size.Y*0.30} do
			newDetail(root,folder,"ResearchBrace",Vector3.new(size.X*0.78,0.18,size.Z*0.78),CFrame.new(0,y,0),DARK_METAL,Enum.Material.Metal,0)
		end
		if not hasToken(lower,"crate") and not hasToken(lower,"case") then
			ball(root,folder,"ContainedPrototypeEnergy",math.min(size.X,size.Y,size.Z)*0.24,CFrame.new(),Color3.fromRGB(65,213,218),Enum.Material.Neon,0.12)
		end
	end
end

local function addRarityModules(root: BasePart, folder: Folder, definition: any, visual: any)
	local rank = tonumber(visual.RarityRank) or 1
	if rank <= 1 then return end
	local rarity = tostring(visual.Rarity or definition.Rarity or "Common")
	local color = visual.RarityColor or RarityConfig.Tiers[rarity].Color
	local size = root.Size
	local kind = tostring(definition.ModelKind or "Legacy")
	local baseId = tostring(definition.BaseItemId or "")

	local rarityFolder = Instance.new("Folder")
	rarityFolder.Name = "RarityGeometry"
	rarityFolder:SetAttribute("Rarity", rarity)
	rarityFolder:SetAttribute("RarityRank", rank)
	rarityFolder.Parent = folder

	-- Uncommon: barely different; one restrained quality badge.
	if rank == 2 then
		newDetail(root,rarityFolder,"UncommonQualityBadge",Vector3.new(math.max(0.16,size.X*0.12),math.max(0.16,size.Y*0.07),0.12),CFrame.new(-size.X*0.31,size.Y*0.32,-size.Z*0.55),color,Enum.Material.Metal,0)
		return
	end

	-- Rare: obvious trim without magical aura.
	for _, x in {-size.X*0.43,size.X*0.43} do
		newDetail(root,rarityFolder,"RareTrim",Vector3.new(math.max(0.13,size.X*0.035),size.Y*0.72,0.13),CFrame.new(x,0,-size.Z*0.55),color,Enum.Material.Metal,0)
	end
	if rank == 3 then
		newDetail(root,rarityFolder,"RareStatus",Vector3.new(size.X*0.22,math.max(0.13,size.Y*0.05),0.12),CFrame.new(0,size.Y*0.36,-size.Z*0.56),color,Enum.Material.Neon,0.15)
		return
	end

	-- Epic: silhouette begins to change.
	newDetail(root,rarityFolder,"EpicTopCap",Vector3.new(size.X*0.72,math.max(0.16,size.Y*0.08),size.Z*0.74),CFrame.new(0,size.Y*0.53,0),color:Lerp(Color3.new(1,1,1),0.12),Enum.Material.Metal,0)
	for _, x in {-size.X*0.49,size.X*0.49} do
		newDetail(root,rarityFolder,"EpicSideModule",Vector3.new(math.max(0.18,size.X*0.08),size.Y*0.30,size.Z*0.48),CFrame.new(x,0,0),color,Enum.Material.Metal,0)
	end
	if rank == 4 then return end

	-- Legendary: premium structural redesign. Furniture gets piping/legs, machines
	-- get engineered frames, cases get reinforced corners.
	local gold = if rarity == "Legendary" then Color3.fromRGB(231,178,65) else color
	if kind == "Sofa" or kind == "Chair" or kind == "Table" or kind == "Piano" then
		for _, x in {-size.X*0.46,size.X*0.46} do
			newDetail(root,rarityFolder,"PremiumEdge",Vector3.new(math.max(0.16,size.X*0.04),size.Y*0.72,size.Z*0.12),CFrame.new(x,0,-size.Z*0.54),gold,Enum.Material.Metal,0)
		end
		newDetail(root,rarityFolder,"PremiumEmblem",Vector3.new(size.X*0.20,size.Y*0.10,0.14),CFrame.new(0,size.Y*0.22,-size.Z*0.58),gold,Enum.Material.Neon,0.12)
	elseif kind == "Engine" or kind == "Machine" or kind == "Core" then
		for _, x in {-size.X*0.46,size.X*0.46} do
			newDetail(root,rarityFolder,"EngineeredRail",Vector3.new(math.max(0.18,size.X*0.06),size.Y*0.80,math.max(0.18,size.Z*0.07)),CFrame.new(x,0,0),gold,Enum.Material.Metal,0)
		end
		ball(root,rarityFolder,"PremiumCore",math.min(size.X,size.Y,size.Z)*0.18,CFrame.new(0,0,-size.Z*0.56),gold,Enum.Material.Neon,0.06)
	else
		for _, x in {-size.X*0.44,size.X*0.44} do
			for _, y in {-size.Y*0.38,size.Y*0.38} do
				newDetail(root,rarityFolder,"PremiumCorner",Vector3.new(size.X*0.10,size.Y*0.14,0.18),CFrame.new(x,y,-size.Z*0.55),gold,Enum.Material.Metal,0)
			end
		end
	end
	if rank == 5 then return end

	-- Mythic: intentionally special construction with suspended-looking nodes.
	for _, x in {-size.X*0.56,size.X*0.56} do
		ball(root,rarityFolder,"MythicNode",math.max(0.28,math.min(size.Y,size.Z)*0.13),CFrame.new(x,size.Y*0.18,0),color,Enum.Material.Neon,0.05)
		newDetail(root,rarityFolder,"MythicBrace",Vector3.new(math.max(0.12,size.X*0.035),size.Y*0.42,math.max(0.12,size.Z*0.035)),CFrame.new(x,0,0),color:Lerp(Color3.new(0,0,0),0.20),Enum.Material.Metal,0)
	end
	if rank == 6 then return end

	-- Cosmic: object is redesigned around containment/energy, not simply cyan.
	for _, y in {-size.Y*0.34,size.Y*0.34} do
		local ring = cylinder(root,rarityFolder,"CosmicContainmentRing",Vector3.new(math.max(0.14,size.X*0.04),size.Z*1.12,size.Z*1.12),CFrame.new(0,y,0)*CFrame.Angles(0,0,math.rad(90)),color,Enum.Material.Neon)
		ring.Transparency = 0.16
	end
	for _, x in {-size.X*0.54,size.X*0.54} do
		newDetail(root,rarityFolder,"CosmicFin",Vector3.new(size.X*0.10,size.Y*0.54,size.Z*0.30),CFrame.new(x,0,0),Color3.fromRGB(55,77,125),Enum.Material.Metal,0)
	end
	local attachment = Instance.new("Attachment")
	attachment.Name = "M6CCosmicVFX"
	attachment.Parent = root
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "CosmicStars"
	emitter.Rate = 1.6
	emitter.Lifetime = NumberRange.new(0.55,0.95)
	emitter.Speed = NumberRange.new(0.15,0.45)
	emitter.SpreadAngle = Vector2.new(30,30)
	emitter.LightEmission = 0.45
	emitter.Color = ColorSequence.new(color,Color3.fromRGB(119,99,221))
	emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.11),NumberSequenceKeypoint.new(1,0)})
	emitter.Parent = attachment
	if rank == 7 then return end

	-- Eternal: ultimate prestige geometry. Controlled white-gold, no rainbow spam.
	newDetail(root,rarityFolder,"EternalCrown",Vector3.new(size.X*0.64,math.max(0.18,size.Y*0.09),size.Z*0.58),CFrame.new(0,size.Y*0.62,0),WHITE_GOLD,Enum.Material.Metal,0)
	for _, x in {-size.X*0.34,0,size.X*0.34} do
		newDetail(root,rarityFolder,"EternalSpine",Vector3.new(math.max(0.12,size.X*0.035),size.Y*0.86,0.14),CFrame.new(x,0,-size.Z*0.59),if x == 0 then WHITE_GOLD else PALE_GOLD,Enum.Material.Neon,0.10)
	end
	local light = Instance.new("PointLight")
	light.Name = "EternalPrestigeLight"
	light.Color = WHITE_GOLD
	light.Brightness = 0.45
	light.Range = math.clamp(size.Magnitude*1.6,7,16)
	light.Shadows = false
	light.Parent = root

	-- Item-aware late-tier emphasis.
	if hasToken(baseId,"Fragrance") or hasToken(baseId,"Parfum") or hasToken(baseId,"Oud") then
		ball(root,rarityFolder,"PrestigeBottleFocus",math.min(size.X,size.Y,size.Z)*0.16,CFrame.new(0,size.Y*0.10,-size.Z*0.62),WHITE_GOLD,Enum.Material.Glass,0.10)
	elseif kind == "Engine" or kind == "Machine" or kind == "Core" then
		ball(root,rarityFolder,"UltimatePowerCore",math.min(size.X,size.Y,size.Z)*0.26,CFrame.new(0,0,-size.Z*0.58),WHITE_GOLD,Enum.Material.Neon,0.03)
	end
end

local function applyPart(part: BasePart)
	local itemId = itemIdFromPart(part)
	if not itemId then return end
	local definition = ItemConfig[itemId]
	local visual = PrototypeVisualConfig.Items[itemId]
	if not definition or not visual then return end
	local baseId = tostring(definition.BaseItemId or itemId)
	local baseDef = LootCatalog.ById[baseId]
	if not baseDef then return end

	if part:GetAttribute("M6CArtItemId") == itemId and part:FindFirstChild("M6CArt") then return end
	clearOld(part)

	part.Color = visual.Color
	part.Material = visual.Material
	part:SetAttribute("M6CArtItemId", itemId)
	part:SetAttribute("M6CBaseItemId", baseId)
	part:SetAttribute("M6CRarity", visual.Rarity)
	part:SetAttribute("M6CRarityRank", visual.RarityRank)

	local folder = Instance.new("Folder")
	folder.Name = "M6CArt"
	folder.Parent = part

	buildKindBase(part, folder, definition, visual)
	addItemSpecific(part, folder, baseId, baseDef, visual)
	addRarityModules(part, folder, definition, visual)

	local manifest = ItemArtManifest.Items[baseId]
	if manifest then
		part:SetAttribute("M6CModelSource", manifest.ModelSource)
		part:SetAttribute("M6CProduction", manifest.Production)
	end

	appliedCount += 1
	appliedBaseIds[baseId] = true
end

local function deferredApply(instance: Instance)
	if not instance:IsA("BasePart") then return end
	-- LootPresentationService is registered first and uses task.defer; give it one
	-- extra scheduling turn so M6C becomes the final presentation layer.
	task.defer(function()
		task.defer(function()
			if instance.Parent then applyPart(instance) end
		end)
	end)
end

local function watchCharacter(character: Model)
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then deferredApply(descendant) end
	end
	character.DescendantAdded:Connect(deferredApply)
end

local function watchPlayer(player: Player)
	player.CharacterAdded:Connect(watchCharacter)
	if player.Character then watchCharacter(player.Character) end
end

function Service.Start(world: Folder)
	generation += 1
	appliedCount = 0
	table.clear(appliedBaseIds)

	for _, player in Players:GetPlayers() do watchPlayer(player) end
	Players.PlayerAdded:Connect(watchPlayer)

	for _, descendant in world:GetDescendants() do
		if descendant:IsA("BasePart") then deferredApply(descendant) end
	end
	world.DescendantAdded:Connect(deferredApply)

	task.delay(1.0,function()
		if not world.Parent then return end
		local represented = 0
		for _ in appliedBaseIds do represented += 1 end
		world:SetAttribute("M6CArtEnabled",true)
		world:SetAttribute("M6CManifestItems",ItemArtManifest.Counts.Total)
		world:SetAttribute("M6CManifestStudio",ItemArtManifest.Counts.Studio)
		world:SetAttribute("M6CManifestMesh",ItemArtManifest.Counts.CustomMesh)
		world:SetAttribute("M6CManifestBlender",ItemArtManifest.Counts.Blender)
		world:SetAttribute("M6CRepresentedBaseItems",represented)
		world:SetAttribute("M6CAppliedInstances",appliedCount)
	end)
end

return Service
