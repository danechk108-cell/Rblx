-- LUXURY HUB v22 - Car Dealership Tycoon
-- Tabs: Заработок | Траты | Player | Other

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TW = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- GUI ROOT
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
    BG5=Color3.fromRGB(30,32,40),
    SB0=Color3.fromRGB(8,9,12),
    SB1=Color3.fromRGB(16,17,22),
    SB2=Color3.fromRGB(22,24,30),
    Acc=Color3.fromRGB(220,180,80),
    Acc2=Color3.fromRGB(180,145,55),
    Acc3=Color3.fromRGB(120,95,30),
    AccLine=Color3.fromRGB(90,72,25),
    AccSoft=Color3.fromRGB(60,48,15),
    AccDim=Color3.fromRGB(35,28,8),
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
    Blue=Color3.fromRGB(70,140,220),
    Orange=Color3.fromRGB(220,140,50),
    White=Color3.fromRGB(255,255,255),
    Black=Color3.fromRGB(0,0,0),
    SlTrack=Color3.fromRGB(18,20,26),
    SlFill=Color3.fromRGB(220,180,80),
    CardOn=Color3.fromRGB(22,20,12),
    CardOnBord=Color3.fromRGB(180,145,55),
}

-- ══════════════════════════════════════════════
-- SETTINGS STATE
-- ══════════════════════════════════════════════
local Settings = {
    menuWidth    = 660,
    menuHeight   = 620,
    miniSize     = 50,
    miniSide     = "left",   -- "left" | "right"
    miniYPct     = 0.5,
    miniShape    = "round",  -- "round" | "square"
    accentColor  = "gold",   -- "gold" | "blue" | "green" | "red"
    showFooter   = true,
    animSpeed    = 0.22,
    hotkey       = "RightShift",
}

local AccentPresets = {
    gold  = {main=Color3.fromRGB(220,180,80),  soft=Color3.fromRGB(60,48,15),  line=Color3.fromRGB(90,72,25)},
    blue  = {main=Color3.fromRGB(80,150,240),  soft=Color3.fromRGB(15,40,80),  line=Color3.fromRGB(40,80,160)},
    green = {main=Color3.fromRGB(80,210,110),  soft=Color3.fromRGB(15,55,25),  line=Color3.fromRGB(40,120,60)},
    red   = {main=Color3.fromRGB(220,80,80),   soft=Color3.fromRGB(60,15,15),  line=Color3.fromRGB(140,40,40)},
}

local function ApplyAccent(key)
    local p = AccentPresets[key] or AccentPresets.gold
    C.Acc=p.main; C.AccSoft=p.soft; C.AccLine=p.line
    C.Acc2=p.main; C.SlFill=p.main
    C.CardOnBord=p.main; C.BordA=p.main
    Settings.accentColor=key
end

-- ══════════════════════════════════════════════
-- UTILS
-- ══════════════════════════════════════════════
local function New(class, props, parent)
    local i = Instance.new(class)
    for k,v in pairs(props or {}) do i[k]=v end
    if parent then i.Parent=parent end
    return i
end

