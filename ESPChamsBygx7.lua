local groupId = 34352374

local player = game.Players.LocalPlayer

if not player:IsInGroup(groupId) then

    warn("Você precisa estar no grupo para usar esse script!/You need to be in the group to use this script!")

    return

end



-- ==========================================

-- ESP BY GX7ツ — OPTIMIZED

-- ==========================================

local THEMES = {

	Dark     = {bg=Color3.fromRGB(0,0,0),      sec=Color3.fromRGB(60,60,60),    acc=Color3.fromRGB(100,100,100), txt=Color3.fromRGB(255,255,255), ok=Color3.fromRGB(0,200,100),   warn=Color3.fromRGB(255,165,0),  err=Color3.fromRGB(220,50,50),  brd=Color3.fromRGB(80,80,80)},

	Light    = {bg=Color3.fromRGB(255,255,255), sec=Color3.fromRGB(220,220,220), acc=Color3.fromRGB(180,180,180), txt=Color3.fromRGB(30,30,30),    ok=Color3.fromRGB(0,180,80),    warn=Color3.fromRGB(235,145,0),  err=Color3.fromRGB(200,30,30),  brd=Color3.fromRGB(160,160,160)},

	Midnight = {bg=Color3.fromRGB(15,15,35),    sec=Color3.fromRGB(25,25,50),    acc=Color3.fromRGB(150,50,255),  txt=Color3.fromRGB(220,220,255), ok=Color3.fromRGB(150,50,255),  warn=Color3.fromRGB(255,180,50), err=Color3.fromRGB(255,100,120),brd=Color3.fromRGB(50,50,100)},

	Ocean    = {bg=Color3.fromRGB(15,25,35),    sec=Color3.fromRGB(20,35,50),    acc=Color3.fromRGB(0,180,216),   txt=Color3.fromRGB(220,240,255), ok=Color3.fromRGB(0,230,180),   warn=Color3.fromRGB(255,200,100),err=Color3.fromRGB(255,80,100), brd=Color3.fromRGB(30,50,70)},

	Forest   = {bg=Color3.fromRGB(15,25,15),    sec=Color3.fromRGB(25,40,25),    acc=Color3.fromRGB(60,140,60),   txt=Color3.fromRGB(220,255,220), ok=Color3.fromRGB(100,220,100), warn=Color3.fromRGB(255,193,7),  err=Color3.fromRGB(244,67,54),  brd=Color3.fromRGB(40,80,40)},

	Sunset   = {bg=Color3.fromRGB(30,20,25),    sec=Color3.fromRGB(40,28,35),    acc=Color3.fromRGB(255,87,34),   txt=Color3.fromRGB(255,240,230), ok=Color3.fromRGB(255,193,7),   warn=Color3.fromRGB(255,152,0),  err=Color3.fromRGB(211,47,47),  brd=Color3.fromRGB(60,40,50)},

	Neon     = {bg=Color3.fromRGB(10,0,20),     sec=Color3.fromRGB(20,0,40),     acc=Color3.fromRGB(255,0,255),   txt=Color3.fromRGB(255,100,255), ok=Color3.fromRGB(0,255,150),   warn=Color3.fromRGB(255,255,0),  err=Color3.fromRGB(255,50,150), brd=Color3.fromRGB(150,0,150)},

	Cyberpunk= {bg=Color3.fromRGB(5,10,15),     sec=Color3.fromRGB(15,20,30),    acc=Color3.fromRGB(0,255,255),   txt=Color3.fromRGB(0,255,255),   ok=Color3.fromRGB(255,0,255),   warn=Color3.fromRGB(255,200,0),  err=Color3.fromRGB(255,0,100),  brd=Color3.fromRGB(0,150,150)},

}

local THEME_ORDER = {"Dark","Light","Midnight","Ocean","Forest","Sunset","Neon","Cyberpunk"}

local Players        = game:GetService("Players")

local RunService     = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")

local CoreGui        = game:GetService("CoreGui")

local TweenService   = game:GetService("TweenService")

local LocalPlayer    = Players.LocalPlayer

local DEFAULT_CONFIG = {

	on=true, dist=1000, box=true, name=true, hp=true, distance=true,

	team=false, tcolor=true, thick=2, weaponESP=false, alive=true,

	menuLocked=false, theme="Dark", alpha=0.05, px=20, py=180,

	keybind="Insert", debugMode=false, watermark=true,

	tracerOrigin="bottom", _version=3,

}

local Config = {}

for k,v in pairs(DEFAULT_CONFIG) do Config[k]=v end

local GUIRef, UIHidden, WatermarkLabel = nil, false, nil

local GUIConns, GUIMin, GUICurrentPage = {}, false, "Main"

local NotifGui = nil

-- ESP state (declarado aqui para o botão X dentro de BuildGUI ter acesso)

local COREGUI = LocalPlayer:FindFirstChildWhichIsA("PlayerGui") or CoreGui

local ESPCache = {}

local WeaponCache = {}

local WeaponCacheTime = {}

local WEAPON_CACHE_TTL = 0.8

-- Forward declarations — funções ESP usadas dentro de BuildGUI (botão X)

local removeESP

local buildESP

-- ==========================================

-- UTILS

-- ==========================================

local function Log(msg, t)

	if Config.debugMode then print(string.format("[GX7][%s] %s", t or "INFO", msg)) end

end

local function SaveConfig() Log("Config saved", "INFO") end

-- ==========================================

-- NOTIFICATION

-- ==========================================

