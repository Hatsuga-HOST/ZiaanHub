--[[
  ZiaanHub v1.0 (single-file)
  - Full custom UI (no external UI libs)
  - Key System (fetch keys from URL)
  - Features: WalkSpeed, JumpPower, Infinite Jump, Fly
  - Reset defaults, Discord button, Home/Features/About tabs
  - Toggle UI: K
  NOTE:
   - Ganti KEY_SOURCE_URL ke Pastebin RAW / GitHub RAW lo
   - Ganti DISCORD_INVITE ke invite lo
--]]

-- ============== CONFIG ==============
local KEY_SOURCE_URL    = "https://pastebin.com/raw/3vaUdQ30"  -- RAW text: satu key per baris
local DISCORD_INVITE    = "https://discord.gg/vzbJt9XQ"
local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50
local DEFAULT_FLY_SPEED = 60
local UI_TOGGLE_KEY     = Enum.KeyCode.K
local NOTIF_TITLE       = "ZiaanHub"

-- ============= UTIL / HELPERS ============
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local setclip = setclipboard or (syn and syn.write_clipboard) or (function() end)
local function tryCopyToClipboard(text)
    if setclip then
        pcall(function() setclip(text) end)
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = NOTIF_TITLE;
                Text = "Link disalin ke clipboard. Paste di browser/Discord.";
                Duration = 4;
            })
        end)
    else
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = NOTIF_TITLE;
                Text = "Salin manual: "..text;
                Duration = 6;
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

-- ensure respawn handling: reapply defaults on character added
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if state.hasAccess then
        -- reapply walkjump values
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

    -- disable inf jump
    if state.infJumpConn then
        state.infJumpConn:Disconnect()
        state.infJumpConn = nil
    end
    state.infJump = false

    -- disable fly
    if state.flyConn then state.flyConn:Disconnect() state.flyConn = nil end
    if state.flyGyro then state.flyGyro:Destroy() state.flyGyro = nil end
    if state.flyVel then state.flyVel:Destroy() state.flyVel = nil end
    state.fly = false

    notify("Semua fitur direset ke default.", 4)
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
        if state.infJumpConn then state.infJumpConn:Disconnect() state.infJumpConn = nil end
        notify("Infinite Jump OFF", 2)
    end
end

local function setFly(enabled)
    state.fly = enabled
    local hum, root, char = getHumanoidAndRoot()
    if not hum or not root then return end

    if enabled then
        -- create movers
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

        -- safe render connection
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
        if state.flyConn then state.flyConn:Disconnect() state.flyConn = nil end
        if state.flyGyro then state.flyGyro:Destroy() state.flyGyro=nil end
        if state.flyVel then state.flyVel:Destroy() state.flyVel=nil end
        hum.PlatformStand = false
        notify("Fly OFF", 2)
    end
end

