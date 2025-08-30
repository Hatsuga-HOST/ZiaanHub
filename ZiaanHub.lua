-- ZiaanHub Ocean Evolution Edition
-- Premium UI dengan desain modern tanpa border dan alur key-first

-- ================= CONFIG =================
local KEY_SOURCE_URL    = "https://pastebin.com/raw/3vaUdQ30"
local DISCORD_INVITE    = "https://discord.gg/vzbJt9XQ"
local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50
local DEFAULT_FLY_SPEED = 60
local UI_TOGGLE_KEY     = Enum.KeyCode.K
local NOTIF_TITLE       = "ZiaanHub Evolution"
local CONFIG_FILE       = "ZiaanHubEvolutionConfig.json"
local NOTIFICATION_DURATION = 5

-- ================ SERVICES / HELPERS ================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

local has_writefile = type(writefile) == "function"
local has_readfile  = type(readfile) == "function"
local has_isfile    = type(isfile) == "function"
local setclip = setclipboard or (syn and syn.write_clipboard) or (function() end)

-- Palet warna tema deep ocean yang ditingkatkan
local COLOR_PALETTE = {
    DARK_BLUE = Color3.fromRGB(8, 18, 30),
    DEEP_BLUE = Color3.fromRGB(12, 28, 48),
    MEDIUM_BLUE = Color3.fromRGB(18, 42, 66),
    LIGHT_BLUE = Color3.fromRGB(24, 120, 190),
    CYAN = Color3.fromRGB(0, 180, 216),
    LIGHT_CYAN = Color3.fromRGB(144, 224, 239),
    WHITE = Color3.fromRGB(240, 245, 250),
    RED = Color3.fromRGB(231, 76, 60),
    GREEN = Color3.fromRGB(46, 204, 113),
    ACCENT = Color3.fromRGB(0, 150, 255)
}

-- Sistem notifikasi custom yang ditingkatkan
local function createNotification(title, text, duration, notifType)
    duration = duration or NOTIFICATION_DURATION
    notifType = notifType or "info"
    
    local notifContainer = CoreGui:FindFirstChild("OceanNotifications")
    if not notifContainer then
        notifContainer = Instance.new("Frame", CoreGui)
        notifContainer.Name = "OceanNotifications"
        notifContainer.Size = UDim2.new(0.3, 0, 1, 0)
        notifContainer.Position = UDim2.new(0.68, 0, 0.02, 0)
        notifContainer.BackgroundTransparency = 1
        notifContainer.ClipsDescendants = true
        
        local uiListLayout = Instance.new("UIListLayout", notifContainer)
        uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        uiListLayout.Padding = UDim.new(0, 10)
    end
    
    local notification = Instance.new("Frame")
    notification.Name = "OceanNotif"
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.AutomaticSize = Enum.AutomaticSize.Y
    notification.BackgroundColor3 = COLOR_PALETTE.DARK_BLUE
    notification.BackgroundTransparency = 0.1
    notification.BorderSizePixel = 0
    notification.LayoutOrder = #notifContainer:GetChildren()
    notification.Parent = notifContainer
    
    local uiCorner = Instance.new("UICorner", notification)
    uiCorner.CornerRadius = UDim.new(0, 14)
    
    local titleLabel = Instance.new("TextLabel", notification)
    titleLabel.Size = UDim2.new(1, -20, 0, 24)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = COLOR_PALETTE.WHITE
    titleLabel.Text = title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local textLabel = Instance.new("TextLabel", notification)
    textLabel.Size = UDim2.new(1, -20, 0, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 34)
    textLabel.AutomaticSize = Enum.AutomaticSize.Y
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 14
    textLabel.TextColor3 = COLOR_PALETTE.LIGHT_CYAN
    textLabel.TextWrapped = true
    textLabel.Text = text
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local progressBar = Instance.new("Frame", notification)
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, -3)
    progressBar.BackgroundColor3 = notifType == "success" and COLOR_PALETTE.GREEN or 
                                  notifType == "error" and COLOR_PALETTE.RED or 
                                  COLOR_PALETTE.CYAN
    progressBar.BorderSizePixel = 0
    
    local progressCorner = Instance.new("UICorner", progressBar)
    progressCorner.CornerRadius = UDim.new(0, 2)
    
    -- Animasi masuk
    notification.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, 0)
    }):Play()
    
    task.wait(0.3)
    TweenService:Create(notification, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, textLabel.TextBounds.Y + 44)
    }):Play()
    
    -- Animasi progress bar
    TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 3)
    }):Play()
    
    -- Hapus notifikasi setelah durasi
    delay(duration, function()
        TweenService:Create(notification, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(titleLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 1
        }):Play()
        TweenService:Create(textLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 1
        }):Play()
        
        wait(0.5)
        notification:Destroy()
    end)
    
    return notification
