local _, CPlusNS = ...
local state = CPlusNS.state
local UPDATE_INTERVAL = CPlusNS.CONST.UPDATE_INTERVAL

local function OnUpdate(self, elapsed)
    if not state.frame or not CPlusNS.db then
        return
    end

    state.updateTimer = state.updateTimer + elapsed

    if state.activeUnit and CPlusNS.db.arrowsRotate and CPlusNS.db.arrowStyle ~= "none" then
        CPlusNS.UpdateArrowRotation(elapsed)
    end

    if state.updateTimer >= UPDATE_INTERVAL then
        state.updateTimer = 0

        if state.activeUnit and UnitExists(state.activeUnit) then
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

        if CPlusNS.db.showRange then
            CPlusNS.UpdateRangeDisplay()
        end

        if CPlusNS.db.showTargetInfo and CPlusNS.db.targetInfoUseTargetColor then
            CPlusNS.UpdateTargetInfoColor()
        end
    end
end

function CPlusNS.SetupOnUpdate()
    state.frame:SetScript("OnUpdate", OnUpdate)
end
