local Gunung = loadstring(game:HttpGet("https://raw.githubusercontent.com/Hatsuga-HOST/ZiaanHub/refs/heads/main/Mount.lua"))()
local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/Hatsuga-HOST/ZiaanHub/refs/heads/main/Games.lua"))()

local URL = Gunung[game.PlaceId] or Tower[game.PlaceId]

if URL then
    loadstring(game:HttpGet(URL))()
else
    warn("Error Bro")
end
