-- ZiaanHub Modern v2.2 (single-file)
-- Improved UI, mobile-friendly sliders, robust features, key system + config save
-- Edit KEY_SOURCE_URL & DISCORD_INVITE sesuai kebutuhan

-- ================= CONFIG =================
local KEY_SOURCE_URL    = "https://pastebin.com/raw/3vaUdQ30"
local DISCORD_INVITE    = "https://discord.gg/vzbJt9XQ"
local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50
local DEFAULT_FLY_SPEED = 60
local UI_TOGGLE_KEY     = Enum.KeyCode.K
local NOTIF_TITLE       = "ZiaanHub"
local CONFIG_FILE       = "ZiaanHubConfig.json"

-- ================ SERVICES / HELPERS ================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local has_writefile = type(writefile) == "function"
local has_readfile  = type(readfile) == "function"
local has_isfile    = type(isfile) == "function"
local setclip = setclipboard or (syn and syn.write_clipboard) or (function() end)

local function notify(text, dur)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = NOTIF_TITLE;
            Text = text or "";
            Duration = dur or 4;
        })
    end)
end

local function tryCopyToClipboard(text)
    if setclip then
        pcall(function() setclip(text) end)
        notify("Invite disalin ke clipboard.", 3)
    else
        notify("Salin manual: "..text, 4)
    end
end

local function safeHttpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and res and #res > 0 then return res end
    return nil
end

local function fetchKeysFromUrl(url)
    local body = safeHttpGet(url)
    if not body then return {} end
    local t = {}
    for line in string.gmatch(body.."\n", "(.-)\n") do
        line = line:gsub("\r",""):gsub("^%s+",""):gsub("%s+$","")
        if line ~= "" then table.insert(t, line) end
    end
    return t
end

local function saveConfig(tbl)
    if not has_writefile then return false end
    local ok, json = pcall(function() return HttpService:JSONEncode(tbl) end)
    if not ok then return false end
    pcall(function() writefile(CONFIG_FILE, json) end)
    return true
end

local function loadConfig()
    if not has_readfile or not has_isfile then return nil end
    local ok, data = pcall(function() if not isfile(CONFIG_FILE) then return nil end; return readfile(CONFIG_FILE) end)
    if not ok or not data then return nil end
    local ok2, tbl = pcall(function() return HttpService:JSONDecode(data) end)
    if not ok2 then return nil end
    return tbl
end

-- Robust humanoid/root finder (works R6/R15)
local function getHumanoidAndRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    return hum, root, char
end

-- ================ STATE =================
local state = {
    hasAccess = false,
    rememberKey = true,
    cachedKey = nil,
    ws = DEFAULT_WALKSPEED,
    jp = DEFAULT_JUMPPOWER,
    flySpeed = DEFAULT_FLY_SPEED,
    infJump = false,
    fly = false,
    -- connections to clean up
    infJumpConn = nil,
    flyConn = nil,
    uiVisible = true
}

-- load config if possible
do
    local cfg = loadConfig()
    if cfg then
        if type(cfg.ws) == "number" then state.ws = cfg.ws end
        if type(cfg.jp) == "number" then state.jp = cfg.jp end
        if type(cfg.flySpeed) == "number" then state.flySpeed = cfg.flySpeed end
        if type(cfg.rememberKey) == "boolean" then state.rememberKey = cfg.rememberKey end
        if type(cfg.lastKey) == "string" then state.cachedKey = cfg.lastKey end
    end
end

local function persist()
    pcall(function()
        saveConfig({
            ws = state.ws,
            jp = state.jp,
            flySpeed = state.flySpeed,
            rememberKey = state.rememberKey,
            lastKey = (state.rememberKey and state.cachedKey) and state.cachedKey or nil
        })
    end)
end

-- respawn handling
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if state.hasAccess then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = state.ws or DEFAULT_WALKSPEED
            hum.JumpPower = state.jp or DEFAULT_JUMPPOWER
        end
    end
end)

-- =============== FEATURES ================
local function applyDefaults()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = DEFAULT_WALKSPEED
        hum.JumpPower = DEFAULT_JUMPPOWER
    end
    state.ws = DEFAULT_WALKSPEED
    state.jp = DEFAULT_JUMPPOWER

    if state.infJumpConn then state.infJumpConn:Disconnect(); state.infJumpConn = nil end
    state.infJump = false

    if state.flyConn then state.flyConn:Disconnect(); state.flyConn = nil end
    if state.flyGyro then pcall(function() state.flyGyro:Destroy() end); state.flyGyro = nil end
    if state.flyVel then pcall(function() state.flyVel:Destroy() end); state.flyVel = nil end
    state.fly = false

    notify("Reset ke default", 3)
    persist()
