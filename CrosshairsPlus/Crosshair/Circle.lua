--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Crosshair/Circle.lua - Circle style switching
]]--

local AddonName, CPlusNS = ...
local state = CPlusNS.state

-- Update circle style
function CPlusNS.UpdateCircleStyle()
    local frame = state.frame
    if not frame or not frame.Core then
        return
    end

    local circleStyle = CPlusNS.db.circleStyle
    local texturePath = "Interface\\AddOns\\CrosshairsPlus\\Assets\\" .. circleStyle
    frame.Core:SetTexture(texturePath)

    local effect = CPlusNS.db.circleEffect
    if frame.CoreGlow then frame.CoreGlow:SetShown(effect == "glow") end
    if frame.CoreShadow then frame.CoreShadow:SetShown(effect == "shadow") end
end
