--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))

local RemoteService = {}

local folder: Folder? = nil

local function ensureRemote(name: string): RemoteEvent
	assert(folder, "RemoteService.Initialize must run first")

	local existing = folder:FindFirstChild(name)
	if existing then
		assert(existing:IsA("RemoteEvent"), ("Remote %s has the wrong class"):format(name))
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = folder
	return remote
end

function RemoteService.Initialize()
	local existing = ReplicatedStorage:FindFirstChild(RemoteNames.Folder)
	if existing then
		assert(existing:IsA("Folder"), "OneTripRemotes exists but is not a Folder")
		folder = existing
	else
		local created = Instance.new("Folder")
		created.Name = RemoteNames.Folder
		created.Parent = ReplicatedStorage
		folder = created
	end

	ensureRemote(RemoteNames.RequestGrab)
	ensureRemote(RemoteNames.RequestDrop)
	ensureRemote(RemoteNames.CarryState)
	ensureRemote(RemoteNames.PrototypeNotice)
end

function RemoteService.Get(name: string): RemoteEvent
	return ensureRemote(name)
end

return RemoteService
