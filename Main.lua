-- Luxury VisionOS/Discord-style UI (Drawing API)
-- Tabs: Main / Player / Other / Settings
-- Toggles: TEST-1..TEST-9 per Main/Player/Other

local UIS = game:GetService("UserInputService")
local RS  = game:GetService("RunService")

-------------------------------------------------------
-- Config / State
-------------------------------------------------------
local CFG = {
	-- Window
	W = 560,
	H = 430,
	X = 420, -- initial screen position
	Y = 110,

	HeaderH = 64,

	-- Detached nav pill
	NavW = 68,
	NavH = 330,
	NavGap = 18, -- distance from window to nav
	NavTopOffset = 86,

	-- Mini button (when closed)
	MiniW = 44,
	MiniH = 80,
	MiniGap = 10, -- from screen edge
	MiniSide = "left", -- "left" | "right"
	MiniY = 0.25,     -- 0..1 vertical position

	-- Toggle key
	ToggleKey = Enum.KeyCode.RightShift,

	-- Visual controls
	Bloom = true,
	BloomAmount = 0.9,     -- 0..1
	NeonPulse = true,

	-- Layout
	ItemsGap = 8,
	CardR = 18,
	NavR = 24,

	-- Animation
	AnimSpeed = 7,         -- open/close + general lerp
	ToggleSpeed = 10,      -- switch lerp
	TabSpeed = 12,

	-- Glass
	GlassAlpha = 0.55,     -- base alpha
	BorderAlpha = 0.55,
}

local S = {
	Open = true,
	OpenAnim = 1, -- 0..1

	-- 1..4 tabs (4=Settings)
	Tab = 1,
	TabAnim = {0,0,0,0},

	-- Drag
	Dragging = false,
	DragOff = Vector2.new(0,0),

	-- Hover
	Hover = nil,

	-- mini
	MiniHover = false,
	DraggingMiniSlider = false,

	-- Keybind capture
	WaitKey = false,

	-- Window position (mutable)
	X = CFG.X,
	Y = CFG.Y,

	-- Toggles: [tab][1..9] = bool
	T = {},
	AnimToggle = {},
}

for t=1,4 do
	S.T[t] = {}
	S.AnimToggle[t] = {}
	for i=1,9 do
		S.T[t][i] = false
		S.AnimToggle[t][i] = 0
	end
end

S.TabAnim[1]=1

-------------------------------------------------------
-- Drawing pool (performance friendly)
-------------------------------------------------------
local Pool = {}
local PoolIdx = 0

local function beginFrame()
	PoolIdx = 0
end

local function getDraw(typeName)
	PoolIdx += 1
	local d = Pool[PoolIdx]
	if (not d) or d.__type ~= typeName then
		if d then pcall(function() d:Remove() end) end
		d = Drawing.new(typeName)
		d.__type = typeName
		Pool[PoolIdx] = d
	end
	d.Visible = true
	return d
end

local function endFrame()
	for i = PoolIdx + 1, #Pool do
		Pool[i].Visible = false
	end
end

-------------------------------------------------------
-- Basic primitives
-------------------------------------------------------
local function Sq(x,y,w,h,col,a,filled,thick)
	local d = getDraw("Square")
	d.Position = Vector2.new(x,y)
	d.Size = Vector2.new(w,h)
	d.Color = col or Color3.new(1,1,1)
	d.Transparency = a or 1
	d.Filled = (filled ~= false)
	d.Thickness = thick or 1
	return d
end

local function Ln(x1,y1,x2,y2,col,a,thick)
	local d = getDraw("Line")
	d.From = Vector2.new(x1,y1)
	d.To = Vector2.new(x2,y2)
	d.Color = col or Color3.new(1,1,1)
	d.Transparency = a or 1
	d.Thickness = thick or 1
	return d
end

local function Ci(x,y,r,col,a,filled,thick)
	local d = getDraw("Circle")
	d.Position = Vector2.new(x,y)
	d.Radius = r
	d.Color = col or Color3.new(1,1,1)
	d.Transparency = a or 1
	d.Filled = (filled ~= false)
	d.Thickness = thick or 1
	return d
end

local function Tx(x,y,text,col,size,center,outline,outCol)
	local d = getDraw("Text")
	d.Position = Vector2.new(x,y)
	d.Text = tostring(text or "")
	d.Color = col or Color3.new(1,1,1)
	d.Size = size or 14
	d.Center = center or false
	d.Outline = (outline == true)
	d.OutlineColor = outCol or Color3.new(0,0,0)
	d.Transparency = 1
	return d
end

local function Tri(a,b,c,col,aT,filled,thick)
	local d = getDraw("Triangle")
	d.PointA = a
	d.PointB = b
	d.PointC = c
	d.Color = col or Color3.new(1,1,1)
	d.Transparency = aT or 1
	d.Filled = (filled ~= false)
	d.Thickness = thick or 1
	return d
end

-------------------------------------------------------
-- Math / helpers
-------------------------------------------------------
local function Clamp(v, mn, mx) return math.max(mn, math.min(mx, v)) end
local function Lerp(a,b,t) return a + (b-a)*t end
local function EaseOut(t) return 1 - (1-t)*(1-t)*(1-t) end

local function MousePos()
	local m = UIS:GetMouseLocation()
	return m.X, m.Y
end

local function HoverRect(x,y,w,h)
	local mx,my = MousePos()
	return mx >= x and mx <= x+w and my >= y and my <= y+h
end

