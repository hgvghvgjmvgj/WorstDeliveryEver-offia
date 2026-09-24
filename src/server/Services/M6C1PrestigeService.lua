--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local LootCatalog = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LootCatalog"))
local PrototypeVisualConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PrototypeVisualConfig"))
local RarityConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("RarityConfig"))

local Service = {}

local applied = 0
local auraCount = 0
local particleCount = 0
local lightCount = 0

local WHITE_GOLD = Color3.fromRGB(250, 239, 194)
local PALE_GOLD = Color3.fromRGB(229, 199, 118)
local DARK_METAL = Color3.fromRGB(45, 51, 60)
local CYAN = Color3.fromRGB(78, 220, 240)
local MAGENTA = Color3.fromRGB(226, 72, 188)

local function itemIdFromPart(part: BasePart): string?
	local attr = part:GetAttribute("ItemId")
	if typeof(attr) == "string" and attr ~= "" then return attr end
	local fromName = string.match(part.Name, "^Carry_(.+)_%d+$")
	if fromName and fromName ~= "" then return fromName end
	return nil
end

local function detail(root: BasePart, folder: Folder, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material?, transparency: number?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = Vector3.new(math.max(0.08,size.X), math.max(0.08,size.Y), math.max(0.08,size.Z))
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
	part:SetAttribute("M6C1Visual", true)
	part.Parent = folder
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = part
	weld.Parent = part
	return part
end

local function ball(root: BasePart, folder: Folder, name: string, diameter: number, offset: CFrame, color: Color3, material: Enum.Material?, transparency: number?): Part
	local p = detail(root,folder,name,Vector3.new(diameter,diameter,diameter),offset,color,material,transparency)
	p.Shape = Enum.PartType.Ball
	return p
end

local function cylinder(root: BasePart, folder: Folder, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material?, transparency: number?): Part
	local p = detail(root,folder,name,size,offset,color,material,transparency)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function token(text: string, query: string): boolean
	return string.find(string.lower(text), string.lower(query), 1, true) ~= nil
end

local function clear(root: BasePart)
	local old = root:FindFirstChild("M6C1Prestige")
	if old then old:Destroy() end
	local oldHighlight = root:FindFirstChild("M6C1AuraHighlight")
	if oldHighlight then oldHighlight:Destroy() end
	local oldAttachment = root:FindFirstChild("M6C1Aura")
	if oldAttachment then oldAttachment:Destroy() end
	local oldLight = root:FindFirstChild("M6C1PrestigeLight")
	if oldLight then oldLight:Destroy() end
end

local function addAura(root: BasePart, folder: Folder, rank: number, color: Color3)
	if rank < 3 then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "M6C1AuraHighlight"
	highlight.Adornee = root
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = color
	highlight.OutlineColor = color:Lerp(Color3.new(1,1,1), if rank >= 8 then 0.65 else 0.28)
	local fillTransparency = ({[3]=0.96,[4]=0.93,[5]=0.89,[6]=0.86,[7]=0.82,[8]=0.78})[rank] or 0.94
	local outlineTransparency = ({[3]=0.72,[4]=0.56,[5]=0.38,[6]=0.27,[7]=0.17,[8]=0.08})[rank] or 0.70
	highlight.FillTransparency = fillTransparency
	highlight.OutlineTransparency = outlineTransparency
	highlight.Parent = root
	auraCount += 1

	-- Epic+ gets a restrained under-object aura plate. It is intentionally faint
	-- so stacks remain readable and the object silhouette stays primary.
	if rank >= 4 then
		local diameter = math.max(root.Size.X,root.Size.Z) * (if rank >= 7 then 1.18 else 1.08)
		local haloColor = if rank == 8 then WHITE_GOLD else color
		local plate = cylinder(root,folder,"AuraPlate",Vector3.new(0.10,diameter,diameter),CFrame.new(0,-root.Size.Y*0.54,0)*CFrame.Angles(0,0,math.rad(90)),haloColor,Enum.Material.Neon,if rank >= 7 then 0.74 else 0.82)
		plate.CastShadow = false
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "M6C1Aura"
	attachment.Parent = root

	local rates = {[5]=0.35,[6]=0.75,[7]=1.30,[8]=0.95}
	local rate = rates[rank]
	if rate then
		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = "PrestigeSparks"
		emitter.Rate = rate
		emitter.Lifetime = NumberRange.new(if rank >= 7 then 0.70 else 0.45, if rank >= 7 then 1.15 else 0.80)
		emitter.Speed = NumberRange.new(0.10, if rank >= 7 then 0.55 else 0.35)
		emitter.Drag = 0.8
		emitter.SpreadAngle = Vector2.new(55,55)
		emitter.LightEmission = if rank >= 7 then 0.65 else 0.35
		emitter.Color = if rank == 8
			then ColorSequence.new(WHITE_GOLD,Color3.fromRGB(215,236,255))
			elseif rank == 7
			then ColorSequence.new(color,Color3.fromRGB(117,88,230))
			else ColorSequence.new(color,color:Lerp(Color3.new(1,1,1),0.25))
		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, if rank >= 7 then 0.12 else 0.08),
			NumberSequenceKeypoint.new(0.65, if rank >= 7 then 0.07 else 0.04),
			NumberSequenceKeypoint.new(1,0),
		})
		emitter.Parent = attachment
		particleCount += 1
	end

	-- PointLights are deliberately reserved for Cosmic/Eternal only.
	if rank >= 7 then
		local light = Instance.new("PointLight")
		light.Name = "M6C1PrestigeLight"
		light.Color = if rank == 8 then WHITE_GOLD else color
		light.Brightness = if rank == 8 then 0.34 else 0.22
		light.Range = math.clamp(root.Size.Magnitude * 1.15,6,12)
		light.Shadows = false
		light.Parent = root
		lightCount += 1
	end
