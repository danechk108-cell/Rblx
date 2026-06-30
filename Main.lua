-- LUXURY HUB v10 - Layout Fixed
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local Players = game:GetService("Players")
local LP      = Players.LocalPlayer
local VP      = workspace.CurrentCamera.ViewportSize

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

-- LAYOUT CONSTANTS
local ROW_H   = 42
local ROW_GAP = 7
local HEADER  = 52
local FOOTER  = 28
local PAD     = 12
local NAV_W   = 58
local NAV_GAP = 18
local MBW,MBH = 38,82

-- Panel size
local PW = math.min(480, math.floor(VP.X * 0.50))
local PH = math.min(
    HEADER + 9*(ROW_H+ROW_GAP) - ROW_GAP + PAD*2 + FOOTER + PAD,
    math.floor(VP.Y * 0.93)
)

-- Positions (mutable for drag)
local PX = math.floor((VP.X - PW) / 2 + 36)
local PY = math.floor((VP.Y - PH) / 2)

-- Nav pill dimensions
local NAV_ITEM_SZ  = 50
local NAV_ITEM_GAP = 10
local NAV_H = 4 * NAV_ITEM_SZ + 3 * NAV_ITEM_GAP + 24

-- Get nav position relative to panel (always recalculated)
local function GetNavPos()
    local nx = PX - NAV_W - NAV_GAP
    local ny = PY + math.floor(PH/2 - NAV_H/2)
    return nx, ny
end

local function GetNavItemPos(i)
    local nx, ny = GetNavPos()
    local bx = nx + math.floor((NAV_W - NAV_ITEM_SZ)/2)
    local by = ny + 12 + (i-1)*(NAV_ITEM_SZ + NAV_ITEM_GAP)
    return bx, by
end

