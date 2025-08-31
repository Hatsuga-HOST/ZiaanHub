--// ZiaanHub Pro - Stylish Key System + Hub Menu with Logo
--// Brand & Copyright: © ZiaanStore | 2025
--// Full custom UI, no external UI libs.

--====================[ CONFIG ]====================--
local KeyLink        = "https://pastebin.com/raw/3vaUdQ30"  -- RAW list (tiap baris 1 key)
local HubName        = "ZiaanHub"
local LogoId         = "rbxassetid://134650706258031"           -- ganti ke Roblox ImageId kamu
local SaveKey        = true                                 -- simpan key (butuh writefile)
local KeyFileName    = "ZiaanHub_Key.txt"                   -- nama file penyimpan key
local OpenOnSuccess  = true                                 -- tampilkan menu setelah key benar
local ToggleKeyBind  = Enum.KeyCode.RightControl            -- hotkey toggle menu
--==================================================--

-- Services
local CoreGui       = game:GetService("CoreGui")
local Players       = game:GetService("Players")
local UserInput     = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local Lighting      = game:GetService("Lighting")
local LocalPlayer   = Players.LocalPlayer

-- Utils
local function safe_pcall(f, ...)
    local ok, res = pcall(f, ...)
    return ok, res
end

local function twn(o, ti, props, easingStyle, easingDir)
    return TweenService:Create(o, TweenInfo.new(ti or 0.25, easingStyle or Enum.EasingStyle.Quad, easingDir or Enum.EasingDirection.Out), props)
end

local function makeCorner(p, r) local c = Instance.new("UICorner") c.Parent = p c.CornerRadius = UDim.new(0, r or 12) return c end
local function makeStroke(p, th, col, tr)
    local s = Instance.new("UIStroke")
    s.Thickness = th or 1.5
    s.Color = col or Color3.fromRGB(220,220,220)
    s.Transparency = tr or 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function dropShadow(parent, size, transparency)
    local sh = Instance.new("ImageLabel")
    sh.Name = "Shadow"
    sh.BackgroundTransparency = 1
    sh.Image = "rbxassetid://6980520019" -- soft shadow sprite
    sh.ScaleType = Enum.ScaleType.Slice
    sh.SliceCenter = Rect.new(10,10,118,118)
    sh.ImageTransparency = transparency or 0.25
    sh.Size = UDim2.new(1, 30, 1, 30)
    sh.Position = UDim2.new(0, -15, 0, -15)
    sh.ZIndex = 0
    sh.Parent = parent
    return sh
end

