--[[
    ZiaanHub - Custom UI (100% buatan sendiri)
    Fitur: Key System (via URL), Home, Features (WalkSpeed, Infinite Jump, Fly), Reset Defaults, Discord Button
    Toggle UI: tekan tombol "K"
    Catatan:
      - Ganti KEY_SOURCE_URL kalau mau pakai link lain (Pastebin RAW/GitHub RAW)
      - Discord: otomatis copy invite ke clipboard. Tinggal paste di browser/Discord.
]]--

-- =============== KONFIGURASI ===============
local KEY_SOURCE_URL = "https://pastebin.com/raw/3vaUdQ30"  -- daftar key dipisah baris
local DISCORD_INVITE = "https://discord.gg/vzbJt9XQ"         -- invite Discord kamu
local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50
local FLY_SPEED = 60
-- ==========================================

-- Helpers executor
local setclip = setclipboard or (syn and syn.write_clipboard)
local httpget = (syn and syn.request) and game.HttpGet or game.HttpGet -- fallback ke game:HttpGet

-- ================== UTIL ==================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function getHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid"), char
end

local function notify(title, text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title or "ZiaanHub",
            Text = text or "",
            Duration = duration or 4
        })
    end)
end

local function tryCopyToClipboard(text)
    if setclip then
        pcall(function() setclip(text) end)
        notify("ZiaanHub", "Link disalin ke clipboard. Paste di browser/Discord.", 5)
    else
        notify("ZiaanHub", "Salin manual: "..text, 6)
    end
end

local function fetchKeysFromUrl(url)
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or not body or #body == 0 then
        return {}
    end
    local keys = {}
    for line in string.gmatch(body.."\n", "(.-)\n") do
        line = line:gsub("\r",""):gsub("^%s+",""):gsub("%s+$","")
        if line ~= "" then
            keys[#keys+1] = line
        end
    end
    return keys
end

local function isKeyValid(inputKey, keyList)
    for _,k in ipairs(keyList) do
        if inputKey == k then return true end
    end
    return false
end

-- ============== STATE FEATURE =============
local state = {
    ws = DEFAULT_WALKSPEED,
    jp = DEFAULT_JUMPPOWER,
    infJump = false,
    fly = false,
    infJumpConn = nil,
    flyConn = nil,
    flyGyro = nil,
    flyVel = nil,
    uiVisible = true
}

-- ============== SET DEFAULTS ==============
local function applyDefaults()
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = DEFAULT_WALKSPEED
        hum.JumpPower = DEFAULT_JUMPPOWER
    end
    state.ws = DEFAULT_WALKSPEED
    state.jp = DEFAULT_JUMPPOWER

    -- Matikan infinite jump
    state.infJump = false
    if state.infJumpConn then
        state.infJumpConn:Disconnect()
        state.infJumpConn = nil
    end

    -- Matikan fly
    state.fly = false
    if state.flyConn then
        state.flyConn:Disconnect()
        state.flyConn = nil
    end
    if state.flyGyro then state.flyGyro:Destroy() state.flyGyro = nil end
    if state.flyVel then state.flyVel:Destroy() state.flyVel = nil end

    notify("ZiaanHub","Semua fitur direset ke default.",4)
end

-- ================ FEATURE: WS =============
local function setWalkSpeed(v)
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = tonumber(v) or DEFAULT_WALKSPEED
        state.ws = hum.WalkSpeed
    end
end

-- ============ FEATURE: Infinite Jump ======
local function setInfiniteJump(enabled)
    state.infJump = enabled
    if enabled then
        if not state.infJumpConn then
            state.infJumpConn = UIS.JumpRequest:Connect(function()
                local hum = getHumanoid()
                if hum and state.infJump then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
        notify("ZiaanHub","Infinite Jump ON",3)
    else
        if state.infJumpConn then
            state.infJumpConn:Disconnect()
            state.infJumpConn = nil
        end
        notify("ZiaanHub","Infinite Jump OFF",3)
    end
end

-- ================ FEATURE: FLY ============
local function setFly(enabled)
    state.fly = enabled
    local hum, char = getHumanoid()
    if not hum or not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if enabled then
        -- Create body movers
        local gyro = Instance.new("BodyGyro")
        gyro.P = 9e4
        gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        gyro.CFrame = root.CFrame
        gyro.Parent = root

        local vel = Instance.new("BodyVelocity")
        vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
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

            move = move.Magnitude > 0 and move.Unit * FLY_SPEED or Vector3.zero
            state.flyVel.Velocity = move
            state.flyGyro.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
        end)

        notify("ZiaanHub","Fly ON (WASD + Space/Shift)",4)
    else
        if state.flyConn then state.flyConn:Disconnect() state.flyConn=nil end
        if state.flyGyro then state.flyGyro:Destroy() state.flyGyro=nil end
        if state.flyVel then state.flyVel:Destroy() state.flyVel=nil end
        hum.PlatformStand = false
        notify("ZiaanHub","Fly OFF",3)
    end
end

-- ================ BUILD UI =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZiaanHub_CustomUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Toggle UI dengan K
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.K then
        state.uiVisible = not state.uiVisible
        ScreenGui.Enabled = state.uiVisible
    end
end)

