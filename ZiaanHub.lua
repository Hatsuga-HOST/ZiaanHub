-- ZiaanHub Key System (Enhanced UI)
-- By ZiaanStore © 2025
-- Modern Dark Theme with Blue Accents

-- CONFIG
local KeyLink = "https://pastebin.com/raw/3vaUdQ30"
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
    return c
end

local function makeStroke(parent, col, thickness)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1.2
    s.Color = col or Color3.fromRGB(60, 140, 220)
    s.Transparency = 0.6
    s.Parent = parent
    return s
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
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Background blur effect
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
tween(blur, 0.5, {Size = 16})

-- Background overlay
local Overlay = Instance.new("Frame", ScreenGui)
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(5, 10, 18)
Overlay.BackgroundTransparency = 0.2
Overlay.BorderSizePixel = 0

-- Main container with shadow effect
local Shadow = Instance.new("Frame", ScreenGui)
Shadow.Size = UDim2.new(0, 450, 0, 320)
Shadow.Position = UDim2.new(0.5, -225, 0.5, -160)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.8
Shadow.BorderSizePixel = 0
makeCorner(Shadow, 16)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 450, 0, 320)
Main.Position = UDim2.new(0.5, -225, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(13, 17, 28)
Main.BorderSizePixel = 0
makeCorner(Main, 16)
makeStroke(Main, Color3.fromRGB(40, 90, 160), 2)

-- Animated background elements
local BgCircle1 = Instance.new("Frame", Main)
BgCircle1.Size = UDim2.new(0, 200, 0, 200)
BgCircle1.Position = UDim2.new(0.1, 0, 0.7, 0)
BgCircle1.BackgroundColor3 = Color3.fromRGB(25, 60, 120)
BgCircle1.BackgroundTransparency = 0.9
BgCircle1.BorderSizePixel = 0
makeCorner(BgCircle1, 100)

local BgCircle2 = Instance.new("Frame", Main)
BgCircle2.Size = UDim2.new(0, 150, 0, 150)
BgCircle2.Position = UDim2.new(0.7, 0, 0.1, 0)
BgCircle2.BackgroundColor3 = Color3.fromRGB(20, 80, 160)
BgCircle2.BackgroundTransparency = 0.9
BgCircle2.BorderSizePixel = 0
makeCorner(BgCircle2, 75)

-- Header with gradient
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(18, 25, 42)
Header.BorderSizePixel = 0
makeCorner(Header, 14)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 50, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "ZIAANHUB KEY SYSTEM"
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(220, 230, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Icon
local Icon = Instance.new("ImageLabel", Header)
Icon.Size = UDim2.new(0, 30, 0, 30)
Icon.Position = UDim2.new(0, 12, 0.5, -15)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://7072716642" -- Lock icon
Icon.ImageColor3 = Color3.fromRGB(100, 170, 255)

-- CLOSE (X)
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 75)
makeCorner(CloseBtn, 8)
makeStroke(CloseBtn, Color3.fromRGB(80, 120, 200))

-- Body content
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -40, 1, -90)
Content.Position = UDim2.new(0, 20, 0, 70)
Content.BackgroundTransparency = 1

-- Welcome text
local Welcome = Instance.new("TextLabel", Content)
Welcome.Size = UDim2.new(1, 0, 0, 30)
Welcome.Position = UDim2.new(0, 0, 0, 0)
Welcome.Text = "Welcome to ZiaanHub"
Welcome.TextColor3 = Color3.fromRGB(180, 200, 255)
Welcome.Font = Enum.Font.GothamSemibold
Welcome.TextSize = 20
Welcome.BackgroundTransparency = 1
Welcome.TextXAlignment = Enum.TextXAlignment.Left

-- Instructions
local Instructions = Instance.new("TextLabel", Content)
Instructions.Size = UDim2.new(1, 0, 0, 40)
Instructions.Position = UDim2.new(0, 0, 0, 30)
Instructions.Text = "Enter your key below to access the hub features. Contact us if you don't have a key."
Instructions.TextColor3 = Color3.fromRGB(140, 160, 200)
Instructions.Font = Enum.Font.Gotham
Instructions.TextSize = 14
Instructions.BackgroundTransparency = 1
Instructions.TextXAlignment = Enum.TextXAlignment.Left
Instructions.TextWrapped = true

-- Key input field
local KeyBoxFrame = Instance.new("Frame", Content)
KeyBoxFrame.Size = UDim2.new(1, 0, 0, 50)
KeyBoxFrame.Position = UDim2.new(0, 0, 0, 85)
KeyBoxFrame.BackgroundColor3 = Color3.fromRGB(22, 30, 48)
makeCorner(KeyBoxFrame, 8)
makeStroke(KeyBoxFrame, Color3.fromRGB(60, 110, 190))

