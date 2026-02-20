--[[
    CrosshairsPlus - Range Tab (AceConfig)
    Range display options — flat layout
]]--

local AddonName, CPlusNS = ...

function CPlusNS.BuildRangeTab()
    return {
        type = "group",
        name = "Range",
        order = 5,
        args = {
            -- Display
            showRange = {
                type = "toggle",
                name = "Enable Range Display",
                desc = "Show estimated distance (in yards) to the current target",
                order = 1,
                width = "full",
                get = function() return CPlusNS.db.showRange end,
                set = function(_, v) CPlusNS.db.showRange = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            rangeUseTargetColor = {
                type = "toggle",
                name = "Use Crosshair Color",
                desc = "Match range text color to the crosshair color instead of white",
                order = 2,
                width = "full",
                disabled = function() return not CPlusNS.db.showRange end,
                get = function() return CPlusNS.db.rangeUseTargetColor end,
                set = function(_, v) CPlusNS.db.rangeUseTargetColor = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            spacer1 = {
                type = "description",
                name = " ",
                order = 3,
            },
            -- Font
            rangeFont = CPlusNS.BuildFontSelect("rangeFont", 4, function() return not CPlusNS.db.showRange end),
            rangeFontSize = {
                type = "range",
                name = "Font Size",
                desc = "Adjust the size of the range text (8-30)",
                order = 5,
                min = 8, max = 30, step = 1,
                disabled = function() return not CPlusNS.db.showRange end,
                get = function() return CPlusNS.db.rangeFontSize end,
                set = function(_, v) CPlusNS.db.rangeFontSize = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            spacer2 = {
                type = "description",
                name = " ",
                order = 6,
            },
            -- Position
            rangePosition = {
                type = "select",
                name = "Anchor",
                desc = "Where to anchor the range text relative to the crosshair",
                order = 7,
                values = {
                    BOTTOM = "Bottom",
                    TOP = "Top",
                    LEFT = "Left",
                    RIGHT = "Right",
                },
                sorting = {"BOTTOM", "TOP", "LEFT", "RIGHT"},
                disabled = function() return not CPlusNS.db.showRange end,
                get = function() return CPlusNS.db.rangePosition end,
                set = function(_, v) CPlusNS.db.rangePosition = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            rangeXOffset = {
                type = "range",
                name = "X Offset",
                desc = "Horizontal offset for the range text (-100 to 100)",
                order = 8,
                min = -100, max = 100, step = 1,
                disabled = function() return not CPlusNS.db.showRange end,
                get = function() return CPlusNS.db.rangeXOffset end,
                set = function(_, v) CPlusNS.db.rangeXOffset = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            rangeYOffset = {
                type = "range",
                name = "Y Offset",
                desc = "Vertical offset for the range text (-100 to 100)",
                order = 9,
                min = -100, max = 100, step = 1,
                disabled = function() return not CPlusNS.db.showRange end,
                get = function() return CPlusNS.db.rangeYOffset end,
                set = function(_, v) CPlusNS.db.rangeYOffset = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
        },
    }
end
