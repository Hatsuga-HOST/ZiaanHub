local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Main Window
local Window = Rayfield:CreateWindow({
Name = "ZiaanHub",
Icon = 125501079062147, -- Roblox asset ID (ganti kalau ga muncul)
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
    Note = "Key Nya lol !",  
    FileName = "ziaanhubkey",  
    SaveKey = false, -- biar user ga usah masukin ulang key setiap buka  
    GrabKeyFromSite = true, -- ambil key dari Pastebin  
    Key = "https://pastebin.com/raw/3vaUdQ30"  
}

})

-- Tab "Home"
local Tab = Window:CreateTab("Home", nil) -- Title, Image
local MainSection = MainTab:CreateSection("Main")

-- Contoh Notifikasi
Rayfield:Notify({
Title = "ZiaanHub",
Content = "ZiaanHub Active",
Duration = 5,
Image = nil,
Actions = {
Ignore = {
Name = "Okay",
Callback = function()
print("The user tapped okay")
end
}
}
})

local Button = MainTab:CreateButton({
Name = "Infinite Jump",
Callback = function()
Name = "Infinite Jump",
Callback = function()
--Toggles the infinite jump between on or off on every script run
_G.infinjump = not _G.infinjump

if _G.infinJumpStarted == nil then  
    --Ensures this only runs once to save resources  
    _G.infinJumpStarted = true  

    --Notifies readiness  
    game.StarterGui:SetCore("SendNotification", {Title="Youtube Hub"; Text="Infinite Jump Activated!"; Duration=5;})  

    --The actual infinite jump  
    local plr = game:GetService("Players").LocalPlayer  
    local m = plr:GetMouse()  
    m.KeyDown:connect(function(k)  
        if _G.infinjump then  
            if k:byte() == 32 then  
                humanoid = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")  
                humanoid:ChangeState("Jumping")  
                wait()  
                humanoid:ChangeState("Seated")  
            end  
        end  
    end)  
end

end,
})
