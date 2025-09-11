local games = {
    [126244816328678] = "https://raw.githubusercontent.com/MajestySkie/DIG/refs/heads/main/DigDigDig.lua",
    [137123819476589] = "https://raw.githubusercontent.com/MajestySkie/Prospecting/refs/heads/main/Prscting.lua",
}

local currentID = game.PlaceId
local scriptURL = games[currentID]

if scriptURL then
    loadstring(game:HttpGet(scriptURL))()
else
    game.Players.LocalPlayer:Kick("Yo! This game ain't on the list.\nCheck the Discord for whitelisted games, homie.")
end
