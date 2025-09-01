-- ZiaanHub Key System (Premium Glass UI)
-- By ZiaanStore © 2025
-- Enhanced Glassmorphism Theme

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
tween(blur, 0.5, {Size = 24})

-- Create a subtle gradient overlay for the entire screen
local BackgroundOverlay = Instance.new("Frame", ScreenGui)
BackgroundOverlay.Size = UDim2.new(1, 0, 1, 0)
BackgroundOverlay.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
BackgroundOverlay.BackgroundTransparency = 0.1
BackgroundOverlay.BorderSizePixel = 0
BackgroundOverlay.ZIndex = 0

local BackgroundGradient = Instance.new("UIGradient", BackgroundOverlay)
BackgroundGradient.Rotation = 120
BackgroundGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 15, 25)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 25, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 20))
}

-- Create animated particles in background
local function createParticle(parent, size, position, color, duration)
    local particle = Instance.new("Frame", parent)
    particle.Size = UDim2.new(0, size, 0, size)
    particle.Position = position
    particle.BackgroundColor3 = color
    particle.BackgroundTransparency = 0.8
    particle.BorderSizePixel = 0
    particle.ZIndex = 1
    makeCorner(particle, size/2)
    
    spawn(function()
        local startPos = particle.Position
        local targetPos = UDim2.new(
            math.random(), math.random(-100, 100),
            math.random(), math.random(-100, 100)
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
        for i = 1, 3 do
            createParticle(
                ScreenGui, 
                math.random(8, 20), 
                UDim2.new(math.random(), 0, math.random(), 0),
                Color3.fromRGB(70, 130, 230),
                math.random(5, 10)
            )
        end
        task.wait(0.15)
    end
end)

-- Create floating orbs
local function createFloatingOrb(parent, size, position, color, duration)
    local orb = Instance.new("Frame", parent)
    orb.Size = UDim2.new(0, size, 0, size)
    orb.Position = position
    orb.BackgroundColor3 = color
    orb.BackgroundTransparency = 0.9
    orb.BorderSizePixel = 0
    orb.ZIndex = 1
    makeCorner(orb, size/2)
    
    -- Add glow effect
    local glow = Instance.new("ImageLabel", orb)
    glow.Size = UDim2.new(2, 0, 2, 0)
    glow.Position = UDim2.new(-0.5, 0, -0.5, 0)
    glow.Image = "rbxassetid://5028857084" -- Glow texture
    glow.ImageColor3 = color
    glow.BackgroundTransparency = 1
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(100, 100, 100, 100)
    
    spawn(function()
        local startPos = orb.Position
        local targetY = startPos.Y.Offset + math.random(-80, 80)
        local targetX = startPos.X.Offset + math.random(-50, 50)
        
        tween(orb, duration/2, {
            Position = UDim2.new(startPos.X.Scale, targetX, startPos.Y.Scale, targetY),
            BackgroundTransparency = 0.7
        })
        
        task.wait(duration/2)
        
        tween(orb, duration/2, {
            Position = startPos,
            BackgroundTransparency = 0.9
        })
        
        task.wait(duration/2)
        orb:Destroy()
    end)
    
    return orb
end

-- Create floating orb system
spawn(function()
    while ScreenGui.Parent do
        createFloatingOrb(
            ScreenGui, 
            math.random(30, 60), 
            UDim2.new(math.random(), math.random(-100, 100), math.random(), math.random(-100, 100)),
            Color3.fromRGB(80, 150, 255),
            math.random(8, 15)
        )
        task.wait(0.8)
    end
end)

-- Main container with enhanced glassmorphism effect
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 460, 0, 420)
Main.Position = UDim2.new(0.5, -230, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
Main.BackgroundTransparency = 0.15
Main.BorderSizePixel = 0
Main.ZIndex = 2
makeCorner(Main, 18)
makeStroke(Main, Color3.fromRGB(100, 160, 240), 1.8, 0.3)

-- Add enhanced glassmorphism effect
local GlassFrame = Instance.new("Frame", Main)
GlassFrame.Size = UDim2.new(1, 0, 1, 0)
GlassFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GlassFrame.BackgroundTransparency = 0.93
GlassFrame.BorderSizePixel = 0
GlassFrame.ZIndex = 2
makeCorner(GlassFrame, 18)

-- Add subtle gradient to main container
local MainGradient = Instance.new("UIGradient", Main)
MainGradient.Rotation = 90
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 40, 65)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 25, 40))
}
MainGradient.Transparency = NumberSequence.new(0.85)

