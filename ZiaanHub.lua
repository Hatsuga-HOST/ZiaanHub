-- ZiaanHub Key System (Premium UI)
-- By ZiaanStore © 2025
-- Professional Dark Theme with Contained Animations

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
local RunService = game:GetService("RunService")

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

-- Background overlay with gradient
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

-- Create a clipping frame to contain the animated elements
local ClipFrame = Instance.new("Frame", Main)
ClipFrame.Size = UDim2.new(1, 0, 1, 0)
ClipFrame.BackgroundTransparency = 1
ClipFrame.ClipsDescendants = true

-- Animated background elements (contained within the frame)
local BgCircle1 = Instance.new("Frame", ClipFrame)
BgCircle1.Size = UDim2.new(0, 180, 0, 180)
BgCircle1.Position = UDim2.new(0.05, 0, 0.7, 0)
BgCircle1.BackgroundColor3 = Color3.fromRGB(25, 60, 120)
BgCircle1.BackgroundTransparency = 0.9
BgCircle1.BorderSizePixel = 0
makeCorner(BgCircle1, 90)

local BgCircle2 = Instance.new("Frame", ClipFrame)
BgCircle2.Size = UDim2.new(0, 130, 0, 130)
BgCircle2.Position = UDim2.new(0.75, 0, 0.05, 0)
BgCircle2.BackgroundColor3 = Color3.fromRGB(20, 80, 160)
BgCircle2.BackgroundTransparency = 0.9
BgCircle2.BorderSizePixel = 0
makeCorner(BgCircle2, 65)

-- Header with gradient
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(18, 25, 42)
Header.BorderSizePixel = 0
makeCorner(Header, 14)

-- Add gradient to header
local HeaderGradient = Instance.new("UIGradient", Header)
HeaderGradient.Rotation = 90
HeaderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 45, 75)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 25, 42))
}

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 50, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "ZIAANHUB KEY SYSTEM"
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(220, 230, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Icon with subtle glow
local Icon = Instance.new("ImageLabel", Header)
Icon.Size = UDim2.new(0, 30, 0, 30)
Icon.Position = UDim2.new(0, 12, 0.5, -15)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://7072716642" -- Lock icon
Icon.ImageColor3 = Color3.fromRGB(100, 170, 255)

-- Add glow effect to icon
local IconGlow = Instance.new("ImageLabel", Icon)
IconGlow.Size = UDim2.new(1.5, 0, 1.5, 0)
IconGlow.Position = UDim2.new(-0.25, 0, -0.25, 0)
IconGlow.Image = "rbxassetid://7072716642"
IconGlow.ImageColor3 = Color3.fromRGB(100, 170, 255)
IconGlow.BackgroundTransparency = 1
IconGlow.ImageTransparency = 0.8
IconGlow.ZIndex = -1

-- CLOSE (X) with improved design
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

-- Welcome text with subtle animation
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

-- Key input field with improved design
local KeyBoxFrame = Instance.new("Frame", Content)
KeyBoxFrame.Size = UDim2.new(1, 0, 0, 50)
KeyBoxFrame.Position = UDim2.new(0, 0, 0, 85)
KeyBoxFrame.BackgroundColor3 = Color3.fromRGB(22, 30, 48)
makeCorner(KeyBoxFrame, 8)
makeStroke(KeyBoxFrame, Color3.fromRGB(60, 110, 190))

-- Add gradient to input field
local InputGradient = Instance.new("UIGradient", KeyBoxFrame)
InputGradient.Rotation = 90
InputGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 40, 65)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 30, 48))
}

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

-- Verify button with improved design
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

-- Add gradient to verify button
local ButtonGradient = Instance.new("UIGradient", VerifyBtn)
ButtonGradient.Rotation = 90
ButtonGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 130, 240)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 110, 220))
}

-- Footer text
local Footer = Instance.new("TextLabel", Main)
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.Text = "ZiaanStore © 2025 | v2.0.1"
Footer.TextColor3 = Color3.fromRGB(100, 130, 180)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 12
Footer.BackgroundTransparency = 1

-- Hover effects with improved animation
local function setupHoverEffect(button, normalColor, hoverColor, normalStroke, hoverStroke)
    button.MouseEnter:Connect(function()
        tween(button, 0.2, {BackgroundColor3 = hoverColor, Position = button.Position - UDim2.new(0, 0, 0.01, 0)})
        if hoverStroke then
            tween(button.UIStroke, 0.2, {Color = hoverStroke, Thickness = 1.8})
        end
    end)
    
    button.MouseLeave:Connect(function()
        tween(button, 0.2, {BackgroundColor3 = normalColor, Position = button.Position + UDim2.new(0, 0, 0.01, 0)})
        if normalStroke then
            tween(button.UIStroke, 0.2, {Color = normalStroke, Thickness = 1.2})
        end
    end)