end

local function notify(text, dur, notifType)
    createNotification(NOTIF_TITLE, text, dur, notifType)
end

local function tryCopyToClipboard(text)
    if setclip then
        pcall(function() setclip(text) end)
        notify("Invite disalin ke clipboard.", 3, "success")
    else
        notify("Salin manual: "..text, 4, "info")
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
    noclip = false,
    -- connections to clean up
    infJumpConn = nil,
    flyConn = nil,
    noclipConn = nil,
    uiVisible = true,
    notificationsEnabled = true
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

    if state.noclipConn then state.noclipConn:Disconnect(); state.noclipConn = nil end
    state.noclip = false

    notify("Reset ke default", 3, "info")
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
        notify("Infinite Jump: ON", 2, "success")
    else
        if state.infJumpConn then state.infJumpConn:Disconnect(); state.infJumpConn = nil end
        notify("Infinite Jump: OFF", 2, "info")
    end
end

local function setFly(enabled)
    state.fly = enabled
    local hum, root = getHumanoidAndRoot()
    if not hum or not root then notify("Gagal: karakter tidak siap.", 2, "error"); return end

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

        notify("Fly: ON (WASD + Space/Shift)", 3, "success")
    else
        if state.flyConn then state.flyConn:Disconnect(); state.flyConn = nil end
        if state.flyGyro then pcall(function() state.flyGyro:Destroy() end); state.flyGyro = nil end
        if state.flyVel then pcall(function() state.flyVel:Destroy() end); state.flyVel = nil end
        pcall(function() hum.PlatformStand = false end)
        notify("Fly: OFF", 2, "info")
    end
    persist()
end