end

local function setWalkSpeed(v)
    v = tonumber(v) or DEFAULT_WALKSPEED
    v = math.clamp(v,1,500)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.WalkSpeed = v end) end
    state.ws = v
    persist()
end

local function setJumpPower(v)
    v = tonumber(v) or DEFAULT_JUMPPOWER
    v = math.clamp(v,1,600)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.JumpPower = v end) end
    state.jp = v
    persist()
end

local function setInfiniteJump(enabled)
    state.infJump = enabled
    if enabled then
        if not state.infJumpConn then
            -- use JumpRequest for compatibility (mobile & PC)
            state.infJumpConn = UIS.JumpRequest:Connect(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum and state.infJump then
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
                end
            end)
        end
        notify("Infinite Jump: ON", 2)
    else
        if state.infJumpConn then state.infJumpConn:Disconnect(); state.infJumpConn = nil end
        notify("Infinite Jump: OFF", 2)
    end
end

local function setFly(enabled)
    state.fly = enabled
    local hum, root = getHumanoidAndRoot()
    if not hum or not root then notify("Gagal: karakter tidak siap.", 2); return end

    if enabled then
        -- create safe unique names so we can clean later
        -- create BodyGyro + BodyVelocity with large forces
        local gyro = Instance.new("BodyGyro")
        gyro.Name = "ZiaanHub_FlyGyro"
        gyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
        gyro.P = 9e4
        gyro.CFrame = root.CFrame
        gyro.Parent = root

        local vel = Instance.new("BodyVelocity")
        vel.Name = "ZiaanHub_FlyVel"
        vel.MaxForce = Vector3.new(9e9,9e9,9e9)
        vel.Velocity = Vector3.new(0,0,0)
        vel.Parent = root

        state.flyGyro = gyro
        state.flyVel = vel

        -- set platform stand to true to reduce animation conflicts (reset later)
        pcall(function() hum.PlatformStand = true end)

        -- RenderStepped handler for movement
        state.flyConn = RunService.RenderStepped:Connect(function()
            if not state.fly or not root or not root.Parent then return end
            local cam = workspace.CurrentCamera
            local move = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end

            move = (move.Magnitude > 0) and move.Unit * state.flySpeed or Vector3.zero
            if state.flyVel then pcall(function() state.flyVel.Velocity = move end) end
            if state.flyGyro then pcall(function() state.flyGyro.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector) end) end
        end)

        notify("Fly: ON (WASD + Space/Shift)", 3)
    else
        if state.flyConn then state.flyConn:Disconnect(); state.flyConn = nil end
        if state.flyGyro then pcall(function() state.flyGyro:Destroy() end); state.flyGyro = nil end
        if state.flyVel then pcall(function() state.flyVel:Destroy() end); state.flyVel = nil end
        pcall(function() hum.PlatformStand = false end)
        notify("Fly: OFF", 2)
    end
    persist()
end

-- =============== UI BUILD ===============
pcall(function() CoreGui:FindFirstChild("ZiaanHub_CustomUI"):Destroy() end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZiaanHub_CustomUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Root container: scale-based so it looks OK on mobile/pc
local rootFrame = Instance.new("Frame", ScreenGui)
rootFrame.Name = "RootFrame"
rootFrame.AnchorPoint = Vector2.new(0.5, 0.5)
rootFrame.Size = UDim2.new(0.92, 0, 0.86, 0)
rootFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
rootFrame.BackgroundColor3 = Color3.fromRGB(20,20,22)
rootFrame.BackgroundTransparency = 0.02
rootFrame.BorderSizePixel = 0
Instance.new("UICorner", rootFrame).CornerRadius = UDim.new(0,12)
local rootStroke = Instance.new("UIStroke", rootFrame)
rootStroke.Thickness = 2
rootStroke.Color = Color3.fromRGB(10,140,220)

-- Header
local header = Instance.new("Frame", rootFrame)
header.Size = UDim2.new(1, 0, 0, 64)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.6, -20, 1, -12)
title.Position = UDim2.new(0, 16, 0, 6)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(245,245,245)
title.Text = "ZiaanHub"
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = Instance.new("TextLabel", header)
subtitle.Size = UDim2.new(0.4, -20, 1, -12)
subtitle.Position = UDim2.new(0.6, 12, 0, 6)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 13
subtitle.TextColor3 = Color3.fromRGB(190,190,190)
subtitle.Text = "by Ziaan • modern"

