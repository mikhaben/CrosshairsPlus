--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Crosshair.lua - Crosshair rendering and attachment logic
]]--

local AddonName, CPlusNS = ...

-- Local references
local frame
local currentNameplate = nil
local updateTimer = 0
local UPDATE_INTERVAL = 0.05 -- Update every 0.05 seconds (20fps) for responsive nameplate detection
local debugMode = false -- Set to true to enable debug logging

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
        -- NPC/Creature
        local isHostile = UnitCanAttack("player", unit) or UnitIsEnemy("player", unit)

        -- Check if it's a critter
        local classification = UnitClassification(unit)
        if classification == "trivial" or classification == "minus" then
            return db.showCritters
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
    if frame.Core then
        frame.Core:SetVertexColor(r, g, b)
    end
    if frame.CoreGlow then
        frame.CoreGlow:SetVertexColor(r, g, b)
    end
    if frame.Arrows then
        frame.Arrows:SetVertexColor(r, g, b)
    end

    -- Apply to lines if enabled
    if CPlusNS.db.showLines then
        if frame.TopLine then frame.TopLine:SetVertexColor(r, g, b) end
        if frame.BottomLine then frame.BottomLine:SetVertexColor(r, g, b) end
        if frame.LeftLine then frame.LeftLine:SetVertexColor(r, g, b) end
        if frame.RightLine then frame.RightLine:SetVertexColor(r, g, b) end
    end
end

-- Update line thickness based on settings
function CPlusNS.UpdateLineThickness()
    if not frame then
        print("|cffff0000CrosshairsPlus|r: UpdateLineThickness called but frame is nil!")
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

-- Update range display
local function UpdateRange(unit)
    if not CPlusNS.db.showRange or not frame.RangeText then
        if frame.RangeText then
            frame.RangeText:Hide()
        end
        return
    end

    if not unit or not UnitExists(unit) then
        frame.RangeText:Hide()
        return
    end

    -- Use LibRangeCheck if available
    if CPlusNS.RangeCheck then
        local minRange, maxRange = CPlusNS.RangeCheck:GetRange(unit)

        if maxRange then
            frame.RangeText:SetText(string.format("%.0f yd", maxRange))
            frame.RangeText:Show()
        else
            frame.RangeText:Hide()
        end
    else
        -- Fallback: simple distance check
        frame.RangeText:Hide()
    end
end

-- Update name display
local function UpdateName(unit)
    if not CPlusNS.db.showName or not frame.NameText then
        if frame.NameText then
            frame.NameText:Hide()
        end
        return
    end

    if not unit or not UnitExists(unit) then
        frame.NameText:Hide()
        return
    end

    local name = GetUnitName(unit, false)
    if name and name ~= "Unknown" then
        frame.NameText:SetText(name)
        frame.NameText:Show()
    else
        frame.NameText:Hide()
    end
end

-- Attach crosshair to nameplate
local function AttachToNameplate(nameplate)
    if not nameplate then
        if debugMode then print("AttachToNameplate: nameplate is nil!") end
        return
    end

    if debugMode then print("AttachToNameplate: attaching, wasShown=" .. tostring(frame:IsShown())) end

    currentNameplate = nameplate

    -- Always clear and reattach (like Crosshairs addon)
    frame:ClearAllPoints()
    frame:SetParent(nameplate)
    frame:SetPoint("CENTER")

    -- Dynamic sizing based on nameplate width
    local width = nameplate:GetWidth() + 14
    if frame.Core then
        frame.Core:SetSize(width, width)
    end
    if frame.CoreGlow then
        frame.CoreGlow:SetSize(width, width)
    end
    if frame.CoreShadow then
        frame.CoreShadow:SetSize(width, width)
    end

    -- Apply scale
    frame:SetScale(CPlusNS.db.crosshairScale or 1.0)
    frame:SetAlpha(CPlusNS.db.crosshairAlpha or 1.0)

    -- Update visuals
    CPlusNS.UpdateLineThickness()
    CPlusNS.UpdateLineVisibility()

    -- Get color and apply
    local r, g, b = CPlusNS.GetUnitColor("target")
    ApplyColorToTextures(r, g, b)

    -- Update text displays
    UpdateName("target")
    UpdateRange("target")

    -- Show with fade in and pulse
    if not frame:IsShown() then
        if debugMode then print("AttachToNameplate: Showing frame (was hidden)") end
        frame:Show()
        -- Note: We don't have FadeIn/ScalePulse animations in our simplified XML
    else
        if debugMode then print("AttachToNameplate: Frame already showing, just repositioned") end
    end
