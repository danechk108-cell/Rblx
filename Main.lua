-- LUXURY HUB v24 - Fixed + No Emoji
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TW = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

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

local C = {
    BG0  = Color3.fromRGB(28,29,32),
    BG1  = Color3.fromRGB(33,34,38),
    BG2  = Color3.fromRGB(40,41,46),
    BG3  = Color3.fromRGB(48,49,55),
    BG4  = Color3.fromRGB(55,57,64),
    BG5  = Color3.fromRGB(62,64,72),
    SB0  = Color3.fromRGB(24,25,28),
    SB1  = Color3.fromRGB(32,33,37),
    SB2  = Color3.fromRGB(42,43,49),
    Acc  = Color3.fromRGB(130,100,240),
    AccS = Color3.fromRGB(80,55,170),
    AccL = Color3.fromRGB(100,75,200),
    AccG = Color3.fromRGB(50,35,110),
    TxW  = Color3.fromRGB(235,235,230),
    TxH  = Color3.fromRGB(185,185,178),
    TxM  = Color3.fromRGB(130,132,126),
    TxL  = Color3.fromRGB(85,87,82),
    TxF  = Color3.fromRGB(55,57,52),
    Bord = Color3.fromRGB(55,57,65),
    BordH= Color3.fromRGB(72,74,84),
    Sep  = Color3.fromRGB(45,47,54),
    Green= Color3.fromRGB(80,200,120),
    Red  = Color3.fromRGB(210,80,80),
    Blue = Color3.fromRGB(80,160,240),
    Yel  = Color3.fromRGB(220,190,80),
    White= Color3.fromRGB(255,255,255),
    SlT  = Color3.fromRGB(30,31,36),
}

local Settings = {
    PW=680, PH=620,
    miniSize=50,
    miniSide="left",
    miniYPct=0.5,
    animSpeed=0.20,
}

local function New(cls,props,parent)
    local i=Instance.new(cls)
    for k,v in pairs(props or {}) do i[k]=v end
    if parent then i.Parent=parent end
    return i
end
local function Tw(inst,props,t)
    if not inst or not inst.Parent then return end
    TW:Create(inst,TweenInfo.new(t or Settings.animSpeed,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),props):Play()
end
local function Rnd(inst,r)
    local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 12);c.Parent=inst;return c
end
local function Strk(inst,col,th)
    local s=Instance.new("UIStroke");s.Color=col or C.Bord;s.Thickness=th or 1.2
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;s.Parent=inst;return s
end
local function Pd(inst,a,t,b,l,r)
    local p=Instance.new("UIPadding")
    if a then
        p.PaddingTop=UDim.new(0,a);p.PaddingBottom=UDim.new(0,a)
        p.PaddingLeft=UDim.new(0,a);p.PaddingRight=UDim.new(0,a)
    else
        if t then p.PaddingTop=UDim.new(0,t) end
        if b then p.PaddingBottom=UDim.new(0,b) end
        if l then p.PaddingLeft=UDim.new(0,l) end
        if r then p.PaddingRight=UDim.new(0,r) end
    end
    p.Parent=inst;return p
end
local function Lst(inst,dir,pad,ha)
    local l=Instance.new("UIListLayout")
    l.FillDirection=dir or Enum.FillDirection.Vertical
    l.Padding=UDim.new(0,pad or 6)
    l.HorizontalAlignment=ha or Enum.HorizontalAlignment.Left
    l.SortOrder=Enum.SortOrder.LayoutOrder
    l.Parent=inst;return l
end

-- safe clipboard
local function SafeClipboard(str)
    pcall(function()
        if setclipboard then setclipboard(str)
        elseif rbxassetid then -- fallback
        end
    end)
end

-- ══════════════════════════════════════════════
-- NOTIFY
-- ══════════════════════════════════════════════
local notifStack={}
local function Notify(title,msg,col)
    local n=New("Frame",{
        Size=UDim2.new(0,300,0,68),
        Position=UDim2.new(1,320,1,-90),
        BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=200
    },Screen)
    Rnd(n,14);Strk(n,col or C.Acc,1.5)

    local bar=New("Frame",{Size=UDim2.new(0,4,1,0),BackgroundColor3=col or C.Acc,BorderSizePixel=0,ZIndex=201},n)
    Rnd(bar,2)

    New("TextLabel",{
        Size=UDim2.new(1,-18,0,24),Position=UDim2.new(0,14,0,6),
        Text=title,TextSize=13,Font=Enum.Font.GothamBold,
        TextColor3=col or C.Acc,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202
    },n)
    New("TextLabel",{
        Size=UDim2.new(1,-18,0,18),Position=UDim2.new(0,14,0,32),
        Text=msg,TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202
    },n)

    table.insert(notifStack,n)
    for i,nn in ipairs(notifStack) do
        local ty=-90-(#notifStack-i)*74
        Tw(nn,{Position=UDim2.new(1,-312,1,ty)},0.3)
    end

    task.delay(3.8,function()
        Tw(n,{Position=UDim2.new(1,320,1,-90)},0.28)
        task.delay(0.35,function()
            pcall(function()
                for i,nn in ipairs(notifStack) do
                    if nn==n then table.remove(notifStack,i);break end
                end
                n:Destroy()
            end)
        end)
    end)
end

-- ══════════════════════════════════════════════
-- ICON BADGE (text-based, no emoji)
-- ══════════════════════════════════════════════
local function MakeIconBadge(parent, txt, col, size)
    size = size or 34
    local f=New("Frame",{
        Size=UDim2.new(0,size,0,size),
        BackgroundColor3=col and Color3.fromRGB(
            math.floor(col.R*40),
            math.floor(col.G*40),
            math.floor(col.B*40)
        ) or C.BG3,
        BorderSizePixel=0
    },parent)
    Rnd(f,8)
    Strk(f,col or C.Bord,1)
    New("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        Text=txt,
        TextSize=size>30 and 11 or 9,
        Font=Enum.Font.GothamBold,
        TextColor3=col or C.TxL,
        BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Center
    },f)
    return f
end

