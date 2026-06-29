-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                     SCRIPT HUB UI v3.0                       ║
-- ║              by Advanced Drawing Library Engine               ║
-- ╚═══════════════════════════════════════════════════════════════╝

local UIS = game:GetService("UserInputService")
local RS  = game:GetService("RunService")

-- ══════════════════════════════════════════
--               CONFIGURATION
-- ══════════════════════════════════════════
local CFG = {
    -- Main window
    WX = 280, WY = 80,
    WW = 520, WH = 480,

    -- Sidebar
    SW = 64,   -- sidebar width
    SH = 360,  -- sidebar height (auto positioned)
    SGap = 12, -- gap between sidebar and window

    -- Mini button (when closed)
    MBW = 36, MBH = 80,

    -- Colors
    BG         = Color3.fromRGB(13,  13,  22 ),
    BG2        = Color3.fromRGB(18,  18,  30 ),
    BG3        = Color3.fromRGB(22,  22,  38 ),
    Panel      = Color3.fromRGB(20,  20,  34 ),
    PanelBord  = Color3.fromRGB(38,  38,  65 ),
    Accent     = Color3.fromRGB(99,  88,  255),
    AccentHot  = Color3.fromRGB(130, 100, 255),
    AccentPink = Color3.fromRGB(200, 60,  180),
    ToggleOn   = Color3.fromRGB(88,  80,  255),
    ToggleOff  = Color3.fromRGB(45,  45,  72 ),
    Knob       = Color3.fromRGB(255, 255, 255),
    TxtMain    = Color3.fromRGB(240, 240, 255),
    TxtSub     = Color3.fromRGB(130, 130, 170),
    TxtDim     = Color3.fromRGB(70,  70,  105),
    Dot        = Color3.fromRGB(88,  80,  255),
    DotOff     = Color3.fromRGB(55,  55,  90 ),
    Sep        = Color3.fromRGB(30,  30,  52 ),
    HeaderBG   = Color3.fromRGB(16,  16,  28 ),
    Glow       = Color3.fromRGB(99,  88,  255),
    Black      = Color3.fromRGB(0,   0,   0  ),
    Success    = Color3.fromRGB(80,  220, 140),
    Danger     = Color3.fromRGB(220, 70,  70 ),

    -- Animation
    AnimSpeed = 8,   -- lerp speed
    ToggleKey = Enum.KeyCode.RightShift,
}

-- ══════════════════════════════════════════
--                  STATE
-- ══════════════════════════════════════════
local S = {
    -- Visibility
    Open    = true,
    OpenAnim= 1.0,   -- 0→1 animated

    -- Tabs: 1=Main 2=Player 3=Other 4=Settings
    Tab     = 1,
    TabAnim = {1, 0, 0, 0},  -- per-tab highlight anim

    -- Buttons [tab][btn] = bool
    Btns = {},

    -- Drag
    Drag       = false,
    DragOff    = Vector2.new(0,0),
    DragTarget = "window", -- "window" | "sidebar"

    -- Hover
    HovBtn  = nil,
    HovTab  = nil,
    HovClose= false,
    HovMin  = false,
    HovMB   = false,

    -- Settings
    MiniSide = "left",   -- "left" | "right"
    MiniY    = 0.3,      -- 0..1 vertical position

    -- Toggle anims [tab][btn] = 0..1
    ToggleAnim = {},

    -- Tick
    Tick = 0,
    Dt   = 0,

    -- Sidebar position (animated)
    SideX = 0, SideY = 0,

    -- Mini button
    MiniX = 0, MiniY2 = 0,
}

-- Init button states
for t = 1, 4 do
    S.Btns[t]       = {}
    S.ToggleAnim[t] = {}
    for b = 1, 9 do
        S.Btns[t][b]       = false
        S.ToggleAnim[t][b] = 0
    end
end

-- ══════════════════════════════════════════
--            DRAWING POOL
-- ══════════════════════════════════════════
local Pool    = {}
local PoolIdx = 0

local function GetDraw(type_)
    PoolIdx = PoolIdx + 1
    if not Pool[PoolIdx] or Pool[PoolIdx].__type ~= type_ then
        if Pool[PoolIdx] then Pool[PoolIdx]:Remove() end
        local d = Drawing.new(type_)
        d.__type = type_
        Pool[PoolIdx] = d
    end
    Pool[PoolIdx].Visible = false
    return Pool[PoolIdx]
end

local function FlushPool()
    for i = PoolIdx + 1, #Pool do
        Pool[i].Visible = false
    end
    PoolIdx = 0
end

