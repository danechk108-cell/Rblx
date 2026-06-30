-- LUXURY HUB v25 FIXED
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TW = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Safe GuiRoot
local GuiRoot = LP.PlayerGui
pcall(function()
    local cg = game:GetService("CoreGui")
    if cg then GuiRoot = cg end
end)
pcall(function()
    local gh = gethui()
    if gh then GuiRoot = gh end
end)

local old = GuiRoot:FindFirstChild("LuxuryHub")
if old then old:Destroy() end

local Screen = Instance.new("ScreenGui")
Screen.Name = "LuxuryHub"
Screen.ResetOnSpawn = false
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Screen.IgnoreGuiInset = true
Screen.Parent = GuiRoot

local C = {
    BG0  = Color3.fromRGB(22,23,26),
    BG1  = Color3.fromRGB(28,29,33),
    BG2  = Color3.fromRGB(35,36,41),
    BG3  = Color3.fromRGB(42,44,50),
    BG4  = Color3.fromRGB(50,52,59),
    BG5  = Color3.fromRGB(58,60,68),
    SB0  = Color3.fromRGB(20,21,24),
    SB1  = Color3.fromRGB(30,31,36),
    SB2  = Color3.fromRGB(40,42,48),
    Acc  = Color3.fromRGB(140,142,150),
    AccH = Color3.fromRGB(170,172,180),
    AccD = Color3.fromRGB(90,92,100),
    TxW  = Color3.fromRGB(230,230,228),
    TxH  = Color3.fromRGB(180,180,176),
    TxM  = Color3.fromRGB(120,121,116),
    TxL  = Color3.fromRGB(75,77,72),
    TxF  = Color3.fromRGB(45,47,44),
    Bord = Color3.fromRGB(50,52,60),
    BordH= Color3.fromRGB(70,72,82),
    BordA= Color3.fromRGB(100,102,112),
    Sep  = Color3.fromRGB(38,40,46),
    Green= Color3.fromRGB(90,180,110),
    Red  = Color3.fromRGB(190,75,75),
    White= Color3.fromRGB(255,255,255),
    SlT  = Color3.fromRGB(25,26,30),
    Toggle=Color3.fromRGB(100,102,112),
}

local Settings = {PW=660,PH=580,miniSize=46}

-- panel and clip forward declarations
local panel, clip, miniBtn, scroll

-- ══════════════════════════════════════════════
-- UTILS
-- ══════════════════════════════════════════════
local function New(cls,props,parent)
    local ok,i = pcall(Instance.new, cls)
    if not ok then return nil end
    for k,v in pairs(props or {}) do
        pcall(function() i[k]=v end)
    end
    if parent then i.Parent=parent end
    return i
end

local function Tw(inst,props,t)
    if not inst or not inst.Parent then return end
    pcall(function()
        TW:Create(inst,TweenInfo.new(t or 0.18,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),props):Play()
    end)
end

local function Rnd(inst,r)
    if not inst then return end
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,r or 10)
    c.Parent=inst
    return c
end

local function Strk(inst,col,th)
    if not inst then return end
    local s=Instance.new("UIStroke")
    s.Color=col or C.Bord
    s.Thickness=th or 1
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    s.Parent=inst
    return s
end

local function Pd(inst,a,t,b,l,r)
    if not inst then return end
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
    p.Parent=inst
    return p
end

local function Lst(inst,dir,pad,ha)
    if not inst then return end
    local l=Instance.new("UIListLayout")
    l.FillDirection=dir or Enum.FillDirection.Vertical
    l.Padding=UDim.new(0,pad or 6)
    l.HorizontalAlignment=ha or Enum.HorizontalAlignment.Left
    l.SortOrder=Enum.SortOrder.LayoutOrder
    l.Parent=inst
    return l
end

local function SafeClip(str)
    pcall(function()
        if setclipboard then setclipboard(str)
        elseif toclipboard then toclipboard(str) end
    end)
end

