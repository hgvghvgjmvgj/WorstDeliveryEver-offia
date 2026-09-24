--!strict

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Controller = {}

local tracked: {[Instance]: BasePart} = {}
local accumulator = 0
local ENABLE_DISTANCE = 135
local DISABLE_DISTANCE = 155

local function findRoot(instance: Instance): BasePart?
	local cursor: Instance? = instance
	while cursor and cursor ~= Workspace do
		if cursor:IsA("BasePart") then
			local itemId = cursor:GetAttribute("ItemId")
			if typeof(itemId) == "string" and itemId ~= "" then
				return cursor
			end
		end
		cursor = cursor.Parent
	end
	return nil
end

local function isProfessionalEffect(instance: Instance): boolean
	if instance:GetAttribute("M6CProfessionalEffect") == true then return true end
	return instance.Name == "M6CProfessionalLight"
end

local function register(instance: Instance)
	if not (instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("PointLight")) then return end
	if not isProfessionalEffect(instance) then return end
	local root = findRoot(instance)
	if root then tracked[instance] = root end
end

local function setEnabled(instance: Instance, enabled: boolean)
	if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("PointLight") then
		instance.Enabled = enabled
	end
end

local function update()
	local camera = Workspace.CurrentCamera
	if not camera then return end
	local cameraPosition = camera.CFrame.Position

	for effect, root in tracked do
		if not effect.Parent or not root.Parent then
			tracked[effect] = nil
			continue
		end
		local distance = (root.Position - cameraPosition).Magnitude
		local enabled = if effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("PointLight") then effect.Enabled else true
		if enabled and distance > DISABLE_DISTANCE then
			setEnabled(effect,false)
		elseif not enabled and distance < ENABLE_DISTANCE then
			setEnabled(effect,true)
		end
	end
end

function Controller.Start()
	for _, descendant in Workspace:GetDescendants() do register(descendant) end
	Workspace.DescendantAdded:Connect(function(instance)
		task.defer(register,instance)
	end)
	Workspace.DescendantRemoving:Connect(function(instance)
		tracked[instance] = nil
	end)
	RunService.RenderStepped:Connect(function(dt)
		accumulator += dt
		if accumulator < 0.25 then return end
		accumulator = 0
		update()
	end)
end

return Controller