-- ══════════════════════════════════════════
--            DRAW PRIMITIVES
-- ══════════════════════════════════════════
local function Sq(x,y,w,h, col, alpha, filled, thick)
    local d = GetDraw("Square")
    d.Position     = Vector2.new(x,y)
    d.Size         = Vector2.new(w,h)
    d.Color        = col or Color3.new(1,1,1)
    d.Transparency = alpha or 1
    d.Filled       = filled ~= false
    d.Thickness    = thick or 1
    d.Visible      = true
    return d
end

local function Ln(x1,y1,x2,y2, col, alpha, thick)
    local d = GetDraw("Line")
    d.From         = Vector2.new(x1,y1)
    d.To           = Vector2.new(x2,y2)
    d.Color        = col or Color3.new(1,1,1)
    d.Transparency = alpha or 1
    d.Thickness    = thick or 1
    d.Visible      = true
    return d
end

local function Ci(x,y,r, col, alpha, filled, thick)
    local d = GetDraw("Circle")
    d.Position     = Vector2.new(x,y)
    d.Radius       = r
    d.Color        = col or Color3.new(1,1,1)
    d.Transparency = alpha or 1
    d.Filled       = filled ~= false
    d.Thickness    = thick or 1
    d.Visible      = true
    return d
end

local function Tx(x,y, text, col, size, center, outline, outCol)
    local d = GetDraw("Text")
    d.Position     = Vector2.new(x,y)
    d.Text         = tostring(text)
    d.Color        = col or Color3.new(1,1,1)
    d.Size         = size or 14
    d.Center       = center or false
    d.Outline      = outline ~= false
    d.OutlineColor = outCol or Color3.new(0,0,0)
    d.Transparency = 1
    d.Visible      = true
    return d
end

local function Tri(a,b,c, col, alpha, filled, thick)
    local d = GetDraw("Triangle")
    d.PointA       = a
    d.PointB       = b
    d.PointC       = c
    d.Color        = col or Color3.new(1,1,1)
    d.Transparency = alpha or 1
    d.Filled       = filled ~= false
    d.Thickness    = thick or 1
    d.Visible      = true
    return d
end

-- ══════════════════════════════════════════
--              HELPERS
-- ══════════════════════════════════════════
local function MousePos()
    return UIS:GetMouseLocation()
end

local function Hover(x,y,w,h)
    local m = MousePos()
    return m.X>=x and m.X<=x+w and m.Y>=y and m.Y<=y+h
end

local function Lerp(a,b,t)
    return a + (b-a)*t
end

local function LerpColor(a,b,t)
    return Color3.new(
        Lerp(a.R,b.R,t),
        Lerp(a.G,b.G,t),
        Lerp(a.B,b.B,t)
    )
end

local function Clamp(v,mn,mx)
    return math.max(mn, math.min(mx, v))
end

local function EaseOut(t)
    return 1 - (1-t)^3
end

local function EaseInOut(t)
    return t < 0.5 and 4*t*t*t or 1 - (-2*t+2)^3/2
end

-- Rounded rect via lines + circles trick (approximate with segments)
local function RoundRect(x,y,w,h, col, alpha, r)
    r = r or 8
    -- fill interior
    Sq(x+r,   y,     w-r*2, h,     col, alpha)
    Sq(x,     y+r,   w,     h-r*2, col, alpha)
    -- corners (filled circles)
    Ci(x+r,   y+r,   r, col, alpha)
    Ci(x+w-r, y+r,   r, col, alpha)
    Ci(x+r,   y+h-r, r, col, alpha)
    Ci(x+w-r, y+h-r, r, col, alpha)
end

local function RoundRectBorder(x,y,w,h, col, alpha, r, thick)
    r = math.max(r or 8, 2)
    thick = thick or 1
    -- top, bottom
    Ln(x+r, y,     x+w-r, y,     col, alpha, thick)
    Ln(x+r, y+h,   x+w-r, y+h,   col, alpha, thick)
    -- left, right
    Ln(x,   y+r,   x,     y+h-r, col, alpha, thick)
    Ln(x+w, y+r,   x+w,   y+h-r, col, alpha, thick)
    -- corners (arcs approximated with circles outline)
    Ci(x+r,   y+r,   r, col, alpha, false, thick)
    Ci(x+w-r, y+r,   r, col, alpha, false, thick)
    Ci(x+r,   y+h-r, r, col, alpha, false, thick)
    Ci(x+w-r, y+h-r, r, col, alpha, false, thick)
end

-- ══════════════════════════════════════════
--           GLOW / SHADOW UTILS
-- ══════════════════════════════════════════
local function DrawGlow(x,y,w,h, col, layers, maxAlpha)
    layers   = layers   or 6
    maxAlpha = maxAlpha or 0.18
    for i = layers, 1, -1 do
        local pad = i * 2
        local a   = maxAlpha * (layers-i+1)/layers
        RoundRect(x-pad, y-pad, w+pad*2, h+pad*2, col, a, 10+pad)
    end
