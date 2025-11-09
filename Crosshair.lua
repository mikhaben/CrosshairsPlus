--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Crosshair.lua - Crosshair rendering and attachment logic
]]--

local AddonName, CPlusNS = ...

-- Local references
local frame
local currentNameplate = nil
local updateTimer = 0
local UPDATE_INTERVAL = 0.3 -- Update every 0.3 seconds for color/range checks (color changes are rare)
local lastNameplateWidth = 0 -- Cache last nameplate width to avoid redundant resizing

-- Check if target should show crosshair based on user settings
function CPlusNS.ShouldShowCrosshair(unit)
    if not unit or not UnitExists(unit) then
        return false
    end

    local db = CPlusNS.db

    -- Check if unit is a player
    if UnitIsPlayer(unit) then
        if UnitCanAttack("player", unit) or UnitIsEnemy("player", unit) then
            return db.showEnemyPlayers
        else
            return db.showFriendlyPlayers
        end
    else
        -- NPC/Creature (including hunter/warlock pets)
        local isHostile = UnitCanAttack("player", unit) or UnitIsEnemy("player", unit)

        -- Skip critters (trivial/ambient creatures like rabbits, squirrels)
        local classification = UnitClassification(unit)
        if classification == "trivial" or classification == "minus" then
            return false  -- Never show crosshair on critters
        end

        if isHostile then
            return db.showHostileNPCs
        else
            return db.showFriendlyNPCs
        end
    end
end

-- Get color for unit based on type and class
function CPlusNS.GetUnitColor(unit)
    if not unit or not UnitExists(unit) then
        return 1, 1, 1 -- Default white
    end

    local db = CPlusNS.db

    -- Check if tapped by another player (gray)
    if UnitIsTapDenied(unit) then
        return 0.5, 0.5, 0.5
    end

    -- Player units with class coloring enabled
    if UnitIsPlayer(unit) and db.enableClassColors then
        local _, class = UnitClass(unit)
        if class and RAID_CLASS_COLORS[class] then
            local color = RAID_CLASS_COLORS[class]
            return color.r, color.g, color.b
        end
    end

    -- Friendly/Hostile coloring
    if UnitCanAttack("player", unit) or UnitIsEnemy("player", unit) then
        return 1, 0, 0 -- Red for hostile
    elseif UnitIsFriend("player", unit) or not UnitCanAttack("player", unit) then
        return 0, 1, 0 -- Green for friendly
    end

    -- Fallback to default selection color
    local r, g, b = UnitSelectionColor(unit)
    return r or 1, g or 1, b or 1
end

-- Apply color to all crosshair textures
local function ApplyColorToTextures(r, g, b)
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
        if frame.ArrowTop then frame.ArrowTop:SetVertexColor(r, g, b) end
        if frame.ArrowRight then frame.ArrowRight:SetVertexColor(r, g, b) end
        if frame.ArrowBottom then frame.ArrowBottom:SetVertexColor(r, g, b) end
        if frame.ArrowLeft then frame.ArrowLeft:SetVertexColor(r, g, b) end
    end

    -- Only update lines if shown
    if frame.TopLine and frame.TopLine:IsShown() then
        frame.TopLine:SetVertexColor(r, g, b)
    end
    if frame.BottomLine and frame.BottomLine:IsShown() then
        frame.BottomLine:SetVertexColor(r, g, b)
    end
    if frame.LeftLine and frame.LeftLine:IsShown() then
        frame.LeftLine:SetVertexColor(r, g, b)
    end
    if frame.RightLine and frame.RightLine:IsShown() then
        frame.RightLine:SetVertexColor(r, g, b)
    end
end

-- Update line thickness based on settings
function CPlusNS.UpdateLineThickness()
    if not frame then
        print("|cffff0000CrosshairsPlus|r: UpdateLineThickness called but frame is nil!")
        return
    end

    -- Skip if lines are disabled
    if not CPlusNS.db.showLines then
        return
    end

    local thickness = CPlusNS.db.lineThickness or 2

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
    if not frame or not frame.Core then
        return
    end

    -- Skip if lines are disabled
    if not CPlusNS.db.showLines then
        return
    end

    local gap = CPlusNS.db.lineStartGap or 0

    -- Core circle is 96px, so radius is 48px
    -- Default (gap=0) should start at circle edge
    -- Negative values go inward toward center
    -- Positive values go outward from edge
    local coreRadius = 48
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
    if not frame then
        print("|cffff0000CrosshairsPlus|r: UpdateLineVisibility called but frame is nil!")
        return
    end

    local showLines = CPlusNS.db.showLines

    if frame.TopLine then frame.TopLine:SetShown(showLines) end
    if frame.BottomLine then frame.BottomLine:SetShown(showLines) end
    if frame.LeftLine then frame.LeftLine:SetShown(showLines) end
    if frame.RightLine then frame.RightLine:SetShown(showLines) end
