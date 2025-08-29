-- ZiaanHub.lua
local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/ZiaanHub/main/KeySystem.lua"))()
local ZiaanUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/ZiaanHub/main/ZiaanUI.lua"))()

-- GUI Input Key
local ScreenGui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Position = UDim2.new(0.35, 0, 0.35, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local Box = Instance.new("TextBox", Frame)
Box.Size = UDim2.new(0.8, 0, 0, 40)
Box.Position = UDim2.new(0.1, 0, 0.2, 0)
Box.PlaceholderText = "Enter Key..."
Box.Text = ""
Box.TextColor3 = Color3.fromRGB(255,255,255)
Box.BackgroundColor3 = Color3.fromRGB(50,50,50)

local Btn = Instance.new("TextButton", Frame)
Btn.Size = UDim2.new(0.6, 0, 0, 40)
Btn.Position = UDim2.new(0.2, 0, 0.6, 0)
Btn.Text = "Submit Key"
Btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
Btn.TextColor3 = Color3.fromRGB(255,255,255)

Btn.MouseButton1Click:Connect(function()
    if KeySystem:Check(Box.Text) then
        ScreenGui:Destroy()
        
        -- Buka Main Hub
        local Main = ZiaanUI:CreateWindow("ZiaanHub")

        ZiaanUI:CreateButton(Main, "WalkSpeed 100", function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
        end)

        ZiaanUI:CreateButton(Main, "JumpPower 150", function()
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = 150
        end)

        ZiaanUI:CreateButton(Main, "Infinite Jump", function()
            game:GetService("UserInputService").JumpRequest:Connect(function()
                game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end)
        end)

        ZiaanUI:CreateButton(Main, "Fly", function()
            loadstring(game:HttpGet("https://pastebin.com/raw/Yk4yfy3P"))()
        end)
    else
        Box.Text = "❌ Wrong Key!"
    end
end)
