--[[
  ZiaanHub Modern v2.0 (single-file)
  - Full custom animated UI (no external libs)
  - Key System (fetch keys from URL)
  - Features: WalkSpeed (slider), JumpPower (slider), Infinite Jump (toggle), Fly (toggle + speed)
  - Reset defaults, Discord button, Home/Features/About tabs
  - Toggle UI: K
  Notes:
   - GANTI KEY_SOURCE_URL & DISCORD_INVITE sesuai milikmu
   - Clipboard only works if executor exposes setclipboard (KRNL/Synapse etc)
--]]

-- ============== CONFIG ==============
local KEY_SOURCE_URL    = "https://pastebin.com/raw/3vaUdQ30"  -- RAW text: satu key per baris
local DISCORD_INVITE    = "https://discord.gg/vzbJt9XQ"
local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50
local DEFAULT_FLY_SPEED = 60
local UI_TOGGLE_KEY     = Enum.KeyCode.K
local NOTIF_TITLE       = "ZiaanHub"

-- ============= SERVICES / HELPERS ============
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local setclip = setclipboard or (syn and syn.write_clipboard) or (function() end)
local function tryCopyToClipboard(text)
    if setclip then
        pcall(function() setclip(text) end)
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = NOTIF_TITLE;
                Text = "Link disalin ke clipboard.";
                Duration = 3;
            })
        end)
    else
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = NOTIF_TITLE;
                Text = "Salin manual: "..text;
                Duration = 5;
            })
        end)
    end
end

local function notify(msg, dur)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = NOTIF_TITLE;
            Text = msg or "";
            Duration = dur or 4;
        })
    end)
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
    for line in string.gmatch(body.."\n","(.-)\n") do
        line = line:gsub("\r",""):gsub("^%s+",""):gsub("%s+$","")
        if line ~= "" then table.insert(t, line) end
    end
    return t
end

local function getHumanoidAndRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    return hum, root, char
end

-- ============ STATE ============
local state = {
    keys = {},
    uiVisible = true,
    hasAccess = false,
    ws = DEFAULT_WALKSPEED,
    jp = DEFAULT_JUMPPOWER,
    flySpeed = DEFAULT_FLY_SPEED,
    infJump = false,
    fly = false,
    flyConn = nil,
    infJumpConn = nil,
    flyGyro = nil,
    flyVel = nil,
}

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

-- ============ FEATURES (logic) ============
local function applyDefaults()
    local hum = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
    if hum then
        hum.WalkSpeed = DEFAULT_WALKSPEED
        hum.JumpPower = DEFAULT_JUMPPOWER
        state.ws = DEFAULT_WALKSPEED
        state.jp = DEFAULT_JUMPPOWER
    end
    if state.infJumpConn then state.infJumpConn:Disconnect(); state.infJumpConn = nil end
    state.infJump = false
    if state.flyConn then state.flyConn:Disconnect(); state.flyConn = nil end
    if state.flyGyro then state.flyGyro:Destroy(); state.flyGyro = nil end
    if state.flyVel then state.flyVel:Destroy(); state.flyVel = nil end
    state.fly = false
    notify("Semua fitur direset ke default.", 3)
end

local function setWalkSpeed(v)
    v = tonumber(v) or DEFAULT_WALKSPEED
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
    state.ws = v
end

local function setJumpPower(v)
    v = tonumber(v) or DEFAULT_JUMPPOWER
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = v end
    state.jp = v
end

