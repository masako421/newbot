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
-- Window / Tab
--==============================
local Window = Rayfield:CreateWindow({
	Name = "R6 Hitbox + Skeleton",
	LoadingTitle = "Loading",
	LoadingSubtitle = "Rayfield UI",
	ConfigurationSaving = {Enabled = false}
})

local MainTab = Window:CreateTab("Main")

--==============================
-- Settings
--==============================
local HITBOX_ON = false
local SKELETON_ON = false

local HITBOX_SIZE = Vector3.new(8,8,8) -- Head拡大サイズ
local SKELETON_THICKNESS = 2.5
local COLOR = Color3.fromRGB(255,0,0)

--==============================
-- UI
--==============================
MainTab:CreateToggle({
	Name = "Head Hitbox Expand (R6)",
	CurrentValue = false,
	Callback = function(v)
		HITBOX_ON = v
	end
})

MainTab:CreateToggle({
	Name = "Skeleton ESP (R6)",
	CurrentValue = false,
	Callback = function(v)
		SKELETON_ON = v
	end
})

--==============================
-- Storage
--==============================
local HeadBackup = {}
local Skeletons = {}

--==============================
-- Drawing helpers
--==============================
local function NewLine()
	local l = Drawing.new("Line")
	l.Color = COLOR
	l.Thickness = SKELETON_THICKNESS
	l.Visible = false
	return l
end

--==============================
-- Skeleton (R6)
--==============================
local function createSkeleton(plr)
	Skeletons[plr] = {
		HT = NewLine(),
		LA = NewLine(),
		RA = NewLine(),
		LL = NewLine(),
		RL = NewLine()
	}
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
-- Hitbox
--==============================
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
-- Main Loop
--==============================
RunService.RenderStepped:Connect(function()
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local char = plr.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			if not char or not hum or hum.Health <= 0 then
				removeSkeleton(plr)
				continue
			end

			-- R6 Parts
			local head = char:FindFirstChild("Head")
			local torso = char:FindFirstChild("Torso")
			local la = char:FindFirstChild("Left Arm")
			local ra = char:FindFirstChild("Right Arm")
			local ll = char:FindFirstChild("Left Leg")
			local rl = char:FindFirstChild("Right Leg")

			if not (head and torso and la and ra and ll and rl) then
				removeSkeleton(plr)
				continue
			end

			-- Hitbox
			if HITBOX_ON then
				applyHitbox(char)
			else
				restoreHitbox(char)
			end

			-- Skeleton
			if SKELETON_ON then
				if not Skeletons[plr] then
					createSkeleton(plr)
				end

				local function w2s(p)
					local v,on = Camera:WorldToViewportPoint(p)
					return Vector2.new(v.X,v.Y), on
				end

				local s = Skeletons[plr]

				local function link(line, a, b)
					local p1,on1 = w2s(a.Position)
					local p2,on2 = w2s(b.Position)
					if on1 and on2 then
						line.From = p1
						line.To = p2
						line.Visible = true
					else
						line.Visible = false
					end
				end

				link(s.HT, head, torso)
				link(s.LA, torso, la)
				link(s.RA, torso, ra)
				link(s.LL, torso, ll)
				link(s.RL, torso, rl)
			else
				removeSkeleton(plr)
			end
		end
	end
end)

--==============================
-- Cleanup
--==============================
Players.PlayerRemoving:Connect(function(plr)
	removeSkeleton(plr)
end)
