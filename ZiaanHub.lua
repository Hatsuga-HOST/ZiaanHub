-- // ZiaanHub Loader UI
-- Key System Stylish Ocean Dark
-- By ZiaanStore

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- GUI utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

-- Frame utama
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 280)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(15,25,35)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Corner
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 15)

-- Gradient stylish
local UIGradient = Instance.new("UIGradient", MainFrame)
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,80,130)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10,15,25))
}
UIGradient.Rotation = 45

-- Logo
local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 90, 0, 90)
Logo.Position = UDim2.new(0.5, -45, 0, 15)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://134650706258031" -- ganti asset id logo
Logo.Parent = MainFrame
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 20)

-- Judul
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 115)
Title.Text = "ZiaanHub Key System"
Title.TextColor3 = Color3.fromRGB(200,230,255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- Input Key
local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.8, 0, 0, 40)
KeyBox.Position = UDim2.new(0.1, 0, 0, 160)
KeyBox.PlaceholderText = "Masukkan Key..."
KeyBox.Text = ""
KeyBox.BackgroundColor3 = Color3.fromRGB(25,40,60)
KeyBox.TextColor3 = Color3.fromRGB(255,255,255)
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 16
KeyBox.Parent = MainFrame
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 10)

-- Tombol Verify
local CheckBtn = Instance.new("TextButton")
CheckBtn.Size = UDim2.new(0.5, 0, 0, 40)
CheckBtn.Position = UDim2.new(0.25, 0, 0, 210)
CheckBtn.Text = "Verify Key"
CheckBtn.BackgroundColor3 = Color3.fromRGB(0,150,255)
CheckBtn.TextColor3 = Color3.fromRGB(255,255,255)
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.TextSize = 16
CheckBtn.Parent = MainFrame
Instance.new("UICorner", CheckBtn).CornerRadius = UDim.new(0, 10)

-- Tombol X
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

-- Tombol minimize (–)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -70, 0, 5)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(80,150,200)
MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.Parent = MainFrame
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)

-- // Close permanent
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- // Minimize
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        for _,v in ipairs(MainFrame:GetChildren()) do
            if v ~= MinBtn and v ~= CloseBtn then
                v.Visible = false
            end
        end
        MainFrame.Size = UDim2.new(0,120,0,40)
    else
        for _,v in ipairs(MainFrame:GetChildren()) do
            v.Visible = true
        end
        MainFrame.Size = UDim2.new(0,420,0,280)
    end
end)

-- // Key System
local keyURL = "https://pastebin.com/raw/3vaUdQ30" -- ganti url raw key
local correctKey = game:HttpGet(keyURL)

CheckBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text == correctKey then
        Title.Text = "Key Valid! Loading Hub..."
        wait(1)
        ScreenGui:Destroy()
        -- // Load Hub (langsung pakai loadstring)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MajestySkie/list/refs/heads/main/games"))()
    else
        Title.Text = "Key Salah! Coba Lagi."
    end
end)
