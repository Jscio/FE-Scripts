-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

-- Constants
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

-- Main
if #Players:GetPlayers() <= 1 then
	Players.LocalPlayer:Kick("\nRejoining...")
	task.wait()
	TeleportService:Teleport(PlaceId, LocalPlayer)
else
	TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
end
