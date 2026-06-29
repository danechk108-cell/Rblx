local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0,650,0,420)
Main.Position = UDim2.new(.5,-325,.5,-210)
Main.BackgroundColor3 = Color3.fromRGB(18,18,24)
Main.BorderSizePixel = 0

Instance.new("UICorner",Main).CornerRadius = UDim.new(0,18)

local Stroke = Instance.new("UIStroke",Main)
Stroke.Color = Color3.fromRGB(80,110,255)
Stroke.Thickness = 1.5
Stroke.Transparency = .3

local Shadow = Instance.new("ImageLabel")
Shadow.Parent = Main
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10,10,118,118)
Shadow.Size = UDim2.new(1,40,1,40)
Shadow.Position = UDim2.new(0,-20,0,-20)
Shadow.ImageTransparency = .55
Shadow.ZIndex = 0

local Top = Instance.new("Frame")
Top.Parent = Main
Top.Size = UDim2.new(1,0,0,55)
Top.BackgroundTransparency = 1

local Title = Instance.new("TextLabel")
Title.Parent = Top
Title.Position = UDim2.new(0,20,0,0)
Title.Size = UDim2.new(0,250,1,0)
Title.Text = "SCRIPT HUB"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 23
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local Tabs = Instance.new("Frame")
Tabs.Parent = Main
Tabs.Position = UDim2.new(0,15,0,70)
Tabs.Size = UDim2.new(0,145,1,-85)
Tabs.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout",Tabs)
Layout.Padding = UDim.new(0,10)

local Content = Instance.new("Frame")
Content.Parent = Main
Content.Position = UDim2.new(0,170,0,70)
Content.Size = UDim2.new(1,-185,1,-85)
Content.BackgroundTransparency = 1

local Pages = {}

local function CreatePage(name)

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Parent = Content
    Scroll.Size = UDim2.new(1,0,1,0)
    Scroll.CanvasSize = UDim2.new()
    Scroll.ScrollBarThickness = 3
    Scroll.BackgroundTransparency = 1
    Scroll.Visible = false

    local UIList = Instance.new("UIListLayout",Scroll)
    UIList.Padding = UDim.new(0,12)

    UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y+20)
    end)

    Pages[name]=Scroll

    for i=1,9 do

        local Holder = Instance.new("Frame")
        Holder.Parent = Scroll
        Holder.Size = UDim2.new(1,-5,0,55)
        Holder.BackgroundColor3 = Color3.fromRGB(26,26,34)
        Holder.BorderSizePixel = 0

        Instance.new("UICorner",Holder).CornerRadius=UDim.new(0,12)

        local txt = Instance.new("TextLabel")
        txt.Parent = Holder
        txt.BackgroundTransparency = 1
        txt.Position = UDim2.new(0,15,0,0)
        txt.Size = UDim2.new(.7,0,1,0)
        txt.Text = "TEST-"..i
        txt.Font = Enum.Font.GothamMedium
        txt.TextSize = 18
        txt.TextColor3 = Color3.new(1,1,1)
        txt.TextXAlignment = Enum.TextXAlignment.Left

        local Toggle = Instance.new("Frame")
        Toggle.Parent = Holder
        Toggle.Size = UDim2.new(0,52,0,28)
        Toggle.Position = UDim2.new(1,-70,.5,-14)
        Toggle.BackgroundColor3 = Color3.fromRGB(45,45,55)
        Toggle.BorderSizePixel = 0

        Instance.new("UICorner",Toggle).CornerRadius=UDim.new(1,0)

        local Ball = Instance.new("Frame")
        Ball.Parent = Toggle
        Ball.Size = UDim2.new(0,22,0,22)
        Ball.Position = UDim2.new(0,3,.5,-11)
        Ball.BackgroundColor3 = Color3.new(1,1,1)
        Ball.BorderSizePixel = 0

        Instance.new("UICorner",Ball).CornerRadius=UDim.new(1,0)

        local Button = Instance.new("TextButton")
        Button.Parent = Toggle
        Button.Size = UDim2.new(1,0,1,0)
        Button.BackgroundTransparency = 1
        Button.Text = ""

        local Enabled = false

        Button.MouseButton1Click:Connect(function()

            Enabled = not Enabled

            TweenService:Create(
                Ball,
                TweenInfo.new(.22,Enum.EasingStyle.Quad),
                {
                    Position = Enabled and UDim2.new(1,-25,.5,-11) or UDim2.new(0,3,.5,-11)
                }
            ):Play()

            TweenService:Create(
                Toggle,
                TweenInfo.new(.22),
                {
                    BackgroundColor3 = Enabled and Color3.fromRGB(85,120,255) or Color3.fromRGB(45,45,55)
                }
            ):Play()

            print(name.." TEST-"..i,Enabled)
        end)

    end

end

CreatePage("Main")
CreatePage("Player")
CreatePage("Other")

Pages.Main.Visible=true

local function Select(name)
    for _,v in pairs(Pages) do
        v.Visible=false
    end
    Pages[name].Visible=true
end

local function Tab(text)

    local Btn = Instance.new("TextButton")
    Btn.Parent = Tabs
    Btn.Size = UDim2.new(1,0,0,45)
    Btn.Text = text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 17
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.BackgroundColor3 = Color3.fromRGB(30,30,40)
    Btn.BorderSizePixel = 0

    Instance.new("UICorner",Btn).CornerRadius=UDim.new(0,12)

    Btn.MouseButton1Click:Connect(function()

        for _,b in pairs(Tabs:GetChildren()) do
            if b:IsA("TextButton") then
                TweenService:Create(b,TweenInfo.new(.2),{
                    BackgroundColor3=Color3.fromRGB(30,30,40)
                }):Play()
            end
        end

        TweenService:Create(Btn,TweenInfo.new(.2),{
            BackgroundColor3=Color3.fromRGB(75,105,255)
        }):Play()

        Select(text)

    end)

    return Btn

end

local A=Tab("Main")
Tab("Player")
Tab("Other")

A.BackgroundColor3=Color3.fromRGB(75,105,255)

-- Drag
local Drag=false
local Start
local StartPos

Top.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        Drag=true
        Start=input.Position
        StartPos=Main.Position
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        Drag=false
    end
end)

UIS.InputChanged:Connect(function(input)
    if Drag and input.UserInputType==Enum.UserInputType.MouseMovement then
        local Delta=input.Position-Start
        Main.Position=UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset+Delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset+Delta.Y
        )
    end
end)
