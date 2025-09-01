-- ZiaanHub Key System (Premium Glass UI) -- By ZiaanStore © 2025 -- Enhanced Glassmorphism Theme -- CONFIG 
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
            if #k > 0 then
                table.insert(ValidKeys, k)
            end
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

-- Enhanced background blur effect
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
tween(blur, 0.8, {Size = 25})

-- Create an ambient light for better glass effect
local ambient = Instance.new("ColorCorrectionEffect", Lighting)
ambient.Brightness = 0.05
ambient.Contrast = 0.1
ambient.Saturation = 0.1
ambient.TintColor = Color3.fromRGB(255, 255, 255)

-- Background overlay with gradient
local Overlay = Instance.new("Frame", ScreenGui)
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(10, 15, 30)
Overlay.BackgroundTransparency = 0.2
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
    
    local glow = Instance.new("ImageLabel", particle)
    glow.Size = UDim2.new(2, 0, 2, 0)
    glow.Position = UDim2.new(-0.5, 0, -0.5, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5107152095" -- Soft glow texture
    glow.ImageColor3 = color
    glow.ImageTransparency = 0.7
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceScale = 0.1
    
    spawn(function()
        local startPos = particle.Position
        local targetPos = UDim2.new(
            math.random(), math.random(-50, 50),
            math.random(), math.random(-50, 50)
        )
        tween(particle, duration, {Position = targetPos, BackgroundTransparency = 1})
        tween(glow, duration, {ImageTransparency = 1})
        task.wait(duration)
        particle:Destroy()
    end)
    return particle
end

-- Create particle system with different colors
spawn(function()
    while ScreenGui.Parent do
        local colors = {
            Color3.fromRGB(70, 130, 230),
            Color3.fromRGB(100, 180, 255),
            Color3.fromRGB(150, 100, 230),
            Color3.fromRGB(80, 200, 220)
        }
        createParticle(
            ScreenGui, 
            math.random(8, 20),
            UDim2.new(math.random(), 0, math.random(), 0),
            colors[math.random(1, #colors)],
            math.random(4, 8)
        )
        task.wait(0.15)
    end
end)

-- Main container with enhanced glassmorphism effect
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 550)
Main.Position = UDim2.new(0.5, -250, 0.5, -275)
Main.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
Main.BackgroundTransparency = 0.15
Main.BorderSizePixel = 0
Main.ZIndex = 2
makeCorner(Main, 20)
makeStroke(Main, Color3.fromRGB(100, 150, 220), 2, 0.3)

-- Add enhanced glassmorphism effect
local GlassFrame = Instance.new("Frame", Main)
GlassFrame.Size = UDim2.new(1, 0, 1, 0)
GlassFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GlassFrame.BackgroundTransparency = 0.93
GlassFrame.BorderSizePixel = 0
GlassFrame.ZIndex = 2
makeCorner(GlassFrame, 20)

-- Create a clipping frame to contain the animated elements
local ClipFrame = Instance.new("Frame", Main)
ClipFrame.Size = UDim2.new(1, 0, 1, 0)
ClipFrame.BackgroundTransparency = 1
ClipFrame.ClipsDescendants = true
ClipFrame.ZIndex = 1

-- Header with enhanced gradient
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, -40, 0, 80)
Header.Position = UDim2.new(0, 20, 0, 20)
Header.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
Header.BorderSizePixel = 0
Header.ZIndex = 3
makeCorner(Header, 16)

-- Add gradient to header
local HeaderGradient = Instance.new("UIGradient", Header)
HeaderGradient.Rotation = 90
HeaderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 70, 120)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 55, 95)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 35, 60))
}

-- Add subtle pattern to header
local Pattern = Instance.new("ImageLabel", Header)
Pattern.Size = UDim2.new(1, 0, 1, 0)
Pattern.Image = "rbxassetid://6572596770" -- Subtle pattern texture
Pattern.ImageTransparency = 0.9
Pattern.ScaleType = Enum.ScaleType.Tile
Pattern.TileSize = UDim2.new(0, 50, 0, 50)
Pattern.BackgroundTransparency = 1
Pattern.ZIndex = 4