local function setNoclip(enabled)
    state.noclip = enabled
    local character = LocalPlayer.Character
    if not character then return end

    if enabled then
        if not state.noclipConn then
            state.noclipConn = RunService.Stepped:Connect(function()
                if state.noclip and character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
        notify("Noclip: ON", 2, "success")
    else
        if state.noclipConn then
            state.noclipConn:Disconnect()
            state.noclipConn = nil
        end
        notify("Noclip: OFF", 2, "info")
    end
end

-- =============== UI BUILD ===============
pcall(function() CoreGui:FindFirstChild("ZiaanHub_CustomUI"):Destroy() end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZiaanHub_CustomUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- Background blur effect
local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 14
blurEffect.Parent = Lighting
blurEffect.Enabled = false

-- =============== KEY OVERLAY ===============
local keyOverlay = Instance.new("Frame", ScreenGui)
keyOverlay.AnchorPoint = Vector2.new(0.5,0.5)
keyOverlay.Size = UDim2.new(0.78, 0, 0.6, 0)
keyOverlay.Position = UDim2.new(0.5, 0, 0.5, 0)
keyOverlay.BackgroundColor3 = COLOR_PALETTE.DARK_BLUE
keyOverlay.BackgroundTransparency = 0.05
keyOverlay.BorderSizePixel = 0
keyOverlay.Visible = true
Instance.new("UICorner", keyOverlay).CornerRadius = UDim.new(0,18)

local keyTitle = Instance.new("TextLabel", keyOverlay)
keyTitle.Size = UDim2.new(1, -36, 0, 44)
keyTitle.Position = UDim2.new(0, 18, 0, 18)
keyTitle.BackgroundTransparency = 1
keyTitle.Font = Enum.Font.GothamBlack
keyTitle.TextSize = 24
keyTitle.Text = "ZiaanHub Evolution"
keyTitle.TextColor3 = COLOR_PALETTE.WHITE

local keySubtitle = Instance.new("TextLabel", keyOverlay)
keySubtitle.Size = UDim2.new(1, -36, 0, 24)
keySubtitle.Position = UDim2.new(0, 18, 0, 58)
keySubtitle.BackgroundTransparency = 1
keySubtitle.Font = Enum.Font.Gotham
keySubtitle.TextSize = 14
keySubtitle.TextColor3 = COLOR_PALETTE.LIGHT_CYAN
keySubtitle.Text = "Masukkan Key untuk Mengakses Fitur"

local keyNote = Instance.new("TextLabel", keyOverlay)
keyNote.Size = UDim2.new(1, -36, 0, 36)
keyNote.Position = UDim2.new(0, 18, 0, 86)
keyNote.BackgroundTransparency = 1
keyNote.Font = Enum.Font.Gotham
keyNote.TextSize = 14
keyNote.TextWrapped = true
keyNote.TextColor3 = COLOR_PALETTE.LIGHT_CYAN
keyNote.Text = "Ambil key di Discord. Tekan Salin Discord untuk copy invite."

local keyBox = Instance.new("TextBox", keyOverlay)
keyBox.Size = UDim2.new(1, -36, 0, 48)
keyBox.Position = UDim2.new(0, 18, 0, 136)
keyBox.BackgroundColor3 = COLOR_PALETTE.MEDIUM_BLUE
keyBox.BackgroundTransparency = 0.4
keyBox.TextColor3 = COLOR_PALETTE.WHITE
keyBox.PlaceholderText = "Paste key di sini..."
keyBox.PlaceholderColor3 = COLOR_PALETTE.LIGHT_CYAN
keyBox.TextXAlignment = Enum.TextXAlignment.Center
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 16
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0,8)

local keyVerifyBtn = Instance.new("TextButton", keyOverlay)
keyVerifyBtn.Size = UDim2.new(0.48, -22, 0, 46)
keyVerifyBtn.Position = UDim2.new(0, 18, 0, 200)
keyVerifyBtn.Text = "Verifikasi Key"
keyVerifyBtn.Font = Enum.Font.GothamBold
keyVerifyBtn.TextSize = 14
keyVerifyBtn.BackgroundColor3 = COLOR_PALETTE.ACCENT
keyVerifyBtn.BackgroundTransparency = 0.3
keyVerifyBtn.TextColor3 = COLOR_PALETTE.WHITE
Instance.new("UICorner", keyVerifyBtn).CornerRadius = UDim.new(0,8)

local keyDiscordBtn = Instance.new("TextButton", keyOverlay)
keyDiscordBtn.Size = UDim2.new(0.48, -22, 0, 46)
keyDiscordBtn.Position = UDim2.new(0.52, 4, 0, 200)
keyDiscordBtn.Text = "Salin Discord"
keyDiscordBtn.Font = Enum.Font.GothamBold
keyDiscordBtn.TextSize = 14
keyDiscordBtn.BackgroundColor3 = COLOR_PALETTE.MEDIUM_BLUE
keyDiscordBtn.BackgroundTransparency = 0.4
keyDiscordBtn.TextColor3 = COLOR_PALETTE.WHITE
Instance.new("UICorner", keyDiscordBtn).CornerRadius = UDim.new(0,8)

local keyStatus = Instance.new("TextLabel", keyOverlay)
keyStatus.Size = UDim2.new(1, -36, 0, 24)
keyStatus.Position = UDim2.new(0, 18, 0, 256)
keyStatus.BackgroundTransparency = 1
keyStatus.Font = Enum.Font.Gotham
keyStatus.TextSize = 14
keyStatus.TextColor3 = COLOR_PALETTE.RED
keyStatus.TextXAlignment = Enum.TextXAlignment.Center

local rememberCheckbox = Instance.new("TextButton", keyOverlay)
rememberCheckbox.Size = UDim2.new(0, 24, 0, 24)
rememberCheckbox.Position = UDim2.new(0, 18, 0, 290)
rememberCheckbox.BackgroundColor3 = COLOR_PALETTE.MEDIUM_BLUE
rememberCheckbox.BackgroundTransparency = 0.4
rememberCheckbox.Text = ""
rememberCheckbox.AutoButtonColor = false
Instance.new("UICorner", rememberCheckbox).CornerRadius = UDim.new(0, 6)

local rememberCheck = Instance.new("TextLabel", rememberCheckbox)
rememberCheck.Size = UDim2.new(1, 0, 1, 0)
rememberCheck.BackgroundTransparency = 1
rememberCheck.Text = "✓"
rememberCheck.TextColor3 = COLOR_PALETTE.WHITE
rememberCheck.Font = Enum.Font.GothamBold
rememberCheck.TextSize = 16
rememberCheck.Visible = state.rememberKey

local rememberLabel = Instance.new("TextLabel", keyOverlay)
rememberLabel.Size = UDim2.new(1, -50, 0, 24)
rememberLabel.Position = UDim2.new(0, 50, 0, 290)
rememberLabel.BackgroundTransparency = 1
rememberLabel.Font = Enum.Font.Gotham
rememberLabel.TextSize = 14
rememberLabel.TextColor3 = COLOR_PALETTE.LIGHT_CYAN
rememberLabel.Text = "Ingat Key Saya"
rememberLabel.TextXAlignment = Enum.TextXAlignment.Left

if state.rememberKey and state.cachedKey then keyBox.Text = state.cachedKey end

-- Function untuk beralih ke UI utama
local function showMainUI()
    pcall(function()
        TweenService:Create(keyOverlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1,
            Position = keyOverlay.Position + UDim2.new(0, 0, 0, 50)
        }):Play()
    end)
    task.wait(0.3)
    keyOverlay.Visible = false
    blurEffect.Enabled = true
    applyDefaults()
    if state._statusBar then state._statusBar.Text = "Key: valid" end
