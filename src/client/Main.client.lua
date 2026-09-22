--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteNames = require(ReplicatedStorage:WaitForChild("Net"):WaitForChild("RemoteNames"))
local remoteFolder = ReplicatedStorage:WaitForChild(RemoteNames.Folder)

-- M0 intentionally has no gameplay input yet. Waiting for the remote folder here
-- proves the client/server project wiring is healthy before CarryService begins.
remoteFolder:WaitForChild(RemoteNames.RequestGrab)
remoteFolder:WaitForChild(RemoteNames.RequestDrop)
remoteFolder:WaitForChild(RemoteNames.CarryState)

print("[ONE TRIP] client foundation loaded")
