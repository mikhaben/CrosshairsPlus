--[[
    CrosshairsPlus - Arrows Tab (AceConfig)
    Arrow style dropdown, positioning, and rotation — flat layout
]]--

local AddonName, CPlusNS = ...

function CPlusNS.BuildArrowsTab()
    -- Build arrow style values and sorting for dropdown
    local arrowValues = { none = "None" }
    local arrowSorting = { "none" }

    for i = 0, 72 do
        local key = "arrow" .. i
        arrowValues[key] = "Arrow " .. i
        arrowSorting[#arrowSorting + 1] = key
    end

    return {
        type = "group",
        name = "Arrows",
        order = 4,
        args = {
            arrowStyle = {
                type = "select",
                name = "Arrow Style",
                desc = "Select which arrow texture to use",
                order = 2,
                values = arrowValues,
                sorting = arrowSorting,
                get = function() return CPlusNS.db.arrowStyle end,
                set = function(_, v) CPlusNS.db.arrowStyle = v; CPlusNS.UpdateCrosshairVisuals() end,
            },

            positioningSpacer = {
                type = "description",
                name = " ",
                order = 10,
            },
            arrowDistance = {
                type = "range",
                name = "Distance from Center",
                desc = "Adjust how far arrows are from the center circle (20-200 pixels)",
                order = 11,
                min = 20, max = 200, step = 2,
                disabled = function() return CPlusNS.db.arrowStyle == "none" end,
                get = function() return CPlusNS.db.arrowDistance end,
                set = function(_, v) CPlusNS.db.arrowDistance = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            arrowSize = {
                type = "range",
                name = "Arrow Size",
                desc = "Adjust the size of the arrows (16-64 pixels)",
                order = 12,
                min = 16, max = 64, step = 2,
                disabled = function() return CPlusNS.db.arrowStyle == "none" end,
                get = function() return CPlusNS.db.arrowSize end,
                set = function(_, v) CPlusNS.db.arrowSize = v; CPlusNS.UpdateCrosshairVisuals() end,
            },

            rotationSpacer = {
                type = "description",
                name = " ",
                order = 20,
            },
            arrowsRotate = {
                type = "toggle",
                name = "Rotate Arrows",
                desc = "Enable continuous rotation of arrows around the circle",
                order = 21,
                width = "full",
                disabled = function() return CPlusNS.db.arrowStyle == "none" end,
                get = function() return CPlusNS.db.arrowsRotate end,
                set = function(_, v) CPlusNS.db.arrowsRotate = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            arrowsRotateCounterClockwise = {
                type = "toggle",
                name = "Rotate Counter-Clockwise",
                desc = "If enabled, arrows rotate counter-clockwise; otherwise clockwise (default)",
                order = 22,
                width = "full",
                disabled = function() return CPlusNS.db.arrowStyle == "none" or not CPlusNS.db.arrowsRotate end,
                get = function() return CPlusNS.db.arrowsRotateCounterClockwise end,
                set = function(_, v) CPlusNS.db.arrowsRotateCounterClockwise = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            arrowRotationSpeed = {
                type = "range",
                name = "Rotation Speed",
                desc = "Adjust the speed of arrow rotation (10-360 degrees/sec)",
                order = 23,
                min = 10, max = 360, step = 5,
                disabled = function() return CPlusNS.db.arrowStyle == "none" or not CPlusNS.db.arrowsRotate end,
                get = function() return CPlusNS.db.arrowRotationSpeed end,
                set = function(_, v) CPlusNS.db.arrowRotationSpeed = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
        },
    }
end