-- ══════════════════════════════════════════════
-- NOTIFY
-- ══════════════════════════════════════════════
local notifStack={}
local function Notify(title,msg,col)
    col=col or C.Acc
    local ok,n=pcall(function()
        return New("Frame",{
            Size=UDim2.new(0,280,0,58),
            Position=UDim2.new(1,300,1,-80),
            BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=300
        },Screen)
    end)
    if not ok or not n then return end
    Rnd(n,10);Strk(n,col,1.2)
    New("Frame",{Size=UDim2.new(0,3,1,0),BackgroundColor3=col,BorderSizePixel=0,ZIndex=301},n)
    New("TextLabel",{Size=UDim2.new(1,-14,0,22),Position=UDim2.new(0,12,0,5),
        Text=title,TextSize=12,Font=Enum.Font.GothamBold,TextColor3=col,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=302},n)
    New("TextLabel",{Size=UDim2.new(1,-14,0,16),Position=UDim2.new(0,12,0,28),
        Text=msg,TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.TxM,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=302},n)
    table.insert(notifStack,n)
    for i,nn in ipairs(notifStack) do
        local ty=-80-(#notifStack-i)*64
        Tw(nn,{Position=UDim2.new(1,-292,1,ty)},0.25)
    end
    task.delay(3.5,function()
        Tw(n,{Position=UDim2.new(1,300,1,-80)},0.22)
        task.delay(0.3,function()
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
-- CONFIRM DIALOG
-- ══════════════════════════════════════════════
local function ShowConfirm(title,msg,onYes,onNo)
    local overlay=New("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=Color3.fromRGB(0,0,0),
        BackgroundTransparency=0.55,BorderSizePixel=0,ZIndex=400
    },Screen)
    if not overlay then return end

    local box=New("Frame",{
        Size=UDim2.new(0,300,0,140),
        Position=UDim2.new(0.5,-150,0.5,-70),
        BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=401
    },overlay)
    Rnd(box,14);Strk(box,C.BordA,1.5)

    New("TextLabel",{
        Size=UDim2.new(1,-16,0,32),Position=UDim2.new(0,8,0,8),
        Text=title,TextSize=14,Font=Enum.Font.GothamBold,
        TextColor3=C.TxW,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=402
    },box)

    New("TextLabel",{
        Size=UDim2.new(1,-16,0,28),Position=UDim2.new(0,8,0,40),
        Text=msg,TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=402
    },box)

    New("Frame",{
        Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,76),
        BackgroundColor3=C.Sep,BorderSizePixel=0,ZIndex=402
    },box)

    local btnRow=New("Frame",{
        Size=UDim2.new(1,-16,0,38),Position=UDim2.new(0,8,0,88),
        BackgroundTransparency=1,ZIndex=402
    },box)
    Lst(btnRow,Enum.FillDirection.Horizontal,8,Enum.HorizontalAlignment.Center)

    local function MkBtn(txt,bgCol,txCol,cb)
        local b=New("TextButton",{
            Size=UDim2.new(0,118,0,32),
            BackgroundColor3=bgCol,BorderSizePixel=0,
            Text=txt,TextSize=11,Font=Enum.Font.GothamBold,
            TextColor3=txCol,AutoButtonColor=false,ZIndex=403
        },btnRow)
        if not b then return end
        Rnd(b,8)
        b.MouseButton1Click:Connect(function()
            pcall(function() overlay:Destroy() end)
            if cb then pcall(cb) end
        end)
    end

    MkBtn("Да, завершить",C.BG4,C.Red,onYes)
    MkBtn("Отмена",C.BG3,C.TxM,onNo)
end

-- ══════════════════════════════════════════════
-- SLIDER
-- ══════════════════════════════════════════════
local function MakeSlider(parent,opts)
    local mn=opts.min or 0
    local mx=opts.max or 100
    local st=opts.step or 1
    local val=opts.val or mn
    local fmt=opts.fmt or tostring

    local cont=New("Frame",{Size=UDim2.new(1,0,0,50),BackgroundTransparency=1},parent)
    if not cont then return end

    local row=New("Frame",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1},cont)
    New("TextLabel",{
        Size=UDim2.new(1,-70,1,0),Text=opts.label or "",TextSize=10,
        Font=Enum.Font.GothamMedium,TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left
    },row)
    local valLbl=New("TextLabel",{
        Size=UDim2.new(0,66,1,0),Position=UDim2.new(1,-66,0,0),
        Text=fmt(val),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.TxW,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right
    },row)
    if not valLbl then return cont end

    local trackBg=New("Frame",{
        Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,0,26),
        BackgroundColor3=C.SlT,BorderSizePixel=0
    },cont)
    Rnd(trackBg,3);Strk(trackBg,C.Bord,0.8)

    local pct0=math.max(0,math.min(1,(val-mn)/(mx-mn)))
    local fill=New("Frame",{
        Size=UDim2.new(pct0,0,1,0),
        BackgroundColor3=C.Acc,BorderSizePixel=0
    },trackBg)
    Rnd(fill,3)

    local knob=New("Frame",{
        Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,-9,0.5,-9),
        BackgroundColor3=C.BG5,BorderSizePixel=0,ZIndex=6
    },fill)
    Rnd(knob,9);Strk(knob,C.BordA,1.2)
    local ki=New("Frame",{
        Size=UDim2.new(0,8,0,8),Position=UDim2.new(0.5,-4,0.5,-4),
        BackgroundColor3=C.TxW,BorderSizePixel=0,ZIndex=7
    },knob)
    Rnd(ki,4)

    local dragging=false
    local function Update(x)
        if not trackBg or not trackBg.Parent then return end
        local abs=trackBg.AbsolutePosition.X
        local sz=trackBg.AbsoluteSize.X
        if sz<=0 then return end
        local p=math.max(0,math.min(1,(x-abs)/sz))
        local raw=mn+p*(mx-mn)
        local snap=math.floor(raw/st+0.5)*st
        snap=math.max(mn,math.min(mx,snap))
        if snap~=val then
            val=snap
            local p2=math.max(0,math.min(1,(val-mn)/(mx-mn)))
            pcall(function() fill.Size=UDim2.new(p2,0,1,0) end)
            pcall(function() valLbl.Text=fmt(val) end)
            if opts.onChange then pcall(opts.onChange,val) end
        end
    end

    local hit=New("TextButton",{
        Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,0,16),
        BackgroundTransparency=1,Text="",ZIndex=9
    },cont)
    if hit then
        hit.MouseButton1Down:Connect(function(x) dragging=true;Update(x) end)
    end
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            Update(i.Position.X)
        end
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
    local H=24
    local cont=New("Frame",{Size=UDim2.new(0,48,0,H),BackgroundTransparency=1},parent)
    if not cont then return cont,{Set=function()end,Get=function() return false end} end

    local track=New("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=init and C.Toggle or C.BG0,BorderSizePixel=0
    },cont)
    Rnd(track,H/2)
    Strk(track,init and C.BordA or C.Bord,1)

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
            Tw(track,{BackgroundColor3=on and C.Toggle or C.BG0},0.15)
            Tw(kn,{Position=pos},0.15)
        else
            pcall(function() track.BackgroundColor3=on and C.Toggle or C.BG0 end)
            pcall(function() kn.Position=pos end)
        end
        pcall(function()
            local uk=track:FindFirstChildOfClass("UIStroke")
            if uk then uk.Color=on and C.BordA or C.Bord end
        end)
    end

    local btn=New("TextButton",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=10
    },cont)
    if btn then
        btn.MouseButton1Click:Connect(function()
            Set(not on,true)
            if onChange then pcall(onChange,on) end
        end)
    end
    return cont,{Set=Set,Get=function() return on end}
end

