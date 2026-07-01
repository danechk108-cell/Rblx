-- LUXURY HUB v27 — Pet Simulator 99 Edition
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TW = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local GuiRoot = LP.PlayerGui
pcall(function() local cg=game:GetService("CoreGui"); if cg then GuiRoot=cg end end)
pcall(function() local gh=gethui(); if gh then GuiRoot=gh end end)

local old=GuiRoot:FindFirstChild("LuxuryHub")
if old then old:Destroy() end

local Screen=Instance.new("ScreenGui")
Screen.Name="LuxuryHub"
Screen.ResetOnSpawn=false
Screen.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
Screen.IgnoreGuiInset=true
Screen.Parent=GuiRoot

local C={
    BG0=Color3.fromRGB(18,19,22),
    BG1=Color3.fromRGB(24,25,29),
    BG2=Color3.fromRGB(31,32,37),
    BG3=Color3.fromRGB(38,40,46),
    BG4=Color3.fromRGB(46,48,55),
    BG5=Color3.fromRGB(54,56,64),
    Acc=Color3.fromRGB(125,127,138),
    TxW=Color3.fromRGB(225,225,220),
    TxH=Color3.fromRGB(172,172,167),
    TxM=Color3.fromRGB(112,113,108),
    TxL=Color3.fromRGB(70,72,68),
    TxF=Color3.fromRGB(42,44,40),
    Bord=Color3.fromRGB(46,48,56),
    BordH=Color3.fromRGB(66,68,78),
    BordA=Color3.fromRGB(92,94,106),
    Sep=Color3.fromRGB(34,36,42),
    Green=Color3.fromRGB(85,175,105),
    Red=Color3.fromRGB(185,70,70),
    White=Color3.fromRGB(255,255,255),
    SlT=Color3.fromRGB(20,21,26),
    Tog=Color3.fromRGB(92,94,108),
    Gold=Color3.fromRGB(255,200,50),
    Pink=Color3.fromRGB(255,100,200),
}

local Settings={PW=700,PH=600,miniSize=46}
local panel,clip,miniBtn,scroll

local function New(cls,props,parent)
    local ok,i=pcall(Instance.new,cls)
    if not ok or not i then return nil end
    for k,v in pairs(props or {}) do pcall(function() i[k]=v end) end
    if parent then i.Parent=parent end
    return i
end
local function Tw(inst,props,t)
    if not inst or not inst.Parent then return end
    pcall(function()
        TW:Create(inst,TweenInfo.new(t or 0.16,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),props):Play()
    end)
end
local function Rnd(inst,r)
    if not inst then return end
    local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=inst;return c
end
local function Strk(inst,col,th)
    if not inst then return end
    local s=Instance.new("UIStroke");s.Color=col or C.Bord;s.Thickness=th or 1
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;s.Parent=inst;return s
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
    p.Parent=inst;return p
end
local function Lst(inst,dir,pad,ha)
    if not inst then return end
    local l=Instance.new("UIListLayout")
    l.FillDirection=dir or Enum.FillDirection.Vertical
    l.Padding=UDim.new(0,pad or 6)
    l.HorizontalAlignment=ha or Enum.HorizontalAlignment.Left
    l.SortOrder=Enum.SortOrder.LayoutOrder
    l.Parent=inst;return l
end
local function SafeClip(str)
    pcall(function() if setclipboard then setclipboard(str) elseif toclipboard then toclipboard(str) end end)
end

-- ══════════════════════════════════════════════
-- HTTP HELPER
-- ══════════════════════════════════════════════
local function HttpGet(url)
    if request then
        local ok,res=pcall(request,{Url=url,Method="GET"})
        if ok and res and res.Body then return true,res.Body end
    end
    if syn and syn.request then
        local ok,res=pcall(syn.request,{Url=url,Method="GET"})
        if ok and res and res.Body then return true,res.Body end
    end
    if http_request then
        local ok,res=pcall(http_request,{Url=url,Method="GET"})
        if ok and res and res.Body then return true,res.Body end
    end
    local ok,res=pcall(function()
        return game:GetService("HttpService"):GetAsync(url,true)
    end)
    if ok and res then return true,res end
    return false,"HTTP недоступен"
end

