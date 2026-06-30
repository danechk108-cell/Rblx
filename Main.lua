-- LUXURY HUB v23 - Car Dealership Tycoon
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

-- COLORS
local C = {
    BG0=Color3.fromRGB(6,6,8),
    BG1=Color3.fromRGB(10,11,14),
    BG2=Color3.fromRGB(15,16,20),
    BG3=Color3.fromRGB(20,21,27),
    BG4=Color3.fromRGB(25,27,34),
    SB0=Color3.fromRGB(8,9,12),
    SB1=Color3.fromRGB(16,17,22),
    SB2=Color3.fromRGB(22,24,30),
    Acc=Color3.fromRGB(220,180,80),
    Acc3=Color3.fromRGB(100,78,22),
    AccLine=Color3.fromRGB(90,72,25),
    AccSoft=Color3.fromRGB(55,44,14),
    TxW=Color3.fromRGB(240,240,235),
    TxH=Color3.fromRGB(190,190,182),
    TxM=Color3.fromRGB(120,122,115),
    TxL=Color3.fromRGB(65,67,62),
    TxF=Color3.fromRGB(35,37,33),
    Bord=Color3.fromRGB(28,30,36),
    BordA=Color3.fromRGB(180,145,55),
    BordH=Color3.fromRGB(50,52,62),
    Sep=Color3.fromRGB(20,22,28),
    Green=Color3.fromRGB(80,200,100),
    Red=Color3.fromRGB(210,70,70),
    White=Color3.fromRGB(255,255,255),
    SlTrack=Color3.fromRGB(18,20,26),
}

-- ══════════════════════════════════════════════
-- SETTINGS
-- ══════════════════════════════════════════════
local Settings = {
    PW = 660, PH = 580,
    miniSize = 52,
    miniSide = "left",
    miniYPct = 0.5,
    miniShape = "round",
    accent = "gold",
    animSpeed = 0.22,
}

local AccentMap = {
    gold  = {Color3.fromRGB(220,180,80),  Color3.fromRGB(55,44,14),  Color3.fromRGB(90,72,25)},
    blue  = {Color3.fromRGB(80,150,240),  Color3.fromRGB(15,38,75),  Color3.fromRGB(40,80,155)},
    green = {Color3.fromRGB(80,210,110),  Color3.fromRGB(15,52,24),  Color3.fromRGB(40,120,58)},
    red   = {Color3.fromRGB(220,80,80),   Color3.fromRGB(58,14,14),  Color3.fromRGB(140,38,38)},
}

local function ApplyAccent(key)
    local p = AccentMap[key] or AccentMap.gold
    C.Acc=p[1]; C.AccSoft=p[2]; C.AccLine=p[3]
    C.BordA=p[1]; Settings.accent=key
end

-- ══════════════════════════════════════════════
-- UTILS
-- ══════════════════════════════════════════════
local function New(cls, props, parent)
    local i = Instance.new(cls)
    for k,v in pairs(props or {}) do i[k]=v end
    if parent then i.Parent=parent end
    return i
end