local function ShowMiniNotification(isHiding)

	pcall(function() if NotifGui then NotifGui:Destroy() end end)

	local theme = THEMES[Config.theme] or THEMES.Dark

	local ng = Instance.new("ScreenGui")

	ng.Name = "ESPGX7_Notif"

	ng.ResetOnSpawn = false

	ng.ZIndexBehavior = Enum.ZIndexBehavior.Global

	ng.DisplayOrder = 9999

	ng.IgnoreGuiInset = true

	ng.Parent = CoreGui

	NotifGui = ng

	local frame = Instance.new("Frame", ng)

	frame.AnchorPoint = Vector2.new(1,1)

	frame.Position = UDim2.new(1,-20,1,-20)

	frame.Size = UDim2.new(0,340,0,56)

	frame.BackgroundColor3 = theme.bg

	frame.BackgroundTransparency = 0.1

	frame.BorderSizePixel = 0

	frame.ZIndex = 200

	Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

	local stroke = Instance.new("UIStroke", frame)

	stroke.Color = isHiding and theme.warn or theme.ok

	stroke.Thickness = 2

	stroke.Transparency = 0.2

	local icon = Instance.new("TextLabel", frame)

	icon.Size = UDim2.new(0,44,1,0)

	icon.Position = UDim2.new(0,8,0,0)

	icon.BackgroundTransparency = 1

	icon.Text = isHiding and "👁️" or "✅"

	icon.TextSize = 24

	icon.Font = Enum.Font.GothamBold

	icon.ZIndex = 201

	local title = Instance.new("TextLabel", frame)

	title.Size = UDim2.new(1,-60,0,20)

	title.Position = UDim2.new(0,56,0,8)

	title.BackgroundTransparency = 1

	title.Text = isHiding and "Interface Hidden" or "Interface Restored"

	title.TextColor3 = theme.txt

	title.TextSize = 14

	title.Font = Enum.Font.GothamBold

	title.TextXAlignment = Enum.TextXAlignment.Left

	title.ZIndex = 201

	local subtitle = Instance.new("TextLabel", frame)

	subtitle.Size = UDim2.new(1,-60,0,16)

	subtitle.Position = UDim2.new(0,56,0,28)

	subtitle.BackgroundTransparency = 1

	subtitle.Text = isHiding and "Press RightShift to restore" or "ESP BY GX7ツ"

	subtitle.TextColor3 = theme.txt

	subtitle.TextSize = 11

	subtitle.Font = Enum.Font.Gotham

	subtitle.TextXAlignment = Enum.TextXAlignment.Left

	subtitle.TextTransparency = 0.3

	subtitle.ZIndex = 201

	local barBg = Instance.new("Frame", frame)

	barBg.Size = UDim2.new(1,-12,0,3)

	barBg.Position = UDim2.new(0,6,1,-8)

	barBg.BackgroundColor3 = theme.brd

	barBg.BackgroundTransparency = 0.5

	barBg.BorderSizePixel = 0

	barBg.ZIndex = 202

	Instance.new("UICorner", barBg).CornerRadius = UDim.new(1,0)

	local bar = Instance.new("Frame", barBg)

	bar.Size = UDim2.new(1,0,1,0)

	bar.BackgroundColor3 = isHiding and theme.warn or theme.ok

	bar.BorderSizePixel = 0

	bar.ZIndex = 203

	Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

	TweenService:Create(bar, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {Size=UDim2.new(0,0,1,0)}):Play()

	task.delay(2.5, function()

		pcall(function() ng:Destroy() end)

		if NotifGui == ng then NotifGui = nil end

	end)

end

local function ToggleFullHide()

	UIHidden = not UIHidden

	if GUIRef then GUIRef.Enabled = not UIHidden end

	ShowMiniNotification(UIHidden)

end

local function UpdateWatermark()

	if WatermarkLabel then

		WatermarkLabel.Visible = Config.watermark

	end

end

-- ==========================================

-- BUILD GUI

-- ==========================================

