--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Crosshair/OnUpdate.lua - Per-frame update handler
]]--

local AddonName, CPlusNS = ...
local state = CPlusNS.state
local CONST = CPlusNS.CONST

-- Track last color for debug change detection
local lastDebugR, lastDebugG, lastDebugB = 0, 0, 0

-- OnUpdate handler for continuous updates (range, color changes, rotation, etc.)
local function OnUpdate(self, elapsed)
    if not state.frame or not CPlusNS.db then
        return
    end

    state.updateTimer = state.updateTimer + elapsed

    -- Update arrow rotation every frame if enabled (skip when no target, e.g. /chp show diagnostic)
    if state.activeUnit and CPlusNS.db.arrowsRotate and CPlusNS.db.arrowStyle ~= "none" then
        CPlusNS.UpdateArrowRotation(elapsed)
    end

    if state.updateTimer >= CONST.UPDATE_INTERVAL then
        state.updateTimer = 0

        -- Only update color, DO NOT hide/show (let events handle that)
        if state.activeUnit and UnitExists(state.activeUnit) then
            -- Update color in case it changed (e.g., tapped by someone else)
            local r, g, b = CPlusNS.GetUnitColor(state.activeUnit)
            CPlusNS.ApplyColorToTextures(r, g, b)

            -- Cache color for reuse by Range and TargetInfo
            state.lastUnitR, state.lastUnitG, state.lastUnitB = r, g, b

            -- Log when color changes (e.g., neutral -> hostile)
            if CPlusNS.db.debugMode then
                if r ~= lastDebugR or g ~= lastDebugG or b ~= lastDebugB then
                    CPlusNS.Debugf("OnUpdate color changed: (%.2f,%.2f,%.2f) -> (%.2f,%.2f,%.2f) unit=%s",
                        lastDebugR, lastDebugG, lastDebugB, r, g, b, CPlusNS.DebugUnitInfo(state.activeUnit))
                    lastDebugR, lastDebugG, lastDebugB = r, g, b
                end
            end
        end

        -- Update range display (zero overhead when disabled — early-exits immediately)
        CPlusNS.UpdateRangeDisplay()

        -- Update target info color (text is set once on target switch)
        CPlusNS.UpdateTargetInfoColor()
    end
end

-- Setup function called by Init.lua (keeps OnUpdate local for performance)
function CPlusNS.SetupOnUpdate()
    state.frame:SetScript("OnUpdate", OnUpdate)
end