-- header buttons
local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.new(0, 44, 0, 36)
btnMin.Position = UDim2.new(1, -104, 0, 14)
btnMin.Text = "—"
btnMin.Font = Enum.Font.GothamBold
btnMin.TextSize = 20
btnMin.BackgroundColor3 = Color3.fromRGB(36,36,38)
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0,8)

local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0, 44, 0, 36)
btnClose.Position = UDim2.new(1, -52, 0, 14)
btnClose.Text = "✕"
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 16
btnClose.BackgroundColor3 = Color3.fromRGB(38,38,40)
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0,8)

-- Left tabs (vertical)
local leftPanel = Instance.new("Frame", rootFrame)
leftPanel.Size = UDim2.new(0, 220, 1, -96)
leftPanel.Position = UDim2.new(0, 16, 0, 72)
leftPanel.BackgroundTransparency = 1

local leftBg = Instance.new("Frame", leftPanel)
leftBg.Size = UDim2.new(1, 0, 1, 0)
leftBg.BackgroundColor3 = Color3.fromRGB(14,14,16)
leftBg.BorderSizePixel = 0
Instance.new("UICorner", leftBg).CornerRadius = UDim.new(0,12)
local leftStroke = Instance.new("UIStroke", leftBg); leftStroke.Thickness = 1; leftStroke.Color = Color3.fromRGB(45,45,45)

local tabsLayout = Instance.new("UIListLayout", leftBg)
tabsLayout.Padding = UDim.new(0,12)
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local function makeTab(text)
    local btn = Instance.new("TextButton", leftBg)
    btn.Size = UDim2.new(1, -28, 0, 52)
    btn.BackgroundColor3 = Color3.fromRGB(36,36,38)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(235,235,235)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke", btn); stroke.Thickness = 1; stroke.Color = Color3.fromRGB(55,55,55)
    btn.MouseEnter:Connect(function() pcall(function() TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(46,46,48)}):Play() end) end)
    btn.MouseLeave:Connect(function() pcall(function() TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(36,36,38)}):Play() end) end)
    return btn
end

-- Pages container
local pagesContainer = Instance.new("Frame", rootFrame)
pagesContainer.Size = UDim2.new(1, -260, 1, -96)
pagesContainer.Position = UDim2.new(0, 248, 0, 72)
pagesContainer.BackgroundTransparency = 1

local pages = {}
local currentPage
local function createPage(name)
    local f = Instance.new("Frame", pagesContainer)
    f.Size = UDim2.new(1, -12, 1, -12)
    f.Position = UDim2.new(0,6,0,6)
    f.BackgroundColor3 = Color3.fromRGB(12,12,14)
    f.BorderSizePixel = 0
    f.Visible = false
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
    pages[name] = f
    return f
end

