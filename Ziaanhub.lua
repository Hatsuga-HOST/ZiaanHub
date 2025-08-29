local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "ZiaanHub | Game",
    LoadingTitle = "ZiaanHub Interface Suite",
    LoadingSubtitle = "by Ziaan",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ZiaanHubData",
        FileName = "ZiaanHubConfig"
    },
    Discord = {
        Enabled = true,
        Invite = "vzbJt9XQ", -- Invite code Discord (tanpa discord.gg/)
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title = "ZiaanHub | Key System",
        Subtitle = "Masukin Key Dulu Gan",
        Note = "Key ada di Discord",
        FileName = "ZiaanHubKey",
        SaveKey = true,
        GrabKeyFromSite = true,
        Key = {"https://pastebin.com/raw/3vaUdQ30"}
    }
})

-- Tab Home
local MainTab = Window:CreateTab("Home", nil)
local MainSection = MainTab:CreateSection("Main")

Rayfield:Notify({
    Title = "ZiaanHub",
    Content = "Script berhasil dijalankan",
    Duration = 5,
    Image = nil,
    Actions = {
        Ignore = {
            Name = "Okay!",
            Callback = function()
                print("User tapped Okay!")
            end
        }
    }
})

-- Infinite Jump
MainTab:CreateButton({
    Name = "Infinite Jump Toggle",
    Callback = function()
        _G.infinjump = not _G.infinjump
        if _G.infinJumpStarted == nil then
            _G.infinJumpStarted = true
            game.StarterGui:SetCore("SendNotification", {Title="ZiaanHub"; Text="Infinite Jump Activated!"; Duration=5;})
            local plr = game:GetService("Players").LocalPlayer
            local m = plr:GetMouse()
            m.KeyDown:Connect(function(k)
                if _G.infinjump and k:byte() == 32 then
                    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState("Jumping")
                        task.wait()
                        humanoid:ChangeState("Seated")
                    end
                end
            end)
        end
    end
})

-- WalkSpeed Slider
MainTab:CreateSlider({
    Name = "WalkSpeed Slider",
    Range = {1, 350},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "sliderws",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end,
})

-- JumpPower Slider
MainTab:CreateSlider({
    Name = "JumpPower Slider",
    Range = {1, 350},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "sliderjp",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end,
})

-- Dropdown
MainTab:CreateDropdown({
    Name = "Select Area",
    Options = {"Starter World", "Pirate Island", "Pineapple Paradise"},
    CurrentOption = {"Starter World"},
    MultipleOptions = false,
    Flag = "dropdownarea",
    Callback = function(Option)
        print("Selected:", Option)
    end,
})

-- Input
MainTab:CreateInput({
    Name = "WalkSpeed Input",
    PlaceholderText = "1-500",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = num
        end
    end,
})

-- Section Other
local OtherSection = MainTab:CreateSection("Other")

-- Toggle Auto Farm
MainTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "ToggleAutoFarm",
    Callback = function(Value)
        if Value then
            print("Auto Farm ON")
        else
            print("Auto Farm OFF")
        end
    end,
})

-- Tab Teleports
local TPTab = Window:CreateTab("Teleports", nil)

TPTab:CreateButton({
    Name = "Starter Island",
    Callback = function()
        -- Teleport Starter Island
    end,
})

TPTab:CreateButton({
    Name = "Pirate Island",
    Callback = function()
        -- Teleport Pirate Island
    end,
})

TPTab:CreateButton({
    Name = "Pineapple Paradise",
    Callback = function()
        -- Teleport Pineapple Paradise
    end,
})

-- Tab Misc
local MiscTab = Window:CreateTab("Misc", nil)
