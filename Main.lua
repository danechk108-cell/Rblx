-- LUXURY HUB v14 - Full Redesign
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local Players = game:GetService("Players")
local LP      = Players.LocalPlayer
local VP      = workspace.CurrentCamera.ViewportSize

-- ══════════════════════════════════════════════
-- PALETTE
-- ══════════════════════════════════════════════
local P = {
    -- Backgrounds
    Base    = Color3.fromRGB(10, 10, 14),
    Panel   = Color3.fromRGB(16, 17, 23),
    Surface = Color3.fromRGB(22, 23, 32),
    Card    = Color3.fromRGB(26, 28, 38),
    CardHov = Color3.fromRGB(32, 34, 46),
    CardOn  = Color3.fromRGB(30, 30, 50),

    -- Sidebar
    Side    = Color3.fromRGB(18, 19, 27),
    SideAct = Color3.fromRGB(28, 30, 46),

    -- Accent
    Acc     = Color3.fromRGB(139, 92, 246),   -- purple
    AccSoft = Color3.fromRGB(109, 72, 196),
    AccDim  = Color3.fromRGB(60,  45, 110),
    AccLine = Color3.fromRGB(88,  56, 180),

    -- Toggle
    TgOn    = Color3.fromRGB(139, 92, 246),
    TgOff   = Color3.fromRGB(45,  46, 62),
    TgKnob  = Color3.fromRGB(255, 255, 255),

    -- Text
    TxHi    = Color3.fromRGB(240, 240, 252),
    TxMid   = Color3.fromRGB(155, 158, 185),
    TxLow   = Color3.fromRGB(88,  90, 115),
    TxFaint = Color3.fromRGB(52,  54, 72),

    -- UI
    Sep     = Color3.fromRGB(30,  32, 46),
    Border  = Color3.fromRGB(38,  40, 58),
    BordOn  = Color3.fromRGB(100, 70, 200),
    White   = Color3.fromRGB(255, 255, 255),
    Black   = Color3.fromRGB(0,   0,   0),
    Red     = Color3.fromRGB(220, 75,  75),
    Green   = Color3.fromRGB(80,  210, 130),
}

-- ══════════════════════════════════════════════
-- LAYOUT
-- ══════════════════════════════════════════════
local ROW_H   = 46
local ROW_GAP = 6
local HDR     = 58
local FTR     = 30
local PAD     = 16
local SW      = 64      -- sidebar width
local SGAP    = 20      -- sidebar gap
local MBW,MBH = 42, 90

local PW = math.min(500, math.floor(VP.X * 0.52))
local PH = math.min(
    HDR + 9*(ROW_H+ROW_GAP) - ROW_GAP + PAD*2 + FTR + PAD,
    math.floor(VP.Y * 0.93)
)
local PX = math.floor((VP.X - PW)/2 + 40)
local PY = math.floor((VP.Y - PH)/2)

local SNAV_SZ  = 46
local SNAV_GAP = 10
local SNAV_H   = 4*SNAV_SZ + 3*SNAV_GAP + 28

local function GNP()
    return PX - SW - SGAP, PY + math.floor(PH/2 - SNAV_H/2)
end
local function GNI(i)
    local nx,ny = GNP()
    return nx + math.floor((SW-SNAV_SZ)/2), ny+14+(i-1)*(SNAV_SZ+SNAV_GAP)
end