end

-- Hide crosshair
local function HideCrosshair()
    if debugMode then print("HideCrosshair called, IsShown=" .. tostring(frame:IsShown())) end

    if frame:IsShown() then
        -- Just play fadeout animation, don't call Hide() manually
        if frame.FadeOut then
            if debugMode then print("Playing FadeOut animation") end
            frame.FadeOut:Play()
        end
    end
    currentNameplate = nil
end

-- Handle target change
local function OnTargetChanged()
    local unit = "target"

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
        AttachToNameplate(nameplate)
    else
        HideCrosshair()
    end
end

-- OnUpdate handler for continuous updates (range, color changes, etc.)
local function OnUpdate(self, elapsed)
    updateTimer = updateTimer + elapsed

    if updateTimer >= UPDATE_INTERVAL then
        updateTimer = 0

        -- Only update range and color, DO NOT hide/show (let events handle that)
        if frame:IsShown() and UnitExists("target") then
            -- Update range
            UpdateRange("target")

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

-- Update all crosshair visuals (called from settings panel)
function CPlusNS.UpdateCrosshairVisuals()
    CPlusNS.UpdateLineThickness()
    CPlusNS.UpdateLineVisibility()

    if frame:IsShown() and UnitExists("target") then
        local r, g, b = CPlusNS.GetUnitColor("target")
        ApplyColorToTextures(r, g, b)
        UpdateName("target")
        UpdateRange("target")

        frame:SetScale(CPlusNS.db.crosshairScale or 1.0)
        frame:SetAlpha(CPlusNS.db.crosshairAlpha or 1.0)
    end
end

-- Toggle debug mode
function CPlusNS.ToggleDebug()
    debugMode = not debugMode
    if debugMode then
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

    print("|cff00ff00CrosshairsPlus|r: Frame reference acquired: " .. tostring(frame))

    -- Check if child elements exist (set in OnLoad script of XML)
    if frame.Core then
        print("|cff00ff00CrosshairsPlus|r: Core texture found")
    else
        print("|cffff0000CrosshairsPlus|r: WARNING - Core texture not found!")
    end

    if frame.TopLine then
        print("|cff00ff00CrosshairsPlus|r: Lines found")
    else
        print("|cffff0000CrosshairsPlus|r: WARNING - Lines not found!")
    end

    -- Set up OnUpdate for continuous updates
    frame:SetScript("OnUpdate", OnUpdate)

    -- Register for target change events
    CPlusNS.EventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    CPlusNS.EventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    CPlusNS.EventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

    print("|cff00ff00CrosshairsPlus|r: Events registered")

    -- Initial setup - wrapped in pcall to catch errors
    local success, err = pcall(function()
        CPlusNS.UpdateLineThickness()
        CPlusNS.UpdateLineVisibility()
    end)

    if not success then
        print("|cffff0000CrosshairsPlus|r: Error in visual setup: " .. tostring(err))
    else
        print("|cff00ff00CrosshairsPlus|r: Crosshair visuals configured")
    end
end

-- Event: Player target changed
function CPlusNS:PLAYER_TARGET_CHANGED()
    OnTargetChanged()
end

-- Event: Nameplate added (following Crosshairs addon pattern exactly)
function CPlusNS:NAME_PLATE_UNIT_ADDED(unitToken)
    -- Get the nameplate for this unit token directly from the event
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitToken)

    -- Check if this nameplate is for our current target (note parameter order!)
    if nameplate and UnitIsUnit("target", unitToken) then
        if debugMode then print("NAMEPLATE_ADDED for target, nameplate=" .. tostring(nameplate)) end

        -- Check if we should show crosshair for this target
        if CPlusNS.ShouldShowCrosshair("target") then
            if debugMode then print("Attaching to nameplate from ADDED event") end
            AttachToNameplate(nameplate)
        end
    end
end

-- Event: Nameplate removed (following Crosshairs addon pattern)
function CPlusNS:NAME_PLATE_UNIT_REMOVED(unitToken)
    -- Check if the removed unit is our target
    if UnitIsUnit("target", unitToken) then
        if debugMode then print("NAMEPLATE_REMOVED for target - hiding") end
        HideCrosshair()
    end
end