local function Tw(inst, props, t)
    if not inst or not inst.Parent then return end
    TW:Create(inst, TweenInfo.new(t or Settings.animSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function Rnd(inst, r)
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 12); c.Parent=inst; return c
end

local function Strk(inst, col, th)
    local s=Instance.new("UIStroke"); s.Color=col or C.Bord; s.Thickness=th or 1.5
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=inst; return s
end

local function Pd(inst, a, t, b, l, r)
    local p=Instance.new("UIPadding")
    if a then p.PaddingTop=UDim.new(0,a);p.PaddingBottom=UDim.new(0,a);p.PaddingLeft=UDim.new(0,a);p.PaddingRight=UDim.new(0,a)
    else
        if t then p.PaddingTop=UDim.new(0,t) end
        if b then p.PaddingBottom=UDim.new(0,b) end
        if l then p.PaddingLeft=UDim.new(0,l) end
        if r then p.PaddingRight=UDim.new(0,r) end
    end
    p.Parent=inst; return p
end

local function Lst(inst, dir, pad, ha)
    local l=Instance.new("UIListLayout")
    l.FillDirection=dir or Enum.FillDirection.Vertical
    l.Padding=UDim.new(0,pad or 6)
    l.HorizontalAlignment=ha or Enum.HorizontalAlignment.Left
    l.SortOrder=Enum.SortOrder.LayoutOrder
    l.Parent=inst; return l
end

local notifY = -80
local function Notify(title, msg, col)
    local n=New("Frame",{
        Size=UDim2.new(0,290,0,64),
        Position=UDim2.new(1,10,1,notifY),
        BackgroundColor3=C.BG2,BorderSizePixel=0,ZIndex=200
    },Screen)
    Rnd(n,12); Strk(n,col or C.Acc,1.5)
    New("Frame",{Size=UDim2.new(0,3,1,0),BackgroundColor3=col or C.Acc,BorderSizePixel=0,ZIndex=201},n)
    New("TextLabel",{Size=UDim2.new(1,-14,0,22),Position=UDim2.new(0,10,0,5),
        Text=title,TextSize=13,Font=Enum.Font.GothamBold,
        TextColor3=col or C.Acc,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},n)
    New("TextLabel",{Size=UDim2.new(1,-14,0,18),Position=UDim2.new(0,10,0,28),
        Text=msg,TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},n)
    Tw(n,{Position=UDim2.new(1,-302,1,notifY)},0.3)
    task.delay(3.5,function()
        Tw(n,{Position=UDim2.new(1,10,1,notifY)},0.3)
        task.delay(0.35,function() pcall(function() n:Destroy() end) end)
    end)
end

-- ══════════════════════════════════════════════
-- AUTO-DRIVE
-- ══════════════════════════════════════════════
local AD = {active=false,conn=nil,road=nil,speed=80,currentCar=nil,startPos=nil}

local function FindCar()
    local char=LP.Character; if not char then return nil,nil end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return nil,nil end
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") and v.Occupant==hum then
            return v.Parent,v
        end
    end
    return nil,nil
end

local function InCar() local c,s=FindCar(); return c~=nil,c,s end

local function BuildRoad(origin)
    if AD.road then AD.road:Destroy() end
    local model=Instance.new("Model")
    model.Name="_LHubRoad"
    model.Parent=workspace
    AD.road=model

    local ry=origin.Y+900
    AD.startPos=Vector3.new(origin.X, ry, origin.Z)

    local totalLen=10000
    local segLen=60
    local segs=math.ceil(totalLen/segLen)

    for i=0,segs do
        local p=Instance.new("Part")
        p.Size=Vector3.new(22,1,segLen)
        p.CFrame=CFrame.new(origin.X, ry, origin.Z+i*segLen)
        p.Anchored=true; p.CanCollide=true
        p.Material=Enum.Material.SmoothPlastic
        p.BrickColor=BrickColor.new("Dark grey metallic")
        p.CastShadow=false; p.Parent=model

        -- center line
        if i%2==0 then
            local m=Instance.new("Part")
            m.Size=Vector3.new(0.6,0.12,segLen*0.65)
            m.CFrame=CFrame.new(origin.X,ry+0.55,origin.Z+i*segLen)
            m.Anchored=true; m.CanCollide=false
            m.Material=Enum.Material.SmoothPlastic
            m.BrickColor=BrickColor.new("Bright yellow")
            m.CastShadow=false; m.Parent=model
        end
    end

    -- finish neon
    local fin=Instance.new("Part")
    fin.Size=Vector3.new(22,3,2)
    fin.CFrame=CFrame.new(origin.X,ry+1,origin.Z+totalLen-15)
    fin.Anchored=true; fin.CanCollide=false
    fin.Material=Enum.Material.Neon
    fin.BrickColor=BrickColor.new("Bright red")
    fin.Transparency=0.3; fin.CastShadow=false
    fin.Name="Finish"; fin.Parent=model

    return totalLen
end

local function TeleportCar(car)
    local pp=car.PrimaryPart
    if not pp then
        -- try to find main body
        for _,p in ipairs(car:GetChildren()) do
            if p:IsA("BasePart") and not p:IsA("UnionOperation") then
                pp=p; break
            end
        end
    end
    if not pp then return false end
    pcall(function()
        car:SetPrimaryPartCFrame(
            CFrame.new(AD.startPos.X, AD.startPos.Y+3, AD.startPos.Z+8)
        )
    end)
    return true
end

local function StopAD()
    AD.active=false
    if AD.conn then AD.conn:Disconnect(); AD.conn=nil end
    if AD.currentCar then
        local pp=AD.currentCar.PrimaryPart or AD.currentCar:FindFirstChildOfClass("BasePart")
        if pp then
            local v=pp:FindFirstChild("_LHubVel"); if v then v:Destroy() end
            local g=pp:FindFirstChild("_LHubGyro"); if g then g:Destroy() end
        end
    end
    if AD.road then AD.road:Destroy(); AD.road=nil end
    AD.currentCar=nil; AD.startPos=nil
end

local function StartAD(car)
    AD.active=true; AD.currentCar=car
    local lap=0
    local totalLen=10000

    -- ensure BodyVelocity on primary
    local pp=car.PrimaryPart or car:FindFirstChildOfClass("BasePart")
    if not pp then StopAD(); return end

    local bv=pp:FindFirstChild("_LHubVel")
    if not bv then
        bv=Instance.new("BodyVelocity"); bv.Name="_LHubVel"
        bv.MaxForce=Vector3.new(0,0,1e7)
        bv.Velocity=Vector3.new(0,0,AD.speed)
        bv.Parent=pp
    end

    local bg=pp:FindFirstChild("_LHubGyro")
    if not bg then
        bg=Instance.new("BodyGyro"); bg.Name="_LHubGyro"
        bg.MaxTorque=Vector3.new(4e5,4e5,4e5)
        bg.D=1000; bg.P=10000
        bg.CFrame=CFrame.new(pp.Position)*CFrame.Angles(0,0,0)
        bg.Parent=pp
    end

    AD.conn=RS.Heartbeat:Connect(function(dt)
        if not AD.active then return end

        -- check still in car
        local ok,_,_=InCar()
        if not ok then
            StopAD()
            Notify("Auto-Drive","Остановлен — вышел из машины",C.Red)
            return
        end

        local p2=car.PrimaryPart or car:FindFirstChildOfClass("BasePart")
        if not p2 then return end

        local endZ=AD.startPos.Z+totalLen-30
        local carZ=p2.Position.Z

        if carZ>=endZ then
            lap=lap+1
            Notify("Auto-Drive","Круг "..lap.."! Телепорт назад...",C.Acc)
            -- stop velocity temporarily
            bv.Velocity=Vector3.new(0,0,0)
            task.wait(0.1)
            pcall(function()
                car:SetPrimaryPartCFrame(
                    CFrame.new(AD.startPos.X, AD.startPos.Y+3, AD.startPos.Z+8)
                )
            end)
            task.wait(0.3)
            bv.Velocity=Vector3.new(0,0,AD.speed)
            return
        end

        -- keep driving
        bv.Velocity=Vector3.new(0,0,AD.speed)
        -- keep car upright facing +Z
        bg.CFrame=CFrame.new(p2.Position)*CFrame.Angles(0,0,0)
    end)
end

local function TryStartAD()
    local ok,car,seat=InCar()
    if not ok then
        Notify("Auto-Drive","❌ Сначала сядь в машину!",C.Red)
        return false
    end

    local char=LP.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    Notify("Auto-Drive","Строю дорогу высоко над картой...",C.Acc)
    local totalLen=BuildRoad(hrp.Position)
    task.wait(0.5)

    local ok2=TeleportCar(car)
    if not ok2 then
        Notify("Auto-Drive","Не удалось найти PrimaryPart машины",C.Red)
        if AD.road then AD.road:Destroy(); AD.road=nil end
        return false
    end
    task.wait(0.5)

    StartAD(car)
    Notify("Auto-Drive","✓ Запущен! Скорость: "..AD.speed.." u/s",C.Green)
    return true
end

-- ══════════════════════════════════════════════
-- TABS
-- ══════════════════════════════════════════════
local TABS={
    {name="Заработок",icon="💰",col=Color3.fromRGB(220,180,80),items={
        {label="Auto-Drive",desc="Авто-езда на бесконечной дороге",
         state=false,isAD=true,
         param={label="Скорость езды",min=20,max=300,step=5,val=80,
          fmt=function(v) return math.floor(v).." u/s" end,
          apply=function(v)
              AD.speed=v
              if AD.active and AD.currentCar then
                  local pp=AD.currentCar.PrimaryPart or AD.currentCar:FindFirstChildOfClass("BasePart")
                  if pp then
                      local bv=pp:FindFirstChild("_LHubVel")
                      if bv then bv.Velocity=Vector3.new(0,0,v) end
                  end
              end
          end},
         enable=function(it)
             AD.speed=it.param.val
             return TryStartAD()
         end,
         disable=function() StopAD() end},

        {label="Anti-AFK",desc="Предотвращает кик за AFK",
         state=false,conn=nil,
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

        {label="Slot 3",desc="Пусто",state=false,enable=function()end,disable=function()end},
        {label="Slot 4",desc="Пусто",state=false,enable=function()end,disable=function()end},
        {label="Slot 5",desc="Пусто",state=false,enable=function()end,disable=function()end},
    }},

    {name="Траты",icon="🏗️",col=Color3.fromRGB(80,150,240),items={
        {label="Auto-Build",desc="Авто-постройка тайкуна",
         state=false,conn=nil,
         param={label="Задержка клика",min=0.05,max=3,step=0.05,val=0.2,
          fmt=function(v) return string.format("%.2fs",v) end,
          apply=function(v,it) it._delay=v end},
         _delay=0.2,
         enable=function(it)
             it._delay=it.param.val
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local char=LP.Character; if not char then return end
                     local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                     for _,v in ipairs(workspace:GetDescendants()) do
                         if v:IsA("BasePart") then
                             local n=v.Name:lower()
                             if n:find("buy") or n:find("button") or n:find("purchase") then
                                 if (hrp.Position-v.Position).Magnitude<30 then
                                     pcall(function() v.Touched:Fire(hrp) end)
                                 end
                             end
                         end
                     end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Tycoon: Стандарт",desc="Выбрать стандартный тайкун",
         state=false,
         enable=function() Notify("Траты","Вариант: Стандарт",C.Acc) end,
         disable=function() end},

        {label="Tycoon: Люкс",desc="Выбрать люкс тайкун",
         state=false,
         enable=function() Notify("Траты","Вариант: Люкс",C.Acc) end,
         disable=function() end},

        {label="Tycoon: Мега",desc="Выбрать мега тайкун",
         state=false,
         enable=function() Notify("Траты","Вариант: Мега",C.Acc) end,
         disable=function() end},

        {label="Slot 5",desc="Пусто",state=false,enable=function()end,disable=function()end},
    }},

    {name="Player",icon="👤",col=Color3.fromRGB(160,100,255),items={
        {label="Speed Boost",desc="Ускорение ходьбы",state=false,
         param={label="Множитель скорости",min=1,max=15,step=0.5,val=2.5,
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

        {label="High Jump",desc="Высокий прыжок",state=false,
         param={label="Сила прыжка",min=50,max=500,step=10,val=150,
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

        {label="Infinite Jump",desc="Прыжок в воздухе",state=false,conn=nil,
         enable=function(it)
             it.conn=UIS.JumpRequest:Connect(function()
                 pcall(function()
                     local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                     if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Fly",desc="Полёт WASD + Пробел",state=false,conn=nil,_bv=nil,_bg=nil,_spd=60,
         param={label="Скорость полёта",min=10,max=300,step=5,val=60,
          fmt=function(v) return math.floor(v).." u/s" end,
          apply=function(v,it) if it then it._spd=v end end},
         enable=function(it)
             it._spd=it.param.val
             pcall(function()
                 local ch=LP.Character; if not ch then return end
                 local root=ch:FindFirstChild("HumanoidRootPart"); if not root then return end
                 local hum=ch:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand=true end
                 local bv=Instance.new("BodyVelocity"); bv.Velocity=Vector3.new(0,0,0)
                 bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Parent=root; it._bv=bv
                 local bg=Instance.new("BodyGyro"); bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
                 bg.D=100; bg.Parent=root; it._bg=bg
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

        {label="God Mode",desc="Бесконечное здоровье",state=false,conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                     if h then h.Health=h.MaxHealth end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="No Clip",desc="Проходить сквозь стены",state=false,conn=nil,
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

        {label="Low Gravity",desc="Низкая гравитация",state=false,
         param={label="Гравитация",min=2,max=196,step=5,val=20,
          fmt=function(v) return math.floor(v).." g" end,
          apply=function(v) pcall(function() workspace.Gravity=v end) end},
         enable=function(it) pcall(function() workspace.Gravity=it.param.val end) end,
         disable=function() pcall(function() workspace.Gravity=196.2 end) end},

        {label="Invisible",desc="Скрыть персонажа",state=false,
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
    }},

    {name="Other",icon="⚙️",col=Color3.fromRGB(130,130,130),items={}},
}

-- ══════════════════════════════════════════════
-- SLIDER
-- ══════════════════════════════════════════════
local function MakeSlider(parent, opts)
    local mn=opts.min or 0; local mx=opts.max or 100
    local st=opts.step or 1; local val=opts.val or mn
    local fmt=opts.fmt or tostring

    local cont=New("Frame",{Size=UDim2.new(1,0,0,52),BackgroundTransparency=1},parent)

    local hdr=New("Frame",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1},cont)
    New("TextLabel",{Size=UDim2.new(1,-64,1,0),Text=opts.label or "",TextSize=10,
        Font=Enum.Font.GothamMedium,TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left},hdr)
    local valLbl=New("TextLabel",{Size=UDim2.new(0,62,1,0),Position=UDim2.new(1,-62,0,0),
        Text=fmt(val),TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.Acc,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right},hdr)

    local track=New("Frame",{Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,0,24),
        BackgroundColor3=C.SlTrack,BorderSizePixel=0},cont)
    Rnd(track,4)

    local fill=New("Frame",{
        Size=UDim2.new(math.max(0,math.min(1,(val-mn)/(mx-mn))),0,1,0),
        BackgroundColor3=C.Acc,BorderSizePixel=0},track)
    Rnd(fill,4)

    local knob=New("Frame",{Size=UDim2.new(0,20,0,20),
        Position=UDim2.new(0,-10,0.5,-10),
        BackgroundColor3=C.Acc,BorderSizePixel=0,ZIndex=6},fill)
    Rnd(knob,10)
    local ki=New("Frame",{Size=UDim2.new(0,9,0,9),Position=UDim2.new(0.5,-4.5,0.5,-4.5),
        BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=7},knob)
    Rnd(ki,5)

    local dragging=false

    local function Update(x)
        local abs=track.AbsolutePosition.X
        local sz=track.AbsoluteSize.X
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

    local hit=New("TextButton",{Size=UDim2.new(1,0,0,34),Position=UDim2.new(0,0,0,16),
        BackgroundTransparency=1,Text="",ZIndex=9},cont)

    hit.MouseButton1Down:Connect(function(x,_) dragging=true; Update(x) end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then Update(i.Position.X) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)

    return cont,{Get=function() return val end, Set=function(v) Update(track.AbsolutePosition.X+(v-mn)/(mx-mn)*track.AbsoluteSize.X) end}
end

-- ══════════════════════════════════════════════
-- TOGGLE
-- ══════════════════════════════════════════════
local function MakeToggle(parent, init, onChange)
    local W,H=52,28
    local cont=New("Frame",{Size=UDim2.new(0,W,0,H),BackgroundTransparency=1},parent)
    local track=New("Frame",{Size=UDim2.new(1,0,1,0),
        BackgroundColor3=init and C.Acc or C.SlTrack,BorderSizePixel=0},cont)
    Rnd(track,H/2)
    local knob=New("Frame",{
        Size=UDim2.new(0,H-8,0,H-8),
        Position=init and UDim2.new(1,-(H-4),0.5,-(H-8)/2) or UDim2.new(0,4,0.5,-(H-8)/2),
        BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=3},track)
    Rnd(knob,(H-8)/2)
    local on=init or false
    local function Set(s,anim)
        on=s
        if anim then
            Tw(track,{BackgroundColor3=on and C.Acc or C.SlTrack},0.18)
            Tw(knob,{Position=on and UDim2.new(1,-(H-4),0.5,-(H-8)/2) or UDim2.new(0,4,0.5,-(H-8)/2)},0.18)
        else
            track.BackgroundColor3=on and C.Acc or C.SlTrack
            knob.Position=on and UDim2.new(1,-(H-4),0.5,-(H-8)/2) or UDim2.new(0,4,0.5,-(H-8)/2)
        end
    end
    local btn=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=10},cont)
    btn.MouseButton1Click:Connect(function() Set(not on,true); if onChange then onChange(on) end end)
    return cont,{Set=Set,Get=function() return on end}
end

-- ══════════════════════════════════════════════
-- CARD
-- ══════════════════════════════════════════════
local function MakeCard(parent, item, tCol)
    local tc=tCol or C.Acc
    local baseH=58
    local expandH=baseH+76

    local wrap=New("Frame",{Size=UDim2.new(1,0,0,baseH),BackgroundTransparency=1,ClipsDescendants=false},parent)

    local card=New("Frame",{Size=UDim2.new(1,0,1,0),
        BackgroundColor3=item.state and C.BG4 or C.BG2,
        BorderSizePixel=0,ClipsDescendants=true},wrap)
    Rnd(card,16)
    local strk=Strk(card,item.state and tc or C.Bord,1)

    local bar=New("Frame",{Size=UDim2.new(0,3,0,30),Position=UDim2.new(0,10,0.5,-15),
        BackgroundColor3=tc,BorderSizePixel=0,Visible=item.state},card)
    Rnd(bar,2)

    local lbl=New("TextLabel",{Size=UDim2.new(1,-80,0,20),Position=UDim2.new(0,24,0,9),
        Text=item.label,TextSize=14,Font=Enum.Font.GothamMedium,
        TextColor3=item.state and C.TxW or C.TxH,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left},card)

    local dsc=New("TextLabel",{Size=UDim2.new(1,-80,0,14),Position=UDim2.new(0,24,0,30),
        Text=item.desc,TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=item.state and C.TxM or C.TxL,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left},card)

    -- PARAM PANEL
    local paramPanel=nil
    if item.param then
        paramPanel=New("Frame",{
            Size=UDim2.new(1,-8,0,0),
            Position=UDim2.new(0,4,1,4),
            BackgroundColor3=C.BG0,
            BorderSizePixel=0,ClipsDescendants=true,Visible=false},wrap)
        Rnd(paramPanel,14)
        Strk(paramPanel,tc,1)
        local inner=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},paramPanel)
        Pd(inner,nil,8,6,12,12)
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
        if anim then Tw(card,{BackgroundColor3=s and C.BG4 or C.BG2},0.18)
        else card.BackgroundColor3=s and C.BG4 or C.BG2 end
        strk.Color=s and tc or C.Bord
        bar.Visible=s
        lbl.TextColor3=s and C.TxW or C.TxH
        dsc.TextColor3=s and C.TxM or C.TxL

        if paramPanel then
            if s then
                paramPanel.Visible=true
                Tw(paramPanel,{Size=UDim2.new(1,-8,0,70)},0.22)
                Tw(wrap,{Size=UDim2.new(1,0,0,expandH)},0.22)
            else
                Tw(paramPanel,{Size=UDim2.new(1,-8,0,0)},0.18)
                Tw(wrap,{Size=UDim2.new(1,0,0,baseH)},0.18)
                task.delay(0.2,function()
                    if not item.state then paramPanel.Visible=false end
                end)
            end
        end
    end

    local tgC,tgCtrl=MakeToggle(card,item.state,nil)
    tgC.Position=UDim2.new(1,-66,0.5,-14); tgC.ZIndex=5

    local function DoToggle()
        local ns=not item.state
        if ns and item.isAD then
            local ok=InCar()
            if not ok then Notify("Auto-Drive","❌ Сначала сядь в машину!",C.Red); return end
        end
        item.state=ns
        tgCtrl.Set(ns,true)
        ApplyState(ns,true)
        if ns then
            local r=true
            pcall(function() r=item.enable(item) end)
            if r==false then
                item.state=false; tgCtrl.Set(false,true); ApplyState(false,true)
            end
        else
            pcall(item.disable,item)
        end
    end

    local hit=New("TextButton",{Size=UDim2.new(1,0,0,baseH),BackgroundTransparency=1,Text="",ZIndex=8},card)
    hit.MouseButton1Click:Connect(DoToggle)

    card.MouseEnter:Connect(function()
        if not item.state then Tw(card,{BackgroundColor3=C.BG3},0.12); strk.Color=C.BordH end
    end)
    card.MouseLeave:Connect(function()
        if not item.state then Tw(card,{BackgroundColor3=C.BG2},0.12); strk.Color=C.Bord end
    end)

    if item.state then ApplyState(true,false) end
    return wrap
end

-- ══════════════════════════════════════════════
-- OPTION SELECTOR
-- ══════════════════════════════════════════════
local function MakeOptions(parent, lbl, opts, cur, onChange)
    local f=New("Frame",{Size=UDim2.new(1,0,0,58),BackgroundTransparency=1},parent)
    New("TextLabel",{Size=UDim2.new(1,0,0,16),Text=lbl,TextSize=10,
        Font=Enum.Font.GothamMedium,TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left},f)
    local row=New("Frame",{Size=UDim2.new(1,0,0,34),Position=UDim2.new(0,0,0,20),
        BackgroundTransparency=1},f)
    Lst(row,Enum.FillDirection.Horizontal,6,Enum.HorizontalAlignment.Left)

    local btns={}
    local function Refresh(sel)
        for _,b in ipairs(btns) do
            local s=(b.Name==tostring(sel))
            Tw(b,{BackgroundColor3=s and C.BG4 or C.BG2},0.15)
            b.TextColor3=s and C.Acc or C.TxM
            if b:FindFirstChildOfClass("UIStroke") then
                b:FindFirstChildOfClass("UIStroke").Color=s and C.Acc or C.Bord
            end
        end
    end

    for _,opt in ipairs(opts) do
        local b=New("TextButton",{
            Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,
            BackgroundColor3=(cur==opt) and C.BG4 or C.BG2,BorderSizePixel=0,
            Text="  "..tostring(opt).."  ",TextSize=11,
            Font=Enum.Font.GothamMedium,TextColor3=(cur==opt) and C.Acc or C.TxM,
            AutoButtonColor=false,Name=tostring(opt),
        },row)
        Rnd(b,10); Strk(b,(cur==opt) and C.Acc or C.Bord,1)
        table.insert(btns,b)
        b.MouseButton1Click:Connect(function()
            cur=opt; Refresh(opt); if onChange then onChange(opt) end
        end)
    end
    return f
end

-- Color picker
local function MakeColorPicker(parent, onChange)
    local f=New("Frame",{Size=UDim2.new(1,0,0,52),BackgroundTransparency=1},parent)
    New("TextLabel",{Size=UDim2.new(1,0,0,16),Text="Цвет акцента",TextSize=10,
        Font=Enum.Font.GothamMedium,TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left},f)
    local row=New("Frame",{Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,0,20),
        BackgroundTransparency=1},f)
    Lst(row,Enum.FillDirection.Horizontal,8,Enum.HorizontalAlignment.Left)

    local palette={
        {k="gold",c=Color3.fromRGB(220,180,80),l="Gold"},
        {k="blue",c=Color3.fromRGB(80,150,240),l="Blue"},
        {k="green",c=Color3.fromRGB(80,210,110),l="Green"},
        {k="red",c=Color3.fromRGB(220,80,80),l="Red"},
    }
    local dotBtns={}
    for _,p in ipairs(palette) do
        local b=New("TextButton",{Size=UDim2.new(0,32,0,32),
            BackgroundColor3=p.c,BorderSizePixel=0,Text="",AutoButtonColor=false},row)
        Rnd(b,16)
        if Settings.accent==p.k then Strk(b,C.White,2.5) end
        table.insert(dotBtns,{btn=b,key=p.k})
        b.MouseButton1Click:Connect(function()
            ApplyAccent(p.k)
            for _,d in ipairs(dotBtns) do
                if d.btn:FindFirstChildOfClass("UIStroke") then
                    d.btn:FindFirstChildOfClass("UIStroke"):Destroy()
                end
            end
            Strk(b,C.White,2.5)
            if onChange then onChange(p.k) end
        end)
    end
    return f
end

-- Section label
local function SecLbl(parent, txt)
    local f=New("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1},parent)
    New("TextLabel",{Size=UDim2.new(1,0,1,0),Text=txt,TextSize=9,
        Font=Enum.Font.GothamBold,TextColor3=C.TxL,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left},f)
    New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=C.Sep,BorderSizePixel=0},f)
    return f
end

-- Settings card wrapper
local function SettCard(parent, h)
    local f=New("Frame",{Size=UDim2.new(1,0,0,h or 80),BackgroundColor3=C.BG2,BorderSizePixel=0},parent)
    Rnd(f,14); Strk(f,C.Bord,1)
    local inner=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},f)
    Pd(inner,nil,10,10,14,14)
    Lst(inner,Enum.FillDirection.Vertical,8)
    return f,inner
end

-- ══════════════════════════════════════════════
-- LAYOUT
-- ══════════════════════════════════════════════
local VP=workspace.CurrentCamera.ViewportSize
local PX=math.floor((VP.X-Settings.PW)/2)
local PY=math.floor((VP.Y-Settings.PH)/2)
local Open=true; local CurTab=1

-- References that need updating
local accentBarRef=nil
local panelRef=nil
local sidebarRef=nil

-- MINI BUTTON
local miniBtn=New("TextButton",{
    Size=UDim2.new(0,Settings.miniSize,0,Settings.miniSize),
    Position=UDim2.new(0,12,Settings.miniYPct,-Settings.miniSize/2),
    BackgroundColor3=C.SB0,BorderSizePixel=0,
    Text="LZ",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.Acc,
    Visible=false,ZIndex=20,AutoButtonColor=false,
},Screen)
Rnd(miniBtn,Settings.miniSize/2)
Strk(miniBtn,C.AccLine,1.5)

-- SIDEBAR
local sidebar=New("Frame",{
    Size=UDim2.new(0,66,0,10),Position=UDim2.new(0,PX-82,0,PY),
    BackgroundColor3=C.SB0,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,
},Screen)
Rnd(sidebar,26); Strk(sidebar,C.Bord,1.5)
sidebarRef=sidebar

local sideInner=New("Frame",{Size=UDim2.new(1,0,0,10),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y},sidebar)
Pd(sideInner,10); Lst(sideInner,Enum.FillDirection.Vertical,8,Enum.HorizontalAlignment.Center)

New("TextLabel",{Size=UDim2.new(1,0,0,12),Text="LZ",TextSize=9,
    Font=Enum.Font.GothamBold,TextColor3=C.TxL,BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Center,LayoutOrder=0},sideInner)

local navBtns={}

local function SyncSidebar()
    if not panelRef or not panelRef.Parent then return end
    local px=panelRef.AbsolutePosition.X
    local py=panelRef.AbsolutePosition.Y
    local ph=panelRef.AbsoluteSize.Y
    local sh=sidebar.AbsoluteSize.Y
    sidebar.Position=UDim2.new(0,px-82,0,py+math.floor((ph-sh)/2))
end

local function BuildNav()
    for _,b in ipairs(navBtns) do b:Destroy() end
    navBtns={}
    local icons={"💰","🏗️","👤","⚙️"}
    for i=1,4 do
        local act=(CurTab==i)
        local tc=TABS[i].col or C.Acc
        local nb=New("TextButton",{
            Size=UDim2.new(0,46,0,46),
            BackgroundColor3=act and C.SB2 or C.SB0,
            BorderSizePixel=0,Text="",AutoButtonColor=false,LayoutOrder=i,
        },sideInner)
        Rnd(nb,15)
        if act then Strk(nb,tc,1.5) end
        New("TextLabel",{Size=UDim2.new(1,0,1,0),Text=icons[i],TextSize=20,
            Font=Enum.Font.GothamBold,TextColor3=act and tc or C.TxL,
            BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center},nb)
        if act then
            local dot=New("Frame",{Size=UDim2.new(0,5,0,5),Position=UDim2.new(1,-2,0.5,-2.5),
                BackgroundColor3=tc,BorderSizePixel=0},nb)
            Rnd(dot,3)
        end
        nb.MouseEnter:Connect(function() if not act then Tw(nb,{BackgroundColor3=C.SB1},0.12) end end)
        nb.MouseLeave:Connect(function() if not act then Tw(nb,{BackgroundColor3=C.SB0},0.12) end end)
        nb.MouseButton1Click:Connect(function() CurTab=i; BuildNav(); RefreshContent() end)
        table.insert(navBtns,nb)
    end
end

-- PANEL
local panel=New("Frame",{
    Size=UDim2.new(0,Settings.PW,0,Settings.PH),
    Position=UDim2.new(0,PX,0,PY),
    BackgroundColor3=C.BG1,BorderSizePixel=0,
},Screen)
Rnd(panel,22); Strk(panel,C.Bord,1.5)
panelRef=panel

local clip=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ClipsDescendants=true},panel)
Rnd(clip,22)

