--// Components.lua

local TweenService = game:GetService("TweenService")

local Components = {}

----------------------------------------------------
-- THEME
----------------------------------------------------

local COLORS = {
    Background = Color3.fromRGB(20,20,25),
    Card = Color3.fromRGB(28,28,34),
    Hover = Color3.fromRGB(36,36,45),
    Accent = Color3.fromRGB(88,155,255),
    Text = Color3.fromRGB(240,240,240),
    TextDark = Color3.fromRGB(140,140,150),
    Stroke = Color3.fromRGB(55,55,65)
}

----------------------------------------------------
-- SIDEBAR BUTTON
----------------------------------------------------

function Components.SideButton(parent,text,icon)

    local Button = Instance.new("TextButton")
    Button.Parent = parent
    Button.Size = UDim2.new(1,-16,0,50)
    Button.BackgroundColor3 = COLORS.Card
    Button.Text = ""
    Button.AutoButtonColor = false

    local Corner = Instance.new("UICorner",Button)
    Corner.CornerRadius = UDim.new(0,14)

    local Stroke = Instance.new("UIStroke",Button)
    Stroke.Color = COLORS.Stroke

    local Icon = Instance.new("TextLabel")
    Icon.Parent = Button
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.fromOffset(16,0)
    Icon.Size = UDim2.fromOffset(30,50)
    Icon.Font = Enum.Font.GothamBold
    Icon.Text = icon
    Icon.TextSize = 22
    Icon.TextColor3 = COLORS.Text

    local Label = Instance.new("TextLabel")
    Label.Parent = Button
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.fromOffset(56,0)
    Label.Size = UDim2.new(1,-60,1,0)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 15
    Label.Text = text
    Label.TextColor3 = COLORS.Text

    Button.MouseEnter:Connect(function()

        TweenService:Create(Button,TweenInfo.new(.15),{
            BackgroundColor3 = COLORS.Hover
        }):Play()

    end)

    Button.MouseLeave:Connect(function()

        TweenService:Create(Button,TweenInfo.new(.15),{
            BackgroundColor3 = COLORS.Card
        }):Play()

    end)

    return Button

end

----------------------------------------------------
-- TOGGLE CARD
----------------------------------------------------

function Components.Toggle(parent,title,desc)

    local Card = Instance.new("Frame")
    Card.Parent = parent
    Card.Size = UDim2.new(1,0,0,60)
    Card.BackgroundColor3 = COLORS.Card

    Instance.new("UICorner",Card).CornerRadius = UDim.new(0,14)

    local Stroke = Instance.new("UIStroke",Card)
    Stroke.Color = COLORS.Stroke

    local Title = Instance.new("TextLabel")
    Title.Parent = Card
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.fromOffset(18,8)
    Title.Size = UDim2.new(.6,0,0,20)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextSize = 15
    Title.TextColor3 = COLORS.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Desc = Instance.new("TextLabel")
    Desc.Parent = Card
    Desc.BackgroundTransparency = 1
    Desc.Position = UDim2.fromOffset(18,30)
    Desc.Size = UDim2.new(.7,0,0,16)
    Desc.Font = Enum.Font.Gotham
    Desc.Text = desc
    Desc.TextSize = 12
    Desc.TextColor3 = COLORS.TextDark
    Desc.TextXAlignment = Enum.TextXAlignment.Left

    ------------------------------------------------
    -- SWITCH
    ------------------------------------------------

    local Toggle = Instance.new("Frame")
    Toggle.Parent = Card
    Toggle.AnchorPoint = Vector2.new(1,.5)
    Toggle.Position = UDim2.new(1,-18,.5,0)
    Toggle.Size = UDim2.fromOffset(52,28)
    Toggle.BackgroundColor3 = Color3.fromRGB(55,55,65)

    Instance.new("UICorner",Toggle).CornerRadius = UDim.new(1,0)

    local Knob = Instance.new("Frame")
    Knob.Parent = Toggle
    Knob.Position = UDim2.fromOffset(3,3)
    Knob.Size = UDim2.fromOffset(22,22)
    Knob.BackgroundColor3 = Color3.new(1,1,1)

    Instance.new("UICorner",Knob).CornerRadius = UDim.new(1,0)

    local Enabled = false

    local function Update()

        if Enabled then

            TweenService:Create(Toggle,TweenInfo.new(.18),{
                BackgroundColor3 = COLORS.Accent
            }):Play()

            TweenService:Create(Knob,TweenInfo.new(.18),{
                Position = UDim2.fromOffset(27,3)
            }):Play()

        else

            TweenService:Create(Toggle,TweenInfo.new(.18),{
                BackgroundColor3 = Color3.fromRGB(55,55,65)
            }):Play()

            TweenService:Create(Knob,TweenInfo.new(.18),{
                Position = UDim2.fromOffset(3,3)
            }):Play()

        end

    end

    Card.InputBegan:Connect(function(i)

        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            Enabled = not Enabled
            Update()
        end

    end)

    return Card

end

----------------------------------------------------
-- NOTIFICATION
----------------------------------------------------

function Components.Notify(parent,title,text)

    local Frame = Instance.new("Frame")
    Frame.Parent = parent
    Frame.Size = UDim2.fromOffset(280,70)
    Frame.Position = UDim2.new(1,300,1,-90)
    Frame.BackgroundColor3 = COLORS.Card

    Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,16)

    Instance.new("UIStroke",Frame).Color = COLORS.Stroke

    local T = Instance.new("TextLabel")
    T.Parent = Frame
    T.BackgroundTransparency = 1
    T.Position = UDim2.fromOffset(16,10)
    T.Size = UDim2.new(1,-20,0,20)
    T.Font = Enum.Font.GothamBold
    T.Text = title
    T.TextSize = 16
    T.TextColor3 = COLORS.Text
    T.TextXAlignment = Enum.TextXAlignment.Left

    local D = Instance.new("TextLabel")
    D.Parent = Frame
    D.BackgroundTransparency = 1
    D.Position = UDim2.fromOffset(16,34)
    D.Size = UDim2.new(1,-20,0,18)
    D.Font = Enum.Font.Gotham
    D.Text = text
    D.TextSize = 13
    D.TextColor3 = COLORS.TextDark
    D.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(Frame,TweenInfo.new(.25),{
        Position = UDim2.new(1,-300,1,-90)
    }):Play()

    task.delay(3,function()

        TweenService:Create(Frame,TweenInfo.new(.25),{
            Position = UDim2.new(1,300,1,-90)
        }):Play()

        task.wait(.3)
        Frame:Destroy()

    end)

end

return Components
