local _, CPlusNS = ...
local defaults = CPlusNS.defaults

CPlusNS.state = {
    frame = nil,
    updateTimer = 0,
    lastNameplateWidth = 0,
    activeUnit = nil,
    lastRangeVal = nil,
    lastMaxRange = nil,
    lastUnitR = 1,
    lastUnitG = 1,
    lastUnitB = 1,
    lastRangeR = nil,
    lastRangeG = nil,
    lastRangeB = nil,
    circleRadius = 48,
    rotationAngle = 0,
    cachedSpeed = defaults.arrowRotationSpeed,
    cachedRadius = defaults.arrowDistance,
    cachedCounterClockwise = defaults.arrowsRotateCounterClockwise,
}

CPlusNS.CONST = {
    UPDATE_INTERVAL = 0.3,
    NAMEPLATE_SIZE_PADDING = 14,
    MIN_CIRCLE_SIZE = 48,
    ARROW_KEYS = {"ArrowTop", "ArrowRight", "ArrowBottom", "ArrowLeft"},
    LINE_KEYS  = {"TopLine", "BottomLine", "LeftLine", "RightLine"},
    ARROW_DATA = {
        {key = "ArrowTop",    offset = 0,   rotationOffset = 180, sx = 0,  sy = 1},
        {key = "ArrowRight",  offset = 90,  rotationOffset = 90,  sx = 1,  sy = 0},
        {key = "ArrowBottom", offset = 180, rotationOffset = 0,   sx = 0,  sy = -1},
        {key = "ArrowLeft",   offset = 270, rotationOffset = -90, sx = -1, sy = 0},
    },
}

CPlusNS.RC = nil
CPlusNS.LSM = LibStub("LibSharedMedia-3.0")

function CPlusNS.ResolveFont(fontName)
    if fontName == "Default" then
        return select(1, GameFontNormal:GetFont())
    end
    return CPlusNS.LSM:Fetch("font", fontName)
end

local TEXT_ANCHORS = {
    TOP    = {"BOTTOM", "TOP"},
    BOTTOM = {"TOP", "BOTTOM"},
    LEFT   = {"RIGHT", "LEFT"},
    RIGHT  = {"LEFT", "RIGHT"},
}

function CPlusNS.SetTextAnchor(textFrame, anchorTo, position, xOff, yOff)
    textFrame:ClearAllPoints()
    local a = TEXT_ANCHORS[position]
    if a then textFrame:SetPoint(a[1], anchorTo, a[2], xOff, yOff) end
end