local function setInfiniteJump(enabled)
    state.infJump = enabled
    if enabled then
        if not state.infJumpConn then
            state.infJumpConn = UIS.JumpRequest:Connect(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum and state.infJump then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
        notify("Infinite Jump ON", 2)
    else
        if state.infJumpConn then state.infJumpConn:Disconnect(); state.infJumpConn = nil end
        notify("Infinite Jump OFF", 2)
    end
end

local function setFly(enabled)
    state.fly = enabled
    local hum, root, char = getHumanoidAndRoot()
    if not hum or not root then return end

    if enabled then
        local gyro = Instance.new("BodyGyro")
        gyro.P = 9e4
        gyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
        gyro.CFrame = root.CFrame
        gyro.Parent = root

        local vel = Instance.new("BodyVelocity")
        vel.MaxForce = Vector3.new(9e9,9e9,9e9)
        vel.Velocity = Vector3.zero
        vel.Parent = root

        state.flyGyro = gyro
        state.flyVel = vel

        hum.PlatformStand = true

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

            move = move.Magnitude > 0 and move.Unit * state.flySpeed or Vector3.zero
            if state.flyVel then state.flyVel.Velocity = move end
            if state.flyGyro then state.flyGyro.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector) end
        end)

        notify("Fly ON (WASD + Space/Shift)", 3)
    else
        if state.flyConn then state.flyConn:Disconnect(); state.flyConn = nil end
        if state.flyGyro then state.flyGyro:Destroy(); state.flyGyro=nil end
        if state.flyVel then state.flyVel:Destroy(); state.flyVel=nil end
        hum.PlatformStand = false
        notify("Fly OFF", 2)
    end
end

-- ============ BUILD MODERN ANIMATED UI ============
pcall(function() CoreGui:FindFirstChild("ZiaanHub_CustomUI"):Destroy() end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZiaanHub_CustomUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- container
local rootFrame = Instance.new("Frame", ScreenGui)
rootFrame.Size = UDim2.new(0, 780, 0, 460)
rootFrame.Position = UDim2.new(0.5, -390, 0.5, -230)
rootFrame.BackgroundColor3 = Color3.fromRGB(22,22,24)
rootFrame.BackgroundTransparency = 0.06
rootFrame.BorderSizePixel = 0
rootFrame.Active = true
rootFrame.Draggable = true
rootFrame.Name = "Root"
Instance.new("UICorner", rootFrame).CornerRadius = UDim.new(0,16)
local rootStroke = Instance.new("UIStroke", rootFrame)
rootStroke.Thickness = 2
rootStroke.Color = Color3.fromRGB(10,150,255)

-- faint vignette / glass
local glass = Instance.new("ImageLabel", rootFrame)
glass.Size = UDim2.new(1, 0, 1, 0)
glass.Position = UDim2.new(0,0,0,0)
glass.BackgroundTransparency = 1
glass.Image = "rbxassetid://3570695787"
glass.ImageColor3 = Color3.fromRGB(30,30,34)
glass.ImageTransparency = 0.88
glass.ScaleType = Enum.ScaleType.Slice
glass.SliceCenter = Rect.new(100,100,100,100)
glass.ZIndex = 0

-- header
local header = Instance.new("Frame", rootFrame)
header.Size = UDim2.new(1, 0, 0, 72)
header.Position = UDim2.new(0,0,0,0)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.65, 0, 1, -18)
title.Position = UDim2.new(0, 18, 0, 12)
title.BackgroundTransparency = 1
title.Text = "ZiaanHub"
title.TextColor3 = Color3.fromRGB(245,245,245)
title.Font = Enum.Font.GothamBlack
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = Instance.new("TextLabel", header)
subtitle.Size = UDim2.new(0.35, -20, 1, -18)
subtitle.Position = UDim2.new(0.65, 8, 0, 12)
subtitle.BackgroundTransparency = 1
subtitle.Text = "by Ziaan"
subtitle.TextColor3 = Color3.fromRGB(170,170,170)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 14
subtitle.TextXAlignment = Enum.TextXAlignment.Right

-- left tabs
local tabsContainer = Instance.new("Frame", rootFrame)
tabsContainer.Size = UDim2.new(0, 200, 1, -100)
tabsContainer.Position = UDim2.new(0, 18, 0, 88)
tabsContainer.BackgroundTransparency = 1

local tabsBg = Instance.new("Frame", tabsContainer)
tabsBg.Size = UDim2.new(1, 0, 1, 0)
tabsBg.Position = UDim2.new(0,0,0,0)
tabsBg.BackgroundColor3 = Color3.fromRGB(18,18,20)
tabsBg.BorderSizePixel = 0
Instance.new("UICorner", tabsBg).CornerRadius = UDim.new(0,12)
local tabsStroke = Instance.new("UIStroke", tabsBg) tabsStroke.Thickness = 1 tabsStroke.Color = Color3.fromRGB(45,45,45)