-- ══════════════════════════════════════════════
-- FEATURES
-- ══════════════════════════════════════════════
local TABS = {
    {name="Main", items={
        {label="Infinite Jump",  desc="Jump while in air",     state=false,conn=nil,
         enable=function(it) it.conn=UIS.JumpRequest:Connect(function() pcall(function() local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end) end) end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},
        {label="Speed Boost",   desc="WalkSpeed ×2.5",        state=false,
         enable=function() pcall(function() local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=40 end end) end,
         disable=function() pcall(function() local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=16 end end) end},
        {label="Anti-AFK",      desc="Prevent idle kick",     state=false,conn=nil,
         enable=function(it) it.conn=LP.Idled:Connect(function() pcall(function() local v=game:GetService("VirtualUser");v:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame);task.wait();v:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame) end) end) end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},
        {label="Fly",           desc="WASD + Space",          state=false,conn=nil,_bv=nil,_bg=nil,
         enable=function(it) pcall(function()
             local c=LP.Character;if not c then return end
             local r=c:FindFirstChild("HumanoidRootPart");if not r then return end
             local h=c:FindFirstChildOfClass("Humanoid");if h then h.PlatformStand=true end
             local bv=Instance.new("BodyVelocity");bv.Velocity=Vector3.zero;bv.MaxForce=Vector3.new(1e5,1e5,1e5);bv.Parent=r;it._bv=bv
             local bg=Instance.new("BodyGyro");bg.MaxTorque=Vector3.new(1e5,1e5,1e5);bg.D=100;bg.Parent=r;it._bg=bg
             it.conn=RS.RenderStepped:Connect(function() pcall(function()
                 local cam=workspace.CurrentCamera;local d=Vector3.zero
                 if UIS:IsKeyDown(Enum.KeyCode.W) then d+=cam.CFrame.LookVector end
                 if UIS:IsKeyDown(Enum.KeyCode.S) then d-=cam.CFrame.LookVector end
                 if UIS:IsKeyDown(Enum.KeyCode.A) then d-=cam.CFrame.RightVector end
                 if UIS:IsKeyDown(Enum.KeyCode.D) then d+=cam.CFrame.RightVector end
                 if UIS:IsKeyDown(Enum.KeyCode.Space) then d+=Vector3.new(0,1,0) end
                 if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d-=Vector3.new(0,1,0) end
                 if d.Magnitude>0 then d=d.Unit end;bv.Velocity=d*55;bg.CFrame=cam.CFrame
             end) end)
         end) end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end;pcall(function() if it._bv then it._bv:Destroy();it._bv=nil end;if it._bg then it._bg:Destroy();it._bg=nil end;local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid");if h then h.PlatformStand=false end end) end},
        {label="No Clip",       desc="Walk through walls",    state=false,conn=nil,
         enable=function(it) it.conn=RS.Stepped:Connect(function() pcall(function() if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) end) end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end;pcall(function() if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end end) end},
        {label="TEST-6",desc="Slot 6",state=false,enable=function()end,disable=function()end},
        {label="TEST-7",desc="Slot 7",state=false,enable=function()end,disable=function()end},
        {label="TEST-8",desc="Slot 8",state=false,enable=function()end,disable=function()end},
        {label="TEST-9",desc="Slot 9",state=false,enable=function()end,disable=function()end},
    }},
    {name="Player", items={
        {label="God Mode",   desc="Max health loop",   state=false,conn=nil,
         enable=function(it) it.conn=RS.Heartbeat:Connect(function() pcall(function() local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid");if h then h.Health=h.MaxHealth end end) end) end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},
        {label="High Jump",  desc="JumpPower ×3",      state=false,
         enable=function() pcall(function() local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid");if h then h.JumpPower=150 end end) end,
         disable=function() pcall(function() local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid");if h then h.JumpPower=50 end end) end},
        {label="Invisible",  desc="Hide character",    state=false,
         enable=function() pcall(function() for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart")or p:IsA("Decal") then p.Transparency=1 end end end) end,
         disable=function() pcall(function() for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency=0 elseif p:IsA("Decal") then p.Transparency=0 end end end) end},
        {label="Freeze",     desc="Anchor character",  state=false,
         enable=function() pcall(function() local r=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart");if r then r.Anchored=true end end) end,
         disable=function() pcall(function() local r=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart");if r then r.Anchored=false end end) end},
        {label="Low Gravity",desc="Gravity = 20",      state=false,
         enable=function() pcall(function() workspace.Gravity=20 end) end,
         disable=function() pcall(function() workspace.Gravity=196.2 end) end},
        {label="TEST-6",desc="Slot 6",state=false,enable=function()end,disable=function()end},
        {label="TEST-7",desc="Slot 7",state=false,enable=function()end,disable=function()end},
        {label="TEST-8",desc="Slot 8",state=false,enable=function()end,disable=function()end},
        {label="TEST-9",desc="Slot 9",state=false,enable=function()end,disable=function()end},
    }},
    {name="Other", items={
        {label="Full Bright",  desc="Max ambient",         state=false,_old=nil,
         enable=function(it) pcall(function() it._old={a=game.Lighting.Ambient,o=game.Lighting.OutdoorAmbient,b=game.Lighting.Brightness};game.Lighting.Ambient=Color3.fromRGB(255,255,255);game.Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255);game.Lighting.Brightness=2 end) end,
         disable=function(it) pcall(function() if it._old then game.Lighting.Ambient=it._old.a;game.Lighting.OutdoorAmbient=it._old.o;game.Lighting.Brightness=it._old.b end end) end},
        {label="Time: Noon",   desc="ClockTime = 12",      state=false,
         enable=function() pcall(function() game.Lighting.ClockTime=12 end) end,disable=function()end},
        {label="No Fog",       desc="Remove all fog",      state=false,_old=nil,
         enable=function(it) pcall(function() it._old={s=game.Lighting.FogStart,e=game.Lighting.FogEnd};game.Lighting.FogStart=0;game.Lighting.FogEnd=1e6 end) end,
         disable=function(it) pcall(function() if it._old then game.Lighting.FogStart=it._old.s;game.Lighting.FogEnd=it._old.e end end) end},
        {label="ESP Players",  desc="Names over heads",    state=false,_bills={},
         enable=function(it) pcall(function() for _,pl in ipairs(Players:GetPlayers()) do if pl~=LP and pl.Character then local root=pl.Character:FindFirstChild("HumanoidRootPart");if root then local bb=Instance.new("BillboardGui",root);bb.Size=UDim2.new(0,100,0,32);bb.StudsOffset=Vector3.new(0,3.5,0);bb.AlwaysOnTop=true;local lb=Instance.new("TextLabel",bb);lb.Size=UDim2.new(1,0,1,0);lb.BackgroundTransparency=1;lb.TextColor3=P.White;lb.TextStrokeTransparency=0;lb.Text=pl.Name;lb.Font=Enum.Font.GothamBold;lb.TextSize=14;table.insert(it._bills,bb) end end end end) end,
         disable=function(it) for _,b in ipairs(it._bills) do pcall(function() b:Destroy() end) end;it._bills={} end},
        {label="Low Gravity",  desc="Float around",        state=false,
         enable=function() pcall(function() workspace.Gravity=15 end) end,
         disable=function() pcall(function() workspace.Gravity=196.2 end) end},
        {label="TEST-6",desc="Slot 6",state=false,enable=function()end,disable=function()end},
        {label="TEST-7",desc="Slot 7",state=false,enable=function()end,disable=function()end},
        {label="TEST-8",desc="Slot 8",state=false,enable=function()end,disable=function()end},
        {label="TEST-9",desc="Slot 9",state=false,enable=function()end,disable=function()end},
    }},
}

local function DoToggle(ti,ii)
    local item=TABS[ti] and TABS[ti].items[ii];if not item then return end
    item.state=not item.state
    if item.state then pcall(item.enable,item) else pcall(item.disable,item) end
end

-- ══════════════════════════════════════════════
-- DRAWING ENGINE
-- ══════════════════════════════════════════════
local ALL={}
local function NS() local d=Drawing.new("Square");d.Filled=true;d.Visible=false;d.Thickness=1;ALL[#ALL+1]=d;return d end
local function NL() local d=Drawing.new("Line");d.Visible=false;d.Thickness=1;ALL[#ALL+1]=d;return d end
local function NC() local d=Drawing.new("Circle");d.Filled=true;d.NumSides=32;d.Visible=false;d.Thickness=1;ALL[#ALL+1]=d;return d end
local function NT() local d=Drawing.new("Text");d.Outline=true;d.OutlineColor=P.Black;d.Size=14;d.Visible=false;ALL[#ALL+1]=d;return d end

local function HA() for _,d in ipairs(ALL) do d.Visible=false end end
local function dS(d,x,y,w,h,c) d.Position=Vector2.new(x,y);d.Size=Vector2.new(w,h);d.Color=c;d.Visible=true end
local function dL(d,x1,y1,x2,y2,c,th) d.From=Vector2.new(x1,y1);d.To=Vector2.new(x2,y2);d.Color=c;d.Thickness=th or 1;d.Visible=true end
local function dC(d,x,y,r,c,f,th) d.Position=Vector2.new(x,y);d.Radius=r;d.Color=c;d.Filled=f~=false;d.Thickness=th or 1;d.Visible=true end
local function dT(d,x,y,t,c,sz,ctr) d.Position=Vector2.new(x,y);d.Text=tostring(t);d.Color=c;d.Size=sz or 14;d.Center=ctr or false;d.Visible=true end

-- Rounded rect via pill method:
-- draw center rect + 4 corner circles (filled same color) 
-- then mask sharp corners with parent-bg squares
local function RR(o,x,y,w,h,col,msk,r,bdc,bth)
    r=math.min(r or 16, math.floor(w/2), math.floor(h/2))
    msk=msk or P.Base
    -- fill
    dS(o.f,  x+r, y,   w-r*2, h,   col)
    dS(o.ft, x,   y+r, w,     h-r*2, col)
    -- corners
    dC(o.c1, x+r,   y+r,   r, col, true)
    dC(o.c2, x+w-r, y+r,   r, col, true)
    dC(o.c3, x+r,   y+h-r, r, col, true)
    dC(o.c4, x+w-r, y+h-r, r, col, true)
    -- masks
    dS(o.m1, x,     y,     r, r, msk)
    dS(o.m2, x+w-r, y,     r, r, msk)
    dS(o.m3, x,     y+h-r, r, r, msk)
    dS(o.m4, x+w-r, y+h-r, r, r, msk)
    -- border
    if bdc then
        bth=bth or 1.5
        dL(o.b1, x+r,   y,     x+w-r, y,     bdc,bth)
        dL(o.b2, x+r,   y+h,   x+w-r, y+h,   bdc,bth)
        dL(o.b3, x,     y+r,   x,     y+h-r, bdc,bth)
        dL(o.b4, x+w,   y+r,   x+w,   y+h-r, bdc,bth)
        dC(o.b5, x+r,   y+r,   r, bdc,false,bth)
        dC(o.b6, x+w-r, y+r,   r, bdc,false,bth)
        dC(o.b7, x+r,   y+h-r, r, bdc,false,bth)
        dC(o.b8, x+w-r, y+h-r, r, bdc,false,bth)
    else
        if o.b1 then o.b1.Visible=false;o.b2.Visible=false;o.b3.Visible=false;o.b4.Visible=false end
        if o.b5 then o.b5.Visible=false;o.b6.Visible=false;o.b7.Visible=false;o.b8.Visible=false end
    end
end

local function HRR(o)
    for _,k in ipairs({"f","ft","c1","c2","c3","c4","m1","m2","m3","m4"}) do if o[k] then o[k].Visible=false end end
    for _,k in ipairs({"b1","b2","b3","b4","b5","b6","b7","b8"}) do if o[k] then o[k].Visible=false end end
end

local function MRR(border)
    local o={f=NS(),ft=NS(),c1=NC(),c2=NC(),c3=NC(),c4=NC(),m1=NS(),m2=NS(),m3=NS(),m4=NS()}
    if border then o.b1=NL();o.b2=NL();o.b3=NL();o.b4=NL();o.b5=NC();o.b6=NC();o.b7=NC();o.b8=NC() end
    return o
end

local function MIL(n) local t={};for i=1,n do t[i]=NL() end;return t end
local function MIC(n) local t={};for i=1,n do t[i]=NC() end;return t end

local function DrawIcon(IL,IC,idx,cx,cy,col)
    for _,d in ipairs(IL) do d.Visible=false end
    for _,d in ipairs(IC) do d.Visible=false end
    if idx==1 then
        dL(IL[1],cx-8,cy+2,cx,cy-8,col,2.2)
        dL(IL[2],cx,cy-8,cx+8,cy+2,col,2.2)
        dL(IL[3],cx-6,cy+2,cx-6,cy+10,col,2.2)
        dL(IL[4],cx+6,cy+2,cx+6,cy+10,col,2.2)
        dL(IL[5],cx-6,cy+10,cx+6,cy+10,col,2.2)
        dL(IL[6],cx-2,cy+5,cx-2,cy+10,col,2.2)
        dL(IL[7],cx+2,cy+5,cx+2,cy+10,col,2.2)
        dL(IL[8],cx-2,cy+5,cx+2,cy+5,col,2.2)
    elseif idx==2 then
        dC(IC[1],cx,cy-5,5,col,false,2.2)
        dL(IL[1],cx-8,cy+10,cx-7,cy+2,col,2.2)
        dL(IL[2],cx-7,cy+2,cx+7,cy+2,col,2.2)
        dL(IL[3],cx+7,cy+2,cx+8,cy+10,col,2.2)
        dL(IL[4],cx-8,cy+10,cx+8,cy+10,col,2.2)
    elseif idx==3 then
        dC(IC[1],cx-7,cy-5,3.8,col,false,2)
        dC(IC[2],cx+7,cy-5,3.8,col,false,2)
        dL(IL[1],cx-12,cy+8,cx-11,cy+1,col,2)
        dL(IL[2],cx-11,cy+1,cx-2,cy+1,col,2)
        dL(IL[3],cx-2,cy+1,cx-2,cy+8,col,2)
        dL(IL[4],cx-12,cy+8,cx-2,cy+8,col,2)
        dL(IL[5],cx+2,cy+1,cx+11,cy+1,col,2)
        dL(IL[6],cx+11,cy+1,cx+12,cy+8,col,2)
        dL(IL[7],cx+2,cy+8,cx+12,cy+8,col,2)
        dL(IL[8],cx+2,cy+1,cx+2,cy+8,col,2)
    elseif idx==4 then
        dC(IC[1],cx,cy,7.5,col,false,2.2)
        dC(IC[2],cx,cy,3,col,false,2.2)
        for t=0,7 do
            local a=(t/8)*math.pi*2
            dL(IL[t+1],cx+math.cos(a)*7.5,cy+math.sin(a)*7.5,cx+math.cos(a)*12,cy+math.sin(a)*12,col,2.2)
        end
    end
end

-- ══════════════════════════════════════════════
-- PRE-CREATE ALL OBJECTS
-- ══════════════════════════════════════════════
local UI = {
    -- Panel
    pan   = MRR(true),
    hSep  = NL(),
    -- Header logo area
    logoR = MRR(false),
    logoT = NT(),
    hT1   = NT(), hT2 = NT(), hSub = NT(),
    -- Header right buttons
    clR   = MRR(false), clX1=NL(), clX2=NL(),
    mnR   = MRR(false), mnL=NL(),
    -- Header accent line
    hAcc  = NL(),
    -- Footer
    fSep  = NL(), fDot=NC(), fT1=NT(), fT2=NT(), fT3=NT(),
}

-- Sidebar
local SB = {rr=MRR(true), items={}}
for i=1,4 do SB.items[i]={rr=MRR(true),IL=MIL(10),IC=MIC(3)} end

-- Cards
local CARDS={}
for i=1,9 do
    CARDS[i]={
        rr=MRR(true),
        bar=NS(),
        dot=NC(),
        lbl=NT(), dsc=NT(),
        -- Toggle: track + inner circles + knob
        tR=MRR(false), tKnob=NC(),
        -- Toggle glow dot
        tGlow=NC(),
    }
end

-- Settings
local SET={
    ti=NT(),l1=NT(),l2=NT(),l3=NT(),l4=NT(),
    sb={{rr=MRR(true),tx=NT()},{rr=MRR(true),tx=NT()}},
    slTR=MRR(false),slFI=MRR(false),slH=NC(),slHR=NC(),slHC=NC(),slP=NT(),
    div=NL(),hkR=MRR(true),hkT=NT(),act={},
}
for i=1,3 do SET.act[i]={nm=NT(),tr=MRR(false),fi=MRR(false),ct=NT()} end

-- Mini
local MINI={rr=MRR(true),iR=MRR(false),tx=NT()}

-- ══════════════════════════════════════════════
-- STATE
-- ══════════════════════════════════════════════
local Open=true, CurTab=1
local Drag=false, DragOff=Vector2.new(0,0)
local MiniSide="left", MiniYPct=0.32
local DragSlider=false

local function Mouse() return UIS:GetMouseLocation() end
local function Hov(x,y,w,h) local m=Mouse();return m.X>=x and m.X<=x+w and m.Y>=y and m.Y<=y+h end
local function Clamp(v,a,b) return math.max(a,math.min(b,v)) end

-- ══════════════════════════════════════════════
-- TOGGLE DRAW
-- ══════════════════════════════════════════════
local function DrawToggle(c,x,y,on,msk)
    local W,H=50,26;local r=H/2
    local col=on and P.TgOn or P.TgOff
    -- track
    RR(c.tR,x,y,W,H,col,msk,r)
    -- knob shadow
    local kx=on and (x+W-r-1) or (x+r+1)
    dC(c.tGlow,kx,y+r,r-1,on and P.AccSoft or P.Black,true)
    -- knob
    dC(c.tKnob,kx,y+r,r-3,P.TgKnob,true)
end

local function HideCard(c)
    HRR(c.rr);c.bar.Visible=false;c.dot.Visible=false
    c.lbl.Visible=false;c.dsc.Visible=false
    HRR(c.tR);c.tKnob.Visible=false;c.tGlow.Visible=false
end

local function HideSettings()
    for _,d in ipairs({SET.ti,SET.l1,SET.l2,SET.l3,SET.l4,SET.slP,SET.div,SET.hkT}) do d.Visible=false end
    HRR(SET.slTR);HRR(SET.slFI);HRR(SET.hkR)
    SET.slH.Visible=false;SET.slHR.Visible=false;SET.slHC.Visible=false
    for i=1,2 do HRR(SET.sb[i].rr);SET.sb[i].tx.Visible=false end
    for i=1,3 do SET.act[i].nm.Visible=false;SET.act[i].ct.Visible=false;HRR(SET.act[i].tr);HRR(SET.act[i].fi) end
end

-- ══════════════════════════════════════════════
-- RENDER
-- ══════════════════════════════════════════════
local function Render()
    HA()

    -- MINI BUTTON
    if not Open then
        local mx=MiniSide=="left" and 10 or (VP.X-MBW-10)
        local my=Clamp(math.floor(VP.Y*MiniYPct-MBH/2),10,VP.Y-MBH-10)
        RR(MINI.rr, mx,my,MBW,MBH, P.Side,P.Base,18,P.AccDim,1.5)
        RR(MINI.iR, mx+MBW/2-13,my+MBH/2-13,26,26, P.Acc,P.Side,8)
        dT(MINI.tx, mx+MBW/2,my+MBH/2-9,"L",P.White,14,true)
        return
    end

    -- SIDEBAR PILL
    local nx,ny=GNP()
    RR(SB.rr, nx,ny,SW,SNAV_H, P.Side,P.Base,22,P.AccDim,1.5)

    for i=1,4 do
        local si=SB.items[i]
        local bx,by=GNI(i)
        local act=CurTab==i
        local hov=Hov(bx,by,SNAV_SZ,SNAV_SZ)
        -- button bg
        local bgC = act and P.SideAct or (hov and P.Card or P.Side)
        local bdC = act and P.Acc or nil
        RR(si.rr, bx,by,SNAV_SZ,SNAV_SZ, bgC,P.Side,14,bdC,1.5)
        -- active left bar
        if act then
            dS(si.rr.f, nx,by+SNAV_SZ/2-10,3,20, P.Acc) -- reuse obj trick? no, just draw
        end
        DrawIcon(si.IL,si.IC,i,bx+SNAV_SZ/2,by+SNAV_SZ/2, act and P.Acc or P.TxLow)
    end

    -- PANEL
    RR(UI.pan, PX,PY,PW,PH, P.Panel,P.Base,20,P.Border,1.5)

    -- Header accent line (top)
    dL(UI.hAcc, PX+20,PY+HDR-1, PX+PW-20,PY+HDR-1, P.AccLine,1)
    dL(UI.hSep, PX+16,PY+HDR,   PX+PW-16,PY+HDR,   P.Sep,1)

    -- Logo
    RR(UI.logoR, PX+14,PY+14,32,32, P.AccDim,P.Panel,10,P.AccLine,1.5)
    dT(UI.logoT, PX+30,PY+20,"L",P.White,16,true)
    dT(UI.hT1,  PX+55,PY+12,"LUXURY",P.TxHi,17)
    dT(UI.hT2,  PX+55+80,PY+12,"HUB",P.Acc,17)
    dT(UI.hSub, PX+56,PY+32,"PREMIUM CONTROLS",P.TxLow,8)

    -- Header buttons
    local BS=28;local cX=PX+PW-BS-12;local bY=PY+15;local nX2=cX-BS-7
    local cH=Hov(cX,bY,BS,BS);local nH=Hov(nX2,bY,BS,BS)
    RR(UI.clR, cX,bY,BS,BS, cH and P.Red or P.Surface,P.Panel,9)
    dL(UI.clX1, cX+9,bY+9,cX+BS-9,bY+BS-9, cH and P.White or P.TxMid,1.8)
    dL(UI.clX2, cX+BS-9,bY+9,cX+9,bY+BS-9, cH and P.White or P.TxMid,1.8)
    RR(UI.mnR, nX2,bY,BS,BS, nH and P.CardHov or P.Surface,P.Panel,9)
    dL(UI.mnL, nX2+8,bY+BS/2,nX2+BS-8,bY+BS/2, P.TxMid,2)

    -- CONTENT
    local CX=PX+PAD;local CY=PY+HDR+PAD;local CW=PW-PAD*2

    if CurTab==4 then
        HideSettings();for i=1,9 do HideCard(CARDS[i]) end
        local px=CX+4;local py=CY+8
        dT(SET.ti,px,py,"Appearance",P.TxHi,16);py=py+34
        dT(SET.l1,px,py,"REOPEN SIDE",P.TxLow,10);py=py+22
        local oW=math.floor((CW-14)/2)
        for si,side in ipairs({"left","right"}) do
            local ox=px+(si-1)*(oW+14)
            local sel=MiniSide==side;local h2=Hov(ox,py,oW,40)
            RR(SET.sb[si].rr,ox,py,oW,40,sel and P.CardOn or (h2 and P.CardHov or P.Card),P.Panel,12,sel and P.Acc or nil,1)
            dT(SET.sb[si].tx,ox+oW/2,py+13,side:sub(1,1):upper()..side:sub(2),sel and P.TxHi or P.TxMid,13,true)
        end;py=py+40+28
        dT(SET.l2,px,py,"VERTICAL POSITION",P.TxLow,10)
        dT(SET.slP,CX+CW-4,py,math.floor(MiniYPct*100).."%",P.Acc,11,true)
        py=py+22;local slW=CW-8
        RR(SET.slTR,px,py,slW,8,P.Surface,P.Panel,4)
        local fw=math.max(8,math.floor(MiniYPct*slW))
        RR(SET.slFI,px,py,fw,8,P.Acc,P.Panel,4)
        local hx=px+fw
        dC(SET.slH,hx,py+4,10,P.Card,true)
        dC(SET.slHR,hx,py+4,10,P.Acc,false,2)
        dC(SET.slHC,hx,py+4,4,P.Acc,true)
        py=py+36;dL(SET.div,CX,py,CX+CW,py,P.Sep,1);py=py+22
        dT(SET.l3,px,py,"HOTKEY",P.TxLow,10);py=py+22
        RR(SET.hkR,px,py,100,34,P.Surface,P.Panel,10,P.AccDim,1)
        dT(SET.hkT,px+50,py+11,"R-SHIFT",P.Acc,12,true)
        py=py+34+28;dT(SET.l4,px,py,"ACTIVITY",P.TxLow,10);py=py+22
        for ti=1,3 do
            local cnt=0;for _,it in ipairs(TABS[ti].items) do if it.state then cnt=cnt+1 end end
            local ar=SET.act[ti];local bW=CW-110
            dT(ar.nm,px,py-1,TABS[ti].name,P.TxMid,12)
            RR(ar.tr,px+65,py+1,bW,10,P.Surface,P.Panel,5)
            local bw=math.floor(cnt/#TABS[ti].items*bW)
            if bw>3 then RR(ar.fi,px+65,py+1,bw,10,P.Acc,P.Panel,5) else HRR(ar.fi) end
            dT(ar.ct,CX+CW-4,py-1,cnt.."/"..#TABS[ti].items,P.TxLow,11,true)
            py=py+22
        end
    else
        HideSettings()
        local items=TABS[CurTab].items
        for i=1,9 do
            local co=CARDS[i];local item=items[i]
            if not item then HideCard(co) else
                local ix=CX;local iy=CY+(i-1)*(ROW_H+ROW_GAP);local iw=CW
                local on=item.state;local hov=Hov(ix,iy,iw,ROW_H)
                -- Card background
                local bgC=on and P.CardOn or (hov and P.CardHov or P.Card)
                local bdC=on and P.BordOn or P.Border
                RR(co.rr,ix,iy,iw,ROW_H,bgC,P.Panel,14,bdC,1)
                -- Left accent bar
                if on then dS(co.bar,ix+10,iy+ROW_H/2-11,3,22,P.Acc);co.bar.Visible=true
                else co.bar.Visible=false end
                -- Dot
                dC(co.dot,ix+26,iy+ROW_H/2,5,on and P.Acc or P.TxFaint,true)
                -- Labels
                dT(co.lbl,ix+40,iy+ROW_H/2-11,item.label,on and P.TxHi or P.TxMid,14)
                dT(co.dsc,ix+41,iy+ROW_H/2+4, item.desc, on and P.TxMid or P.TxFaint,9)
                -- Toggle
                DrawToggle(co,ix+iw-50-12,iy+ROW_H/2-13,on,P.Panel)
            end
        end
    end

    -- FOOTER
    local FY=PY+PH-FTR
    dL(UI.fSep,PX+14,FY,PX+PW-14,FY,P.Sep,1)
    local cnt=0
    if CurTab<4 then for _,it in ipairs(TABS[CurTab].items) do if it.state then cnt=cnt+1 end end end
    local sc=(CurTab<4 and cnt>0) and P.Green or P.TxLow
    dC(UI.fDot,PX+20,FY+13,4,sc,true)
    dT(UI.fT1,PX+30,FY+7,CurTab<4 and (cnt.." active") or "settings",sc,9)
    local tn={"Main","Player","Other","Settings"}
    dT(UI.fT2,PX+PW/2,FY+7,tn[CurTab],P.TxMid,9,true)
    dT(UI.fT3,PX+PW-14,FY+7,"RShift",P.TxFaint,9,true)
end

RS.RenderStepped:Connect(Render)

-- ══════════════════════════════════════════════
-- INPUT
-- ══════════════════════════════════════════════
local function ClampP() PX=Clamp(PX,0,VP.X-PW);PY=Clamp(PY,0,VP.Y-PH) end

UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.RightShift then Open=not Open;return end
    if inp.UserInputType~=Enum.UserInputType.MouseButton1
    and inp.UserInputType~=Enum.UserInputType.Touch then return end
    local m=Mouse()

    if not Open then
        local mx=MiniSide=="left" and 10 or (VP.X-MBW-10)
        local my=Clamp(math.floor(VP.Y*MiniYPct-MBH/2),10,VP.Y-MBH-10)
        if Hov(mx,my,MBW,MBH) then Open=true end;return
    end

    local BS=28;local cX=PX+PW-BS-12;local bY=PY+15;local nX2=cX-BS-7
    if Hov(cX,bY,BS,BS) or Hov(nX2,bY,BS,BS) then Open=false;return end

    if CurTab==4 then
        local px=PX+PAD+4;local CW=PW-PAD*2
        local py0=PY+HDR+PAD+8+34+22
        local oW=math.floor((CW-14)/2)
        for si,side in ipairs({"left","right"}) do
            local ox=px+(si-1)*(oW+14)
            if Hov(ox,py0,oW,40) then MiniSide=side;return end
        end
        local slY=py0+40+28+22;local slW=CW-8
        if Hov(px-10,slY-10,slW+20,28) then
            DragSlider=true;MiniYPct=Clamp((m.X-px)/slW,0,1);return
        end
    end

    for i=1,4 do
        local bx,by=GNI(i)
        if Hov(bx,by,SNAV_SZ,SNAV_SZ) then CurTab=i;return end
    end

    if CurTab<4 then
        local CX=PX+PAD;local CY=PY+HDR+PAD;local CW=PW-PAD*2
        for i=1,9 do
            local iy=CY+(i-1)*(ROW_H+ROW_GAP)
            if Hov(CX,iy,CW,ROW_H) then DoToggle(CurTab,i);return end
        end
    end

    if Hov(PX,PY,PW-100,HDR) then Drag=true;DragOff=Vector2.new(m.X-PX,m.Y-PY) end
end)

UIS.InputChanged:Connect(function(inp)
    if inp.UserInputType~=Enum.UserInputType.MouseMovement
    and inp.UserInputType~=Enum.UserInputType.Touch then return end
    local m=Mouse()
    if Drag then PX=m.X-DragOff.X;PY=m.Y-DragOff.Y;ClampP() end
    if DragSlider then
        local px=PX+PAD+4;local slW=PW-PAD*2-8
        MiniYPct=Clamp((m.X-px)/slW,0,1)
    end
end)

UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1
    or inp.UserInputType==Enum.UserInputType.Touch then
        Drag=false;DragSlider=false
    end
end)

LP.CharacterAdded:Connect(function()
    task.wait(1)
    for ti=1,3 do
        for _,it in ipairs(TABS[ti].items) do
            if it.state then pcall(it.enable,it) end
        end
    end
end)

print("LUXURY HUB v14 - OK")