end

-- Hide unused text elements (range and name features not implemented)
local function HideTextElements()
    if frame.RangeText then
        frame.RangeText:Hide()
    end
    if frame.NameText then
        frame.NameText:Hide()
    end
end

-- Attach crosshair to nameplate
local function AttachToNameplate(nameplate)
    if not nameplate then
        if CPlusNS.db and CPlusNS.db.debugMode then print("AttachToNameplate: nameplate is nil!") end
        return
    end

    -- CRITICAL: Verify this nameplate actually belongs to our target
    if not UnitExists("target") then
        if CPlusNS.db and CPlusNS.db.debugMode then print("AttachToNameplate: No target exists!") end
        return
    end

    local targetNameplate = C_NamePlate.GetNamePlateForUnit("target")
    if targetNameplate ~= nameplate then
        if CPlusNS.db and CPlusNS.db.debugMode then
            print("AttachToNameplate: ERROR - nameplate mismatch!")
            print("  Passed nameplate: " .. tostring(nameplate))
            print("  Target nameplate: " .. tostring(targetNameplate))
        end
        return
    end

    if CPlusNS.db and CPlusNS.db.debugMode then
        local targetName = GetUnitName("target", false) or "Unknown"
        print("AttachToNameplate: attaching to " .. targetName .. ", wasShown=" .. tostring(frame:IsShown()))
    end

    currentNameplate = nameplate

    -- Always clear and reattach (like Crosshairs addon)
    frame:ClearAllPoints()
    frame:SetParent(nameplate)
    frame:SetPoint("CENTER")

    -- Dynamic sizing based on nameplate width (cached to avoid redundant resizing)
    local width = nameplate:GetWidth() + 14
    if width ~= lastNameplateWidth then
        lastNameplateWidth = width
        if frame.Core then
            frame.Core:SetSize(width, width)
        end
        if frame.CoreGlow then
            frame.CoreGlow:SetSize(width, width)
        end
        if frame.CoreShadow then
            frame.CoreShadow:SetSize(width, width)
        end
    end

    -- Apply scale
    frame:SetScale(CPlusNS.db.crosshairScale or 1.0)
    frame:SetAlpha(CPlusNS.db.crosshairAlpha or 1.0)

    -- Update visuals
    CPlusNS.UpdateLineThickness()
    CPlusNS.UpdateLineGap()
    CPlusNS.UpdateLineVisibility()
    CPlusNS.UpdateArrowStyle()
    CPlusNS.UpdateCircleStyle()

    -- Hide unused text elements
    HideTextElements()

    -- Show frame (instant, no fade)
    if not frame:IsShown() then
        if CPlusNS.db and CPlusNS.db.debugMode then print("AttachToNameplate: Showing frame (was hidden)") end
        frame:Show()
    else
        if CPlusNS.db and CPlusNS.db.debugMode then print("AttachToNameplate: Frame already showing, just repositioned") end
    end

    -- CRITICAL: Always update color AFTER showing frame (moved here to avoid duplicate code)
    -- This ensures immediate color update on target change
    local r, g, b = CPlusNS.GetUnitColor("target")
    if CPlusNS.db and CPlusNS.db.debugMode then
        local targetName = GetUnitName("target", false) or "Unknown"
        print(string.format("Applying color to %s: R=%.2f G=%.2f B=%.2f", targetName, r, g, b))
    end
    ApplyColorToTextures(r, g, b)

    -- Restore user's alpha setting after showing
    frame:SetAlpha(CPlusNS.db.crosshairAlpha or 1.0)
end

-- Hide crosshair
local function HideCrosshair()
    if CPlusNS.db and CPlusNS.db.debugMode then print("HideCrosshair called, IsShown=" .. tostring(frame:IsShown())) end

    if frame:IsShown() then
        if CPlusNS.db and CPlusNS.db.debugMode then print("Hiding frame instantly (no fade)") end
        frame:Hide()
    end
    currentNameplate = nil