-- HEADER
local hdr=New("Frame",{Size=UDim2.new(1,0,0,66),BackgroundColor3=C.BG2,BorderSizePixel=0},clip)
Rnd(hdr,22)
New("Frame",{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,1,-22),BackgroundColor3=C.BG2,BorderSizePixel=0},hdr)
accentBarRef=New("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=C.Acc,BorderSizePixel=0},hdr)

-- Logo (just LZ text, no image)
local logoFrame=New("Frame",{Size=UDim2.new(0,42,0,42),Position=UDim2.new(0,14,0.5,-21),
    BackgroundColor3=C.Acc3,BorderSizePixel=0},hdr)
Rnd(logoFrame,21); Strk(logoFrame,C.AccLine,1.5)
New("Frame",{Size=UDim2.new(0,34,0,34),Position=UDim2.new(0.5,-17,0.5,-17),
    BackgroundColor3=C.AccSoft,BorderSizePixel=0},logoFrame)
Rnd(logoFrame:FindFirstChildOfClass("Frame"),17)
New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="LZ",TextSize=14,Font=Enum.Font.GothamBold,
    TextColor3=C.Acc,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center},logoFrame)

-- Title
New("TextLabel",{Size=UDim2.new(0,200,0,24),Position=UDim2.new(0,64,0,10),
    RichText=true,
    Text='<font color="#F0F0EB" weight="800">LUXURY </font><font color="#DCB450" weight="800">HUB</font>',
    TextSize=18,Font=Enum.Font.GothamBold,TextColor3=C.TxW,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left},hdr)