end

local function DrawShadow(x,y,w,h, layers)
    layers = layers or 5
    for i = layers, 1, -1 do
        local pad = i*2
        local a   = 0.25 * (layers-i+1)/layers
        RoundRect(x-pad+4, y-pad+4, w+pad*2, h+pad*2,
            CFG.Black, a, 10+pad)
    end
end

-- ══════════════════════════════════════════
--           ICON RENDERER
-- ══════════════════════════════════════════
-- Icons drawn with primitives (house, person, group, gear)
local function DrawIconHome(cx, cy, col, alpha)
    -- Roof
    Tri(Vector2.new(cx,cy-10),
        Vector2.new(cx-10,cy),
        Vector2.new(cx+10,cy),
        col, alpha, true)
    -- Body
    Sq(cx-7, cy, 14, 10, col, alpha)
    -- Door
    Sq(cx-3, cy+4, 6, 6, CFG.BG2, alpha)
end

local function DrawIconPerson(cx, cy, col, alpha)
    Ci(cx, cy-7, 5, col, alpha)
    -- Body arc
    Sq(cx-7, cy, 14, 2, col, alpha*0.4)
    -- Body
    RoundRect(cx-6, cy-1, 12, 10, col, alpha, 3)
end

local function DrawIconGroup(cx, cy, col, alpha)
    -- Two persons
    Ci(cx-5, cy-7, 4, col, alpha*0.7)
    Ci(cx+5, cy-7, 4, col, alpha*0.7)
    RoundRect(cx-10, cy-1, 9, 9, col, alpha*0.7, 2)
    RoundRect(cx+1,  cy-1, 9, 9, col, alpha*0.7, 2)
end

local function DrawIconGear(cx, cy, col, alpha, rot)
    rot = rot or 0
    local r1, r2 = 8, 5
    local teeth  = 6
    for i = 0, teeth-1 do
        local ang = rot + (i/teeth)*math.pi*2
        local ax  = cx + math.cos(ang)*(r1+3)
        local ay  = cy + math.sin(ang)*(r1+3)
        Sq(ax-2, ay-2, 4, 4, col, alpha*0.9)
    end
    Ci(cx, cy, r1, col, alpha*0.6, false, 3)
    Ci(cx, cy, r2, col, alpha)
end

local function DrawIconArrow(cx, cy, col, alpha, dir)
    -- dir: "right" | "left"
    if dir == "right" then
        Tri(Vector2.new(cx+5,cy),
            Vector2.new(cx-3,cy-6),
            Vector2.new(cx-3,cy+6),
            col, alpha, true)
    else
        Tri(Vector2.new(cx-5,cy),
            Vector2.new(cx+3,cy-6),
            Vector2.new(cx+3,cy+6),
            col, alpha, true)
    end
end

-- ══════════════════════════════════════════
--         TOGGLE DRAW (smooth)
-- ══════════════════════════════════════════
local function DrawToggle(x, y, anim)
    -- anim: 0=off, 1=on
    local TW, TH = 44, 24
    local col = LerpColor(CFG.ToggleOff, CFG.ToggleOn, anim)
    local glow= LerpColor(CFG.ToggleOff, CFG.Accent,   anim)

    -- Glow behind
    if anim > 0.05 then
        for i=3,1,-1 do
            RoundRect(x-i, y-i, TW+i*2, TH+i*2,
                glow, 0.06*anim*i, TH/2+i)
        end
    end

    -- Track
    RoundRect(x, y, TW, TH, col, 1, TH/2)

    -- Border
    RoundRectBorder(x, y, TW, TH,
        LerpColor(CFG.ToggleOff, CFG.AccentHot, anim),
        0.5+0.5*anim, TH/2, 1)

    -- Knob
    local knobX = Lerp(x+3, x+TW-TH+3, anim)
    local knobR  = TH/2 - 3
    -- Knob shadow
    Ci(knobX+knobR+1, y+TH/2+1, knobR, CFG.Black, 0.3)
    -- Knob body
    Ci(knobX+knobR, y+TH/2, knobR, CFG.Knob, 1)
    -- Knob shine
    Ci(knobX+knobR-2, y+TH/2-2, knobR*0.35,
        Color3.new(1,1,1), 0.4)
end

-- ══════════════════════════════════════════
--         MINI OPEN BUTTON
-- ══════════════════════════════════════════
local function GetMiniPos()
    local vp   = workspace.CurrentCamera.ViewportSize
    local mbx, mby
    if CFG.MiniSide == "left" then
        mbx = 8
    else
        mbx = vp.X - CFG.MBW - 8
    end
    mby = math.floor(vp.Y * S.MiniY - CFG.MBH/2)
    mby = Clamp(mby, 8, vp.Y - CFG.MBH - 8)
    return mbx, mby