end

-- Handle target change
local function OnTargetChanged()
    local unit = "target"

    -- Reset update timer to prevent stale color updates
    updateTimer = 0

    if not UnitExists(unit) then
        HideCrosshair()
        return
    end

    -- Check if we should show crosshair for this target
    if not CPlusNS.ShouldShowCrosshair(unit) then
        HideCrosshair()
        return
    end

    -- Get nameplate for target
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)

    if nameplate then
        -- AttachToNameplate already updates colors immediately
        AttachToNameplate(nameplate)
    else
        HideCrosshair()
    end
end

-- Rotation animation state
local rotationAngle = 0

-- Pre-calculate arrow data (avoid creating tables every frame)
local arrowData = {
    {offset = 0, rotationOffset = 180},     -- Top: point DOWN
    {offset = 90, rotationOffset = 90},     -- Right: point LEFT
    {offset = 180, rotationOffset = 0},     -- Bottom: point UP
    {offset = 270, rotationOffset = -90}    -- Left: point RIGHT
}

-- Reusable variables to avoid garbage collection
local angle, radians, x, y, arrowRotation

-- Cached rotation settings (updated when settings change)
local cachedSpeed = 5.0
local cachedRadius = 56
local cachedCounterClockwise = false

-- Refresh cached rotation settings (call when settings change)
local function RefreshRotationCache()
    if CPlusNS.db then
        cachedSpeed = CPlusNS.db.arrowRotationSpeed or 5.0
        cachedRadius = CPlusNS.db.arrowDistance or 56
        cachedCounterClockwise = CPlusNS.db.arrowsRotateCounterClockwise or false
    end
end

-- Update arrow rotation (called from OnUpdate)
-- Makes arrows orbit around the circle while pointing toward center
local function UpdateArrowRotation(elapsed)
    if not CPlusNS.db or not CPlusNS.db.arrowsRotate then
        return
    end

    -- CRITICAL: Don't rotate if arrows are disabled
    if CPlusNS.db.arrowStyle == "none" then
        return
    end

    if not frame or not frame.ArrowTop or not frame.Core then
        if CPlusNS.db and CPlusNS.db.debugMode then
            print("UpdateArrowRotation: frame or arrows not found")
        end
        return
    end

    -- Use cached settings for performance (updated when settings change)
    local speed = cachedSpeed
    local radius = cachedRadius
    local counterClockwise = cachedCounterClockwise

    -- Calculate rotation increment (360 degrees in 'speed' seconds)
    -- Default is clockwise (positive), checkbox enables counter-clockwise (negative)
    local rotationIncrement = elapsed * (360 / speed)
    if counterClockwise then
        rotationAngle = rotationAngle - rotationIncrement
    else
        rotationAngle = rotationAngle + rotationIncrement
    end

    -- Wrap angle to stay within 0-360 range
    if rotationAngle >= 360 then
        rotationAngle = rotationAngle - 360
    elseif rotationAngle < 0 then
        rotationAngle = rotationAngle + 360
    end

    -- Update ArrowTop
    angle = rotationAngle + arrowData[1].offset
    radians = math.rad(angle)
    x = radius * math.sin(radians)
    y = radius * math.cos(radians)
    frame.ArrowTop:ClearAllPoints()
    frame.ArrowTop:SetPoint("CENTER", frame.Core, "CENTER", x, y)
    frame.ArrowTop:SetRotation(math.rad(-rotationAngle + arrowData[1].rotationOffset))

    -- Update ArrowRight
    angle = rotationAngle + arrowData[2].offset
    radians = math.rad(angle)
    x = radius * math.sin(radians)
    y = radius * math.cos(radians)
    frame.ArrowRight:ClearAllPoints()
    frame.ArrowRight:SetPoint("CENTER", frame.Core, "CENTER", x, y)
    frame.ArrowRight:SetRotation(math.rad(-rotationAngle + arrowData[2].rotationOffset))

    -- Update ArrowBottom
    angle = rotationAngle + arrowData[3].offset
    radians = math.rad(angle)
    x = radius * math.sin(radians)
    y = radius * math.cos(radians)
    frame.ArrowBottom:ClearAllPoints()
    frame.ArrowBottom:SetPoint("CENTER", frame.Core, "CENTER", x, y)
    frame.ArrowBottom:SetRotation(math.rad(-rotationAngle + arrowData[3].rotationOffset))

    -- Update ArrowLeft
    angle = rotationAngle + arrowData[4].offset
    radians = math.rad(angle)
    x = radius * math.sin(radians)
    y = radius * math.cos(radians)
    frame.ArrowLeft:ClearAllPoints()
    frame.ArrowLeft:SetPoint("CENTER", frame.Core, "CENTER", x, y)
    frame.ArrowLeft:SetRotation(math.rad(-rotationAngle + arrowData[4].rotationOffset))
