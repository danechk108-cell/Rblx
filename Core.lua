-- Core.lua - LUXURY HUB v20
-- Modular UI System using ScreenGui

local Core = {}

-- Services
Core.UIS     = game:GetService("UserInputService")
Core.RS      = game:GetService("RunService")
Core.TW      = game:GetService("TweenService")
Core.Players = game:GetService("Players")
Core.LP      = Core.Players.LocalPlayer

-- Try to get protected GUI container
local function GetGUI()
    local gui
    pcall(function()
        gui = gethui()
    end)
    if not gui then
        pcall(function()
            gui = game:GetService("CoreGui")
        end)
    end
    if not gui then
        gui = Core.LP.PlayerGui
    end
    return gui
end

Core.GuiRoot = GetGUI()

-- Destroy old instance if exists
local old = Core.GuiRoot:FindFirstChild("LuxuryHub")
if old then old:Destroy() end

-- Create ScreenGui
Core.Screen = Instance.new("ScreenGui")
Core.Screen.Name = "LuxuryHub"
Core.Screen.ResetOnSpawn = false
Core.Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Core.Screen.IgnoreGuiInset = true
Core.Screen.Parent = Core.GuiRoot

-- Utility: Create instance with properties
function Core.New(class, props, parent)
    local inst = Instance.new(class)
    for k,v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

-- Utility: Tween
function Core.Tween(inst, props, t, style, dir)
    local info = TweenInfo.new(
        t or 0.2,
        style or Enum.EasingStyle.Quart,
        dir or Enum.EasingDirection.Out
    )
    local tw = Core.TW:Create(inst, info, props)
    tw:Play()
    return tw
end

-- Utility: Round corner via UICorner
function Core.Round(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = inst
    return c
end

-- Utility: Stroke/border
function Core.Stroke(inst, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(50,50,80)
    s.Thickness = thickness or 1.5
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
    return s
end

-- Utility: Gradient
function Core.Gradient(inst, c0, c1, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c0, c1)
    g.Rotation = rotation or 90
    g.Parent = inst
    return g
end

-- Utility: Padding
function Core.Pad(inst, all, top, bot, left, right)
    local p = Instance.new("UIPadding")
    if all then
        p.PaddingTop    = UDim.new(0, all)
        p.PaddingBottom = UDim.new(0, all)
        p.PaddingLeft   = UDim.new(0, all)
        p.PaddingRight  = UDim.new(0, all)
    else
        if top   then p.PaddingTop    = UDim.new(0, top)   end
        if bot   then p.PaddingBottom = UDim.new(0, bot)   end
        if left  then p.PaddingLeft   = UDim.new(0, left)  end
        if right then p.PaddingRight  = UDim.new(0, right) end
    end
    p.Parent = inst
    return p
end

-- Utility: List layout
function Core.List(inst, dir, pad, align)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Padding = UDim.new(0, pad or 6)
    l.HorizontalAlignment = align or Enum.HorizontalAlignment.Left
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = inst
    return l
end

-- Color palette
Core.C = {
    BG0     = Color3.fromRGB(8,   9,  14),
    BG1     = Color3.fromRGB(13,  14, 22),
    BG2     = Color3.fromRGB(18,  20, 32),
    BG3     = Color3.fromRGB(23,  25, 40),
    BG4     = Color3.fromRGB(28,  30, 50),
    SB0     = Color3.fromRGB(11,  12, 20),
    SB1     = Color3.fromRGB(20,  22, 38),
    SB2     = Color3.fromRGB(26,  28, 50),
    Acc     = Color3.fromRGB(147,100,255),
    Acc2    = Color3.fromRGB(120, 75,220),
    Acc3    = Color3.fromRGB(80,  45,160),
    AccLine = Color3.fromRGB(70,  45,140),
    AccSoft = Color3.fromRGB(55,  35,110),
    AccDim  = Color3.fromRGB(35,  22, 75),
    TxW     = Color3.fromRGB(245,245,255),
    TxH     = Color3.fromRGB(200,202,230),
    TxM     = Color3.fromRGB(130,133,170),
    TxL     = Color3.fromRGB(70,  73,105),
    TxF     = Color3.fromRGB(40,  43, 65),
    Bord    = Color3.fromRGB(32,  34, 55),
    BordA   = Color3.fromRGB(90,  60,190),
    BordH   = Color3.fromRGB(55,  58, 88),
    Sep     = Color3.fromRGB(25,  27, 45),
    Green   = Color3.fromRGB(80, 220,140),
    Red     = Color3.fromRGB(230, 75, 80),
    White   = Color3.fromRGB(255,255,255),
    Black   = Color3.fromRGB(0,   0,   0),
    SlTrack = Color3.fromRGB(22,  24, 40),
}

return Core
