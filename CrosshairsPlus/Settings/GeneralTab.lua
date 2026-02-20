--[[
    CrosshairsPlus - General Tab (AceConfig)
    Target filters and visual options — flat layout, no sidebar
]]--

local AddonName, CPlusNS = ...

function CPlusNS.BuildGeneralTab()
    return {
        type = "group",
        name = "General",
        order = 1,
        args = {
            description = {
                type = "description",
                name = "Displays a crosshair on your target's nameplate.\nNameplates must be enabled for the addon to work.\n",
                order = 0,
                fontSize = "medium",
            },
            nameplateWarning = {
                type = "description",
                name = function()
                    if not CPlusNS.CheckNameplateCVars then return "" end
                    local warnings = CPlusNS.CheckNameplateCVars()
                    if #warnings == 0 then return "" end
                    return "|cffff8800" .. table.concat(warnings, "\n") .. "|r"
                end,
                order = 0.5,
                fontSize = "medium",
                hidden = function()
                    if not CPlusNS.CheckNameplateCVars then return true end
                    return #CPlusNS.CheckNameplateCVars() == 0
                end,
            },
            -- ==========================================
            -- ENEMY TARGETS
            -- ==========================================
            enemyHeader = {
                type = "header",
                name = "Enemy Targets",
                order = 1,
            },
            showEnemy = {
                type = "toggle",
                name = "Show on Enemy",
                desc = "Master toggle for all enemy targets",
                order = 2,
                width = "full",
                get = function() return CPlusNS.db.showEnemy end,
                set = function(_, v) CPlusNS.db.showEnemy = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            showEnemyPlayers = {
                type = "toggle",
                name = "   Players",
                desc = "Display crosshair on enemy players in PvP",
                order = 3,
                width = "full",
                disabled = function() return not CPlusNS.db.showEnemy end,
                get = function() return CPlusNS.db.showEnemyPlayers end,
                set = function(_, v) CPlusNS.db.showEnemyPlayers = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            showEnemyNPCs = {
                type = "toggle",
                name = "   NPCs",
                desc = "Display crosshair on hostile creatures and NPCs",
                order = 4,
                width = "full",
                disabled = function() return not CPlusNS.db.showEnemy end,
                get = function() return CPlusNS.db.showEnemyNPCs end,
                set = function(_, v) CPlusNS.db.showEnemyNPCs = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            showEnemyCritters = {
                type = "toggle",
                name = "   Critters (trivial creatures)",
                desc = "Display crosshair on trivial/ambient enemy creatures like critters. These may not have nameplates.",
                order = 5,
                width = "full",
                disabled = function() return not CPlusNS.db.showEnemy end,
                get = function() return CPlusNS.db.showEnemyCritters end,
                set = function(_, v) CPlusNS.db.showEnemyCritters = v; CPlusNS.UpdateCrosshairVisuals() end,
            },

            -- ==========================================
            -- FRIENDLY TARGETS
            -- ==========================================
            friendlyHeader = {
                type = "header",
                name = "Friendly Targets",
                order = 10,
            },
            showFriendly = {
                type = "toggle",
                name = "Show on Friendly",
                desc = "Master toggle for all friendly targets",
                order = 11,
                width = "full",
                get = function() return CPlusNS.db.showFriendly end,
                set = function(_, v) CPlusNS.db.showFriendly = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            showFriendlyPlayers = {
                type = "toggle",
                name = "   Players",
                desc = "Display crosshair on friendly players",
                order = 12,
                width = "full",
                disabled = function() return not CPlusNS.db.showFriendly end,
                get = function() return CPlusNS.db.showFriendlyPlayers end,
                set = function(_, v) CPlusNS.db.showFriendlyPlayers = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            showFriendlyNPCs = {
                type = "toggle",
                name = "   NPCs",
                desc = "Display crosshair on friendly creatures and NPCs",
                order = 13,
                width = "full",
                disabled = function() return not CPlusNS.db.showFriendly end,
                get = function() return CPlusNS.db.showFriendlyNPCs end,
                set = function(_, v) CPlusNS.db.showFriendlyNPCs = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            showFriendlyCritters = {
                type = "toggle",
                name = "   Critters (trivial creatures)",
                desc = "Display crosshair on trivial/ambient friendly creatures like critters. These may not have nameplates.",
                order = 14,
                width = "full",
                disabled = function() return not CPlusNS.db.showFriendly end,
                get = function() return CPlusNS.db.showFriendlyCritters end,
                set = function(_, v) CPlusNS.db.showFriendlyCritters = v; CPlusNS.UpdateCrosshairVisuals() end,
            },

            -- ==========================================
            -- ACTION TARGETING
            -- ==========================================
            actionTargetingHeader = {
                type = "header",
                name = "Action Targeting",
                order = 20,
            },
            enableActionTargeting = {
                type = "toggle",
                name = "Enable Action Targeting",
                desc = "Show crosshair on soft enemy targets (requires WoW's Action Targeting enabled). Hard target always takes priority.",
                order = 21,
                width = "full",
                get = function() return CPlusNS.db.enableActionTargeting end,
                set = function(_, v) CPlusNS.db.enableActionTargeting = v; CPlusNS.UpdateCrosshairVisuals() end,
            },

            -- ==========================================
            -- VISUAL OPTIONS
            -- ==========================================
            visualHeader = {
                type = "header",
                name = "Visual Options",
                order = 30,
            },
            enableClassColors = {
                type = "toggle",
                name = "Enable Class Coloring",
                desc = "Color player targets based on their class",
                order = 31,
                width = "full",
                get = function() return CPlusNS.db.enableClassColors end,
                set = function(_, v) CPlusNS.db.enableClassColors = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            frameStrata = {
                type = "select",
                name = "Frame Strata (Rendering Layer)",
                desc = "Controls which layer the crosshair renders on",
                order = 34,
                values = {
                    WORLD = "World",
                    BACKGROUND = "Background",
                    LOW = "Low (Default)",
                    MEDIUM = "Medium",
                    HIGH = "High",
                    DIALOG = "Dialog",
                    FULLSCREEN = "Fullscreen",
                    FULLSCREEN_DIALOG = "Fullscreen Dialog",
                    TOOLTIP = "Tooltip",
                },
                sorting = {"WORLD", "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP"},
                get = function() return CPlusNS.db.frameStrata end,
                set = function(_, v) CPlusNS.db.frameStrata = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            crosshairScale = {
                type = "range",
                name = "Frame Scale",
                desc = "Adjust the overall size of the crosshair (0.5-2.0x)",
                order = 32,
                width = "normal",
                min = 0.5, max = 2.0, step = 0.1,
                get = function() return CPlusNS.db.crosshairScale end,
                set = function(_, v) CPlusNS.db.crosshairScale = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            crosshairAlpha = {
                type = "range",
                name = "Frame Opacity",
                desc = "Adjust the transparency of the crosshair (0.0-1.0)",
                order = 33,
                width = "normal",
                min = 0.0, max = 1.0, step = 0.1,
                isPercent = true,
                get = function() return CPlusNS.db.crosshairAlpha end,
                set = function(_, v) CPlusNS.db.crosshairAlpha = v; CPlusNS.UpdateCrosshairVisuals() end,
            },
            strataSpacer = {
                type = "description",
                name = " ",
                order = 33.5,
            },

            -- ==========================================
            -- RESET
            -- ==========================================
            resetHeader = {
                type = "header",
                name = "",
                order = 99,
            },
            resetDefaults = {
                type = "execute",
                name = "Reset to Defaults",
                desc = "Reset all CrosshairsPlus settings to their default values",
                order = 100,
                confirm = true,
                confirmText = "Reset all CrosshairsPlus settings to defaults?",
                func = function()
                    for k, v in pairs(CPlusNS.defaults) do
                        if type(v) == "table" then
                            CPlusNS.db[k] = CPlusNS.DeepCopy(v)
                        else
                            CPlusNS.db[k] = v
                        end
                    end
                    CPlusNS.UpdateCrosshairVisuals()
                end,
            },
        },
    }
end
