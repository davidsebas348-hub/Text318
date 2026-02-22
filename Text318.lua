local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- 🔥 Variable global editable
_G.FAKE_JUMP_POWER = _G.FAKE_JUMP_POWER or 70
local MAX_DISTANCE = 10

-- ======================
-- TOGGLE SOLO GUI
-- ======================

if _G.BombJumpGUI then
	_G.BombJumpGUI:Destroy()
	_G.BombJumpGUI = nil
	return
end

-- ======================
-- GUI
-- ======================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BombJumpGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

_G.BombJumpGUI = ScreenGui

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0,170,0,55)
Button.Position = UDim2.new(0.5,-85,0.8,0)
Button.BackgroundColor3 = Color3.fromRGB(255,80,80)
Button.TextColor3 = Color3.new(1,1,1)
Button.TextScaled = true
Button.Text = "BOMB BOOST"
Button.Parent = ScreenGui

-- ======================
-- DRAG
-- ======================

local dragging = false
local dragInput, dragStart, startPos

Button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseButton1 then
		
		dragging = true
		dragInput = input
		dragStart = input.Position
		startPos = Button.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		local delta = input.Position - dragStart
		
		Button.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input == dragInput then
		dragging = false
	end
end)

-- ======================
-- FUNCIONES
-- ======================

local waitingForHandle = false

local function simulateJump()
	local character = LocalPlayer.Character
	if not character then return end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp then return end
	
	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	hrp.Velocity = Vector3.new(hrp.Velocity.X, _G.FAKE_JUMP_POWER, hrp.Velocity.Z)
end

local function equipAndDropBomb()
	local character = LocalPlayer.Character
	if not character then return end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp then return end
	
	local tool = character:FindFirstChild("FakeBomb")
		or LocalPlayer.Backpack:FindFirstChild("FakeBomb")
	if not tool then return end
	
	humanoid:EquipTool(tool)
	task.wait(0.1)
	
	local remote = tool:FindFirstChild("Remote")
	if not remote then return end
	
	waitingForHandle = true
	remote:FireServer(CFrame.new(hrp.Position - Vector3.new(0,2,0)), 50)
end

Workspace.ChildAdded:Connect(function(obj)
	if waitingForHandle and obj.Name == "Handle" and obj:IsA("Part") then
		
		local character = LocalPlayer.Character
		if not character then return end
		
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		
		task.wait(0.1)
		
		if (obj.Position - hrp.Position).Magnitude <= MAX_DISTANCE then
			obj.CFrame = hrp.CFrame * CFrame.new(0,-2,0)
			waitingForHandle = false
			
			task.wait(0.1)
			simulateJump()
		end
	end
end)

Button.MouseButton1Click:Connect(function()
	simulateJump()
	task.wait(0.15)
	equipAndDropBomb()
end)