local function BuildGUI()

	for _,c in ipairs(GUIConns) do pcall(function() c:Disconnect() end) end

	GUIConns = {}

	local theme = THEMES[Config.theme] or THEMES.Dark

	pcall(function()

		for _,g in ipairs(CoreGui:GetChildren()) do

			if g:IsA("ScreenGui") and g.Name:find("ESPGX7") then g:Destroy() end

		end

	end)

	local sg = Instance.new("ScreenGui")

	sg.Name = "ESPGX7"..math.random(10000,99999)

	sg.ResetOnSpawn = false

	sg.ZIndexBehavior = Enum.ZIndexBehavior.Global

	sg.DisplayOrder = 999

	sg.IgnoreGuiInset = true

	sg.Parent = CoreGui

	GUIRef = sg

	-- Watermark

	local wm = Instance.new("TextLabel", sg)

	wm.Size = UDim2.new(0,260,0,25)

	wm.Position = UDim2.new(0,10,0,10)

	wm.BackgroundTransparency = 1

	wm.Text = "ESP BY GX7ツ"

	wm.TextColor3 = Color3.fromRGB(255,255,255)

	wm.TextSize = 14

	wm.Font = Enum.Font.GothamBold

	wm.TextXAlignment = Enum.TextXAlignment.Left

	wm.ZIndex = 100

	wm.TextStrokeColor3 = Color3.fromRGB(0,0,0)

	wm.TextStrokeTransparency = 0.5

	wm.Visible = Config.watermark

	WatermarkLabel = wm

	-- Main frame

	local fr = Instance.new("Frame", sg)

	fr.Size = UDim2.new(0,300,0, GUIMin and 36 or 420)

	fr.Position = UDim2.new(0,Config.px,0,Config.py)

	fr.BackgroundColor3 = theme.bg

	fr.BackgroundTransparency = Config.alpha

	fr.BorderSizePixel = 0

	Instance.new("UICorner", fr).CornerRadius = UDim.new(0,12)

	local frStk = Instance.new("UIStroke", fr)

	frStk.Color = theme.acc frStk.Thickness = 2 frStk.Transparency = 0.3

	-- Header

	local hdr = Instance.new("Frame", fr)

	hdr.Size = UDim2.new(1,0,0,35)

	hdr.BackgroundColor3 = theme.sec

	hdr.BackgroundTransparency = Config.alpha

	hdr.BorderSizePixel = 0

	hdr.ZIndex = 2

	Instance.new("UICorner", hdr).CornerRadius = UDim.new(0,12)

	local ttl = Instance.new("TextLabel", hdr)

	ttl.Size = UDim2.new(1,-110,1,0)

	ttl.Position = UDim2.new(0,12,0,0)

	ttl.BackgroundTransparency = 1

	ttl.Text = "ESP BY GX7ツ"

	ttl.TextColor3 = theme.txt

	ttl.TextSize = 16

	ttl.Font = Enum.Font.GothamBold

	ttl.TextXAlignment = Enum.TextXAlignment.Left

	ttl.ZIndex = 3

	local function hbtn(xo, tx, bg)

		local b = Instance.new("TextButton", hdr)

		b.Size = UDim2.new(0,28,0,28)

		b.Position = UDim2.new(1,xo,0.5,-14)

		b.BackgroundColor3 = bg

		b.BackgroundTransparency = 0.2

		b.BorderSizePixel = 0

		b.Text = tx

		b.TextColor3 = theme.txt

		b.TextSize = 14

		b.Font = Enum.Font.GothamBold

		b.ZIndex = 4

		Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

		return b

	end

	local bLock  = hbtn(-100, Config.menuLocked and "🔒" or "🔓", Config.menuLocked and Color3.fromRGB(0,200,100) or Color3.fromRGB(0,150,255))

	local bMin   = hbtn(-65, GUIMin and "+" or "-", theme.acc)

	local bClose = hbtn(-30, "X", theme.err)

	-- Drag

	local drag, ds, df = false, nil, nil

	table.insert(GUIConns, hdr.InputBegan:Connect(function(i)

		if i.UserInputType == Enum.UserInputType.MouseButton1 and not Config.menuLocked then

			drag=true ds=i.Position df=fr.Position

		end

	end))

	table.insert(GUIConns, hdr.InputEnded:Connect(function(i)

		if i.UserInputType == Enum.UserInputType.MouseButton1 then drag=false end

	end))

	table.insert(GUIConns, UserInputService.InputChanged:Connect(function(i)

		if drag and i.UserInputType == Enum.UserInputType.MouseMovement then

			local d = i.Position-ds

			fr.Position = UDim2.new(0,df.X.Offset+d.X,0,df.Y.Offset+d.Y)

		end

	end))

	-- Nav

	local nav = Instance.new("Frame", fr)

	nav.Size = UDim2.new(1,0,0,40)

	nav.Position = UDim2.new(0,0,0,45)

	nav.BackgroundTransparency = 1

	nav.BorderSizePixel = 0

	nav.ZIndex = 2

	nav.Visible = not GUIMin

	local navL = Instance.new("UIListLayout", nav)

	navL.FillDirection = Enum.FillDirection.Horizontal

	navL.HorizontalAlignment = Enum.HorizontalAlignment.Center

	navL.VerticalAlignment = Enum.VerticalAlignment.Center

	navL.Padding = UDim.new(0,8)

	local PAGES = {"Main","Visuals","Settings","Themes"}

	local pBtns, pFrames = {}, {}

	local curP = GUICurrentPage

	for _,pn in ipairs(PAGES) do

		local b = Instance.new("TextButton", nav)

		b.Size = UDim2.new(0,62,0,28)

		b.BorderSizePixel = 0

		b.BackgroundColor3 = curP==pn and theme.acc or theme.sec

		b.BackgroundTransparency = 0.3

		b.Text = pn

		b.TextColor3 = theme.txt

		b.TextSize = 12

		b.Font = Enum.Font.GothamBold

		b.ZIndex = 3

		Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

		pBtns[pn] = b

	end

	local body = Instance.new("Frame", fr)

	body.Size = UDim2.new(1,-20,1,-95)

	body.Position = UDim2.new(0,10,0,90)

	body.BackgroundTransparency = 1

	body.BorderSizePixel = 0

	body.ZIndex = 2

	body.Visible = not GUIMin

	for _,pn in ipairs(PAGES) do

		local pf = Instance.new("Frame", body)

		pf.Size = UDim2.new(1,0,1,0)

		pf.BackgroundTransparency = 1

		pf.BorderSizePixel = 0

		pf.ZIndex = 2

		pf.Visible = curP==pn

		pFrames[pn] = pf

	end

	local function scroll(p)

		local s = Instance.new("ScrollingFrame", p)

		s.Size = UDim2.new(1,0,1,0)

		s.BackgroundTransparency = 1

		s.BorderSizePixel = 0

		s.ScrollBarThickness = 4

		s.CanvasSize = UDim2.new(0,0,0,0)

		s.AutomaticCanvasSize = Enum.AutomaticSize.Y

		s.ZIndex = 3

		s.ScrollingDirection = Enum.ScrollingDirection.Y

		local l = Instance.new("UIListLayout", s)

		l.Padding = UDim.new(0,8)

		l.HorizontalAlignment = Enum.HorizontalAlignment.Center

		return s

	end

	local function tog(par, lbl, get, set, lo)

		local row = Instance.new("Frame", par)

		row.Size = UDim2.new(1,0,0,32)

		row.BackgroundColor3 = theme.sec

		row.BackgroundTransparency = 0.5

		row.BorderSizePixel = 0

		row.ZIndex = 3

		row.LayoutOrder = lo or 0

		Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

		local l = Instance.new("TextLabel", row)

		l.Size = UDim2.new(1,-55,1,0)

		l.Position = UDim2.new(0,10,0,0)

		l.BackgroundTransparency = 1

		l.Text = lbl

		l.TextColor3 = theme.txt

		l.TextSize = 12

		l.Font = Enum.Font.Gotham

		l.TextXAlignment = Enum.TextXAlignment.Left

		l.ZIndex = 4

		local v = get()

		local tb = Instance.new("TextButton", row)

		tb.Size = UDim2.new(0,45,0,22)

		tb.Position = UDim2.new(1,-50,0.5,-11)

		tb.BackgroundColor3 = v and theme.ok or theme.brd

		tb.BackgroundTransparency = 0.2

		tb.BorderSizePixel = 0

		tb.Text = ""

		tb.ZIndex = 5

		Instance.new("UICorner", tb).CornerRadius = UDim.new(1,0)

		local ind = Instance.new("Frame", tb)

		ind.Size = UDim2.new(0,18,0,18)

		ind.Position = v and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)

		ind.BackgroundColor3 = theme.txt

		ind.BorderSizePixel = 0

		ind.ZIndex = 6

		Instance.new("UICorner", ind).CornerRadius = UDim.new(1,0)

		tb.MouseButton1Click:Connect(function()

			v = not v set(v)

			tb.BackgroundColor3 = v and theme.ok or theme.brd

			ind.Position = v and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)

			SaveConfig()

		end)

	end

	local function numInput(par, lbl, mn, mx, get, set, lo)

		local row = Instance.new("Frame", par)

		row.Size = UDim2.new(1,0,0,55)

		row.BackgroundColor3 = theme.sec

		row.BackgroundTransparency = 0.5

		row.BorderSizePixel = 0

		row.ZIndex = 3

		row.LayoutOrder = lo or 0

		Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

		local topRow = Instance.new("Frame", row)

		topRow.Size = UDim2.new(1,-10,0,22)

		topRow.Position = UDim2.new(0,10,0,6)

		topRow.BackgroundTransparency = 1

		topRow.ClipsDescendants = false

		topRow.ZIndex = 4

		local tLayout = Instance.new("UIListLayout", topRow)

		tLayout.FillDirection = Enum.FillDirection.Horizontal

		tLayout.VerticalAlignment = Enum.VerticalAlignment.Center

		tLayout.Padding = UDim.new(0,0)

		tLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local l = Instance.new("TextLabel", topRow)

		l.AutomaticSize = Enum.AutomaticSize.X

		l.Size = UDim2.new(0,0,1,0)

		l.BackgroundTransparency = 1

		l.Text = lbl..": "

		l.TextColor3 = theme.txt

		l.TextSize = 13

		l.Font = Enum.Font.GothamBold

		l.TextXAlignment = Enum.TextXAlignment.Left

		l.ZIndex = 4

		l.LayoutOrder = 1

		local valBtn = Instance.new("TextButton", topRow)

		valBtn.AutomaticSize = Enum.AutomaticSize.X

		valBtn.Size = UDim2.new(0,0,1,0)

		valBtn.BackgroundColor3 = theme.acc

		valBtn.BackgroundTransparency = 0.2

		valBtn.BorderSizePixel = 0

		valBtn.Text = " "..tostring(get()).." "

		valBtn.TextColor3 = theme.txt

		valBtn.TextSize = 13

		valBtn.Font = Enum.Font.GothamBold

		valBtn.ZIndex = 5

		valBtn.LayoutOrder = 2

		Instance.new("UICorner", valBtn).CornerRadius = UDim.new(0,5)

		local bg = Instance.new("Frame", row)

		bg.Size = UDim2.new(1,-20,0,8)

		bg.Position = UDim2.new(0,10,1,-18)

		bg.BackgroundColor3 = theme.brd

		bg.BackgroundTransparency = 0.3

		bg.BorderSizePixel = 0

		bg.ZIndex = 4

		Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)

		local fi = Instance.new("Frame", bg)

		fi.Size = UDim2.new((get()-mn)/(mx-mn),0,1,0)

		fi.BackgroundColor3 = theme.acc

		fi.BorderSizePixel = 0

		fi.ZIndex = 5

		Instance.new("UICorner", fi).CornerRadius = UDim.new(1,0)

		local hit = Instance.new("TextButton", bg)

		hit.Size = UDim2.new(1,0,4,0)

		hit.Position = UDim2.new(0,0,-1.5,0)

		hit.BackgroundTransparency = 1

		hit.Text = ""

		hit.ZIndex = 6

		local dg = false

		hit.MouseButton1Down:Connect(function() dg=true end)

		table.insert(GUIConns, UserInputService.InputChanged:Connect(function(i)

			if not dg or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end

			local pct = math.clamp((i.Position.X-bg.AbsolutePosition.X)/bg.AbsoluteSize.X,0,1)

			local val = math.floor(mn+(mx-mn)*pct)

			fi.Size = UDim2.new(pct,0,1,0)

			valBtn.Text = " "..tostring(val).." "

			set(val)

		end))

		table.insert(GUIConns, UserInputService.InputEnded:Connect(function(i)

			if i.UserInputType == Enum.UserInputType.MouseButton1 and dg then

				dg=false SaveConfig()

			end

		end))

		valBtn.MouseButton1Click:Connect(function()

			local inputBox = Instance.new("TextBox")

			inputBox.Size = UDim2.new(0,80,0,24)

			inputBox.Position = UDim2.new(0,valBtn.AbsolutePosition.X-sg.AbsolutePosition.X,0,valBtn.AbsolutePosition.Y-sg.AbsolutePosition.Y)

			inputBox.BackgroundColor3 = theme.bg

			inputBox.BackgroundTransparency = 0.1

			inputBox.BorderSizePixel = 0

			inputBox.Text = tostring(get())

			inputBox.TextColor3 = theme.txt

			inputBox.TextSize = 13

			inputBox.Font = Enum.Font.GothamBold

			inputBox.ClearTextOnFocus = false

			inputBox.ZIndex = 100

			inputBox.Parent = sg

			Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0,5)

			inputBox:CaptureFocus()

			inputBox.CursorPosition = #inputBox.Text+1

			inputBox.FocusLost:Connect(function(enter)

				if enter then

					local num = tonumber(inputBox.Text)

					if num and num>=mn and num<=mx then

						set(num)

						valBtn.Text = " "..tostring(num).." "

						fi.Size = UDim2.new((num-mn)/(mx-mn),0,1,0)

						SaveConfig()

					end

				end

				pcall(function() inputBox:Destroy() end)

			end)

			inputBox.Changed:Connect(function(prop)

				if prop=="Text" then

					local clean = inputBox.Text:gsub("[^0-9]","")

					if inputBox.Text~=clean then inputBox.Text=clean end

				end

			end)

		end)

	end

	-- ======== MAIN PAGE ========

	local mS = scroll(pFrames["Main"])

	do

		local row = Instance.new("Frame", mS)

		row.Size = UDim2.new(1,0,0,32)

		row.BackgroundColor3 = theme.sec

		row.BackgroundTransparency = 0.5

		row.BorderSizePixel = 0

		row.ZIndex = 3

		row.LayoutOrder = 1

		Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

		local lbl = Instance.new("TextLabel", row)

		lbl.Size = UDim2.new(1,-55,1,0)

		lbl.Position = UDim2.new(0,10,0,0)

		lbl.BackgroundTransparency = 1

		lbl.TextSize = 12

		lbl.Font = Enum.Font.GothamBold

		lbl.TextXAlignment = Enum.TextXAlignment.Left

		lbl.ZIndex = 4

		local tb = Instance.new("TextButton", row)

		tb.Size = UDim2.new(0,45,0,22)

		tb.Position = UDim2.new(1,-50,0.5,-11)

		tb.BackgroundTransparency = 0.2

		tb.BorderSizePixel = 0

		tb.Text = ""

		tb.ZIndex = 5

		Instance.new("UICorner", tb).CornerRadius = UDim.new(1,0)

		local ind = Instance.new("Frame", tb)

		ind.Size = UDim2.new(0,18,0,18)

		ind.BackgroundColor3 = theme.txt

		ind.BorderSizePixel = 0

		ind.ZIndex = 6

		Instance.new("UICorner", ind).CornerRadius = UDim.new(1,0)

		local function refreshEnabled()

			local on = Config.on

			local t = THEMES[Config.theme] or THEMES.Dark

			lbl.Text = on and "Enabled" or "Disabled"

			lbl.TextColor3 = on and t.ok or t.err

			tb.BackgroundColor3 = on and t.ok or t.brd

			ind.Position = on and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)

		end

		refreshEnabled()

		_G._GX7_UpdateMainStatus = refreshEnabled

		tb.MouseButton1Click:Connect(function()

			Config.on = not Config.on

			refreshEnabled()

			if _G._GX7_UpdateEspLbl then _G._GX7_UpdateEspLbl() end

			SaveConfig()

		end)

	end

	tog(mS,"Name",     function() return Config.name end,     function(v) Config.name=v end, 2)

	tog(mS,"Health",   function() return Config.hp end,       function(v) Config.hp=v end, 3)

	tog(mS,"Distance", function() return Config.distance end, function(v) Config.distance=v end, 4)

	tog(mS,"Team Check",  function() return Config.team end,   function(v) Config.team=v end, 5)

	tog(mS,"Team Colors", function() return Config.tcolor end, function(v) Config.tcolor=v end, 6)

	tog(mS,"Weapon ESP",  function() return Config.weaponESP end, function(v) Config.weaponESP=v end, 7)

	tog(mS,"Alive Check", function() return Config.alive end,     function(v) Config.alive=v end, 8)

	-- ======== VISUALS PAGE ========

	local vS = scroll(pFrames["Visuals"])

	local bindRow = Instance.new("Frame", vS)

	bindRow.Size = UDim2.new(1,0,0,60)

	bindRow.BackgroundColor3 = theme.sec

	bindRow.BackgroundTransparency = 0.5

	bindRow.BorderSizePixel = 0

	bindRow.LayoutOrder = 0

	Instance.new("UICorner", bindRow).CornerRadius = UDim.new(0,8)

	local espLbl = Instance.new("TextLabel", bindRow)

	espLbl.Size = UDim2.new(1,-10,0,28)

	espLbl.Position = UDim2.new(0,10,0,4)

	espLbl.BackgroundTransparency = 1

	espLbl.TextXAlignment = Enum.TextXAlignment.Left

	espLbl.Font = Enum.Font.GothamBold

	espLbl.TextSize = 14

	espLbl.ZIndex = 4

	espLbl.TextColor3 = theme.txt

	local function updateEspLbl()

		espLbl.Text = Config.on and "⚡ ESP ON" or "⚡ ESP OFF"

		espLbl.TextColor3 = Config.on and (THEMES[Config.theme] or THEMES.Dark).ok or (THEMES[Config.theme] or THEMES.Dark).err

	end

	updateEspLbl()

	_G._GX7_UpdateEspLbl = updateEspLbl

	local bindBtn = Instance.new("TextButton", bindRow)

	bindBtn.Size = UDim2.new(1,-20,0,20)

	bindBtn.Position = UDim2.new(0,10,0,34)

	bindBtn.BackgroundColor3 = theme.brd

	bindBtn.BackgroundTransparency = 0.3

	bindBtn.BorderSizePixel = 0

	bindBtn.ZIndex = 5

	bindBtn.Font = Enum.Font.Gotham

	bindBtn.TextSize = 11

	bindBtn.TextColor3 = theme.txt

	bindBtn.Text = "Keybind: ["..Config.keybind.."]"

	Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0,5)

	local rowHit = Instance.new("TextButton", bindRow)

	rowHit.Size = UDim2.new(1,0,0,28)

	rowHit.Position = UDim2.new(0,0,0,0)

	rowHit.BackgroundTransparency = 1

	rowHit.Text = ""

	rowHit.ZIndex = 6

	rowHit.BorderSizePixel = 0

	rowHit.MouseButton1Click:Connect(function()

		Config.on = not Config.on updateEspLbl() SaveConfig()

	end)

	local kbListening = false

	bindBtn.MouseButton1Click:Connect(function()

		if kbListening then return end

		kbListening = true

		bindBtn.Text = "Press any key..."

		local conn

		conn = UserInputService.InputBegan:Connect(function(i,g)

			if g then return end

			if i.UserInputType ~= Enum.UserInputType.Keyboard then return end

			local name = tostring(i.KeyCode):gsub("Enum.KeyCode.","")

			local BLOCKED = {"W","A","S","D","Space","Unknown","Escape","Backspace","Tab"}

			local blocked = false

			for _,b in ipairs(BLOCKED) do if name==b then blocked=true break end end

			if not blocked then

				Config.keybind = name

				bindBtn.Text = "Keybind: ["..name.."]"

				bindBtn.TextColor3 = theme.txt

				SaveConfig()

			else

				bindBtn.Text = "Key blocked!"

				bindBtn.TextColor3 = theme.err

				task.delay(1.2, function()

					bindBtn.Text = "Keybind: ["..Config.keybind.."]"

					bindBtn.TextColor3 = theme.txt

				end)

			end

			conn:Disconnect() kbListening=false

		end)

	end)

	tog(vS,"Watermark",  function() return Config.watermark end,  function(v) Config.watermark=v UpdateWatermark() end, 2)

	tog(vS,"Debug Mode", function() return Config.debugMode end,  function(v) Config.debugMode=v end, 3)

	-- ======== SETTINGS PAGE ========

	local sS = scroll(pFrames["Settings"])

	numInput(sS,"Max Distance (m)",100,5000,

		function() return math.floor(Config.dist*0.28) end,

		function(v) Config.dist=math.floor(v/0.28) end, 1)

	numInput(sS,"Thickness",1,5,

		function() return Config.thick end,

		function(v) Config.thick=v end, 2)

	numInput(sS,"Transparency",0,100,

		function() return math.floor(Config.alpha*100) end,

		function(v)

			Config.alpha=v/100

			fr.BackgroundTransparency=Config.alpha

			hdr.BackgroundTransparency=Config.alpha

		end, 3)

	local function actionBtn(par, lo, text, col, fn)

		local wrap = Instance.new("Frame", par)

		wrap.Size = UDim2.new(1,0,0,40)

		wrap.BackgroundTransparency = 1

		wrap.BorderSizePixel = 0

		wrap.LayoutOrder = lo

		local btn = Instance.new("TextButton", wrap)

		btn.Size = UDim2.new(0,220,1,0)

		btn.AnchorPoint = Vector2.new(0.5,0)

		btn.Position = UDim2.new(0.5,0,0,0)

		btn.BackgroundColor3 = col

		btn.BackgroundTransparency = 0.15

		btn.BorderSizePixel = 0

		btn.Text = text

		btn.TextColor3 = theme.txt

		btn.TextSize = 13

		btn.Font = Enum.Font.GothamBold

		btn.ZIndex = 5

		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

		local stroke = Instance.new("UIStroke", btn)

		stroke.Color = col stroke.Thickness = 1 stroke.Transparency = 0.5

		btn.MouseButton1Click:Connect(fn)

		return btn

	end

	local saveBtn = actionBtn(sS,4,"💾 Save All Configurations",theme.ok,function()

		Config.px = fr.Position.X.Offset

		Config.py = fr.Position.Y.Offset

		SaveConfig()

		local orig = saveBtn.Text

		saveBtn.Text = "✅ Saved!"

		task.delay(1, function() saveBtn.Text = orig end)

	end)

	actionBtn(sS,5,"🔄 Reset Script Completely",theme.err,function()

		for k,v in pairs(DEFAULT_CONFIG) do Config[k]=v end

		BuildGUI()

	end)

	-- ======== THEMES PAGE ========

	local THEME_GRADIENTS = {

		Dark     = {Color3.fromRGB(40,40,40),   Color3.fromRGB(0,0,0)},

		Light    = {Color3.fromRGB(255,255,255), Color3.fromRGB(200,200,200)},

		Midnight = {Color3.fromRGB(100,30,200),  Color3.fromRGB(10,10,30)},

		Ocean    = {Color3.fromRGB(0,100,160),   Color3.fromRGB(10,20,35)},

		Forest   = {Color3.fromRGB(40,100,40),   Color3.fromRGB(10,20,10)},

		Sunset   = {Color3.fromRGB(255,87,34),   Color3.fromRGB(30,15,20)},

		Neon     = {Color3.fromRGB(255,0,255),   Color3.fromRGB(10,0,20)},

		Cyberpunk= {Color3.fromRGB(0,255,255),   Color3.fromRGB(255,0,180)},

	}

	local thF = pFrames["Themes"]

	local thScroll = Instance.new("ScrollingFrame", thF)

	thScroll.Size = UDim2.new(1,0,1,0)

	thScroll.BackgroundTransparency = 1

	thScroll.BorderSizePixel = 0

	thScroll.ScrollBarThickness = 4

	thScroll.CanvasSize = UDim2.new(0,0,0,0)

	thScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

	thScroll.ScrollingDirection = Enum.ScrollingDirection.Y

	thScroll.ZIndex = 3

	local thGrid = Instance.new("Frame", thScroll)

	thGrid.Size = UDim2.new(1,0,0,0)

	thGrid.AutomaticSize = Enum.AutomaticSize.Y

	thGrid.BackgroundTransparency = 1

	thGrid.BorderSizePixel = 0

	thGrid.ZIndex = 3

	local gridLayout = Instance.new("UIGridLayout", thGrid)

	gridLayout.CellSize = UDim2.new(0.5,-6,0,82)

	gridLayout.CellPadding = UDim2.new(0,6,0,8)

	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local thPad = Instance.new("UIPadding", thGrid)

	thPad.PaddingTop    = UDim.new(0,4)

	thPad.PaddingBottom = UDim.new(0,8)

	thPad.PaddingLeft   = UDim.new(0,4)

	thPad.PaddingRight  = UDim.new(0,4)

	for idx, tn in ipairs(THEME_ORDER) do

		local tc = THEMES[tn]

		local gradColors = THEME_GRADIENTS[tn]

		local card = Instance.new("Frame", thGrid)

		card.BackgroundColor3 = Color3.fromRGB(255,255,255)

		card.BorderSizePixel = 0

		card.ZIndex = 10

		card.LayoutOrder = idx

		Instance.new("UICorner", card).CornerRadius = UDim.new(0,10)

		local grad = Instance.new("UIGradient", card)

		grad.Color = ColorSequence.new({

			ColorSequenceKeypoint.new(0, gradColors[1]),

			ColorSequenceKeypoint.new(1, gradColors[2]),

		})

		grad.Rotation = 135

		local st = Instance.new("UIStroke", card)

		st.Color = Config.theme==tn and tc.acc or tc.brd

		st.Thickness = Config.theme==tn and 3 or 1

		st.Transparency = Config.theme==tn and 0 or 0.4

		local nl = Instance.new("TextLabel", card)

		nl.Size = UDim2.new(1,0,0,26)

		nl.BackgroundColor3 = Color3.fromRGB(60,60,60)

		nl.BackgroundTransparency = 0.2

		nl.Text = tn

		nl.TextColor3 = Color3.fromRGB(255,255,255)

		nl.TextSize = 12

		nl.Font = Enum.Font.GothamBold

		nl.ZIndex = 11

		nl.TextStrokeTransparency = 1

		Instance.new("UICorner", nl).CornerRadius = UDim.new(0,10)

		if Config.theme==tn then

			local dot = Instance.new("Frame", card)

			dot.Size = UDim2.new(0,10,0,10)

			dot.Position = UDim2.new(1,-14,1,-14)

			dot.BackgroundColor3 = tc.ok

			dot.BorderSizePixel = 0

			dot.ZIndex = 12

			Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

		end

		local hb = Instance.new("TextButton", card)

		hb.Size = UDim2.new(1,0,1,0)

		hb.BackgroundTransparency = 1

		hb.Text = ""

		hb.ZIndex = 20

		hb.BorderSizePixel = 0

		local tname = tn

		hb.MouseButton1Click:Connect(function()

			Config.theme = tname

			Config.px = fr.Position.X.Offset

			Config.py = fr.Position.Y.Offset

			GUICurrentPage = "Themes"

			SaveConfig()

			BuildGUI()

		end)

	end

	-- Nav page switching

	for pn,pb in pairs(pBtns) do

		pb.MouseButton1Click:Connect(function()

			curP = pn GUICurrentPage = pn

			for n,pf in pairs(pFrames) do pf.Visible=(n==pn) end

			for n,b in pairs(pBtns) do

				b.BackgroundColor3 = n==pn and theme.acc or theme.sec

				b.TextColor3 = theme.txt

			end

		end)

	end

	bLock.MouseButton1Click:Connect(function()

		Config.menuLocked = not Config.menuLocked

		bLock.Text = Config.menuLocked and "🔒" or "🔓"

		bLock.BackgroundColor3 = Config.menuLocked and Color3.fromRGB(0,200,100) or Color3.fromRGB(0,150,255)

		SaveConfig()

	end)

	bMin.MouseButton1Click:Connect(function()

		GUIMin = not GUIMin

		body.Visible = not GUIMin

		nav.Visible = not GUIMin

		bMin.Text = GUIMin and "+" or "-"

		fr.Size = UDim2.new(0,300,0, GUIMin and 35 or 420)

		SaveConfig()

	end)

	bClose.MouseButton1Click:Connect(function()

		SaveConfig()

		-- Coleta players antes de iterar (evita modificar tabela durante pairs)

		local toRemove = {}

		for plr in pairs(ESPCache) do table.insert(toRemove, plr) end

		for _, plr in ipairs(toRemove) do pcall(function() removeESP(plr) end) end

		-- Para o loop global do ESP

		pcall(function()

			if _G._GX7_RenderConn then _G._GX7_RenderConn:Disconnect() _G._GX7_RenderConn = nil end

			if _G._GX7_InputConn  then _G._GX7_InputConn:Disconnect()  _G._GX7_InputConn  = nil end

			if _G._GX7_InputConn2 then _G._GX7_InputConn2:Disconnect() _G._GX7_InputConn2 = nil end

		end)

		-- Desconecta conexões da UI

		for _,c in ipairs(GUIConns) do pcall(function() c:Disconnect() end) end

		GUIConns = {}

		-- Destroi toda a GUI

		pcall(function()

			for _,g in ipairs(CoreGui:GetChildren()) do

				if g:IsA("ScreenGui") and g.Name:find("ESPGX7") then g:Destroy() end

			end

		end)

		print("[GX7] Script encerrado.")

	end)