-- ══════════════════════════════════════════════
-- SLIDER
-- ══════════════════════════════════════════════
local function MakeSlider(parent,opts)
    local mn=opts.min or 0;local mx=opts.max or 100
    local st=opts.step or 1;local val=opts.val or mn
    local fmt=opts.fmt or tostring

    local cont=New("Frame",{Size=UDim2.new(1,0,0,54),BackgroundTransparency=1},parent)
    local row=New("Frame",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1},cont)
    New("TextLabel",{
        Size=UDim2.new(1,-70,1,0),Text=opts.label or "",TextSize=10,
        Font=Enum.Font.GothamMedium,TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left
    },row)
    local valLbl=New("TextLabel",{
        Size=UDim2.new(0,68,1,0),Position=UDim2.new(1,-68,0,0),
        Text=fmt(val),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.Acc,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right
    },row)

    local trackBg=New("Frame",{
        Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,0,28),
        BackgroundColor3=C.SlT,BorderSizePixel=0
    },cont)
    Rnd(trackBg,4);Strk(trackBg,C.Bord,0.8)

    local fill=New("Frame",{
        Size=UDim2.new(math.max(0,math.min(1,(val-mn)/(mx-mn))),0,1,0),
        BackgroundColor3=C.Acc,BorderSizePixel=0
    },trackBg)
    Rnd(fill,4)

    local knob=New("Frame",{
        Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,-10,0.5,-10),
        BackgroundColor3=C.Acc,BorderSizePixel=0,ZIndex=6
    },fill)
    Rnd(knob,10);Strk(knob,C.AccG,1.5)
    local ki=New("Frame",{
        Size=UDim2.new(0,8,0,8),Position=UDim2.new(0.5,-4,0.5,-4),
        BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=7
    },knob)
    Rnd(ki,4)

    local dragging=false
    local function Update(x)
        local abs=trackBg.AbsolutePosition.X
        local sz=trackBg.AbsoluteSize.X
        if sz<=0 then return end
        local pct=math.max(0,math.min(1,(x-abs)/sz))
        local raw=mn+pct*(mx-mn)
        local snap=math.floor(raw/st+0.5)*st
        snap=math.max(mn,math.min(mx,snap))
        if snap~=val then
            val=snap
            fill.Size=UDim2.new(math.max(0,math.min(1,(val-mn)/(mx-mn))),0,1,0)
            valLbl.Text=fmt(val)
            if opts.onChange then opts.onChange(val) end
        end
    end

    local hit=New("TextButton",{
        Size=UDim2.new(1,0,0,36),Position=UDim2.new(0,0,0,18),
        BackgroundTransparency=1,Text="",ZIndex=9
    },cont)
    hit.MouseButton1Down:Connect(function(x) dragging=true;Update(x) end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then Update(i.Position.X) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    return cont
end

-- ══════════════════════════════════════════════
-- TOGGLE
-- ══════════════════════════════════════════════
local function MakeToggle(parent,init,onChange)
    local H=26
    local cont=New("Frame",{Size=UDim2.new(0,50,0,H),BackgroundTransparency=1},parent)
    local track=New("Frame",{Size=UDim2.new(1,0,1,0),
        BackgroundColor3=init and C.Acc or C.BG0,BorderSizePixel=0},cont)
    Rnd(track,H/2);Strk(track,init and C.AccL or C.Bord,1)
    local kn=New("Frame",{
        Size=UDim2.new(0,H-6,0,H-6),
        Position=init and UDim2.new(1,-(H-3),0.5,-(H-6)/2) or UDim2.new(0,3,0.5,-(H-6)/2),
        BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=3
    },track)
    Rnd(kn,(H-6)/2)
    local on=init or false
    local function Set(s,anim)
        on=s
        local pos=on and UDim2.new(1,-(H-3),0.5,-(H-6)/2) or UDim2.new(0,3,0.5,-(H-6)/2)
        if anim then
            Tw(track,{BackgroundColor3=on and C.Acc or C.BG0},0.18)
            Tw(kn,{Position=pos},0.18)
        else
            track.BackgroundColor3=on and C.Acc or C.BG0
            kn.Position=pos
        end
        local uk=track:FindFirstChildOfClass("UIStroke")
        if uk then uk.Color=on and C.AccL or C.Bord end
    end
    local btn=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=10},cont)
    btn.MouseButton1Click:Connect(function() Set(not on,true);if onChange then onChange(on) end end)
    return cont,{Set=Set,Get=function() return on end}
end

-- ══════════════════════════════════════════════
-- SECTION LABEL
-- ══════════════════════════════════════════════
local function SecLbl(parent,txt,col)
    local f=New("Frame",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1},parent)
    local dot=New("Frame",{Size=UDim2.new(0,10,0,10),Position=UDim2.new(0,0,0.5,-5),
        BackgroundColor3=col or C.Acc,BorderSizePixel=0},f)
    Rnd(dot,3)
    New("TextLabel",{
        Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,16,0,0),
        Text=txt,TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.TxM,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left
    },f)
    New("Frame",{
        Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=C.Sep,BorderSizePixel=0
    },f)
    return f
end