end

local function DrawMiniButton()
    local a   = Clamp(1 - S.OpenAnim, 0, 1)
    if a < 0.02 then return end

    local mbx, mby = GetMiniPos()
    local W,  H    = CFG.MBW, CFG.MBH
    local tick      = S.Tick
    local pulse     = 0.7 + 0.3*math.sin(tick*3)

    -- Glow
    DrawGlow(mbx, mby, W, H,
        CFG.Accent, 5, 0.15*a*pulse)

    -- Background
    RoundRect(mbx, mby, W, H, CFG.BG2, a, 10)
    RoundRectBorder(mbx, mby, W, H,
        CFG.Accent, 0.6*a*pulse, 10, 1.5)

    -- Animated bar lines
    for i = 1, 3 do
        local ly = mby + H/2 - 10 + (i-1)*10
        local lw = i == 2 and W-10 or W-18
        local lx = mbx + (W-lw)/2
        Ln(lx, ly, lx+lw, ly, CFG.Accent, 0.8*a, 2)
    end

    -- Hover highlight
    if Hover(mbx, mby, W, H) then
        RoundRect(mbx, mby, W, H, CFG.AccentHot, 0.1*a, 10)
        S.HovMB = true
    else
        S.HovMB = false
    end
end

-- ══════════════════════════════════════════
--           SIDEBAR RENDERER
-- ══════════════════════════════════════════
local TabIcons = {
    [1] = "home",
    [2] = "person",
    [3] = "group",
    [4] = "gear",
}

local function DrawSidebar(a)
    if a < 0.02 then return end

    local WX = CFG.WX
    local WY = CFG.WY
    local WH = CFG.WH
    local SW = CFG.SW
    local SH = math.min(WH - 20, 320)

    -- Sidebar sits to the LEFT of main window
    local sx = WX - SW - CFG.SGap
    local sy = WY + WH/2 - SH/2

    S.SideX = sx
    S.SideY = sy

    -- Shadow
    DrawShadow(sx, sy, SW, SH, 4)

    -- Glow border
    local pulse = 0.5 + 0.5*math.sin(S.Tick*1.5)
    DrawGlow(sx, sy, SW, SH,
        CFG.Accent, 4, 0.12*a*pulse)

    -- Background
    RoundRect(sx, sy, SW, SH, CFG.BG2, a, 14)

    -- Border gradient (top=accent, bottom=pink)
    RoundRectBorder(sx, sy, SW, SH, CFG.Accent, 0.55*a, 14, 1.5)

    -- Separator line inside
    Ln(sx+12, sy+10, sx+SW-12, sy+10,
        CFG.Sep, 0.6*a, 1)

    -- Tab buttons
    local btnH  = 52
    local btnPad= 8
    local totalH= 4*(btnH+btnPad) - btnPad
    local startY= sy + SH/2 - totalH/2

    for i = 1, 4 do
        local bx = sx + 8
        local by = startY + (i-1)*(btnH+btnPad)
        local bw = SW - 16

        local isActive = S.Tab == i
        local isHover  = Hover(bx, by, bw, btnH)

        -- Animate tab indicator
        local target = isActive and 1 or 0
        S.TabAnim[i] = Lerp(S.TabAnim[i], target,
            S.Dt * CFG.AnimSpeed)
        local ta = S.TabAnim[i]

        -- Button glow (active)
        if ta > 0.05 then
            for g = 3,1,-1 do
                RoundRect(bx-g, by-g, bw+g*2, btnH+g*2,
                    CFG.Accent, 0.07*ta*a, 12+g)
            end
        end

        -- Button background
        local btnCol = LerpColor(CFG.BG3,
            LerpColor(CFG.Panel, CFG.Accent, ta*0.25),
            isHover and 0.5 or ta)
        RoundRect(bx, by, bw, btnH, btnCol, a, 10)

        -- Active left bar
        if ta > 0.02 then
            RoundRect(bx, by+6, 3, btnH-12,
                CFG.Accent, ta*a, 2)
        end

        -- Active border
        if ta > 0.02 then
            RoundRectBorder(bx, by, bw, btnH,
                CFG.Accent, ta*0.7*a, 10, 1)
        end

        -- Icon
        local icx = bx + bw/2
        local icy = by + btnH/2
        local icCol = LerpColor(CFG.TxtDim,
            LerpColor(CFG.TxtSub, CFG.Accent, ta),
            isHover and 0.6 or ta)

        if i == 1 then DrawIconHome  (icx, icy, icCol, a)
        elseif i==2 then DrawIconPerson(icx, icy, icCol, a)
        elseif i==3 then DrawIconGroup (icx, icy, icCol, a)
        elseif i==4 then
            DrawIconGear(icx, icy, icCol, a,
                S.Tick * 0.4)
        end

        -- Active dot indicator
        if ta > 0.02 then
            Ci(sx+SW-10, by+btnH/2, 3,
                CFG.Accent, ta*a)
        end

        S.HovTab = isHover and i or S.HovTab
    end

    -- Bottom decoration
    Ln(sx+12, sy+SH-10, sx+SW-12, sy+SH-10,
        CFG.Sep, 0.6*a, 1)

    -- Version dot
    Ci(sx+SW/2, sy+SH-5, 2, CFG.Accent, 0.5*a)
