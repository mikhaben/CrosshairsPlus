--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Crosshair/Lines.lua - Line thickness, gap, and visibility
]]--

local AddonName, CPlusNS = ...
local state = CPlusNS.state
local CONST = CPlusNS.CONST

-- Update line thickness based on settings
function CPlusNS.UpdateLineThickness()
    local frame = state.frame
    if not frame then
        CPlusNS.Debug("UpdateLineThickness: frame is nil!")
        return
    end

    -- Skip if lines are disabled
    if not CPlusNS.db.showLines then
        return
    end

    local thickness = CPlusNS.db.lineThickness

    if frame.TopLine then
        frame.TopLine:SetWidth(thickness)
    end
    if frame.BottomLine then
        frame.BottomLine:SetWidth(thickness)
    end
    if frame.LeftLine then
        frame.LeftLine:SetHeight(thickness)
    end
    if frame.RightLine then
        frame.RightLine:SetHeight(thickness)
    end
end

-- Update line gap from center
function CPlusNS.UpdateLineGap()
    local frame = state.frame
    if not frame or not frame.Core then
        return
    end

    -- Skip if lines are disabled
    if not CPlusNS.db.showLines then
        return
    end

    local gap = CPlusNS.db.lineStartGap

    -- Use actual circle radius from state (updated on nameplate resize)
    -- Default (gap=0) should start at circle edge
    -- Negative values go inward toward center
    -- Positive values go outward from edge
    local coreRadius = state.circleRadius
    local offset = coreRadius + gap

    -- Reposition lines starting from center with the calculated offset
    if frame.TopLine then
        frame.TopLine:ClearAllPoints()
        frame.TopLine:SetPoint("BOTTOM", frame.Core, "CENTER", 0, offset)
    end
    if frame.BottomLine then
        frame.BottomLine:ClearAllPoints()
        frame.BottomLine:SetPoint("TOP", frame.Core, "CENTER", 0, -offset)
    end
    if frame.LeftLine then
        frame.LeftLine:ClearAllPoints()
        frame.LeftLine:SetPoint("RIGHT", frame.Core, "CENTER", -offset, 0)
    end
    if frame.RightLine then
        frame.RightLine:ClearAllPoints()
        frame.RightLine:SetPoint("LEFT", frame.Core, "CENTER", offset, 0)
    end
end

-- Update line visibility based on settings
function CPlusNS.UpdateLineVisibility()
    local frame = state.frame
    if not frame then
        CPlusNS.Debug("UpdateLineVisibility: frame is nil!")
        return
    end

    local showLines = CPlusNS.db.showLines

    local lineKeys = CONST.LINE_KEYS
    for i = 1, #lineKeys do
        if frame[lineKeys[i]] then frame[lineKeys[i]]:SetShown(showLines) end
    end
end
