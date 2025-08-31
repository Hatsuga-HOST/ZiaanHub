-- ZiaanHub Key System (Professional Light UI)
-- By ZiaanStore © 2025
-- Clean, Professional Light Theme

-- CONFIG
local KeyLink = "https://pastebin.com/raw/3vaUdQ30"
local MenuLoadURL = "https://raw.githubusercontent.com/MajestySkie/list/refs/heads/main/games"

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInput = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- HELPERS
local function tween(obj, time, props)
    TweenService:Create(obj, TweenInfo.new(time or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function makeStroke(parent, col, thickness)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1
    s.Color = col or Color3.fromRGB(220, 220, 220)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
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
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main container with clean white background
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 480, 0, 360)
Main.Position = UDim2.new(0.5, -240, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Main.BorderSizePixel = 0
makeCorner(Main, 10)
makeStroke(Main, Color3.fromRGB(230, 230, 230))

-- Header with accent color
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(47, 128, 237)
Header.BorderSizePixel = 0
makeCorner(Header, 10, 10, 0, 0)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 60, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "ZIAANHUB KEY SYSTEM"
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Icon
local Icon = Instance.new("ImageLabel", Header)
Icon.Size = UDim2.new(0, 30, 0, 30)
Icon.Position = UDim2.new(0, 15, 0.5, -15)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://7072716642" -- Lock icon
Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)

-- Close button
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(47, 128, 237)
CloseBtn.AutoButtonColor = false
makeCorner(CloseBtn, 15)

-- Body content
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -40, 1, -100)
Content.Position = UDim2.new(0, 20, 0, 70)
Content.BackgroundTransparency = 1

-- Welcome text
local Welcome = Instance.new("TextLabel", Content)
Welcome.Size = UDim2.new(1, 0, 0, 36)
Welcome.Position = UDim2.new(0, 0, 0, 0)
Welcome.Text = "Welcome to ZiaanHub"
Welcome.TextColor3 = Color3.fromRGB(60, 60, 60)
Welcome.Font = Enum.Font.GothamSemibold
Welcome.TextSize = 20
Welcome.BackgroundTransparency = 1
Welcome.TextXAlignment = Enum.TextXAlignment.Left

-- Instructions
local Instructions = Instance.new("TextLabel", Content)
Instructions.Size = UDim2.new(1, 0, 0, 45)
Instructions.Position = UDim2.new(0, 0, 0, 36)
Instructions.Text = "Enter your key below to access premium features. Contact support if you need assistance."
Instructions.TextColor3 = Color3.fromRGB(120, 120, 120)
Instructions.Font = Enum.Font.Gotham
Instructions.TextSize = 14
Instructions.BackgroundTransparency = 1
Instructions.TextXAlignment = Enum.TextXAlignment.Left
Instructions.TextWrapped = true

-- Key input field
local KeyBoxFrame = Instance.new("Frame", Content)
KeyBoxFrame.Size = UDim2.new(1, 0, 0, 45)
KeyBoxFrame.Position = UDim2.new(0, 0, 0, 95)
KeyBoxFrame.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
makeCorner(KeyBoxFrame, 6)
makeStroke(KeyBoxFrame, Color3.fromRGB(220, 220, 220))

local KeyBox = Instance.new("TextBox", KeyBoxFrame)
KeyBox.Size = UDim2.new(1, -20, 1, -10)
KeyBox.Position = UDim2.new(0, 10, 0, 5)
KeyBox.PlaceholderText = "Enter your access key..."
KeyBox.Text = ""
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 16
KeyBox.TextColor3 = Color3.fromRGB(60, 60, 60)
KeyBox.BackgroundTransparency = 1
KeyBox.ClearTextOnFocus = false
KeyBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)

-- Verify button
local VerifyBtn = Instance.new("TextButton", Content)
VerifyBtn.Size = UDim2.new(1, 0, 0, 45)
VerifyBtn.Position = UDim2.new(0, 0, 1, -55)
VerifyBtn.Text = "VERIFY KEY"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 16
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(47, 128, 237)
makeCorner(VerifyBtn, 6)

-- Footer text
local Footer = Instance.new("TextLabel", Main)
Footer.Size = UDim2.new(1, 0, 0, 24)
Footer.Position = UDim2.new(0, 0, 1, -30)
Footer.Text = "ZiaanStore © 2025 | Premium Edition"
Footer.TextColor3 = Color3.fromRGB(150, 150, 150)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 12
Footer.BackgroundTransparency = 1

-- Hover effects
local function setupHoverEffect(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        tween(button, 0.2, {BackgroundColor3 = hoverColor})
    end)
    
    button.MouseLeave:Connect(function()
        tween(button, 0.2, {BackgroundColor3 = normalColor})
    end)
