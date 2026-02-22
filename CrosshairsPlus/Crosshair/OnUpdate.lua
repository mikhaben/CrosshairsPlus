--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Crosshair/OnUpdate.lua - Per-frame update handler
]]--

local AddonName, CPlusNS = ...
local state = CPlusNS.state
local UPDATE_INTERVAL = CPlusNS.CONST.UPDATE_INTERVAL

-- OnUpdate handler for continuous updates (range, color changes, rotation, etc.)
local function OnUpdate(self, elapsed)
    if not state.frame or not CPlusNS.db then
        return
    end

    state.updateTimer = state.updateTimer + elapsed

    -- Update arrow rotation every frame if enabled (skip when no target, e.g. /chp preview diagnostic)
    if state.activeUnit and CPlusNS.db.arrowsRotate and CPlusNS.db.arrowStyle ~= "none" then
        CPlusNS.UpdateArrowRotation(elapsed)
    end

    if state.updateTimer >= UPDATE_INTERVAL then
        state.updateTimer = 0

        -- Only update color, DO NOT hide/show (let events handle that)
        if state.activeUnit and UnitExists(state.activeUnit) then
            -- Update color only when it changes (e.g., tapped by someone else, threat transition)
            local r, g, b = CPlusNS.GetUnitColor(state.activeUnit)
            if r ~= state.lastUnitR or g ~= state.lastUnitG or b ~= state.lastUnitB then
                if CPlusNS.db.debugMode then
                    CPlusNS.Debugf("OnUpdate color changed: (%.2f,%.2f,%.2f) -> (%.2f,%.2f,%.2f) unit=%s",
                        state.lastUnitR, state.lastUnitG, state.lastUnitB, r, g, b, CPlusNS.DebugUnitInfo(state.activeUnit))
                end
                state.lastUnitR, state.lastUnitG, state.lastUnitB = r, g, b
                CPlusNS.ApplyColorToTextures(r, g, b)
            end
        end

        -- Update range display (skip call entirely when disabled)
        if CPlusNS.db.showRange then
            CPlusNS.UpdateRangeDisplay()
        end

        -- Update target info color (skip when feature is off or not using target color)
        if CPlusNS.db.showTargetInfo and CPlusNS.db.targetInfoUseTargetColor then
            CPlusNS.UpdateTargetInfoColor()
        end
    end
end

-- Setup function called by Init.lua (keeps OnUpdate local for performance)
function CPlusNS.SetupOnUpdate()
    state.frame:SetScript("OnUpdate", OnUpdate)
end
