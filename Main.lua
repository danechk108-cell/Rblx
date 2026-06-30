--// Luxury Hub v13
--// Main.lua

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

-- удалить старый GUI
pcall(function()
    Player.PlayerGui:FindFirstChild("LuxuryHub"):Destroy()
end)

-------------------------------------------------
-- GUI
-------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LuxuryHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player.PlayerGui

-------------------------------------------------
-- MAIN
-------------------------------------------------

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.fromOffset(760,470)
Main.Position = UDim2.new(.5,-380,.5,-235)
Main.BackgroundColor3 = Color3.fromRGB(15,15,18)
Main.BorderSizePixel = 0

Instance.new("UICorner",Main).CornerRadius = UDim.new(0,18)

local Stroke = Instance.new("UIStroke",Main)
Stroke.Color = Color3.fromRGB(50,50,58)
Stroke.Thickness = 1.2

-------------------------------------------------
-- SHADOW
-------------------------------------------------

local Shadow = Instance.new("ImageLabel")
Shadow.Parent = Main
Shadow.BackgroundTransparency = 1
Shadow.AnchorPoint = Vector2.new(.5,.5)
Shadow.Position = UDim2.fromScale(.5,.5)
Shadow.Size = UDim2.new(1,60,1,60)
Shadow.ZIndex = -1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageTransparency = .55
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10,10,118,118)

-------------------------------------------------
-- HEADER
-------------------------------------------------

local Header = Instance.new("Frame")
Header.Parent = Main
Header.Size = UDim2.new(1,0,0,58)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(24,12)
Title.Size = UDim2.fromOffset(300,30)
Title.Font = Enum.Font.GothamBold
Title.Text = "LUXURY HUB"
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(240,240,240)
Title.TextXAlignment = Enum.TextXAlignment.Left

local Sub = Instance.new("TextLabel")
Sub.Parent = Header
Sub.BackgroundTransparency = 1
Sub.Position = UDim2.fromOffset(25,34)
Sub.Size = UDim2.fromOffset(260,18)
Sub.Font = Enum.Font.Gotham
Sub.Text = "Premium Interface"
Sub.TextSize = 11
Sub.TextColor3 = Color3.fromRGB(140,140,150)
Sub.TextXAlignment = Enum.TextXAlignment.Left

-------------------------------------------------
-- SIDEBAR
-------------------------------------------------

local Sidebar = Instance.new("Frame")
Sidebar.Parent = Main
Sidebar.Position = UDim2.fromOffset(18,70)
Sidebar.Size = UDim2.fromOffset(72,382)
Sidebar.BackgroundColor3 = Color3.fromRGB(20,20,24)
Sidebar.BorderSizePixel = 0

Instance.new("UICorner",Sidebar).CornerRadius = UDim.new(0,18)

-------------------------------------------------
-- CONTENT
-------------------------------------------------

local Content = Instance.new("Frame")
Content.Parent = Main
Content.Position = UDim2.fromOffset(108,70)
Content.Size = UDim2.fromOffset(634,382)
Content.BackgroundColor3 = Color3.fromRGB(18,18,22)
Content.BorderSizePixel = 0

Instance.new("UICorner",Content).CornerRadius = UDim.new(0,18)

-------------------------------------------------
-- CLOSE
-------------------------------------------------

local Close = Instance.new("TextButton")
Close.Parent = Header
Close.AnchorPoint = Vector2.new(1,0)
Close.Position = UDim2.new(1,-18,0,14)
Close.Size = UDim2.fromOffset(34,34)
Close.Text = "✕"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 16
Close.TextColor3 = Color3.new(1,1,1)
Close.BackgroundColor3 = Color3.fromRGB(210,70,70)
Close.BorderSizePixel = 0

Instance.new("UICorner",Close).CornerRadius = UDim.new(1,0)

-------------------------------------------------
-- MINIMIZE
-------------------------------------------------

local Min = Instance.new("TextButton")
Min.Parent = Header
Min.AnchorPoint = Vector2.new(1,0)
Min.Position = UDim2.new(1,-60,0,14)
Min.Size = UDim2.fromOffset(34,34)
Min.Text = "—"
Min.Font = Enum.Font.GothamBold
Min.TextSize = 18
Min.TextColor3 = Color3.new(1,1,1)
Min.BackgroundColor3 = Color3.fromRGB(45,45,55)
Min.BorderSizePixel = 0

Instance.new("UICorner",Min).CornerRadius = UDim.new(1,0)

-------------------------------------------------
-- DRAG
-------------------------------------------------

local Dragging
local DragStart
local StartPos

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = true
		DragStart = input.Position
		StartPos = Main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				Dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local Delta = input.Position - DragStart

		Main.Position = UDim2.new(
			StartPos.X.Scale,
			StartPos.X.Offset + Delta.X,
			StartPos.Y.Scale,
			StartPos.Y.Offset + Delta.Y
		)
	end
end)

-------------------------------------------------
-- BUTTONS
-------------------------------------------------

Close.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

local Minimized = false

Min.MouseButton1Click:Connect(function()

	Minimized = not Minimized

	local Goal = {}

	if Minimized then
		Goal.Size = UDim2.fromOffset(760,58)
	else
		Goal.Size = UDim2.fromOffset(760,470)
	end

	TweenService:Create(
		Main,
		TweenInfo.new(.25,Enum.EasingStyle.Quart),
		Goal
	):Play()

	Sidebar.Visible = not Minimized
	Content.Visible = not Minimized

end)

print("Luxury Hub v13 loaded.")
