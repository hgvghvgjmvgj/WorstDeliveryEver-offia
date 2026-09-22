--!strict

local Players = game:GetService("Players")

local Controller = {}

local player = Players.LocalPlayer
local highlight: Highlight? = nil

local function ensureHighlight(): Highlight
	if highlight and highlight.Parent then
		return highlight
	end

	local created = Instance.new("Highlight")
	created.Name = "OneTripLocalBayHighlight"
	created.FillTransparency = 0.94
	created.OutlineTransparency = 0.14
	created.DepthMode = Enum.HighlightDepthMode.Occluded
	created.Enabled = false
	created.Parent = workspace
	highlight = created
	return created
end

local function refresh()
	local current = ensureHighlight()
	local bayIndex = player:GetAttribute("BayIndex")
	local world = workspace:FindFirstChild("OneTripPrototype")
	local bays = world and world:FindFirstChild("Bays")

	if typeof(bayIndex) ~= "number" or not bays then
		current.Adornee = nil
		current.Enabled = false
		return
	end

	local bay = bays:FindFirstChild(("Bay%02d"):format(bayIndex))
	if bay and bay:IsA("Model") then
		current.Adornee = bay
		current.Enabled = true
	else
		current.Adornee = nil
		current.Enabled = false
	end
end

function Controller.Start()
	player:GetAttributeChangedSignal("BayIndex"):Connect(refresh)

	task.spawn(function()
		local world = workspace:WaitForChild("OneTripPrototype", 10)
		if world then
			world:WaitForChild("Bays", 10)
		end
		refresh()
	end)
end

return Controller