-- ===== Overlay Key Screen =====
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 420, 0, 220)
KeyFrame.Position = UDim2.new(0.5, -210, 0.45, -110)
KeyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
KeyFrame.Parent = ScreenGui
KeyFrame.Active = true
KeyFrame.Draggable = true

local KeyCorner = Instance.new("UICorner", KeyFrame) KeyCorner.CornerRadius = UDim.new(0,12)
local KeyStroke = Instance.new("UIStroke", KeyFrame) KeyStroke.Thickness = 2 KeyStroke.Color = Color3.fromRGB(0,160,255)

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, -20, 0, 34)
KeyTitle.Position = UDim2.new(0, 10, 0, 10)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "ZiaanHub | Key System"
KeyTitle.TextColor3 = Color3.new(1,1,1)
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 20
KeyTitle.Parent = KeyFrame

local KeyNote = Instance.new("TextLabel")
KeyNote.Size = UDim2.new(1, -20, 0, 20)
KeyNote.Position = UDim2.new(0, 10, 0, 48)
KeyNote.BackgroundTransparency = 1
KeyNote.Text = "Ambil key di Discord, lalu paste di bawah."
KeyNote.TextColor3 = Color3.fromRGB(200,200,200)
KeyNote.Font = Enum.Font.Gotham
KeyNote.TextSize = 14
KeyNote.TextXAlignment = Enum.TextXAlignment.Left
KeyNote.Parent = KeyFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -20, 0, 36)
KeyBox.Position = UDim2.new(0, 10, 0, 78)
KeyBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
KeyBox.Text = ""
KeyBox.PlaceholderText = "Paste Key di sini..."
KeyBox.TextColor3 = Color3.new(1,1,1)
KeyBox.ClearTextOnFocus = false
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 16
KeyBox.Parent = KeyFrame
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0,8)

local CheckBtn = Instance.new("TextButton")
CheckBtn.Size = UDim2.new(0.48, -15, 0, 36)
CheckBtn.Position = UDim2.new(0, 10, 0, 124)
CheckBtn.BackgroundColor3 = Color3.fromRGB(0,170,85)
CheckBtn.Text = "Verifikasi Key"
CheckBtn.TextColor3 = Color3.new(1,1,1)
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.TextSize = 16
CheckBtn.Parent = KeyFrame
Instance.new("UICorner", CheckBtn).CornerRadius = UDim.new(0,8)

local DiscordBtnKey = Instance.new("TextButton")
DiscordBtnKey.Size = UDim2.new(0.48, -15, 0, 36)
DiscordBtnKey.Position = UDim2.new(0.52, 5, 0, 124)
DiscordBtnKey.BackgroundColor3 = Color3.fromRGB(60,60,60)
DiscordBtnKey.Text = "Discord"
DiscordBtnKey.TextColor3 = Color3.new(1,1,1)
DiscordBtnKey.Font = Enum.Font.GothamBold
DiscordBtnKey.TextSize = 16
DiscordBtnKey.Parent = KeyFrame
Instance.new("UICorner", DiscordBtnKey).CornerRadius = UDim.new(0,8)

