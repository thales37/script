local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")

-- GUI
local Window = Rayfield:CreateWindow({
   Name = "PvP System",
   LoadingTitle = "Carregando...",
   LoadingSubtitle = "by Você",
   ConfigurationSaving = {Enabled = false}
})

local Tab = Window:CreateTab("Combat", 4483362458)

-- Estados
local aimbot = false
local aimlock = false
local esp = false
local godmode = false
local noclip = false

local strength = 0.5
local fov = 150
local maxDistance = 100

local lockedTarget = nil
local lastMousePos = Vector2.new(mouse.X, mouse.Y)

-- TOGGLES
Tab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Callback = function(v) aimbot = v end,
})

Tab:CreateToggle({
   Name = "AimLock",
   CurrentValue = false,
   Callback = function(v)
      aimlock = v
      if not v then lockedTarget = nil end
   end,
})

Tab:CreateToggle({
   Name = "ESP",
   CurrentValue = false,
   Callback = function(v) esp = v end,
})

Tab:CreateToggle({
   Name = "Vida Infinita",
   CurrentValue = false,
   Callback = function(v) godmode = v end,
})

Tab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Callback = function(v) noclip = v end,
})

-- SLIDERS
Tab:CreateSlider({
   Name = "Força da Mira",
   Range = {0.1, 1},
   Increment = 0.1,
   CurrentValue = 0.5,
   Callback = function(v) strength = v end,
})

Tab:CreateSlider({
   Name = "FOV",
   Range = {50, 300},
   Increment = 10,
   CurrentValue = 150,
   Callback = function(v) fov = v end,
})

Tab:CreateSlider({
   Name = "Distância Máxima",
   Range = {20, 300},
   Increment = 10,
   CurrentValue = 100,
   Callback = function(v) maxDistance = v end,
})

-- PEGAR ALVO
local function getClosestTarget()
	local closest = nil
	local shortest = fov

	for _, p in pairs(game.Players:GetPlayers()) do
		if p ~= player 
		and p.Character 
		and p.Character:FindFirstChild("Head") 
		and p.Character:FindFirstChild("Humanoid") 
		and p.Character.Humanoid.Health > 0 then

			local distance = (p.Character.Head.Position - camera.CFrame.Position).Magnitude
			
			if distance <= maxDistance then
				local pos, visible = camera:WorldToViewportPoint(p.Character.Head.Position)

				if visible then
					local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
					
					if dist < shortest then
						shortest = dist
						closest = p.Character.Head
					end
				end
			end
		end
	end
	
	return closest
end

-- ESP
local function updateESP()
	for _, p in pairs(game.Players:GetPlayers()) do
		if p ~= player and p.Character then
			local existing = p.Character:FindFirstChild("ESP_HIGHLIGHT")

			if esp then
				if not existing then
					local h = Instance.new("Highlight")
					h.Name = "ESP_HIGHLIGHT"
					h.FillColor = Color3.fromRGB(255, 0, 0)
					h.OutlineColor = Color3.fromRGB(255,255,255)
					h.Parent = p.Character
				end
			else
				if existing then
					existing:Destroy()
				end
			end
		end
	end
end

-- VIDA INFINITA REAL
local function applyGodmode()
	if godmode and player.Character and player.Character:FindFirstChild("Humanoid") then
		local hum = player.Character.Humanoid
		hum.Health = hum.MaxHealth
	end
end

-- NOCLIP
runService.Stepped:Connect(function()
	if noclip and player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- LOOP PRINCIPAL
runService.RenderStepped:Connect(function()

	-- GODMODE
	applyGodmode()

	-- detectar movimento do mouse (soltar lock)
	local currentMouse = Vector2.new(mouse.X, mouse.Y)
	local moved = (currentMouse - lastMousePos).Magnitude > 5
	lastMousePos = currentMouse

	if moved then
		lockedTarget = nil -- 🔥 solta alvo ao mexer a mira
	end

	local target = getClosestTarget()

	-- AIMBOT
	if aimbot and target then
		local current = camera.CFrame
		local goal = CFrame.new(current.Position, target.Position)

		camera.CFrame = current:Lerp(goal, strength)
	end

	-- AIMLOCK INTELIGENTE
	if aimlock then
		if not lockedTarget then
			lockedTarget = target
		end
		
		if lockedTarget and lockedTarget.Parent and lockedTarget.Parent:FindFirstChild("Humanoid") then
			if lockedTarget.Parent.Humanoid.Health > 0 then
				local current = camera.CFrame
				local goal = CFrame.new(current.Position, lockedTarget.Position)

				camera.CFrame = current:Lerp(goal, strength)
			else
				lockedTarget = nil
			end
		else
			lockedTarget = nil
		end
	end

	updateESP()
end)