-- Create a clipping frame to contain the animated elements
local ClipFrame = Instance.new("Frame", Main)
ClipFrame.Size = UDim2.new(1, 0, 1, 0)
ClipFrame.BackgroundTransparency = 1
ClipFrame.ClipsDescendants = true
ClipFrame.ZIndex = 1

-- Header with enhanced gradient
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 70)
Header.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
Header.BorderSizePixel = 0
Header.ZIndex = 3
makeCorner(Header, 16)

-- Add gradient to header
local HeaderGradient = Instance.new("UIGradient", Header)
HeaderGradient.Rotation = 90
HeaderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 65, 110)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 50, 85)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 35, 60))
}

-- Add subtle pattern to header
local HeaderPattern = Instance.new("ImageLabel", Header)
HeaderPattern.Size = UDim2.new(1, 0, 1, 0)
HeaderPattern.Image = "rbxassetid://6572594246" -- Subtle pattern
HeaderPattern.ImageTransparency = 0.9
HeaderPattern.ImageColor3 = Color3.fromRGB(20, 30, 50)
HeaderPattern.ScaleType = Enum.ScaleType.Tile
HeaderPattern.TileSize = UDim2.new(0, 50, 0, 50)
HeaderPattern.BackgroundTransparency = 1
HeaderPattern.ZIndex = 3

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 70, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "ZIAANHUB PREMIUM ACCESS"
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(230, 240, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 4

-- Add text shadow
local TitleShadow = Title:Clone()
TitleShadow.Parent = Header
TitleShadow.TextColor3 = Color3.fromRGB(10, 20, 40)
TitleShadow.Position = Title.Position + UDim2.new(0, 2, 0, 2)
TitleShadow.ZIndex = 3

-- Icon with enhanced glow effect
local Icon = Instance.new("ImageLabel", Header)
Icon.Size = UDim2.new(0, 42, 0, 42)
Icon.Position = UDim2.new(0, 15, 0.5, -21)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://7072716642" -- Lock icon
Icon.ImageColor3 = Color3.fromRGB(140, 200, 255)
Icon.ZIndex = 4

-- Add glow effect to icon
local IconGlow = Instance.new("ImageLabel", Icon)
IconGlow.Size = UDim2.new(2, 0, 2, 0)
IconGlow.Position = UDim2.new(-0.5, 0, -0.5, 0)
IconGlow.Image = "rbxassetid://5028857084" -- Glow texture
IconGlow.ImageColor3 = Color3.fromRGB(100, 180, 255)
IconGlow.BackgroundTransparency = 1
IconGlow.ScaleType = Enum.ScaleType.Slice
IconGlow.SliceCenter = Rect.new(100, 100, 100, 100)
IconGlow.ZIndex = 3

-- Enhanced close button
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -46, 0.5, -18)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 28
CloseBtn.TextColor3 = Color3.fromRGB(220, 220, 240)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 65, 100)
CloseBtn.ZIndex = 4
makeCorner(CloseBtn, 10)
makeStroke(CloseBtn, Color3.fromRGB(100, 160, 240))

-- Add hover effect to close button
local CloseHover = Instance.new("Frame", CloseBtn)
CloseHover.Size = UDim2.new(1, 0, 1, 0)
CloseHover.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseHover.BackgroundTransparency = 0.9
CloseHover.BorderSizePixel = 0
CloseHover.ZIndex = 4
makeCorner(CloseHover, 10)

-- Body content
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -40, 1, -100)
Content.Position = UDim2.new(0, 20, 0, 90)
Content.BackgroundTransparency = 1
Content.ZIndex = 3

-- Welcome text with enhanced styling
local Welcome = Instance.new("TextLabel", Content)
Welcome.Size = UDim2.new(1, 0, 0, 40)
Welcome.Position = UDim2.new(0, 0, 0, 0)
Welcome.Text = "Welcome to ZiaanHub Premium"
Welcome.TextColor3 = Color3.fromRGB(200, 220, 255)
Welcome.Font = Enum.Font.GothamSemibold
Welcome.TextSize = 22
Welcome.BackgroundTransparency = 1
Welcome.TextXAlignment = Enum.TextXAlignment.Left
Welcome.ZIndex = 3