-- ══════════════════════════════════════════════
-- SEC LABEL
-- ══════════════════════════════════════════════
local function SecLbl(parent,txt)
    local f=New("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1},parent)
    if not f then return end
    New("TextLabel",{
        Size=UDim2.new(1,0,1,0),Text=txt,TextSize=9,
        Font=Enum.Font.GothamBold,TextColor3=C.TxL,
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
local function MakeCard(parent,item)
    local baseH=58
    local expandH=baseH+70

    local wrap=New("Frame",{
        Size=UDim2.new(1,0,0,baseH),
        BackgroundTransparency=1,ClipsDescendants=false
    },parent)
    if not wrap then return end

    local card=New("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=item.state and C.BG4 or C.BG2,
        BorderSizePixel=0,ClipsDescendants=true,ZIndex=1
    },wrap)
    Rnd(card,12)
    local strk=Strk(card,item.state and C.BordA or C.Bord,1)

    local bar=New("Frame",{
        Size=UDim2.new(0,3,0,26),Position=UDim2.new(0,0,0.5,-13),
        BackgroundColor3=C.Acc,BorderSizePixel=0,Visible=item.state,ZIndex=2
    },card)
    Rnd(bar,2)

    local iconF=New("Frame",{
        Size=UDim2.new(0,32,0,32),Position=UDim2.new(0,10,0.5,-16),
        BackgroundColor3=item.state and C.BG5 or C.BG3,BorderSizePixel=0,ZIndex=2
    },card)
    Rnd(iconF,8)
    Strk(iconF,item.state and C.BordA or C.Bord,1)
    local iconLbl=New("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        Text=item.icon or "?",TextSize=9,Font=Enum.Font.GothamBold,
        TextColor3=item.state and C.TxW or C.TxL,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=3
    },iconF)

    local lbl=New("TextLabel",{
        Size=UDim2.new(1,-118,0,20),Position=UDim2.new(0,52,0,9),
        Text=item.label,TextSize=13,Font=Enum.Font.GothamBold,
        TextColor3=item.state and C.TxW or C.TxH,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2
    },card)

    local dsc=New("TextLabel",{
        Size=UDim2.new(1,-118,0,14),Position=UDim2.new(0,52,0,32),
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
        if paramPanel then
            Rnd(paramPanel,10);Strk(paramPanel,C.Bord,1)
            local inner=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},paramPanel)
            if inner then
                Pd(inner,nil,10,8,14,14)
                local pp=item.param
                MakeSlider(inner,{
                    label=pp.label,min=pp.min,max=pp.max,step=pp.step,val=pp.val,fmt=pp.fmt,
                    onChange=function(v)
                        pp.val=v
                        if pp.apply then pcall(pp.apply,v,item) end
                    end,
                })
            end
        end
    end

    local function ApplyState(s,anim)
        pcall(function()
            if anim then Tw(card,{BackgroundColor3=s and C.BG4 or C.BG2},0.15)
            else card.BackgroundColor3=s and C.BG4 or C.BG2 end
            strk.Color=s and C.BordA or C.Bord
            bar.Visible=s
            lbl.TextColor3=s and C.TxW or C.TxH
            dsc.TextColor3=s and C.TxM or C.TxL
            iconF.BackgroundColor3=s and C.BG5 or C.BG3
            iconLbl.TextColor3=s and C.TxW or C.TxL
            local ik=iconF:FindFirstChildOfClass("UIStroke")
            if ik then ik.Color=s and C.BordA or C.Bord end
        end)
        if paramPanel then
            pcall(function()
                if s then
                    paramPanel.Visible=true
                    Tw(paramPanel,{Size=UDim2.new(1,-8,0,68)},0.2)
                    Tw(wrap,{Size=UDim2.new(1,0,0,expandH)},0.2)
                else
                    Tw(paramPanel,{Size=UDim2.new(1,-8,0,0)},0.15)
                    Tw(wrap,{Size=UDim2.new(1,0,0,baseH)},0.15)
                    task.delay(0.18,function()
                        pcall(function()
                            if not item.state and paramPanel and paramPanel.Parent then
                                paramPanel.Visible=false
                            end
                        end)
                    end)
                end
            end)
        end
    end

    local tgC,tgCtrl=MakeToggle(card,item.state,nil)
    if tgC then tgC.Position=UDim2.new(1,-60,0.5,-12);tgC.ZIndex=5 end

    local function DoToggle()
        local ns=not item.state
        item.state=ns
        if tgCtrl then tgCtrl.Set(ns,true) end
        ApplyState(ns,true)
        if ns then
            local ok=true
            pcall(function()
                local r=item.enable(item)
                if r==false then ok=false end
            end)
            if not ok then
                item.state=false
                if tgCtrl then tgCtrl.Set(false,true) end
                ApplyState(false,true)
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
    if hit then
        hit.MouseButton1Click:Connect(DoToggle)
    end
    if card then
        card.MouseEnter:Connect(function()
            if not item.state then
                Tw(card,{BackgroundColor3=C.BG3},0.1)
                pcall(function() strk.Color=C.BordH end)
            end
        end)
        card.MouseLeave:Connect(function()
            if not item.state then
                Tw(card,{BackgroundColor3=C.BG2},0.1)
                pcall(function() strk.Color=C.Bord end)
            end
        end)
    end
    if item.state then ApplyState(true,false) end
    return wrap
end

-- ══════════════════════════════════════════════
-- ITEMS
-- ══════════════════════════════════════════════
local PLAYER_SECTIONS={
    {title="ДВИЖЕНИЕ",items={
        {label="Speed Boost",icon="SPD",desc="Ускорение ходьбы",state=false,
         param={label="Множитель",min=1,max=20,step=0.5,val=2.5,
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
                 if h then h.WalkSpeed=16*(it.param and it.param.val or 2.5) end
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
                 if h then h.JumpPower=(it.param and it.param.val or 150) end
             end)
         end,
         disable=function()
             pcall(function()
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.JumpPower=50 end
             end)
         end},

        {label="Infinite Jump",icon="INF",desc="Прыжок в воздухе",state=false,conn=nil,
         enable=function(it)
             it.conn=UIS.JumpRequest:Connect(function()
                 pcall(function()
                     local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                     if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                 end)
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
         end},

        {label="Fly",icon="FLY",desc="Полёт WASD+Space/Ctrl",state=false,conn=nil,_bv=nil,_bg=nil,_spd=60,
         param={label="Скорость",min=10,max=500,step=5,val=60,
          fmt=function(v) return math.floor(v).."u/s" end,
          apply=function(v,it) if it then it._spd=v end end},
         enable=function(it)
             it._spd=(it.param and it.param.val or 60)
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
                 if it._bv and it._bv.Parent then it._bv:Destroy() end;it._bv=nil
                 if it._bg and it._bg.Parent then it._bg:Destroy() end;it._bg=nil
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.PlatformStand=false end
             end)
         end},

        {label="No Clip",icon="NCP",desc="Сквозь стены",state=false,conn=nil,
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

        {label="Freeze",icon="FRZ",desc="Заморозить персонажа",state=false,
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
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
         end},

        {label="TP to Player",icon="TP",desc="Телепорт к ближайшему",state=false,conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local char=LP.Character;if not char then return end
                     local hrp=char:FindFirstChild("HumanoidRootPart");if not hrp then return end
                     local nearest,dist=nil,math.huge
                     for _,pl in ipairs(Players:GetPlayers()) do
                         if pl~=LP and pl.Character then
                             local oh=pl.Character:FindFirstChild("HumanoidRootPart")
                             if oh then
                                 local d=(hrp.Position-oh.Position).Magnitude
                                 if d<dist then dist=d;nearest=oh end
                             end
                         end
                     end
                     if nearest then
                         hrp.CFrame=nearest.CFrame*CFrame.new(0,0,3.5)
                     end
                 end)
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
         end},

        {label="Click TP",icon="CLK",desc="Телепорт по ПКМ",state=false,conn=nil,
         enable=function(it)
             it.conn=UIS.InputBegan:Connect(function(inp,gpe)
                 if gpe then return end
                 if inp.UserInputType==Enum.UserInputType.MouseButton2 then
                     pcall(function()
                         local cam=workspace.CurrentCamera
                         local ray=cam:ScreenPointToRay(inp.Position.X,inp.Position.Y)
                         local res=workspace:Raycast(ray.Origin,ray.Direction*500)
                         if res then
                             local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                             if hrp then
                                 hrp.CFrame=CFrame.new(res.Position+Vector3.new(0,3,0))
                             end
                         end
                     end)
                 end
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
         end},

        {label="Speed Dash",icon="DSH",desc="Рывок по Q",state=false,conn=nil,_dashPow=150,
         param={label="Сила рывка",min=50,max=500,step=10,val=150,
          fmt=function(v) return math.floor(v).."u/s" end,
          apply=function(v,it) if it then it._dashPow=v end end},
         enable=function(it)
             it._dashPow=(it.param and it.param.val or 150)
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
                         game:GetService("Debris"):AddItem(bv,0.2)
                     end)
                 end
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
         end},

        {label="Save Position",icon="PIN",desc="F5=сохранить F6=вернуться",state=false,conn=nil,_pos=nil,
         enable=function(it)
             it.conn=UIS.InputBegan:Connect(function(inp,gpe)
                 if gpe then return end
                 if inp.KeyCode==Enum.KeyCode.F5 then
                     pcall(function()
                         local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                         if hrp then it._pos=hrp.CFrame;Notify("Position","Сохранено",C.Green) end
                     end)
                 elseif inp.KeyCode==Enum.KeyCode.F6 then
                     pcall(function()
                         if it._pos then
                             local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                             if hrp then hrp.CFrame=it._pos;Notify("Position","Телепорт",C.Acc) end
                         end
                     end)
                 end
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
         end},
    }},
    {title="ПЕРСОНАЖ",items={
        {label="God Mode",icon="GOD",desc="Бесконечное здоровье",state=false,conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                     if h then h.Health=h.MaxHealth end
                 end)
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
         end},

        {label="Max Health",icon="HP+",desc="Увеличить макс. здоровье",state=false,
         param={label="Макс. здоровье",min=100,max=10000,step=100,val=1000,
          fmt=function(v) return math.floor(v).."HP" end,
          apply=function(v)
              pcall(function()
                  local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                  if h then h.MaxHealth=v;h.Health=v end
              end)
          end},
         enable=function(it)
             pcall(function()
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then
                     h.MaxHealth=(it.param and it.param.val or 1000)
                     h.Health=h.MaxHealth
                 end
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
          fmt=function(v) return math.floor(v).."g" end,
          apply=function(v) pcall(function() workspace.Gravity=v end) end},
         enable=function(it)
             pcall(function() workspace.Gravity=(it.param and it.param.val or 20) end)
         end,
         disable=function()
             pcall(function() workspace.Gravity=196.2 end)
         end},

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

        {label="Neon Body",icon="NEO",desc="Neon материал",state=false,_orig={},
         enable=function(it)
             pcall(function()
                 it._orig={}
                 for _,p in ipairs(LP.Character:GetDescendants()) do
                     if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                         it._orig[p]=p.Material
                         p.Material=Enum.Material.Neon
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

        {label="Rainbow Body",icon="RGB",desc="Переливающиеся цвета",state=false,conn=nil,_hue=0,
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
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
         end},

        {label="Spin",icon="SPN",desc="Вращение персонажа",state=false,conn=nil,_angle=0,_spd=10,
         param={label="Скорость вращения",min=1,max=60,step=1,val=10,
          fmt=function(v) return math.floor(v).."x" end,
          apply=function(v,it) if it then it._spd=v end end},
         enable=function(it)
             it._spd=(it.param and it.param.val or 10)
             it._angle=0
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
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
         end},

        {label="Anti-AFK",icon="AFK",desc="Защита от кика",state=false,conn=nil,
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
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
         end},

        {label="Auto Respawn",icon="RSP",desc="Авто-возрождение",state=false,conn=nil,
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
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
         end},
    }},
}

local VISUAL_SECTIONS={
    {title="ВИЗУАЛ",items={
        {label="ESP Players",icon="ESP",desc="Игроки сквозь стены",state=false,_esp={},conn=nil,
         enable=function(it)
             it._esp={}
             local function MakeTag(pl)
                 if pl==LP then return end
                 local function DoTag(char)
                     task.wait(0.5)
                     pcall(function()
                         local hrp=char:FindFirstChild("HumanoidRootPart");if not hrp then return end
                         local old2=hrp:FindFirstChild("_LHubESP");if old2 then old2:Destroy() end
                         local bb=Instance.new("BillboardGui")
                         bb.Name="_LHubESP"
                         bb.Size=UDim2.new(0,90,0,36)
                         bb.AlwaysOnTop=true
                         bb.StudsOffset=Vector3.new(0,3,0)
                         bb.Parent=hrp
                         New("TextLabel",{
                             Size=UDim2.new(1,0,0,20),
                             Text=pl.Name,TextSize=11,Font=Enum.Font.GothamBold,
                             TextColor3=C.Red,BackgroundTransparency=1,
                             TextStrokeTransparency=0,TextStrokeColor3=Color3.new(0,0,0)
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
             for _,pl in ipairs(Players:GetPlayers()) do
                 if pl~=LP and pl.Character then
                     local hrp=pl.Character:FindFirstChild("HumanoidRootPart")
                     if hrp then
                         local t2=hrp:FindFirstChild("_LHubESP")
                         if t2 then t2:Destroy() end
                     end
                 end
             end
         end},

        {label="Fullbright",icon="FBR",desc="Максимальная яркость",state=false,_orig=nil,
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

        {label="Remove Fog",icon="FOG",desc="Убрать туман",state=false,
         enable=function()
             pcall(function()
                 local L=game:GetService("Lighting")
                 L.FogStart=0;L.FogEnd=999999
             end)
         end,
         disable=function()
             pcall(function() game:GetService("Lighting").FogEnd=100000 end)
         end},

        {label="Night Vision",icon="NVS",desc="Яркость ночью",state=false,
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

        {label="FOV Changer",icon="FOV",desc="Поле зрения камеры",state=false,
         param={label="Field of View",min=30,max=130,step=5,val=90,
          fmt=function(v) return math.floor(v).."deg" end,
          apply=function(v)
              pcall(function() workspace.CurrentCamera.FieldOfView=v end)
          end},
         enable=function(it)
             pcall(function() workspace.CurrentCamera.FieldOfView=(it.param and it.param.val or 90) end)
         end,
         disable=function()
             pcall(function() workspace.CurrentCamera.FieldOfView=70 end)
         end},

        {label="Zoom Unlock",icon="ZOM",desc="Снять лимит зума",state=false,
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

        {label="Time Changer",icon="TME",desc="Время суток",state=false,
         param={label="Время (0-24)",min=0,max=24,step=0.5,val=12,
          fmt=function(v) return string.format("%.1fh",v) end,
          apply=function(v)
              pcall(function() game:GetService("Lighting").ClockTime=v end)
          end},
         enable=function(it)
             pcall(function() game:GetService("Lighting").ClockTime=(it.param and it.param.val or 12) end)
         end,
         disable=function()
             pcall(function() game:GetService("Lighting").ClockTime=14 end)
         end},
    }},
    {title="HUD",items={
        {label="FPS Counter",icon="FPS",desc="Счётчик FPS",state=false,_gui=nil,conn=nil,
         enable=function(it)
             pcall(function()
                 local fr=New("Frame",{Size=UDim2.new(0,110,0,26),Position=UDim2.new(0,8,0,8),
                     BackgroundColor3=C.BG1,BorderSizePixel=0,ZIndex=150},Screen)
                 Rnd(fr,8);Strk(fr,C.Bord,1)
                 local lbl=New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="FPS: --",TextSize=11,
                     Font=Enum.Font.GothamBold,TextColor3=C.TxW,BackgroundTransparency=1,
                     TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151},fr)
                 it._gui=fr
                 local last=tick();local frames=0
                 it.conn=RS.RenderStepped:Connect(function()
                     frames=frames+1
                     if tick()-last>=0.5 then
                         pcall(function() lbl.Text="FPS: "..math.floor(frames/(tick()-last)) end)
                         frames=0;last=tick()
                     end
                 end)
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             if it._gui then pcall(function() it._gui:Destroy() end);it._gui=nil end
         end},

        {label="Speed Meter",icon="SPM",desc="Скорость персонажа",state=false,_gui=nil,conn=nil,
         enable=function(it)
             pcall(function()
                 local fr=New("Frame",{Size=UDim2.new(0,130,0,26),Position=UDim2.new(0,8,0,40),
                     BackgroundColor3=C.BG1,BorderSizePixel=0,ZIndex=150},Screen)
                 Rnd(fr,8);Strk(fr,C.Bord,1)
                 local lbl=New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="Spd: --",TextSize=11,
                     Font=Enum.Font.GothamBold,TextColor3=C.TxW,BackgroundTransparency=1,
                     TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151},fr)
                 it._gui=fr;local lastPos=nil
                 it.conn=RS.Heartbeat:Connect(function(dt)
                     pcall(function()
                         local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                         if hrp then
                             if lastPos then
                                 lbl.Text=string.format("Spd: %.1f",(hrp.Position-lastPos).Magnitude/dt)
                             end
                             lastPos=hrp.Position
                         end
                     end)
                 end)
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             if it._gui then pcall(function() it._gui:Destroy() end);it._gui=nil end
         end},

        {label="Position HUD",icon="XYZ",desc="XYZ позиция",state=false,_gui=nil,conn=nil,
         enable=function(it)
             pcall(function()
                 local fr=New("Frame",{Size=UDim2.new(0,200,0,26),Position=UDim2.new(0,8,0,72),
                     BackgroundColor3=C.BG1,BorderSizePixel=0,ZIndex=150},Screen)
                 Rnd(fr,8);Strk(fr,C.Bord,1)
                 local lbl=New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="X:0 Y:0 Z:0",TextSize=10,
                     Font=Enum.Font.GothamMedium,TextColor3=C.TxW,BackgroundTransparency=1,
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
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             if it._gui then pcall(function() it._gui:Destroy() end);it._gui=nil end
         end},

        {label="Clock HUD",icon="CLK",desc="Реальное время",state=false,_gui=nil,conn=nil,
         enable=function(it)
             pcall(function()
                 local fr=New("Frame",{Size=UDim2.new(0,110,0,26),Position=UDim2.new(0,8,0,104),
                     BackgroundColor3=C.BG1,BorderSizePixel=0,ZIndex=150},Screen)
                 Rnd(fr,8);Strk(fr,C.Bord,1)
                 local lbl=New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="--:--:--",TextSize=11,
                     Font=Enum.Font.GothamBold,TextColor3=C.TxW,BackgroundTransparency=1,
                     TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151},fr)
                 it._gui=fr
                 it.conn=RS.Heartbeat:Connect(function()
                     pcall(function()
                         local t=os.date("*t")
                         lbl.Text=string.format("%02d:%02d:%02d",t.hour,t.min,t.sec)
                     end)
                 end)
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             if it._gui then pcall(function() it._gui:Destroy() end);it._gui=nil end
         end},

        {label="Crosshair",icon="AIM",desc="Прицел на экране",state=false,_gui=nil,
         enable=function(it)
             pcall(function()
                 local fr=New("Frame",{Size=UDim2.new(0,36,0,36),
                     Position=UDim2.new(0.5,-18,0.5,-18),BackgroundTransparency=1,ZIndex=180},Screen)
                 New("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,0.5,-1),
                     BackgroundColor3=C.TxW,BorderSizePixel=0,ZIndex=181},fr)
                 New("Frame",{Size=UDim2.new(0,2,1,0),Position=UDim2.new(0.5,-1,0,0),
                     BackgroundColor3=C.TxW,BorderSizePixel=0,ZIndex=181},fr)
                 it._gui=fr
             end)
         end,
         disable=function(it)
             if it._gui then pcall(function() it._gui:Destroy() end);it._gui=nil end
         end},
    }},
}

local OTHER_SECTIONS={
    {title="УТИЛИТЫ",items={
        {label="Copy Position",icon="CPY",desc="Позиция в Output",state=false,
         enable=function(it)
             it.state=false
             pcall(function()
                 local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                 if hrp then
                     local p=hrp.Position
                     local str=string.format("Vector3.new(%.2f,%.2f,%.2f)",p.X,p.Y,p.Z)
                     print("[LuxuryHub] "..str)
                     SafeClip(str)
                     Notify("Position",str,C.Acc)
                 end
             end)
         end,
         disable=function() end},

        {label="Rejoin",icon="RJN",desc="Реджоин",state=false,
         enable=function(it)
             it.state=false
             pcall(function()
                 game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
             end)
         end,
         disable=function() end},

        {label="Server Hop",icon="HOP",desc="Другой сервер",state=false,
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
                             "/servers/Public?sortOrder=Asc&limit=100"))
                     end)
                     if ok and data and data.data then
                         for _,s in ipairs(data.data) do
                             if s.id and s.id~=game.JobId and (s.playing or 0)<(s.maxPlayers or 1) then
                                 TPS:TeleportToPlaceInstance(pid,s.id,LP)
                                 return
                             end
                         end
                     end
                     Notify("Server Hop","Нет серверов",C.Red)
                 end)
             end)
         end,
         disable=function() end},

        {label="Lag Switch",icon="LAG",desc="Держи E чтобы заморозить",state=false,conn=nil,conn2=nil,
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

        {label="Print Players",icon="LST",desc="Список в Output",state=false,
         enable=function(it)
             it.state=false
             local list=""
             for _,pl in ipairs(Players:GetPlayers()) do list=list..pl.Name.."\n" end
             print("[LuxuryHub] Players:\n"..list)
             Notify("Players",#Players:GetPlayers().." игроков",C.Acc)
         end,
         disable=function() end},
    }},
    {title="НАСТРОЙКИ МЕНЮ",items={
        {label="Menu Width",icon="WDT",desc="Ширина меню",state=false,
         param={label="Ширина",min=400,max=900,step=10,val=660,
          fmt=function(v) return math.floor(v).."px" end,
          apply=function(v)
              Settings.PW=v
              pcall(function()
                  if panel and panel.Parent then
                      panel.Size=UDim2.new(0,v,0,Settings.PH)
                  end
              end)
          end},
         enable=function(it)
             Settings.PW=(it.param and it.param.val or 660)
             pcall(function()
                 if panel and panel.Parent then
                     panel.Size=UDim2.new(0,Settings.PW,0,Settings.PH)
                 end
             end)
         end,
         disable=function() end},

        {label="Menu Height",icon="HGT",desc="Высота меню",state=false,
         param={label="Высота",min=300,max=900,step=10,val=580,
          fmt=function(v) return math.floor(v).."px" end,
          apply=function(v)
              Settings.PH=v
              pcall(function()
                  if panel and panel.Parent then
                      panel.Size=UDim2.new(0,Settings.PW,0,v)
                  end
              end)
          end},
         enable=function(it)
             Settings.PH=(it.param and it.param.val or 580)
             pcall(function()
                 if panel and panel.Parent then
                     panel.Size=UDim2.new(0,Settings.PW,0,Settings.PH)
                 end
             end)
         end,
         disable=function() end},

        {label="Menu Opacity",icon="OPC",desc="Прозрачность меню",state=false,
         param={label="Прозрачность",min=20,max=100,step=5,val=100,
          fmt=function(v) return math.floor(v).."%" end,
          apply=function(v)
              local t=1-(v/100)
              pcall(function()
                  if panel and panel.Parent then panel.BackgroundTransparency=t end
              end)
          end},
         enable=function(it)
             local t=1-((it.param and it.param.val or 100)/100)
             pcall(function()
                 if panel and panel.Parent then panel.BackgroundTransparency=t end
             end)
         end,
         disable=function()
             pcall(function()
                 if panel and panel.Parent then panel.BackgroundTransparency=0 end
             end)
         end},

        {label="Mini Btn Size",icon="BTN",desc="Размер кнопки показа",state=false,
         param={label="Размер",min=30,max=80,step=2,val=46,
          fmt=function(v) return math.floor(v).."px" end,
          apply=function(v)
              Settings.miniSize=v
              pcall(function()
                  if miniBtn and miniBtn.Parent then
                      miniBtn.Size=UDim2.new(0,v,0,v)
                  end
              end)
          end},
         enable=function(it)
             Settings.miniSize=(it.param and it.param.val or 46)
             pcall(function()
                 if miniBtn and miniBtn.Parent then
                     miniBtn.Size=UDim2.new(0,Settings.miniSize,0,Settings.miniSize)
                 end
             end)
         end,
         disable=function() end},
    }},
}

local ALL_ITEMS={}
for _,sec in ipairs(PLAYER_SECTIONS) do for _,it in ipairs(sec.items) do table.insert(ALL_ITEMS,it) end end
for _,sec in ipairs(VISUAL_SECTIONS) do for _,it in ipairs(sec.items) do table.insert(ALL_ITEMS,it) end end
for _,sec in ipairs(OTHER_SECTIONS)  do for _,it in ipairs(sec.items) do table.insert(ALL_ITEMS,it) end end

-- ══════════════════════════════════════════════
-- BUILD UI
-- ══════════════════════════════════════════════
local VP=workspace.CurrentCamera.ViewportSize
local PX=math.floor((VP.X-Settings.PW)/2)
local PY=math.floor((VP.Y-Settings.PH)/2)
local Open=true
local CurTab=1

local TAB_DATA={
    {name="Player",  short="PLR", sections=PLAYER_SECTIONS},
    {name="Visual",  short="VIS", sections=VISUAL_SECTIONS},
    {name="Other",   short="OTH", sections=OTHER_SECTIONS},
}

-- PANEL
panel=New("Frame",{
    Size=UDim2.new(0,Settings.PW,0,Settings.PH),
    Position=UDim2.new(0,PX,0,PY),
    BackgroundColor3=C.BG1,BorderSizePixel=0,Visible=true,
},Screen)
Rnd(panel,16);Strk(panel,C.Bord,1.5)

clip=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ClipsDescendants=true},panel)
Rnd(clip,16)

-- HEADER
local hdr=New("Frame",{
    Size=UDim2.new(1,0,0,56),BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=2
},clip)
Rnd(hdr,16)
New("Frame",{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,1,-16),
    BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=2},hdr)