end

-- OnUpdate handler for continuous updates (range, color changes, rotation, etc.)
local function OnUpdate(self, elapsed)
    if not frame or not CPlusNS.db then
        return
    end

    -- CRITICAL: Exit immediately if frame is hidden to avoid wasted CPU cycles
    if not frame:IsShown() then
        updateTimer = 0  -- Reset timer when hidden
        return
    end

    updateTimer = updateTimer + elapsed

    -- Update arrow rotation every frame if enabled
    if CPlusNS.db.arrowsRotate then
        UpdateArrowRotation(elapsed)
    end

    if updateTimer >= UPDATE_INTERVAL then
        updateTimer = 0

        -- Only update color, DO NOT hide/show (let events handle that)
        if UnitExists("target") then
            -- Update color in case it changed (e.g., tapped by someone else)
            local r, g, b = CPlusNS.GetUnitColor("target")
            ApplyColorToTextures(r, g, b)
        end
    end
end

-- Refresh crosshair (called when settings change or on zone change)
function CPlusNS.RefreshCrosshair()
    if UnitExists("target") and frame:IsShown() then
        OnTargetChanged()
    end
end

-- Update arrow style (sets texture for all 4 arrows)
function CPlusNS.UpdateArrowStyle()
    if not frame then
        return
    end

    local arrowStyle = CPlusNS.db.arrowStyle or "arrow0"

    -- Map style to texture path
    local texturePath
    if arrowStyle == "none" then
        -- Hide all arrows
        if frame.ArrowTop then frame.ArrowTop:Hide() end
        if frame.ArrowRight then frame.ArrowRight:Hide() end
        if frame.ArrowBottom then frame.ArrowBottom:Hide() end
        if frame.ArrowLeft then frame.ArrowLeft:Hide() end
        return
    elseif arrowStyle:match("^arrow%d+$") then
        -- Handle arrow0, arrow1, arrow2, ... arrow50
        local arrowNum = arrowStyle:match("^arrow(%d+)$")
        texturePath = "Interface\\AddOns\\CrosshairsPlus\\Assets\\Arrow" .. arrowNum
    else
        -- Default fallback
        texturePath = "Interface\\AddOns\\CrosshairsPlus\\Assets\\Arrow0"
    end

    -- Get arrow size from settings
    local arrowSize = CPlusNS.db.arrowSize or 32

    -- Apply texture and size to all 4 arrows
    -- Note: Don't unconditionally call :Show() as it overrides "none" setting
    if frame.ArrowTop then
        frame.ArrowTop:SetTexture(texturePath)
        frame.ArrowTop:SetSize(arrowSize, arrowSize)
        if not frame.ArrowTop:IsShown() and frame:IsShown() then
            frame.ArrowTop:Show()
        end
    end
    if frame.ArrowRight then
        frame.ArrowRight:SetTexture(texturePath)
        frame.ArrowRight:SetSize(arrowSize, arrowSize)
        if not frame.ArrowRight:IsShown() and frame:IsShown() then
            frame.ArrowRight:Show()
        end
    end
    if frame.ArrowBottom then
        frame.ArrowBottom:SetTexture(texturePath)
        frame.ArrowBottom:SetSize(arrowSize, arrowSize)
        if not frame.ArrowBottom:IsShown() and frame:IsShown() then
            frame.ArrowBottom:Show()
        end
    end
    if frame.ArrowLeft then
        frame.ArrowLeft:SetTexture(texturePath)
        frame.ArrowLeft:SetSize(arrowSize, arrowSize)
        if not frame.ArrowLeft:IsShown() and frame:IsShown() then
            frame.ArrowLeft:Show()
        end
    end

    -- Set initial positions and rotation
    if not CPlusNS.db.arrowsRotate then
        -- If rotation is disabled, set static positions (top/right/bottom/left)
        rotationAngle = 0

        -- Get configured distance from center (same as rotating arrows)
        local distance = CPlusNS.db.arrowDistance or 56

        -- For static arrows, we use CENTER to CENTER positioning to match rotating arrows
        -- The distance is from center of core to center of arrow
        -- Reset arrows to fixed positions - each pointing toward center
        -- Arrow texture naturally points UP (0°), so we rotate based on position:
        if frame.ArrowTop then
            frame.ArrowTop:ClearAllPoints()
            frame.ArrowTop:SetPoint("CENTER", frame.Core, "CENTER", 0, distance)
            frame.ArrowTop:SetRotation(math.rad(180))  -- At top, point DOWN (180°)
        end
        if frame.ArrowRight then
            frame.ArrowRight:ClearAllPoints()
            frame.ArrowRight:SetPoint("CENTER", frame.Core, "CENTER", distance, 0)
            frame.ArrowRight:SetRotation(math.rad(90))  -- At right, point LEFT (90°)
        end
        if frame.ArrowBottom then
            frame.ArrowBottom:ClearAllPoints()
            frame.ArrowBottom:SetPoint("CENTER", frame.Core, "CENTER", 0, -distance)
            frame.ArrowBottom:SetRotation(math.rad(0))  -- At bottom, point UP (0°)
        end
        if frame.ArrowLeft then
            frame.ArrowLeft:ClearAllPoints()
            frame.ArrowLeft:SetPoint("CENTER", frame.Core, "CENTER", -distance, 0)
            frame.ArrowLeft:SetRotation(math.rad(-90))  -- At left, point RIGHT (-90°/270°)
        end

        if CPlusNS.db and CPlusNS.db.debugMode then
            print("UpdateArrowStyle: Rotation DISABLED, set static positions")
        end
    else
        -- Rotation is enabled, keep angle continuous (don't reset)
        -- Note: rotationAngle will be 0 on first load, then continues from there
        if CPlusNS.db and CPlusNS.db.debugMode then
            print("UpdateArrowStyle: Rotation ENABLED, angle=" .. tostring(rotationAngle))
        end
    end
end

-- Update circle style
function CPlusNS.UpdateCircleStyle()
    if not frame or not frame.Core then
        return
    end

    local circleStyle = CPlusNS.db.circleStyle or "default"

    if circleStyle == "minimal" then
        -- Use minimal circle (from Crosshairs addon)
        frame.Core:SetTexture("Interface\\AddOns\\CrosshairsPlus\\Assets\\circle")
    else
        -- Default: detailed core texture
        frame.Core:SetTexture("Interface\\AddOns\\CrosshairsPlus\\Assets\\core")
    end
end

-- Update all crosshair visuals (called from settings panel)
function CPlusNS.UpdateCrosshairVisuals()
    -- Refresh cached settings for performance
    RefreshRotationCache()

    CPlusNS.UpdateLineThickness()
    CPlusNS.UpdateLineGap()
    CPlusNS.UpdateLineVisibility()
    CPlusNS.UpdateArrowStyle()
    CPlusNS.UpdateCircleStyle()

    if frame:IsShown() and UnitExists("target") then
        local r, g, b = CPlusNS.GetUnitColor("target")
        ApplyColorToTextures(r, g, b)
        HideTextElements()

        frame:SetScale(CPlusNS.db.crosshairScale or 1.0)
        frame:SetAlpha(CPlusNS.db.crosshairAlpha or 1.0)
    end
end

-- Toggle debug mode
function CPlusNS.ToggleDebug()
    CPlusNS.db.debugMode = not CPlusNS.db.debugMode
    if CPlusNS.db.debugMode then
        print("|cff00ff00CrosshairsPlus|r: Debug mode ENABLED")
        print("Watch chat for crosshair events during camera movement")
    else
        print("|cff00ff00CrosshairsPlus|r: Debug mode DISABLED")
    end
end

-- Initialize crosshair system
function CPlusNS.InitializeCrosshair()
    -- Get frame reference
    frame = _G["CrosshairsPlusFrame"]

    -- Ensure frame exists
    if not frame then
        print("|cffff0000CrosshairsPlus|r: Error - CrosshairsPlusFrame not found in _G!")
        return
    end

    -- Debug: Frame reference acquired
    if CPlusNS.db and CPlusNS.db.debugMode then
        print("|cff00ff00CrosshairsPlus|r: Frame reference acquired: " .. tostring(frame))
    end

    -- Check if child elements exist (set in OnLoad script of XML)
    if frame.Core then
        if CPlusNS.db and CPlusNS.db.debugMode then
            print("|cff00ff00CrosshairsPlus|r: Core texture found")
        end
    else
        print("|cffff0000CrosshairsPlus|r: WARNING - Core texture not found!")
    end

    if frame.TopLine then
        if CPlusNS.db and CPlusNS.db.debugMode then
            print("|cff00ff00CrosshairsPlus|r: Lines found")
        end
    else
        print("|cffff0000CrosshairsPlus|r: WARNING - Lines not found!")
    end

    -- Check if 4 arrow frames exist
    if frame.ArrowTop and frame.ArrowRight and frame.ArrowBottom and frame.ArrowLeft then
        if CPlusNS.db and CPlusNS.db.debugMode then
            print("|cff00ff00CrosshairsPlus|r: 4 Arrow frames found")
        end
    else
        print("|cffff0000CrosshairsPlus|r: WARNING - Arrow frames not found!")
        print("  ArrowTop: " .. tostring(frame.ArrowTop ~= nil))
        print("  ArrowRight: " .. tostring(frame.ArrowRight ~= nil))
        print("  ArrowBottom: " .. tostring(frame.ArrowBottom ~= nil))
        print("  ArrowLeft: " .. tostring(frame.ArrowLeft ~= nil))
    end

    -- Set up OnUpdate for continuous updates
    frame:SetScript("OnUpdate", OnUpdate)

    -- Register for target change events
    CPlusNS.EventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    CPlusNS.EventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    CPlusNS.EventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

    if CPlusNS.db and CPlusNS.db.debugMode then
        print("|cff00ff00CrosshairsPlus|r: Events registered")
    end

    -- Initial setup - wrapped in pcall to catch errors
    local success, err = pcall(function()
        RefreshRotationCache()  -- Cache rotation settings
        CPlusNS.UpdateLineThickness()
        CPlusNS.UpdateLineGap()
        CPlusNS.UpdateLineVisibility()
        CPlusNS.UpdateArrowStyle()
        CPlusNS.UpdateCircleStyle()
    end)

    if not success then
        print("|cffff0000CrosshairsPlus|r: Error in visual setup: " .. tostring(err))
    elseif CPlusNS.db and CPlusNS.db.debugMode then
        print("|cff00ff00CrosshairsPlus|r: Crosshair visuals configured")
    end
end

-- Event: Player target changed
function CPlusNS:PLAYER_TARGET_CHANGED()
    OnTargetChanged()
end

-- Event: Nameplate added (following Crosshairs addon pattern exactly)
function CPlusNS:NAME_PLATE_UNIT_ADDED(unitToken)
    -- Only care about nameplates if we have a target
    if not UnitExists("target") then
        return
    end

    -- Get the nameplate for this unit token directly from the event
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitToken)

    -- Check if this nameplate is for our current target (note parameter order!)
    if nameplate and UnitIsUnit("target", unitToken) then
        if CPlusNS.db and CPlusNS.db.debugMode then
            local targetName = GetUnitName("target", false) or "Unknown"
            print("NAMEPLATE_ADDED for target: " .. targetName .. ", nameplate=" .. tostring(nameplate))
        end

        -- Check if we should show crosshair for this target
        if CPlusNS.ShouldShowCrosshair("target") then
            if CPlusNS.db and CPlusNS.db.debugMode then print("Attaching to nameplate from ADDED event") end
            AttachToNameplate(nameplate)
        else
            if CPlusNS.db and CPlusNS.db.debugMode then print("Target exists but should NOT show crosshair (filtered out)") end
        end
    end
end

-- Event: Nameplate removed (following Crosshairs addon pattern)
function CPlusNS:NAME_PLATE_UNIT_REMOVED(unitToken)
    -- Check if the removed unit is our target
    if UnitIsUnit("target", unitToken) then
        if CPlusNS.db and CPlusNS.db.debugMode then print("NAMEPLATE_REMOVED for target - hiding") end
        HideCrosshair()
    end
end