-- ══════════════════════════════════════════════
-- CARD
-- ══════════════════════════════════════════════
local function MakeCard(parent,item,tabCol)
    local tc=tabCol or C.Acc
    local baseH=62
    local expandH=baseH+80

    local wrap=New("Frame",{
        Size=UDim2.new(1,0,0,baseH),
        BackgroundTransparency=1,ClipsDescendants=false
    },parent)

    local card=New("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=item.state and C.BG4 or C.BG2,
        BorderSizePixel=0,ClipsDescendants=true,ZIndex=1
    },wrap)
    Rnd(card,14)
    local strk=Strk(card,item.state and tc or C.Bord,1.2)

    -- left accent bar
    local bar=New("Frame",{
        Size=UDim2.new(0,3,0,30),Position=UDim2.new(0,0,0.5,-15),
        BackgroundColor3=tc,BorderSizePixel=0,Visible=item.state,ZIndex=2
    },card)
    Rnd(bar,2)

    -- icon badge (text-based)
    local iconBadge=MakeIconBadge(card,item.icon or "?",item.state and tc or C.TxL,34)
    iconBadge.Position=UDim2.new(0,12,0.5,-17)
    iconBadge.ZIndex=2

    local lbl=New("TextLabel",{
        Size=UDim2.new(1,-118,0,22),Position=UDim2.new(0,56,0,10),
        Text=item.label,TextSize=13,Font=Enum.Font.GothamBold,
        TextColor3=item.state and C.TxW or C.TxH,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2
    },card)

    local dsc=New("TextLabel",{
        Size=UDim2.new(1,-118,0,16),Position=UDim2.new(0,56,0,34),
        Text=item.desc,TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=item.state and C.TxM or C.TxL,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2
    },card)

    local paramPanel=nil
    if item.param then
        paramPanel=New("Frame",{
            Size=UDim2.new(1,-8,0,0),
            Position=UDim2.new(0,4,1,4),
            BackgroundColor3=C.BG1,
            BorderSizePixel=0,ClipsDescendants=true,Visible=false
        },wrap)
        Rnd(paramPanel,12);Strk(paramPanel,tc,1)
        local inner=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},paramPanel)
        Pd(inner,nil,10,8,14,14)
        local pp=item.param
        MakeSlider(inner,{
            label=pp.label,min=pp.min,max=pp.max,step=pp.step,val=pp.val,fmt=pp.fmt,
            onChange=function(v)
                pp.val=v
                if pp.apply then pp.apply(v,item) end
            end,
        })
    end

    local function ApplyState(s,anim)
        local dur=anim and 0.18 or 0
        if dur>0 then Tw(card,{BackgroundColor3=s and C.BG4 or C.BG2},dur)
        else card.BackgroundColor3=s and C.BG4 or C.BG2 end
        strk.Color=s and tc or C.Bord
        bar.Visible=s
        lbl.TextColor3=s and C.TxW or C.TxH
        dsc.TextColor3=s and C.TxM or C.TxL

        if dur>0 then
            Tw(iconBadge,{BackgroundColor3=s and Color3.fromRGB(
                math.floor(tc.R*40),math.floor(tc.G*40),math.floor(tc.B*40)
            ) or C.BG3},dur)
        else
            iconBadge.BackgroundColor3=s and Color3.fromRGB(
                math.floor(tc.R*40),math.floor(tc.G*40),math.floor(tc.B*40)
            ) or C.BG3
        end
        local ic=iconBadge:FindFirstChildOfClass("TextLabel")
        if ic then ic.TextColor3=s and tc or C.TxL end
        local ik=iconBadge:FindFirstChildOfClass("UIStroke")
        if ik then ik.Color=s and tc or C.Bord end

        if paramPanel then
            if s then
                paramPanel.Visible=true
                Tw(paramPanel,{Size=UDim2.new(1,-8,0,76)},0.22)
                Tw(wrap,{Size=UDim2.new(1,0,0,expandH)},0.22)
            else
                Tw(paramPanel,{Size=UDim2.new(1,-8,0,0)},0.18)
                Tw(wrap,{Size=UDim2.new(1,0,0,baseH)},0.18)
                task.delay(0.22,function()
                    if not item.state and paramPanel and paramPanel.Parent then
                        paramPanel.Visible=false
                    end
                end)
            end
        end
    end

    local tgC,tgCtrl=MakeToggle(card,item.state,nil)
    tgC.Position=UDim2.new(1,-66,0.5,-13);tgC.ZIndex=5

    local function DoToggle()
        local ns=not item.state
        item.state=ns
        tgCtrl.Set(ns,true)
        ApplyState(ns,true)
        if ns then
            local ok=true
            pcall(function()
                local r=item.enable(item)
                if r==false then ok=false end
            end)
            if not ok then
                item.state=false;tgCtrl.Set(false,true);ApplyState(false,true)
            else
                Notify(item.label,"Включено",C.Green)
            end
        else
            pcall(item.disable,item)
            Notify(item.label,"Выключено",C.TxL)
        end
    end

    local hit=New("TextButton",{
        Size=UDim2.new(1,0,0,baseH),BackgroundTransparency=1,Text="",ZIndex=8
    },card)
    hit.MouseButton1Click:Connect(DoToggle)

    card.MouseEnter:Connect(function()
        if not item.state then Tw(card,{BackgroundColor3=C.BG3},0.12);strk.Color=C.BordH end
    end)
    card.MouseLeave:Connect(function()
        if not item.state then Tw(card,{BackgroundColor3=C.BG2},0.12);strk.Color=C.Bord end
    end)

    if item.state then ApplyState(true,false) end
    return wrap
end

