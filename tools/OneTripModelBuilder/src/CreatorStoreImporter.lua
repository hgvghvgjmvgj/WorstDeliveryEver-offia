--!strict

local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")

local LocalApproved = require(script.Parent:WaitForChild("ApprovedCreatorStoreAssets"))

local Importer = {}

local STORAGE_FOLDER = "OneTripImportedAssets"
local REVIEW_FOLDER = "OneTripImportedAssetReview"

local function approvedAssets(): {[string]: any}
	local configFolder = ReplicatedStorage:FindFirstChild("Config")
	local manifestModule = configFolder and configFolder:FindFirstChild("ImportedAssetManifest")
	if manifestModule and manifestModule:IsA("ModuleScript") then
		local ok, manifest = pcall(require, manifestModule)
		if ok and type(manifest) == "table" and type(manifest.Assets) == "table" then
			return manifest.Assets
		end
	end
	return LocalApproved
end

function Importer.GetApprovedAssets(): {[string]: any}
	return approvedAssets()
end

local function ensureStorage(): Folder
	local existing = ServerStorage:FindFirstChild(STORAGE_FOLDER)
	if existing and existing:IsA("Folder") then return existing end
	if existing then existing:Destroy() end
	local folder = Instance.new("Folder")
	folder.Name = STORAGE_FOLDER
	folder:SetAttribute("OneTripUnmanagedStorage", true)
	folder.Parent = ServerStorage
	return folder
end

local REMOVE_CLASSES = {
	Script = true,
	LocalScript = true,
	ModuleScript = true,
	RemoteEvent = true,
	RemoteFunction = true,
	BindableEvent = true,
	BindableFunction = true,
	Sound = true,
	Animation = true,
	AnimationController = true,
	Animator = true,
	Humanoid = true,
	ProximityPrompt = true,
	ClickDetector = true,
	SurfaceGui = true,
	BillboardGui = true,
	ParticleEmitter = true,
	Trail = true,
	Beam = true,
	Highlight = true,
	ForceField = true,
	BodyPosition = true,
	BodyVelocity = true,
	BodyGyro = true,
	BodyForce = true,
	BodyAngularVelocity = true,
	LinearVelocity = true,
	AngularVelocity = true,
	VectorForce = true,
	Torque = true,
	AlignPosition = true,
	AlignOrientation = true,
	SpringConstraint = true,
	RopeConstraint = true,
	RodConstraint = true,
	HingeConstraint = true,
	BallSocketConstraint = true,
	PrismaticConstraint = true,
	CylindricalConstraint = true,
}

local function sanitizeAsset(root: Instance, definition: any): any
	local removed = 0
	local scriptsRemoved = 0
	local warnings = {}
	local removeAllTextures = definition.RemoveAllExternalTextures == true

	for _, descendant in root:GetDescendants() do
		if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
			scriptsRemoved += 1
			removed += 1
			descendant:Destroy()
		elseif REMOVE_CLASSES[descendant.ClassName] == true then
			removed += 1
			descendant:Destroy()
		elseif removeAllTextures and (descendant:IsA("Decal") or descendant:IsA("Texture") or descendant:IsA("SurfaceAppearance")) then
			removed += 1
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.CastShadow = true
			if descendant:IsA("MeshPart") and removeAllTextures then
				pcall(function() descendant.TextureID = "" end)
				pcall(function() descendant.MaterialVariant = "" end)
			end
		end
	end

	if #root:GetDescendants() == 0 then
		table.insert(warnings, "Asset became empty after sanitization.")
	end

	return {
		Removed = removed,
		ScriptsRemoved = scriptsRemoved,
		Warnings = warnings,
	}
end

local function collectVisualChildren(raw: Instance, visual: Model)
	for _, child in raw:GetChildren() do
		if child:IsA("BasePart") or child:IsA("Model") or child:IsA("Folder") then
			child.Parent = visual
		end
	end
end

local function partCount(root: Instance): number
	local count = 0
	for _, descendant in root:GetDescendants() do
		if descendant:IsA("BasePart") then count += 1 end
	end
	return count
end

local function normalizeVisual(visual: Model, targetBounds: Vector3)
	local _, initialSize = visual:GetBoundingBox()
	local sx = targetBounds.X / math.max(initialSize.X, 0.01)
	local sy = targetBounds.Y / math.max(initialSize.Y, 0.01)
	local sz = targetBounds.Z / math.max(initialSize.Z, 0.01)
	local uniformScale = math.min(sx, sy, sz)
	uniformScale = math.clamp(uniformScale, 0.05, 25)
	visual:ScaleTo(uniformScale)

	local boundsCf, boundsSize = visual:GetBoundingBox()
	local bottomY = boundsCf.Position.Y - boundsSize.Y * 0.5
	local translation = Vector3.new(-boundsCf.Position.X, -bottomY, -boundsCf.Position.Z)
	visual:PivotTo(visual:GetPivot() + translation)

	return boundsSize, uniformScale