-- ============ BUILD NICE UI =============
local CoreGui = game:GetService("CoreGui")
-- remove previous GUI if exists
pcall(function() CoreGui:FindFirstChild("ZiaanHub_CustomUI"):Destroy() end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZiaanHub_CustomUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- root frame (centered)
local rootFrame = Instance.new("Frame", ScreenGui)
rootFrame.Size = UDim2.new(0, 640, 0, 380)
rootFrame.Position = UDim2.new(0.5, -320, 0.5, -190)
rootFrame.BackgroundColor3 = Color3.fromRGB(24,24,24)
rootFrame.BorderSizePixel = 0
rootFrame.Active = true
rootFrame.Draggable = true
rootFrame.Name = "Root"
Instance.new("UICorner", rootFrame).CornerRadius = UDim.new(0,12)
local rootStroke = Instance.new("UIStroke", rootFrame)
rootStroke.Thickness = 2
rootStroke.Color = Color3.fromRGB(0,155,255)

-- topbar
local topBar = Instance.new("Frame", rootFrame)
topBar.Size = UDim2.new(1,0,0,56)
topBar.Position = UDim2.new(0,0,0,0)
topBar.BackgroundTransparency = 1

local titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Size = UDim2.new(0.6, -20, 1, -12)
titleLabel.Position = UDim2.new(0, 12, 0, 6)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ZiaanHub"
titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = Instance.new("TextLabel", topBar)
subtitle.Size = UDim2.new(0.4, -16, 1, -12)
subtitle.Position = UDim2.new(0.6, 8, 0, 6)
subtitle.BackgroundTransparency = 1
subtitle.Text = "by Ziaan"
subtitle.TextColor3 = Color3.fromRGB(190,190,190)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 14
subtitle.TextXAlignment = Enum.TextXAlignment.Right

-- left tabs
local tabsFrame = Instance.new("Frame", rootFrame)
tabsFrame.Size = UDim2.new(0, 160, 1, -76)
tabsFrame.Position = UDim2.new(0, 10, 0, 66)
tabsFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Instance.new("UICorner", tabsFrame).CornerRadius = UDim.new(0,8)
local tabsStroke = Instance.new("UIStroke", tabsFrame)
tabsStroke.Thickness = 1
tabsStroke.Color = Color3.fromRGB(60,60,60)

local tabsLayout = Instance.new("UIListLayout", tabsFrame)
tabsLayout.Padding = UDim.new(0,10)
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Top

-- pages container
local pagesFrame = Instance.new("Frame", rootFrame)
pagesFrame.Size = UDim2.new(1, -190, 1, -76)
pagesFrame.Position = UDim2.new(0, 180, 0, 66)
pagesFrame.BackgroundTransparency = 1
Instance.new("UICorner", pagesFrame).CornerRadius = UDim.new(0,8)

local function makeTabButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.fromRGB(230,230,230)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = text
    btn.AutoButtonColor = true
    btn.Parent = tabsFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    local stroke = Instance.new("UIStroke", btn) stroke.Thickness = 1 stroke.Color = Color3.fromRGB(70,70,70)
    return btn
end

local pages = {}
local currentPage = nil
local function createPage(name)
    local p = Instance.new("Frame", pagesFrame)
    p.Size = UDim2.new(1, -12, 1, -12)
    p.Position = UDim2.new(0,6,0,6)
    p.BackgroundColor3 = Color3.fromRGB(12,12,12)
    p.Visible = false
    Instance.new("UICorner", p).CornerRadius = UDim.new(0,8)
    pages[name] = p
    return p
end

local function showPage(name)
    if currentPage and currentPage ~= pages[name] then currentPage.Visible = false end
    currentPage = pages[name]
    if currentPage then currentPage.Visible = true end
end

-- create tabs & pages
local homeBtn = makeTabButton("Home")
local featBtn = makeTabButton("Features")
local aboutBtn = makeTabButton("About")

local homePage = createPage("Home")
local featPage = createPage("Features")
local aboutPage = createPage("About")

-- HOME PAGE content
do
    local title = Instance.new("TextLabel", homePage)
    title.Text = "Welcome to ZiaanHub"
    title.Size = UDim2.new(1, -20, 0, 28)
    title.Position = UDim2.new(0,10,0,10)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18

    local desc = Instance.new("TextLabel", homePage)
    desc.Text = "Custom hub by Ziaan.\nFitur utama: WalkSpeed, Infinite Jump, Fly.\nGunakan tab Features untuk mengakses fitur."
    desc.Size = UDim2.new(1, -20, 0, 80)
    desc.Position = UDim2.new(0,10,0,44)
    desc.BackgroundTransparency = 1
    desc.TextColor3 = Color3.fromRGB(200,200,200)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 14
    desc.TextWrapped = true

    local discordBtn = Instance.new("TextButton", homePage)
    discordBtn.Size = UDim2.new(0, 160, 0, 36)
    discordBtn.Position = UDim2.new(0,10,1,-50)
    discordBtn.Text = "Open Discord"
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.TextSize = 14
    discordBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    discordBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0,8)
    discordBtn.MouseButton1Click:Connect(function() tryCopyToClipboard(DISCORD_INVITE) end)
end

