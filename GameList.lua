local games = {
    [102234703920418] = "https://raw.githubusercontent.com/Hatsuga-HOST/ZiaanHub/refs/heads/main/Gunung/AutoSummit/GunungDaun/utm.lua",
    [137123819476589] = "https://raw.githubusercontent.com/Hatsuga-HOST/ZiaanHub/refs/heads/main/Gunung/AutoSummit/GunungSakahayang/Csx.lua",
}

local currentID = game.PlaceId
local scriptURL = games[currentID]

if scriptURL then
    loadstring(game:HttpGet(scriptURL))()
else
    game.Players.LocalPlayer:Kick("Yo! This game ain't on the list.\nCheck the Discord for whitelisted games, homie.")
end