New("TextLabel",{Size=UDim2.new(0,200,0,14),Position=UDim2.new(0,65,0,35),
    Text="CAR DEALERSHIP TYCOON",TextSize=9,Font=Enum.Font.GothamMedium,
    TextColor3=C.TxL,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left},hdr)

-- Tab pills in header
local tabPillsFrame=New("Frame",{Size=UDim2.new(0,220,0,26),
    Position=UDim2.new(0,270,0.5,-13),BackgroundTransparency=1},hdr)
Lst(tabPillsFrame,Enum.FillDirection.Horizontal,4,Enum.HorizontalAlignment.Left)
local pillBtns={}
local tabNames2={"💰 Заработок","🏗️ Траты","👤 Player","⚙️ Other"}

local function BuildPills()
    for _,b in ipairs(pillBtns) do b:Destroy() end
    pillBtns={}
    for i=1,4 do
        local act=(CurTab==i)
        local pb=New("TextButton",{
            Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,
            BackgroundColor3=act and C.BG3 or Color3.fromRGB(0,0,0),
            BackgroundTransparency=act and 0 or 1,
            BorderSizePixel=0,
            Text=" "..tabNames2[i].." ",TextSize=9,
            Font=act and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextColor3=act and C.Acc or C.TxL,
            AutoButtonColor=false,
        },tabPillsFrame)
        if act then Rnd(pb,10); Strk(pb,C.AccLine,1) end
        pb.MouseButton1Click:Connect(function() CurTab=i; BuildNav(); BuildPills(); RefreshContent() end)
        table.insert(pillBtns,pb)
    end