local function RoundRectFill(x,y,w,h,col,a,r)
	r = r or 10
	r = math.min(r, math.floor(math.min(w,h)/2))
	-- center
	if w - 2*r > 0 then Sq(x+r, y, w-2*r, h, col, a, true) end
	-- sides
	if h - 2*r > 0 then
		Sq(x, y+r, r, h-2*r, col, a, true)
		Sq(x+w-r, y+r, r, h-2*r, col, a, true)
	end
	-- corners
	Ci(x+r, y+r, r, col, a, true)
	Ci(x+w-r, y+r, r, col, a, true)
	Ci(x+r, y+h-r, r, col, a, true)
	Ci(x+w-r, y+h-r, r, col, a, true)
end

local function RoundRectBorder(x,y,w,h,col,a,r,thick)
	r = r or 10
	r = math.min(r, math.floor(math.min(w,h)/2))
	thick = thick or 1

	-- straight sides
	Ln(x+r, y, x+w-r, y, col, a, thick)
	Ln(x+r, y+h, x+w-r, y+h, col, a, thick)
	Ln(x, y+r, x, y+h-r, col, a, thick)
	Ln(x+w, y+r, x+w, y+h-r, col, a, thick)

	-- corner outlines (approx)
	Ci(x+r, y+r, r, col, a, false, thick)
	Ci(x+w-r, y+r, r, col, a, false, thick)
	Ci(x+r, y+h-r, r, col, a, false, thick)
	Ci(x+w-r, y+h-r, r, col, a, false, thick)
end

local function GlowRound(x,y,w,h,col,alpha,r,layers)
	layers = layers or 6
	for i = layers, 1, -1 do
		local pad = (i*2)
		local a = alpha * (i/layers) * 0.45
		RoundRectFill(x-pad, y-pad, w+pad*2, h+pad*2, col, a, r+pad*0.12)
	end
end

-------------------------------------------------------
-- Monochrome icon drawing (simple vector shapes)
-------------------------------------------------------
local ICON_COL_ON  = Color3.fromRGB(255,255,255)
local ICON_COL_OFF = Color3.fromRGB(145,145,165)

local function IconHome(cx,cy,scale,col,a)
	-- roof
	Tri(Vector2.new(cx,cy-10*scale), Vector2.new(cx-10*scale,cy+2*scale), Vector2.new(cx+10*scale,cy+2*scale), col, a, true)
	-- body
	RoundRectFill(cx-7*scale, cy+2*scale, 14*scale, 10*scale, col, a, 3*scale)
	-- door
	RoundRectFill(cx-2.3*scale, cy+6*scale, 4.6*scale, 6.5*scale, Color3.fromRGB(30,30,40), a*0.9, 2*scale)
end

local function IconPerson(cx,cy,scale,col,a)
	Ci(cx, cy-6*scale, 5*scale, col, a, true)
	RoundRectFill(cx-9*scale, cy-1*scale, 18*scale, 14*scale, col, a, 7*scale)
end

local function IconGroup(cx,cy,scale,col,a)
	Ci(cx-7*scale, cy-6*scale, 5*scale, col, a, true)
	Ci(cx+7*scale, cy-6*scale, 5*scale, col, a, true)
	RoundRectFill(cx-12*scale, cy-1*scale, 24*scale, 15*scale, col, a, 10*scale)
end

local function IconGear(cx,cy,scale,col,a,t)
	-- tiny gear dots
	local teeth = 8
	for i=0,teeth-1 do
		local ang = (i/teeth)*math.pi*2 + (t or 0)
		local rx = math.cos(ang)*(10*scale)
		local ry = math.sin(ang)*(10*scale)
		Sq(cx+rx-2*scale, cy+ry-2*scale, 4*scale, 4*scale, col, a, true)
	end
	Ci(cx,cy,7*scale,col,a,true)
	Ci(cx,cy,3.2*scale,Color3.fromRGB(15,15,24),a,true)
end

local function DrawNavIcon(i, cx, cy, active, t)
	local scale = 1.0
	local col = active and ICON_COL_ON or ICON_COL_OFF
	local a = active and 1 or 0.85
	if i==1 then IconHome(cx,cy,scale,col,a)
	elseif i==2 then IconPerson(cx,cy,scale,col,a)
	elseif i==3 then IconGroup(cx,cy,scale,col,a)
	elseif i==4 then IconGear(cx,cy,scale,col,a, t*0.8)
	end
end

-------------------------------------------------------
-- iOS toggle (smooth)
-------------------------------------------------------
local function iOSToggle(x,y,w,h, tAnim, neonOn, a)
	-- w x h is track size
	-- tAnim: 0..1
	local anim = Clamp(tAnim,0,1)

	local trackW, trackH = w, h
	local r = trackH/2

	-- colors (monochrome-ish + neon for ON)
	local neon = Color3.fromRGB(88, 110, 255)
	local off   = Color3.fromRGB(52, 55, 78)
	local mid   = Color3.fromRGB(40, 42, 62)

	local onCol = neon
	local offCol = off

	local lerpCol = Color3.new(
		Lerp(offCol.R/255, onCol.R/255, anim),
		Lerp(offCol.G/255, onCol.G/255, anim),
		Lerp(offCol.B/255, onCol.B/255, anim)
	)

	-- bloom behind (premium)
	if CFG.Bloom and neonOn and anim > 0.03 then
		local bloomA = a * CFG.BloomAmount * (0.12 + 0.20*anim)
		GlowRound(x-10, y-4, trackW+20, trackH+8, neon, bloomA, r, 4)
	end

	-- track
	RoundRectFill(x, y, trackW, trackH, lerpCol, a, r)

	-- subtle border
	local borderCol = active and neon or mid
	RoundRectBorder(x, y, trackW, trackH, onCol, a*0.25*anim + a*0.10*(1-anim), r, 1)

	-- knob
	local knobR = trackH/2 - 2
	local knobX = x + 2 + (trackW - trackH + 4)*anim
	-- knob shine
	Ci(knobX+knobR, y+knobR, knobR, Color3.fromRGB(255,255,255), a, true)

	Ci(knobX+knobR-1.2, y+knobR-1.2, knobR*0.45, Color3.fromRGB(255,255,255), a*0.55, true)
