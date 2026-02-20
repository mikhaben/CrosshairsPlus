--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Crosshair/Arrows.lua - Arrow style, static positioning, rotation animation, and rotation cache
]]--

local AddonName, CPlusNS = ...
local state = CPlusNS.state
local CONST = CPlusNS.CONST

-- Cache math functions and constants for hot-path performance
local RAD = math.pi / 180
local sin, cos = math.sin, math.cos

-- Reusable variables to avoid garbage collection (file-local for hot-path performance)
local angle, radians, x, y

-- Refresh cached rotation settings (call when settings change)
function CPlusNS.RefreshRotationCache()
    if CPlusNS.db then
        state.cachedSpeed = CPlusNS.db.arrowRotationSpeed
        state.cachedRadius = CPlusNS.db.arrowDistance
        state.cachedCounterClockwise = CPlusNS.db.arrowsRotateCounterClockwise
    end
end

-- Update arrow rotation (called from OnUpdate)
-- Makes arrows orbit around the circle while pointing toward center
-- NOTE: Intentionally unrolled for per-frame performance — do NOT convert to loop
function CPlusNS.UpdateArrowRotation(elapsed)
    local frame = state.frame

    if not frame or not frame.ArrowTop or not frame.Core then
        CPlusNS.Debug("UpdateArrowRotation: frame or arrows not found")
        return
    end

    -- Use cached settings for performance (updated when settings change)
    local speed = state.cachedSpeed
    local radius = state.cachedRadius
    local counterClockwise = state.cachedCounterClockwise
    local arrowData = CONST.ARROW_DATA

    -- Calculate rotation increment (speed = degrees per second)
    -- Default is clockwise (positive), checkbox enables counter-clockwise (negative)
    local rotationIncrement = elapsed * speed
    if counterClockwise then
        state.rotationAngle = state.rotationAngle - rotationIncrement
    else
        state.rotationAngle = state.rotationAngle + rotationIncrement
    end

    -- Wrap angle to stay within 0-360 range (modulo handles any magnitude)
    state.rotationAngle = state.rotationAngle % 360
    local rotAngle = state.rotationAngle

    -- Update ArrowTop
    angle = rotAngle + arrowData[1].offset
    radians = angle * RAD
    x = radius * sin(radians)
    y = radius * cos(radians)
    frame.ArrowTop:ClearAllPoints()
    frame.ArrowTop:SetPoint("CENTER", frame.Core, "CENTER", x, y)
    frame.ArrowTop:SetRotation((-rotAngle + arrowData[1].rotationOffset) * RAD)

    -- Update ArrowRight
    angle = rotAngle + arrowData[2].offset
    radians = angle * RAD
    x = radius * sin(radians)
    y = radius * cos(radians)
    frame.ArrowRight:ClearAllPoints()
    frame.ArrowRight:SetPoint("CENTER", frame.Core, "CENTER", x, y)
    frame.ArrowRight:SetRotation((-rotAngle + arrowData[2].rotationOffset) * RAD)

    -- Update ArrowBottom
    angle = rotAngle + arrowData[3].offset
    radians = angle * RAD
    x = radius * sin(radians)
    y = radius * cos(radians)
    frame.ArrowBottom:ClearAllPoints()
    frame.ArrowBottom:SetPoint("CENTER", frame.Core, "CENTER", x, y)
    frame.ArrowBottom:SetRotation((-rotAngle + arrowData[3].rotationOffset) * RAD)

    -- Update ArrowLeft
    angle = rotAngle + arrowData[4].offset
    radians = angle * RAD
    x = radius * sin(radians)
    y = radius * cos(radians)
    frame.ArrowLeft:ClearAllPoints()
    frame.ArrowLeft:SetPoint("CENTER", frame.Core, "CENTER", x, y)
    frame.ArrowLeft:SetRotation((-rotAngle + arrowData[4].rotationOffset) * RAD)
end

-- Update arrow style (sets texture for all 4 arrows)
function CPlusNS.UpdateArrowStyle()
    local frame = state.frame
    if not frame then
        return
    end

    local arrowStyle = CPlusNS.db.arrowStyle

    -- Map style to texture path
    local texturePath
    if arrowStyle == "none" then
        for i = 1, #CONST.ARROW_KEYS do
            local key = CONST.ARROW_KEYS[i]
            if frame[key] then frame[key]:Hide() end
        end
        return
    elseif arrowStyle:match("^arrow%d+$") then
        -- Handle arrow0, arrow1, arrow2, ... arrow72
        local arrowNum = arrowStyle:match("^arrow(%d+)$")
        texturePath = "Interface\\AddOns\\CrosshairsPlus\\Assets\\Arrow" .. arrowNum
    else
        -- Default fallback
        texturePath = "Interface\\AddOns\\CrosshairsPlus\\Assets\\Arrow0"
    end

    -- Get arrow size from settings
    local arrowSize = CPlusNS.db.arrowSize

    -- Apply texture and size to all 4 arrows and show them
    for i = 1, #CONST.ARROW_KEYS do
        local key = CONST.ARROW_KEYS[i]
        if frame[key] then
            frame[key]:SetTexture(texturePath)
            frame[key]:SetSize(arrowSize, arrowSize)
            frame[key]:Show()
        end
    end

    -- Set initial positions and rotation
    if not CPlusNS.db.arrowsRotate then
        -- If rotation is disabled, set static positions (top/right/bottom/left)
        state.rotationAngle = 0

        -- Get configured distance from center (same as rotating arrows)
        local distance = CPlusNS.db.arrowDistance

        -- Reset arrows to fixed positions - each pointing toward center
        for i = 1, #CONST.ARROW_DATA do
            local data = CONST.ARROW_DATA[i]
            if frame[data.key] then
                frame[data.key]:ClearAllPoints()
                frame[data.key]:SetPoint("CENTER", frame.Core, "CENTER", data.sx * distance, data.sy * distance)
                frame[data.key]:SetRotation(math.rad(data.rotationOffset))
            end
        end

        CPlusNS.Debug("UpdateArrowStyle: Rotation DISABLED, set static positions")
    else
        -- Rotation is enabled, keep angle continuous (don't reset)
        CPlusNS.Debug("UpdateArrowStyle: Rotation ENABLED, angle=" .. tostring(state.rotationAngle))
    end
end