-- Add subtle glow to welcome text
local WelcomeGlow = Instance.new("TextLabel", Content)
WelcomeGlow.Size = Welcome.Size
WelcomeGlow.Position = Welcome.Position
WelcomeGlow.Text = Welcome.Text
WelcomeGlow.Font = Welcome.Font
WelcomeGlow.TextSize = Welcome.TextSize
WelcomeGlow.TextColor3 = Color3.fromRGB(70, 130, 230)
WelcomeGlow.BackgroundTransparency = 1
WelcomeGlow.TextTransparency = 0.7
WelcomeGlow.TextXAlignment = Welcome.TextXAlignment
WelcomeGlow.ZIndex = 2

-- Instructions with improved styling
local Instructions = Instance.new("TextLabel", Content)
Instructions.Size = UDim2.new(1, 0, 0, 50)
Instructions.Position = UDim2.new(0, 0, 0, 40)
Instructions.Text = "Enter your premium access key to unlock exclusive features and scripts."
Instructions.TextColor3 = Color3.fromRGB(160, 180, 220)
Instructions.Font = Enum.Font.Gotham
Instructions.TextSize = 15
Instructions.BackgroundTransparency = 1
Instructions.TextXAlignment = Enum.TextXAlignment.Left
Instructions.TextWrapped = true
Instructions.ZIndex = 3

-- Enhanced key input field
local KeyBoxFrame = Instance.new("Frame", Content)
KeyBoxFrame.Size = UDim2.new(1, 0, 0, 55)
KeyBoxFrame.Position = UDim2.new(0, 0, 0, 100)
KeyBoxFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 65)
KeyBoxFrame.ZIndex = 3
makeCorner(KeyBoxFrame, 12)
makeStroke(KeyBoxFrame, Color3.fromRGB(80, 150, 240))

-- Add gradient to input field
local InputGradient = Instance.new("UIGradient", KeyBoxFrame)
InputGradient.Rotation = 90
InputGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 55, 90)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 40, 65))
}

-- Add inner shadow effect
local InputShadow = Instance.new("Frame", KeyBoxFrame)
InputShadow.Size = UDim2.new(1, 0, 0, 4)
InputShadow.Position = UDim2.new(0, 0, 1, -4)
InputShadow.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
InputShadow.BorderSizePixel = 0
InputShadow.ZIndex = 3
makeCorner(InputShadow, 0)

local KeyBox = Instance.new("TextBox", KeyBoxFrame)
KeyBox.Size = UDim2.new(1, -50, 1, -10)
KeyBox.Position = UDim2.new(0, 15, 0, 5)
KeyBox.PlaceholderText = "Enter your premium access key..."
KeyBox.Text = ""
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 17
KeyBox.TextColor3 = Color3.fromRGB(230, 240, 255)
KeyBox.BackgroundTransparency = 1
KeyBox.ClearTextOnFocus = false
KeyBox.PlaceholderColor3 = Color3.fromRGB(140, 160, 200)
KeyBox.ZIndex = 4

-- Enhanced show/hide key button
local ShowKeyBtn = Instance.new("TextButton", KeyBoxFrame)
ShowKeyBtn.Size = UDim2.new(0, 35, 0, 35)
ShowKeyBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
ShowKeyBtn.Text = ""
ShowKeyBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 110)
ShowKeyBtn.ZIndex = 4
makeCorner(ShowKeyBtn, 8)
makeStroke(ShowKeyBtn, Color3.fromRGB(90, 160, 250))

local EyeIcon = Instance.new("ImageLabel", ShowKeyBtn)
EyeIcon.Size = UDim2.new(0, 22, 0, 22)
EyeIcon.Position = UDim2.new(0.5, -11, 0.5, -11)
EyeIcon.Image = "rbxassetid://7072717000" -- Eye icon
EyeIcon.ImageColor3 = Color3.fromRGB(160, 200, 255)
EyeIcon.BackgroundTransparency = 1