end

-------------------------------------------------------
-- Layout helpers (must match render)
-------------------------------------------------------
local function Layout()
	local wx, wy = S.X, S.Y
	local W, H = CFG.W, CFG.H

	local headerH = CFG.HeaderH

	local navX = wx - CFG.NavW - CFG.NavGap
	local navY = wy + CFG.NavTopOffset
	local navW = CFG.NavW
	local navH = CFG.NavH
	local navR  = CFG.NavR

	local contentX = wx + 16
	local contentY = wy + headerH + 12
	local contentW = W - 32
	local contentH = H - headerH - 22

	return {
		wx=wx, wy=wy, W=W, H=H,
		headerH=headerH,
		navX=navX, navY=navY, navW=navW, navH=navH, navR=navR,
		contentX=contentX, contentY=contentY, contentW=contentW, contentH=contentH,
	}
end

local function TabIconRects()
	local L = Layout()
	-- 4 icons vertical; settings at bottom
	local bx = L.navX
	local by = L.navY
	local bw = L.navW
	local bh = L.navH

	local pad = 10
	local iconBoxH = (bh - pad*2) / 4

	local rects = {}
	for i=1,4 do
		local ix = bx + 6
		local iy = by + pad + (i-1)*iconBoxH + 6
		local iw = bw - 12
		local ih = 44
		rects[i] = {x=ix,y=iy,w=iw,h=ih}
	end
	-- better: settings at bottom
	rects[4].y = by + bh - pad - 44
	return rects
end

local function ToggleItemRects(tab)
	local L = Layout()
	local cx = L.contentX
	local cy = L.contentY

	local cardR = CFG.CardR
	local itemH = 52
	local gap = CFG.ItemsGap

	-- list start
	local startY = cy + 10

	local rects = {}
	for i=1,9 do
		local iy = startY + (i-1)*(itemH+gap)
		rects[i] = {x=cx, y=iy, w=L.contentW, h=itemH}
	end
	return rects
end

local function MiniButtonRect()
	local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
	local mx,my = vp.X, vp.Y

	local y = math.floor(my * CFG.MiniY - CFG.MiniH/2)
	y = Clamp(y, 8, my - CFG.MiniH - 8)

	local x
	if CFG.MiniSide == "left" then
		x = CFG.MiniGap
	else
		x = mx - CFG.MiniW - CFG.MiniGap
	end

	return {x=x,y=y,w=CFG.MiniW,h=CFG.MiniH}
end

-------------------------------------------------------
-- Render
-------------------------------------------------------
local colors = {
	bgTop = Color3.fromRGB(10, 10, 16),
	bgBot = Color3.fromRGB(14, 14, 22),
	glass = Color3.fromRGB(25, 25, 40),
	border = Color3.fromRGB(70, 70, 110),
	sep = Color3.fromRGB(30, 30, 52),

	neon = Color3.fromRGB(96, 70, 255),
	neon2= Color3.fromRGB(70, 170, 255),

	text = Color3.fromRGB(235,235,255),
	sub  = Color3.fromRGB(140,140,175),
	dotOff = Color3.fromRGB(65,65,95),
	ok = Color3.fromRGB(115, 240, 170),
}

local function DrawHeader(L, a)
	-- Header glass + neon edge
	local X,Y,W,H = L.wx, L.wy, L.W, L.headerH

	-- background glass layers
	RoundRectFill(X, Y, W, H, colors.glass, 0.75*a, 14)
	RoundRectFill(X+1, Y+1, W-2, H-2, Color3.fromRGB(18,18,32), 0.45*a, 14)

	-- neon top stripe
	local pulse = CFG.NeonPulse and (0.6 + 0.4*math.sin(S.Tick*2.2)) or 1
	RoundRectFill(X+6, Y+4, W-12, 2, colors.neon, 0.35*a*pulse, 1)
	RoundRectFill(X+6, Y+6, W-12, 1, colors.neon2, 0.35*a*pulse, 1)

	-- Title
	local logoX = X + 18
	local logoY = Y + 16
	RoundRectFill(logoX, logoY, 28, 28, colors.neon, 0.9*a, 10)
	RoundRectFill(logoX+7, logoY+7, 14, 14, Color3.fromRGB(20,20,30), 0.6*a, 6)

	Tx(X+58, Y+14, "LUXURY UI", colors.text, 18, false, false)
	Tx(X+58, Y+34, "PREMIUM CONTROLS", colors.sub, 11, false, true, Color3.fromRGB(0,0,0))

	-- Close / Min buttons (right)
	local btnS = 30
	local pad = 12
	local bx3 = X + W - pad - btnS*0
	-- We'll place: min at x2, close at x3
	local closeX = X + W - pad - btnS
	local minX = closeX - btnS - 8
	local btnY = Y + 16

	local hoverClose = HoverRect(closeX, btnY, btnS, btnS)
	local hoverMin   = HoverRect(minX, btnY, btnS, btnS)

	-- min (decor)
	RoundRectFill(minX, btnY, btnS, btnS, Color3.fromRGB(22,22,38), a*0.75, 10)
	RoundRectBorder(minX, btnY, btnS, btnS, Color3.fromRGB(60,60,95), a*0.45, 10, 1)
	Ln(minX+9, btnY+btnS/2, minX+btnS-9, btnY+btnS/2, colors.sub, a*0.85, 2)
	if hoverMin then
		RoundRectBorder(minX, btnY, btnS, btnS, colors.neon2, a*0.6, 10, 1)
	end

	-- close
	local colC = hoverClose and Color3.fromRGB(220,70,70) or Color3.fromRGB(22,22,38)
	RoundRectFill(closeX, btnY, btnS, btnS, colC, a*0.75, 10)
	RoundRectBorder(closeX, btnY, btnS, btnS, hoverClose and Color3.fromRGB(255,120,120) or Color3.fromRGB(60,60,95), a*0.55, 10, 1)
	Ln(closeX+9, btnY+9, closeX+btnS-9, btnY+btnS-9, colors.text, a*0.9, 2)
	Ln(closeX+9, btnY+btnS-9, closeX+btnS-9, btnY+9, colors.text, a*0.9, 2)
