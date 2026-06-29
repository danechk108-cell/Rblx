-- LUXURY HUB v9 FIXED - No 'continue', stable
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local Players = game:GetService("Players")
local LP      = Players.LocalPlayer

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
-- FUNCTIONS
-- ══════════════════════════════════════════════
local TABS = {
    {
        name = "Main",
        items = {
            {
                label="Infinite Jump", desc="Jump in air", state=false, conn=nil,
                enable=function(item)
                    item.conn = UIS.JumpRequest:Connect(function()
                        pcall(function()
                            local c=LP.Character
                            if c then
                                local h=c:FindFirstChildOfClass("Humanoid")
                                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                            end
                        end)
                    end)
                end,
                disable=function(item)
                    if item.conn then item.conn:Disconnect() item.conn=nil end
                end,
            },
            {
                label="Speed Boost", desc="WalkSpeed x2.5", state=false,
                enable=function()
                    pcall(function()
                        local h=LP.Character:FindFirstChildOfClass("Humanoid")
                        if h then h.WalkSpeed=40 end
                    end)
                end,
                disable=function()
                    pcall(function()
                        local h=LP.Character:FindFirstChildOfClass("Humanoid")
                        if h then h.WalkSpeed=16 end
                    end)
                end,
            },
            {
                label="Anti-AFK", desc="Prevent kick", state=false, conn=nil,
                enable=function(item)
                    item.conn = LP.Idled:Connect(function()
                        pcall(function()
                            local vu=game:GetService("VirtualUser")
                            vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                            task.wait()
                            vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                        end)
                    end)
                end,
                disable=function(item)
                    if item.conn then item.conn:Disconnect() item.conn=nil end
                end,
            },
            {
                label="Fly", desc="WASD+Space to fly", state=false, conn=nil, bv=nil, bg2=nil,
                enable=function(item)
                    pcall(function()
                        local char=LP.Character
                        if not char then return end
                        local root=char:FindFirstChild("HumanoidRootPart")
                        if not root then return end
                        local hum=char:FindFirstChildOfClass("Humanoid")
                        if hum then hum.PlatformStand=true end
                        local bv=Instance.new("BodyVelocity",root)
                        bv.Velocity=Vector3.new(0,0,0)
                        bv.MaxForce=Vector3.new(1e5,1e5,1e5)
                        item.bv=bv
                        local bg=Instance.new("BodyGyro",root)
                        bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
                        bg.D=100
                        item.bg2=bg
                        item.conn=RS.RenderStepped:Connect(function()
                            pcall(function()
                                local cam=workspace.CurrentCamera
                                local dir=Vector3.new(0,0,0)
                                if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+cam.CFrame.LookVector end
                                if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-cam.CFrame.LookVector end
                                if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-cam.CFrame.RightVector end
                                if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+cam.CFrame.RightVector end
                                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
                                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.new(0,1,0) end
                                if dir.Magnitude>0 then dir=dir.Unit end
                                bv.Velocity=dir*50
                                bg.CFrame=cam.CFrame
                            end)
                        end)
                    end)
                end,
                disable=function(item)
                    if item.conn then item.conn:Disconnect() item.conn=nil end
                    pcall(function()
                        if item.bv then item.bv:Destroy() item.bv=nil end
                        if item.bg2 then item.bg2:Destroy() item.bg2=nil end
                        local char=LP.Character
                        if char then
                            local hum=char:FindFirstChildOfClass("Humanoid")
                            if hum then hum.PlatformStand=false end
                        end
                    end)
                end,
            },
            {
                label="No Clip", desc="Walk thru walls", state=false, conn=nil,
                enable=function(item)
                    item.conn=RS.Stepped:Connect(function()
                        pcall(function()
                            if LP.Character then
                                for _,p in ipairs(LP.Character:GetDescendants()) do
                                    if p:IsA("BasePart") then p.CanCollide=false end
                                end
                            end
                        end)
                    end)
                end,
                disable=function(item)
                    if item.conn then item.conn:Disconnect() item.conn=nil end
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
                label="God Mode", desc="Max health always", state=false, conn=nil,
                enable=function(item)
                    item.conn=RS.Heartbeat:Connect(function()
                        pcall(function()
                            local h=LP.Character:FindFirstChildOfClass("Humanoid")
                            if h then h.Health=h.MaxHealth end
                        end)
                    end)
                end,
                disable=function(item)
                    if item.conn then item.conn:Disconnect() item.conn=nil end
                end,
            },
            {
                label="High Jump", desc="JumpPower x3", state=false,
                enable=function()
                    pcall(function()
                        local h=LP.Character:FindFirstChildOfClass("Humanoid")
                        if h then h.JumpPower=150 end
                    end)
                end,
                disable=function()
                    pcall(function()
                        local h=LP.Character:FindFirstChildOfClass("Humanoid")
                        if h then h.JumpPower=50 end
                    end)
                end,
            },
            {
                label="Invisible", desc="Hide character", state=false,
                enable=function()
                    pcall(function()
                        for _,p in ipairs(LP.Character:GetDescendants()) do
                            if p:IsA("BasePart") then p.Transparency=1
                            elseif p:IsA("Decal") then p.Transparency=1 end
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
                label="Freeze", desc="Anchor character", state=false,
                enable=function()
                    pcall(function()
                        local r=LP.Character:FindFirstChild("HumanoidRootPart")
                        if r then r.Anchored=true end
                    end)
                end,
                disable=function()
                    pcall(function()
                        local r=LP.Character:FindFirstChild("HumanoidRootPart")
                        if r then r.Anchored=false end
                    end)
                end,
            },
            {
                label="Low Gravity", desc="Float around", state=false,
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
                label="Full Bright", desc="Max lighting", state=false, old=nil,
                enable=function(item)
                    pcall(function()
                        item.old={
                            amb=game.Lighting.Ambient,
                            oamb=game.Lighting.OutdoorAmbient,
                            brit=game.Lighting.Brightness
                        }
                        game.Lighting.Ambient=Color3.fromRGB(255,255,255)
                        game.Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
                        game.Lighting.Brightness=2
                    end)
                end,
                disable=function(item)
                    pcall(function()
                        if item.old then
                            game.Lighting.Ambient=item.old.amb
                            game.Lighting.OutdoorAmbient=item.old.oamb
                            game.Lighting.Brightness=item.old.brit
                        end
                    end)
                end,
            },
            {
                label="Time: Noon", desc="ClockTime = 12", state=false,
                enable=function() pcall(function() game.Lighting.ClockTime=12 end) end,
                disable=function() end,
            },
            {
                label="No Fog", desc="Remove all fog", state=false, old=nil,
                enable=function(item)
                    pcall(function()
                        item.old={s=game.Lighting.FogStart,e=game.Lighting.FogEnd}
                        game.Lighting.FogStart=0
                        game.Lighting.FogEnd=1e6
                    end)
                end,
                disable=function(item)
                    pcall(function()
                        if item.old then
                            game.Lighting.FogStart=item.old.s
                            game.Lighting.FogEnd=item.old.e
                        end
                    end)
                end,
            },
            {
                label="ESP Players", desc="Names over heads", state=false, bills={},
                enable=function(item)
                    pcall(function()
                        for _,pl in ipairs(Players:GetPlayers()) do
                            if pl~=LP and pl.Character then
                                local root=pl.Character:FindFirstChild("HumanoidRootPart")
                                if root then
                                    local bb=Instance.new("BillboardGui",root)
                                    bb.Size=UDim2.new(0,80,0,30)
                                    bb.StudsOffset=Vector3.new(0,3,0)
                                    bb.AlwaysOnTop=true
                                    local lbl=Instance.new("TextLabel",bb)
                                    lbl.Size=UDim2.new(1,0,1,0)
                                    lbl.BackgroundTransparency=1
                                    lbl.TextColor3=Color3.fromRGB(120,110,255)
                                    lbl.TextStrokeTransparency=0
                                    lbl.Text=pl.Name
                                    lbl.Font=Enum.Font.GothamBold
                                    lbl.TextSize=14
                                    table.insert(item.bills,bb)
                                end
                            end
                        end
                    end)
                end,
                disable=function(item)
                    for _,b in ipairs(item.bills) do pcall(function() b:Destroy() end) end
                    item.bills={}
                end,
            },
            {
                label="Infinite Yield", desc="cmd util (console)", state=false,
                enable=function()
                    pcall(function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
                    end)
                end,
                disable=function()end,
            },
            {label="TEST-6", desc="Slot 6", state=false, enable=function()end, disable=function()end},
            {label="TEST-7", desc="Slot 7", state=false, enable=function()end, disable=function()end},
            {label="TEST-8", desc="Slot 8", state=false, enable=function()end, disable=function()end},
            {label="TEST-9", desc="Slot 9", state=false, enable=function()end, disable=function()end},
        }
    },
}

local function ToggleItem(ti,ii)
    local item=TABS[ti].items[ii]
    if not item then return end
    item.state=not item.state
    if item.state then pcall(item.enable,item)
    else pcall(item.disable,item) end
end

-- STATE
local Open       = true
local CurTab     = 1
local Drag       = false
local DragOff    = Vector2.new(0,0)
local MiniSide   = "left"
local MiniYPos   = 0.32
local DragSlider = false

-- ══════════════════════════════════════════════
-- DRAWING SETUP
-- ══════════════════════════════════════════════
local allObjs={}
local function NSq() local d=Drawing.new("Square"); d.Filled=true; d.Visible=false; d.Thickness=1; table.insert(allObjs,d); return d end
local function NLn() local d=Drawing.new("Line");   d.Visible=false; d.Thickness=1; table.insert(allObjs,d); return d end
local function NCi() local d=Drawing.new("Circle"); d.Filled=true; d.NumSides=24; d.Visible=false; d.Thickness=1; table.insert(allObjs,d); return d end
local function NTx() local d=Drawing.new("Text");   d.Outline=true; d.OutlineColor=BLACK; d.Size=14; d.Visible=false; table.insert(allObjs,d); return d end

local function HideAll() for _,d in ipairs(allObjs) do d.Visible=false end end

local function DS(d,x,y,w,h,c) d.Position=Vector2.new(x,y); d.Size=Vector2.new(w,h); d.Color=c; d.Filled=true; d.Visible=true end
local function DL(d,x1,y1,x2,y2,c,th) d.From=Vector2.new(x1,y1); d.To=Vector2.new(x2,y2); d.Color=c; d.Thickness=th or 1; d.Visible=true end
local function DC(d,x,y,r,c,f,th) d.Position=Vector2.new(x,y); d.Radius=r; d.Color=c; d.Filled=f~=false; d.Thickness=th or 1; d.Visible=true end
local function DT(d,x,y,t,c,sz,ctr) d.Position=Vector2.new(x,y); d.Text=tostring(t); d.Color=c; d.Size=sz or 14; d.Center=ctr or false; d.Visible=true end

-- Rounded rect: 3 squares + 4 corner circles + optional 4 line borders + 4 corner arc circles
local function MakeRR(border)
    local o={
        s1=NSq(),s2=NSq(),s3=NSq(),
        c1=NCi(),c2=NCi(),c3=NCi(),c4=NCi(),
    }
    if border then
        o.b1=NLn();o.b2=NLn();o.b3=NLn();o.b4=NLn()
        o.a1=NCi();o.a2=NCi();o.a3=NCi();o.a4=NCi()
    end
    return o
end

local function DrawRR(o,x,y,w,h,col,bcol,r,bth)
    r=math.min(r or 12,w/2,h/2)
    DS(o.s1,x+r,y,w-r*2,h,col)
    DS(o.s2,x,y+r,r,h-r*2,col)
    DS(o.s3,x+w-r,y+r,r,h-r*2,col)
    DC(o.c1,x+r,   y+r,   r,col,true)
    DC(o.c2,x+w-r, y+r,   r,col,true)
    DC(o.c3,x+r,   y+h-r, r,col,true)
    DC(o.c4,x+w-r, y+h-r, r,col,true)
    if bcol and o.b1 then
        bth=bth or 1.5
        DL(o.b1,x+r,  y,   x+w-r,y,   bcol,bth)
        DL(o.b2,x+r,  y+h, x+w-r,y+h, bcol,bth)
        DL(o.b3,x,    y+r, x,    y+h-r,bcol,bth)
        DL(o.b4,x+w,  y+r, x+w,  y+h-r,bcol,bth)
        DC(o.a1,x+r,   y+r,   r,bcol,false,bth)
        DC(o.a2,x+w-r, y+r,   r,bcol,false,bth)
        DC(o.a3,x+r,   y+h-r, r,bcol,false,bth)
        DC(o.a4,x+w-r, y+h-r, r,bcol,false,bth)
    elseif o.b1 then
        o.b1.Visible=false;o.b2.Visible=false;o.b3.Visible=false;o.b4.Visible=false
        o.a1.Visible=false;o.a2.Visible=false;o.a3.Visible=false;o.a4.Visible=false
    end
end

local function HideRR(o)
    o.s1.Visible=false;o.s2.Visible=false;o.s3.Visible=false
    o.c1.Visible=false;o.c2.Visible=false;o.c3.Visible=false;o.c4.Visible=false
    if o.b1 then
        o.b1.Visible=false;o.b2.Visible=false;o.b3.Visible=false;o.b4.Visible=false
        o.a1.Visible=false;o.a2.Visible=false;o.a3.Visible=false;o.a4.Visible=false
    end
end

-- Icons
local function MIL(n) local t={} for i=1,n do t[i]=NLn() end return t end
local function MIC(n) local t={} for i=1,n do t[i]=NCi() end return t end
local function HIL(t) for _,d in ipairs(t) do d.Visible=false end end
local function HIC(t) for _,d in ipairs(t) do d.Visible=false end end

local function DrawIcon(IL,IC,idx,cx,cy,col)
    HIL(IL); HIC(IC)
    if idx==1 then
        DL(IL[1],cx-7,cy-1,cx,cy-8,col,2); DL(IL[2],cx,cy-8,cx+7,cy-1,col,2)
        DL(IL[3],cx-5,cy-1,cx-5,cy+6,col,2); DL(IL[4],cx+5,cy-1,cx+5,cy+6,col,2)
        DL(IL[5],cx-5,cy+6,cx+5,cy+6,col,2)
    elseif idx==2 then
        DC(IC[1],cx,cy-4,3.5,col,false,2)
        DL(IL[1],cx-6,cy+6,cx-5,cy+1,col,2); DL(IL[2],cx-5,cy+1,cx+5,cy+1,col,2)
        DL(IL[3],cx+5,cy+1,cx+6,cy+6,col,2); DL(IL[4],cx-6,cy+6,cx+6,cy+6,col,2)
    elseif idx==3 then
        DC(IC[1],cx-5,cy-3,3,col,false,2); DC(IC[2],cx+5,cy-3,3,col,false,2)
        DL(IL[1],cx-9,cy+5,cx-1,cy+5,col,2); DL(IL[2],cx-9,cy+5,cx-8,cy+1,col,2)
        DL(IL[3],cx-8,cy+1,cx-1,cy+1,col,2); DL(IL[4],cx-1,cy+1,cx-1,cy+5,col,2)
        DL(IL[5],cx+1,cy+1,cx+9,cy+1,col,2); DL(IL[6],cx+1,cy+5,cx+9,cy+5,col,2)
        DL(IL[7],cx+9,cy+1,cx+9,cy+5,col,2)
    elseif idx==4 then
        for t=0,5 do
            local a=(t/6)*math.pi*2
            DL(IL[t+1],cx+math.cos(a)*5,cy+math.sin(a)*5,cx+math.cos(a)*9,cy+math.sin(a)*9,col,2)
        end
        DC(IC[1],cx,cy,5,col,false,2); DC(IC[2],cx,cy,2,col,false,2)
    end
end

-- ══════════════════════════════════════════════
-- PRE-CREATE OBJECTS
-- ══════════════════════════════════════════════

-- Panel + header
local panRR  = MakeRR(true)
local hdrLn  = NLn()
local logoRR = MakeRR(false)
local logoTx = NTx()
local tit1   = NTx(); local tit2 = NTx(); local subT = NTx()
local clRR   = MakeRR(false); local clX1=NLn(); local clX2=NLn()
local mnRR   = MakeRR(false); local mnLn=NLn()
local ftLn   = NLn(); local ftDot=NCi(); local ftTx1=NTx(); local ftTx2=NTx(); local ftTx3=NTx()

-- Nav
local navRR = MakeRR(true)
local navI  = {}
for i=1,4 do
    navI[i]={rr=MakeRR(true), IL=MIL(9), IC=MIC(3)}
end

-- Cards
local cardO={}
for i=1,9 do
    cardO[i]={
        rr=MakeRR(true), bar=NSq(), dot=NCi(), lbl=NTx(), dsc=NTx(),
        tRR=MakeRR(false), tE1=NCi(), tE2=NCi(), knob=NCi(),
    }
end

-- Settings
local sTitle=NTx(); local sL1=NTx(); local sL2=NTx(); local sL3=NTx(); local sL4=NTx()
local sSB={{rr=MakeRR(true),tx=NTx()},{rr=MakeRR(true),tx=NTx()}}
local slTR=MakeRR(false); local slFI=MakeRR(false)
local slDt=NCi(); local slRi=NCi(); local slCt=NCi(); local slPc=NTx()
local divL=NLn()
local hkRR=MakeRR(true); local hkTx=NTx()
local aRows={}
for i=1,3 do aRows[i]={nm=NTx(),tr=MakeRR(false),fi=MakeRR(false),ct=NTx()} end

-- Mini
local mRR=MakeRR(true); local mLRR=MakeRR(false); local mTx=NTx()

-- ══════════════════════════════════════════════
-- HIDE HELPERS
-- ══════════════════════════════════════════════
local function HideCard(c)
    HideRR(c.rr); c.bar.Visible=false; c.dot.Visible=false
    c.lbl.Visible=false; c.dsc.Visible=false
    HideRR(c.tRR); c.tE1.Visible=false; c.tE2.Visible=false; c.knob.Visible=false
end
local function HideSettings()
    for _,d in ipairs({sTitle,sL1,sL2,sL3,sL4,slPc,divL,hkTx}) do d.Visible=false end
    HideRR(slTR); HideRR(slFI); HideRR(hkRR)
    slDt.Visible=false; slRi.Visible=false; slCt.Visible=false
    for i=1,2 do HideRR(sSB[i].rr); sSB[i].tx.Visible=false end
    for i=1,3 do HideRR(aRows[i].tr); HideRR(aRows[i].fi); aRows[i].nm.Visible=false; aRows[i].ct.Visible=false end
end

-- ══════════════════════════════════════════════
-- DRAW TOGGLE
-- ══════════════════════════════════════════════
local function DrawToggle(c,x,y,on)
    local W,H=46,24; local r=H/2
    local col=on and NEON or TRACK
    DrawRR(c.tRR,x,y,W,H,col,nil,r)
    DC(c.tE1,x+r,y+r,r,col,true)
    DC(c.tE2,x+W-r,y+r,r,col,true)
    local kx=on and (x+W-r-1) or (x+r+1)
    DC(c.knob,kx,y+r,r-3,WHITE,true)
end

-- Hov helper
local function Mouse() return UIS:GetMouseLocation() end
local function Hov(x,y,w,h) local m=Mouse(); return m.X>=x and m.X<=x+w and m.Y>=y and m.Y<=y+h end

-- ══════════════════════════════════════════════
-- RENDER
-- ══════════════════════════════════════════════
local function Render()
    HideAll()

    if not Open then
        local mx=MiniSide=="left" and 10 or (VP.X-MBW-10)
        local my=math.max(10,math.min(VP.Y-MBH-10,math.floor(VP.Y*MiniYPos-MBH/2)))
        DrawRR(mRR,mx,my,MBW,MBH,BGLITE,NEON,14,1.5)
        DrawRR(mLRR,mx+MBW/2-10,my+MBH/2-10,20,20,NEON,nil,6)
        DT(mTx,mx+MBW/2,my+MBH/2-7,"L",WHITE,12,true)
        return
    end

    -- NAV
    local ns,ng=48,10
    local nNH=4*ns+3*ng+20
    local nNX=PX-NAV_W-NAV_GAP
    local nNY=PY+PH/2-nNH/2
    DrawRR(navRR,nNX,nNY,NAV_W,nNH,BGLITE,NEONDIM,18,1.5)
    for i=1,4 do
        local ni=navI[i]
        local bx=nNX+(NAV_W-ns)/2
        local by=nNY+10+(i-1)*(ns+ng)
        local act=CurTab==i
        local hov=Hov(bx,by,ns,ns)
        DrawRR(ni.rr,bx,by,ns,ns,act and CARDON or (hov and CARDHI or CARD),act and NEON or nil,14,1.5)
        DrawIcon(ni.IL,ni.IC,i,bx+ns/2,by+ns/2,act and NEON or TXLOW)
    end

    -- PANEL
    DrawRR(panRR,PX,PY,PW,PH,BG,NEONDIM,18,1.5)
    DL(hdrLn,PX+16,PY+HEADER,PX+PW-16,PY+HEADER,BORDER,1)
    DrawRR(logoRR,PX+14,PY+13,30,30,NEON,nil,9)
    DT(logoTx,PX+29,PY+19,"L",WHITE,15,true)
    DT(tit1,PX+52,PY+10,"LUXURY",TXHI,17)
    DT(tit2,PX+52+74,PY+10,"HUB",NEON,17)
    DT(subT,PX+53,PY+31,"PREMIUM CONTROLS",TXLOW,8)

    local bs=28; local cX=PX+PW-bs-14; local bY=PY+13; local nX2=cX-bs-6
    local cHov=Hov(cX,bY,bs,bs); local nHov=Hov(nX2,bY,bs,bs)
    DrawRR(clRR,cX,bY,bs,bs,cHov and RED or CARD,nil,9)
    DL(clX1,cX+9,bY+9,cX+bs-9,bY+bs-9,TXHI,1.8)
    DL(clX2,cX+bs-9,bY+9,cX+9,bY+bs-9,TXHI,1.8)
    DrawRR(mnRR,nX2,bY,bs,bs,nHov and CARDHI or CARD,nil,9)
    DL(mnLn,nX2+8,bY+bs/2,nX2+bs-8,bY+bs/2,TXMID,2)

    local CX=PX+PAD; local CY=PY+HEADER+PAD; local CW=PW-PAD*2

    if CurTab==4 then
        HideSettings()
        for i=1,9 do HideCard(cardO[i]) end
        local px=CX+4; local py=CY+4
        DT(sTitle,px,py,"Appearance",TXHI,16); py=py+32
        DT(sL1,px,py,"REOPEN SIDE",TXLOW,10); py=py+22
        local optW=(CW-12)/2
        for si,side in ipairs({"left","right"}) do
            local ox=px+(si-1)*(optW+12)
            local sel=MiniSide==side
            local hov=Hov(ox,py,optW,38)
            DrawRR(sSB[si].rr,ox,py,optW,38,sel and CARDON or (hov and CARDHI or CARD),sel and NEON or nil,10,1)
            DT(sSB[si].tx,ox+optW/2,py+12,side:sub(1,1):upper()..side:sub(2),sel and TXHI or TXMID,13,true)
        end
        py=py+38+28
        DT(sL2,px,py,"VERTICAL POSITION",TXLOW,10)
        DT(slPc,CX+CW-4,py,math.floor(MiniYPos*100).."%",NEON,11,true)
        py=py+22
        local slW=CW-8
        DrawRR(slTR,px,py,slW,8,TRACK,nil,4)
        local fw=math.max(8,math.floor(MiniYPos*slW))
        DrawRR(slFI,px,py,fw,8,NEON,nil,4)
        local hx=px+fw
        DC(slDt,hx,py+4,9,CARD,true); DC(slRi,hx,py+4,9,NEON,false,2); DC(slCt,hx,py+4,3,NEON,true)
        py=py+36
        DL(divL,CX,py,CX+CW,py,BORDER,1); py=py+22
        DT(sL3,px,py,"HOTKEY",TXLOW,10); py=py+22
        DrawRR(hkRR,px,py,96,32,CARD,NEONDIM,10,1)
        DT(hkTx,px+48,py+10,"R-SHIFT",NEON,12,true)
        py=py+32+28
        DT(sL4,px,py,"ACTIVITY",TXLOW,10); py=py+22
        for ti=1,3 do
            local cnt=0
            for _,item in ipairs(TABS[ti].items) do if item.state then cnt=cnt+1 end end
            local ar=aRows[ti]; local barW=CW-100
            DT(ar.nm,px,py-1,TABS[ti].name,TXMID,12)
            DrawRR(ar.tr,px+60,py+1,barW,10,TRACK,nil,5)
            local bw=math.floor(cnt/#TABS[ti].items*barW)
            if bw>2 then DrawRR(ar.fi,px+60,py+1,bw,10,NEON,nil,5) else HideRR(ar.fi) end
            DT(ar.ct,CX+CW-4,py-1,cnt.."/"..#TABS[ti].items,TXLOW,11,true)
            py=py+22
        end
    else
        HideSettings()
        local items=TABS[CurTab].items
        for i=1,9 do
            local co=cardO[i]
            local item=items[i]
            if item==nil then
                HideCard(co)
            else
                local ix=CX; local iy=CY+(i-1)*(ROW_H+GAP); local iw=CW
                local on=item.state; local hov=Hov(ix,iy,iw,ROW_H)
                DrawRR(co.rr,ix,iy,iw,ROW_H,on and CARDON or (hov and CARDHI or CARD),on and NEON or (hov and NEONDIM or BORDER),14,1)
                if on then DS(co.bar,ix+9,iy+ROW_H/2-10,3,20,NEON); co.bar.Visible=true
                else co.bar.Visible=false end
                DC(co.dot,ix+24,iy+ROW_H/2,4.5,on and NEON or TXFAINT,true)
                DT(co.lbl,ix+38,iy+ROW_H/2-10,item.label,on and TXHI or TXMID,13)
                DT(co.dsc,ix+39,iy+ROW_H/2+3,item.desc,on and NEON or TXFAINT,9)
                DrawToggle(co,ix+iw-46-12,iy+ROW_H/2-12,on)
            end
        end
    end

    -- FOOTER
    local FY=PY+PH-FOOTER
    DL(ftLn,PX+16,FY,PX+PW-16,FY,BORDER,1)
    local cnt=0
    if CurTab<4 then
        for _,item in ipairs(TABS[CurTab].items) do if item.state then cnt=cnt+1 end end
    end
    local stCol=(CurTab<4 and cnt>0) and GREEN or TXLOW
    DC(ftDot,PX+18,FY+12,3,stCol,true)
    DT(ftTx1,PX+26,FY+6,CurTab<4 and (cnt.." active") or "settings",stCol,9)
    local tnames={"Main","Player","Other","Settings"}
    DT(ftTx2,PX+PW/2,FY+6,tnames[CurTab],TXMID,9,true)
    DT(ftTx3,PX+PW-14,FY+6,"RShift",TXFAINT,9,true)
end

RS.RenderStepped:Connect(Render)

-- ══════════════════════════════════════════════
-- INPUT
-- ══════════════════════════════════════════════
local function ClampPX()
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
        local mx=MiniSide=="left" and 10 or (VP.X-MBW-10)
        local my=math.max(10,math.min(VP.Y-MBH-10,math.floor(VP.Y*MiniYPos-MBH/2)))
        if Hov(mx,my,MBW,MBH) then Open=true end
        return
    end

    local bs=28; local cX=PX+PW-bs-14; local bY=PY+13
    if Hov(cX,bY,bs,bs) or Hov(cX-bs-6,bY,bs,bs) then Open=false return end

    if CurTab==4 then
        local px=PX+PAD+4; local CW=PW-PAD*2
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

    local ns,ng=48,10
    local nNH=4*ns+3*ng+20
    local nNX=PX-NAV_W-NAV_GAP
    local nNY=PY+PH/2-nNH/2
    for i=1,4 do
        local bx=nNX+(NAV_W-ns)/2
        local by=nNY+10+(i-1)*(ns+ng)
        if Hov(bx,by,ns,ns) then CurTab=i return end
    end

    if CurTab<4 then
        local CX=PX+PAD; local CY=PY+HEADER+PAD; local CW=PW-PAD*2
        for i=1,9 do
            local iy=CY+(i-1)*(ROW_H+GAP)
            if Hov(CX,iy,CW,ROW_H) then ToggleItem(CurTab,i) return end
        end
    end

    if Hov(PX,PY,PW-100,HEADER) then
        Drag=true
        DragOff=Vector2.new(m.X-PX,m.Y-PY)
    end
end)

UIS.InputChanged:Connect(function(inp)
    if inp.UserInputType~=Enum.UserInputType.MouseMovement
    and inp.UserInputType~=Enum.UserInputType.Touch then return end
    local m=Mouse()
    if Drag then PX=m.X-DragOff.X; PY=m.Y-DragOff.Y; ClampPX() end
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

LP.CharacterAdded:Connect(function()
    task.wait(1)
    for ti=1,3 do
        for _,item in ipairs(TABS[ti].items) do
            if item.state then pcall(item.enable,item) end
        end
    end
end)

print("LUXURY HUB v9 FIXED - OK")