local keyVisible = false
ShowKeyBtn.MouseButton1Click:Connect(function()
    keyVisible = not keyVisible
    if keyVisible then
        KeyBox.TextTransparency = 0
        EyeIcon.ImageColor3 = Color3.fromRGB(100, 180, 255)
        tween(ShowKeyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(60, 90, 140)})
    else
        KeyBox.TextTransparency = 0
        EyeIcon.ImageColor3 = Color3.fromRGB(160, 200, 255)
        tween(ShowKeyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(50, 70, 110)})
    end
end)

-- Enhanced verify button
local VerifyBtn = Instance.new("TextButton", Content)
VerifyBtn.Size = UDim2.new(1, 0, 0, 55)
VerifyBtn.Position = UDim2.new(0, 0, 0, 170)
VerifyBtn.Text = "VERIFY KEY"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 18
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 255)
VerifyBtn.ZIndex = 3
makeCorner(VerifyBtn, 12)
makeStroke(VerifyBtn, Color3.fromRGB(120, 190, 255))

-- Add gradient to verify button
local ButtonGradient = Instance.new("UIGradient", VerifyBtn)
ButtonGradient.Rotation = 90
ButtonGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 160, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 140, 255))
}

-- Add shine effect to verify button
local ButtonShine = Instance.new("Frame", VerifyBtn)
ButtonShine.Size = UDim2.new(0, 30, 2, 0)
ButtonShine.Position = UDim2.new(-0.1, 0, -0.5, 0)
ButtonShine.Rotation = 45
ButtonShine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ButtonShine.BackgroundTransparency = 0.8
ButtonShine.BorderSizePixel = 0
ButtonShine.ZIndex = 4

-- Animate the shine effect
spawn(function()
    while VerifyBtn.Parent do
        tween(ButtonShine, 0.8, {Position = UDim2.new(1.1, 0, -0.5, 0)})
        task.wait(0.8)
        ButtonShine.Position = UDim2.new(-0.1, 0, -0.5, 0)
        task.wait(2)
    end
end)

-- Status indicator
local Status = Instance.new("TextLabel", Content)
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0, 235)
Status.Text = "Status: Waiting for input..."
Status.TextColor3 = Color3.fromRGB(160, 200, 255)
Status.Font = Enum.Font.Gotham
Status.TextSize = 14
Status.BackgroundTransparency = 1
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.ZIndex = 3

-- Footer with enhanced design
local Footer = Instance.new("Frame", Main)
Footer.Size = UDim2.new(1, 0, 0, 40)
Footer.Position = UDim2.new(0, 0, 1, -40)
Footer.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
Footer.BorderSizePixel = 0
Footer.ZIndex = 3
makeCorner(Footer, 0, 0, 16, 16)

local FooterText = Instance.new("TextLabel", Footer)
FooterText.Size = UDim2.new(1, 0, 1, 0)
FooterText.Text = "ZiaanStore © 2025 | Premium Edition v2.5"
FooterText.TextColor3 = Color3.fromRGB(140, 170, 220)
FooterText.Font = Enum.Font.Gotham
FooterText.TextSize = 13
FooterText.BackgroundTransparency = 1
FooterText.ZIndex = 3

-- Add a subtle pattern to footer
local FooterPattern = Instance.new("ImageLabel", Footer)
FooterPattern.Size = UDim2.new(1, 0, 1, 0)
FooterPattern.Image = "rbxassetid://6572594246" -- Subtle pattern
FooterPattern.ImageTransparency = 0.95
FooterPattern.ImageColor3 = Color3.fromRGB(20, 30, 50)
FooterPattern.ScaleType = Enum.ScaleType.Tile
FooterPattern.TileSize = UDim2.new(0, 40, 0, 40)
FooterPattern.BackgroundTransparency = 1
FooterPattern.ZIndex = 3

