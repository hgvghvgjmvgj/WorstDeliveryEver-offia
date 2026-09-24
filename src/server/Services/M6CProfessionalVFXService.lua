--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local BatchConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("M6CProductionBatchConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local RarityConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("RarityConfig"))

local Service = {}
local watched: {[BasePart]: RBXScriptConnection} = {}
local orbitStates: {[BasePart]: any} = {}
local accumulated = 0
local applied = 0
local emitters = 0
local beams = 0
local lights = 0

local WHITE_GOLD = Color3.fromRGB(255,239,178)
local PEARL = Color3.fromRGB(226,241,255)
local MAGENTA = Color3.fromRGB(255,70,148)
local COSMIC = Color3.fromRGB(82,225,255)
local VIOLET = Color3.fromRGB(134,91,239)

local function itemIdFromRoot(root: BasePart): string?
	local attr = root:GetAttribute("ItemId")
	if typeof(attr) == "string" and attr ~= "" then return attr end
	return string.match(root.Name,"^Carry_(.+)_%d+$")
end

local function isCarried(root: BasePart): boolean
	if string.match(root.Name,"^Carry_") then return true end
	local ancestor = root:FindFirstAncestorOfClass("Model")
	return ancestor ~= nil and Players:GetPlayerFromCharacter(ancestor) ~= nil
end

local function attachment(root: BasePart, name: string, position: Vector3): Attachment
	local existing = root:FindFirstChild(name)
	if existing and existing:IsA("Attachment") then
		existing.Position = position
		return existing
	end
	local a = Instance.new("Attachment")
	a.Name = name
	a.Position = position
	a:SetAttribute("M6CProductionTemporary",true)
	a.Parent = root
	return a
end

local function standard(root: BasePart, name: string): Attachment
	local a = root:FindFirstChild(name)
	if a and a:IsA("Attachment") then return a end
	local half = root.Size * 0.5
	local pos = Vector3.zero
	if name == "VFX_Top" then pos = Vector3.new(0,half.Y,0)
	elseif name == "VFX_Left" then pos = Vector3.new(-half.X,0,0)
	elseif name == "VFX_Right" then pos = Vector3.new(half.X,0,0)
	elseif name == "VFX_Front" then pos = Vector3.new(0,0,-half.Z) end
	local created = Instance.new("Attachment")
	created.Name = name
	created.Position = pos
	created.Parent = root
	return created
end

local function newBeam(parent: Folder, name: string, a0: Attachment, a1: Attachment, color: ColorSequence, width: number, curve0: number, curve1: number, transparency: number): Beam
	local b = Instance.new("Beam")
	b.Name = name
	b.Attachment0 = a0
	b.Attachment1 = a1
	b.FaceCamera = true
	b.Width0 = width
	b.Width1 = width * 0.88
	b.CurveSize0 = curve0
	b.CurveSize1 = curve1
	b.Segments = 18
	b.LightEmission = 0.85
	b.Color = color
	b.Transparency = NumberSequence.new(transparency)
	b:SetAttribute("M6CProfessionalEffect",true)
	b.Parent = parent
	beams += 1
	return b
end

local function newEmitter(parent: Attachment, name: string, texture: string, color: ColorSequence, rate: number, life: NumberRange, speed: NumberRange, size: NumberSequence, transparency: NumberSequence): ParticleEmitter
	local e = Instance.new("ParticleEmitter")
	e.Name = name
	e.Texture = texture
	e.Rate = rate
	e.Lifetime = life
	e.Speed = speed
	e.SpreadAngle = Vector2.new(32,32)
	e.Rotation = NumberRange.new(-180,180)
	e.RotSpeed = NumberRange.new(-65,65)
	e.Drag = 1.0
	e.LightEmission = 0.82
	e.Color = color
	e.Size = size
	e.Transparency = transparency
	e:SetAttribute("M6CProfessionalEffect",true)
	e.Parent = parent
	emitters += 1
	return e
end

local function pointLight(parent: Attachment, color: Color3, brightness: number, range: number): PointLight
	local l = Instance.new("PointLight")
	l.Name = "M6CProfessionalLight"
	l.Color = color
	l.Brightness = 0
	l.Range = range
	l.Shadows = false
	l:SetAttribute("M6CProfessionalEffect",true)
	l.Parent = parent
	lights += 1
	TweenService:Create(l,TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Brightness=brightness}):Play()
	return l
