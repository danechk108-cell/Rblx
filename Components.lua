-- Components.lua - Reusable UI building blocks
local Core = require(script.Parent.Core)
local C = Core.C
local Components = {}

-- ══════════════════════════════════════════════
-- LABEL
-- ══════════════════════════════════════════════
function Components.Label(parent, text, size, color, props)
    return Core.New("TextLabel", {
        Text               = text or "",
        TextSize           = size or 14,
        TextColor3         = color or C.TxH,
        Font               = Enum.Font.GothamMedium,
        BackgroundTransparency = 1,
        TextXAlignment     = Enum.TextXAlignment.Left,
        TextYAlignment     = Enum.TextYAlignment.Center,
        Size               = UDim2.new(1,0,0,size and size+4 or 18),
        RichText           = true,
    }, parent)
end

-- ══════════════════════════════════════════════
-- FRAME (rounded)
-- ══════════════════════════════════════════════
function Components.Frame(parent, props)
    local f = Core.New("Frame", {
        BackgroundColor3   = C.BG2,
        BorderSizePixel    = 0,
        Size               = UDim2.new(1,0,0,40),
    }, parent)
    -- Apply custom props
    for k,v in pairs(props or {}) do
        f[k] = v
    end
    return f
end

-- ══════════════════════════════════════════════
-- TOGGLE SWITCH
-- ══════════════════════════════════════════════
function Components.Toggle(parent, state, callback)
    local W,H = 52,28

    local container = Core.New("Frame", {
        Size = UDim2.new(0,W,0,H),
        BackgroundTransparency = 1,
    }, parent)

    local track = Core.New("Frame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundColor3 = state and C.Acc or C.SlTrack,
        BorderSizePixel = 0,
    }, container)
    Core.Round(track, H/2)

    local knob = Core.New("Frame", {
        Size = UDim2.new(0,H-8,0,H-8),
        Position = state and UDim2.new(1,-(H-4),0.5,-((H-8)/2))
                          or UDim2.new(0,4,       0.5,-((H-8)/2)),
        BackgroundColor3 = C.White,
        BorderSizePixel = 0,
    }, track)
    Core.Round(knob, (H-8)/2)

    -- Shadow under knob
    local shadow = Core.New("UIStroke", {
        Color     = Color3.fromRGB(0,0,0),
        Thickness = 1,
        Transparency = 0.6,
    }, knob)

    local on = state or false

    local function SetState(newState, animate)
        on = newState
        local trackCol  = on and C.Acc or C.SlTrack
        local knobPos   = on
            and UDim2.new(1,-(H-4),0.5,-((H-8)/2))
            or  UDim2.new(0,4,     0.5,-((H-8)/2))

        if animate then
            Core.Tween(track, {BackgroundColor3=trackCol}, 0.18)
            Core.Tween(knob,  {Position=knobPos},          0.18)
        else
            track.BackgroundColor3 = trackCol
            knob.Position = knobPos
        end
    end

    -- Click handler
    local btn = Core.New("TextButton", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 10,
    }, container)

    btn.MouseButton1Click:Connect(function()
        SetState(not on, true)
        if callback then callback(on) end
    end)

    return container, {
        SetState = SetState,
        GetState = function() return on end,
        Track = track,
        Knob  = knob,
    }
end