-- ══════════════════════════════════════════════
-- NOTIFY
-- ══════════════════════════════════════════════
local notifStack={}
local function Notify(title,msg,col)
    col=col or C.Acc
    local n=New("Frame",{Size=UDim2.new(0,280,0,58),Position=UDim2.new(1,300,1,-80),
        BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=300},Screen)
    if not n then return end
    Rnd(n,10);Strk(n,col,1.2)
    New("Frame",{Size=UDim2.new(0,3,1,0),BackgroundColor3=col,BorderSizePixel=0,ZIndex=301},n)
    New("TextLabel",{Size=UDim2.new(1,-14,0,22),Position=UDim2.new(0,12,0,5),Text=title,
        TextSize=12,Font=Enum.Font.GothamBold,TextColor3=col,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=302},n)
    New("TextLabel",{Size=UDim2.new(1,-14,0,16),Position=UDim2.new(0,12,0,28),Text=msg,
        TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=302},n)
    table.insert(notifStack,n)
    for i,nn in ipairs(notifStack) do
        Tw(nn,{Position=UDim2.new(1,-292,1,-80-(#notifStack-i)*64)},0.25)
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
-- PRELOADER
-- ══════════════════════════════════════════════
local function ShowPreloader(onDone)
    local pFrame=New("Frame",{
        Size=UDim2.new(0,140,0,80),
        Position=UDim2.new(0.5,-70,0.5,-40),
        BackgroundColor3=C.BG1,BorderSizePixel=0,ZIndex=500,
        BackgroundTransparency=1,
    },Screen)
    Rnd(pFrame,16);Strk(pFrame,C.Pink,1.5)
    local lxLbl=New("TextLabel",{
        Size=UDim2.new(1,0,0,44),Position=UDim2.new(0,0,0,10),
        Text="🐾 LX",TextSize=28,Font=Enum.Font.GothamBold,
        TextColor3=C.TxW,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=501,TextTransparency=1,
    },pFrame)
    local subLbl=New("TextLabel",{
        Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,54),
        Text="PET SIM 99",TextSize=9,Font=Enum.Font.GothamMedium,
        TextColor3=C.Pink,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=501,TextTransparency=1,
    },pFrame)
    Tw(pFrame,{BackgroundTransparency=0},0.3)
    task.delay(0.3,function()
        Tw(lxLbl,{TextTransparency=0},0.4)
        task.delay(0.3,function()
            Tw(subLbl,{TextTransparency=0},0.3)
            task.delay(0.8,function()
                Tw(pFrame,{BackgroundTransparency=1},0.3)
                Tw(lxLbl,{TextTransparency=1},0.25)
                Tw(subLbl,{TextTransparency=1},0.25)
                task.delay(0.35,function()
                    pcall(function() pFrame:Destroy() end)
                    if onDone then onDone() end
                end)
            end)
        end)
    end)
end

-- ══════════════════════════════════════════════
-- KEY SYSTEM
-- ══════════════════════════════════════════════
local API_URL = "https://rblx-bot-cpe2.onrender.com"

local function ShowKeyScreen(onSuccess)
    local overlay=New("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=C.BG0,
        BackgroundTransparency=0,
        BorderSizePixel=0,ZIndex=100
    },Screen)
    local box=New("Frame",{
        Size=UDim2.new(0,340,0,260),
        Position=UDim2.new(0.5,-170,0.5,-130),
        BackgroundColor3=C.BG2,
        BorderSizePixel=0,ZIndex=101
    },overlay)
    Rnd(box,18);Strk(box,C.Pink,1.5)
    local logo=New("Frame",{
        Size=UDim2.new(0,52,0,52),
        Position=UDim2.new(0.5,-26,0,18),
        BackgroundColor3=C.BG4,BorderSizePixel=0,ZIndex=102
    },box)
    Rnd(logo,14);Strk(logo,C.Pink,1.2)
    New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="🐾",TextSize=24,
        Font=Enum.Font.GothamBold,TextColor3=C.Pink,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=103},logo)
    New("TextLabel",{
        Size=UDim2.new(1,-20,0,22),Position=UDim2.new(0,10,0,80),
        Text="LUXURY HUB — PS99",TextSize=16,Font=Enum.Font.GothamBold,
        TextColor3=C.TxW,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=102
    },box)
    New("TextLabel",{
        Size=UDim2.new(1,-20,0,16),Position=UDim2.new(0,10,0,104),
        Text="Введи ключ для продолжения",TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=102
    },box)
    local inputBg=New("Frame",{
        Size=UDim2.new(1,-24,0,36),Position=UDim2.new(0,12,0,130),
        BackgroundColor3=C.BG0,BorderSizePixel=0,ZIndex=102
    },box)
    Rnd(inputBg,10);Strk(inputBg,C.Bord,1)
    local input=New("TextBox",{
        Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),
        Text="",PlaceholderText="LX-XXXXX-XXXXX-XXXXX-XXXXX",
        TextSize=12,Font=Enum.Font.GothamMedium,
        TextColor3=C.TxW,PlaceholderColor3=C.TxF,
        BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Center,
        ClearTextOnFocus=false,ZIndex=103
    },inputBg)
    local statusLbl=New("TextLabel",{
        Size=UDim2.new(1,-20,0,14),Position=UDim2.new(0,10,0,174),
        Text="",TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=102
    },box)
    local confirmBtn=New("TextButton",{
        Size=UDim2.new(1,-24,0,36),Position=UDim2.new(0,12,0,194),
        BackgroundColor3=C.BG4,BorderSizePixel=0,
        Text="Подтвердить ключ",TextSize=12,Font=Enum.Font.GothamBold,
        TextColor3=C.TxW,AutoButtonColor=false,ZIndex=102
    },box)
    Rnd(confirmBtn,10);Strk(confirmBtn,C.Pink,1)
    New("TextButton",{
        Size=UDim2.new(1,-24,0,20),Position=UDim2.new(0,12,0,238),
        BackgroundTransparency=1,BorderSizePixel=0,
        Text="Получить ключ → @LuxuryHubBot",
        TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=C.TxL,AutoButtonColor=false,ZIndex=102
    },box)
    local loading=false
    local function SetStatus(txt,col)
        pcall(function() statusLbl.Text=txt;statusLbl.TextColor3=col or C.TxM end)
    end
    local function ValidateKey(key)
        if loading then return end
        key=key:match("^%s*(.-)%s*$")
        if not key:match("^LX%-") or #key~=26 then
            SetStatus("❌ Неверный формат (len="..#key..")",C.Red);return
        end
        loading=true
        SetStatus("⏳ Проверяем ключ...",C.TxM)
        Tw(confirmBtn,{BackgroundColor3=C.BG3},0.1)
        task.spawn(function()
            local url=API_URL.."/validate?key="..key
            local httpOk,body=HttpGet(url)
            loading=false
            Tw(confirmBtn,{BackgroundColor3=C.BG4},0.1)
            if not httpOk then SetStatus("❌ "..tostring(body),C.Red);return end
            local ok,result=pcall(function()
                return game:GetService("HttpService"):JSONDecode(body)
            end)
            if not ok then SetStatus("❌ Ошибка парсинга",C.Red);return end
            if result and result.valid then
                local keyType=result.type=="paid" and "♾ Вечный" or "⏱ 24 часа"
                SetStatus("✅ Ключ принят! ("..keyType..")",C.Green)
                task.wait(1)
                pcall(function() overlay:Destroy() end)
                onSuccess()
            else
                local reasons={
                    not_found="Ключ не найден",
                    expired="Ключ истёк. Получи новый в боте",
                    no_key="Введи ключ"
                }
                local reason=result and reasons[result.reason] or "Неверный ключ"
                SetStatus("❌ "..reason,C.Red)
                Tw(inputBg,{BackgroundColor3=Color3.fromRGB(50,25,25)},0.15)
                task.delay(0.3,function() Tw(inputBg,{BackgroundColor3=C.BG0},0.15) end)
            end
        end)
    end
    confirmBtn.MouseButton1Click:Connect(function() ValidateKey(input.Text) end)
    input.FocusLost:Connect(function(e) if e then ValidateKey(input.Text) end end)
    confirmBtn.MouseEnter:Connect(function()
        if not loading then Tw(confirmBtn,{BackgroundColor3=C.BG5},0.1) end end)
    confirmBtn.MouseLeave:Connect(function()
        if not loading then Tw(confirmBtn,{BackgroundColor3=C.BG4},0.1) end end)
end

-- ══════════════════════════════════════════════
-- CONFIRM
-- ══════════════════════════════════════════════
local function ShowConfirm(title,msg,onYes)
    local ov=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=0.55,BorderSizePixel=0,ZIndex=400},Screen)
    if not ov then return end
    local box=New("Frame",{Size=UDim2.new(0,300,0,138),Position=UDim2.new(0.5,-150,0.5,-69),
        BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=401},ov)
    Rnd(box,14);Strk(box,C.BordA,1.5)
    New("TextLabel",{Size=UDim2.new(1,-16,0,32),Position=UDim2.new(0,8,0,8),Text=title,
        TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.TxW,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=402},box)
    New("TextLabel",{Size=UDim2.new(1,-16,0,26),Position=UDim2.new(0,8,0,40),Text=msg,
        TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=402},box)
    New("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,74),
        BackgroundColor3=C.Sep,BorderSizePixel=0,ZIndex=402},box)
    local row=New("Frame",{Size=UDim2.new(1,-16,0,36),Position=UDim2.new(0,8,0,88),
        BackgroundTransparency=1,ZIndex=402},box)
    Lst(row,Enum.FillDirection.Horizontal,8,Enum.HorizontalAlignment.Center)
    local function Btn(txt,bg,tc,cb)
        local b=New("TextButton",{Size=UDim2.new(0,116,0,30),BackgroundColor3=bg,BorderSizePixel=0,
            Text=txt,TextSize=11,Font=Enum.Font.GothamBold,TextColor3=tc,AutoButtonColor=false,ZIndex=403},row)
        if b then Rnd(b,8);b.MouseButton1Click:Connect(function()
            pcall(function() ov:Destroy() end);if cb then pcall(cb) end end) end
    end
    Btn("Да",C.BG4,C.Red,onYes);Btn("Отмена",C.BG3,C.TxM,nil)
end

