-- LUXURY HUB v12 - NO CIRCLE CORNERS, pure rect rounding
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local Players = game:GetService("Players")
local LP      = Players.LocalPlayer
local VP      = workspace.CurrentCamera.ViewportSize

local BG      = Color3.fromRGB(12, 12, 16)
local BG2     = Color3.fromRGB(18, 18, 24)
local BG3     = Color3.fromRGB(24, 24, 32)
local CARD    = Color3.fromRGB(26, 26, 34)
local CARDON  = Color3.fromRGB(36, 36, 48)
local CARDHI  = Color3.fromRGB(30, 30, 40)
local ACCENT  = Color3.fromRGB(155, 155, 175)
local ACCDIM  = Color3.fromRGB(65,  65,  80)
local WHITE   = Color3.fromRGB(240, 240, 248)
local BLACK   = Color3.fromRGB(4,   4,   6)
local BORDER  = Color3.fromRGB(40,  40,  52)
local BORDON  = Color3.fromRGB(88,  88, 108)
local TRACK   = Color3.fromRGB(42,  42,  54)
local TXHI    = Color3.fromRGB(228, 228, 238)
local TXMID   = Color3.fromRGB(138, 138, 155)
local TXLOW   = Color3.fromRGB(82,  82,  98)
local TXFAINT = Color3.fromRGB(50,  50,  64)
local GREEN   = Color3.fromRGB(95,  205, 138)
local RED     = Color3.fromRGB(205, 82,  82)

local ROW_H   = 42
local ROW_GAP = 7
local HEADER  = 52
local FOOTER  = 28
local PAD     = 14
local NAV_W   = 56
local NAV_GAP = 16
local MBW,MBH = 38, 82

local PW = math.min(460, math.floor(VP.X * 0.50))
local PH = math.min(
    HEADER + 9*(ROW_H+ROW_GAP) - ROW_GAP + PAD*2 + FOOTER + PAD,
    math.floor(VP.Y * 0.93)
)
local PX = math.floor((VP.X - PW) / 2 + 36)
local PY = math.floor((VP.Y - PH) / 2)

local NAV_SZ = 48
local NAV_IG = 10
local NAV_H  = 4*NAV_SZ + 3*NAV_IG + 24

local function GetNavPos()
    return PX - NAV_W - NAV_GAP,
           PY + math.floor(PH/2 - NAV_H/2)
end
local function GetNavItem(i)
    local nx,ny = GetNavPos()
    return nx + math.floor((NAV_W-NAV_SZ)/2),
           ny + 12 + (i-1)*(NAV_SZ+NAV_IG)
end

