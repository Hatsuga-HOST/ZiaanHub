-- ZiaanHub Key System (Premium Glass UI)
-- By ZiaanStore © 2025
-- Enhanced Glassmorphism Theme with Advanced Animations

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
local HttpService = game:GetService("HttpService")

-- HELPERS
local function tween(obj, time, props, easingStyle, easingDirection)
    TweenService:Create(obj, TweenInfo.new(time or 0.25, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out), props):Play()
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function makeStroke(parent, col, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1.2
    s.Color = col or Color3.fromRGB(60, 140, 220)
    s.Transparency = transparency or 0.6
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
ScreenGui.Name = "ZiaanHub_KeyUI_" .. HttpService:GenerateGUID(false)
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Background blur effect
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
tween(blur, 0.5, {Size = 20})

-- Background overlay with gradient
local Overlay = Instance.new("Frame", ScreenGui)
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(8, 15, 28)
Overlay.BackgroundTransparency = 0.1
Overlay.BorderSizePixel = 0

-- Create animated particles in background
local function createParticle(parent, size, position, color, duration)
    local particle = Instance.new("Frame", parent)
    particle.Size = UDim2.new(0, size, 0, size)
    particle.Position = position
    particle.BackgroundColor3 = color
    particle.BackgroundTransparency = 0.8
    particle.BorderSizePixel = 0
    particle.ZIndex = 0
    makeCorner(particle, size/2)
    
    spawn(function()
        local startPos = particle.Position
        local targetPos = UDim2.new(
            math.random(), math.random(-50, 50),
            math.random(), math.random(-50, 50)
        )
        
        tween(particle, duration, {Position = targetPos, BackgroundTransparency = 1})
        task.wait(duration)
        particle:Destroy()
    end)
    
    return particle
end

-- Create particle system
spawn(function()
    while ScreenGui.Parent do
        createParticle(
            ScreenGui, 
            math.random(5, 15), 
            UDim2.new(math.random(), 0, math.random(), 0),
            Color3.fromRGB(70, 130, 230),
            math.random(3, 7)
        )
        task.wait(0.2)
    end
end)

-- Main container with glassmorphism effect
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 420)
Main.Position = UDim2.new(0.5, -250, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
Main.BackgroundTransparency = 0.2
Main.BorderSizePixel = 0
Main.ZIndex = 2
makeCorner(Main, 16)
makeStroke(Main, Color3.fromRGB(100, 150, 220), 1.5, 0.4)

-- Add glassmorphism effect
local GlassFrame = Instance.new("Frame", Main)
GlassFrame.Size = UDim2.new(1, 0, 1, 0)
GlassFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GlassFrame.BackgroundTransparency = 0.95
GlassFrame.BorderSizePixel = 0
GlassFrame.ZIndex = 2
makeCorner(GlassFrame, 16)

-- Create a clipping frame to contain the animated elements
local ClipFrame = Instance.new("Frame", Main)
ClipFrame.Size = UDim2.new(1, 0, 1, 0)
ClipFrame.BackgroundTransparency = 1
ClipFrame.ClipsDescendants = true
ClipFrame.ZIndex = 1

-- Animated background elements (contained within the frame)
local BgCircle1 = Instance.new("Frame", ClipFrame)
BgCircle1.Size = UDim2.new(0, 200, 0, 200)
BgCircle1.Position = UDim2.new(0.05, 0, 0.7, 0)
BgCircle1.BackgroundColor3 = Color3.fromRGB(40, 80, 160)
BgCircle1.BackgroundTransparency = 0.9
BgCircle1.BorderSizePixel = 0
BgCircle1.ZIndex = 1
makeCorner(BgCircle1, 100)

local BgCircle2 = Instance.new("Frame", ClipFrame)
BgCircle2.Size = UDim2.new(0, 150, 0, 150)
BgCircle2.Position = UDim2.new(0.75, 0, 0.05, 0)
BgCircle2.BackgroundColor3 = Color3.fromRGB(30, 100, 200)
BgCircle2.BackgroundTransparency = 0.9
BgCircle2.BorderSizePixel = 0
BgCircle2.ZIndex = 1
makeCorner(BgCircle2, 75)

-- Header with gradient
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 70)
Header.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
Header.BorderSizePixel = 0
Header.ZIndex = 3
makeCorner(Header, 14)