-- Title with better typography
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -100, 1, -10)
Title.Position = UDim2.new(0, 70, 0, 5)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "ZIAANHUB PREMIUM ACCESS"
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(230, 240, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 5

-- Subtitle
local Subtitle = Instance.new("TextLabel", Header)
Subtitle.Size = UDim2.new(1, -100, 0, 20)
Subtitle.Position = UDim2.new(0, 70, 0, 40)
Subtitle.BackgroundTransparency = 1
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "Unlock exclusive features with your premium key"
Subtitle.TextSize = 14
Subtitle.TextColor3 = Color3.fromRGB(180, 200, 230)
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 5

-- Icon with enhanced design
local Icon = Instance.new("ImageLabel", Header)
Icon.Size = UDim2.new(0, 45, 0, 45)
Icon.Position = UDim2.new(0, 15, 0.5, -22.5)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://7072716642" -- Lock icon
Icon.ImageColor3 = Color3.fromRGB(150, 210, 255)
Icon.ZIndex = 5

-- Add glow effect to icon
local IconGlow = Instance.new("ImageLabel", Icon)
IconGlow.Size = UDim2.new(2, 0, 2, 0)
IconGlow.Position = UDim2.new(-0.5, 0, -0.5, 0)
IconGlow.BackgroundTransparency = 1
IconGlow.Image = "rbxassetid://5021865973" -- Glow texture
IconGlow.ImageColor3 = Color3.fromRGB(100, 180, 255)
IconGlow.ImageTransparency = 0.8
IconGlow.ZIndex = 4

-- CLOSE (X) with enhanced design
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -46, 0.5, -18)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 24
CloseBtn.TextColor3 = Color3.fromRGB(220, 220, 240)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 65, 100)
CloseBtn.ZIndex = 5
makeCorner(CloseBtn, 10)
makeStroke(CloseBtn, Color3.fromRGB(100, 150, 220))

-- Body content
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -40, 1, -140)
Content.Position = UDim2.new(0, 20, 0, 120)
Content.BackgroundTransparency = 1
Content.ZIndex = 3

-- Welcome text with enhanced design
local Welcome = Instance.new("TextLabel", Content)
Welcome.Size = UDim2.new(1, 0, 0, 40)
Welcome.Position = UDim2.new(0, 0, 0, 0)
Welcome.Text = "Welcome to ZiaanHub Premium"
Welcome.TextColor3 = Color3.fromRGB(220, 230, 255)
Welcome.Font = Enum.Font.GothamSemibold
Welcome.TextSize = 24
Welcome.BackgroundTransparency = 1
Welcome.TextXAlignment = Enum.TextXAlignment.Left
Welcome.ZIndex = 3

-- Divider line
local Divider = Instance.new("Frame", Content)
Divider.Size = UDim2.new(1, 0, 0, 2)
Divider.Position = UDim2.new(0, 0, 0, 45)
Divider.BackgroundColor3 = Color3.fromRGB(60, 90, 140)
Divider.BackgroundTransparency = 0.7
Divider.BorderSizePixel = 0
Divider.ZIndex = 3

-- Instructions with better layout
local Instructions = Instance.new("TextLabel", Content)
Instructions.Size = UDim2.new(1, 0, 0, 60)
Instructions.Position = UDim2.new(0, 0, 0, 55)
Instructions.Text = "Enter your premium key below to access exclusive features. Your key can be obtained from our official Discord server or website."
Instructions.TextColor3 = Color3.fromRGB(170, 190, 220)
Instructions.Font = Enum.Font.Gotham
Instructions.TextSize = 15
Instructions.BackgroundTransparency = 1
Instructions.TextXAlignment = Enum.TextXAlignment.Left
Instructions.TextWrapped = true
Instructions.ZIndex = 3

