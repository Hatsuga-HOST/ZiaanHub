-- ZiaanHub Key System dengan Orion Library
-- By ZiaanStore © 2025

-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- CONFIG 
local KeyLink = "https://pastebin.com/raw/3vaUdQ30" 
local MenuLoadURL = "https://raw.githubusercontent.com/MajestySkie/list/refs/heads/main/games" 

-- Fungsi untuk memotong spasi
local function trim(s) 
    return (s or ""):gsub("^%s+", ""):gsub("%s+$", "") 
end 

-- Ambil kunci valid dari pastebin
local ValidKeys = {}
local function loadValidKeys()
    local success, result = pcall(function()
        return game:HttpGet(KeyLink)
    end)
    
    if success and result then
        for line in result:gmatch("[^\r\n]+") do
            local key = trim(line)
            if #key > 0 then
                table.insert(ValidKeys, key)
            end
        end
        return true
    else
        return false
    end
end

-- Muat kunci valid
local keysLoaded = loadValidKeys()

-- Fungsi validasi kunci
local function isValidKey(inputKey)
    inputKey = trim(inputKey or "")
    for _, validKey in ipairs(ValidKeys) do
        if inputKey == validKey then
            return true
        end
    end
    return false
end

-- Buat window Orion
local Window = OrionLib:MakeWindow({
    Name = "ZIAANHUB ACCESS",
    HidePremium = false,
    SaveConfig = false,
    IntroEnabled = false,
    ConfigFolder = "ZiaanHub"
})

-- Buat tab utama
local MainTab = Window:MakeTab({
    Name = "Key System",
    Icon = "rbxassetid://7072716642",
    PremiumOnly = false
})

-- Header
MainTab:AddParagraph("Welcome", "Welcome to ZiaanHub Premium. Enter your key to access exclusive features.")

if not keysLoaded then
    MainTab:AddParagraph("Warning", "Failed to load valid keys. Please check your connection.")
end

-- Input key
local KeyInput = MainTab:AddTextbox({
    Name = "Access Key",
    Default = "",
    TextDisappear = false,
    Callback = function(value)
        -- Callback untuk textbox
    end
})

-- Tombol verifikasi
MainTab:AddButton({
    Name = "VERIFY KEY",
    Callback = function()
        local key = trim(KeyInput.Value)
        
        if key == "" then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Please enter a key",
                Image = "rbxassetid://7072717852",
                Time = 3
            })
            return
        end
        
        -- Tampilkan notifikasi loading
        OrionLib:MakeNotification({
            Name = "Verifying",
            Content = "Checking your key...",
            Image = "rbxassetid://7072716642",
            Time = 2
        })
        
        -- Verifikasi kunci
        if isValidKey(key) then
            OrionLib:MakeNotification({
                Name = "Success",
                Content = "Key verified! Loading menu...",
                Image = "rbxassetid://7072717770",
                Time = 3
            })
            
            -- Tunggu sebentar lalu tutup window dan muat menu
            wait(2)
            OrionLib:Destroy()
            loadstring(game:HttpGet(MenuLoadURL))()
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Invalid key. Please try again.",
                Image = "rbxassetid://7072717852",
                Time = 3
            })
        end
    end
})

-- Footer
MainTab:AddParagraph("Footer", "ZiaanStore © 2025 | Edition v2.1")

-- Inisialisasi Orion
OrionLib:Init()

-- Tambahkan handler untuk tombol ESC
game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Escape then
        OrionLib:Destroy()
    end
end)
