-- ZiaanHub Key System (Full) - Final
-- By ZiaanStore © 2025
-- Pure custom UI (no external libs). Theme: Ocean Dark Blue.
-- CONFIG (ganti ini sesuai kebutuhan)
local KeyLink = "https://pastebin.com/raw/3vaUdQ30" -- pastebin/raw atau github raw, tiap baris 1 key
-- MAIN MENU HARUS DIJALANKAN DENGAN LOADSTRING DI SINI:
local MenuLoadURL_HARDCODED = "https://raw.githubusercontent.com/MajestySkie/Zombie-Killer/refs/heads/main/Chx.lua"

local SaveKey = true            -- simpan key lokal (writefile/readfile)
local KeyFile = "ZiaanHub_Key.txt"
local ToggleKeyBind = Enum.KeyCode.RightControl -- toggle UI

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInput = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- HELPERS
local function safe_pcall(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok, res
end

local function tween(instance, t, props)
    return TweenService:Create(instance, TweenInfo.new(t or 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.Parent = parent
    c.CornerRadius = UDim.new(0, radius or 12)
    return c
end

local function makeStroke(parent, th, col, tr)
    local s = Instance.new("UIStroke")
    s.Thickness = th or 1.2
    s.Color = col or Color3.fromRGB(255,255,255)
    s.Transparency = tr or 0.75
    s.Parent = parent
    return s
end

local function trim(s)
    return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

-- CHECK HTTP AVAILABILITY
local HttpEnabled = true
do
    local ok = pcall(function() return game.HttpGet or game:HttpGet("") end)
    if not ok then HttpEnabled = false end
end

-- LOAD KEYS (from remote + local saved)
local ValidKeys = {}
do
    -- saved key (prefill)
    if SaveKey and type(readfile) == "function" then
        local ok, saved = safe_pcall(readfile, KeyFile)
        if ok and saved and #saved > 0 then
            ValidKeys.__SAVED = trim(tostring(saved))
        end
    end

    if HttpEnabled then
        local ok, resp = safe_pcall(function() return game:HttpGet(KeyLink) end)
        if ok and resp and #resp > 0 then
            for line in string.gmatch(resp, "[^\r\n]+") do
                local k = trim(line)
                if #k > 0 then table.insert(ValidKeys, k) end
            end
        else
            warn("[ZiaanHub] Gagal ambil key dari KeyLink, cek URL/HTTP executor.")
        end
    else
        warn("[ZiaanHub] HTTP tidak tersedia; hanya saved key (jika ada) bisa dipakai.")
    end
end

-- UI CREATION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZiaanHub_KeyUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

-- BACKDROP BLUR
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

-- MAIN FRAME (ocean-dark glass)
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 460, 0, 260)
Main.Position = UDim2.new(0.5, -230, 0.5, -130)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(12, 26, 45)
Main.BackgroundTransparency = 0.10
Main.BorderSizePixel = 0
Main.ZIndex = 50
Main.Parent = ScreenGui
makeCorner(Main, 16)
makeStroke(Main, 1.2, Color3.fromRGB(170,210,255), 0.88)

local grad = Instance.new("UIGradient", Main)
grad.Rotation = 90
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 38, 64)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 18, 32))
}
grad.Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0,0.84), NumberSequenceKeypoint.new(1,0.83) }

-- HEADER
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 56)
Header.BackgroundTransparency = 1
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "ZiaanHub — Key Verification"
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(180,220,255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- CLOSE BUTTON (X)
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -46, 0.5, -18)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(255,150,150)
CloseBtn.BackgroundColor3 = Color3.fromRGB(28,44,68)
CloseBtn.BorderSizePixel = 0
makeCorner(CloseBtn, 8)

-- BODY
local Body = Instance.new("Frame", Main)
Body.Size = UDim2.new(1, -28, 1, -76)
Body.Position = UDim2.new(0, 14, 0, 62)
Body.BackgroundTransparency = 1

local Info = Instance.new("TextLabel", Body)
Info.Size = UDim2.new(1, 0, 0, 26)
Info.BackgroundTransparency = 1
Info.Font = Enum.Font.Gotham
Info.Text = "Masukkan key yang kamu dapatkan (Pastebin / GitHub RAW / Lino)."
Info.TextColor3 = Color3.fromRGB(200,220,255)
Info.TextSize = 14
Info.TextXAlignment = Enum.TextXAlignment.Left

-- Key Input
local KeyBox = Instance.new("TextBox", Body)
KeyBox.Size = UDim2.new(1, 0, 0, 44)
KeyBox.Position = UDim2.new(0, 0, 0, 34)
KeyBox.PlaceholderText = "Paste your key here..."
KeyBox.ClearTextOnFocus = false
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 16
KeyBox.TextColor3 = Color3.fromRGB(245,245,245)
KeyBox.BackgroundColor3 = Color3.fromRGB(12,30,52)
KeyBox.BorderSizePixel = 0
makeCorner(KeyBox, 10)

-- Buttons Row
local Buttons = Instance.new("Frame", Body)
Buttons.Size = UDim2.new(1, 0, 0, 48)
Buttons.Position = UDim2.new(0, 0, 1, -52)
Buttons.BackgroundTransparency = 1

local VerifyBtn = Instance.new("TextButton", Buttons)
VerifyBtn.Size = UDim2.new(0.55, -8, 1, 0)
VerifyBtn.Position = UDim2.new(0, 0, 0, 0)
VerifyBtn.Text = "Verify"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 16
VerifyBtn.TextColor3 = Color3.fromRGB(245,245,245)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0,120,210)
makeCorner(VerifyBtn, 10)

