-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Game Objects
local LocalPlayer = Players.LocalPlayer

-- Variables
local flyKeyDown, flyKeyUp

-- Utility Functions
local function getRootPart(character: Model)
	return character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(character: Model)
	return character:FindFirstChildWhichIsA("Humanoid")
end

local function createBodyControl(rootPart: Part)
	local gyro = Instance.new("BodyGyro")
	local velocity = Instance.new("BodyVelocity")

	gyro.P = 9e4 -- 9 x 10^4
	gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9) -- 9 x 10^9
	gyro.CFrame = rootPart.CFrame

	velocity.Velocity = Vector3.new(0, 0, 0)
	velocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

	gyro.Parent = rootPart
	velocity.Parent = rootPart

	return gyro, velocity
end

local function disconnectKeyConnections()
	if flyKeyDown or flyKeyUp then
		flyKeyDown:Disconnect()
		flyKeyUp:Disconnect()
	end
end

local function toggleAnimations(humanoid: Humanoid, bool)
	humanoid.PlatformStand = not bool
end

-- Module
local Fly = {
	Enabled = false,
	Speed = 1,
}

function Fly:Start()
	-- Ensure player character exists
	repeat
		task.wait()
	until LocalPlayer
		and LocalPlayer.Character
		and getRootPart(LocalPlayer.Character)
		and getHumanoid(LocalPlayer.Character)
	repeat
		task.wait()
	until UserInputService

	disconnectKeyConnections()

	local rootPart = getRootPart(LocalPlayer.Character)

	local controls = { x = 0, y = 0, z = 0 }
	local lastControls = { x = 0, y = 0, z = 0 }
	local speed = 0

	local function internalFly()
		self.Enabled = true
		local bodyGyro, bodyVel = createBodyControl(rootPart)

		-- Loop to manage flying
		task.spawn(function()
			repeat
				task.wait()

				-- On Death
				if not LocalPlayer.Character or not getHumanoid(LocalPlayer.Character) then
					self.Enabled = false
					disconnectKeyConnections()
					break
				end

				-- Disable animations
				if getHumanoid(LocalPlayer.Character) then
					toggleAnimations(getHumanoid(LocalPlayer.Character), false)
				end

				-- Adjust speed based on controls
				if controls.x ~= 0 or controls.y ~= 0 or controls.z ~= 0 then
					speed = 50
				elseif not (controls.x ~= 0 or controls.y ~= 0 or controls.z ~= 0) and speed ~= 0 then
					speed = 0
				end

				-- Update velocity based on controls
				-- This affects the character
				if controls.x ~= 0 or controls.y ~= 0 or controls.z ~= 0 then
					bodyVel.Velocity = (
						(workspace.CurrentCamera.CFrame.LookVector * controls.z)
						+ (
							(workspace.CurrentCamera.CFrame * CFrame.new(controls.x, controls.y, 0).Position)
							- workspace.CurrentCamera.CFrame.Position
						)
					) * speed

					lastControls = { x = controls.x, y = controls.y, z = controls.z }
				elseif controls.x == 0 and controls.y == 0 and controls.z == 0 and speed ~= 0 then
					bodyVel.Velocity = (
						(workspace.CurrentCamera.CFrame.LookVector * lastControls.z)
						+ (
							(workspace.CurrentCamera.CFrame * CFrame.new(lastControls.x, lastControls.y, 0).Position)
							- workspace.CurrentCamera.CFrame.Position
						)
					) * speed
				else
					bodyVel.Velocity = Vector3.new(0, 0, 0)
				end

				bodyGyro.CFrame = workspace.CurrentCamera.CFrame
			until not self.Enabled

			controls = { x = 0, y = 0, z = 0 }
			lastControls = { x = 0, y = 0, z = 0 }
			speed = 0

			bodyGyro:Destroy()
			bodyVel:Destroy()

			-- Do not manually set isFlying to disable flying, use `stopFly()`
		end)
	end

	flyKeyDown = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if input.KeyCode == Enum.KeyCode.W then
			-- Forward
			controls.z = self.Speed
		elseif input.KeyCode == Enum.KeyCode.S then
			-- Backward
			controls.z = -self.Speed
		elseif input.KeyCode == Enum.KeyCode.D then
			-- Right
			controls.x = self.Speed
		elseif input.KeyCode == Enum.KeyCode.A then
			-- Left
			controls.x = -self.Speed
		elseif input.KeyCode == Enum.KeyCode.E then
			-- Up
			controls.y = self.Speed
		elseif input.KeyCode == Enum.KeyCode.Q then
			-- Down
			controls.y = -self.Speed
		end

		pcall(function()
			workspace.CurrentCamera.CameraType = Enum.CameraType.Track
		end)
	end)

	flyKeyUp = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if input.KeyCode == Enum.KeyCode.W then
			-- Forward
			controls.z = 0
		elseif input.KeyCode == Enum.KeyCode.S then
			-- Backward
			controls.z = 0
		elseif input.KeyCode == Enum.KeyCode.D then
			-- Right
			controls.x = 0
		elseif input.KeyCode == Enum.KeyCode.A then
			-- Left
			controls.x = 0
		elseif input.KeyCode == Enum.KeyCode.E then
			-- Up
			controls.y = 0
		elseif input.KeyCode == Enum.KeyCode.Q then
			-- Down
			controls.y = 0
		end
	end)

	internalFly()
end

function Fly:Stop()
	self.Enabled = false

	disconnectKeyConnections()

	-- Enable animations
	if getHumanoid(LocalPlayer.Character) then
		toggleAnimations(getHumanoid(LocalPlayer.Character), true)
	end

	-- Set the camera back to normal
	pcall(function()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end)
end

Fly:Start()

return Fly