-- ══════════════════════════════════════════════
-- SLIDER
-- ══════════════════════════════════════════════
local function MakeSlider(parent,opts)
    local mn=opts.min or 0;local mx=opts.max or 100
    local st=opts.step or 1;local val=opts.val or mn
    local fmt=opts.fmt or tostring
    local cont=New("Frame",{Size=UDim2.new(1,0,0,52),BackgroundTransparency=1},parent)
    if not cont then return nil end
    local lblRow=New("Frame",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1},cont)
    New("TextLabel",{Size=UDim2.new(0.6,0,1,0),Text=opts.label or "",TextSize=10,
        Font=Enum.Font.GothamMedium,TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left},lblRow)
    local valLbl=New("TextLabel",{Size=UDim2.new(0.4,0,1,0),Position=UDim2.new(0.6,0,0,0),
        Text=tostring(fmt(val)),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.TxW,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right},lblRow)
    local trackBg=New("Frame",{Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,0,26),
        BackgroundColor3=C.SlT,BorderSizePixel=0},cont)
    Rnd(trackBg,3)
    local pct0=math.max(0,math.min(1,(val-mn)/(mx-mn)))
    local fill=New("Frame",{Size=UDim2.new(pct0,0,1,0),BackgroundColor3=C.Pink,BorderSizePixel=0},trackBg)
    Rnd(fill,3)
    local knob=New("Frame",{Size=UDim2.new(0,18,0,18),Position=UDim2.new(1,-9,0.5,-9),
        BackgroundColor3=C.BG5,BorderSizePixel=0,ZIndex=6},fill)
    Rnd(knob,9);Strk(knob,C.Pink,1.5)
    New("Frame",{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0.5,-4,0.5,-4),
        BackgroundColor3=C.TxW,BorderSizePixel=0,ZIndex=7},knob)
    Rnd(knob:FindFirstChildOfClass("Frame"),4)
    local dragging=false
    local function SetVal(v)
        v=math.max(mn,math.min(mx,math.floor(v/st+0.5)*st));val=v
        local p2=math.max(0,math.min(1,(val-mn)/(mx-mn)))
        pcall(function() fill.Size=UDim2.new(p2,0,1,0) end)
        pcall(function() valLbl.Text=tostring(fmt(val)) end)
        if opts.onChange then pcall(opts.onChange,val) end
    end
    local function UpdateFromX(x)
        if not trackBg or not trackBg.Parent then return end
        local ax=trackBg.AbsolutePosition.X;local aw=trackBg.AbsoluteSize.X
        if aw<=0 then return end
        SetVal(mn+(math.max(0,math.min(1,(x-ax)/aw)))*(mx-mn))
    end
    local hit=New("TextButton",{Size=UDim2.new(1,0,0,36),Position=UDim2.new(0,0,0,16),
        BackgroundTransparency=1,Text="",ZIndex=10,BorderSizePixel=0},cont)
    if hit then
        hit.MouseButton1Down:Connect(function(x) dragging=true;UpdateFromX(x) end)
        hit.MouseButton1Up:Connect(function() dragging=false end)
    end
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then UpdateFromX(i.Position.X) end
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
    if not cont then return nil,{Set=function()end,Get=function()return false end} end
    local track=New("Frame",{Size=UDim2.new(1,0,1,0),
        BackgroundColor3=init and C.Tog or C.BG0,BorderSizePixel=0},cont)
    Rnd(track,H/2);Strk(track,init and C.BordA or C.Bord,1)
    local kn=New("Frame",{
        Size=UDim2.new(0,H-6,0,H-6),
        Position=init and UDim2.new(1,-(H-3),0.5,-(H-6)/2) or UDim2.new(0,3,0.5,-(H-6)/2),
        BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=3},track)
    Rnd(kn,(H-6)/2)
    local on=init or false
    local function Set(s,anim)
        on=s
        local pos=on and UDim2.new(1,-(H-3),0.5,-(H-6)/2) or UDim2.new(0,3,0.5,-(H-6)/2)
        if anim then Tw(track,{BackgroundColor3=on and C.Tog or C.BG0},0.14);Tw(kn,{Position=pos},0.14)
        else pcall(function()track.BackgroundColor3=on and C.Tog or C.BG0 end);pcall(function()kn.Position=pos end) end
        pcall(function()
            local uk=track:FindFirstChildOfClass("UIStroke")
            if uk then uk.Color=on and C.BordA or C.Bord end
        end)
    end
    local btn=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=10},cont)
    if btn then btn.MouseButton1Click:Connect(function() Set(not on,true);if onChange then pcall(onChange,on) end end) end
    return cont,{Set=Set,Get=function()return on end}
end

local function MakeToggleRow(parent,label,initVal,onChange)
    local row=New("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1},parent)
    New("TextLabel",{Size=UDim2.new(1,-56,1,0),Text=label,TextSize=10,
        Font=Enum.Font.GothamMedium,TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left},row)
    local tgC,tgCtrl=MakeToggle(row,initVal,onChange)
    if tgC then tgC.Position=UDim2.new(1,-52,0.5,-12) end
    return row,tgCtrl
end

local function SecLbl(parent,txt)
    local f=New("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1},parent)
    if not f then return end
    New("TextLabel",{Size=UDim2.new(1,0,1,0),Text=txt,TextSize=9,
        Font=Enum.Font.GothamBold,TextColor3=C.TxL,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left},f)
    New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=C.Sep,BorderSizePixel=0},f)
end

-- ══════════════════════════════════════════════
-- CARD
-- ══════════════════════════════════════════════
local function MakeCard(parent,item)
    local BASE_H=60;local PARAM_H=item.paramH or 72;local GAP=4
    local wrap=New("Frame",{Size=UDim2.new(1,0,0,BASE_H),BackgroundTransparency=1,ClipsDescendants=false},parent)
    if not wrap then return end
    local card=New("Frame",{Size=UDim2.new(1,0,0,BASE_H),
        BackgroundColor3=item.state and C.BG4 or C.BG2,BorderSizePixel=0,ClipsDescendants=false,ZIndex=1},wrap)
    Rnd(card,12)
    local strk=Strk(card,item.state and C.BordA or C.Bord,1)
    local bar=New("Frame",{Size=UDim2.new(0,3,0,26),Position=UDim2.new(0,0,0.5,-13),
        BackgroundColor3=C.Pink,BorderSizePixel=0,Visible=item.state,ZIndex=2},card)
    Rnd(bar,2)
    local iconF=New("Frame",{Size=UDim2.new(0,32,0,32),Position=UDim2.new(0,10,0.5,-16),
        BackgroundColor3=item.state and C.BG5 or C.BG3,BorderSizePixel=0,ZIndex=2},card)
    Rnd(iconF,8);Strk(iconF,item.state and C.Pink or C.Bord,1)
    local iconLbl=New("TextLabel",{Size=UDim2.new(1,0,1,0),Text=item.icon or "?",TextSize=14,
        Font=Enum.Font.GothamBold,TextColor3=item.state and C.TxW or C.TxL,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=3},iconF)
    local lbl=New("TextLabel",{Size=UDim2.new(1,-118,0,20),Position=UDim2.new(0,52,0,9),
        Text=item.label,TextSize=13,Font=Enum.Font.GothamBold,
        TextColor3=item.state and C.TxW or C.TxH,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2},card)
    local dsc=New("TextLabel",{Size=UDim2.new(1,-118,0,14),Position=UDim2.new(0,52,0,32),
        Text=item.desc,TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=item.state and C.TxM or C.TxL,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2},card)
    local tgC,tgCtrl=MakeToggle(card,item.state,nil)
    if tgC then tgC.Position=UDim2.new(1,-60,0.5,-12);tgC.ZIndex=5 end
    local paramPanel=nil
    if item.param or item.buildParamPanel then
        paramPanel=New("Frame",{Size=UDim2.new(1,-4,0,0),Position=UDim2.new(0,2,0,BASE_H+GAP),
            BackgroundColor3=C.BG1,BorderSizePixel=0,ClipsDescendants=true,Visible=true,ZIndex=2},wrap)
        if paramPanel then
            Rnd(paramPanel,10);Strk(paramPanel,C.Bord,1)
            local inner=New("Frame",{Size=UDim2.new(1,0,0,PARAM_H),BackgroundTransparency=1},paramPanel)
            if inner then
                Pd(inner,nil,8,6,12,12)
                if item.buildParamPanel then item.buildParamPanel(inner)
                elseif item.param then
                    local pp=item.param
                    MakeSlider(inner,{label=pp.label,min=pp.min,max=pp.max,step=pp.step,val=pp.val,fmt=pp.fmt,
                        onChange=function(v) pp.val=v;if pp.apply then pcall(pp.apply,v,item) end end})
                end
            end
        end
    end
    local function ApplyVisual(s)
        pcall(function()
            card.BackgroundColor3=s and C.BG4 or C.BG2
            strk.Color=s and C.BordA or C.Bord
            bar.Visible=s
            lbl.TextColor3=s and C.TxW or C.TxH
            dsc.TextColor3=s and C.TxM or C.TxL
            iconF.BackgroundColor3=s and C.BG5 or C.BG3
            iconLbl.TextColor3=s and C.TxW or C.TxL
            local ik=iconF:FindFirstChildOfClass("UIStroke")
            if ik then ik.Color=s and C.Pink or C.Bord end
        end)
        if paramPanel then
            pcall(function()
                if s then
                    Tw(paramPanel,{Size=UDim2.new(1,-4,0,PARAM_H)},0.2)
                    Tw(wrap,{Size=UDim2.new(1,0,0,BASE_H+GAP+PARAM_H)},0.2)
                else
                    Tw(paramPanel,{Size=UDim2.new(1,-4,0,0)},0.16)
                    Tw(wrap,{Size=UDim2.new(1,0,0,BASE_H)},0.16)
                end
            end)
        end
    end
    local function DoToggle()
        local ns=not item.state;item.state=ns
        if tgCtrl then tgCtrl.Set(ns,true) end
        ApplyVisual(ns)
        if ns then
            local ok=true
            pcall(function() local r=item.enable(item);if r==false then ok=false end end)
            if not ok then
                item.state=false;if tgCtrl then tgCtrl.Set(false,true) end
                ApplyVisual(false)
            else Notify(item.label,"Включено",C.Green) end
        else
            pcall(item.disable,item)
            Notify(item.label,"Выключено",C.TxL)
        end
    end
    local hit=New("TextButton",{Size=UDim2.new(1,0,0,BASE_H),BackgroundTransparency=1,Text="",ZIndex=8},card)
    if hit then hit.MouseButton1Click:Connect(DoToggle) end
    card.MouseEnter:Connect(function()
        if not item.state then Tw(card,{BackgroundColor3=C.BG3},0.1);pcall(function()strk.Color=C.BordH end) end end)
    card.MouseLeave:Connect(function()
        if not item.state then Tw(card,{BackgroundColor3=C.BG2},0.1);pcall(function()strk.Color=C.Bord end) end end)
    if item.state then ApplyVisual(true) end
    return wrap
