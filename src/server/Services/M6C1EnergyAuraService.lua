--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local PrototypeVisualConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PrototypeVisualConfig"))

local Service = {}

local applied = 0
local beamCount = 0
local particleCount = 0
local lightCount = 0

local WHITE_GOLD = Color3.fromRGB(255, 237, 166)
local PRISM_BLUE = Color3.fromRGB(190, 226, 255)
local COSMIC_PURPLE = Color3.fromRGB(128, 84, 238)

local function itemIdFromPart(part: BasePart): string?
	local attr = part:GetAttribute("ItemId")
	if typeof(attr) == "string" and attr ~= "" then return attr end
	local carry = string.match(part.Name,"^Carry_(.+)_%d+$")
	return carry
end

local function visualPart(root: BasePart, folder: Folder, name: string, size: Vector3, offset: CFrame, color: Color3, transparency: number): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = Vector3.new(math.max(0.06,size.X),math.max(0.06,size.Y),math.max(0.06,size.Z))
	p.CFrame = root.CFrame * offset
	p.Color = color
	p.Material = Enum.Material.Neon
	p.Transparency = transparency
	p.Anchored = false
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.CastShadow = false
	p:SetAttribute("M6C1EnergyAuraVisual",true)
	p.Parent = folder
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = p
	weld.Parent = p
	return p
end

local function clearLegacyAura(root: BasePart)
	for _, name in {"M6C1AuraHighlight","M6C1Aura","M6C1PrestigeLight","M6C1EnergyAura"} do
		local old = root:FindFirstChild(name)
		if old then old:Destroy() end
	end
	local prestige = root:FindFirstChild("M6C1Prestige")
	if prestige then
		for _, name in {"AuraPlate"} do
			local old = prestige:FindFirstChild(name)
			if old then old:Destroy() end
		end
	end
	for _, child in root:GetChildren() do
		if child:GetAttribute("M6C1EnergyAttachment") == true then child:Destroy() end
	end
end

local function ring(root: BasePart, folder: Folder, name: string, radius: number, y: number, color: Color3, segments: number, transparency: number, thickness: number)
	local arc = (2 * math.pi * radius / segments) * 0.66
	for i = 0, segments - 1 do
		local theta = (i / segments) * math.pi * 2
		local x = math.cos(theta) * radius
		local z = math.sin(theta) * radius
		visualPart(
			root,
			folder,
			name .. tostring(i + 1),
			Vector3.new(arc,thickness,math.max(0.07,thickness*0.85)),
			CFrame.new(x,y,z) * CFrame.Angles(0,-theta + math.pi/2,0),
			color,
			transparency
		)
	end
end

local function radialRunes(root: BasePart, folder: Folder, radius: number, y: number, color: Color3, count: number, transparency: number)
	for i = 0, count - 1 do
		local theta = (i / count) * math.pi * 2
		local x = math.cos(theta) * radius * 0.56
		local z = math.sin(theta) * radius * 0.56
		visualPart(
			root,
			folder,
			"RuneSpoke" .. tostring(i + 1),
			Vector3.new(radius*0.48,0.06,0.08),
			CFrame.new(x,y,z) * CFrame.Angles(0,-theta,0),
			color,
			transparency
		)
	end
end

local function attachment(root: BasePart, name: string, position: Vector3): Attachment
	local a = Instance.new("Attachment")
	a.Name = name
	a.Position = position
	a:SetAttribute("M6C1EnergyAttachment",true)
	a.Parent = root
	return a
end

local function energyBeam(root: BasePart, folder: Folder, name: string, p0: Vector3, p1: Vector3, color: Color3, width: number, curve0: number, curve1: number, transparency: number)
	local a0 = attachment(root,name.."A0",p0)
	local a1 = attachment(root,name.."A1",p1)
	local beam = Instance.new("Beam")
	beam.Name = name
	beam.Attachment0 = a0
	beam.Attachment1 = a1
	beam.FaceCamera = true
	beam.Width0 = width
	beam.Width1 = width * 0.82
	beam.CurveSize0 = curve0
	beam.CurveSize1 = curve1
	beam.Segments = 20
	beam.LightEmission = 1
	beam.Color = ColorSequence.new(color)
	beam.Transparency = NumberSequence.new(transparency)
	beam.Parent = folder
	beamCount += 1