local function createTabButton(text, y)
    local btn = Instance.new("TextButton", tabsBg)
    btn.Size = UDim2.new(1, -28, 0, 52)
    btn.Position = UDim2.new(0, 14, 0, 14 + y)
    btn.BackgroundColor3 = Color3.fromRGB(38,38,40)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.TextColor3 = Color3.fromRGB(235,235,235)
    btn.Text = text
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke", btn) stroke.Thickness = 1 stroke.Color = Color3.fromRGB(55,55,55)
    -- hover animation
    btn.MouseEnter:Connect(function()
        pcall(function() TweenService:Create(btn, TweenInfo.new(0.13), {BackgroundColor3 = Color3.fromRGB(48,48,50)}):Play() end)
    end)
    btn.MouseLeave:Connect(function()
        pcall(function() TweenService:Create(btn, TweenInfo.new(0.13), {BackgroundColor3 = Color3.fromRGB(38,38,40)}):Play() end)
    end)
    return btn
end

local pagesContainer = Instance.new("Frame", rootFrame)
pagesContainer.Size = UDim2.new(1, -246, 1, -100)
pagesContainer.Position = UDim2.new(0, 230, 0, 88)
pagesContainer.BackgroundTransparency = 1

local pages = {}
local currentPage = nil
local function createPage(name)
    local p = Instance.new("Frame", pagesContainer)
    p.Size = UDim2.new(1, -12, 1, -12)
    p.Position = UDim2.new(0,6,0,6)
    p.BackgroundColor3 = Color3.fromRGB(14,14,16)
    p.Visible = false
    p.BorderSizePixel = 0
    Instance.new("UICorner", p).CornerRadius = UDim.new(0,10)
    pages[name] = p
    return p