-- Add gradient to header
local HeaderGradient = Instance.new("UIGradient", Header)
HeaderGradient.Rotation = 90
HeaderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 55, 95)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 35, 60))
}

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 60, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "ZIAANHUB PREMIUM ACCESS"
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(230, 240, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3

-- Icon with subtle glow
local Icon = Instance.new("ImageLabel", Header)
Icon.Size = UDim2.new(0, 40, 0, 40)
Icon.Position = UDim2.new(0, 15, 0.5, -20)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://7072716642" -- Lock icon
Icon.ImageColor3 = Color3.fromRGB(120, 190, 255)
Icon.ZIndex = 3

-- Add glow effect to icon
local IconGlow = Instance.new("ImageLabel", Icon)
IconGlow.Size = UDim2.new(1.8, 0, 1.8, 0)
IconGlow.Position = UDim2.new(-0.4, 0, -0.4, 0)
IconGlow.Image = "rbxassetid://7072716642"
IconGlow.ImageColor3 = Color3.fromRGB(120, 190, 255)
IconGlow.BackgroundTransparency = 1
IconGlow.ImageTransparency = 0.8
IconGlow.ZIndex = 2

-- CLOSE (X) with improved design
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -16)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 22
CloseBtn.TextColor3 = Color3.fromRGB(220, 220, 240)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 65, 100)
CloseBtn.ZIndex = 3
makeCorner(CloseBtn, 8)
makeStroke(CloseBtn, Color3.fromRGB(100, 150, 220))

-- Body content
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -40, 1, -100)
Content.Position = UDim2.new(0, 20, 0, 80)
Content.BackgroundTransparency = 1
Content.ZIndex = 3

-- Welcome text with subtle animation
local Welcome = Instance.new("TextLabel", Content)
Welcome.Size = UDim2.new(1, 0, 0, 36)
Welcome.Position = UDim2.new(0, 0, 0, 0)
Welcome.Text = "Welcome to ZiaanHub Premium"
Welcome.TextColor3 = Color3.fromRGB(200, 220, 255)
Welcome.Font = Enum.Font.GothamSemibold
Welcome.TextSize = 22
Welcome.BackgroundTransparency = 1
Welcome.TextXAlignment = Enum.TextXAlignment.Left
Welcome.ZIndex = 3

-- Instructions
local Instructions = Instance.new("TextLabel", Content)
Instructions.Size = UDim2.new(1, 0, 0, 45)
Instructions.Position = UDim2.new(0, 0, 0, 36)
Instructions.Text = "Enter your premium key below to access exclusive features. Contact support if you need assistance."
Instructions.TextColor3 = Color3.fromRGB(160, 180, 220)
Instructions.Font = Enum.Font.Gotham
Instructions.TextSize = 15
Instructions.BackgroundTransparency = 1
Instructions.TextXAlignment = Enum.TextXAlignment.Left
Instructions.TextWrapped = true
Instructions.ZIndex = 3

-- Key input field with improved design
local KeyBoxFrame = Instance.new("Frame", Content)
KeyBoxFrame.Size = UDim2.new(1, 0, 0, 55)
KeyBoxFrame.Position = UDim2.new(0, 0, 0, 95)
KeyBoxFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 65)
KeyBoxFrame.ZIndex = 3
makeCorner(KeyBoxFrame, 10)
makeStroke(KeyBoxFrame, Color3.fromRGB(80, 140, 220))

-- Add gradient to input field
local InputGradient = Instance.new("UIGradient", KeyBoxFrame)
InputGradient.Rotation = 90
InputGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 50, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 40, 65))
}