end

setupHoverEffect(VerifyBtn, Color3.fromRGB(50, 110, 220), Color3.fromRGB(70, 130, 240), 
                 Color3.fromRGB(100, 160, 255), Color3.fromRGB(120, 180, 255))
setupHoverEffect(CloseBtn, Color3.fromRGB(40, 50, 75), Color3.fromRGB(60, 70, 95),
                 Color3.fromRGB(80, 120, 200), Color3.fromRGB(100, 140, 220))

-- Input field hover effect
KeyBoxFrame.MouseEnter:Connect(function()
    tween(KeyBoxFrame.UIStroke, 0.2, {Color = Color3.fromRGB(80, 150, 220), Thickness = 1.8})
end)

KeyBoxFrame.MouseLeave:Connect(function()
    tween(KeyBoxFrame.UIStroke, 0.2, {Color = Color3.fromRGB(60, 110, 190), Thickness = 1.2})
end)

-- TOAST NOTIFICATION with improved design
local function toast(msg, ok)
    local holder = Instance.new("Frame", ScreenGui)
    holder.Size = UDim2.new(0, 320, 0, 45)
    holder.Position = UDim2.new(0.5, -160, 1, 40)
    holder.BackgroundColor3 = ok and Color3.fromRGB(20, 60, 30) or Color3.fromRGB(60, 30, 30)
    makeCorner(holder, 8)
    makeStroke(holder, ok and Color3.fromRGB(40, 160, 70) or Color3.fromRGB(180, 60, 60))
    
    -- Add gradient to toast
    local ToastGradient = Instance.new("UIGradient", holder)
    ToastGradient.Rotation = 90
    ToastGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ok and Color3.fromRGB(25, 70, 35) or Color3.fromRGB(70, 35, 35)),
        ColorSequenceKeypoint.new(1, ok and Color3.fromRGB(20, 60, 30) or Color3.fromRGB(60, 30, 30))
    }
    
    local message = Instance.new("TextLabel", holder)
    message.Size = UDim2.new(1, 0, 1, 0)
    message.Text = msg
    message.Font = Enum.Font.GothamMedium
    message.TextSize = 14
    message.TextColor3 = ok and Color3.fromRGB(160, 255, 180) or Color3.fromRGB(255, 160, 160)
    message.BackgroundTransparency = 1
    
    local icon = Instance.new("ImageLabel", holder)
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 15, 0.5, -10)
    icon.BackgroundTransparency = 1
    icon.Image = ok and "rbxassetid://7072717770" or "rbxassetid://7072717852" -- Check/cross icons
    icon.ImageColor3 = message.TextColor3
    
    message.Position = UDim2.new(0, 45, 0, 0)
    message.Size = UDim2.new(1, -55, 1, 0)
    
    tween(holder, 0.3, {Position = UDim2.new(0.5, -160, 1, -60)})
    task.delay(2.5, function()
        tween(holder, 0.3, {Position = UDim2.new(0.5, -160, 1, 40)})
        task.wait(0.35)
        holder:Destroy()
    end)
end

-- DRAGGABLE UI with improved shadow effect
do
    local dragging, dragInput, startPos, dragStart
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            tween(Shadow, 0.1, {Position = startPos + UDim2.new(0, 4, 0, 4), BackgroundTransparency = 0.7})
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
            Shadow.Position = Main.Position + UDim2.new(0, 4, 0, 4)
        end
    end)
    
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            tween(Shadow, 0.2, {Position = Main.Position, BackgroundTransparency = 0.8})
        end
    end)
end

