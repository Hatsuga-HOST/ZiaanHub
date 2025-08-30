--[[
    Universal Roblox GUI Hub
    Sistem Key dari Pastebin
    Desain modern, unik, dan responsif
    Support semua game Roblox
    Author: BLACKBOX AI (contoh)
--]]

-- =============== CONFIG ===============
local KEY_URL = "https://pastebin.com/raw/3vaUdQ30" -- Ganti dengan link key Anda
local UI_TOGGLE_KEY = Enum.KeyCode.K
local CONFIG_FILE = "UniversalHubConfig.json"
local NOTIF_DURATION = 5
local DEFAULT_WALK_SPEED = 16
local DEFAULT_JUMP_POWER = 50
local DEFAULT_FLY_SPEED = 60

-- =============== SERVICES ===============
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("User InputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

local has_writefile = type(writefile) == "function"
local has_readfile = type(readfile) == "function"
local has_isfile = type(isfile) == "function"
local setclipboard = setclipboard or (syn and syn.write_clipboard) or (function() end)

-- =============== COLOR PALETTE ===============
local COLORS = {
    BACKGROUND = Color3.fromRGB(15, 15, 30),
    PANEL = Color3.fromRGB(25, 25, 50),
    ACCENT = Color3.fromRGB(0, 170, 255),
    TEXT = Color3.fromRGB(230, 230, 255),
    SUCCESS = Color3.fromRGB(50, 200, 100),
    ERROR = Color3.fromRGB(220, 50, 50),
    WARNING = Color3.fromRGB(255, 170, 0),
    TRANSPARENT = Color3.new(1,1,1)
}

-- =============== STATE ===============
local state = {
    hasAccess = false,
    cachedKey = nil,
    rememberKey = true,
    walkSpeed = DEFAULT_WALK_SPEED,
    jumpPower = DEFAULT_JUMP_POWER,
    flySpeed = DEFAULT_FLY_SPEED,
    infiniteJump = false,
    fly = false,
    noclip = false,
    uiVisible = true,
    connections = {},
}

-- =============== UTILS ===============

local function notify(text, duration, type)
    duration = duration or NOTIF_DURATION
    type = type or "info"

    local notifContainer = CoreGui:FindFirstChild("UniversalHubNotifications")
    if not notifContainer then
        notifContainer = Instance.new("Frame", CoreGui)
        notifContainer.Name = "UniversalHubNotifications"
        notifContainer.Size = UDim2.new(0.3, 0, 1, 0)
        notifContainer.Position = UDim2.new(0.7, 0, 0.02, 0)
        notifContainer.BackgroundTransparency = 1
        notifContainer.ClipsDescendants = true
        local layout = Instance.new("UIListLayout", notifContainer)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
    end

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.AutomaticSize = Enum.AutomaticSize.Y
    notif.BackgroundColor3 = COLORS.PANEL
    notif.BackgroundTransparency = 0.1
    notif.BorderSizePixel = 0
    notif.LayoutOrder = #notifContainer:GetChildren()
    notif.Parent = notifContainer

    local corner = Instance.new("UICorner", notif)
    corner.CornerRadius = UDim.new(0, 12)

    local titleLabel = Instance.new("TextLabel", notif)
    titleLabel.Size = UDim2.new(1, -20, 0, 24)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = COLORS.TEXT
    titleLabel.Text = "Universal Hub"
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local textLabel = Instance.new("TextLabel", notif)
    textLabel.Size = UDim2.new(1, -20, 0, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 34)
    textLabel.AutomaticSize = Enum.AutomaticSize.Y
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 14
    textLabel.TextColor3 = COLORS.ACCENT
    textLabel.TextWrapped = true
    textLabel.Text = text
    textLabel.TextXAlignment = Enum.TextXAlignment.Left

    local progressBar = Instance.new("Frame", notif)
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, -3)
    progressBar.BackgroundColor3 = (type == "success" and COLORS.SUCCESS) or (type == "error" and COLORS.ERROR) or COLORS.ACCENT
    progressBar.BorderSizePixel = 0
    local progressCorner = Instance.new("UICorner", progressBar)
    progressCorner.CornerRadius = UDim.new(0, 2)

    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, textLabel.TextBounds.Y + 44)
    }):Play()

    TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 3)
    }):Play()

    delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(titleLabel, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(textLabel, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        wait(0.5)
        notif:Destroy()
    end)
end

local function safeHttpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and res and #res > 0 then return res end
    return nil
end

local function fetchKeys()
    local body = safeHttpGet(KEY_URL)
    if not body then return {} end
    local keys = {}
    for line in string.gmatch(body.."\n", "(.-)\n") do
        line = line:gsub("\r",""):gsub("^%s+",""):gsub("%s+$","")
        if line ~= "" then table.insert(keys, line) end
    end
    return keys
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

local function getHumanoidAndRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    return hum, root, char
end

-- =============== UI BUILD ===============

pcall(function() CoreGui:FindFirstChild("UniversalHubUI"):Destroy() end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 15
blurEffect.Parent = Lighting
blurEffect.Enabled = false

local rootFrame = Instance.new("Frame", ScreenGui)
rootFrame.AnchorPoint = Vector2.new(0.5, 0.5)
rootFrame.Size = UDim2.new(0.9, 0, 0.85, 0)
rootFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
rootFrame.BackgroundColor3 = COLORS.BACKGROUND
rootFrame.BackgroundTransparency = 0.05
rootFrame.BorderSizePixel = 0
rootFrame.Visible = false
Instance.new("UICorner", rootFrame).CornerRadius = UDim.new(0, 20)

-- Header
local header = Instance.new("Frame", rootFrame)
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = COLORS.PANEL
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 20)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 24
title.TextColor3 = COLORS.TEXT
title.Text = "Universal Hub"
title.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0, 40, 0, 40)
btnClose.Position = UDim2.new(1, -50, 0, 10)
btnClose.BackgroundColor3 = COLORS.ACCENT
btnClose.Text = "✕"
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 20
btnClose.TextColor3 = COLORS.TEXT
btnClose.BorderSizePixel = 0
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0, 12)

