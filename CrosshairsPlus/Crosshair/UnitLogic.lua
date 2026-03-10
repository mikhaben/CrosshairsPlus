--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Crosshair/UnitLogic.lua - Unit filtering, color logic, and nameplate CVar checks
]]--

local AddonName, CPlusNS = ...

local function IsHostile(unit)
    return UnitCanAttack("player", unit) or UnitIsEnemy("player", unit)
end

-- Check if target should show crosshair based on user settings
function CPlusNS.ShouldShowCrosshair(unit)
    if not unit or not UnitExists(unit) then
        return false
    end

    if UnitIsDead(unit) then
        return false
    end

    local db = CPlusNS.db

    local isHostile = IsHostile(unit)

    -- Check if unit is a player
    if UnitIsPlayer(unit) then
        if isHostile then
            return db.showEnemy and db.showEnemyPlayers
        else
            return db.showFriendly and db.showFriendlyPlayers
        end
    else
        -- NPC/Creature (including hunter/warlock pets)
        local classification = UnitClassification(unit)
        local isCritter = (classification == "trivial" or classification == "minus")

        if isHostile then
            if isCritter then
                return db.showEnemy and db.showEnemyCritters
            end
            return db.showEnemy and db.showEnemyNPCs
        else
            if isCritter then
                return db.showFriendly and db.showFriendlyCritters
            end
            return db.showFriendly and db.showFriendlyNPCs
        end
    end
end

-- Check nameplate CVars and return table of warning strings
function CPlusNS.CheckNameplateCVars()
    local warnings = {}
    local db = CPlusNS.db

    if GetCVar("nameplateShowAll") ~= "1" then
        table.insert(warnings, "Nameplates are disabled (Ctrl+V to toggle, or Interface > Names > Always Show Nameplates)")
        return warnings
    end

    local missing = {}

    if db.showEnemy and (db.showEnemyPlayers or db.showEnemyNPCs or db.showEnemyCritters)
        and GetCVar("nameplateShowEnemies") ~= "1" then
        table.insert(missing, "Enemy Units")
    end
    if db.showFriendly and db.showFriendlyPlayers
        and GetCVar("nameplateShowFriends") ~= "1" then
        table.insert(missing, "Friendly Players")
    end
    if db.showFriendly and (db.showFriendlyNPCs or db.showFriendlyCritters)
        and GetCVar("nameplateShowFriendlyNPCs") ~= "1" then
        table.insert(missing, "Friendly NPCs")
    end

    if #missing > 0 then
        table.insert(warnings, "WoW nameplates disabled for: " .. table.concat(missing, ", ")
            .. ". Enable in Interface > Names")
    end

    return warnings
end

-- Determine which unit (if any) the crosshair should follow
-- Hard target always takes priority over soft enemy
function CPlusNS.GetActiveUnit()
    if UnitExists("target") and CPlusNS.ShouldShowCrosshair("target") then
        return "target"
    end
    if CPlusNS.db.enableActionTargeting and UnitExists("softenemy") and CPlusNS.ShouldShowCrosshair("softenemy") then
        return "softenemy"
    end
    return nil
end

-- Reaction-based color (FACTION_BAR_COLORS with threat override)
local function GetReactionColor(unit)
    local reaction = UnitReaction("player", unit)

    -- Neutral mobs (reaction 4/yellow) stay reaction 4 even after you attack them.
    -- Check threat to override to hostile red when the player has aggroed the mob.
    if reaction and reaction == 4 and UnitThreatSituation("player", unit) ~= nil then
        local color = FACTION_BAR_COLORS[2]
        return color.r, color.g, color.b
    end

    if reaction and FACTION_BAR_COLORS[reaction] then
        local color = FACTION_BAR_COLORS[reaction]
        return color.r, color.g, color.b
    end

    -- Fallback: hostile red, friendly green
    if IsHostile(unit) then
        return 1, 0, 0
    end

    return 0, 1, 0
end

-- Get color for unit based on color mode setting
function CPlusNS.GetUnitColor(unit)
    if not unit or not UnitExists(unit) then
        return 1, 1, 1 -- Default white
    end

    local db = CPlusNS.db

    -- Tapped by another player is always gray
    if UnitIsTapDenied(unit) then
        return 0.5, 0.5, 0.5
    end

    local mode = db.colorMode or "class"

    if mode == "custom" then
        local isHostile = IsHostile(unit)
        if isHostile then
            local c = db.customEnemyColor
            return c.r, c.g, c.b
        else
            local c = db.customFriendlyColor
            return c.r, c.g, c.b
        end
    end

    if mode == "class" and UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        if class and RAID_CLASS_COLORS[class] then
            local color = RAID_CLASS_COLORS[class]
            return color.r, color.g, color.b
        end
    end

    -- "reaction" mode, or "class" mode fallthrough for NPCs
    return GetReactionColor(unit)
end