local function makeToast(screen, text, ok)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, 320, 0, 44)
    holder.Position = UDim2.new(1, -340, 1, 60)
    holder.BackgroundTransparency = 0.2
    holder.BackgroundColor3 = Color3.fromRGB(30,30,30)
    holder.BorderSizePixel = 0
    holder.ClipsDescendants = true
    holder.Active = true
    holder.ZIndex = 1000
    holder.Parent = screen
    makeCorner(holder, 10)
    makeStroke(holder, 1.2, Color3.fromRGB(255,255,255), 0.75)
    dropShadow(holder, nil, 0.35)

    local bar = Instance.new("Frame", holder)
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = ok and Color3.fromRGB(100,220,150) or Color3.fromRGB(220,90,90)
    bar.BorderSizePixel = 0

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(1, -14, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(235,235,235)
    lbl.Text = text

    holder.Visible = true
    twn(holder, 0.25, {Position = UDim2.new(1, -340, 1, -60)}):Play()
    task.delay(3, function()
        twn(holder, 0.25, {Position = UDim2.new(1, -340, 1, 60)}):Play()
        task.wait(0.28)
        holder:Destroy()
    end)
end

-- Blur (khusus saat Key UI aktif)
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

-- Load keys from remote
local ValidKeys = {}
do
    -- coba read saved key dulu (opsional)
    if SaveKey and typeof(readfile) == "function" then
        local ok, saved = safe_pcall(readfile, KeyFileName)
        if ok and saved and saved ~= "" then
            ValidKeys.__SAVED = saved:gsub("%s+$","")
        end
    end
    -- ambil list dari RAW link
    local ok, resp = safe_pcall(function() return game:HttpGet(KeyLink) end)
    if ok and resp then
        for key in string.gmatch(resp, "[^\r\n]+") do
            key = (key or ""):gsub("^%s+",""):gsub("%s+$","")
            if #key > 0 then table.insert(ValidKeys, key) end
        end
    else
        warn("Gagal ambil key dari link RAW, cek URL.")
    end
end

-- Screen
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZiaanHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ScreenGui.Parent = CoreGui

-- Floating Logo (toggle)
local LogoButton = Instance.new("ImageButton")
LogoButton.Name = "ZiaanLogo"
LogoButton.Size = UDim2.new(0,64,0,64)
LogoButton.Position = UDim2.new(0,20,0.5,-32)
LogoButton.BackgroundTransparency = 1
LogoButton.Image = LogoId
LogoButton.AutoButtonColor = true
LogoButton.ZIndex = 50
LogoButton.Parent = ScreenGui

-- Manual draggable for Logo
do
    local dragging = false
    local dragStart, startPos
    LogoButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = LogoButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    LogoButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                LogoButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end

-- Main Window (glassmorphism)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainWindow"
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.BackgroundTransparency = 0.18
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
makeCorner(MainFrame, 18)
makeStroke(MainFrame, 1.6, Color3.fromRGB(255,255,255), 0.7)
dropShadow(MainFrame, nil, 0.32)

-- Subtle glass gradient
local grad = Instance.new("UIGradient", MainFrame)
grad.Rotation = 90
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(220,220,220)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,255,255)),
})
grad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0.00, 0.85),
    NumberSequenceKeypoint.new(0.45, 0.9),
    NumberSequenceKeypoint.new(1.00, 0.92),
})

-- TopBar
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1,0,0,44)
TopBar.BackgroundColor3 = Color3.fromRGB(35,35,35)
TopBar.BackgroundTransparency = 0.15
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 5
makeCorner(TopBar, 18)
makeStroke(TopBar, 1.2, Color3.fromRGB(255,255,255), 0.8)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -110, 1, 0)
Title.Position = UDim2.new(0,16,0,0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = Color3.fromRGB(255,210,90)
Title.Text = HubName.."   •   © ZiaanStore"

-- Buttons (Minimize & Close)
local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0,30,0,28)
MinBtn.Position = UDim2.new(1,-76,0.5,-14)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.TextColor3 = Color3.fromRGB(235,235,235)
MinBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
MinBtn.AutoButtonColor = true
makeCorner(MinBtn, 8)

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0,30,0,28)
CloseBtn.Position = UDim2.new(1,-40,0.5,-14)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(255,120,120)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
CloseBtn.AutoButtonColor = true
makeCorner(CloseBtn, 8)

-- Drag Main by TopBar
do
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Content area
local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, -20, 1, -64)
Content.Position = UDim2.new(0,10,0,54)
Content.BackgroundTransparency = 1

-- Example content (placeholder)
local para = Instance.new("TextLabel", Content)
para.Size = UDim2.new(1, 0, 1, 0)
para.BackgroundTransparency = 1
para.Text = "Selamat datang di ZiaanHub Pro.\nTambahkan menu & fitur lu di area ini."
para.Font = Enum.Font.Gotham
para.TextSize = 16
para.TextColor3 = Color3.fromRGB(230,230,230)
para.TextWrapped = true