end

local function addPrestigeGeometry(root: BasePart, folder: Folder, definition: any, visual: any)
	local rank = tonumber(visual.RarityRank) or 1
	if rank < 4 then return end
	local size = root.Size
	local rarity = tostring(visual.Rarity or definition.Rarity or "Common")
	local color = visual.RarityColor or RarityConfig.Tiers[rarity].Color
	local kind = tostring(definition.ModelKind or "Legacy")

	-- Epic: one extra silhouette break beyond M6C's cap/side modules.
	for _, x in {-size.X*0.46,size.X*0.46} do
		detail(root,folder,"EpicShoulder",Vector3.new(math.max(0.16,size.X*0.07),math.max(0.16,size.Y*0.13),size.Z*0.70),CFrame.new(x,size.Y*0.35,0),color:Lerp(Color3.new(0,0,0),0.12),Enum.Material.Metal,0)
	end
	if rank == 4 then return end

	-- Legendary: premium normal-world redesign with a crown rail and front crest.
	local legendaryColor = if rank == 5 then Color3.fromRGB(231,179,68) else color
	detail(root,folder,"PrestigeCrownRail",Vector3.new(size.X*0.72,math.max(0.15,size.Y*0.05),math.max(0.15,size.Z*0.10)),CFrame.new(0,size.Y*0.58,-size.Z*0.30),legendaryColor,Enum.Material.Metal,0)
	detail(root,folder,"PrestigeCrest",Vector3.new(size.X*0.20,math.max(0.14,size.Y*0.08),0.13),CFrame.new(0,size.Y*0.24,-size.Z*0.60),legendaryColor,Enum.Material.Neon,0.12)
	if kind == "Sofa" or kind == "Chair" or kind == "Table" then
		for _, x in {-size.X*0.39,size.X*0.39} do
			detail(root,folder,"PrestigeFurnitureFoot",Vector3.new(math.max(0.15,size.X*0.05),math.max(0.22,size.Y*0.18),math.max(0.15,size.Z*0.06)),CFrame.new(x,-size.Y*0.50,size.Z*0.20),legendaryColor,Enum.Material.Metal,0)
		end
	end
	if rank == 5 then return end

	-- Mythic: visibly beyond premium, with suspended-looking energy nodes.
	for index, offset in {Vector3.new(-size.X*0.58,size.Y*0.18,0),Vector3.new(size.X*0.58,size.Y*0.18,0),Vector3.new(0,size.Y*0.62,0)} do
		local node = ball(root,folder,"MythicFocus"..index,math.max(0.22,math.min(size.X,size.Y,size.Z)*0.10),CFrame.new(offset),color,Enum.Material.Neon,0.04)
		node.CastShadow = false
	end
	detail(root,folder,"MythicSpine",Vector3.new(math.max(0.12,size.X*0.035),size.Y*0.66,math.max(0.12,size.Z*0.035)),CFrame.new(0,0,size.Z*0.55),color:Lerp(DARK_METAL,0.35),Enum.Material.Metal,0)
	if rank == 6 then return end

	-- Cosmic: stronger containment silhouette, not just cyan paint.
	for _, y in {-size.Y*0.28,size.Y*0.28} do
		local ring = cylinder(root,folder,"CosmicOrbitFrame",Vector3.new(math.max(0.12,size.X*0.035),size.Z*1.30,size.Z*1.30),CFrame.new(0,y,0)*CFrame.Angles(0,0,math.rad(90)),color,Enum.Material.Neon,0.22)
		ring.CastShadow = false
	end
	for _, x in {-size.X*0.60,size.X*0.60} do
		detail(root,folder,"CosmicStabilizer",Vector3.new(size.X*0.10,size.Y*0.68,size.Z*0.20),CFrame.new(x,0,0)*CFrame.Angles(0,0,math.rad(if x < 0 then -9 else 9)),Color3.fromRGB(58,72,112),Enum.Material.Metal,0)
	end
	if rank == 7 then return end

	-- Eternal: cleaner final-form prestige. White-gold frame + prismatic focus.
	for _, x in {-size.X*0.52,size.X*0.52} do
		detail(root,folder,"EternalPillar",Vector3.new(math.max(0.16,size.X*0.055),size.Y*0.90,math.max(0.16,size.Z*0.07)),CFrame.new(x,0,0),WHITE_GOLD,Enum.Material.Metal,0)
	end
	detail(root,folder,"EternalArch",Vector3.new(size.X*1.02,math.max(0.16,size.Y*0.06),math.max(0.16,size.Z*0.10)),CFrame.new(0,size.Y*0.62,0),WHITE_GOLD,Enum.Material.Metal,0)
	local focus = ball(root,folder,"EternalPrismaticFocus",math.max(0.26,math.min(size.X,size.Y,size.Z)*0.13),CFrame.new(0,size.Y*0.54,-size.Z*0.60),Color3.fromRGB(222,240,255),Enum.Material.Glass,0.12)
	focus.Reflectance = 0.12