end
local function showPage(name)
    if currentPage and currentPage ~= pages[name] then
        -- animate hide
        pcall(function()
            TweenService:Create(currentPage, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
            task.wait(0.16)
            currentPage.Visible = false
        end)
    end
    currentPage = pages[name]
    if currentPage then
        currentPage.Visible = true
        currentPage.BackgroundTransparency = 1
        TweenService:Create(currentPage, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
    end
end

-- create tab buttons & pages
local homeBtn = createTabButton("Home", 0)
local featBtn = createTabButton("Features", 72)
local aboutBtn = createTabButton("About", 144)

local homePage = createPage("Home")
local featPage = createPage("Features")
local aboutPage = createPage("About")

-- HOME content
do
    local hTitle = Instance.new("TextLabel", homePage)
    hTitle.Text = "Welcome to ZiaanHub"
    hTitle.Size = UDim2.new(1, -24, 0, 32)
    hTitle.Position = UDim2.new(0, 12, 0, 12)
    hTitle.BackgroundTransparency = 1
    hTitle.TextColor3 = Color3.fromRGB(245,245,245)
    hTitle.Font = Enum.Font.GothamBold
    hTitle.TextSize = 20
    hTitle.TextXAlignment = Enum.TextXAlignment.Left

    local desc = Instance.new("TextLabel", homePage)
    desc.Text = "Modern animated hub by Ziaan.\nFitur utama: WalkSpeed, Infinite Jump, Fly.\nGunakan tab Features untuk mengatur fitur. Tekan K untuk toggle UI."
    desc.Size = UDim2.new(1, -24, 0, 90)
    desc.Position = UDim2.new(0, 12, 0, 52)
    desc.BackgroundTransparency = 1
    desc.TextColor3 = Color3.fromRGB(200,200,200)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 14
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left

    local discordBtn = Instance.new("TextButton", homePage)
    discordBtn.Text = "Copy Discord Invite"
    discordBtn.Size = UDim2.new(0,200,0,40)
    discordBtn.Position = UDim2.new(0, 12, 1, -56)
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.TextSize = 15
    discordBtn.BackgroundColor3 = Color3.fromRGB(40,40,44)
    discordBtn.TextColor3 = Color3.fromRGB(245,245,245)
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0,8)
    discordBtn.MouseButton1Click:Connect(function()
        tryCopyToClipboard(DISCORD_INVITE)
        notify("Discord invite copied.", 3)
    end)
end

-- FEATURES content (sliders & toggles)
do
    -- helper for label
    local function makeLabel(parent, txt, posY)
        local l = Instance.new("TextLabel", parent)
        l.Size = UDim2.new(0.45, -12, 0, 20)
        l.Position = UDim2.new(0, 12, 0, posY)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = Color3.fromRGB(230,230,230)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 14
        l.TextXAlignment = Enum.TextXAlignment.Left
        return l
    end

    -- WalkSpeed slider
    makeLabel(featPage, "WalkSpeed", 12)
    local wsBar = Instance.new("Frame", featPage)
    wsBar.Size = UDim2.new(0.6, 0, 0, 12)
    wsBar.Position = UDim2.new(0, 12, 0, 40)
    wsBar.BackgroundColor3 = Color3.fromRGB(36,36,36)
    Instance.new("UICorner", wsBar).CornerRadius = UDim.new(0,6)
    local wsFill = Instance.new("Frame", wsBar)
    wsFill.Size = UDim2.new(((state.ws - 1) / (350 - 1)),0,1,0)
    wsFill.BackgroundColor3 = Color3.fromRGB(0,160,255)
    Instance.new("UICorner", wsFill).CornerRadius = UDim.new(0,6)
    local wsValue = Instance.new("TextLabel", featPage)
    wsValue.Size = UDim2.new(0, 90, 0, 26)
    wsValue.Position = UDim2.new(0.62, 12, 0, 32)
    wsValue.BackgroundColor3 = Color3.fromRGB(36,36,36)
    wsValue.Text = tostring(state.ws)
    wsValue.TextColor3 = Color3.fromRGB(230,230,230)
    wsValue.Font = Enum.Font.Gotham
    wsValue.TextSize = 14
    Instance.new("UICorner", wsValue).CornerRadius = UDim.new(0,6)

    local draggingWS = false
    wsBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingWS = true
            pcall(function() TweenService:Create(wsBar, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(46,46,46)}):Play() end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if draggingWS and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - wsBar.AbsolutePosition.X) / wsBar.AbsoluteSize.X, 0, 1)
            wsFill.Size = UDim2.new(rel,0,1,0)
            local val = math.floor(1 + (350-1) * rel)
            wsValue.Text = tostring(val)
            setWalkSpeed(val)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingWS = false
            pcall(function() TweenService:Create(wsBar, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(36,36,36)}):Play() end)
        end
    end)

    -- JumpPower slider
    makeLabel(featPage, "JumpPower", 92)
    local jpBar = Instance.new("Frame", featPage)
    jpBar.Size = UDim2.new(0.6, 0, 0, 12)
    jpBar.Position = UDim2.new(0, 12, 0, 120)
    jpBar.BackgroundColor3 = Color3.fromRGB(36,36,36)
    Instance.new("UICorner", jpBar).CornerRadius = UDim.new(0,6)
    local jpFill = Instance.new("Frame", jpBar)
    jpFill.Size = UDim2.new(((state.jp - 1) / (500 - 1)),0,1,0)
    jpFill.BackgroundColor3 = Color3.fromRGB(0,160,255)
    Instance.new("UICorner", jpFill).CornerRadius = UDim.new(0,6)
    local jpValue = Instance.new("TextLabel", featPage)
    jpValue.Size = UDim2.new(0, 90, 0, 26)
    jpValue.Position = UDim2.new(0.62, 12, 0, 112)
    jpValue.BackgroundColor3 = Color3.fromRGB(36,36,36)
    jpValue.Text = tostring(state.jp)
    jpValue.TextColor3 = Color3.fromRGB(230,230,230)
    jpValue.Font = Enum.Font.Gotham
    jpValue.TextSize = 14
    Instance.new("UICorner", jpValue).CornerRadius = UDim.new(0,6)

    local draggingJP = false
    jpBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingJP = true
            pcall(function() TweenService:Create(jpBar, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(46,46,46)}):Play() end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if draggingJP and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - jpBar.AbsolutePosition.X) / jpBar.AbsoluteSize.X, 0, 1)
            jpFill.Size = UDim2.new(rel,0,1,0)
            local val = math.floor(1 + (500-1) * rel)
            jpValue.Text = tostring(val)
            setJumpPower(val)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingJP = false
            pcall(function() TweenService:Create(jpBar, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(36,36,36)}):Play() end)
        end
    end)

    -- Infinite Jump toggle
    local ijBtn = Instance.new("TextButton", featPage)
    ijBtn.Size = UDim2.new(0, 240, 0, 40)
    ijBtn.Position = UDim2.new(0, 12, 0, 170)
    ijBtn.Text = "Infinite Jump • OFF"
    ijBtn.Font = Enum.Font.GothamBold
    ijBtn.TextSize = 14
    ijBtn.BackgroundColor3 = Color3.fromRGB(42,42,44)
    ijBtn.TextColor3 = Color3.fromRGB(235,235,235)
    Instance.new("UICorner", ijBtn).CornerRadius = UDim.new(0,8)
    ijBtn.MouseButton1Click:Connect(function()
        setInfiniteJump(not state.infJump)
        ijBtn.Text = "Infinite Jump • "..(state.infJump and "ON" or "OFF")
        ijBtn.BackgroundColor3 = state.infJump and Color3.fromRGB(0,170,85) or Color3.fromRGB(42,42,44)
    end)

    -- Fly toggle + speed input
    local flyBtn = Instance.new("TextButton", featPage)
    flyBtn.Size = UDim2.new(0, 240, 0, 40)
    flyBtn.Position = UDim2.new(0, 12, 0, 224)
    flyBtn.Text = "Fly • OFF"
    flyBtn.Font = Enum.Font.GothamBold
    flyBtn.TextSize = 14
    flyBtn.BackgroundColor3 = Color3.fromRGB(42,42,44)
    flyBtn.TextColor3 = Color3.fromRGB(235,235,235)
    Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0,8)

    local flyBox = Instance.new("TextBox", featPage)
    flyBox.Size = UDim2.new(0, 120, 0, 34)
    flyBox.Position = UDim2.new(0, 262, 0, 224)
    flyBox.PlaceholderText = tostring(DEFAULT_FLY_SPEED)
    flyBox.BackgroundColor3 = Color3.fromRGB(36,36,36)
    flyBox.TextColor3 = Color3.fromRGB(230,230,230)
    flyBox.ClearTextOnFocus = false
    Instance.new("UICorner", flyBox).CornerRadius = UDim.new(0,8)

    flyBtn.MouseButton1Click:Connect(function()
        local n = tonumber(flyBox.Text) or state.flySpeed or DEFAULT_FLY_SPEED
        state.flySpeed = math.clamp(n, 10, 500)
        setFly(not state.fly)
        flyBtn.Text = "Fly • "..(state.fly and "ON" or "OFF")
        flyBtn.BackgroundColor3 = state.fly and Color3.fromRGB(0,170,85) or Color3.fromRGB(42,42,44)
    end)

    -- Reset Button
    local resetBtn = Instance.new("TextButton", featPage)
    resetBtn.Size = UDim2.new(0, 160, 0, 36)
    resetBtn.Position = UDim2.new(0, 12, 0, 284)
    resetBtn.Text = "Reset to Default"
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 14
    resetBtn.BackgroundColor3 = Color3.fromRGB(155,55,55)
    resetBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,8)
    resetBtn.MouseButton1Click:Connect(function()
        applyDefaults()
        wsValue.Text = tostring(state.ws)
        jpValue.Text = tostring(state.jp)
        ijBtn.Text = "Infinite Jump • OFF"
        ijBtn.BackgroundColor3 = Color3.fromRGB(42,42,44)
        flyBtn.Text = "Fly • OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(42,42,44)
        wsFill.Size = UDim2.new(((state.ws - 1) / (350 - 1)),0,1,0)
        jpFill.Size = UDim2.new(((state.jp - 1) / (500 - 1)),0,1,0)
    end)