local KeyBox = Instance.new("TextBox", KeyBoxFrame)
KeyBox.Size = UDim2.new(1, -20, 1, -10)
KeyBox.Position = UDim2.new(0, 10, 0, 5)
KeyBox.PlaceholderText = "Enter your premium access key..."
KeyBox.Text = ""
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 17
KeyBox.TextColor3 = Color3.fromRGB(230, 240, 255)
KeyBox.BackgroundTransparency = 1
KeyBox.ClearTextOnFocus = false
KeyBox.PlaceholderColor3 = Color3.fromRGB(140, 160, 200)
KeyBox.ZIndex = 3

-- Show/Hide Key Button
local ShowKeyBtn = Instance.new("TextButton", KeyBoxFrame)
ShowKeyBtn.Size = UDim2.new(0, 30, 0, 30)
ShowKeyBtn.Position = UDim2.new(1, -35, 0.5, -15)
ShowKeyBtn.Text = ""
ShowKeyBtn.BackgroundTransparency = 1
ShowKeyBtn.ZIndex = 3

local EyeIcon = Instance.new("ImageLabel", ShowKeyBtn)
EyeIcon.Size = UDim2.new(1, 0, 1, 0)
EyeIcon.Image = "rbxassetid://7072717000" -- Eye icon
EyeIcon.ImageColor3 = Color3.fromRGB(140, 160, 200)
EyeIcon.BackgroundTransparency = 1

local keyVisible = false
ShowKeyBtn.MouseButton1Click:Connect(function()
    keyVisible = not keyVisible
    if keyVisible then
        KeyBox.TextTransparency = 0
        EyeIcon.ImageColor3 = Color3.fromRGB(100, 180, 255)
    else
        KeyBox.TextTransparency = 0.5
        EyeIcon.ImageColor3 = Color3.fromRGB(140, 160, 200)
    end
end)

-- Verify button with improved design
local VerifyBtn = Instance.new("TextButton", Content)
VerifyBtn.Size = UDim2.new(1, 0, 0, 50)
VerifyBtn.Position = UDim2.new(0, 0, 1, -60)
VerifyBtn.Text = "VERIFY KEY"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 18
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(60, 130, 240)
VerifyBtn.ZIndex = 3
makeCorner(VerifyBtn, 10)
makeStroke(VerifyBtn, Color3.fromRGB(120, 180, 255))

-- Add gradient to verify button
local ButtonGradient = Instance.new("UIGradient", VerifyBtn)
ButtonGradient.Rotation = 90
ButtonGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 130, 240))
}

-- Status indicator
local StatusIndicator = Instance.new("Frame", Content)
StatusIndicator.Size = UDim2.new(1, 0, 0, 6)
StatusIndicator.Position = UDim2.new(0, 0, 1, -70)
StatusIndicator.BackgroundColor3 = Color3.fromRGB(60, 130, 240)
StatusIndicator.ZIndex = 3
makeCorner(StatusIndicator, 3)

-- Footer text
local Footer = Instance.new("TextLabel", Main)
Footer.Size = UDim2.new(1, 0, 0, 24)
Footer.Position = UDim2.new(0, 0, 1, -30)
Footer.Text = "ZiaanStore © 2025 | Premium Edition v2.1"
Footer.TextColor3 = Color3.fromRGB(120, 150, 200)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 13
Footer.BackgroundTransparency = 1
Footer.ZIndex = 3

-- Hover effects with improved animation
local function setupHoverEffect(button, normalColor, hoverColor, normalStroke, hoverStroke)
    button.MouseEnter:Connect(function()
        tween(button, 0.2, {
            BackgroundColor3 = hoverColor, 
            Position = button.Position - UDim2.new(0, 0, 0.01, 0),
            Size = button.Size + UDim2.new(0, 0, 0.01, 0)
        })
        if hoverStroke then
            tween(button.UIStroke, 0.2, {Color = hoverStroke, Thickness = 2})
        end
    end)
    
    button.MouseLeave:Connect(function()
        tween(button, 0.2, {
            BackgroundColor3 = normalColor, 
            Position = button.Position + UDim2.new(0, 0, 0.01, 0),
            Size = button.Size - UDim2.new(0, 0, 0.01, 0)
        })
        if normalStroke then
            tween(button.UIStroke, 0.2, {Color = normalStroke, Thickness = 1.2})
        end
    end)
