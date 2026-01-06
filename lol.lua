-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ===== 機能状態 =====
local VISUAL_TP = true
local ESP = true
local AIMBOT = true

-- ===== Rayfield =====
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Combat UI",
	LoadingTitle = "Loading",
	LoadingSubtitle = "Local Only",
	ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("機能一覧", 4483362458)
Tab:CreateSection("戦闘補助")

-- 視覚TP
Tab:CreateToggle({
	Name = "視覚TP",
	CurrentValue = true,
	Callback = function(v)
		VISUAL_TP = v
	end
})

-- ESP
Tab:CreateToggle({
	Name = "ESP（敵表示）",
	CurrentValue = true,
	Callback = function(v)
		ESP = v
	end
})

-- エイムボット
Tab:CreateToggle({
	Name = "エイムボット",
	CurrentValue = true,
	Callback = function(v)
		AIMBOT = v
	end
})

-- ===== ESP =====
local ESP_CACHE = {}

local function isEnemy(plr)
	return plr ~= LP
		and plr.Character
		and plr.Character:FindFirstChild("HumanoidRootPart")
end

local function createESP(plr)
	local box = Drawing.new("Square")
	box.Color = Color3.fromRGB(0,255,0)
	box.Thickness = 2
	box.Filled = false
	ESP_CACHE[plr] = box
end

-- ===== 共通 =====
local function getClosestEnemy()
	local closest, dist = nil, math.huge
	for _,plr in pairs(Players:GetPlayers()) do
		if isEnemy(plr) and plr.Character:FindFirstChild("Head") then
			local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
			if onScreen then
				local m = (Vector2.new(pos.X,pos.Y) - Vector2.new(Mouse.X,Mouse.Y)).Magnitude
				if m < dist then
					dist = m
					closest = plr
				end
			end
		end
	end
	return closest
end

-- ===== メイン処理 =====
RunService.RenderStepped:Connect(function()
	-- ESP
	for _,plr in pairs(Players:GetPlayers()) do
		if isEnemy(plr) then
			if not ESP_CACHE[plr] then
				createESP(plr)
			end
			local hrp = plr.Character.HumanoidRootPart
			local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			local box = ESP_CACHE[plr]

			if ESP and onScreen then
				box.Visible = true
				box.Size = Vector2.new(40, 60)
				box.Position = Vector2.new(pos.X - 20, pos.Y - 30)
			else
				box.Visible = false
			end
		end
	end

	local target = getClosestEnemy()
	if not target or not target.Character then return end

	-- エイムボット
	if AIMBOT and target.Character:FindFirstChild("Head") then
		Camera.CFrame = CFrame.new(
			Camera.CFrame.Position,
			target.Character.Head.Position
		)
	end

	-- 視覚TP（見た目のみ）
	if VISUAL_TP and target.Character:FindFirstChild("HumanoidRootPart") then
		local front = Camera.CFrame.Position + Camera.CFrame.LookVector * 6
		target.Character.HumanoidRootPart.CFrame = CFrame.new(front)
	end
end)