local function Tween(inst, props, t, style, dir)
    if not inst or not inst.Parent then return end
    local info = TweenInfo.new(t or Settings.animSpeed, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local tw = TW:Create(inst, info, props)
    tw:Play(); return tw
end

local function Round(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 12)
    c.Parent = inst; return c
end

local function Stroke(inst, col, th)
    local s = Instance.new("UIStroke")
    s.Color = col or C.Bord; s.Thickness = th or 1.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst; return s
end

local function Pad(inst, a, t, b, l, r)
    local p = Instance.new("UIPadding")
    if a then p.PaddingTop=UDim.new(0,a);p.PaddingBottom=UDim.new(0,a);p.PaddingLeft=UDim.new(0,a);p.PaddingRight=UDim.new(0,a)
    else
        if t then p.PaddingTop=UDim.new(0,t) end
        if b then p.PaddingBottom=UDim.new(0,b) end
        if l then p.PaddingLeft=UDim.new(0,l) end
        if r then p.PaddingRight=UDim.new(0,r) end
    end
    p.Parent=inst; return p
end

local function List(inst, dir, pad, ha)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Padding = UDim.new(0, pad or 6)
    l.HorizontalAlignment = ha or Enum.HorizontalAlignment.Left
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = inst; return l
end

-- Notification toast
local function Notify(title, msg, col)
    local notif = New("Frame",{
        Size=UDim2.new(0,285,0,66),
        Position=UDim2.new(1,10,1,-80),
        BackgroundColor3=C.BG2,
        BorderSizePixel=0,
        ZIndex=200,
    }, Screen)
    Round(notif,12)
    Stroke(notif, col or C.Acc, 1.5)

    New("Frame",{Size=UDim2.new(0,3,1,0),BackgroundColor3=col or C.Acc,BorderSizePixel=0,ZIndex=201},notif)
    Round(New("Frame",{Size=UDim2.new(0,3,1,0),BackgroundColor3=col or C.Acc,BorderSizePixel=0,ZIndex=201},notif),2)

    New("TextLabel",{Size=UDim2.new(1,-18,0,22),Position=UDim2.new(0,10,0,6),
        Text=title,TextSize=13,Font=Enum.Font.GothamBold,
        TextColor3=col or C.Acc,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},notif)
    New("TextLabel",{Size=UDim2.new(1,-18,0,18),Position=UDim2.new(0,10,0,28),
        Text=msg,TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},notif)

    Tween(notif,{Position=UDim2.new(1,-298,1,-80)},0.3)
    task.delay(3.5,function()
        Tween(notif,{Position=UDim2.new(1,10,1,-80)},0.3)
        task.delay(0.35,function() pcall(function() notif:Destroy() end) end)
    end)
end

-- Section header inside scroll
local function SectionHeader(parent, text, order)
    local f = New("Frame",{
        Size=UDim2.new(1,0,0,28),
        BackgroundTransparency=1,
        LayoutOrder=order or 0,
    }, parent)
    New("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        Text=text,
        TextSize=9,
        Font=Enum.Font.GothamBold,
        TextColor3=C.TxL,
        BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, f)
    New("Frame",{
        Size=UDim2.new(1,0,0,1),
        Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=C.Sep,
        BorderSizePixel=0,
    }, f)
    return f
end

-- ══════════════════════════════════════════════
-- AUTO-DRIVE SYSTEM
-- ══════════════════════════════════════════════
local AutoDrive = {
    active=false, conn=nil, road=nil,
    speed=60, roadLength=8000, startPos=nil, currentCar=nil,
}

local function GetPlayerCar()
    local char=LP.Character; if not char then return nil,nil end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return nil,nil end
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") and v.Occupant==hum then
            return v.Parent, v
        end
    end
    return nil,nil
end

local function IsInCar()
    local car,seat=GetPlayerCar(); return car~=nil,car,seat
end

local function BuildRoad(startCF)
    if AutoDrive.road then AutoDrive.road:Destroy(); AutoDrive.road=nil end
    local roadModel=Instance.new("Model"); roadModel.Name="LHubRoad"; roadModel.Parent=workspace
    AutoDrive.road=roadModel
    local segLen=50
    local numSegs=math.ceil(AutoDrive.roadLength/segLen)
    local roadY=startCF.Position.Y+800
    AutoDrive.startPos=Vector3.new(startCF.Position.X, roadY, startCF.Position.Z)

    for i=0,numSegs do
        local seg=Instance.new("Part")
        seg.Size=Vector3.new(20,1,segLen)
        seg.Position=Vector3.new(AutoDrive.startPos.X, roadY, AutoDrive.startPos.Z+i*segLen)
        seg.Anchored=true; seg.CanCollide=true
        seg.BrickColor=BrickColor.new("Dark grey metallic")
        seg.Material=Enum.Material.SmoothPlastic
        seg.CastShadow=false; seg.Parent=roadModel

        if i%2==0 then
            local m=Instance.new("Part")
            m.Size=Vector3.new(0.5,0.1,segLen*0.6)
            m.Position=Vector3.new(AutoDrive.startPos.X, roadY+0.6, AutoDrive.startPos.Z+i*segLen)
            m.Anchored=true; m.CanCollide=false
            m.BrickColor=BrickColor.new("Bright yellow")
            m.Material=Enum.Material.SmoothPlastic
            m.CastShadow=false; m.Parent=roadModel
        end
    end

    local finish=Instance.new("Part")
    finish.Size=Vector3.new(20,2,4)
    finish.Position=Vector3.new(AutoDrive.startPos.X, roadY+0.5, AutoDrive.startPos.Z+AutoDrive.roadLength-10)
    finish.Anchored=true; finish.CanCollide=false
    finish.BrickColor=BrickColor.new("Bright red")
    finish.Material=Enum.Material.Neon
    finish.Transparency=0.4; finish.CastShadow=false
    finish.Name="FinishLine"; finish.Parent=roadModel
    return roadModel
end

local function StartAutoDrive(car, seat)
    AutoDrive.active=true; AutoDrive.currentCar=car
    local lap=0

    AutoDrive.conn=RS.Heartbeat:Connect(function()
        if not AutoDrive.active then return end
        local inCar,_,_=IsInCar()
        if not inCar then
            AutoDrive.active=false
            if AutoDrive.conn then AutoDrive.conn:Disconnect(); AutoDrive.conn=nil end
            Notify("Auto-Drive","Stopped — left vehicle", C.Red)
            return
        end
        local primary=car.PrimaryPart or car:FindFirstChildOfClass("BasePart")
        if not primary then return end

        local vel=primary:FindFirstChild("LHubDriveVel")
        if not vel then
            vel=Instance.new("BodyVelocity"); vel.Name="LHubDriveVel"
            vel.MaxForce=Vector3.new(1e6,0,1e6); vel.Parent=primary
        end

        local endZ=AutoDrive.startPos.Z+AutoDrive.roadLength-20
        if primary.Position.Z>=endZ then
            lap=lap+1
            Notify("Auto-Drive","Lap "..lap.."! Resetting...", C.Acc)
            pcall(function()
                car:SetPrimaryPartCFrame(CFrame.new(
                    AutoDrive.startPos.X, AutoDrive.startPos.Y+4, AutoDrive.startPos.Z+5))
            end)
            task.wait(0.2); return
        end

        vel.Velocity=Vector3.new(0,0,AutoDrive.speed)

        local gyro=primary:FindFirstChild("LHubDriveGyro")
        if not gyro then
            gyro=Instance.new("BodyGyro"); gyro.Name="LHubDriveGyro"
            gyro.MaxTorque=Vector3.new(0,1e5,0); gyro.D=500; gyro.Parent=primary
        end
        gyro.CFrame=CFrame.new(primary.Position)
    end)
end

local function StopAutoDrive()
    AutoDrive.active=false
    if AutoDrive.conn then AutoDrive.conn:Disconnect(); AutoDrive.conn=nil end
    if AutoDrive.currentCar then
        local p=AutoDrive.currentCar.PrimaryPart or AutoDrive.currentCar:FindFirstChildOfClass("BasePart")
        if p then
            local v=p:FindFirstChild("LHubDriveVel"); if v then v:Destroy() end
            local g=p:FindFirstChild("LHubDriveGyro"); if g then g:Destroy() end
        end
    end
    if AutoDrive.road then AutoDrive.road:Destroy(); AutoDrive.road=nil end
    AutoDrive.currentCar=nil
end

local function TryStartAutoDrive()
    local inCar,car,seat=IsInCar()
    if not inCar then Notify("Auto-Drive","❌ Get in a car first!",C.Red); return false end
    local char=LP.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    Notify("Auto-Drive","Building road high above...",C.Acc)
    BuildRoad(hrp.CFrame)
    task.wait(0.4)
    pcall(function()
        car:SetPrimaryPartCFrame(CFrame.new(AutoDrive.startPos.X, AutoDrive.startPos.Y+4, AutoDrive.startPos.Z+5))
    end)
    task.wait(0.4)
    StartAutoDrive(car,seat)
    Notify("Auto-Drive","✓ Started! Speed: "..AutoDrive.speed,C.Green)
    return true
end

-- ══════════════════════════════════════════════
-- AUTO-BUILD (Tycoon) SYSTEM
-- ══════════════════════════════════════════════
local AutoBuild = {
    active=false, conn=nil,
    delay=0.1, variant=1,
}

-- Attempt to find and click tycoon build buttons
local function TryBuildClick()
    pcall(function()
        -- Find buttons in the tycoon (common patterns in CDT)
        for _,obj in ipairs(workspace:GetDescendants()) do
            if (obj:IsA("BasePart") or obj:IsA("Model")) then
                local name=obj.Name:lower()
                if name:find("buy") or name:find("button") or name:find("plot") or name:find("purchase") then
                    -- Try to trigger with touch or proximity
                    local part=obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
                    if part then
                        local char=LP.Character
                        local hrp=char and char:FindFirstChild("HumanoidRootPart")
                        if hrp and (hrp.Position-part.Position).Magnitude<50 then
                            -- Simulate touch
                            local te=part.Touched
                            if te then
                                local fakepart=Instance.new("Part")
                                fakepart.Parent=workspace
                                part.Touched:Fire(fakepart)
                                fakepart:Destroy()
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function StartAutoBuild()
    AutoBuild.active=true
    AutoBuild.conn=RS.Heartbeat:Connect(function()
        if not AutoBuild.active then return end
        TryBuildClick()
    end)
end

local function StopAutoBuild()
    AutoBuild.active=false
    if AutoBuild.conn then AutoBuild.conn:Disconnect(); AutoBuild.conn=nil end
end

-- ══════════════════════════════════════════════
-- TABS DATA
-- ══════════════════════════════════════════════
local TABS={
    -- ── TAB 1: ЗАРАБОТОК ─────────────────────
    {name="Заработок", icon="💰", color=Color3.fromRGB(220,180,80), items={

        {label="Auto-Drive", desc="Авто-езда на бесконечной дороге",
         state=false, isAutoDrive=true,
         param={label="Скорость езды", min=20, max=300, step=5, val=60,
          fmt=function(v) return math.floor(v).." u/s" end,
          apply=function(v) AutoDrive.speed=v
              if AutoDrive.active then Notify("Auto-Drive","Speed → "..v.." u/s",C.Acc) end
          end},
         enable=function(it)
             AutoDrive.speed=it.param.val
             local ok=TryStartAutoDrive()
             if not ok then it.state=false end
         end,
         disable=function() StopAutoDrive() end},

        {label="Auto-Drive Boost", desc="Ускорить авто до максимума пока едет",
         state=false, conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 if not AutoDrive.active then return end
                 local car=AutoDrive.currentCar; if not car then return end
                 local p=car.PrimaryPart or car:FindFirstChildOfClass("BasePart"); if not p then return end
                 local v=p:FindFirstChild("LHubDriveVel"); if v then v.Velocity=Vector3.new(0,0,300) end
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Anti-AFK", desc="Предотвращает кик за AFK",
         state=false, conn=nil,
         enable=function(it)
             it.conn=LP.Idled:Connect(function()
                 pcall(function()
                     local vu=game:GetService("VirtualUser")
                     vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                     task.wait(); vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Auto-Collect", desc="Авто-сбор монет / денег на карте",
         state=false, conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local char=LP.Character; if not char then return end
                     local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                     for _,v in ipairs(workspace:GetDescendants()) do
                         local n=v.Name:lower()
                         if v:IsA("BasePart") and (n:find("coin") or n:find("cash") or n:find("money") or n:find("collect")) then
                             if (hrp.Position-v.Position).Magnitude<30 then
                                 pcall(function() v.Touched:Fire(hrp) end)
                             end
                         end
                     end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Speed Collect", desc="Телепорт к ближайшим монетам",
         state=false, conn=nil,
         param={label="Радиус поиска", min=20, max=500, step=10, val=100,
          fmt=function(v) return math.floor(v).." studs" end,
          apply=function(v,it) it._radius=v end},
         _radius=100,
         enable=function(it)
             it._radius=it.param.val
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local char=LP.Character; if not char then return end
                     local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                     local best,bestDist=nil,it._radius or 100
                     for _,v in ipairs(workspace:GetDescendants()) do
                         local n=v.Name:lower()
                         if v:IsA("BasePart") and (n:find("coin") or n:find("cash") or n:find("money")) then
                             local d=(hrp.Position-v.Position).Magnitude
                             if d<bestDist then bestDist=d; best=v end
                         end
                     end
                     if best then hrp.CFrame=CFrame.new(best.Position+Vector3.new(0,3,0)) end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Slot 6",desc="Пусто",state=false,enable=function()end,disable=function()end},
        {label="Slot 7",desc="Пусто",state=false,enable=function()end,disable=function()end},
        {label="Slot 8",desc="Пусто",state=false,enable=function()end,disable=function()end},
        {label="Slot 9",desc="Пусто",state=false,enable=function()end,disable=function()end},
    }},

    -- ── TAB 2: ТРАТЫ ─────────────────────────
    {name="Траты", icon="🏗️", color=Color3.fromRGB(80,180,220), items={

        {label="Auto-Build Tycoon", desc="Авто-постройка тайкуна (нажимает кнопки)",
         state=false,
         param={label="Задержка", min=0.05, max=2, step=0.05, val=0.15,
          fmt=function(v) return string.format("%.2f",v).."s" end,
          apply=function(v) AutoBuild.delay=v end},
         enable=function(it)
             AutoBuild.delay=it.param.val
             StartAutoBuild()
             Notify("Auto-Build","✓ Запущено",C.Green)
         end,
         disable=function()
             StopAutoBuild()
             Notify("Auto-Build","Остановлено",C.TxM)
         end},

        {label="Tycoon Variant: Стандарт", desc="Выбрать стандартный вариант тайкуна",
         state=false,
         enable=function()
             AutoBuild.variant=1
             Notify("Траты","Вариант: Стандарт выбран",C.Acc)
         end,
         disable=function() end},

        {label="Tycoon Variant: Люкс", desc="Выбрать люкс вариант тайкуна",
         state=false,
         enable=function()
             AutoBuild.variant=2
             Notify("Траты","Вариант: Люкс выбран",C.Acc)
         end,
         disable=function() end},

        {label="Tycoon Variant: Мега", desc="Выбрать мега вариант тайкуна",
         state=false,
         enable=function()
             AutoBuild.variant=3
             Notify("Траты","Вариант: Мега выбран",C.Acc)
         end,
         disable=function() end},

        {label="Auto-Upgrade Cars", desc="Авто-апгрейд машин в дилершипе",
         state=false, conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     for _,v in ipairs(workspace:GetDescendants()) do
                         local n=v.Name:lower()
                         if v:IsA("BasePart") and (n:find("upgrade") or n:find("improve")) then
                             local char=LP.Character
                             local hrp=char and char:FindFirstChild("HumanoidRootPart")
                             if hrp and (hrp.Position-v.Position).Magnitude<60 then
                                 pcall(function() v.Touched:Fire(hrp) end)
                             end
                         end
                     end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Auto-Buy Showroom", desc="Авто покупка показрума / шоурума",
         state=false, conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     for _,v in ipairs(workspace:GetDescendants()) do
                         local n=v.Name:lower()
                         if v:IsA("BasePart") and (n:find("showroom") or n:find("dealer") or n:find("buy")) then
                             local char=LP.Character
                             local hrp=char and char:FindFirstChild("HumanoidRootPart")
                             if hrp and (hrp.Position-v.Position).Magnitude<40 then
                                 pcall(function() v.Touched:Fire(hrp) end)
                             end
                         end
                     end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Slot 7",desc="Пусто",state=false,enable=function()end,disable=function()end},
        {label="Slot 8",desc="Пусто",state=false,enable=function()end,disable=function()end},
        {label="Slot 9",desc="Пусто",state=false,enable=function()end,disable=function()end},
    }},

    -- ── TAB 3: PLAYER ────────────────────────
    {name="Player", icon="👤", color=Color3.fromRGB(180,120,255), items={

        {label="Speed Boost", desc="Ускорение ходьбы игрока",
         state=false,
         param={label="Множитель скорости", min=1, max=15, step=0.5, val=2.5,
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

        {label="High Jump", desc="Высокий прыжок",
         state=false,
         param={label="Сила прыжка", min=50, max=500, step=10, val=150,
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

        {label="Infinite Jump", desc="Прыжок в воздухе",
         state=false, conn=nil,
         enable=function(it)
             it.conn=UIS.JumpRequest:Connect(function()
                 pcall(function()
                     local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                     if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Fly", desc="Полёт WASD + Пробел",
         state=false, conn=nil, _bv=nil, _bg=nil, _spd=60,
         param={label="Скорость полёта", min=10, max=300, step=5, val=60,
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

        {label="God Mode", desc="Бесконечное здоровье",
         state=false, conn=nil,
         enable=function(it)
             it.conn=RS.Heartbeat:Connect(function()
                 pcall(function()
                     local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                     if h then h.Health=h.MaxHealth end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="No Clip", desc="Проходить сквозь стены",
         state=false, conn=nil,
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

        {label="Low Gravity", desc="Низкая гравитация",
         state=false,
         param={label="Гравитация", min=2, max=196, step=5, val=20,
          fmt=function(v) return math.floor(v).." g" end,
          apply=function(v) pcall(function() workspace.Gravity=v end) end},
         enable=function(it) pcall(function() workspace.Gravity=it.param.val end) end,
         disable=function() pcall(function() workspace.Gravity=196.2 end) end},

        {label="Invisible", desc="Скрыть персонажа",
         state=false,
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

        {label="Slot 9",desc="Пусто",state=false,enable=function()end,disable=function()end},
    }},

    -- ── TAB 4: OTHER (Settings) ───────────────
    {name="Other", icon="⚙️", color=Color3.fromRGB(140,140,140), items={}},
}

-- ══════════════════════════════════════════════
-- SLIDER COMPONENT
-- ══════════════════════════════════════════════
local function MakeSlider(parent, opts)
    local mn=opts.min or 0; local mx=opts.max or 100
    local st=opts.step or 1; local val=opts.val or mn
    local fmt=opts.fmt or function(v) return tostring(v) end

    local cont=New("Frame",{Size=UDim2.new(1,0,0,54),BackgroundTransparency=1},parent)

    local row=New("Frame",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1},cont)
    New("TextLabel",{Size=UDim2.new(1,-62,1,0),
        Text=opts.label or "",TextSize=10,Font=Enum.Font.GothamMedium,
        TextColor3=C.TxM,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left},row)
    local valLbl=New("TextLabel",{Size=UDim2.new(0,60,1,0),Position=UDim2.new(1,-60,0,0),
        Text=fmt(val),TextSize=11,Font=Enum.Font.GothamBold,
        TextColor3=C.Acc,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right},row)

    local trackBG=New("Frame",{Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,0,26),
        BackgroundColor3=C.SlTrack,BorderSizePixel=0},cont)
    Round(trackBG,4)

    local fill=New("Frame",{Size=UDim2.new((val-mn)/(mx-mn),0,1,0),
        BackgroundColor3=C.SlFill,BorderSizePixel=0},trackBG)
    Round(fill,4)

    local knob=New("Frame",{Size=UDim2.new(0,22,0,22),Position=UDim2.new(0,-11,0.5,-11),
        BackgroundColor3=C.Acc,BorderSizePixel=0,ZIndex=6},fill)
    Round(knob,11)
    local ki=New("Frame",{Size=UDim2.new(0,10,0,10),Position=UDim2.new(0.5,-5,0.5,-5),
        BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=7},knob)
    Round(ki,5)

    local dragging=false

    local function UpdateVal(newVal)
        local snap=math.floor(newVal/st+0.5)*st
        snap=math.max(mn,math.min(mx,snap))
        if snap~=val then
            val=snap
            fill.Size=UDim2.new((val-mn)/(mx-mn),0,1,0)
            valLbl.Text=fmt(val)
            if opts.onChange then opts.onChange(val) end
        end
    end

    local function OnInput(x)
        local abs=trackBG.AbsolutePosition.X
        local sz=trackBG.AbsoluteSize.X
        if sz<=0 then return end
        local pct=math.max(0,math.min(1,(x-abs)/sz))
        UpdateVal(mn+pct*(mx-mn))
    end

    local hit=New("TextButton",{Size=UDim2.new(1,0,0,34),Position=UDim2.new(0,0,0,18),
        BackgroundTransparency=1,Text="",ZIndex=8},cont)

    hit.MouseButton1Down:Connect(function(x)
        dragging=true; OnInput(x)
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
            OnInput(inp.Position.X) end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)

    return cont,{GetValue=function() return val end, SetValue=function(v) UpdateVal(v) end}
end

-- ══════════════════════════════════════════════
-- TOGGLE COMPONENT
-- ══════════════════════════════════════════════
local function MakeToggle(parent, initState, onChange)
    local W,H=52,28
    local cont=New("Frame",{Size=UDim2.new(0,W,0,H),BackgroundTransparency=1},parent)
    local track=New("Frame",{Size=UDim2.new(1,0,1,0),
        BackgroundColor3=initState and C.Acc or C.SlTrack,BorderSizePixel=0},cont)
    Round(track,H/2)
    local knob=New("Frame",{
        Size=UDim2.new(0,H-8,0,H-8),
        Position=initState and UDim2.new(1,-(H-4),0.5,-(H-8)/2) or UDim2.new(0,4,0.5,-(H-8)/2),
        BackgroundColor3=C.White,BorderSizePixel=0,ZIndex=3},track)
    Round(knob,(H-8)/2)
    local on=initState or false
    local function Set(state,anim)
        on=state
        local tc=on and C.Acc or C.SlTrack
        local kp=on and UDim2.new(1,-(H-4),0.5,-(H-8)/2) or UDim2.new(0,4,0.5,-(H-8)/2)
        if anim then Tween(track,{BackgroundColor3=tc},0.18); Tween(knob,{Position=kp},0.18)
        else track.BackgroundColor3=tc; knob.Position=kp end
    end
    local btn=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=10},cont)
    btn.MouseButton1Click:Connect(function() Set(not on,true); if onChange then onChange(on) end end)
    return cont,{Set=Set,Get=function() return on end,Track=track,Knob=knob}
end

-- ══════════════════════════════════════════════
-- CARD COMPONENT
-- ══════════════════════════════════════════════
local function MakeCard(parent, item, tabColor)
    local tCol = tabColor or C.Acc

    local cardWrap=New("Frame",{
        Size=UDim2.new(1,0,0,58),
        BackgroundTransparency=1,
        ClipsDescendants=false,
    },parent)

    local card=New("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=item.state and C.CardOn or C.BG2,
        BorderSizePixel=0,
        ClipsDescendants=true,
    },cardWrap)
    Round(card,18)
    local stroke=Stroke(card, item.state and tCol or C.Bord, 1)

    -- Color tab indicator
    local tabInd=New("Frame",{
        Size=UDim2.new(0,3,0,34),
        Position=UDim2.new(0,12,0.5,-17),
        BackgroundColor3=tCol,
        BorderSizePixel=0,
        Visible=item.state,
    },card)
    Round(tabInd,2)

    local lblMain=New("TextLabel",{
        Size=UDim2.new(1,-80,0,22),
        Position=UDim2.new(0,26,0,8),
        Text=item.label,TextSize=14,Font=Enum.Font.GothamMedium,
        TextColor3=item.state and C.TxW or C.TxH,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,
    },card)

    local lblDesc=New("TextLabel",{
        Size=UDim2.new(1,-80,0,14),
        Position=UDim2.new(0,26,0,30),
        Text=item.desc,TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=item.state and C.TxM or C.TxL,
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,
    },card)

    -- Param panel
    local paramPanel=nil
    if item.param then
        paramPanel=New("Frame",{
            Size=UDim2.new(1,-8,0,0),
            Position=UDim2.new(0,4,1,4),
            BackgroundColor3=C.BG0,
            BorderSizePixel=0,
            ClipsDescendants=true,
            Visible=false,
        },cardWrap)
        Round(paramPanel,14)
        Stroke(paramPanel,tCol,1)
        local inner=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},paramPanel)
        Pad(inner,nil,8,8,12,12)
        local pp=item.param
        MakeSlider(inner,{
            label=pp.label,min=pp.min,max=pp.max,step=pp.step,val=pp.val,fmt=pp.fmt,
            onChange=function(v)
                pp.val=v
                if pp.apply then pp.apply(v,item) end
            end,
        })
    end

    local function ApplyVisual(state,animate)
        local bgC=state and C.CardOn or C.BG2
        local bdC=state and tCol or C.Bord
        if animate then Tween(card,{BackgroundColor3=bgC},0.2) else card.BackgroundColor3=bgC end
        stroke.Color=bdC
        tabInd.Visible=state
        lblMain.TextColor3=state and C.TxW or C.TxH
        lblDesc.TextColor3=state and C.TxM or C.TxL
        if paramPanel then
            if state then
                paramPanel.Visible=true
                Tween(paramPanel,{Size=UDim2.new(1,-8,0,72)},0.22)
                Tween(cardWrap,{Size=UDim2.new(1,0,0,140)},0.22)
            else
                Tween(paramPanel,{Size=UDim2.new(1,-8,0,0)},0.18)
                Tween(cardWrap,{Size=UDim2.new(1,0,0,58)},0.18)
                task.delay(0.2,function()
                    if not item.state then paramPanel.Visible=false end
                end)
            end
        end
    end

    local tgCont,tgCtrl=MakeToggle(card,item.state,nil)
    tgCont.Position=UDim2.new(1,-66,0.5,-14); tgCont.ZIndex=5

    local function DoToggle()
        local newState=not item.state
        if newState and item.isAutoDrive then
            local inCar=IsInCar()
            if not inCar then
                Notify("Auto-Drive","❌ Сначала сядь в машину!",C.Red)
                return
            end
        end
        item.state=newState
        tgCtrl.Set(newState,true)
        ApplyVisual(newState,true)
        if newState then
            local ok=true
            pcall(function() ok=item.enable(item) end)
            if ok==false then
                item.state=false; tgCtrl.Set(false,true); ApplyVisual(false,true)
            end
        else
            pcall(item.disable,item)
        end
    end

    local hit=New("TextButton",{Size=UDim2.new(1,0,0,58),BackgroundTransparency=1,Text="",ZIndex=8},card)
    hit.MouseButton1Click:Connect(DoToggle)

    card.MouseEnter:Connect(function()
        if not item.state then Tween(card,{BackgroundColor3=C.BG3},0.15); stroke.Color=C.BordH end
    end)
    card.MouseLeave:Connect(function()
        if not item.state then Tween(card,{BackgroundColor3=C.BG2},0.15); stroke.Color=C.Bord end
    end)

    if item.state then ApplyVisual(true,false) end
    return cardWrap
end

-- ══════════════════════════════════════════════
-- MAIN UI CONSTRUCTION
-- ══════════════════════════════════════════════
local PW=Settings.menuWidth; local PH=Settings.menuHeight
local PX=math.floor((workspace.CurrentCamera.ViewportSize.X-PW)/2)
local PY=math.floor((workspace.CurrentCamera.ViewportSize.Y-PH)/2)

local Open=true; local CurTab=1

-- MINI BUTTON
local miniBtn=New("TextButton",{
    Size=UDim2.new(0,Settings.miniSize,0,Settings.miniSize),
    Position=UDim2.new(0,12,Settings.miniYPct,-Settings.miniSize/2),
    BackgroundColor3=C.SB0,BorderSizePixel=0,
    Text="🚗",TextSize=20,Font=Enum.Font.GothamBold,TextColor3=C.Acc,
    Visible=false,ZIndex=20,AutoButtonColor=false,
},Screen)
Round(miniBtn,Settings.miniSize/2)
Stroke(miniBtn,C.AccLine,1.5)

-- SIDEBAR
local sidebarWrap=New("Frame",{
    Size=UDim2.new(0,66,0,10),
    Position=UDim2.new(0,PX-82,0,PY),
    BackgroundColor3=C.SB0,BorderSizePixel=0,
    AutomaticSize=Enum.AutomaticSize.Y,
},Screen)
Round(sidebarWrap,26)
Stroke(sidebarWrap,C.Bord,1.5)

local sideInner=New("Frame",{
    Size=UDim2.new(1,0,0,10),BackgroundTransparency=1,
    AutomaticSize=Enum.AutomaticSize.Y,
},sidebarWrap)
Pad(sideInner,10)
List(sideInner,Enum.FillDirection.Vertical,8,Enum.HorizontalAlignment.Center)

New("TextLabel",{Size=UDim2.new(1,0,0,12),Text="HUB",TextSize=7,
    Font=Enum.Font.GothamBold,TextColor3=C.TxL,BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Center,LayoutOrder=0},sideInner)

local NAV_ICONS={"💰","🏗️","👤","⚙️"}
local NAV_NAMES={"Заработок","Траты","Player","Other"}
local navBtns={}

-- PANEL
local panel=New("Frame",{
    Size=UDim2.new(0,PW,0,PH),
    Position=UDim2.new(0,PX,0,PY),
    BackgroundColor3=C.BG1,BorderSizePixel=0,
},Screen)
Round(panel,22)
Stroke(panel,C.Bord,1.5)

local panelClip=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ClipsDescendants=true},panel)
Round(panelClip,22)

-- HEADER
local header=New("Frame",{Size=UDim2.new(1,0,0,70),BackgroundColor3=C.BG2,BorderSizePixel=0},panelClip)
Round(header,22)
New("Frame",{Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,1,-24),BackgroundColor3=C.BG2,BorderSizePixel=0},header)

local accentBar=New("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=C.Acc,BorderSizePixel=0},header)

-- Logo
local logoOuter=New("Frame",{Size=UDim2.new(0,44,0,44),Position=UDim2.new(0,14,0.5,-22),BackgroundColor3=C.Acc3,BorderSizePixel=0},header)
Round(logoOuter,22); Stroke(logoOuter,C.AccLine,1.5)
local logoInner=New("Frame",{Size=UDim2.new(0,36,0,36),Position=UDim2.new(0.5,-18,0.5,-18),BackgroundColor3=C.AccSoft,BorderSizePixel=0},logoOuter)
Round(logoInner,18)
New("TextLabel",{Size=UDim2.new(1,0,1,0),Text="🚗",TextSize=20,Font=Enum.Font.GothamBold,
    TextColor3=C.Acc,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center},logoOuter)

-- Tab indicator strip
local tabStrip=New("Frame",{
    Size=UDim2.new(0,240,0,32),
    Position=UDim2.new(0,66,0.5,-16),
    BackgroundTransparency=1,
},header)

local tabStripBtns={}
local function BuildTabStrip()
    for _,b in ipairs(tabStripBtns) do b:Destroy() end
    tabStripBtns={}
    local btnW=math.floor(240/4)
    for i=1,4 do
        local isAct=(CurTab==i)
        local tb=New("TextButton",{
            Size=UDim2.new(0,btnW,1,0),
            Position=UDim2.new(0,(i-1)*btnW,0,0),
            BackgroundColor3=isAct and C.BG3 or C.BG2,
            BorderSizePixel=0,
            Text=NAV_NAMES[i],
            TextSize=9,
            Font=isAct and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextColor3=isAct and C.Acc or C.TxL,
            AutoButtonColor=false,
        },tabStrip)
        Round(tb,10)
        if isAct then Stroke(tb,C.AccLine,1) end

        if isAct then
            New("Frame",{Size=UDim2.new(0.7,0,0,2),Position=UDim2.new(0.15,0,1,-2),
                BackgroundColor3=C.Acc,BorderSizePixel=0},tb)
        end

        tb.MouseButton1Click:Connect(function()
            CurTab=i; BuildNav(); BuildTabStrip(); RefreshContent()
        end)
        table.insert(tabStripBtns,tb)
    end
end

-- Header buttons
local function MakeHBtn(xOff, icon, hC, onClick)
    local btn=New("TextButton",{
        Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,xOff,0.5,-14),
        BackgroundColor3=C.BG3,BorderSizePixel=0,
        Text=icon,TextSize=12,Font=Enum.Font.GothamBold,
        TextColor3=C.TxM,AutoButtonColor=false,ZIndex=10,
    },header)
    Round(btn,14); Stroke(btn,C.Bord,1)
    btn.MouseEnter:Connect(function() Tween(btn,{BackgroundColor3=hC},0.15) end)
    btn.MouseLeave:Connect(function() Tween(btn,{BackgroundColor3=C.BG3},0.15) end)
    btn.MouseButton1Click:Connect(onClick)
    return btn
end

local closeBtn=MakeHBtn(-10,"✕",C.Red,function()
    Open=false
    Tween(panel,{Size=UDim2.new(0,PW,0,0)},Settings.animSpeed)
    task.delay(Settings.animSpeed+0.05,function()
        panel.Visible=false; sidebarWrap.Visible=false; miniBtn.Visible=true
    end)
end)
local minBtn=MakeHBtn(-46,"─",C.BG5,function()
    Open=false
    Tween(panel,{Size=UDim2.new(0,PW,0,0)},Settings.animSpeed)
    task.delay(Settings.animSpeed+0.05,function()
        panel.Visible=false; sidebarWrap.Visible=false; miniBtn.Visible=true
    end)
end)

-- CONTENT
local contentScroll=New("ScrollingFrame",{
    Size=UDim2.new(1,0,1,-70-32),
    Position=UDim2.new(0,0,0,70),
    BackgroundTransparency=1,BorderSizePixel=0,
    ScrollBarThickness=3,ScrollBarImageColor3=C.AccSoft,
    CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ClipsDescendants=true,
},panelClip)
Pad(contentScroll,nil,8,8,10,10)
List(contentScroll,Enum.FillDirection.Vertical,6)

-- FOOTER
local footer=New("Frame",{
    Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,1,-32),
    BackgroundColor3=C.BG1,BorderSizePixel=0,
},panelClip)
New("Frame",{Size=UDim2.new(1,-24,0,1),Position=UDim2.new(0,12,0,0),
    BackgroundColor3=C.Sep,BorderSizePixel=0},footer)

local footStatus=New("TextLabel",{
    Size=UDim2.new(0.4,0,1,0),Position=UDim2.new(0,14,0,0),
    Text="0 активно",TextSize=10,Font=Enum.Font.Gotham,
    TextColor3=C.TxL,BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Left,
},footer)
local footTab=New("TextLabel",{
    Size=UDim2.new(0.3,0,1,0),Position=UDim2.new(0.35,0,0,0),
    Text="Заработок",TextSize=10,Font=Enum.Font.GothamMedium,
    TextColor3=C.TxM,BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Center,
},footer)
New("TextLabel",{
    Size=UDim2.new(0.3,0,1,0),Position=UDim2.new(0.7,0,0,0),
    Text="RShift",TextSize=10,Font=Enum.Font.Gotham,
    TextColor3=C.TxF,BackgroundTransparency=1,
    TextXAlignment=Enum.TextXAlignment.Right,
},footer)

-- ══════════════════════════════════════════════
-- SIDEBAR NAV BUILD
-- ══════════════════════════════════════════════
function BuildNav()
    for _,b in ipairs(navBtns) do b:Destroy() end
    navBtns={}
    for i=1,4 do
        local isAct=(CurTab==i)
        local tc=TABS[i].color or C.Acc
        local nb=New("TextButton",{
            Size=UDim2.new(0,46,0,46),
            BackgroundColor3=isAct and C.SB2 or C.SB0,
            BorderSizePixel=0,Text="",AutoButtonColor=false,LayoutOrder=i,
        },sideInner)
        Round(nb,15)
        if isAct then Stroke(nb,tc,1.5) end

        New("TextLabel",{Size=UDim2.new(1,0,1,0),Text=NAV_ICONS[i],TextSize=20,
            Font=Enum.Font.GothamBold,TextColor3=isAct and tc or C.TxL,
            BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center},nb)

        if isAct then
            local dot=New("Frame",{Size=UDim2.new(0,5,0,5),Position=UDim2.new(1,-2,0.5,-2.5),
                BackgroundColor3=tc,BorderSizePixel=0},nb)
            Round(dot,3)
        end

        nb.MouseEnter:Connect(function() if not isAct then Tween(nb,{BackgroundColor3=C.SB1},0.15) end end)
        nb.MouseLeave:Connect(function() if not isAct then Tween(nb,{BackgroundColor3=C.SB0},0.15) end end)
        nb.MouseButton1Click:Connect(function() CurTab=i; BuildNav(); BuildTabStrip(); RefreshContent() end)
        table.insert(navBtns,nb)
    end
end

-- ══════════════════════════════════════════════
-- OPTION BUTTONS (for Other tab)
-- ══════════════════════════════════════════════
local function MakeOptionRow(parent, label, options, current, onChange)
    local frame=New("Frame",{Size=UDim2.new(1,0,0,60),BackgroundTransparency=1},parent)
    New("TextLabel",{Size=UDim2.new(1,0,0,18),Text=label,TextSize=10,
        Font=Enum.Font.GothamMedium,TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left},frame)

    local btnRow=New("Frame",{Size=UDim2.new(1,0,0,36),Position=UDim2.new(0,0,0,22),
        BackgroundTransparency=1},frame)
    List(btnRow,Enum.FillDirection.Horizontal,6,Enum.HorizontalAlignment.Left)

    local btns={}
    local function Refresh(sel)
        for _,b in ipairs(btns) do
            local isS=(b.Name==tostring(sel))
            b.BackgroundColor3=isS and C.BG4 or C.BG2
            b.TextColor3=isS and C.Acc or C.TxM
            if b:FindFirstChildOfClass("UIStroke") then
                b:FindFirstChildOfClass("UIStroke").Color=isS and C.Acc or C.Bord
            end
        end
    end

    for _,opt in ipairs(options) do
        local btn=New("TextButton",{
            Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,
            BackgroundColor3=C.BG2,BorderSizePixel=0,
            Text="  "..tostring(opt).."  ",TextSize=11,
            Font=Enum.Font.GothamMedium,TextColor3=C.TxM,
            AutoButtonColor=false,Name=tostring(opt),
        },btnRow)
        Round(btn,10); Stroke(btn,C.Bord,1)
        table.insert(btns,btn)
        btn.MouseButton1Click:Connect(function()
            current=opt; Refresh(opt)
            if onChange then onChange(opt) end
        end)
    end
    Refresh(current)
    return frame
end

local function MakeColorPicker(parent, onChange)
    local frame=New("Frame",{Size=UDim2.new(1,0,0,56),BackgroundTransparency=1},parent)
    New("TextLabel",{Size=UDim2.new(1,0,0,16),Text="Цвет акцента",TextSize=10,
        Font=Enum.Font.GothamMedium,TextColor3=C.TxM,BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left},frame)

    local row=New("Frame",{Size=UDim2.new(1,0,0,34),Position=UDim2.new(0,0,0,20),
        BackgroundTransparency=1},frame)
    List(row,Enum.FillDirection.Horizontal,8,Enum.HorizontalAlignment.Left)

    local colors={
        {key="gold",  col=Color3.fromRGB(220,180,80),  label="Gold"},
        {key="blue",  col=Color3.fromRGB(80,150,240),  label="Blue"},
        {key="green", col=Color3.fromRGB(80,210,110),  label="Green"},
        {key="red",   col=Color3.fromRGB(220,80,80),   label="Red"},
    }

    for _,c in ipairs(colors) do
        local btn=New("TextButton",{
            Size=UDim2.new(0,34,0,34),BackgroundColor3=c.col,
            BorderSizePixel=0,Text="",AutoButtonColor=false,
        },row)
        Round(btn,17)
        if Settings.accentColor==c.key then Stroke(btn,C.White,2) end

        btn.MouseButton1Click:Connect(function()
            ApplyAccent(c.key)
            -- Update accent bar
            accentBar.BackgroundColor3=C.Acc
            Notify("Other","Акцент → "..c.label,C.Acc)
            if onChange then onChange(c.key) end
            -- Rebuild to refresh colors
            BuildNav(); BuildTabStrip()
        end)
    end
    return frame
end

-- ══════════════════════════════════════════════
-- CONTENT BUILDER
-- ══════════════════════════════════════════════
local statusConn=nil

function RefreshContent()
    if statusConn then statusConn:Disconnect(); statusConn=nil end
    for _,c in ipairs(contentScroll:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end

    footTab.Text=NAV_NAMES[CurTab] or "?"
    local tCol=(TABS[CurTab] and TABS[CurTab].color) or C.Acc

    if CurTab<=3 then
        local tab=TABS[CurTab]
        for _,item in ipairs(tab.items) do
            MakeCard(contentScroll, item, tCol)
        end

        local function UpdateFoot()
            if not footStatus or not footStatus.Parent then return end
            local cnt=0
            for _,it in ipairs(tab.items) do if it.state then cnt=cnt+1 end end
            footStatus.Text=cnt.." активно"
            footStatus.TextColor3=cnt>0 and C.Green or C.TxL
        end
        UpdateFoot()
        task.spawn(function()
            while panel.Parent do
                task.wait(1)
                UpdateFoot()
            end
        end)

    else
        -- ── OTHER TAB ─────────────────────────
        footStatus.Text="настройки"
        footStatus.TextColor3=C.TxL

        -- MENU SIZE
        SectionHeader(contentScroll,"РАЗМЕР МЕНЮ")

        local sizeCard=New("Frame",{Size=UDim2.new(1,0,0,130),BackgroundColor3=C.BG2,BorderSizePixel=0},contentScroll)
        Round(sizeCard,16); Stroke(sizeCard,C.Bord,1)
        local sInner=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},sizeCard)
        Pad(sInner,nil,10,10,14,14)
        List(sInner,Enum.FillDirection.Vertical,4)

        MakeSlider(sInner,{label="Ширина меню",min=400,max=900,step=10,val=Settings.menuWidth,
            fmt=function(v) return math.floor(v).."px" end,
            onChange=function(v)
                Settings.menuWidth=v
                Tween(panel,{Size=UDim2.new(0,v,0,Settings.menuHeight)},0.15)
            end})

        MakeSlider(sInner,{label="Высота меню",min=300,max=900,step=10,val=Settings.menuHeight,
            fmt=function(v) return math.floor(v).."px" end,
            onChange=function(v)
                Settings.menuHeight=v
                Tween(panel,{Size=UDim2.new(0,Settings.menuWidth,0,v)},0.15)
            end})

        -- MINI BUTTON SETTINGS
        SectionHeader(contentScroll,"КНОПКА СВЕРНУТЬ")

        local miniCard=New("Frame",{Size=UDim2.new(1,0,0,200),BackgroundColor3=C.BG2,BorderSizePixel=0},contentScroll)
        Round(miniCard,16); Stroke(miniCard,C.Bord,1)
        local mInner=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},miniCard)
        Pad(mInner,nil,10,10,14,14)
        List(mInner,Enum.FillDirection.Vertical,8)

        MakeSlider(mInner,{label="Размер кнопки",min=30,max=100,step=2,val=Settings.miniSize,
            fmt=function(v) return math.floor(v).."px" end,
            onChange=function(v)
                Settings.miniSize=v
                miniBtn.Size=UDim2.new(0,v,0,v)
                Round(miniBtn,v/2)
            end})

        MakeSlider(mInner,{label="Позиция по вертикали",min=0,max=100,step=1,val=math.floor(Settings.miniYPct*100),
            fmt=function(v) return v.."%" end,
            onChange=function(v)
                Settings.miniYPct=v/100
                miniBtn.Position=UDim2.new(0,12,Settings.miniYPct,-Settings.miniSize/2)
            end})

        MakeOptionRow(mInner,"Сторона кнопки",{"left","right"},Settings.miniSide,function(v)
            Settings.miniSide=v
            local xOff=v=="left" and 12 or (workspace.CurrentCamera.ViewportSize.X-Settings.miniSize-12)
            miniBtn.Position=UDim2.new(0,xOff,Settings.miniYPct,-Settings.miniSize/2)
        end)

        MakeOptionRow(mInner,"Форма кнопки",{"round","square"},Settings.miniShape,function(v)
            Settings.miniShape=v
            local r=v=="round" and Settings.miniSize/2 or 10
            if miniBtn:FindFirstChildOfClass("UICorner") then
                miniBtn:FindFirstChildOfClass("UICorner").CornerRadius=UDim.new(0,r)
            end
        end)

        -- ACCENT COLOR
        SectionHeader(contentScroll,"ЦВЕТ АКЦЕНТА")
        local acCard=New("Frame",{Size=UDim2.new(1,0,0,80),BackgroundColor3=C.BG2,BorderSizePixel=0},contentScroll)
        Round(acCard,16); Stroke(acCard,C.Bord,1)
        local acInner=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},acCard)
        Pad(acInner,nil,12,12,14,14)
        MakeColorPicker(acInner,nil)

        -- ANIMATION
        SectionHeader(contentScroll,"АНИМАЦИЯ")
        local animCard=New("Frame",{Size=UDim2.new(1,0,0,70),BackgroundColor3=C.BG2,BorderSizePixel=0},contentScroll)
        Round(animCard,16); Stroke(animCard,C.Bord,1)
        local anInner=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},animCard)
        Pad(anInner,nil,10,10,14,14)
        MakeSlider(anInner,{label="Скорость анимации",min=0.05,max=0.8,step=0.05,val=Settings.animSpeed,
            fmt=function(v) return string.format("%.2f",v).."s" end,
            onChange=function(v) Settings.animSpeed=v end})

        -- HOTKEY INFO
        SectionHeader(contentScroll,"ГОРЯЧАЯ КЛАВИША")
        local hkCard=New("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=C.BG3,BorderSizePixel=0},contentScroll)
        Round(hkCard,14); Stroke(hkCard,C.AccLine,1)
        New("TextLabel",{Size=UDim2.new(1,0,1,0),
            Text="RIGHT SHIFT  ·  Скрыть / Показать меню",
            TextSize=12,Font=Enum.Font.GothamMedium,TextColor3=C.Acc,
            BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Center},hkCard)

        -- STATUS
        SectionHeader(contentScroll,"АКТИВНОСТЬ")
        for ti=1,3 do
            local t=TABS[ti]; local cnt=0
            for _,it in ipairs(t.items) do if it.state then cnt=cnt+1 end end
            local tC=t.color or C.Acc
            local row=New("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=C.BG2,BorderSizePixel=0},contentScroll)
            Round(row,12)
            New("Frame",{Size=UDim2.new(0,3,0,20),Position=UDim2.new(0,8,0.5,-10),
                BackgroundColor3=tC,BorderSizePixel=0},row)
            New("TextLabel",{Size=UDim2.new(0,90,1,0),Position=UDim2.new(0,16,0,0),
                Text=NAV_ICONS[ti].." "..t.name,TextSize=11,Font=Enum.Font.GothamMedium,
                TextColor3=C.TxM,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left},row)
            local bW=Settings.menuWidth-230
            local tr=New("Frame",{Size=UDim2.new(0,bW,0,8),Position=UDim2.new(0,100,0.5,-4),
                BackgroundColor3=C.SlTrack,BorderSizePixel=0},row)
            Round(tr,4)
            if cnt>0 then
                local fi=New("Frame",{Size=UDim2.new(cnt/#t.items,0,1,0),BackgroundColor3=tC,BorderSizePixel=0},tr)
                Round(fi,4)
            end
            New("TextLabel",{Size=UDim2.new(0,50,1,0),Position=UDim2.new(1,-55,0,0),
                Text=cnt.."/"..#t.items,TextSize=10,Font=Enum.Font.Gotham,
                TextColor3=C.TxL,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right},row)
        end
    end
end

-- ══════════════════════════════════════════════
-- OPEN/CLOSE
-- ══════════════════════════════════════════════
local function ShowUI()
    Open=true; miniBtn.Visible=false
    panel.Visible=true; sidebarWrap.Visible=true
    panel.Size=UDim2.new(0,Settings.menuWidth,0,0)
    Tween(panel,{Size=UDim2.new(0,Settings.menuWidth,0,Settings.menuHeight)},Settings.animSpeed)
end

local function HideUI()
    Open=false
    Tween(panel,{Size=UDim2.new(0,Settings.menuWidth,0,0)},Settings.animSpeed)
    task.delay(Settings.animSpeed+0.05,function()
        panel.Visible=false; sidebarWrap.Visible=false; miniBtn.Visible=true
    end)
end

miniBtn.MouseButton1Click:Connect(ShowUI)

UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.RightShift then
        if Open then HideUI() else ShowUI() end
    end
end)

-- DRAG
local dragging=false; local dragStart; local startPos
header.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true; dragStart=inp.Position; startPos=panel.Position
    end
end)
UIS.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
        local d=inp.Position-dragStart
        panel.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        task.defer(function()
            if not panel.Parent then return end
            local px=panel.AbsolutePosition.X; local py=panel.AbsolutePosition.Y
            local ph=panel.AbsoluteSize.Y; local sh=sidebarWrap.AbsoluteSize.Y
            sidebarWrap.Position=UDim2.new(0,px-82,0,py+math.floor((ph-sh)/2))
        end)
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

-- RESPAWN
LP.CharacterAdded:Connect(function()
    task.wait(1)
    if AutoDrive.active then StopAutoDrive()
        for _,item in ipairs(TABS[1].items) do
            if item.isAutoDrive then item.state=false end
        end
    end
    for _,tab in ipairs(TABS) do
        for _,item in ipairs(tab.items) do
            if item.state and not item.isAutoDrive then pcall(item.enable,item) end
        end
    end
end)

-- INIT
BuildNav()
BuildTabStrip()
RefreshContent()

task.defer(function()
    local px=panel.AbsolutePosition.X; local py=panel.AbsolutePosition.Y
    local ph=panel.AbsoluteSize.Y; local sh=sidebarWrap.AbsoluteSize.Y
    sidebarWrap.Position=UDim2.new(0,px-82,0,py+math.floor((ph-sh)/2))
end)

Notify("LUXURY HUB","Загружен для Car Dealership Tycoon!",C.Acc)
print("LUXURY HUB v22 CDT - OK") 