end

-- ══════════════════════════════════════════════
-- PS99 HELPERS
-- ══════════════════════════════════════════════

-- Получить RemoteEvent по имени
local function GetRemote(name)
    local RS2=game:GetService("ReplicatedStorage")
    return RS2:FindFirstChild(name,true)
end

-- Стрельнуть в RemoteEvent
local function FireServer(name,...)
    local rem=GetRemote(name)
    if rem and rem:IsA("RemoteEvent") then
        pcall(function() rem:FireServer(...) end)
        return true
    end
    return false
end

-- Invoke RemoteFunction
local function InvokeServer(name,...)
    local rem=GetRemote(name)
    if rem and rem:IsA("RemoteFunction") then
        local ok,res=pcall(function() return rem:InvokeServer(...) end)
        if ok then return res end
    end
    return nil
end

-- Получить данные игрока
local function GetPlayerData()
    -- PS99 хранит данные в разных местах
    local data=LP:FindFirstChild("Data") or
               LP:FindFirstChild("PlayerData") or
               LP:FindFirstChild("leaderstats")
    return data
end

-- Получить монеты
local function GetCoins()
    local data=GetPlayerData()
    if data then
        local coins=data:FindFirstChild("Coins") or
                    data:FindFirstChild("Cash") or
                    data:FindFirstChild("Money")
        if coins then return coins.Value end
    end
    return 0
end

-- Получить diamonds
local function GetDiamonds()
    local data=GetPlayerData()
    if data then
        local gems=data:FindFirstChild("Diamonds") or
                   data:FindFirstChild("Gems") or
                   data:FindFirstChild("Crystals")
        if gems then return gems.Value end
    end
    return 0
end

-- Найти все яйца на карте
local function FindEggs()
    local eggs={}
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and (
            v.Name:find("Egg") or
            v.Name:find("egg") or
            v.Name:find("EGG")
        ) then
            local root=v:FindFirstChildOfClass("BasePart") or
                       v:FindFirstChild("HumanoidRootPart")
            if root then
                table.insert(eggs,{model=v,part=root,name=v.Name})
            end
        end
    end
    return eggs
end

-- Найти монеты/кристаллы на карте
local function FindCollectibles()
    local items={}
    local names={"Coin","coin","COIN","Diamond","diamond","Gem","gem",
                 "Crystal","crystal","Money","Collectible","Reward"}
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            for _,name in ipairs(names) do
                if v.Name:find(name) then
                    local pos=v:IsA("Model") and
                        (v:FindFirstChildOfClass("BasePart") and
                        v:FindFirstChildOfClass("BasePart").Position) or
                        (v:IsA("BasePart") and v.Position)
                    if pos then
                        table.insert(items,{obj=v,pos=pos,name=v.Name})
                        break
                    end
                end
            end
        end
    end
    return items
end

-- Найти breakables (копилки, сундуки)
local function FindBreakables()
    local items={}
    local names={"Breakable","breakable","Piggy","piggy","Chest","chest",
                 "Box","box","Barrel","barrel","Crate","Present"}
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            for _,name in ipairs(names) do
                if v.Name:find(name) then
                    local pos=v:IsA("Model") and
                        (v:FindFirstChildOfClass("BasePart") and
                        v:FindFirstChildOfClass("BasePart").Position) or
                        (v:IsA("BasePart") and v.Position)
                    if pos then
                        table.insert(items,{obj=v,pos=pos})
                        break
                    end
                end
            end
        end
    end
    return items
end

-- Статистика в секунду
local _coinsPerSec=0
local _lastCoins=0
local _lastTime=tick()

RS.Heartbeat:Connect(function()
    local now=tick()
    if now-_lastTime>=1 then
        local cur=GetCoins()
        _coinsPerSec=cur-_lastCoins
        _lastCoins=cur
        _lastTime=now
    end
end)

