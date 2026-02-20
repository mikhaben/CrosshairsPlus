--[[
    CrosshairsPlus - Target Info Tab (AceConfig)
    Target info display options — flat layout
]]--

local AddonName, CPlusNS = ...

function CPlusNS.BuildTargetInfoTab()
    return {
        type = "group",
        name = "Target Info",
        order = 6,
        args = {
            -- Display
            showTargetInfo = {
                type = "toggle",
                name = "Enable Target Info",
                desc = "Show target name (and optionally level) near the crosshair",
                order = 1,
                width = "full",
                get = function() return CPlusNS.db.showTargetInfo end,
                set = function(_, v) CPlusNS.db.showTargetInfo = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            targetInfoUseTargetColor = {
                type = "toggle",
                name = "Use Crosshair Color",
                desc = "Match target info text color to the crosshair color instead of white",
                order = 2,
                width = "full",
                disabled = function() return not CPlusNS.db.showTargetInfo end,
                get = function() return CPlusNS.db.targetInfoUseTargetColor end,
                set = function(_, v) CPlusNS.db.targetInfoUseTargetColor = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            targetInfoMode = {
                type = "select",
                name = "Display Mode",
                desc = "Choose what information to display",
                order = 3,
                values = {
                    name = "Name",
                    namelevel = "Name + Level",
                },
                sorting = {"name", "namelevel"},
                disabled = function() return not CPlusNS.db.showTargetInfo end,
                get = function() return CPlusNS.db.targetInfoMode end,
                set = function(_, v) CPlusNS.db.targetInfoMode = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            spacer1 = {
                type = "description",
                name = " ",
                order = 4,
            },
            -- Font
            targetInfoFont = CPlusNS.BuildFontSelect("targetInfoFont", 5, function() return not CPlusNS.db.showTargetInfo end),
            targetInfoFontSize = {
                type = "range",
                name = "Font Size",
                desc = "Adjust the size of the target info text (8-30)",
                order = 6,
                min = 8, max = 30, step = 1,
                disabled = function() return not CPlusNS.db.showTargetInfo end,
                get = function() return CPlusNS.db.targetInfoFontSize end,
                set = function(_, v) CPlusNS.db.targetInfoFontSize = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            spacer2 = {
                type = "description",
                name = " ",
                order = 7,
            },
            -- Position
            targetInfoPosition = {
                type = "select",
                name = "Anchor",
                desc = "Where to anchor the target info text relative to the crosshair",
                order = 8,
                values = {
                    BOTTOM = "Bottom",
                    TOP = "Top",
                    LEFT = "Left",
                    RIGHT = "Right",
                },
                sorting = {"BOTTOM", "TOP", "LEFT", "RIGHT"},
                disabled = function() return not CPlusNS.db.showTargetInfo end,
                get = function() return CPlusNS.db.targetInfoPosition end,
                set = function(_, v) CPlusNS.db.targetInfoPosition = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            targetInfoXOffset = {
                type = "range",
                name = "X Offset",
                desc = "Horizontal offset for the target info text (-100 to 100)",
                order = 9,
                min = -100, max = 100, step = 1,
                disabled = function() return not CPlusNS.db.showTargetInfo end,
                get = function() return CPlusNS.db.targetInfoXOffset end,
                set = function(_, v) CPlusNS.db.targetInfoXOffset = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            targetInfoYOffset = {
                type = "range",
                name = "Y Offset",
                desc = "Vertical offset for the target info text (-100 to 100)",
                order = 10,
                min = -100, max = 100, step = 1,
                disabled = function() return not CPlusNS.db.showTargetInfo end,
                get = function() return CPlusNS.db.targetInfoYOffset end,
                set = function(_, v) CPlusNS.db.targetInfoYOffset = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
        },
    }
end