local KeyBox = Instance.new("TextBox", KeyBoxFrame)
KeyBox.Size = UDim2.new(1, -20, 1, -10)
KeyBox.Position = UDim2.new(0, 10, 0, 5)
KeyBox.PlaceholderText = "Paste your key here..."
KeyBox.Text = ""
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 16
KeyBox.TextColor3 = Color3.fromRGB(220, 230, 255)
KeyBox.BackgroundTransparency = 1
KeyBox.ClearTextOnFocus = false

-- Verify button
local VerifyBtn = Instance.new("TextButton", Content)
VerifyBtn.Size = UDim2.new(1, 0, 0, 45)
VerifyBtn.Position = UDim2.new(0, 0, 1, -55)
VerifyBtn.Text = "VERIFY KEY"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 16
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(50, 110, 220)
makeCorner(VerifyBtn, 8)
makeStroke(VerifyBtn, Color3.fromRGB(100, 160, 255))

-- Footer text
local Footer = Instance.new("TextLabel", Main)
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.Text = "ZiaanStore © 2025 | v2.0.1"
Footer.TextColor3 = Color3.fromRGB(100, 130, 180)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 12
Footer.BackgroundTransparency = 1

-- Hover effects
local function setupHoverEffect(button, normalColor, hoverColor, normalStroke, hoverStroke)
    button.MouseEnter:Connect(function()
        tween(button, 0.2, {BackgroundColor3 = hoverColor})
        if hoverStroke then
            tween(button.UIStroke, 0.2, {Color = hoverStroke})
        end
    end)
    
    button.MouseLeave:Connect(function()
        tween(button, 0.2, {BackgroundColor3 = normalColor})
        if normalStroke then
            tween(button.UIStroke, 0.2, {Color = normalStroke})
        end
    end)
end

setupHoverEffect(VerifyBtn, Color3.fromRGB(50, 110, 220), Color3.fromRGB(70, 130, 240), 
                 Color3.fromRGB(100, 160, 255), Color3.fromRGB(120, 180, 255))
setupHoverEffect(CloseBtn, Color3.fromRGB(40, 50, 75), Color3.fromRGB(60, 70, 95),
                 Color3.fromRGB(80, 120, 200), Color3.fromRGB(100, 140, 220))

-- TOAST NOTIFICATION
local function toast(msg, ok)
    local holder = Instance.new("Frame", ScreenGui)
    holder.Size = UDim2.new(0, 300, 0, 40)
    holder.Position = UDim2.new(0.5, -150, 1, 40)
    holder.BackgroundColor3 = ok and Color3.fromRGB(20, 60, 30) or Color3.fromRGB(60, 30, 30)
    makeCorner(holder, 8)
    makeStroke(holder, ok and Color3.fromRGB(40, 160, 70) or Color3.fromRGB(180, 60, 60))
    
    local message = Instance.new("TextLabel", holder)
    message.Size = UDim2.new(1, 0, 1, 0)
    message.Text = msg
    message.Font = Enum.Font.GothamMedium
    message.TextSize = 14
    message.TextColor3 = ok and Color3.fromRGB(160, 255, 180) or Color3.fromRGB(255, 160, 160)
    message.BackgroundTransparency = 1
    
    local icon = Instance.new("ImageLabel", holder)
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 10, 0.5, -10)
    icon.BackgroundTransparency = 1
    icon.Image = ok and "rbxassetid://7072717770" or "rbxassetid://7072717852" -- Check/cross icons
    icon.ImageColor3 = message.TextColor3
    
    message.Position = UDim2.new(0, 35, 0, 0)
    message.Size = UDim2.new(1, -40, 1, 0)
    
    tween(holder, 0.3, {Position = UDim2.new(0.5, -150, 1, -60)})
    task.delay(2.5, function()
        tween(holder, 0.3, {Position = UDim2.new(0.5, -150, 1, 40)})
        task.wait(0.35)
        holder:Destroy()
    end)
end

-- DRAGGABLE UI
do
    local dragging, dragInput, startPos, dragStart
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            tween(Shadow, 0.1, {Position = startPos + UDim2.new(0, 3, 0, 3)})
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
            Shadow.Position = Main.Position + UDim2.new(0, 3, 0, 3)
        end
    end)
    
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            tween(Shadow, 0.2, {Position = Main.Position})
        end
    end)
end

