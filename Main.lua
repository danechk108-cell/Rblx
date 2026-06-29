-- Beautiful UI Menu System
-- Dependencies: Drawing Library (Universal/Synapse X)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- ╔══════════════════════════════════════════════════════════╗
-- ║                    CONFIGURATION                          ║
-- ╚══════════════════════════════════════════════════════════╝

local Config = {
    -- Window
    WindowWidth = 580,
    WindowHeight = 420,
    WindowX = 100,
    WindowY = 100,
    
    -- Colors
    Colors = {
        Background      = Color3.fromRGB(10, 10, 15),
        BackgroundGrad  = Color3.fromRGB(15, 15, 25),
        Header          = Color3.fromRGB(18, 18, 30),
        TabActive       = Color3.fromRGB(88, 101, 242),
        TabInactive     = Color3.fromRGB(25, 25, 40),
        TabHover        = Color3.fromRGB(40, 40, 65),
        ButtonOn        = Color3.fromRGB(88, 101, 242),
        ButtonOff       = Color3.fromRGB(30, 30, 50),
        ButtonHover     = Color3.fromRGB(50, 50, 80),
        ButtonBorder    = Color3.fromRGB(60, 60, 100),
        TextPrimary     = Color3.fromRGB(255, 255, 255),
        TextSecondary   = Color3.fromRGB(150, 150, 180),
        TextDisabled    = Color3.fromRGB(80, 80, 110),
        Accent          = Color3.fromRGB(88, 101, 242),
        AccentGlow      = Color3.fromRGB(120, 130, 255),
        AccentSecondary = Color3.fromRGB(235, 69, 158),
        Separator       = Color3.fromRGB(30, 30, 50),
        Shadow          = Color3.fromRGB(0, 0, 0),
        Success         = Color3.fromRGB(87, 242, 135),
        Panel           = Color3.fromRGB(18, 18, 28),
        PanelBorder     = Color3.fromRGB(35, 35, 60),
    },
    
    -- Animation
    AnimSpeed = 0.15,
    
    -- Toggle key
    ToggleKey = Enum.KeyCode.RightShift,
}

-- ╔══════════════════════════════════════════════════════════╗
-- ║                      STATE                               ║
-- ╚══════════════════════════════════════════════════════════╝

local State = {
    IsOpen      = true,
    ActiveTab   = 1,
    IsDragging  = false,
    DragOffset  = Vector2.new(0, 0),
    Buttons     = {},
    HoverButton = nil,
    HoverTab    = nil,
    Tick        = 0,
}

-- Initialize buttons (9 per tab, 3 tabs = 27 total)
for tab = 1, 3 do
    State.Buttons[tab] = {}
    for btn = 1, 9 do
        State.Buttons[tab][btn] = false
    end
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║                    DRAWING UTILS                         ║
-- ╚══════════════════════════════════════════════════════════╝

local function NewDrawing(type_, props)
    local obj = Drawing.new(type_)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function DrawRect(x, y, w, h, color, alpha, filled, thickness)
    return NewDrawing("Square", {
        Position  = Vector2.new(x, y),
        Size      = Vector2.new(w, h),
        Color     = color or Color3.new(1,1,1),
        Transparency = alpha or 1,
        Filled    = filled ~= false,
        Thickness = thickness or 1,
        Visible   = true,
    })
end

local function DrawLine(x1, y1, x2, y2, color, alpha, thickness)
    return NewDrawing("Line", {
        From  = Vector2.new(x1, y1),
        To    = Vector2.new(x2, y2),
        Color = color or Color3.new(1,1,1),
        Transparency = alpha or 1,
        Thickness    = thickness or 1,
        Visible      = true,
    })
end

local function DrawText(x, y, text, color, size, center, outline)
    return NewDrawing("Text", {
        Position    = Vector2.new(x, y),
        Text        = text,
        Color       = color or Color3.new(1,1,1),
        Size        = size or 14,
        Center      = center or false,
        Outline     = outline ~= false,
        OutlineColor= Color3.fromRGB(0,0,0),
        Transparency= 1,
        Visible     = true,
    })
end

local function DrawCircle(x, y, r, color, alpha, filled, thickness)
    return NewDrawing("Circle", {
        Position     = Vector2.new(x, y),
        Radius       = r,
        Color        = color or Color3.new(1,1,1),
        Transparency = alpha or 1,
        Filled       = filled ~= false,
        Thickness    = thickness or 1,
        Visible      = true,
    })