end

local function newPaintPart(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cf
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = true
	part.Parent = parent
	return part
end

local function neutralizeArcade(visual: Model)
	-- Some Creator Store arcade cabinets expose most of the shell as one MeshPart.
	-- A MeshPart only supports one Color3, so tinting the source cannot create a
	-- true multi-color cabinet. Use a neutral shell and deterministic, separate,
	-- nearly-flush paint geometry so the result ALWAYS reads as several colors.
	local shell = Color3.fromRGB(52, 58, 72)
	local shellSecondary = Color3.fromRGB(68, 76, 94)
	local screenColor = Color3.fromRGB(8, 12, 19)
	local gold = Color3.fromRGB(244, 190, 64)
	local orange = Color3.fromRGB(229, 104, 55)
	local purple = Color3.fromRGB(124, 82, 178)
	local teal = Color3.fromRGB(54, 190, 181)
	local cyan = Color3.fromRGB(60, 220, 219)
	local yellow = Color3.fromRGB(250, 211, 68)
	local pink = Color3.fromRGB(241, 91, 150)
	local red = Color3.fromRGB(234, 78, 72)

	-- First make the imported shell deliberately neutral. Keep tiny control pieces
	-- slightly lighter, but do not rely on them for the multi-color look.
	local _, prePaintSize = visual:GetBoundingBox()
	for _, descendant in visual:GetDescendants() do
		if descendant:IsA("BasePart") then
			local lower = string.lower(descendant.Name)
			local namedScreen = string.find(lower, "screen", 1, true)
				or string.find(lower, "display", 1, true)
				or string.find(lower, "monitor", 1, true)
			local namedControl = string.find(lower, "button", 1, true)
				or string.find(lower, "joystick", 1, true)
				or string.find(lower, "control", 1, true)

			if namedScreen then
				descendant.Color = screenColor
				descendant.Material = Enum.Material.Glass
			elseif namedControl or descendant.Size.Magnitude <= prePaintSize.Magnitude * 0.08 then
				descendant.Color = shellSecondary
				descendant.Material = Enum.Material.SmoothPlastic
			else
				descendant.Color = shell
				descendant.Material = Enum.Material.SmoothPlastic
			end
		end
	end

	local boundsCf, boundsSize = visual:GetBoundingBox()
	local halfX = boundsSize.X * 0.5
	local halfY = boundsSize.Y * 0.5
	local halfZ = boundsSize.Z * 0.5
	local paint = Instance.new("Model")
	paint.Name = "OneTripArcadePaint"
	paint:SetAttribute("ArcadePaintVersion", "MULTICOLOR-PANELS-V1")
	paint.Parent = visual

	-- Front is -Z for the approved arcade assets. These panels are intentionally
	-- thin and only 0.02-0.05 studs off the shell, so they read as paint/trim rather
	-- than the old detached replacement screen.
	local frontPlane = -halfZ - 0.035
	local insetFront = -halfZ * 0.78

	-- Gold marquee/header.
	newPaintPart(
		paint,
		"GoldMarquee",
		Vector3.new(boundsSize.X * 0.78, boundsSize.Y * 0.105, 0.07),
		boundsCf * CFrame.new(0, halfY * 0.76, insetFront),
		gold,
		Enum.Material.SmoothPlastic
	)

	-- Dark screen, kept thin and recessed relative to the front-most control deck.
	local screen = newPaintPart(
		paint,
		"InsetScreen",
		Vector3.new(boundsSize.X * 0.66, boundsSize.Y * 0.25, 0.055),
		boundsCf * CFrame.new(0, halfY * 0.34, -halfZ * 0.72),
		screenColor,
		Enum.Material.Glass
	)
	screen.Reflectance = 0.04

	-- Orange control-deck fascia directly below the screen.
	newPaintPart(
		paint,
		"OrangeControlFascia",
		Vector3.new(boundsSize.X * 0.90, boundsSize.Y * 0.095, 0.075),
		boundsCf * CFrame.new(0, -halfY * 0.02, frontPlane),
		orange,
		Enum.Material.SmoothPlastic
	)

	-- Purple lower-front insert so the cabinet cannot read as one solid shell.
	newPaintPart(
		paint,
		"PurpleLowerFront",
		Vector3.new(boundsSize.X * 0.66, boundsSize.Y * 0.29, 0.065),
		boundsCf * CFrame.new(0, -halfY * 0.50, -halfZ * 0.82),
		purple,
		Enum.Material.SmoothPlastic
	)

	-- Teal vertical rails frame the front silhouette.
	for _, xSign in {-1, 1} do
		newPaintPart(
			paint,
			if xSign < 0 then "TealRailLeft" else "TealRailRight",
			Vector3.new(math.max(0.09, boundsSize.X * 0.035), boundsSize.Y * 0.68, 0.075),
			boundsCf * CFrame.new(halfX * 0.91 * xSign, -halfY * 0.03, -halfZ * 0.70),
			teal,
			Enum.Material.SmoothPlastic
		)
	end

	-- Four unmistakably different button colors. Spheres avoid orientation issues.
	local buttonColors = {cyan, yellow, pink, red}
	local buttonXs = {-0.28, -0.09, 0.10, 0.29}
	for index, xScale in buttonXs do
		local button = newPaintPart(
			paint,
			"ColorButton" .. tostring(index),
			Vector3.new(boundsSize.X * 0.065, boundsSize.X * 0.065, boundsSize.X * 0.065),
			boundsCf * CFrame.new(boundsSize.X * xScale, -halfY * 0.005, frontPlane - 0.055),
			buttonColors[index],
			Enum.Material.Neon
		)
		button.Shape = Enum.PartType.Ball
		button.CastShadow = false
	end

	visual:SetAttribute("ArcadePaintVersion", "MULTICOLOR-PANELS-V1")
end

local function addStandardFormat(model: Model, definition: any, visual: Model)
	local boundsCf, boundsSize = visual:GetBoundingBox()
	local hitbox = Instance.new("Part")
	hitbox.Name = "CarryHitbox"
	hitbox.Size = Vector3.new(math.max(0.5,boundsSize.X),math.max(0.5,boundsSize.Y),math.max(0.5,boundsSize.Z))
	hitbox.CFrame = boundsCf
	hitbox.Transparency = 1
	hitbox.Anchored = true
	hitbox.CanCollide = false
	hitbox.CanTouch = false
	hitbox.CanQuery = true
	hitbox.CastShadow = false
	hitbox:SetAttribute("CarryHitbox",true)
	hitbox.Parent = model
	model.PrimaryPart = hitbox

	local half = hitbox.Size * 0.5
	for name, position in {
		VFX_Core = Vector3.zero,
		VFX_Top = Vector3.new(0,half.Y,0),
		VFX_Left = Vector3.new(-half.X,0,0),
		VFX_Right = Vector3.new(half.X,0,0),
		VFX_Front = Vector3.new(0,0,-half.Z),
	} do
		local attachment = Instance.new("Attachment")
		attachment.Name = name
		attachment.Position = position
		attachment.Parent = hitbox
	end

	model:SetAttribute("CargoId",definition.CargoId)
	model:SetAttribute("BaseItemId",definition.CargoId)
	model:SetAttribute("SectionId",definition.SectionId)
	model:SetAttribute("SourceAssetId",definition.AssetId)
	model:SetAttribute("OneTripImportedAsset",true)
	model:SetAttribute("Sanitized",true)
	model:SetAttribute("ImportPipelineVersion","M6C.1-ARCADE-MULTICOLOR-PANELS-V1")
	local arcadePaintVersion = visual:GetAttribute("ArcadePaintVersion")
	if arcadePaintVersion then
		model:SetAttribute("ArcadePaintVersion", arcadePaintVersion)
	end
end

local function loadAsset(assetId: number): Instance
	local ok, result = pcall(function()
		return AssetService:LoadAssetAsync(assetId)
	end)
	if not ok then
		error(
			("Creator Store import failed for asset %d: %s\nIf this is a public third-party Creator Store asset, enable 'Allow Loading Third Party Assets' in Studio/Game Settings and try again.")
				:format(assetId,tostring(result))
		)
	end
	return result
end

function Importer.Import(cargoId: string, overwrite: boolean?): any
	local definitions = approvedAssets()
	local definition = definitions[cargoId]
	assert(definition, "CargoId is not in the approved three-model proof manifest: " .. tostring(cargoId))

	local storage = ensureStorage()
	local existing = storage:FindFirstChild(cargoId)
	if existing and overwrite ~= true then
		return { Success=false, CargoId=cargoId, AssetId=definition.AssetId, Error="Template already exists. Use REBUILD SELECTED to replace it." }
	end

	local raw = loadAsset(definition.AssetId)
	local report = sanitizeAsset(raw,definition)

	local production = Instance.new("Model")
	production.Name = cargoId
	local visual = Instance.new("Model")
	visual.Name = "Visual"
	visual.Parent = production
	collectVisualChildren(raw,visual)
	raw:Destroy()

	assert(partCount(visual) > 0, "Imported asset contains no usable BaseParts after sanitization.")
	local _, scale = normalizeVisual(visual,definition.TargetBounds)
	if cargoId == "ArcadeCabinet" then neutralizeArcade(visual) end
	addStandardFormat(production,definition,visual)

	if existing then existing:Destroy() end
	production.Parent = storage

	local _, finalSize = visual:GetBoundingBox()
	local finalParts = partCount(visual)
	production:SetAttribute("ImportedPartCount",finalParts)
	production:SetAttribute("ImportedUniformScale",scale)
	production:SetAttribute("ImportedBoundsX",finalSize.X)
	production:SetAttribute("ImportedBoundsY",finalSize.Y)
	production:SetAttribute("ImportedBoundsZ",finalSize.Z)

	return {
		Success = true,
		CargoId = cargoId,
		AssetId = definition.AssetId,
		Removed = report.Removed,
		ScriptsRemoved = report.ScriptsRemoved,
		PartCount = finalParts,
		Bounds = finalSize,
		Scale = scale,
		Warnings = report.Warnings,
		Path = "ServerStorage/" .. STORAGE_FOLDER .. "/" .. cargoId,
	}
end

function Importer.ImportApproved(overwrite: boolean?): {any}
	local definitions = approvedAssets()
	local ordered = {}
	for cargoId, definition in definitions do
		table.insert(ordered,{CargoId=cargoId,Order=definition.ReviewOrder or 99})
	end
	table.sort(ordered,function(a,b) return a.Order < b.Order end)
	local results = {}
	for _, entry in ordered do
		local ok, result = pcall(Importer.Import,entry.CargoId,overwrite)
		if ok then table.insert(results,result) else table.insert(results,{Success=false,CargoId=entry.CargoId,Error=tostring(result)}) end
	end
	return results
end

local function addLabel(model: Model, cargoId: string, assetId: number)
	local hitbox = model:FindFirstChild("CarryHitbox")
	if not hitbox or not hitbox:IsA("BasePart") then return end
	local gui = Instance.new("BillboardGui")
	gui.Name = "ReviewLabel"
	gui.Adornee = hitbox
	gui.Size = UDim2.fromOffset(220,54)
	gui.StudsOffset = Vector3.new(0,hitbox.Size.Y*0.5+1.4,0)
	gui.AlwaysOnTop = true
	gui.Parent = model
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1,1)
	label.BackgroundColor3 = Color3.fromRGB(26,29,35)
	label.BackgroundTransparency = 0.08
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextColor3 = Color3.fromRGB(245,247,250)
	label.Text = cargoId .. "\nASSET " .. tostring(assetId)
	label.Parent = gui