btnClose.MouseButton1Click:Connect(function()
    rootFrame.Visible = false
    blurEffect.Enabled = false
end)

-- Tabs container
local tabsFrame = Instance.new("Frame", rootFrame)
tabsFrame.Size = UDim2.new(0, 200, 1, -60)
tabsFrame.Position = UDim2.new(0, 0, 0, 60)
tabsFrame.BackgroundTransparency = 1

local tabsLayout = Instance.new("UIListLayout", tabsFrame)
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.Padding = UDim.new(0, 10)

-- Pages container
local pagesFrame = Instance.new("Frame", rootFrame)
pagesFrame.Size = UDim2.new(1, -200, 1, -60)
pagesFrame.Position = UDim2.new(0, 200, 0, 60)
pagesFrame.BackgroundTransparency = 1

local pages = {}
local currentPage

local function createTab(name)
    local btn = Instance.new("TextButton", tabsFrame)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = COLORS.PANEL
    btn.BackgroundTransparency = 0.2
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = COLORS.TEXT
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
    end)

    return btn
end

local function createPage(name)
    local frame = Instance.new("Frame", pagesFrame)
    frame.Size = UDim2.new(1, -20, 1, -20)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = COLORS.PANEL
    frame.BackgroundTransparency = 0.1
    frame.Visible = false
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)
    pages[name] = frame
    return frame
end

local function showPage(name)
    if currentPage then
        currentPage.Visible = false
    end
    currentPage = pages[name]
    if currentPage then
        currentPage.Visible = true
    end
end

-- Create tabs and pages
local tabHome = createTab("Home")
local tabFeatures = createTab("Features")
local tabAbout = createTab("About")

local pageHome = createPage("Home")
local pageFeatures = createPage("Features")
local pageAbout = createPage("About")