-- ══════════════════════════════════════════════
-- FEATURE DEFINITIONS
-- ══════════════════════════════════════════════
local TABS = {
    {
        name="Main",
        items={
            {
                label="Infinite Jump", desc="Jump while in air",
                state=false, conn=nil,
                enable=function(it)
                    it.conn = UIS.JumpRequest:Connect(function()
                        pcall(function()
                            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                        end)
                    end)
                end,
                disable=function(it)
                    if it.conn then it.conn:Disconnect(); it.conn=nil end
                end,
            },
            {
                label="Speed Boost", desc="WalkSpeed x2.5",
                state=false,
                enable=function()
                    pcall(function()
                        local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                        if h then h.WalkSpeed=40 end
                    end)
                end,
                disable=function()
                    pcall(function()
                        local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                        if h then h.WalkSpeed=16 end
                    end)
                end,
            },
            {
                label="Anti-AFK", desc="Prevent idle kick",
                state=false, conn=nil,
                enable=function(it)
                    it.conn = LP.Idled:Connect(function()
                        pcall(function()
                            local vu = game:GetService("VirtualUser")
                            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                            task.wait()
                            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                        end)
                    end)
                end,
                disable=function(it)
                    if it.conn then it.conn:Disconnect(); it.conn=nil end
                end,
            },
            {
                label="Fly", desc="WASD+Space to fly",
                state=false, conn=nil, _bv=nil, _bg=nil,
                enable=function(it)
                    pcall(function()
                        local char = LP.Character
                        if not char then return end
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if not root then return end
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum.PlatformStand = true end
                        local bv = Instance.new("BodyVelocity")
                        bv.Velocity = Vector3.new(0,0,0)
                        bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                        bv.Parent = root
                        it._bv = bv
                        local bg = Instance.new("BodyGyro")
                        bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
                        bg.D = 100
                        bg.Parent = root
                        it._bg = bg
                        it.conn = RS.RenderStepped:Connect(function()
                            pcall(function()
                                local cam = workspace.CurrentCamera
                                local d = Vector3.new(0,0,0)
                                if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+cam.CFrame.LookVector end
                                if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-cam.CFrame.LookVector end
                                if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-cam.CFrame.RightVector end
                                if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+cam.CFrame.RightVector end
                                if UIS:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end
                                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d=d-Vector3.new(0,1,0) end
                                if d.Magnitude>0 then d=d.Unit end
                                bv.Velocity = d*52
                                bg.CFrame   = cam.CFrame
                            end)
                        end)
                    end)
                end,
                disable=function(it)
                    if it.conn then it.conn:Disconnect(); it.conn=nil end
                    pcall(function()
                        if it._bv then it._bv:Destroy(); it._bv=nil end
                        if it._bg then it._bg:Destroy(); it._bg=nil end
                        local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                        if h then h.PlatformStand=false end
                    end)
                end,
            },
            {
                label="No Clip", desc="Walk thru walls",
                state=false, conn=nil,
                enable=function(it)
                    it.conn = RS.Stepped:Connect(function()
                        pcall(function()
                            if LP.Character then
                                for _,p in ipairs(LP.Character:GetDescendants()) do
                                    if p:IsA("BasePart") then p.CanCollide=false end
                                end
                            end
                        end)
                    end)
                end,
                disable=function(it)
                    if it.conn then it.conn:Disconnect(); it.conn=nil end
                    pcall(function()
                        if LP.Character then
                            for _,p in ipairs(LP.Character:GetDescendants()) do
                                if p:IsA("BasePart") then p.CanCollide=true end
                            end
                        end
                    end)
                end,
            },
            {label="TEST-6",  desc="Slot 6",  state=false, enable=function()end, disable=function()end},
            {label="TEST-7",  desc="Slot 7",  state=false, enable=function()end, disable=function()end},
            {label="TEST-8",  desc="Slot 8",  state=false, enable=function()end, disable=function()end},
            {label="TEST-9",  desc="Slot 9",  state=false, enable=function()end, disable=function()end},
        }
    },
    {
        name="Player",
        items={
            {
                label="God Mode", desc="Max health loop",
                state=false, conn=nil,
                enable=function(it)
                    it.conn = RS.Heartbeat:Connect(function()
                        pcall(function()
                            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                            if h then h.Health=h.MaxHealth end
                        end)
                    end)
                end,
                disable=function(it)
                    if it.conn then it.conn:Disconnect(); it.conn=nil end
                end,
            },
            {
                label="High Jump", desc="JumpPower x3",
                state=false,
                enable=function()
                    pcall(function()
                        local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                        if h then h.JumpPower=150 end
                    end)
                end,
                disable=function()
                    pcall(function()
                        local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                        if h then h.JumpPower=50 end
                    end)
                end,
            },
            {
                label="Invisible", desc="Hide character",
                state=false,
                enable=function()
                    pcall(function()
                        for _,p in ipairs(LP.Character:GetDescendants()) do
                            if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency=1 end
                        end
                    end)
                end,
                disable=function()
                    pcall(function()
                        for _,p in ipairs(LP.Character:GetDescendants()) do
                            if p:IsA("BasePart") then p.Transparency=0
                            elseif p:IsA("Decal") then p.Transparency=0 end
                        end
                    end)
                end,
            },
            {
                label="Freeze", desc="Anchor character",
                state=false,
                enable=function()
                    pcall(function()
                        local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        if r then r.Anchored=true end
                    end)
                end,
                disable=function()
                    pcall(function()
                        local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        if r then r.Anchored=false end
                    end)
                end,
            },
            {
                label="Low Gravity", desc="Workspace.Gravity=20",
                state=false,
                enable=function() pcall(function() workspace.Gravity=20 end) end,
                disable=function() pcall(function() workspace.Gravity=196.2 end) end,
            },
            {label="TEST-6", desc="Slot 6", state=false, enable=function()end, disable=function()end},
            {label="TEST-7", desc="Slot 7", state=false, enable=function()end, disable=function()end},
            {label="TEST-8", desc="Slot 8", state=false, enable=function()end, disable=function()end},
            {label="TEST-9", desc="Slot 9", state=false, enable=function()end, disable=function()end},
        }
    },
    {
        name="Other",
        items={
            {
                label="Full Bright", desc="Max ambient",
                state=false, _old=nil,
                enable=function(it)
                    pcall(function()
                        it._old={
                            a=game.Lighting.Ambient,
                            o=game.Lighting.OutdoorAmbient,
                            b=game.Lighting.Brightness
                        }
                        game.Lighting.Ambient=Color3.fromRGB(255,255,255)
                        game.Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
                        game.Lighting.Brightness=2
                    end)
                end,
                disable=function(it)
                    pcall(function()
                        if it._old then
                            game.Lighting.Ambient=it._old.a
                            game.Lighting.OutdoorAmbient=it._old.o
                            game.Lighting.Brightness=it._old.b
                        end
                    end)
                end,
            },
            {
                label="Time: Noon", desc="ClockTime = 12",
                state=false,
                enable=function() pcall(function() game.Lighting.ClockTime=12 end) end,
                disable=function() end,
            },
            {
                label="No Fog", desc="Remove all fog",
                state=false, _old=nil,
                enable=function(it)
                    pcall(function()
                        it._old={s=game.Lighting.FogStart, e=game.Lighting.FogEnd}
                        game.Lighting.FogStart=0
                        game.Lighting.FogEnd=1e6
                    end)
                end,
                disable=function(it)
                    pcall(function()
                        if it._old then
                            game.Lighting.FogStart=it._old.s
                            game.Lighting.FogEnd=it._old.e
                        end
                    end)
                end,
            },
            {
                label="ESP Players", desc="Names over heads",
                state=false, _bills={},
                enable=function(it)
                    pcall(function()
                        for _,pl in ipairs(Players:GetPlayers()) do
                            if pl~=LP and pl.Character then
                                local root = pl.Character:FindFirstChild("HumanoidRootPart")
                                if root then
                                    local bb = Instance.new("BillboardGui", root)
                                    bb.Size=UDim2.new(0,100,0,32)
                                    bb.StudsOffset=Vector3.new(0,3.5,0)
                                    bb.AlwaysOnTop=true
                                    local lb = Instance.new("TextLabel", bb)
                                    lb.Size=UDim2.new(1,0,1,0)
                                    lb.BackgroundTransparency=1
                                    lb.TextColor3=NEON
                                    lb.TextStrokeTransparency=0
                                    lb.Text=pl.Name
                                    lb.Font=Enum.Font.GothamBold
                                    lb.TextSize=14
                                    table.insert(it._bills, bb)
                                end
                            end
                        end
                    end)
                end,
                disable=function(it)
                    for _,b in ipairs(it._bills) do pcall(function() b:Destroy() end) end
                    it._bills={}
                end,
            },
            {
                label="Low Gravity", desc="Float around",
                state=false,
                enable=function() pcall(function() workspace.Gravity=15 end) end,
                disable=function() pcall(function() workspace.Gravity=196.2 end) end,
            },
            {label="TEST-6", desc="Slot 6", state=false, enable=function()end, disable=function()end},
            {label="TEST-7", desc="Slot 7", state=false, enable=function()end, disable=function()end},
            {label="TEST-8", desc="Slot 8", state=false, enable=function()end, disable=function()end},
            {label="TEST-9", desc="Slot 9", state=false, enable=function()end, disable=function()end},
        }
    },
}