local CloseBtn2 = Instance.new("TextButton", Buttons)
CloseBtn2.Size = UDim2.new(0.45, -8, 1, 0)
CloseBtn2.Position = UDim2.new(0.55, 8, 0, 0)
CloseBtn2.Text = "Close"
CloseBtn2.Font = Enum.Font.GothamBold
CloseBtn2.TextSize = 16
CloseBtn2.TextColor3 = Color3.fromRGB(245,245,245)
CloseBtn2.BackgroundColor3 = Color3.fromRGB(40,60,80)
makeCorner(CloseBtn2, 10)

-- FOOTER
local Footer = Instance.new("TextLabel", Main)
Footer.Size = UDim2.new(1, -20, 0, 20)
Footer.Position = UDim2.new(0, 10, 1, -26)
Footer.BackgroundTransparency = 1
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 12
Footer.TextColor3 = Color3.fromRGB(160,200,230)
Footer.Text = "© ZiaanStore"

-- TOAST helper
local function toast(msg, ok)
    local holder = Instance.new("Frame", ScreenGui)
    holder.Size = UDim2.new(0, 340, 0, 46)
    holder.Position = UDim2.new(1, -360, 1, 60)
    holder.BackgroundColor3 = Color3.fromRGB(12,26,44)
    holder.BackgroundTransparency = 0.06
    holder.BorderSizePixel = 0
    holder.ZIndex = 9999
    makeCorner(holder, 10)
    makeStroke(holder, 1, Color3.fromRGB(160,200,255), 0.9)
    local bar = Instance.new("Frame", holder)
    bar.Size = UDim2.new(0, 8, 1, 0)
    bar.Position = UDim2.new(0, 0, 0, 0)
    bar.BackgroundColor3 = ok and Color3.fromRGB(90,200,140) or Color3.fromRGB(220,80,80)
    bar.BorderSizePixel = 0
    local label = Instance.new("TextLabel", holder)
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.Text = msg
    tween(holder, 0.22, {Position = UDim2.new(1, -360, 1, -80)}):Play()
    task.delay(3, function()
        tween(holder, 0.22, {Position = UDim2.new(1, -360, 1, 60)}):Play()
        task.wait(0.3) holder:Destroy()
    end)
end

-- DRAG (Main frame)
do
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- CLOSE / BUTTONS
local function destroyAll()
    pcall(function() ScreenGui:Destroy() end)
    pcall(function() blur:Destroy() end)
end

CloseBtn.MouseButton1Click:Connect(destroyAll)
CloseBtn2.MouseButton1Click:Connect(destroyAll)

-- Helper: isValidKey
local function isValidKey(k)
    if not k or #k < 1 then return false end
    k = trim(k)
    if ValidKeys.__SAVED and k == ValidKeys.__SAVED then return true end
    for _, v in ipairs(ValidKeys) do
        if k == v then return true end
    end
    return false
end

-- Prefill saved if any
if ValidKeys.__SAVED then
    KeyBox.Text = ValidKeys.__SAVED
end

-- VERIFY LOGIC
VerifyBtn.MouseButton1Click:Connect(function()
    local entered = trim(KeyBox.Text)
    if entered == "" then
        toast("Masukkan key dulu.", false)
        return
    end

    -- If we have no remote keys (Http failed) but user saved one locally allow check saved
    if #ValidKeys == 0 and not ValidKeys.__SAVED then
        toast("Tidak dapat menghubungi server key (HTTP).", false)
        return
    end

    if isValidKey(entered) then
        VerifyBtn.Text = "Verified"
        tween(VerifyBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(60,200,140)}):Play()
        toast("Key valid. Loading main menu...", true)

        if SaveKey and type(writefile) == "function" then
            pcall(function() writefile(KeyFile, entered) end)
        end

        -- fade out UI
        tween(Main, 0.18, {BackgroundTransparency = 1}):Play()
        for _, o in ipairs(Main:GetDescendants()) do
            if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
                pcall(function() tween(o, 0.18, {TextTransparency = 1}):Play() end)
            end
        end
        task.wait(0.22)
        destroyAll()

        -- DIRECT loadstring (hardcoded as requested)
        if HttpEnabled then
            local ok, res = safe_pcall(function()
                return game:HttpGet(MenuLoadURL_HARDCODED)
            end)
            if ok and res and #res > 10 then
                local ok2, err = safe_pcall(function() loadstring(res)() end)
                if not ok2 then
                    warn("[ZiaanHub] Error executing menu script:", err)
                    toast("Gagal menjalankan menu utama.", false)
                end
            else
                warn("[ZiaanHub] Gagal ambil menu utama:", res)
                toast("Gagal load menu utama. Cek URL/koneksi.", false)
            end
        else
            toast("HTTP tidak tersedia. Tidak bisa load menu.", false)
        end
    else
        VerifyBtn.Text = "Invalid"
        tween(VerifyBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(210,80,80)}):Play()
        toast("Key salah. Ambil key yang valid lalu coba lagi.", false)
        task.delay(0.9, function()
            if VerifyBtn then
                VerifyBtn.Text = "Verify"
                tween(VerifyBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(0,120,210)}):Play()
            end
        end)
    end
end)

-- TOGGLE WITH HOTKEY & ESC CLOSE
UserInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == ToggleKeyBind then
        Main.Visible = not Main.Visible
        tween(blur, 0.18, {Size = Main.Visible and 14 or 0}):Play()
    elseif input.KeyCode == Enum.KeyCode.Escape then
        destroyAll()
    end
end)

-- show UI
Main.Visible = true
tween(blur, 0.22, {Size = 14}):Play()