end

-- ABOUT content
do
    local aTitle = Instance.new("TextLabel", aboutPage)
    aTitle.Text = "About ZiaanHub"
    aTitle.Size = UDim2.new(1,-24,0,28)
    aTitle.Position = UDim2.new(0,12,0,12)
    aTitle.BackgroundTransparency = 1
    aTitle.TextColor3 = Color3.fromRGB(245,245,245)
    aTitle.Font = Enum.Font.GothamBold
    aTitle.TextSize = 18

    local aboutTxt = Instance.new("TextLabel", aboutPage)
    aboutTxt.Text = "ZiaanHub dibuat oleh Ziaan.\nFitur: WalkSpeed, Infinite Jump, Fly.\nVersi modern dengan animasi & slider. Gunakan dengan bijak."
    aboutTxt.Size = UDim2.new(1,-24,1,-64)
    aboutTxt.Position = UDim2.new(0,12,0,46)
    aboutTxt.BackgroundTransparency = 1
    aboutTxt.TextColor3 = Color3.fromRGB(200,200,200)
    aboutTxt.Font = Enum.Font.Gotham
    aboutTxt.TextSize = 14
    aboutTxt.TextWrapped = true
end

-- default page show (animate in)
showPage("Home")
homeBtn.MouseButton1Click:Connect(function() showPage("Home") end)
featBtn.MouseButton1Click:Connect(function() showPage("Features") end)
aboutBtn.MouseButton1Click:Connect(function() showPage("About") end)