end

local function DrawNav()
	local L = Layout()
	local a = EaseOut(S.OpenAnim)

	-- detached nav pill
	local navA = a
	if navA < 0.01 then return end

	-- glow + shadow style
	if CFG.Bloom then
		local pulse = CFG.NeonPulse and (0.55 + 0.45*math.sin(S.Tick*1.7)) or 1
		GlowRound(L.navX, L.navY, L.navW, L.navH, colors.neon2, 0.08*CFG.BloomAmount*a*pulse, 18, 5)
	end

	-- glass-ish nav
	RoundRectFill(L.navX, L.navY, L.navW, L.navH, Color3.fromRGB(14,14,26), 0.62*navA, CFG.NavR)
	RoundRectBorder(L.navX, L.navY, L.navW, L.navH, Color3.fromRGB(70,70,120), 0.6*navA, CFG.NavR, 1)

	-- subtle internal separators
	Ln(L.navX+12, L.navY+10, L.navX+L.navW-12, L.navY+10, colors.sep, 0.5*navA, 1)
	Ln(L.navX+12, L.navY+L.navH-10, L.navX+L.navW-12, L.navY+L.navH-10, colors.sep, 0.5*navA, 1)

	local rects = TabIconRects()
	local t = S.Tick

	for i=1,4 do
		local r = rects[i]
		local active = (S.Tab == i)

		local boxHover = HoverRect(r.x, r.y, r.w, r.h)
		local pulse = CFG.NeonPulse and (0.6 + 0.4*math.sin(S.Tick*2 + i)) or 1

		-- only mono icons, active glowing state
		local bgAlpha = active and (0.18*navA) or (0.08*navA)
		RoundRectFill(r.x, r.y, r.w, r.h, Color3.fromRGB(12,12,20), bgAlpha, 16)

		-- active glow edge
		if active then
			local glA = 0.20*navA*CFG.BloomAmount*pulse
			GlowRound(r.x-6, r.y-6, r.w+12, r.h+12, colors.neon2, glA, 18, 4)
			RoundRectBorder(r.x, r.y, r.w, r.h, colors.neon2, 0.35*navA, 16, 1)
			-- active dot indicator
			Ci(L.navX+L.navW-10, r.y+r.h/2, 4, colors.neon2, 0.95, true)
		else
			if boxHover then
				RoundRectBorder(r.x, r.y, r.w, r.h, Color3.fromRGB(110,110,160), 0.25*navA, 16, 1)
			else
				-- keep minimal
				RoundRectBorder(r.x, r.y, r.w, r.h, Color3.fromRGB(65,65,95), 0.15*navA, 16, 1)
			end
		end

		-- icon (monochrome)
		local cx = r.x + r.w/2
		local cy = r.y + r.h/2
		DrawNavIcon(i, cx, cy, active, t)

		-- tiny active halo
		if active then
			Ci(cx, cy, 22, colors.neon, 0.06*navA, true)
		end
	end
end

local function DrawToggleCard(tab, i, rect, a)
	local x,y,w,h = rect.x, rect.y, rect.w, rect.h

	local on = S.T[tab][i]
	local anim = S.AnimToggle[tab][i]

	-- animate switch amount
	local target = on and 1 or 0
	anim = Lerp(anim, target, math.min(1, S.Dt * CFG.ToggleSpeed))
	S.AnimToggle[tab][i] = anim

	-- hover
	local hover = HoverRect(x,y,w,h)

	-- card background (glass)
	local base = Color3.fromRGB(20,20,34)
	local hoverBoost = hover and 0.10 or 0.0
	RoundRectFill(x,y,w,h, base, (0.52*a + hoverBoost*a), CFG.CardR)
	RoundRectFill(x+1,y+1,w-2,h-2, Color3.fromRGB(12,12,22), 0.33*a, CFG.CardR)

	-- card border / neon edge when ON
	local borderCol = Color3.fromRGB(70,70,115)
	local borderA = 0.28*a
	if on then
		local pulse = CFG.NeonPulse and (0.75 + 0.25*math.sin(S.Tick*3 + i)) or 1
		borderCol = colors.neon2
		borderA = 0.65*a
		if CFG.Bloom then
			GlowRound(x-8,y-6,w+16,h+12, colors.neon2, 0.06*CFG.BloomAmount*a*pulse, 20, 4)
		end
	else
		if hover then
			borderA = 0.38*a
		end
	end
	RoundRectBorder(x,y,w,h,borderCol,borderA,CFG.CardR,1)

	-- left dot
	local dotX = x + 18
	local dotY = y + h/2
	local dotR = 5.0
	local dotCol = on and colors.neon2 or colors.dotOff
	Ci(dotX, dotY, dotR, dotCol, 0.9*a, true)

	-- label
	local labelCol = on and Color3.fromRGB(245,245,255) or colors.text
	Tx(x+34, dotY-8, string.format("TEST-%d", i), labelCol, 14, false, true, Color3.fromRGB(0,0,0))

	-- subtle subtext when ON
	if anim > 0.08 then
		local sub = on and "ENABLED" or "DISABLED"
		local sc = on and Color3.fromRGB(110,240,170) or Color3.fromRGB(120,120,160)
		Tx(x+34, dotY+6, sub, sc, 10, false, true, Color3.fromRGB(0,0,0))
	end

	-- toggle switch on right (iOS)
	local tw, th = 52, 28
	local tx = x + w - tw - 18
	local ty = y + h/2 - th/2

	-- knob + track
	local neonOn = on
	-- NOTE: uses variable name "active" inside iOSToggle previously; fix by passing neon state
	-- We'll re-implement quickly here without that variable bug:
	-- (track)
	local trackR = th/2
	local onCol  = colors.neon2
	local offCol = Color3.fromRGB(58,60,86)
	local midCol = Color3.fromRGB(36,38,58)

	local animT = anim
	local lerpCol = Color3.new(
		Lerp(offCol.R/255, onCol.R/255, animT),
		Lerp(offCol.G/255, onCol.G/255, animT),
		Lerp(offCol.B/255, onCol.B/255, animT)
	)
	if CFG.Bloom and neonOn and animT > 0.03 then
		local pulse = CFG.NeonPulse and (0.7 + 0.3*math.sin(S.Tick*2.7 + i)) or 1
		local bloomA = 0.10*a*CFG.BloomAmount*pulse*animT
		GlowRound(tx-10, ty-5, tw+20, th+10, colors.neon2, bloomA, 20, 4)
	end

	RoundRectFill(tx, ty, tw, th, lerpCol, 0.98*a, trackR)
	RoundRectBorder(tx, ty, tw, th, onCol, (0.15 + 0.35*animT)*a, trackR, 1)

	local knobR = th/2 - 2
	local knobX = tx + 2 + (tw - th + 4)*animT
	Ci(knobX+knobR, ty+knobR, knobR, Color3.fromRGB(255,255,255), 0.98*a, true)
	Ci(knobX+knobR-1.2, ty+knobR-1.2, knobR*0.42, Color3.fromRGB(255,255,255), 0.55*a, true)

	-- hover hint border (micro)
	if hover and not on then
		RoundRectBorder(x,y,w,h, Color3.fromRGB(110,110,160), 0.22*a, CFG.CardR, 1)
	end