end

-- Header buttons
local function MkHBtn(xOff,txt,hc,cb)
    local b=New("TextButton",{Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,xOff,0.5,-14),
        BackgroundColor3=C.BG3,BorderSizePixel=0,Text=txt,TextSize=13,
        Font=Enum.Font.GothamBold,TextColor3=C.TxM,AutoButtonColor=false,ZIndex=10},hdr)
    Rnd(b,14); Strk(b,C.Bord,1)
    b.MouseEnter:Connect(function() Tw(b,{BackgroundColor3=hc},0.12) end)
    b.MouseLeave:Connect(function() Tw(b,{BackgroundColor3=C.BG3},0.12) end)
    b.MouseButton1Click:Connect(cb)
    return b
end

local function HideUI()
    Open=false
    Tw(panel,{Size=UDim2.new(0,Settings.PW,0,0)},Settings.animSpeed)
    task.delay(Settings.animSpeed+0.05,function()
        panel.Visible=false; sidebar.Visible=false; miniBtn.Visible=true
    end)
end

local function ShowUI()
    Open=true; miniBtn.Visible=false
    panel.Visible=true; sidebar.Visible=true
    panel.Size=UDim2.new(0,Settings.PW,0,0)
    Tw(panel,{Size=UDim2.new(0,Settings.PW,0,Settings.PH)},Settings.animSpeed)
    task.defer(SyncSidebar)