New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
    BackgroundColor3=C.Sep,BorderSizePixel=0,ZIndex=3},hdr)

-- Logo
local logoF=New("Frame",{
    Size=UDim2.new(0,34,0,34),Position=UDim2.new(0,12,0.5,-17),
    BackgroundColor3=C.BG4,BorderSizePixel=0,ZIndex=3
},hdr)
Rnd(logoF,8);Strk(logoF,C.BordH,1)
New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="LZ",TextSize=12,Font=Enum.Font.GothamBold,
    TextColor3=C.TxW,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=4},logoF)

New("TextLabel",{Size=UDim2.new(0,170,0,20),Position=UDim2.new(0,54,0,7),
    Text="LUXURY HUB",TextSize=15,Font=Enum.Font.GothamBold,TextColor3=C.TxW,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},hdr)
New("TextLabel",{Size=UDim2.new(0,170,0,14),Position=UDim2.new(0,55,0,28),
    Text="v25 Player Edition",TextSize=9,Font=Enum.Font.Gotham,TextColor3=C.TxL,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},hdr)

-- Active badge
local activeBadge=New("TextLabel",{
    Size=UDim2.new(0,68,0,20),Position=UDim2.new(1,-174,0.5,-10),
    BackgroundColor3=C.BG3,BorderSizePixel=0,
    Text="0 акт.",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.TxM,
    TextXAlignment=Enum.TextXAlignment.Center,ZIndex=4
},hdr)
Rnd(activeBadge,8);Strk(activeBadge,C.Bord,1)

