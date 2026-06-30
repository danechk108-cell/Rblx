-- LUXURY HUB v24 - Player Edition
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

-- ══════════════════════════════════════════════
-- COLORS (Dark Gray Theme)
-- ══════════════════════════════════════════════
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
    AccG  = Color3.fromRGB(50,35,110),
    TxW  = Color3.fromRGB(235,235,230),
    TxH  = Color3.fromRGB(185,185,178),
    TxM  = Color3.fromRGB(130,132,126),
    TxL  = Color3.fromRGB(85,87,82),
    TxF  = Color3.fromRGB(55,57,52),
    Bord = Color3.fromRGB(55,57,65),
    BordA= Color3.fromRGB(100,75,200),
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

-- ══════════════════════════════════════════════
-- UTILS
-- ══════════════════════════════════════════════
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
local function Rnd(inst,r) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 12);c.Parent=inst;return c end
local function Strk(inst,col,th)
    local s=Instance.new("UIStroke");s.Color=col or C.Bord;s.Thickness=th or 1.2
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;s.Parent=inst;return s
end
local function Pd(inst,a,t,b,l,r)
    local p=Instance.new("UIPadding")
    if a then p.PaddingTop=UDim.new(0,a);p.PaddingBottom=UDim.new(0,a);p.PaddingLeft=UDim.new(0,a);p.PaddingRight=UDim.new(0,a)
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

-- Notify
local notifStack={}
local function Notify(title,msg,col)
    local n=New("Frame",{
        Size=UDim2.new(0,300,0,68),
        Position=UDim2.new(1,10,1,-90),
        BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=200
    },Screen)
    Rnd(n,14);Strk(n,col or C.Acc,1.5)
    New("Frame",{Size=UDim2.new(0,4,1,0),BackgroundColor3=col or C.Acc,BorderSizePixel=0,ZIndex=201},n)
    Rnd(n:FindFirstChildOfClass("Frame"),2)
    New("TextLabel",{Size=UDim2.new(1,-18,0,24),Position=UDim2.new(0,14,0,6),
        Text=title,TextSize=13,Font=Enum.Font.GothamBold,
        TextColor3=col or C.Acc,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},n)
    New("TextLabel",{Size=UDim2.new(1,-18,0,18),Position=UDim2.new(0,14,0,32),
        Text=msg,TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},n)

    table.insert(notifStack,n)
    local idx=#notifStack
    local baseY=-90
    for i,nn in ipairs(notifStack) do
        local ty=baseY-(#notifStack-i)*74
        Tw(nn,{Position=UDim2.new(1,-312,1,ty)},0.3)
    end

    task.delay(3.8,function()
        Tw(n,{Position=UDim2.new(1,20,1,baseY)},0.28)
        task.delay(0.32,function()
            pcall(function()
                for i,nn in ipairs(notifStack) do if nn==n then table.remove(notifStack,i) break end end
                n:Destroy()
            end)
        end)
    end)
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
    New("TextLabel",{Size=UDim2.new(1,-70,1,0),Text=opts.label or "",TextSize=10,
        Font=Enum.Font.GothamMedium,TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left},row)
    local valLbl=New("TextLabel",{Size=UDim2.new(0,68,1,0),Position=UDim2.new(1,-68,0,0),
        Text=fmt(val),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.Acc,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right},row)

    local trackBg=New("Frame",{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,26),
        BackgroundColor3=C.SlT,BorderSizePixel=0},cont)
    Rnd(trackBg,5);Strk(trackBg,C.Bord,0.8)

    local fill=New("Frame",{
        Size=UDim2.new(math.max(0,math.min(1,(val-mn)/(mx-mn))),0,1,0),
        BackgroundColor3=C.Acc,BorderSizePixel=0},trackBg)
    Rnd(fill,5)

    local knob=New("Frame",{Size=UDim2.new(0,22,0,22),
        Position=UDim2.new(0,-11,0.5,-11),
        BackgroundColor3=C.Acc,BorderSizePixel=0,ZIndex=6},fill)
    Rnd(knob,11);Strk(knob,C.AccG,1.5)
    New("Frame",{Size=UDim2.new(0,10,0,10),Position=UDim2.new(0.5,-5,0.5,-5),
        BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=7},knob)
    Rnd(knob:FindFirstChildOfClass("Frame"),5)

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
            local p2=math.max(0,math.min(1,(val-mn)/(mx-mn)))
            fill.Size=UDim2.new(p2,0,1,0)
            valLbl.Text=fmt(val)
            if opts.onChange then opts.onChange(val) end
        end
    end
    local hit=New("TextButton",{Size=UDim2.new(1,0,0,36),Position=UDim2.new(0,0,0,18),
        BackgroundTransparency=1,Text="",ZIndex=9},cont)
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
    local W,H=54,28
    local cont=New("Frame",{Size=UDim2.new(0,W,0,H),BackgroundTransparency=1},parent)
    local track=New("Frame",{Size=UDim2.new(1,0,1,0),
        BackgroundColor3=init and C.Acc or C.BG0,BorderSizePixel=0},cont)
    Rnd(track,H/2);Strk(track,init and C.AccL or C.Bord,1)
    local kn=New("Frame",{
        Size=UDim2.new(0,H-6,0,H-6),
        Position=init and UDim2.new(1,-(H-3),0.5,-(H-6)/2) or UDim2.new(0,3,0.5,-(H-6)/2),
        BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=3},track)
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
        if track:FindFirstChildOfClass("UIStroke") then
            track:FindFirstChildOfClass("UIStroke").Color=on and C.AccL or C.Bord
        end
    end
    local btn=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=10},cont)
    btn.MouseButton1Click:Connect(function() Set(not on,true);if onChange then onChange(on) end end)
    return cont,{Set=Set,Get=function() return on end}
