-- ZiaanHub Key System Premium Glass UI + Particles + Sound v2
-- By ZiaanStore © 2025

-- CONFIG
local KeyLink = "https://pastebin.com/raw/3vaUdQ30"
local MenuLoadURL = "https://raw.githubusercontent.com/MajestySkie/list/refs/heads/main/games"

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- SOUND FUNCTION
local function makeSound(id,parent)
    local s = Instance.new("Sound",parent)
    s.SoundId = "rbxassetid://"..id
    s.Volume = 0.5
    return s
end

local ClickSound = makeSound(84270429231946, workspace)
local SuccessSound = makeSound(118763404331701, workspace)
local FailSound = makeSound(139730102703190, workspace)

-- SCREEN GUI
local ScreenGui = Instance.new("ScreenGui",Players.LocalPlayer:WaitForChild("PlayerGui"))

-- MAIN FRAME
local Main = Instance.new("Frame",ScreenGui)
Main.Size = UDim2.new(0,500,0,550)
Main.Position = UDim2.new(0.5,-250,0.5,-275)
Main.BackgroundColor3 = Color3.fromRGB(255,255,255)
Main.BackgroundTransparency = 0.9
Main.BorderSizePixel = 0
Main.ZIndex = 5

local UICorner = Instance.new("UICorner",Main)
UICorner.CornerRadius = UDim.new(0,20)

-- GLASS BLUR
local Blur = Instance.new("ImageLabel",Main)
Blur.Size = UDim2.new(1,0,1,0)
Blur.BackgroundTransparency = 1
Blur.Image = "rbxassetid://3570695787"
Blur.ImageColor3 = Color3.fromRGB(30,30,60)
Blur.ImageTransparency = 0.4
Blur.ScaleType = Enum.ScaleType.Slice
Blur.SliceCenter = Rect.new(100,100,100,100)
Blur.ZIndex = 1

-- SHADOW
local Shadow = Instance.new("ImageLabel",Main)
Shadow.Size = UDim2.new(1,30,1,30)
Shadow.Position = UDim2.new(0,-15,0,-15)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5024737430"
Shadow.ImageColor3 = Color3.fromRGB(0,0,0)
Shadow.ImageTransparency = 0.85
Shadow.ZIndex = 0

-- TITLE
local Title = Instance.new("TextLabel",Main)
Title.Size = UDim2.new(1,0,0,60)
Title.Position = UDim2.new(0,0,0,0)
Title.BackgroundTransparency = 1
Title.Text = "ZiaanHub Premium"
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.ZIndex = 5

-- TITLE GLOW
local Glow = Instance.new("UIStroke",Title)
Glow.Thickness = 2
Glow.Color = Color3.fromRGB(100,200,255)

-- KEY INPUT
local KeyInput = Instance.new("TextBox",Main)
KeyInput.Size = UDim2.new(0.8,0,0,45)
KeyInput.Position = UDim2.new(0.1,0,0.35,0)
KeyInput.PlaceholderText = "Masukkan Key Anda..."
KeyInput.BackgroundColor3 = Color3.fromRGB(50,65,100)
KeyInput.TextColor3 = Color3.fromRGB(255,255,255)
KeyInput.TextScaled = true
KeyInput.ClearTextOnFocus = false
local inputCorner = Instance.new("UICorner",KeyInput)
inputCorner.CornerRadius = UDim.new(0,12)
KeyInput.ZIndex = 6

-- VERIFY BUTTON
local VerifyBtn = Instance.new("TextButton",Main)
VerifyBtn.Size = UDim2.new(0.5,0,0,45)
VerifyBtn.Position = UDim2.new(0.25,0,0.5,0)
VerifyBtn.Text = "Verify Key"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextColor3 = Color3.fromRGB(255,255,255)
VerifyBtn.TextScaled = true
VerifyBtn.BackgroundColor3 = Color3.fromRGB(80,95,150)
local btnCorner = Instance.new("UICorner",VerifyBtn)
btnCorner.CornerRadius = UDim.new(0,12)
VerifyBtn.ZIndex = 6

-- TOAST FUNCTION
local function toast(msg,color)
    local T = Instance.new("TextLabel",ScreenGui)
    T.Size = UDim2.new(0,300,0,50)
    T.Position = UDim2.new(0.5,-150,0,50)
    T.BackgroundColor3 = color or Color3.fromRGB(100,100,100)
    T.TextColor3 = Color3.fromRGB(255,255,255)
    T.TextScaled = true
    T.Text = msg
    T.BackgroundTransparency = 0.2
    local tc = Instance.new("UICorner",T)
    tc.CornerRadius = UDim.new(0,10)
    T.ZIndex = 10
    tween(T,0.5,{Position=UDim2.new(0.5,-150,0,80),TextTransparency=0},Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
    delay(1.5,function()
        tween(T,0.5,{Position=UDim2.new(0.5,-150,0,50),TextTransparency=1},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
        delay(0.5,function() T:Destroy() end)
    end)
end

-- TWEEN FUNCTION
function tween(obj,time,props,style,dir)
    TweenService:Create(obj,TweenInfo.new(time or 0.5, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),props):Play()
end

-- DRAGGABLE
do
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging=true
            dragStart=input.Position
            startPos=Main.Position
            tween(Main,0.1,{Size=Main.Size+UDim2.new(0,10,0,10)})
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then
                    dragging=false
                    tween(Main,0.1,{Size=UDim2.new(0,500,0,550)})
                end
            end)
        end
    end)
    Main.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end
    end)
    UserInput.InputChanged:Connect(function(input)
        if input==dragInput and dragging then update(input) end
    end)
end

-- PARTICLE BACKGROUND
local ParticleHolder = Instance.new("Frame",Main)
ParticleHolder.Size = UDim2.new(1,0,1,0)
ParticleHolder.BackgroundTransparency = 1
ParticleHolder.ZIndex = 0

local particles = {}
for i=1,25 do
    local p = Instance.new("Frame",ParticleHolder)
    p.Size = UDim2.new(0,5,0,5)
    p.Position = UDim2.new(math.random(),0,math.random(),0)
    p.BackgroundColor3 = Color3.fromRGB(100,200,255)
    p.BackgroundTransparency = 0.6
    local c = Instance.new("UICorner",p)
    c.CornerRadius = UDim.new(0,2.5)
    table.insert(particles,p)
end

RunService.RenderStepped:Connect(function()
    for _,p in pairs(particles) do
        local pos = p.Position
        local y = pos.Y.Scale + 0.001*math.random()
        if y>1 then y=0 end
        p.Position = UDim2.new(pos.X.Scale,0,y,0)
    end
end)

-- VERIFY LOGIC
VerifyBtn.MouseButton1Click:Connect(function()
    ClickSound:Play()
    local key = KeyInput.Text
    spawn(function()
        local validKeys = {}
        for line in game:HttpGet(KeyLink):gmatch("[^\r\n]+") do
            table.insert(validKeys,line)
        end
        local isValid=false
        for _,v in pairs(validKeys) do
            if key==v then isValid=true break end
        end
        if isValid then
            SuccessSound:Play()
            toast("Key Valid! Loading Menu...", Color3.fromRGB(50,200,50))
            loadstring(game:HttpGet(MenuLoadURL))()
        else
            FailSound:Play()
            toast("Key Invalid!", Color3.fromRGB(200,50,50))
        end
    end)
end)