end

local function addIdentityPolish(root: BasePart, folder: Folder, baseId: string, baseDef: any, visual: any)
	local size = root.Size
	local baseColor = visual.BaseColor or root.Color
	local light = baseColor:Lerp(Color3.new(1,1,1),0.24)
	local dark = baseColor:Lerp(Color3.new(0,0,0),0.38)
	local lower = string.lower(baseId)

	-- APPLIANCES: stronger front-face identity and recognizable controls.
	if baseId == "Refrigerator" or baseId == "MiniFridge" or baseId == "PrototypeSmartFridge" then
		detail(root,folder,"FridgeDoorSplit",Vector3.new(0.12,size.Y*0.78,0.13),CFrame.new(0,-size.Y*0.03,-size.Z*0.57),dark,Enum.Material.Metal,0)
		detail(root,folder,"FridgeKickPlate",Vector3.new(size.X*0.72,math.max(0.14,size.Y*0.055),0.14),CFrame.new(0,-size.Y*0.43,-size.Z*0.57),dark,Enum.Material.Metal,0)
		if baseId ~= "MiniFridge" then
			detail(root,folder,"FridgeDispenser",Vector3.new(size.X*0.25,size.Y*0.17,0.15),CFrame.new(-size.X*0.18,size.Y*0.08,-size.Z*0.59),Color3.fromRGB(40,55,68),Enum.Material.Glass,0.06)
		end
	elseif baseId == "Washer" or baseId == "Dryer" then
		local knob = cylinder(root,folder,"LaundryDial",Vector3.new(0.18,size.X*0.12,size.X*0.12),CFrame.new(size.X*0.26,size.Y*0.37,-size.Z*0.57)*CFrame.Angles(0,0,math.rad(90)),dark,Enum.Material.Metal,0)
		knob.CastShadow = false
		detail(root,folder,"LaundryKick",Vector3.new(size.X*0.68,0.14,0.14),CFrame.new(0,-size.Y*0.45,-size.Z*0.57),dark,Enum.Material.Metal,0)
	elseif baseId == "Microwave" or baseId == "CountertopOven" then
		detail(root,folder,"ApplianceGlassDoor",Vector3.new(size.X*0.64,size.Y*0.62,0.14),CFrame.new(-size.X*0.08,0,-size.Z*0.57),Color3.fromRGB(28,34,43),Enum.Material.Glass,0.10)
		for _, y in {-size.Y*0.18,0,size.Y*0.18} do
			ball(root,folder,"ControlButton",math.max(0.10,size.X*0.035),CFrame.new(size.X*0.36,y,-size.Z*0.60),light,Enum.Material.Metal,0)
		end
	elseif baseId == "OvenRange" then
		detail(root,folder,"OvenGlass",Vector3.new(size.X*0.66,size.Y*0.52,0.14),CFrame.new(0,-size.Y*0.12,-size.Z*0.57),Color3.fromRGB(27,30,35),Enum.Material.Glass,0.08)
		for _, x in {-size.X*0.26,-size.X*0.09,size.X*0.09,size.X*0.26} do
			ball(root,folder,"RangeKnob",math.max(0.11,size.X*0.035),CFrame.new(x,size.Y*0.36,-size.Z*0.59),light,Enum.Material.Metal,0)
		end
	end

	-- FURNITURE: stronger cushions/frames and product-specific supports.
	if baseId == "Couch" or baseId == "SectionalSofa" or baseId == "LuxurySofa" then
		for _, x in {-size.X*0.30,0,size.X*0.30} do
			detail(root,folder,"BackPillow",Vector3.new(size.X*0.26,size.Y*0.36,math.max(0.20,size.Z*0.13)),CFrame.new(x,size.Y*0.22,size.Z*0.37),light,Enum.Material.SmoothPlastic,0)
		end
	elseif baseId == "OfficeChair" then
		detail(root,folder,"ChairCenterPost",Vector3.new(0.24,size.Y*0.38,0.24),CFrame.new(0,-size.Y*0.34,0),DARK_METAL,Enum.Material.Metal,0)
		for _, angle in {0,90,180,270} do
			local rad = math.rad(angle)
			detail(root,folder,"ChairCasterArm",Vector3.new(size.X*0.28,0.16,0.16),CFrame.new(math.cos(rad)*size.X*0.18,-size.Y*0.50,math.sin(rad)*size.Z*0.18)*CFrame.Angles(0,-rad,0),DARK_METAL,Enum.Material.Metal,0)
		end
	elseif baseId == "DiningChairBasic" or baseId == "DesignerChair" then
		detail(root,folder,"ChairBackInset",Vector3.new(size.X*0.62,size.Y*0.34,0.15),CFrame.new(0,size.Y*0.30,size.Z*0.48),light,Enum.Material.SmoothPlastic,0)
	elseif baseId == "Mattress" then
		for _, z in {-size.Z*0.44,size.Z*0.44} do
			detail(root,folder,"MattressPiping",Vector3.new(size.X*0.92,0.11,0.11),CFrame.new(0,size.Y*0.47,z),dark,Enum.Material.SmoothPlastic,0)
		end
	elseif baseId == "CoffeeTable" or baseId == "DiningTable" or baseId == "MarbleTable" then
		detail(root,folder,"TableTopInset",Vector3.new(size.X*0.78,0.10,size.Z*0.72),CFrame.new(0,size.Y*0.49,0),light,if baseId == "MarbleTable" then Enum.Material.Marble else Enum.Material.WoodPlanks,0)
	end

	-- ELECTRONICS / RECREATION.
	if baseId == "GamingPC" then
		local side = detail(root,folder,"PCGlassSide",Vector3.new(size.X*0.82,size.Y*0.72,0.12),CFrame.new(0,0,-size.Z*0.57),Color3.fromRGB(37,56,72),Enum.Material.Glass,0.28)
		side.Reflectance = 0.05
		for _, y in {-size.Y*0.23,0,size.Y*0.23} do
			ball(root,folder,"PCFan",math.max(0.24,size.X*0.18),CFrame.new(-size.X*0.25,y,-size.Z*0.60),CYAN,Enum.Material.Neon,0.16)
		end
		detail(root,folder,"GPUAccent",Vector3.new(size.X*0.46,0.18,0.12),CFrame.new(size.X*0.10,-size.Y*0.13,-size.Z*0.61),MAGENTA,Enum.Material.Neon,0.18)
	elseif baseId == "Television" or baseId == "GamingMonitor" then
		detail(root,folder,"ScreenInner",Vector3.new(size.X*0.76,size.Y*0.64,0.10),CFrame.new(0,0,-size.Z*0.59),Color3.fromRGB(20,32,46),Enum.Material.Glass,0.04)
	elseif baseId == "ArcadeCabinet" then
		detail(root,folder,"ArcadeMarquee",Vector3.new(size.X*0.76,size.Y*0.18,0.18),CFrame.new(0,size.Y*0.43,-size.Z*0.55),Color3.fromRGB(225,87,196),Enum.Material.Neon,0.12)
		detail(root,folder,"ArcadeControlDeck",Vector3.new(size.X*0.70,0.24,size.Z*0.30),CFrame.new(0,-size.Y*0.02,-size.Z*0.48)*CFrame.Angles(math.rad(-12),0,0),dark,Enum.Material.Metal,0)
		ball(root,folder,"ArcadeJoystick",math.max(0.12,size.X*0.05),CFrame.new(-size.X*0.20,size.Y*0.04,-size.Z*0.64),Color3.fromRGB(224,69,75),Enum.Material.SmoothPlastic,0)
	end

	-- GARAGE / INDUSTRIAL.
	if token(lower,"engine") then
		for _, x in {-size.X*0.28,size.X*0.28} do
			detail(root,folder,"EngineHeader",Vector3.new(size.X*0.14,size.Y*0.52,size.Z*0.14),CFrame.new(x,0,-size.Z*0.38)*CFrame.Angles(0,0,math.rad(if x < 0 then -18 else 18)),Color3.fromRGB(117,124,132),Enum.Material.Metal,0)
		end
		detail(root,folder,"EngineTopIntake",Vector3.new(size.X*0.42,size.Y*0.20,size.Z*0.42),CFrame.new(0,size.Y*0.56,0),light,Enum.Material.Metal,0)
	elseif token(lower,"compressor") or token(lower,"pump") or token(lower,"hydraulic") then
		cylinder(root,folder,"IndustrialTank",Vector3.new(size.X*0.44,size.Y*0.56,size.Y*0.56),CFrame.new(-size.X*0.16,0,0)*CFrame.Angles(0,0,math.rad(90)),light,Enum.Material.Metal,0)
		detail(root,folder,"IndustrialMotor",Vector3.new(size.X*0.34,size.Y*0.42,size.Z*0.44),CFrame.new(size.X*0.25,-size.Y*0.05,0),dark,Enum.Material.Metal,0)
	end

	-- LUXURY / FRAGRANCE.
	if token(lower,"fragrance") or token(lower,"parfum") or token(lower,"oud") or token(lower,"perfumer") then
		detail(root,folder,"LuxuryInnerFrame",Vector3.new(size.X*0.86,size.Y*0.70,0.12),CFrame.new(0,0,-size.Z*0.61),Color3.fromRGB(188,149,76),Enum.Material.Metal,0)
		for index, x in {-size.X*0.27,-size.X*0.09,size.X*0.09,size.X*0.27} do
			local bottleColor = Color3.fromRGB(110+index*20,70+index*12,136+index*8)
			detail(root,folder,"PerfumeBottle",Vector3.new(size.X*0.11,size.Y*0.22,size.Z*0.13),CFrame.new(x,-size.Y*0.10,-size.Z*0.66),bottleColor,Enum.Material.Glass,0.12)
			ball(root,folder,"PerfumeCap",math.max(0.09,size.X*0.035),CFrame.new(x,size.Y*0.04,-size.Z*0.66),PALE_GOLD,Enum.Material.Metal,0)
		end
	end

	-- SECURE / VAULT.
	if token(lower,"safe") or token(lower,"vault") or baseId == "HighSecurityCase" then
		local wheel = cylinder(root,folder,"VaultWheel",Vector3.new(0.16,size.Y*0.26,size.Y*0.26),CFrame.new(0,0,-size.Z*0.62)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(159,168,177),Enum.Material.Metal,0)
		wheel.CastShadow = false
		for angle = 0,270,90 do
			local rad = math.rad(angle)
			detail(root,folder,"VaultSpoke",Vector3.new(size.X*0.16,0.10,0.10),CFrame.new(math.cos(rad)*size.X*0.08,math.sin(rad)*size.Y*0.08,-size.Z*0.64)*CFrame.Angles(0,0,-rad),Color3.fromRGB(159,168,177),Enum.Material.Metal,0)
		end
		detail(root,folder,"VaultKeypad",Vector3.new(size.X*0.18,size.Y*0.18,0.12),CFrame.new(size.X*0.30,size.Y*0.16,-size.Z*0.63),Color3.fromRGB(38,53,67),Enum.Material.Glass,0.04)
	end

	-- RESTRICTED / PROTOTYPE.
	if baseDef.SectionId == "RestrictedPrototype" or baseId == "BlackProjectContainmentUnit" then
		local coreColor = if tonumber(visual.RarityRank) and tonumber(visual.RarityRank) >= 7 then visual.RarityColor else CYAN
		ball(root,folder,"PrototypeCore",math.max(0.30,math.min(size.X,size.Y,size.Z)*0.18),CFrame.new(0,0,-size.Z*0.58),coreColor,Enum.Material.Neon,0.06)
		for _, x in {-size.X*0.43,size.X*0.43} do
			detail(root,folder,"ContainmentRail",Vector3.new(math.max(0.15,size.X*0.05),size.Y*0.76,math.max(0.15,size.Z*0.05)),CFrame.new(x,0,0),DARK_METAL,Enum.Material.Metal,0)
		end
	end
