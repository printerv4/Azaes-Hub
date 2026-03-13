local RunService = game:GetService("RunService")
local cloneref = (cloneref or clonereference or function(i) return i end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local WindUI
do
	local ok, res = pcall(function()
		return require("./src/Init")
	end)
	if ok then
		WindUI = res
	else
		if cloneref(game:GetService("RunService")):IsStudio() then
			WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
		else
			WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
		end
	end
end

local plr = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")
local tweens = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local brainrot = false
local cash = false
local afk = false
local antilag = false
local invis = false
local noclip = false
local spedon = false
local flying = false
local infjump = false
local antifall = false
local instprox = false
local autobat = false

local spd = 50
local flyspd = 20
local brdelay = 1.5
local cashdelay = 0.5
local batRange = 20

local brloop = nil
local cashloop = nil
local autobatloop = nil
local afkconn = nil
local promptconn = nil
local instproxconn = nil
local chair = nil
local flyConn = nil
local infJumpConn = nil
local antiFallPart = nil
local antiFallConn = nil
local noclipConn = nil
local flyBodyVel = nil
local flyBodyGyro = nil

local function getChar()
	return plr.Character or plr.CharacterAdded:Wait()
end

local function getHum()
	local c = plr.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
	local c = plr.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function setTrans(val)
	local c = plr.Character
	if not c then return end
	for _, v in pairs(c:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.Transparency = val
		end
	end
end

local Window = WindUI:CreateWindow({
	Title = "Azeas Hub",
	Folder = "AzeasHub",
	Icon = "solar:home-2-bold-duotone",
	NewElements = true,
	HideSearchBar = false,
	OpenButton = {
		Title = "Azeas Hub",
		CornerRadius = UDim.new(1, 0),
		StrokeThickness = 2,
		Enabled = true,
		Draggable = true,
		OnlyMobile = false,
		Scale = 0.5,
		Color = ColorSequence.new(
			Color3.fromHex("#7c3aed"),
			Color3.fromHex("#a855f7")
		),
	},
	Topbar = {
		Height = 44,
		ButtonsType = "Default",
	},
})

Window:Tag({
	Title = "A Hub",
	Icon = "star",
	Color = Color3.fromHex("#FFD700"),
	Border = true,
})

local HomeSection     = Window:Section({ Title = "Home" })
local PlayerSection   = Window:Section({ Title = "Player" })
local FarmSection     = Window:Section({ Title = "Farm" })
local AutoSection     = Window:Section({ Title = "Auto" })
local VisualSection   = Window:Section({ Title = "Visual" })
local SettingsSection = Window:Section({ Title = "Settings" })

local HomeTab = HomeSection:Tab({
	Title = "Home",
	Icon = "solar:home-2-bold",
	IconColor = Color3.fromHex("#7775F2"),
	IconShape = "Square",
	Border = true,
})

HomeTab:Section({
	Title = "Welcome to Azeas Hub",
	TextSize = 22,
	FontWeight = Enum.FontWeight.SemiBold,
})

HomeTab:Space()

HomeTab:Section({
	Title = "A feature-rich hub with farm, movement and visual tools.\nUse the tabs on the left to navigate.",
	TextSize = 16,
	TextTransparency = 0.4,
	FontWeight = Enum.FontWeight.Medium,
})

HomeTab:Space({ Columns = 3 })

HomeTab:Button({
	Title = "Teleport to End",
	Color = Color3.fromHex("#7775F2"),
	Icon = "map-pin",
	IconAlign = "Left",
	Justify = "Center",
	Callback = function()
		local root = getRoot()
		if root then
			root.CFrame = CFrame.new(84.44, -4.35, -15651.74)
		end
	end,
})

HomeTab:Space()

HomeTab:Button({
	Title = "Teleport to Base",
	Color = Color3.fromHex("#10C550"),
	Icon = "map-pin",
	IconAlign = "Left",
	Justify = "Center",
	Callback = function()
		local root = getRoot()
		if root then
			root.CFrame = CFrame.new(-19.15, -7.82, -23.04)
		end
	end,
})

local PlayerTab = PlayerSection:Tab({
	Title = "Player",
	Icon = "solar:cursor-square-bold",
	IconColor = Color3.fromHex("#257AF7"),
	IconShape = "Square",
	Border = true,
})

PlayerTab:Toggle({
	Title = "Speed Hack",
	Desc = "Boost your walk speed",
	Value = false,
	Callback = function(v)
		spedon = v
		if spedon then
			task.spawn(function()
				while spedon do
					local hum = getHum()
					if hum and hum.Parent then
						hum.WalkSpeed = spd
					end
					task.wait(0.3)
				end
				local hum = getHum()
				if hum and hum.Parent then
					hum.WalkSpeed = 16
				end
			end)
		end
	end,
})

PlayerTab:Slider({
	Title = "Speed Value",
	IsTooltip = true,
	Step = 1,
	Value = { Min = 1, Max = 999, Default = 50 },
	Callback = function(v)
		spd = v
		if spedon then
			local hum = getHum()
			if hum and hum.Parent then hum.WalkSpeed = v end
		end
	end,
})

PlayerTab:Space()

PlayerTab:Toggle({
	Title = "Noclip",
	Desc = "Walk through walls",
	Value = false,
	Callback = function(v)
		noclip = v
		if noclip then
			if noclipConn then noclipConn:Disconnect() end
			noclipConn = RS.Stepped:Connect(function()
				if not noclip then
					if noclipConn then noclipConn:Disconnect() noclipConn = nil end
					return
				end
				local char = plr.Character
				if char then
					for _, part in pairs(char:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end
			end)
		else
			if noclipConn then noclipConn:Disconnect() noclipConn = nil end
		end
	end,
})

PlayerTab:Space()

PlayerTab:Slider({
	Title = "Jump Power",
	IsTooltip = true,
	Step = 1,
	Value = { Min = 50, Max = 300, Default = 50 },
	Callback = function(v)
		local hum = getHum()
		if hum and hum.Parent then
			hum.JumpPower = v
		end
	end,
})

PlayerTab:Space()

PlayerTab:Toggle({
	Title = "Inf Jump",
	Desc = "Jump again while in the air",
	Value = false,
	Callback = function(v)
		infjump = v
		if infjump then
			if infJumpConn then infJumpConn:Disconnect() end
			infJumpConn = UIS.JumpRequest:Connect(function()
				if not infjump then return end
				local hum = getHum()
				if hum and hum.Parent then
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		else
			if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
		end
	end,
})

PlayerTab:Space()

PlayerTab:Toggle({
	Title = "Fly",
	Desc = "Fly with WASD + Space / Ctrl",
	Value = false,
	Callback = function(v)
		flying = v
		if flying then
			local root = getRoot()
			local hum = getHum()
			if not root or not hum then return end

			hum.PlatformStand = true

			if flyBodyVel then flyBodyVel:Destroy() end
			if flyBodyGyro then flyBodyGyro:Destroy() end

			flyBodyVel = Instance.new("BodyVelocity")
			flyBodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
			flyBodyVel.Velocity = Vector3.new(0, 0, 0)
			flyBodyVel.Parent = root

			flyBodyGyro = Instance.new("BodyGyro")
			flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
			flyBodyGyro.P = 1e4
			flyBodyGyro.Parent = root

			if flyConn then flyConn:Disconnect() end
			flyConn = RS.RenderStepped:Connect(function()
				if not flying then
					pcall(function() flyBodyVel:Destroy() end)
					pcall(function() flyBodyGyro:Destroy() end)
					flyBodyVel = nil
					flyBodyGyro = nil
					local h = getHum()
					if h and h.Parent then h.PlatformStand = false end
					flyConn:Disconnect()
					flyConn = nil
					return
				end
				local r = getRoot()
				if not r then return end
				local cam = workspace.CurrentCamera
				local move = Vector3.new(0, 0, 0)
				if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
				if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
				flyBodyVel.Velocity = move * flyspd
				flyBodyGyro.CFrame = cam.CFrame
			end)
		else
			flying = false
		end
	end,
})

PlayerTab:Slider({
	Title = "Fly Speed",
	IsTooltip = true,
	Step = 1,
	Value = { Min = 1, Max = 99, Default = 20 },
	Callback = function(v)
		flyspd = v
	end,
})

PlayerTab:Space()

PlayerTab:Toggle({
	Title = "Anti Fall",
	Desc = "Invisible platform keeps you from falling",
	Value = false,
	Callback = function(v)
		antifall = v
		if antifall then
			if antiFallPart then antiFallPart:Destroy() end
			antiFallPart = Instance.new("Part")
			antiFallPart.Size = Vector3.new(12, 0.5, 12)
			antiFallPart.Anchored = true
			antiFallPart.CanCollide = true
			antiFallPart.Transparency = 1
			antiFallPart.Name = "_AntiFall"
			antiFallPart.CFrame = CFrame.new(0, -9999, 0)
			antiFallPart.Parent = workspace
			if antiFallConn then antiFallConn:Disconnect() end
			antiFallConn = RS.Heartbeat:Connect(function()
				if not antifall then
					pcall(function() antiFallPart:Destroy() end)
					antiFallPart = nil
					antiFallConn:Disconnect()
					antiFallConn = nil
					return
				end
				local root = getRoot()
				local hum = getHum()
				if root and hum then
					if hum:GetState() == Enum.HumanoidStateType.Freefall then
						antiFallPart.CFrame = CFrame.new(root.Position.X, root.Position.Y - 3.2, root.Position.Z)
					else
						antiFallPart.CFrame = CFrame.new(0, -9999, 0)
					end
				end
			end)
		else
			if antiFallPart then antiFallPart:Destroy() antiFallPart = nil end
			if antiFallConn then antiFallConn:Disconnect() antiFallConn = nil end
		end
	end,
})

local FarmTab = FarmSection:Tab({
	Title = "Farm",
	Icon = "solar:check-square-bold",
	IconColor = Color3.fromHex("#10C550"),
	IconShape = "Square",
	Border = true,
})

FarmTab:Toggle({
	Title = "Auto Cash",
	Desc = "Automatically touches cash pods",
	Value = false,
	Callback = function(v)
		cash = v
		if cash then
			cashloop = task.spawn(function()
				while cash do
					local ok = pcall(function()
						local root = getRoot()
						if root then
							local plots = workspace:FindFirstChild("Plots")
							if plots then
								for _, plot in pairs(plots:GetChildren()) do
									local pods = plot:FindFirstChild("Pods")
									if pods then
										for _, pod in pairs(pods:GetChildren()) do
											local touch = pod:FindFirstChild("TouchPart")
											if touch and touch:FindFirstChild("TouchInterest") then
												firetouchinterest(root, touch, 0)
												task.wait(0.03 + math.random(0, 3) / 100)
												firetouchinterest(root, touch, 1)
											end
										end
									end
									task.wait(0.02)
								end
							end
						end
					end)
					if not ok then task.wait(1) end
					task.wait(cashdelay + math.random(0, 2) / 10)
				end
			end)
		else
			if cashloop then task.cancel(cashloop) cashloop = nil end
		end
	end,
})

FarmTab:Space()

FarmTab:Slider({
	Title = "Cash Delay",
	IsTooltip = true,
	Step = 0.1,
	Value = { Min = 0.1, Max = 2, Default = 0.5 },
	Callback = function(v)
		cashdelay = v
	end,
})

local AutoTab = AutoSection:Tab({
	Title = "Auto",
	Icon = "solar:square-transfer-horizontal-bold",
	IconColor = Color3.fromHex("#ECA201"),
	IconShape = "Square",
	Border = true,
})

AutoTab:Toggle({
	Title = "Auto Brainrots",
	Desc = "Automatically collects brainrots",
	Value = false,
	Callback = function(v)
		brainrot = v
		if brainrot then
			if promptconn then promptconn:Disconnect() end
			for _, child in pairs(workspace:GetDescendants()) do
				if child:IsA("ProximityPrompt") then
					child.HoldDuration = 0
				end
			end
			promptconn = workspace.DescendantAdded:Connect(function(d)
				if d:IsA("ProximityPrompt") then d.HoldDuration = 0 end
			end)
			brloop = task.spawn(function()
				while brainrot do
					local ok = pcall(function()
						local root = getRoot()
						if root then
							local folder = workspace:FindFirstChild("ActiveBrainrots")
							if folder then
								local target, maxDist = nil, -1
								for _, item in pairs(folder:GetChildren()) do
									if item.Name == "ServerHitbox" and item:IsA("BasePart") then
										local dist = (root.Position - item.Position).Magnitude
										if dist > maxDist then
											target = item
											maxDist = dist
										end
									end
								end
								if target then
									local goal = target.CFrame * CFrame.new(0, 0, 10)
									local t = tweens:Create(root, TweenInfo.new(0.3 + math.random(0, 10) / 100), { CFrame = goal })
									t:Play()
									t.Completed:Wait()
									task.wait(brdelay + math.random(0, 3) / 10)
									for i = 1, 20 do
										if not target or not target.Parent or not brainrot then break end
										vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
										task.wait(0.05 + math.random(0, 2) / 100)
										vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
										task.wait(0.05 + math.random(0, 2) / 100)
									end
									local ret = tweens:Create(root, TweenInfo.new(0.2 + math.random(0, 5) / 100), { CFrame = CFrame.new(123.66, -7.34, -23.73) })
									ret:Play()
									ret.Completed:Wait()
									task.wait(0.2 + math.random(0, 2) / 10)
								end
							end
						end
					end)
					if not ok then task.wait(1) end
					task.wait(0.5 + math.random(0, 3) / 10)
				end
			end)
		else
			if brloop then task.cancel(brloop) brloop = nil end
			if promptconn then promptconn:Disconnect() promptconn = nil end
		end
	end,
})

AutoTab:Space()

AutoTab:Slider({
	Title = "Brainrot Delay",
	IsTooltip = true,
	Step = 0.1,
	Value = { Min = 0.1, Max = 5, Default = 1.5 },
	Callback = function(v)
		brdelay = v
	end,
})

AutoTab:Space()

AutoTab:Toggle({
	Title = "Instant Proximity",
	Desc = "Sets all proximity prompts to instant",
	Value = false,
	Callback = function(v)
		instprox = v
		if instprox then
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj.ClassName == "ProximityPrompt" then
					obj.HoldDuration = 0.0001
				end
			end
			if instproxconn then instproxconn:Disconnect() end
			instproxconn = workspace.DescendantAdded:Connect(function(d)
				if not instprox then
					instproxconn:Disconnect()
					instproxconn = nil
					return
				end
				if d.ClassName == "ProximityPrompt" then
					d.HoldDuration = 0.0001
				end
			end)
		else
			if instproxconn then instproxconn:Disconnect() instproxconn = nil end
		end
	end,
})

AutoTab:Space()

AutoTab:Toggle({
	Title = "Auto Bat",
	Desc = "Equips Bat and attacks nearby players",
	Value = false,
	Callback = function(v)
		autobat = v
		if autobat then
			autobatloop = task.spawn(function()
				while autobat do
					pcall(function()
						local char = plr.Character
						local root = getRoot()
						if not char or not root then return end

						local bat = plr.Backpack:FindFirstChild("Bat") or char:FindFirstChild("Bat")
						if not bat then return end

						if char:FindFirstChild("Bat") == nil then
							plr.Character.Humanoid:EquipTool(bat)
							task.wait(0.3)
						end

						local closest = nil
						local closestDist = batRange

						for _, other in pairs(game.Players:GetPlayers()) do
							if other ~= plr and other.Character then
								local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")
								local otherHum = other.Character:FindFirstChildOfClass("Humanoid")
								if otherRoot and otherHum and otherHum.Health > 0 then
									local dist = (root.Position - otherRoot.Position).Magnitude
									if dist < closestDist then
										closestDist = dist
										closest = other
									end
								end
							end
						end

						if closest and closest.Character then
							local otherRoot = closest.Character:FindFirstChild("HumanoidRootPart")
							if otherRoot then
								root.CFrame = CFrame.new(root.Position, otherRoot.Position)
								local tool = char:FindFirstChild("Bat")
								if tool then
									local fa = tool:FindFirstChildOfClass("RemoteEvent") or tool:FindFirstChild("SwingEvent")
									if fa then
										fa:FireServer()
									else
										tool:Activate()
									end
								end
							end
						end
					end)
					task.wait(0.4 + math.random(0, 3) / 10)
				end
			end)
		else
			if autobatloop then task.cancel(autobatloop) autobatloop = nil end
		end
	end,
})

AutoTab:Slider({
	Title = "Bat Range",
	Desc = "How close a player needs to be",
	IsTooltip = true,
	Step = 1,
	Value = { Min = 5, Max = 100, Default = 20 },
	Callback = function(v)
		batRange = v
	end,
})

AutoTab:Space()

AutoTab:Toggle({
	Title = "Anti AFK",
	Desc = "Stops you getting kicked for idling",
	Value = false,
	Callback = function(v)
		afk = v
		if afk then
			if afkconn then afkconn:Disconnect() end
			afkconn = plr.Idled:Connect(function()
				local vu = game:GetService("VirtualUser")
				vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
				task.wait(1 + math.random(0, 5) / 10)
				vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			end)
		else
			if afkconn then afkconn:Disconnect() afkconn = nil end
		end
	end,
})

local VisTab = VisualSection:Tab({
	Title = "Visual",
	Icon = "solar:info-square-bold",
	IconColor = Color3.fromHex("#EF4F1D"),
	IconShape = "Square",
	Border = true,
})

VisTab:Toggle({
	Title = "Invisible",
	Desc = "Makes your character fully invisible",
	Value = false,
	Callback = function(v)
		invis = v
		if invis then
			setTrans(1)
			local root = getRoot()
			if root then
				local saved = root.CFrame
				local char = getChar()
				char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
				task.wait(0.15 + math.random(0, 5) / 100)
				if chair then chair:Destroy() end
				chair = Instance.new("Seat")
				chair.Anchored = false
				chair.CanCollide = false
				chair.Name = "_invischair"
				chair.Transparency = 1
				chair.Position = Vector3.new(-25.95, 84, 3537.55)
				chair.Parent = workspace
				local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
				if torso then
					local weld = Instance.new("Weld")
					weld.Part0 = chair
					weld.Part1 = torso
					weld.Parent = chair
				end
				chair.CFrame = saved
			end
		else
			setTrans(0)
			if chair then chair:Destroy() chair = nil end
		end
	end,
})

VisTab:Space()

VisTab:Toggle({
	Title = "Anti Lag",
	Desc = "Removes all textures, VFX and effects",
	Value = false,
	Callback = function(v)
		antilag = v
		if antilag then
			settings().Rendering.QualityLevel = 1
			local l = game:GetService("Lighting")
			l.GlobalShadows = false
			l.FogEnd = 1e9
			l.Brightness = 2
			for _, fx in pairs(l:GetChildren()) do
				pcall(function() fx.Enabled = false end)
			end
			for _, obj in pairs(workspace:GetDescendants()) do
				if obj:IsA("Decal") or obj:IsA("Texture") then
					pcall(function() obj.Transparency = 1 end)
				end
				if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
					pcall(function() obj.Enabled = false end)
				end
				if obj:IsA("SpecialMesh") then
					pcall(function() obj.TextureId = "" end)
				end
			end
		else
			settings().Rendering.QualityLevel = 5
			local l = game:GetService("Lighting")
			l.GlobalShadows = true
			for _, fx in pairs(l:GetChildren()) do
				pcall(function() fx.Enabled = true end)
			end
		end
	end,
})

local SettingsTab = SettingsSection:Tab({
	Title = "Settings",
	Icon = "solar:folder-with-files-bold",
	IconColor = Color3.fromHex("#83889E"),
	IconShape = "Square",
	Border = true,
})

SettingsTab:Keybind({
	Title = "Toggle UI",
	Desc = "Open or close the hub",
	Value = "Y",
	Callback = function(v)
		pcall(function()
			Window:SetToggleKey(Enum.KeyCode[v])
		end)
	end,
})

SettingsTab:Space()

SettingsTab:Button({
	Title = "Destroy Hub",
	Color = Color3.fromHex("#EF4F1D"),
	Icon = "shredder",
	IconAlign = "Left",
	Justify = "Center",
	Callback = function()
		pcall(function() if brloop then task.cancel(brloop) end end)
		pcall(function() if cashloop then task.cancel(cashloop) end end)
		pcall(function() if autobatloop then task.cancel(autobatloop) end end)
		pcall(function() if afkconn then afkconn:Disconnect() end end)
		pcall(function() if promptconn then promptconn:Disconnect() end end)
		pcall(function() if instproxconn then instproxconn:Disconnect() end end)
		pcall(function() if flyConn then flyConn:Disconnect() end end)
		pcall(function() if infJumpConn then infJumpConn:Disconnect() end end)
		pcall(function() if antiFallConn then antiFallConn:Disconnect() end end)
		pcall(function() if antiFallPart then antiFallPart:Destroy() end end)
		pcall(function() if noclipConn then noclipConn:Disconnect() end end)
		pcall(function() if flyBodyVel then flyBodyVel:Destroy() end end)
		pcall(function() if flyBodyGyro then flyBodyGyro:Destroy() end end)
		pcall(function() if chair then chair:Destroy() end end)
		local hum = getHum()
		if hum and hum.Parent then
			hum.WalkSpeed = 16
			hum.JumpPower = 50
			hum.PlatformStand = false
		end
		setTrans(0)
		Window:Destroy()
	end,
})