end

-- ══════════════════════════════════════════
--         SETTINGS TAB CONTENT
-- ══════════════════════════════════════════
local function DrawSettingsContent(cx, cy, cw, ch, a)
    local px, py = cx+16, cy+16

    -- Title
    Tx(px, py, "Mini Button Settings",
        CFG.TxtMain, 15, false, true)
    py = py + 30

    Ln(cx+8, py, cx+cw-8, py, CFG.Sep, 0.8, 1)
    py = py + 14

    -- Side chooser
    Tx(px, py, "Position Side:", CFG.TxtSub, 12, false, true)
    py = py + 22

    local optW = (cw-48)/2
    for si, side in ipairs({"left","right"}) do
        local ox = px + (si-1)*(optW+16)
        local isSelected = CFG.MiniSide == side
        local isHover    = Hover(ox, py, optW, 34)

        RoundRect(ox, py, optW, 34,
            isSelected and CFG.Accent or
            (isHover and CFG.BG3 or CFG.Panel),
            a, 8)
        RoundRectBorder(ox, py, optW, 34,
            isSelected and CFG.AccentHot or CFG.PanelBord,
            (isSelected and 0.8 or 0.4)*a, 8, 1)

        Tx(ox+optW/2, py+10,
            side:sub(1,1):upper()..side:sub(2),
            isSelected and CFG.TxtMain or CFG.TxtSub,
            13, true, true)
    end
    py = py + 50

    -- Vertical position slider
    Tx(px, py, "Vertical Position:", CFG.TxtSub, 12, false, true)
    Tx(cx+cw-px, py,
        string.format("%.0f%%", S.MiniY*100),
        CFG.Accent, 12, true, true)
    py = py + 22

    local slW = cw - 32
    -- Track
    RoundRect(px, py+8, slW, 6, CFG.Panel, a, 3)
    RoundRectBorder(px, py+8, slW, 6, CFG.PanelBord, 0.6*a, 3, 1)
    -- Fill
    local fillW = math.max(0, math.floor(S.MiniY*slW))
    if fillW > 0 then
        RoundRect(px, py+8, fillW, 6, CFG.Accent, a, 3)
    end
    -- Handle
    local hx = px + fillW
    for g=3,1,-1 do
        Ci(hx, py+11, 10+g, CFG.Accent, 0.06*a)
    end
    Ci(hx, py+11, 10, CFG.BG2, a)
    Ci(hx, py+11, 10, CFG.Accent, 0.7*a, false, 2)
    Ci(hx, py+11, 4,  CFG.Accent, a)
    py = py + 36

    Ln(cx+8, py, cx+cw-8, py, CFG.Sep, 0.8, 1)
    py = py + 14

    -- Keybind info
    Tx(px, py, "Toggle Key", CFG.TxtSub, 12, false, true)
    py = py + 22
    RoundRect(px, py, 80, 28, CFG.Panel, a, 6)
    RoundRectBorder(px, py, 80, 28, CFG.PanelBord, 0.7*a, 6, 1)
    Tx(px+40, py+8, "RShift", CFG.Accent, 12, true, true)
    py = py + 46

    -- Stats
    Tx(px, py, "Active Toggles per Tab:", CFG.TxtSub, 12, false, true)
    py = py + 22
    local tabNames = {"Main","Player","Other","Settings"}
    for ti = 1, 3 do
        local cnt = 0
        for _,v in pairs(S.Btns[ti]) do if v then cnt=cnt+1 end end
        local barW = cnt / 9 * (cw-80)
        RoundRect(px, py, cw-80, 12, CFG.Panel, a, 6)
        if barW > 0 then
            RoundRect(px, py, barW, 12, CFG.Accent, 0.8*a, 6)
        end
        Tx(px+cw-72, py-1, tabNames[ti]..": "..cnt.."/9",
            CFG.TxtSub, 11, false, true)
        py = py + 20
    end
end