-- Hover effects with enhanced animation
local function setupHoverEffect(button, normalColor, hoverColor, normalStroke, hoverStroke)
    button.MouseEnter:Connect(function()
        tween(button, 0.2, {
            BackgroundColor3 = hoverColor, 
            Position = button.Position - UDim2.new(0, 0, 0.01, 0),
            Size = button.Size + UDim2.new(0, 0, 0.02, 0)
        })
        if hoverStroke then
            tween(button.UIStroke, 0.2, {Color = hoverStroke, Thickness = 2.2})
        end
    end)
    
    button.MouseLeave:Connect(function()
        tween(button, 0.2, {
            BackgroundColor3 = normalColor, 
            Position = button.Position + UDim2.new(0, 0, 0.01, 0),
            Size = button.Size - UDim2.new(0, 0, 0.02, 0)
        })
        if normalStroke then
            tween(button.UIStroke, 0.2, {Color = normalStroke, Thickness = 1.8})
        end
    end)
end

setupHoverEffect(VerifyBtn, Color3.fromRGB(60, 140, 255), Color3.fromRGB(80, 160, 255), 
                 Color3.fromRGB(120, 190, 255), Color3.fromRGB(140, 210, 255))
setupHoverEffect(CloseBtn, Color3.fromRGB(50, 65, 100), Color3.fromRGB(70, 85, 120),
                 Color3.fromRGB(100, 160, 240), Color3.fromRGB(120, 180, 255))

-- Input field hover effect
KeyBoxFrame.MouseEnter:Connect(function()
    tween(KeyBoxFrame.UIStroke, 0.2, {Color = Color3.fromRGB(100, 180, 255), Thickness = 2.2})
    tween(KeyBoxFrame, 0.2, {Position = KeyBoxFrame.Position - UDim2.new(0, 0, 0.005, 0)})
end)

KeyBoxFrame.MouseLeave:Connect(function()
    tween(KeyBoxFrame.UIStroke, 0.2, {Color = Color3.fromRGB(80, 150, 240), Thickness = 1.8})
    tween(KeyBoxFrame, 0.2, {Position = KeyBoxFrame.Position + UDim2.new(0, 0, 0.005, 0)})
end)

-- TOAST NOTIFICATION with enhanced design
local function toast(msg, ok)
    local holder = Instance.new("Frame", ScreenGui)
    holder.Size = UDim2.new(0, 380, 0, 60)
    holder.Position = UDim2.new(0.5, -190, 1, 50)
    holder.BackgroundColor3 = ok and Color3.fromRGB(25, 70, 40) or Color3.fromRGB(70, 35, 40)
    holder.ZIndex = 10
    makeCorner(holder, 12)
    makeStroke(holder, ok and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(200, 70, 70), 2.5, 0.2)
    
    -- Add gradient to toast
    local ToastGradient = Instance.new("UIGradient", holder)
    ToastGradient.Rotation = 90
    ToastGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ok and Color3.fromRGB(35, 90, 55) or Color3.fromRGB(90, 45, 50)),
        ColorSequenceKeypoint.new(1, ok and Color3.fromRGB(25, 70, 40) or Color3.fromRGB(70, 35, 40))
    }
    
    -- Add glow effect
    local ToastGlow = Instance.new("ImageLabel", holder)
    ToastGlow.Size = UDim2.new(1, 20, 1, 20)
    ToastGlow.Position = UDim2.new(-0.1, 0, -0.1, 0)
    ToastGlow.Image = "rbxassetid://5028857084" -- Glow texture
    ToastGlow.ImageColor3 = ok and Color3.fromRGB(30, 100, 50) or Color3.fromRGB(100, 30, 40)
    ToastGlow.BackgroundTransparency = 1
    ToastGlow.ScaleType = Enum.ScaleType.Slice
    ToastGlow.SliceCenter = Rect.new(100, 100, 100, 100)
    ToastGlow.ZIndex = 9
    
    local message = Instance.new("TextLabel", holder)
    message.Size = UDim2.new(1, -60, 1, 0)
    message.Position = UDim2.new(0, 50, 0, 0)
    message.Text = msg
    message.Font = Enum.Font.GothamMedium
    message.TextSize = 16
    message.TextColor3 = ok and Color3.fromRGB(180, 255, 200) or Color3.fromRGB(255, 180, 180)
    message.BackgroundTransparency = 1
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.ZIndex = 10
    
    local icon = Instance.new("ImageLabel", holder)
    icon.Size = UDim2.new(0, 28, 0, 28)
    icon.Position = UDim2.new(0, 15, 0.5, -14)
    icon.BackgroundTransparency = 1
    icon.Image = ok and "rbxassetid://7072717770" or "rbxassetid://7072717852" -- Check/cross icons
    icon.ImageColor3 = message.TextColor3
    icon.ZIndex = 10
    
    tween(holder, 0.3, {Position = UDim2.new(0.5, -190, 1, -80)})
    task.delay(2.5, function()
        tween(holder, 0.3, {Position = UDim2.new(0.5, -190, 1, 50)})
        task.wait(0.35)
        holder:Destroy()
    end)
