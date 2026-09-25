--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ImportedAssetManifest = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ImportedAssetManifest"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))

local Service = {}
local watched: {[BasePart]: RBXScriptConnection} = {}
local warnedMissing: {[string]: boolean} = {}
local warnedStale: {[string]: boolean} = {}

local function itemId(root: BasePart): string?
	local attr = root:GetAttribute("ItemId")
	if typeof(attr) == "string" and attr ~= "" then return attr end
	local fromName = string.match(root.Name,"^Carry_(.+)_%d+$")
	if fromName and fromName ~= "" then return fromName end
	return nil
end

local function baseItemId(root: BasePart): string?
	local id = itemId(root)
	if not id then return nil end
	local definition = ItemConfig[id]
	if definition and definition.BaseItemId then return tostring(definition.BaseItemId) end
	return id
end

local function clearImported(root: BasePart)
	local existing = root:FindFirstChild("ImportedCreatorStoreVisual")
	if existing then existing:Destroy() end
	root:SetAttribute("ImportedCreatorStoreActive",false)
	root:SetAttribute("ImportedCreatorStoreAssetId",nil)
	root:SetAttribute("ImportedCreatorStoreTemplateVersion",nil)
end

local function clearProceduralArt(root: BasePart)
	for _, child in root:GetChildren() do
		local name = child.Name
		if name == "M6CArt"
			or name == "M6CIdentity"
			or name == "M6C1ModelCorrection"
			or name == "M6C1Prestige"
			or name == "M6C1EnergyAura"
			or name == "M6CProductionVisual"
			or name == "M6CProfessionalVFX"
			or name == "LootDetails"
			or string.sub(name,1,6) == "Rarity"
			or string.sub(name,1,4) == "M6C1"
		then
			child:Destroy()
		elseif child:GetAttribute("M6CVisual") == true
			or child:GetAttribute("M6C1Visual") == true
			or child:GetAttribute("M6CProductionTemporary") == true
		then
			child:Destroy()
		end
	end
end

local function copyVFXAnchors(sourceHitbox: BasePart, root: BasePart)
	for _, name in {"VFX_Core","VFX_Top","VFX_Left","VFX_Right","VFX_Front"} do
		local old = root:FindFirstChild(name)
		if old and old:IsA("Attachment") then old:Destroy() end
		local source = sourceHitbox:FindFirstChild(name)
		if source and source:IsA("Attachment") then
			local clone = source:Clone()
			clone.Parent = root
		end
	end
end

local function applyTemplate(root: BasePart, template: Model, definition: any)
	clearImported(root)
	clearProceduralArt(root)

	local clone = template:Clone()
	clone.Name = "ImportedCreatorStoreVisual"
	clone:SetAttribute("VisualOnly",true)
	clone:SetAttribute("SourceAssetId",definition.AssetId)
	clone.Parent = root

	local hitbox = clone:FindFirstChild("CarryHitbox")
	if not hitbox or not hitbox:IsA("BasePart") then
		clone:Destroy()
		warn(("[ONE TRIP] imported template %s is missing CarryHitbox; safe fallback retained"):format(definition.CargoId))
		return
	end

	clone.PrimaryPart = hitbox
	clone:PivotTo(root.CFrame)
	copyVFXAnchors(hitbox,root)

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") and descendant ~= hitbox then
			descendant.Anchored = false
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true
			local weld = Instance.new("WeldConstraint")
			weld.Name = "OneTripImportedVisualWeld"
			weld.Part0 = root
			weld.Part1 = descendant
			weld.Parent = descendant
		end
	end
	hitbox:Destroy()

	local templateVersion = template:GetAttribute("ImportPipelineVersion")

	-- The authoritative gameplay part remains unchanged for Weight/Bulk/stacking;
	-- it is only hidden while the sanitized visual template is displayed.
	root.Transparency = 1
	root:SetAttribute("ImportedCreatorStoreActive",true)
	root:SetAttribute("ImportedCreatorStoreAssetId",definition.AssetId)
	root:SetAttribute("ImportedCreatorStoreTemplateVersion",templateVersion)
	root:SetAttribute("ImportedCreatorStoreCommonProof",true)
end

local function refresh(root: BasePart)
	local baseId = baseItemId(root)
	local definition = baseId and ImportedAssetManifest.Assets[baseId]
	if not definition then
		if root:GetAttribute("ImportedCreatorStoreActive") == true then
			clearImported(root)
			root.Transparency = 0
		end
		return
	end

	local storage = ServerStorage:FindFirstChild(ImportedAssetManifest.StorageFolderName)
	local template = storage and storage:FindFirstChild(baseId)
	if not template or not template:IsA("Model") then
		clearImported(root)
		root.Transparency = 0
		if not warnedMissing[baseId] then
			warn(("[ONE TRIP] sanitized Creator Store template missing for %s. Open ONE TRIP Model Builder and refresh asset %s. Using safe procedural fallback.")
				:format(baseId,tostring(definition.AssetId)))
			warnedMissing[baseId] = true
		end
		return
	end

	local requiredVersion = ImportedAssetManifest.ImportPipelineVersion
	local templateVersion = template:GetAttribute("ImportPipelineVersion")
	if typeof(requiredVersion) == "string" and templateVersion ~= requiredVersion then
		clearImported(root)
		root.Transparency = 0
		if not warnedStale[baseId] then
			warn(("[ONE TRIP] imported template for %s is stale (%s, expected %s). Refresh approved assets in ONE TRIP Model Builder before using it. Stale visual was rejected.")
				:format(baseId,tostring(templateVersion),requiredVersion))
			warnedStale[baseId] = true
		end
		return
	end

	local currentAsset = root:GetAttribute("ImportedCreatorStoreAssetId")
	local currentVersion = root:GetAttribute("ImportedCreatorStoreTemplateVersion")
	if root:GetAttribute("ImportedCreatorStoreActive") == true
		and currentAsset == definition.AssetId
		and currentVersion == templateVersion
	then
		return
	end

	warnedMissing[baseId] = nil
	warnedStale[baseId] = nil
	applyTemplate(root,template,definition)
end

local function watch(root: BasePart)
	if watched[root] then return end
	watched[root] = root:GetAttributeChangedSignal("ItemId"):Connect(function()
		task.defer(function() if root.Parent then refresh(root) end end)
	end)
	task.defer(function() if root.Parent then refresh(root) end end)
end

function Service.Start(world: Folder)
	for _, descendant in world:GetDescendants() do
		if descendant:IsA("BasePart") then watch(descendant) end
	end
	world.DescendantAdded:Connect(function(instance)
		if instance:IsA("BasePart") then watch(instance) end
	end)
	world:SetAttribute("M6CImportedAssetProof",true)
	world:SetAttribute("M6CImportedAssetProofCount",3)
end

return Service