-- ══════════════════════════════════════════════
-- PS99 SECTIONS
-- ══════════════════════════════════════════════
local PS99_SECTIONS={

    -- ══ ФАРМ ══
    {title="🥚 ФАРМ ЯИЦ",items={

        {label="Auto Hatch Eggs",icon="🥚",desc="Авто открытие яиц рядом",state=false,conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                     if not hrp then return end
                     local eggs=FindEggs()
                     -- Идём к ближайшему яйцу
                     local nearest,nearDist=nil,math.huge
                     for _,egg in ipairs(eggs) do
                         local d=(hrp.Position-egg.part.Position).Magnitude
                         if d<nearDist then nearDist=d;nearest=egg end
                     end
                     if nearest then
                         if nearDist>5 then
                             -- Телепортируемся к яйцу
                             hrp.CFrame=CFrame.new(nearest.part.Position+Vector3.new(0,3,0))
                         end
                         -- Пробуем открыть через разные remotes
                         FireServer("HatchEgg",nearest.model)
                         FireServer("OpenEgg",nearest.model)
                         FireServer("Hatch",nearest.model)
                         -- Клик по яйцу
                         local clickDetector=nearest.model:FindFirstChildOfClass("ClickDetector")
                         if clickDetector then
                             pcall(function()
                                 fireclickdetector(clickDetector)
                             end)
                         end
                     end
                 end)
             end)
         end,
         disable=function(it)if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="TP to Best Egg",icon="⭐",desc="Телепорт к лучшему яйцу",state=false,
         enable=function(it) it.state=false
             pcall(function()
                 local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                 if not hrp then return end
                 local eggs=FindEggs()
                 if #eggs==0 then Notify("Eggs","Яйца не найдены",C.Red);return end
                 -- Берём последнее (обычно лучшее)
                 local best=eggs[#eggs]
                 hrp.CFrame=CFrame.new(best.part.Position+Vector3.new(0,3,0))
                 Notify("TP Egg","Телепорт к: "..best.name,C.Green)
             end)
         end,disable=function()end},

        {label="Auto Farm Coins",icon="🪙",desc="Авто сбор монет на карте",state=false,conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                     if not hrp then return end
                     local items=FindCollectibles()
                     if #items==0 then return end
                     -- Телепортируемся к каждой монете
                     local nearest,nearDist=nil,math.huge
                     for _,item in ipairs(items) do
                         local d=(hrp.Position-item.pos).Magnitude
                         if d<nearDist then nearDist=d;nearest=item end
                     end
                     if nearest and nearDist>3 then
                         hrp.CFrame=CFrame.new(nearest.pos+Vector3.new(0,2,0))
                     end
                 end)
             end)
         end,
         disable=function(it)if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Break All Breakables",icon="💥",desc="Авто разбивать копилки/сундуки",state=false,conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                     if not hrp then return end
                     local items=FindBreakables()
                     for _,item in ipairs(items) do
                         if (hrp.Position-item.pos).Magnitude<30 then
                             -- Пробуем через ClickDetector
                             local cd=nil
                             if item.obj:IsA("Model") then
                                 cd=item.obj:FindFirstChildOfClass("ClickDetector")
                             elseif item.obj:IsA("BasePart") then
                                 cd=item.obj:FindFirstChildOfClass("ClickDetector")
                             end
                             if cd then pcall(function() fireclickdetector(cd) end) end
                             -- Через remote
                             FireServer("BreakObject",item.obj)
                             FireServer("Break",item.obj)
                             FireServer("BreakPiggyBank",item.obj)
                         end
                     end
                 end)
             end)
         end,
         disable=function(it)if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Coin Magnet",icon="🧲",desc="Притягивать монеты к себе",state=false,conn=nil,_range=50,
         param={label="Радиус магнита",min=10,max=200,step=10,val=50,
          fmt=function(v)return math.floor(v).."u"end,
          apply=function(v,it)it._range=v end},
         enable=function(it)
             it._range=it.param.val
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                     if not hrp then return end
                     local names={"Coin","Diamond","Gem","Crystal","Money","Orb"}
                     for _,v in ipairs(workspace:GetDescendants()) do
                         if v:IsA("BasePart") then
                             for _,name in ipairs(names) do
                                 if v.Name:find(name) then
                                     if (hrp.Position-v.Position).Magnitude<(it._range or 50) then
                                         -- Телепортируем монету к нам
                                         pcall(function() v.CFrame=CFrame.new(hrp.Position) end)
                                     end
                                     break
                                 end
                             end
                         end
                     end
                 end)
             end)
         end,
         disable=function(it)if it.conn then it.conn:Disconnect();it.conn=nil end end},
    }},

    -- ══ ПИТОМЦЫ ══
    {title="🐾 ПИТОМЦЫ",items={

        {label="Auto Equip Best Pets",icon="🐕",desc="Авто надеть лучших питомцев",state=false,
         enable=function(it) it.state=false
             pcall(function()
                 -- Ищем инвентарь питомцев
                 FireServer("EquipBestPets")
                 FireServer("AutoEquip")
                 FireServer("EquipPets")
                 -- Через PlayerGui
                 local pg=LP.PlayerGui
                 for _,v in ipairs(pg:GetDescendants()) do
                     if v:IsA("TextButton") and
                        (v.Text:find("Equip") or v.Text:find("Best")) then
                         pcall(function() v:FindFirstChild("UIAspectRatioConstraint") end)
                     end
                 end
                 Notify("Pets","Питомцы надеты!",C.Pink)
             end)
         end,disable=function()end},

        {label="Auto Delete Dupes",icon="🗑️",desc="Авто удаление дублей питомцев",state=false,
         enable=function(it) it.state=false
             pcall(function()
                 FireServer("DeleteDuplicates")
                 FireServer("SellDupes")
                 FireServer("AutoDelete")
                 Notify("Pets","Дубли удалены!",C.Green)
             end)
         end,disable=function()end},

        {label="Auto Sell Pets",icon="💰",desc="Авто продажа плохих питомцев",state=false,conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     FireServer("SellPets")
                     FireServer("AutoSell")
                     FireServer("SellAllPets")
                 end)
             end)
         end,
         disable=function(it)if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Max Pet Level",icon="⬆️",desc="Авто апгрейд питомцев",state=false,
         enable=function(it) it.state=false
             pcall(function()
                 FireServer("UpgradePets")
                 FireServer("LevelUpPets")
                 FireServer("MaxLevelPets")
                 Notify("Pets","Апгрейд запущен!",C.Green)
             end)
         end,disable=function()end},

        {label="Fuse Pets",icon="✨",desc="Авто слияние питомцев",state=false,conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     FireServer("FusePets")
                     FireServer("MergePets")
                     FireServer("AutoFuse")
                 end)
             end)
         end,
         disable=function(it)if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Unlock All Areas",icon="🔓",desc="Разблокировать все зоны",state=false,
         enable=function(it) it.state=false
             pcall(function()
                 FireServer("UnlockArea")
                 FireServer("UnlockZone")
                 FireServer("OpenArea")
                 -- Телепортируемся в последнюю зону
                 local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                 if hrp then
                     -- Ищем самую дальнюю зону
                     local zones={}
                     for _,v in ipairs(workspace:GetDescendants()) do
                         if v.Name:find("Zone") or v.Name:find("Area") or v.Name:find("World") then
                             if v:IsA("BasePart") or v:IsA("Model") then
                                 table.insert(zones,v)
                             end
                         end
                     end
                     if #zones>0 then
                         local zone=zones[#zones]
                         local pos=zone:IsA("BasePart") and zone.Position or
                             (zone:FindFirstChildOfClass("BasePart") and
                             zone:FindFirstChildOfClass("BasePart").Position)
                         if pos then hrp.CFrame=CFrame.new(pos+Vector3.new(0,5,0)) end
                     end
                 end
                 Notify("Areas","Зоны разблокированы!",C.Green)
             end)
         end,disable=function()end},
    }},

    -- ══ REBIRTH ══
    {title="♻️ REBIRTH / ПРОКАЧКА",items={

        {label="Auto Rebirth",icon="♻️",desc="Авто перерождение когда готово",state=false,conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     -- Проверяем готовность ребёрса
                     local data=GetPlayerData()
                     if data then
                         local rebirths=data:FindFirstChild("Rebirths") or
                                        data:FindFirstChild("Rebirth")
                         local coins=GetCoins()
                         -- Пробуем ребёрс
                         FireServer("Rebirth")
                         FireServer("DoRebirth")
                         FireServer("PrestigeRebirth")
                     end
                 end)
             end)
         end,
         disable=function(it)if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Auto Prestige",icon="🌟",desc="Авто престиж",state=false,conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     FireServer("Prestige")
                     FireServer("DoPrestige")
                     FireServer("PrestigeUp")
                 end)
             end)
         end,
         disable=function(it)if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Auto Rank Up",icon="🏆",desc="Авто повышение ранга",state=false,conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     FireServer("RankUp")
                     FireServer("Rank")
                     FireServer("IncreaseRank")
                 end)
             end)
         end,
         disable=function(it)if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="TP to Rebirth NPC",icon="🧙",desc="Телепорт к NPC перерождения",state=false,
         enable=function(it) it.state=false
             pcall(function()
                 local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                 if not hrp then return end
                 local targets={"RebirthNPC","Rebirth","PrestigeNPC","Prestige","RankNPC"}
                 for _,v in ipairs(workspace:GetDescendants()) do
                     for _,name in ipairs(targets) do
                         if v.Name:find(name) and (v:IsA("Model") or v:IsA("BasePart")) then
                             local pos=v:IsA("BasePart") and v.Position or
                                 (v:FindFirstChildOfClass("BasePart") and
                                 v:FindFirstChildOfClass("BasePart").Position)
                             if pos then
                                 hrp.CFrame=CFrame.new(pos+Vector3.new(0,5,3))
                                 Notify("Rebirth NPC","Телепортирован!",C.Green)
                                 return
                             end
                         end
                     end
                 end
                 Notify("Rebirth NPC","NPC не найден",C.Red)
             end)
         end,disable=function()end},
    }},

    -- ══ ДВИЖЕНИЕ ══
    {title="🚀 ДВИЖЕНИЕ",items={

        {label="Speed Boost",icon="💨",desc="Ускорение персонажа",state=false,
         param={label="Множитель",min=1,max=30,step=0.5,val=3,
          fmt=function(v)return string.format("%.1fx",v)end,
          apply=function(v)pcall(function()
              local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
              if h then h.WalkSpeed=16*v end end)end},
         enable=function(it)pcall(function()
             local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
             if h then h.WalkSpeed=16*it.param.val end end)end,
         disable=function()pcall(function()
             local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
             if h then h.WalkSpeed=16 end end)end},

        {label="Infinite Jump",icon="⬆️",desc="Прыжок в воздухе",state=false,conn=nil,
         enable=function(it)
             it.conn=UIS.JumpRequest:Connect(function()pcall(function()
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end) end)
         end,
         disable=function(it)if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Fly",icon="🛸",desc="Полёт WASD+Space/Ctrl",state=false,conn=nil,_bv=nil,_bg=nil,_spd=80,
         param={label="Скорость полёта",min=10,max=500,step=10,val=80,
          fmt=function(v)return math.floor(v).."u/s"end,
          apply=function(v,it)if it then it._spd=v end end},
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
                 it.conn=RS.RenderStepped:Connect(function()pcall(function()
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
                     bv.Velocity=d*(it._spd or 80);bg.CFrame=cam.CFrame end) end)
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             pcall(function()
                 if it._bv and it._bv.Parent then it._bv:Destroy() end;it._bv=nil
                 if it._bg and it._bg.Parent then it._bg:Destroy() end;it._bg=nil
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.PlatformStand=false end end)
         end},

        {label="No Clip",icon="👻",desc="Сквозь стены",state=false,conn=nil,
         enable=function(it)
             it.conn=RS.Stepped:Connect(function()pcall(function()
                 if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do
                     if p:IsA("BasePart") then p.CanCollide=false end end end end) end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             pcall(function()if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do
                 if p:IsA("BasePart") then p.CanCollide=true end end end end)
         end},

        {label="Click TP",icon="🖱️",desc="Телепорт по ПКМ",state=false,conn=nil,
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
                             if hrp then hrp.CFrame=CFrame.new(res.Position+Vector3.new(0,3,0)) end
                         end end) end end)
         end,
         disable=function(it)if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Anti-AFK",icon="💤",desc="Защита от кика",state=false,conn=nil,
         enable=function(it)
             it.conn=LP.Idled:Connect(function()pcall(function()
                 local vu=game:GetService("VirtualUser")
                 vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                 task.wait();vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame) end) end)
         end,
         disable=function(it)if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="God Mode",icon="🛡️",desc="Бесконечное здоровье",state=false,conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()pcall(function()
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.Health=h.MaxHealth end end) end)
         end,
         disable=function(it)if it.conn then it.conn:Disconnect();it.conn=nil end end},
    }},

    -- ══ HUD ══
    {title="📊 HUD / СТАТЫ",items={

        {label="Coins HUD",icon="🪙",desc="Монеты + монеты/сек",state=false,_gui=nil,conn=nil,
         enable=function(it)pcall(function()
             local fr=New("Frame",{Size=UDim2.new(0,220,0,52),
                 Position=UDim2.new(0,8,0,8),
                 BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=150},Screen)
             Rnd(fr,10);Strk(fr,C.Gold,1.2)
             New("TextLabel",{Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,0,4),
                 Text="🪙 Монеты",TextSize=10,Font=Enum.Font.GothamBold,
                 TextColor3=C.Gold,BackgroundTransparency=1,
                 TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151},fr)
             local coinsLbl=New("TextLabel",{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,24),
                 Text="0",TextSize=11,Font=Enum.Font.GothamBold,
                 TextColor3=C.TxW,BackgroundTransparency=1,
                 TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151},fr)
             local psLbl=New("TextLabel",{Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,0,40),
                 Text="+0/сек",TextSize=9,Font=Enum.Font.Gotham,
                 TextColor3=C.TxM,BackgroundTransparency=1,
                 TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151},fr)
             it._gui=fr
             it.conn=RS.Heartbeat:Connect(function()pcall(function()
                 local c=GetCoins()
                 coinsLbl.Text=tostring(c)
                 local ps=_coinsPerSec
                 psLbl.Text=(ps>=0 and "+" or "")..tostring(ps).."/сек"
                 psLbl.TextColor3=ps>0 and C.Green or C.Red
             end) end) end)end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             if it._gui then pcall(function()it._gui:Destroy()end);it._gui=nil end end},

        {label="Stats HUD",icon="📊",desc="Полная статистика игрока",state=false,_gui=nil,conn=nil,
         enable=function(it)pcall(function()
             local fr=New("Frame",{Size=UDim2.new(0,200,0,100),
                 Position=UDim2.new(0,8,0,70),
                 BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=150},Screen)
             Rnd(fr,10);Strk(fr,C.Pink,1.2)
             New("TextLabel",{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,4),
                 Text="🐾 PS99 Stats",TextSize=10,Font=Enum.Font.GothamBold,
                 TextColor3=C.Pink,BackgroundTransparency=1,
                 TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151},fr)
             local statsLbl=New("TextLabel",{Size=UDim2.new(1,-10,0,72),Position=UDim2.new(0,5,0,24),
                 Text="Загрузка...",TextSize=9,Font=Enum.Font.Gotham,
                 TextColor3=C.TxW,BackgroundTransparency=1,
                 TextXAlignment=Enum.TextXAlignment.Left,
                 TextYAlignment=Enum.TextYAlignment.Top,
                 TextWrapped=true,ZIndex=151},fr)
             it._gui=fr
             it.conn=RS.Heartbeat:Connect(function()pcall(function()
                 local data=GetPlayerData()
                 local txt=""
                 if data then
                     for _,v in ipairs(data:GetChildren()) do
                         if v:IsA("NumberValue") or v:IsA("IntValue") then
                             txt=txt..v.Name..": "..tostring(v.Value).."\n"
                         end
                     end
                 end
                 if txt=="" then txt="Данные недоступны" end
                 statsLbl.Text=txt
             end) end) end)end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             if it._gui then pcall(function()it._gui:Destroy()end);it._gui=nil end end},

        {label="FPS Counter",icon="🖥️",desc="Счётчик FPS",state=false,_gui=nil,conn=nil,
         enable=function(it)pcall(function()
             local fr=New("Frame",{Size=UDim2.new(0,110,0,26),Position=UDim2.new(1,-120,0,8),
                 BackgroundColor3=C.BG1,BorderSizePixel=0,ZIndex=150},Screen)
             Rnd(fr,8);Strk(fr,C.Bord,1)
             local lbl=New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="FPS: --",TextSize=11,
                 Font=Enum.Font.GothamBold,TextColor3=C.TxW,BackgroundTransparency=1,
                 TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151},fr)
             it._gui=fr;local last=tick();local fr2=0
             it.conn=RS.RenderStepped:Connect(function()
                 fr2=fr2+1
                 if tick()-last>=0.5 then
                     local fps=math.floor(fr2/(tick()-last))
                     pcall(function()
                         lbl.Text="FPS: "..fps
                         lbl.TextColor3=fps>=55 and C.Green or fps>=30 and C.Gold or C.Red
                     end)
                     fr2=0;last=tick() end end) end)end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             if it._gui then pcall(function()it._gui:Destroy()end);it._gui=nil end end},

        {label="Position HUD",icon="📍",desc="XYZ позиция игрока",state=false,_gui=nil,conn=nil,
         enable=function(it)pcall(function()
             local fr=New("Frame",{Size=UDim2.new(0,200,0,26),Position=UDim2.new(1,-210,0,40),
                 BackgroundColor3=C.BG1,BorderSizePixel=0,ZIndex=150},Screen)
             Rnd(fr,8);Strk(fr,C.Bord,1)
             local lbl=New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="X:0 Y:0 Z:0",TextSize=10,
                 Font=Enum.Font.GothamMedium,TextColor3=C.TxW,BackgroundTransparency=1,
                 TextXAlignment=Enum.TextXAlignment.Center,ZIndex=151},fr)
             it._gui=fr
             it.conn=RS.Heartbeat:Connect(function()pcall(function()
                 local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                 if hrp then local p=hrp.Position
                     lbl.Text=string.format("X:%.0f Y:%.0f Z:%.0f",p.X,p.Y,p.Z) end end) end) end)end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             if it._gui then pcall(function()it._gui:Destroy()end);it._gui=nil end end},
    }},

    -- ══ УТИЛИТЫ ══
    {title="🔧 УТИЛИТЫ",items={

        {label="Print Remotes",icon="📡",desc="Все RemoteEvents в Output",state=false,
         enable=function(it) it.state=false
             pcall(function()
                 local RS2=game:GetService("ReplicatedStorage")
                 local count=0
                 print("══ PS99 REMOTES ══")
                 for _,v in ipairs(RS2:GetDescendants()) do
                     if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                         count=count+1
                         print(count..". ["..v.ClassName.."] "..v:GetFullName())
                     end
                 end
                 print("══ TOTAL: "..count.." ══")
                 Notify("Remotes",count.." найдено",C.Acc)
             end)
         end,disable=function()end},

        {label="Print Eggs",icon="🥚",desc="Список всех яиц",state=false,
         enable=function(it) it.state=false
             pcall(function()
                 local eggs=FindEggs()
                 print("══ PS99 EGGS ══")
                 for i,egg in ipairs(eggs) do
                     print(i..". "..egg.name.." @ "..tostring(egg.part.Position))
                 end
                 print("══ TOTAL: "..#eggs.." ══")
                 Notify("Eggs",#eggs.." яиц найдено",C.Pink)
             end)
         end,disable=function()end},

        {label="Rejoin",icon="🔄",desc="Реджоин",state=false,
         enable=function(it) it.state=false
             pcall(function()game:GetService("TeleportService"):Teleport(game.PlaceId,LP)end)
         end,disable=function()end},

        {label="Server Hop",icon="🌐",desc="Другой сервер",state=false,
         enable=function(it) it.state=false
             task.spawn(function()pcall(function()
                 local TPS=game:GetService("TeleportService")
                 local pid=game.PlaceId
                 local ok2,body2=HttpGet("https://games.roblox.com/v1/games/"..pid.."/servers/Public?sortOrder=Asc&limit=100")
                 if ok2 then
                     local ok3,data=pcall(function()
                         return game:GetService("HttpService"):JSONDecode(body2) end)
                     if ok3 and data and data.data then
                         for _,s in ipairs(data.data) do
                             if s.id and s.id~=game.JobId and (s.playing or 0)<(s.maxPlayers or 1) then
                                 TPS:TeleportToPlaceInstance(pid,s.id,LP);return end end end end
                 Notify("Server Hop","Нет серверов",C.Red) end) end)
         end,disable=function()end},

        {label="Copy Position",icon="📋",desc="Скопировать позицию",state=false,
         enable=function(it) it.state=false
             pcall(function()
                 local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                 if hrp then
                     local p=hrp.Position
                     local str=string.format("Vector3.new(%.2f,%.2f,%.2f)",p.X,p.Y,p.Z)
                     SafeClip(str);Notify("Position",str,C.Acc) end end)
         end,disable=function()end},

        {label="Fullbright",icon="☀️",desc="Максимальная яркость",state=false,_orig=nil,
         enable=function(it)pcall(function()
             local L=game:GetService("Lighting")
             it._orig={Brightness=L.Brightness,Ambient=L.Ambient,OutdoorAmbient=L.OutdoorAmbient}
             L.Brightness=2;L.Ambient=Color3.new(1,1,1);L.OutdoorAmbient=Color3.new(1,1,1) end)end,
         disable=function(it)pcall(function()
             if it._orig then local L=game:GetService("Lighting")
                 for k,v in pairs(it._orig) do L[k]=v end end end)end},
    }},
}

local ALL_ITEMS={}
for _,sec in ipairs(PS99_SECTIONS) do
    for _,it in ipairs(sec.items) do table.insert(ALL_ITEMS,it) end
end

-- ══════════════════════════════════════════════
-- BUILD UI
-- ══════════════════════════════════════════════
local VP=workspace.CurrentCamera.ViewportSize
local PX=math.floor((VP.X-Settings.PW)/2)
local PY=math.floor((VP.Y-Settings.PH)/2)
local Open=false
local CurTab=1

local TAB_DATA={
    {name="🥚 Farm",   sections={PS99_SECTIONS[1]}},
    {name="🐾 Pets",   sections={PS99_SECTIONS[2]}},
    {name="♻️ Rebirth",sections={PS99_SECTIONS[3]}},
    {name="🚀 Move",   sections={PS99_SECTIONS[4]}},
    {name="📊 HUD",    sections={PS99_SECTIONS[5]}},
    {name="🔧 Utils",  sections={PS99_SECTIONS[6]}},
}

panel=New("Frame",{
    Size=UDim2.new(0,Settings.PW,0,Settings.PH),
    Position=UDim2.new(0,PX,0,PY),
    BackgroundColor3=C.BG1,BorderSizePixel=0,Visible=false,
},Screen)
Rnd(panel,14);Strk(panel,C.Pink,1.5)
clip=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ClipsDescendants=true},panel)
Rnd(clip,14)