-- ============ KEY OVERLAY (animated) ============
local keyOverlay = Instance.new("Frame", ScreenGui)
keyOverlay.Size = UDim2.new(0, 560, 0, 320)
keyOverlay.Position = UDim2.new(0.5, -280, 0.5, -170)
keyOverlay.BackgroundColor3 = Color3.fromRGB(22,22,24)
Instance.new("UICorner", keyOverlay).CornerRadius = UDim.new(0,14)
local keyStroke = Instance.new("UIStroke", keyOverlay) keyStroke.Thickness = 2 keyStroke.Color = Color3.fromRGB(0,150,255)

local keyTitle = Instance.new("TextLabel", keyOverlay)
keyTitle.Size = UDim2.new(1, -36, 0, 36)
keyTitle.Position = UDim2.new(0, 18, 0, 18)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "ZiaanHub | Masukkan Key"
keyTitle.TextColor3 = Color3.fromRGB(245,245,245)
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 18

local keyNote = Instance.new("TextLabel", keyOverlay)
keyNote.Size = UDim2.new(1, -36, 0, 36)
keyNote.Position = UDim2.new(0,18,0,58)
keyNote.BackgroundTransparency = 1
keyNote.Text = "Ambil key di Discord. Tekan tombol Discord untuk menyalin invite."
keyNote.TextColor3 = Color3.fromRGB(200,200,200)
keyNote.Font = Enum.Font.Gotham
keyNote.TextSize = 14
keyNote.TextWrapped = true

local keyBox = Instance.new("TextBox", keyOverlay)
keyBox.Size = UDim2.new(1, -36, 0, 44)
keyBox.Position = UDim2.new(0, 18, 0, 108)
keyBox.PlaceholderText = "Paste key di sini..."
keyBox.ClearTextOnFocus = false
keyBox.TextColor3 = Color3.fromRGB(235,235,235)
keyBox.BackgroundColor3 = Color3.fromRGB(36,36,38)
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0,8)

local keyVerify = Instance.new("TextButton", keyOverlay)
keyVerify.Size = UDim2.new(0.5, -22, 0, 44)
keyVerify.Position = UDim2.new(0, 18, 0, 164)
keyVerify.Text = "Verifikasi Key"
keyVerify.Font = Enum.Font.GothamBold
keyVerify.TextSize = 15
keyVerify.BackgroundColor3 = Color3.fromRGB(0,170,85)
Instance.new("UICorner", keyVerify).CornerRadius = UDim.new(0,8)

local keyDiscord = Instance.new("TextButton", keyOverlay)
keyDiscord.Size = UDim2.new(0.5, -22, 0, 44)
keyDiscord.Position = UDim2.new(0.5, 4, 0, 164)
keyDiscord.Text = "Salin Discord"
keyDiscord.Font = Enum.Font.GothamBold
keyDiscord.TextSize = 15
keyDiscord.BackgroundColor3 = Color3.fromRGB(44,44,46)
Instance.new("UICorner", keyDiscord).CornerRadius = UDim.new(0,8)

