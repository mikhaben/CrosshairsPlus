local _, CPlusNS = ...
local state = CPlusNS.state
local CONST = CPlusNS.CONST

function CPlusNS.ApplyColorToTextures(r, g, b)
    local frame = state.frame
    if not frame then return end

    if not frame:IsShown() then
        return
    end

    if frame.Core then
        frame.Core:SetVertexColor(r, g, b)
    end
    if frame.CoreGlow then
        frame.CoreGlow:SetVertexColor(r, g, b)
    end

    if CPlusNS.db.arrowStyle ~= "none" then
        local arrowKeys = CONST.ARROW_KEYS
        for i = 1, #arrowKeys do
            local tex = frame[arrowKeys[i]]
            if tex then tex:SetVertexColor(r, g, b) end
        end
    end

    local lineKeys = CONST.LINE_KEYS
    for i = 1, #lineKeys do
        local tex = frame[lineKeys[i]]
        if tex and tex:IsShown() then
            tex:SetVertexColor(r, g, b)
        end
    end
end

function CPlusNS.ApplyFrameSettings()
    local db = CPlusNS.db
    state.frame:SetFrameStrata(db.frameStrata)
    state.frame:SetFrameLevel(100)
    state.frame:SetScale(db.crosshairScale)
    state.frame:SetAlpha(db.crosshairAlpha)
end

function CPlusNS.AttachToNameplate(nameplate)
    local frame = state.frame

    if not nameplate then
        CPlusNS.Debug("AttachToNameplate: nameplate is nil!")
        return
    end

    if not state.activeUnit or not UnitExists(state.activeUnit) then
        CPlusNS.Debug("AttachToNameplate: No active unit exists!")
        return
    end

    local unitNameplate = C_NamePlate.GetNamePlateForUnit(state.activeUnit, true)
    if unitNameplate ~= nameplate then
        CPlusNS.Debugf("AttachToNameplate: ERROR - nameplate mismatch! passed=%s active=%s",
            tostring(nameplate), tostring(unitNameplate))
        return
    end

    if nameplate.IsForbidden and nameplate:IsForbidden() then
        CPlusNS.Debug("AttachToNameplate: nameplate is forbidden — cannot attach")
        CPlusNS.HideCrosshair()
        return
    end

    if CPlusNS.db.debugMode then
        CPlusNS.Debugf("AttachToNameplate: %s (%s) wasShown=%s",
            GetUnitName(state.activeUnit, false) or "Unknown", state.activeUnit, tostring(frame:IsShown()))
    end

    frame:ClearAllPoints()
    frame:SetParent(nameplate)
    frame:SetPoint("CENTER")

    local sizeOffset = CPlusNS.db.circleSize
    local width = math.max(nameplate:GetWidth() + CONST.NAMEPLATE_SIZE_PADDING + sizeOffset, CONST.MIN_CIRCLE_SIZE)
    if width ~= state.lastNameplateWidth then
        if CPlusNS.db.debugMode then
            CPlusNS.Debugf("Nameplate resize: %.0f -> %.0f (radius=%.0f)", state.lastNameplateWidth, width, width / 2)
        end
        state.lastNameplateWidth = width
        state.circleRadius = width / 2
        if frame.Core then
            frame.Core:SetSize(width, width)
        end
        if frame.CoreGlow then
            frame.CoreGlow:SetSize(width, width)
        end
        if frame.CoreShadow then
            frame.CoreShadow:SetSize(width, width)
        end
        CPlusNS.UpdateLineGap()
    end

    CPlusNS.ApplyFrameSettings()

    if not frame:IsShown() then
        CPlusNS.Debug("AttachToNameplate: Showing frame (was hidden)")
        frame:Show()
    else
        CPlusNS.Debug("AttachToNameplate: Frame already showing, just repositioned")
    end

    local r, g, b = CPlusNS.GetUnitColor(state.activeUnit)
    state.lastUnitR, state.lastUnitG, state.lastUnitB = r, g, b
    if CPlusNS.db.debugMode then
        CPlusNS.Debugf("Applying color to %s: R=%.2f G=%.2f B=%.2f",
            GetUnitName(state.activeUnit, false) or "Unknown", r, g, b)
    end
    CPlusNS.ApplyColorToTextures(r, g, b)

    CPlusNS.RefreshTargetInfoText()
end

function CPlusNS.HideCrosshair()
    local frame = state.frame
    if not frame then return end

    if CPlusNS.db.debugMode then
        CPlusNS.Debug("HideCrosshair called, IsShown=" .. tostring(frame:IsShown()))
    end

    if frame:IsShown() then
        CPlusNS.Debug("Hiding frame")
        frame:Hide()
    end

    if frame.RangeText then
        frame.RangeText:Hide()
        state.lastRangeVal = nil
        state.lastMaxRange = nil
    end

    if frame.TargetInfoText then
        frame.TargetInfoText:Hide()
    end

end

function CPlusNS.RefreshActiveUnit()
    state.updateTimer = 0

    local prevUnit = state.activeUnit
    state.activeUnit = CPlusNS.GetActiveUnit()

    if CPlusNS.db.debugMode then
        if prevUnit ~= state.activeUnit then
            CPlusNS.Debugf("RefreshActiveUnit: %s -> %s", tostring(prevUnit), tostring(state.activeUnit))
        end
        if state.activeUnit and UnitExists(state.activeUnit) then
            local r, g, b = CPlusNS.GetUnitColor(state.activeUnit)
            CPlusNS.Debugf(" unit=%s color=(%.2f, %.2f, %.2f)", CPlusNS.DebugUnitInfo(state.activeUnit), r, g, b)
        end
    end

    if not state.activeUnit then
        CPlusNS.HideCrosshair()
        return
    end

    local nameplate = C_NamePlate.GetNamePlateForUnit(state.activeUnit, true)

    if nameplate then
        CPlusNS.AttachToNameplate(nameplate)
    else
        CPlusNS.Debug("No nameplate found — hiding crosshair")
        CPlusNS.HideCrosshair()
    end
end
