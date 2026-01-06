--==============================
-- Rayfield
--==============================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--==============================
-- Services
--==============================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--==============================
-- Window
--==============================
local Window = Rayfield:CreateWindow({
	Name = "R15 Visual Assist",
	LoadingTitle = "Loading",
	LoadingSubtitle = "Local Only",
	ConfigurationSaving = {Enabled = false}
})

local MainTab = Window:CreateTab("Main")

--==============================
-- States
--==============================
local HITBOX_ON = false
local SKELETON_ON = false
local VISUAL_TP = false
local AIM_LOCK = false

--==============================
-- Settings
--==============================
local HITBOX_SIZE = Vector3.new(6,6,6)
local SKELETON_THICKNESS = 2.5
local COLOR = Color3.fromRGB(255,0,0)
local AIM_SMOOTH = 0.15
local VISUAL_DISTANCE = 6

--==============================
-- UI
--==============================
MainTab:CreateToggle({
	Name = "R15 Head Hitbox",
	Callback = function(v) HITBOX_ON = v end
})

MainTab:CreateToggle({
	Name = "Skeleton ESP (R15)",
	Callback = function(v) SKELETON_ON = v end
})

MainTab:CreateToggle({
	Name = "Visual TP (Local)",
	Callback = function(v) VISUAL_TP = v end
})

MainTab:CreateToggle({
	Name = "Aim Lock (吸着)",
	Callback = function(v) AIM_LOCK = v end
})

--==============================
-- Hitbox
--==============================
local HeadBackup = {}

local function applyHitbox(char)
	local head = char:FindFirstChild("Head")
	if not head then return end
	if not HeadBackup[head] then
		HeadBackup[head] = head.Size
	end
	head.Size = HITBOX_SIZE
	head.Transparency = 0.2
	head.CanCollide = false
end

local function restoreHitbox(char)
	local head = char:FindFirstChild("Head")
	if head and HeadBackup[head] then
		head.Size = HeadBackup[head]
		HeadBackup[head] = nil
	end
end

--==============================
-- Skeleton (Motor6D)
--==============================
local Skeletons = {}

local function newLine()
	local l = Drawing.new("Line")
	l.Color = COLOR
	l.Thickness = SKELETON_THICKNESS
	l.Visible = false
	return l
end

local function createSkeleton(plr)
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
-- Visual TP (Clone)
--==============================
local VisualClone

local function updateVisualTP(targetChar)
	if not VISUAL_TP or not targetChar then
		if VisualClone then VisualClone:Destroy() VisualClone = nil end
		return
	end

	if not VisualClone then
		VisualClone = targetChar:Clone()
		for _,v in ipairs(VisualClone:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = true
				v.CanCollide = false
			end
		end
		VisualClone.Parent = workspace
	end

	local cf = Camera.CFrame * CFrame.new(0,0,-VISUAL_DISTANCE)
	VisualClone:SetPrimaryPartCFrame(cf)
end

--==============================
-- Target finder
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
-- Loop
--==============================
RunService.RenderStepped:Connect(function()
	local target = getTarget()
	if not target or not target.Character then return end

	-- Hitbox
	if HITBOX_ON then
		applyHitbox(target.Character)
	else
		restoreHitbox(target.Character)
	end

	-- Skeleton
	if SKELETON_ON then
		if not Skeletons[target] then
			createSkeleton(target)
		end
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
	else
		removeSkeleton(target)
	end

	-- Visual TP
	updateVisualTP(target.Character)

	-- Aim Lock
	if AIM_LOCK then
		local head = target.Character:FindFirstChild("Head")
		if head then
			local cf = CFrame.new(Camera.CFrame.Position, head.Position)
			Camera.CFrame = Camera.CFrame:Lerp(cf, AIM_SMOOTH)
		end
	end
end)
