--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ClearanceConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ClearanceConfig"))
local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local CollisionService = require(script.Parent:WaitForChild("CollisionService"))
local RemoteService = require(script.Parent:WaitForChild("RemoteService"))

local ClearanceService = {}

local worldRoot: Folder? = nil
local checkpoints: {{RequiredRig: number, Z: number, BeforeSection: string}} = {}
local noticeRemote: RemoteEvent
local lastRejectAt: {[Player]: number} = {}
local recoveryAccumulator = 0
local wrappedItemService: any = nil
local originalTryTake: any = nil

local function makePart(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, transparency: number, collidable: boolean): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = collidable
	part.CanTouch = false
	part.CanQuery = collidable
	part.Material = Enum.Material.Metal
	part.Color = color
	part.Transparency = transparency
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function addLabel(anchor: BasePart, requiredRig: number, sectionId: string)
	local gui = Instance.new("BillboardGui")
	gui.Name = "ClearanceBillboard"
	gui.Adornee = anchor
	gui.Size = UDim2.fromOffset(360, 90)
	gui.StudsOffset = Vector3.new(0, 3.2, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 120
	gui.Parent = anchor

	local label = Instance.new("TextLabel")
	label.Name = "ClearanceText"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.16
	label.BackgroundColor3 = Color3.fromRGB(40, 43, 49)
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.TextColor3 = Color3.fromRGB(255, 156, 88)
	label.TextStrokeTransparency = 0.55
	label.Text = ("%s REQUIRED\n%s"):format(ClearanceConfig.RigName(requiredRig), ClearanceConfig.SectionName(sectionId))
	label.Parent = gui
end

local function gateZFor(world: Folder, sectionId: string): number?
	local gameplay = world:FindFirstChild("WarehouseGameplay")
	local sections = gameplay and gameplay:FindFirstChild("Sections")
	local model = sections and sections:FindFirstChild(sectionId)
	if not model then return nil end
	local value = model:GetAttribute("FrontZ")
	return if typeof(value) == "number" then value else nil
end

local function buildGate(folder: Folder, requiredRig: number, beforeSection: string, z: number)
	local model = Instance.new("Model")
	model.Name = ("Rig%d_%s_Checkpoint"):format(requiredRig, beforeSection)
	model:SetAttribute("RequiredRig", requiredRig)
	model:SetAttribute("BeforeSection", beforeSection)
	model:SetAttribute("GateZ", z)
	model.Parent = folder

	local lockedAccent = Color3.fromRGB(228, 105, 61)
	local dark = Color3.fromRGB(56, 63, 72)
	local mid = Color3.fromRGB(91, 99, 109)

	-- Static industrial frame. These pieces NEVER get recolored by client state.
	for _, x in {-82, 82} do
		local post = makePart(model, if x < 0 then "LeftSecurityPost" else "RightSecurityPost", Vector3.new(6, 19, 4), CFrame.new(x, 9.5, z), dark, 0.02, false)
		post:SetAttribute("ClearanceStructure", true)
		local scanner = makePart(model, "ScannerHousing", Vector3.new(7.2, 4.0, 5.0), CFrame.new(x, 7.0, z - 0.6), mid, 0.02, false)
		scanner:SetAttribute("ClearanceStructure", true)
	end
	local beam = makePart(model, "SecurityArch", Vector3.new(170, 3, 4), CFrame.new(0, 17.8, z), dark, 0.02, false)
	beam:SetAttribute("ClearanceStructure", true)

	-- Lock-state lighting is intentionally thin/transparent so the checkpoint reads
	-- as an industrial scanner, not a giant glowing wall. Future content stays visible.
	for index, y in {3.4, 8.2, 13.0} do
		local strip = makePart(model, "ScannerStrip" .. index, Vector3.new(154, 0.34, 0.42), CFrame.new(0, y, z - 1.25), lockedAccent, 0.34, false)
		strip.Material = Enum.Material.Neon
		strip:SetAttribute("ClearanceStateAccent", true)
	end
	for _, x in {-64, 64} do
		local lamp = makePart(model, "GateStateLamp", Vector3.new(2.0, 2.0, 1.0), CFrame.new(x, 14.8, z - 1.4), lockedAccent, 0.06, false)
		lamp.Material = Enum.Material.Neon
		lamp:SetAttribute("ClearanceStateAccent", true)
	end

	-- Invisible collision stays authoritative and full-width. Presentation is open;
	-- access security is not weakened.
	local blocker = makePart(model, "ClearanceBlocker", Vector3.new(172, 22, 2.4), CFrame.new(0, 11, z), Color3.new(1,1,1), 1, true)
	blocker.CanQuery = false
	blocker:SetAttribute("ClearanceBlocker", true)
	CollisionService.SetGatePart(blocker, requiredRig)

	local labelAnchor = makePart(model, "ClearanceLabelAnchor", Vector3.new(1,1,1), CFrame.new(0, 13.5, z + 2), Color3.new(1,1,1), 1, false)
	labelAnchor.CanQuery = false
	labelAnchor:SetAttribute("ClearanceLabelAnchor", true)
	addLabel(labelAnchor, requiredRig, beforeSection)
end

local function rigTier(player: Player): number
	return math.clamp(math.floor((tonumber(player:GetAttribute("HandlingRigTier")) or 0) + 0.5), 0, 5)
end

local function rejectGrab(player: Player, sectionId: string): boolean
	local required = ClearanceConfig.RequiredRig(sectionId)
	if required <= rigTier(player) then return false end
	local now = os.clock()
	if now - (lastRejectAt[player] or -math.huge) >= 1.0 then
		lastRejectAt[player] = now
		noticeRemote:FireClient(player, ("%s CLEARANCE REQUIRED FOR %s"):format(ClearanceConfig.RigName(required), ClearanceConfig.SectionName(sectionId)))
	end
	return true
end

local function installItemValidation(itemService: any)
	if wrappedItemService == itemService then return end
	wrappedItemService = itemService
	originalTryTake = itemService.TryTake
	assert(typeof(originalTryTake) == "function", "ItemService.TryTake missing")
	itemService.TryTake = function(player: Player, candidate: Instance)
		if candidate and candidate:IsA("BasePart") then
			local sectionId = candidate:GetAttribute("SectorName")
			if typeof(sectionId) == "string" and sectionId ~= "" and rejectGrab(player, sectionId) then
				return false, nil, nil
			end
		end
		return originalTryTake(player, candidate)
	end
end

local function firstLockedCheckpoint(player: Player)
	local tier = rigTier(player)
	for _, checkpoint in checkpoints do
		if checkpoint.RequiredRig > tier then return checkpoint end
	end
	return nil
end

local function recoverExploit(player: Player)
	if player:GetAttribute("ProgressionReady") ~= true then return end
	local checkpoint = firstLockedCheckpoint(player)
	if not checkpoint then return end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then return end

	if root.Position.Z < checkpoint.Z - 7 then
		local x = math.clamp(root.Position.X, -70, 70)
		local target = Vector3.new(x, root.Position.Y, checkpoint.Z + 9)
		root.CFrame = CFrame.new(target) * root.CFrame.Rotation
		root.AssemblyLinearVelocity = Vector3.zero
		noticeRemote:FireClient(player, ("%s CLEARANCE REQUIRED"):format(ClearanceConfig.RigName(checkpoint.RequiredRig)))
	end
end

function ClearanceService.Start(world: Folder, itemService: any)
	worldRoot = world
	noticeRemote = RemoteService.Get(RemoteNames.PrototypeNotice)
	table.clear(checkpoints)

	local gameplay = world:FindFirstChild("WarehouseGameplay")
	if not gameplay then return end
	local old = gameplay:FindFirstChild("ClearanceCheckpoints")
	if old then old:Destroy() end
	local folder = Instance.new("Folder")
	folder.Name = "ClearanceCheckpoints"
	folder.Parent = gameplay

	for _, checkpoint in ClearanceConfig.Checkpoints do
		local z = gateZFor(world, checkpoint.BeforeSection)
		if z then
			buildGate(folder, checkpoint.RequiredRig, checkpoint.BeforeSection, z)
			table.insert(checkpoints, {
				RequiredRig = checkpoint.RequiredRig,
				Z = z,
				BeforeSection = checkpoint.BeforeSection,
			})
		end
	end
	table.sort(checkpoints, function(a, b) return a.RequiredRig < b.RequiredRig end)
	installItemValidation(itemService)

	world:SetAttribute("M6A3ClearanceEnabled", true)
	world:SetAttribute("M6A3CheckpointCount", #checkpoints)
	world:SetAttribute("M6BGatePresentation", "IndustrialScannerOpenSightline")

	Players.PlayerRemoving:Connect(function(player) lastRejectAt[player] = nil end)
	RunService.Heartbeat:Connect(function(dt)
		recoveryAccumulator += dt
		if recoveryAccumulator < 0.20 then return end
		recoveryAccumulator = 0
		for _, player in Players:GetPlayers() do recoverExploit(player) end
	end)
end

return ClearanceService
