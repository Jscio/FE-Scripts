-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Game Objects
local LocalPlayer = Players.LocalPlayer

-- Variables
local oldGravity = workspace.Gravity
local swimLoop

-- Utility Functions
local function getRootPart(character: Model)
	return character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(character: Model)
	return character:FindFirstChildWhichIsA("Humanoid")
end

local function toggleAllStates(humanoid: Humanoid, bool)
	local enums = Enum.HumanoidStateType:GetEnumItems()
	table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
	table.remove(enums, table.find(enums, Enum.HumanoidStateType.Dead))

	for _, v in pairs(enums) do
		humanoid:SetStateEnabled(v, bool)
	end
end

-- Module
local Swim = {
	Enabled = false,
}

function Swim:Start()
	if self.Enabled or not LocalPlayer or not LocalPlayer.Character or not getHumanoid(LocalPlayer.Character) then
		return
	end

	oldGravity = workspace.Gravity
	workspace.Gravity = 0

	local humanoid = getHumanoid(LocalPlayer.Character)

	toggleAllStates(humanoid, false)
	humanoid:ChangeState(Enum.HumanoidStateType.Swimming)

	swimLoop = RunService.Heartbeat:Connect(function()
		if not LocalPlayer.Character or not getHumanoid(LocalPlayer.Character) then
			workspace.Gravity = oldGravity
			self.Enabled = false

			if swimLoop then
				swimLoop:Disconnect()
			end

			return
		end

		pcall(function()
			LocalPlayer.Character.HumanoidRootPart.Velocity = (
				(humanoid.MoveDirection ~= Vector3.new()) and getRootPart(LocalPlayer.Character).Velocity
				or Vector3.new()
			)
		end)
	end)

	self.Enabled = true
end

function Swim:Stop()
	if not LocalPlayer or not LocalPlayer.Character or not getHumanoid(LocalPlayer.Character) then
		return
	end

	workspace.Gravity = oldGravity
	self.Enabled = false

	if swimLoop then
		swimLoop:Disconnect()
	end

	toggleAllStates(getHumanoid(LocalPlayer.Character), true)
end

return Swim
