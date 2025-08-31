-- ZiaanHub Key System (Full)
-- By ZiaanStore © 2025
-- Pure custom UI (no external libs). Theme: Ocean Dark Blue.
-- CONFIG:
local KeyLink = "https://pastebin.com/raw/3vaUdQ30"             -- RAW file: tiap baris 1 key
local MenuURL = "https://raw.githubusercontent.com/MajestySkie/list/refs/heads/main/games"    -- URL script utama yang akan di-load jika key valid
local LogoId  = "rbxassetid://134650706258031"                      -- Roblox image id untuk logo melengkung
local SaveKey = true                                            -- Simpan key lokal (butuh writefile/readfile)
local KeyFile = "ZiaanHub_Key.txt"                              -- nama file jika SaveKey=true
local OpenOnSuccess = true                                      -- buka main window otomatis setelah verifikasi
local ToggleKeyBind = Enum.KeyCode.RightControl                  -- hotkey toggle (optional)

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInput = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpEnabled = true
local LocalPlayer = Players.LocalPlayer

-- SAFETY HELPERS
local function safe_pcall(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok, res
end

local function tween(instance, t, props)
    return TweenService:Create(instance, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
end

local function makeCorner(parent, radius) local c = Instance.new("UICorner") c.Parent = parent c.CornerRadius = UDim.new(0, radius or 12) return c end
local function makeStroke(parent, th, col, tr) local s = Instance.new("UIStroke") s.Thickness = th or 1.2 s.Color = col or Color3.fromRGB(255,255,255) s.Transparency = tr or 0.75 s.Parent = parent return s end

-- TRY HTTP
local okHttp, test = pcall(function() return game:HttpGet or HttpGet end)
if not okHttp then HttpEnabled = false end

-- LOAD remote keys
local ValidKeys = {}
do
    -- Try saved key first (prefill)
    if SaveKey and type(readfile) == "function" then
        local ok, saved = safe_pcall(readfile, KeyFile)
        if ok and saved and #saved > 0 then
            ValidKeys.__SAVED = tostring(saved):gsub("%s+$","")
        end
    end

    if HttpEnabled then
        local ok, resp = safe_pcall(function() return game:HttpGet(KeyLink) end)
        if ok and resp and #resp > 0 then
            for line in string.gmatch(resp, "[^\r\n]+") do
                local k = tostring(line):gsub("^%s+",""):gsub("%s+$","")
                if #k > 0 then table.insert(ValidKeys, k) end
            end
        else
            warn("[ZiaanHub] Gagal ambil key dari KeyLink, cek URL atau executor HTTP.")
        end
    else
        warn("[ZiaanHub] HTTP tidak tersedia pada executor. Hanya saved key bisa dipakai.")
    end
end

-- CREATE UI
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZiaanHub_KeyUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

-- BACKDROP BLUR (aktif hanya saat KeyFrame muncul)
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

-- FLOATING LOGO (draggable)
local LogoBtn = Instance.new("ImageButton")
LogoBtn.Name = "ZiaanLogo"
LogoBtn.Size = UDim2.new(0, 68, 0, 68)
LogoBtn.Position = UDim2.new(0, 18, 0.5, -34)
LogoBtn.AnchorPoint = Vector2.new(0,0.5)
LogoBtn.BackgroundTransparency = 1
LogoBtn.Image = LogoId
LogoBtn.Parent = ScreenGui
LogoBtn.AutoButtonColor = true
LogoBtn.ZIndex = 60
-- rounded logo
makeCorner(LogoBtn, 34)

-- subtle outline
local logoStroke = Instance.new("ImageLabel", LogoBtn)
logoStroke.Size = UDim2.new(1,6,1,6)
logoStroke.Position = UDim2.new(0,-3,0,-3)
logoStroke.BackgroundTransparency = 1
logoStroke.Image = "rbxassetid://6991545602" -- subtle outer glow sprite (works as decoration)
logoStroke.ScaleType = Enum.ScaleType.Slice
logoStroke.SliceCenter = Rect.new(10,10,118,118)
logoStroke.ImageTransparency = 0.8

-- MAIN KEY FRAME (glass card)
local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeyFrame"
KeyFrame.Size = UDim2.new(0, 420, 0, 220)
KeyFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
KeyFrame.AnchorPoint = Vector2.new(0.5,0.5)
KeyFrame.BackgroundColor3 = Color3.fromRGB(12,26,45) -- deeper ocean base
KeyFrame.BackgroundTransparency = 0.12
KeyFrame.BorderSizePixel = 0
KeyFrame.ZIndex = 65
KeyFrame.Parent = ScreenGui
makeCorner(KeyFrame, 16)
makeStroke(KeyFrame, 1.4, Color3.fromRGB(180,210,255), 0.88)

-- subtle gradient to keep it vivid (not butek)
local grad = Instance.new("UIGradient", KeyFrame)
grad.Rotation = 90
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 38, 64)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 18, 32))
}
grad.Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0,0.85), NumberSequenceKeypoint.new(1,0.84) }

