--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MacroLayoutConfig = require(
	ReplicatedStorage:WaitForChild("Config"):WaitForChild("MacroLayoutConfig")
)

local Service = {}

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	transparency: number,
	canCollide: boolean
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = canCollide
	part.CanTouch = false
	part.CanQuery = canCollide
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Color = color
	part.Transparency = transparency
	part.Parent = parent
	return part
end

function Service.Apply(root: Folder)
	if root:GetAttribute("MacroLayoutMode") ~= "D" then
		return
	end

	local config = MacroLayoutConfig.OptionD
	local depth = config.LongTermDepth
	if not depth then
		return
	end

	-- The M6A.1 playable run still ends after Secure for timing tests, but the
	-- visible facility must not read as a warehouse that literally ends there.
	local oldBackWall = root:FindFirstChild("SecureBackWall")
	if oldBackWall then oldBackWall:Destroy() end

	local folder = Instance.new("Folder")
	folder.Name = "FutureDepthPreview"
	folder:SetAttribute("NonPlayablePreview", true)
	folder:SetAttribute("ReservedPurpose", depth.FutureExpansionPurpose)
	folder.Parent = root

	-- Invisible current-test boundary. This is beyond the six playable sections,
	-- not a progression gate; it only keeps M6A.1 travel/economy measurements
	-- comparable while the shell visually implies more warehouse ahead.
	local boundary = makePart(
		folder,
		"CurrentM6A1PlayableLimit",
		Vector3.new(config.RunwayWidth, 24, 2),
		CFrame.new(0, 12, depth.CurrentPlayableBackZ - 2),
		Color3.new(1, 1, 1),
		1,
		true
	)
	boundary.CanQuery = false
	boundary:SetAttribute("ReservedPurpose", "M6A1TestBoundaryOnly")

	local continuationLength = depth.VisualContinuationLength
	local continuationCenterZ = depth.CurrentPlayableBackZ - continuationLength * 0.5
	local floor = makePart(
		folder,
		"FutureContinuationFloor",
		Vector3.new(config.RunwayWidth, 0.20, continuationLength),
		CFrame.new(0, -0.40, continuationCenterZ),
		Color3.fromRGB(40, 43, 49),
		0.18,
		false
	)
	floor.Material = Enum.Material.Concrete

	local wallY = config.WallHeight * 0.5
	for _, x in { -config.RunwayWidth * 0.5, config.RunwayWidth * 0.5 } do
		local wall = makePart(
			folder,
			if x < 0 then "FutureWestWall" else "FutureEastWall",
			Vector3.new(1.5, config.WallHeight, continuationLength),
			CFrame.new(x, wallY, continuationCenterZ),
			Color3.fromRGB(55, 58, 65),
			0.32,
			false
		)
		wall.Material = Enum.Material.Metal
	end

	-- Primitive depth frames are intentionally graybox-only. They break the
	-- direct sightline and suggest repeating warehouse infrastructure without
	-- pretending this is the final environment-art solution.
	local frameOffsets = { 34, 78, 128, 188, 252 }
	for index, offset in frameOffsets do
		local z = depth.CurrentPlayableBackZ - offset
		local fade = math.clamp(0.12 + index * 0.08, 0.12, 0.58)
		for _, x in { -70, 70 } do
			local column = makePart(
				folder,
				("DepthColumn_%02d_%s"):format(index, if x < 0 then "L" else "R"),
				Vector3.new(5, 24, 5),
				CFrame.new(x, 12, z),
				Color3.fromRGB(66, 69, 75),
				fade,
				false
			)
			column.Material = Enum.Material.Metal
		end
		local beam = makePart(
			folder,
			("DepthBeam_%02d"):format(index),
			Vector3.new(145, 4, 5),
			CFrame.new(0, 24, z),
			Color3.fromRGB(66, 69, 75),
			fade,
			false
		)
		beam.Material = Enum.Material.Metal
	end

	root:SetAttribute("M6A1_FinalWarehouseLengthLocked", false)
	root:SetAttribute("M6A1_CurrentPlayableBackZ", depth.CurrentPlayableBackZ)
	root:SetAttribute("M6A1_VisualContinuationLength", continuationLength)
	root:SetAttribute("M6A1_VisualContinuationBackZ", depth.CurrentPlayableBackZ - continuationLength)
	root:SetAttribute("M6A1_EndlessWarehouseIntent", true)
end

return Service