end

-- ==========================================

-- INPUT HANDLERS

-- ==========================================

_G._GX7_InputConn = UserInputService.InputBegan:Connect(function(i,g)

	if g then return end

	local ok,kc = pcall(function() return Enum.KeyCode[Config.keybind] end)

	if ok and kc and i.KeyCode==kc then

		Config.on = not Config.on

		if _G._GX7_UpdateEspLbl then _G._GX7_UpdateEspLbl() end

		if _G._GX7_UpdateMainStatus then _G._GX7_UpdateMainStatus() end

	end

end)

_G._GX7_InputConn2 = UserInputService.InputBegan:Connect(function(i)

	if tostring(i.KeyCode):gsub("Enum.KeyCode.","") == "RightShift" then

		ToggleFullHide()

	end

end)

-- ==========================================

-- INIT UI

-- ==========================================

BuildGUI()

print("═══════════════════════════════════════════════════════════")

print("✅ ESP BY GX7ツ LOADED")

print("🎯 Press "..Config.keybind.." to toggle ESP")

print("👁️  Press RightShift to hide/show UI")

print("═══════════════════════════════════════════════════════════")

-- ==========================================

-- ESP IY — SINGLE GLOBAL LOOP (OPTIMIZED)

-- ==========================================

local function getRoot(char)

	if not char then return nil end

	local h = char:FindFirstChildOfClass("Humanoid")

	return h and h.RootPart or nil

