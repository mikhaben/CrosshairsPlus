--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Utils.lua - Utility functions and helpers
]]--

local AddonName, CPlusNS = ...

-- Round number to specified decimal places
function CPlusNS.Round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end
