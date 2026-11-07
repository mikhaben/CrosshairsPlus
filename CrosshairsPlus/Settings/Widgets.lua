local _, CPlusNS = ...

local LSM = CPlusNS.LSM

local function GetFontValues()
    local fonts = {}
    for k, v in pairs(LSM:HashTable("font")) do
        fonts[k] = v
    end
    fonts["Default"] = select(1, GameFontNormal:GetFont())
    return fonts
end

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
