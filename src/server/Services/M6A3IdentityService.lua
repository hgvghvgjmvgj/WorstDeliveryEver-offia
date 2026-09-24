--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SectionConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("SectionConfig"))

local Service = {}

local HEIGHTS = { 18, 20, 22, 25, 21, 27, 20, 23, 26, 29, 23, 25, 28, 22, 31 }
local AISLE_EDGE = { 60, 55, 52, 66, 50, 63, 54, 58, 61, 48, 67, 56, 64, 51, 59 }
local FLOOR_WIDTH = { 150, 142, 146, 164, 138, 158, 148, 152, 160, 140, 166, 145, 162, 136, 156 }
local MATERIALS = {
	Enum.Material.Concrete, Enum.Material.WoodPlanks, Enum.Material.Metal, Enum.Material.WoodPlanks,
	Enum.Material.SmoothPlastic, Enum.Material.Concrete, Enum.Material.Metal, Enum.Material.Concrete,
	Enum.Material.Metal, Enum.Material.DiamondPlate, Enum.Material.Marble, Enum.Material.SmoothPlastic,
	Enum.Material.Marble, Enum.Material.Metal, Enum.Material.DiamondPlate,
}

local function part(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material, transparency: number): Part
	local value = Instance.new("Part")
	value.Name = name
	value.Size = size
	value.CFrame = cframe
	value.Anchored = true
	value.CanCollide = false
	value.CanTouch = false
	value.CanQuery = false
	value.Color = color
	value.Material = material
	value.Transparency = transparency
	value.TopSurface = Enum.SurfaceType.Smooth
	value.BottomSurface = Enum.SurfaceType.Smooth
	value:SetAttribute("M6A3GrayboxIdentity", true)
	value.Parent = parent
	return value
end

function Service.Apply(world: Folder)
	local gameplay = world:FindFirstChild("WarehouseGameplay")
	local sectionsFolder = gameplay and gameplay:FindFirstChild("Sections")
	if not sectionsFolder then return end

	for _, sectionId in SectionConfig.Order do
		local section = sectionsFolder:FindFirstChild(sectionId)
		local meta = SectionConfig.Sections[sectionId]
		if section and section:IsA("Model") and meta then
			local old = section:FindFirstChild("M6A3Identity")
			if old then old:Destroy() end
			local folder = Instance.new("Folder")
			folder.Name = "M6A3Identity"
			folder.Parent = section

			local front = tonumber(section:GetAttribute("FrontZ")) or 0
			local back = tonumber(section:GetAttribute("BackZ")) or front - meta.Length
			local center = (front + back) * 0.5
			local height = HEIGHTS[meta.Index] or 22
			local aisle = AISLE_EDGE[meta.Index] or 56
			local floorWidth = FLOOR_WIDTH[meta.Index] or 150
			local material = MATERIALS[meta.Index] or Enum.Material.Concrete
			local tone = meta.Color:Lerp(Color3.fromRGB(120,125,132), 0.35)

			-- Floor treatment changes section rhythm without pretending to be final art.
			part(folder, "FloorTreatment", Vector3.new(floorWidth,0.035,math.max(8,meta.Length-5)), CFrame.new(0,0.17,center), tone, material, 0.76)

			-- Different aisle spacing/openness reads immediately when crossing a boundary.
			for _, x in {-aisle, aisle} do
				part(folder, if x < 0 then "LeftAisleEdge" else "RightAisleEdge", Vector3.new(0.45,0.12,math.max(8,meta.Length-10)), CFrame.new(x,0.23,center), tone, Enum.Material.Neon, 0.48)
			end

			-- Repeating overhead frames vary dramatically in height and frequency. These
			-- are graybox navigation cues only; M6B owns final ceilings/architecture.
			local samples = if meta.Length >= 105 then {0.20,0.50,0.80} elseif meta.Index % 2 == 0 then {0.32,0.68} else {0.50}
			for frameIndex, t in samples do
				local z = front - meta.Length * t
				for _, x in {-78,78} do
					part(folder, ("FramePost_%02d_%d"):format(frameIndex,x), Vector3.new(2.2,height,2.2), CFrame.new(x,height*0.5,z), tone, Enum.Material.Metal, 0.28)
				end
				part(folder, ("CeilingBeam_%02d"):format(frameIndex), Vector3.new(158,1.7,2.2), CFrame.new(0,height,z), tone, Enum.Material.Metal, 0.24)
			end

			section:SetAttribute("M6A3CeilingHeight", height)
			section:SetAttribute("M6A3AisleEdge", aisle)
			section:SetAttribute("M6A3FloorMaterial", material.Name)
		end
	end

	world:SetAttribute("M6A3GrayboxIdentityPass", true)
end

return Service