end

local function risingEnergy(root: BasePart, folder: Folder, radius: number, color: Color3, rank: number)
	local count = if rank >= 8 then 6 elseif rank >= 7 then 5 elseif rank >= 6 then 4 else 2
	local height = root.Size.Y * (if rank >= 7 then 0.88 else 0.64)
	for i = 0, count - 1 do
		local theta = (i / count) * math.pi * 2 + math.rad(15)
		local x = math.cos(theta) * radius * 0.76
		local z = math.sin(theta) * radius * 0.76
		local tilt = math.rad(if i % 2 == 0 then 10 else -10)
		visualPart(
			root,
			folder,
			"EnergyRise" .. tostring(i + 1),
			Vector3.new(0.07,height,0.09),
			CFrame.new(x,-root.Size.Y*0.06,z) * CFrame.Angles(tilt,-theta,0),
			color,
			if rank >= 7 then 0.34 else 0.46
		)
	end
end

local function particleAura(root: BasePart, rank: number, primary: Color3, secondary: Color3)
	if rank < 5 then return end
	local a = attachment(root,"EnergyEmitter",Vector3.new(0,-root.Size.Y*0.42,0))

	local wisps = Instance.new("ParticleEmitter")
	wisps.Name = "EnergyWisps"
	wisps.Texture = "rbxasset://textures/particles/fire_main.dds"
	wisps.Rate = if rank == 5 then 1.0 elseif rank == 6 then 1.8 elseif rank == 7 then 2.4 else 2.0
	wisps.Lifetime = NumberRange.new(0.55,1.05)
	wisps.Speed = NumberRange.new(0.45,1.25)
	wisps.Acceleration = Vector3.new(0,2.4,0)
	wisps.Drag = 1.1
	wisps.SpreadAngle = Vector2.new(26,26)
	wisps.Rotation = NumberRange.new(-180,180)
	wisps.RotSpeed = NumberRange.new(-80,80)
	wisps.LightEmission = 0.8
	wisps.Color = ColorSequence.new(primary,secondary)
	wisps.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,0.18),
		NumberSequenceKeypoint.new(0.65,0.38),
		NumberSequenceKeypoint.new(1,1),
	})
	wisps.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0,0.18),
		NumberSequenceKeypoint.new(0.45,0.32),
		NumberSequenceKeypoint.new(1,0),
	})
	wisps.Parent = a
	particleCount += 1

	if rank >= 6 then
		local sparks = Instance.new("ParticleEmitter")
		sparks.Name = "EnergySparks"
		sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		sparks.Rate = if rank == 6 then 0.8 elseif rank == 7 then 1.4 else 1.1
		sparks.Lifetime = NumberRange.new(0.45,0.85)
		sparks.Speed = NumberRange.new(0.35,1.0)
		sparks.Acceleration = Vector3.new(0,1.8,0)
		sparks.SpreadAngle = Vector2.new(45,45)
		sparks.LightEmission = 1
		sparks.Color = ColorSequence.new(secondary,primary)
		sparks.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.10),NumberSequenceKeypoint.new(1,0)})
		sparks.Parent = a
		particleCount += 1
	end
end

