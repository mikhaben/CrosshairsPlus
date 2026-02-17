--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Core.lua - Namespace initialization and addon lifecycle management
]]--

local AddonName, CPlusNS = ...

-- Addon namespace
_G.CrosshairsPlus = CPlusNS

-- Version info
CPlusNS.Version = "1.0.2"

-- Default settings
local defaults = {
    version = "1.0.2",

    -- Target filters
    showEnemyPlayers = true,
    showFriendlyPlayers = false,
    showHostileNPCs = true,
    showFriendlyNPCs = false,
    enableActionTargeting = false,

    -- Visual options
    enableClassColors = true,
    showLines = true,

    -- Debug
    debugMode = false,

    -- Style settings
    arrowStyle = "arrow0",
    circleStyle = "default",
    lineThickness = 2,
    lineStartGap = 0,
    crosshairScale = 0.8,
    crosshairAlpha = 0.6,

    -- Arrow settings
    arrowDistance = 74,
    arrowSize = 24,
    arrowsRotate = true,
    arrowsRotateCounterClockwise = false,
    arrowRotationSpeed = 5.0,
}

-- Deep copy function for tables
function CPlusNS.DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[CPlusNS.DeepCopy(orig_key)] = CPlusNS.DeepCopy(orig_value)
        end
        setmetatable(copy, CPlusNS.DeepCopy(getmetatable(orig)))
    else
        copy = orig
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
        CrosshairsPlusDB = CPlusNS.DeepCopy(defaults)
    else
        CrosshairsPlusDB = MergeDefaults(CrosshairsPlusDB, defaults)
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
end

-- PLAYER_ENTERING_WORLD event
function CPlusNS:PLAYER_ENTERING_WORLD()
    -- Refresh crosshair state on zone change
    if CPlusNS.RefreshCrosshair then
        CPlusNS.RefreshCrosshair()
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
        -- Test command
        print("|cff00ff00CrosshairsPlus|r: Running diagnostics...")
        print("Frame exists: " .. tostring(CrosshairsPlusFrame ~= nil))
        print("Frame visible: " .. tostring(CrosshairsPlusFrame and CrosshairsPlusFrame:IsShown()))
        print("Has target: " .. tostring(UnitExists("target")))
        print("Target nameplate: " .. tostring(C_NamePlate.GetNamePlateForUnit("target") ~= nil))
        print("ShouldShow (target): " .. tostring(CPlusNS.ShouldShowCrosshair and CPlusNS.ShouldShowCrosshair("target")))
        print("Action Targeting enabled: " .. tostring(CPlusNS.db.enableActionTargeting))
        print("Has soft enemy: " .. tostring(UnitExists("softenemy")))
        if CPlusNS.db.enableActionTargeting then
            print("ShouldShow (softenemy): " .. tostring(CPlusNS.ShouldShowCrosshair and CPlusNS.ShouldShowCrosshair("softenemy")))
        end

        if CrosshairsPlusFrame then
            print("Frame parent: " .. tostring(CrosshairsPlusFrame:GetParent():GetName()))
            print("Frame scale: " .. tostring(CrosshairsPlusFrame:GetScale()))
            print("Frame alpha: " .. tostring(CrosshairsPlusFrame:GetAlpha()))
        end
    elseif msg == "show" then
        -- Force show crosshair for testing
        if CrosshairsPlusFrame then
            CrosshairsPlusFrame:SetParent(UIParent)
            CrosshairsPlusFrame:ClearAllPoints()
            CrosshairsPlusFrame:SetPoint("CENTER", UIParent, "CENTER")
            CrosshairsPlusFrame:Show()
            print("|cff00ff00CrosshairsPlus|r: Crosshair forced to center of screen")
        else
            print("|cffff0000CrosshairsPlus|r: Frame not found!")
        end
    elseif msg == "hide" then
        if CrosshairsPlusFrame then
            CrosshairsPlusFrame:Hide()
            print("|cff00ff00CrosshairsPlus|r: Crosshair hidden")
        end
    else
        -- Open settings panel
        if CPlusNS.OpenSettings then
            CPlusNS.OpenSettings()
        elseif Settings and Settings.OpenToCategory then
            Settings.OpenToCategory("CrosshairsPlus")
        else
            print("|cffff0000CrosshairsPlus|r: Could not open settings panel")
        end
    end
end