local function showPage(name)
    if currentPage and currentPage ~= pages[name] then
        pcall(function() TweenService:Create(currentPage, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play() end)
        task.wait(0.12)
        currentPage.Visible = false
    end
    currentPage = pages[name]
    if currentPage then
        currentPage.Visible = true
        currentPage.BackgroundTransparency = 1
        pcall(function() TweenService:Create(currentPage, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play() end)
    end
end

-- Create tabs & pages
local tabHome = makeTab("Home")
local tabFeatures = makeTab("Features")
local tabAbout = makeTab("About")

local pageHome = createPage("Home")
local pageFeatures = createPage("Features")
local pageAbout = createPage("About")

-- HOME content
do
    local headerLabel = Instance.new("TextLabel", pageHome)
    headerLabel.Size = UDim2.new(1, -24, 0, 32)
    headerLabel.Position = UDim2.new(0, 12, 0, 12)
    headerLabel.BackgroundTransparency = 1
    headerLabel.Font = Enum.Font.GothamBlack
    headerLabel.TextSize = 18
    headerLabel.TextColor3 = Color3.fromRGB(245,245,245)
    headerLabel.Text = "Welcome to ZiaanHub"

    local desc = Instance.new("TextLabel", pageHome)
    desc.Size = UDim2.new(1, -24, 0, 100)
    desc.Position = UDim2.new(0, 12, 0, 48)
    desc.BackgroundTransparency = 1
    desc.TextWrapped = true
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 14
    desc.TextColor3 = Color3.fromRGB(200,200,200)
    desc.Text = "Modern hub by Ziaan. Fitur utama: WalkSpeed, JumpPower, Infinite Jump, Fly.\nUI mobile-friendly & works across most rigs/maps."

    local discordBtn = Instance.new("TextButton", pageHome)
    discordBtn.Size = UDim2.new(0, 220, 0, 40)
    discordBtn.Position = UDim2.new(0, 12, 1, -60)
    discordBtn.Text = "Copy Discord Invite"
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.TextSize = 14
    discordBtn.BackgroundColor3 = Color3.fromRGB(40,40,44)
    discordBtn.TextColor3 = Color3.fromRGB(240,240,240)
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0,8)
    discordBtn.MouseButton1Click:Connect(function()
        tryCopyToClipboard(DISCORD_INVITE)
    end)

    local statusBar = Instance.new("TextLabel", pageHome)
    statusBar.Size = UDim2.new(1, -24, 0, 24)
    statusBar.Position = UDim2.new(0, 12, 1, -100)
    statusBar.BackgroundTransparency = 1
    statusBar.Font = Enum.Font.Gotham
    statusBar.TextSize = 13
    statusBar.TextColor3 = Color3.fromRGB(200,200,200)
    statusBar.Text = "Key: "..(state.cachedKey and "cached" or "not cached")
    state._statusBar = statusBar
end

-- FEATURES content (with robust sliders and mobile support)
do
    local function makeLabel(parent, text, y)
        local t = Instance.new("TextLabel", parent)
        t.Size = UDim2.new(0.5, -12, 0, 20)
        t.Position = UDim2.new(0, 12, 0, y)
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.GothamBold
        t.TextColor3 = Color3.fromRGB(230,230,230)
        t.TextSize = 14
        t.Text = text
        return t
    end

    -- generic slider builder (returns table with set/get)
    local function createSlider(parent, labelY, minV, maxV, initial)
        makeLabel(parent, "", labelY) -- placeholder (we set text externally)
        local bar = Instance.new("Frame", parent)
        bar.Size = UDim2.new(0.6, 0, 0, 12)
        bar.Position = UDim2.new(0, 12, 0, labelY + 28)
        bar.BackgroundColor3 = Color3.fromRGB(36,36,36)
        bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(0,0,1,0)
        fill.BackgroundColor3 = Color3.fromRGB(0,160,255)
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0,6)

        local knob = Instance.new("Frame", bar)
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(0, 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(0,9)

        local valueBox = Instance.new("TextBox", parent)
        valueBox.Size = UDim2.new(0, 100, 0, 28)
        valueBox.Position = UDim2.new(0.62, 12, 0, labelY + 20)
        valueBox.BackgroundColor3 = Color3.fromRGB(36,36,36)
        valueBox.TextColor3 = Color3.fromRGB(230,230,230)
        valueBox.ClearTextOnFocus = false
        valueBox.Font = Enum.Font.Gotham
        valueBox.TextSize = 14

        local dragging = false
        local function setValue(v)
            v = math.clamp(math.floor(v), minV, maxV)
            local rel = (v - minV) / math.max(1, (maxV - minV))
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
            valueBox.Text = tostring(v)
        end

        -- Input handlers (mouse + touch)
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local absX = (input.Position and input.Position.X) or 0
                local rel = math.clamp((absX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(minV + rel * (maxV - minV))
                setValue(val)
                return val
            end
        end)
        bar.InputChanged:Connect(function(input)
            -- used for some touch devices, but main dragging handled by global InputChanged below
        end)

        -- use UIS.InputChanged so both touch and mouse move are handled
        local connMove
        connMove = UIS.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local absX = (input.Position and input.Position.X) or 0
                local rel = math.clamp((absX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(minV + rel * (maxV - minV))
                setValue(val)
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    dragging = false
                end
            end
        end)

        valueBox.FocusLost:Connect(function(enter)
            if enter then
                local num = tonumber(valueBox.Text)
                if num then
                    setValue(math.clamp(math.floor(num), minV, maxV))
                else
                    setValue(initial)
                end
            end
        end)

        -- initialize
        setValue(initial)
        return {
            Set = setValue,
            Get = function()
                return tonumber(valueBox.Text) or initial
            end,
            ValueBox = valueBox,
            Dispose = function()
                if connMove then connMove:Disconnect() end
            end,
            Fill = fill,
            Knob = knob
        }
    end

    -- WalkSpeed
    local wsLabel = Instance.new("TextLabel", pageFeatures)
    wsLabel.Size = UDim2.new(0.5,-12,0,20)
    wsLabel.Position = UDim2.new(0,12,0,12)
    wsLabel.BackgroundTransparency = 1
    wsLabel.Font = Enum.Font.GothamBold
    wsLabel.TextSize = 14
    wsLabel.TextColor3 = Color3.fromRGB(230,230,230)
    wsLabel.Text = "WalkSpeed"

    local wsSlider = createSlider(pageFeatures, 12, 1, 350, state.ws)
    wsSlider.ValueBox.FocusLost:Connect(function(enter)
        if enter then
            local n = tonumber(wsSlider.ValueBox.Text)
            if n then
                setWalkSpeed(n)
                wsSlider.Set(state.ws)
            end
        end
    end)
    -- live update on drag via InputChanged: we connect an additional small loop to set value to humanoid
    do
        local last = state.ws
        local function update()
            local n = tonumber(wsSlider.ValueBox.Text) or state.ws
            if n ~= last then
                setWalkSpeed(n)
                last = n
            end
        end
        -- small heartbeat to apply while user drags (lightweight)
        local conn = RunService.Heartbeat:Connect(function()
            update()
        end)
        -- disconnect on cleanup if needed later (not strictly necessary)
    end

    -- JumpPower
    local jpLabel = Instance.new("TextLabel", pageFeatures)
    jpLabel.Size = UDim2.new(0.5,-12,0,20)
    jpLabel.Position = UDim2.new(0,12,0,96)
    jpLabel.BackgroundTransparency = 1
    jpLabel.Font = Enum.Font.GothamBold
    jpLabel.TextSize = 14
    jpLabel.TextColor3 = Color3.fromRGB(230,230,230)
    jpLabel.Text = "JumpPower"

    local jpSlider = createSlider(pageFeatures, 96, 1, 500, state.jp)
    jpSlider.ValueBox.FocusLost:Connect(function(enter)
        if enter then
            local n = tonumber(jpSlider.ValueBox.Text)
            if n then
                setJumpPower(n)
                jpSlider.Set(state.jp)
            end
        end
    end)
    do
        local last = state.jp
        local conn = RunService.Heartbeat:Connect(function()
            local n = tonumber(jpSlider.ValueBox.Text) or state.jp
            if n ~= last then
                setJumpPower(n)
                last = n
            end
        end)
    end

    -- Infinite Jump toggle
    local ijBtn = Instance.new("TextButton", pageFeatures)
    ijBtn.Size = UDim2.new(0, 280, 0, 40)
    ijBtn.Position = UDim2.new(0, 12, 0, 192)
    ijBtn.Text = "Infinite Jump • OFF (I)"
    ijBtn.Font = Enum.Font.GothamBold
    ijBtn.TextSize = 14
    ijBtn.BackgroundColor3 = Color3.fromRGB(38,38,40)
    Instance.new("UICorner", ijBtn).CornerRadius = UDim.new(0,8)
    ijBtn.MouseButton1Click:Connect(function()
        setInfiniteJump(not state.infJump)
        ijBtn.Text = "Infinite Jump • "..(state.infJump and "ON (I)" or "OFF (I)")
        ijBtn.BackgroundColor3 = state.infJump and Color3.fromRGB(0,160,90) or Color3.fromRGB(38,38,40)
    end)

    -- Fly toggle and speed input
    local flyBtn = Instance.new("TextButton", pageFeatures)
    flyBtn.Size = UDim2.new(0, 280, 0, 40)
    flyBtn.Position = UDim2.new(0, 12, 0, 248)
    flyBtn.Text = "Fly • OFF (F)"
    flyBtn.Font = Enum.Font.GothamBold
    flyBtn.TextSize = 14
    flyBtn.BackgroundColor3 = Color3.fromRGB(38,38,40)
    Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0,8)

    local flyInput = Instance.new("TextBox", pageFeatures)
    flyInput.Size = UDim2.new(0, 120, 0, 34)
    flyInput.Position = UDim2.new(0, 306, 0, 252)
    flyInput.PlaceholderText = tostring(state.flySpeed)
    flyInput.ClearTextOnFocus = false
    flyInput.BackgroundColor3 = Color3.fromRGB(36,36,36)
    flyInput.TextColor3 = Color3.fromRGB(230,230,230)
    Instance.new("UICorner", flyInput).CornerRadius = UDim.new(0,8)

    flyBtn.MouseButton1Click:Connect(function()
        local n = tonumber(flyInput.Text) or state.flySpeed or DEFAULT_FLY_SPEED
        state.flySpeed = math.clamp(n, 10, 500)
        setFly(not state.fly)
        flyBtn.Text = "Fly • "..(state.fly and "ON (F)" or "OFF (F)")
        flyBtn.BackgroundColor3 = state.fly and Color3.fromRGB(0,160,90) or Color3.fromRGB(38,38,40)
    end)

    -- Reset
    local resetBtn = Instance.new("TextButton", pageFeatures)
    resetBtn.Size = UDim2.new(0, 180, 0, 36)
    resetBtn.Position = UDim2.new(0, 12, 0, 312)
    resetBtn.Text = "Reset to Default (R)"
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 14
    resetBtn.BackgroundColor3 = Color3.fromRGB(150,55,55)
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,8)
    resetBtn.MouseButton1Click:Connect(function()
        applyDefaults()
        wsSlider.Set(state.ws)
        jpSlider.Set(state.jp)
        flyBtn.Text = "Fly • OFF (F)"; flyBtn.BackgroundColor3 = Color3.fromRGB(38,38,40)
        ijBtn.Text = "Infinite Jump • OFF (I)"; ijBtn.BackgroundColor3 = Color3.fromRGB(38,38,40)
    end)
end

-- ABOUT content
do
    local aboutTitle = Instance.new("TextLabel", pageAbout)
    aboutTitle.Size = UDim2.new(1, -24, 0, 28)
    aboutTitle.Position = UDim2.new(0, 12, 0, 12)
    aboutTitle.BackgroundTransparency = 1
    aboutTitle.Font = Enum.Font.GothamBlack
    aboutTitle.TextSize = 18
    aboutTitle.TextColor3 = Color3.fromRGB(245,245,245)
    aboutTitle.Text = "About ZiaanHub"

    local aboutTxt = Instance.new("TextLabel", pageAbout)
    aboutTxt.Size = UDim2.new(1, -24, 1, -64)
    aboutTxt.Position = UDim2.new(0, 12, 0, 46)
    aboutTxt.BackgroundTransparency = 1
    aboutTxt.Font = Enum.Font.Gotham
    aboutTxt.TextSize = 14
    aboutTxt.TextColor3 = Color3.fromRGB(200,200,200)
    aboutTxt.TextWrapped = true
    aboutTxt.Text = "ZiaanHub oleh Ziaan\nVersi: 2.2\nFitur: WalkSpeed, JumpPower, Infinite Jump, Fly.\nMobile & PC suport. Save config jika executor mendukung."

    local rememberBtn = Instance.new("TextButton", pageAbout)
    rememberBtn.Size = UDim2.new(0, 220, 0, 36)
    rememberBtn.Position = UDim2.new(0, 12, 1, -60)
    rememberBtn.Font = Enum.Font.GothamBold
    rememberBtn.TextSize = 14
    rememberBtn.BackgroundColor3 = Color3.fromRGB(40,40,44)
    Instance.new("UICorner", rememberBtn).CornerRadius = UDim.new(0,8)
    rememberBtn.Text = "Remember Key: "..(state.rememberKey and "ON" or "OFF")
    rememberBtn.MouseButton1Click:Connect(function()
        state.rememberKey = not state.rememberKey
        rememberBtn.Text = "Remember Key: "..(state.rememberKey and "ON" or "OFF")
        persist()
    end)
end

-- tab bindings
tabHome.MouseButton1Click:Connect(function() showPage("Home") end)
tabFeatures.MouseButton1Click:Connect(function() showPage("Features") end)
tabAbout.MouseButton1Click:Connect(function() showPage("About") end)
showPage("Home")

-- header controls functionality
btnMin.MouseButton1Click:Connect(function()
    if rootFrame.Size.X.Scale > 0.7 then
        -- minimize (animate)
        TweenService:Create(rootFrame, TweenInfo.new(0.16), {Size = UDim2.new(0.3,0,0.11,0)}):Play()
        task.delay(0.16,function()
            for _,v in pairs(rootFrame:GetChildren()) do
                if v ~= header then v.Visible = false end
            end
        end)
    else
        for _,v in pairs(rootFrame:GetChildren()) do v.Visible = true end
        TweenService:Create(rootFrame, TweenInfo.new(0.16), {Size = UDim2.new(0.92,0,0.86,0)}):Play()
    end
end)
btnClose.MouseButton1Click:Connect(function() pcall(function() ScreenGui:Destroy() end) end)

-- =============== KEY OVERLAY ===============
local keyOverlay = Instance.new("Frame", ScreenGui)
keyOverlay.AnchorPoint = Vector2.new(0.5,0.5)
keyOverlay.Size = UDim2.new(0.78, 0, 0.6, 0)
keyOverlay.Position = UDim2.new(0.5, 0, 0.5, 0)
keyOverlay.BackgroundColor3 = Color3.fromRGB(22,22,24)
keyOverlay.BorderSizePixel = 0
Instance.new("UICorner", keyOverlay).CornerRadius = UDim.new(0,12)
local keyStroke = Instance.new("UIStroke", keyOverlay); keyStroke.Color = Color3.fromRGB(0,150,255); keyStroke.Thickness = 2

local keyTitle = Instance.new("TextLabel", keyOverlay)
keyTitle.Size = UDim2.new(1, -36, 0, 34)
keyTitle.Position = UDim2.new(0, 18, 0, 18)
keyTitle.BackgroundTransparency = 1
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 18
keyTitle.Text = "ZiaanHub | Masukkan Key"
keyTitle.TextColor3 = Color3.fromRGB(245,245,245)

local keyNote = Instance.new("TextLabel", keyOverlay)
keyNote.Size = UDim2.new(1, -36, 0, 36)
keyNote.Position = UDim2.new(0, 18, 0, 56)
keyNote.BackgroundTransparency = 1
keyNote.Font = Enum.Font.Gotham
keyNote.TextSize = 14
keyNote.TextWrapped = true
keyNote.Text = "Ambil key di Discord. Tekan Salin Discord untuk copy invite."

local keyBox = Instance.new("TextBox", keyOverlay)
keyBox.Size = UDim2.new(1, -36, 0, 48)
keyBox.Position = UDim2.new(0, 18, 0, 108)
keyBox.BackgroundColor3 = Color3.fromRGB(36,36,38)
keyBox.TextColor3 = Color3.fromRGB(235,235,235)
keyBox.PlaceholderText = "Paste key di sini..."
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0,8)

