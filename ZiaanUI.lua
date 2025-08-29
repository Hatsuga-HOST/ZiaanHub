-- ZiaanUI.lua
local ZiaanUI = {}

function ZiaanUI:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 400, 0, 250)
    Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.BorderSizePixel = 0
    Frame.Name = title

    local Title = Instance.new("TextLabel", Frame)
    Title.Text = title
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18

    return Frame
end

function ZiaanUI:CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -20, 0, 40)
    Btn.Position = UDim2.new(0, 10, 0, (#parent:GetChildren() - 1) * 45 + 50)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = text
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 16
    Btn.MouseButton1Click:Connect(callback)
end

return ZiaanUI