end

local function verifyKeyFlow()
    keyStatus.TextColor3 = COLOR_PALETTE.LIGHT_CYAN
    keyStatus.Text = "Memeriksa key..."
    local keys = fetchKeysFromUrl(KEY_SOURCE_URL)
    if #keys == 0 then
        keyStatus.TextColor3 = COLOR_PALETTE.RED
        keyStatus.Text = "Gagal ambil key dari server."
        notify("Gagal ambil key.", 3, "error")
        return
    end
    local input = (keyBox.Text or ""):gsub("^%s+",""):gsub("%s+$","")
    if input == "" then
        keyStatus.TextColor3 = COLOR_PALETTE.RED
        keyStatus.Text = "Masukkan key terlebih dahulu."
        return
    end
    for _,k in ipairs(keys) do
        if input == k then
            keyStatus.TextColor3 = COLOR_PALETTE.GREEN
            keyStatus.Text = "Key valid! Membuka UI..."
            notify("Key valid. Welcome!", 3, "success")
            state.hasAccess = true
            if state.rememberKey then state.cachedKey = input; persist() end
            task.wait(0.8)
            showMainUI()
            return
        end
    end
    keyStatus.TextColor3 = COLOR_PALETTE.RED
    keyStatus.Text = "Key tidak ditemukan. Cek Discord."
    notify("Key salah.", 3, "error")
end

keyVerifyBtn.MouseButton1Click:Connect(verifyKeyFlow)
keyBox.FocusLost:Connect(function(enter) if enter then verifyKeyFlow() end end)
keyDiscordBtn.MouseButton1Click:Connect(function() tryCopyToClipboard(DISCORD_INVITE) end)

rememberCheckbox.MouseButton1Click:Connect(function()
    state.rememberKey = not state.rememberKey
    rememberCheck.Visible = state.rememberKey
    persist()
end)

-- =============== MAIN UI ===============
-- Root container: scale-based so it looks OK on mobile/pc
local rootFrame = Instance.new("Frame", ScreenGui)
rootFrame.Name = "RootFrame"
rootFrame.AnchorPoint = Vector2.new(0.5, 0.5)
rootFrame.Size = UDim2.new(0.92, 0, 0.86, 0)
rootFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
rootFrame.BackgroundColor3 = COLOR_PALETTE.DARK_BLUE
rootFrame.BackgroundTransparency = 0.05
rootFrame.BorderSizePixel = 0
rootFrame.Visible = false
Instance.new("UICorner", rootFrame).CornerRadius = UDim.new(0,18)