local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, -20, 0, 20)
KeyStatus.Position = UDim2.new(0, 10, 0, 168)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Text = ""
KeyStatus.TextColor3 = Color3.fromRGB(255,120,120)
KeyStatus.Font = Enum.Font.Gotham
KeyStatus.TextSize = 14
KeyStatus.TextXAlignment = Enum.TextXAlignment.Left
KeyStatus.Parent = KeyFrame

-- ===== Main Window =====
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 540, 0, 340)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,12)
local MainStroke = Instance.new("UIStroke", MainFrame) MainStroke.Thickness = 2 MainStroke.Color = Color3.fromRGB(0,160,255)

-- Top Bar
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "ZiaanHub - Custom UI"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

-- Tab Buttons Container
local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(0, 140, 1, -60)
Tabs.Position = UDim2.new(0, 10, 0, 50)
Tabs.BackgroundColor3 = Color3.fromRGB(22,22,22)
Tabs.Parent = MainFrame
Instance.new("UICorner", Tabs).CornerRadius = UDim.new(0,10)

-- Content Container
local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -170, 1, -60)
Pages.Position = UDim2.new(0, 160, 0, 50)
Pages.BackgroundColor3 = Color3.fromRGB(18,18,18)
Pages.Parent = MainFrame
Instance.new("UICorner", Pages).CornerRadius = UDim.new(0,10)

-- function buat bikin tombol tab
local function createTabButton(text, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 36)
    btn.Position = UDim2.new(0, 10, 0, 10 + (order-1)*44)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = Tabs
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    local st = Instance.new("UIStroke", btn) st.Thickness = 1 st.Color = Color3.fromRGB(90,90,90)
    return btn
end

local function createPage()
    local p = Instance.new("Frame")
    p.Size = UDim2.new(1, -20, 1, -20)
    p.Position = UDim2.new(0, 10, 0, 10)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.Parent = Pages
    return p
end

local currentPage

local function showPage(p)
    if currentPage then currentPage.Visible = false end
    currentPage = p
    currentPage.Visible = true
end

-- ====== HOME PAGE ======
local HomeTab = createTabButton("Home", 1)
local HomePage = createPage()

local HomeTitle = Instance.new("TextLabel")
HomeTitle.Size = UDim2.new(1, 0, 0, 30)
HomeTitle.BackgroundTransparency = 1
HomeTitle.Text = "ZiaanHub"
HomeTitle.TextColor3 = Color3.new(1,1,1)
HomeTitle.Font = Enum.Font.GothamBold
HomeTitle.TextSize = 22
HomeTitle.Parent = HomePage

local HomeDesc = Instance.new("TextLabel")
HomeDesc.Size = UDim2.new(1, 0, 0, 70)
HomeDesc.Position = UDim2.new(0,0,0,34)
HomeDesc.BackgroundTransparency = 1
HomeDesc.Text = "Script hub buatan Ziaan. Fitur: WalkSpeed, Infinite Jump, Fly.\nGunakan tombol di tab Features untuk mengaktifkan."
HomeDesc.TextColor3 = Color3.fromRGB(210,210,210)
HomeDesc.Font = Enum.Font.Gotham
HomeDesc.TextSize = 14
HomeDesc.TextWrapped = true
HomeDesc.Parent = HomePage

local DiscordBtnHome = Instance.new("TextButton")
DiscordBtnHome.Size = UDim2.new(0, 160, 0, 34)
DiscordBtnHome.Position = UDim2.new(0, 0, 0, 110)
DiscordBtnHome.BackgroundColor3 = Color3.fromRGB(60,60,60)
DiscordBtnHome.Text = "Buka Discord"
DiscordBtnHome.TextColor3 = Color3.new(1,1,1)
DiscordBtnHome.Font = Enum.Font.GothamBold
DiscordBtnHome.TextSize = 16
DiscordBtnHome.Parent = HomePage
Instance.new("UICorner", DiscordBtnHome).CornerRadius = UDim.new(0,8)

DiscordBtnHome.MouseButton1Click:Connect(function()
    tryCopyToClipboard(DISCORD_INVITE)
end)

-- ====== FEATURES PAGE ======
local FeaturesTab = createTabButton("Features", 2)
local FeaturesPage = createPage()