end

function Importer.OpenReviewGallery(): Folder
	local storage = ensureStorage()
	local old = workspace:FindFirstChild(REVIEW_FOLDER)
	if old then old:Destroy() end
	local gallery = Instance.new("Folder")
	gallery.Name = REVIEW_FOLDER
	gallery.Parent = workspace

	local floor = Instance.new("Part")
	floor.Name = "NeutralReviewFloor"
	floor.Size = Vector3.new(52,0.4,22)
	floor.CFrame = CFrame.new(0,-0.2,0)
	floor.Anchored = true
	floor.Color = Color3.fromRGB(98,102,110)
	floor.Material = Enum.Material.SmoothPlastic
	floor.Parent = gallery

	local back = Instance.new("Part")
	back.Name = "NeutralReviewBackdrop"
	back.Size = Vector3.new(52,16,0.5)
	back.CFrame = CFrame.new(0,8,8)
	back.Anchored = true
	back.Color = Color3.fromRGB(48,52,60)
	back.Material = Enum.Material.SmoothPlastic
	back.Parent = gallery

	local definitions = approvedAssets()
	local ordered = {}
	for cargoId, definition in definitions do table.insert(ordered,{CargoId=cargoId,Definition=definition}) end
	table.sort(ordered,function(a,b) return (a.Definition.ReviewOrder or 99) < (b.Definition.ReviewOrder or 99) end)
	local xPositions = {-16,0,16}
	local reviewModels = {}
	for index, entry in ordered do
		local template = storage:FindFirstChild(entry.CargoId)
		if template and template:IsA("Model") then
			local clone = template:Clone()
			clone.Name = "Review_" .. entry.CargoId
			clone.Parent = gallery
			clone:PivotTo(CFrame.new(xPositions[index] or 0,0,0))
			addLabel(clone,entry.CargoId,entry.Definition.AssetId)
			table.insert(reviewModels,clone)
		end
	end

	for _, x in {-13,0,13} do
		local anchor = Instance.new("Part")
		anchor.Name = "ReviewLightAnchor"
		anchor.Size = Vector3.new(0.2,0.2,0.2)
		anchor.CFrame = CFrame.new(x,10,-3)
		anchor.Transparency = 1
		anchor.Anchored = true
		anchor.CanCollide = false
		anchor.Parent = gallery
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(246,241,225)
		light.Brightness = 1.3
		light.Range = 22
		light.Shadows = true
		light.Parent = anchor
	end

	Selection:Set(reviewModels)
	return gallery
end

return Importer