end

local function DrawButtonsPanel(a)
	local L = Layout()
	local cx, cy, cw, ch = L.contentX, L.contentY, L.contentW, L.contentH

	-- main glass panel background
	-- subtle depth layers
	RoundRectFill(L.wx, L.wy+CFG.HeaderH, L.W, L.H-CFG.HeaderH, Color3.fromRGB(14,14,24), 0.50*a, 16)
	RoundRectFill(L.wx+1, L.wy+CFG.HeaderH+1, L.W-2, L.H-CFG.HeaderH-2, Color3.fromRGB(24,24,38), 0.28*a, 16)

	-- neon edge lighting on right/top
	local pulse = CFG.NeonPulse and (0.55 + 0.45*math.sin(S.Tick*1.5)) or 1
	RoundRectFill(L.wx+L.W-10, L.wy+CFG.HeaderH+14, 2, ch-28, colors.neon2, 0.16*a*pulse, 2)

	-- inner content surface
	RoundRectFill(cx, cy, cw, ch, Color3.fromRGB(18,18,30), 0.30*a, 16)
	RoundRectBorder(cx, cy, cw, ch, Color3.fromRGB(60,60,98), 0.35*a, 16, 1)

	-- scanline (cinematic)
	local scanY = cy + ((S.Tick*55) % ch)
	Ln(cx, scanY, cx+cw, scanY, colors.neon2, 0.03*a, 1)

	local tab = S.Tab
	if tab <= 3 then
		local rects = ToggleItemRects(tab)
		for i=1,9 do
			DrawToggleCard(tab, i, rects[i], a)
		end
	else
		-- Settings content
		-- small premium cards + sliders
		local top = cy + 10

		local title = (S.Tab == 4 and "SETTINGS" or "")
		Tx(cx+10, top, title, colors.text, 15, false, false)

		Tx(cx+10, top+20, "Mini button + visuals tuning", colors.sub, 11, false, true, Color3.fromRGB(0,0,0))

		-- Card 1: Mini side
		local cardX = cx+8
		local cardW = cw-16
		local cardY1 = top + 46

		local itemH = 52
		local gap = 10

		-- Side chooser card
		RoundRectFill(cardX, cardY1, cardW, itemH, Color3.fromRGB(18,18,30), 0.55*a, CFG.CardR)
		RoundRectBorder(cardX, cardY1, cardW, itemH, Color3.fromRGB(70,70,115), 0.40*a, CFG.CardR, 1)
		Tx(cardX+14, cardY1+17, "Mini button side", colors.text, 12, false, false)
		Tx(cardX+14, cardY1+34, "Choose left / right", colors.sub, 10, false, true, Color3.fromRGB(0,0,0))

		-- Buttons inside
		local segW = (cardW-160)/2
		local baseX = cardX + cardW - 120
		local yBtn = cardY1 + 10

		local function SegButton(side, x, y, w, h)
			local active = (CFG.MiniSide == side)
			local hov = HoverRect(x,y,w,h)
			RoundRectFill(x,y,w,h, active and Color3.fromRGB(70,70,120) or Color3.fromRGB(14,14,24), 0.65*a, 14)
			RoundRectBorder(x,y,w,h, active and colors.neon2 or Color3.fromRGB(70,70,115), (active and 0.70 or 0.35)*a, 14, 1)
			if hov then
				RoundRectBorder(x,y,w,h, colors.neon2, 0.25*a, 14, 1)
			end
			local txt = side == "left" and "LEFT" or "RIGHT"
			Tx(x+w/2, y+h/2-7, txt, active and Color3.fromRGB(235,235,255) or colors.sub, 11, true, false)
		end

		local leftX = baseX
		local rightX = baseX + segW + 18
		SegButton("left", leftX, yBtn, segW, 32)
		SegButton("right", rightX, yBtn, segW, 32)

		-- Card 2: Mini vertical slider
		local cardY2 = cardY1 + itemH + 10
		RoundRectFill(cardX, cardY2, cardW, 74, Color3.fromRGB(18,18,30), 0.55*a, CFG.CardR)
		RoundRectBorder(cardX, cardY2, cardW, 74, Color3.fromRGB(70,70,115), 0.40*a, CFG.CardR, 1)

		Tx(cardX+14, cardY2+16, "Mini vertical position", colors.text, 12, false, false)
		local perc = math.floor(CFG.MiniY*100+0.5)
		Tx(cardX+14, cardY2+36, perc.."%", colors.sub, 11, false, true, Color3.fromRGB(0,0,0))

		-- slider bar
		local sx = cardX+14
		local sy = cardY2+46
		local sw = cardW-28
		local sh = 8
		RoundRectFill(sx, sy, sw, sh, Color3.fromRGB(40,40,62), 0.6*a, 4)
		RoundRectBorder(sx, sy, sw, sh, Color3.fromRGB(65,65,105), 0.35*a, 4, 1)

		local knobX = sx + (sw-16)*CFG.MiniY
		RoundRectFill(knobX, sy-6, 16, sh+12, colors.neon2, 0.8*a, 12)
		RoundRectBorder(knobX, sy-6, 16, sh+12, colors.neon2, 0.25*a, 12, 1)

		-- Card 3: Visual toggles
		local cardY3 = cardY2 + 74 + 12
		RoundRectFill(cardX, cardY3, cardW, 128, Color3.fromRGB(18,18,30), 0.55*a, CFG.CardR)
		RoundRectBorder(cardX, cardY3, cardW, 128, Color3.fromRGB(70,70,115), 0.40*a, CFG.CardR, 1)

		Tx(cardX+14, cardY3+16, "Visual effects", colors.text, 12, false, false)
		Tx(cardX+14, cardY3+34, "Bloom & neon pulse", colors.sub, 11, false, true, Color3.fromRGB(0,0,0))

		local function drawSwitchRow(rowY, label, on, toggleId)
			local hov = HoverRect(cardX+14, rowY, cardW-28, 40)
			local tx = cardX + cardW - 14 - 52
			local ty = rowY + 6

			-- row
			RoundRectFill(cardX+10, rowY, cardW-20, 40, Color3.fromRGB(14,14,24), 0.20*a, 14)
			RoundRectBorder(cardX+10, rowY, cardW-20, 40, Color3.fromRGB(70,70,115), 0.20*a, 14, 1)

			Tx(cardX+22, rowY+10, label, colors.text, 11, false, false)

			-- switch
			local anim = on and 1 or 0
			-- re-use toggle renderer by faking AnimToggle
			local neon = on
			-- iOS track
			local tw, th = 52, 28
			local trackR = th/2

			local onCol = colors.neon2
			local offCol = Color3.fromRGB(58,60,86)
			local lerpCol = Color3.new(
				Lerp(offCol.R/255, onCol.R/255, anim),
				Lerp(offCol.G/255, onCol.G/255, anim),
				Lerp(offCol.B/255, onCol.B/255, anim)
			)

			if CFG.Bloom and on then
				GlowRound(tx-10, ty-5, tw+20, th+10, colors.neon2, 0.08*a*CFG.BloomAmount, 20, 4)
			end

			RoundRectFill(tx, ty, tw, th, lerpCol, 0.95*a, trackR)
			RoundRectBorder(tx, ty, tw, th, colors.neon2, (0.15 + 0.35*anim)*a, trackR, 1)

			local knobR = th/2 - 2
			local knobX = tx + 2 + (tw - th + 4)*anim
			Ci(knobX+knobR, ty+knobR, knobR, Color3.fromRGB(255,255,255), 0.98*a, true)
			Ci(knobX+knobR-1.2, ty+knobR-1.2, knobR*0.42, Color3.fromRGB(255,255,255), 0.55*a, true)

			return hov
		end

		drawSwitchRow(cardY3+48, "Bloom", CFG.Bloom, 1)
		drawSwitchRow(cardY3+88, "Neon pulse", CFG.NeonPulse, 2)

		-- Card 4: Keybind + reset
		local cardY4 = cardY3 + 128 + 12
		RoundRectFill(cardX, cardY4, cardW, 110, Color3.fromRGB(18,18,30), 0.55*a, CFG.CardR)
		RoundRectBorder(cardX, cardY4, cardW, 110, Color3.fromRGB(70,70,115), 0.40*a, CFG.CardR, 1)

		Tx(cardX+14, cardY4+16, "Toggle key", colors.text, 12, false, false)
		local keyName = tostring(CFG.ToggleKey):gsub("Enum%.KeyCode%.","")
		Tx(cardX+14, cardY4+36, keyName, colors.neon2, 12, false, true, Color3.fromRGB(0,0,0))

		local btnW = 168
		local btnH = 32
		local bx = cardX + cardW - btnW - 14
		local by = cardY4 + 22

		local hov = HoverRect(bx, by, btnW, btnH)
		RoundRectFill(bx, by, btnW, btnH, Color3.fromRGB(20,20,32), 0.65*a, 14)
		RoundRectBorder(bx, by, btnW, btnH, hov and colors.neon2 or Color3.fromRGB(70,70,115), (hov and 0.75 or 0.40)*a, 14, 1)
		Tx(bx+btnW/2, by+8, S.WaitKey and "PRESS KEY..." or "CHANGE", colors.text, 11, true, false)

		-- Reset toggles button
		local bx2 = cardX + 14
		local by2 = cardY4 + 62
		local rW, rH = 220, 32

		local hov2 = HoverRect(bx2, by2, rW, rH)
		RoundRectFill(bx2, by2, rW, rH, Color3.fromRGB(20,20,32), 0.65*a, 14)
		RoundRectBorder(bx2, by2, rW, rH, hov2 and Color3.fromRGB(220,70,70) or Color3.fromRGB(70,70,115), (hov2 and 0.75 or 0.40)*a, 14, 1)
		Tx(bx2+rW/2, by2+8, "RESET TESTS", hov2 and Color3.fromRGB(255,170,170) or colors.sub, 11, true, false)
	end
