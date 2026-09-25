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

local function neutralizeArcade(visual: Model)
	-- Keep the useful Creator Store geometry intact. The previous proof pass added
	-- a replacement screen/control deck in front of the cabinet, which made the
	-- monitor look detached and changed the silhouette. M6C.1 should only sanitize
	-- and restyle this asset; it should not remodel it.
	local body = Color3.fromRGB(132, 143, 158)
	local bodyDark = Color3.fromRGB(88, 99, 116)
	local trim = Color3.fromRGB(43, 50, 61)
	local screen = Color3.fromRGB(13, 19, 28)
	local control = Color3.fromRGB(63, 73, 89)
	local accent = Color3.fromRGB(77, 154, 214)

	for _, descendant in visual:GetDescendants() do
		if descendant:IsA("BasePart") then
			local lower = string.lower(descendant.Name)

			if string.find(lower, "screen", 1, true)
				or string.find(lower, "display", 1, true)
				or string.find(lower, "monitor", 1, true)
			then
				descendant.Color = screen
				descendant.Material = Enum.Material.Glass
				descendant.Reflectance = 0.04
			elseif string.find(lower, "bezel", 1, true)
				or string.find(lower, "frame", 1, true)
				or string.find(lower, "trim", 1, true)
				or string.find(lower, "border", 1, true)
			then
				descendant.Color = trim
				descendant.Material = Enum.Material.SmoothPlastic
			elseif string.find(lower, "button", 1, true)
				or string.find(lower, "joystick", 1, true)
			then
				descendant.Color = accent
				descendant.Material = Enum.Material.SmoothPlastic
			elseif string.find(lower, "control", 1, true)
				or string.find(lower, "panel", 1, true)
				or string.find(lower, "console", 1, true)
			then
				descendant.Color = control
				descendant.Material = Enum.Material.SmoothPlastic
			elseif string.find(lower, "base", 1, true)
				or string.find(lower, "back", 1, true)
			then
				descendant.Color = bodyDark
				descendant.Material = Enum.Material.SmoothPlastic
			else
				descendant.Color = body
				descendant.Material = Enum.Material.SmoothPlastic
			end
		end
	end
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
	model:SetAttribute("ImportPipelineVersion","M6C.1-CREATOR-STORE-PROOF")
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
	local finalBounds, scale = normalizeVisual(visual,definition.TargetBounds)
	if cargoId == "ArcadeCabinet" then neutralizeArcade(visual) end
	addStandardFormat(production,definition,visual)

	if existing then existing:Destroy() end
	production.Parent = storage

	local finalCf, finalSize = visual:GetBoundingBox()
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