end

setupHoverEffect(VerifyBtn, Color3.fromRGB(60, 130, 240), Color3.fromRGB(80, 150, 255), 
                 Color3.fromRGB(120, 180, 255), Color3.fromRGB(140, 200, 255))
setupHoverEffect(CloseBtn, Color3.fromRGB(50, 65, 100), Color3.fromRGB(70, 85, 120),
                 Color3.fromRGB(100, 150, 220), Color3.fromRGB(120, 170, 240))

-- Input field hover effect
KeyBoxFrame.MouseEnter:Connect(function()
    tween(KeyBoxFrame.UIStroke, 0.2, {Color = Color3.fromRGB(100, 170, 240), Thickness = 2})
    tween(KeyBoxFrame, 0.2, {Position = KeyBoxFrame.Position - UDim2.new(0, 0, 0.005, 0)})
end)

KeyBoxFrame.MouseLeave:Connect(function()
    tween(KeyBoxFrame.UIStroke, 0.2, {Color = Color3.fromRGB(80, 140, 220), Thickness = 1.2})
    tween(KeyBoxFrame, 0.2, {Position = KeyBoxFrame.Position + UDim2.new(0, 0, 0.005, 0)})
end)

-- TOAST NOTIFICATION with improved design
local function toast(msg, ok)
    local holder = Instance.new("Frame", ScreenGui)
    holder.Size = UDim2.new(0, 350, 0, 50)
    holder.Position = UDim2.new(0.5, -175, 1, 40)
    holder.BackgroundColor3 = ok and Color3.fromRGB(25, 70, 40) or Color3.fromRGB(70, 35, 40)
    holder.ZIndex = 10
    makeCorner(holder, 10)
    makeStroke(holder, ok and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(200, 70, 70), 2, 0.3)
    
    -- Add gradient to toast
    local ToastGradient = Instance.new("UIGradient", holder)
    ToastGradient.Rotation = 90
    ToastGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ok and Color3.fromRGB(30, 85, 50) or Color3.fromRGB(85, 40, 45)),
        ColorSequenceKeypoint.new(1, ok and Color3.fromRGB(25, 70, 40) or Color3.fromRGB(70, 35, 40))
    }
    
    local message = Instance.new("TextLabel", holder)
    message.Size = UDim2.new(1, 0, 1, 0)
    message.Text = msg
    message.Font = Enum.Font.GothamMedium
    message.TextSize = 15
    message.TextColor3 = ok and Color3.fromRGB(180, 255, 200) or Color3.fromRGB(255, 180, 180)
    message.BackgroundTransparency = 1
    message.ZIndex = 10
    
    local icon = Instance.new("ImageLabel", holder)
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 15, 0.5, -12)
    icon.BackgroundTransparency = 1
    icon.Image = ok and "rbxassetid://7072717770" or "rbxassetid://7072717852" -- Check/cross icons
    icon.ImageColor3 = message.TextColor3
    icon.ZIndex = 10
    
    message.Position = UDim2.new(0, 50, 0, 0)
    message.Size = UDim2.new(1, -60, 1, 0)
    
    tween(holder, 0.3, {Position = UDim2.new(0.5, -175, 1, -70)})
    task.delay(2.5, function()
        tween(holder, 0.3, {Position = UDim2.new(0.5, -175, 1, 40)})
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
            
            -- Add slight scale effect when dragging
            tween(Main, 0.1, {Size = UDim2.new(0, 495, 0, 415)})
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
            tween(Main, 0.1, {Size = UDim2.new(0, 500, 0, 420)})
        end
    end)
end