tabHome.MouseButton1Click:Connect(function() showPage("Home") end)
tabFeatures.MouseButton1Click:Connect(function() showPage("Features") end)
tabAbout.MouseButton1Click:Connect(function() showPage("About") end)

showPage("Home")

-- =============== HOME PAGE ===============
do
    local welcome = Instance.new("TextLabel", pageHome)
    welcome.Size = UDim2.new(1, -40, 0, 60)
    welcome.Position = UDim2.new(0, 20, 0, 20)
    welcome.BackgroundTransparency = 1
    welcome.Font = Enum.Font.GothamBold
    welcome.TextSize = 24
    welcome.TextColor3 = COLORS.TEXT
    welcome.Text = "Welcome to Universal Hub"
    welcome.TextWrapped = true

    local desc = Instance.new("TextLabel", pageHome)
    desc.Size = UDim2.new(1, -40, 0, 100)
    desc.Position = UDim2.new(0, 20, 0, 90)
    desc.BackgroundTransparency = 1
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 14
    desc.TextColor3 = COLORS.ACCENT
    desc.TextWrapped = true
    desc.Text = "Premium universal hub with key system.\nWorks on all Roblox games.\nUse the Features tab to customize your gameplay."

    local discordBtn = Instance.new("TextButton", pageHome)
    discordBtn.Size = UDim2.new(0, 180, 0, 40)
    discordBtn.Position = UDim2.new(0, 20, 1, -60)
    discordBtn.BackgroundColor3 = COLORS.ACCENT
    discordBtn.TextColor3 = COLORS.TEXT
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.TextSize = 16
    discordBtn.Text = "Copy Discord Invite"
    discordBtn.BorderSizePixel = 0
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 12)

    discordBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/vzbJt9XQ") end)
        notify("Discord invite copied to clipboard!", 3, "success")
    end)
end

-- =============== FEATURES PAGE ===============
do
    local function createLabel(parent, text, y)
        local label = Instance.new("TextLabel", parent)
        label.Size = UDim2.new(0.5, -10, 0, 20)
        label.Position = UDim2.new(0, 20, 0, y)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextColor3 = COLORS.TEXT
        label.Text = text
        label.TextXAlignment = Enum.TextXAlignment.Left
        return label
    end

    local function createSlider(parent, y, min, max, default, callback)
        local label = createLabel(parent, "", y)
        local bar = Instance.new("Frame", parent)
        bar.Size = UDim2.new(0.7, 0, 0, 8)
        bar.Position = UDim2.new(0, 20, 0, y + 25)
        bar.BackgroundColor3 = COLORS.PANEL
        bar.BackgroundTransparency = 0.3
        bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = COLORS.ACCENT
        fill.BackgroundTransparency = 0.2
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

        local knob = Instance.new("Frame", bar)
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(0, 0, 0.5, 0)
        knob.BackgroundColor3 = COLORS.TEXT
       -- Lanjutan fungsi createSlider
local dragging = false

local function setValue(v)
    v = math.clamp(math.floor(v), min, max)
    local rel = (v - min) / math.max(1, (max - min))
    fill.Size = UDim2.new(rel, 0, 1, 0)
    knob.Position = UDim2.new(rel, 0, 0.5, 0)
    label.Text = text .. ": " .. tostring(v)
    if callback then callback(v) end
end