-- FEATURES PAGE content
do
    local y = 10
    local function addLabel(text, yOff)
        local l = Instance.new("TextLabel", featPage)
        l.Size = UDim2.new(1, -20, 0, 22)
        l.Position = UDim2.new(0, 10, 0, yOff)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(230,230,230)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 14
        return l
    end

    -- WalkSpeed controls
    addLabel("WalkSpeed", 10)
    local wsVal = Instance.new("TextLabel", featPage)
    wsVal.Size = UDim2.new(0, 120, 0, 28)
    wsVal.Position = UDim2.new(0, 10, 0, 36)
    wsVal.BackgroundColor3 = Color3.fromRGB(40,40,40)
    wsVal.Text = "Speed: "..tostring(DEFAULT_WALKSPEED)
    wsVal.TextColor3 = Color3.fromRGB(240,240,240)
    wsVal.Font = Enum.Font.Gotham
    wsVal.TextSize = 14
    Instance.new("UICorner", wsVal).CornerRadius = UDim.new(0,6)

    local wsMinus = Instance.new("TextButton", featPage)
    wsMinus.Size = UDim2.new(0, 48, 0, 28)
    wsMinus.Position = UDim2.new(0, 140, 0, 36)
    wsMinus.Text = "-5"
    wsMinus.Font = Enum.Font.GothamBold
    wsMinus.TextSize = 14
    wsMinus.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Instance.new("UICorner", wsMinus).CornerRadius = UDim.new(0,6)

    local wsPlus = wsMinus:Clone()
    wsPlus.Parent = featPage
    wsPlus.Position = UDim2.new(0, 198, 0, 36)
    wsPlus.Text = "+5"

    local wsBox = Instance.new("TextBox", featPage)
    wsBox.Size = UDim2.new(0, 80, 0, 28)
    wsBox.Position = UDim2.new(0, 258, 0, 36)
    wsBox.PlaceholderText = "Set..."
    wsBox.ClearTextOnFocus = false
    wsBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    wsBox.TextColor3 = Color3.fromRGB(240,240,240)
    Instance.new("UICorner", wsBox).CornerRadius = UDim.new(0,6)

    local function refreshWSLabel() wsVal.Text = "Speed: "..tostring(state.ws) end

    wsMinus.MouseButton1Click:Connect(function()
        local new = math.max(1, (state.ws or DEFAULT_WALKSPEED) - 5)
        setWalkSpeed(new); refreshWSLabel()
    end)
    wsPlus.MouseButton1Click:Connect(function()
        local new = math.min(350, (state.ws or DEFAULT_WALKSPEED) + 5)
        setWalkSpeed(new); refreshWSLabel()
    end)
    wsBox.FocusLost:Connect(function(enter)
        if enter then
            local n = tonumber(wsBox.Text)
            if n then setWalkSpeed(math.clamp(n,1,350)); refreshWSLabel() end
        end
    end)

    -- JumpPower controls
    addLabel("JumpPower", 80)
    local jpVal = Instance.new("TextLabel", featPage)
    jpVal.Size = UDim2.new(0, 120, 0, 28)
    jpVal.Position = UDim2.new(0, 10, 0, 106)
    jpVal.BackgroundColor3 = Color3.fromRGB(40,40,40)
    jpVal.Text = "Jump: "..tostring(DEFAULT_JUMPPOWER)
    jpVal.TextColor3 = Color3.fromRGB(240,240,240)
    jpVal.Font = Enum.Font.Gotham
    jpVal.TextSize = 14
    Instance.new("UICorner", jpVal).CornerRadius = UDim.new(0,6)

    local jpBox = Instance.new("TextBox", featPage)
    jpBox.Size = UDim2.new(0, 80, 0, 28)
    jpBox.Position = UDim2.new(0, 140, 0, 106)
    jpBox.PlaceholderText = "Set..."
    jpBox.ClearTextOnFocus = false
    jpBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    jpBox.TextColor3 = Color3.fromRGB(240,240,240)
    Instance.new("UICorner", jpBox).CornerRadius = UDim.new(0,6)

    jpBox.FocusLost:Connect(function(enter)
        if enter then
            local n = tonumber(jpBox.Text)
            if n then setJumpPower(math.clamp(n,1,350)); jpVal.Text = "Jump: "..tostring(state.jp) end
        end
    end)

    -- Infinite Jump toggle
    local ijBtn = Instance.new("TextButton", featPage)
    ijBtn.Size = UDim2.new(0, 180, 0, 36)
    ijBtn.Position = UDim2.new(0, 10, 0, 152)
    ijBtn.Text = "Infinite Jump: OFF"
    ijBtn.Font = Enum.Font.GothamBold
    ijBtn.TextSize = 14
    ijBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Instance.new("UICorner", ijBtn).CornerRadius = UDim.new(0,8)
    ijBtn.MouseButton1Click:Connect(function()
        setInfiniteJump(not state.infJump)
        ijBtn.Text = "Infinite Jump: "..(state.infJump and "ON" or "OFF")
        ijBtn.BackgroundColor3 = state.infJump and Color3.fromRGB(0,170,85) or Color3.fromRGB(45,45,45)
    end)

    -- Fly toggle + speed
    local flyBtn = Instance.new("TextButton", featPage)
    flyBtn.Size = UDim2.new(0, 180, 0, 36)
    flyBtn.Position = UDim2.new(0, 10, 0, 198)
    flyBtn.Text = "Fly: OFF"
    flyBtn.Font = Enum.Font.GothamBold
    flyBtn.TextSize = 14
    flyBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0,8)

    local flyBox = Instance.new("TextBox", featPage)
    flyBox.Size = UDim2.new(0, 80, 0, 28)
    flyBox.Position = UDim2.new(0, 200, 0, 198)
    flyBox.PlaceholderText = tostring(DEFAULT_FLY_SPEED)
    flyBox.ClearTextOnFocus = false
    flyBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    flyBox.TextColor3 = Color3.fromRGB(240,240,240)
    Instance.new("UICorner", flyBox).CornerRadius = UDim.new(0,6)

    flyBtn.MouseButton1Click:Connect(function()
        local n = tonumber(flyBox.Text) or state.flySpeed or DEFAULT_FLY_SPEED
        state.flySpeed = math.clamp(n, 10, 500)
        setFly(not state.fly)
        flyBtn.Text = "Fly: "..(state.fly and "ON" or "OFF")
        flyBtn.BackgroundColor3 = state.fly and Color3.fromRGB(0,170,85) or Color3.fromRGB(45,45,45)
    end)

    -- Reset Button
    local resetBtn = Instance.new("TextButton", featPage)
    resetBtn.Size = UDim2.new(0, 180, 0, 36)
    resetBtn.Position = UDim2.new(0, 10, 0, 246)
    resetBtn.Text = "Reset to Default"
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 14
    resetBtn.BackgroundColor3 = Color3.fromRGB(120,50,50)
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,8)
    resetBtn.MouseButton1Click:Connect(function()
        applyDefaults()
        refreshWSLabel()
        jpVal.Text = "Jump: "..tostring(state.jp)
        ijBtn.Text = "Infinite Jump: OFF"
        ijBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
        flyBtn.Text = "Fly: OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    end)
end

-- ABOUT page content
do
    local aboutTitle = Instance.new("TextLabel", aboutPage)
    aboutTitle.Text = "About ZiaanHub"
    aboutTitle.Size = UDim2.new(1, -20, 0, 28)
    aboutTitle.Position = UDim2.new(0,10,0,10)
    aboutTitle.TextColor3 = Color3.fromRGB(255,255,255)
    aboutTitle.Font = Enum.Font.GothamBold
    aboutTitle.TextSize = 18
    aboutTitle.BackgroundTransparency = 1

    local aboutTxt = Instance.new("TextLabel", aboutPage)
    aboutTxt.Text = "ZiaanHub dibuat oleh Ziaan.\nFitur: WalkSpeed, Infinite Jump, Fly.\nGunakan dengan bijak. Tidak untuk disalahgunakan."
    aboutTxt.Size = UDim2.new(1, -20, 1, -60)
    aboutTxt.Position = UDim2.new(0,10,0,44)
    aboutTxt.TextColor3 = Color3.fromRGB(200,200,200)
    aboutTxt.Font = Enum.Font.Gotham
    aboutTxt.TextSize = 14
    aboutTxt.TextWrapped = true
    aboutTxt.BackgroundTransparency = 1
end

-- show default page
showPage("Home")

-- connect tab clicks
homeBtn.MouseButton1Click:Connect(function() showPage("Home") end)
featBtn.MouseButton1Click:Connect(function() showPage("Features") end)
aboutBtn.MouseButton1Click:Connect(function() showPage("About") end)

-- ============ KEY SCREEN (overlay) ============
local keyOverlay = Instance.new("Frame", ScreenGui)
keyOverlay.Size = UDim2.new(0, 480, 0, 260)
keyOverlay.Position = UDim2.new(0.5, -240, 0.5, -130)
keyOverlay.BackgroundColor3 = Color3.fromRGB(25,25,25)
keyOverlay.Name = "KeyOverlay"
Instance.new("UICorner", keyOverlay).CornerRadius = UDim.new(0,12)
local keyStroke = Instance.new("UIStroke", keyOverlay) keyStroke.Thickness = 2 keyStroke.Color = Color3.fromRGB(0,160,255)

local keyTitle = Instance.new("TextLabel", keyOverlay)
keyTitle.Size = UDim2.new(1, -20, 0, 36)
keyTitle.Position = UDim2.new(0, 10, 0, 10)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "ZiaanHub | Masukkan Key"
keyTitle.TextColor3 = Color3.fromRGB(255,255,255)
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 18

local keyNote = Instance.new("TextLabel", keyOverlay)
keyNote.Size = UDim2.new(1, -20, 0, 24)
keyNote.Position = UDim2.new(0,10,0,48)
keyNote.BackgroundTransparency = 1
keyNote.Text = "Ambil key di Discord. Tekan tombol Discord untuk menyalin invite."
keyNote.TextColor3 = Color3.fromRGB(200,200,200)
keyNote.Font = Enum.Font.Gotham
keyNote.TextSize = 14
keyNote.TextWrapped = true

local keyBox = Instance.new("TextBox", keyOverlay)
keyBox.Size = UDim2.new(1, -20, 0, 36)
keyBox.Position = UDim2.new(0,10,0,84)
keyBox.PlaceholderText = "Paste key di sini..."
keyBox.ClearTextOnFocus = false
keyBox.TextColor3 = Color3.fromRGB(255,255,255)
keyBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0,8)