-- CONFIRM EXIT POPUP with improved design
local function confirmExit()
    local PopupOverlay = Instance.new("Frame", ScreenGui)
    PopupOverlay.Size = UDim2.new(1, 0, 1, 0)
    PopupOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    PopupOverlay.BackgroundTransparency = 0.6
    PopupOverlay.ZIndex = 10
    
    local Popup = Instance.new("Frame", PopupOverlay)
    Popup.Size = UDim2.new(0, 340, 0, 200)
    Popup.Position = UDim2.new(0.5, -170, 0.5, -100)
    Popup.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
    Popup.BackgroundTransparency = 0.1
    Popup.ZIndex = 11
    makeCorner(Popup, 14)
    makeStroke(Popup, Color3.fromRGB(80, 140, 220), 2, 0.4)
    
    -- Add glass effect to popup
    local PopupGlass = Instance.new("Frame", Popup)
    PopupGlass.Size = UDim2.new(1, 0, 1, 0)
    PopupGlass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PopupGlass.BackgroundTransparency = 0.95
    PopupGlass.BorderSizePixel = 0
    PopupGlass.ZIndex = 12
    makeCorner(PopupGlass, 14)
    
    local Title = Instance.new("TextLabel", Popup)
    Title.Size = UDim2.new(1, -20, 0, 50)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.Text = "Confirm Exit"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextColor3 = Color3.fromRGB(230, 240, 255)
    Title.BackgroundTransparency = 1
    Title.ZIndex = 13
    
    local Message = Instance.new("TextLabel", Popup)
    Message.Size = UDim2.new(1, -20, 0, 70)
    Message.Position = UDim2.new(0, 10, 0, 50)
    Message.Text = "Are you sure you want to close the key system?"
    Message.Font = Enum.Font.Gotham
    Message.TextSize = 15
    Message.TextColor3 = Color3.fromRGB(180, 200, 230)
    Message.BackgroundTransparency = 1
    Message.TextWrapped = true
    Message.ZIndex = 13
    
    local ButtonContainer = Instance.new("Frame", Popup)
    ButtonContainer.Size = UDim2.new(1, -20, 0, 50)
    ButtonContainer.Position = UDim2.new(0, 10, 1, -60)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.ZIndex = 13
    
    local YesBtn = Instance.new("TextButton", ButtonContainer)
    YesBtn.Size = UDim2.new(0.45, 0, 1, 0)
    YesBtn.Position = UDim2.new(0, 0, 0, 0)
    YesBtn.Text = "YES"
    YesBtn.Font = Enum.Font.GothamBold
    YesBtn.TextSize = 15
    YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    YesBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    makeCorner(YesBtn, 8)
    makeStroke(YesBtn, Color3.fromRGB(250, 120, 120))
    YesBtn.ZIndex = 14
    
    -- Add gradient to yes button
    local YesGradient = Instance.new("UIGradient", YesBtn)
    YesGradient.Rotation = 90
    YesGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 100, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 80, 80))
    }
    
    local NoBtn = Instance.new("TextButton", ButtonContainer)
    NoBtn.Size = UDim2.new(0.45, 0, 1, 0)
    NoBtn.Position = UDim2.new(0.55, 0, 0, 0)
    NoBtn.Text = "NO"
    NoBtn.Font = Enum.Font.GothamBold
    NoBtn.TextSize = 15
    NoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 230)
    makeCorner(NoBtn, 8)
    makeStroke(NoBtn, Color3.fromRGB(120, 180, 255))
    NoBtn.ZIndex = 14
    
    -- Add gradient to no button
    local NoGradient = Instance.new("UIGradient", NoBtn)
    NoGradient.Rotation = 90
    NoGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 160, 250)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 140, 230))
    }
    
    setupHoverEffect(YesBtn, Color3.fromRGB(220, 80, 80), Color3.fromRGB(240, 100, 100),
                    Color3.fromRGB(250, 120, 120), Color3.fromRGB(255, 140, 140))
    setupHoverEffect(NoBtn, Color3.fromRGB(70, 140, 230), Color3.fromRGB(90, 160, 250),
                    Color3.fromRGB(120, 180, 255), Color3.fromRGB(140, 200, 255))
    
    YesBtn.MouseButton1Click:Connect(function()
        tween(Main, 0.5, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1})
        tween(blur, 0.5, {Size = 0})
        task.wait(0.5)
        ScreenGui:Destroy()
        blur:Destroy()
    end)
    
    NoBtn.MouseButton1Click:Connect(function()
        tween(PopupOverlay, 0.2, {BackgroundTransparency = 1})
        task.wait(0.2)
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
    tween(VerifyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(90, 120, 180)})
    tween(StatusIndicator, 0.2, {BackgroundColor3 = Color3.fromRGB(90, 120, 180)})
    
    -- Create loading animation
    local loadingCircle = Instance.new("Frame", VerifyBtn)
    loadingCircle.Size = UDim2.new(0, 24, 0, 24)
    loadingCircle.Position = UDim2.new(0.5, -12, 0.5, -12)
    loadingCircle.BackgroundTransparency = 1
    loadingCircle.BorderSizePixel = 0
    loadingCircle.ZIndex = 4
    makeCorner(loadingCircle, 12)
    
    local loadingStroke = Instance.new("UIStroke", loadingCircle)
    loadingStroke.Thickness = 2.5
    loadingStroke.Color = Color3.fromRGB(220, 240, 255)
    loadingStroke.Transparency = 0.2
    
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
        tween(StatusIndicator, 0.3, {BackgroundColor3 = Color3.fromRGB(50, 200, 100)})
        task.wait(1)
        
        -- Animate success before loading menu
        tween(Main, 0.5, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1})
        tween(blur, 0.5, {Size = 0})
        task.wait(0.5)
        
        ScreenGui:Destroy()
        blur:Destroy()
        loadstring(game:HttpGet(MenuLoadURL))()
    else
        connection:Disconnect()
        loadingCircle:Destroy()
        toast("Invalid key. Please check and try again.", false)
        tween(StatusIndicator, 0.3, {BackgroundColor3 = Color3.fromRGB(200, 70, 70)})
        
        -- Reset button state
        VerifyBtn.Text = "VERIFY KEY"
        VerifyBtn.AutoButtonColor = true
        tween(VerifyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(60, 130, 240)})
        
        -- Shake animation for invalid key
        local shakeTime = 0.3
        local shakeIntensity = 5
        local originalPosition = KeyBoxFrame.Position
        for i = 1, 3 do
            tween(KeyBoxFrame, shakeTime/6, {Position = originalPosition + UDim2.new(0, shakeIntensity, 0, 0)})
            task.wait(shakeTime/6)
            tween(KeyBoxFrame, shakeTime/6, {Position = originalPosition - UDim2.new(0, shakeIntensity, 0, 0)})
            task.wait(shakeTime/6)
        end
        tween(KeyBoxFrame, shakeTime/6, {Position = originalPosition})
    end
