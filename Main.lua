-- LUXURY HUB v9 - Rounded Design + Real Functions
local UIS = game:GetService("UserInputService")
local RS  = game:GetService("RunService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local VP = workspace.CurrentCamera.ViewportSize

-- COLORS
local BG      = Color3.fromRGB(18,19,28)
local BGLITE  = Color3.fromRGB(24,26,38)
local CARD    = Color3.fromRGB(28,30,45)
local CARDON  = Color3.fromRGB(44,42,78)
local CARDHI  = Color3.fromRGB(36,39,58)
local NEON    = Color3.fromRGB(120,110,255)
local NEONDIM = Color3.fromRGB(75,70,150)
local WHITE   = Color3.fromRGB(255,255,255)
local BLACK   = Color3.fromRGB(8,8,12)
local BORDER  = Color3.fromRGB(52,56,86)
local TRACK   = Color3.fromRGB(55,58,85)
local TXHI    = Color3.fromRGB(245,246,255)
local TXMID   = Color3.fromRGB(150,155,185)
local TXLOW   = Color3.fromRGB(100,105,135)
local TXFAINT = Color3.fromRGB(70,73,100)
local GREEN   = Color3.fromRGB(80,220,150)
local RED     = Color3.fromRGB(240,100,100)
local ORANGE  = Color3.fromRGB(255,160,60)

-- LAYOUT
local ROW_H  = 44
local GAP    = 8
local HEADER = 54
local FOOTER = 28
local PAD    = 14
local NAV_W  = 56
local NAV_GAP= 16

local PW = math.min(460, VP.X * 0.52)
local PH = math.min(
    HEADER + (9*(ROW_H+GAP)-GAP) + PAD*2 + FOOTER + PAD,
    VP.Y * 0.92
)
local PX = math.floor((VP.X - (NAV_W+NAV_GAP+PW))/2 + NAV_W + NAV_GAP)
local PY = math.floor((VP.Y - PH)/2)

local MBW, MBH = 36, 80

-- ══════════════════════════════════════════════
-- TAB DEFINITIONS + FUNCTIONS
-- ══════════════════════════════════════════════
local TABS = {
    {
        name = "Main",
        items = {
            {
                label = "Infinite Jump",
                desc  = "Jump while in air",
                state = false,
                conn  = nil,
                enable = function(item)
                    item.conn = UIS.JumpRequest:Connect(function()
                        if LP.Character then
                            local hum = LP.Character:FindFirstChildOfClass("Humanoid")
                            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                        end
                    end)
                end,
                disable = function(item)
                    if item.conn then item.conn:Disconnect() item.conn=nil end
                end,
            },
            {
                label = "Speed Boost",
                desc  = "WalkSpeed x2.5",
                state = false,
                enable = function()
                    if LP.Character then
                        local h = LP.Character:FindFirstChildOfClass("Humanoid")
                        if h then h.WalkSpeed = 40 end
                    end
                end,
                disable = function()
                    if LP.Character then
                        local h = LP.Character:FindFirstChildOfClass("Humanoid")
                        if h then h.WalkSpeed = 16 end
                    end
                end,
            },
            {
                label = "Anti-AFK",
                desc  = "Prevent kick",
                state = false,
                conn  = nil,
                enable = function(item)
                    item.conn = LP.Idled:Connect(function()
                        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                        task.wait()
                        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    end)
                end,
                disable = function(item)
                    if item.conn then item.conn:Disconnect() item.conn=nil end
                end,
            },
            {
                label = "Fly",
                desc  = "Free fly mode",
                state = false,
                conn  = nil,
                bv    = nil,
                enable = function(item)
                    local char = LP.Character
                    if not char then return end
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if not root then return end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.PlatformStand = true end
                    local bv = Instance.new("BodyVelocity", root)
                    bv.Velocity = Vector3.new(0,0,0)
                    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                    item.bv = bv
                    local bg = Instance.new("BodyGyro", root)
                    bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
                    bg.D = 100
                    item.bg = bg
                    item.conn = RS.RenderStepped:Connect(function()
                        local cam = workspace.CurrentCamera
                        local spd = 40
                        local dir = Vector3.new(0,0,0)
                        if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+cam.CFrame.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-cam.CFrame.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-cam.CFrame.RightVector end
                        if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+cam.CFrame.RightVector end
                        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
                        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.new(0,1,0) end
                        if dir.Magnitude > 0 then dir = dir.Unit end
                        bv.Velocity = dir * spd
                        bg.CFrame = cam.CFrame
                    end)
                end,
                disable = function(item)
                    if item.conn then item.conn:Disconnect() item.conn=nil end
                    if item.bv then item.bv:Destroy() item.bv=nil end
                    if item.bg then item.bg:Destroy() item.bg=nil end
                    local char = LP.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum.PlatformStand = false end
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            for _,v in ipairs(root:GetChildren()) do
                                if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
                            end
                        end
                    end
                end,
            },
            {
                label = "No Clip",
                desc  = "Walk through walls",
                state = false,
                conn  = nil,
                enable = function(item)
                    item.conn = RS.Stepped:Connect(function()
                        if LP.Character then
                            for _,p in ipairs(LP.Character:GetDescendants()) do
                                if p:IsA("BasePart") then
                                    p.CanCollide = false
                                end
                            end
                        end
                    end)
                end,
                disable = function(item)
                    if item.conn then item.conn:Disconnect() item.conn=nil end
                    if LP.Character then
                        for _,p in ipairs(LP.Character:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = true end
                        end
                    end
                end,
            },
            {label="TEST-6",  desc="Feature slot 6",  state=false, enable=function()end, disable=function()end},
            {label="TEST-7",  desc="Feature slot 7",  state=false, enable=function()end, disable=function()end},
            {label="TEST-8",  desc="Feature slot 8",  state=false, enable=function()end, disable=function()end},
            {label="TEST-9",  desc="Feature slot 9",  state=false, enable=function()end, disable=function()end},
        }
    },
    {
        name = "Player",
        items = {
            {
                label = "God Mode",
                desc  = "Max health always",
                state = false,
                conn  = nil,
                enable = function(item)
                    item.conn = RS.Heartbeat:Connect(function()
                        if LP.Character then
                            local h = LP.Character:FindFirstChildOfClass("Humanoid")
                            if h then h.Health = h.MaxHealth end
                        end
                    end)
                end,
                disable = function(item)
                    if item.conn then item.conn:Disconnect() item.conn=nil end
                end,
            },
            {
                label = "High Jump",
                desc  = "JumpPower x3",
                state = false,
                enable = function()
                    if LP.Character then
                        local h = LP.Character:FindFirstChildOfClass("Humanoid")
                        if h then h.JumpPower = 150 end
                    end
                end,
                disable = function()
                    if LP.Character then
                        local h = LP.Character:FindFirstChildOfClass("Humanoid")
                        if h then h.JumpPower = 50 end
                    end
                end,
            },
            {
                label = "Invisible",
                desc  = "Hide local char",
                state = false,
                enable = function()
                    if LP.Character then
                        for _,p in ipairs(LP.Character:GetDescendants()) do
                            if p:IsA("BasePart") or p:IsA("Decal") then
                                p.Transparency = 1
                            end
                        end
                    end
                end,
                disable = function()
                    if LP.Character then
                        for _,p in ipairs(LP.Character:GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.Transparency = 0
                            elseif p:IsA("Decal") then
                                p.Transparency = 0
                            end
                        end
                    end
                end,
            },
            {
                label = "Freeze",
                desc  = "Stop character",
                state = false,
                enable = function()
                    if LP.Character then
                        local root = LP.Character:FindFirstChild("HumanoidRootPart")
                        if root then root.Anchored = true end
                    end
                end,
                disable = function()
                    if LP.Character then
                        local root = LP.Character:FindFirstChild("HumanoidRootPart")
                        if root then root.Anchored = false end
                    end
                end,
            },
            {
                label = "Reach",
                desc  = "Long tool reach",
                state = false,
                enable = function()
                    if LP.Character then
                        local tool = LP.Character:FindFirstChildOfClass("Tool")
                        if tool and tool.Handle then
                            tool.Handle.Size = Vector3.new(20,1,1)
                        end
                    end
                end,
                disable = function()
                    if LP.Character then
                        local tool = LP.Character:FindFirstChildOfClass("Tool")
                        if tool and tool.Handle then
                            tool.Handle.Size = Vector3.new(1,1,1)
                        end
                    end
                end,
            },
            {label="TEST-6",  desc="Player slot 6",   state=false, enable=function()end, disable=function()end},
            {label="TEST-7",  desc="Player slot 7",   state=false, enable=function()end, disable=function()end},
            {label="TEST-8",  desc="Player slot 8",   state=false, enable=function()end, disable=function()end},
            {label="TEST-9",  desc="Player slot 9",   state=false, enable=function()end, disable=function()end},
        }
    },
    {
        name = "Other",
        items = {
            {
                label = "Full Bright",
                desc  = "Max ambient light",
                state = false,
                old   = nil,
                enable = function(item)
                    item.old = {
                        amb  = game.Lighting.Ambient,
                        oamb = game.Lighting.OutdoorAmbient,
                        brit = game.Lighting.Brightness,
                    }
                    game.Lighting.Ambient         = Color3.fromRGB(255,255,255)
                    game.Lighting.OutdoorAmbient  = Color3.fromRGB(255,255,255)
                    game.Lighting.Brightness      = 2
                end,
                disable = function(item)
                    if item.old then
                        game.Lighting.Ambient        = item.old.amb
                        game.Lighting.OutdoorAmbient = item.old.oamb
                        game.Lighting.Brightness     = item.old.brit
                    end
                end,
            },
            {
                label = "Time: Noon",
                desc  = "Set time to 12",
                state = false,
                enable = function()
                    game.Lighting.ClockTime = 12
                end,
                disable = function()
                    game.Lighting.ClockTime = 12
                end,
            },
            {
                label = "Fog Remove",
                desc  = "Clear all fog",
                state = false,
                old   = nil,
                enable = function(item)
                    item.old = {
                        start = game.Lighting.FogStart,
                        ende  = game.Lighting.FogEnd,
                    }
                    game.Lighting.FogStart = 0
                    game.Lighting.FogEnd   = 1e6
                end,
                disable = function(item)
                    if item.old then
                        game.Lighting.FogStart = item.old.start
                        game.Lighting.FogEnd   = item.old.ende
                    end
                end,
            },
            {
                label = "Chat Spam",
                desc  = "Repeat chat msg",
                state = false,
                conn  = nil,
                enable = function(item)
                    item.conn = task.spawn(function()
                        while item.state do
                            game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                                and pcall(function()
                                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("hi","All")
                                end)
                            task.wait(3)
                        end
                    end)
                end,
                disable = function(item)
                    item.state = false
                end,
            },
            {
                label = "ESP Players",
                desc  = "Show player names",
                state = false,
                conns = {},
                bills = {},
                enable = function(item)
                    for _,pl in ipairs(Players:GetPlayers()) do
                        if pl~=LP and pl.Character then
                            local root=pl.Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                local bb=Instance.new("BillboardGui",root)
                                bb.Size=UDim2.new(0,80,0,30)
                                bb.StudsOffset=Vector3.new(0,3,0)
                                local lbl=Instance.new("TextLabel",bb)
                                lbl.Size=UDim2.new(1,0,1,0)
                                lbl.BackgroundTransparency=1
                                lbl.TextColor3=Color3.fromRGB(120,110,255)
                                lbl.TextStrokeTransparency=0
                                lbl.Text=pl.Name
                                lbl.Font=Enum.Font.GothamBold
                                lbl.TextSize=14
                                table.insert(item.bills, bb)
                            end
                        end
                    end
                end,
                disable = function(item)
                    for _,b in ipairs(item.bills) do pcall(function() b:Destroy() end) end
                    item.bills={}
                end,
            },
            {label="TEST-6",  desc="Other slot 6",    state=false, enable=function()end, disable=function()end},
            {label="TEST-7",  desc="Other slot 7",    state=false, enable=function()end, disable=function()end},
            {label="TEST-8",  desc="Other slot 8",    state=false, enable=function()end, disable=function()end},
            {label="TEST-9",  desc="Other slot 9",    state=false, enable=function()end, disable=function()end},
        }
    },
}

local function ToggleItem(tabIdx, itemIdx)
    local item = TABS[tabIdx].items[itemIdx]
    if not item then return end
    item.state = not item.state
    if item.state then
        pcall(item.enable, item)
    else
        pcall(item.disable, item)
    end
end

-- SETTINGS
local Open     = true
local CurTab   = 1
local Drag     = false
local DragOff  = Vector2.new(0,0)
local MiniSide = "left"
local MiniYPos = 0.32
local DragSlider = false

-- ══════════════════════════════════════════════
-- DRAWING OBJECTS
-- ══════════════════════════════════════════════
local allObjs = {}
local function NewSq()
    local d=Drawing.new("Square"); d.Filled=true; d.Visible=false; d.Thickness=1
    table.insert(allObjs,d); return d
end
local function NewLn()
    local d=Drawing.new("Line"); d.Visible=false; d.Thickness=1
    table.insert(allObjs,d); return d
end
local function NewCi()
    local d=Drawing.new("Circle"); d.Filled=true; d.NumSides=24; d.Visible=false; d.Thickness=1
    table.insert(allObjs,d); return d
end
local function NewTx()
    local d=Drawing.new("Text"); d.Outline=true; d.OutlineColor=BLACK; d.Size=14; d.Visible=false
    table.insert(allObjs,d); return d
end

local function HideAll()
    for _,d in ipairs(allObjs) do d.Visible=false end
end

local function S(d,x,y,w,h,c)
    d.Position=Vector2.new(x,y); d.Size=Vector2.new(w,h)
    d.Color=c; d.Filled=true; d.Visible=true
end
local function L(d,x1,y1,x2,y2,c,th)
    d.From=Vector2.new(x1,y1); d.To=Vector2.new(x2,y2)
    d.Color=c; d.Thickness=th or 1; d.Visible=true
end
local function CI(d,x,y,r,c,f,th)
    d.Position=Vector2.new(x,y); d.Radius=r; d.Color=c
    d.Filled=f~=false; d.Thickness=th or 1; d.Visible=true
end
local function TX(d,x,y,t,c,sz,ctr)
    d.Position=Vector2.new(x,y); d.Text=tostring(t); d.Color=c
    d.Size=sz or 14; d.Center=ctr or false; d.Visible=true
end

-- ROUNDED RECT using circles + rects
local function RR(bg, corners, borders, x,y,w,h, col, bCol, r, bth)
    r = math.min(r or 12, w/2, h/2)
    -- Fill
    S(bg[1], x+r, y,   w-r*2, h,   col)
    S(bg[2], x,   y+r, r,     h-r*2, col)
    S(bg[3], x+w-r, y+r, r,   h-r*2, col)
    CI(corners[1], x+r,   y+r,   r, col, true)
    CI(corners[2], x+w-r, y+r,   r, col, true)
    CI(corners[3], x+r,   y+h-r, r, col, true)
    CI(corners[4], x+w-r, y+h-r, r, col, true)
    -- Border lines (4 sides)
    if bCol and borders then
        L(borders[1], x+r,   y,   x+w-r, y,   bCol, bth or 1.5)
        L(borders[2], x+r,   y+h, x+w-r, y+h, bCol, bth or 1.5)
        L(borders[3], x,   y+r,   x,   y+h-r, bCol, bth or 1.5)
        L(borders[4], x+w, y+r,   x+w, y+h-r, bCol, bth or 1.5)
        -- corner arcs (circle outlines)
        CI(borders[5], x+r,   y+r,   r, bCol, false, bth or 1.5)
        CI(borders[6], x+w-r, y+r,   r, bCol, false, bth or 1.5)
        CI(borders[7], x+r,   y+h-r, r, bCol, false, bth or 1.5)
        CI(borders[8], x+w-r, y+h-r, r, bCol, false, bth or 1.5)
    end
end

local function HideRR(bg, corners, borders)
    for _,d in ipairs(bg) do d.Visible=false end
    for _,d in ipairs(corners) do d.Visible=false end
    if borders then for _,d in ipairs(borders) do d.Visible=false end end
end

-- Helper to create RR object set
local function MakeRR(hasBorder)
    local bg      = {NewSq(),NewSq(),NewSq()}
    local corners = {NewCi(),NewCi(),NewCi(),NewCi()}
    local borders = nil
    if hasBorder then
        borders = {NewLn(),NewLn(),NewLn(),NewLn(),NewCi(),NewCi(),NewCi(),NewCi()}
    end
    return {bg=bg, corners=corners, borders=borders}
end

-- ICONS using lines only
local function MakeIconLines(n)
    local t={}
    for i=1,n do t[i]=NewLn() end
    return t
end
local function MakeIconCircles(n)
    local t={}
    for i=1,n do t[i]=NewCi() end
    return t
end

local function HideIconLines(lines)
    for _,l in ipairs(lines) do l.Visible=false end
end
local function HideIconCircles(circs)
    for _,c in ipairs(circs) do c.Visible=false end
end

local function DrawIcon(lines, circs, idx, cx,cy, col)
    HideIconLines(lines)
    HideIconCircles(circs)
    if idx==1 then
        L(lines[1],cx-7,cy-1,cx,cy-8,col,2)
        L(lines[2],cx,cy-8,cx+7,cy-1,col,2)
        L(lines[3],cx-5,cy-1,cx-5,cy+6,col,2)
        L(lines[4],cx+5,cy-1,cx+5,cy+6,col,2)
        L(lines[5],cx-5,cy+6,cx+5,cy+6,col,2)
    elseif idx==2 then
        CI(circs[1],cx,cy-4,3.5,col,false,2)
        L(lines[1],cx-6,cy+6,cx-5,cy+1,col,2)
        L(lines[2],cx-5,cy+1,cx+5,cy+1,col,2)
        L(lines[3],cx+5,cy+1,cx+6,cy+6,col,2)
        L(lines[4],cx-6,cy+6,cx+6,cy+6,col,2)
    elseif idx==3 then
        CI(circs[1],cx-5,cy-3,3,col,false,2)
        CI(circs[2],cx+5,cy-3,3,col,false,2)
        L(lines[1],cx-9,cy+5,cx-1,cy+5,col,2)
        L(lines[2],cx-9,cy+5,cx-8,cy+1,col,2)
        L(lines[3],cx-8,cy+1,cx-1,cy+1,col,2)
        L(lines[4],cx-1,cy+1,cx-1,cy+5,col,2)
        L(lines[5],cx+1,cy+1,cx+9,cy+1,col,2)
        L(lines[6],cx+1,cy+5,cx+9,cy+5,col,2)
        L(lines[7],cx+9,cy+1,cx+9,cy+5,col,2)
    elseif idx==4 then
        for t=0,5 do
            local a=(t/6)*math.pi*2
            L(lines[t+1],
                cx+math.cos(a)*5,cy+math.sin(a)*5,
                cx+math.cos(a)*9,cy+math.sin(a)*9,
                col,2)
        end
        CI(circs[1],cx,cy,5,col,false,2)
        CI(circs[2],cx,cy,2,col,false,2)
    end
end

-- ══════════════════════════════════════════════
-- PRE-CREATE ALL DRAWING OBJECTS
-- ══════════════════════════════════════════════

-- Panel
local panRR = MakeRR(true)
-- Header
local hdrLine = NewLn()
local logoRR  = MakeRR(false)
local logoTx  = NewTx()
local titTx1  = NewTx()
local titTx2  = NewTx()
local subTx   = NewTx()
-- Header buttons
local clRR  = MakeRR(false)
local clX1  = NewLn(); local clX2 = NewLn()
local mnRR  = MakeRR(false)
local mnLn  = NewLn()
-- Footer
local ftLine = NewLn()
local ftDot  = NewCi()
local ftTxt  = NewTx()
local ftTab  = NewTx()
local ftKey  = NewTx()

-- Nav pill
local navRR = MakeRR(true)
local navItems = {}
for i=1,4 do
    navItems[i] = {
        rr    = MakeRR(true),
        lines = MakeIconLines(9),
        circs = MakeIconCircles(3),
    }
end

-- Cards (9 per tab, shared)
local cardObjs = {}
for i=1,9 do
    cardObjs[i] = {
        rr       = MakeRR(true),
        bar      = NewSq(),
        dot      = NewCi(),
        lbl      = NewTx(),
        desc     = NewTx(),
        -- toggle
        trkRR    = MakeRR(false),
        trkEnd1  = NewCi(),
        trkEnd2  = NewCi(),
        knob     = NewCi(),
    }
end

-- Settings
local setTitle = NewTx()
local setL1    = NewTx()
local setL2    = NewTx()
local setL3    = NewTx()
local setL4    = NewTx()
local setSB    = {}
for i=1,2 do
    setSB[i]={rr=MakeRR(true), tx=NewTx()}
end
local slTrack  = MakeRR(false)
local slFill   = MakeRR(false)
local slDot    = NewCi()
local slRing   = NewCi()
local slCtr    = NewCi()
local slPct    = NewTx()
local divLine  = NewLn()
local hkRR     = MakeRR(true)
local hkTx     = NewTx()
local actRows  = {}
for i=1,3 do
    actRows[i]={
        name  = NewTx(),
        track = MakeRR(false),
        fill  = MakeRR(false),
        cnt   = NewTx(),
    }
end

-- Mini button
local miniRR   = MakeRR(true)
local miniLRR  = MakeRR(false)
local miniTx   = NewTx()

-- ══════════════════════════════════════════════
-- HIDE HELPERS
-- ══════════════════════════════════════════════
local function HideRRObj(o)
    HideRR(o.bg, o.corners, o.borders)
end
local function HideToggle(c)
    HideRRObj(c.trkRR)
    c.trkEnd1.Visible=false; c.trkEnd2.Visible=false; c.knob.Visible=false
end
local function HideCard(c)
    HideRRObj(c.rr)
    c.bar.Visible=false; c.dot.Visible=false
    c.lbl.Visible=false; c.desc.Visible=false
    HideToggle(c)
end
local function HideSettings()
    for _,d in ipairs({setTitle,setL1,setL2,setL3,setL4,slPct,divLine,hkTx}) do d.Visible=false end
    for _,o in ipairs({slTrack,slFill}) do HideRRObj(o) end
    slDot.Visible=false; slRing.Visible=false; slCtr.Visible=false
    HideRRObj(hkRR)
    for i=1,2 do HideRRObj(setSB[i].rr); setSB[i].tx.Visible=false end
    for i=1,3 do
        local r=actRows[i]
        r.name.Visible=false; r.cnt.Visible=false
        HideRRObj(r.track); HideRRObj(r.fill)
    end
end

-- ══════════════════════════════════════════════
-- DRAW TOGGLE
-- ══════════════════════════════════════════════
local function DrawToggle(c, x,y, on)
    local W,H=46,24
    local r=H/2
    local col=on and NEON or TRACK
    RR(c.trkRR.bg, c.trkRR.corners, nil, x,y,W,H, col, nil, r)
    CI(c.trkEnd1, x+r,   y+r, r, col, true)
    CI(c.trkEnd2, x+W-r, y+r, r, col, true)
    local kR=r-3
    local kx=on and (x+W-r-1) or (x+r+1)
    CI(c.knob, kx,y+r, kR, WHITE, true)
end

-- ══════════════════════════════════════════════
-- MAIN RENDER
-- ══════════════════════════════════════════════
local function Render()
    HideAll()

    if not Open then
        local mx = MiniSide=="left" and 10 or (VP.X-MBW-10)
        local my = math.max(10, math.min(VP.Y-MBH-10, math.floor(VP.Y*MiniYPos-MBH/2)))
        RR(miniRR.bg,miniRR.corners,miniRR.borders, mx,my,MBW,MBH, BGLITE,NEON,14,1.5)
        RR(miniLRR.bg,miniLRR.corners,nil, mx+MBW/2-10,my+MBH/2-10,20,20, NEON,nil,6)
        TX(miniTx, mx+MBW/2,my+MBH/2-7, "L", WHITE,12,true)
        return
    end

    -- NAV PILL
    local ns,ng = 48,10
    local nNH  = 4*ns+3*ng+20
    local nNX  = PX-NAV_W-NAV_GAP
    local nNY  = PY+PH/2-nNH/2
    RR(navRR.bg,navRR.corners,navRR.borders, nNX,nNY,NAV_W,nNH, BGLITE,NEONDIM,18,1.5)

    for i=1,4 do
        local ni  = navItems[i]
        local bx  = nNX+(NAV_W-ns)/2
        local by  = nNY+10+(i-1)*(ns+ng)
        local act = CurTab==i
        local hov = Hov(bx,by,ns,ns)
        local bg  = act and CARDON or (hov and CARDHI or CARD)
        local bc  = act and NEON or nil
        RR(ni.rr.bg,ni.rr.corners,ni.rr.borders, bx,by,ns,ns, bg,bc,14,1.5)
        if not act then HideRR({},{},ni.rr.borders) end
        DrawIcon(ni.lines,ni.circs, i, bx+ns/2,by+ns/2, act and NEON or TXLOW)
    end

    -- MAIN PANEL
    RR(panRR.bg,panRR.corners,panRR.borders, PX,PY,PW,PH, BG,NEONDIM,18,1.5)

    -- Header
    L(hdrLine, PX+16,PY+HEADER, PX+PW-16,PY+HEADER, BORDER,1)
    RR(logoRR.bg,logoRR.corners,nil, PX+14,PY+13,30,30, NEON,nil,9)
    TX(logoTx, PX+29,PY+19, "L",  WHITE,15,true)
    TX(titTx1, PX+52,PY+10, "LUXURY",   TXHI,17)
    TX(titTx2, PX+52+74,PY+10, "HUB",  NEON,17)
    TX(subTx,  PX+53,PY+31, "PREMIUM CONTROLS", TXLOW,8)

    local bs=28; local bgap=6
    local cX=PX+PW-bs-14; local bY=PY+13
    local nX2=cX-bs-bgap
    local cHov=Hov(cX,bY,bs,bs)
    local nHov=Hov(nX2,bY,bs,bs)
    RR(clRR.bg,clRR.corners,nil, cX,bY,bs,bs, cHov and RED or CARD,nil,9)
    L(clX1, cX+9,bY+9,cX+bs-9,bY+bs-9, TXHI,1.8)
    L(clX2, cX+bs-9,bY+9,cX+9,bY+bs-9, TXHI,1.8)
    RR(mnRR.bg,mnRR.corners,nil, nX2,bY,bs,bs, nHov and CARDHI or CARD,nil,9)
    L(mnLn, nX2+8,bY+bs/2,nX2+bs-8,bY+bs/2, TXMID,2)

    -- CONTENT
    local CX=PX+PAD
    local CY=PY+HEADER+PAD
    local CW=PW-PAD*2

    if CurTab==4 then
        HideSettings()
        -- SETTINGS CONTENT
        local px=CX+4; local py=CY+4
        TX(setTitle, px,py, "Appearance", TXHI,16)
        py=py+32
        TX(setL1, px,py, "REOPEN SIDE", TXLOW,10)
        py=py+22
        local optW=(CW-12)/2
        for si,side in ipairs({"left","right"}) do
            local ox=px+(si-1)*(optW+12)
            local sel=MiniSide==side
            local hov=Hov(ox,py,optW,38)
            local bc2=sel and NEON or (hov and NEONDIM or nil)
            RR(setSB[si].rr.bg,setSB[si].rr.corners,setSB[si].rr.borders,
               ox,py,optW,38, sel and CARDON or (hov and CARDHI or CARD), bc2,10,1)
            if not bc2 then HideRR({},{},setSB[si].rr.borders) end
            TX(setSB[si].tx, ox+optW/2,py+12,
               side:sub(1,1):upper()..side:sub(2),
               sel and TXHI or TXMID,13,true)
        end
        py=py+38+28
        TX(setL2, px,py, "VERTICAL POSITION", TXLOW,10)
        TX(slPct, CX+CW-4,py, math.floor(MiniYPos*100).."%", NEON,11,true)
        py=py+22
        local slW=CW-8
        RR(slTrack.bg,slTrack.corners,nil, px,py,slW,8, TRACK,nil,4)
        local fw=math.max(8,math.floor(MiniYPos*slW))
        RR(slFill.bg,slFill.corners,nil, px,py,fw,8, NEON,nil,4)
        local hx=px+fw
        CI(slDot,  hx,py+4,9,CARD,true)
        CI(slRing, hx,py+4,9,NEON,false,2)
        CI(slCtr,  hx,py+4,3,NEON,true)
        py=py+36
        L(divLine, CX,py,CX+CW,py, BORDER,1)
        py=py+22
        TX(setL3, px,py, "HOTKEY", TXLOW,10)
        py=py+22
        RR(hkRR.bg,hkRR.corners,hkRR.borders, px,py,96,32, CARD,NEONDIM,10,1)
        TX(hkTx, px+48,py+10, "R-SHIFT", NEON,12,true)
        py=py+32+28
        TX(setL4, px,py, "ACTIVITY", TXLOW,10)
        py=py+22
        for ti=1,3 do
            local cnt=0
            local tItems=TABS[ti].items
            for _,item in ipairs(tItems) do if item.state then cnt=cnt+1 end end
            local ar=actRows[ti]
            local barW=CW-100
            TX(ar.name,  px,py-1, TABS[ti].name, TXMID,12)
            RR(ar.track.bg,ar.track.corners,nil, px+60,py+1,barW,10,TRACK,nil,5)
            local bw=math.floor(cnt/#tItems*barW)
            if bw>2 then RR(ar.fill.bg,ar.fill.corners,nil,px+60,py+1,bw,10,NEON,nil,5)
            else HideRRObj(ar.fill) end
            TX(ar.cnt, CX+CW-4,py-1, cnt.."/"..#tItems, TXLOW,11,true)
            py=py+22
        end
        -- hide cards
        for i=1,9 do HideCard(cardObjs[i]) end
    else
        HideSettings()
        local items = TABS[CurTab].items
        for i=1,9 do
            local co  = cardObjs[i]
            local item= items[i]
            if not item then HideCard(co) continue end

            local ix  = CX
            local iy  = CY+(i-1)*(ROW_H+GAP)
            local iw  = CW
            local on  = item.state
            local hov = Hov(ix,iy,iw,ROW_H)

            local bg  = on and CARDON or (hov and CARDHI or CARD)
            local bc  = on and NEON or (hov and NEONDIM or BORDER)
            RR(co.rr.bg,co.rr.corners,co.rr.borders, ix,iy,iw,ROW_H, bg,bc,14,1)

            if on then
                S(co.bar, ix+9,iy+ROW_H/2-10,3,20, NEON)
                co.bar.Visible=true
            else
                co.bar.Visible=false
            end

            CI(co.dot, ix+24,iy+ROW_H/2, 4.5, on and NEON or TXFAINT, true)

            TX(co.lbl, ix+38,iy+ROW_H/2-10, item.label, on and TXHI or TXMID, 13)
            TX(co.desc, ix+39,iy+ROW_H/2+3, item.desc, on and NEON or TXFAINT, 9)

            DrawToggle(co, ix+iw-46-12, iy+ROW_H/2-12, on)
        end
    end

    -- FOOTER
    local FY=PY+PH-FOOTER
    L(ftLine, PX+16,FY, PX+PW-16,FY, BORDER,1)
    local cnt=0
    local tItems=CurTab<4 and TABS[CurTab].items or {}
    for _,item in ipairs(tItems) do if item.state then cnt=cnt+1 end end
    local stCol=(CurTab<4 and cnt>0) and GREEN or TXLOW
    CI(ftDot, PX+18,FY+12,3,stCol,true)
    TX(ftTxt, PX+26,FY+6, CurTab<4 and (cnt.." active") or "settings", stCol,9)
    local tabNames={"Main","Player","Other","Settings"}
    TX(ftTab, PX+PW/2,FY+6, tabNames[CurTab], TXMID,9,true)
    TX(ftKey, PX+PW-14,FY+6, "RShift",TXFAINT,9,true)
end

-- RENDER LOOP
RS.RenderStepped:Connect(Render)

-- INPUT
local function GetMiniPos()
    local mx=MiniSide=="left" and 10 or (VP.X-MBW-10)
    local my=math.max(10,math.min(VP.Y-MBH-10,math.floor(VP.Y*MiniYPos-MBH/2)))
    return mx,my
end
local function ClampPos()
    PX=math.max(0,math.min(VP.X-PW,PX))
    PY=math.max(0,math.min(VP.Y-PH,PY))
end

UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.RightShift then Open=not Open return end
    if inp.UserInputType~=Enum.UserInputType.MouseButton1
    and inp.UserInputType~=Enum.UserInputType.Touch then return end
    local m=Mouse()

    if not Open then
        local mx,my=GetMiniPos()
        if Hov(mx,my,MBW,MBH) then Open=true end
        return
    end

    -- Close / Min
    local bs=28; local cX=PX+PW-bs-14; local bY=PY+13
    if Hov(cX,bY,bs,bs) then Open=false return end
    if Hov(cX-bs-6,bY,bs,bs) then Open=false return end

    -- Settings interactions
    if CurTab==4 then
        local px=PX+PAD+4
        local CW=PW-PAD*2
        local py0=PY+HEADER+PAD+4+32+22
        local optW=(CW-12)/2
        for si,side in ipairs({"left","right"}) do
            local ox=px+(si-1)*(optW+12)
            if Hov(ox,py0,optW,38) then MiniSide=side return end
        end
        local slY=py0+38+28+22
        local slW=CW-8
        if Hov(px-10,slY-10,slW+20,28) then
            DragSlider=true
            MiniYPos=math.max(0,math.min(1,(m.X-px)/slW))
            return
        end
    end

    -- Nav tabs
    local ns,ng=48,10
    local nNH=4*ns+3*ng+20
    local nNX=PX-NAV_W-NAV_GAP
    local nNY=PY+PH/2-nNH/2
    for i=1,4 do
        local bx=nNX+(NAV_W-ns)/2
        local by=nNY+10+(i-1)*(ns+ng)
        if Hov(bx,by,ns,ns) then CurTab=i return end
    end

    -- Cards
    if CurTab<4 then
        local CX=PX+PAD; local CY=PY+HEADER+PAD; local CW=PW-PAD*2
        for i=1,9 do
            local iy=CY+(i-1)*(ROW_H+GAP)
            if Hov(CX,iy,CW,ROW_H) then ToggleItem(CurTab,i) return end
        end
    end

    -- Drag header
    if Hov(PX,PY,PW-100,HEADER) then
        Drag=true
        DragOff=Vector2.new(m.X-PX,m.Y-PY)
    end
end)

UIS.InputChanged:Connect(function(inp)
    if inp.UserInputType~=Enum.UserInputType.MouseMovement
    and inp.UserInputType~=Enum.UserInputType.Touch then return end
    local m=Mouse()
    if Drag then
        PX=m.X-DragOff.X; PY=m.Y-DragOff.Y; ClampPos()
    end
    if DragSlider then
        local px=PX+PAD+4; local slW=PW-PAD*2-8
        MiniYPos=math.max(0,math.min(1,(m.X-px)/slW))
    end
end)

UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1
    or inp.UserInputType==Enum.UserInputType.Touch then
        Drag=false; DragSlider=false
    end
end)

-- Handle respawn
LP.CharacterAdded:Connect(function()
    task.wait(1)
    for ti=1,3 do
        for _,item in ipairs(TABS[ti].items) do
            if item.state then pcall(item.enable,item) end
        end
    end
end)

print("LUXURY HUB v9 - Ready")
