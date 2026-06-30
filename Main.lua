-- LUXURY HUB v20 - SINGLE FILE
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TW = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- ══════════════════════════════════════════════
-- GUI ROOT
-- ══════════════════════════════════════════════
local GuiRoot
pcall(function() GuiRoot = gethui() end)
if not GuiRoot then pcall(function() GuiRoot = game:GetService("CoreGui") end) end
if not GuiRoot then GuiRoot = LP.PlayerGui end

local old = GuiRoot:FindFirstChild("LuxuryHub")
if old then old:Destroy() end

local Screen = Instance.new("ScreenGui")
Screen.Name = "LuxuryHub"
Screen.ResetOnSpawn = false
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Screen.IgnoreGuiInset = true
Screen.Parent = GuiRoot

-- ══════════════════════════════════════════════
-- COLORS
-- ══════════════════════════════════════════════
local C = {
    BG0=Color3.fromRGB(8,9,14),
    BG1=Color3.fromRGB(13,14,22),
    BG2=Color3.fromRGB(18,20,32),
    BG3=Color3.fromRGB(23,25,40),
    BG4=Color3.fromRGB(28,30,50),
    BG5=Color3.fromRGB(33,35,58),
    SB0=Color3.fromRGB(11,12,20),
    SB1=Color3.fromRGB(20,22,38),
    SB2=Color3.fromRGB(26,28,50),
    Acc=Color3.fromRGB(147,100,255),
    Acc2=Color3.fromRGB(120,75,220),
    Acc3=Color3.fromRGB(80,45,160),
    AccLine=Color3.fromRGB(70,45,140),
    AccSoft=Color3.fromRGB(55,35,110),
    AccDim=Color3.fromRGB(35,22,75),
    TxW=Color3.fromRGB(245,245,255),
    TxH=Color3.fromRGB(200,202,230),
    TxM=Color3.fromRGB(130,133,170),
    TxL=Color3.fromRGB(70,73,105),
    TxF=Color3.fromRGB(40,43,65),
    Bord=Color3.fromRGB(32,34,55),
    BordA=Color3.fromRGB(90,60,190),
    BordH=Color3.fromRGB(55,58,88),
    Sep=Color3.fromRGB(25,27,45),
    Green=Color3.fromRGB(80,220,140),
    Red=Color3.fromRGB(230,75,80),
    White=Color3.fromRGB(255,255,255),
    Black=Color3.fromRGB(0,0,0),
    SlTrack=Color3.fromRGB(22,24,40),
    SlFill=Color3.fromRGB(147,100,255),
}

-- ══════════════════════════════════════════════
-- UTILITIES
-- ══════════════════════════════════════════════
local function New(class, props, parent)
    local i = Instance.new(class)
    for k,v in pairs(props or {}) do i[k]=v end
    if parent then i.Parent=parent end
    return i
end

local function Tween(inst, props, t, style, dir)
    local info = TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local tw = TW:Create(inst, info, props)
    tw:Play()
    return tw
end

local function Round(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 12)
    c.Parent = inst
    return c
end

local function Stroke(inst, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or C.Bord
    s.Thickness = th or 1.5
    s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
    return s
end

local function Pad(inst, a, t, b, l, r)
    local p = Instance.new("UIPadding")
    if a then p.PaddingTop=UDim.new(0,a); p.PaddingBottom=UDim.new(0,a); p.PaddingLeft=UDim.new(0,a); p.PaddingRight=UDim.new(0,a)
    else
        if t then p.PaddingTop=UDim.new(0,t) end
        if b then p.PaddingBottom=UDim.new(0,b) end
        if l then p.PaddingLeft=UDim.new(0,l) end
        if r then p.PaddingRight=UDim.new(0,r) end
    end
    p.Parent=inst; return p
end

local function List(inst, dir, pad, ha, va)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Padding = UDim.new(0, pad or 6)
    l.HorizontalAlignment = ha or Enum.HorizontalAlignment.Left
    l.VerticalAlignment = va or Enum.VerticalAlignment.Top
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = inst
    return l
end

local function Shadow(parent, size)
    local s = New("ImageLabel", {
        Size = UDim2.new(1, size or 30, 1, size or 30),
        Position = UDim2.new(0, -(size or 30)/2, 0, -(size or 30)/2),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0,0,0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49,49,450,450),
        ZIndex = -1,
    }, parent)
    return s
end