local HDR_H=54
local hdr=New("Frame",{Size=UDim2.new(1,0,0,HDR_H),BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=5},clip)
Rnd(hdr,14)
New("Frame",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=5},hdr)
New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.Sep,BorderSizePixel=0,ZIndex=6},hdr)

local logoF=New("Frame",{Size=UDim2.new(0,36,0,36),Position=UDim2.new(0,10,0.5,-18),
    BackgroundColor3=C.BG4,BorderSizePixel=0,ZIndex=6},hdr)
Rnd(logoF,10);Strk(logoF,C.Pink,1)
New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="🐾",TextSize=20,
    TextColor3=C.Pink,BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Center,ZIndex=7},logoF)

New("TextLabel",{Size=UDim2.new(0,250,0,18),Position=UDim2.new(0,54,0,7),
    Text="LUXURY HUB — PS99",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.TxW,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},hdr)
New("TextLabel",{Size=UDim2.new(0,250,0,13),Position=UDim2.new(0,55,0,27),
    Text="Pet Simulator 99 Edition",TextSize=9,Font=Enum.Font.Gotham,TextColor3=C.Pink,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},hdr)

local activeBadge=New("TextLabel",{
    Size=UDim2.new(0,62,0,20),Position=UDim2.new(0.5,-31,0.5,-10),
    BackgroundColor3=C.BG3,BorderSizePixel=0,
    Text="0 акт.",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.TxM,
    TextXAlignment=Enum.TextXAlignment.Center,ZIndex=6},hdr)
