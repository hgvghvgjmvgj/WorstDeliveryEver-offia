--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BatchConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("M6CProductionBatchConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))

local Service = {}
local watched: {[BasePart]: RBXScriptConnection} = {}

local function itemId(root: BasePart): string?
	local value = root:GetAttribute("ItemId")
	if typeof(value) == "string" and value ~= "" then return value end
	return string.match(root.Name,"^Carry_(.+)_%d+$")
end

local function isBatch(root: BasePart): boolean
	local id = itemId(root)
	if not id then return false end
	local def = ItemConfig[id]
	if not def then return false end
	return BatchConfig.Recipes[tostring(def.BaseItemId or id)] ~= nil
end

local function cleanup(root: BasePart)
	if isBatch(root) then return end
	local vfx = root:FindFirstChild("M6CProfessionalVFX")
	if vfx then vfx:Destroy() end
	root:SetAttribute("M6CProfessionalVFXItemId",nil)
	for _, child in root:GetChildren() do
		if child:GetAttribute("M6CProductionTemporary") == true then child:Destroy() end
	end
end

local function watch(root: BasePart)
	if watched[root] then return end
	watched[root] = root:GetAttributeChangedSignal("ItemId"):Connect(function()
		task.defer(function() if root.Parent then cleanup(root) end end)
	end)
end

function Service.Start(world: Folder)
	for _, descendant in world:GetDescendants() do
		if descendant:IsA("BasePart") then watch(descendant) end
	end
	world.DescendantAdded:Connect(function(instance)
		if instance:IsA("BasePart") then watch(instance) end
	end)
end

return Service
