-- LUXURY HUB v15 FIXED
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local Players = game:GetService("Players")
local LP      = Players.LocalPlayer

local function GetVP() return workspace.CurrentCamera.ViewportSize end

local C = {
    Base    = Color3.fromRGB(10, 10, 14),
    Panel   = Color3.fromRGB(16, 17, 23),
    Surface = Color3.fromRGB(22, 23, 32),
    Card    = Color3.fromRGB(26, 28, 38),
    CardHov = Color3.fromRGB(32, 34, 46),
    CardOn  = Color3.fromRGB(30, 30, 50),
    Side    = Color3.fromRGB(18, 19, 27),
    SideAct = Color3.fromRGB(28, 30, 46),
    Acc     = Color3.fromRGB(139, 92, 246),
    AccSoft = Color3.fromRGB(109, 72, 196),
    AccDim  = Color3.fromRGB(60,  45, 110),
    AccLine = Color3.fromRGB(88,  56, 180),
    TgOn    = Color3.fromRGB(139, 92, 246),
    TgOff   = Color3.fromRGB(45,  46, 62),
    TgKnob  = Color3.fromRGB(255, 255, 255),
    TxHi    = Color3.fromRGB(240, 240, 252),
    TxMid   = Color3.fromRGB(155, 158, 185),
    TxLow   = Color3.fromRGB(88,  90, 115),
    TxFaint = Color3.fromRGB(52,  54, 72),
    Sep     = Color3.fromRGB(30,  32, 46),
    Border  = Color3.fromRGB(38,  40, 58),
    BordOn  = Color3.fromRGB(100, 70, 200),
    White   = Color3.fromRGB(255, 255, 255),
    Black   = Color3.fromRGB(0,   0,   0),
    Red     = Color3.fromRGB(220, 75,  75),
    Green   = Color3.fromRGB(80,  210, 130),
}

local ROW_H   = 44
local ROW_GAP = 5
local HDR     = 56
local FTR     = 28
local PAD     = 14
local SW      = 58
local SGAP    = 16
local MBW,MBH = 40, 86

local PW, PH, PX, PY

local function RecalcLayout()
    local VP = GetVP()
    PW = math.min(480, math.floor(VP.X * 0.50))
    PH = math.min(
        HDR + 9*(ROW_H+ROW_GAP) - ROW_GAP + PAD*2 + FTR + PAD,
        math.floor(VP.Y * 0.92)
    )
    PX = math.floor((VP.X - PW)/2 + 36)
    PY = math.floor((VP.Y - PH)/2)
end
RecalcLayout()

local SNAV_SZ  = 44
local SNAV_GAP = 8
local SNAV_H   = 4*SNAV_SZ + 3*SNAV_GAP + 24

local function GNP()
    return PX - SW - SGAP, PY + math.floor(PH/2 - SNAV_H/2)
end
local function GNI(i)
    local nx,ny = GNP()
    return nx + math.floor((SW-SNAV_SZ)/2), ny+12+(i-1)*(SNAV_SZ+SNAV_GAP)
end

