--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Crosshair/Init.lua - Initialization, event handlers, master update, and debug toggle
]]--

local AddonName, CPlusNS = ...
local state = CPlusNS.state
local defaults = CPlusNS.defaults

-- Update all crosshair visuals (called from settings panel)
function CPlusNS.UpdateCrosshairVisuals()
    CPlusNS.RefreshRotationCache()
    -- Visual config (only needs to run when settings change)
    CPlusNS.UpdateCircleStyle()
    CPlusNS.UpdateLineThickness()
    CPlusNS.UpdateLineGap()
    CPlusNS.UpdateLineVisibility()
    CPlusNS.UpdateArrowStyle()
    CPlusNS.UpdateRangePosition()
    CPlusNS.UpdateTargetInfoPosition()
    -- Re-evaluate unit (handles parent, color, show/hide, frame settings)
    CPlusNS.RefreshActiveUnit()
end

-- Initialize crosshair system
function CPlusNS.InitializeCrosshair()
    -- Get frame reference
    state.frame = _G["CrosshairsPlusFrame"]

    -- Ensure frame exists
    if not state.frame then
        print("|cffff0000CrosshairsPlus|r: Error - CrosshairsPlusFrame not found in _G!")
        return
    end

    local frame = state.frame

    CPlusNS.Debug("Frame reference acquired: " .. tostring(frame))

    -- Check if child elements exist (set in OnLoad script of XML)
    if frame.Core then
        CPlusNS.Debug("Core texture found")
    else
        print("|cffff0000CrosshairsPlus|r: WARNING - Core texture not found!")
    end

    if frame.TopLine then
        CPlusNS.Debug("Lines found")
    else
        print("|cffff0000CrosshairsPlus|r: WARNING - Lines not found!")
    end

    -- Check if 4 arrow frames exist
    if frame.ArrowTop and frame.ArrowRight and frame.ArrowBottom and frame.ArrowLeft then
        CPlusNS.Debug("4 Arrow frames found")
    else
        print("|cffff0000CrosshairsPlus|r: WARNING - Arrow frames not found!")
        print("  ArrowTop: " .. tostring(frame.ArrowTop ~= nil))
        print("  ArrowRight: " .. tostring(frame.ArrowRight ~= nil))
        print("  ArrowBottom: " .. tostring(frame.ArrowBottom ~= nil))
        print("  ArrowLeft: " .. tostring(frame.ArrowLeft ~= nil))
    end

    -- Set up OnUpdate for continuous updates
    CPlusNS.SetupOnUpdate()

    -- Register for target change events
    CPlusNS.EventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    CPlusNS.EventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    CPlusNS.EventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    CPlusNS.EventFrame:RegisterEvent("PLAYER_SOFT_ENEMY_CHANGED")

    CPlusNS.Debug("Events registered")

    -- Initial setup - wrapped in pcall to catch errors
    local success, err = pcall(function()
        CPlusNS.RefreshRotationCache()
        CPlusNS.UpdateLineThickness()
        CPlusNS.UpdateLineGap()
        CPlusNS.UpdateLineVisibility()
        CPlusNS.UpdateArrowStyle()
        CPlusNS.UpdateCircleStyle()
        CPlusNS.UpdateRangePosition()
        CPlusNS.UpdateTargetInfoPosition()
    end)

    if not success then
        print("|cffff0000CrosshairsPlus|r: Error in visual setup: " .. tostring(err))
    else
        CPlusNS.Debug("Crosshair visuals configured")
    end
end

-- Event: Player target changed
function CPlusNS:PLAYER_TARGET_CHANGED()
    if CPlusNS.db.debugMode then
        CPlusNS.Debug("PLAYER_TARGET_CHANGED -> " .. CPlusNS.DebugUnitInfo("target"))
    end
    CPlusNS.RefreshActiveUnit()
end

-- Event: Soft enemy changed (Action Targeting)
function CPlusNS:PLAYER_SOFT_ENEMY_CHANGED()
    if not CPlusNS.db.enableActionTargeting then
        if CPlusNS.db.debugMode then
            CPlusNS.Debug("PLAYER_SOFT_ENEMY_CHANGED (ignored — action targeting disabled)")
        end
        return
    end
    if CPlusNS.db.debugMode then
        CPlusNS.Debug("PLAYER_SOFT_ENEMY_CHANGED -> " .. CPlusNS.DebugUnitInfo("softenemy"))
    end
    CPlusNS.RefreshActiveUnit()
end

-- Event: Nameplate added (following Crosshairs addon pattern exactly)
function CPlusNS:NAME_PLATE_UNIT_ADDED(unitToken)
    -- Only care about nameplates if we have an active unit
    if not state.activeUnit or not UnitExists(state.activeUnit) then
        return
    end

    -- Get the nameplate for this unit token directly from the event (includeForbidden for instances)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitToken, true)

    -- Check if this nameplate is for our active unit
    if nameplate and UnitIsUnit(state.activeUnit, unitToken) then
        if CPlusNS.db.debugMode then
            CPlusNS.Debugf("NAME_PLATE_UNIT_ADDED for %s: %s",
                state.activeUnit, GetUnitName(state.activeUnit, false) or "Unknown")
        end

        -- Check if we should show crosshair for this unit
        if CPlusNS.ShouldShowCrosshair(state.activeUnit) then
            CPlusNS.Debug("Attaching to nameplate from ADDED event")
            CPlusNS.AttachToNameplate(nameplate)
        else
            CPlusNS.Debug("Active unit filtered out — not showing crosshair")
        end
    end
end

-- Event: Nameplate removed (following Crosshairs addon pattern)
function CPlusNS:NAME_PLATE_UNIT_REMOVED(unitToken)
    -- Check if the removed unit is our active unit
    if state.activeUnit and UnitIsUnit(state.activeUnit, unitToken) then
        if CPlusNS.db.debugMode then
            CPlusNS.Debug("NAME_PLATE_UNIT_REMOVED for " .. state.activeUnit .. " — hiding")
        end
        CPlusNS.HideCrosshair()
    end
end
