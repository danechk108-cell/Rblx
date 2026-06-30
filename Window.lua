-- Window.lua
local Core       = require(script.Parent.Core)
local Components = require(script.Parent.Components)
local Features   = require(script.Parent.Features)
local C          = Core.C
local TW         = game:GetService("TweenService")

local Window = {}

function Window.Build()
    local Screen = Core.Screen
    local Open   = true
    local CurTab = 1

    -- ── MINI BUTTON ─────────────────────────────
    local mini = Core.New("TextButton", {
        Size = UDim2.new(0,48,0,48),
        Position = UDim2.new(0,12,0.35,-24),
        BackgroundColor3 = C.SB0,
        BorderSizePixel  = 0,
        Text = "L",
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        TextColor3 = C.Acc,
        Visible = false,
        ZIndex = 20,
    }, Screen)
    Core.Round(mini, 16)
    Core.Stroke(mini, C.AccLine, 1.5)

    -- ── SIDEBAR ─────────────────────────────────
    local sidebar = Core.New("Frame", {
        Size     = UDim2.new(0,68,0,0),
        Position = UDim2.new(0,12,0.5,0),
        BackgroundColor3 = C.SB0,
        BorderSizePixel  = 0,
        AutomaticSize    = Enum.AutomaticSize.Y,
    }, Screen)
    Core.Round(sidebar, 24)
    Core.Stroke(sidebar, C.AccSoft, 1.5)

    local sideInner = Core.New("Frame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, sidebar)
    Core.Pad(sideInner, 10)
    Core.List(sideInner, Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center)

    -- "MENU" label
    Core.New("TextLabel", {
        Size = UDim2.new(1,0,0,14),
        Text = "MENU",
        TextSize = 7,
        Font = Enum.Font.GothamMedium,
        TextColor3 = C.TxL,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        LayoutOrder = 0,
    }, sideInner)

    -- Icons for tabs
    local icons = {"⚡","👤","👁","⚙"}
    local navBtns = {}

    local function BuildNav()
        for _,btn in ipairs(navBtns) do btn:Destroy() end
        navBtns = {}
        for i,tab in ipairs(Features.TABS) do
            local btn = Components.NavButton(sideInner, icons[i], CurTab==i, function()
                CurTab = i
                BuildNav()
                -- rebuild content
                Window.RefreshContent()
            end)
            btn.LayoutOrder = i
            btn.Size = UDim2.new(0,48,0,48)
            table.insert(navBtns, btn)
        end
        -- Settings button
        local sBtn = Components.NavButton(sideInner, icons[4], CurTab==4, function()
            CurTab = 4
            BuildNav()
            Window.RefreshContent()
        end)
        sBtn.LayoutOrder = 10
        sBtn.Size = UDim2.new(0,48,0,48)
        table.insert(navBtns, sBtn)
    end
    BuildNav()

    -- Anchor sidebar to panel
    local function UpdateSidebarPos()
        local panX = panel and panel.AbsolutePosition.X or 200
        local panY = panel and panel.AbsolutePosition.Y or 100
        local panH = panel and panel.AbsoluteSize.Y or 500
        sidebar.Position = UDim2.new(0, panX-78, 0, panY + math.floor(panH/2) - math.floor(sidebar.AbsoluteSize.Y/2))
    end

    -- ── MAIN PANEL ──────────────────────────────
    local VP = workspace.CurrentCamera.ViewportSize
    local PW = math.min(680, math.floor(VP.X * 0.60))
    local PH = 600
    local PX = math.floor((VP.X - PW)/2)
    local PY = math.floor((VP.Y - PH)/2)

    local panel = Core.New("Frame", {
        Size     = UDim2.new(0,PW,0,PH),
        Position = UDim2.new(0,PX,0,PY),
        BackgroundColor3 = C.BG1,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
    }, Screen)
    Core.Round(panel, 22)
    Core.Stroke(panel, C.Bord, 1.5)

    -- HEADER
    local header = Core.New("Frame", {
        Size = UDim2.new(1,0,0,68),
        BackgroundColor3 = C.BG2,
        BorderSizePixel  = 0,
    }, panel)
    Core.Round(header, 22)
    -- Fix bottom corners of header
    Core.New("Frame", {
        Size = UDim2.new(1,0,0,22),
        Position = UDim2.new(0,0,1,-22),
        BackgroundColor3 = C.BG2,
        BorderSizePixel = 0,
    }, header)

    -- Accent line
    local accentLine = Core.New("Frame", {
        Size = UDim2.new(1,0,0,2),
        Position = UDim2.new(0,0,1,-2),
        BackgroundColor3 = C.Acc,
        BorderSizePixel  = 0,
    }, header)

    -- Logo circle
    local logoFrame = Core.New("Frame", {
        Size = UDim2.new(0,40,0,40),
        Position = UDim2.new(0,14,0.5,-20),
        BackgroundColor3 = C.Acc3,
        BorderSizePixel  = 0,
    }, header)
    Core.Round(logoFrame, 20)
    Core.Stroke(logoFrame, C.AccLine, 1.5)
    Core.New("Frame", {
        Size = UDim2.new(0,32,0,32),
        Position = UDim2.new(0.5,-16,0.5,-16),
        BackgroundColor3 = C.AccSoft,
        BorderSizePixel  = 0,
    }, logoFrame)
    Core.Round(logoFrame:FindFirstChildOfClass("Frame"), 16)
    Core.New("TextLabel", {
        Size = UDim2.new(1,0,1,0),
        Text = "L",
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        TextColor3 = C.Acc,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, logoFrame)

    -- Title
    local titleFrame = Core.New("Frame", {
        Size = UDim2.new(0,200,1,0),
        Position = UDim2.new(0,62,0,0),
        BackgroundTransparency = 1,
    }, header)
    Core.New("TextLabel", {
        Size = UDim2.new(1,0,0,30),
        Position = UDim2.new(0,0,0,10),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        RichText = true,
        Text = '<font color="#F5F5FF">LUXURY </font><font color="#9364FF">HUB</font>',
        TextColor3 = C.TxW,
    }, titleFrame)
    Core.New("TextLabel", {
        Size = UDim2.new(1,0,0,16),
        Position = UDim2.new(0,0,0,38),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        Text = "PREMIUM CONTROLS",
        TextColor3 = C.TxL,
    }, titleFrame)

    -- Close & Minimize buttons
    local function MakeBtn(xOffset, bgColor, hoverColor, onClick)
        local btn = Core.New("TextButton", {
            Size = UDim2.new(0,28,0,28),
            Position = UDim2.new(1,xOffset,0.5,-14),
            BackgroundColor3 = bgColor,
            BorderSizePixel  = 0,
            Text = "",
            AutoButtonColor  = false,
        }, header)
        Core.Round(btn, 14)
        Core.Stroke(btn, C.Bord, 1)
        btn.MouseEnter:Connect(function()
            Core.Tween(btn,{BackgroundColor3=hoverColor},0.15)
        end)
        btn.MouseLeave:Connect(function()
            Core.Tween(btn,{BackgroundColor3=bgColor},0.15)
        end)
        btn.MouseButton1Click:Connect(onClick)
        return btn
    end

    local closeBtn = MakeBtn(-10, C.BG3, C.Red, function()
        Core.Tween(panel,   {Size=UDim2.new(0,PW,0,0)}, 0.25)
        Core.Tween(sidebar, {BackgroundTransparency=1},  0.2)
        task.delay(0.26, function()
            panel.Visible   = false
            sidebar.Visible = false
            mini.Visible    = true
            Core.Tween(mini,{BackgroundTransparency=0},0.2)
        end)
        Open = false
    end)
    -- X icon
    Core.New("TextLabel",{
        Size=UDim2.new(1,0,1,0), Text="✕",
        TextSize=12, Font=Enum.Font.GothamBold,
        TextColor3=C.TxM, BackgroundTransparency=1,
    }, closeBtn)

    local minBtn = MakeBtn(-46, C.BG3, C.BG4, function()
        Core.Tween(panel,   {Size=UDim2.new(0,PW,0,0)}, 0.25)
        task.delay(0.26, function()
            panel.Visible   = false
            sidebar.Visible = false
            mini.Visible    = true
        end)
        Open = false
    end)
    Core.New("TextLabel",{
        Size=UDim2.new(1,0,1,0), Text="─",
        TextSize=14, Font=Enum.Font.GothamBold,
        TextColor3=C.TxM, BackgroundTransparency=1,
    }, minBtn)

    -- CONTENT AREA
    local contentArea = Core.New("ScrollingFrame", {
        Size = UDim2.new(1,0,1,-68-30),
        Position = UDim2.new(0,0,0,68),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, panel)
    Core.Pad(contentArea, nil, 8, 8, 12, 12)
    Core.List(contentArea, Enum.FillDirection.Vertical, 5)

    -- FOOTER
    local footer = Core.New("Frame", {
        Size = UDim2.new(1,0,0,30),
        Position = UDim2.new(0,0,1,-30),
        BackgroundColor3 = C.BG1,
        BorderSizePixel  = 0,
    }, panel)

    local footSep = Core.New("Frame", {
        Size = UDim2.new(1,-24,0,1),
        Position = UDim2.new(0,12,0,0),
        BackgroundColor3 = C.Sep,
        BorderSizePixel  = 0,
    }, footer)

    local footStatus = Core.New("TextLabel", {
        Size = UDim2.new(0.4,0,1,0),
        Position = UDim2.new(0,14,0,0),
        Text = "0 active",
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextColor3 = C.TxL,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, footer)

    local footTab = Core.New("TextLabel", {
        Size = UDim2.new(0.3,0,1,0),
        Position = UDim2.new(0.35,0,0,0),
        Text = "Main",
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextColor3 = C.TxM,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, footer)

    Core.New("TextLabel", {
        Size = UDim2.new(0.3,0,1,0),
        Position = UDim2.new(0.7,0,0,0),
        Text = "RShift",
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextColor3 = C.TxF,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, footer)

    -- DRAG
    local dragging=false; local dragStart; local startPos
    header.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true
            dragStart=inp.Position
            startPos=panel.Position
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
            local d=inp.Position-dragStart
            panel.Position=UDim2.new(
                startPos.X.Scale, startPos.X.Offset+d.X,
                startPos.Y.Scale, startPos.Y.Offset+d.Y)
            -- Update sidebar position
            local px=panel.AbsolutePosition.X
            local py=panel.AbsolutePosition.Y
            local ph=panel.AbsoluteSize.Y
            sidebar.Position=UDim2.new(0,px-78,0,py+math.floor(ph/2)-math.floor(sidebar.AbsoluteSize.Y/2))
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=false
        end
    end)

    -- MINI BUTTON CLICK
    mini.MouseButton1Click:Connect(function()
        mini.Visible    = false
        panel.Visible   = true
        sidebar.Visible = true
        panel.Size = UDim2.new(0,PW,0,0)
        Core.Tween(panel,{Size=UDim2.new(0,PW,0,PH)},0.3)
        Open = true
    end)

    -- RShift toggle
    game:GetService("UserInputService").InputBegan:Connect(function(inp,gpe)
        if gpe then return end
        if inp.KeyCode==Enum.KeyCode.RightShift then
            if Open then
                Core.Tween(panel,{Size=UDim2.new(0,PW,0,0)},0.25)
                task.delay(0.26,function()
                    panel.Visible=false; sidebar.Visible=false; mini.Visible=true end)
                Open=false
            else
                mini.Visible=false; panel.Visible=true; sidebar.Visible=true
                panel.Size=UDim2.new(0,PW,0,0)
                Core.Tween(panel,{Size=UDim2.new(0,PW,0,PH)},0.3)
                Open=true
            end
        end
    end)

    -- CONTENT BUILDER
    local tabNames={"Main","Player","Visual"}
    function Window.RefreshContent()
        -- Clear
        for _,c in ipairs(contentArea:GetChildren()) do
            if c:IsA("Frame") or c:IsA("TextButton") or c:IsA("TextLabel") then
                c:Destroy()
            end
        end

        footTab.Text = tabNames[CurTab] or "Settings"

        if CurTab <= 3 then
            local tab = Features.TABS[CurTab]
            local activeCount = 0

            for _,item in ipairs(tab.items) do
                Components.Card(contentArea, item, function(state, it)
                    if state then
                        pcall(it.enable, it)
                        activeCount = activeCount + 1
                    else
                        pcall(it.disable, it)
                        activeCount = math.max(0, activeCount-1)
                    end
                    -- Recount
                    local cnt=0
                    for _,i2 in ipairs(tab.items) do if i2.state then cnt=cnt+1 end end
                    footStatus.Text = cnt.." active"
                    footStatus.TextColor3 = cnt>0 and C.Green or C.TxL
                end)
            end

            -- Initial count
            local cnt=0
            for _,item in ipairs(tab.items) do if item.state then cnt=cnt+1 end end
            footStatus.Text = cnt.." active"
            footStatus.TextColor3 = cnt>0 and C.Green or C.TxL

        else
            -- Settings tab
            footStatus.Text = "settings"
            footStatus.TextColor3 = C.TxL

            local function Section(txt)
                Core.New("TextLabel",{
                    Size=UDim2.new(1,0,0,14),
                    Text=txt, TextSize=9,
                    Font=Enum.Font.GothamMedium,
                    TextColor3=C.TxL,
                    BackgroundTransparency=1,
                    TextXAlignment=Enum.TextXAlignment.Left,
                }, contentArea)
            end

            Section("HOTKEY")
            local hkFrame = Core.New("Frame",{
                Size=UDim2.new(1,0,0,38),
                BackgroundColor3=C.BG3,
                BorderSizePixel=0,
            }, contentArea)
            Core.Round(hkFrame,12)
            Core.Stroke(hkFrame, C.AccLine, 1)
            Core.New("TextLabel",{
                Size=UDim2.new(1,0,1,0),
                Text="RIGHT SHIFT  —  Toggle UI",
                TextSize=12,
                Font=Enum.Font.GothamMedium,
                TextColor3=C.Acc,
                BackgroundTransparency=1,
                TextXAlignment=Enum.TextXAlignment.Center,
            }, hkFrame)

            Section("ACTIVITY")
            for ti=1,3 do
                local tab=Features.TABS[ti]
                local cnt=0
                for _,it in ipairs(tab.items) do if it.state then cnt=cnt+1 end end
                local row=Core.New("Frame",{
                    Size=UDim2.new(1,0,0,32),
                    BackgroundColor3=C.BG2,
                    BorderSizePixel=0,
                }, contentArea)
                Core.Round(row,10)
                Core.New("TextLabel",{
                    Size=UDim2.new(0,80,1,0),
                    Position=UDim2.new(0,10,0,0),
                    Text=tab.name,
                    TextSize=11,Font=Enum.Font.GothamMedium,
                    TextColor3=C.TxM,BackgroundTransparency=1,
                    TextXAlignment=Enum.TextXAlignment.Left,
                }, row)
                local bW=200
                local trackF=Core.New("Frame",{
                    Size=UDim2.new(0,bW,0,8),
                    Position=UDim2.new(0,90,0.5,-4),
                    BackgroundColor3=C.SlTrack,BorderSizePixel=0,
                }, row)
                Core.Round(trackF,4)
                if cnt>0 then
                    local fillF=Core.New("Frame",{
                        Size=UDim2.new(cnt/#tab.items,0,1,0),
                        BackgroundColor3=C.Acc,BorderSizePixel=0,
                    }, trackF)
                    Core.Round(fillF,4)
                end
                Core.New("TextLabel",{
                    Size=UDim2.new(0,50,1,0),
                    Position=UDim2.new(1,-55,0,0),
                    Text=cnt.."/"..#tab.items,
                    TextSize=10,Font=Enum.Font.Gotham,
                    TextColor3=C.TxL,BackgroundTransparency=1,
                    TextXAlignment=Enum.TextXAlignment.Right,
                }, row)
            end
        end
    end

    -- Initial sidebar position
    task.defer(function()
        local px=panel.AbsolutePosition.X
        local py=panel.AbsolutePosition.Y
        local ph=panel.AbsoluteSize.Y
        sidebar.Position=UDim2.new(0,px-78,0,py+math.floor(ph/2)-math.floor(sidebar.AbsoluteSize.Y/2))
    end)

    Window.RefreshContent()
    return Window
end

return Window
