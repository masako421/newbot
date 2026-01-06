--==============================
-- Rayfield
--==============================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--==============================
-- Window
--==============================
local Window = Rayfield:CreateWindow({
	Name = "Test Assist UI",
	LoadingTitle = "Loading",
	LoadingSubtitle = "UI Only",
	ConfigurationSaving = {Enabled = false}
})

--==============================
-- Tab
--==============================
local MainTab = Window:CreateTab("Main")

--==============================
-- States
--==============================
local VisualTP = false
local HeadExpand = false
local ESPEnabled = false
local AimBot = false
local ShowFOV = true
local FOVSize = 80

--==============================
-- UI
--==============================
MainTab:CreateToggle({
	Name = "視覚TP",
	Callback = function(v) VisualTP = v end
})

MainTab:CreateToggle({
	Name = "ヘッド判定拡大",
	Callback = function(v) HeadExpand = v end
})

MainTab:CreateToggle({
	Name = "ESP（敵表示）",
	Callback = function(v) ESPEnabled = v end
})

MainTab:CreateToggle({
	Name = "エイムボット",
	Callback = function(v) AimBot = v end
})

MainTab:CreateToggle({
	Name = "FOV表示",
	CurrentValue = true,
	Callback = function(v) ShowFOV = v end
})

MainTab:CreateSlider({
	Name = "FOVサイズ",
	Range = {20,120},
	Increment = 1,
	CurrentValue = FOVSize,
	Callback = function(v) FOVSize = v end
})

--==============================
-- Drawing UI
--==============================
local FOV = Drawing.new("Circle")
FOV.Filled = false
FOV.Thickness = 2
FOV.Color = Color3.fromRGB(170, 0, 255)

local CrosshairH = Drawing.new("Line")
local CrosshairV = Drawing.new("Line")

for _,v in pairs({CrosshairH, CrosshairV}) do
	v.Thickness = 2
	v.Color = Color3.new(1,1,1)
end

--==============================
-- Status Text
--==============================
local Status = Drawing.new("Text")
Status.Size = 18
Status.Color = Color3.fromRGB(255, 200, 0)
Status.Outline = true
Status.Position = Vector2.new(20, 200)

--==============================
-- Render
--==============================
RunService.RenderStepped:Connect(function()
	local center = Vector2.new(
		Camera.ViewportSize.X/2,
		Camera.ViewportSize.Y/2
	)

	-- FOV
	FOV.Visible = ShowFOV
	FOV.Position = center
	FOV.Radius = FOVSize

	-- Crosshair
	CrosshairH.From = center - Vector2.new(6,0)
	CrosshairH.To   = center + Vector2.new(6,0)
	CrosshairV.From = center - Vector2.new(0,6)
	CrosshairV.To   = center + Vector2.new(0,6)

	CrosshairH.Visible = true
	CrosshairV.Visible = true

	-- Status
	Status.Text =
		"【機能一覧】\n" ..
		"視覚TP : " .. (VisualTP and "ON" or "OFF") .. "\n" ..
		"ヘッド判定拡大 : " .. (HeadExpand and "ON" or "OFF") .. "\n" ..
		"ESP（敵表示） : " .. (ESPEnabled and "ON" or "OFF") .. "\n" ..
		"エイムボット : " .. (AimBot and "ON" or "OFF")

	Status.Visible = true
end)

--==============================
-- UI Toggle Key
--==============================
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.Q then
		Rayfield:Toggle()
	end
end)