end

local function getESPColor(plr)

	return Config.tcolor and plr.TeamColor or BrickColor.new("White")

end

removeESP = function(plr)

	local data = ESPCache[plr]

	if data then

		pcall(function() data.holder:Destroy() end)

		ESPCache[plr] = nil

	end

	WeaponCache[plr] = nil

	WeaponCacheTime[plr] = nil

	-- limpa qualquer holder solto

	for _,v in pairs(COREGUI:GetChildren()) do

		if v.Name == plr.Name.."_ESP" then v:Destroy() end

	end

end

local function getWeapon(char)

	if not char then return nil end

	-- Tool equipada no character (mais confiável)

	local tool = char:FindFirstChildOfClass("Tool")

	if tool then

		local name = tool.Name:gsub(" %- .*$",""):gsub(" v%d+.*$",""):gsub(" %[%d+%]$","")

		name = name:match("^%s*(.-)%s*$")

		if name ~= "" then return name end

	end

	-- HopperBin (antigo)

	local bin = char:FindFirstChildOfClass("HopperBin")

	if bin then return bin.Name end

	return nil

end

local function getCachedWeapon(plr)

	local now = os.clock()

	if not WeaponCacheTime[plr] or now - WeaponCacheTime[plr] >= WEAPON_CACHE_TTL then

		WeaponCache[plr] = getWeapon(plr.Character)

		WeaponCacheTime[plr] = now

	end

	return WeaponCache[plr]

