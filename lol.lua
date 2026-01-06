-- ===============================
-- Rayfield（最初に読み込み）
-- ===============================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ===============================
-- Services
-- ===============================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ===============================
-- 状態（UIでON/OFF）
-- ===============================
local VISUAL_TP = true
local ESP_ENABLED = true
local AIMBOT_ENABLED = true

-- 視覚TP距離
local VISUAL_DISTANCE = 6

-- ===============================
-- Rayfield UI
-- ===============================
local Window = Rayfield:CreateWindow({
	Name = "Combat Assist",
	LoadingTitle = "Loading...",
	LoadingSubtitle = "Local Only",
	ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("機能一覧", 4483362458)
Tab:CreateSection("戦闘補助")

Tab:CreateToggle({
	Name = "視覚TP",
	CurrentValue = true,
	Callback = function(v)
		VISUAL_TP = v
	end
})

Tab:CreateToggle({
	Name = "ESP（敵表示）",
	CurrentValue = true,
	Callback = function(v)
		ESP_ENABLED = v
	end
})

Tab:CreateToggle({
	Name = "エイムボット",
	CurrentValue = true,
	Callback = function(v)
		AIMBOT_ENABLED = v
	end
})

Tab:CreateSlider({
	Name = "視覚TP 距離",
	Range = {3, 10},
	Increment = 1,
	Suffix = "studs",
	CurrentValue = VISUAL_DISTANCE,
	Callback = function(v)
		VISUAL_DISTANCE = v
	end
})

-- ===============================
-- ESP（Drawing）
-- ===============================
local ESP_CACHE = {}

local function isEnemy(plr)
	return plr ~= LP
		and plr.Character
		and plr.Character:FindFirstChild("HumanoidRootPart")
end

local function createESP(plr)
	local box = Drawing.new("Square")
	box.Color = Color3.fromRGB(180, 0, 255) -- 紫系
	box.Thickness = 2
	box.Filled = false
	box.Visible = false
	ESP_CACHE[plr] = box
end

-- ===============================
-- ターゲット取得
-- ===============================
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

-- ===============================
-- メインループ
-- ===============================
RunService.RenderStepped:Connect(function()
	-- ESP更新
	for _,plr in pairs(Players:GetPlayers()) do
		if isEnemy(plr) then
			if not ESP_CACHE[plr] then
				createESP(plr)
			end

			local hrp = plr.Character.HumanoidRootPart
			local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			local box = ESP_CACHE[plr]

			if ESP_ENABLED and onScreen then
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

	-- エイムボット（カメラ向け）
	if AIMBOT_ENABLED and target.Character:FindFirstChild("Head") then
		Camera.CFrame = CFrame.new(
			Camera.CFrame.Position,
			target.Character.Head.Position
		)
	end

	-- 視覚TP（見た目のみ）
	if VISUAL_TP and target.Character:FindFirstChild("HumanoidRootPart") then
		local front = Camera.CFrame.Position + Camera.CFrame.LookVector * VISUAL_DISTANCE
		target.Character.HumanoidRootPart.CFrame = CFrame.new(front)
	end
end)