end

local function clear(root: BasePart)
	orbitStates[root] = nil
	for _, name in {"M6CProfessionalVFX","M6C1EnergyAura","M6C1AuraHighlight","M6C1PrestigeLight"} do
		local old = root:FindFirstChild(name)
		if old then old:Destroy() end
	end
	for _, child in root:GetChildren() do
		if child:GetAttribute("M6CProductionTemporary") == true then child:Destroy() end
	end
	for _, anchorName in {"VFX_Core","VFX_Top","VFX_Left","VFX_Right","VFX_Front"} do
		local a = root:FindFirstChild(anchorName)
		if a and a:IsA("Attachment") then
			for _, child in a:GetChildren() do
				if child:GetAttribute("M6CProfessionalEffect") == true then child:Destroy() end
			end
		end
	end
end

local function colorPair(rank: number, rarityColor: Color3): ColorSequence
	if rank == 8 then
		return ColorSequence.new({ColorSequenceKeypoint.new(0,WHITE_GOLD),ColorSequenceKeypoint.new(0.5,PEARL),ColorSequenceKeypoint.new(1,WHITE_GOLD)})
	elseif rank == 7 then
		return ColorSequence.new({ColorSequenceKeypoint.new(0,COSMIC),ColorSequenceKeypoint.new(0.55,VIOLET),ColorSequenceKeypoint.new(1,COSMIC)})
	elseif rank == 6 then
		return ColorSequence.new(MAGENTA,rarityColor:Lerp(Color3.new(1,1,1),0.20))
	end
	return ColorSequence.new(rarityColor,rarityColor:Lerp(Color3.new(1,1,1),0.24))
end

local function spawnBurst(core: Attachment, rank: number, colors: ColorSequence, carried: boolean)
	if rank < 5 then return end
	local burst = newEmitter(
		core,"SpawnBurst","rbxasset://textures/particles/sparkles_main.dds",colors,0,
		NumberRange.new(0.38,0.72),NumberRange.new(2.2,4.6),
		NumberSequence.new({NumberSequenceKeypoint.new(0,0.22),NumberSequenceKeypoint.new(0.35,0.42),NumberSequenceKeypoint.new(1,0)}),
		NumberSequence.new({NumberSequenceKeypoint.new(0,0.08),NumberSequenceKeypoint.new(0.65,0.30),NumberSequenceKeypoint.new(1,1)})
	)
	burst:Emit(if carried then 3 elseif rank >= 7 then 10 else 6)
	task.delay(1.0,function() if burst.Parent then burst:Destroy() end end)
end