end

local function DrawMainWindow()
	local a = EaseOut(S.OpenAnim)
	if a < 0.001 then return end

	local L = Layout()

	-- window shadow
	GlowRound(L.wx-2, L.wy-2, L.W+4, L.H+4, colors.neon2, 0.045*a*CFG.BloomAmount, 16, 4)

	-- main glass background
	RoundRectFill(L.wx, L.wy, L.W, L.H, Color3.fromRGB(18,18,30), 0.60*a, 16)
	RoundRectFill(L.wx+1, L.wy+1, L.W-2, L.H-2, Color3.fromRGB(12,12,22), 0.38*a, 16)

	-- neon border (edge lighting)
	local pulse = CFG.NeonPulse and (0.55 + 0.45*math.sin(S.Tick*1.8)) or 1
	RoundRectBorder(L.wx, L.wy, L.W, L.H, Color3.fromRGB(90,70,255), 0.40*a*pulse, 16, 1.5)
	RoundRectBorder(L.wx, L.wy, L.W, L.H, colors.neon2, 0.22*a*pulse, 16, 1)

	-- premium header
	DrawHeader(L, a)

	-- content
	DrawButtonsPanel(a)
end

local function DrawMiniButton()
	-- show only when closed/closing
	local a = 1 - EaseOut(S.OpenAnim)
	if a < 0.01 then return end

	local r = MiniButtonRect()
	local hov = HoverRect(r.x, r.y, r.w, r.h)
	S.MiniHover = hov

	-- background + glow
	local pulse = CFG.NeonPulse and (0.6 + 0.4*math.sin(S.Tick*2.3)) or 1
	if CFG.Bloom then
		GlowRound(r.x-8, r.y-8, r.w+16, r.h+16, colors.neon2, 0.12*a*CFG.BloomAmount*pulse, 22, 4)
	end

	RoundRectFill(r.x, r.y, r.w, r.h, Color3.fromRGB(14,14,24), 0.78*a, CFG.NavR)
	RoundRectBorder(r.x, r.y, r.w, r.h, hov and colors.neon2 or Color3.fromRGB(70,70,120), (hov and 0.75 or 0.45)*a, CFG.NavR, 1)

	-- icon (pill expand)
	local cx, cy = r.x + r.w/2, r.y + r.h/2
	Ci(cx, cy-10, 3.5, Color3.fromRGB(255,255,255), 0.9*a, true)
	Ci(cx, cy,    3.5, colors.neon2, 0.9*a, true)
	Ci(cx, cy+10, 3.5, Color3.fromRGB(255,255,255), 0.9*a, true)

	-- hover highlight
	if hov then
		RoundRectBorder(r.x, r.y, r.w, r.h, colors.neon2, 0.95*a, CFG.NavR, 1.5)
	end
