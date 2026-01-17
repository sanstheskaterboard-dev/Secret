-- Key System GUI (Mobile + PC)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- CONFIG
local CORRECT_KEY = "NAGI1002"
local DISCORD_INVITE = "https://discord.gg/MQAut7egGp"
local SCRIPT_URL = "https://raw.githubusercontent.com/sanstheskaterboard-dev/Secret/refs/heads/main/Protected.lua"

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeySystemGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromScale(0.38, 0.32)
MainFrame.Position = UDim2.fromScale(0.31, 0.34)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true -- REQUIRED for mobile drag
MainFrame.Parent = ScreenGui

-- Corner
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromScale(1, 0.18)
Title.BackgroundTransparency = 1
Title.Text = "Key System"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = MainFrame

-- TextBox
local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.fromScale(0.9, 0.18)
KeyBox.Position = UDim2.fromScale(0.05, 0.25)
KeyBox.PlaceholderText = "Enter Key..."
KeyBox.Text = ""
KeyBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
KeyBox.TextColor3 = Color3.new(1, 1, 1)
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextScaled = true
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = MainFrame
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 8)

-- Redeem Button
local RedeemButton = Instance.new("TextButton")
RedeemButton.Size = UDim2.fromScale(0.42, 0.18)
RedeemButton.Position = UDim2.fromScale(0.05, 0.52)
RedeemButton.Text = "Redeem"
RedeemButton.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
RedeemButton.TextColor3 = Color3.new(1, 1, 1)
RedeemButton.Font = Enum.Font.GothamBold
RedeemButton.TextScaled = true
RedeemButton.Parent = MainFrame
Instance.new("UICorner", RedeemButton).CornerRadius = UDim.new(0, 8)

-- Get Key Button
local GetKeyButton = Instance.new("TextButton")
GetKeyButton.Size = UDim2.fromScale(0.42, 0.18)
GetKeyButton.Position = UDim2.fromScale(0.53, 0.52)
GetKeyButton.Text = "Get Key"
GetKeyButton.BackgroundColor3 = Color3.fromRGB(60, 200, 120)
GetKeyButton.TextColor3 = Color3.new(1, 1, 1)
GetKeyButton.Font = Enum.Font.GothamBold
GetKeyButton.TextScaled = true
GetKeyButton.Parent = MainFrame
Instance.new("UICorner", GetKeyButton).CornerRadius = UDim.new(0, 8)

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.fromScale(1, 0.14)
Status.Position = UDim2.fromScale(0, 0.8)
Status.BackgroundTransparency = 1
Status.Text = ""
Status.TextColor3 = Color3.fromRGB(255, 80, 80)
Status.Font = Enum.Font.Gotham
Status.TextScaled = true
Status.Parent = MainFrame

-- Redeem Logic
RedeemButton.MouseButton1Click:Connect(function()
	if KeyBox.Text == CORRECT_KEY then
		Status.TextColor3 = Color3.fromRGB(80, 255, 120)
		Status.Text = "Key Accepted"

		task.wait(0.4)

		-- Execute script
		loadstring(game:HttpGet(SCRIPT_URL))()

		-- Destroy GUI after success
		ScreenGui:Destroy()
	else
		Status.TextColor3 = Color3.fromRGB(255, 80, 80)
		Status.Text = "Invalid Key"
	end
end)

-- Get Key (Clipboard)
GetKeyButton.MouseButton1Click:Connect(function()
	if setclipboard then
		setclipboard(DISCORD_INVITE)
		Status.TextColor3 = Color3.fromRGB(80, 255, 120)
		Status.Text = "Link Copied"
	else
		Status.TextColor3 = Color3.fromRGB(255, 200, 80)
		Status.Text = "Clipboard Unsupported"
	end
end)

-- 🔥 DRAG SYSTEM (PC + MOBILE)
local dragging = false
local dragStart
local startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
		updateDrag(input)
	end
end)