local keyVerifyBtn = Instance.new("TextButton", keyOverlay)
keyVerifyBtn.Size = UDim2.new(0.48, -22, 0, 46)
keyVerifyBtn.Position = UDim2.new(0, 18, 0, 170)
keyVerifyBtn.Text = "Verifikasi Key"
keyVerifyBtn.Font = Enum.Font.GothamBold
keyVerifyBtn.TextSize = 14
keyVerifyBtn.BackgroundColor3 = Color3.fromRGB(0,170,85)
Instance.new("UICorner", keyVerifyBtn).CornerRadius = UDim.new(0,8)

local keyDiscordBtn = Instance.new("TextButton", keyOverlay)
keyDiscordBtn.Size = UDim2.new(0.48, -22, 0, 46)
keyDiscordBtn.Position = UDim2.new(0.52, 4, 0, 170)
keyDiscordBtn.Text = "Salin Discord"
keyDiscordBtn.Font = Enum.Font.GothamBold
keyDiscordBtn.TextSize = 14
keyDiscordBtn.BackgroundColor3 = Color3.fromRGB(44,44,46)
Instance.new("UICorner", keyDiscordBtn).CornerRadius = UDim.new(0,8)

local keyStatus = Instance.new("TextLabel", keyOverlay)
keyStatus.Size = UDim2.new(1, -36, 0, 24)
keyStatus.Position = UDim2.new(0, 18, 0, 226)
keyStatus.BackgroundTransparency = 1
keyStatus.Font = Enum.Font.Gotham
keyStatus.TextSize = 14
keyStatus.TextColor3 = Color3.fromRGB(255,120,120)
keyStatus.TextXAlignment = Enum.TextXAlignment.Left

