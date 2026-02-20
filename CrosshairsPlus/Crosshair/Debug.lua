--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Crosshair/Debug.lua - Debug logging, diagnostics, and debug toggle
]]--

local AddonName, CPlusNS = ...

local PREFIX = "|cff00ff00[CHP]|r "

-- Log a debug message (only prints when debugMode is on)
function CPlusNS.Debug(msg)
    if CPlusNS.db and CPlusNS.db.debugMode then
        print(PREFIX .. msg)
    end
end

-- Log a formatted debug message (only prints when debugMode is on)
function CPlusNS.Debugf(fmt, ...)
    if CPlusNS.db and CPlusNS.db.debugMode then
        print(PREFIX .. string.format(fmt, ...))
    end
end

-- Format unit info string for debug output
function CPlusNS.DebugUnitInfo(unit)
    if not unit or not UnitExists(unit) then return "nil" end
    local name = GetUnitName(unit, false) or "?"
    local reaction = UnitReaction("player", unit) or "?"
    local dead = UnitIsDead(unit) and " DEAD" or ""
    local hostile = (UnitCanAttack("player", unit) or UnitIsEnemy("player", unit)) and "hostile" or "friendly"
    local threat = UnitThreatSituation("player", unit)
    local threatStr = threat and (" threat=" .. threat) or ""
    local hasPlate = C_NamePlate.GetNamePlateForUnit(unit, true) and "yes" or "no"
    return string.format("%s (%s) reaction=%s %s%s%s plate=%s", name, unit, tostring(reaction), hostile, dead, threatStr, hasPlate)
end

-- Toggle debug mode
function CPlusNS.ToggleDebug()
    CPlusNS.db.debugMode = not CPlusNS.db.debugMode
    if CPlusNS.db.debugMode then
        print("|cff00ff00CrosshairsPlus|r: Debug mode ENABLED")
        print("Watch chat for crosshair events during camera movement")
    else
        print("|cff00ff00CrosshairsPlus|r: Debug mode DISABLED")
    end
end

-- Run full diagnostics dump (/chp test)
function CPlusNS.RunDiagnostics()
    local db = CPlusNS.db
    local G = "|cff00ff00"   -- green (enabled / label)
    local R = "|cffff4444"   -- red (disabled)
    local Y = "|cffffff00"   -- yellow (values)
    local H = "|cff00ccff"   -- cyan (headers)
    local E = "|r"

    local function on(v) return v and (G .. "ON" .. E) or (R .. "OFF" .. E) end
    local function val(v) return Y .. tostring(v) .. E end

    print(G .. "CrosshairsPlus" .. E .. " v" .. (CPlusNS.Version or "?") .. " — Diagnostics")

    -- Runtime state
    print(H .. "--- Runtime ---" .. E)
    print("  Frame: " .. on(CrosshairsPlusFrame) .. "  Visible: " .. on(CrosshairsPlusFrame and CrosshairsPlusFrame:IsShown()))
    print("  Active unit: " .. val(CPlusNS.state.activeUnit))
    print("  Has target: " .. on(UnitExists("target")) .. "  Nameplate: " .. on(C_NamePlate.GetNamePlateForUnit("target") ~= nil))
    print("  Has softenemy: " .. on(UnitExists("softenemy")))
    print("  Range lib loaded: " .. on(CPlusNS.RC ~= nil))
    print("  Range sub-addon: " .. on(C_AddOns.GetAddOnEnableState("CrosshairsPlus_Range") > 0))
    UpdateAddOnMemoryUsage()
    print("  Memory: " .. val(string.format("%.0f KB", GetAddOnMemoryUsage("CrosshairsPlus"))))

    -- Target filters
    print(H .. "--- Target Filters ---" .. E)
    print("  Enemy: " .. on(db.showEnemy) .. "  Players: " .. on(db.showEnemyPlayers) .. "  NPCs: " .. on(db.showEnemyNPCs) .. "  Critters: " .. on(db.showEnemyCritters))
    print("  Friendly: " .. on(db.showFriendly) .. "  Players: " .. on(db.showFriendlyPlayers) .. "  NPCs: " .. on(db.showFriendlyNPCs) .. "  Critters: " .. on(db.showFriendlyCritters))
    print("  Action Targeting: " .. on(db.enableActionTargeting))
    print("  Class Colors: " .. on(db.enableClassColors))

    -- Visual
    print(H .. "--- Visual ---" .. E)
    print("  Scale: " .. val(db.crosshairScale) .. "  Alpha: " .. val(db.crosshairAlpha) .. "  Strata: " .. val(db.frameStrata))
    print("  Circle: " .. val(db.circleStyle) .. "  Effect: " .. val(db.circleEffect) .. "  Size offset: " .. val(db.circleSize))

    -- Lines
    print(H .. "--- Lines ---" .. E)
    print("  Show: " .. on(db.showLines) .. "  Thickness: " .. val(db.lineThickness) .. "  Gap: " .. val(db.lineStartGap))

    -- Arrows
    print(H .. "--- Arrows ---" .. E)
    print("  Style: " .. val(db.arrowStyle) .. "  Size: " .. val(db.arrowSize) .. "  Distance: " .. val(db.arrowDistance))
    print("  Rotate: " .. on(db.arrowsRotate) .. "  Speed: " .. val(db.arrowRotationSpeed) .. "  CCW: " .. on(db.arrowsRotateCounterClockwise))

    -- Range
    print(H .. "--- Range ---" .. E)
    print("  Show: " .. on(db.showRange) .. "  Use target color: " .. on(db.rangeUseTargetColor))
    print("  Font: " .. val(db.rangeFont) .. "  Size: " .. val(db.rangeFontSize))
    print("  Position: " .. val(db.rangePosition) .. "  X: " .. val(db.rangeXOffset) .. "  Y: " .. val(db.rangeYOffset))

    -- Target Info
    print(H .. "--- Target Info ---" .. E)
    print("  Show: " .. on(db.showTargetInfo) .. "  Mode: " .. val(db.targetInfoMode) .. "  Use target color: " .. on(db.targetInfoUseTargetColor))
    print("  Font: " .. val(db.targetInfoFont) .. "  Size: " .. val(db.targetInfoFontSize))
    print("  Position: " .. val(db.targetInfoPosition) .. "  X: " .. val(db.targetInfoXOffset) .. "  Y: " .. val(db.targetInfoYOffset))

    -- Debug
    print(H .. "--- Debug ---" .. E)
    print("  Debug mode: " .. on(db.debugMode))

    -- Nameplate CVars
    print(H .. "--- Nameplate CVars ---" .. E)
    print("  ShowAll: " .. val(GetCVar("nameplateShowAll")) .. "  Enemies: " .. val(GetCVar("nameplateShowEnemies")))
    print("  Friends: " .. val(GetCVar("nameplateShowFriends")) .. "  FriendlyNPCs: " .. val(GetCVar("nameplateShowFriendlyNPCs")))

    -- Warnings
    if CPlusNS.CheckNameplateCVars then
        local warnings = CPlusNS.CheckNameplateCVars()
        if #warnings > 0 then
            print(H .. "--- Warnings ---" .. E)
            for _, warning in ipairs(warnings) do
                print("  |cffff8800" .. warning .. "|r")
            end
        end
    end
end