end

local function apply(part: BasePart)
	local itemId = itemIdFromPart(part)
	if not itemId then return end
	local definition = ItemConfig[itemId]
	local visual = PrototypeVisualConfig.Items[itemId]
	if not definition or not visual then return end
	local baseId = tostring(definition.BaseItemId or itemId)
	local baseDef = LootCatalog.ById[baseId]
	if not baseDef then return end

	if part:GetAttribute("M6C1PrestigeItemId") == itemId and part:FindFirstChild("M6C1Prestige") then return end
	clear(part)

	local folder = Instance.new("Folder")
	folder.Name = "M6C1Prestige"
	folder.Parent = part
	part:SetAttribute("M6C1PrestigeItemId", itemId)

	addIdentityPolish(part,folder,baseId,baseDef,visual)
	addPrestigeGeometry(part,folder,definition,visual)
	addAura(part,folder,tonumber(visual.RarityRank) or 1,visual.RarityColor or Color3.new(1,1,1))

	applied += 1
end

local function deferred(instance: Instance)
	if not instance:IsA("BasePart") then return end
	-- M6C.1 must run after both M6C services have had a chance to attach their
	-- base and identity geometry.
	task.defer(function()
		task.defer(function()
			task.defer(function()
				if instance.Parent then apply(instance) end
			end)
		end)
	end)
end

local function watchCharacter(character: Model)
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then deferred(descendant) end
	end
	character.DescendantAdded:Connect(deferred)
end

local function watchPlayer(player: Player)
	player.CharacterAdded:Connect(watchCharacter)
	if player.Character then watchCharacter(player.Character) end
end

function Service.Start(world: Folder)
	applied = 0
	auraCount = 0
	particleCount = 0
	lightCount = 0

	for _, player in Players:GetPlayers() do watchPlayer(player) end
	Players.PlayerAdded:Connect(watchPlayer)

	for _, descendant in world:GetDescendants() do
		if descendant:IsA("BasePart") then deferred(descendant) end
	end
	world.DescendantAdded:Connect(deferred)

	task.delay(1.25,function()
		if not world.Parent then return end
		world:SetAttribute("M6C1PrestigeEnabled",true)
		world:SetAttribute("M6C1AppliedInstances",applied)
		world:SetAttribute("M6C1AuraCount",auraCount)
		world:SetAttribute("M6C1ParticleEmitterCount",particleCount)
		world:SetAttribute("M6C1PointLightCount",lightCount)
	end)
end

return Service