local keyStatus = Instance.new("TextLabel", keyOverlay)
keyStatus.Size = UDim2.new(1, -36, 0, 24)
keyStatus.Position = UDim2.new(0, 18, 0, 220)
keyStatus.BackgroundTransparency = 1
keyStatus.Text = ""
keyStatus.TextColor3 = Color3.fromRGB(255,120,120)
keyStatus.Font = Enum.Font.Gotham
keyStatus.TextSize = 14
keyStatus.TextXAlignment = Enum.TextXAlignment.Left

-- animated appear
keyOverlay.Visible = true
rootFrame.Visible = false

local function verifyKeyFlow()
    keyStatus.TextColor3 = Color3.fromRGB(190,190,190)
    keyStatus.Text = "Mengambil key dari server..."
    local keys = fetchKeysFromUrl(KEY_SOURCE_URL)
    if #keys == 0 then
        keyStatus.TextColor3 = Color3.fromRGB(255,120,120)
        keyStatus.Text = "Gagal ambil key. Pastikan URL benar."
        notify("Gagal ambil key dari server.",4)
        return
    end
    local input = (keyBox.Text or ""):gsub("^%s+",""):gsub("%s+$","")
    if input == "" then
        keyStatus.TextColor3 = Color3.fromRGB(255,120,120)
        keyStatus.Text = "Isi key dulu."
        return
    end
    for _,k in ipairs(keys) do
        if input == k then
            keyStatus.TextColor3 = Color3.fromRGB(120,255,140)
            keyStatus.Text = "Key valid. Membuka UI..."
            notify("Key valid. Selamat datang!", 3)
            state.hasAccess = true
            task.wait(0.5)
            -- animate overlay out, main in
            pcall(function() TweenService:Create(keyOverlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = keyOverlay.Position + UDim2.new(0,0,0,40), BackgroundTransparency = 1}):Play() end)
            task.wait(0.22)
            keyOverlay.Visible = false
            rootFrame.Visible = true
            applyDefaults()
            return
        end
    end
    keyStatus.TextColor3 = Color3.fromRGB(255,120,120)
    keyStatus.Text = "Key salah. Ambil key di Discord."
    notify("Key salah. Cek Discord.", 4)
end

keyVerify.MouseButton1Click:Connect(verifyKeyFlow)
keyBox.FocusLost:Connect(function(enter) if enter then verifyKeyFlow() end end)
keyDiscord.MouseButton1Click:Connect(function() tryCopyToClipboard(DISCORD_INVITE) end)

-- initial state
rootFrame.Visible = false
keyOverlay.Visible = true
notify("Masukkan key. Tekan K untuk toggle UI.", 5)

-- UI toggle with K
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == UI_TOGGLE_KEY then
        if state.hasAccess then
            state.uiVisible = not state.uiVisible
            pcall(function()
                if state.uiVisible then
                    rootFrame.Visible = true
                    rootFrame.Position = UDim2.new(0.5, -390, 0.5, -230) + UDim2.new(0,0,0,-10)
                    TweenService:Create(rootFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -390, 0.5, -230)}):Play()
                else
                    TweenService:Create(rootFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -390, 0.5, -210)}):Play()
                    task.delay(0.18, function() rootFrame.Visible = false end)
                end
            end)
        else
            keyOverlay.Visible = not keyOverlay.Visible
        end
    end
end)

-- cleanup
local function cleanup()
    if state.flyConn then state.flyConn:Disconnect(); state.flyConn = nil end
    if state.infJumpConn then state.infJumpConn:Disconnect(); state.infJumpConn = nil end
    if state.flyGyro then state.flyGyro:Destroy(); state.flyGyro = nil end
    if state.flyVel then state.flyVel:Destroy(); state.flyVel = nil end
    pcall(function() ScreenGui:Destroy() end)
end
_G.ZiaanHubCleanup = cleanup

-- final
-- UI hidden until key verified