-- ══════════════════════════════════════════════
-- SLIDER
-- ══════════════════════════════════════════════
function Components.Slider(parent, opts)
    -- opts: {min, max, step, val, width, fmt, onChange}
    local min   = opts.min  or 0
    local max   = opts.max  or 100
    local step  = opts.step or 1
    local val   = opts.val  or min
    local W     = opts.width or 200
    local fmt   = opts.fmt or function(v) return tostring(v) end

    local container = Core.New("Frame", {
        Size = UDim2.new(1,0,0,36),
        BackgroundTransparency = 1,
    }, parent)

    -- Track
    local track = Core.New("Frame", {
        Size = UDim2.new(1,-48,0,8),
        Position = UDim2.new(0,24,0.5,-4),
        BackgroundColor3 = C.SlTrack,
        BorderSizePixel = 0,
    }, container)
    Core.Round(track, 4)

    -- Fill
    local fill = Core.New("Frame", {
        Size = UDim2.new(0,0,1,0),
        BackgroundColor3 = C.Acc,
        BorderSizePixel = 0,
    }, track)
    Core.Round(fill, 4)

    -- Knob
    local knob = Core.New("Frame", {
        Size = UDim2.new(0,20,0,20),
        Position = UDim2.new(0,-10,0.5,-10),
        BackgroundColor3 = C.Acc,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, fill)
    Core.Round(knob, 10)
    Core.New("Frame", {
        Size = UDim2.new(0,10,0,10),
        Position = UDim2.new(0.5,-5,0.5,-5),
        BackgroundColor3 = C.White,
        BorderSizePixel = 0,
    }, knob)
    Core.Round(knob.Frame, 5)

    -- Value label
    local valLbl = Core.New("TextLabel", {
        Size = UDim2.new(0,40,1,0),
        Position = UDim2.new(1,-40,0,0),
        Text = fmt(val),
        TextSize = 11,
        TextColor3 = C.Acc,
        Font = Enum.Font.GothamMedium,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, container)

    local function UpdateVisual(v, animate)
        local pct = (v - min) / (max - min)
        local fw = UDim2.new(pct, 0, 1, 0)
        if animate then
            Core.Tween(fill, {Size=fw}, 0.05)
        else
            fill.Size = fw
        end
        valLbl.Text = fmt(v)
    end

    UpdateVisual(val, false)

    local dragging = false

    local function OnInput(x)
        local abs = track.AbsolutePosition.X
        local sz  = track.AbsoluteSize.X
        local pct = math.max(0, math.min(1, (x - abs) / sz))
        local raw = min + pct * (max - min)
        local snapped = math.floor(raw / step + 0.5) * step
        snapped = math.max(min, math.min(max, snapped))
        if snapped ~= val then
            val = snapped
            UpdateVisual(val, false)
            if opts.onChange then opts.onChange(val) end
        end
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            OnInput(inp.Position.X)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(inp)
        if dragging then
            if inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch then
                OnInput(inp.Position.X)
            end
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return container, {
        GetValue = function() return val end,
        SetValue = function(v, anim)
            val = math.max(min, math.min(max, v))
            UpdateVisual(val, anim)
        end,
    }
end

-- ══════════════════════════════════════════════
-- ICON BUTTON (sidebar nav)
-- ══════════════════════════════════════════════
function Components.NavButton(parent, icon, active, onClick)
    local SZ = 48

    local btn = Core.New("TextButton", {
        Size = UDim2.new(0,SZ,0,SZ),
        BackgroundColor3 = active and C.SB2 or C.SB0,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, parent)
    Core.Round(btn, 16)
    if active then Core.Stroke(btn, C.Acc, 1.5) end

    -- Icon label (emoji or text icon)
    Core.New("TextLabel", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text = icon,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        TextColor3 = active and C.Acc or C.TxL,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, btn)

    -- Active dot
    if active then
        local dot = Core.New("Frame", {
            Size = UDim2.new(0,5,0,5),
            Position = UDim2.new(1,-3,0.5,-2.5),
            BackgroundColor3 = C.Acc,
            BorderSizePixel = 0,
        }, btn)
        Core.Round(dot, 3)
    end

    btn.MouseButton1Click:Connect(onClick or function() end)

    btn.MouseEnter:Connect(function()
        if not active then
            Core.Tween(btn, {BackgroundColor3=C.SB1}, 0.15)
        end
    end)
    btn.MouseLeave:Connect(function()
        if not active then
            Core.Tween(btn, {BackgroundColor3=C.SB0}, 0.15)
        end
    end)

    return btn
end

-- ══════════════════════════════════════════════
-- FEATURE CARD
-- ══════════════════════════════════════════════
function Components.Card(parent, item, onToggle)
    local C2 = Core.C

    local card = Core.New("Frame", {
        Size = UDim2.new(1,0,0,52),
        BackgroundColor3 = C2.BG2,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, parent)
    Core.Round(card, 18)
    local stroke = Core.Stroke(card, C2.Bord, 1)

    -- Left accent bar
    local bar = Core.New("Frame", {
        Size = UDim2.new(0,3,0,28),
        Position = UDim2.new(0,10,0.5,-14),
        BackgroundColor3 = C2.Acc,
        BorderSizePixel = 0,
        Visible = item.state,
    }, card)
    Core.Round(bar, 2)

    -- Text container
    local textFrame = Core.New("Frame", {
        Size = UDim2.new(1,-120,1,0),
        Position = UDim2.new(0,24,0,0),
        BackgroundTransparency = 1,
    }, card)

    Core.New("TextLabel", {
        Size = UDim2.new(1,0,0,26),
        Position = UDim2.new(0,0,0,8),
        Text = item.label,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        TextColor3 = item.state and C2.TxW or C2.TxH,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, textFrame)

    Core.New("TextLabel", {
        Size = UDim2.new(1,0,0,16),
        Position = UDim2.new(0,0,0,28),
        Text = item.desc,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextColor3 = item.state and C2.TxM or C2.TxL,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, textFrame)

    -- Toggle
    local tgFrame, tgCtrl = Components.Toggle(card, item.state, function(state)
        item.state = state
        if state then
            Core.Tween(card,  {BackgroundColor3=C2.BG4}, 0.2)
            stroke.Color = C2.BordA
            bar.Visible  = true
            Core.Tween(bar, {BackgroundColor3=C2.Acc}, 0.1)
            textFrame:FindFirstChild("TextLabel").TextColor3 = C2.TxW
            if onToggle then onToggle(state, item) end
        else
            Core.Tween(card,  {BackgroundColor3=C2.BG2}, 0.2)
            stroke.Color = C2.Bord
            bar.Visible  = false
            textFrame:FindFirstChild("TextLabel").TextColor3 = C2.TxH
            if onToggle then onToggle(state, item) end
        end
    end)

    tgFrame.Position = UDim2.new(1,-64,0.5,-14)

    -- Param panel (hidden by default)
    local paramPanel = nil
    if item.param then
        paramPanel = Core.New("Frame", {
            Size = UDim2.new(1,0,0,0),
            BackgroundColor3 = Color3.fromRGB(10,11,20),
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Visible = false,
        }, card)

        Core.Stroke(paramPanel, C2.AccLine, 1)
        Core.Pad(paramPanel, nil, 10, 10, 14, 14)

        local pp = item.param
        local pLabel = Core.New("TextLabel", {
            Size = UDim2.new(1,0,0,18),
            Text = pp.label,
            TextSize = 10,
            Font = Enum.Font.GothamMedium,
            TextColor3 = C2.TxM,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, paramPanel)

        local sliderFrame, sliderCtrl = Components.Slider(paramPanel, {
            min = pp.min, max = pp.max,
            step = pp.step, val = pp.val,
            fmt = pp.fmt,
            onChange = function(v)
                pp.val = v
                if pp.apply and item.state then pp.apply(v, item) end
            end,
        })
        sliderFrame.Position = UDim2.new(0,0,0,22)

        -- Show/hide param panel when toggled
        local function ShowParam(show)
            if show then
                paramPanel.Visible = true
                Core.Tween(paramPanel, {Size=UDim2.new(1,0,0,68)}, 0.2)
                Core.Tween(card,       {Size=UDim2.new(1,0,0,128)}, 0.2)
            else
                Core.Tween(paramPanel, {Size=UDim2.new(1,0,0,0)},  0.15, nil, nil)
                Core.Tween(card,       {Size=UDim2.new(1,0,0,52)}, 0.15)
                task.delay(0.16, function()
                    if not item.state then paramPanel.Visible=false end
                end)
            end
        end

        -- Override toggle callback to also show param
        tgCtrl.Track:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
            ShowParam(tgCtrl.GetState())
        end)
    end

    -- Hover effect
    local hitbox = Core.New("TextButton", {
        Size = UDim2.new(1,0,0,52),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 5,
    }, card)

    hitbox.MouseEnter:Connect(function()
        if not item.state then
            Core.Tween(card, {BackgroundColor3=C2.BG3}, 0.15)
            stroke.Color = C2.BordH
        end
    end)
    hitbox.MouseLeave:Connect(function()
        if not item.state then
            Core.Tween(card, {BackgroundColor3=C2.BG2}, 0.15)
            stroke.Color = C2.Bord
        end
    end)

    return card
end

return Components
