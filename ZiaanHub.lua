local Gunung = loadstring(game:HttpGet("https://raw.githubusercontent.com/Hatsuga-HOST/ZiaanHub/refs/heads/main/Games.lua"))()

local URL = Gunung[game.PlaceId]

if URL then
    loadstring(game:HttpGet(URL))()
else
    warn("Error Bro")
end
