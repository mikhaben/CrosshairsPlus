--[[
    CrosshairsPlus - Settings Initialization (AceConfig)
    Assembles all tabs and registers with AceConfig + Blizzard Options
]]--

local AddonName, CPlusNS = ...

function CPlusNS.InitializeSettings()
    if CPlusNS.db and CPlusNS.db.debugMode then
        print("|cff00ff00CrosshairsPlus|r: InitializeSettings called (AceConfig)")
    end

    -- Check if range sub-addon is available (installed and not disabled by user)
    local rangeAvailable = C_AddOns.GetAddOnEnableState("CrosshairsPlus_Range") > 0

    local options = {
        type = "group",
        name = "CrosshairsPlus",
        childGroups = "tab",
        args = {
            general = CPlusNS.BuildGeneralTab(),
            circle  = CPlusNS.BuildCircleTab(),
            lines   = CPlusNS.BuildLinesTab(),
            arrows  = CPlusNS.BuildArrowsTab(),
            range      = rangeAvailable and CPlusNS.BuildRangeTab() or nil,
            targetInfo = CPlusNS.BuildTargetInfoTab(),
            about      = CPlusNS.BuildAboutTab(),
        },
    }

    LibStub("AceConfig-3.0"):RegisterOptionsTable("CrosshairsPlus", options)
    CPlusNS.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CrosshairsPlus", "CrosshairsPlus")

    if CPlusNS.db and CPlusNS.db.debugMode then
        print("|cff00ff00CrosshairsPlus|r: AceConfig options registered")
    end
end

function CPlusNS.OpenSettings()
    Settings.OpenToCategory("CrosshairsPlus")
end