local function UpdateBadge()
    local cnt=0
    for _,it in ipairs(ALL_ITEMS) do if it.state then cnt=cnt+1 end end
    pcall(function()
        activeBadge.Text=cnt.." акт."
        activeBadge.TextColor3=cnt>0 and C.Green or C.TxM
    end)
end

-- Header buttons - RIGHT side
local function MkHBtn(xOff,txt,hoverCol,cb)
    local b=New("TextButton",{
        Size=UDim2.new(0,26,0,26),
        Position=UDim2.new(1,xOff,0.5,-13),
        BackgroundColor3=C.BG3,BorderSizePixel=0,
        Text=txt,TextSize=11,Font=Enum.Font.GothamBold,
        TextColor3=C.TxM,AutoButtonColor=false,ZIndex=5
    },hdr)
    if not b then return end
    Rnd(b,7);Strk(b,C.Bord,1)
    b.MouseEnter:Connect(function()
        Tw(b,{BackgroundColor3=hoverCol},0.1)
        pcall(function() b.TextColor3=C.TxW end)
    end)
    b.MouseLeave:Connect(function()
        Tw(b,{BackgroundColor3=C.BG3},0.1)
        pcall(function() b.TextColor3=C.TxM end)
    end)
    b.MouseButton1Click:Connect(function() pcall(cb) end)
    return b