end

-------------------------------------------------------
-- Input
-------------------------------------------------------
local DraggingMiniSlider = false

local function IsOnHeader()
	local L = Layout()
	return HoverRect(L.wx, L.wy, L.W, CFG.HeaderH)
end

local function IsOnCloseBtn()
	local L = Layout()
	local btnS = 30
	local pad = 12
	local closeX = L.wx + L.W - pad - btnS
	local minX = closeX - btnS - 8
	local by = L.wy + 16
	-- close only
	return HoverRect(closeX, by, btnS, btnS)
end

local function IsOnMinBtn()
	local L = Layout()
	local btnS = 30
	local pad = 12
	local closeX = L.wx + L.W - pad - btnS
	local minX = closeX - btnS - 8
	local by = L.wy + 16
	return HoverRect(minX, by, btnS, btnS)
end

local function GetTabFromMouse()
	if not (S.OpenAnim > 0.4) then return nil end
	local rects = TabIconRects()
	for i=1,4 do
		local r = rects[i]
		if HoverRect(r.x, r.y, r.w, r.h) then
			return i
		end
	end
	return nil
end

local function GetToggleFromMouse(tab)
	if not (S.OpenAnim > 0.4) then return nil end
	if tab > 3 then return nil end
	local rects = ToggleItemRects(tab)
	for i=1,9 do
		local r = rects[i]
		if HoverRect(r.x, r.y, r.w, r.h) then
			return i
		end
	end
	return nil
end

