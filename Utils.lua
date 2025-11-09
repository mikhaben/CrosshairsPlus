--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Utils.lua - Utility functions and helpers
]]--

local AddonName, CPlusNS = ...

-- Validate settings structure
function CPlusNS.ValidateSettings(db)
    if not db then
        return false
    end

    -- Ensure boolean values are booleans
    local booleanFields = {
        "showEnemyPlayers",
        "showFriendlyPlayers",
        "showHostileNPCs",
        "showFriendlyNPCs",
        "showCritters",
        "showRange",
        "showName",
        "enableClassColors",
        "showLines",
    }

    for _, field in ipairs(booleanFields) do
        if type(db[field]) ~= "boolean" then
            db[field] = false
        end
    end

    -- Ensure numeric values are numbers and within range
    if type(db.lineThickness) ~= "number" or db.lineThickness < 1 or db.lineThickness > 10 then
        db.lineThickness = 2
    end

    if type(db.crosshairScale) ~= "number" or db.crosshairScale < 0.5 or db.crosshairScale > 2.0 then
        db.crosshairScale = 1.0
    end

    if type(db.crosshairAlpha) ~= "number" or db.crosshairAlpha < 0 or db.crosshairAlpha > 1.0 then
        db.crosshairAlpha = 1.0
    end

    -- Ensure string values are strings
    if type(db.arrowStyle) ~= "string" then
        db.arrowStyle = "rotating"
    end

    if type(db.visualStyle) ~= "string" then
        db.visualStyle = "default"
    end

    return true
end

-- Round number to specified decimal places
function CPlusNS.Round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Clamp value between min and max
function CPlusNS.Clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    end
    return value
end

-- Format color as hex string
function CPlusNS.ColorToHex(r, g, b)
    return string.format("%02x%02x%02x",
        CPlusNS.Round(r * 255),
        CPlusNS.Round(g * 255),
        CPlusNS.Round(b * 255)
    )
end

-- Parse hex color to RGB
function CPlusNS.HexToColor(hex)
    hex = hex:gsub("#", "")
    if #hex == 6 then
        local r = tonumber(hex:sub(1, 2), 16) / 255
        local g = tonumber(hex:sub(3, 4), 16) / 255
        local b = tonumber(hex:sub(5, 6), 16) / 255
        return r, g, b
    end
    return 1, 1, 1 -- Default white
end

-- Print colored message to chat
function CPlusNS.Print(msg, r, g, b)
    local color = ""
    if r and g and b then
        color = "|cff" .. CPlusNS.ColorToHex(r, g, b)
    else
        color = "|cff00ff00" -- Default green
    end

    print(color .. "CrosshairsPlus|r: " .. msg)
end

-- Print error message
function CPlusNS.PrintError(msg)
    CPlusNS.Print(msg, 1, 0, 0)
end

-- Print warning message
function CPlusNS.PrintWarning(msg)
    CPlusNS.Print(msg, 1, 0.5, 0)
end

-- Get class color as RGB
function CPlusNS.GetClassColor(class)
    if not class then
        return 1, 1, 1
    end

    if RAID_CLASS_COLORS[class] then
        local color = RAID_CLASS_COLORS[class]
        return color.r, color.g, color.b
    end

    return 1, 1, 1
end

-- Check if unit is valid and exists
function CPlusNS.IsValidUnit(unit)
    return unit and UnitExists(unit) and not UnitIsUnit(unit, "player")
end

-- Get unit type string (for debugging)
function CPlusNS.GetUnitType(unit)
    if not CPlusNS.IsValidUnit(unit) then
        return "invalid"
    end

    if UnitIsPlayer(unit) then
        return "player"
    end

    local classification = UnitClassification(unit)
    if classification == "trivial" or classification == "minus" then
        return "critter"
    end

    if UnitCanAttack("player", unit) then
        return "hostile_npc"
    else
        return "friendly_npc"
    end
end

-- Safe call wrapper with error handling
function CPlusNS.SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        CPlusNS.PrintError("Error: " .. tostring(result))
        return nil
    end
    return result
end

-- Table contains value check
function CPlusNS.TableContains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- Get table size (for tables with non-numeric keys)
function CPlusNS.TableSize(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- Debug print (only if debug mode is enabled)
function CPlusNS.Debug(msg)
    if CPlusNS.db and CPlusNS.db.debugMode then
        print("|cff888888[DEBUG]|r " .. tostring(msg))
    end
end

-- Format time in seconds to readable string
function CPlusNS.FormatTime(seconds)
    if seconds < 60 then
        return string.format("%.1fs", seconds)
    elseif seconds < 3600 then
        local minutes = math.floor(seconds / 60)
        local secs = seconds % 60
        return string.format("%dm %ds", minutes, secs)
    else
        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        return string.format("%dh %dm", hours, minutes)
    end
end

-- Create a simple deep copy (already defined in Core.lua, but available here too)
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