end

-- X = -12 from right, minimize = -44
MkHBtn(-12,"X",C.Red,function()
    ShowConfirm(
        "Завершить скрипт?",
        "Все активные функции будут отключены.",
        function()
            for _,it in ipairs(ALL_ITEMS) do
                if it.state then
                    it.state=false
                    pcall(it.disable,it)
                end
            end
            pcall(function() Screen:Destroy() end)
        end,
        nil
    )
end)
MkHBtn(-44,"-",C.BG5,function()
    Open=false
    panel.Visible=false
    miniBtn.Visible=true
end)

-- MINI BUTTON
miniBtn=New("TextButton",{
    Size=UDim2.new(0,Settings.miniSize,0,Settings.miniSize),
    Position=UDim2.new(0,12,0.5,-Settings.miniSize/2),
    BackgroundColor3=C.BG2,BorderSizePixel=0,
    Text="LZ",TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.TxW,
    Visible=false,ZIndex=20,AutoButtonColor=false,
},Screen)
Rnd(miniBtn,10);Strk(miniBtn,C.BordH,1.2)
miniBtn.MouseButton1Click:Connect(function()
    Open=true
    miniBtn.Visible=false
    panel.Visible=true
end)

-- TAB BAR
local tabBar=New("Frame",{
    Size=UDim2.new(1,0,0,34),
    Position=UDim2.new(0,0,0,56),
    BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=3
},clip)
New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
    BackgroundColor3=C.Sep,BorderSizePixel=0,ZIndex=4},tabBar)
