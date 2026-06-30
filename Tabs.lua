--// Tabs.lua

local Components = require(script.Parent.Components)

local Tabs = {}

Tabs.List = {}
Tabs.Current = nil

-------------------------------------------------
-- CREATE TAB
-------------------------------------------------

function Tabs:Create(Name, Icon, Sidebar, Content)

    local Button = Components.SideButton(Sidebar, Name, Icon)

    local Page = Instance.new("ScrollingFrame")
    Page.Name = Name
    Page.Parent = Content
    Page.Visible = false
    Page.Size = UDim2.new(1,-20,1,-20)
    Page.Position = UDim2.fromOffset(10,10)

    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0

    Page.CanvasSize = UDim2.new()
    Page.ScrollBarThickness = 4
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Page
    Layout.Padding = UDim.new(0,10)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local Padding = Instance.new("UIPadding")
    Padding.Parent = Page
    Padding.PaddingBottom = UDim.new(0,8)

    -------------------------------------------------
    -- SELECT TAB
    -------------------------------------------------

    local function Select()

        if Tabs.Current then
            Tabs.Current.Page.Visible = false
            Tabs.Current.Button.BackgroundColor3 = Color3.fromRGB(28,28,34)
        end

        Page.Visible = true
        Button.BackgroundColor3 = Color3.fromRGB(88,155,255)

        Tabs.Current = {
            Button = Button,
            Page = Page
        }

    end

    Button.MouseButton1Click:Connect(Select)

    local Tab = {}

    -------------------------------------------------
    -- ADD TOGGLE
    -------------------------------------------------

    function Tab:Toggle(Name, Desc)

        return Components.Toggle(Page, Name, Desc)

    end

    -------------------------------------------------
    -- ADD BUTTON
    -------------------------------------------------

    function Tab:Button(Name)

        local Btn = Instance.new("TextButton")
        Btn.Parent = Page
        Btn.Size = UDim2.new(1,0,0,52)
        Btn.BackgroundColor3 = Color3.fromRGB(28,28,34)
        Btn.Text = Name
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 15
        Btn.TextColor3 = Color3.new(1,1,1)
        Btn.AutoButtonColor = false

        Instance.new("UICorner",Btn).CornerRadius = UDim.new(0,14)

        Instance.new("UIStroke",Btn).Color =
            Color3.fromRGB(55,55,65)

        return Btn

    end

    -------------------------------------------------
    -- ADD LABEL
    -------------------------------------------------

    function Tab:Label(Text)

        local L = Instance.new("TextLabel")
        L.Parent = Page
        L.Size = UDim2.new(1,0,0,24)
        L.BackgroundTransparency = 1
        L.Font = Enum.Font.GothamBold
        L.Text = Text
        L.TextSize = 18
        L.TextColor3 = Color3.new(1,1,1)
        L.TextXAlignment = Enum.TextXAlignment.Left

        return L

    end

    table.insert(Tabs.List, Tab)

    if #Tabs.List == 1 then
        Select()
    end

    return Tab

end

return Tabs