end

local function DrawTriangle(a, b, c, color, alpha, filled, thickness)
    return NewDrawing("Triangle", {
        PointA       = a,
        PointB       = b,
        PointC       = c,
        Color        = color or Color3.new(1,1,1),
        Transparency = alpha or 1,
        Filled       = filled ~= false,
        Thickness    = thickness or 1,
        Visible      = true,
    })
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║                   RENDER ENGINE                          ║
-- ╚══════════════════════════════════════════════════════════╝

local Drawings = {}

local function ClearDrawings()
    for _, d in pairs(Drawings) do
        pcall(function() d:Remove() end)
    end
    Drawings = {}
end

local function Add(d)
    table.insert(Drawings, d)
    return d
end

local Tabs = {
    {Name = "Main",   Icon = "⬡"},
    {Name = "Player", Icon = "⬡"},
    {Name = "Other",  Icon = "⬡"},
}

local function GetMousePos()
    return UserInputService:GetMouseLocation()
end

local function IsHovering(x, y, w, h)
    local m = GetMousePos()
    return m.X >= x and m.X <= x+w and m.Y >= y and m.Y <= y+h
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║                  RENDER FUNCTION                         ║
-- ╚══════════════════════════════════════════════════════════╝

local function Render()
    ClearDrawings()
    if not State.IsOpen then return end
    
    local C = Config.Colors
    local X = Config.WindowX
    local Y = Config.WindowY
    local W = Config.WindowWidth
    local H = Config.WindowHeight
    local tick = State.Tick
    
    -- ════════════════════════════════════════
    --            SHADOW LAYERS
    -- ════════════════════════════════════════
    for i = 8, 1, -1 do
        local alpha = 0.08 * (9 - i) / 8
        Add(DrawRect(X - i*2, Y - i*2, W + i*4, H + i*4,
            Color3.fromRGB(88, 101, 242), alpha))
    end
    
    -- ════════════════════════════════════════
    --           OUTER BORDER GLOW
    -- ════════════════════════════════════════
    local glowPulse = 0.6 + 0.4 * math.sin(tick * 2)
    Add(DrawRect(X-2, Y-2, W+4, H+4,
        C.AccentGlow, 0.15 * glowPulse))
    Add(DrawRect(X-1, Y-1, W+2, H+2,
        C.Accent, 0.5))
    
    -- ════════════════════════════════════════
    --           MAIN BACKGROUND
    -- ════════════════════════════════════════
    Add(DrawRect(X, Y, W, H, C.Background, 1))
    
    -- Background grid pattern
    for gx = 0, W, 30 do
        Add(DrawLine(X+gx, Y, X+gx, Y+H,
            Color3.fromRGB(30, 30, 50), 0.15))
    end
    for gy = 0, H, 30 do
        Add(DrawLine(X, Y+gy, X+W, Y+gy,
            Color3.fromRGB(30, 30, 50), 0.15))
    end
    
    -- ════════════════════════════════════════
    --              HEADER BAR
    -- ════════════════════════════════════════
    Add(DrawRect(X, Y, W, 50, C.Header, 1))
    
    -- Header accent line (animated)
    local rainbowH = Color3.fromHSV((tick * 0.1) % 1, 0.7, 1)
    Add(DrawRect(X, Y+48, W, 2, rainbowH, 0.9))
    
    -- Header left accent block
    Add(DrawRect(X, Y, 4, 50, C.Accent, 1))
    
    -- Logo circles
    for i = 1, 3 do
        local cx = X + 22 + (i-1)*12
        Add(DrawCircle(cx, Y+25,
            6 - i,
            i == 1 and C.Accent or 
            i == 2 and C.AccentSecondary or 
            C.AccentGlow,
            0.8 + 0.2*i))
    end
    
    -- Title text
    Add(DrawText(X + 60, Y + 14,
        "◈  SCRIPT MENU",
        C.TextPrimary, 18, false, true))
    
    -- Subtitle
    Add(DrawText(X + 61, Y + 33,
        "Ultimate Enhancement Suite v2.0",
        C.TextSecondary, 11, false, true))
    
    -- Close button area
    Add(DrawRect(X + W - 40, Y + 10, 28, 28,
        Color3.fromRGB(200, 60, 60), 
        IsHovering(X+W-40, Y+10, 28, 28) and 0.9 or 0.5))
    Add(DrawText(X + W - 27, Y + 17,
        "✕", C.TextPrimary, 13, true, true))
    
    -- Minimize button
    Add(DrawRect(X + W - 76, Y + 10, 28, 28,
        Color3.fromRGB(60, 60, 80),
        IsHovering(X+W-76, Y+10, 28, 28) and 0.9 or 0.5))
    Add(DrawText(X + W - 63, Y + 20,
        "─", C.TextSecondary, 11, true, true))
    
    -- ════════════════════════════════════════
    --            TAB NAVIGATION
    -- ════════════════════════════════════════
    local tabY = Y + 58
    local tabW = W / 3
    
    for i, tab in ipairs(Tabs) do
        local tx = X + (i-1) * tabW
        local isActive = State.ActiveTab == i
        local isHover  = State.HoverTab == i
        
        -- Tab background
        local tabColor = isActive and C.TabActive or
                         (isHover and C.TabHover or C.TabInactive)
        Add(DrawRect(tx, tabY, tabW, 38,
            tabColor, isActive and 1 or 0.85))
        
        -- Active tab glow
        if isActive then
            Add(DrawRect(tx, tabY, tabW, 38,
                C.AccentGlow, 0.1))
            Add(DrawRect(tx, tabY + 35, tabW, 3,
                C.AccentGlow, 1))
            
            -- Active tab corner accents
            Add(DrawRect(tx, tabY, 3, 38, C.AccentGlow, 0.8))
            Add(DrawRect(tx+tabW-3, tabY, 3, 38, C.AccentGlow, 0.8))
        end
        
        -- Tab separator
        if i < 3 then
            Add(DrawLine(tx+tabW, tabY+5,
                tx+tabW, tabY+30,
                C.Separator, 0.5, 1))
        end
        
        -- Tab number badge
        local badgePulse = isActive and (0.7 + 0.3*math.sin(tick*3)) or 0.5
        Add(DrawCircle(tx + tabW/2 - 28, tabY + 19,
            8, isActive and C.Accent or C.TextDisabled, badgePulse))
        Add(DrawText(tx + tabW/2 - 28, tabY + 14,
            tostring(i), C.TextPrimary, 11, true, true))
        
        -- Tab label
        Add(DrawText(tx + tabW/2 + 2, tabY + 12,
            tab.Name,
            isActive and C.TextPrimary or C.TextSecondary,
            14, true, true))
    end
    
    -- Tab bottom border
    Add(DrawLine(X, tabY+38, X+W, tabY+38,
        C.Separator, 0.8, 1))
    
    -- ════════════════════════════════════════
    --            CONTENT AREA
    -- ════════════════════════════════════════
    local contentY = tabY + 46
    local contentH = H - (contentY - Y) - 10
    
    -- Content panel background
    Add(DrawRect(X + 8, contentY, W - 16, contentH,
        C.Panel, 0.6))
    Add(DrawRect(X + 8, contentY, W - 16, contentH,
        C.PanelBorder, 0, false, 1))
    
    -- Section header
    local sectionName = Tabs[State.ActiveTab].Name .. " Options"
    Add(DrawRect(X + 8, contentY, W - 16, 24,
        Color3.fromRGB(20, 20, 35), 1))
    Add(DrawText(X + 18, contentY + 5,
        "▸  " .. sectionName,
        C.AccentGlow, 12, false, true))
    
    -- Count indicator
    local activeCount = 0
    for _, v in pairs(State.Buttons[State.ActiveTab]) do
        if v then activeCount = activeCount + 1 end
    end
    Add(DrawText(X + W - 20, contentY + 5,
        activeCount .. "/9 Active",
        activeCount > 0 and C.Success or C.TextDisabled,
        11, true, true))
    
    Add(DrawLine(X+8, contentY+24, X+W-8, contentY+24,
        C.Separator, 0.6, 1))
    
    -- ════════════════════════════════════════
    --              BUTTONS (3x3 grid)
    -- ════════════════════════════════════════
    local btnStartY = contentY + 32
    local btnW  = 152
    local btnH  = 42
    local btnPX = 16  -- padding X
    local btnPY = 10  -- padding Y
    local cols  = 3
    
    for btnIdx = 1, 9 do
        local row = math.ceil(btnIdx / cols) - 1
        local col = (btnIdx - 1) % cols
        
        local bx = X + 8 + btnPX + col * (btnW + btnPX)
        local by = btnStartY + row * (btnH + btnPY)
        
        local isOn    = State.Buttons[State.ActiveTab][btnIdx]
        local isHover = State.HoverButton == btnIdx
        
        -- Button shadow
        Add(DrawRect(bx+2, by+2, btnW, btnH,
            C.Shadow, 0.3))
        
        -- Button background
        local btnColor = isOn and C.ButtonOn or
                         (isHover and C.ButtonHover or C.ButtonOff)
        Add(DrawRect(bx, by, btnW, btnH, btnColor,
            isOn and 1 or (isHover and 0.9 or 0.85)))
        
        -- Button glow if ON
        if isOn then
            local pulse = 0.15 + 0.08 * math.sin(tick * 3 + btnIdx)
            Add(DrawRect(bx-1, by-1, btnW+2, btnH+2,
                C.AccentGlow, pulse))
        end
        
        -- Button border
        Add(DrawRect(bx, by, btnW, btnH,
            isOn and C.AccentGlow or
            (isHover and C.ButtonBorder or C.Separator),
            isOn and 0.8 or 0.5, false, 1))
        
        -- Left accent bar
        Add(DrawRect(bx, by, 3, btnH,
            isOn and C.AccentGlow or C.TextDisabled,
            isOn and 1 or 0.3))
        
        -- Button icon area
        Add(DrawRect(bx+8, by + btnH/2 - 10, 20, 20,
            isOn and Color3.fromRGB(100, 115, 255) or
            Color3.fromRGB(30, 30, 50),
            isOn and 0.9 or 0.5))
        Add(DrawText(bx+18, by + btnH/2 - 7,
            isOn and "✓" or "#",
            isOn and C.TextPrimary or C.TextDisabled,
            11, true, true))
        
        -- Button label
        Add(DrawText(bx + 36, by + 8,
            string.format("TEST-%d", btnIdx),
            isOn and C.TextPrimary or C.TextSecondary,
            13, false, true))
        
        -- Status text
        Add(DrawText(bx + 37, by + 23,
            isOn and "● ENABLED" or "○ DISABLED",
            isOn and C.Success or C.TextDisabled,
            10, false, true))
        
        -- Toggle indicator (right side)
        local toggleX = bx + btnW - 34
        local toggleY = by + btnH/2 - 8
        Add(DrawRect(toggleX, toggleY, 26, 16,
            isOn and C.Accent or Color3.fromRGB(20,20,35),
            isOn and 1 or 0.8))
        Add(DrawRect(toggleX, toggleY, 26, 16,
            isOn and C.AccentGlow or C.Separator,
            0.6, false, 1))
        local knobX = isOn and toggleX+12 or toggleX+2
        Add(DrawRect(knobX, toggleY+2, 12, 12,
            C.TextPrimary, isOn and 1 or 0.5))
    end
    
    -- ════════════════════════════════════════
    --           FOOTER / STATUS BAR
    -- ════════════════════════════════════════
    local footerY = Y + H - 24
    Add(DrawRect(X, footerY, W, 24,
        Color3.fromRGB(12, 12, 20), 1))
    Add(DrawLine(X, footerY, X+W, footerY,
        C.Separator, 0.8, 1))
    
    -- Left status
    Add(DrawText(X + 12, footerY + 6,
        "◈ Status: Running",
        C.Success, 11, false, true))
    
    -- Center - tab indicator dots
    for i = 1, 3 do
        local dotX = X + W/2 - 12 + (i-1)*12
        Add(DrawCircle(dotX, footerY + 12,
            i == State.ActiveTab and 4 or 2.5,
            i == State.ActiveTab and C.AccentGlow or C.TextDisabled,
            i == State.ActiveTab and 1 or 0.5))
    end
    
    -- Right - toggle key hint
    Add(DrawText(X + W - 12, footerY + 6,
        "RShift to Toggle",
        C.TextDisabled, 10, true, true))
    
    -- ════════════════════════════════════════
    --        DECORATIVE CORNER ELEMENTS
    -- ════════════════════════════════════════
    -- Top-left corner
    Add(DrawLine(X, Y, X+15, Y, C.AccentGlow, 0.8, 2))
    Add(DrawLine(X, Y, X, Y+15, C.AccentGlow, 0.8, 2))
    
    -- Top-right corner
    Add(DrawLine(X+W, Y, X+W-15, Y, C.AccentGlow, 0.8, 2))
    Add(DrawLine(X+W, Y, X+W, Y+15, C.AccentGlow, 0.8, 2))
    
    -- Bottom-left corner
    Add(DrawLine(X, Y+H, X+15, Y+H, C.AccentGlow, 0.8, 2))
    Add(DrawLine(X, Y+H, X, Y+H-15, C.AccentGlow, 0.8, 2))
    
    -- Bottom-right corner
    Add(DrawLine(X+W, Y+H, X+W-15, Y+H, C.AccentGlow, 0.8, 2))
    Add(DrawLine(X+W, Y+H, X+W, Y+H-15, C.AccentGlow, 0.8, 2))
    
    -- ════════════════════════════════════════
    --          ANIMATED SCAN LINE
    -- ════════════════════════════════════════
    local scanY = Y + ((tick * 60) % H)
    Add(DrawLine(X, scanY, X+W, scanY,
        C.AccentGlow, 0.04, 1))
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║                   INPUT HANDLING                         ║
-- ╚══════════════════════════════════════════════════════════╝