-- inner shadow sprite
local shadow = Instance.new("ImageLabel", KeyFrame)
shadow.Size = UDim2.new(1, 16, 1, 16)
shadow.Position = UDim2.new(0, -8, 0, -8)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6980520019"
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10,10,118,118)
shadow.ImageTransparency = 0.28

-- TOPBAR
local TopBar = Instance.new("Frame", KeyFrame)
TopBar.Size = UDim2.new(1, 0, 0, 52)
TopBar.BackgroundTransparency = 1
TopBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -110, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "🔑 ZiaanHub — Key Verification"
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(170,220,255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- MINIMIZE & CLOSE
local BtnMin = Instance.new("TextButton", TopBar)
BtnMin.Size = UDim2.new(0, 34, 0, 34)
BtnMin.Position = UDim2.new(1, -98, 0.5, -17)
BtnMin.AnchorPoint = Vector2.new(0,0)
BtnMin.Text = "-"
BtnMin.Font = Enum.Font.GothamBold
BtnMin.TextSize = 20
BtnMin.TextColor3 = Color3.fromRGB(230,230,230)
BtnMin.BackgroundColor3 = Color3.fromRGB(28,44,68)
BtnMin.BorderSizePixel = 0
makeCorner(BtnMin, 8)

local BtnClose = Instance.new("TextButton", TopBar)
BtnClose.Size = UDim2.new(0, 34, 0, 34)
BtnClose.Position = UDim2.new(1, -54, 0.5, -17)
BtnClose.Text = "X"
BtnClose.Font = Enum.Font.GothamBold
BtnClose.TextSize = 16
BtnClose.TextColor3 = Color3.fromRGB(255,140,140)
BtnClose.BackgroundColor3 = Color3.fromRGB(28,44,68)
BtnClose.BorderSizePixel = 0
makeCorner(BtnClose, 8)

-- Logo small inside topbar (rounded)
local TopLogo = Instance.new("ImageLabel", TopBar)
TopLogo.Size = UDim2.new(0, 42, 0, 42)
TopLogo.Position = UDim2.new(1, -170, 0.5, -21)
TopLogo.BackgroundTransparency = 1
TopLogo.Image = LogoId
makeCorner(TopLogo, 10)

-- BODY (content)
local Body = Instance.new("Frame", KeyFrame)
Body.Size = UDim2.new(1, -28, 1, -64)
Body.Position = UDim2.new(0, 14, 0, 54)
Body.BackgroundTransparency = 1

local SubText = Instance.new("TextLabel", Body)
SubText.Size = UDim2.new(1,0,0,26)
SubText.Position = UDim2.new(0,0,0,0)
SubText.BackgroundTransparency = 1
SubText.Font = Enum.Font.Gotham
SubText.Text = "Masukkan key yang kamu dapatkan. (Pastebin / GitHub RAW list)"
SubText.TextColor3 = Color3.fromRGB(200,220,255)
SubText.TextSize = 14
SubText.TextXAlignment = Enum.TextXAlignment.Left

-- KeyBox
local KeyBox = Instance.new("TextBox", Body)
KeyBox.Size = UDim2.new(1, -0, 0, 44)
KeyBox.Position = UDim2.new(0, 0, 0, 32)
KeyBox.PlaceholderText = "Paste your key here..."
KeyBox.Text = ""
KeyBox.ClearTextOnFocus = false
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 16
KeyBox.TextColor3 = Color3.fromRGB(245,245,245)
KeyBox.BackgroundColor3 = Color3.fromRGB(12,30,52)
KeyBox.BorderSizePixel = 0
makeCorner(KeyBox, 10)

-- Buttons row
local BtnRow = Instance.new("Frame", Body)
BtnRow.Size = UDim2.new(1, 0, 0, 48)
BtnRow.Position = UDim2.new(0, 0, 1, -52)
BtnRow.BackgroundTransparency = 1

local VerifyBtn = Instance.new("TextButton", BtnRow)
VerifyBtn.Size = UDim2.new(0.55, -8, 1, 0)
VerifyBtn.Position = UDim2.new(0, 0, 0, 0)
VerifyBtn.Text = "Verify"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 16
VerifyBtn.TextColor3 = Color3.fromRGB(245,245,245)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0,120,210)
makeCorner(VerifyBtn, 10)

