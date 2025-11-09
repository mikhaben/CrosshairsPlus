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

-- Create a simple deep copy
if not CPlusNS.DeepCopy then
    function CPlusNS.DeepCopy(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[CPlusNS.DeepCopy(orig_key)] = CPlusNS.DeepCopy(orig_value)
            end
            setmetatable(copy, CPlusNS.DeepCopy(getmetatable(orig)))
        else
            copy = orig
        end
        return copy
    end
end
