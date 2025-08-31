-- ZiaanHub Key System (Final Pro UI)
-- By ZiaanStore © 2025
-- Ocean Dark Blue Theme, draggable, confirm exit

-- CONFIG
local KeyLink = "https://pastebin.com/raw/3vaUdQ30" -- pastebin/github raw, tiap baris 1 key
local MenuLoadURL = "https://raw.githubusercontent.com/MajestySkie/list/refs/heads/main/games"

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInput = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- HELPERS
local function tween(obj, time, props)
    TweenService:Create(obj, TweenInfo.new(time or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
end

local function makeStroke(parent, col)
    local s = Instance.new("UIStroke")
    s.Thickness = 1.2
    s.Color = col or Color3.fromRGB(150,200,255)
    s.Transparency = 0.6
    s.Parent = parent
end

local function trim(s)
    return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

-- GET KEYS
local ValidKeys = {}
do
    local ok, resp = pcall(function()
        return game:HttpGet(KeyLink)
    end)
    if ok and resp and #resp > 0 then
        for line in string.gmatch(resp, "[^\r\n]+") do
            local k = trim(line)
            if #k > 0 then table.insert(ValidKeys, k) end
        end
    else
        warn("[ZiaanHub] Gagal ambil key dari System")
    end
end

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZiaanHub_KeyUI"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true

local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
tween(blur, 0.25, {Size = 14})

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 420, 0, 240)
Main.Position = UDim2.new(0.5, -210, 0.5, -120)
Main.BackgroundColor3 = Color3.fromRGB(14,28,48)
Main.BackgroundTransparency = 0.05
Main.BorderSizePixel = 0
makeCorner(Main, 14)
makeStroke(Main, Color3.fromRGB(120,180,255))

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(18,34,60)
Header.BorderSizePixel = 0
makeCorner(Header, 14)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "ZiaanHub Key System"
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(190,220,255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- CLOSE (X)
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(255,120,120)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30,50,80)
makeCorner(CloseBtn, 8)

-- Body
local Info = Instance.new("TextLabel", Main)
Info.Size = UDim2.new(1, -20, 0, 20)
Info.Position = UDim2.new(0, 10, 0, 55)
Info.Text = "Masukkan key :"
Info.TextColor3 = Color3.fromRGB(200,220,255)
Info.Font = Enum.Font.Gotham
Info.TextSize = 14
Info.BackgroundTransparency = 1
Info.TextXAlignment = Enum.TextXAlignment.Left

local KeyBox = Instance.new("TextBox", Main)
KeyBox.Size = UDim2.new(1, -40, 0, 40)
KeyBox.Position = UDim2.new(0, 20, 0, 90)
KeyBox.PlaceholderText = "Paste key di sini..."
KeyBox.Text = ""
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 16
KeyBox.TextColor3 = Color3.fromRGB(240,240,240)
KeyBox.BackgroundColor3 = Color3.fromRGB(20,40,70)
KeyBox.BorderSizePixel = 0
makeCorner(KeyBox, 10)

local VerifyBtn = Instance.new("TextButton", Main)
VerifyBtn.Size = UDim2.new(0.5, -30, 0, 38)
VerifyBtn.Position = UDim2.new(0.25, 15, 0, 150)
VerifyBtn.Text = "Verify Key"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 16
VerifyBtn.TextColor3 = Color3.fromRGB(255,255,255)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0,120,210)
makeCorner(VerifyBtn, 10)

-- TOAST
local function toast(msg, ok)
    local holder = Instance.new("TextLabel", ScreenGui)
    holder.Size = UDim2.new(0, 300, 0, 35)
    holder.Position = UDim2.new(0.5, -150, 1, 40)
    holder.BackgroundColor3 = Color3.fromRGB(14,32,60)
    holder.Text = msg
    holder.Font = Enum.Font.Gotham
    holder.TextSize = 14
    holder.TextColor3 = ok and Color3.fromRGB(80,255,140) or Color3.fromRGB(255,120,120)
    makeCorner(holder, 8)
    tween(holder, 0.25, {Position = UDim2.new(0.5, -150, 1, -60)})
    task.delay(2, function()
        tween(holder, 0.25, {Position = UDim2.new(0.5, -150, 1, 40)})
        task.wait(0.3) holder:Destroy()
    end)
end

-- DRAG
do
    local dragging, dragInput, startPos, dragStart
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInput.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- Confirm popup
local function confirmExit()
    local Pop = Instance.new("Frame", ScreenGui)
    Pop.Size = UDim2.new(0, 260, 0, 120)
    Pop.Position = UDim2.new(0.5, -130, 0.5, -60)
    Pop.BackgroundColor3 = Color3.fromRGB(18,34,60)
    Pop.BorderSizePixel = 0
    makeCorner(Pop, 12)

    local Txt = Instance.new("TextLabel", Pop)
    Txt.Size = UDim2.new(1, -20, 0, 40)
    Txt.Position = UDim2.new(0, 10, 0, 10)
    Txt.Text = "Apakah Anda Yakin Ingin Menghapus Menu Secara Permanen ?"
    Txt.Font = Enum.Font.GothamBold
    Txt.TextSize = 14
    Txt.TextColor3 = Color3.fromRGB(230,230,230)
    Txt.BackgroundTransparency = 1

    local Yes = Instance.new("TextButton", Pop)
    Yes.Size = UDim2.new(0.45, -10, 0, 30)
    Yes.Position = UDim2.new(0.05, 0, 1, -40)
    Yes.Text = "Ya"
    Yes.BackgroundColor3 = Color3.fromRGB(0,180,120)
    Yes.TextColor3 = Color3.fromRGB(255,255,255)
    makeCorner(Yes, 8)

    local No = Instance.new("TextButton", Pop)
    No.Size = UDim2.new(0.45, -10, 0, 30)
    No.Position = UDim2.new(0.5, 10, 1, -40)
    No.Text = "Tidak"
    No.BackgroundColor3 = Color3.fromRGB(200,60,60)
    No.TextColor3 = Color3.fromRGB(255,255,255)
    makeCorner(No, 8)

    Yes.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        blur:Destroy()
    end)

    No.MouseButton1Click:Connect(function()
        Pop:Destroy()
    end)
end

CloseBtn.MouseButton1Click:Connect(confirmExit)

-- Key check
local function isValidKey(k)
    k = trim(k or "")
    for _, v in ipairs(ValidKeys) do
        if k == v then return true end
    end
    return false
end

VerifyBtn.MouseButton1Click:Connect(function()
    local key = trim(KeyBox.Text)
    if key == "" then toast("Isi key dulu!", false) return end
    if isValidKey(key) then
        toast("Key valid. Loading menu...", true)
        task.wait(0.6)
        ScreenGui:Destroy()
        blur:Destroy()
        loadstring(game:HttpGet(MenuLoadURL))()
    else
        toast("Key salah!", false)
    end
end)