bar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        local absX = input.Position and input.Position.X or 0
        local rel = math.clamp((absX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        setValue(min + rel * (max - min))
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local absX = input.Position and input.Position.X or 0
        local rel = math.clamp((absX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        setValue(min + rel * (max - min))
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Inisialisasi nilai slider
setValue(default)

return {
    Set = setValue,
    Get = function() return tonumber(label.Text:match("%d+")) or default end
}
end

-- Toggle builder
local function createToggle(parent, y, text, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -40, 0, 30)
    frame.Position = UDim2.new(0, 20, 0, y)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = COLORS.TEXT
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBg = Instance.new("Frame", frame)
    toggleBg.Size = UDim2.new(0, 50, 0, 24)
    toggleBg.Position = UDim2.new(1, -50, 0, 3)
    toggleBg.BackgroundColor3 = default and COLORS.SUCCESS or COLORS.PANEL
    toggleBg.BackgroundTransparency = 0.3
    toggleBg.BorderSizePixel = 0
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(0, 12)

    local toggleKnob = Instance.new("Frame", toggleBg)
    toggleKnob.Size = UDim2.new(0, 20, 0, 20)
    toggleKnob.Position = default and UDim2.new(0.55, 2, 0, 2) or UDim2.new(0, 2, 0, 2)
    toggleKnob.BackgroundColor3 = COLORS.TEXT
    toggleKnob.BorderSizePixel = 0
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(0, 10)

    local stateToggle = default

    local function setState(newState)
        stateToggle = newState
        toggleBg.BackgroundColor3 = newState and COLORS.SUCCESS or COLORS.PANEL
        TweenService:Create(toggleKnob, TweenInfo.new(0.2), {
            Position = newState and UDim2.new(0.55, 2, 0, 2) or UDim2.new(0, 2, 0, 2)
        }):Play()
        if callback then callback(newState) end
    end

    toggleBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setState(not stateToggle)
        end
    end)

    return {
        Set = setState,
        Get = function() return stateToggle end
    }
end

-- =============== Fitur ===============

local function setWalkSpeed(value)
    value = math.clamp(tonumber(value) or DEFAULT_WALK_SPEED, 1, 500)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.WalkSpeed = value end) end
    state.walkSpeed = value
    saveConfig(state)
end

local function setJumpPower(value)
    value = math.clamp(tonumber(value) or DEFAULT_JUMP_POWER, 1, 600)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.JumpPower = value end) end
    state.jumpPower = value
    saveConfig(state)
end

local function setInfiniteJump(enabled)
    state.infiniteJump = enabled
    if enabled then
        if not state.connections.infJump then
            state.connections.infJump = UIS.JumpRequest:Connect(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum and state.infiniteJump then
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
                end
            end)
        end
        notify("Infinite Jump: ON", 2, "success")
    else
        if state.connections.infJump then
            state.connections.infJump:Disconnect()
            state.connections.infJump = nil
        end
        notify("Infinite Jump: OFF", 2, "info")
    end
    saveConfig(state)
end

local function setFly(enabled)
    state.fly = enabled
    local hum, root = getHumanoidAndRoot()
    if not hum or not root then notify("Karakter tidak siap.", 2, "error"); return end

    if enabled then
        local gyro = Instance.new("BodyGyro")
        gyro.Name = "UniversalHub_FlyGyro"
        gyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
        gyro.P = 9e4
        gyro.CFrame = root.CFrame
        gyro.Parent = root

        local vel = Instance.new("BodyVelocity")
        vel.Name = "UniversalHub_FlyVel"
        vel.MaxForce = Vector3.new(9e9,9e9,9e9)
        vel.Velocity = Vector3.new(0,0,0)
        vel.Parent = root

        state.flyGyro = gyro
        state.flyVel = vel

        pcall(function() hum.PlatformStand = true end)

        state.connections.fly = RunService.RenderStepped:Connect(function()
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
        if state.connections.fly then
            state.connections.fly:Disconnect()
            state.connections.fly = nil
        end
        if state.flyGyro then pcall(function() state.flyGyro:Destroy() end) end
        if state.flyVel then pcall(function() state.flyVel:Destroy() end) end
        pcall(function() hum.PlatformStand = false end)
        notify("Fly: OFF", 2, "info")
    end
    saveConfig(state)
end

local function setNoclip(enabled)
    state.noclip = enabled
    local character = LocalPlayer.Character
    if not character then return end

    if enabled then
        if not state.connections.noclip then
            state.connections.noclip = RunService.Stepped:Connect(function()
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
        if state.connections.noclip then
            state.connections.noclip:Disconnect()
            state.connections.noclip = nil
        end
        notify("Noclip: OFF", 2, "info")
    end
    saveConfig(state)
end

-- =============== UI FEATURES ===============

-- WalkSpeed slider
local wsSlider = createSlider(pageFeatures, 20, 1, 350, state.walkSpeed, setWalkSpeed)

-- JumpPower slider
local jpSlider = createSlider(pageFeatures, 80, 1, 500, state.jumpPower, setJumpPower)

-- Fly Speed slider
local flySpeedSlider = createSlider(pageFeatures, 140, 10, 500, state.flySpeed, function(value)
    state.flySpeed = value
    saveConfig(state)
end)

-- Infinite Jump toggle
local infJumpToggle = createToggle(pageFeatures, 200, "Infinite Jump (I)", state.infiniteJump, setInfiniteJump)

-- Fly toggle
local flyToggle = createToggle(pageFeatures, 240, "Fly (F)", state.fly, setFly)

-- Noclip toggle
local noclipToggle = createToggle(pageFeatures, 280, "Noclip (N)", state.noclip, setNoclip)

-- Reset button
local resetBtn = Instance.new("TextButton", pageFeatures)
resetBtn.Size = UDim2.new(0, 180, 0, 36)
resetBtn.Position = UDim2.new(0, 20, 0, 330)
resetBtn.BackgroundColor3 = COLORS.PANEL
resetBtn.BackgroundTransparency = 0.3
resetBtn.TextColor3 = COLORS.TEXT
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 16
resetBtn.Text = "Reset to Default (R)"
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 12)

resetBtn.MouseButton1Click:Connect(function()
    setWalkSpeed(DEFAULT_WALK_SPEED)
    wsSlider.Set(DEFAULT_WALK_SPEED)
    setJumpPower(DEFAULT_JUMP_POWER)
    jpSlider.Set(DEFAULT_JUMP_POWER)
    state.flySpeed = DEFAULT_FLY_SPEED
    flySpeedSlider.Set(DEFAULT_FLY_SPEED)
    setInfiniteJump(false)
    infJumpToggle.Set(false)
    setFly(false)
    flyToggle.Set(false)
    setNoclip(false)
    noclipToggle.Set(false)
    notify("Reset to default values", 3, "info")
end)

-- =============== KEY SYSTEM ===============

-- Key input overlay
local keyOverlay = Instance.new("Frame", ScreenGui)
keyOverlay.AnchorPoint = Vector2.new(0.5, 0.5)
keyOverlay.Size = UDim2.new(0.5, 0, 0.4, 0)
keyOverlay.Position = UDim2.new(0.5, 0, 0.5, 0)
keyOverlay.BackgroundColor3 = COLORS.PANEL
keyOverlay.BackgroundTransparency = 0.1
keyOverlay.BorderSizePixel = 0
Instance.new("UICorner", keyOverlay).CornerRadius = UDim.new(0, 20)

local keyLabel = Instance.new("TextLabel", keyOverlay)
keyLabel.Size = UDim2.new(1, -40, 0, 40)
keyLabel.Position = UDim2.new(0, 20, 0, 20)
keyLabel.BackgroundTransparency = 1
keyLabel.Font = Enum.Font.GothamBold
keyLabel.TextSize = 20
keyLabel.TextColor3 = COLORS.TEXT
keyLabel.Text = "Enter your key:"

local keyBox = Instance.new("TextBox", keyOverlay)
keyBox.Size = UDim2.new(1, -40, 0, 40)
keyBox.Position = UDim2.new(0, 20, 0, 70)
keyBox.BackgroundColor3 = COLORS.BACKGROUND
keyBox.TextColor3 = COLORS.TEXT
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 18
keyBox.ClearTextOnFocus = false
keyBox.PlaceholderText = "Paste your key here..."
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 12)

local verifyBtn = Instance.new("TextButton", keyOverlay)
verifyBtn.Size = UDim2.new(0.5, -30, 0, 40)
verifyBtn.Position = UDim2.new(0, 20, 1, -60)
verifyBtn.BackgroundColor3 = COLORS.ACCENT
verifyBtn.TextColor3 = COLORS.TEXT
verifyBtn.Font = Enum.Font.GothamBold
verifyBtn.TextSize = 18
verifyBtn.Text = "Verify"
Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 12)