local tabRow=New("Frame",{
    Size=UDim2.new(1,-14,1,-8),Position=UDim2.new(0,7,0,4),
    BackgroundTransparency=1,ZIndex=4
},tabBar)
Lst(tabRow,Enum.FillDirection.Horizontal,4,Enum.HorizontalAlignment.Left)

-- SCROLL
scroll=New("ScrollingFrame",{
    Size=UDim2.new(1,0,1,-56-34-24),
    Position=UDim2.new(0,0,0,56+34),
    BackgroundTransparency=1,BorderSizePixel=0,
    ScrollBarThickness=3,ScrollBarImageColor3=C.BG5,
    CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ClipsDescendants=true,ZIndex=2
},clip)
Pd(scroll,nil,6,6,10,10)
Lst(scroll,Enum.FillDirection.Vertical,5)

-- FOOTER
local ftr=New("Frame",{
    Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,1,-24),
    BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=3
},clip)
New("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,0),
    BackgroundColor3=C.Sep,BorderSizePixel=0,ZIndex=4},ftr)
local fTabName=New("TextLabel",{
    Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,12,0,0),
    Text="Player",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.TxM,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4
},ftr)
New("TextLabel",{
    Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0.5,-12,0,0),
    Text="RShift = скрыть",TextSize=9,Font=Enum.Font.Gotham,TextColor3=C.TxF,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=4
},ftr)