-- Modal confirm Close
local function confirmClose(callbackYes)
    local modal = Instance.new("Frame", ScreenGui)
    modal.Size = UDim2.new(1,0,1,0)
    modal.BackgroundColor3 = Color3.fromRGB(0,0,0)
    modal.BackgroundTransparency = 0.35
    modal.ZIndex = 200
    local card = Instance.new("Frame", modal)
    card.Size = UDim2.new(0, 360, 0, 160)
    card.Position = UDim2.new(0.5, -180, 0.5, -80)
    card.BackgroundColor3 = Color3.fromRGB(28,28,28)
    card.BackgroundTransparency = 0.1
    card.BorderSizePixel = 0
    card.ZIndex = 201
    makeCorner(card, 14)
    makeStroke(card, 1.2, Color3.fromRGB(255,255,255), 0.75)
    dropShadow(card, nil, 0.35)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(1,-24,0,60)
    lbl.Position = UDim2.new(0,12,0,14)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 16
    lbl.TextWrapped = true
    lbl.TextColor3 = Color3.fromRGB(240,240,240)
    lbl.Text = "Yakin mau menutup ZiaanHub secara permanen?"

    local yes = Instance.new("TextButton", card)
    yes.Size = UDim2.new(0.5, -18, 0, 36)
    yes.Position = UDim2.new(0, 12, 1, -48)
    yes.Text = "Ya, Tutup"
    yes.Font = Enum.Font.GothamBold
    yes.TextSize = 15
    yes.TextColor3 = Color3.fromRGB(255,255,255)
    yes.BackgroundColor3 = Color3.fromRGB(230,90,90)
    makeCorner(yes, 10)

    local no = Instance.new("TextButton", card)
    no.Size = UDim2.new(0.5, -18, 0, 36)
    no.Position = UDim2.new(0.5, 6, 1, -48)
    no.Text = "Batal"
    no.Font = Enum.Font.GothamBold
    no.TextSize = 15
    no.TextColor3 = Color3.fromRGB(255,255,255)
    no.BackgroundColor3 = Color3.fromRGB(70,140,220)
    makeCorner(no, 10)

    twn(card, 0.18, {Size = UDim2.new(0, 360, 0, 160)}):Play()

    yes.MouseButton1Click:Connect(function()
        modal:Destroy()
        if callbackYes then callbackYes() end
    end)
    no.MouseButton1Click:Connect(function()
        twn(card, 0.18, {Size = UDim2.new(0, 360, 0, 160)}):Play()
        modal:Destroy()
    end)
end

-- Button logic
LogoButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        twn(MainFrame, 0.18, {BackgroundTransparency = 0.18}):Play()
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    makeToast(ScreenGui, "Minimized. Klik logo untuk munculin lagi.", true)
end)

CloseBtn.MouseButton1Click:Connect(function()
    confirmClose(function()
        ScreenGui:Destroy()
        if blur then blur:Destroy() end
    end)
end)

-- Hotkey toggle
UserInput.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == ToggleKeyBind then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

--====================[ KEY SYSTEM POPUP ]====================--
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0,360,0,210)
KeyFrame.Position = UDim2.new(0.5,-180,0.5,-105)
KeyFrame.BackgroundColor3 = Color3.fromRGB(22,22,22)
KeyFrame.BackgroundTransparency = 0.05
KeyFrame.BorderSizePixel = 0
KeyFrame.ZIndex = 150
KeyFrame.Parent = ScreenGui
makeCorner(KeyFrame, 16)
makeStroke(KeyFrame, 1.4, Color3.fromRGB(255,255,255), 0.7)
dropShadow(KeyFrame, nil, 0.35)

local KeyTitle = Instance.new("TextLabel", KeyFrame)
KeyTitle.Size = UDim2.new(1, -20, 0, 40)
KeyTitle.Position = UDim2.new(0,10,0,8)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 18
KeyTitle.TextColor3 = Color3.fromRGB(255,210,90)
KeyTitle.Text = "🔑 ZiaanHub Pro — Key Verification"

local Sub = Instance.new("TextLabel", KeyFrame)
Sub.Size = UDim2.new(1, -20, 0, 20)
Sub.Position = UDim2.new(0,10,0,44)
Sub.BackgroundTransparency = 1
Sub.Font = Enum.Font.Gotham
Sub.TextSize = 14
Sub.TextColor3 = Color3.fromRGB(210,210,210)
Sub.TextXAlignment = Enum.TextXAlignment.Left
Sub.Text = "Masukkan key kamu (RAW list: Pastebin/GitHub)."