local function build(root: BasePart, rank: number, rarityColor: Color3)
	clear(root)
	if rank <= 2 then return end

	local carried = isCarried(root)
	local intensity = if carried then 0.46 else 1.0
	local folder = Instance.new("Folder")
	folder.Name = "M6CProfessionalVFX"
	folder:SetAttribute("RarityRank",rank)
	folder:SetAttribute("CarriedIntensityScale",intensity)
	folder.Parent = root

	local core = standard(root,"VFX_Core")
	local top = standard(root,"VFX_Top")
	local left = standard(root,"VFX_Left")
	local right = standard(root,"VFX_Right")
	local front = standard(root,"VFX_Front")
	local colors = colorPair(rank,rarityColor)
	local s = root.Size

	-- Rare: occasional glint only. No continuous aura cloud.
	if rank == 3 then
		newEmitter(top,"RareGlint","rbxasset://textures/particles/sparkles_main.dds",colors,0.05*intensity,NumberRange.new(0.30,0.45),NumberRange.new(0.15,0.35),NumberSequence.new({NumberSequenceKeypoint.new(0,0.10),NumberSequenceKeypoint.new(1,0)}),NumberSequence.new({NumberSequenceKeypoint.new(0,0.15),NumberSequenceKeypoint.new(1,1)}))
		return
	end

	-- Epic: first proper composition: one subtle front energy accent plus tiny glints.
	newBeam(folder,"FrontAccent",left,right,colors,0.055*intensity,s.Z*0.28,-s.Z*0.28,0.56)
	newEmitter(top,"EpicGlints","rbxasset://textures/particles/sparkles_main.dds",colors,0.10*intensity,NumberRange.new(0.35,0.60),NumberRange.new(0.10,0.30),NumberSequence.new({NumberSequenceKeypoint.new(0,0.12),NumberSequenceKeypoint.new(1,0)}),NumberSequence.new({NumberSequenceKeypoint.new(0,0.18),NumberSequenceKeypoint.new(1,1)}))
	if rank == 4 then return end

	spawnBurst(core,rank,colors,carried)

	-- Legendary: first major tier. Warm curved halo and low-rate sparks.
	local ringL = attachment(root,"M6C_RingL",Vector3.new(-s.X*0.56,-s.Y*0.44,0))
	local ringR = attachment(root,"M6C_RingR",Vector3.new(s.X*0.56,-s.Y*0.44,0))
	newBeam(folder,"LegendaryHaloA",ringL,ringR,colors,0.085*intensity,s.X*0.42,s.X*0.42,0.36)
	newBeam(folder,"LegendaryHaloB",ringL,ringR,colors,0.055*intensity,-s.X*0.42,-s.X*0.42,0.53)
	newEmitter(core,"LegendarySparks","rbxasset://textures/particles/sparkles_main.dds",colors,0.22*intensity,NumberRange.new(0.45,0.75),NumberRange.new(0.35,0.85),NumberSequence.new({NumberSequenceKeypoint.new(0,0.11),NumberSequenceKeypoint.new(1,0)}),NumberSequence.new({NumberSequenceKeypoint.new(0,0.15),NumberSequenceKeypoint.new(1,1)}))
	if rank == 5 then return end

	-- Mythic: stronger movement through wisps and side-to-top arcs.
	newBeam(folder,"MythicArcL",left,top,colors,0.08*intensity,-s.X*0.22,s.Y*0.18,0.30)
	newBeam(folder,"MythicArcR",right,top,colors,0.08*intensity,s.X*0.22,-s.Y*0.18,0.30)
	local wisps = newEmitter(core,"MythicWisps","rbxasset://textures/particles/fire_main.dds",colors,0.34*intensity,NumberRange.new(0.55,0.95),NumberRange.new(0.25,0.70),NumberSequence.new({NumberSequenceKeypoint.new(0,0.20),NumberSequenceKeypoint.new(0.55,0.36),NumberSequenceKeypoint.new(1,0)}),NumberSequence.new({NumberSequenceKeypoint.new(0,0.34),NumberSequenceKeypoint.new(0.70,0.55),NumberSequenceKeypoint.new(1,1)}))
	wisps.Acceleration = Vector3.new(0,1.7,0)
	pointLight(core,rarityColor,0.15*intensity,math.clamp(s.Magnitude*1.05,6,12))
	if rank == 6 then return end

	-- Cosmic/Eternal: two animated 3D rings. Attachments rotate; the object remains untouched.
	local a0 = attachment(root,"M6C_OrbitA0",Vector3.zero)
	local a1 = attachment(root,"M6C_OrbitA1",Vector3.zero)
	local b0 = attachment(root,"M6C_OrbitB0",Vector3.zero)
	local b1 = attachment(root,"M6C_OrbitB1",Vector3.zero)
	newBeam(folder,"OrbitA",a0,a1,colors,0.075*intensity,s.X*0.40,s.X*0.40,if rank == 8 then 0.30 else 0.22)
	newBeam(folder,"OrbitB",b0,b1,colors,0.060*intensity,-s.X*0.36,-s.X*0.36,if rank == 8 then 0.42 else 0.32)
	newEmitter(top,"StarDrift","rbxasset://textures/particles/sparkles_main.dds",colors,(if rank == 8 then 0.20 else 0.36)*intensity,NumberRange.new(0.65,1.15),NumberRange.new(0.18,0.55),NumberSequence.new({NumberSequenceKeypoint.new(0,0.12),NumberSequenceKeypoint.new(0.5,0.20),NumberSequenceKeypoint.new(1,0)}),NumberSequence.new({NumberSequenceKeypoint.new(0,0.15),NumberSequenceKeypoint.new(0.72,0.44),NumberSequenceKeypoint.new(1,1)}))
	pointLight(core,if rank == 8 then WHITE_GOLD else COSMIC,(if rank == 8 then 0.24 else 0.28)*intensity,math.clamp(s.Magnitude*1.18,7,14))
	orbitStates[root] = {
		A0=a0,A1=a1,B0=b0,B1=b1,
		Radius=math.max(s.X,s.Z)*0.60,
		Height=math.max(0.55,s.Y*0.30),
		Speed=if rank == 8 then 0.50 else 0.78,
		Phase=0,
		Tilt=if rank == 8 then math.rad(18) else math.rad(31),
	}