-- CONFIRM EXIT POPUP with improved design
local function confirmExit()
    local PopupOverlay = Instance.new("Frame", ScreenGui)
    PopupOverlay.Size = UDim2.new(1, 0, 1, 0)
    PopupOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    PopupOverlay.BackgroundTransparency = 0.5
    PopupOverlay.ZIndex = 10
    
    local PopupShadow = Instance.new("Frame", PopupOverlay)
    PopupShadow.Size = UDim2.new(0, 320, 0, 180)
    PopupShadow.Position = UDim2.new(0.5, -160, 0.5, -90)
    PopupShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    PopupShadow.BackgroundTransparency = 0.8
    PopupShadow.BorderSizePixel = 0
    PopupShadow.ZIndex = 11
    makeCorner(PopupShadow, 12)
    
    local Popup = Instance.new("Frame", PopupOverlay)
    Popup.Size = UDim2.new(0, 320, 0, 180)
    Popup.Position = UDim2.new(0.5, -160, 0.5, -90)
    Popup.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
    Popup.ZIndex = 12
    makeCorner(Popup, 12)
    makeStroke(Popup, Color3.fromRGB(60, 110, 200), 2)
    
    -- Add gradient to popup
    local PopupGradient = Instance.new("UIGradient", Popup)
    PopupGradient.Rotation = 90
    PopupGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 35, 55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 25, 40))
    }
    
    local Title = Instance.new("TextLabel", Popup)
    Title.Size = UDim2.new(1, -20, 0, 40)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.Text = "Confirm Exit"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(220, 230, 255)
    Title.BackgroundTransparency = 1
    Title.ZIndex = 13
    
    local Message = Instance.new("TextLabel", Popup)
    Message.Size = UDim2.new(1, -20, 0, 60)
    Message.Position = UDim2.new(0, 10, 0, 40)
    Message.Text = "Are you sure you want to close the key system?"
    Message.Font = Enum.Font.Gotham
    Message.TextSize = 14
    Message.TextColor3 = Color3.fromRGB(170, 190, 220)
    Message.BackgroundTransparency = 1
    Message.TextWrapped = true
    Message.ZIndex = 13
    
    local ButtonContainer = Instance.new("Frame", Popup)
    ButtonContainer.Size = UDim2.new(1, -20, 0, 40)
    ButtonContainer.Position = UDim2.new(0, 10, 1, -50)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.ZIndex = 13
    
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
    YesBtn.ZIndex = 14
    
    -- Add gradient to yes button
    local YesGradient = Instance.new("UIGradient", YesBtn)
    YesGradient.Rotation = 90
    YesGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 80, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 60, 60))
    }
    
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
    NoBtn.ZIndex = 14
    
    -- Add gradient to no button
    local NoGradient = Instance.new("UIGradient", NoBtn)
    NoGradient.Rotation = 90
    NoGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 140, 220)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 120, 200))
    }
    
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

-- VERIFY BUTTON FUNCTION with improved loading animation
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
    
    -- Create loading animation
    local loadingCircle = Instance.new("Frame", VerifyBtn)
    loadingCircle.Size = UDim2.new(0, 20, 0, 20)
    loadingCircle.Position = UDim2.new(0.5, -10, 0.5, -10)
    loadingCircle.BackgroundTransparency = 1
    loadingCircle.BorderSizePixel = 0
    makeCorner(loadingCircle, 10)
    
    local loadingStroke = Instance.new("UIStroke", loadingCircle)
    loadingStroke.Thickness = 2
    loadingStroke.Color = Color3.fromRGB(200, 220, 255)
    loadingStroke.Transparency = 0.3
    
    local rotation = 0
    local connection
    connection = RunService.RenderStepped:Connect(function(delta)
        rotation = (rotation + delta * 360) % 360
        loadingStroke.Rotation = rotation
    end)
    
    -- Simulate network delay
    task.wait(0.5)
    
    if isValidKey(key) then
        connection:Disconnect()
        loadingCircle:Destroy()
        toast("Key verified successfully! Loading menu...", true)
        task.wait(1)
        ScreenGui:Destroy()
        blur:Destroy()
        loadstring(game:HttpGet(MenuLoadURL))()
    else
        connection:Disconnect()
        loadingCircle:Destroy()
        toast("Invalid key. Please check and try again.", false)
        -- Reset button state
        VerifyBtn.Text = "VERIFY KEY"
        VerifyBtn.AutoButtonColor = true
        tween(VerifyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(50, 110, 220)})
    end
end)

-- Initial animation with improved entrance
Main.Position = UDim2.new(0.5, -225, 0.3, -160)
Shadow.Position = UDim2.new(0.5, -222, 0.3, -157)
Main.BackgroundTransparency = 1
Shadow.BackgroundTransparency = 1

tween(Main, 0.5, {Position = UDim2.new(0.5, -225, 0.5, -160), BackgroundTransparency = 0})
tween(Shadow, 0.5, {Position = UDim2.new(0.5, -222, 0.5, -157), BackgroundTransparency = 0.8})

-- Subtle background animation (contained within frame)
spawn(function()
    while ScreenGui.Parent do
        tween(BgCircle1, 5, {Position = UDim2.new(0.05, 0, 0.65, 0)})
        tween(BgCircle2, 5, {Position = UDim2.new(0.7, 0, 0.1, 0)})
        task.wait(5)
        tween(BgCircle1, 5, {Position = UDim2.new(0.1, 0, 0.7, 0)})
        tween(BgCircle2, 5, {Position = UDim2.new(0.75, 0, 0.05, 0)})
        task.wait(5)
    end
end)

-- Add subtle pulse effect to icon
spawn(function()
    while ScreenGui.Parent do
        tween(IconGlow, 1.5, {ImageTransparency = 0.9})
        task.wait(1.5)
        tween(IconGlow, 1.5, {ImageTransparency = 0.7})
        task.wait(1.5)
    end
end)