-- ══════════════════════════════════════════
--         BUTTONS CONTENT RENDERER
-- ══════════════════════════════════════════
local function DrawButtons(tab, cx, cy, cw, ch, a)
    local itemH  = 44
    local itemPY = 6
    local startY = cy + 8

    for i = 1, 9 do
        local ix = cx + 12
        local iy = startY + (i-1)*(itemH+itemPY)
        local iw = cw - 24

        local isOn    = S.Btns[tab][i]
        local isHov   = Hover(ix, iy, iw, itemH)
        local ta      = S.ToggleAnim[tab][i]

        -- Animate toggle
        S.ToggleAnim[tab][i] = Lerp(ta, isOn and 1 or 0,
            S.Dt * CFG.AnimSpeed * 1.5)
        ta = S.ToggleAnim[tab][i]

        -- Item background hover glow
        if isHov then
            RoundRect(ix, iy, iw, itemH, CFG.Accent, 0.04*a, 8)
        end
        if ta > 0.02 then
            RoundRect(ix, iy, iw, itemH, CFG.Accent, 0.04*ta*a, 8)
        end

        -- Item background
        RoundRect(ix, iy, iw, itemH,
            LerpColor(CFG.Panel,
                Color3.fromRGB(22,20,42), isHov and 0.5 or ta*0.3),
            a, 8)

        -- Border
        local bordCol = LerpColor(CFG.Sep,
            LerpColor(CFG.PanelBord, CFG.Accent, ta),
            isHov and 0.4 or ta*0.6)
        RoundRectBorder(ix, iy, iw, itemH, bordCol, 0.8*a, 8, 1)

        -- Dot indicator
        local dotCol = LerpColor(CFG.DotOff, CFG.Dot, ta)
        Ci(ix+22, iy+itemH/2, 5, dotCol, a)
        if ta > 0.02 then
            Ci(ix+22, iy+itemH/2, 8, dotCol, 0.15*ta*a, false, 1)
        end

        -- Label
        Tx(ix+38, iy+itemH/2-8,
            string.format("TEST-%d", i),
            LerpColor(CFG.TxtSub, CFG.TxtMain, 0.3+ta*0.7),
            14, false, true)

        -- Status sub-label
        if ta > 0.05 then
            Tx(ix+39, iy+itemH/2+5,
                "Enabled",
                LerpColor(CFG.TxtDim, CFG.Success, ta),
                9, false, true)
        end

        -- Toggle widget
        local tw = 44
        local tx2 = ix+iw-tw-14
        local ty2 = iy+itemH/2-12
        DrawToggle(tx2, ty2, ta)

        if isHov then S.HovBtn = i end

        -- Separator (not last)
        if i < 9 then
            Ln(ix+20, iy+itemH+itemPY/2,
               ix+iw-20, iy+itemH+itemPY/2,
               CFG.Sep, 0.5*a, 1)
        end
    end
end