-- WalkSpeed Control
local WSLabel = Instance.new("TextLabel")
WSLabel.Size = UDim2.new(0, 140, 0, 26)
WSLabel.Position = UDim2.new(0, 0, 0, 0)
WSLabel.BackgroundTransparency = 1
WSLabel.Text = "WalkSpeed: "..DEFAULT_WALKSPEED
WSLabel.TextColor3 = Color3.new(1,1,1)
WSLabel.Font = Enum.Font.Gotham
WSLabel.TextSize = 14
WSLabel.Parent = FeaturesPage

local WSMinus = Instance.new("TextButton")
WSMinus.Size = UDim2.new(0, 34, 0, 30)
WSMinus.Position = UDim2.new(0, 150, 0, 0)
WSMinus.BackgroundColor3 = Color3.fromRGB(45,45,45)
WSMinus.Text = "-5"
WSMinus.TextColor3 = Color3.new(1,1,1)
WSMinus.Font = Enum.Font.GothamBold
WSMinus.TextSize = 16
WSMinus.Parent = FeaturesPage
Instance.new("UICorner", WSMinus).CornerRadius = UDim.new(0,6)

local WSPlus = WSMinus:Clone()
WSPlus.Position = UDim2.new(0, 190, 0, 0)
WSPlus.Text = "+5"
WSPlus.Parent = FeaturesPage

local WSSet = Instance.new("TextBox")
WSSet.Size = UDim2.new(0, 80, 0, 30)
WSSet.Position = UDim2.new(0, 230, 0, 0)
WSSet.BackgroundColor3 = Color3.fromRGB(40,40,40)
WSSet.PlaceholderText = "Set…"
WSSet.TextColor3 = Color3.new(1,1,1)
WSSet.ClearTextOnFocus = false
WSSet.Font = Enum.Font.Gotham
WSSet.TextSize = 14
WSSet.Parent = FeaturesPage
Instance.new("UICorner", WSSet).CornerRadius = UDim.new(0,6)

local function refreshWS()
    WSLabel.Text = "WalkSpeed: "..tostring(state.ws)
end

WSMinus.MouseButton1Click:Connect(function()
    local new = math.max(1, (state.ws or DEFAULT_WALKSPEED) - 5)
    setWalkSpeed(new); refreshWS()
end)
WSPlus.MouseButton1Click:Connect(function()
    local new = math.min(350, (state.ws or DEFAULT_WALKSPEED) + 5)
    setWalkSpeed(new); refreshWS()
end)
WSSet.FocusLost:Connect(function(enter)
    if enter then
        local n = tonumber(WSSet.Text)
        if n then setWalkSpeed(math.clamp(n,1,350)); refreshWS() end
    end
end)

-- Infinite Jump Toggle
local IJBtn = Instance.new("TextButton")
IJBtn.Size = UDim2.new(0, 180, 0, 34)
IJBtn.Position = UDim2.new(0, 0, 0, 50)
IJBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
IJBtn.Text = "Infinite Jump: OFF"
IJBtn.TextColor3 = Color3.new(1,1,1)
IJBtn.Font = Enum.Font.GothamBold
IJBtn.TextSize = 16
IJBtn.Parent = FeaturesPage
Instance.new("UICorner", IJBtn).CornerRadius = UDim.new(0,8)

IJBtn.MouseButton1Click:Connect(function()
    setInfiniteJump(not state.infJump)
    IJBtn.Text = "Infinite Jump: "..(state.infJump and "ON" or "OFF")
    IJBtn.BackgroundColor3 = state.infJump and Color3.fromRGB(0,170,85) or Color3.fromRGB(45,45,45)
end)

-- Fly Toggle
local FlyBtn = Instance.new("TextButton")
FlyBtn.Size = UDim2.new(0, 180, 0, 34)
FlyBtn.Position = UDim2.new(0, 0, 0, 94)
FlyBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
FlyBtn.Text = "Fly: OFF"
FlyBtn.TextColor3 = Color3.new(1,1,1)
FlyBtn.Font = Enum.Font.GothamBold
FlyBtn.TextSize = 16
FlyBtn.Parent = FeaturesPage
Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0,8)