-- ══════════════════════════════════════════════
-- TAB BUILD
-- ══════════════════════════════════════════════
local tabPills={}

local function RefreshContent()
    for _,c in ipairs(scroll:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
            pcall(function() c:Destroy() end)
        end
    end
    local td=TAB_DATA[CurTab]
    pcall(function() fTabName.Text=td.name end)
    for _,sec in ipairs(td.sections) do
        SecLbl(scroll,sec.title)
        for _,item in ipairs(sec.items) do
            MakeCard(scroll,item)
        end
    end
end

local function BuildTabs()
    for _,p in ipairs(tabPills) do pcall(function() p:Destroy() end) end
    tabPills={}
    for i,td in ipairs(TAB_DATA) do
        local act=(CurTab==i)
        local pill=New("TextButton",{
            Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,
            BackgroundColor3=act and C.BG4 or C.BG2,
            BorderSizePixel=0,
            Text="  "..td.name.."  ",
            TextSize=10,Font=act and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextColor3=act and C.TxW or C.TxL,
            AutoButtonColor=false,ZIndex=5
        },tabRow)
        if not pill then continue end
        Rnd(pill,8)
        if act then Strk(pill,C.BordA,1) end
        pill.MouseEnter:Connect(function()
            if not act then
                Tw(pill,{BackgroundColor3=C.BG3},0.1)
                pcall(function() pill.TextColor3=C.TxM end)
            end
        end)
        pill.MouseLeave:Connect(function()
            if not act then
                Tw(pill,{BackgroundColor3=C.BG2},0.1)
                pcall(function() pill.TextColor3=C.TxL end)
            end
        end)
        pill.MouseButton1Click:Connect(function()
            CurTab=i;BuildTabs();RefreshContent()
        end)
        table.insert(tabPills,pill)
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
        pcall(function()
            local d=i.Position-dragS
            panel.Position=UDim2.new(dragP.X.Scale,dragP.X.Offset+d.X,dragP.Y.Scale,dragP.Y.Offset+d.Y)
        end)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
end)

-- HOTKEY
UIS.InputBegan:Connect(function(i,gpe)
    if gpe then return end
    if i.KeyCode==Enum.KeyCode.RightShift then
        if Open then
            Open=false;panel.Visible=false;miniBtn.Visible=true
        else
            Open=true;miniBtn.Visible=false;panel.Visible=true
        end
    end
end)

-- BADGE POLL
task.spawn(function()
    while Screen and Screen.Parent do
        task.wait(1);pcall(UpdateBadge)
    end
end)

-- RESPAWN
LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    for _,it in ipairs(ALL_ITEMS) do
        if it.state then pcall(it.enable,it) end
    end
end)

-- INIT
BuildTabs()
RefreshContent()
UpdateBadge()

Notify("LUXURY HUB v25","OK! "..#ALL_ITEMS.." функций загружено",C.Acc)
print("LUXURY HUB v25 FIXED - OK | "..#ALL_ITEMS.." items")