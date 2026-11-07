local _, CPlusNS = ...
local state = CPlusNS.state
local CONST = CPlusNS.CONST

local RAD = math.pi / 180
local sin, cos = math.sin, math.cos

local angle, radians, x, y

function CPlusNS.RefreshRotationCache()
    if CPlusNS.db then
        state.cachedSpeed = CPlusNS.db.arrowRotationSpeed
        state.cachedRadius = CPlusNS.db.arrowDistance
        state.cachedCounterClockwise = CPlusNS.db.arrowsRotateCounterClockwise
    end
end

function CPlusNS.UpdateArrowRotation(elapsed)
    local frame = state.frame

    if not frame or not frame.ArrowTop or not frame.Core then
        CPlusNS.Debug("UpdateArrowRotation: frame or arrows not found")
        return
    end

    local speed = state.cachedSpeed
    local radius = state.cachedRadius
    local counterClockwise = state.cachedCounterClockwise
    local arrowData = CONST.ARROW_DATA

    local rotationIncrement = elapsed * speed
    if counterClockwise then
        state.rotationAngle = state.rotationAngle - rotationIncrement
    else
        state.rotationAngle = state.rotationAngle + rotationIncrement
    end

    state.rotationAngle = state.rotationAngle % 360
    local rotAngle = state.rotationAngle

    angle = rotAngle + arrowData[1].offset
    radians = angle * RAD
    x = radius * sin(radians)
    y = radius * cos(radians)
    frame.ArrowTop:ClearAllPoints()
    frame.ArrowTop:SetPoint("CENTER", frame.Core, "CENTER", x, y)
    frame.ArrowTop:SetRotation((-rotAngle + arrowData[1].rotationOffset) * RAD)

    angle = rotAngle + arrowData[2].offset
    radians = angle * RAD
    x = radius * sin(radians)
    y = radius * cos(radians)
    frame.ArrowRight:ClearAllPoints()
    frame.ArrowRight:SetPoint("CENTER", frame.Core, "CENTER", x, y)
    frame.ArrowRight:SetRotation((-rotAngle + arrowData[2].rotationOffset) * RAD)

    angle = rotAngle + arrowData[3].offset
    radians = angle * RAD
    x = radius * sin(radians)
    y = radius * cos(radians)
    frame.ArrowBottom:ClearAllPoints()
    frame.ArrowBottom:SetPoint("CENTER", frame.Core, "CENTER", x, y)
    frame.ArrowBottom:SetRotation((-rotAngle + arrowData[3].rotationOffset) * RAD)

    angle = rotAngle + arrowData[4].offset
    radians = angle * RAD
    x = radius * sin(radians)
    y = radius * cos(radians)
    frame.ArrowLeft:ClearAllPoints()
    frame.ArrowLeft:SetPoint("CENTER", frame.Core, "CENTER", x, y)
    frame.ArrowLeft:SetRotation((-rotAngle + arrowData[4].rotationOffset) * RAD)
end

function CPlusNS.UpdateArrowStyle()
    local frame = state.frame
    if not frame then
        return
    end

    local arrowStyle = CPlusNS.db.arrowStyle

    local texturePath
    if arrowStyle == "none" then
        for i = 1, #CONST.ARROW_KEYS do
            local key = CONST.ARROW_KEYS[i]
            if frame[key] then frame[key]:Hide() end
        end
        return
    elseif arrowStyle:match("^arrow%d+$") then
        local arrowNum = arrowStyle:match("^arrow(%d+)$")
        texturePath = "Interface\\AddOns\\CrosshairsPlus\\Assets\\Arrow" .. arrowNum
    else
        texturePath = "Interface\\AddOns\\CrosshairsPlus\\Assets\\Arrow0"
    end

    local arrowSize = CPlusNS.db.arrowSize

    for i = 1, #CONST.ARROW_KEYS do
        local key = CONST.ARROW_KEYS[i]
        if frame[key] then
            frame[key]:SetTexture(texturePath)
            frame[key]:SetSize(arrowSize, arrowSize)
            frame[key]:Show()
        end
    end

    if not CPlusNS.db.arrowsRotate then
        state.rotationAngle = 0

        local distance = CPlusNS.db.arrowDistance

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
        CPlusNS.Debug("UpdateArrowStyle: Rotation ENABLED, angle=" .. tostring(state.rotationAngle))
    end
end