end

local function apply(root: BasePart)
	local itemId = itemIdFromRoot(root)
	if not itemId then return end
	local def = ItemConfig[itemId]
	if not def then return end
	local baseId = tostring(def.BaseItemId or itemId)
	if not BatchConfig.Recipes[baseId] then return end
	if root:GetAttribute("M6CProfessionalVFXItemId") == itemId and root:FindFirstChild("M6CProfessionalVFX") then return end
	root:SetAttribute("M6CProfessionalVFXItemId",itemId)
	local rarity = tostring(def.Rarity or "Common")
	local tier = RarityConfig.Tiers[rarity] or RarityConfig.Tiers.Common
	build(root,tier.Rank,tier.Color)
	applied += 1
end

local function watchPart(root: BasePart)
	if watched[root] then return end
	watched[root] = root:GetAttributeChangedSignal("ItemId"):Connect(function()
		task.defer(function() if root.Parent then apply(root) end end)
	end)
	task.defer(function() if root.Parent then apply(root) end end)
end

local function descendant(instance: Instance)
	if instance:IsA("BasePart") then watchPart(instance) end
end

local function character(model: Model)
	for _, d in model:GetDescendants() do descendant(d) end
	model.DescendantAdded:Connect(descendant)
end

local function player(p: Player)
	p.CharacterAdded:Connect(character)
	if p.Character then character(p.Character) end
end

function Service.Start(world: Folder)
	applied,emitters,beams,lights = 0,0,0,0
	for _, d in world:GetDescendants() do descendant(d) end
	world.DescendantAdded:Connect(descendant)
	for _, p in Players:GetPlayers() do player(p) end
	Players.PlayerAdded:Connect(player)

	RunService.Heartbeat:Connect(function(dt)
		accumulated += dt
		if accumulated < 1/20 then return end
		local step = accumulated
		accumulated = 0
		for root,state in orbitStates do
			if not root.Parent or not state.A0.Parent then orbitStates[root] = nil continue end
			state.Phase += step * state.Speed
			local r = state.Radius
			local h = state.Height
			local a = state.Phase
			state.A0.Position = Vector3.new(math.cos(a)*r,math.sin(a)*h,math.sin(a)*r)
			state.A1.Position = -state.A0.Position
			local b = -a*0.78 + state.Tilt
			state.B0.Position = Vector3.new(math.cos(b)*r*0.88,math.sin(b)*h*0.70,math.sin(b)*r*0.88)
			state.B1.Position = -state.B0.Position
		end
	end)

	task.delay(1.8,function()
		if not world.Parent then return end
		world:SetAttribute("M6CProfessionalVFXEnabled",true)
		world:SetAttribute("M6CProfessionalVFXApplied",applied)
		world:SetAttribute("M6CProfessionalVFXEmitters",emitters)
		world:SetAttribute("M6CProfessionalVFXBeams",beams)
		world:SetAttribute("M6CProfessionalVFXLights",lights)
		world:SetAttribute("M6CSineStatus","NOT_PROGRAMMATICALLY_ACCESSIBLE")
	end)
end

return Service