end

-- DRAGGABLE UI with enhanced feedback
do
    local dragging, dragInput, startPos, dragStart
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            
            -- Add visual feedback when dragging
            tween(Main, 0.1, {Size = UDim2.new(0, 455, 0, 415)})
            tween(Header, 0.1, {BackgroundColor3 = Color3.fromRGB(35, 50, 80)})
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
            tween(Main, 0.1, {Size = UDim2.new(0, 460, 0, 420)})
            tween(Header, 0.2, {BackgroundColor3 = Color3.fromRGB(25, 35, 60)})
        end
    end)
end

-- CONFIRM EXIT POPUP with enhanced design
local function confirmExit()
    local PopupOverlay = Instance.new("Frame", ScreenGui)
    PopupOverlay.Size = UDim2.new(1, 0, 1, 0)
    PopupOverlay.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
    PopupOverlay.BackgroundTransparency = 0.6
    PopupOverlay.ZIndex = 10
    
    local Popup = Instance.new("Frame", PopupOverlay)
    Popup.Size = UDim2.new(0, 360, 0, 220)
    Popup.Position = UDim2.new(0.5, -180, 0.5, -110)
    Popup.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
    Popup.BackgroundTransparency = 0.1
    Popup.ZIndex = 11
    makeCorner(Popup, 16)
    makeStroke(Popup, Color3.fromRGB(80, 150, 240), 2.2, 0.3)
    
    -- Add glass effect to popup
    local PopupGlass = Instance.new("Frame", Popup)
    PopupGlass.Size = UDim2.new(1, 0, 1, 0)
    PopupGlass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PopupGlass.BackgroundTransparency = 0.94
    PopupGlass.BorderSizePixel = 0
    PopupGlass.ZIndex = 12
    makeCorner(PopupGlass, 16)
    
    -- Add gradient to popup
    local PopupGradient = Instance.new("UIGradient", Popup)
    PopupGradient.Rotation = 90
    PopupGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 45, 75)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 35, 60))
    }
    PopupGradient.Transparency = NumberSequence.new(0.9)
    
    local Title = Instance.new("TextLabel", Popup)
    Title.Size = UDim2.new(1, -20, 0, 60)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.Text = "Confirm Exit"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22
    Title.TextColor3 = Color3.fromRGB(230, 240, 255)
    Title.BackgroundTransparency = 1
    Title.ZIndex = 13
    
    local Message = Instance.new("TextLabel", Popup)
    Message.Size = UDim2.new(1, -20, 0, 80)
    Message.Position = UDim2.new(0, 10, 0, 60)
    Message.Text = "Are you sure you want to close the key system?"
    Message.Font = Enum.Font.Gotham
    Message.TextSize = 16
    Message.TextColor3 = Color3.fromRGB(180, 200, 230)
    Message.BackgroundTransparency = 1
    Message.TextWrapped = true
    Message.ZIndex = 13
    
    local ButtonContainer = Instance.new("Frame", Popup)
    ButtonContainer.Size = UDim2.new(1, -20, 0, 55)
    ButtonContainer.Position = UDim2.new(0, 10, 1, -65)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.ZIndex = 13
    
    local YesBtn = Instance.new("TextButton", ButtonContainer)
    YesBtn.Size = UDim2.new(0.45, 0, 1, 0)
    YesBtn.Position = UDim2.new(0, 0, 0, 0)
    YesBtn.Text = "YES"
    YesBtn.Font = Enum.Font.GothamBold
    YesBtn.TextSize = 16
    YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    YesBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    makeCorner(YesBtn, 10)
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
    NoBtn.TextSize = 16
    NoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 230)
    makeCorner(NoBtn, 10)
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