end

MkHBtn(-10,"✕",C.Red,HideUI)
MkHBtn(-46,"─",C.BG5,HideUI)

-- SCROLL
local scroll=New("ScrollingFrame",{
    Size=UDim2.new(1,0,1,-66-32),Position=UDim2.new(0,0,0,66),
    BackgroundTransparency=1,BorderSizePixel=0,
    ScrollBarThickness=3,ScrollBarImageColor3=C.AccSoft,
    CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ClipsDescendants=true,
},clip)
Pd(scroll,nil,8,8,10,10); Lst(scroll,Enum.FillDirection.Vertical,6)

-- FOOTER
local ftr=New("Frame",{Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,1,-32),
    BackgroundColor3=C.BG1,BorderSizePixel=0},clip)
New("Frame",{Size=UDim2.new(1,-24,0,1),Position=UDim2.new(0,12,0,0),
    BackgroundColor3=C.Sep,BorderSizePixel=0},ftr)
local fStat=New("TextLabel",{Size=UDim2.new(0.4,0,1,0),Position=UDim2.new(0,14,0,0),
    Text="0 активно",TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.TxL,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left},ftr)
local fName=New("TextLabel",{Size=UDim2.new(0.3,0,1,0),Position=UDim2.new(0.35,0,0,0),
    Text="Заработок",TextSize=10,Font=Enum.Font.GothamMedium,TextColor3=C.TxM,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center},ftr)
