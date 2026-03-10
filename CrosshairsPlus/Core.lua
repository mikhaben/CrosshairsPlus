--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Core.lua - Namespace initialization and addon lifecycle management
]]--

local AddonName, CPlusNS = ...

-- Addon namespace
_G.CrosshairsPlus = CPlusNS

-- Version info
CPlusNS.Title = C_AddOns.GetAddOnMetadata(AddonName, "Title")
CPlusNS.Version = C_AddOns.GetAddOnMetadata(AddonName, "Version")
CPlusNS.Author = C_AddOns.GetAddOnMetadata(AddonName, "Author")

-- Default settings (shared: used for fallbacks, merge, and reset)
CPlusNS.defaults = {
    -- Target filters
    showEnemy = true,
    showEnemyPlayers = true,
    showEnemyNPCs = true,
    showEnemyCritters = false,

    showFriendly = false,
    showFriendlyPlayers = false,
    showFriendlyNPCs = false,
    showFriendlyCritters = false,

    enableActionTargeting = false,

    -- Visual options
    colorMode = "class", -- "reaction", "class", "custom"
    customFriendlyColor = { r = 0, g = 1, b = 0 },
    customEnemyColor = { r = 1, g = 0, b = 0 },
    showLines = true,

    -- Debug
    debugMode = false,

    -- Style settings
    frameStrata = "LOW",
    arrowStyle = "arrow11",
    circleStyle = "Circle0",
    circleEffect = "shadow",
    circleSize = 0,
    lineThickness = 2,
    lineStartGap = 0,
    crosshairScale = 0.8,
    crosshairAlpha = 0.6,

    -- Arrow settings
    arrowDistance = 100,
    arrowSize = 42,
    arrowsRotate = true,
    arrowsRotateCounterClockwise = false,
    arrowRotationSpeed = 75,

    -- Range display
    showRange = true,
    rangePosition = "TOP",
    rangeFont = "Default",
    rangeFontSize = 16,
    rangeXOffset = 0,
    rangeYOffset = 0,
    rangeUseTargetColor = true,

    -- Target info display
    showTargetInfo = true,
    targetInfoMode = "namelevel",
    targetInfoPosition = "BOTTOM",
    targetInfoFont = "Default",
    targetInfoFontSize = 14,
    targetInfoXOffset = 0,
    targetInfoYOffset = 0,
    targetInfoUseTargetColor = true,
}

-- Deep copy function for tables
function CPlusNS.DeepCopy(orig)
    if type(orig) ~= 'table' then
        return orig
    end
    local copy = {}
    for k, v in next, orig, nil do
        copy[CPlusNS.DeepCopy(k)] = CPlusNS.DeepCopy(v)
    end
    return copy
end

-- Merge saved settings with defaults
local function MergeDefaults(saved, defaults)
    for k, v in pairs(defaults) do
        if saved[k] == nil then
            if type(v) == "table" then
                saved[k] = CPlusNS.DeepCopy(v)
            else
                saved[k] = v
            end
        elseif type(v) == "table" and type(saved[k]) == "table" then
            MergeDefaults(saved[k], v)
        end
    end
    return saved
end

-- Initialize database
local function InitializeDatabase()
    if not CrosshairsPlusDB then
        CrosshairsPlusDB = CPlusNS.DeepCopy(CPlusNS.defaults)
    else
        CrosshairsPlusDB = MergeDefaults(CrosshairsPlusDB, CPlusNS.defaults)
    end

    CPlusNS.db = CrosshairsPlusDB
end

-- Event frame
local eventFrame = CreateFrame("Frame")
CPlusNS.EventFrame = eventFrame

-- Event handler
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if CPlusNS[event] then
        CPlusNS[event](CPlusNS, ...)
    end
end)

-- PLAYER_LOGIN event
function CPlusNS:PLAYER_LOGIN()
    InitializeDatabase()

    -- Debug logging for initialization
    if CPlusNS.db.debugMode then
        print("|cff00ff00CrosshairsPlus|r: PLAYER_LOGIN event fired")
        print("|cff00ff00CrosshairsPlus|r: Database initialized")
    end

    -- Check if crosshair frame exists
    if CrosshairsPlusFrame then
        if CPlusNS.db.debugMode then
            print("|cff00ff00CrosshairsPlus|r: CrosshairsPlusFrame found")
        end
    else
        print("|cffff0000CrosshairsPlus|r: ERROR - CrosshairsPlusFrame not found!")
        return
    end

    -- Initialize crosshair system
    if CPlusNS.InitializeCrosshair then
        CPlusNS.InitializeCrosshair()
        if CPlusNS.db.debugMode then
            print("|cff00ff00CrosshairsPlus|r: Crosshair system initialized")
        end
    else
        print("|cffff0000CrosshairsPlus|r: ERROR - InitializeCrosshair function not found!")
        return
    end

    -- Initialize settings panel
    if CPlusNS.InitializeSettings then
        CPlusNS.InitializeSettings()
        if CPlusNS.db.debugMode then
            print("|cff00ff00CrosshairsPlus|r: Settings panel initialized")
        end
    else
        print("|cffff0000CrosshairsPlus|r: ERROR - InitializeSettings function not found!")
        return
    end

    -- Only show this message (user-facing, not debug)
    print("|cff00ff00CrosshairsPlus|r v" .. CPlusNS.Version .. " loaded. Type /crosshairsplus for options.")

    -- Print nameplate CVar warnings once on login
    if CPlusNS.CheckNameplateCVars then
        local warnings = CPlusNS.CheckNameplateCVars()
        for _, warning in ipairs(warnings) do
            print("|cffff8800CrosshairsPlus|r: " .. warning)
        end
    end
end

-- PLAYER_ENTERING_WORLD event
function CPlusNS:PLAYER_ENTERING_WORLD()
    -- Refresh crosshair state on zone change
    if CPlusNS.RefreshActiveUnit then
        CPlusNS.RefreshActiveUnit()
    end
end

-- Register events
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Slash command
SLASH_CROSSHAIRSPLUS1 = "/crosshairsplus"
SLASH_CROSSHAIRSPLUS2 = "/chp"

SlashCmdList["CROSSHAIRSPLUS"] = function(msg)
    msg = msg:lower():trim()

    if msg == "debug" then
        -- Toggle debug mode
        if CrosshairsPlus.ToggleDebug then
            CrosshairsPlus.ToggleDebug()
        end
    elseif msg == "test" then
        CPlusNS.RunDiagnostics()
    elseif msg == "preview" then
        if CrosshairsPlusFrame then
            if CrosshairsPlusFrame:IsShown() then
                CrosshairsPlusFrame:Hide()
                print("|cff00ff00CrosshairsPlus|r: Crosshair hidden")
            else
                CrosshairsPlusFrame:SetParent(UIParent)
                CrosshairsPlusFrame:ClearAllPoints()
                CrosshairsPlusFrame:SetPoint("CENTER", UIParent, "CENTER")
                CrosshairsPlusFrame:Show()
                print("|cff00ff00CrosshairsPlus|r: Crosshair forced to center of screen")
            end
        else
            print("|cffff0000CrosshairsPlus|r: Frame not found!")
        end
    else
        -- Open settings panel
        if CPlusNS.OpenSettings then
            CPlusNS.OpenSettings()
        else
            print("|cffff0000CrosshairsPlus|r: Could not open settings panel")
        end
    end
end