end

setupHoverEffect(VerifyBtn, Color3.fromRGB(47, 128, 237), Color3.fromRGB(65, 145, 255))
setupHoverEffect(CloseBtn, Color3.fromRGB(47, 128, 237), Color3.fromRGB(220, 80, 80))

-- Input field hover effect
KeyBoxFrame.MouseEnter:Connect(function()
    tween(KeyBoxFrame, 0.2, {BackgroundColor3 = Color3.fromRGB(245, 245, 245)})
end)

KeyBoxFrame.MouseLeave:Connect(function()
    tween(KeyBoxFrame, 0.2, {BackgroundColor3 = Color3.fromRGB(250, 250, 250)})
end)

-- TOAST NOTIFICATION
local function toast(msg, ok)
    local holder = Instance.new("Frame", ScreenGui)
    holder.Size = UDim2.new(0, 300, 0, 40)
    holder.Position = UDim2.new(0.5, -150, 1, 40)
    holder.BackgroundColor3 = ok and Color3.fromRGB(56, 168, 82) or Color3.fromRGB(220, 80, 80)
    makeCorner(holder, 6)
    
    local message = Instance.new("TextLabel", holder)
    message.Size = UDim2.new(1, 0, 1, 0)
    message.Text = msg
    message.Font = Enum.Font.GothamMedium
    message.TextSize = 14
    message.TextColor3 = Color3.fromRGB(255, 255, 255)
    message.BackgroundTransparency = 1
    
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- CONFIRM EXIT POPUP
local function confirmExit()
    local PopupOverlay = Instance.new("Frame", ScreenGui)
    PopupOverlay.Size = UDim2.new(1, 0, 1, 0)
    PopupOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    PopupOverlay.BackgroundTransparency = 0.4
    PopupOverlay.ZIndex = 10
    
    local Popup = Instance.new("Frame", PopupOverlay)
    Popup.Size = UDim2.new(0, 300, 0, 160)
    Popup.Position = UDim2.new(0.5, -150, 0.5, -80)
    Popup.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Popup.ZIndex = 11
    makeCorner(Popup, 8)
    makeStroke(Popup, Color3.fromRGB(220, 220, 220))
    
    local Title = Instance.new("TextLabel", Popup)
    Title.Size = UDim2.new(1, -20, 0, 40)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.Text = "Confirm Exit"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(60, 60, 60)
    Title.BackgroundTransparency = 1
    Title.ZIndex = 12
    
    local Message = Instance.new("TextLabel", Popup)
    Message.Size = UDim2.new(1, -20, 0, 50)
    Message.Position = UDim2.new(0, 10, 0, 50)
    Message.Text = "Are you sure you want to close the key system?"
    Message.Font = Enum.Font.Gotham
    Message.TextSize = 14
    Message.TextColor3 = Color3.fromRGB(120, 120, 120)
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
    YesBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    makeCorner(YesBtn, 6)
    YesBtn.ZIndex = 13
    
    local NoBtn = Instance.new("TextButton", ButtonContainer)
    NoBtn.Size = UDim2.new(0.45, 0, 1, 0)
    NoBtn.Position = UDim2.new(0.55, 0, 0, 0)
    NoBtn.Text = "NO"
    NoBtn.Font = Enum.Font.GothamBold
    NoBtn.TextSize = 14
    NoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    makeCorner(NoBtn, 6)
    NoBtn.ZIndex = 13
    
    setupHoverEffect(YesBtn, Color3.fromRGB(220, 80, 80), Color3.fromRGB(200, 60, 60))
    setupHoverEffect(NoBtn, Color3.fromRGB(100, 100, 100), Color3.fromRGB(80, 80, 80))
    
    YesBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
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
    tween(VerifyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
    
    -- Simulate network delay
    task.wait(0.5)
    
    if isValidKey(key) then
        toast("Key verified successfully! Loading menu...", true)
        task.wait(1)
        ScreenGui:Destroy()
        loadstring(game:HttpGet(MenuLoadURL))()
    else
        toast("Invalid key. Please check and try again.", false)
        -- Reset button state
        VerifyBtn.Text = "VERIFY KEY"
        VerifyBtn.AutoButtonColor = true
        tween(VerifyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(47, 128, 237)})
    end
end)

-- Initial animation
Main.Position = UDim2.new(0.5, -240, 0.4, -180)
Main.BackgroundTransparency = 1

tween(Main, 0.5, {Position = UDim2.new(0.5, -240, 0.5, -180), BackgroundTransparency = 0})

-- Add keyboard shortcut for verification
UserInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Return and KeyBox:IsFocused() then
        VerifyBtn.MouseButton1Click:Fire()
    end
end)