-- VERIFY BUTTON FUNCTION with enhanced loading animation
VerifyBtn.MouseButton1Click:Connect(function()
    local key = trim(KeyBox.Text)
    if key == "" then 
        toast("Please enter a key", false) 
        Status.Text = "Status: Please enter a key"
        return 
    end
    
    -- Show loading state
    VerifyBtn.Text = "VERIFYING..."
    VerifyBtn.AutoButtonColor = false
    Status.Text = "Status: Verifying key..."
    tween(VerifyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(90, 120, 180)})
    
    -- Create enhanced loading animation
    local loadingContainer = Instance.new("Frame", VerifyBtn)
    loadingContainer.Size = UDim2.new(1, 0, 1, 0)
    loadingContainer.BackgroundTransparency = 1
    loadingContainer.ZIndex = 4
    
    local loadingCircle = Instance.new("Frame", loadingContainer)
    loadingCircle.Size = UDim2.new(0, 30, 0, 30)
    loadingCircle.Position = UDim2.new(0.5, -15, 0.5, -15)
    loadingCircle.BackgroundTransparency = 1
    loadingCircle.BorderSizePixel = 0
    loadingCircle.ZIndex = 4
    makeCorner(loadingCircle, 15)
    
    local loadingStroke = Instance.new("UIStroke", loadingCircle)
    loadingStroke.Thickness = 3
    loadingStroke.Color = Color3.fromRGB(220, 240, 255)
    loadingStroke.Transparency = 0.1
    
    -- Add glow to loading circle
    local loadingGlow = Instance.new("ImageLabel", loadingCircle)
    loadingGlow.Size = UDim2.new(2, 0, 2, 0)
    loadingGlow.Position = UDim2.new(-0.5, 0, -0.5, 0)
    loadingGlow.Image = "rbxassetid://5028857084" -- Glow texture
    loadingGlow.ImageColor3 = Color3.fromRGB(100, 180, 255)
    loadingGlow.BackgroundTransparency = 1
    loadingGlow.ScaleType = Enum.ScaleType.Slice
    loadingGlow.SliceCenter = Rect.new(100, 100, 100, 100)
    loadingGlow.ZIndex = 3
    
    local rotation = 0
    local connection
    connection = RunService.RenderStepped:Connect(function(delta)
        rotation = (rotation + delta * 360) % 360
        loadingStroke.Rotation = rotation
    end)
    
    -- Simulate network delay
    task.wait(0.8)
    
    if isValidKey(key) then
        connection:Disconnect()
        loadingContainer:Destroy()
        Status.Text = "Status: Key verified successfully!"
        toast("Key verified successfully! Loading menu...", true)
        task.wait(1.2)
        
        -- Animate success before loading menu
        tween(Main, 0.7, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1})
        tween(blur, 0.7, {Size = 0})
        task.wait(0.7)
        
        ScreenGui:Destroy()
        blur:Destroy()
        loadstring(game:HttpGet(MenuLoadURL))()
    else
        connection:Disconnect()
        loadingContainer:Destroy()
        Status.Text = "Status: Invalid key"
        toast("Invalid key. Please check and try again.", false)
        
        -- Reset button state
        VerifyBtn.Text = "VERIFY KEY"
        VerifyBtn.AutoButtonColor = true
        tween(VerifyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(60, 140, 255)})
        
        -- Enhanced shake animation for invalid key
        local shakeTime = 0.4
        local shakeIntensity = 8
        local originalPosition = KeyBoxFrame.Position
        
        for i = 1, 4 do
            tween(KeyBoxFrame, shakeTime/8, {Position = originalPosition + UDim2.new(0, shakeIntensity, 0, 0)})
            task.wait(shakeTime/8)
            tween(KeyBoxFrame, shakeTime/8, {Position = originalPosition - UDim2.new(0, shakeIntensity, 0, 0)})
            task.wait(shakeTime/8)
        end
        tween(KeyBoxFrame, shakeTime/8, {Position = originalPosition})
    end
end)

-- Initial enhanced animation
Main.Position = UDim2.new(0.5, -230, 0.4, -210)
Main.BackgroundTransparency = 1
Main.Size = UDim2.new(0, 10, 0, 10)

tween(Main, 0.8, {Position = UDim2.new(0.5, -230, 0.5, -210), BackgroundTransparency = 0.15, Size = UDim2.new(0, 460, 0, 420)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

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