-- ══════════════════════════════════════════════
-- PLAYER SECTIONS
-- ══════════════════════════════════════════════
local PLAYER_SECTIONS = {
    {title="ДВИЖЕНИЕ", col=Color3.fromRGB(130,100,240), items={
        {label="Speed Boost",icon="SPD",desc="Ускорение ходьбы",state=false,
         param={label="Множитель скорости",min=1,max=20,step=0.5,val=2.5,
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

        {label="High Jump",icon="JMP",desc="Высокий прыжок",state=false,
         param={label="Сила прыжка",min=50,max=600,step=10,val=150,
          fmt=function(v) return math.floor(v) end,
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

        {label="Infinite Jump",icon="INF",desc="Прыгай бесконечно в воздухе",state=false,conn=nil,
         enable=function(it)
             it.conn=UIS.JumpRequest:Connect(function()
                 pcall(function()
                     local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                     if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Fly",icon="FLY",desc="Свободный полёт WASD + Space/Ctrl",state=false,conn=nil,_bv=nil,_bg=nil,_spd=60,
         param={label="Скорость полёта",min=10,max=500,step=5,val=60,
          fmt=function(v) return math.floor(v).." u/s" end,
          apply=function(v,it) if it then it._spd=v end end},
         enable=function(it)
             it._spd=it.param.val
             pcall(function()
                 local ch=LP.Character;if not ch then return end
                 local root=ch:FindFirstChild("HumanoidRootPart");if not root then return end
                 local hum=ch:FindFirstChildOfClass("Humanoid")
                 if hum then hum.PlatformStand=true end
                 local bv=Instance.new("BodyVelocity")
                 bv.Velocity=Vector3.new(0,0,0)
                 bv.MaxForce=Vector3.new(1e5,1e5,1e5)
                 bv.Parent=root;it._bv=bv
                 local bg=Instance.new("BodyGyro")
                 bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
                 bg.D=100;bg.Parent=root;it._bg=bg
                 it.conn=RS.RenderStepped:Connect(function()
                     pcall(function()
                         local cam=workspace.CurrentCamera
                         local lv=cam.CFrame.LookVector
                         local rv=cam.CFrame.RightVector
                         local d=Vector3.new(0,0,0)
                         if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+lv end
                         if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-lv end
                         if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-rv end
                         if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+rv end
                         if UIS:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end
                         if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d=d+Vector3.new(0,-1,0) end
                         if d.Magnitude>0 then d=d.Unit end
                         bv.Velocity=d*(it._spd or 60)
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

        {label="No Clip",icon="NCP",desc="Проходить сквозь стены",state=false,conn=nil,
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

        {label="Freeze",icon="FRZ",desc="Заморозить персонажа на месте",state=false,
         enable=function()
             pcall(function()
                 local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                 if hrp then hrp.Anchored=true end
             end)
         end,
         disable=function()
             pcall(function()
                 local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                 if hrp then hrp.Anchored=false end
             end)
         end},

        {label="Bunny Hop",icon="HOP",desc="Авто-прыжок при приземлении",state=false,conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                     if h and h:GetState()==Enum.HumanoidStateType.Landed then
                         h:ChangeState(Enum.HumanoidStateType.Jumping)
                     end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Teleport to Player",icon="TP",desc="Телепорт к ближайшему игроку",state=false,conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local char=LP.Character;if not char then return end
                     local hrp=char:FindFirstChild("HumanoidRootPart");if not hrp then return end
                     local nearest,dist=nil,math.huge
                     for _,pl in ipairs(Players:GetPlayers()) do
                         if pl~=LP and pl.Character then
                             local ohrp=pl.Character:FindFirstChild("HumanoidRootPart")
                             if ohrp then
                                 local d=(hrp.Position-ohrp.Position).Magnitude
                                 if d<dist then dist=d;nearest=ohrp end
                             end
                         end
                     end
                     if nearest then
                         hrp.CFrame=nearest.CFrame*CFrame.new(0,0,3.5)
                     end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Click Teleport",icon="CLK",desc="Телепорт по ПКМ в точку",state=false,conn=nil,
         enable=function(it)
             it.conn=UIS.InputBegan:Connect(function(inp,gpe)
                 if gpe then return end
                 if inp.UserInputType==Enum.UserInputType.MouseButton2 then
                     pcall(function()
                         local cam=workspace.CurrentCamera
                         local ray=cam:ScreenPointToRay(inp.Position.X,inp.Position.Y)
                         local result=workspace:Raycast(ray.Origin,ray.Direction*500)
                         if result then
                             local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                             if hrp then hrp.CFrame=CFrame.new(result.Position+Vector3.new(0,3,0)) end
                         end
                     end)
                 end
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Speed Dash",icon="DSH",desc="Рывок вперёд по клавише Q",state=false,conn=nil,_dashPow=150,
         param={label="Сила рывка",min=50,max=500,step=10,val=150,
          fmt=function(v) return math.floor(v).." u/s" end,
          apply=function(v,it) if it then it._dashPow=v end end},
         enable=function(it)
             it._dashPow=it.param.val
             it.conn=UIS.InputBegan:Connect(function(inp,gpe)
                 if gpe then return end
                 if inp.KeyCode==Enum.KeyCode.Q then
                     pcall(function()
                         local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                         if not hrp then return end
                         local bv=Instance.new("BodyVelocity")
                         bv.Velocity=hrp.CFrame.LookVector*(it._dashPow or 150)
                         bv.MaxForce=Vector3.new(1e6,0,1e6)
                         bv.Parent=hrp
                         game:GetService("Debris"):AddItem(bv,0.22)
                     end)
                 end
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Save Position",icon="PIN",desc="F5 сохранить, F6 вернуться",state=false,conn=nil,_pos=nil,
         enable=function(it)
             it.conn=UIS.InputBegan:Connect(function(inp,gpe)
                 if gpe then return end
                 if inp.KeyCode==Enum.KeyCode.F5 then
                     pcall(function()
                         local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                         if hrp then
                             it._pos=hrp.CFrame
                             Notify("Position","Позиция сохранена!",C.Green)
                         end
                     end)
                 elseif inp.KeyCode==Enum.KeyCode.F6 then
                     pcall(function()
                         if it._pos then
                             local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                             if hrp then
                                 hrp.CFrame=it._pos
                                 Notify("Position","Телепорт на позицию!",C.Acc)
                             end
                         end
                     end)
                 end
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},
    }},

    {title="ПЕРСОНАЖ", col=Color3.fromRGB(100,200,150), items={
        {label="God Mode",icon="GOD",desc="Бесконечное здоровье",state=false,conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                     if h then h.Health=h.MaxHealth end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Max Health",icon="HP",desc="Увеличить максимальное здоровье",state=false,
         param={label="Макс. здоровье",min=100,max=10000,step=100,val=1000,
          fmt=function(v) return math.floor(v).." HP" end,
          apply=function(v)
              pcall(function()
                  local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                  if h then h.MaxHealth=v;h.Health=v end
              end)
          end},
         enable=function(it)
             pcall(function()
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.MaxHealth=it.param.val;h.Health=it.param.val end
             end)
         end,
         disable=function()
             pcall(function()
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.MaxHealth=100;h.Health=100 end
             end)
         end},

        {label="Low Gravity",icon="GRV",desc="Изменить гравитацию",state=false,
         param={label="Гравитация",min=2,max=196,step=5,val=20,
          fmt=function(v) return math.floor(v).." g" end,
          apply=function(v) pcall(function() workspace.Gravity=v end) end},
         enable=function(it) pcall(function() workspace.Gravity=it.param.val end) end,
         disable=function() pcall(function() workspace.Gravity=196.2 end) end},

        {label="Invisible",icon="INV",desc="Скрыть персонажа",state=false,
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
                     if p:IsA("BasePart") then
                         p.Transparency=p.Name=="HumanoidRootPart" and 1 or 0
                     elseif p:IsA("Decal") then p.Transparency=0 end
                 end
             end)
         end},

        {label="Neon Body",icon="NEO",desc="Материал Neon для тела",state=false,_orig={},
         enable=function(it)
             pcall(function()
                 it._orig={}
                 for _,p in ipairs(LP.Character:GetDescendants()) do
                     if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                         it._orig[p]=p.Material;p.Material=Enum.Material.Neon
                     end
                 end
             end)
         end,
         disable=function(it)
             pcall(function()
                 for p,mat in pairs(it._orig or {}) do
                     pcall(function() if p and p.Parent then p.Material=mat end end)
                 end
                 it._orig={}
             end)
         end},

        {label="Rainbow Body",icon="RGB",desc="Персонаж переливается цветами",state=false,conn=nil,_hue=0,
         enable=function(it)
             it._hue=0
             it.conn=RS.RenderStepped:Connect(function(dt)
                 pcall(function()
                     it._hue=(it._hue+dt*0.35)%1
                     local col=Color3.fromHSV(it._hue,0.85,1)
                     for _,p in ipairs(LP.Character:GetDescendants()) do
                         if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                             p.Color=col
                         end
                     end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Spin",icon="SPN",desc="Вращение персонажа",state=false,conn=nil,_angle=0,
         param={label="Скорость вращения",min=1,max=60,step=1,val=10,
          fmt=function(v) return math.floor(v).."x" end,
          apply=function(v,it) if it then it._spd=v end end},
         _spd=10,
         enable=function(it)
             it._spd=it.param.val;it._angle=0
             it.conn=RS.RenderStepped:Connect(function(dt)
                 pcall(function()
                     local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                     if hrp then
                         it._angle=(it._angle or 0)+(it._spd or 10)*dt*5
                         local cf=hrp.CFrame
                         hrp.CFrame=CFrame.new(cf.Position)*CFrame.Angles(0,math.rad(it._angle),0)
                     end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Anti-AFK",icon="AFK",desc="Защита от кика за бездействие",state=false,conn=nil,
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

        {label="Auto Respawn",icon="RSP",desc="Авто-возрождение при смерти",state=false,conn=nil,
         enable=function(it)
             it.conn=LP.CharacterAdded:Connect(function(char)
                 local hum=char:WaitForChild("Humanoid",5)
                 if hum then
                     hum.Died:Connect(function()
                         task.wait(1)
                         pcall(function() LP:LoadCharacter() end)
                     end)
                 end
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},
    }},
}

-- ══════════════════════════════════════════════
-- VISUAL SECTIONS
-- ══════════════════════════════════════════════
local VISUAL_SECTIONS = {
    {title="ВИЗУАЛЬНЫЕ", col=Color3.fromRGB(80,160,240), items={
        {label="ESP Players",icon="ESP",desc="Видеть игроков сквозь стены",state=false,_esp={},conn=nil,
         enable=function(it)
             it._esp={}
             local function MakeTag(pl)
                 if pl==LP then return end
                 local function DoTag(char)
                     task.wait(0.5)
                     pcall(function()
                         local hrp=char:FindFirstChild("HumanoidRootPart");if not hrp then return end
                         local old2=hrp:FindFirstChild("_LHubESP")
                         if old2 then old2:Destroy() end
                         local bb=Instance.new("BillboardGui")
                         bb.Name="_LHubESP"
                         bb.Size=UDim2.new(0,100,0,44)
                         bb.AlwaysOnTop=true
                         bb.StudsOffset=Vector3.new(0,3.5,0)
                         bb.Parent=hrp
                         local nm=New("TextLabel",{
                             Size=UDim2.new(1,0,0,22),
                             Text=pl.Name,TextSize=12,Font=Enum.Font.GothamBold,
                             TextColor3=C.Red,BackgroundTransparency=1,
                             TextStrokeTransparency=0,
                             TextStrokeColor3=Color3.new(0,0,0)
                         },bb)
                         local hl=New("TextLabel",{
                             Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,22),
                             Text="[ESP]",TextSize=9,Font=Enum.Font.Gotham,
                             TextColor3=C.TxL,BackgroundTransparency=1
                         },bb)
                         it._esp[pl.UserId]=bb
                     end)
                 end
                 if pl.Character then DoTag(pl.Character) end
                 pl.CharacterAdded:Connect(DoTag)
             end
             for _,pl in ipairs(Players:GetPlayers()) do MakeTag(pl) end
             it.conn=Players.PlayerAdded:Connect(MakeTag)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             for _,bb in pairs(it._esp or {}) do pcall(function() bb:Destroy() end) end
             it._esp={}
             -- cleanup remaining
             for _,pl in ipairs(Players:GetPlayers()) do
                 if pl.Character then
                     local hrp=pl.Character:FindFirstChild("HumanoidRootPart")
                     if hrp then
                         local tag=hrp:FindFirstChild("_LHubESP")
                         if tag then tag:Destroy() end
                     end
                 end
             end
         end},

        {label="Fullbright",icon="FBR",desc="Максимальная яркость окружения",state=false,_orig=nil,
         enable=function(it)
             pcall(function()
                 local L=game:GetService("Lighting")
                 it._orig={Brightness=L.Brightness,Ambient=L.Ambient,OutdoorAmbient=L.OutdoorAmbient}
                 L.Brightness=2;L.Ambient=Color3.new(1,1,1);L.OutdoorAmbient=Color3.new(1,1,1)
             end)
         end,
         disable=function(it)
             pcall(function()
                 if it._orig then
                     local L=game:GetService("Lighting")
                     for k,v in pairs(it._orig) do L[k]=v end
                 end
             end)
         end},

        {label="Remove Fog",icon="FOG",desc="Убрать туман с карты",state=false,
         enable=function()
             pcall(function()
                 local L=game:GetService("Lighting")
                 L.FogStart=0;L.FogEnd=999999
             end)
         end,
         disable=function()
             pcall(function()
                 local L=game:GetService("Lighting")
                 L.FogEnd=100000
             end)
         end},

        {label="Night Vision",icon="NVS",desc="Яркость окружения ночью",state=false,
         enable=function()
             pcall(function()
                 local L=game:GetService("Lighting")
                 L.Brightness=4;L.Ambient=Color3.fromRGB(180,180,220)
             end)
         end,
         disable=function()
             pcall(function()
                 local L=game:GetService("Lighting")
                 L.Brightness=1;L.Ambient=Color3.fromRGB(70,70,70)
             end)
         end},

        {label="FOV Changer",icon="FOV",desc="Изменить поле зрения камеры",state=false,
         param={label="Field of View",min=30,max=130,step=5,val=90,
          fmt=function(v) return math.floor(v).."deg" end,
          apply=function(v) pcall(function() workspace.CurrentCamera.FieldOfView=v end) end},
         enable=function(it) pcall(function() workspace.CurrentCamera.FieldOfView=it.param.val end) end,
         disable=function() pcall(function() workspace.CurrentCamera.FieldOfView=70 end) end},

        {label="Zoom Unlock",icon="ZOM",desc="Снять ограничение зума (до 500)",state=false,
         enable=function()
             pcall(function()
                 LP.CameraMinZoomDistance=0
                 LP.CameraMaxZoomDistance=500
             end)
         end,
         disable=function()
             pcall(function()
                 LP.CameraMinZoomDistance=0.5
                 LP.CameraMaxZoomDistance=400
             end)
         end},

        {label="Time Changer",icon="TME",desc="Изменить время суток",state=false,
         param={label="Время (0 - 24)",min=0,max=24,step=0.5,val=12,
          fmt=function(v) return string.format("%.1fh",v) end,
          apply=function(v) pcall(function() game:GetService("Lighting").ClockTime=v end) end},
         enable=function(it) pcall(function() game:GetService("Lighting").ClockTime=it.param.val end) end,
         disable=function() pcall(function() game:GetService("Lighting").ClockTime=14 end) end},
    }},

    {title="ИНФОРМАЦИЯ", col=Color3.fromRGB(220,190,80), items={
        {label="FPS Counter",icon="FPS",desc="Счётчик FPS на экране",state=false,_gui=nil,conn=nil,
         enable=function(it)
             local fr=New("Frame",{
                 Size=UDim2.new(0,120,0,28),Position=UDim2.new(0,8,0,8),
                 BackgroundColor3=C.BG1,BorderSizePixel=0,ZIndex=150
             },Screen)
             Rnd(fr,8);Strk(fr,C.Bord,1)
             local lbl=New("TextLabel",{
                 Size=UDim2.new(1,0,1,0),Text="FPS: --",TextSize=11,
                 Font=Enum.Font.GothamBold,TextColor3=C.Acc,BackgroundTransparency=1,
                 TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151
             },fr)
             it._gui=fr
             local last=tick();local frames=0
             it.conn=RS.RenderStepped:Connect(function()
                 frames=frames+1
                 if tick()-last>=0.5 then
                     lbl.Text="FPS: "..math.floor(frames/(tick()-last))
                     frames=0;last=tick()
                 end
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             if it._gui then it._gui:Destroy();it._gui=nil end
         end},

        {label="Speed Meter",icon="SPM",desc="Текущая скорость персонажа",state=false,_gui=nil,conn=nil,
         enable=function(it)
             local fr=New("Frame",{
                 Size=UDim2.new(0,140,0,28),Position=UDim2.new(0,8,0,42),
                 BackgroundColor3=C.BG1,BorderSizePixel=0,ZIndex=150
             },Screen)
             Rnd(fr,8);Strk(fr,C.Bord,1)
             local lbl=New("TextLabel",{
                 Size=UDim2.new(1,0,1,0),Text="Speed: --",TextSize=11,
                 Font=Enum.Font.GothamBold,TextColor3=C.Blue,BackgroundTransparency=1,
                 TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151
             },fr)
             it._gui=fr
             local lastPos=nil
             it.conn=RS.Heartbeat:Connect(function(dt)
                 pcall(function()
                     local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                     if hrp then
                         if lastPos then
                             lbl.Text=string.format("Speed: %.1f",(hrp.Position-lastPos).Magnitude/dt)
                         end
                         lastPos=hrp.Position
                     end
                 end)
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             if it._gui then it._gui:Destroy();it._gui=nil end
         end},

        {label="Position HUD",icon="XYZ",desc="Показывать XYZ позицию",state=false,_gui=nil,conn=nil,
         enable=function(it)
             local fr=New("Frame",{
                 Size=UDim2.new(0,210,0,28),Position=UDim2.new(0,8,0,76),
                 BackgroundColor3=C.BG1,BorderSizePixel=0,ZIndex=150
             },Screen)
             Rnd(fr,8);Strk(fr,C.Bord,1)
             local lbl=New("TextLabel",{
                 Size=UDim2.new(1,0,1,0),Text="X:0 Y:0 Z:0",TextSize=10,
                 Font=Enum.Font.GothamMedium,TextColor3=C.Yel,BackgroundTransparency=1,
                 TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151
             },fr)
             it._gui=fr
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                     if hrp then
                         local p=hrp.Position
                         lbl.Text=string.format("X:%.0f Y:%.0f Z:%.0f",p.X,p.Y,p.Z)
                     end
                 end)
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             if it._gui then it._gui:Destroy();it._gui=nil end
         end},

        {label="Clock HUD",icon="CLK",desc="Реальное время на экране",state=false,_gui=nil,conn=nil,
         enable=function(it)
             local fr=New("Frame",{
                 Size=UDim2.new(0,120,0,28),Position=UDim2.new(0,8,0,110),
                 BackgroundColor3=C.BG1,BorderSizePixel=0,ZIndex=150
             },Screen)
             Rnd(fr,8);Strk(fr,C.Bord,1)
             local lbl=New("TextLabel",{
                 Size=UDim2.new(1,0,1,0),Text="--:--:--",TextSize=11,
                 Font=Enum.Font.GothamBold,TextColor3=C.Green,BackgroundTransparency=1,
                 TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151
             },fr)
             it._gui=fr
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local t=os.date("*t")
                     lbl.Text=string.format("%02d:%02d:%02d",t.hour,t.min,t.sec)
                 end)
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             if it._gui then it._gui:Destroy();it._gui=nil end
         end},

        {label="Crosshair",icon="AIM",desc="Прицел на экране",state=false,_gui=nil,
         enable=function(it)
             local fr=New("Frame",{
                 Size=UDim2.new(0,40,0,40),
                 Position=UDim2.new(0.5,-20,0.5,-20),
                 BackgroundTransparency=1,ZIndex=180
             },Screen)
             New("Frame",{
                 Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,0.5,-1),
                 BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=181
             },fr)
             New("Frame",{
                 Size=UDim2.new(0,2,1,0),Position=UDim2.new(0.5,-1,0,0),
                 BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=181
             },fr)
             it._gui=fr
         end,
         disable=function(it)
             if it._gui then it._gui:Destroy();it._gui=nil end
         end},
    }},
}

-- ══════════════════════════════════════════════
-- OTHER SECTIONS
-- ══════════════════════════════════════════════
local OTHER_SECTIONS = {
    {title="УТИЛИТЫ", col=Color3.fromRGB(200,140,80), items={
        {label="Copy Position",icon="CPY",desc="Скопировать позицию в Output",state=false,
         enable=function(it)
             it.state=false
             pcall(function()
                 local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                 if hrp then
                     local p=hrp.Position
                     local str=string.format("Vector3.new(%.2f, %.2f, %.2f)",p.X,p.Y,p.Z)
                     print("[LuxuryHub] "..str)
                     Notify("Copy Position",str,C.Acc)
                     SafeClipboard(str)
                 end
             end)
         end,
         disable=function() end},

        {label="Rejoin",icon="RJN",desc="Быстрый реджоин на тот же сервер",state=false,
         enable=function(it)
             it.state=false
             pcall(function()
                 game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
             end)
         end,
         disable=function() end},

        {label="Server Hop",icon="HOP",desc="Найти другой сервер и перейти",state=false,
         enable=function(it)
             it.state=false
             task.spawn(function()
                 pcall(function()
                     local TPS=game:GetService("TeleportService")
                     local Http=game:GetService("HttpService")
                     local pid=game.PlaceId
                     local ok,data=pcall(function()
                         return Http:JSONDecode(game:HttpGet(
                             "https://games.roblox.com/v1/games/"..pid..
                             "/servers/Public?sortOrder=Asc&limit=100"
                         ))
                     end)
                     if ok and data and data.data then
                         for _,s in ipairs(data.data) do
                             if s.id and s.id~=game.JobId and (s.playing or 0)<(s.maxPlayers or 1) then
                                 TPS:TeleportToPlaceInstance(pid,s.id,LP)
                                 return
                             end
                         end
                     end
                     Notify("Server Hop","Нет доступных серверов",C.Red)
                 end)
             end)
         end,
         disable=function() end},

        {label="Lag Switch",icon="LAG",desc="Заморозить HRP по клавише E",state=false,conn=nil,conn2=nil,
         enable=function(it)
             it.conn=UIS.InputBegan:Connect(function(inp,gpe)
                 if gpe then return end
                 if inp.KeyCode==Enum.KeyCode.E then
                     pcall(function()
                         local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                         if hrp then hrp.Anchored=true end
                     end)
                 end
             end)
             it.conn2=UIS.InputEnded:Connect(function(inp)
                 if inp.KeyCode==Enum.KeyCode.E then
                     pcall(function()
                         local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                         if hrp then hrp.Anchored=false end
                     end)
                 end
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             if it.conn2 then it.conn2:Disconnect();it.conn2=nil end
             pcall(function()
                 local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                 if hrp then hrp.Anchored=false end
             end)
         end},

        {label="Print Players",icon="LST",desc="Вывести список игроков в Output",state=false,
         enable=function(it)
             it.state=false
             local list=""
             for _,pl in ipairs(Players:GetPlayers()) do
                 list=list..pl.Name.." ("..pl.UserId..")\n"
             end
             print("[LuxuryHub] Players:\n"..list)
             Notify("Players","Список в Output ("..#Players:GetPlayers().." чел.)",C.Acc)
         end,
         disable=function() end},
    }},
}

-- ══════════════════════════════════════════════
-- ALL ITEMS FLAT
-- ══════════════════════════════════════════════
local ALL_ITEMS={}
for _,sec in ipairs(PLAYER_SECTIONS) do
    for _,it in ipairs(sec.items) do table.insert(ALL_ITEMS,it) end
end
for _,sec in ipairs(VISUAL_SECTIONS) do
    for _,it in ipairs(sec.items) do table.insert(ALL_ITEMS,it) end
end
for _,sec in ipairs(OTHER_SECTIONS) do
    for _,it in ipairs(sec.items) do table.insert(ALL_ITEMS,it) end
end

-- ══════════════════════════════════════════════
-- LAYOUT
-- ══════════════════════════════════════════════
local VP=workspace.CurrentCamera.ViewportSize
local PX=math.floor((VP.X-Settings.PW)/2)
local PY=math.floor((VP.Y-Settings.PH)/2)
local Open=true
local CurTab=1

local TAB_DATA={
    {name="Player",  short="PLR", col=Color3.fromRGB(130,100,240), sections=PLAYER_SECTIONS},
    {name="Visual",  short="VIS", col=Color3.fromRGB(80,160,240),  sections=VISUAL_SECTIONS},
    {name="Other",   short="OTH", col=Color3.fromRGB(200,140,80),  sections=OTHER_SECTIONS},
}

-- MINI BUTTON
local miniBtn=New("TextButton",{
    Size=UDim2.new(0,Settings.miniSize,0,Settings.miniSize),
    Position=UDim2.new(0,12,Settings.miniYPct,-Settings.miniSize/2),
    BackgroundColor3=C.BG2,BorderSizePixel=0,
    Text="LZ",TextSize=12,Font=Enum.Font.GothamBold,TextColor3=C.Acc,
    Visible=false,ZIndex=20,AutoButtonColor=false,
},Screen)
Rnd(miniBtn,10);Strk(miniBtn,C.AccL,1.5)

-- SIDEBAR
local sidebar=New("Frame",{
    Size=UDim2.new(0,68,0,10),
    Position=UDim2.new(0,PX-82,0,PY),
    BackgroundColor3=C.SB0,BorderSizePixel=0,
    AutomaticSize=Enum.AutomaticSize.Y,
},Screen)
Rnd(sidebar,18);Strk(sidebar,C.Bord,1.2)

local sideInner=New("Frame",{
    Size=UDim2.new(1,0,0,10),BackgroundTransparency=1,
    AutomaticSize=Enum.AutomaticSize.Y
},sidebar)
Pd(sideInner,10);Lst(sideInner,Enum.FillDirection.Vertical,8,Enum.HorizontalAlignment.Center)

New("TextLabel",{
    Size=UDim2.new(1,0,0,14),Text="MENU",TextSize=7,
    Font=Enum.Font.GothamBold,TextColor3=C.TxF,BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Center,LayoutOrder=0
},sideInner)

-- PANEL
local panel=New("Frame",{
    Size=UDim2.new(0,Settings.PW,0,Settings.PH),
    Position=UDim2.new(0,PX,0,PY),
    BackgroundColor3=C.BG1,BorderSizePixel=0,
},Screen)
Rnd(panel,20);Strk(panel,C.Bord,1.5)

local clip=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ClipsDescendants=true},panel)
Rnd(clip,20)

-- HEADER
local hdr=New("Frame",{
    Size=UDim2.new(1,0,0,64),BackgroundColor3=C.BG2,BorderSizePixel=0
},clip)
Rnd(hdr,20)
New("Frame",{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,1,-20),BackgroundColor3=C.BG2,BorderSizePixel=0},hdr)
New("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=C.Acc,BorderSizePixel=0},hdr)

-- Logo badge
local logoF=New("Frame",{
    Size=UDim2.new(0,40,0,40),Position=UDim2.new(0,14,0.5,-20),
    BackgroundColor3=C.AccG,BorderSizePixel=0
},hdr)
Rnd(logoF,10);Strk(logoF,C.AccL,1.5)
New("TextLabel",{
    Size=UDim2.new(1,0,1,0),Text="LZ",TextSize=14,Font=Enum.Font.GothamBold,
    TextColor3=C.Acc,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center
},logoF)

New("TextLabel",{
    Size=UDim2.new(0,220,0,22),Position=UDim2.new(0,62,0,8),
    Text="LUXURY HUB",TextSize=17,Font=Enum.Font.GothamBold,TextColor3=C.TxW,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left
},hdr)
New("TextLabel",{
    Size=UDim2.new(0,220,0,14),Position=UDim2.new(0,63,0,32),
    Text="v24 Player Edition",TextSize=9,Font=Enum.Font.Gotham,
    TextColor3=C.TxL,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left
},hdr)

local activeBadge=New("TextLabel",{
    Size=UDim2.new(0,78,0,22),Position=UDim2.new(1,-194,0.5,-11),
    BackgroundColor3=C.BG3,BorderSizePixel=0,
    Text="0 акт.",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.TxM,
    TextXAlignment=Enum.TextXAlignment.Center,
},hdr)
Rnd(activeBadge,8);Strk(activeBadge,C.Bord,1)

local function UpdateBadge()
    local cnt=0
    for _,it in ipairs(ALL_ITEMS) do if it.state then cnt=cnt+1 end end
    activeBadge.Text=cnt.." акт."
    activeBadge.TextColor3=cnt>0 and C.Green or C.TxM
    activeBadge.BackgroundColor3=cnt>0 and C.AccG or C.BG3
end

local function MkHBtn(xOff,txt,hc,cb)
    local b=New("TextButton",{
        Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,xOff,0.5,-14),
        BackgroundColor3=C.BG3,BorderSizePixel=0,Text=txt,TextSize=12,
        Font=Enum.Font.GothamBold,TextColor3=C.TxM,AutoButtonColor=false,ZIndex=10
    },hdr)
    Rnd(b,8);Strk(b,C.Bord,1)
    b.MouseEnter:Connect(function() Tw(b,{BackgroundColor3=hc},0.12) end)
    b.MouseLeave:Connect(function() Tw(b,{BackgroundColor3=C.BG3},0.12) end)
    b.MouseButton1Click:Connect(cb)
    return b
end

local function SyncSidebar()
    task.defer(function()
        local px=panel.AbsolutePosition.X
        local py=panel.AbsolutePosition.Y
        local ph=panel.AbsoluteSize.Y
        local sh=sidebar.AbsoluteSize.Y
        sidebar.Position=UDim2.new(0,px-82,0,py+math.floor((ph-sh)/2))
    end)
end

local function HideUI()
    Open=false
    Tw(panel,{Size=UDim2.new(0,Settings.PW,0,0)},Settings.animSpeed)
    task.delay(Settings.animSpeed+0.05,function()
        panel.Visible=false;sidebar.Visible=false;miniBtn.Visible=true
    end)
end
local function ShowUI()
    Open=true;miniBtn.Visible=false
    panel.Visible=true;sidebar.Visible=true
    panel.Size=UDim2.new(0,Settings.PW,0,0)
    Tw(panel,{Size=UDim2.new(0,Settings.PW,0,Settings.PH)},Settings.animSpeed)
    SyncSidebar()
end

MkHBtn(-10,"X",C.Red,HideUI)
MkHBtn(-46,"-",C.BG5,HideUI)

-- SCROLL
local scroll=New("ScrollingFrame",{
    Size=UDim2.new(1,0,1,-64-30),Position=UDim2.new(0,0,0,64),
    BackgroundTransparency=1,BorderSizePixel=0,
    ScrollBarThickness=3,ScrollBarImageColor3=C.AccG,
    CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ClipsDescendants=true,
},clip)
Pd(scroll,nil,8,8,12,12);Lst(scroll,Enum.FillDirection.Vertical,6)

-- FOOTER
local ftr=New("Frame",{
    Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,1,-30),
    BackgroundColor3=C.BG2,BorderSizePixel=0
},clip)
New("Frame",{
    Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,0),
    BackgroundColor3=C.Sep,BorderSizePixel=0
},ftr)
local fTabName=New("TextLabel",{
    Size=UDim2.new(0.4,0,1,0),Position=UDim2.new(0,14,0,0),
    Text="Player",TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.Acc,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left
},ftr)
New("TextLabel",{
    Size=UDim2.new(0.4,0,1,0),Position=UDim2.new(0.6,0,0,0),
    Text="RShift = скрыть",TextSize=9,Font=Enum.Font.Gotham,TextColor3=C.TxF,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right
},ftr)

-- ══════════════════════════════════════════════
-- NAV
-- ══════════════════════════════════════════════
local navBtns={}

local function RefreshContent()
    for _,c in ipairs(scroll:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
    local td=TAB_DATA[CurTab]
    fTabName.Text=td.name
    fTabName.TextColor3=td.col
    for _,sec in ipairs(td.sections) do
        SecLbl(scroll,sec.title,sec.col)
        for _,item in ipairs(sec.items) do
            MakeCard(scroll,item,sec.col)
        end
    end
end

local function BuildNav()
    for _,b in ipairs(navBtns) do b:Destroy() end
    navBtns={}
    for i,td in ipairs(TAB_DATA) do
        local act=(CurTab==i)
        local nb=New("TextButton",{
            Size=UDim2.new(0,48,0,52),
            BackgroundColor3=act and C.SB2 or C.SB0,
            BorderSizePixel=0,Text="",AutoButtonColor=false,LayoutOrder=i,
        },sideInner)
        Rnd(nb,14)
        if act then Strk(nb,td.col,1.5) end

        -- icon box
        local iconBox=New("Frame",{
            Size=UDim2.new(0,30,0,30),
            Position=UDim2.new(0.5,-15,0,6),
            BackgroundColor3=act and Color3.fromRGB(
                math.floor(td.col.R*40),
                math.floor(td.col.G*40),
                math.floor(td.col.B*40)
            ) or C.BG3,
            BorderSizePixel=0
        },nb)
        Rnd(iconBox,8)
        New("TextLabel",{
            Size=UDim2.new(1,0,1,0),
            Text=td.short,TextSize=9,Font=Enum.Font.GothamBold,
            TextColor3=act and td.col or C.TxL,
            BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center
        },iconBox)

        New("TextLabel",{
            Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-14),
            Text=td.name,TextSize=7,Font=Enum.Font.GothamBold,
            TextColor3=act and td.col or C.TxF,
            BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center
        },nb)

        nb.MouseEnter:Connect(function()
            if not act then Tw(nb,{BackgroundColor3=C.SB1},0.12) end
        end)
        nb.MouseLeave:Connect(function()
            if not act then Tw(nb,{BackgroundColor3=C.SB0},0.12) end
        end)
        nb.MouseButton1Click:Connect(function()
            CurTab=i;BuildNav();RefreshContent();SyncSidebar()
        end)
        table.insert(navBtns,nb)
    end
end

-- ══════════════════════════════════════════════
-- DRAG
-- ══════════════════════════════════════════════
local drag=false;local dragS;local dragP
hdr.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=true;dragS=i.Position;dragP=panel.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-dragS
        panel.Position=UDim2.new(dragP.X.Scale,dragP.X.Offset+d.X,dragP.Y.Scale,dragP.Y.Offset+d.Y)
        SyncSidebar()
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
end)

-- ══════════════════════════════════════════════
-- HOTKEY
-- ══════════════════════════════════════════════
miniBtn.MouseButton1Click:Connect(ShowUI)
UIS.InputBegan:Connect(function(i,gpe)
    if gpe then return end
    if i.KeyCode==Enum.KeyCode.RightShift then
        if Open then HideUI() else ShowUI() end
    end
end)

-- ══════════════════════════════════════════════
-- BADGE POLL
-- ══════════════════════════════════════════════
task.spawn(function()
    while panel and panel.Parent do
        task.wait(1);pcall(UpdateBadge)
    end
end)

-- ══════════════════════════════════════════════
-- RESPAWN
-- ══════════════════════════════════════════════
LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    for _,it in ipairs(ALL_ITEMS) do
        if it.state then pcall(it.enable,it) end
    end
end)

-- ══════════════════════════════════════════════
-- INIT
-- ══════════════════════════════════════════════
BuildNav()
RefreshContent()
SyncSidebar()
UpdateBadge()

Notify("LUXURY HUB v24","Загружен! "..#ALL_ITEMS.." функций",C.Acc)
print("LUXURY HUB v24 - OK | "..#ALL_ITEMS.." items")