--[[
    CrosshairsPlus - Settings Widgets
    Reusable AceConfig widget builders
]]--

local AddonName, CPlusNS = ...

local LSM = CPlusNS.LSM

-- Returns all LSM fonts plus a "Default" entry that uses the game's current font
local function GetFontValues()
    local fonts = {}
    for k, v in pairs(LSM:HashTable("font")) do
        fonts[k] = v
    end
    fonts["Default"] = select(1, GameFontNormal:GetFont())
    return fonts
end

-- Build a font selector AceConfig entry (uses LibSharedMedia font widget with preview)
-- dbKey: the CPlusNS.db key to read/write (e.g. "rangeFont")
-- order: display order in the tab
-- disabledFn: function returning true when the widget should be disabled
function CPlusNS.BuildFontSelect(dbKey, order, disabledFn)
    return {
        type = "select",
        name = "Font",
        desc = "Choose the font style",
        order = order,
        dialogControl = "LSM30_Font",
        values = GetFontValues,
        disabled = disabledFn,
        get = function() return CPlusNS.db[dbKey] end,
        set = function(_, v) CPlusNS.db[dbKey] = v; CPlusNS.UpdateCrosshairVisuals() end,
    }
end
