-- dai1228
local Configuration = {
	HitboxSize = 10,
	HitChance = 50,
	HitboxTransparency = 0.5,
	AttackDistance = 10,
	TeamCheck = true,
	WallCheck = true
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Target = nil
local BotEnabled = false

if _G.BotConnections then
	for _, connection in pairs(_G.BotConnections) do
		pcall(function() connection:Disconnect() end)
	end
end
_G.BotConnections = {}

_G.HitboxSize = Vector3.new(Configuration.HitboxSize, Configuration.HitboxSize, Configuration.HitboxSize)
_G.HitboxTransparency = Configuration.HitboxTransparency
_G.HitboxMaterial = Enum.Material.ForceField

local function isTeammate(player)
	if not Configuration.TeamCheck then return false end
	return player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team
end

local function isAlive(player)
	return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

local function isVisible(targetChar)
	if not Configuration.WallCheck then return true end
	if not LocalPlayer.Character then return false end

	local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")

	if not myRoot or not targetRoot then return false end

	local origin = myRoot.Position
	local direction = targetRoot.Position - origin
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetChar}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = Workspace:Raycast(origin, direction, raycastParams)
	return result == nil
end

local function getClosestTarget()
	local closestDist = math.huge
	local closestTarget = nil
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not myRoot then return nil end

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and isAlive(player) and not isTeammate(player) then
			local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				local dist = (myRoot.Position - targetRoot.Position).Magnitude
				if dist < closestDist then
					if isVisible(player.Character) then
						closestDist = dist
						closestTarget = player.Character
					end
				end
			end
		end
	end

	return closestTarget
end

local function resetHitbox(player)
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local rootPart = player.Character.HumanoidRootPart
		if rootPart.Size.X > 3 or rootPart.Transparency ~= 1 then
			rootPart.Size = Vector3.new(2, 2, 1)
			rootPart.Transparency = 1
			rootPart.CanCollide = true
			rootPart.Material = Enum.Material.Plastic
			rootPart.Color = Color3.new(0.64, 0.635, 0.647)

			local glow = rootPart:FindFirstChild("GlowEffect")
			if glow then glow:Destroy() end
		end
	end
end

local function updateHitboxes()
	local currentSize = _G.HitboxSize

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local rootPart = player.Character.HumanoidRootPart

			if isAlive(player) and not isTeammate(player) then
				rootPart.Size = currentSize
				rootPart.Transparency = Configuration.HitboxTransparency
				rootPart.Material = _G.HitboxMaterial
				rootPart.CanCollide = false
				rootPart.Color = Color3.fromRGB(255, 0, 0)

				local glow = rootPart:FindFirstChild("GlowEffect")
				if not glow then
					glow = Instance.new("SelectionBox", rootPart)
					glow.Name = "GlowEffect"
					glow.Adornee = rootPart
					glow.LineThickness = 0.05
					glow.Transparency = 1
					glow.Color3 = Color3.fromRGB(255, 0, 0)
				end
			else
				resetHitbox(player)
			end
		end
	end
end

local function changeColorSmoothly()
	local hue = tick() % 5 / 5
	local color = Color3.fromHSV(hue, 1, 1)

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and isAlive(player) and not isTeammate(player) then
			local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				local glow = rootPart:FindFirstChild("GlowEffect")
				rootPart.Color = color
				if glow then glow.Color3 = color end
			end
		end
	end
end

local function attackTarget()
	if Target and Target:FindFirstChild("Humanoid") and Target.Humanoid.Health > 0 then
		local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local targetRoot = Target:FindFirstChild("HumanoidRootPart")

		if myRoot and targetRoot then
			local distance = (myRoot.Position - targetRoot.Position).Magnitude
			if distance <= Configuration.AttackDistance then
				local chanceRoll = math.random(1, 100)
				if chanceRoll <= Configuration.HitChance then
					for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
						if tool:IsA("Tool") then
							tool:Activate()
						end
					end
				end
			end
		end
	end
end

local function followTarget()
	if Target and Target:FindFirstChild("HumanoidRootPart") then
		local myHumanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
		if myHumanoid then
			myHumanoid:MoveTo(Target.HumanoidRootPart.Position)
		end
	end
end

local function spinCharacter()
	local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(90), 0)
	end
end

local function toggleBot()
	BotEnabled = not BotEnabled
	if BotEnabled then
		print("Bot Enabled")
	else
		print("Bot Disabled")
	end
end

local function makeUnstoppable()
	local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
		humanoid.Sit = false
		local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			rootPart.Anchored = false
		end
	end
end

local function onRenderStep()
	if BotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		makeUnstoppable()
		Target = getClosestTarget()

		if Target then
			followTarget()
			spinCharacter()
			attackTarget()
		end
	end
end

table.insert(_G.BotConnections, RunService.Stepped:Connect(updateHitboxes))
table.insert(_G.BotConnections, RunService.RenderStepped:Connect(changeColorSmoothly))
table.insert(_G.BotConnections, RunService.RenderStepped:Connect(onRenderStep))

table.insert(_G.BotConnections, Mouse.KeyDown:Connect(function(key)
	if key == "y" then
		toggleBot()
	end
end))

pcall(function()
	if not ReplicatedStorage:FindFirstChild("DamageEvent") then
		local damageEvent = Instance.new("BindableEvent")
		damageEvent.Name = "DamageEvent"
		damageEvent.Parent = ReplicatedStorage

		local function onDamageEvent(player, character)
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:TakeDamage(10)
			end
		end
		damageEvent.Event:Connect(onDamageEvent)
	end
end)