UIS.InputBegan:Connect(function(inp, gpe)
	if gpe then return end

	-- keybind capture
	if S.WaitKey then
		if inp.KeyCode then
			CFG.ToggleKey = inp.KeyCode
		end
		S.WaitKey = false
		return
	end

	-- toggle menu open/close by key
	if inp.KeyCode == CFG.ToggleKey then
		S.Open = not S.Open
		return
	end

	if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	local mx,my = MousePos()

	-- if closed => mini click
	if S.OpenAnim < 0.25 then
		local r = MiniButtonRect()
		if HoverRect(r.x,r.y,r.w,r.h) then
			S.Open = true
		end
		return
	end

	-- close buttons / minimize
	if IsOnCloseBtn() then
		S.Open = false
		return
	end
	if IsOnMinBtn() then
		-- minimize treated as close to mini
		S.Open = false
		return
	end

	-- tab nav
	local tab = GetTabFromMouse()
	if tab then
		S.Tab = tab
		return
	end

	-- settings interactions
	if S.Tab == 4 then
		local L = Layout()
		local cx, cy = L.contentX, L.contentY

		-- We reproduce key interaction hitboxes approximated:
		-- Side buttons
		local cardX = cx+8
		local cardW = L.contentW-16
		local itemH = 52
		local top = cy + 10
		local cardY1 = top + 46

		-- reset key button + change
		local cardY3 = (cardY1 + itemH + 10 + 74 + 12) -- not precise; we'll use Hover by zones

		-- mini side buttons zone:
		local segW = (cardW-160)/2
		local baseX = cardX + cardW - 120
		local yBtn = cardY1 + 10

		local leftX = baseX
		local rightX = baseX + segW + 18
		local ifLeft = HoverRect(leftX, yBtn, segW, 32)
		local ifRight= HoverRect(rightX, yBtn, segW, 32)

		if ifLeft then CFG.MiniSide = "left"; return end
		if ifRight then CFG.MiniSide = "right"; return end

		-- vertical slider zone (slider bar)
		local cardY2 = cardY1 + itemH + 10
		local sx = cardX+14
		local sy = cardY2+46
		local sw = cardW-28

		-- knob area
		local knobX = sx + (sw-16)*CFG.MiniY
		local knobRect = {x=knobX, y=sy-10, w=16, h=28}

		local barHover = HoverRect(sx, sy-4, sw, 16)
		if barHover then
			DraggingMiniSlider = true
			local _, my = MousePos()
			local t = (my - (sy)) / 1 -- not used
			-- compute by X position instead of Y (slider in design is vertical for mini button, but we render horizontal track)
			-- We'll map slider based on mouse Y within settings card to vertical value.
			-- For simplicity: use click X to map.
			local mx = MousePos()
			-- (safer: compute from mouse X on track)
			local mx2 = select(1, MousePos())
			CFG.MiniY = Clamp((mx2 - sx) / sw, 0, 1)
			return
		end
		if HoverRect(knobRect.x, knobRect.y, knobRect.w, knobRect.h) then
			DraggingMiniSlider = true
			local mx2 = select(1, MousePos())
			CFG.MiniY = Clamp((mx2 - sx) / sw, 0, 1)
			return
		end

		-- Bloom / Pulse toggles:
		-- We approximate hitboxes:
		-- Visual card starts at cardY3 = cardY2 + 74 + 12
		local cardY3Exact = cardY1 + itemH + 10 + 74 + 12
		local function SwitchHit(rowY)
			local hx, hy = cardX+10, rowY
			return HoverRect(hx, hy, cardW-20, 40)
		end

		if SwitchHit(cardY3Exact+48) then
			CFG.Bloom = not CFG.Bloom
			return
		end
		if SwitchHit(cardY3Exact+88) then
			CFG.NeonPulse = not CFG.NeonPulse
			return
		end

		-- Change key button:
		-- approximate from cardY4 zone
		local cardY4 = cardY3Exact + 128 + 12
		local btnW, btnH = 168, 32
		local bx = cardX + cardW - btnW - 14
		local by = cardY4 + 22
		if HoverRect(bx, by, btnW, btnH) then
			S.WaitKey = true
			return
		end

		-- Reset tests button:
		local bx2 = cardX + 14
		local by2 = cardY4 + 62
		local rW, rH = 220, 32
		if HoverRect(bx2, by2, rW, rH) then
			for t=1,3 do
				for i=1,9 do
					S.T[t][i] = false
				end
			end
			return
		end
	end

	-- Toggle click (TEST cards)
	local t = S.Tab
	local idx = GetToggleFromMouse(t)
	if idx and t <= 3 then
		S.T[t][idx] = not S.T[t][idx]
		return
	end

	-- Drag start from header
	if IsOnHeader() then
		S.Dragging = true
		local _, my = MousePos()
		S.DragOff = Vector2.new(select(1, MousePos()) - S.X, my - S.Y)
		return
	end
end)

UIS.InputChanged:Connect(function(inp, gpe)
	if gpe then return end
	if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end

	if S.Dragging then
		local mx, my = MousePos()
		S.X = mx - S.DragOff.X
		S.Y = my - S.DragOff.Y
	end

	if DraggingMiniSlider and S.Tab == 4 then
		local L = Layout()
		local cx, cy = L.contentX, L.contentY
		local cardX = cx+8
		local cardW = L.contentW-16
		local itemH = 52
		local top = cy + 10
		local cardY1 = top + 46
		local cardY2 = cardY1 + itemH + 10

		local sx = cardX+14
		local sy = cardY2+46
		local sw = cardW-28

		local mx, _ = MousePos()
		CFG.MiniY = Clamp((mx - sx) / sw, 0, 1)
	end
end)

UIS.InputEnded:Connect(function(inp, gpe)
	if gpe then return end
	if inp.UserInputType == Enum.UserInputType.MouseButton1 then
		S.Dragging = false
		DraggingMiniSlider = false
	end
end)

-------------------------------------------------------
-- Main loop
-------------------------------------------------------
S.Tick = 0
S.Dt = 0

RS.RenderStepped:Connect(function(dt)
	S.Dt = math.min(dt, 0.033)
	S.Tick += S.Dt

	-- open/close animation
	local target = S.Open and 1 or 0
	S.OpenAnim = Lerp(S.OpenAnim, target, S.Dt * CFG.AnimSpeed)
	S.OpenAnim = Clamp(S.OpenAnim, 0, 1)

	-- tab animation state (optional smoothing)
	for i=1,4 do
		local t = (S.Tab == i) and 1 or 0
		S.TabAnim[i] = Lerp(S.TabAnim[i], t, S.Dt * CFG.TabSpeed)
	end

	beginFrame()
	DrawMiniButton()
	DrawNav()
	DrawMainWindow()
	endFrame()
end)

print("Luxury UI loaded ✓  Toggle key:", CFG.ToggleKey.Name)
