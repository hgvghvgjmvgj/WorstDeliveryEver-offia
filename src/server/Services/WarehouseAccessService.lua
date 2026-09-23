--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WarehouseConfig = require(
	ReplicatedStorage:WaitForChild("Config"):WaitForChild("WarehouseConfig")
)

local WarehouseAccessService = {}

function WarehouseAccessService.Start(root: Folder)
	local existing = root:FindFirstChild("CurrentPlayableBoundary")
	if existing then
		existing:Destroy()
	end

	local wall = Instance.new("Part")
	wall.Name = "CurrentPlayableBoundary"
	wall.Size = Vector3.new(WarehouseConfig.Section.Width, 18, 4)
	wall.CFrame = CFrame.new(0, 9, -318)
	wall.Anchored = true
	wall.CanCollide = true
	wall.CanTouch = false
	wall.CanQuery = true
	wall.Material = Enum.Material.Metal
	wall.Color = Color3.fromRGB(67, 65, 64)
	wall.Transparency = 0.08
	wall:SetAttribute("M5APhaseBoundary", true)
	wall:SetAttribute("ReservedPurpose", "FutureWarehouseExpansion")
	wall.Parent = root
end

return WarehouseAccessService