-- ══════════════════════════════════════════════
-- FEATURES
-- ══════════════════════════════════════════════
local TABS = {
    {name="Main", items={
        {label="Infinite Jump", desc="Jump while in air", state=false, conn=nil,
         enable=function(it) it.conn=UIS.JumpRequest:Connect(function() pcall(function() local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end) end) end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},
        {label="Speed Boost", desc="WalkSpeed x2.5", state=false,
         enable=function() pcall(function() local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=40 end end) end,
         disable=function() pcall(function() local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=16 end end) end},
        {label="Anti-AFK", desc="Prevent idle kick", state=false, conn=nil,
         enable=function(it) it.conn=LP.Idled:Connect(function() pcall(function() local vu=game:GetService("VirtualUser") vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame) task.wait() vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame) end) end) end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},
        {label="Fly", desc="WASD + Space to fly", state=false, conn=nil, _bv=nil, _bg=nil,
         enable=function(it) pcall(function() local char=LP.Character;if not char then return end local root=char:FindFirstChild("HumanoidRootPart");if not root then return end local hum=char:FindFirstChildOfClass("Humanoid");if hum then hum.PlatformStand=true end local bv=Instance.new("BodyVelocity");bv.Velocity=Vector3.new(0,0,0);bv.MaxForce=Vector3.new(1e5,1e5,1e5);bv.Parent=root;it._bv=bv local bg=Instance.new("BodyGyro");bg.MaxTorque=Vector3.new(1e5,1e5,1e5);bg.D=100;bg.Parent=root;it._bg=bg it.conn=RS.RenderStepped:Connect(function() pcall(function() local cam=workspace.CurrentCamera;local d=Vector3.new(0,0,0) if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+cam.CFrame.LookVector end if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-cam.CFrame.LookVector end if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-cam.CFrame.RightVector end if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+cam.CFrame.RightVector end if UIS:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d=d-Vector3.new(0,1,0) end if d.Magnitude>0 then d=d.Unit end bv.Velocity=d*52;bg.CFrame=cam.CFrame end) end) end) end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end pcall(function() if it._bv then it._bv:Destroy();it._bv=nil end if it._bg then it._bg:Destroy();it._bg=nil end local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid");if h then h.PlatformStand=false end end) end},
        {label="No Clip", desc="Walk through walls", state=false, conn=nil,
         enable=function(it) it.conn=RS.Stepped:Connect(function() pcall(function() if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) end) end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end pcall(function() if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end end) end},
        {label="TEST-6", desc="Slot 6", state=false, enable=function()end, disable=function()end},
        {label="TEST-7", desc="Slot 7", state=false, enable=function()end, disable=function()end},
        {label="TEST-8", desc="Slot 8", state=false, enable=function()end, disable=function()end},
        {label="TEST-9", desc="Slot 9", state=false, enable=function()end, disable=function()end},
    }},
    {name="Player", items={
        {label="God Mode", desc="Infinite health", state=false, conn=nil,
         enable=function(it) it.conn=RS.Heartbeat:Connect(function() pcall(function() local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid");if h then h.Health=h.MaxHealth end end) end) end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},
        {label="High Jump", desc="JumpPower x3", state=false,
         enable=function() pcall(function() local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid");if h then h.JumpPower=150 end end) end,
         disable=function() pcall(function() local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid");if h then h.JumpPower=50 end end) end},
        {label="Invisible", desc="Hide character", state=false,
         enable=function() pcall(function() for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency=1 end end end) end,
         disable=function() pcall(function() for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency=0 elseif p:IsA("Decal") then p.Transparency=0 end end end) end},
        {label="Freeze", desc="Anchor character", state=false,
         enable=function() pcall(function() local r=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart");if r then r.Anchored=true end end) end,
         disable=function() pcall(function() local r=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart");if r then r.Anchored=false end end) end},
        {label="Low Gravity", desc="Gravity = 20", state=false,
         enable=function() pcall(function() workspace.Gravity=20 end) end,
         disable=function() pcall(function() workspace.Gravity=196.2 end) end},
        {label="TEST-6", desc="Slot 6", state=false, enable=function()end, disable=function()end},
        {label="TEST-7", desc="Slot 7", state=false, enable=function()end, disable=function()end},
        {label="TEST-8", desc="Slot 8", state=false, enable=function()end, disable=function()end},
        {label="TEST-9", desc="Slot 9", state=false, enable=function()end, disable=function()end},
    }},
    {name="Other", items={
        {label="Full Bright", desc="Max ambient light", state=false, _old=nil,
         enable=function(it) pcall(function() it._old={a=game.Lighting.Ambient,o=game.Lighting.OutdoorAmbient,b=game.Lighting.Brightness} game.Lighting.Ambient=Color3.fromRGB(255,255,255);game.Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255);game.Lighting.Brightness=2 end) end,
         disable=function(it) pcall(function() if it._old then game.Lighting.Ambient=it._old.a;game.Lighting.OutdoorAmbient=it._old.o;game.Lighting.Brightness=it._old.b end end) end},
        {label="Time: Noon", desc="ClockTime = 12", state=false,
         enable=function() pcall(function() game.Lighting.ClockTime=12 end) end, disable=function()end},
        {label="No Fog", desc="Remove all fog", state=false, _old=nil,
         enable=function(it) pcall(function() it._old={s=game.Lighting.FogStart,e=game.Lighting.FogEnd};game.Lighting.FogStart=0;game.Lighting.FogEnd=1e6 end) end,
         disable=function(it) pcall(function() if it._old then game.Lighting.FogStart=it._old.s;game.Lighting.FogEnd=it._old.e end end) end},
        {label="ESP Players", desc="Names over heads", state=false, _bills={},
         enable=function(it) pcall(function() for _,pl in ipairs(Players:GetPlayers()) do if pl~=LP and pl.Character then local root=pl.Character:FindFirstChild("HumanoidRootPart");if root then local bb=Instance.new("BillboardGui",root);bb.Size=UDim2.new(0,100,0,32);bb.StudsOffset=Vector3.new(0,3.5,0);bb.AlwaysOnTop=true;local lb=Instance.new("TextLabel",bb);lb.Size=UDim2.new(1,0,1,0);lb.BackgroundTransparency=1;lb.TextColor3=WHITE;lb.TextStrokeTransparency=0;lb.Text=pl.Name;lb.Font=Enum.Font.GothamBold;lb.TextSize=14;table.insert(it._bills,bb) end end end end) end,
         disable=function(it) for _,b in ipairs(it._bills) do pcall(function() b:Destroy() end) end;it._bills={} end},
        {label="Low Gravity", desc="Float around", state=false,
         enable=function() pcall(function() workspace.Gravity=15 end) end,
         disable=function() pcall(function() workspace.Gravity=196.2 end) end},
        {label="TEST-6", desc="Slot 6", state=false, enable=function()end, disable=function()end},
        {label="TEST-7", desc="Slot 7", state=false, enable=function()end, disable=function()end},
        {label="TEST-8", desc="Slot 8", state=false, enable=function()end, disable=function()end},
        {label="TEST-9", desc="Slot 9", state=false, enable=function()end, disable=function()end},
    }},
}

local function DoToggle(ti,ii)
    local item=TABS[ti] and TABS[ti].items[ii]
    if not item then return end
    item.state=not item.state
    if item.state then pcall(item.enable,item) else pcall(item.disable,item) end
end

-- ══════════════════════════════════════════════
-- DRAWING - ONLY SQUARES AND LINES, NO CIRCLES FOR ROUNDING
-- ══════════════════════════════════════════════
local ALL={}
local function NSq() local d=Drawing.new("Square");d.Filled=true;d.Visible=false;d.Thickness=1;ALL[#ALL+1]=d;return d end
local function NLn() local d=Drawing.new("Line");d.Visible=false;d.Thickness=1;ALL[#ALL+1]=d;return d end
local function NCi() local d=Drawing.new("Circle");d.Filled=true;d.NumSides=32;d.Visible=false;d.Thickness=1;ALL[#ALL+1]=d;return d end
local function NTx() local d=Drawing.new("Text");d.Outline=true;d.OutlineColor=BLACK;d.Size=14;d.Visible=false;ALL[#ALL+1]=d;return d end

local function HA() for _,d in ipairs(ALL) do d.Visible=false end end

local function dS(d,x,y,w,h,c)         d.Position=Vector2.new(x,y);d.Size=Vector2.new(w,h);d.Color=c;d.Filled=true;d.Visible=true end
local function dL(d,x1,y1,x2,y2,c,th) d.From=Vector2.new(x1,y1);d.To=Vector2.new(x2,y2);d.Color=c;d.Thickness=th or 1;d.Visible=true end
local function dC(d,x,y,r,c,f,th)     d.Position=Vector2.new(x,y);d.Radius=r;d.Color=c;d.Filled=f~=false;d.Thickness=th or 1;d.Visible=true end
local function dT(d,x,y,t,c,sz,ctr)   d.Position=Vector2.new(x,y);d.Text=tostring(t);d.Color=c;d.Size=sz or 14;d.Center=ctr or false;d.Visible=true end

-- ══════════════════════════════════════════════
-- ROUNDED RECT - uses only Squares + overlay to mask corners
-- Approach: draw big rect, then draw small corner-masking squares
-- on top using the PARENT background color to "cut" the corners
-- ══════════════════════════════════════════════

-- Simple filled rounded rect: center + 4 strips (no corner circles)
-- r = corner size in pixels (small values like 6-10 look clean)
local function FillRR(squares, x,y,w,h,c,r)
    -- 3 rects that together fill a rounded shape:
    -- horizontal full-width (minus corners height)
    -- vertical strips on left/right
    dS(squares[1], x,   y+r, w,   h-r*2, c)  -- center column
    dS(squares[2], x+r, y,   w-r*2, r,   c)  -- top strip
    dS(squares[3], x+r, y+h-r, w-r*2, r, c)  -- bottom strip
    -- corner squares (small, same color)
    dS(squares[4], x+r-3,   y+r-3,   6, 6, c)
    dS(squares[5], x+w-r-3, y+r-3,   6, 6, c)
    dS(squares[6], x+r-3,   y+h-r-3, 6, 6, c)
    dS(squares[7], x+w-r-3, y+h-r-3, 6, 6, c)
end

-- Border: 4 lines only, straight
local function DrawBorder(lines, x,y,w,h,c,r,th)
    r=r or 8; th=th or 1.2
    dL(lines[1], x+r, y,     x+w-r, y,     c, th)
    dL(lines[2], x+r, y+h,   x+w-r, y+h,   c, th)
    dL(lines[3], x,   y+r,   x,     y+h-r, c, th)
    dL(lines[4], x+w, y+r,   x+w,   y+h-r, c, th)
end

local function HideBorder(lines)
    for _,d in ipairs(lines) do d.Visible=false end
end

-- Make a rounded rect object
local function MRR(hasBorder)
    local o={sq={NSq(),NSq(),NSq(),NSq(),NSq(),NSq(),NSq()}}
    if hasBorder then
        o.bd={NLn(),NLn(),NLn(),NLn()}
    end
    return o
end

local function DRR(o,x,y,w,h,bg,bc,r,bt)
    r=math.min(r or 10, math.floor(w/2)-1, math.floor(h/2)-1)
    FillRR(o.sq,x,y,w,h,bg,r)
    if o.bd then
        if bc then DrawBorder(o.bd,x,y,w,h,bc,r,bt or 1.2)
        else HideBorder(o.bd) end
    end
end

local function HRR(o)
    for _,d in ipairs(o.sq) do d.Visible=false end
    if o.bd then HideBorder(o.bd) end
end

-- Icons: lines only
local function MIL(n) local t={} for i=1,n do t[i]=NLn() end return t end
local function MIC(n) local t={} for i=1,n do t[i]=NCi() end return t end

local function DrawIcon(IL,IC,idx,cx,cy,col)
    for _,d in ipairs(IL) do d.Visible=false end
    for _,d in ipairs(IC) do d.Visible=false end
    if idx==1 then
        dL(IL[1],cx-8,cy+1,cx,cy-8,col,2)
        dL(IL[2],cx,cy-8,cx+8,cy+1,col,2)
        dL(IL[3],cx-6,cy+1,cx-6,cy+9,col,2)
        dL(IL[4],cx+6,cy+1,cx+6,cy+9,col,2)
        dL(IL[5],cx-6,cy+9,cx+6,cy+9,col,2)
        dL(IL[6],cx-2,cy+4,cx-2,cy+9,col,2)
        dL(IL[7],cx+2,cy+4,cx+2,cy+9,col,2)
        dL(IL[8],cx-2,cy+4,cx+2,cy+4,col,2)
    elseif idx==2 then
        dC(IC[1],cx,cy-5,4.5,col,false,2)
        dL(IL[1],cx-8,cy+9,cx-7,cy+2,col,2)
        dL(IL[2],cx-7,cy+2,cx+7,cy+2,col,2)
        dL(IL[3],cx+7,cy+2,cx+8,cy+9,col,2)
        dL(IL[4],cx-8,cy+9,cx+8,cy+9,col,2)
    elseif idx==3 then
        dC(IC[1],cx-7,cy-5,3.5,col,false,2)
        dC(IC[2],cx+7,cy-5,3.5,col,false,2)
        dL(IL[1],cx-12,cy+7,cx-11,cy+1,col,2)
        dL(IL[2],cx-11,cy+1,cx-2,cy+1,col,2)
        dL(IL[3],cx-2,cy+1,cx-2,cy+7,col,2)
        dL(IL[4],cx-12,cy+7,cx-2,cy+7,col,2)
        dL(IL[5],cx+2,cy+1,cx+11,cy+1,col,2)
        dL(IL[6],cx+11,cy+1,cx+12,cy+7,col,2)
        dL(IL[7],cx+2,cy+7,cx+12,cy+7,col,2)
        dL(IL[8],cx+2,cy+1,cx+2,cy+7,col,2)
    elseif idx==4 then
        dC(IC[1],cx,cy,7,col,false,2)
        dC(IC[2],cx,cy,3,col,false,2)
        for t=0,7 do
            local a=(t/8)*math.pi*2
            dL(IL[t+1],cx+math.cos(a)*7,cy+math.sin(a)*7,cx+math.cos(a)*11,cy+math.sin(a)*11,col,2)
        end
    end
end

-- ══════════════════════════════════════════════
-- PRE-CREATE OBJECTS
-- ══════════════════════════════════════════════
local P={
    rr=MRR(true), hLn=NLn(),
    logo=MRR(false), logT=NTx(),
    t1=NTx(),t2=NTx(),sub=NTx(),
    clRR=MRR(false),clX1=NLn(),clX2=NLn(),
    mnRR=MRR(false),mnLn=NLn(),
    fLn=NLn(),fDot=NCi(),fT1=NTx(),fT2=NTx(),fT3=NTx(),
}

local NAV={rr=MRR(true),items={}}
for i=1,4 do
    NAV.items[i]={rr=MRR(true),IL=MIL(10),IC=MIC(3)}
end

local CARDS={}
for i=1,9 do
    CARDS[i]={
        rr=MRR(true),bar=NSq(),dot=NSq(),
        lbl=NTx(),dsc=NTx(),
        -- toggle: track rect + knob circle
        tBg=MRR(false),knob=NCi(),
    }
end

local SET={
    ti=NTx(),l1=NTx(),l2=NTx(),l3=NTx(),l4=NTx(),
    sb={{rr=MRR(true),tx=NTx()},{rr=MRR(true),tx=NTx()}},
    slTR=MRR(false),slFI=MRR(false),
    slDt=NCi(),slRi=NCi(),slCt=NCi(),slP=NTx(),
    div=NLn(),hkRR=MRR(true),hkTx=NTx(),act={},
}
for i=1,3 do SET.act[i]={nm=NTx(),tr=MRR(false),fi=MRR(false),ct=NTx()} end

local MINI={rr=MRR(true),lRR=MRR(false),tx=NTx()}

-- ══════════════════════════════════════════════
-- STATE + HELPERS
-- ══════════════════════════════════════════════
local Open=true
local CurTab=1
local Drag=false
local DragOff=Vector2.new(0,0)
local MiniSide="left"
local MiniYPct=0.32
local DragSlider=false

local function Mouse() return UIS:GetMouseLocation() end
local function Hov(x,y,w,h) local m=Mouse();return m.X>=x and m.X<=x+w and m.Y>=y and m.Y<=y+h end
local function Clamp(v,a,b) return math.max(a,math.min(b,v)) end

-- Toggle: simple track + knob (no circles on track ends)
local function DrawTog(c,x,y,on)
    local W,H=44,22
    DRR(c.tBg,x,y,W,H,on and ACCENT or TRACK,nil,H/2)
    local kR=H/2-3
    local kx=on and (x+W-kR-4) or (x+kR+4)
    dC(c.knob,kx,y+H/2,kR,WHITE,true)
end

local function HideCard(c)
    HRR(c.rr);c.bar.Visible=false;c.dot.Visible=false
    c.lbl.Visible=false;c.dsc.Visible=false
    HRR(c.tBg);c.knob.Visible=false
end

local function HideSettings()
    for _,d in ipairs({SET.ti,SET.l1,SET.l2,SET.l3,SET.l4,SET.slP,SET.div,SET.hkTx}) do d.Visible=false end
    HRR(SET.slTR);HRR(SET.slFI);HRR(SET.hkRR)
    SET.slDt.Visible=false;SET.slRi.Visible=false;SET.slCt.Visible=false
    for i=1,2 do HRR(SET.sb[i].rr);SET.sb[i].tx.Visible=false end
    for i=1,3 do SET.act[i].nm.Visible=false;SET.act[i].ct.Visible=false;HRR(SET.act[i].tr);HRR(SET.act[i].fi) end
end

-- ══════════════════════════════════════════════
-- RENDER
-- ══════════════════════════════════════════════
local function Render()
    HA()

    if not Open then
        local mx=MiniSide=="left" and 10 or (VP.X-MBW-10)
        local my=Clamp(math.floor(VP.Y*MiniYPct-MBH/2),10,VP.Y-MBH-10)
        DRR(MINI.rr,  mx,my,MBW,MBH,  BG2,ACCDIM,10,1.2)
        DRR(MINI.lRR, mx+MBW/2-11,my+MBH/2-11,22,22, BG3,nil,7)
        dT(MINI.tx,   mx+MBW/2,my+MBH/2-8,"L",TXHI,13,true)
        return
    end

    -- NAV PILL
    local nx,ny=GetNavPos()
    DRR(NAV.rr,nx,ny,NAV_W,NAV_H,BG2,ACCDIM,16,1.2)
    for i=1,4 do
        local ni=NAV.items[i]
        local bx,by=GetNavItem(i)
        local act=CurTab==i
        local hov=Hov(bx,by,NAV_SZ,NAV_SZ)
        DRR(ni.rr,bx,by,NAV_SZ,NAV_SZ,
            act and CARDON or (hov and CARDHI or CARD),
            act and BORDON or nil, 10, 1.2)
        DrawIcon(ni.IL,ni.IC,i,bx+NAV_SZ/2,by+NAV_SZ/2,act and ACCENT or TXLOW)
    end

    -- PANEL
    DRR(P.rr,PX,PY,PW,PH,BG,ACCDIM,14,1.2)
    dL(P.hLn,PX+16,PY+HEADER,PX+PW-16,PY+HEADER,BORDER,1)

    DRR(P.logo,PX+14,PY+12,30,30,BG3,nil,8)
    dT(P.logT,PX+29,PY+18,"L",TXHI,15,true)
    dT(P.t1,  PX+52,PY+10,"LUXURY",TXHI,17)
    dT(P.t2,  PX+52+76,PY+10,"HUB",TXMID,17)
    dT(P.sub, PX+53,PY+30,"PREMIUM CONTROLS",TXLOW,8)

    local BS=28;local cX=PX+PW-BS-12;local bY=PY+12;local nX2=cX-BS-7
    local cH=Hov(cX,bY,BS,BS);local nH=Hov(nX2,bY,BS,BS)
    DRR(P.clRR,cX,bY,BS,BS,cH and RED or BG3,nil,8)
    dL(P.clX1,cX+9,bY+9,cX+BS-9,bY+BS-9,cH and WHITE or TXMID,1.8)
    dL(P.clX2,cX+BS-9,bY+9,cX+9,bY+BS-9,cH and WHITE or TXMID,1.8)
    DRR(P.mnRR,nX2,bY,BS,BS,nH and CARDHI or BG3,nil,8)
    dL(P.mnLn,nX2+8,bY+BS/2,nX2+BS-8,bY+BS/2,TXMID,2)

    local CX=PX+PAD;local CY=PY+HEADER+PAD;local CW=PW-PAD*2

    if CurTab==4 then
        HideSettings()
        for i=1,9 do HideCard(CARDS[i]) end
        local px=CX+4;local py=CY+6
        dT(SET.ti,px,py,"Appearance",TXHI,16);py=py+32
        dT(SET.l1,px,py,"REOPEN SIDE",TXLOW,10);py=py+22
        local optW=math.floor((CW-14)/2)
        for si,side in ipairs({"left","right"}) do
            local ox=px+(si-1)*(optW+14)
            local sel=MiniSide==side
            local hov=Hov(ox,py,optW,38)
            DRR(SET.sb[si].rr,ox,py,optW,38,sel and CARDON or (hov and CARDHI or CARD),sel and BORDON or nil,9,1)
            dT(SET.sb[si].tx,ox+optW/2,py+12,side:sub(1,1):upper()..side:sub(2),sel and TXHI or TXMID,13,true)
        end
        py=py+38+28
        dT(SET.l2,px,py,"VERTICAL POSITION",TXLOW,10)
        dT(SET.slP,CX+CW-4,py,math.floor(MiniYPct*100).."%",ACCENT,11,true)
        py=py+22
        local slW=CW-8
        DRR(SET.slTR,px,py,slW,8,TRACK,nil,4)
        local fw=math.max(8,math.floor(MiniYPct*slW))
        DRR(SET.slFI,px,py,fw,8,ACCENT,nil,4)
        local hx=px+fw
        dC(SET.slDt,hx,py+4,9,BG3,true)
        dC(SET.slRi,hx,py+4,9,ACCENT,false,2)
        dC(SET.slCt,hx,py+4,3,ACCENT,true)
        py=py+36
        dL(SET.div,CX,py,CX+CW,py,BORDER,1);py=py+22
        dT(SET.l3,px,py,"HOTKEY",TXLOW,10);py=py+22
        DRR(SET.hkRR,px,py,96,32,BG3,ACCDIM,8,1)
        dT(SET.hkTx,px+48,py+10,"R-SHIFT",ACCENT,12,true)
        py=py+32+28
        dT(SET.l4,px,py,"ACTIVITY",TXLOW,10);py=py+22
        for ti=1,3 do
            local cnt=0
            for _,it in ipairs(TABS[ti].items) do if it.state then cnt=cnt+1 end end
            local ar=SET.act[ti];local barW=CW-100
            dT(ar.nm,px,py-1,TABS[ti].name,TXMID,12)
            DRR(ar.tr,px+60,py+1,barW,10,TRACK,nil,5)
            local bw=math.floor(cnt/#TABS[ti].items*barW)
            if bw>2 then DRR(ar.fi,px+60,py+1,bw,10,ACCENT,nil,5) else HRR(ar.fi) end
            dT(ar.ct,CX+CW-4,py-1,cnt.."/"..#TABS[ti].items,TXLOW,11,true)
            py=py+22
        end
    else
        HideSettings()
        local items=TABS[CurTab].items
        for i=1,9 do
            local co=CARDS[i]
            local item=items[i]
            if not item then
                HideCard(co)
            else
                local ix=CX;local iy=CY+(i-1)*(ROW_H+ROW_GAP);local iw=CW
                local on=item.state;local hov=Hov(ix,iy,iw,ROW_H)
                DRR(co.rr,ix,iy,iw,ROW_H,
                    on and CARDON or (hov and CARDHI or CARD),
                    on and BORDON or BORDER, 10, 1)
                -- left accent bar
                if on then dS(co.bar,ix+9,iy+ROW_H/2-9,3,18,ACCENT);co.bar.Visible=true
                else co.bar.Visible=false end
                -- dot indicator (small square instead of circle)
                dS(co.dot,ix+22,iy+ROW_H/2-4,8,8,on and ACCENT or TXFAINT)
                dT(co.lbl,ix+38,iy+ROW_H/2-10,item.label,on and TXHI or TXMID,13)
                dT(co.dsc,ix+39,iy+ROW_H/2+4, item.desc, on and TXMID or TXFAINT,9)
                DrawTog(co,ix+iw-44-10,iy+ROW_H/2-11,on)
            end
        end
    end

    -- Footer
    local FY=PY+PH-FOOTER
    dL(P.fLn,PX+14,FY,PX+PW-14,FY,BORDER,1)
    local cnt=0
    if CurTab<4 then for _,it in ipairs(TABS[CurTab].items) do if it.state then cnt=cnt+1 end end end
    local sc=(CurTab<4 and cnt>0) and GREEN or TXLOW
    dC(P.fDot,PX+18,FY+12,3,sc,true)
    dT(P.fT1,PX+26,FY+6,CurTab<4 and (cnt.." active") or "settings",sc,9)
    local tn={"Main","Player","Other","Settings"}
    dT(P.fT2,PX+PW/2,FY+6,tn[CurTab],TXMID,9,true)
    dT(P.fT3,PX+PW-14,FY+6,"RShift",TXFAINT,9,true)
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
        if Hov(mx,my,MBW,MBH) then Open=true end
        return
    end

    local BS=28;local cX=PX+PW-BS-12;local bY=PY+12;local nX2=cX-BS-7
    if Hov(cX,bY,BS,BS) or Hov(nX2,bY,BS,BS) then Open=false;return end

    if CurTab==4 then
        local px=PX+PAD+4;local CW=PW-PAD*2
        local py0=PY+HEADER+PAD+6+32+22
        local optW=math.floor((CW-14)/2)
        for si,side in ipairs({"left","right"}) do
            local ox=px+(si-1)*(optW+14)
            if Hov(ox,py0,optW,38) then MiniSide=side;return end
        end
        local slY=py0+38+28+22
        local slW=CW-8
        if Hov(px-10,slY-10,slW+20,28) then
            DragSlider=true
            MiniYPct=Clamp((m.X-px)/slW,0,1)
            return
        end
    end

    for i=1,4 do
        local bx,by=GetNavItem(i)
        if Hov(bx,by,NAV_SZ,NAV_SZ) then CurTab=i;return end
    end

    if CurTab<4 then
        local CX=PX+PAD;local CY=PY+HEADER+PAD;local CW=PW-PAD*2
        for i=1,9 do
            local iy=CY+(i-1)*(ROW_H+ROW_GAP)
            if Hov(CX,iy,CW,ROW_H) then DoToggle(CurTab,i);return end
        end
    end

    if Hov(PX,PY,PW-100,HEADER) then
        Drag=true;DragOff=Vector2.new(m.X-PX,m.Y-PY)
    end
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

print("LUXURY HUB v12 - No circle corners")
