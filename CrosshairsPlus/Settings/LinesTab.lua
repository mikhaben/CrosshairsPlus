--[[
    CrosshairsPlus - Lines Tab (AceConfig)
    Crosshair lines display options — flat layout
]]--

local AddonName, CPlusNS = ...

function CPlusNS.BuildLinesTab()
    return {
        type = "group",
        name = "Lines",
        order = 3,
        args = {
            showLines = {
                type = "toggle",
                name = "Show Crosshair Lines",
                desc = "Display directional lines extending from crosshair",
                order = 1,
                width = "full",
                get = function() return CPlusNS.db.showLines end,
                set = function(_, v) CPlusNS.db.showLines = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            spacer1 = {
                type = "description",
                name = " ",
                order = 2,
            },
            lineStartGap = {
                type = "range",
                name = "Line Start Position",
                desc = "Adjust where lines start: negative values go toward center, positive values go outward from edge",
                order = 3,
                min = -48, max = 100, step = 2,
                disabled = function() return not CPlusNS.db.showLines end,
                get = function() return CPlusNS.db.lineStartGap end,
                set = function(_, v) CPlusNS.db.lineStartGap = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            lineThickness = {
                type = "range",
                name = "Line Thickness",
                desc = "Adjust the thickness of crosshair lines (1-10 pixels)",
                order = 4,
                min = 1, max = 10, step = 1,
                disabled = function() return not CPlusNS.db.showLines end,
                get = function() return CPlusNS.db.lineThickness end,
                set = function(_, v) CPlusNS.db.lineThickness = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
        },
    }
end