end

buildESP = function(plr)

	removeESP(plr)

	task.spawn(function()

		-- espera character válido

		local timeout = 0

		while not (plr.Character and getRoot(plr.Character)) do

			task.wait(1)

			timeout += 1

			if timeout > 15 or not plr.Parent then return end

		end

		local char = plr.Character

		local holder = Instance.new("Folder")

		holder.Name = plr.Name.."_ESP"

		holder.Parent = COREGUI

		local boxes = {}

		local function addBox(part)

			local a = Instance.new("BoxHandleAdornment")

			a.Name = "box"

			a.Adornee = part

			a.AlwaysOnTop = true

			a.ZIndex = 10

			a.Size = part.Size

			a.Transparency = 1

			a.Color = getESPColor(plr)

			a.Parent = holder

			table.insert(boxes, a)

		end

		for _, obj in pairs(char:GetChildren()) do

			if obj:IsA("BasePart") then

				addBox(obj)

			elseif obj:IsA("Accessory") then

				-- Handle dentro do acessório (chapéu, cabelo, etc.)

				local handle = obj:FindFirstChild("Handle")

				if handle and handle:IsA("BasePart") then

					addBox(handle)

				end

			end

		end

		local bb, tl

		local head = char:FindFirstChild("Head")

		if head then

			bb = Instance.new("BillboardGui")

			bb.Adornee = head

			bb.Size = UDim2.new(0,200,0,150)

			bb.StudsOffset = Vector3.new(0,1,0)

			bb.AlwaysOnTop = true

			bb.Enabled = false

			bb.Parent = holder

			tl = Instance.new("TextLabel", bb)

			tl.BackgroundTransparency = 1

			tl.Position = UDim2.new(0,0,0,-50)

			tl.Size = UDim2.new(0,200,0,100)

			tl.Font = Enum.Font.SourceSansSemibold

			tl.TextSize = 20

			tl.TextColor3 = Color3.new(1,1,1)

			tl.TextStrokeTransparency = 0

			tl.TextYAlignment = Enum.TextYAlignment.Bottom

			tl.Text = ""

			tl.ZIndex = 10

		end

		ESPCache[plr] = {boxes=boxes, bb=bb, tl=tl, holder=holder}

		-- rebuld no respawn

		plr.CharacterAdded:Connect(function()

			task.wait(0.1)

			buildESP(plr)

		end)

		-- rebuild na mudança de time

		plr:GetPropertyChangedSignal("TeamColor"):Connect(function()

			buildESP(plr)

		end)

	end)