local function GetTabAtMouse()
    if not State.IsOpen then return nil end
    local m   = GetMousePos()
    local X   = Config.WindowX
    local Y   = Config.WindowY
    local W   = Config.WindowWidth
    local tabY = Y + 58
    local tabW = W / 3
    
    for i = 1, 3 do
        local tx = X + (i-1)*tabW
        if m.X >= tx and m.X <= tx+tabW and
           m.Y >= tabY and m.Y <= tabY+38 then
            return i
        end
    end
    return nil
end

local function GetButtonAtMouse()
    if not State.IsOpen then return nil end
    local m       = GetMousePos()
    local X       = Config.WindowX
    local Y       = Config.WindowY
    local tabY    = Y + 58
    local contentY= tabY + 46
    local btnStartY = contentY + 32
    local btnW    = 152
    local btnH    = 42
    local btnPX   = 16
    local btnPY   = 10
    local cols    = 3
    
    for btnIdx = 1, 9 do
        local row = math.ceil(btnIdx / cols) - 1
        local col = (btnIdx - 1) % cols
        local bx  = X + 8 + btnPX + col*(btnW+btnPX)
        local by  = btnStartY + row*(btnH+btnPY)
        
        if m.X >= bx and m.X <= bx+btnW and
           m.Y >= by and m.Y <= by+btnH then
            return btnIdx
        end
    end
    return nil