if state.rememberKey and state.cachedKey then keyBox.Text = state.cachedKey end

local function verifyKeyFlow()
    keyStatus.TextColor3 = Color3.fromRGB(200,200,200)
    keyStatus.Text = "Memeriksa key..."
    local keys = fetchKeysFromUrl(KEY_SOURCE_URL)
    if #keys == 0 then
        keyStatus.TextColor3 = Color3.fromRGB(255,120,120)
        keyStatus.Text = "Gagal ambil key dari server."
        notify("Gagal ambil key.", 3)
        return
    end
    local input = (keyBox.Text or ""):gsub("^%s+",""):gsub("%s+$","")
    if input == "" then
        keyStatus.TextColor3 = Color3.fromRGB(255,120,120)
        keyStatus.Text = "Masukkan key terlebih dahulu."
        return
    end
    for _,k in ipairs(keys) do
        if input == k then
            keyStatus.TextColor3 = Color3.fromRGB(120,255,140)
            keyStatus.Text = "Key valid! Membuka UI..."
            notify("Key valid. Welcome!", 3)
            state.hasAccess = true
            if state.rememberKey then state.cachedKey = input; persist() end
            task.wait(0.45)
            -- animate out
            pcall(function() TweenService:Create(keyOverlay, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 1, Position = keyOverlay.Position + UDim2.new(0,0,0,40)}):Play() end)
            task.wait(0.18)
            keyOverlay.Visible = false
            rootFrame.Visible = true
            applyDefaults()
            if state._statusBar then state._statusBar.Text = "Key: valid" end
            return
        end
    end
    keyStatus.TextColor3 = Color3.fromRGB(255,120,120)
    keyStatus.Text = "Key tidak ditemukan. Cek Discord."
    notify("Key salah.", 3)
    if state._statusBar then state._statusBar.Text = "Key: invalid" end