-- Header dengan efek glassmorphism
local header = Instance.new("Frame", rootFrame)
header.Size = UDim2.new(1, 0, 0, 64)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = COLOR_PALETTE.DEEP_BLUE
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0

local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 18)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.6, -20, 1, -12)
title.Position = UDim2.new(0, 16, 0, 6)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 24
title.TextColor3 = COLOR_PALETTE.WHITE
title.Text = "ZiaanHub Evolution"
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = Instance.new("TextLabel", header)
subtitle.Size = UDim2.new(0.4, -20, 1, -12)
subtitle.Position = UDim2.new(0.6, 12, 0, 6)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 14
subtitle.TextColor3 = COLOR_PALETTE.LIGHT_CYAN
subtitle.Text = "by Ziaan • premium edition"

-- header buttons
local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.new(0, 44, 0, 36)
btnMin.Position = UDim2.new(1, -104, 0, 14)
btnMin.Text = "—"
btnMin.Font = Enum.Font.GothamBold
btnMin.TextSize = 20
btnMin.BackgroundColor3 = COLOR_PALETTE.MEDIUM_BLUE
btnMin.BackgroundTransparency = 0.4
btnMin.TextColor3 = COLOR_PALETTE.WHITE
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0,8)

local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0, 44, 0, 36)
btnClose.Position = UDim2.new(1, -52, 0, 14)
btnClose.Text = "✕"
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 16
btnClose.BackgroundColor3 = COLOR_PALETTE.MEDIUM_BLUE
btnClose.BackgroundTransparency = 0.4
btnClose.TextColor3 = COLOR_PALETTE.WHITE
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0,8)

-- Left tabs (vertical)
local leftPanel = Instance.new("Frame", rootFrame)
leftPanel.Size = UDim2.new(0, 220, 1, -96)
leftPanel.Position = UDim2.new(0, 16, 0, 72)
leftPanel.BackgroundTransparency = 1

local leftBg = Instance.new("Frame", leftPanel)
leftBg.Size = UDim2.new(1, 0, 1, 0)
leftBg.BackgroundColor3 = COLOR_PALETTE.DEEP_BLUE
leftBg.BackgroundTransparency = 0.1
leftBg.BorderSizePixel = 0
Instance.new("UICorner", leftBg).CornerRadius = UDim.new(0,14)

local tabsLayout = Instance.new("UIListLayout", leftBg)
tabsLayout.Padding = UDim.new(0,12)
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local function makeTab(text)
    local btn = Instance.new("TextButton", leftBg)
    btn.Size = UDim2.new(1, -28, 0, 52)
    btn.BackgroundColor3 = COLOR_PALETTE.MEDIUM_BLUE
    btn.BackgroundTransparency = 0.4
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.Text = text
    btn.TextColor3 = COLOR_PALETTE.WHITE
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    
    btn.MouseEnter:Connect(function()
        pcall(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundTransparency = 0.2,
                BackgroundColor3 = COLOR_PALETTE.LIGHT_BLUE
            }):Play()
        end)
    end)
    
    btn.MouseLeave:Connect(function()
        pcall(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundTransparency = 0.4,
                BackgroundColor3 = COLOR_PALETTE.MEDIUM_BLUE
            }):Play()
        end)
    end)
    
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
    f.BackgroundColor3 = COLOR_PALETTE.DEEP_BLUE
    f.BackgroundTransparency = 0.1
    f.BorderSizePixel = 0
    f.Visible = false
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,14)
    pages[name] = f
    return f
end

