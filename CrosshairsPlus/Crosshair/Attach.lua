--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Crosshair/Attach.lua - Color application, frame settings, nameplate attachment, and active unit management
]]--

local AddonName, CPlusNS = ...
local state = CPlusNS.state
local CONST = CPlusNS.CONST

-- Apply color to all crosshair textures
function CPlusNS.ApplyColorToTextures(r, g, b)
    local frame = state.frame
    if not frame then return end

    -- Skip if frame is not visible
    if not frame:IsShown() then
        return
    end

    -- Core elements (always visible when frame is shown)
    if frame.Core then
        frame.Core:SetVertexColor(r, g, b)
    end
    if frame.CoreGlow then
        frame.CoreGlow:SetVertexColor(r, g, b)
    end

    -- Only update arrows if they're enabled (not "none")
    if CPlusNS.db.arrowStyle ~= "none" then
        local arrowKeys = CONST.ARROW_KEYS
        for i = 1, #arrowKeys do
            local tex = frame[arrowKeys[i]]
            if tex then tex:SetVertexColor(r, g, b) end
        end
    end

    -- Only update lines if shown
    local lineKeys = CONST.LINE_KEYS
    for i = 1, #lineKeys do
        local tex = frame[lineKeys[i]]
        if tex and tex:IsShown() then
            tex:SetVertexColor(r, g, b)
        end
    end
end

-- Apply frame settings (scale, alpha, strata) — DRY helper
function CPlusNS.ApplyFrameSettings()
    local db = CPlusNS.db
    state.frame:SetFrameStrata(db.frameStrata)
    state.frame:SetFrameLevel(100)
    state.frame:SetScale(db.crosshairScale)
    state.frame:SetAlpha(db.crosshairAlpha)
end

-- Attach crosshair to nameplate
function CPlusNS.AttachToNameplate(nameplate)
    local frame = state.frame

    if not nameplate then
        CPlusNS.Debug("AttachToNameplate: nameplate is nil!")
        return
    end

    -- CRITICAL: Verify this nameplate actually belongs to our active unit
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

    if CPlusNS.db.debugMode then
        CPlusNS.Debugf("AttachToNameplate: %s (%s) wasShown=%s",
            GetUnitName(state.activeUnit, false) or "Unknown", state.activeUnit, tostring(frame:IsShown()))
    end

    -- Always clear and reattach (like Crosshairs addon)
    frame:ClearAllPoints()
    frame:SetParent(nameplate)
    frame:SetPoint("CENTER")

    -- Dynamic sizing based on nameplate width + user offset (cached to avoid redundant resizing)
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
        -- Update line gap to match new circle size
        CPlusNS.UpdateLineGap()
    end

    -- Apply frame settings (strata, scale, alpha)
    CPlusNS.ApplyFrameSettings()

    -- Show frame (instant, no fade)
    if not frame:IsShown() then
        CPlusNS.Debug("AttachToNameplate: Showing frame (was hidden)")
        frame:Show()
    else
        CPlusNS.Debug("AttachToNameplate: Frame already showing, just repositioned")
    end

    -- CRITICAL: Always update color AFTER showing frame
    -- This ensures immediate color update on target change
    local r, g, b = CPlusNS.GetUnitColor(state.activeUnit)
    state.lastUnitR, state.lastUnitG, state.lastUnitB = r, g, b
    if CPlusNS.db.debugMode then
        CPlusNS.Debugf("Applying color to %s: R=%.2f G=%.2f B=%.2f",
            GetUnitName(state.activeUnit, false) or "Unknown", r, g, b)
    end
    CPlusNS.ApplyColorToTextures(r, g, b)

    -- Set target info text (name/level — only needs to run once per target switch)
    CPlusNS.RefreshTargetInfoText()
end

-- Hide crosshair
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

    -- Nudge GC during idle (target lost) to reclaim combat allocations
    collectgarbage("step", 50)
end

-- Refresh crosshair based on current active unit
function CPlusNS.RefreshActiveUnit()
    -- Reset update timer to prevent stale color updates
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

    -- Get nameplate for active unit (includeForbidden for instance nameplates)
    local nameplate = C_NamePlate.GetNamePlateForUnit(state.activeUnit, true)

    if nameplate then
        -- AttachToNameplate already updates colors immediately
        CPlusNS.AttachToNameplate(nameplate)
    else
        CPlusNS.Debug("No nameplate found — hiding crosshair")
        CPlusNS.HideCrosshair()
    end
end