end

-- =============================================

-- LOOP GLOBAL ÚNICO — roda a ~10fps (throttle)

-- Em vez de N conexões RenderStepped, só 1

-- =============================================

local _frame = 0

local THROTTLE = 6 -- atualiza a cada 6 frames (~10fps a 60fps)

_G._GX7_RenderConn = RunService.RenderStepped:Connect(function()

	_frame += 1

	if _frame % THROTTLE ~= 0 then return end

	local localChar = LocalPlayer.Character

	local localRoot = localChar and getRoot(localChar)

	for plr, data in pairs(ESPCache) do

		-- verifica se player ainda existe

		if not plr.Parent then

			removeESP(plr)

			continue

		end

		-- verifica se holder ainda existe

		if not data.holder.Parent then

			ESPCache[plr] = nil

			continue

		end

		local plrChar = plr.Character

		local plrRoot = plrChar and getRoot(plrChar)

		local hum     = plrChar and plrChar:FindFirstChildOfClass("Humanoid")

		local isDead  = hum and hum.Health <= 0

		local sameTeam = Config.team and (plr.Team == LocalPlayer.Team)

		local showESP  = Config.on and not sameTeam and localRoot ~= nil and plrRoot ~= nil

		-- Alive Check: se ativado, esconde ESP de players mortos

		if Config.alive and isDead then showESP = false end

		if not showESP then

			-- esconde tudo

			for _,box in pairs(data.boxes) do box.Transparency = 1 end

			if data.bb then data.bb.Enabled = false end

			if data.tl then data.tl.Text = "" end

			continue

		end

		local studs  = (localRoot.Position - plrRoot.Position).Magnitude

		local meters = math.floor(studs * 0.28)

		-- fora do alcance

		if studs > Config.dist then

			for _,box in pairs(data.boxes) do box.Transparency = 1 end

			if data.bb then data.bb.Enabled = false end

			if data.tl then data.tl.Text = "" end

			continue

		end

		-- cores

		local espColor = getESPColor(plr)

		local textColor = Config.tcolor and plr.TeamColor.Color or Color3.new(1,1,1)

		-- boxes

		for _,box in pairs(data.boxes) do

			box.Transparency = Config.box and 0.3 or 1

			box.Color = espColor

		end

		-- billboard

		if data.bb and data.tl then

			data.bb.Enabled = true

			data.tl.TextColor3 = textColor

			local lines = {}

			if Config.weaponESP then

				local wname = getCachedWeapon(plr)

				if wname then table.insert(lines, wname) end

			end

			local info = {}

			if Config.name     then table.insert(info, plr.Name) end

			if Config.hp and hum then table.insert(info, "HP: "..math.floor(hum.Health)) end

			if Config.distance then table.insert(info, meters.."m") end

			if #info > 0 then table.insert(lines, table.concat(info, " | ")) end

			data.tl.Text = table.concat(lines, "\n")

		end

	end

end)

-- ==========================================

-- PLAYER EVENTS

-- ==========================================

for _,plr in ipairs(Players:GetPlayers()) do

	if plr ~= LocalPlayer then buildESP(plr) end

end

Players.PlayerAdded:Connect(function(plr)

	if plr ~= LocalPlayer then buildESP(plr) end

end)

Players.PlayerRemoving:Connect(function(plr)

	removeESP(plr)

end)

-- ==========================================

-- REJOIN PERSISTENCE

-- salve o script como "gx7esp.lua" no seu executor

-- e ele vai recarregar automaticamente após teleport/rejoin

-- ==========================================

pcall(function()

	local qot = queue_on_teleport

	local rf  = readfile

	if qot and rf then

		local ok, src = pcall(rf, "gx7esp.lua")

		if ok and src and src ~= "" then

			qot(src)

		end

	end

end)