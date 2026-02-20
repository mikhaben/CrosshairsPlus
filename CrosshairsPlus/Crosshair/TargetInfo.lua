--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Crosshair/TargetInfo.lua - Target info text display and position
]]--

local AddonName, CPlusNS = ...
local state = CPlusNS.state

-- Set target info text (called once on target switch from AttachToNameplate)
function CPlusNS.RefreshTargetInfoText()
    local frame = state.frame

    if not CPlusNS.db.showTargetInfo or not state.activeUnit or not UnitExists(state.activeUnit) then
        if frame.TargetInfoText and frame.TargetInfoText:IsShown() then
            frame.TargetInfoText:Hide()
        end
        return
    end

    local name = GetUnitName(state.activeUnit, false) or ""
    local text

    if CPlusNS.db.targetInfoMode == "namelevel" then
        local level = UnitLevel(state.activeUnit)
        local levelStr = (level and level > 0) and tostring(level) or "??"
        text = name .. " - " .. levelStr
    else
        text = name
    end

    frame.TargetInfoText:SetText(text)

    if CPlusNS.db.targetInfoUseTargetColor then
        frame.TargetInfoText:SetTextColor(state.lastUnitR, state.lastUnitG, state.lastUnitB)
    else
        frame.TargetInfoText:SetTextColor(1, 1, 1)
    end

    if not frame.TargetInfoText:IsShown() then frame.TargetInfoText:Show() end
end

-- Update target info color only (called from OnUpdate — lightweight)
function CPlusNS.UpdateTargetInfoColor()
    if not CPlusNS.db.showTargetInfo or not CPlusNS.db.targetInfoUseTargetColor then
        return
    end

    local frame = state.frame
    if not frame.TargetInfoText or not frame.TargetInfoText:IsShown() then
        return
    end

    if state.activeUnit and UnitExists(state.activeUnit) then
        frame.TargetInfoText:SetTextColor(state.lastUnitR, state.lastUnitG, state.lastUnitB)
    end
end

-- Update target info text position and font size
function CPlusNS.UpdateTargetInfoPosition()
    local frame = state.frame
    if not frame or not frame.TargetInfoText then return end

    local db = CPlusNS.db
    local fontPath = CPlusNS.ResolveFont(db.targetInfoFont)
    frame.TargetInfoText:SetFont(fontPath, db.targetInfoFontSize, "OUTLINE")
    CPlusNS.SetTextAnchor(frame.TargetInfoText, frame.Core, db.targetInfoPosition, db.targetInfoXOffset, db.targetInfoYOffset)
end
