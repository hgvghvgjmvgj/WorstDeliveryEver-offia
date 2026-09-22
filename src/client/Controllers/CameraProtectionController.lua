--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Controller = {}

local player = Players.LocalPlayer

function Controller.Start()
	RunService.RenderStepped:Connect(function()
		local camera = workspace.CurrentCamera
		local character = player.Character
		local carryFolder = character and character:FindFirstChild("OneTripCarry")

		if not camera or not carryFolder then
			return
		end

		for _, descendant in carryFolder:GetDescendants() do
			if descendant:IsA("BasePart") and descendant.Name ~= "CarryRoot" then
				local distance = (camera.CFrame.Position - descendant.Position).Magnitude
				descendant.LocalTransparencyModifier = if distance < 3.5 then 0.62 else 0
			end
		end
	end)
end

return Controller