New("TextLabel",{Size=UDim2.new(0.3,0,1,0),Position=UDim2.new(0.7,0,0,0),
    Text="RShift",TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.TxF,
    BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right},ftr)

-- ══════════════════════════════════════════════
-- CONTENT
-- ══════════════════════════════════════════════
function RefreshContent()
    for _,c in ipairs(scroll:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end

    local tabNms={"Заработок","Траты","Player","Other"}
    fName.Text=tabNms[CurTab] or ""

    if CurTab<=3 then
        local tab=TABS[CurTab]
        for _,item in ipairs(tab.items) do
            MakeCard(scroll,item,tab.col)
        end
        local function UpdFt()
            local cnt=0
            for _,it in ipairs(tab.items) do if it.state then cnt=cnt+1 end end
            fStat.Text=cnt.." активно"
            fStat.TextColor3=cnt>0 and C.Green or C.TxL
        end
        UpdFt()
        -- polling
        task.spawn(function()
            while panel.Parent and Open do task.wait(1); UpdFt() end
        end)
    else
        -- ── OTHER ──
        fStat.Text="настройки"; fStat.TextColor3=C.TxL

        -- MENU SIZE
        SecLbl(scroll,"РАЗМЕР МЕНЮ")
        local sc1,si1=SettCard(scroll,130)
        MakeSlider(si1,{label="Ширина",min=400,max=900,step=10,val=Settings.PW,
            fmt=function(v) return math.floor(v).."px" end,
            onChange=function(v)
                Settings.PW=v
                if panel and panel.Parent then
                    Tw(panel,{Size=UDim2.new(0,v,0,Settings.PH)},0.15)
                    task.defer(SyncSidebar)
                end
            end})
        MakeSlider(si1,{label="Высота",min=300,max=900,step=10,val=Settings.PH,
            fmt=function(v) return math.floor(v).."px" end,
            onChange=function(v)
                Settings.PH=v
                if panel and panel.Parent then
                    Tw(panel,{Size=UDim2.new(0,Settings.PW,0,v)},0.15)
                    task.defer(SyncSidebar)
                end
            end})

        -- MINI BUTTON
        SecLbl(scroll,"КНОПКА СВЕРНУТЬ")
        local sc2,si2=SettCard(scroll,220)

        MakeSlider(si2,{label="Размер кнопки",min=30,max=100,step=2,val=Settings.miniSize,
            fmt=function(v) return math.floor(v).."px" end,
            onChange=function(v)
                Settings.miniSize=v
                miniBtn.Size=UDim2.new(0,v,0,v)
                if miniBtn:FindFirstChildOfClass("UICorner") then
                    miniBtn:FindFirstChildOfClass("UICorner").CornerRadius=
                        UDim.new(0,Settings.miniShape=="round" and v/2 or 10)
                end
            end})

        MakeSlider(si2,{label="Позиция по вертикали",min=5,max=95,step=1,
            val=math.floor(Settings.miniYPct*100),
            fmt=function(v) return v.."%" end,
            onChange=function(v)
                Settings.miniYPct=v/100
                local xOff=Settings.miniSide=="right" and (VP.X-Settings.miniSize-12) or 12
                miniBtn.Position=UDim2.new(0,xOff,Settings.miniYPct,-Settings.miniSize/2)
            end})

        MakeOptions(si2,"Сторона",{"left","right"},Settings.miniSide,function(v)
            Settings.miniSide=v
            local xOff=v=="right" and (VP.X-Settings.miniSize-12) or 12
            miniBtn.Position=UDim2.new(0,xOff,Settings.miniYPct,-Settings.miniSize/2)
        end)

        MakeOptions(si2,"Форма",{"round","square"},Settings.miniShape,function(v)
            Settings.miniShape=v
            if miniBtn:FindFirstChildOfClass("UICorner") then
                miniBtn:FindFirstChildOfClass("UICorner").CornerRadius=
                    UDim.new(0,v=="round" and Settings.miniSize/2 or 10)
            end
        end)

        -- ACCENT
        SecLbl(scroll,"ЦВЕТ АКЦЕНТА")
        local sc3,si3=SettCard(scroll,72)
        MakeColorPicker(si3,function(key)
            if accentBarRef and accentBarRef.Parent then
                accentBarRef.BackgroundColor3=C.Acc
            end
            BuildNav(); BuildPills()
            Notify("Other","Акцент изменён",C.Acc)
        end)

        -- ANIMATION SPEED
        SecLbl(scroll,"АНИМАЦИЯ")
        local sc4,si4=SettCard(scroll,70)
        MakeSlider(si4,{label="Скорость анимации",min=0.05,max=0.8,step=0.05,val=Settings.animSpeed,
            fmt=function(v) return string.format("%.2fs",v) end,
            onChange=function(v) Settings.animSpeed=v end})

        -- HOTKEY
        SecLbl(scroll,"ГОРЯЧАЯ КЛАВИША")
        local sc5=New("Frame",{Size=UDim2.new(1,0,0,40),BackgroundColor3=C.BG3,BorderSizePixel=0},scroll)
        Rnd(sc5,14); Strk(sc5,C.AccLine,1)
        New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="RIGHT SHIFT  ·  Скрыть / Показать меню",
            TextSize=12,Font=Enum.Font.GothamMedium,TextColor3=C.Acc,
            BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center},sc5)

        -- ACTIVITY
        SecLbl(scroll,"АКТИВНОСТЬ")
        local tabNmsAct={"Заработок","Траты","Player"}
        for ti=1,3 do
            local t=TABS[ti]; local cnt=0
            for _,it in ipairs(t.items) do if it.state then cnt=cnt+1 end end
            local row=New("Frame",{Size=UDim2.new(1,0,0,34),BackgroundColor3=C.BG2,BorderSizePixel=0},scroll)
            Rnd(row,12)
            New("Frame",{Size=UDim2.new(0,3,0,18),Position=UDim2.new(0,8,0.5,-9),
                BackgroundColor3=t.col or C.Acc,BorderSizePixel=0},row)
            New("TextLabel",{Size=UDim2.new(0,100,1,0),Position=UDim2.new(0,16,0,0),
                Text=tabNmsAct[ti],TextSize=11,Font=Enum.Font.GothamMedium,
                TextColor3=C.TxM,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left},row)
            local bW=Settings.PW-220
            local tr=New("Frame",{Size=UDim2.new(0,bW,0,8),Position=UDim2.new(0,105,0.5,-4),
                BackgroundColor3=C.SlTrack,BorderSizePixel=0},row)
            Rnd(tr,4)
            if cnt>0 then
                local fi=New("Frame",{Size=UDim2.new(cnt/#t.items,0,1,0),
                    BackgroundColor3=t.col or C.Acc,BorderSizePixel=0},tr)
                Rnd(fi,4)
            end
            New("TextLabel",{Size=UDim2.new(0,50,1,0),Position=UDim2.new(1,-55,0,0),
                Text=cnt.."/"..#t.items,TextSize=10,Font=Enum.Font.Gotham,
                TextColor3=C.TxL,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right},row)
        end
    end
end

-- ══════════════════════════════════════════════
-- DRAG
-- ══════════════════════════════════════════════
local drag=false; local dragS; local dragP
hdr.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=true; dragS=i.Position; dragP=panel.Position
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
-- RESPAWN
-- ══════════════════════════════════════════════
LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    if AD.active then
        StopAD()
        for _,it in ipairs(TABS[1].items) do
            if it.isAD then it.state=false end
        end
    end
    for _,tab in ipairs(TABS) do
        for _,it in ipairs(tab.items) do
            if it.state and not it.isAD then pcall(it.enable,it) end
        end
    end
end)

-- ══════════════════════════════════════════════
-- INIT
-- ══════════════════════════════════════════════
BuildNav()
BuildPills()
RefreshContent()

task.defer(SyncSidebar)
Notify("LUXURY HUB","Загружен для Car Dealership Tycoon!",C.Acc)
print("LUXURY HUB v23 CDT - OK")
