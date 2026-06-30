-- Main.lua - LUXURY HUB v20
-- Запусти только этот файл!

local function Load(src)
    return loadstring(game:HttpGet(src))()
end

-- Если используешь как один файл - просто inline всё:
local Core       = require(game.ReplicatedStorage.LuxuryHub.Core)
local Components = require(game.ReplicatedStorage.LuxuryHub.Components)
local Features   = require(game.ReplicatedStorage.LuxuryHub.Features)
local Window     = require(game.ReplicatedStorage.LuxuryHub.Window)

Window.Build()

-- Re-enable features on respawn
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    for _,tab in ipairs(Features.TABS) do
        for _,item in ipairs(tab.items) do
            if item.state then pcall(item.enable, item) end
        end
    end
end)

print("LUXURY HUB v20 - Loaded!")
