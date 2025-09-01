-- ZiaanHub Key System (Premium Glass UI) dengan Orion Library
-- By ZiaanStore © 2025
-- Compact Glassmorphism Theme

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- CONFIG 
local KeyLink = "https://pastebin.com/raw/3vaUdQ30" 
local MenuLoadURL = "https://raw.githubusercontent.com/MajestySkie/list/refs/heads/main/games" 

-- SOUND ASSETS
local ClickSoundId = 84270429231946
local SuccessSoundId = 118763404331701
local FailSoundId = 139730102703190

-- SERVICES 
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInput = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

-- HELPERS 
local function playSound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Parent = SoundService
    sound:Play()
    game.Debris:AddItem(sound, sound.TimeLength + 1)
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

-- Create Orion window dengan tema glassmorphism
local Window = OrionLib:MakeWindow({
    Name = "ZIAANHUB ACCESS",
    HidePremium = false,
    IntroEnabled = false,
    SaveConfig = false,
    ConfigFolder = "ZiaanHub"
})

-- Tab utama
local Tab = Window:MakeTab({
    Name = "Key System",
    Icon = "rbxassetid://7072716642",
    PremiumOnly = false
})

-- Background blur effect
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
TweenService:Create(blur, TweenInfo.new(0.5), {Size = 20}):Play()

-- Fungsi untuk menutup window dengan animasi
local function closeWindow()
    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()
    OrionLib:Destroy()
end

-- Toast notification function
local function toast(msg, success)
    if success then
        playSound(SuccessSoundId)
    else
        playSound(FailSoundId)
    end
    
    OrionLib:MakeNotification({
        Name = success and "SUCCESS" or "ERROR",
        Content = msg,
        Image = success and "rbxassetid://7072717770" or "rbxassetid://7072717852",
        Time = 3
    })
end

-- Tambahkan elemen UI dengan gaya glassmorphism
Tab:AddParagraph("Welcome", "Welcome to ZiaanHub Premium. Enter your key to access exclusive features.")

local KeyInput = Tab:AddTextbox({
    Name = "Access Key",
    Default = "",
    TextDisappear = false,
    Callback = function(Value)
        -- Callback untuk textbox
    end
})

-- Custom styling untuk Orion UI
spawn(function()
    while not OrionLib.Flags do task.wait() end
    
    -- Temukan elemen UI Orion dan terapkan gaya glassmorphism
    for _, obj in pairs(OrionLib:GetUI().Gui:GetDescendants()) do
        if obj:IsA("Frame") then
            if obj.Name == "Main" or obj.Name == "Dialog" then
                obj.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
                obj.BackgroundTransparency = 0.2
                
                local uicorner = Instance.new("UICorner")
                uicorner.CornerRadius = UDim.new(0, 16)
                uicorner.Parent = obj
                
                local uistroke = Instance.new("UIStroke")
                uistroke.Thickness = 1.5
                uistroke.Color = Color3.fromRGB(100, 150, 220)
                uistroke.Transparency = 0.4
                uistroke.Parent = obj
                
                -- Glass effect
                local glassFrame = Instance.new("Frame")
                glassFrame.Size = UDim2.new(1, 0, 1, 0)
                glassFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                glassFrame.BackgroundTransparency = 0.95
                glassFrame.BorderSizePixel = 0
                glassFrame.ZIndex = 0
                glassFrame.Parent = obj
                
                local glassCorner = Instance.new("UICorner")
                glassCorner.CornerRadius = UDim.new(0, 16)
                glassCorner.Parent = glassFrame
            end
            
            if obj.Name == "TabSystem" then
                obj.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
                
                local uicorner = Instance.new("UICorner")
                uicorner.CornerRadius = UDim.new(0, 14)
                uicorner.Parent = obj
                
                -- Header gradient
                local headerGradient = Instance.new("UIGradient")
                headerGradient.Rotation = 90
                headerGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 55, 95)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 35, 60))
                }
                headerGradient.Parent = obj
            end
            
            if obj.Name == "ElementFrame" then
                obj.BackgroundTransparency = 1
            end
        end
        
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            if obj.Name == "Title" then
                obj.TextColor3 = Color3.fromRGB(230, 240, 255)
            elseif obj.Name == "ItemText" then
                obj.TextColor3 = Color3.fromRGB(200, 220, 255)
            end
        end
        
        if obj:IsA("TextBox") then
            obj.BackgroundColor3 = Color3.fromRGB(30, 40, 65)
            obj.TextColor3 = Color3.fromRGB(230, 240, 255)
            
            local uicorner = Instance.new("UICorner")
            uicorner.CornerRadius = UDim.new(0, 10)
            uicorner.Parent = obj
            
            local uistroke = Instance.new("UIStroke")
            uistroke.Thickness = 1.2
            uistroke.Color = Color3.fromRGB(80, 140, 220)
            uistroke.Parent = obj
            
            -- Input gradient
            local inputGradient = Instance.new("UIGradient")
            inputGradient.Rotation = 90
            inputGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 50, 80)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 40, 65))
            }
            inputGradient.Parent = obj
        end
        
        if obj:IsA("ImageButton") and obj.Name == "CloseButton" then
            obj.BackgroundColor3 = Color3.fromRGB(50, 65, 100)
            obj.Text = "×"
            obj.TextColor3 = Color3.fromRGB(220, 220, 240)
            
            local uicorner = Instance.new("UICorner")
            uicorner.CornerRadius = UDim.new(0, 8)
            uicorner.Parent = obj
            
            local uistroke = Instance.new("UIStroke")
            uistroke.Thickness = 1.2
            uistroke.Color = Color3.fromRGB(100, 150, 220)
            uistroke.Parent = obj
        end
    end
end)

-- Verify button
Tab:AddButton({
    Name = "VERIFY KEY",
    Callback = function()
        playSound(ClickSoundId)
        local key = trim(KeyInput.Value)
        
        if key == "" then
            toast("Please enter a key", false)
            return
        end
        
        -- Tampilkan loading state
        OrionLib:MakeNotification({
            Name = "VERIFYING",
            Content = "Checking your key...",
            Image = "rbxassetid://7072716642",
            Time = 5
        })
        
        -- Simulate network delay
        task.wait(0.5)
        
        if isValidKey(key) then
            toast("Key verified successfully! Loading menu...", true)
            task.wait(1)
            closeWindow()
            loadstring(game:HttpGet(MenuLoadURL))()
        else
            toast("Invalid key. Please check and try again.", false)
        end
    end
})

-- Footer
Tab:AddParagraph("Footer", "ZiaanStore © 2025 | Edition v2.1")

-- Close button handler
OrionLib:MakeNotification({
    Name = "ZIAANHUB",
    Content = "Press ESC to close the key system",
    Image = "rbxassetid://7072716642",
    Time = 5
})

UserInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Escape then
        playSound(ClickSoundId)
        closeWindow()
    end
end)

-- Init Orion
OrionLib:Init()