-- Key input field with enhanced design
local KeyBoxFrame = Instance.new("Frame", Content)
KeyBoxFrame.Size = UDim2.new(1, 0, 0, 60)
KeyBoxFrame.Position = UDim2.new(0, 0, 0, 125)
KeyBoxFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 65)
KeyBoxFrame.ZIndex = 3
makeCorner(KeyBoxFrame, 12)
makeStroke(KeyBoxFrame, Color3.fromRGB(80, 140, 220))

-- Add gradient to input field
local InputGradient = Instance.new("UIGradient", KeyBoxFrame)
InputGradient.Rotation = 90
InputGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 55, 90)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 40, 65))
}

-- Add pattern to input field
local InputPattern = Instance.new("ImageLabel", KeyBoxFrame)
InputPattern.Size = UDim2.new(1, 0, 1, 0)
InputPattern.Image = "rbxassetid://6572596770"
InputPattern.ImageTransparency = 0.95
InputPattern.ScaleType = Enum.ScaleType.Tile
InputPattern.TileSize = UDim2.new(0, 30, 0, 30)
InputPattern.BackgroundTransparency = 1
InputPattern.ZIndex = 4

local KeyBox = Instance.new("TextBox", KeyBoxFrame)
KeyBox.Size = UDim2.new(1, -50, 1, -10)
KeyBox.Position = UDim2.new(0, 15, 0, 5)
KeyBox.PlaceholderText = "Enter your premium access key..."
KeyBox.Text = ""
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 18
KeyBox.TextColor3 = Color3.fromRGB(230, 240, 255)
KeyBox.BackgroundTransparency = 1
KeyBox.ClearTextOnFocus = false
KeyBox.PlaceholderColor3 = Color3.fromRGB(140, 160, 200)
KeyBox.ZIndex = 5

-- Show/Hide Key Button with enhanced design
local ShowKeyBtn = Instance.new("TextButton", KeyBoxFrame)
ShowKeyBtn.Size = UDim2.new(0, 40, 0, 40)
ShowKeyBtn.Position = UDim2.new(1, -45, 0.5, -20)
ShowKeyBtn.Text = ""
ShowKeyBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 110)
ShowKeyBtn.AutoButtonColor = false
ShowKeyBtn.ZIndex = 5
makeCorner(ShowKeyBtn, 10)
makeStroke(ShowKeyBtn, Color3.fromRGB(100, 160, 230))

local EyeIcon = Instance.new("ImageLabel", ShowKeyBtn)
EyeIcon.Size = UDim2.new(0, 24, 0, 24)
EyeIcon.Position = UDim2.new(0.5, -12, 0.5, -12)
EyeIcon.Image = "rbxassetid://7072717000" -- Eye icon
EyeIcon.ImageColor3 = Color3.fromRGB(180, 200, 230)
EyeIcon.BackgroundTransparency = 1

local keyVisible = false
ShowKeyBtn.MouseButton1Click:Connect(function()
    keyVisible = not keyVisible
    if keyVisible then
        KeyBox.TextTransparency = 0
        EyeIcon.Image = "rbxassetid://7072716906" -- Eye closed icon
        EyeIcon.ImageColor3 = Color3.fromRGB(120, 200, 255)
        tween(ShowKeyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(60, 100, 160)})
    else
        KeyBox.TextTransparency = 0.5
        EyeIcon.Image = "rbxassetid://7072717000" -- Eye open icon
        EyeIcon.ImageColor3 = Color3.fromRGB(180, 200, 230)
        tween(ShowKeyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(50, 70, 110)})
    end
end)

-- Verify button with enhanced design
local VerifyBtn = Instance.new("TextButton", Content)
VerifyBtn.Size = UDim2.new(1, 0, 0, 55)
VerifyBtn.Position = UDim2.new(0, 0, 0, 200)
VerifyBtn.Text = "VERIFY KEY"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 18
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(60, 130, 240)
VerifyBtn.AutoButtonColor = false
VerifyBtn.ZIndex = 3
makeCorner(VerifyBtn, 12)
makeStroke(VerifyBtn, Color3.fromRGB(120, 180, 255))

