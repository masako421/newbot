--==============================
-- Rayfield（UIは最初に作る）
--==============================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "R15 Visual Assist",
	LoadingTitle = "Loading UI",
	LoadingSubtitle = "Stable Build",
	ConfigurationSaving = {Enabled = false}
})

local MainTab = Window:CreateTab("Main")

--==============================
-- Services
--==============================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--==============================
-- States
--==============================
local HITBOX_ON   = false
local SKELETON_ON = false
local AIM_LOCK    = false
local VISUAL_TP   = false

--==============================
-- Settings
--==============================
local HITBOX_SIZE = Vector3.new(9,9,9) -- ★ デカくした
local AIM_SMOOTH = 0.15
local VISUAL_DISTANCE = 6
local COLOR = Color3.fromRGB(255,0,0)
local SKELETON_THICKNESS = 2.5

--==============================
-- UI
--==============================
MainTab:CreateToggle({
	Name = "Head Hitbox (R15)",
	Callback = function(v) HITBOX_ON = v end
})

MainTab:CreateToggle({
	Name = "Skeleton ESP (R15)",
	Callback = function(v) SKELETON_ON = v end
})

MainTab:CreateToggle({
	Name = "Aim Assist",
	Callback = function(v) AIM_LOCK = v end
})

MainTab:CreateToggle({
	Name = "Visual TP",
	Callback = function(v) VISUAL_TP = v end
})

--==============================
-- Storage
--==============================
local HeadBackup = {}
local Skeletons = {}
local VisualClone = nil

--==============================
-- Hitbox（R15安定版）
--==============================
local function applyHitbox(char)
	local head = char:FindFirstChild("Head")
	if not head then return end

	if not HeadBackup[head] then
		HeadBackup[head] = {
			Size = head.Size,
			Transparency = head.Transparency
		}
	end

	-- 強制適用（毎回）
	head.Size = HITBOX_SIZE
	head.Transparency = 0.25
	head.CanCollide = false
end

local function restoreHitbox(char)
	local head = char:FindFirstChild("Head")
	local data = head and HeadBackup[head]
	if head and data then
		head.Size = data.Size
		head.Transparency = data.Transparency
		HeadBackup[head] = nil
	end
end

--==============================
-- Skeleton
--==============================
local function newLine()
	local l = Drawing.new("Line")
	l.Color = COLOR
	l.Thickness = SKELETON_THICKNESS
	l.Visible = false
	return l
end

local function createSkeleton(plr)
	if not plr.Character then return end
	local t = {}
	for _,m in ipairs(plr.Character:GetDescendants()) do
		if m:IsA("Motor6D") and m.Part0 and m.Part1 then
			t[m] = newLine()
		end
	end
	Skeletons[plr] = t
end

local function removeSkeleton(plr)
	if Skeletons[plr] then
		for _,l in pairs(Skeletons[plr]) do
			l:Remove()
		end
	end
	Skeletons[plr] = nil
end

--==============================
-- Target
--==============================
local function getTarget()
	local closest,dist=nil,math.huge
	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
			local d = (Camera.CFrame.Position - p.Character.Head.Position).Magnitude
			if d < dist then
				dist = d
				closest = p
			end
		end
	end
	return closest
end

--==============================
-- Visual TP（Clone安定版）
--==============================
local function updateVisualTP(char)
	if not VISUAL_TP or not char then
		if VisualClone then
			VisualClone:Destroy()
			VisualClone = nil
		end
		return
	end

	if not VisualClone then
		VisualClone = char:Clone()
		for _,v in ipairs(VisualClone:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = true
				v.CanCollide = false
			end
		end
		VisualClone.PrimaryPart = VisualClone:FindFirstChild("HumanoidRootPart") or VisualClone:FindFirstChild("Head")
		VisualClone.Parent = workspace
	end

	if VisualClone.PrimaryPart then
		local cf = Camera.CFrame * CFrame.new(0,0,-VISUAL_DISTANCE)
		VisualClone:SetPrimaryPartCFrame(cf)
	end
end

--==============================
-- 状態管理（0.3秒）
--==============================
task.spawn(function()
	while true do
		task.wait(0.3)

		for _,p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				if HITBOX_ON then
					applyHitbox(p.Character)
				else
					restoreHitbox(p.Character)
				end

				if SKELETON_ON then
					if not Skeletons[p] then
						createSkeleton(p)
					end
				else
					removeSkeleton(p)
				end
			end
		end
	end
end)

--==============================
-- 描画 & Aim
--==============================
RunService.RenderStepped:Connect(function()
	local target = getTarget()
	if not target or not target.Character then return end

	-- Skeleton
	if SKELETON_ON and Skeletons[target] then
		for m,l in pairs(Skeletons[target]) do
			local p1,on1 = Camera:WorldToViewportPoint(m.Part0.Position)
			local p2,on2 = Camera:WorldToViewportPoint(m.Part1.Position)
			if on1 and on2 then
				l.From = Vector2.new(p1.X,p1.Y)
				l.To   = Vector2.new(p2.X,p2.Y)
				l.Visible = true
			else
				l.Visible = false
			end
		end
	end

	-- Visual TP
	updateVisualTP(target.Character)

	-- Aim Assist
	if AIM_LOCK then
		local head = target.Character:FindFirstChild("Head")
		if head then
			local cf = CFrame.new(Camera.CFrame.Position, head.Position)
			Camera.CFrame = Camera.CFrame:Lerp(cf, AIM_SMOOTH)
		end
	end
end)

--==============================
-- Cleanup
--==============================
Players.PlayerRemoving:Connect(removeSkeleton)
