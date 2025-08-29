-- KeySystem.lua
local KeySystem = {}

KeySystem.Key = "ZiaanHubKey123" -- ganti key sesuai keinginan
KeySystem.Access = false

function KeySystem:Check(input)
    if input == self.Key then
        self.Access = true
        return true
    else
        return false
    end
end

return KeySystem
