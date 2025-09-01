-- ZiaanHub Key System (Professional Dark Blue) - Orion Library (English)

-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- CONFIG
local KeyLink = "https://pastebin.com/raw/3vaUdQ30" -- replace with your key list link
local MenuLoadURL = "https://raw.githubusercontent.com/MajestySkie/list/refs/heads/main/games"

-- Function to check key
local function checkKey(userKey)
    local success, response = pcall(function()
        return game:HttpGet(KeyLink)
    end)
    
    if success then
        for key in response:gmatch("[^\r\n]+") do
            if userKey == key then
                return true
            end
        end
        return false
    else
        warn("Failed to fetch key list from server.")
        return false
    end
end

-- Create Orion Window with Professional Dark Blue Theme
local Window = OrionLib:MakeWindow({
    Name = "ZiaanHub",
    HidePremium = false,
    SaveConfig = true,
    IntroText = "Welcome to ZiaanHub.\nPlease enter your key to access the main menu.",
    MainColor = Color3.fromRGB(10, 25, 80),  -- Dark Blue
    MinimizeIcon = "rbxassetid://6031094674",
    IntroIcon = "rbxassetid://4483345998",
})

-- Key Input Tab
local Tab = Window:MakeTab({
    Name = "Key Login",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Textbox for entering key
Tab:AddTextbox({
    Name = "Enter Key",
    Default = "",
    TextDisappear = true,
    Callback = function(text)
        local valid = checkKey(text)
        if valid then
            OrionLib:MakeNotification({
                Name = "Key Valid",
                Content = "Your key has been verified successfully.\nThe main menu will now load.",
                Image = "rbxassetid://4483345998",
                Time = 3,
                TitleColor = Color3.fromRGB(0, 170, 255)
            })
            
            -- Load main menu from GitHub
            local success, menuCode = pcall(function()
                return game:HttpGet(MenuLoadURL)
            end)
            
            if success then
                loadstring(menuCode)()
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Failed to load the main menu. Please try again.",
                    Image = "rbxassetid://4483345998",
                    Time = 3,
                    TitleColor = Color3.fromRGB(255, 50, 50)
                })
            end
        else
            OrionLib:MakeNotification({
                Name = "Invalid Key",
                Content = "The key you entered was not found.\nPlease check and try again.",
                Image = "rbxassetid://4483345998",
                Time = 3,
                TitleColor = Color3.fromRGB(255, 50, 50)
            })
        end
    end
})