Rnd(activeBadge,8);Strk(activeBadge,C.Bord,1)

local function UpdateBadge()
    local cnt=0
    for _,it in ipairs(ALL_ITEMS) do if it.state then cnt=cnt+1 end end
    pcall(function()
        activeBadge.Text=cnt.." акт."
        activeBadge.TextColor3=cnt>0 and C.Green or C.TxM
    end)
end

local btnContainer=New("Frame",{Size=UDim2.new(0,68,0,HDR_H),Position=UDim2.new(1,-72,0,0),
    BackgroundTransparency=1,ZIndex=7},hdr)

local minBtn=New("TextButton",{Size=UDim2.new(0,26,0,26),Position=UDim2.new(0,0,0.5,-13),
    BackgroundColor3=C.BG3,BorderSizePixel=0,Text="-",TextSize=14,Font=Enum.Font.GothamBold,
    TextColor3=C.TxM,AutoButtonColor=false,ZIndex=8},btnContainer)
Rnd(minBtn,7);Strk(minBtn,C.Bord,1)
minBtn.MouseEnter:Connect(function() Tw(minBtn,{BackgroundColor3=C.BG5},0.1) end)
minBtn.MouseLeave:Connect(function() Tw(minBtn,{BackgroundColor3=C.BG3},0.1) end)
minBtn.MouseButton1Click:Connect(function() Open=false;panel.Visible=false;miniBtn.Visible=true end)