end

keyVerifyBtn.MouseButton1Click:Connect(verifyKeyFlow)
keyBox.FocusLost:Connect(function(enter) if enter then verifyKeyFlow() end end)
keyDiscordBtn.MouseButton1Click:Connect(function() tryCopyToClipboard(DISCORD_INVITE) end)

-- initial visibility
rootFrame.Visible = false
keyOverlay.Visible = true

-- UI toggle & hotkeys
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == UI_TOGGLE_KEY then
        if state.hasAccess then
            state.uiVisible = not state.uiVisible
            if state.uiVisible then
                rootFrame.Visible = true
                rootFrame.Position = UDim2.new(0.5, 0, 0.5, -20)
                TweenService:Create(rootFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
            else
                TweenService:Create(rootFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, 0, 0.5, 60)}):Play()
                task.delay(0.18, function() rootFrame.Visible = false end)
            end
        else
            keyOverlay.Visible = not keyOverlay.Visible
        end
    elseif input.KeyCode == Enum.KeyCode.I then
        if state.hasAccess then setInfiniteJump(not state.infJump); notify("InfiniteJump "..(state.infJump and "ON" or "OFF"),2) end
    elseif input.KeyCode == Enum.KeyCode.F then
        if state.hasAccess then setFly(not state.fly); notify("Fly "..(state.fly and "ON" or "OFF"),2) end
    elseif input.KeyCode == Enum.KeyCode.R then
        if state.hasAccess then applyDefaults() end
    end
end)

-- auto-verify cached key if available
if state.rememberKey and state.cachedKey then
    task.spawn(function()
        local keys = fetchKeysFromUrl(KEY_SOURCE_URL)
        if #keys > 0 then
            for _,k in ipairs(keys) do
                if k == state.cachedKey then
                    state.hasAccess = true
                    keyOverlay.Visible = false
                    rootFrame.Visible = true
                    applyDefaults()
                    if state._statusBar then state._statusBar.Text = "Key: valid (auto)" end
                    return
                end
            end
        end
    end)
end

notify("ZiaanHub siap. Tekan K untuk membuka/tutup (setelah verifikasi).", 5)

-- cleanup hook
_G.ZiaanHubCleanup = function()
    if state.infJumpConn then state.infJumpConn:Disconnect(); state.infJumpConn=nil end
    if state.flyConn then state.flyConn:Disconnect(); state.flyConn=nil end
    if state.flyGyro then pcall(function() state.flyGyro:Destroy() end); state.flyGyro=nil end
    if state.flyVel then pcall(function() state.flyVel:Destroy() end); state.flyVel=nil end
    pcall(function() ScreenGui:Destroy() end)
end