local statusLabel = Instance.new("TextLabel", keyOverlay)
statusLabel.Size = UDim2.new(1, -40, 0, 30)
statusLabel.Position = UDim2.new(0, 20, 1, -100)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 16
statusLabel.TextColor3 = COLORS.ERROR
statusLabel.Text = ""

local function verifyKey()
    local inputKey = keyBox.Text:gsub("^%s*(.-)%s*$", "%1") -- trim spaces
    if inputKey == "" then
        statusLabel.TextColor3 = COLORS.ERROR
        statusLabel.Text = "Please enter a key."
        return
    end
    statusLabel.TextColor3 = COLORS.ACCENT
    statusLabel.Text = "Checking key..."
    local keys = fetchKeys()
    if #keys == 0 then
        statusLabel.TextColor3 = COLORS.ERROR
        statusLabel.Text = "Failed to fetch keys."
        notify("Failed to fetch keys from server.", 3, "error")
        return
    end
    for _, k in ipairs(keys) do
        if k == inputKey then
            statusLabel.TextColor3 = COLORS.SUCCESS
            statusLabel.Text = "Key valid! Loading UI..."
            notify("Key valid. Welcome!", 3, "success")
            state.hasAccess = true
            state.cachedKey = inputKey
            if state.rememberKey then
                saveConfig(state)
            end
            task.wait(1)
            keyOverlay.Visible = false
            rootFrame.Visible = true
            blurEffect.Enabled = true
            return
        end
    end
    statusLabel.TextColor3 = COLORS.ERROR
    statusLabel.Text = "Invalid key. Please check again."
    notify("Invalid key entered.", 3, "error")
