--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Crosshair/Range.lua - Range display text and position
]]--

local AddonName, CPlusNS = ...
local state = CPlusNS.state

-- Cache sub-addon availability once (nil = not checked yet)
local rangeAddonAvailable = nil

-- Update range display text (called from OnUpdate every 0.3s)
function CPlusNS.UpdateRangeDisplay()
    local frame = state.frame
    if not frame then return end

    if not CPlusNS.db.showRange or not state.activeUnit or not UnitExists(state.activeUnit) then
        if frame.RangeText:IsShown() then frame.RangeText:Hide() end
        return
    end

    -- Lazy-load LibRangeCheck from LoadOnDemand sub-addon
    if not CPlusNS.RC then
        -- Check availability once
        if rangeAddonAvailable == nil then
            rangeAddonAvailable = C_AddOns.GetAddOnEnableState("CrosshairsPlus_Range") > 0
        end
        if not rangeAddonAvailable then
            CPlusNS.db.showRange = false
            if frame.RangeText:IsShown() then frame.RangeText:Hide() end
            return
        end
        local loaded = C_AddOns.LoadAddOn("CrosshairsPlus_Range")
        if loaded then
            CPlusNS.RC = LibStub("LibRangeCheck-3.0")
            CPlusNS.Debug("LibRangeCheck-3.0 loaded on demand")
        else
            rangeAddonAvailable = false
            CPlusNS.db.showRange = false
            if frame.RangeText:IsShown() then frame.RangeText:Hide() end
            return
        end
    end

    local minRange, maxRange = CPlusNS.RC:GetRange(state.activeUnit)
    local rangeVal = maxRange or minRange  -- nil when out of range
    if rangeVal ~= state.lastRangeVal or (not maxRange and maxRange ~= state.lastMaxRange) then
        state.lastRangeVal = rangeVal
        state.lastMaxRange = maxRange
        local text
        if not minRange then
            text = "\226\128\148" -- em dash (—) for out-of-range display
        elseif maxRange then
            text = tostring(maxRange)
        else
            text = tostring(minRange) .. "+"
        end
        frame.RangeText:SetText(text)
    end

    -- Only call SetTextColor when the color actually changes
    local r, g, b
    if CPlusNS.db.rangeUseTargetColor then
        r, g, b = state.lastUnitR, state.lastUnitG, state.lastUnitB
    else
        r, g, b = 1, 1, 1
    end
    if r ~= state.lastRangeR or g ~= state.lastRangeG or b ~= state.lastRangeB then
        frame.RangeText:SetTextColor(r, g, b)
        state.lastRangeR, state.lastRangeG, state.lastRangeB = r, g, b
    end

    if not frame.RangeText:IsShown() then frame.RangeText:Show() end
end

-- Update range text position and font size
function CPlusNS.UpdateRangePosition()
    local frame = state.frame
    if not frame or not frame.RangeText then return end

    local db = CPlusNS.db
    local fontPath = CPlusNS.ResolveFont(db.rangeFont)
    frame.RangeText:SetFont(fontPath, db.rangeFontSize, "OUTLINE")
    CPlusNS.SetTextAnchor(frame.RangeText, frame.Core, db.rangePosition, db.rangeXOffset, db.rangeYOffset)
end