local function showPage(name)
    if currentPage and currentPage ~= pages[name] then
        pcall(function()
            TweenService:Create(currentPage, TweenInfo.new(0.12), {
                BackgroundTransparency = 1
            }):Play()
        end)
        task.wait(0.12)
        currentPage.Visible = false
    end
    currentPage = pages[name]
    if currentPage then
        currentPage.Visible = true
        currentPage.BackgroundTransparency = 1
        pcall(function()
            TweenService:Create(currentPage, TweenInfo.new(0.12), {
                BackgroundTransparency = 0.1
            }):Play()
        end)
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
    headerLabel.TextColor3 = COLOR_PALETTE.WHITE
    headerLabel.Text = "Welcome to ZiaanHub Evolution"

    local desc = Instance.new("TextLabel", pageHome)
    desc.Size = UDim2.new(1, -24, 0, 100)
    desc.Position = UDim2.new(0, 12, 0, 48)
    desc.BackgroundTransparency = 1
    desc.TextWrapped = true
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 14
    desc.TextColor3 = COLOR_PALETTE.LIGHT_CYAN
    desc.Text = "Premium hub dengan desain modern. Fitur utama: WalkSpeed, JumpPower, Infinite Jump, Fly, Noclip.\nUI mobile-friendly & works across most rigs/maps."

    local discordBtn = Instance.new("TextButton", pageHome)
    discordBtn.Size = UDim2.new(0, 220, 0, 40)
    discordBtn.Position = UDim2.new(0, 12, 1, -60)
    discordBtn.Text = "Copy Discord Invite"
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.TextSize = 14
    discordBtn.BackgroundColor3 = COLOR_PALETTE.MEDIUM_BLUE
    discordBtn.BackgroundTransparency = 0.4
    discordBtn.TextColor3 = COLOR_PALETTE.WHITE
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
    statusBar.TextColor3 = COLOR_PALETTE.LIGHT_CYAN
    statusBar.Text = "Key: "..(state.cachedKey and "cached" or "not cached")
    state._statusBar = statusBar
end