end

verifyBtn.MouseButton1Click:Connect(verifyKey)
keyBox.FocusLost:Connect(function(enter)
    if enter then verifyKey() end
end)

-- Auto verify cached key
local cfg = loadConfig()
if cfg and cfg.cachedKey and cfg.rememberKey then
    state.cachedKey = cfg.cachedKey
    state.rememberKey = cfg.rememberKey
    local keys = fetchKeys()
    for _, k in ipairs(keys) do
        if k == state.cachedKey then
            state.hasAccess = true
            keyOverlay.Visible = false
            rootFrame.Visible = true
            blurEffect.Enabled = true
            notify("Auto key verified.", 3, "success")
            break
        end
    end
end

if not state.hasAccess then
    keyOverlay.Visible = true
    rootFrame.Visible = false
    blurEffect.Enabled = false
else
    keyOverlay.Visible = false
    rootFrame.Visible = true
    blurEffect.Enabled = true
end

-- =============== UI TOGGLE ===============
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == UI_TOGGLE_KEY and state.hasAccess then
        state.uiVisible = not state.uiVisible
        rootFrame.Visible = state.uiVisible
        blurEffect.Enabled = state.uiVisible
    end
    if state.hasAccess then
        if input.KeyCode == Enum.KeyCode.I then
            setInfiniteJump(not state.infiniteJump)
            infJumpToggle.Set(state.infiniteJump)
        elseif input.KeyCode == Enum.KeyCode.F then
            setFly(not state.fly)
            flyToggle.Set(state.fly)
        elseif input.KeyCode == Enum.KeyCode.N then
            setNoclip(not state.noclip)
            noclipToggle.Set(state.noclip)
        elseif input.KeyCode == Enum.KeyCode.R then
            resetBtn.MouseButton1Click:Fire()
        end
    end
end)

-- Respawn handling
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if state.hasAccess then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = state.walkSpeed
            hum.JumpPower = state.jumpPower
        end
    end
end)

notify("Universal Hub loaded. Please enter your key.", 5, "info")

-- Cleanup function (optional)
_G.UniversalHubCleanup = function()
    for _, conn in pairs(state.connections) do
        if conn and conn.Disconnect then
            conn:Disconnect()
        end
    end