end

local function IsOnCloseButton()
    local X = Config.WindowX
    local Y = Config.WindowY
    local W = Config.WindowWidth
    return IsHovering(X+W-40, Y+10, 28, 28)
end

local function IsOnHeader()
    return IsHovering(Config.WindowX, Config.WindowY,
        Config.WindowWidth - 80, 50)
end

-- Mouse button pressed
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    -- Toggle menu
    if input.KeyCode == Config.ToggleKey then
        State.IsOpen = not State.IsOpen
        return
    end
    
    if not State.IsOpen then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local m = GetMousePos()
        
        -- Close button
        if IsOnCloseButton() then
            State.IsOpen = false
            return
        end
        
        -- Tab click
        local tab = GetTabAtMouse()
        if tab then
            State.ActiveTab = tab
            return
        end
        
        -- Button click
        local btn = GetButtonAtMouse()
        if btn then
            State.Buttons[State.ActiveTab][btn] =
                not State.Buttons[State.ActiveTab][btn]
            return
        end
        
        -- Drag start
        if IsOnHeader() then
            State.IsDragging = true
            State.DragOffset = Vector2.new(
                m.X - Config.WindowX,
                m.Y - Config.WindowY
            )
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        State.IsDragging = false
    end
end)

-- ╔══════════════════════════════════════════════════════════╗
-- ║                    MAIN LOOP                             ║
-- ╚══════════════════════════════════════════════════════════╝

RunService.RenderStepped:Connect(function(dt)
    State.Tick = State.Tick + dt
    
    -- Update drag
    if State.IsDragging then
        local m = GetMousePos()
        Config.WindowX = m.X - State.DragOffset.X
        Config.WindowY = m.Y - State.DragOffset.Y
    end
    
    -- Update hover states
    State.HoverButton = GetButtonAtMouse()
    State.HoverTab    = GetTabAtMouse()
    
    -- Re-render
    Render()
end)

-- Initial render
Render()

print("╔══════════════════════════════════════╗")
print("║     UI Menu Loaded Successfully!     ║")
print("║   Press RightShift to Toggle Menu   ║")
print("╚══════════════════════════════════════╝")
