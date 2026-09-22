local Workspace = game:GetService("Workspace")

local JobPlotService = {}

local plots = {}
local plotByPlayer = {}

local function getPlotFolder()
	local world = Workspace:WaitForChild("GetItInPrototype")
	return world:WaitForChild("JobPlots")
end

function JobPlotService.Initialize()
	table.clear(plots)
	table.clear(plotByPlayer)

	for _, plot in getPlotFolder():GetChildren() do
		if plot:IsA("Model") and plot:GetAttribute("PlotIndex") then
			table.insert(plots, plot)
			plot:SetAttribute("OccupiedUserId", 0)
		end
	end

	table.sort(plots, function(a, b)
		return (a:GetAttribute("PlotIndex") or 0) < (b:GetAttribute("PlotIndex") or 0)
	end)
end

function JobPlotService.Claim(player)
	if plotByPlayer[player] then
		return plotByPlayer[player]
	end

	for _, plot in plots do
		if (plot:GetAttribute("OccupiedUserId") or 0) == 0 then
			plot:SetAttribute("OccupiedUserId", player.UserId)
			plotByPlayer[player] = plot
			return plot
		end
	end

	return nil
end

function JobPlotService.Release(player)
	local plot = plotByPlayer[player]
	if not plot then
		return
	end

	plot:SetAttribute("OccupiedUserId", 0)

	local roundObject = plot:FindFirstChild("RoundObject")
	if roundObject then
		roundObject:ClearAllChildren()
	end

	local challenge = plot:FindFirstChild("ChallengeGeometry")
	if challenge then
		challenge:ClearAllChildren()
	end

	local markers = plot:FindFirstChild("RoundMarkers")
	if markers then
		markers:ClearAllChildren()
	end

	plotByPlayer[player] = nil
end

function JobPlotService.GetForPlayer(player)
	return plotByPlayer[player]
end

function JobPlotService.GetOrigin(plot)
	return plot and plot:FindFirstChild("Origin")
end

function JobPlotService.GetPlayerSpawn(plot)
	return plot and plot:FindFirstChild("PlayerSpawn")
end

function JobPlotService.GetAvailableCount()
	local count = 0
	for _, plot in plots do
		if (plot:GetAttribute("OccupiedUserId") or 0) == 0 then
			count += 1
		end
	end
	return count
end

return JobPlotService