-- Add gradient to verify button
local ButtonGradient = Instance.new("UIGradient", VerifyBtn)
ButtonGradient.Rotation = 90
ButtonGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 160, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 130, 240))
}

-- Add pattern to button
local ButtonPattern = Instance.new("ImageLabel", VerifyBtn)
ButtonPattern.Size = UDim2.new(1, 0, 1, 0)
ButtonPattern.Image = "rbxassetid://6572596770"
ButtonPattern.ImageTransparency = 0.9
ButtonPattern.ScaleType = Enum.ScaleType.Tile
ButtonPattern.TileSize = UDim2.new(0, 40, 0, 40)
ButtonPattern.BackgroundTransparency = 1
ButtonPattern.ZIndex = 4

-- Add icon to verify button
local VerifyIcon = Instance.new("ImageLabel", VerifyBtn)
VerifyIcon.Size = UDim2.new(0, 24, 0, 24)
VerifyIcon.Position = UDim2.new(0, 20, 0.5, -12)
VerifyIcon.Image = "rbxassetid://7072717770" -- Check icon
VerifyIcon.ImageColor3 = Color3.fromRGB(230, 240, 255)
VerifyIcon.BackgroundTransparency = 1
VerifyIcon.ZIndex = 5

-- Footer with enhanced design
local Footer = Instance.new("Frame", Main)
Footer.Size = UDim2.new(1, -40, 0, 40)
Footer.Position = UDim2.new(0, 20, 1, -50)
Footer.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
Footer.BackgroundTransparency = 0.3
Footer.BorderSizePixel = 0
Footer.ZIndex = 3
makeCorner(Footer, 10)

local FooterText = Instance.new("TextLabel", Footer)
FooterText.Size = UDim2.new(1, 0, 1, 0)
FooterText.Text = "ZiaanStore © 2025 | Premium Edition v2.1"
FooterText.TextColor3 = Color3.fromRGB(150, 170, 210)
FooterText.Font = Enum.Font.Gotham
FooterText.TextSize = 14
FooterText.BackgroundTransparency = 1
FooterText.ZIndex = 4

-- Hover effects with enhanced animation
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

setupHoverEffect(VerifyBtn, 
    Color3.fromRGB(60, 130, 240), 
    Color3.fromRGB(80, 150, 255), 
    Color3.fromRGB(120, 180, 255), 
    Color3.fromRGB(140, 200, 255)
)

setupHoverEffect(CloseBtn, 
    Color3.fromRGB(50, 65, 100), 
    Color3.fromRGB(70, 85, 120), 
    Color3.fromRGB(100, 150, 220), 
    Color3.fromRGB(120, 170, 240)
)

setupHoverEffect(ShowKeyBtn, 
    Color3.fromRGB(50, 70, 110), 
    Color3.fromRGB(60, 90, 140), 
    Color3.fromRGB(100, 160, 230), 
    Color3.fromRGB(120, 180, 250)
)

-- Input field hover effect
KeyBoxFrame.MouseEnter:Connect(function()
    tween(KeyBoxFrame.UIStroke, 0.2, {Color = Color3.fromRGB(100, 170, 240), Thickness = 2})
    tween(KeyBoxFrame, 0.2, {Position = KeyBoxFrame.Position - UDim2.new(0, 0, 0.005, 0)})
end)

KeyBoxFrame.MouseLeave:Connect(function()
    tween(KeyBoxFrame.UIStroke, 0.2, {Color = Color3.fromRGB(80, 140, 220), Thickness = 1.2})
    tween(KeyBoxFrame, 0.2, {Position = KeyBoxFrame.Position + UDim2.new(0, 0, 0.005, 0)})
end)