-- FEATURES content dengan slider dan toggle yang ditingkatkan
do
    local function makeLabel(parent, text, y)
        local t = Instance.new("TextLabel", parent)
        t.Size = UDim2.new(0.5, -12, 0, 20)
        t.Position = UDim2.new(0, 12, 0, y)
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.GothamBold
        t.TextColor3 = COLOR_PALETTE.WHITE
        t.TextSize = 14
        t.Text = text
        return t
    end

    -- Slider builder yang ditingkatkan
    local function createSlider(parent, labelY, minV, maxV, initial, callback)
        makeLabel(parent, "", labelY) -- placeholder (we set text externally)
        local bar = Instance.new("Frame", parent)
        bar.Size = UDim2.new(0.7, 0, 0, 8)
        bar.Position = UDim2.new(0, 12, 0, labelY + 28)
        bar.BackgroundColor3 = COLOR_PALETTE.MEDIUM_BLUE
        bar.BackgroundTransparency = 0.4
        bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0,4)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(0,0,1,0)
        fill.BackgroundColor3 = COLOR_PALETTE.ACCENT
        fill.BackgroundTransparency = 0.2
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0,4)

        local knob = Instance.new("Frame", bar)
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(0, 0, 0.5, 0)
        knob.BackgroundColor3 = COLOR_PALETTE.WHITE
        Instance.new("UICorner", knob).CornerRadius = UDim.new(0,9)

        local valueLabel = Instance.new("TextLabel", parent)
        valueLabel.Size = UDim2.new(0, 60, 0, 20)
        valueLabel.Position = UDim2.new(0.72, 12, 0, labelY + 24)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 14
        valueLabel.TextColor3 = COLOR_PALETTE.WHITE
        valueLabel.Text = tostring(initial)

        local dragging = false
        local function setValue(v)
            v = math.clamp(math.floor(v), minV, maxV)
            local rel = (v - minV) / math.max(1, (maxV - minV))
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
            valueLabel.Text = tostring(v)
            if callback then callback(v) end
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

        -- initialize
        setValue(initial)
        return {
            Set = setValue,
            Get = function()
                return tonumber(valueLabel.Text) or initial
            end,
            Dispose = function()
                if connMove then connMove:Disconnect() end
            end
        }
    end

    -- Toggle builder yang ditingkatkan
    local function createToggle(parent, y, text, initialState, callback)
        local toggleFrame = Instance.new("Frame", parent)
        toggleFrame.Size = UDim2.new(1, -24, 0, 30)
        toggleFrame.Position = UDim2.new(0, 12, 0, y)
        toggleFrame.BackgroundTransparency = 1

        local toggleText = Instance.new("TextLabel", toggleFrame)
        toggleText.Size = UDim2.new(0.7, 0, 1, 0)
        toggleText.Position = UDim2.new(0, 0, 0, 0)
        toggleText.BackgroundTransparency = 1
        toggleText.Font = Enum.Font.GothamBold
        toggleText.TextSize = 14
        toggleText.TextColor3 = COLOR_PALETTE.WHITE
        toggleText.Text = text
        toggleText.TextXAlignment = Enum.TextXAlignment.Left

        local toggleBg = Instance.new("Frame", toggleFrame)
        toggleBg.Size = UDim2.new(0, 50, 0, 24)
        toggleBg.Position = UDim2.new(1, -50, 0, 3)
        toggleBg.BackgroundColor3 = initialState and COLOR_PALETTE.GREEN or COLOR_PALETTE.MEDIUM_BLUE
        toggleBg.BackgroundTransparency = 0.4
        toggleBg.BorderSizePixel = 0
        Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(0, 12)

        local toggleKnob = Instance.new("Frame", toggleBg)
        toggleKnob.Size = UDim2.new(0, 20, 0, 20)
        toggleKnob.Position = UDim2.new(initialState and 0.55 or 0, 2, 0, 2)
        toggleKnob.BackgroundColor3 = COLOR_PALETTE.WHITE
        toggleKnob.BorderSizePixel = 0
        Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(0, 10)

        local function setState(newState)
            toggleBg.BackgroundColor3 = newState and COLOR_PALETTE.GREEN or COLOR_PALETTE.MEDIUM_BLUE
            TweenService:Create(toggleKnob, TweenInfo.new(0.2), {
                Position = UDim2.new(newState and 0.55 or 0, 2, 0, 2)
            }):Play()
            if callback then callback(newState) end
        end

        toggleBg.MouseButton1Click:Connect(function()
            setState(not initialState)
            initialState = not initialState
        end)

        return {
            Set = setState,
            Get = function() return initialState end
        }
    end

    -- WalkSpeed
    local wsLabel = makeLabel(pageFeatures, "WalkSpeed", 12)

    local wsSlider = createSlider(pageFeatures, 12, 1, 350, state.ws, function(value)
        setWalkSpeed(value)
    end)

    -- JumpPower
    local jpLabel = makeLabel(pageFeatures, "JumpPower", 80)

    local jpSlider = createSlider(pageFeatures, 80, 1, 500, state.jp, function(value)
        setJumpPower(value)
    end)

    -- Fly Speed
    local flySpeedLabel = makeLabel(pageFeatures, "Fly Speed", 148)

    local flySpeedSlider = createSlider(pageFeatures, 148, 10, 500, state.flySpeed, function(value)
        state.flySpeed = value
        persist()
    end)

    -- Toggles
    local infJumpToggle = createToggle(pageFeatures, 216, "Infinite Jump (I)", state.infJump, function(value)
        setInfiniteJump(value)
    end)

    local flyToggle = createToggle(pageFeatures, 256, "Fly (F)", state.fly, function(value)
        setFly(value)
    end)

    local noclipToggle = createToggle(pageFeatures, 296, "Noclip (N)", state.noclip, function(value)
        setNoclip(value)
    end)

    -- Reset
    local resetBtn = Instance.new("TextButton", pageFeatures)
    resetBtn.Size = UDim2.new(0, 180, 0, 36)
    resetBtn.Position = UDim2.new(0, 12, 0, 336)
    resetBtn.Text = "Reset to Default (R)"
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 14
    resetBtn.BackgroundColor3 = COLOR_PALETTE.MEDIUM_BLUE
    resetBtn.BackgroundTransparency = 0.4
    resetBtn.TextColor3 = COLOR_PALETTE.WHITE
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,8)
    
    resetBtn.MouseButton1Click:Connect(function()
        applyDefaults()
        wsSlider.Set(state.ws)
        jpSlider.Set(state.jp)
        flySpeedSlider.Set(state.flySpeed)
        infJumpToggle.Set(false)
        flyToggle.Set(false)
        noclipToggle.Set(false)
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
    aboutTitle.TextColor3 = COLOR_PALETTE.WHITE
    aboutTitle.Text = "About ZiaanHub Evolution"

    local aboutTxt = Instance.new("TextLabel", pageAbout)
    aboutTxt.Size = UDim2.new(1, -24, 1, -64)
    aboutTxt.Position = UDim2.new(0, 12, 0, 46)
    aboutTxt.BackgroundTransparency = 1
    aboutTxt.Font = Enum.Font.Gotham
    aboutTxt.TextSize = 14
    aboutTxt.TextColor3 = COLOR_PALETTE.LIGHT_CYAN
    aboutTxt.TextWrapped = true
    aboutTxt.Text = "ZiaanHub Evolution oleh Ziaan\nVersi: Premium Edition\nFitur: WalkSpeed, JumpPower, Infinite Jump, Fly, Noclip.\nMobile & PC support. Save config jika executor mendukung."

    local rememberBtn = Instance.new("TextButton", pageAbout)
    rememberBtn.Size = UDim2.new(0, 220, 0, 36)
    rememberBtn.Position = UDim2.new(0, 12, 1, -60)
    rememberBtn.Font = Enum.Font.GothamBold
    rememberBtn.TextSize = 14
    rememberBtn.BackgroundColor3 = COLOR_PALETTE.MEDIUM_BLUE
    rememberBtn.BackgroundTransparency = 0.4
    rememberBtn.TextColor3 = COLOR_PALETTE.WHITE
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
btnClose.MouseButton1Click:Connect(function() pcall(function() ScreenGui:Destroy() blurEffect.Enabled = false end) end)

-- UI toggle & hotkeys
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == UI_TOGGLE_KEY then
        if state.hasAccess then
            state.uiVisible = not state.uiVisible
            if state.uiVisible then
                rootFrame.Visible = true
                rootFrame.Position = UDim2.new(0.5, 0, 0.5, -20)
                TweenService:Create(rootFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                }):Play()
                blurEffect.Enabled = true
            else
                TweenService:Create(rootFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0.5, 0, 0.5, 60)
                }):Play()
                task.delay(0.18, function()
                    rootFrame.Visible = false
                    blurEffect.Enabled = false
                end)
            end
        else
            keyOverlay.Visible = not keyOverlay.Visible
        end
    elseif input.KeyCode == Enum.KeyCode.I then
        if state.hasAccess then setInfiniteJump(not state.infJump); notify("InfiniteJump "..(state.infJump and "ON" or "OFF"),2, "info") end
    elseif input.KeyCode == Enum.KeyCode.F then
        if state.hasAccess then setFly(not state.fly); notify("Fly "..(state.fly and "ON" or "OFF"),2, "info") end
    elseif input.KeyCode == Enum.KeyCode.N then
        if state.hasAccess then setNoclip(not state.noclip); notify("Noclip "..(state.noclip and "ON" or "OFF"),2, "info") end
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
                    showMainUI()
                    if state._statusBar then state._statusBar.Text = "Key: valid (auto)" end
                    return
                end
            end
        end
    end)
end

notify("ZiaanHub Evolution siap. Masukkan key untuk mulai.", 5, "info")

-- cleanup hook
_G.ZiaanHubCleanup = function()
    if state.infJumpConn then state.infJumpConn:Disconnect(); state.infJumpConn=nil end
    if state.flyConn then state.flyConn:Disconnect(); state.flyConn=nil end
    if state.noclipConn then state.noclipConn:Disconnect(); state.noclipConn=nil end
    if state.flyGyro then pcall(function() state.flyGyro:Destroy() end); state.flyGyro=nil end
    if state.flyVel then pcall(function() state.flyVel:Destroy() end); state.flyVel=nil end
    pcall(function() ScreenGui:Destroy() end)
    pcall(function() blurEffect:Destroy() end)
end
