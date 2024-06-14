-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Game Objects
local LocalPlayer = Players.LocalPlayer

-- Module
local Noclip = {
	Enabled = false,
	Connection = nil,
}

function Noclip:Start()
	self:Stop()

	self.Enabled = true
	self.Connection = RunService.Stepped:Connect(function()
		if self.Enabled and LocalPlayer.Character then
			for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
				if v:IsA("BasePart") and v.CanCollide then
					v.CanCollide = false
				end
			end
		end
	end)
end

function Noclip:Stop()
	self.Enabled = false

	if self.Connection then
		self.Connection:Disconnect()
	end
end

return Noclip
