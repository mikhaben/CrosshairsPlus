--[[
    CrosshairsPlus - About Tab (AceConfig)
    Version info and slash commands
]]--

local AddonName, CPlusNS = ...

function CPlusNS.BuildAboutTab()
    return {
        type = "group",
        name = "About",
        order = 7,
        args = {
            title = {
                type = "description",
                name = "|cff00ff00" .. CPlusNS.Title .. "|r",
                order = 1,
                fontSize = "large",
            },
            version = {
                type = "description",
                name = "Version " .. CPlusNS.Version,
                order = 2,
                fontSize = "medium",
            },
            author = {
                type = "description",
                name = "Author: |cffffffff" .. CPlusNS.Author .. "|r",
                order = 3,
                fontSize = "medium",
            },
            aboutText = {
                type = "description",
                name = "\nCrosshairsPlus places a customizable crosshair overlay on your target's nameplate, making it easy to track your current target in busy encounters. Choose from over 70 arrow styles, adjust colors, size, opacity, and add a range display. Lightweight and built to stay out of your way.",
                order = 4,
                fontSize = "medium",
            },
            slashHeader = {
                type = "header",
                name = "Slash Commands",
                order = 10,
            },
            slashInfo = {
                type = "description",
                name = "|cffffd100/chp|r — Open settings panel\n" ..
                       "|cffffd100/chp debug|r — Toggle debug mode\n" ..
                       "|cffffd100/chp test|r — Run diagnostics\n" ..
                       "|cffffd100/chp preview|r — Toggle crosshair at screen center",
                order = 11,
                fontSize = "medium",
            },
        },
    }
end