end

-- ══════════════════════════════════════════════
-- SECTION LABEL
-- ══════════════════════════════════════════════
local function SecLbl(parent,txt,icon)
    local f=New("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1},parent)
    local row=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},f)
    Lst(row,Enum.FillDirection.Horizontal,6,Enum.HorizontalAlignment.Left)
    if icon then
        New("TextLabel",{Size=UDim2.new(0,16,1,0),Text=icon,TextSize=12,
            Font=Enum.Font.GothamBold,TextColor3=C.Acc,BackgroundTransparency=1,
            TextXAlignment=Enum.TextXAlignment.Left},row)
    end
    New("TextLabel",{Size=UDim2.new(0,200,1,0),Text=txt,TextSize=9,
        Font=Enum.Font.GothamBold,TextColor3=C.TxL,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left},row)
    New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=C.Sep,BorderSizePixel=0},f)
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

    -- shadow effect
    local shadow=New("Frame",{
        Size=UDim2.new(1,6,1,6),
        Position=UDim2.new(0,-3,0,3),
        BackgroundColor3=Color3.fromRGB(15,15,18),
        BackgroundTransparency=0.6,
        BorderSizePixel=0,ZIndex=0
    },wrap)
    Rnd(shadow,18)

    local card=New("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=item.state and C.BG4 or C.BG2,
        BorderSizePixel=0,ClipsDescendants=true,ZIndex=1
    },wrap)
    Rnd(card,16)
    local strk=Strk(card,item.state and tc or C.Bord,1.2)

    -- left accent bar
    local bar=New("Frame",{
        Size=UDim2.new(0,4,0,32),
        Position=UDim2.new(0,0,0.5,-16),
        BackgroundColor3=tc,BorderSizePixel=0,
        Visible=item.state,ZIndex=2
    },card)
    Rnd(bar,2)

    -- icon circle
    local iconCircle=New("Frame",{
        Size=UDim2.new(0,34,0,34),
        Position=UDim2.new(0,14,0.5,-17),
        BackgroundColor3=item.state and C.AccG or C.BG3,
        BorderSizePixel=0,ZIndex=2
    },card)
    Rnd(iconCircle,17)
    if item.state then Strk(iconCircle,C.AccL,1) end
    New("TextLabel",{Size=UDim2.new(1,0,1,0),
        Text=item.icon or "◆",TextSize=14,Font=Enum.Font.GothamBold,
        TextColor3=item.state and tc or C.TxL,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=3
    },iconCircle)

    local lbl=New("TextLabel",{
        Size=UDim2.new(1,-118,0,22),Position=UDim2.new(0,58,0,10),
        Text=item.label,TextSize=14,Font=Enum.Font.GothamBold,
        TextColor3=item.state and C.TxW or C.TxH,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2
    },card)

    local dsc=New("TextLabel",{
        Size=UDim2.new(1,-118,0,16),Position=UDim2.new(0,58,0,34),
        Text=item.desc,TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=item.state and C.TxM or C.TxL,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2
    },card)

    -- status pill
    local pill=New("TextLabel",{
        Size=UDim2.new(0,0,0,18),
        Position=UDim2.new(0,58,0,34),
        AutomaticSize=Enum.AutomaticSize.X,
        BackgroundColor3=item.state and C.AccG or C.BG3,
        Text=item.state and "  ВКЛ  " or "  ВЫКЛ  ",
        TextSize=8,Font=Enum.Font.GothamBold,
        TextColor3=item.state and tc or C.TxL,
        BorderSizePixel=0,Visible=false,ZIndex=3
    },card)
    Rnd(pill,9)

    -- param panel
    local paramPanel=nil
    if item.param then
        paramPanel=New("Frame",{
            Size=UDim2.new(1,-8,0,0),
            Position=UDim2.new(0,4,1,4),
            BackgroundColor3=C.BG1,
            BorderSizePixel=0,ClipsDescendants=true,Visible=false
        },wrap)
        Rnd(paramPanel,14);Strk(paramPanel,tc,1)
        local inner=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},paramPanel)
        Pd(inner,nil,10,8,14,14)
        local pp=item.param
        MakeSlider(inner,{
            label=pp.label,min=pp.min,max=pp.max,step=pp.step,val=pp.val,fmt=pp.fmt,
            onChange=function(v) pp.val=v;if pp.apply then pp.apply(v,item) end end,
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
            Tw(iconCircle,{BackgroundColor3=s and C.AccG or C.BG3},dur)
        else
            iconCircle.BackgroundColor3=s and C.AccG or C.BG3
        end
        local ic=iconCircle:FindFirstChildOfClass("TextLabel")
        if ic then ic.TextColor3=s and tc or C.TxL end

        if paramPanel then
            if s then
                paramPanel.Visible=true
                Tw(paramPanel,{Size=UDim2.new(1,-8,0,76)},0.22)
                Tw(wrap,{Size=UDim2.new(1,0,0,expandH)},0.22)
            else
                Tw(paramPanel,{Size=UDim2.new(1,-8,0,0)},0.18)
                Tw(wrap,{Size=UDim2.new(1,0,0,baseH)},0.18)
                task.delay(0.2,function()
                    if not item.state and paramPanel and paramPanel.Parent then
                        paramPanel.Visible=false
                    end
                end)
            end
        end
    end

    local tgC,tgCtrl=MakeToggle(card,item.state,nil)
    tgC.Position=UDim2.new(1,-70,0.5,-14);tgC.ZIndex=5

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

    local hit=New("TextButton",{Size=UDim2.new(1,0,0,baseH),BackgroundTransparency=1,Text="",ZIndex=8},card)
    hit.MouseButton1Click:Connect(DoToggle)

    card.MouseEnter:Connect(function()
        if not item.state then
            Tw(card,{BackgroundColor3=C.BG3},0.12)
            strk.Color=C.BordH
        end
    end)
    card.MouseLeave:Connect(function()
        if not item.state then
            Tw(card,{BackgroundColor3=C.BG2},0.12)
            strk.Color=C.Bord
        end
    end)

    if item.state then ApplyState(true,false) end
    return wrap
end

-- ══════════════════════════════════════════════
-- PLAYER ITEMS
-- ══════════════════════════════════════════════
local PLAYER_SECTIONS = {
    {
        title="ДВИЖЕНИЕ", icon="🏃",
        items={
            {label="Speed Boost",icon="⚡",desc="Ускорение ходьбы",state=false,
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

            {label="High Jump",icon="🦘",desc="Высокий прыжок",state=false,
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

            {label="Infinite Jump",icon="🔁",desc="Прыгай бесконечно в воздухе",state=false,conn=nil,
             enable=function(it)
                 it.conn=UIS.JumpRequest:Connect(function()
                     pcall(function()
                         local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                         if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                     end)
                 end)
             end,
             disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

            {label="Fly",icon="🛸",desc="Свободный полёт WASD + Space/Ctrl",state=false,conn=nil,_bv=nil,_bg=nil,_spd=60,
             param={label="Скорость полёта",min=10,max=500,step=5,val=60,
              fmt=function(v) return math.floor(v).." u/s" end,
              apply=function(v,it) if it then it._spd=v end end},
             enable=function(it)
                 it._spd=it.param.val
                 pcall(function()
                     local ch=LP.Character;if not ch then return end
                     local root=ch:FindFirstChild("HumanoidRootPart");if not root then return end
                     local hum=ch:FindFirstChildOfClass("Humanoid");if hum then hum.PlatformStand=true end
                     local bv=Instance.new("BodyVelocity");bv.Velocity=Vector3.new(0,0,0)
                     bv.MaxForce=Vector3.new(1e5,1e5,1e5);bv.Parent=root;it._bv=bv
                     local bg=Instance.new("BodyGyro");bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
                     bg.D=100;bg.Parent=root;it._bg=bg
                     it.conn=RS.RenderStepped:Connect(function()
                         pcall(function()
                             local cam=workspace.CurrentCamera
                             local lv=cam.CFrame.LookVector;local rv=cam.CFrame.RightVector
                             local d=Vector3.new(0,0,0)
                             if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+lv end
                             if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-lv end
                             if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-rv end
                             if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+rv end
                             if UIS:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end
                             if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d=d+Vector3.new(0,-1,0) end
                             if d.Magnitude>0 then d=d.Unit end
                             bv.Velocity=d*(it._spd or 60);bg.CFrame=cam.CFrame
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

            {label="No Clip",icon="👻",desc="Проходить сквозь стены",state=false,conn=nil,
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

            {label="Freeze",icon="🧊",desc="Заморозить персонажа на месте",state=false,
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

            {label="Bunny Hop",icon="🐰",desc="Авто-прыжок при приземлении",state=false,conn=nil,
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

            {label="Teleport to Player",icon="🎯",desc="Телепорт к ближайшему игроку",state=false,conn=nil,
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

            {label="ClickTP",icon="🖱️",desc="Телепорт по ПКМ в точку",state=false,conn=nil,
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

            {label="Speed Glitch",icon="💨",desc="Рывок-спринт по нажатию Q",state=false,conn=nil,
             param={label="Сила рывка",min=50,max=500,step=10,val=150,
              fmt=function(v) return math.floor(v).." u/s" end,
              apply=function(v,it) it._dashPow=v end},
             _dashPow=150,
             enable=function(it)
                 it._dashPow=it.param.val
                 it.conn=UIS.InputBegan:Connect(function(inp,gpe)
                     if gpe then return end
                     if inp.KeyCode==Enum.KeyCode.Q then
                         pcall(function()
                             local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                             if not hrp then return end
                             local bv=Instance.new("BodyVelocity")
                             bv.Velocity=hrp.CFrame.LookVector*it._dashPow
                             bv.MaxForce=Vector3.new(1e6,0,1e6)
                             bv.Parent=hrp
                             game:GetService("Debris"):AddItem(bv,0.22)
                         end)
                     end
                 end)
             end,
             disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

            {label="Save / Load Position",icon="📍",desc="F5 сохранить, F6 вернуться",state=false,conn=nil,_pos=nil,
             enable=function(it)
                 it.conn=UIS.InputBegan:Connect(function(inp,gpe)
                     if gpe then return end
                     if inp.KeyCode==Enum.KeyCode.F5 then
                         pcall(function()
                             local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                             if hrp then it._pos=hrp.CFrame;Notify("Position","Позиция сохранена!",C.Green) end
                         end)
                     elseif inp.KeyCode==Enum.KeyCode.F6 then
                         pcall(function()
                             if it._pos then
                                 local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                                 if hrp then hrp.CFrame=it._pos;Notify("Position","Телепорт на позицию!",C.Acc) end
                             end
                         end)
                     end
                 end)
             end,
             disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},
        }
    },
    {
        title="ПЕРСОНАЖ", icon="👤",
        items={
            {label="God Mode",icon="🛡️",desc="Бесконечное здоровье",state=false,conn=nil,
             enable=function(it)
                 it.conn=RS.Heartbeat:Connect(function()
                     pcall(function()
                         local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                         if h then h.Health=h.MaxHealth end
                     end)
                 end)
             end,
             disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

            {label="Max Health Boost",icon="❤️",desc="Увеличить максимальное здоровье",state=false,
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

            {label="Low Gravity",icon="🌙",desc="Изменить гравитацию",state=false,
             param={label="Гравитация",min=2,max=196,step=5,val=20,
              fmt=function(v) return math.floor(v).." g" end,
              apply=function(v) pcall(function() workspace.Gravity=v end) end},
             enable=function(it) pcall(function() workspace.Gravity=it.param.val end) end,
             disable=function() pcall(function() workspace.Gravity=196.2 end) end},

            {label="Invisible",icon="👁️",desc="Скрыть персонажа",state=false,
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

            {label="Neon Character",icon="✨",desc="Материал Neon для персонажа",state=false,_origMats={},
             enable=function(it)
                 pcall(function()
                     it._origMats={}
                     for _,p in ipairs(LP.Character:GetDescendants()) do
                         if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                             it._origMats[p]=p.Material;p.Material=Enum.Material.Neon
                         end
                     end
                 end)
             end,
             disable=function(it)
                 pcall(function()
                     for p,mat in pairs(it._origMats or {}) do
                         pcall(function() if p and p.Parent then p.Material=mat end end)
                     end
                     it._origMats={}
                 end)
             end},

            {label="Rainbow Character",icon="🌈",desc="Персонаж переливается цветами",state=false,conn=nil,_hue=0,
             enable=function(it)
                 it._hue=0
                 it.conn=RS.RenderStepped:Connect(function(dt)
                     pcall(function()
                         it._hue=(it._hue+dt*0.4)%1
                         local col=Color3.fromHSV(it._hue,0.8,1)
                         for _,p in ipairs(LP.Character:GetDescendants()) do
                             if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                                 p.Color=col
                             end
                         end
                     end)
                 end)
             end,
             disable=function(it)
                 if it.conn then it.conn:Disconnect();it.conn=nil end
             end},

            {label="Spin",icon="🌀",desc="Вращение персонажа (настраивается)",state=false,conn=nil,_angle=0,
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

            {label="Anti-AFK",icon="⏰",desc="Защита от кика за бездействие",state=false,conn=nil,
             enable=function(it)
                 it.conn=LP.Idled:Connect(function()
                     pcall(function()
                         local vu=game:GetService("VirtualUser")
                         vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                         task.wait();vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                     end)
                 end)
             end,
             disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

            {label="Auto Respawn",icon="🔄",desc="Авто-возрождение при смерти",state=false,conn=nil,
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
        }
    },
}

-- ══════════════════════════════════════════════
-- VISUAL ITEMS
-- ══════════════════════════════════════════════
local VISUAL_SECTIONS = {
    {
        title="ВИЗУАЛЬНЫЕ", icon="👁️",
        items={
            {label="ESP Players",icon="🔴",desc="Видеть игроков сквозь стены",state=false,conn=nil,_esp={},
             enable=function(it)
                 local function AddESP(pl)
                     if pl==LP then return end
                     it.conn2=pl.CharacterAdded:Connect(function(char)
                         task.wait(0.5)
                         pcall(function()
                             local hrp=char:FindFirstChild("HumanoidRootPart");if not hrp then return end
                             local bb=Instance.new("BillboardGui")
                             bb.Size=UDim2.new(0,80,0,40);bb.AlwaysOnTop=true
                             bb.StudsOffset=Vector3.new(0,3,0);bb.Parent=hrp
                             New("TextLabel",{Size=UDim2.new(1,0,1,0),
                                 Text=pl.Name,TextSize=12,Font=Enum.Font.GothamBold,
                                 TextColor3=C.Red,BackgroundTransparency=1,
                                 TextStrokeTransparency=0,TextStrokeColor3=Color3.new(0,0,0)},bb)
                             it._esp[pl.Name]=bb
                         end)
                     end)
                     if pl.Character then
                         local hrp=pl.Character:FindFirstChild("HumanoidRootPart")
                         if hrp then
                             local bb=Instance.new("BillboardGui")
                             bb.Size=UDim2.new(0,80,0,40);bb.AlwaysOnTop=true
                             bb.StudsOffset=Vector3.new(0,3,0);bb.Parent=hrp
                             New("TextLabel",{Size=UDim2.new(1,0,1,0),
                                 Text=pl.Name,TextSize=12,Font=Enum.Font.GothamBold,
                                 TextColor3=C.Red,BackgroundTransparency=1,
                                 TextStrokeTransparency=0,TextStrokeColor3=Color3.new(0,0,0)},bb)
                             it._esp[pl.Name]=bb
                         end
                     end
                 end
                 for _,pl in ipairs(Players:GetPlayers()) do AddESP(pl) end
                 it.conn=Players.PlayerAdded:Connect(AddESP)
             end,
             disable=function(it)
                 if it.conn then it.conn:Disconnect();it.conn=nil end
                 if it.conn2 then it.conn2:Disconnect();it.conn2=nil end
                 for _,bb in pairs(it._esp or {}) do pcall(function() bb:Destroy() end) end
                 it._esp={}
             end},

            {label="Fullbright",icon="☀️",desc="Убрать тени, максимальная яркость",state=false,_origLight=nil,
             enable=function(it)
                 pcall(function()
                     local lighting=game:GetService("Lighting")
                     it._origLight={
                         Brightness=lighting.Brightness,
                         Ambient=lighting.Ambient,
                         OutdoorAmbient=lighting.OutdoorAmbient,
                         FogEnd=lighting.FogEnd,
                     }
                     lighting.Brightness=2
                     lighting.Ambient=Color3.new(1,1,1)
                     lighting.OutdoorAmbient=Color3.new(1,1,1)
                     lighting.FogEnd=100000
                 end)
             end,
             disable=function(it)
                 pcall(function()
                     if it._origLight then
                         local lighting=game:GetService("Lighting")
                         for k,v in pairs(it._origLight) do lighting[k]=v end
                     end
                 end)
             end},

            {label="Remove Fog",icon="🌫️",desc="Убрать туман с карты",state=false,
             enable=function()
                 pcall(function()
                     local l=game:GetService("Lighting")
                     l.FogStart=0;l.FogEnd=100000
                 end)
             end,
             disable=function()
                 pcall(function()
                     local l=game:GetService("Lighting")
                     l.FogStart=0;l.FogEnd=100000
                 end)
             end},

            {label="Night Vision",icon="🌑",desc="Яркость окружения ночью",state=false,
             enable=function()
                 pcall(function()
                     local l=game:GetService("Lighting")
                     l.Brightness=4;l.Ambient=Color3.fromRGB(180,180,220)
                 end)
             end,
             disable=function()
                 pcall(function()
                     local l=game:GetService("Lighting")
                     l.Brightness=1;l.Ambient=Color3.fromRGB(70,70,70)
                 end)
             end},

            {label="FOV Changer",icon="📷",desc="Изменить поле зрения камеры",state=false,
             param={label="FOV",min=30,max=130,step=5,val=90,
              fmt=function(v) return math.floor(v).."°" end,
              apply=function(v) pcall(function() workspace.CurrentCamera.FieldOfView=v end) end},
             enable=function(it) pcall(function() workspace.CurrentCamera.FieldOfView=it.param.val end) end,
             disable=function() pcall(function() workspace.CurrentCamera.FieldOfView=70 end) end},

            {label="Zoom Unlock",icon="🔭",desc="Снять ограничение зума (до 500)",state=false,
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

            {label="Third Person Lock",icon="🎬",desc="Зафиксировать камеру третьего лица",state=false,conn=nil,
             enable=function(it)
                 it.conn=RS.RenderStepped:Connect(function()
                     pcall(function()
                         local cam=workspace.CurrentCamera
                         local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                         if hrp then
                             cam.CameraType=Enum.CameraType.Attach
                         end
                     end)
                 end)
             end,
             disable=function(it)
                 if it.conn then it.conn:Disconnect();it.conn=nil end
                 pcall(function() workspace.CurrentCamera.CameraType=Enum.CameraType.Custom end)
             end},

            {label="Time Changer",icon="🕐",desc="Изменить время суток",state=false,
             param={label="Время (0–24)",min=0,max=24,step=0.5,val=12,
              fmt=function(v) return string.format("%.1fh",v) end,
              apply=function(v)
                  pcall(function() game:GetService("Lighting").ClockTime=v end)
              end},
             enable=function(it)
                 pcall(function() game:GetService("Lighting").ClockTime=it.param.val end)
             end,
             disable=function()
                 pcall(function() game:GetService("Lighting").ClockTime=14 end)
             end},
        }
    },
    {
        title="ИНФОРМАЦИЯ НА ЭКРАНЕ", icon="📊",
        items={
            {label="FPS Counter",icon="📈",desc="Счётчик FPS в углу экрана",state=false,_gui=nil,conn=nil,
             enable=function(it)
                 local fr=New("Frame",{Size=UDim2.new(0,110,0,28),Position=UDim2.new(0,8,0,8),
                     BackgroundColor3=C.BG1,BorderSizePixel=0,ZIndex=150},Screen)
                 Rnd(fr,10);Strk(fr,C.Bord,1)
                 local lbl=New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="FPS: --",TextSize=11,
                     Font=Enum.Font.GothamBold,TextColor3=C.Acc,BackgroundTransparency=1,
                     TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151},fr)
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

            {label="Speed Meter",icon="🚀",desc="Текущая скорость персонажа",state=false,_gui=nil,conn=nil,
             enable=function(it)
                 local fr=New("Frame",{Size=UDim2.new(0,130,0,28),Position=UDim2.new(0,8,0,42),
                     BackgroundColor3=C.BG1,BorderSizePixel=0,ZIndex=150},Screen)
                 Rnd(fr,10);Strk(fr,C.Bord,1)
                 local lbl=New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="Speed: --",TextSize=11,
                     Font=Enum.Font.GothamBold,TextColor3=C.Blue,BackgroundTransparency=1,
                     TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151},fr)
                 it._gui=fr
                 local lastPos=nil
                 it.conn=RS.Heartbeat:Connect(function(dt)
                     pcall(function()
                         local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                         if hrp then
                             if lastPos then
                                 local spd=(hrp.Position-lastPos).Magnitude/dt
                                 lbl.Text=string.format("Speed: %.1f",spd)
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

            {label="Position HUD",icon="📌",desc="Показывать XYZ позицию",state=false,_gui=nil,conn=nil,
             enable=function(it)
                 local fr=New("Frame",{Size=UDim2.new(0,200,0,28),Position=UDim2.new(0,8,0,76),
                     BackgroundColor3=C.BG1,BorderSizePixel=0,ZIndex=150},Screen)
                 Rnd(fr,10);Strk(fr,C.Bord,1)
                 local lbl=New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="X:0 Y:0 Z:0",TextSize=10,
                     Font=Enum.Font.GothamMedium,TextColor3=C.Yel,BackgroundTransparency=1,
                     TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151},fr)
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

            {label="Clock HUD",icon="🕰️",desc="Реальное время на экране",state=false,_gui=nil,conn=nil,
             enable=function(it)
                 local fr=New("Frame",{Size=UDim2.new(0,110,0,28),Position=UDim2.new(0,8,0,110),
                     BackgroundColor3=C.BG1,BorderSizePixel=0,ZIndex=150},Screen)
                 Rnd(fr,10);Strk(fr,C.Bord,1)
                 local lbl=New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="--:--:--",TextSize=11,
                     Font=Enum.Font.GothamBold,TextColor3=C.Green,BackgroundTransparency=1,
                     TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151},fr)
                 it._gui=fr
                 it.conn=RS.Heartbeat:Connect(function()
                     local t=os.date("*t")
                     lbl.Text=string.format("%02d:%02d:%02d",t.hour,t.min,t.sec)
                 end)
             end,
             disable=function(it)
                 if it.conn then it.conn:Disconnect();it.conn=nil end
                 if it._gui then it._gui:Destroy();it._gui=nil end
             end},

            {label="Crosshair",icon="➕",desc="Кастомный прицел на экране",state=false,_gui=nil,
             enable=function(it)
                 local fr=New("Frame",{Size=UDim2.new(0,40,0,40),
                     Position=UDim2.new(0.5,-20,0.5,-20),
                     BackgroundTransparency=1,ZIndex=180},Screen)
                 New("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,0.5,-1),
                     BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=181},fr)
                 New("Frame",{Size=UDim2.new(0,2,1,0),Position=UDim2.new(0.5,-1,0,0),
                     BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=181},fr)
                 it._gui=fr
             end,
             disable=function(it)
                 if it._gui then it._gui:Destroy();it._gui=nil end
             end},
        }
    },
}

-- ══════════════════════════════════════════════
-- OTHER ITEMS
-- ══════════════════════════════════════════════
local OTHER_SECTIONS = {
    {
        title="УТИЛИТЫ", icon="🔧",
        items={
            {label="Chat Spam",icon="💬",desc="Авто-отправка сообщений в чат",state=false,conn=nil,
             param={label="Задержка (сек)",min=0.5,max=10,step=0.5,val=2,
              fmt=function(v) return string.format("%.1fs",v) end,
              apply=function(v,it) it._delay=v end},
             _delay=2,_msg="Hello!",
             enable=function(it)
                 it._delay=it.param.val
                 it.conn=task.spawn(function()
                     while it.state do
                         pcall(function()
                             local cs=game:GetService("Chat")
                             game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                                 and game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents
                                 :FindFirstChild("SayMessageRequest")
                                 and game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents
                                 .SayMessageRequest:FireServer(it._msg or "Hello!","All")
                         end)
                         task.wait(it._delay or 2)
                     end
                 end)
             end,
             disable=function(it)
                 it.state=false
             end},

            {label="Rejoin",icon="🔃",desc="Быстрый реджоин на тот же сервер",state=false,
             enable=function(it)
                 it.state=false
                 pcall(function()
                     local TPS=game:GetService("TeleportService")
                     TPS:Teleport(game.PlaceId,LP)
                 end)
             end,
             disable=function() end},

            {label="Server Hop",icon="🌐",desc="Прыгать по серверам автоматически",state=false,
             enable=function(it)
                 it.state=false
                 pcall(function()
                     local TPS=game:GetService("TeleportService")
                     local HttpService=game:GetService("HttpService")
                     local placeId=game.PlaceId
                     local found=false
                     local ok,servers=pcall(function()
                         return HttpService:JSONDecode(game:HttpGet(
                             "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
                         ))
                     end)
                     if ok and servers and servers.data then
                         for _,s in ipairs(servers.data) do
                             if s.id and s.id~=game.JobId and s.playing<s.maxPlayers then
                                 TPS:TeleportToPlaceInstance(placeId,s.id,LP)
                                 found=true;break
                             end
                         end
                     end
                     if not found then Notify("Server Hop","Нет доступных серверов",C.Red) end
                 end)
             end,
             disable=function() end},

            {label="Copy Position",icon="📋",desc="Скопировать CFrame в аутпут",state=false,
             enable=function(it)
                 it.state=false
                 pcall(function()
                     local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                     if hrp then
                         local p=hrp.Position
                         local str=string.format("Vector3.new(%.2f, %.2f, %.2f)",p.X,p.Y,p.Z)
                         print("[LuxuryHub] Position: "..str)
                         Notify("Position",str,C.Acc)
                         setclipboard(str)
                     end
                 end)
             end,
             disable=function() end},

            {label="Lag Switch",icon="⚡",desc="Заморозить соединение (E держать)",state=false,conn=nil,
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
        }
    },
}

-- ══════════════════════════════════════════════
-- ALL ITEMS FLAT (for respawn)
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

-- MINI BUTTON
local miniBtn=New("TextButton",{
    Size=UDim2.new(0,Settings.miniSize,0,Settings.miniSize),
    Position=UDim2.new(0,12,Settings.miniYPct,-Settings.miniSize/2),
    BackgroundColor3=C.BG2,BorderSizePixel=0,
    Text="LZ",TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.Acc,
    Visible=false,ZIndex=20,AutoButtonColor=false,
},Screen)
Rnd(miniBtn,Settings.miniSize/2);Strk(miniBtn,C.AccL,1.5)

-- SIDEBAR
local sidebar=New("Frame",{
    Size=UDim2.new(0,68,0,10),
    Position=UDim2.new(0,PX-84,0,PY),
    BackgroundColor3=C.SB0,BorderSizePixel=0,
    AutomaticSize=Enum.AutomaticSize.Y,
},Screen)
Rnd(sidebar,22);Strk(sidebar,C.Bord,1.2)

local sideInner=New("Frame",{Size=UDim2.new(1,0,0,10),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y},sidebar)
Pd(sideInner,10);Lst(sideInner,Enum.FillDirection.Vertical,8,Enum.HorizontalAlignment.Center)

New("TextLabel",{Size=UDim2.new(1,0,0,14),Text="MENU",TextSize=7,
    Font=Enum.Font.GothamBold,TextColor3=C.TxF,BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Center,LayoutOrder=0},sideInner)

-- PANEL
local panel=New("Frame",{
    Size=UDim2.new(0,Settings.PW,0,Settings.PH),
    Position=UDim2.new(0,PX,0,PY),
    BackgroundColor3=C.BG1,BorderSizePixel=0,
},Screen)
Rnd(panel,22);Strk(panel,C.Bord,1.5)

local clip=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ClipsDescendants=true},panel)
Rnd(clip,22)

-- HEADER
local hdr=New("Frame",{Size=UDim2.new(1,0,0,64),BackgroundColor3=C.BG2,BorderSizePixel=0},clip)
Rnd(hdr,22)
New("Frame",{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,1,-22),BackgroundColor3=C.BG2,BorderSizePixel=0},hdr)
local accentLine=New("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=C.Acc,BorderSizePixel=0},hdr)

-- Logo
local logoF=New("Frame",{Size=UDim2.new(0,40,0,40),Position=UDim2.new(0,14,0.5,-20),
    BackgroundColor3=C.AccG,BorderSizePixel=0},hdr)
Rnd(logoF,20);Strk(logoF,C.AccL,1.5)
New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="LZ",TextSize=14,Font=Enum.Font.GothamBold,
    TextColor3=C.Acc,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center},logoF)

New("TextLabel",{Size=UDim2.new(0,220,0,22),Position=UDim2.new(0,62,0,8),
    Text="LUXURY HUB",TextSize=17,Font=Enum.Font.GothamBold,TextColor3=C.TxW,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left},hdr)
New("TextLabel",{Size=UDim2.new(0,220,0,14),Position=UDim2.new(0,63,0,32),
    Text="v24 · Player Edition",TextSize=9,Font=Enum.Font.Gotham,
    TextColor3=C.TxL,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left},hdr)

local activeBadge=New("TextLabel",{
    Size=UDim2.new(0,80,0,22),Position=UDim2.new(1,-196,0.5,-11),
    BackgroundColor3=C.BG3,BorderSizePixel=0,
    Text="0 акт.",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.TxM,
    TextXAlignment=Enum.TextXAlignment.Center,
},hdr)
Rnd(activeBadge,11);Strk(activeBadge,C.Bord,1)

local function UpdateBadge()
    local cnt=0
    for _,it in ipairs(ALL_ITEMS) do if it.state then cnt=cnt+1 end end
    activeBadge.Text=cnt.." акт."
    activeBadge.TextColor3=cnt>0 and C.Green or C.TxM
    activeBadge.BackgroundColor3=cnt>0 and C.AccG or C.BG3
end

-- HBtn
local function MkHBtn(xOff,txt,hc,cb)
    local b=New("TextButton",{Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,xOff,0.5,-14),
        BackgroundColor3=C.BG3,BorderSizePixel=0,Text=txt,TextSize=13,
        Font=Enum.Font.GothamBold,TextColor3=C.TxM,AutoButtonColor=false,ZIndex=10},hdr)
    Rnd(b,14);Strk(b,C.Bord,1)
    b.MouseEnter:Connect(function() Tw(b,{BackgroundColor3=hc},0.12) end)
    b.MouseLeave:Connect(function() Tw(b,{BackgroundColor3=C.BG3},0.12) end)
    b.MouseButton1Click:Connect(cb)
    return b
end

local function HideUI()
    Open=false
    Tw(panel,{Size=UDim2.new(0,Settings.PW,0,0)},Settings.animSpeed)
    Tw(sidebar,{BackgroundTransparency=1},Settings.animSpeed)
    task.delay(Settings.animSpeed+0.05,function()
        panel.Visible=false;sidebar.Visible=false;miniBtn.Visible=true
    end)
end
local function ShowUI()
    Open=true;miniBtn.Visible=false
    panel.Visible=true;sidebar.Visible=true
    sidebar.BackgroundTransparency=0
    panel.Size=UDim2.new(0,Settings.PW,0,0)
    Tw(panel,{Size=UDim2.new(0,Settings.PW,0,Settings.PH)},Settings.animSpeed)
    task.defer(function()
        local px=panel.AbsolutePosition.X
        local py=panel.AbsolutePosition.Y
        local ph=panel.AbsoluteSize.Y
        local sh=sidebar.AbsoluteSize.Y
        sidebar.Position=UDim2.new(0,px-84,0,py+math.floor((ph-sh)/2))
    end)
end

MkHBtn(-10,"✕",C.Red,HideUI)
MkHBtn(-46,"─",C.BG5,HideUI)

-- SCROLL
local scroll=New("ScrollingFrame",{
    Size=UDim2.new(1,0,1,-64-32),Position=UDim2.new(0,0,0,64),
    BackgroundTransparency=1,BorderSizePixel=0,
    ScrollBarThickness=3,ScrollBarImageColor3=C.AccG,
    CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ClipsDescendants=true,
},clip)
Pd(scroll,nil,8,8,12,12);Lst(scroll,Enum.FillDirection.Vertical,6)

-- FOOTER
local ftr=New("Frame",{Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,1,-32),
    BackgroundColor3=C.BG2,BorderSizePixel=0},clip)
New("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,0),BackgroundColor3=C.Sep,BorderSizePixel=0},ftr)
local fTabName=New("TextLabel",{Size=UDim2.new(0.4,0,1,0),Position=UDim2.new(0,14,0,0),
    Text="Player",TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.Acc,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left},ftr)
New("TextLabel",{Size=UDim2.new(0.4,0,1,0),Position=UDim2.new(0.6,0,0,0),
    Text="RShift — скрыть",TextSize=9,Font=Enum.Font.Gotham,TextColor3=C.TxF,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right},ftr)

-- ══════════════════════════════════════════════
-- NAV TABS
-- ══════════════════════════════════════════════
local navBtns={}
local TAB_DATA={
    {name="Player",icon="👤",col=C.Acc,sections=PLAYER_SECTIONS},
    {name="Visual",icon="👁️",col=C.Blue,sections=VISUAL_SECTIONS},
    {name="Other",icon="🔧",col=C.Yel,sections=OTHER_SECTIONS},
}

local function SyncSidebar()
    local px=panel.AbsolutePosition.X
    local py=panel.AbsolutePosition.Y
    local ph=panel.AbsoluteSize.Y
    local sh=sidebar.AbsoluteSize.Y
    sidebar.Position=UDim2.new(0,px-84,0,py+math.floor((ph-sh)/2))
end

local function RefreshContent()
    for _,c in ipairs(scroll:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
    local td=TAB_DATA[CurTab]
    fTabName.Text=td.name
    for _,sec in ipairs(td.sections) do
        SecLbl(scroll,sec.title,sec.icon)
        for _,item in ipairs(sec.items) do
            MakeCard(scroll,item,td.col)
        end
    end
end

local function BuildNav()
    for _,b in ipairs(navBtns) do b:Destroy() end
    navBtns={}
    for i,td in ipairs(TAB_DATA) do
        local act=(CurTab==i)
        local nb=New("TextButton",{
            Size=UDim2.new(0,48,0,48),
            BackgroundColor3=act and C.SB2 or C.SB0,
            BorderSizePixel=0,Text="",AutoButtonColor=false,LayoutOrder=i,
        },sideInner)
        Rnd(nb,16)
        if act then Strk(nb,td.col,1.5) end
        New("TextLabel",{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0,4),
            Text=td.icon,TextSize=18,Font=Enum.Font.GothamBold,
            TextColor3=act and td.col or C.TxL,
            BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center},nb)
        New("TextLabel",{Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-14),
            Text=td.name,TextSize=7,Font=Enum.Font.GothamBold,
            TextColor3=act and td.col or C.TxF,
            BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center},nb)
        if act then
            local dot=New("Frame",{Size=UDim2.new(0,5,0,5),Position=UDim2.new(1,-3,0.5,-2.5),
                BackgroundColor3=td.col,BorderSizePixel=0},nb)
            Rnd(dot,3)
        end
        nb.MouseEnter:Connect(function() if not act then Tw(nb,{BackgroundColor3=C.SB1},0.12) end end)
        nb.MouseLeave:Connect(function() if not act then Tw(nb,{BackgroundColor3=C.SB0},0.12) end end)
        nb.MouseButton1Click:Connect(function()
            CurTab=i;BuildNav();RefreshContent();task.defer(SyncSidebar)
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
        task.defer(SyncSidebar)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
end)

-- ══════════════════════════════════════════════
-- HOTKEY / MINI
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
task.defer(SyncSidebar)
UpdateBadge()

local total=0
for _,it in ipairs(ALL_ITEMS) do total=total+1 end
Notify("LUXURY HUB v24","Загружен! "..total.." функций · 3 таба",C.Acc)
print("LUXURY HUB v24 - OK | "..total.." items")