local CloseBtn2 = Instance.new("TextButton", BtnRow)
CloseBtn2.Size = UDim2.new(0.45, -8, 1, 0)
CloseBtn2.Position = UDim2.new(0.55, 8, 0, 0)
CloseBtn2.Text = "Close"
CloseBtn2.Font = Enum.Font.GothamBold
CloseBtn2.TextSize = 16
CloseBtn2.TextColor3 = Color3.fromRGB(245,245,245)
CloseBtn2.BackgroundColor3 = Color3.fromRGB(40,60,80)
makeCorner(CloseBtn2, 10)

-- FOOTER copyright
local Footer = Instance.new("TextLabel", KeyFrame)
Footer.Size = UDim2.new(1, -20, 0, 20)
Footer.Position = UDim2.new(0, 10, 1, -28)
Footer.BackgroundTransparency = 1
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 12
Footer.TextColor3 = Color3.fromRGB(170,200,230)
Footer.Text = "© ZiaanStore"

-- TOAST helper
local function toast(msg, ok)
    local holder = Instance.new("Frame", ScreenGui)
    holder.Size = UDim2.new(0, 320, 0, 44)
    holder.Position = UDim2.new(1, -340, 1, 60)
    holder.BackgroundColor3 = Color3.fromRGB(12,26,44)
    holder.BackgroundTransparency = 0.06
    holder.BorderSizePixel = 0
    holder.ZIndex = 9999
    makeCorner(holder, 10)
    makeStroke(holder, 1, Color3.fromRGB(160,200,255), 0.9)
    local bar = Instance.new("Frame", holder)
    bar.Size = UDim2.new(0, 6, 1, 0)
    bar.Position = UDim2.new(0,0,0,0)
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
    tween(holder, 0.22, {Position = UDim2.new(1, -340, 1, -60)}):Play()
    task.delay(3, function()
        tween(holder, 0.22, {Position = UDim2.new(1, -340, 1, 60)}):Play()
        task.wait(0.28) holder:Destroy()
    end)
end

-- DRAG (for KeyFrame)
do
    local dragging, dragStart, startPos
    KeyFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = KeyFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    KeyFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            KeyFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- DRAG for floating Logo separate (so user can move logo)
do
    local dragging, dragStart, startPos
    LogoBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = LogoBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    LogoBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            LogoBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Top small logo draggable too
do
    local dragging, dragStart, startPos
    TopLogo.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = KeyFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TopLogo.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            KeyFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Logo click toggles KeyFrame visibility (and blur)
LogoBtn.MouseButton1Click:Connect(function()
    KeyFrame.Visible = not KeyFrame.Visible
    if KeyFrame.Visible then
        tween(blur, 0.22, {Size = 14}):Play()
    else
        tween(blur, 0.22, {Size = 0}):Play()
    end
end)

-- Minimize button behaviour
BtnMin.MouseButton1Click:Connect(function()
    KeyFrame.Visible = false
    toast("Minimized. Click logo to show again.", true)
    tween(blur, 0.22, {Size = 0}):Play()
end)