local KeyBox = Instance.new("TextBox", KeyFrame)
KeyBox.Size = UDim2.new(1, -24, 0, 40)
KeyBox.Position = UDim2.new(0,12,0,78)
KeyBox.PlaceholderText = "Paste your key here..."
KeyBox.Text = ""
KeyBox.BackgroundColor3 = Color3.fromRGB(36,36,36)
KeyBox.TextColor3 = Color3.fromRGB(255,255,255)
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 16
KeyBox.ClearTextOnFocus = false
makeCorner(KeyBox, 10)

local Submit = Instance.new("TextButton", KeyFrame)
Submit.Size = UDim2.new(0.5, -16, 0, 36)
Submit.Position = UDim2.new(0,12,1,-48)
Submit.Text = "Verify"
Submit.Font = Enum.Font.GothamBold
Submit.TextSize = 16
Submit.TextColor3 = Color3.fromRGB(255,255,255)
Submit.BackgroundColor3 = Color3.fromRGB(70,140,220)
makeCorner(Submit, 10)

local Cancel = Instance.new("TextButton", KeyFrame)
Cancel.Size = UDim2.new(0.5, -16, 0, 36)
Cancel.Position = UDim2.new(0.5,4,1,-48)
Cancel.Text = "Close"
Cancel.Font = Enum.Font.GothamBold
Cancel.TextSize = 16
Cancel.TextColor3 = Color3.fromRGB(255,255,255)
Cancel.BackgroundColor3 = Color3.fromRGB(80,80,80)
makeCorner(Cancel, 10)

local CopyR = Instance.new("TextLabel", KeyFrame)
CopyR.Size = UDim2.new(1, -20, 0, 18)
CopyR.Position = UDim2.new(0,10,1,-22)
CopyR.BackgroundTransparency = 1
CopyR.Font = Enum.Font.Gotham
CopyR.TextSize = 12
CopyR.TextColor3 = Color3.fromRGB(180,180,180)
CopyR.TextXAlignment = Enum.TextXAlignment.Right
CopyR.Text = "© ZiaanStore"

-- Activate blur for key UI
twn(blur, 0.22, {Size = 16}):Play()

-- If saved key exists, prefill
if ValidKeys.__SAVED then
    KeyBox.Text = ValidKeys.__SAVED
end

local function isValidKey(k)
    if not k or #k == 0 then return false end
    for _, v in ipairs(ValidKeys) do
        if k == v then return true end
    end
    return false
end

Submit.MouseButton1Click:Connect(function()
    local inputKey = (KeyBox.Text or ""):gsub("^%s+",""):gsub("%s+$","")
    if isValidKey(inputKey) then
        Submit.Text = "✅ Verified"
        twn(Submit, 0.18, {BackgroundColor3 = Color3.fromRGB(90,200,140)}):Play()
        makeToast(ScreenGui, "Key benar. Selamat datang!", true)

        -- Save key if allowed
        if SaveKey and typeof(writefile) == "function" then
            safe_pcall(writefile, KeyFileName, inputKey)
        end

        -- Close key UI & open main
        twn(KeyFrame, 0.18, {BackgroundTransparency = 1}):Play()
        task.wait(0.18)
        KeyFrame:Destroy()
        twn(blur, 0.25, {Size = 0}):Play()

        if OpenOnSuccess then
            MainFrame.Visible = true
            MainFrame.BackgroundTransparency = 0.28
            twn(MainFrame, 0.22, {BackgroundTransparency = 0.18}):Play()
        end
    else
        Submit.Text = "❌ Salah"
        twn(Submit, 0.18, {BackgroundColor3 = Color3.fromRGB(210,80,80)}):Play()
        makeToast(ScreenGui, "Key salah. Coba lagi.", false)
        task.delay(0.7, function()
            Submit.Text = "Verify"
            twn(Submit, 0.18, {BackgroundColor3 = Color3.fromRGB(70,140,220)}):Play()
        end)
    end
end)

Cancel.MouseButton1Click:Connect(function()
    confirmClose(function()
        ScreenGui:Destroy()
        if blur then blur:Destroy() end
    end)
end)