-- ══════════════════════════════════════════
--             MAIN WINDOW
-- ══════════════════════════════════════════
local function DrawWindow(a)
    if a < 0.02 then return end

    local X,Y = CFG.WX, CFG.WY
    local W,H = CFG.WW, CFG.WH
    local tick  = S.Tick
    local pulse  = 0.6+0.4*math.sin(tick*2)

    -- Shadow
    DrawShadow(X, Y, W, H, 6)

    -- Outer glow
    DrawGlow(X, Y, W, H, CFG.Accent, 5, 0.14*a*pulse)

    -- Background
    RoundRect(X, Y, W, H, CFG.BG, a, 14)

    -- Subtle grid
    for gx=0,W,28 do
        Ln(X+gx, Y+50, X+gx, Y+H,
           Color3.fromRGB(25,25,42), 0.18*a)
    end
    for gy=50,H,28 do
        Ln(X, Y+gy, X+W, Y+gy,
           Color3.fromRGB(25,25,42), 0.18*a)
    end

    -- Main border
    local rainbow = Color3.fromHSV((tick*0.07)%1, 0.6, 1)
    RoundRectBorder(X, Y, W, H,
        LerpColor(CFG.Accent, rainbow, 0.3),
        0.6*a, 14, 1.5)

    -- ── HEADER ──────────────────────────────
    local HH = 60
    RoundRect(X, Y, W, HH, CFG.HeaderBG, a, 14)
    Sq(X, Y+HH-14, W, 14, CFG.HeaderBG, a) -- flatten bottom
    Ln(X, Y+HH, X+W, Y+HH, CFG.Sep, 0.9*a, 1)

    -- Accent stripe at very top
    RoundRect(X, Y, W, 3,
        LerpColor(CFG.Accent, CFG.AccentPink, 0.4), a, 2)

    -- Logo icon  (S-shape placeholder)
    local lx, ly = X+20, Y+15
    RoundRect(lx, ly, 30, 30, CFG.Accent, 0.9*a, 6)
    -- S letter
    Tx(lx+15, ly+7, "S", CFG.TxtMain, 16, true, false)

    -- Title
    Tx(X+60, Y+13, "SCRIPT", CFG.TxtMain, 19, false, true)
    Tx(X+60+68, Y+13, "HUB", CFG.Accent, 19, false, true)
    Tx(X+61, Y+35, "PREMIUM SCRIPT MENU",
        CFG.TxtSub, 10, false, true)

    -- Header right buttons
    local bSize  = 28
    local bGap   = 6
    local b3x    = X+W-bSize-12
    local b2x    = b3x-bSize-bGap
    local b1x    = b2x-bSize-bGap
    local bY     = Y+16

    -- Close
    local hClose = Hover(b3x, bY, bSize, bSize)
    RoundRect(b3x, bY, bSize, bSize,
        hClose and CFG.Danger or CFG.BG3,
        (hClose and 0.95 or 0.7)*a, 7)
    RoundRectBorder(b3x, bY, bSize, bSize,
        hClose and CFG.Danger or CFG.PanelBord,
        0.6*a, 7, 1)
    Tx(b3x+14, bY+7, "×", CFG.TxtMain, 15, true, true)

    -- Maximize (decorative)
    local hMax = Hover(b2x, bY, bSize, bSize)
    RoundRect(b2x, bY, bSize, bSize,
        hMax and CFG.BG3 or CFG.Panel,
        (hMax and 0.95 or 0.6)*a, 7)
    RoundRectBorder(b2x, bY, bSize, bSize,
        CFG.PanelBord, 0.5*a, 7, 1)
    Sq(b2x+8, bY+8, 12, 12, CFG.TxtSub, 0.7*a, false, 1.5)

    -- Minimize
    local hMin = Hover(b1x, bY, bSize, bSize)
    RoundRect(b1x, bY, bSize, bSize,
        hMin and CFG.BG3 or CFG.Panel,
        (hMin and 0.95 or 0.6)*a, 7)
    RoundRectBorder(b1x, bY, bSize, bSize,
        CFG.PanelBord, 0.5*a, 7, 1)
    Ln(b1x+7, bY+bSize/2, b1x+bSize-7, bY+bSize/2,
       CFG.TxtSub, 0.8*a, 2)

    S.HovClose = hClose
    S.HovMin   = hMin

    -- ── TAB NAME HINT (current) ──────────────
    local tabNames = {"Main","Player","Other","Settings"}
    local activeTab = tabNames[S.Tab]
    Tx(X+W/2, Y+HH-16, "▸  "..activeTab,
        CFG.TxtSub, 11, true, true)

    -- ── CONTENT ─────────────────────────────
    local CX = X+12
    local CY = Y+HH+8
    local CW = W-24
    local CH = H-HH-20

    -- Content bg
    RoundRect(CX, CY, CW, CH, CFG.Panel, 0.5*a, 10)
    RoundRectBorder(CX, CY, CW, CH, CFG.PanelBord, 0.6*a, 10, 1)

    if S.Tab == 4 then
        DrawSettingsContent(CX, CY, CW, CH, a)
    else
        DrawButtons(S.Tab, CX, CY, CW, CH, a)
    end

    -- ── FOOTER ──────────────────────────────
    local FY = Y+H-22
    Ln(X, FY, X+W, FY, CFG.Sep, 0.7*a, 1)

    -- Active count
    local cnt = 0
    if S.Tab < 4 then
        for _,v in pairs(S.Btns[S.Tab]) do if v then cnt=cnt+1 end end
    end
    Tx(X+16, FY+5,
        cnt > 0 and ("● "..cnt.." active") or "○ None active",
        cnt>0 and CFG.Success or CFG.TxtDim,
        10, false, true)

    -- Scan line anim
    local scanY = CY + ((tick*55)%CH)
    Ln(CX, scanY, CX+CW, scanY, CFG.Accent, 0.03*a, 1)

    -- Right footer
    Tx(X+W-16, FY+5, "RShift = Toggle",
        CFG.TxtDim, 10, true, true)
end

-- ══════════════════════════════════════════
--            MAIN RENDER LOOP
-- ══════════════════════════════════════════
local function Render(dt)
    S.Tick = S.Tick + dt
    S.Dt   = dt

    -- Animate open/close
    local targetAnim = S.Open and 1 or 0
    S.OpenAnim = Lerp(S.OpenAnim, targetAnim, dt*CFG.AnimSpeed)

    local a = EaseOut(S.OpenAnim)

    -- Reset hover
    S.HovBtn  = nil
    S.HovTab  = nil

    -- Draw order: shadow, sidebar, window, mini
    DrawSidebar(a)
    DrawWindow(a)
    DrawMiniButton()

    FlushPool()
end