-- Enhanced TOAST NOTIFICATION
local function toast(msg, ok)
    local holder = Instance.new("Frame", ScreenGui)
    holder.Size = UDim2.new(0, 400, 0, 60)
    holder.Position = UDim2.new(0.5, -200, 1, 60)
    holder.BackgroundColor3 = ok and Color3.fromRGB(25, 70, 40) or Color3.fromRGB(70, 35, 40)
    holder.ZIndex = 10
    makeCorner(holder, 12)
    makeStroke(holder, ok and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(200, 70, 70), 2, 0.3)

    -- Add gradient to toast
    local ToastGradient = Instance.new("UIGradient", holder)
    ToastGradient.Rotation = 90
    ToastGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ok and Color3.fromRGB(35, 90, 55) or Color3.fromRGB(90, 45, 50)),
        ColorSequenceKeypoint.new(1, ok and Color3.fromRGB(25, 70, 40) or Color3.fromRGB(70, 35, 40))
    }

    -- Add pattern to toast
    local ToastPattern = Instance.new("ImageLabel", holder)
    ToastPattern.Size = UDim2.new(1, 0, 1, 0)
    ToastPattern.Image = "rbxassetid://6572596770"
    ToastPattern.ImageTransparency = 0.9
    ToastPattern.ScaleType = Enum.ScaleType.Tile
    ToastPattern.TileSize = UDim2.new(0, 40, 0, 40)
    ToastPattern.BackgroundTransparency = 1
    ToastPattern.ZIndex = 11

    local message = Instance.new("TextLabel", holder)
    message.Size = UDim2.new(1, -70, 1, 0)
    message.Position = UDim2.new(0, 60, 0, 0)
    message.Text = msg
    message.Font = Enum.Font.GothamMedium
    message.TextSize = 16
    message.TextColor3 = ok and Color3.fromRGB(180, 255, 200) or Color3.fromRGB(255, 180, 180)
    message.BackgroundTransparency = 1
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.ZIndex = 12

    local icon = Instance.new("ImageLabel", holder)
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 20, 0.5, -15)
    icon.BackgroundTransparency = 1
    icon.Image = ok and "rbxassetid://7072717770" or "rbxassetid://7072717852" -- Check/cross icons
    icon.ImageColor3 = message.TextColor3
    icon.ZIndex = 12

    -- Add progress bar for toast timeout
    local progressBar = Instance.new("Frame", holder)
    progressBar.Size = UDim2.new(1, 0, 0, 4)
    progressBar.Position = UDim2.new(0, 0, 1, -4)
    progressBar.BackgroundColor3 = message.TextColor3
    progressBar.BorderSizePixel = 0
    progressBar.ZIndex = 12
    makeCorner(progressBar, 2)

    tween(holder, 0.4, {Position = UDim2.new(0.5, -200, 1, -80)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tween(progressBar, 2.5, {Size = UDim2.new(0, 0, 0, 4)})
    
    task.delay(2.5, function()
        tween(holder, 0.4, {Position = UDim2.new(0.5, -200, 1, 60)})
        task.wait(0.4)
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
            tween(Main, 0.1, {Size = UDim2.new(0, 495, 0, 545)})
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
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            tween(Main, 0.1, {Size = UDim2.new(0, 500, 0, 550)})
        end
    end)
end

-- ENHANCED CONFIRM EXIT POPUP
local function confirmExit()
    local PopupOverlay = Instance.new("Frame", ScreenGui)
    PopupOverlay.Size = UDim2.new(1, 0, 1, 0)
    PopupOverlay.BackgroundColor3 = Color3.fromRGB(10, 15, 30)
    PopupOverlay.BackgroundTransparency = 0.6
    PopupOverlay.ZIndex = 10
    
    local Popup = Instance.new("Frame", PopupOverlay)
    Popup.Size = UDim2.new(0, 400, 0, 240)
    Popup.Position = UDim2.new(0.5, -200, 0.5, -120)
    Popup.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
    Popup.BackgroundTransparency = 0.1
    Popup.ZIndex = 11
    makeCorner(Popup, 16)
    makeStroke(Popup, Color3.fromRGB(80, 140, 220), 2, 0.4)
    
    -- Add glass effect to popup
    local PopupGlass = Instance.new("Frame", Popup)
    PopupGlass.Size = UDim2.new(1, 0, 1, 0)
    PopupGlass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PopupGlass.BackgroundTransparency = 0.95
    PopupGlass.BorderSizePixel = 0
    PopupGlass.ZIndex = 12
    makeCorner(PopupGlass, 16)
    
    -- Add pattern to popup
    local PopupPattern = Instance.new("ImageLabel", Popup)
    PopupPattern.Size = UDim2.new(1, 0, 1, 0)
    PopupPattern.Image = "rbxassetid://6572596770"
    PopupPattern.ImageTransparency = 0.95
    PopupPattern.ScaleType = Enum.ScaleType.Tile
    PopupPattern.TileSize = UDim2.new(0, 50, 0, 50)
    PopupPattern.BackgroundTransparency = 1
    PopupPattern.ZIndex = 12
    
    local Title = Instance.new("TextLabel", Popup)
    Title.Size = UDim2.new(1, -20, 0, 60)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.Text = "Confirm Exit"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24
    Title.TextColor3 = Color3.fromRGB(230, 240, 255)
    Title.BackgroundTransparency = 1
    Title.ZIndex = 13
    
    local Message = Instance.new("TextLabel", Popup)
    Message.Size = UDim2.new(1, -20, 0, 80)
    Message.Position = UDim2.new(0, 10, 0, 70)
    Message.Text = "Are you sure you want to close the key system? Any unsaved progress will be lost."
    Message.Font = Enum.Font.Gotham
    Message.TextSize = 16
    Message.TextColor3 = Color3.fromRGB(180, 200, 230)
    Message.BackgroundTransparency = 1
    Message.TextWrapped = true
    Message.ZIndex = 13
    
    local ButtonContainer = Instance.new("Frame", Popup)
    ButtonContainer.Size = UDim2.new(1, -20, 0, 60)
    ButtonContainer.Position = UDim2.new(0, 10, 1, -70)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.ZIndex = 13
    
    local YesBtn = Instance.new("TextButton", ButtonContainer)
    YesBtn.Size = UDim2.new(0.45, 0, 1, 0)
    YesBtn.Position = UDim2.new(0, 0, 0, 0)
    YesBtn.Text = "YES, EXIT"
    YesBtn.Font = Enum.Font.GothamBold
    YesBtn.TextSize = 16
    YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    YesBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    YesBtn.AutoButtonColor = false
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
    NoBtn.Text = "NO, STAY"
    NoBtn.Font = Enum.Font.GothamBold
    NoBtn.TextSize = 16
    NoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 230)
    NoBtn.AutoButtonColor = false
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
    
    setupHoverEffect(YesBtn, 
        Color3.fromRGB(220, 80, 80), 
        Color3.fromRGB(240, 100, 100), 
        Color3.fromRGB(250, 120, 120), 
        Color3.fromRGB(255, 140, 140)
    )
    
    setupHoverEffect(NoBtn, 
        Color3.fromRGB(70, 140, 230), 
        Color3.fromRGB(90, 160, 250), 
        Color3.fromRGB(120, 180, 255), 
        Color3.fromRGB(140, 200, 255)
    )
    
    YesBtn.MouseButton1Click:Connect(function()
        tween(Main, 0.5, {
            Size = UDim2.new(0, 0, 0, 0), 
            Position = UDim2.new(0.5, 0, 0.5, 0), 
            BackgroundTransparency = 1
        })
        tween(blur, 0.5, {Size = 0})
        task.wait(0.5)
        ScreenGui:Destroy()
        blur:Destroy()
        ambient:Destroy()
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
        if k == v then
            return true
        end
    end
    return false
end

-- ENHANCED VERIFY BUTTON FUNCTION with improved loading animation
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
    loadingStroke.Transparency = 0.2
    
    -- Add glow to loading circle
    local loadingGlow = Instance.new("ImageLabel", loadingCircle)
    loadingGlow.Size = UDim2.new(2, 0, 2, 0)
    loadingGlow.Position = UDim2.new(-0.5, 0, -0.5, 0)
    loadingGlow.BackgroundTransparency = 1
    loadingGlow.Image = "rbxassetid://5021865973"
    loadingGlow.ImageColor3 = Color3.fromRGB(150, 200, 255)
    loadingGlow.ImageTransparency = 0.8
    loadingGlow.ZIndex = 3
    
    local rotation = 0
    local connection
    connection = RunService.RenderStepped:Connect(function(delta)
        rotation = (rotation + delta * 360) % 360
        loadingStroke.Rotation = rotation
    end)
    
    -- Simulate network delay
    task.wait(1.2)
    
    if isValidKey(key) then
        connection:Disconnect()
        loadingContainer:Destroy()
        
        -- Success animation
        toast("Key verified successfully! Loading menu...", true)
        
        -- Add success checkmark animation
        VerifyBtn.Text = "SUCCESS!"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
        VerifyBtn.UIStroke.Color = Color3.fromRGB(120, 255, 150)
        
        local checkmark = Instance.new("ImageLabel", VerifyBtn)
        checkmark.Size = UDim2.new(0, 30, 0, 30)
        checkmark.Position = UDim2.new(0.5, -15, 0.5, -15)
        checkmark.Image = "rbxassetid://7072717770"
        checkmark.ImageColor3 = Color3.fromRGB(255, 255, 255)
        checkmark.BackgroundTransparency = 1
        checkmark.ZIndex = 5
        
        tween(checkmark, 0.3, {Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0.5, -20, 0.5, -20)})
        
        task.wait(1.5)
        
        -- Animate success before loading menu
        tween(Main, 0.7, {
            Size = UDim2.new(0, 0, 0, 0), 
            Position = UDim2.new(0.5, 0, 0.5, 0), 
            BackgroundTransparency = 1
        })
        tween(blur, 0.7, {Size = 0})
        task.wait(0.7)
        ScreenGui:Destroy()
        blur:Destroy()
        ambient:Destroy()
        
        loadstring(game:HttpGet(MenuLoadURL))()
    else
        connection:Disconnect()
        loadingContainer:Destroy()
        
        toast("Invalid key. Please check and try again.", false)
        
        -- Reset button state
        VerifyBtn.Text = "VERIFY KEY"
        VerifyBtn.AutoButtonColor = true
        tween(VerifyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(60, 130, 240)})
        
        -- Enhanced shake animation for invalid key
        local shakeTime = 0.4
        local shakeIntensity = 8
        local originalPosition = KeyBoxFrame.Position
        
        for i = 1, 4 do
            tween(KeyBoxFrame, shakeTime/8, {
                Position = originalPosition + UDim2.new(0, shakeIntensity, 0, 0),
                Rotation = 2
            })
            task.wait(shakeTime/8)
            tween(KeyBoxFrame, shakeTime/8, {
                Position = originalPosition - UDim2.new(0, shakeIntensity, 0, 0),
                Rotation = -2
            })
            task.wait(shakeTime/8)
        end
        
        tween(KeyBoxFrame, shakeTime/8, {
            Position = originalPosition,
            Rotation = 0
        })
    end
end)

-- Initial enhanced animation
Main.Position = UDim2.new(0.5, -250, 0.4, -275)
Main.BackgroundTransparency = 1
Main.Size = UDim2.new(0, 10, 0, 10)
Main.Rotation = -5

tween(Main, 0.8, {
    Position = UDim2.new(0.5, -250, 0.5, -275), 
    BackgroundTransparency = 0.15, 
    Size = UDim2.new(0, 500, 0, 550),
    Rotation = 0
}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

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
