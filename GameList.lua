local games = {
    [102234703920418] = "https://raw.githubusercontent.com/Hatsuga-HOST/ZiaanHub/refs/heads/main/Gunung/AutoSummit/GunungDaun/utm.lua",
    [137123819476589] = "https://raw.githubusercontent.com/Hatsuga-HOST/ZiaanHub/refs/heads/main/Gunung/AutoSummit/GunungSakahayang/Csx.lua"
}

local currentID = game.PlaceId
local scriptURL = games[currentID]

if scriptURL then
    -- Gunakan pcall untuk menangani error saat loading script
    local success, result = pcall(function()
        return loadstring(game:HttpGet(scriptURL, true))()
    end)
    
    if not success then
        warn("Error loading script: " .. result)
        game.Players.LocalPlayer:Kick("Failed to load script. Check console for details.")
    end
else
    -- Gunakan warn untuk logging dan kick dengan pesan yang jelas
    warn("Game not supported: " .. currentID)
    game.Players.LocalPlayer:Kick("Game ini tidak didukung. Silakan cek Discord untuk daftar game yang diwhitelist.")
end