local function DoToggle(ti, ii)
    local item = TABS[ti] and TABS[ti].items[ii]
    if not item then return end
    item.state = not item.state
    if item.state then pcall(item.enable, item)
    else pcall(item.disable, item) end
end

-- ══════════════════════════════════════════════
-- DRAWING OBJECTS
-- ══════════════════════════════════════════════
local ALL = {}
local function NSq() local d=Drawing.new("Square"); d.Filled=true; d.Visible=false; d.Thickness=1; ALL[#ALL+1]=d; return d end
local function NLn() local d=Drawing.new("Line");   d.Visible=false; d.Thickness=1;                ALL[#ALL+1]=d; return d end
local function NCi() local d=Drawing.new("Circle"); d.Filled=true; d.NumSides=24; d.Visible=false; d.Thickness=1; ALL[#ALL+1]=d; return d end
local function NTx() local d=Drawing.new("Text");   d.Outline=true; d.OutlineColor=BLACK; d.Size=14; d.Visible=false; ALL[#ALL+1]=d; return d end

local function HA() for _,d in ipairs(ALL) do d.Visible=false end end

-- draw helpers
local function dS(d,x,y,w,h,c)         d.Position=Vector2.new(x,y);d.Size=Vector2.new(w,h);d.Color=c;d.Filled=true;d.Visible=true end
local function dL(d,x1,y1,x2,y2,c,th) d.From=Vector2.new(x1,y1);d.To=Vector2.new(x2,y2);d.Color=c;d.Thickness=th or 1;d.Visible=true end
local function dC(d,x,y,r,c,f,th)     d.Position=Vector2.new(x,y);d.Radius=r;d.Color=c;d.Filled=f~=false;d.Thickness=th or 1;d.Visible=true end
local function dT(d,x,y,t,c,sz,ctr)   d.Position=Vector2.new(x,y);d.Text=tostring(t);d.Color=c;d.Size=sz or 14;d.Center=ctr or false;d.Visible=true end

-- Rounded rect object
-- fill: s1(center wide),s2(left strip),s3(right strip) + 4 corner circles
-- border: 4 lines + 4 arc circles
local function MRR(hasBorder)
    local o={s1=NSq(),s2=NSq(),s3=NSq(),c1=NCi(),c2=NCi(),c3=NCi(),c4=NCi()}
    if hasBorder then
        o.b1=NLn();o.b2=NLn();o.b3=NLn();o.b4=NLn()
        o.a1=NCi();o.a2=NCi();o.a3=NCi();o.a4=NCi()
    end
    return o
end

local function DRR(o,x,y,w,h,bg,bc,r,bt)
    r=math.min(r or 12,w/2,h/2)
    dS(o.s1,x+r,y,w-r*2,h,bg)
    dS(o.s2,x,y+r,r,h-r*2,bg)
    dS(o.s3,x+w-r,y+r,r,h-r*2,bg)
    dC(o.c1,x+r,y+r,r,bg,true)
    dC(o.c2,x+w-r,y+r,r,bg,true)
    dC(o.c3,x+r,y+h-r,r,bg,true)
    dC(o.c4,x+w-r,y+h-r,r,bg,true)
    if o.b1 then
        if bc then
            bt=bt or 1.5
            dL(o.b1,x+r,y,x+w-r,y,bc,bt)
            dL(o.b2,x+r,y+h,x+w-r,y+h,bc,bt)
            dL(o.b3,x,y+r,x,y+h-r,bc,bt)
            dL(o.b4,x+w,y+r,x+w,y+h-r,bc,bt)
            dC(o.a1,x+r,y+r,r,bc,false,bt)
            dC(o.a2,x+w-r,y+r,r,bc,false,bt)
            dC(o.a3,x+r,y+h-r,r,bc,false,bt)
            dC(o.a4,x+w-r,y+h-r,r,bc,false,bt)
        else
            o.b1.Visible=false;o.b2.Visible=false
            o.b3.Visible=false;o.b4.Visible=false
            o.a1.Visible=false;o.a2.Visible=false
            o.a3.Visible=false;o.a4.Visible=false
        end
    end
end

local function HRR(o)
    o.s1.Visible=false;o.s2.Visible=false;o.s3.Visible=false
    o.c1.Visible=false;o.c2.Visible=false
    o.c3.Visible=false;o.c4.Visible=false
    if o.b1 then
        o.b1.Visible=false;o.b2.Visible=false
        o.b3.Visible=false;o.b4.Visible=false
        o.a1.Visible=false;o.a2.Visible=false
        o.a3.Visible=false;o.a4.Visible=false
    end
end

-- Icons (lines only, circles for user/group/gear)
local function DrawIcon(IL, IC, idx, cx, cy, col)
    for _,d in ipairs(IL) do d.Visible=false end
    for _,d in ipairs(IC) do d.Visible=false end
    if idx==1 then -- Home
        dL(IL[1],cx-8,cy,cx,cy-9,col,2)
        dL(IL[2],cx,cy-9,cx+8,cy,col,2)
        dL(IL[3],cx-6,cy,cx-6,cy+8,col,2)
        dL(IL[4],cx+6,cy,cx+6,cy+8,col,2)
        dL(IL[5],cx-6,cy+8,cx+6,cy+8,col,2)
        dL(IL[6],cx-2,cy+3,cx-2,cy+8,col,2)
        dL(IL[7],cx+2,cy+3,cx+2,cy+8,col,2)
        dL(IL[8],cx-2,cy+3,cx+2,cy+3,col,2)
    elseif idx==2 then -- Person
        dC(IC[1],cx,cy-6,4,col,false,2)
        dL(IL[1],cx-7,cy+8,cx-6,cy+1,col,2)
        dL(IL[2],cx-6,cy+1,cx+6,cy+1,col,2)
        dL(IL[3],cx+6,cy+1,cx+7,cy+8,col,2)
        dL(IL[4],cx-7,cy+8,cx+7,cy+8,col,2)
    elseif idx==3 then -- Group
        dC(IC[1],cx-6,cy-5,3,col,false,2)
        dC(IC[2],cx+6,cy-5,3,col,false,2)
        dL(IL[1],cx-10,cy+6,cx-9,cy+1,col,2)
        dL(IL[2],cx-9,cy+1,cx-1,cy+1,col,2)
        dL(IL[3],cx-1,cy+1,cx-1,cy+6,col,2)
        dL(IL[4],cx-10,cy+6,cx-1,cy+6,col,2)
        dL(IL[5],cx+1,cy+1,cx+9,cy+1,col,2)
        dL(IL[6],cx+9,cy+1,cx+10,cy+6,col,2)
        dL(IL[7],cx+1,cy+6,cx+10,cy+6,col,2)
        dL(IL[8],cx+1,cy+1,cx+1,cy+6,col,2)
    elseif idx==4 then -- Gear
        dC(IC[1],cx,cy,6,col,false,2)
        dC(IC[2],cx,cy,2.5,col,false,2)
        for t=0,7 do
            local a=(t/8)*math.pi*2
            dL(IL[t+1],
                cx+math.cos(a)*6,cy+math.sin(a)*6,
                cx+math.cos(a)*10,cy+math.sin(a)*10,
                col,2)
        end
    end
end

-- ══════════════════════════════════════════════
-- PRE-CREATE ALL OBJECTS
-- ══════════════════════════════════════════════
-- Panel
local P = {
    rr   = MRR(true),
    hLn  = NLn(),
    logo = MRR(false),
    logT = NTx(),
    tit1 = NTx(), tit2 = NTx(), sub = NTx(),
    clRR = MRR(false), clX1 = NLn(), clX2 = NLn(),
    mnRR = MRR(false), mnLn = NLn(),
    fLn  = NLn(),
    fDot = NCi(), fT1 = NTx(), fT2 = NTx(), fT3 = NTx(),
}

-- Nav
local NAV = {rr=MRR(true), items={}}
for i=1,4 do
    local IL={}; for j=1,10 do IL[j]=NLn() end
    local IC={}; for j=1,3  do IC[j]=NCi() end
    NAV.items[i]={rr=MRR(true), IL=IL, IC=IC}
end

-- Cards
local CARDS = {}
for i=1,9 do
    CARDS[i]={
        rr   = MRR(true),
        bar  = NSq(),
        dot  = NCi(),
        lbl  = NTx(),
        dsc  = NTx(),
        tRR  = MRR(false),
        tC1  = NCi(), tC2 = NCi(),
        knob = NCi(),
    }
end

-- Settings
local SET = {
    title=NTx(), l1=NTx(), l2=NTx(), l3=NTx(), l4=NTx(),
    sb={{rr=MRR(true),tx=NTx()},{rr=MRR(true),tx=NTx()}},
    slTR=MRR(false), slFI=MRR(false),
    slDt=NCi(), slRi=NCi(), slCt=NCi(), slPc=NTx(),
    div=NLn(),
    hkRR=MRR(true), hkTx=NTx(),
    act={},
}
for i=1,3 do SET.act[i]={nm=NTx(),tr=MRR(false),fi=MRR(false),ct=NTx()} end

-- Mini
local MINI = {rr=MRR(true), lRR=MRR(false), tx=NTx()}

-- ══════════════════════════════════════════════
-- STATE
-- ══════════════════════════════════════════════
local Open       = true
local CurTab     = 1
local Drag       = false
local DragOff    = Vector2.new(0,0)
local MiniSide   = "left"
local MiniYPct   = 0.32
local DragSlider = false

local function Mouse()  return UIS:GetMouseLocation() end
local function Hov(x,y,w,h) local m=Mouse(); return m.X>=x and m.X<=x+w and m.Y>=y and m.Y<=y+h end
local function Clamp(v,a,b) return math.max(a,math.min(b,v)) end

-- Toggle draw
local function DrawTog(c,x,y,on)
    local W,H=44,24; local r=H/2
    local col=on and NEON or TRACK
    DRR(c.tRR,x,y,W,H,col,nil,r)
    dC(c.tC1,x+r,y+r,r,col,true)
    dC(c.tC2,x+W-r,y+r,r,col,true)
    local kx=on and (x+W-r-1) or (x+r+1)
    dC(c.knob,kx,y+r,r-3,WHITE,true)
end

local function HideCard(c)
    HRR(c.rr); c.bar.Visible=false; c.dot.Visible=false
    c.lbl.Visible=false; c.dsc.Visible=false
    HRR(c.tRR); c.tC1.Visible=false; c.tC2.Visible=false; c.knob.Visible=false
end

local function HideSettings()
    for _,d in ipairs({SET.title,SET.l1,SET.l2,SET.l3,SET.l4,
                       SET.slPc,SET.div,SET.hkTx}) do d.Visible=false end
    HRR(SET.slTR); HRR(SET.slFI); HRR(SET.hkRR)
    SET.slDt.Visible=false; SET.slRi.Visible=false; SET.slCt.Visible=false
    for i=1,2 do HRR(SET.sb[i].rr); SET.sb[i].tx.Visible=false end
    for i=1,3 do
        SET.act[i].nm.Visible=false; SET.act[i].ct.Visible=false
        HRR(SET.act[i].tr); HRR(SET.act[i].fi)
    end
end

-- ══════════════════════════════════════════════
-- RENDER
-- ══════════════════════════════════════════════
local function Render()
    HA()

    -- MINI BUTTON (when closed)
    if not Open then
        local mx = MiniSide=="left" and 10 or (VP.X-MBW-10)
        local my = Clamp(math.floor(VP.Y*MiniYPct - MBH/2), 10, VP.Y-MBH-10)
        DRR(MINI.rr,  mx,my,MBW,MBH,BGLITE,NEON,16,1.5)
        DRR(MINI.lRR, mx+MBW/2-11,my+MBH/2-11,22,22,NEON,nil,7)
        dT(MINI.tx,   mx+MBW/2,my+MBH/2-8,"L",WHITE,13,true)
        return
    end

    -- NAV PILL
    local nx,ny = GetNavPos()
    DRR(NAV.rr, nx,ny,NAV_W,NAV_H, BGLITE,NEONDIM,20,1.5)

    for i=1,4 do
        local ni = NAV.items[i]
        local bx,by = GetNavItemPos(i)
        local act = CurTab==i
        local hov = Hov(bx,by,NAV_ITEM_SZ,NAV_ITEM_SZ)
        local bg  = act and CARDON or (hov and CARDHI or CARD)
        local bc  = act and NEON or nil
        DRR(ni.rr, bx,by,NAV_ITEM_SZ,NAV_ITEM_SZ, bg,bc,14,1.5)
        DrawIcon(ni.IL, ni.IC, i, bx+NAV_ITEM_SZ/2, by+NAV_ITEM_SZ/2, act and NEON or TXLOW)
    end

    -- MAIN PANEL
    DRR(P.rr, PX,PY,PW,PH, BG,NEONDIM,18,1.5)

    -- Header
    dL(P.hLn, PX+14,PY+HEADER, PX+PW-14,PY+HEADER, BORDER,1)
    DRR(P.logo, PX+14,PY+12,30,30, NEON,nil,9)
    dT(P.logT, PX+29,PY+18,"L", WHITE,15,true)
    dT(P.tit1, PX+52,PY+10, "LUXURY",          TXHI, 17)
    dT(P.tit2, PX+52+76,PY+10, "HUB",          NEON, 17)
    dT(P.sub,  PX+53,PY+30, "PREMIUM CONTROLS",TXLOW,8)

    -- Control buttons (top-right)
    local BS  = 28; local BGP = 7
    local cX  = PX+PW-BS-12
    local nX2 = cX-BS-BGP
    local bY  = PY+12
    local cH  = Hov(cX,bY,BS,BS)
    local nH  = Hov(nX2,bY,BS,BS)

    DRR(P.clRR, cX,bY,BS,BS, cH and RED or CARD,nil,9)
    dL(P.clX1, cX+9,bY+9,cX+BS-9,bY+BS-9, TXHI,1.8)
    dL(P.clX2, cX+BS-9,bY+9,cX+9,bY+BS-9, TXHI,1.8)

    DRR(P.mnRR, nX2,bY,BS,BS, nH and CARDHI or CARD,nil,9)
    dL(P.mnLn,  nX2+8,bY+BS/2, nX2+BS-8,bY+BS/2, TXMID,2)

    -- Content area
    local CX = PX+PAD
    local CY = PY+HEADER+PAD
    local CW = PW-PAD*2

    if CurTab==4 then
        -- SETTINGS
        HideSettings()
        for i=1,9 do HideCard(CARDS[i]) end

        local px=CX+4; local py=CY+6
        dT(SET.title, px,py,"Appearance",TXHI,16); py=py+32

        dT(SET.l1, px,py,"REOPEN SIDE",TXLOW,10); py=py+22
        local optW = math.floor((CW-14)/2)
        for si,side in ipairs({"left","right"}) do
            local ox=px+(si-1)*(optW+14)
            local sel=MiniSide==side
            local hov=Hov(ox,py,optW,38)
            local bc2=sel and NEON or nil
            DRR(SET.sb[si].rr, ox,py,optW,38,
                sel and CARDON or (hov and CARDHI or CARD), bc2, 10, 1)
            dT(SET.sb[si].tx, ox+optW/2,py+12,
               side:sub(1,1):upper()..side:sub(2),
               sel and TXHI or TXMID, 13, true)
        end
        py=py+38+28

        dT(SET.l2, px,py,"VERTICAL POSITION",TXLOW,10)
        dT(SET.slPc, CX+CW-4,py,math.floor(MiniYPct*100).."%",NEON,11,true)
        py=py+22
        local slW=CW-8
        DRR(SET.slTR, px,py,slW,8, TRACK,nil,4)
        local fw=math.max(8,math.floor(MiniYPct*slW))
        DRR(SET.slFI, px,py,fw,8, NEON,nil,4)
        local hx=px+fw
        dC(SET.slDt,hx,py+4,9,CARD,true)
        dC(SET.slRi,hx,py+4,9,NEON,false,2)
        dC(SET.slCt,hx,py+4,3,NEON,true)
        py=py+36

        dL(SET.div, CX,py,CX+CW,py,BORDER,1); py=py+22
        dT(SET.l3, px,py,"HOTKEY",TXLOW,10); py=py+22
        DRR(SET.hkRR, px,py,96,32, CARD,NEONDIM,10,1)
        dT(SET.hkTx, px+48,py+10,"R-SHIFT",NEON,12,true)
        py=py+32+28

        dT(SET.l4, px,py,"ACTIVITY",TXLOW,10); py=py+22
        for ti=1,3 do
            local cnt=0
            for _,it in ipairs(TABS[ti].items) do if it.state then cnt=cnt+1 end end
            local ar=SET.act[ti]; local barW=CW-100
            dT(ar.nm, px,py-1, TABS[ti].name,TXMID,12)
            DRR(ar.tr, px+60,py+1,barW,10,TRACK,nil,5)
            local bw=math.floor(cnt/#TABS[ti].items*barW)
            if bw>2 then DRR(ar.fi,px+60,py+1,bw,10,NEON,nil,5) else HRR(ar.fi) end
            dT(ar.ct, CX+CW-4,py-1, cnt.."/"..#TABS[ti].items,TXLOW,11,true)
            py=py+22
        end
    else
        -- CARDS
        HideSettings()
        local items=TABS[CurTab].items
        for i=1,9 do
            local co   = CARDS[i]
            local item = items[i]
            if not item then
                HideCard(co)
            else
                local ix=CX; local iy=CY+(i-1)*(ROW_H+ROW_GAP); local iw=CW
                local on=item.state
                local hov=Hov(ix,iy,iw,ROW_H)
                local bg=on and CARDON or (hov and CARDHI or CARD)
                local bc=on and NEON or (hov and NEONDIM or BORDER)
                DRR(co.rr, ix,iy,iw,ROW_H, bg,bc,14,1)
                if on then dS(co.bar,ix+9,iy+ROW_H/2-10,3,20,NEON); co.bar.Visible=true
                else co.bar.Visible=false end
                dC(co.dot, ix+24,iy+ROW_H/2,4.5, on and NEON or TXFAINT,true)
                dT(co.lbl, ix+38,iy+ROW_H/2-10, item.label, on and TXHI or TXMID,13)
                dT(co.dsc, ix+39,iy+ROW_H/2+4,  item.desc,  on and NEON or TXFAINT,9)
                DrawTog(co, ix+iw-44-10, iy+ROW_H/2-12, on)
            end
        end
    end

    -- Footer
    local FY=PY+PH-FOOTER
    dL(P.fLn, PX+14,FY,PX+PW-14,FY,BORDER,1)
    local cnt=0
    if CurTab<4 then
        for _,it in ipairs(TABS[CurTab].items) do if it.state then cnt=cnt+1 end end
    end
    local sc=(CurTab<4 and cnt>0) and GREEN or TXLOW
    dC(P.fDot, PX+18,FY+12,3,sc,true)
    dT(P.fT1,  PX+26,FY+6, CurTab<4 and (cnt.." active") or "settings",sc,9)
    local tnames={"Main","Player","Other","Settings"}
    dT(P.fT2,  PX+PW/2,FY+6, tnames[CurTab],TXMID,9,true)
    dT(P.fT3,  PX+PW-14,FY+6,"RShift",TXFAINT,9,true)
end

RS.RenderStepped:Connect(Render)

-- ══════════════════════════════════════════════
-- INPUT
-- ══════════════════════════════════════════════
local function ClampPanel()
    PX=Clamp(PX,0,VP.X-PW)
    PY=Clamp(PY,0,VP.Y-PH)
end

UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.RightShift then Open=not Open; return end
    local isMouse = inp.UserInputType==Enum.UserInputType.MouseButton1
    local isTouch = inp.UserInputType==Enum.UserInputType.Touch
    if not isMouse and not isTouch then return end

    local m=Mouse()

    -- Mini button
    if not Open then
        local mx=MiniSide=="left" and 10 or (VP.X-MBW-10)
        local my=Clamp(math.floor(VP.Y*MiniYPct-MBH/2),10,VP.Y-MBH-10)
        if Hov(mx,my,MBW,MBH) then Open=true end
        return
    end

    -- Header buttons
    local BS=28; local cX=PX+PW-BS-12; local bY=PY+12
    local nX2=cX-BS-7
    if Hov(cX,bY,BS,BS) or Hov(nX2,bY,BS,BS) then Open=false; return end

    -- Settings interactions
    if CurTab==4 then
        local px=PX+PAD+4
        local CW=PW-PAD*2
        local py0=PY+HEADER+PAD+6+32+22
        local optW=math.floor((CW-14)/2)
        for si,side in ipairs({"left","right"}) do
            local ox=px+(si-1)*(optW+14)
            if Hov(ox,py0,optW,38) then MiniSide=side; return end
        end
        local slY=py0+38+28+22
        local slW=CW-8
        if Hov(px-10,slY-10,slW+20,28) then
            DragSlider=true
            MiniYPct=Clamp((m.X-px)/slW,0,1)
            return
        end
    end

    -- Nav tabs
    for i=1,4 do
        local bx,by=GetNavItemPos(i)
        if Hov(bx,by,NAV_ITEM_SZ,NAV_ITEM_SZ) then CurTab=i; return end
    end

    -- Cards
    if CurTab<4 then
        local CX=PX+PAD; local CY=PY+HEADER+PAD; local CW=PW-PAD*2
        for i=1,9 do
            local iy=CY+(i-1)*(ROW_H+ROW_GAP)
            if Hov(CX,iy,CW,ROW_H) then DoToggle(CurTab,i); return end
        end
    end

    -- Drag
    if Hov(PX,PY,PW-100,HEADER) then
        Drag=true
        DragOff=Vector2.new(m.X-PX, m.Y-PY)
    end
end)

UIS.InputChanged:Connect(function(inp)
    if inp.UserInputType~=Enum.UserInputType.MouseMovement
    and inp.UserInputType~=Enum.UserInputType.Touch then return end
    local m=Mouse()
    if Drag then
        PX=m.X-DragOff.X; PY=m.Y-DragOff.Y; ClampPanel()
    end
    if DragSlider then
        local px=PX+PAD+4; local slW=PW-PAD*2-8
        MiniYPct=Clamp((m.X-px)/slW,0,1)
    end
end)

UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1
    or inp.UserInputType==Enum.UserInputType.Touch then
        Drag=false; DragSlider=false
    end
end)

-- Respawn handler
LP.CharacterAdded:Connect(function()
    task.wait(1)
    for ti=1,3 do
        for _,it in ipairs(TABS[ti].items) do
            if it.state then pcall(it.enable,it) end
        end
    end
end)

print("LUXURY HUB v10 - OK")