-- ══════════════════════════════════════════════
-- FEATURES
-- ══════════════════════════════════════════════
local TABS = {
    {name="Main", items={
        {label="Infinite Jump", desc="Jump while in air", state=false, conn=nil,
         enable=function(it)
             it.conn=UIS.JumpRequest:Connect(function()
                 pcall(function()
                     local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                     if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Speed Boost", desc="WalkSpeed x2.5", state=false,
         enable=function()
             pcall(function()
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.WalkSpeed=40 end
             end)
         end,
         disable=function()
             pcall(function()
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.WalkSpeed=16 end
             end)
         end},

        {label="Anti-AFK", desc="Prevent idle kick", state=false, conn=nil,
         enable=function(it)
             it.conn=LP.Idled:Connect(function()
                 pcall(function()
                     local v=game:GetService("VirtualUser")
                     v:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                     task.wait()
                     v:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Fly", desc="WASD + Space", state=false, conn=nil, _bv=nil, _bg=nil,
         enable=function(it)
             pcall(function()
                 local ch=LP.Character
                 if not ch then return end
                 local root=ch:FindFirstChild("HumanoidRootPart")
                 if not root then return end
                 local hum=ch:FindFirstChildOfClass("Humanoid")
                 if hum then hum.PlatformStand=true end
                 local bv=Instance.new("BodyVelocity")
                 bv.Velocity=Vector3.new(0,0,0)
                 bv.MaxForce=Vector3.new(1e5,1e5,1e5)
                 bv.Parent=root
                 it._bv=bv
                 local bg=Instance.new("BodyGyro")
                 bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
                 bg.D=100
                 bg.Parent=root
                 it._bg=bg
                 it.conn=RS.RenderStepped:Connect(function()
                     pcall(function()
                         local cam=workspace.CurrentCamera
                         local d=Vector3.new(0,0,0)
                         if UIS:IsKeyDown(Enum.KeyCode.W) then d=Vector3.new(d.X+cam.CFrame.LookVector.X, d.Y+cam.CFrame.LookVector.Y, d.Z+cam.CFrame.LookVector.Z) end
                         if UIS:IsKeyDown(Enum.KeyCode.S) then d=Vector3.new(d.X-cam.CFrame.LookVector.X, d.Y-cam.CFrame.LookVector.Y, d.Z-cam.CFrame.LookVector.Z) end
                         if UIS:IsKeyDown(Enum.KeyCode.A) then d=Vector3.new(d.X-cam.CFrame.RightVector.X, d.Y-cam.CFrame.RightVector.Y, d.Z-cam.CFrame.RightVector.Z) end
                         if UIS:IsKeyDown(Enum.KeyCode.D) then d=Vector3.new(d.X+cam.CFrame.RightVector.X, d.Y+cam.CFrame.RightVector.Y, d.Z+cam.CFrame.RightVector.Z) end
                         if UIS:IsKeyDown(Enum.KeyCode.Space) then d=Vector3.new(d.X,d.Y+1,d.Z) end
                         if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d=Vector3.new(d.X,d.Y-1,d.Z) end
                         if d.Magnitude>0 then d=d.Unit end
                         bv.Velocity=d*55
                         bg.CFrame=cam.CFrame
                     end)
                 end)
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             pcall(function()
                 if it._bv then it._bv:Destroy();it._bv=nil end
                 if it._bg then it._bg:Destroy();it._bg=nil end
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.PlatformStand=false end
             end)
         end},

        {label="No Clip", desc="Walk through walls", state=false, conn=nil,
         enable=function(it)
             it.conn=RS.Stepped:Connect(function()
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
             if it.conn then it.conn:Disconnect();it.conn=nil end
             pcall(function()
                 if LP.Character then
                     for _,p in ipairs(LP.Character:GetDescendants()) do
                         if p:IsA("BasePart") then p.CanCollide=true end
                     end
                 end
             end)
         end},

        {label="TEST-6",desc="Slot 6",state=false,enable=function()end,disable=function()end},
        {label="TEST-7",desc="Slot 7",state=false,enable=function()end,disable=function()end},
        {label="TEST-8",desc="Slot 8",state=false,enable=function()end,disable=function()end},
        {label="TEST-9",desc="Slot 9",state=false,enable=function()end,disable=function()end},
    }},

    {name="Player", items={
        {label="God Mode", desc="Max health loop", state=false, conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                     if h then h.Health=h.MaxHealth end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="High Jump", desc="JumpPower x3", state=false,
         enable=function()
             pcall(function()
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.JumpPower=150 end
             end)
         end,
         disable=function()
             pcall(function()
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.JumpPower=50 end
             end)
         end},

        {label="Invisible", desc="Hide character", state=false,
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
         end},

        {label="Freeze", desc="Anchor character", state=false,
         enable=function()
             pcall(function()
                 local r=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                 if r then r.Anchored=true end
             end)
         end,
         disable=function()
             pcall(function()
                 local r=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                 if r then r.Anchored=false end
             end)
         end},

        {label="Low Gravity", desc="Gravity = 20", state=false,
         enable=function() pcall(function() workspace.Gravity=20 end) end,
         disable=function() pcall(function() workspace.Gravity=196.2 end) end},

        {label="TEST-6",desc="Slot 6",state=false,enable=function()end,disable=function()end},
        {label="TEST-7",desc="Slot 7",state=false,enable=function()end,disable=function()end},
        {label="TEST-8",desc="Slot 8",state=false,enable=function()end,disable=function()end},
        {label="TEST-9",desc="Slot 9",state=false,enable=function()end,disable=function()end},
    }},

    {name="Other", items={
        {label="Full Bright", desc="Max ambient", state=false, _old=nil,
         enable=function(it)
             pcall(function()
                 it._old={a=game.Lighting.Ambient,o=game.Lighting.OutdoorAmbient,b=game.Lighting.Brightness}
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
         end},

        {label="Time: Noon", desc="ClockTime = 12", state=false,
         enable=function() pcall(function() game.Lighting.ClockTime=12 end) end,
         disable=function() end},

        {label="No Fog", desc="Remove all fog", state=false, _old=nil,
         enable=function(it)
             pcall(function()
                 it._old={s=game.Lighting.FogStart,e=game.Lighting.FogEnd}
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
         end},

        {label="ESP Players", desc="Names over heads", state=false, _bills={},
         enable=function(it)
             pcall(function()
                 for _,pl in ipairs(Players:GetPlayers()) do
                     if pl~=LP and pl.Character then
                         local root=pl.Character:FindFirstChild("HumanoidRootPart")
                         if root then
                             local bb=Instance.new("BillboardGui",root)
                             bb.Size=UDim2.new(0,100,0,32)
                             bb.StudsOffset=Vector3.new(0,3.5,0)
                             bb.AlwaysOnTop=true
                             local lb=Instance.new("TextLabel",bb)
                             lb.Size=UDim2.new(1,0,1,0)
                             lb.BackgroundTransparency=1
                             lb.TextColor3=C.White
                             lb.TextStrokeTransparency=0
                             lb.Text=pl.Name
                             lb.Font=Enum.Font.GothamBold
                             lb.TextSize=14
                             table.insert(it._bills,bb)
                         end
                     end
                 end
             end)
         end,
         disable=function(it)
             for _,b in ipairs(it._bills) do pcall(function() b:Destroy() end) end
             it._bills={}
         end},

        {label="Low Gravity", desc="Float around", state=false,
         enable=function() pcall(function() workspace.Gravity=15 end) end,
         disable=function() pcall(function() workspace.Gravity=196.2 end) end},

        {label="TEST-6",desc="Slot 6",state=false,enable=function()end,disable=function()end},
        {label="TEST-7",desc="Slot 7",state=false,enable=function()end,disable=function()end},
        {label="TEST-8",desc="Slot 8",state=false,enable=function()end,disable=function()end},
        {label="TEST-9",desc="Slot 9",state=false,enable=function()end,disable=function()end},
    }},
}

local function DoToggle(ti,ii)
    local item=TABS[ti] and TABS[ti].items[ii]
    if not item then return end
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
local function NT() local d=Drawing.new("Text");d.Outline=true;d.OutlineColor=C.Black;d.Size=14;d.Visible=false;ALL[#ALL+1]=d;return d end

local function HA() for _,d in ipairs(ALL) do d.Visible=false end end

local function dS(d,x,y,w,h,col,tr)
    d.Position=Vector2.new(x,y)
    d.Size=Vector2.new(math.max(1,w),math.max(1,h))
    d.Color=col
    d.Transparency=tr or 1
    d.Visible=true
end
local function dL(d,x1,y1,x2,y2,col,th)
    d.From=Vector2.new(x1,y1)
    d.To=Vector2.new(x2,y2)
    d.Color=col
    d.Thickness=th or 1
    d.Visible=true
end
local function dC(d,x,y,r,col,f,th)
    d.Position=Vector2.new(x,y)
    d.Radius=math.max(1,r)
    d.Color=col
    d.Filled=f~=false
    d.Thickness=th or 1
    d.Visible=true
end
local function dT(d,x,y,t,col,sz,ctr)
    d.Position=Vector2.new(x,y)
    d.Text=tostring(t)
    d.Color=col
    d.Size=sz or 14
    d.Center=ctr or false
    d.Visible=true
end

-- Simple rounded rect using filled squares + corner circles (NO MASK)
-- This approach draws the rounded rect properly without needing a mask color
local function MRR()
    return {
        body =NS(), -- main center body
        lext =NS(), -- left extension
        rext =NS(), -- right extension
        c1=NC(),c2=NC(),c3=NC(),c4=NC(), -- corners
        -- border
        bt=NL(),bb=NL(),bl=NL(),br=NL(),
        bc1=NC(),bc2=NC(),bc3=NC(),bc4=NC(),
    }
end

local function RR(o,x,y,w,h,col,_msk,r,bdc,bth)
    if not o then return end
    r = math.min(r or 12, math.floor(w/2), math.floor(h/2))
    r = math.max(r, 1)

    -- Center body (full width, inner height)
    dS(o.body, x, y+r, w, h-r*2, col)
    -- Top strip
    dS(o.lext, x+r, y, w-r*2, r, col)
    -- Bottom strip  
    dS(o.rext, x+r, y+h-r, w-r*2, r, col)

    -- Four corner circles
    dC(o.c1, x+r,   y+r,   r, col, true)
    dC(o.c2, x+w-r, y+r,   r, col, true)
    dC(o.c3, x+r,   y+h-r, r, col, true)
    dC(o.c4, x+w-r, y+h-r, r, col, true)

    -- Border
    if bdc then
        bth = bth or 1.5
        dL(o.bt, x+r,   y,     x+w-r, y,     bdc, bth)
        dL(o.bb, x+r,   y+h,   x+w-r, y+h,   bdc, bth)
        dL(o.bl, x,     y+r,   x,     y+h-r, bdc, bth)
        dL(o.br, x+w,   y+r,   x+w,   y+h-r, bdc, bth)
        dC(o.bc1, x+r,   y+r,   r, bdc, false, bth)
        dC(o.bc2, x+w-r, y+r,   r, bdc, false, bth)
        dC(o.bc3, x+r,   y+h-r, r, bdc, false, bth)
        dC(o.bc4, x+w-r, y+h-r, r, bdc, false, bth)
    else
        if o.bt then o.bt.Visible=false end
        if o.bb then o.bb.Visible=false end
        if o.bl then o.bl.Visible=false end
        if o.br then o.br.Visible=false end
        if o.bc1 then o.bc1.Visible=false end
        if o.bc2 then o.bc2.Visible=false end
        if o.bc3 then o.bc3.Visible=false end
        if o.bc4 then o.bc4.Visible=false end
    end
end

local function HRR(o)
    if not o then return end
    for _,k in ipairs({"body","lext","rext","c1","c2","c3","c4",
                        "bt","bb","bl","br","bc1","bc2","bc3","bc4"}) do
        if o[k] then o[k].Visible=false end
    end
end

local function MIL(n) local t={};for i=1,n do t[i]=NL() end;return t end
local function MIC(n) local t={};for i=1,n do t[i]=NC() end;return t end

local function DrawIcon(IL,IC,idx,cx,cy,col)
    for _,d in ipairs(IL) do d.Visible=false end
    for _,d in ipairs(IC) do d.Visible=false end
    if idx==1 then
        -- House icon
        dL(IL[1],cx-8,cy+2, cx,   cy-8,  col,2.2)
        dL(IL[2],cx,  cy-8, cx+8, cy+2,  col,2.2)
        dL(IL[3],cx-6,cy+2, cx-6, cy+10, col,2.2)
        dL(IL[4],cx+6,cy+2, cx+6, cy+10, col,2.2)
        dL(IL[5],cx-6,cy+10,cx+6, cy+10, col,2.2)
        dL(IL[6],cx-2,cy+5, cx-2, cy+10, col,2.2)
        dL(IL[7],cx+2,cy+5, cx+2, cy+10, col,2.2)
        dL(IL[8],cx-2,cy+5, cx+2, cy+5,  col,2.2)
    elseif idx==2 then
        -- Person icon
        dC(IC[1],cx,cy-5,5,col,false,2.2)
        dL(IL[1],cx-8,cy+10,cx-7,cy+2, col,2.2)
        dL(IL[2],cx-7,cy+2, cx+7,cy+2, col,2.2)
        dL(IL[3],cx+7,cy+2, cx+8,cy+10,col,2.2)
        dL(IL[4],cx-8,cy+10,cx+8,cy+10,col,2.2)
    elseif idx==3 then
        -- Other icon
        dC(IC[1],cx-7,cy-5,3.8,col,false,2)
        dC(IC[2],cx+7,cy-5,3.8,col,false,2)
        dL(IL[1],cx-12,cy+8,cx-11,cy+1,col,2)
        dL(IL[2],cx-11,cy+1,cx-2, cy+1,col,2)
        dL(IL[3],cx-2, cy+1,cx-2, cy+8,col,2)
        dL(IL[4],cx-12,cy+8,cx-2, cy+8,col,2)
        dL(IL[5],cx+2, cy+1,cx+11,cy+1,col,2)
        dL(IL[6],cx+11,cy+1,cx+12,cy+8,col,2)
        dL(IL[7],cx+2, cy+8,cx+12,cy+8,col,2)
        dL(IL[8],cx+2, cy+1,cx+2, cy+8,col,2)
    elseif idx==4 then
        -- Settings icon
        dC(IC[1],cx,cy,7.5,col,false,2.2)
        dC(IC[2],cx,cy,3,  col,true)
        for t=0,7 do
            local a=(t/8)*math.pi*2
            dL(IL[t+1],
                cx+math.cos(a)*8, cy+math.sin(a)*8,
                cx+math.cos(a)*12,cy+math.sin(a)*12,
                col, 2.2)
        end
    end
end

-- ══════════════════════════════════════════════
-- PRE-CREATE OBJECTS
-- ══════════════════════════════════════════════
local UI={
    pan=MRR(), hSep=NL(), hAcc=NL(),
    logoR=MRR(), logoT=NT(),
    hT1=NT(), hT2=NT(), hSub=NT(),
    clR=MRR(), clX1=NL(), clX2=NL(),
    mnR=MRR(), mnL=NL(),
    fSep=NL(), fDot=NC(), fT1=NT(), fT2=NT(), fT3=NT(),
}

local SB={rr=MRR(),items={}}
for i=1,4 do
    SB.items[i]={rr=MRR(),IL=MIL(10),IC=MIC(3)}
end

local CARDS={}
for i=1,9 do
    CARDS[i]={
        rr=MRR(), bar=NS(), dot=NC(),
        lbl=NT(), dsc=NT(),
        tR=MRR(), tKnob=NC(), tGlow=NC(),
    }
end

local SET={
    ti=NT(),l1=NT(),l2=NT(),l3=NT(),l4=NT(),
    sb={{rr=MRR(),tx=NT()},{rr=MRR(),tx=NT()}},
    slTR=MRR(),slFI=MRR(),
    slH=NC(),slHR=NC(),slHC=NC(),slP=NT(),
    div=NL(),hkR=MRR(),hkT=NT(),act={},
}
for i=1,3 do SET.act[i]={nm=NT(),tr=MRR(),fi=MRR(),ct=NT()} end

local MINI={rr=MRR(),iR=MRR(),tx=NT()}

-- ══════════════════════════════════════════════
-- STATE
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

local function DrawToggle(co,x,y,on)
    local W,H=48,24
    local r=H/2
    local col=on and C.TgOn or C.TgOff
    RR(co.tR,x,y,W,H,col,nil,r)
    local kx=on and (x+W-r-1) or (x+r+1)
    dC(co.tGlow,kx,y+r,r-1,on and C.AccSoft or C.TgOff,true)
    dC(co.tKnob,kx,y+r,r-3,C.TgKnob,true)
end

local function HideCard(co)
    HRR(co.rr)
    co.bar.Visible=false
    co.dot.Visible=false
    co.lbl.Visible=false
    co.dsc.Visible=false
    HRR(co.tR)
    co.tKnob.Visible=false
    co.tGlow.Visible=false
end

local function HideSettings()
    for _,d in ipairs({SET.ti,SET.l1,SET.l2,SET.l3,SET.l4,SET.slP,SET.div,SET.hkT}) do
        d.Visible=false
    end
    HRR(SET.slTR);HRR(SET.slFI);HRR(SET.hkR)
    SET.slH.Visible=false;SET.slHR.Visible=false;SET.slHC.Visible=false
    for i=1,2 do HRR(SET.sb[i].rr);SET.sb[i].tx.Visible=false end
    for i=1,3 do
        SET.act[i].nm.Visible=false
        SET.act[i].ct.Visible=false
        HRR(SET.act[i].tr)
        HRR(SET.act[i].fi)
    end
end

-- ══════════════════════════════════════════════
-- RENDER
-- ══════════════════════════════════════════════
local function Render()
    HA()

    -- MINI MODE
    if not Open then
        local VP=GetVP()
        local mx=MiniSide=="left" and 10 or (VP.X-MBW-10)
        local my=Clamp(math.floor(VP.Y*MiniYPct-MBH/2),10,VP.Y-MBH-10)
        RR(MINI.rr,mx,my,MBW,MBH,C.Side,nil,18,C.AccDim,1.5)
        RR(MINI.iR,mx+math.floor(MBW/2)-13,my+math.floor(MBH/2)-13,26,26,C.AccDim,nil,8)
        dT(MINI.tx,mx+math.floor(MBW/2),my+math.floor(MBH/2)-7,"L",C.Acc,16,true)
        return
    end

    -- SIDEBAR
    local nx,ny=GNP()
    RR(SB.rr,nx,ny,SW,SNAV_H,C.Side,nil,22,C.AccDim,1.5)
    for i=1,4 do
        local si=SB.items[i]
        local bx,by=GNI(i)
        local act=CurTab==i
        local hov=Hov(bx,by,SNAV_SZ,SNAV_SZ)
        local bgC=act and C.SideAct or (hov and C.Card or C.Side)
        local bdC=act and C.Acc or nil
        RR(si.rr,bx,by,SNAV_SZ,SNAV_SZ,bgC,nil,14,bdC,1.5)
        DrawIcon(si.IL,si.IC,i,bx+SNAV_SZ/2,by+SNAV_SZ/2,act and C.Acc or C.TxLow)
    end

    -- PANEL BACKGROUND
    RR(UI.pan,PX,PY,PW,PH,C.Panel,nil,20,C.Border,1.5)

    -- Header separator lines
    dL(UI.hAcc,PX+16,PY+HDR-1,PX+PW-16,PY+HDR-1,C.AccLine,1)
    dL(UI.hSep,PX+16,PY+HDR,  PX+PW-16,PY+HDR,  C.Sep,1)

    -- Logo
    RR(UI.logoR,PX+12,PY+12,30,30,C.AccDim,nil,10,C.AccLine,1.5)
    dT(UI.logoT,PX+27,PY+18,"L",C.White,15,true)

    -- Title
    dT(UI.hT1,PX+50,PY+11,"LUXURY",C.TxHi,16)
    dT(UI.hT2,PX+50+74,PY+11,"HUB",C.Acc,16)
    dT(UI.hSub,PX+51,PY+30,"PREMIUM CONTROLS",C.TxLow,8)

    -- Close and Minimize buttons
    local BS=26
    local cX=PX+PW-BS-10
    local bY=PY+14
    local nX2=cX-BS-6
    local cH=Hov(cX,bY,BS,BS)
    local nH=Hov(nX2,bY,BS,BS)

    RR(UI.clR,cX,bY,BS,BS,cH and C.Red or C.Surface,nil,8)
    dL(UI.clX1,cX+7,bY+7,cX+BS-7,bY+BS-7,cH and C.White or C.TxMid,1.8)
    dL(UI.clX2,cX+BS-7,bY+7,cX+7,bY+BS-7,cH and C.White or C.TxMid,1.8)

    RR(UI.mnR,nX2,bY,BS,BS,nH and C.CardHov or C.Surface,nil,8)
    dL(UI.mnL,nX2+7,bY+BS/2,nX2+BS-7,bY+BS/2,C.TxMid,2)

    -- Content area
    local CX=PX+PAD
    local CY=PY+HDR+PAD
    local CW=PW-PAD*2

    if CurTab==4 then
        -- SETTINGS TAB
        HideSettings()
        for i=1,9 do HideCard(CARDS[i]) end

        local px=CX+4
        local py=CY+6

        dT(SET.ti,px,py,"Appearance",C.TxHi,15)
        py=py+30

        dT(SET.l1,px,py,"REOPEN SIDE",C.TxLow,9)
        py=py+20

        local oW=math.floor((CW-12)/2)
        for si,side in ipairs({"left","right"}) do
            local ox=px+(si-1)*(oW+12)
            local sel=MiniSide==side
            local h2=Hov(ox,py,oW,38)
            RR(SET.sb[si].rr,ox,py,oW,38,
                sel and C.CardOn or (h2 and C.CardHov or C.Card),
                nil,10,sel and C.Acc or nil,1)
            dT(SET.sb[si].tx,ox+math.floor(oW/2),py+11,
               side:sub(1,1):upper()..side:sub(2),
               sel and C.TxHi or C.TxMid,12,true)
        end
        py=py+38+24

        dT(SET.l2,px,py,"VERTICAL POSITION",C.TxLow,9)
        dT(SET.slP,CX+CW-2,py,math.floor(MiniYPct*100).."%",C.Acc,10,true)
        py=py+20

        local slW=CW-6
        RR(SET.slTR,px,py,slW,8,C.Surface,nil,4)
        local fw=math.max(8,math.floor(MiniYPct*slW))
        RR(SET.slFI,px,py,fw,8,C.Acc,nil,4)
        local hx=px+fw
        dC(SET.slH, hx,py+4,10,C.Card,true)
        dC(SET.slHR,hx,py+4,10,C.Acc,false,2)
        dC(SET.slHC,hx,py+4,4, C.Acc,true)
        py=py+34

        dL(SET.div,CX,py,CX+CW,py,C.Sep,1)
        py=py+20

        dT(SET.l3,px,py,"HOTKEY",C.TxLow,9)
        py=py+20

        RR(SET.hkR,px,py,96,32,C.Surface,nil,10,C.AccDim,1)
        dT(SET.hkT,px+48,py+10,"R-SHIFT",C.Acc,11,true)
        py=py+32+24

        dT(SET.l4,px,py,"ACTIVITY",C.TxLow,9)
        py=py+20

        for ti=1,3 do
            local cnt=0
            for _,it in ipairs(TABS[ti].items) do if it.state then cnt=cnt+1 end end
            local ar=SET.act[ti]
            local bW=CW-106
            dT(ar.nm,px,py-1,TABS[ti].name,C.TxMid,11)
            RR(ar.tr,px+62,py+1,bW,10,C.Surface,nil,5)
            local bw=math.floor(cnt/#TABS[ti].items*bW)
            if bw>3 then
                RR(ar.fi,px+62,py+1,bw,10,C.Acc,nil,5)
            else
                HRR(ar.fi)
            end
            dT(ar.ct,CX+CW-2,py-1,cnt.."/"..#TABS[ti].items,C.TxLow,10,true)
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
                local ix=CX
                local iy=CY+(i-1)*(ROW_H+ROW_GAP)
                local iw=CW
                local on=item.state
                local hov=Hov(ix,iy,iw,ROW_H)
                local bgC=on and C.CardOn or (hov and C.CardHov or C.Card)
                local bdC=on and C.BordOn or C.Border

                RR(co.rr,ix,iy,iw,ROW_H,bgC,nil,12,bdC,1)

                if on then
                    dS(co.bar,ix+8,iy+math.floor(ROW_H/2)-10,3,20,C.Acc)
                    co.bar.Visible=true
                else
                    co.bar.Visible=false
                end

                dC(co.dot,ix+24,iy+math.floor(ROW_H/2),4,on and C.Acc or C.TxFaint,true)
                dT(co.lbl,ix+38,iy+math.floor(ROW_H/2)-11,item.label,on and C.TxHi or C.TxMid,13)
                dT(co.dsc,ix+38,iy+math.floor(ROW_H/2)+3, item.desc, on and C.TxMid or C.TxFaint,9)
                DrawToggle(co,ix+iw-48-10,iy+math.floor(ROW_H/2)-12,on)
            end
        end
    end

    -- Footer
    local FY=PY+PH-FTR
    dL(UI.fSep,PX+12,FY,PX+PW-12,FY,C.Sep,1)

    local cnt=0
    if CurTab<4 then
        for _,it in ipairs(TABS[CurTab].items) do if it.state then cnt=cnt+1 end end
    end

    local sc=(CurTab<4 and cnt>0) and C.Green or C.TxLow
    dC(UI.fDot,PX+18,FY+12,3,sc,true)
    dT(UI.fT1, PX+28,FY+6, CurTab<4 and (cnt.." active") or "settings",sc,9)

    local tn={"Main","Player","Other","Settings"}
    dT(UI.fT2,PX+math.floor(PW/2),FY+6,tn[CurTab],C.TxMid,9,true)
    dT(UI.fT3,PX+PW-12,FY+6,"RShift",C.TxFaint,9,true)
end

RS.RenderStepped:Connect(Render)

-- ══════════════════════════════════════════════
-- INPUT
-- ══════════════════════════════════════════════
local function ClampP()
    local VP=GetVP()
    PX=Clamp(PX,0,VP.X-PW)
    PY=Clamp(PY,0,VP.Y-PH)
end

UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.RightShift then
        Open=not Open
        return
    end
    if inp.UserInputType~=Enum.UserInputType.MouseButton1
    and inp.UserInputType~=Enum.UserInputType.Touch then return end

    local m=Mouse()
    local VP=GetVP()

    if not Open then
        local mx=MiniSide=="left" and 10 or (VP.X-MBW-10)
        local my=Clamp(math.floor(VP.Y*MiniYPct-MBH/2),10,VP.Y-MBH-10)
        if Hov(mx,my,MBW,MBH) then Open=true end
        return
    end

    -- Close / Minimize
    local BS=26
    local cX=PX+PW-BS-10
    local bY=PY+14
    local nX2=cX-BS-6

    if Hov(cX,bY,BS,BS) then Open=false;return end
    if Hov(nX2,bY,BS,BS) then Open=false;return end

    -- Settings tab interactions
    if CurTab==4 then
        local px=PX+PAD+4
        local CW=PW-PAD*2
        local py0=PY+HDR+PAD+6+30+20
        local oW=math.floor((CW-12)/2)

        for si,side in ipairs({"left","right"}) do
            local ox=px+(si-1)*(oW+12)
            if Hov(ox,py0,oW,38) then
                MiniSide=side
                return
            end
        end

        local slY=py0+38+24+20
        local slW=CW-6
        if Hov(px-12,slY-12,slW+24,32) then
            DragSlider=true
            MiniYPct=Clamp((m.X-px)/slW,0,1)
            return
        end
    end

    -- Sidebar tab buttons
    for i=1,4 do
        local bx,by=GNI(i)
        if Hov(bx,by,SNAV_SZ,SNAV_SZ) then
            CurTab=i
            return
        end
    end

    -- Feature cards
    if CurTab<4 then
        local CX=PX+PAD
        local CY=PY+HDR+PAD
        local CW=PW-PAD*2
        for i=1,9 do
            local iy=CY+(i-1)*(ROW_H+ROW_GAP)
            if Hov(CX,iy,CW,ROW_H) then
                DoToggle(CurTab,i)
                return
            end
        end
    end

    -- Panel drag
    local BS2=26
    local headerExcludeX=PX+PW-BS2*2-16-6
    if Hov(PX,PY,headerExcludeX-PX,HDR) then
        Drag=true
        DragOff=Vector2.new(m.X-PX,m.Y-PY)
    end
end)

UIS.InputChanged:Connect(function(inp)
    if inp.UserInputType~=Enum.UserInputType.MouseMovement
    and inp.UserInputType~=Enum.UserInputType.Touch then return end
    local m=Mouse()
    if Drag then
        PX=m.X-DragOff.X
        PY=m.Y-DragOff.Y
        ClampP()
    end
    if DragSlider then
        local px=PX+PAD+4
        local slW=PW-PAD*2-6
        MiniYPct=Clamp((m.X-px)/slW,0,1)
    end
end)

UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1
    or inp.UserInputType==Enum.UserInputType.Touch then
        Drag=false
        DragSlider=false
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

print("LUXURY HUB v15 - OK")
