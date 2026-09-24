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
	label.BackgroundTransparency = 0.22
	label.BackgroundColor3 = Color3.fromRGB(54, 18, 18)
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.TextColor3 = Color3.fromRGB(255, 126, 126)
	label.TextStrokeTransparency = 0.5
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

	local red = Color3.fromRGB(168, 54, 54)
	local dark = Color3.fromRGB(65, 69, 76)
	for _, x in {-82, 82} do
		local post = makePart(model, if x < 0 then "LeftSecurityPost" else "RightSecurityPost", Vector3.new(6, 20, 4), CFrame.new(x, 10, z), dark, 0.05, false)
		post:SetAttribute("ClearanceVisual", true)
	end
	local beam = makePart(model, "SecurityArch", Vector3.new(170, 3, 4), CFrame.new(0, 18.5, z), dark, 0.04, false)
	beam:SetAttribute("ClearanceVisual", true)
	local scanTop = makePart(model, "ScannerTop", Vector3.new(155, 0.8, 1.2), CFrame.new(0, 15.5, z - 1.4), red, 0.12, false)
	scanTop.Material = Enum.Material.Neon
	scanTop:SetAttribute("ClearanceVisual", true)
	local scanLow = makePart(model, "ScannerLow", Vector3.new(155, 0.55, 1.0), CFrame.new(0, 6.2, z - 1.2), red, 0.22, false)
	scanLow.Material = Enum.Material.Neon
	scanLow:SetAttribute("ClearanceVisual", true)
	local field = makePart(model, "BarrierField", Vector3.new(164, 15, 0.8), CFrame.new(0, 8.2, z), red, 0.76, false)
	field.Material = Enum.Material.Neon
	field:SetAttribute("ClearanceVisual", true)

	-- Invisible collision is separated from presentation so clients may display a
	-- green CLEARED state without ever becoming authoritative over access.
	local blocker = makePart(model, "ClearanceBlocker", Vector3.new(172, 22, 2.4), CFrame.new(0, 11, z), Color3.new(1,1,1), 1, true)
	blocker.CanQuery = false
	blocker:SetAttribute("ClearanceBlocker", true)
	CollisionService.SetGatePart(blocker, requiredRig)

	local labelAnchor = makePart(model, "ClearanceLabelAnchor", Vector3.new(1,1,1), CFrame.new(0, 14, z + 2), Color3.new(1,1,1), 1, false)
	labelAnchor.CanQuery = false
	labelAnchor:SetAttribute("ClearanceVisual", true)
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

	-- Runway progression travels toward decreasing Z. If a player somehow gets
	-- meaningfully beyond their first locked gate, put them back on its home side.
	if root.Position.Z < checkpoint.Z - 7 then
		local x = math.clamp(root.Position.X, -70, 70)
		local target = Vector3.new(x, root.Position.Y, checkpoint.Z + 9)
		root.CFrame = CFrame.new(target) * root.CFrame.Rotation
		-- Do not reset carry Sway/Pressure. An exploit recovery is a movement event,
		-- not a safe zone or free pile repair.
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

	Players.PlayerRemoving:Connect(function(player) lastRejectAt[player] = nil end)
	RunService.Heartbeat:Connect(function(dt)
		recoveryAccumulator += dt
		if recoveryAccumulator < 0.20 then return end
		recoveryAccumulator = 0
		for _, player in Players:GetPlayers() do recoverExploit(player) end
	end)
end

return ClearanceService