local keyVerify = Instance.new("TextButton", keyOverlay)
keyVerify.Size = UDim2.new(0.48, -15, 0, 36)
keyVerify.Position = UDim2.new(0, 10, 0, 132)
keyVerify.Text = "Verifikasi Key"
keyVerify.Font = Enum.Font.GothamBold
keyVerify.TextSize = 14
keyVerify.BackgroundColor3 = Color3.fromRGB(0,170,85)
Instance.new("UICorner", keyVerify).CornerRadius = UDim.new(0,8)

local keyDiscord = Instance.new("TextButton", keyOverlay)
keyDiscord.Size = UDim2.new(0.48, -15, 0, 36)
keyDiscord.Position = UDim2.new(0.52, 5, 0, 132)
keyDiscord.Text = "Discord"
keyDiscord.Font = Enum.Font.GothamBold
keyDiscord.TextSize = 14
keyDiscord.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", keyDiscord).CornerRadius = UDim.new(0,8)

local keyStatus = Instance.new("TextLabel", keyOverlay)
keyStatus.Size = UDim2.new(1, -20, 0, 20)
keyStatus.Position = UDim2.new(0, 10, 0, 180)
keyStatus.BackgroundTransparency = 1
keyStatus.Text = ""
keyStatus.TextColor3 = Color3.fromRGB(255,120,120)
keyStatus.Font = Enum.Font.Gotham
keyStatus.TextSize = 14
keyStatus.TextXAlignment = Enum.TextXAlignment.Left

-- key logic
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
            task.wait(0.6)
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

-- initial state: hide main UI until key verified
rootFrame.Visible = false
keyOverlay.Visible = true
notify("Masukkan key. Tekan K untuk toggle UI.", 5)

-- UI toggle with K (only when has access or when on key screen allow toggle)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == UI_TOGGLE_KEY then
        if state.hasAccess then
            state.uiVisible = not state.uiVisible
            rootFrame.Visible = state.uiVisible
        else
            keyOverlay.Visible = not keyOverlay.Visible
        end
    end
end)

-- cleanup on disable (optional function for developer)
local function cleanup()
    -- disconnect connections
    if state.flyConn then state.flyConn:Disconnect(); state.flyConn=nil end
    if state.infJumpConn then state.infJumpConn:Disconnect(); state.infJumpConn=nil end
    if state.flyGyro then state.flyGyro:Destroy(); state.flyGyro=nil end
    if state.flyVel then state.flyVel:Destroy(); state.flyVel=nil end
    pcall(function() ScreenGui:Destroy() end)
end

-- expose cleanup to global (dev use)
_G.ZiaanHubCleanup = cleanup

-- final notify
-- if key already cached (rare), you could auto-verify here (not implemented)
-- done
