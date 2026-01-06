-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ===== 機能トグル =====
local VISUAL_TP = true
local ESP = true
local AIMBOT = true

-- ===== UI作成 =====
local gui = Instance.new("ScreenGui")
gui.Parent = LP.PlayerGui
gui.ResetOnSpawn = false

-- 左上 緑ボックス
local tpLabel = Instance.new("TextLabel")
tpLabel.Parent = gui
tpLabel.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
tpLabel.BorderSizePixel = 0
tpLabel.Position = UDim2.new(0.02, 0, 0.12, 0)
tpLabel.Size = UDim2.new(0, 200, 0, 45)
tpLabel.Font = Enum.Font.SourceSansBold
tpLabel.TextSize = 20
tpLabel.TextColor3 = Color3.new(1,1,1)
tpLabel.Text = "視覚TP : ON"

-- 右側 機能一覧
local funcLabel = Instance.new("TextLabel")
funcLabel.Parent = gui
funcLabel.BackgroundTransparency = 1
funcLabel.Position = UDim2.new(0.65, 0, 0.28, 0)
funcLabel.Size = UDim2.new(0, 300, 0, 160)
funcLabel.Font = Enum.Font.SourceSansBold
funcLabel.TextSize = 20
funcLabel.TextXAlignment = Left
funcLabel.TextYAlignment = Top
funcLabel.TextColor3 = Color3.fromRGB(255, 200, 50)

local function updateFuncText()
	funcLabel.Text =
		"【機能一覧】\n" ..
		"・ヘッド当たり判定拡大\n" ..
		"・ESP（敵表示） : " .. (ESP and "ON" or "OFF") .. "\n" ..
		"・エイムボット : " .. (AIMBOT and "ON" or "OFF")
end
updateFuncText()

-- ===== キー操作 =====
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.Q then
		VISUAL_TP = not VISUAL_TP
		tpLabel.Text = "視覚TP : " .. (VISUAL_TP and "ON" or "OFF")
	end

	if input.KeyCode == Enum.KeyCode.E then
		ESP = not ESP
		updateFuncText()
	end

	if input.KeyCode == Enum.KeyCode.R then
		AIMBOT = not AIMBOT
		updateFuncText()
	end
end)

-- ===== 機能処理（簡易）=====
local function getEnemy()
	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character and plr.Character:FindFirstChild("Head") then
			return plr
		end
	end
end

RunService.RenderStepped:Connect(function()
	local enemy = getEnemy()
	if not enemy or not enemy.Character then return end

	-- エイムボット
	if AIMBOT then
		Camera.CFrame = CFrame.new(
			Camera.CFrame.Position,
			enemy.Character.Head.Position
		)
	end

	-- 視覚TP（見た目のみ）
	if VISUAL_TP and enemy.Character:FindFirstChild("HumanoidRootPart") then
		local pos = Camera.CFrame.Position + Camera.CFrame.LookVector * 6
		enemy.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
	end
end)