local function buildAura(root: BasePart, rank: number, rarityColor: Color3)
	clearLegacyAura(root)
	if rank < 3 then return end

	local folder = Instance.new("Folder")
	folder.Name = "M6C1EnergyAura"
	folder.Parent = root

	local radius = math.max(root.Size.X,root.Size.Z) * 0.66 + 0.7
	local y = -root.Size.Y * 0.54
	local primary = if rank == 8 then WHITE_GOLD else rarityColor
	local secondary = if rank == 8 then PRISM_BLUE elseif rank == 7 then COSMIC_PURPLE else rarityColor:Lerp(Color3.new(1,1,1),0.30)

	if rank == 3 then
		ring(root,folder,"RareRing",radius,y,primary,6,0.48,0.055)
		return
	end

	local segments = if rank == 4 then 8 elseif rank == 5 then 10 else 12
	ring(root,folder,"OuterSigil",radius,y,primary,segments,if rank >= 7 then 0.26 else 0.36,0.075)
	ring(root,folder,"InnerSigil",radius*0.70,y+0.015,secondary,math.max(6,segments-2),if rank >= 7 then 0.42 else 0.56,0.055)
	radialRunes(root,folder,radius,y+0.02,primary,if rank >= 6 then 6 else 4,if rank >= 7 then 0.42 else 0.58)

	if rank >= 5 then
		energyBeam(root,folder,"GroundArcA",Vector3.new(-radius*0.82,y+0.15,0),Vector3.new(radius*0.82,y+0.15,0),primary,0.12,radius*0.92,radius*0.92,0.20)
		energyBeam(root,folder,"GroundArcB",Vector3.new(-radius*0.82,y+0.19,0),Vector3.new(radius*0.82,y+0.19,0),secondary,0.075,-radius*0.92,-radius*0.92,0.36)
		risingEnergy(root,folder,radius,primary,rank)
	end

	if rank >= 6 then
		local topY = root.Size.Y*0.48
		energyBeam(root,folder,"ShellLeft",Vector3.new(-radius*0.74,y+0.22,0),Vector3.new(-radius*0.42,topY,0),primary,0.10,-radius*0.46,radius*0.18,0.22)
		energyBeam(root,folder,"ShellRight",Vector3.new(radius*0.74,y+0.22,0),Vector3.new(radius*0.42,topY,0),secondary,0.10,radius*0.46,-radius*0.18,0.22)
	end

	if rank >= 7 then
		energyBeam(root,folder,"OrbitFront",Vector3.new(0,0,-radius*0.86),Vector3.new(0,0,radius*0.86),primary,0.09,radius*0.72,radius*0.72,0.18)
		energyBeam(root,folder,"OrbitBack",Vector3.new(0,0,-radius*0.86),Vector3.new(0,0,radius*0.86),secondary,0.075,-radius*0.72,-radius*0.72,0.28)
	end

	particleAura(root,rank,primary,secondary)

	if rank >= 7 then
		local light = Instance.new("PointLight")
		light.Name = "M6C1EnergyAuraLight"
		light.Color = primary
		light.Brightness = if rank == 8 then 0.55 else 0.38
		light.Range = math.clamp(root.Size.Magnitude*1.45,8,16)
		light.Shadows = false
		light.Parent = root
		lightCount += 1
	end

	applied += 1
end

local function apply(root: BasePart)
	local itemId = itemIdFromPart(root)
	if not itemId then return end
	local definition = ItemConfig[itemId]
	local visual = PrototypeVisualConfig.Items[itemId]
	if not definition or not visual then return end
	local rank = tonumber(visual.RarityRank) or 1
	if root:GetAttribute("M6C1EnergyAuraItemId") == itemId and ((rank < 3 and not root:FindFirstChild("M6C1EnergyAura")) or root:FindFirstChild("M6C1EnergyAura")) then return end
	root:SetAttribute("M6C1EnergyAuraItemId",itemId)
	buildAura(root,rank,visual.RarityColor or Color3.new(1,1,1))
end

local function deferred(instance: Instance)
	if not instance:IsA("BasePart") then return end
	-- Run after base art, identity, model correction and the first M6C.1 prestige layer.
	task.defer(function() task.defer(function() task.defer(function() task.defer(function() task.defer(function()
		if instance.Parent then apply(instance) end
	end) end) end) end) end)
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
	beamCount = 0
	particleCount = 0
	lightCount = 0
	for _, player in Players:GetPlayers() do watchPlayer(player) end
	Players.PlayerAdded:Connect(watchPlayer)
	for _, descendant in world:GetDescendants() do if descendant:IsA("BasePart") then deferred(descendant) end end
	world.DescendantAdded:Connect(deferred)
	task.delay(1.7,function()
		if not world.Parent then return end
		world:SetAttribute("M6C1EnergyAuraEnabled",true)
		world:SetAttribute("M6C1EnergyAuraApplied",applied)
		world:SetAttribute("M6C1EnergyBeamCount",beamCount)
		world:SetAttribute("M6C1EnergyParticleEmitterCount",particleCount)
		world:SetAttribute("M6C1EnergyPointLightCount",lightCount)
	end)
end

return Service