-- ══════════════════════════════════════════════
-- FEATURES
-- ══════════════════════════════════════════════
local TABS = {
    {name="Main", icon="⚡", items={
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

        {label="Speed Boost", desc="Multiply walk speed", state=false,
         param={label="Speed Multiplier", min=1, max=10, step=0.5, val=2.5,
          fmt=function(v) return string.format("%.1fx",v) end,
          apply=function(v)
              pcall(function()
                  local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                  if h then h.WalkSpeed=16*v end
              end)
          end},
         enable=function(it)
             pcall(function()
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.WalkSpeed=16*it.param.val end
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
                     local vu=game:GetService("VirtualUser")
                     vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                     task.wait()
                     vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Fly", desc="WASD + Space to fly", state=false, conn=nil, _bv=nil, _bg=nil, _spd=60,
         param={label="Fly Speed", min=10, max=300, step=5, val=60,
          fmt=function(v) return math.floor(v).." u/s" end,
          apply=function(v,it) if it then it._spd=v end end},
         enable=function(it)
             it._spd=it.param.val
             pcall(function()
                 local ch=LP.Character; if not ch then return end
                 local root=ch:FindFirstChild("HumanoidRootPart"); if not root then return end
                 local hum=ch:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand=true end
                 local bv=Instance.new("BodyVelocity")
                 bv.Velocity=Vector3.new(0,0,0); bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Parent=root; it._bv=bv
                 local bg=Instance.new("BodyGyro")
                 bg.MaxTorque=Vector3.new(1e5,1e5,1e5); bg.D=100; bg.Parent=root; it._bg=bg
                 it.conn=RS.RenderStepped:Connect(function()
                     pcall(function()
                         local cam=workspace.CurrentCamera
                         local lv=cam.CFrame.LookVector; local rv=cam.CFrame.RightVector
                         local d=Vector3.new(0,0,0)
                         if UIS:IsKeyDown(Enum.KeyCode.W) then d=Vector3.new(d.X+lv.X,d.Y+lv.Y,d.Z+lv.Z) end
                         if UIS:IsKeyDown(Enum.KeyCode.S) then d=Vector3.new(d.X-lv.X,d.Y-lv.Y,d.Z-lv.Z) end
                         if UIS:IsKeyDown(Enum.KeyCode.A) then d=Vector3.new(d.X-rv.X,d.Y-rv.Y,d.Z-rv.Z) end
                         if UIS:IsKeyDown(Enum.KeyCode.D) then d=Vector3.new(d.X+rv.X,d.Y+rv.Y,d.Z+rv.Z) end
                         if UIS:IsKeyDown(Enum.KeyCode.Space) then d=Vector3.new(d.X,d.Y+1,d.Z) end
                         if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d=Vector3.new(d.X,d.Y-1,d.Z) end
                         if d.Magnitude>0 then d=d.Unit end
                         bv.Velocity=d*(it._spd or 60); bg.CFrame=cam.CFrame
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

        {label="Slot 6", desc="Empty slot", state=false, enable=function()end, disable=function()end},
        {label="Slot 7", desc="Empty slot", state=false, enable=function()end, disable=function()end},
        {label="Slot 8", desc="Empty slot", state=false, enable=function()end, disable=function()end},
        {label="Slot 9", desc="Empty slot", state=false, enable=function()end, disable=function()end},
    }},

    {name="Player", icon="👤", items={
        {label="God Mode", desc="Infinite health", state=false, conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                     if h then h.Health=h.MaxHealth end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="High Jump", desc="Custom jump power", state=false,
         param={label="Jump Power", min=50, max=500, step=10, val=150,
          fmt=function(v) return math.floor(v).." pow" end,
          apply=function(v)
              pcall(function()
                  local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                  if h then h.JumpPower=v end
              end)
          end},
         enable=function(it)
             pcall(function()
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.JumpPower=it.param.val end
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

        {label="Freeze", desc="Anchor in place", state=false,
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

        {label="Low Gravity", desc="Custom gravity", state=false,
         param={label="Gravity", min=2, max=196, step=5, val=20,
          fmt=function(v) return math.floor(v).." g" end,
          apply=function(v) pcall(function() workspace.Gravity=v end) end},
         enable=function(it) pcall(function() workspace.Gravity=it.param.val end) end,
         disable=function() pcall(function() workspace.Gravity=196.2 end) end},

        {label="Slot 6", desc="Empty slot", state=false, enable=function()end, disable=function()end},
        {label="Slot 7", desc="Empty slot", state=false, enable=function()end, disable=function()end},
        {label="Slot 8", desc="Empty slot", state=false, enable=function()end, disable=function()end},
        {label="Slot 9", desc="Empty slot", state=false, enable=function()end, disable=function()end},
    }},

    {name="Visual", icon="👁", items={
        {label="Full Bright", desc="Max ambient", state=false, _old=nil,
         param={label="Brightness", min=1, max=10, step=0.5, val=2,
          fmt=function(v) return string.format("%.1f",v) end,
          apply=function(v)
              pcall(function()
                  game.Lighting.Ambient=Color3.fromRGB(255,255,255)
                  game.Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
                  game.Lighting.Brightness=v
              end)
          end},
         enable=function(it)
             pcall(function()
                 it._old={a=game.Lighting.Ambient,o=game.Lighting.OutdoorAmbient,b=game.Lighting.Brightness}
                 game.Lighting.Ambient=Color3.fromRGB(255,255,255)
                 game.Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
                 game.Lighting.Brightness=it.param.val
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

        {label="Time of Day", desc="Set clock hour", state=false,
         param={label="Clock Hour", min=0, max=24, step=0.5, val=12,
          fmt=function(v) local h=math.floor(v); return string.format("%02d:%02d",h,math.floor((v-h)*60)) end,
          apply=function(v) pcall(function() game.Lighting.ClockTime=v end) end},
         enable=function(it) pcall(function() game.Lighting.ClockTime=it.param.val end) end,
         disable=function() end},

        {label="No Fog", desc="Remove world fog", state=false, _old=nil,
         enable=function(it)
             pcall(function()
                 it._old={s=game.Lighting.FogStart,e=game.Lighting.FogEnd}
                 game.Lighting.FogStart=0; game.Lighting.FogEnd=1e6
             end)
         end,
         disable=function(it)
             pcall(function()
                 if it._old then game.Lighting.FogStart=it._old.s; game.Lighting.FogEnd=it._old.e end
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
                             bb.Size=UDim2.new(0,120,0,36)
                             bb.StudsOffset=Vector3.new(0,4,0)
                             bb.AlwaysOnTop=true
                             local lb=Instance.new("TextLabel",bb)
                             lb.Size=UDim2.new(1,0,1,0)
                             lb.BackgroundTransparency=1
                             lb.TextColor3=Color3.fromRGB(255,255,255)
                             lb.TextStrokeTransparency=0
                             lb.Text=pl.Name
                             lb.Font=Enum.Font.GothamBold
                             lb.TextSize=15
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

        {label="Slot 5", desc="Empty slot", state=false, enable=function()end, disable=function()end},
        {label="Slot 6", desc="Empty slot", state=false, enable=function()end, disable=function()end},
        {label="Slot 7", desc="Empty slot", state=false, enable=function()end, disable=function()end},
        {label="Slot 8", desc="Empty slot", state=false, enable=function()end, disable=function()end},
        {label="Slot 9", desc="Empty slot", state=false, enable=function()end, disable=function()end},
    }},
}

-- ══════════════════════════════════════════════
-- TOGGLE COMPONENT
-- ══════════════════════════════════════════════
local function MakeToggle(parent, initState, onChange)
    local W,H = 52,28
    local cont = New("Frame", {
        Size=UDim2.new(0,W,0,H),
        BackgroundTransparency=1,
    }, parent)

    local track = New("Frame", {
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=initState and C.Acc or C.SlTrack,
        BorderSizePixel=0,
    }, cont)
    Round(track, H/2)

    local knob = New("Frame", {
        Size=UDim2.new(0,H-8,0,H-8),
        Position=initState and UDim2.new(1,-(H-4),0.5,-(H-8)/2) or UDim2.new(0,4,0.5,-(H-8)/2),
        BackgroundColor3=C.White,
        BorderSizePixel=0,
        ZIndex=3,
    }, track)
    Round(knob, (H-8)/2)

    local on = initState or false

    local function Set(state, anim)
        on = state
        local tc = on and C.Acc or C.SlTrack
        local kp = on and UDim2.new(1,-(H-4),0.5,-(H-8)/2) or UDim2.new(0,4,0.5,-(H-8)/2)
        if anim then
            Tween(track,{BackgroundColor3=tc},0.18)
            Tween(knob,{Position=kp},0.18)
        else
            track.BackgroundColor3=tc; knob.Position=kp
        end
    end

    local btn = New("TextButton", {
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="", ZIndex=10,
    }, cont)

    btn.MouseButton1Click:Connect(function()
        Set(not on, true)
        if onChange then onChange(on) end
    end)

    return cont, {Set=Set, Get=function() return on end, Track=track, Knob=knob}
end

-- ══════════════════════════════════════════════
-- SLIDER COMPONENT
-- ══════════════════════════════════════════════
local function MakeSlider(parent, opts)
    local mn=opts.min or 0; local mx=opts.max or 100
    local st=opts.step or 1; local val=opts.val or mn
    local fmt=opts.fmt or function(v) return tostring(v) end

    local cont = New("Frame", {
        Size=UDim2.new(1,-10,0,40),
        BackgroundTransparency=1,
    }, parent)

    local valLbl = New("TextLabel", {
        Size=UDim2.new(0,60,0,16),
        Position=UDim2.new(1,-60,0,0),
        Text=fmt(val),
        TextSize=11,
        Font=Enum.Font.GothamMedium,
        TextColor3=C.Acc,
        BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Right,
    }, cont)

    local labelTxt = New("TextLabel", {
        Size=UDim2.new(1,-65,0,16),
        Position=UDim2.new(0,0,0,0),
        Text=opts.label or "",
        TextSize=10,
        Font=Enum.Font.Gotham,
        TextColor3=C.TxM,
        BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, cont)

    local trackFrame = New("Frame", {
        Size=UDim2.new(1,0,0,8),
        Position=UDim2.new(0,0,0,22),
        BackgroundColor3=C.SlTrack,
        BorderSizePixel=0,
        ClipsDescendants=false,
    }, cont)
    Round(trackFrame,4)

    local fill = New("Frame", {
        Size=UDim2.new((val-mn)/(mx-mn),0,1,0),
        BackgroundColor3=C.Acc,
        BorderSizePixel=0,
    }, trackFrame)
    Round(fill,4)

    local knob = New("Frame", {
        Size=UDim2.new(0,20,0,20),
        Position=UDim2.new(0,-10,0.5,-10),
        BackgroundColor3=C.Acc,
        BorderSizePixel=0,
        ZIndex=5,
    }, fill)
    Round(knob,10)
    local knobInner = New("Frame", {
        Size=UDim2.new(0,10,0,10),
        Position=UDim2.new(0.5,-5,0.5,-5),
        BackgroundColor3=C.White,
        BorderSizePixel=0,
    }, knob)
    Round(knobInner,5)

    local dragging=false

    local function Update(x)
        local abs=trackFrame.AbsolutePosition.X
        local sz=trackFrame.AbsoluteSize.X
        local pct=math.max(0,math.min(1,(x-abs)/sz))
        local raw=mn+pct*(mx-mn)
        local snap=math.floor(raw/st+0.5)*st
        snap=math.max(mn,math.min(mx,snap))
        if snap~=val then
            val=snap
            fill.Size=UDim2.new((val-mn)/(mx-mn),0,1,0)
            valLbl.Text=fmt(val)
            if opts.onChange then opts.onChange(val) end
        end
    end

    trackFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
        or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=true; Update(inp.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement
        or inp.UserInputType==Enum.UserInputType.Touch) then
            Update(inp.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
        or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=false
        end
    end)

    return cont, {GetValue=function() return val end}
end

-- ══════════════════════════════════════════════
-- CARD COMPONENT
-- ══════════════════════════════════════════════
local function MakeCard(parent, item)
    local cardWrap = New("Frame", {
        Size=UDim2.new(1,0,0,56),
        BackgroundTransparency=1,
        ClipsDescendants=false,
    }, parent)

    local card = New("Frame", {
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=C.BG2,
        BorderSizePixel=0,
        ClipsDescendants=true,
    }, cardWrap)
    Round(card,18)
    local stroke = Stroke(card, C.Bord, 1)

    -- Left bar
    local bar = New("Frame", {
        Size=UDim2.new(0,3,0,30),
        Position=UDim2.new(0,12,0.5,-15),
        BackgroundColor3=C.Acc,
        BorderSizePixel=0,
        Visible=item.state,
    }, card)
    Round(bar,2)

    -- Labels
    local lblMain = New("TextLabel", {
        Size=UDim2.new(1,-80,0,20),
        Position=UDim2.new(0,26,0,9),
        Text=item.label,
        TextSize=14,
        Font=Enum.Font.GothamMedium,
        TextColor3=item.state and C.TxW or C.TxH,
        BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, card)

    local lblDesc = New("TextLabel", {
        Size=UDim2.new(1,-80,0,14),
        Position=UDim2.new(0,26,0,30),
        Text=item.desc,
        TextSize=10,
        Font=Enum.Font.Gotham,
        TextColor3=item.state and C.TxM or C.TxL,
        BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, card)

    -- Toggle
    local tgCont, tgCtrl = MakeToggle(card, item.state, nil)
    tgCont.Position = UDim2.new(1,-66,0.5,-14)
    tgCont.ZIndex = 5

    -- Param panel
    local paramPanel = nil
    local paramVisible = false

    if item.param then
        paramPanel = New("Frame", {
            Size=UDim2.new(1,-4,0,0),
            Position=UDim2.new(0,2,1,4),
            BackgroundColor3=Color3.fromRGB(10,11,20),
            BorderSizePixel=0,
            ClipsDescendants=true,
            Visible=false,
        }, cardWrap)
        Round(paramPanel,14)
        Stroke(paramPanel, C.AccLine, 1)

        local pp=item.param
        local innerPad = New("Frame", {
            Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
        }, paramPanel)
        Pad(innerPad, nil, 10, 10, 14, 14)

        MakeSlider(innerPad, {
            label=pp.label,
            min=pp.min, max=pp.max, step=pp.step, val=pp.val,
            fmt=pp.fmt,
            onChange=function(v)
                pp.val=v
                if pp.apply and item.state then pp.apply(v,item) end
            end,
        })
    end

    -- State update function
    local function ApplyState(state, animate)
        item.state = state
        local bgCol = state and C.BG4 or C.BG2
        local bdCol = state and C.BordA or C.Bord
        local lblCol = state and C.TxW or C.TxH
        local dscCol = state and C.TxM or C.TxL

        if animate then
            Tween(card, {BackgroundColor3=bgCol}, 0.2)
        else
            card.BackgroundColor3=bgCol
        end
        stroke.Color = bdCol
        bar.Visible = state
        lblMain.TextColor3 = lblCol
        lblDesc.TextColor3 = dscCol

        -- Param panel
        if paramPanel then
            if state then
                paramPanel.Visible=true
                paramVisible=true
                Tween(paramPanel, {Size=UDim2.new(1,-4,0,64)}, 0.22)
                Tween(cardWrap,   {Size=UDim2.new(1,0,0,128)}, 0.22)
            else
                paramVisible=false
                Tween(paramPanel, {Size=UDim2.new(1,-4,0,0)},  0.18)
                Tween(cardWrap,   {Size=UDim2.new(1,0,0,56)},  0.18)
                task.delay(0.19, function()
                    if not item.state then paramPanel.Visible=false end
                end)
            end
        end

        if state then pcall(item.enable, item)
        else pcall(item.disable, item) end
    end

    -- Connect toggle
    local btn = New("TextButton", {
        Size=UDim2.new(1,0,0,56),
        BackgroundTransparency=1,
        Text="", ZIndex=8,
    }, card)

    btn.MouseButton1Click:Connect(function()
        tgCtrl.Set(not item.state, true)
        ApplyState(not item.state, true)
    end)

    -- Also wire the toggle button itself
    local tgBtn = tgCont:FindFirstChildOfClass("TextButton")
    if tgBtn then
        tgBtn.MouseButton1Click:Connect(function()
            -- prevent double fire - toggle already called ApplyState via btn
        end)
    end

    -- Hover
    card.MouseEnter:Connect(function()
        if not item.state then
            Tween(card,{BackgroundColor3=C.BG3},0.15)
            stroke.Color=C.BordH
        end
    end)
    card.MouseLeave:Connect(function()
        if not item.state then
            Tween(card,{BackgroundColor3=C.BG2},0.15)
            stroke.Color=C.Bord
        end
    end)

    -- Init state
    if item.state then
        card.BackgroundColor3=C.BG4
        stroke.Color=C.BordA
    end

    return cardWrap
end

-- ══════════════════════════════════════════════
-- BUILD UI
-- ══════════════════════════════════════════════
local VP = workspace.CurrentCamera.ViewportSize
local PW = math.min(680, math.floor(VP.X*0.60))
local PH = math.min(620, math.floor(VP.Y*0.88))
local PX = math.floor((VP.X-PW)/2)
local PY = math.floor((VP.Y-PH)/2)

local Open = true
local CurTab = 1

-- ── MINI BUTTON ──────────────────────────────
local miniBtn = New("TextButton", {
    Size=UDim2.new(0,50,0,50),
    Position=UDim2.new(0,12,0.5,-25),
    BackgroundColor3=C.SB0,
    BorderSizePixel=0,
    Text="L",
    TextSize=20,
    Font=Enum.Font.GothamBold,
    TextColor3=C.Acc,
    Visible=false,
    ZIndex=20,
    AutoButtonColor=false,
}, Screen)
Round(miniBtn,18)
Stroke(miniBtn,C.AccLine,1.5)
Shadow(miniBtn,20)

-- ── SIDEBAR ──────────────────────────────────
local sidebarWrap = New("Frame", {
    Size=UDim2.new(0,68,0,10),
    Position=UDim2.new(0,PX-82,0,PY),
    BackgroundColor3=C.SB0,
    BorderSizePixel=0,
    AutomaticSize=Enum.AutomaticSize.Y,
    ClipsDescendants=false,
}, Screen)
Round(sidebarWrap,26)
Stroke(sidebarWrap,C.AccSoft,1.5)
Shadow(sidebarWrap,18)

local sideInner = New("Frame", {
    Size=UDim2.new(1,0,0,10),
    BackgroundTransparency=1,
    AutomaticSize=Enum.AutomaticSize.Y,
}, sidebarWrap)
Pad(sideInner,10)
List(sideInner, Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center)

New("TextLabel", {
    Size=UDim2.new(1,0,0,12),
    Text="MENU",
    TextSize=7,
    Font=Enum.Font.GothamBold,
    TextColor3=C.TxL,
    BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Center,
    LayoutOrder=0,
}, sideInner)

-- Nav buttons
local NAV_ICONS = {"⚡","👤","👁","⚙"}
local NAV_TABS  = {"Main","Player","Visual","Settings"}
local navBtns   = {}

local function BuildNav()
    for _,b in ipairs(navBtns) do b:Destroy() end
    navBtns={}
    for i=1,4 do
        local isAct = (CurTab==i)
        local nb = New("TextButton", {
            Size=UDim2.new(0,48,0,48),
            BackgroundColor3=isAct and C.SB2 or C.SB0,
            BorderSizePixel=0,
            Text="",
            AutoButtonColor=false,
            LayoutOrder=i,
        }, sideInner)
        Round(nb,16)
        if isAct then Stroke(nb,C.Acc,1.5) end

        New("TextLabel", {
            Size=UDim2.new(1,0,1,0),
            Text=NAV_ICONS[i],
            TextSize=22,
            Font=Enum.Font.GothamBold,
            TextColor3=isAct and C.Acc or C.TxL,
            BackgroundTransparency=1,
            TextXAlignment=Enum.TextXAlignment.Center,
        }, nb)

        if isAct then
            local dot = New("Frame", {
                Size=UDim2.new(0,5,0,5),
                Position=UDim2.new(1,-2,0.5,-2.5),
                BackgroundColor3=C.Acc,
                BorderSizePixel=0,
            }, nb)
            Round(dot,3)
        end

        nb.MouseEnter:Connect(function()
            if not isAct then Tween(nb,{BackgroundColor3=C.SB1},0.15) end
        end)
        nb.MouseLeave:Connect(function()
            if not isAct then Tween(nb,{BackgroundColor3=C.SB0},0.15) end
        end)
        nb.MouseButton1Click:Connect(function()
            CurTab=i; BuildNav(); RefreshContent()
        end)
        table.insert(navBtns,nb)
    end
end

-- ── MAIN PANEL ───────────────────────────────
local panel = New("Frame", {
    Size=UDim2.new(0,PW,0,PH),
    Position=UDim2.new(0,PX,0,PY),
    BackgroundColor3=C.BG1,
    BorderSizePixel=0,
    ClipsDescendants=false,
}, Screen)
Round(panel,22)
Stroke(panel,C.Bord,1.5)
Shadow(panel,30)

-- Clip inner content
local panelClip = New("Frame", {
    Size=UDim2.new(1,0,1,0),
    BackgroundTransparency=1,
    ClipsDescendants=true,
}, panel)
Round(panelClip,22)

-- HEADER
local header = New("Frame", {
    Size=UDim2.new(1,0,0,68),
    BackgroundColor3=C.BG2,
    BorderSizePixel=0,
}, panelClip)
Round(header,22)

-- Fix bottom corners of header
New("Frame", {
    Size=UDim2.new(1,0,0,24),
    Position=UDim2.new(0,0,1,-24),
    BackgroundColor3=C.BG2,
    BorderSizePixel=0,
}, header)

-- Purple accent line
New("Frame", {
    Size=UDim2.new(1,0,0,2),
    Position=UDim2.new(0,0,1,-2),
    BackgroundColor3=C.Acc,
    BorderSizePixel=0,
}, header)

-- Logo
local logoOuter = New("Frame", {
    Size=UDim2.new(0,42,0,42),
    Position=UDim2.new(0,14,0.5,-21),
    BackgroundColor3=C.Acc3,
    BorderSizePixel=0,
}, header)
Round(logoOuter,21)
Stroke(logoOuter,C.AccLine,1.5)

local logoInner = New("Frame", {
    Size=UDim2.new(0,34,0,34),
    Position=UDim2.new(0.5,-17,0.5,-17),
    BackgroundColor3=C.AccSoft,
    BorderSizePixel=0,
}, logoOuter)
Round(logoInner,17)

New("TextLabel", {
    Size=UDim2.new(1,0,1,0),
    Text="L",
    TextSize=20,
    Font=Enum.Font.GothamBold,
    TextColor3=C.Acc,
    BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Center,
}, logoOuter)

-- Title
New("TextLabel", {
    Size=UDim2.new(0,200,0,28),
    Position=UDim2.new(0,64,0,10),
    RichText=true,
    Text='<font color="#F5F5FF" weight="700">LUXURY </font><font color="#9364FF" weight="700">HUB</font>',
    TextSize=19,
    Font=Enum.Font.GothamBold,
    TextColor3=C.TxW,
    BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Left,
}, header)

New("TextLabel", {
    Size=UDim2.new(0,200,0,14),
    Position=UDim2.new(0,65,0,38),
    Text="PREMIUM CONTROLS",
    TextSize=9,
    Font=Enum.Font.GothamMedium,
    TextColor3=C.TxL,
    BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Left,
}, header)

-- Close button
local closeBtn = New("TextButton", {
    Size=UDim2.new(0,28,0,28),
    Position=UDim2.new(1,-38,0.5,-14),
    BackgroundColor3=C.BG3,
    BorderSizePixel=0,
    Text="✕",
    TextSize=12,
    Font=Enum.Font.GothamBold,
    TextColor3=C.TxM,
    AutoButtonColor=false,
    ZIndex=10,
}, header)
Round(closeBtn,14)
Stroke(closeBtn,C.Bord,1)

closeBtn.MouseEnter:Connect(function() Tween(closeBtn,{BackgroundColor3=C.Red},0.15) end)
closeBtn.MouseLeave:Connect(function() Tween(closeBtn,{BackgroundColor3=C.BG3},0.15) end)

-- Minimize button
local minBtn = New("TextButton", {
    Size=UDim2.new(0,28,0,28),
    Position=UDim2.new(1,-74,0.5,-14),
    BackgroundColor3=C.BG3,
    BorderSizePixel=0,
    Text="─",
    TextSize=14,
    Font=Enum.Font.GothamBold,
    TextColor3=C.TxM,
    AutoButtonColor=false,
    ZIndex=10,
}, header)
Round(minBtn,14)
Stroke(minBtn,C.Bord,1)
minBtn.MouseEnter:Connect(function() Tween(minBtn,{BackgroundColor3=C.BG4},0.15) end)
minBtn.MouseLeave:Connect(function() Tween(minBtn,{BackgroundColor3=C.BG3},0.15) end)

-- CONTENT SCROLL
local contentScroll = New("ScrollingFrame", {
    Size=UDim2.new(1,0,1,-68-32),
    Position=UDim2.new(0,0,0,68),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    ScrollBarThickness=3,
    ScrollBarImageColor3=C.AccSoft,
    CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ClipsDescendants=true,
}, panelClip)
Pad(contentScroll,nil,8,8,10,10)
List(contentScroll,Enum.FillDirection.Vertical,6)

-- FOOTER
local footer = New("Frame", {
    Size=UDim2.new(1,0,0,32),
    Position=UDim2.new(0,0,1,-32),
    BackgroundColor3=C.BG1,
    BorderSizePixel=0,
}, panelClip)

New("Frame",{
    Size=UDim2.new(1,-24,0,1),
    Position=UDim2.new(0,12,0,0),
    BackgroundColor3=C.Sep,
    BorderSizePixel=0,
}, footer)

local footStatus = New("TextLabel",{
    Size=UDim2.new(0.35,0,1,0),
    Position=UDim2.new(0,14,0,0),
    Text="0 active",
    TextSize=10,
    Font=Enum.Font.Gotham,
    TextColor3=C.TxL,
    BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Left,
}, footer)

local footTab = New("TextLabel",{
    Size=UDim2.new(0.3,0,1,0),
    Position=UDim2.new(0.35,0,0,0),
    Text="Main",
    TextSize=10,
    Font=Enum.Font.GothamMedium,
    TextColor3=C.TxM,
    BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Center,
}, footer)

New("TextLabel",{
    Size=UDim2.new(0.3,0,1,0),
    Position=UDim2.new(0.7,0,0,0),
    Text="RShift",
    TextSize=10,
    Font=Enum.Font.Gotham,
    TextColor3=C.TxF,
    BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Right,
}, footer)

-- ══════════════════════════════════════════════
-- CONTENT BUILDER
-- ══════════════════════════════════════════════
function RefreshContent()
    for _,c in ipairs(contentScroll:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end

    footTab.Text = NAV_TABS[CurTab] or "?"

    if CurTab <= 3 then
        local tab = TABS[CurTab]
        for _,item in ipairs(tab.items) do
            MakeCard(contentScroll, item)
        end
        local function UpdateStatus()
            local cnt=0
            for _,it in ipairs(tab.items) do if it.state then cnt=cnt+1 end end
            footStatus.Text=cnt.." active"
            footStatus.TextColor3=cnt>0 and C.Green or C.TxL
        end
        UpdateStatus()
        -- Status update on each toggle (listen for changes)
        RS.Heartbeat:Connect(function()
            UpdateStatus()
        end)
    else
        -- Settings
        footStatus.Text="settings"
        footStatus.TextColor3=C.TxL

        local function SecLabel(txt)
            New("TextLabel",{
                Size=UDim2.new(1,0,0,14),
                Text=txt,
                TextSize=9,
                Font=Enum.Font.GothamBold,
                TextColor3=C.TxL,
                BackgroundTransparency=1,
                TextXAlignment=Enum.TextXAlignment.Left,
            }, contentScroll)
        end

        SecLabel("HOTKEY")
        local hkF = New("Frame",{
            Size=UDim2.new(1,0,0,40),
            BackgroundColor3=C.BG3,
            BorderSizePixel=0,
        }, contentScroll)
        Round(hkF,14)
        Stroke(hkF,C.AccLine,1)
        New("TextLabel",{
            Size=UDim2.new(1,0,1,0),
            Text="RIGHT SHIFT  ·  Toggle UI Visibility",
            TextSize=12,
            Font=Enum.Font.GothamMedium,
            TextColor3=C.Acc,
            BackgroundTransparency=1,
            TextXAlignment=Enum.TextXAlignment.Center,
        }, hkF)

        SecLabel("ACTIVITY")
        for ti=1,3 do
            local t=TABS[ti]; local cnt=0
            for _,it in ipairs(t.items) do if it.state then cnt=cnt+1 end end
            local row=New("Frame",{
                Size=UDim2.new(1,0,0,36),
                BackgroundColor3=C.BG2,
                BorderSizePixel=0,
            },contentScroll)
            Round(row,12)
            New("TextLabel",{
                Size=UDim2.new(0,70,1,0),
                Position=UDim2.new(0,12,0,0),
                Text=t.name,
                TextSize=12,
                Font=Enum.Font.GothamMedium,
                TextColor3=C.TxM,
                BackgroundTransparency=1,
                TextXAlignment=Enum.TextXAlignment.Left,
            },row)
            local bW=PW-200
            local tr=New("Frame",{
                Size=UDim2.new(0,bW,0,8),
                Position=UDim2.new(0,90,0.5,-4),
                BackgroundColor3=C.SlTrack,
                BorderSizePixel=0,
            },row)
            Round(tr,4)
            if cnt>0 then
                local fi=New("Frame",{
                    Size=UDim2.new(cnt/#t.items,0,1,0),
                    BackgroundColor3=C.Acc,
                    BorderSizePixel=0,
                },tr)
                Round(fi,4)
            end
            New("TextLabel",{
                Size=UDim2.new(0,50,1,0),
                Position=UDim2.new(1,-55,0,0),
                Text=cnt.."/"..#t.items,
                TextSize=10,
                Font=Enum.Font.Gotham,
                TextColor3=C.TxL,
                BackgroundTransparency=1,
                TextXAlignment=Enum.TextXAlignment.Right,
            },row)
        end
    end
end

-- ══════════════════════════════════════════════
-- OPEN / CLOSE
-- ══════════════════════════════════════════════
local function ShowUI()
    Open=true
    miniBtn.Visible=false
    panel.Visible=true
    sidebarWrap.Visible=true
    panel.Size=UDim2.new(0,PW,0,0)
    panel.BackgroundTransparency=1
    Tween(panel,{Size=UDim2.new(0,PW,0,PH),BackgroundTransparency=0},0.28)
    Tween(sidebarWrap,{BackgroundTransparency=0},0.2)
end

local function HideUI()
    Open=false
    Tween(panel,{Size=UDim2.new(0,PW,0,0)},0.22)
    Tween(sidebarWrap,{BackgroundTransparency=1},0.18)
    task.delay(0.23,function()
        panel.Visible=false
        sidebarWrap.Visible=false
        miniBtn.Visible=true
        Tween(miniBtn,{BackgroundTransparency=0},0.18)
    end)
end

closeBtn.MouseButton1Click:Connect(HideUI)
minBtn.MouseButton1Click:Connect(HideUI)
miniBtn.MouseButton1Click:Connect(ShowUI)

-- ══════════════════════════════════════════════
-- DRAG
-- ══════════════════════════════════════════════
local dragging=false; local dragStart; local startPos

header.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true; dragStart=inp.Position; startPos=panel.Position
    end
end)

UIS.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
        local d=inp.Position-dragStart
        local np=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        panel.Position=np
        -- Sync sidebar
        task.defer(function()
            local px=panel.AbsolutePosition.X
            local py=panel.AbsolutePosition.Y
            local ph=panel.AbsoluteSize.Y
            local sh=sidebarWrap.AbsoluteSize.Y
            sidebarWrap.Position=UDim2.new(0,px-82,0,py+math.floor((ph-sh)/2))
        end)
    end
end)

UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

-- ══════════════════════════════════════════════
-- HOTKEY
-- ══════════════════════════════════════════════
UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.RightShift then
        if Open then HideUI() else ShowUI() end
    end
end)

-- ══════════════════════════════════════════════
-- RESPAWN
-- ══════════════════════════════════════════════
LP.CharacterAdded:Connect(function()
    task.wait(1)
    for _,tab in ipairs(TABS) do
        for _,item in ipairs(tab.items) do
            if item.state then pcall(item.enable,item) end
        end
    end
end)

-- ══════════════════════════════════════════════
-- INIT
-- ══════════════════════════════════════════════
BuildNav()
RefreshContent()

-- Position sidebar relative to panel
task.defer(function()
    local px=panel.AbsolutePosition.X
    local py=panel.AbsolutePosition.Y
    local ph=panel.AbsoluteSize.Y
    local sh=sidebarWrap.AbsoluteSize.Y
    sidebarWrap.Position=UDim2.new(0,px-82,0,py+math.floor((ph-sh)/2))
end)

print("LUXURY HUB v20 — OK")
