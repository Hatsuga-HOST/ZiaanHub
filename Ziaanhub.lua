if game.PlaceId == 126884695634066 then

    -- Load Rayfield Library
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    -- Create Main Window
    local Window = Rayfield:CreateWindow({
        Name = "ZiaanHub",
        Icon = 79162384088889, -- Roblox asset ID (ganti kalau ga muncul)
        LoadingTitle = "ZiaanHub Interface Suite",
        LoadingSubtitle = "by ZiaanStore",
        ShowText = "ZiaanHub", -- teks untuk toggle UI di mobile
        Theme = "Ocean",

        ToggleUIKeybind = "K", -- Keybind untuk show/hide UI

        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,

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
            Note = "Ambil Key dari Discord!",
            FileName = "ziaanhubkey",
            SaveKey = true, -- biar user ga usah masukin ulang key setiap buka
            GrabKeyFromSite = true, -- ambil key dari Pastebin
            Key = "https://pastebin.com/raw/3vaUdQ30"
        }
    })

end
