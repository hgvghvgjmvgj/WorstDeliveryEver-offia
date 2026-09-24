--!strict

local Selection = game:GetService("Selection")

local Builder = {}

local function vec3(value: any, fallback: Vector3?): Vector3
	if typeof(value) == "Vector3" then
		return value
	end
	if type(value) == "table" and #value >= 3 then
		return Vector3.new(tonumber(value[1]) or 0, tonumber(value[2]) or 0, tonumber(value[3]) or 0)
	end
	return fallback or Vector3.zero
end

local function color3(value: any, fallback: Color3?): Color3
	if typeof(value) == "Color3" then
		return value
	end
	if type(value) == "table" and #value >= 3 then
		return Color3.fromRGB(
			math.clamp(tonumber(value[1]) or 255, 0, 255),
			math.clamp(tonumber(value[2]) or 255, 0, 255),
			math.clamp(tonumber(value[3]) or 255, 0, 255)
		)
	end
	return fallback or Color3.fromRGB(163, 162, 165)
end

local function material(name: any): Enum.Material
	if type(name) == "string" then
		local ok, result = pcall(function()
			return Enum.Material[name]
		end)
		if ok and result then
			return result
		end
	end
	return Enum.Material.SmoothPlastic
end

local function partFromSpec(spec: any): BasePart
	local partType = string.lower(tostring(spec.Type or "Block"))
	local part: BasePart
	if partType == "wedge" then
		part = Instance.new("WedgePart")
	elseif partType == "cornerwedge" then
		part = Instance.new("CornerWedgePart")
	else
		local normal = Instance.new("Part")
		if partType == "cylinder" then
			normal.Shape = Enum.PartType.Cylinder
		elseif partType == "ball" or partType == "sphere" then
			normal.Shape = Enum.PartType.Ball
		else
			normal.Shape = Enum.PartType.Block
		end
		part = normal
	end

	part.Name = tostring(spec.Name or "Part")
	part.Size = vec3(spec.Size, Vector3.new(2, 2, 2))
	part.Color = color3(spec.Color)
	part.Material = material(spec.Material)
	part.Transparency = math.clamp(tonumber(spec.Transparency) or 0, 0, 1)
	part.Reflectance = math.clamp(tonumber(spec.Reflectance) or 0, 0, 1)
	part.Anchored = true
	part.CanCollide = spec.CanCollide ~= false
	part.CanQuery = spec.CanQuery ~= false
	part.CanTouch = spec.CanTouch ~= false
	part.CastShadow = spec.CastShadow ~= false

	local pos = vec3(spec.Position)
	local rot = vec3(spec.Rotation)
	part.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))

	if spec.ShapeTag then
		part:SetAttribute("ShapeTag", tostring(spec.ShapeTag))
	end
	return part
end

local function selectedPivot(): CFrame?
	local selected = Selection:Get()
	if #selected == 0 then
		return nil
	end
	local first = selected[1]
	if first:IsA("Model") then
		return first:GetPivot()
	elseif first:IsA("BasePart") then
		return first.CFrame
	end
	return nil
end

local function addAnchor(root: BasePart, name: string, position: Vector3)
	local attachment = Instance.new("Attachment")
	attachment.Name = name
	attachment.Position = position
	attachment.Parent = root
end

function Builder.Validate(recipe: any): (boolean, string)
	if type(recipe) ~= "table" then
		return false, "Recipe must be a JSON object."
	end
	if type(recipe.Name) ~= "string" or recipe.Name == "" then
		return false, "Recipe.Name is required."
	end
	if type(recipe.Parts) ~= "table" or #recipe.Parts == 0 then
		return false, "Recipe.Parts must contain at least one part."
	end
	for i, spec in ipairs(recipe.Parts) do
		if type(spec) ~= "table" then
			return false, string.format("Part %d must be an object.", i)
		end
		if type(spec.Name) ~= "string" or spec.Name == "" then
			return false, string.format("Part %d is missing Name.", i)
		end
		if type(spec.Size) ~= "table" or #spec.Size < 3 then
			return false, string.format("Part %d (%s) needs Size [x,y,z].", i, spec.Name)
		end
	end
	return true, "Recipe is valid."
end

function Builder.Build(recipe: any): Model
	local ok, message = Builder.Validate(recipe)
	if not ok then
		error(message)
	end

	local model = Instance.new("Model")
	model.Name = recipe.Name
	model:SetAttribute("OneTripGenerated", true)
	model:SetAttribute("CargoId", tostring(recipe.CargoId or recipe.Name))
	model:SetAttribute("SectionId", tostring(recipe.SectionId or "Unassigned"))
	model:SetAttribute("Rarity", tostring(recipe.Rarity or "Common"))
	model:SetAttribute("GeneratorVersion", "0.1.0")

	for _, spec in ipairs(recipe.Parts) do
		local part = partFromSpec(spec)
		part.Parent = model
	end

	model.Parent = workspace

	local origin = vec3(recipe.Origin, Vector3.new(0, 5, 0))
	local basePivot = CFrame.new(origin)
	if recipe.BuildAtSelection == true then
		basePivot = selectedPivot() or basePivot
	end
	model:PivotTo(basePivot)

	local boundsCf, boundsSize = model:GetBoundingBox()
	local root = Instance.new("Part")
	root.Name = "_OT_Root"
	root.Size = Vector3.new(math.max(boundsSize.X, 0.2), math.max(boundsSize.Y, 0.2), math.max(boundsSize.Z, 0.2))
	root.CFrame = boundsCf
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.CanQuery = false
	root.CanTouch = false
	root.CastShadow = false
	root.Parent = model
	model.PrimaryPart = root

	local hitbox = Instance.new("Part")
	hitbox.Name = "CarryHitbox"
	hitbox.Size = root.Size
	hitbox.CFrame = root.CFrame
	hitbox.Transparency = 1
	hitbox.Anchored = true
	hitbox.CanCollide = false
	hitbox.CanTouch = false
	hitbox.CanQuery = true
	hitbox.CastShadow = false
	hitbox:SetAttribute("CarryHitbox", true)
	hitbox.Parent = model

	local half = root.Size * 0.5
	addAnchor(root, "VFX_Core", Vector3.zero)
	addAnchor(root, "VFX_Top", Vector3.new(0, half.Y, 0))
	addAnchor(root, "VFX_Left", Vector3.new(-half.X, 0, 0))
	addAnchor(root, "VFX_Right", Vector3.new(half.X, 0, 0))
	addAnchor(root, "VFX_Front", Vector3.new(0, 0, -half.Z))

	if type(recipe.Attributes) == "table" then
		for key, value in pairs(recipe.Attributes) do
			if type(key) == "string" and (type(value) == "string" or type(value) == "number" or type(value) == "boolean") then
				model:SetAttribute(key, value)
			end
		end
	end

	Selection:Set({ model })
	return model
end

return Builder