end)

-- Initial animation with improved entrance
Main.Position = UDim2.new(0.5, -250, 0.4, -210)
Main.BackgroundTransparency = 1
Main.Size = UDim2.new(0, 10, 0, 10)

tween(Main, 0.7, {Position = UDim2.new(0.5, -250, 0.5, -210), BackgroundTransparency = 0.2, Size = UDim2.new(0, 500, 0, 420)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Subtle background animation (contained within frame)
spawn(function()
    while ScreenGui.Parent do
        tween(BgCircle1, 6, {Position = UDim2.new(0.05, 0, 0.65, 0)})
        tween(BgCircle2, 6, {Position = UDim2.new(0.7, 0, 0.1, 0)})
        task.wait(6)
        tween(BgCircle1, 6, {Position = UDim2.new(0.1, 0, 0.7, 0)})
        tween(BgCircle2, 6, {Position = UDim2.new(0.75, 0, 0.05, 0)})
        task.wait(6)
    end
end)

-- Add subtle pulse effect to icon
spawn(function()
    while ScreenGui.Parent do
        tween(IconGlow, 2, {ImageTransparency = 0.9})
        task.wait(2)
        tween(IconGlow, 2, {ImageTransparency = 0.7})
        task.wait(2)
    end
end)

-- Add keyboard shortcut for verification
UserInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Return and KeyBox:IsFocused() then
        VerifyBtn.MouseButton1Click:Fire()
    end
end)

-- Add escape key to close
UserInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Escape then
        confirmExit()
    end
end)
