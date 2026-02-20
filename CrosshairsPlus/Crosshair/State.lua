--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Crosshair/State.lua - Shared runtime state, constants, and library references
]]--

local AddonName, CPlusNS = ...
local defaults = CPlusNS.defaults

-- Internal runtime state (not settings, not persisted)
CPlusNS.state = {
    frame = nil,              -- CrosshairsPlusFrame ref (set once in Init)
    updateTimer = 0,          -- elapsed accumulator (OnUpdate + RefreshActiveUnit)
    lastNameplateWidth = 0,   -- cache for AttachToNameplate
    activeUnit = nil,         -- "target" / "softenemy" / nil
    lastRangeVal = nil,       -- cached raw range number (for change detection)
    lastMaxRange = nil,       -- cached maxRange flag (nil vs number distinction)
    lastUnitR = 1,            -- cached unit color R (set by OnUpdate + AttachToNameplate)
    lastUnitG = 1,            -- cached unit color G
    lastUnitB = 1,            -- cached unit color B
    lastRangeR = nil,         -- cached range text color R (for change detection)
    lastRangeG = nil,         -- cached range text color G
    lastRangeB = nil,         -- cached range text color B
    circleRadius = 48,        -- actual circle radius (updated on resize)
    rotationAngle = 0,        -- current arrow rotation angle (0-360 degrees)
    cachedSpeed = defaults.arrowRotationSpeed,
    cachedRadius = defaults.arrowDistance,
    cachedCounterClockwise = defaults.arrowsRotateCounterClockwise,
}

-- Constants (read-only, shared across modules)
CPlusNS.CONST = {
    UPDATE_INTERVAL = 0.3,
    NAMEPLATE_SIZE_PADDING = 14,    -- added to nameplate width for circle sizing
    MIN_CIRCLE_SIZE = 48,           -- minimum circle diameter
    ARROW_KEYS = {"ArrowTop", "ArrowRight", "ArrowBottom", "ArrowLeft"},
    LINE_KEYS  = {"TopLine", "BottomLine", "LeftLine", "RightLine"},
    ARROW_DATA = {
        {key = "ArrowTop",    offset = 0,   rotationOffset = 180, sx = 0,  sy = 1},
        {key = "ArrowRight",  offset = 90,  rotationOffset = 90,  sx = 1,  sy = 0},
        {key = "ArrowBottom", offset = 180, rotationOffset = 0,   sx = 0,  sy = -1},
        {key = "ArrowLeft",   offset = 270, rotationOffset = -90, sx = -1, sy = 0},
    },
}

-- Library references
CPlusNS.RC = nil  -- lazy-loaded by Range.lua via CrosshairsPlus_Range sub-addon
CPlusNS.LSM = LibStub("LibSharedMedia-3.0")

-- Shared helpers

-- Resolve font name to font path (handles "Default" and LSM lookup)
function CPlusNS.ResolveFont(fontName)
    if fontName == "Default" then
        return select(1, GameFontNormal:GetFont())
    end
    return CPlusNS.LSM:Fetch("font", fontName)
end

-- Anchor lookup for text positioning
local TEXT_ANCHORS = {
    TOP    = {"BOTTOM", "TOP"},
    BOTTOM = {"TOP", "BOTTOM"},
    LEFT   = {"RIGHT", "LEFT"},
    RIGHT  = {"LEFT", "RIGHT"},
}

-- Set text frame anchor relative to another frame by position keyword
function CPlusNS.SetTextAnchor(textFrame, anchorTo, position, xOff, yOff)
    textFrame:ClearAllPoints()
    local a = TEXT_ANCHORS[position]
    if a then textFrame:SetPoint(a[1], anchorTo, a[2], xOff, yOff) end
end
