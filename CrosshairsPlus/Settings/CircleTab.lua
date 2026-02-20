--[[
    CrosshairsPlus - Circle Tab (AceConfig)
    Circle style options — flat layout
]]--

local AddonName, CPlusNS = ...

function CPlusNS.BuildCircleTab()
    return {
        type = "group",
        name = "Circle",
        order = 2,
        args = {
            circleStyle = {
                type = "select",
                name = "Circle Style",
                desc = "Choose the center circle appearance",
                order = 1,
                width = "normal",
                values = {
                    Circle0 = "Circle 0",
                    Circle1 = "Circle 1",
                    Circle2 = "Circle 2",
                    Circle3 = "Circle 3",
                    Circle4 = "Circle 4",
                    Circle5 = "Circle 5",
                },
                sorting = {"Circle0", "Circle1", "Circle2", "Circle3", "Circle4", "Circle5"},
                get = function() return CPlusNS.db.circleStyle end,
                set = function(_, v) CPlusNS.db.circleStyle = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            circleEffect = {
                type = "select",
                name = "Circle Effect",
                desc = "Choose the effect applied behind the circle",
                order = 2,
                width = "normal",
                values = {
                    none = "None",
                    glow = "Glow",
                    shadow = "Shadow",
                },
                sorting = {"none", "shadow", "glow"},
                get = function() return CPlusNS.db.circleEffect end,
                set = function(_, v) CPlusNS.db.circleEffect = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            spacer = {
                type = "description",
                name = " ",
                order = 2.5,
            },
            circleSize = {
                type = "range",
                name = "Circle Size",
                desc = "Adjust the size of the circle relative to the nameplate (-50 to +100 pixels)",
                order = 3,
                min = -50, max = 100, step = 2,
                get = function() return CPlusNS.db.circleSize end,
                set = function(_, v)
                    CPlusNS.db.circleSize = v
                    CPlusNS.state.lastNameplateWidth = 0
                    CPlusNS.UpdateCrosshairVisuals()
                end,
            },
        },
    }
end