FlyBtn.MouseButton1Click:Connect(function()
    setFly(not state.fly)
    FlyBtn.Text = "Fly: "..(state.fly and "ON" or "OFF")
    FlyBtn.BackgroundColor3 = state.fly and Color3.fromRGB(0,170,85) or Color3.fromRGB(45,45,45)
end)

-- Reset Defaults
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(0, 180, 0, 34)
ResetBtn.Position = UDim2.new(0, 0, 0, 138)
ResetBtn.BackgroundColor3 = Color3.fromRGB(120,50,50)
ResetBtn.Text = "Reset to Default"
ResetBtn.TextColor3 = Color3.new(1,1,1)
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.TextSize = 16
ResetBtn.Parent = FeaturesPage
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0,8)

ResetBtn.MouseButton1Click:Connect(function()
    applyDefaults()
    refreshWS()
    IJBtn.Text = "Infinite Jump: OFF"
    IJBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    FlyBtn.Text = "Fly: OFF"
    FlyBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
end)

-- ====== ABOUT/CREDITS (optional 3rd tab) ======
local AboutTab = createTabButton("About", 3)
local AboutPage = createPage()

local AboutTxt = Instance.new("TextLabel")
AboutTxt.Size = UDim2.new(1, -20, 1, -20)
AboutTxt.Position = UDim2.new(0, 10, 0, 10)
AboutTxt.BackgroundTransparency = 1
AboutTxt.Text = "ZiaanHub dibuat oleh Ziaan.\nTujuan: menyediakan fitur utility sederhana yang stabil.\nGunakan dengan bijak."
AboutTxt.TextColor3 = Color3.fromRGB(210,210,210)
AboutTxt.Font = Enum.Font.Gotham
AboutTxt.TextSize = 14
AboutTxt.TextWrapped = true
AboutTxt.TextXAlignment = Enum.TextXAlignment.Left
AboutTxt.TextYAlignment = Enum.TextYAlignment.Top
AboutTxt.Parent = AboutPage

-- Default page
showPage(HomePage)

-- Tab switching
HomeTab.MouseButton1Click:Connect(function() showPage(HomePage) end)
FeaturesTab.MouseButton1Click:Connect(function() showPage(FeaturesPage) end)
AboutTab.MouseButton1Click:Connect(function() showPage(AboutPage) end)

-- ====== DISCORD tombol di Key Screen ======
DiscordBtnKey.MouseButton1Click:Connect(function()
    tryCopyToClipboard(DISCORD_INVITE)
end)

-- ====== KEY VERIFY ======
local cachedKeys = {}
local function verifyKeyFlow()
    KeyStatus.TextColor3 = Color3.fromRGB(190,190,190)
    KeyStatus.Text = "Mengambil key..."
    cachedKeys = fetchKeysFromUrl(KEY_SOURCE_URL)
    if #cachedKeys == 0 then
        KeyStatus.TextColor3 = Color3.fromRGB(255,120,120)
        KeyStatus.Text = "Gagal ambil key. Pastikan URL benar."
        return
    end
    local input = KeyBox.Text:gsub("^%s+",""):gsub("%s+$","")
    if input == "" then
        KeyStatus.TextColor3 = Color3.fromRGB(255,120,120)
        KeyStatus.Text = "Isi key dulu."
        return
    end
    if isKeyValid(input, cachedKeys) then
        KeyStatus.TextColor3 = Color3.fromRGB(120,255,120)
        KeyStatus.Text = "Key valid! Membuka UI..."
        notify("ZiaanHub","Key valid. Selamat datang!",4)
        task.wait(0.6)
        KeyFrame.Visible = false
        MainFrame.Visible = true
        applyDefaults()
        -- refresh label WS
        state.ws = DEFAULT_WALKSPEED
        refreshWS()
    else
        KeyStatus.TextColor3 = Color3.fromRGB(255,120,120)
        KeyStatus.Text = "Key salah. Ambil key di Discord."
        notify("ZiaanHub","Key salah. Cek Discord!",4)
    end
end

CheckBtn.MouseButton1Click:Connect(verifyKeyFlow)
KeyBox.FocusLost:Connect(function(enter)
    if enter then verifyKeyFlow() end
end)

-- Selesai
notify("ZiaanHub","UI siap. Tekan K untuk show/hide.",5)