-- ══════════════════════════════════════════
--            INPUT HANDLING
-- ══════════════════════════════════════════
local function GetButtonAtMouse()
    if not S.Open or S.OpenAnim < 0.3 then return nil end
    local X   = CFG.WX
    local Y   = CFG.WY
    local W   = CFG.WW
    local H   = CFG.WH
    local HH  = 60
    local CX  = X+12
    local CY  = Y+HH+8
    local CW  = W-24

    local itemH  = 44
    local itemPY = 6

    for i = 1, 9 do
        local ix = CX+12
        local iy = CY+8 + (i-1)*(itemH+itemPY)
        local iw = CW-24
        if Hover(ix, iy, iw, itemH) then
            return i
        end
    end
    return nil
end

local function GetTabAtMouse()
    if S.OpenAnim < 0.3 then return nil end
    local WX = CFG.WX
    local WY = CFG.WY
    local WH = CFG.WH
    local SW = CFG.SW
    local SH = math.min(WH-20, 320)
    local sx  = WX - SW - CFG.SGap
    local sy  = WY + WH/2 - SH/2

    local btnH  = 52
    local btnPad= 8
    local totalH= 4*(btnH+btnPad) - btnPad
    local startY= sy + SH/2 - totalH/2

    for i = 1, 4 do
        local bx = sx+8
        local by = startY + (i-1)*(btnH+btnPad)
        local bw = SW-16
        if Hover(bx, by, bw, btnH) then
            return i
        end
    end
    return nil
end

local function IsOnCloseBtn()
    local X,Y = CFG.WX, CFG.WY
    local W   = CFG.WW
    return Hover(X+W-40, Y+16, 28, 28)
end

local function IsOnHeader()
    return Hover(CFG.WX, CFG.WY, CFG.WW-110, 60)
end

-- Settings slider interaction
local function GetSliderValue(mx)
    local X  = CFG.WX
    local W  = CFG.WW
    local CX = X+12
    local CW = W-24
    local px = CX+16
    local slW= CW-32
    local v  = (mx - px) / slW
    return Clamp(v, 0, 1)
end

local DragSlider = false
local DragSideOpts = false

UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end

    -- Toggle key
    if inp.KeyCode == CFG.ToggleKey then
        S.Open = not S.Open
        return
    end

    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    local m = MousePos()

    -- Mini button
    if not S.Open then
        local mbx, mby = GetMiniPos()
        if Hover(mbx, mby, CFG.MBW, CFG.MBH) then
            S.Open = true
            return
        end
        return
    end

    if S.OpenAnim < 0.3 then return end

    -- Close button
    if IsOnCloseBtn() then
        S.Open = false
        return
    end

    -- Settings tab interactions
    if S.Tab == 4 then
        local X   = CFG.WX
        local Y   = CFG.WY
        local W   = CFG.WW
        local HH  = 60
        local CX  = X+12
        local CY  = Y+HH+8
        local CW  = W-24
        local px  = CX+16
        local py  = CY+16+30+14+22

        -- Side options
        local optW= (CW-48)/2
        for si, side in ipairs({"left","right"}) do
            local ox = px + (si-1)*(optW+16)
            if Hover(ox, py, optW, 34) then
                CFG.MiniSide = side
                return
            end
        end
        py = py + 50

        -- Vertical slider
        local slY = py + 8
        if Hover(px-10, slY-10, CW-32+20, 30) then
            DragSlider = true
            S.MiniY = GetSliderValue(m.X)
            return
        end
    end

    -- Tab click
    local tab = GetTabAtMouse()
    if tab then
        S.Tab = tab
        return
    end

    -- Button click
    local btn = GetButtonAtMouse()
    if btn and S.Tab < 4 then
        S.Btns[S.Tab][btn] = not S.Btns[S.Tab][btn]
        return
    end

    -- Header drag
    if IsOnHeader() then
        S.Drag    = true
        S.DragOff = Vector2.new(m.X - CFG.WX, m.Y - CFG.WY)
    end
end)

UIS.InputChanged:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseMovement then
        local m = MousePos()
        if S.Drag then
            CFG.WX = m.X - S.DragOff.X
            CFG.WY = m.Y - S.DragOff.Y
        end
        if DragSlider then
            local X  = CFG.WX
            local W  = CFG.WW
            local CX = X+12
            local CW = W-24
            local px = CX+16
            local slW= CW-32
            S.MiniY = Clamp((m.X-px)/slW, 0, 1)
        end
    end
end)

UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        S.Drag      = false
        DragSlider  = false
    end
end)

-- ══════════════════════════════════════════
--              START
-- ══════════════════════════════════════════
RS.RenderStepped:Connect(function(dt)
    Render(math.min(dt, 0.05))
end)

print("╔══════════════════════════════════╗")
print("║     Script Hub UI v3.0 Loaded   ║")
print("║  RightShift — Toggle Menu        ║")
print("╚══════════════════════════════════╝")