local clsBtn=New("TextButton",{Size=UDim2.new(0,26,0,26),Position=UDim2.new(0,34,0.5,-13),
    BackgroundColor3=C.BG3,BorderSizePixel=0,Text="X",TextSize=11,Font=Enum.Font.GothamBold,
    TextColor3=C.TxM,AutoButtonColor=false,ZIndex=8},btnContainer)
Rnd(clsBtn,7);Strk(clsBtn,C.Bord,1)
clsBtn.MouseEnter:Connect(function() Tw(clsBtn,{BackgroundColor3=C.Red},0.1) end)
clsBtn.MouseLeave:Connect(function() Tw(clsBtn,{BackgroundColor3=C.BG3},0.1) end)
clsBtn.MouseButton1Click:Connect(function()
    ShowConfirm("Завершить?","Все функции будут отключены.",function()
        for _,it in ipairs(ALL_ITEMS) do
            if it.state then it.state=false;pcall(it.disable,it) end
        end
        pcall(function() Screen:Destroy() end)
    end)
end)

miniBtn=New("TextButton",{
    Size=UDim2.new(0,Settings.miniSize,0,Settings.miniSize),
    Position=UDim2.new(0,12,0.5,-Settings.miniSize/2),
    BackgroundColor3=C.BG2,BorderSizePixel=0,
    Text="🐾",TextSize=18,Font=Enum.Font.GothamBold,TextColor3=C.Pink,
    Visible=false,ZIndex=20,AutoButtonColor=false},Screen)
Rnd(miniBtn,10);Strk(miniBtn,C.Pink,1.2)
miniBtn.MouseButton1Click:Connect(function() Open=true;miniBtn.Visible=false;panel.Visible=true end)

local TAB_BAR_H=34
local tabBar=New("Frame",{Size=UDim2.new(1,0,0,TAB_BAR_H),Position=UDim2.new(0,0,0,HDR_H),
    BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=4},clip)
New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.Sep,BorderSizePixel=0,ZIndex=5},tabBar)
local tabRow=New("Frame",{Size=UDim2.new(1,-14,1,-8),Position=UDim2.new(0,7,0,4),
    BackgroundTransparency=1,ZIndex=5},tabBar)
Lst(tabRow,Enum.FillDirection.Horizontal,4,Enum.HorizontalAlignment.Left)

local SCROLL_TOP=HDR_H+TAB_BAR_H
local FOOTER_H=24
scroll=New("ScrollingFrame",{
    Size=UDim2.new(1,0,1,-SCROLL_TOP-FOOTER_H),
    Position=UDim2.new(0,0,0,SCROLL_TOP),
    BackgroundTransparency=1,BorderSizePixel=0,
    ScrollBarThickness=3,ScrollBarImageColor3=C.Pink,
    CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ClipsDescendants=true,ZIndex=2},clip)
Pd(scroll,nil,6,6,10,10)
Lst(scroll,Enum.FillDirection.Vertical,5)

local ftr=New("Frame",{Size=UDim2.new(1,0,0,FOOTER_H),Position=UDim2.new(0,0,1,-FOOTER_H),
    BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=4},clip)
New("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,0),BackgroundColor3=C.Sep,BorderSizePixel=0,ZIndex=5},ftr)
local fTabName=New("TextLabel",{Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,12,0,0),
    Text="Farm",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.Pink,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},ftr)
New("TextLabel",{Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0.5,-12,0,0),
    Text="RShift = скрыть/показать",TextSize=9,Font=Enum.Font.Gotham,TextColor3=C.TxF,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=5},ftr)

local tabPills={}
local function RefreshContent()
    for _,c in ipairs(scroll:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then pcall(function()c:Destroy()end) end
    end
    local td=TAB_DATA[CurTab]
    pcall(function()fTabName.Text=td.name end)
    for _,sec in ipairs(td.sections) do
        SecLbl(scroll,sec.title)
        for _,item in ipairs(sec.items) do MakeCard(scroll,item) end
    end
end

local function BuildTabs()
    for _,p in ipairs(tabPills) do pcall(function()p:Destroy()end) end
    tabPills={}
    for i,td in ipairs(TAB_DATA) do
        local act=(CurTab==i)
        local pill=New("TextButton",{
            Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,
            BackgroundColor3=act and C.BG4 or C.BG2,BorderSizePixel=0,
            Text="  "..td.name.."  ",TextSize=10,
            Font=act and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextColor3=act and C.Pink or C.TxL,
            AutoButtonColor=false,ZIndex=6},tabRow)
        if not pill then continue end
        Rnd(pill,8)
        if act then Strk(pill,C.Pink,1) end
        pill.MouseEnter:Connect(function()
            if not act then Tw(pill,{BackgroundColor3=C.BG3},0.1) end end)
        pill.MouseLeave:Connect(function()
            if not act then Tw(pill,{BackgroundColor3=C.BG2},0.1) end end)
        pill.MouseButton1Click:Connect(function() CurTab=i;BuildTabs();RefreshContent() end)
        table.insert(tabPills,pill)
    end
end

-- DRAG
local drag=false;local dragS;local dragP
hdr.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=true;dragS=i.Position;dragP=panel.Position end end)
UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        pcall(function()
            local d=i.Position-dragS
            panel.Position=UDim2.new(dragP.X.Scale,dragP.X.Offset+d.X,dragP.Y.Scale,dragP.Y.Offset+d.Y) end) end end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)

UIS.InputBegan:Connect(function(i,gpe)
    if gpe then return end
    if i.KeyCode==Enum.KeyCode.RightShift then
        if Open then Open=false;panel.Visible=false;miniBtn.Visible=true
        else Open=true;miniBtn.Visible=false;panel.Visible=true end
    end
end)

task.spawn(function()
    while Screen and Screen.Parent do task.wait(1);pcall(UpdateBadge) end
end)

LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    for _,it in ipairs(ALL_ITEMS) do if it.state then pcall(it.enable,it) end end
end)

BuildTabs()
RefreshContent()
UpdateBadge()

ShowPreloader(function()
    ShowKeyScreen(function()
        Open=true
        panel.Visible=true
        Notify("LUXURY HUB — PS99","🐾 "..#ALL_ITEMS.." функций загружено!",C.Pink)
    end)
end)

print("LUXURY HUB PS99 loaded | "..#ALL_ITEMS.." items")