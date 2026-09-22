--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local Controller = {}

local pulseToken = 0

local function pulseFov(delta: number, outwardSeconds: number, returnSeconds: number)
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	pulseToken += 1
	local token = pulseToken
	local baseFov = camera.FieldOfView

	local outward = TweenService:Create(
		camera,
		TweenInfo.new(outwardSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ FieldOfView = baseFov + delta }
	)
	outward:Play()

	outward.Completed:Once(function()
		if token ~= pulseToken or not camera.Parent then
			return
		end

		local back = TweenService:Create(
			camera,
			TweenInfo.new(returnSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ FieldOfView = baseFov }
		)
		back:Play()
	end)
end

function Controller.Start()
	local remoteFolder = ReplicatedStorage:WaitForChild(RemoteNames.Folder)
	local feedback = remoteFolder:WaitForChild(RemoteNames.PrototypeFeedback) :: RemoteEvent

	feedback.OnClientEvent:Connect(function(kind: string, data)
		if kind == "Grab" then
			local weight = if typeof(data) == "table" then tonumber(data.weight) or 1 else 1
			pulseFov(math.clamp(0.8 + weight * 0.32, 1.0, 3.0), 0.055, 0.11)
		elseif kind == "Warning" then
			pulseFov(2.4, 0.07, 0.16)
		elseif kind == "Recovered" then
			pulseFov(1.2, 0.06, 0.15)
		elseif kind == "Collapse" then
			pulseFov(4.5, 0.07, 0.22)
		elseif kind == "Unload" then
			local count = if typeof(data) == "table" then tonumber(data.itemCount) or 1 else 1
			pulseFov(math.clamp(2.5 + count * 0.18, 3.0, 6.0), 0.08, 0.24)
		end
	end)
end

return Controller