-- CONFIRM EXIT POPUP
local function confirmExit()
    local PopupOverlay = Instance.new("Frame", ScreenGui)
    PopupOverlay.Size = UDim2.new(1, 0, 1, 0)
    PopupOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    PopupOverlay.BackgroundTransparency = 0.5
    PopupOverlay.ZIndex = 10
    
    local Popup = Instance.new("Frame", PopupOverlay)
    Popup.Size = UDim2.new(0, 300, 0, 160)
    Popup.Position = UDim2.new(0.5, -150, 0.5, -80)
    Popup.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
    Popup.ZIndex = 11
    makeCorner(Popup, 12)
    makeStroke(Popup, Color3.fromRGB(60, 110, 200), 2)
    
    local Title = Instance.new("TextLabel", Popup)
    Title.Size = UDim2.new(1, -20, 0, 40)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.Text = "Confirm Exit"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(220, 230, 255)
    Title.BackgroundTransparency = 1
    Title.ZIndex = 12
    
    local Message = Instance.new("TextLabel", Popup)
    Message.Size = UDim2.new(1, -20, 0, 50)
    Message.Position = UDim2.new(0, 10, 0, 40)
    Message.Text = "Are you sure you want to close the key system?"
    Message.Font = Enum.Font.Gotham
    Message.TextSize = 14
    Message.TextColor3 = Color3.fromRGB(170, 190, 220)
    Message.BackgroundTransparency = 1
    Message.TextWrapped = true
    Message.ZIndex = 12
    
    local ButtonContainer = Instance.new("Frame", Popup)
    ButtonContainer.Size = UDim2.new(1, -20, 0, 40)
    ButtonContainer.Position = UDim2.new(0, 10, 1, -50)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.ZIndex = 12
    
    local YesBtn = Instance.new("TextButton", ButtonContainer)
    YesBtn.Size = UDim2.new(0.45, 0, 1, 0)
    YesBtn.Position = UDim2.new(0, 0, 0, 0)
    YesBtn.Text = "YES"
    YesBtn.Font = Enum.Font.GothamBold
    YesBtn.TextSize = 14
    YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    YesBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    makeCorner(YesBtn, 6)
    makeStroke(YesBtn, Color3.fromRGB(240, 100, 100))
    YesBtn.ZIndex = 13
    
    local NoBtn = Instance.new("TextButton", ButtonContainer)
    NoBtn.Size = UDim2.new(0.45, 0, 1, 0)
    NoBtn.Position = UDim2.new(0.55, 0, 0, 0)
    NoBtn.Text = "NO"
    NoBtn.Font = Enum.Font.GothamBold
    NoBtn.TextSize = 14
    NoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    makeCorner(NoBtn, 6)
    makeStroke(NoBtn, Color3.fromRGB(100, 160, 255))
    NoBtn.ZIndex = 13
    
    setupHoverEffect(YesBtn, Color3.fromRGB(200, 60, 60), Color3.fromRGB(220, 80, 80),
                    Color3.fromRGB(240, 100, 100), Color3.fromRGB(255, 120, 120))
    setupHoverEffect(NoBtn, Color3.fromRGB(60, 120, 200), Color3.fromRGB(80, 140, 220),
                    Color3.fromRGB(100, 160, 255), Color3.fromRGB(120, 180, 255))
    
    YesBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        blur:Destroy()
    end)
    
    NoBtn.MouseButton1Click:Connect(function()
        PopupOverlay:Destroy()
    end)
end

CloseBtn.MouseButton1Click:Connect(confirmExit)

-- KEY VALIDATION
local function isValidKey(k)
    k = trim(k or "")
    for _, v in ipairs(ValidKeys) do
        if k == v then return true end
    end
    return false
end

-- VERIFY BUTTON FUNCTION
VerifyBtn.MouseButton1Click:Connect(function()
    local key = trim(KeyBox.Text)
    if key == "" then 
        toast("Please enter a key", false) 
        return 
    end
    
    -- Show loading state
    VerifyBtn.Text = "VERIFYING..."
    VerifyBtn.AutoButtonColor = false
    tween(VerifyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(80, 100, 160)})
    
    -- Simulate network delay
    task.wait(0.5)
    
    if isValidKey(key) then
        toast("Key verified successfully! Loading menu...", true)
        task.wait(1)
        ScreenGui:Destroy()
        blur:Destroy()
        loadstring(game:HttpGet(MenuLoadURL))()
    else
        toast("Invalid key. Please check and try again.", false)
        -- Reset button state
        VerifyBtn.Text = "VERIFY KEY"
        VerifyBtn.AutoButtonColor = true
        tween(VerifyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(50, 110, 220)})
    end
end)

-- Initial animation
Main.Position = UDim2.new(0.5, -225, 0.3, -160)
Shadow.Position = UDim2.new(0.5, -222, 0.3, -157)
Main.BackgroundTransparency = 1
Shadow.BackgroundTransparency = 1

tween(Main, 0.5, {Position = UDim2.new(0.5, -225, 0.5, -160), BackgroundTransparency = 0})
tween(Shadow, 0.5, {Position = UDim2.new(0.5, -222, 0.5, -157), BackgroundTransparency = 0.8})

-- Subtle background animation
spawn(function()
    while ScreenGui.Parent do
        tween(BgCircle1, 4, {Position = UDim2.new(0.1, 0, 0.65, 0)})
        tween(BgCircle2, 4, {Position = UDim2.new(0.65, 0, 0.1, 0)})
        task.wait(4)
        tween(BgCircle1, 4, {Position = UDim2.new(0.15, 0, 0.7, 0)})
        tween(BgCircle2, 4, {Position = UDim2.new(0.7, 0, 0.15, 0)})
        task.wait(4)
    end
end)