-- Confirm modal helper
local function confirmModal(question, onYes)
    local modal = Instance.new("Frame", ScreenGui)
    modal.Size = UDim2.new(1,0,1,0)
    modal.BackgroundColor3 = Color3.fromRGB(0,0,0)
    modal.BackgroundTransparency = 0.36
    modal.ZIndex = 9998
    local card = Instance.new("Frame", modal)
    card.Size = UDim2.new(0, 380, 0, 150)
    card.Position = UDim2.new(0.5, -190, 0.5, -75)
    card.BackgroundColor3 = Color3.fromRGB(16,28,44)
    card.BorderSizePixel = 0
    makeCorner(card, 12)
    makeStroke(card, 1.2, Color3.fromRGB(180,210,255), 0.85)
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(1, -24, 0, 72)
    lbl.Position = UDim2.new(0,12,0,12)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 15
    lbl.TextColor3 = Color3.fromRGB(230,230,230)
    lbl.Text = question
    local yes = Instance.new("TextButton", card)
    yes.Size = UDim2.new(0.48, -10, 0, 36)
    yes.Position = UDim2.new(0, 12, 1, -48)
    yes.Text = "Yes"
    yes.Font = Enum.Font.GothamBold
    yes.BackgroundColor3 = Color3.fromRGB(200,70,70)
    makeCorner(yes, 10)
    local no = Instance.new("TextButton", card)
    no.Size = UDim2.new(0.48, -10, 0, 36)
    no.Position = UDim2.new(0.52, 8, 1, -48)
    no.Text = "No"
    no.Font = Enum.Font.GothamBold
    no.BackgroundColor3 = Color3.fromRGB(70,140,220)
    makeCorner(no, 10)
    yes.MouseButton1Click:Connect(function()
        modal:Destroy()
        if onYes then pcall(onYes) end
    end)
    no.MouseButton1Click:Connect(function()
        modal:Destroy()
    end)
end

-- Close behaviour (confirm)
BtnClose.MouseButton1Click:Connect(function()
    confirmModal("Yakin mau menutup ZiaanHub secara permanen? (Script akan dihapus dari UI)", function()
        pcall(function() ScreenGui:Destroy() end)
        if blur then pcall(function() blur:Destroy() end) end
    end)
end)
CloseBtn2.MouseButton1Click:Connect(function()
    confirmModal("Yakin mau menutup ZiaanHub secara permanen? (Script akan dihapus dari UI)", function()
        pcall(function() ScreenGui:Destroy() end)
        if blur then pcall(function() blur:Destroy() end) end
    end)
end)

-- Helpers: isValidKey
local function isValidKey(k)
    if not k or #k < 1 then return false end
    -- check saved quick match
    if ValidKeys.__SAVED and k == ValidKeys.__SAVED then return true end
    for _, v in ipairs(ValidKeys) do
        if k == v then return true end
    end
    return false
end

-- Pre-fill if saved
if ValidKeys.__SAVED then
    KeyBox.Text = ValidKeys.__SAVED
end

-- VERIFY logic
VerifyBtn.MouseButton1Click:Connect(function()
    local entered = (KeyBox.Text or ""):gsub("^%s+",""):gsub("%s+$","")
    if isValidKey(entered) then
        VerifyBtn.Text = "✅ Verified"
        tween(VerifyBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(60,200,140)}):Play()
        toast("Key valid. Loading main menu...", true)
        -- save key if allowed
        if SaveKey and type(writefile) == "function" then
            pcall(function() writefile(KeyFile, entered) end)
        end
        -- close key UI
        tween(KeyFrame, 0.18, {BackgroundTransparency = 1}):Play()
        task.wait(0.18)
        pcall(function() KeyFrame:Destroy() end)
        tween(blur, 0.22, {Size = 0}):Play()
        -- Load main menu script (separate)
        if MenuURL and #MenuURL > 8 then
            local ok, res = safe_pcall(function() return game:HttpGet(MenuURL) end)
            if ok and res then
                safe_pcall(function() loadstring(res)() end)
            else
                toast("Gagal load Menu utama. Cek MenuURL atau HTTP.", false)
                warn("[ZiaanHub] Gagal load MenuURL:", res)
            end
        else
            toast("MenuURL belum diset. Berhenti.", false)
        end
    else
        VerifyBtn.Text = "❌ Invalid"
        tween(VerifyBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(210,80,80)}):Play()
        toast("Key salah. Cek kembali atau ambil dari link resmi.", false)
        task.delay(0.8, function()
            if VerifyBtn then
                VerifyBtn.Text = "Verify"
                tween(VerifyBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(0,120,210)}):Play()
            end
        end)
    end
end)

-- Close with ESC key optionally
UserInput.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Escape then
        confirmModal("Tutup ZiaanHub? (ESC)", function()
            pcall(function() ScreenGui:Destroy() end)
            if blur then pcall(function() blur:Destroy() end) end
        end)
    elseif input.KeyCode == ToggleKeyBind then
        KeyFrame.Visible = not KeyFrame.Visible
        if KeyFrame.Visible then tween(blur, 0.18, {Size = 14}):Play() else tween(blur, 0.18, {Size = 0}):Play() end
    end
end)

-- Final: show blur + panel
tween(blur, 0.22, {Size = 14}):Play()
KeyFrame.Visible = true
