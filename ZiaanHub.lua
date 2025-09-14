local Gunung = loadstring(game:HttpGet("https://raw.githubusercontent.com/Hatsuga-HOST/ZiaanHub/refs/heads/main/Mount.lua"))()
local Tower = loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/GameList.lua"))()

local URL = Gunung[game.PlaceId]
local URL = Tower[game.PlaceId]

if URL then
  loadstring(game:HttpGet(URL))()
end
