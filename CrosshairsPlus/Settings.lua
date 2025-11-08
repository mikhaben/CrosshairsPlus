--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Settings.lua - Settings panel and configuration UI
]]--

local AddonName, CPlusNS = ...

-- Settings frame
local settingsFrame = nil

-- Create settings panel
local function CreateSettingsPanel()
    -- Main settings frame
    local frame = CreateFrame("Frame", "CrosshairsPlusSettingsFrame", UIParent)
    frame:Hide()
    frame:SetSize(600, 700)

    -- Title
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("CrosshairsPlus Settings")

    -- Version text
    local version = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    version:SetText("Version " .. CPlusNS.Version)
    version:SetTextColor(0.5, 0.5, 0.5)

    -- Scroll frame for settings content
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -16)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 16)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(550, 1000)
    scrollFrame:SetScrollChild(content)

    -- Current Y offset for placing elements
    local yOffset = -10

    -- Helper function to create a checkbox
    local function CreateCheckbox(parent, text, tooltip, dbKey)
        local checkbox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, yOffset)
        checkbox.Text:SetText(text)
        checkbox.tooltipText = tooltip

        checkbox:SetChecked(CPlusNS.db[dbKey])

        checkbox:SetScript("OnClick", function(self)
            CPlusNS.db[dbKey] = self:GetChecked()
            CPlusNS.UpdateCrosshairVisuals()
        end)

        yOffset = yOffset - 30

        return checkbox
    end

    -- Helper function to create a section header
    local function CreateHeader(parent, text)
        local header = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        header:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, yOffset)
        header:SetText(text)
        header:SetTextColor(1, 0.82, 0)

        yOffset = yOffset - 30

        return header
    end

    -- Helper function to create a slider
    local function CreateSlider(parent, text, tooltip, min, max, step, dbKey)
        local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, yOffset)
        slider:SetWidth(400)
        slider:SetMinMaxValues(min, max)
        slider:SetValueStep(step)
        slider:SetValue(CPlusNS.db[dbKey])
        slider:SetObeyStepOnDrag(true)

        -- Slider texts
        slider.Text:SetText(text)
        slider.Low:SetText(tostring(min))
        slider.High:SetText(tostring(max))

        -- Value display
        local valueText = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        valueText:SetPoint("TOP", slider, "BOTTOM", 0, 0)
        valueText:SetText(tostring(CPlusNS.db[dbKey]))

        slider:SetScript("OnValueChanged", function(self, value)
            value = CPlusNS.Round(value, 1)
            CPlusNS.db[dbKey] = value
            valueText:SetText(tostring(value))
            CPlusNS.UpdateCrosshairVisuals()
        end)

        slider.tooltipText = tooltip

        yOffset = yOffset - 50

        return slider
    end

    -- Helper function to create a dropdown
    local function CreateDropdown(parent, text, tooltip, options, dbKey)
        local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
        dropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)

        -- Label
        local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        label:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 16, 3)
        label:SetText(text)

        -- Initialize dropdown
        UIDropDownMenu_SetWidth(dropdown, 200)
        UIDropDownMenu_SetText(dropdown, options[CPlusNS.db[dbKey]] or options[1])

        UIDropDownMenu_Initialize(dropdown, function(self, level)
            for key, displayText in pairs(options) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = displayText
                info.value = key
                info.func = function()
                    CPlusNS.db[dbKey] = key
                    UIDropDownMenu_SetText(dropdown, displayText)
                    CPlusNS.UpdateCrosshairVisuals()
                end
                info.checked = (CPlusNS.db[dbKey] == key)
                UIDropDownMenu_AddButton(info)
            end
        end)

        dropdown.tooltipText = tooltip

        yOffset = yOffset - 50

        return dropdown
    end

    -- TARGET FILTERS SECTION
    CreateHeader(content, "Target Filters")

    CreateCheckbox(content,
        "Show on Enemy Players",
        "Display crosshair on enemy players in PvP",
        "showEnemyPlayers")

    CreateCheckbox(content,
        "Show on Friendly Players",
        "Display crosshair on friendly players",
        "showFriendlyPlayers")

    CreateCheckbox(content,
        "Show on Hostile NPCs",
        "Display crosshair on hostile creatures and NPCs",
        "showHostileNPCs")

    CreateCheckbox(content,
        "Show on Friendly NPCs",
        "Display crosshair on friendly creatures and NPCs",
        "showFriendlyNPCs")

    CreateCheckbox(content,
        "Show on Critters",
        "Display crosshair on trivial targets (critters)",
        "showCritters")

    yOffset = yOffset - 10

    -- VISUAL OPTIONS SECTION
    CreateHeader(content, "Visual Options")

    CreateCheckbox(content,
        "Show Range Display",
        "Show distance to target in yards",
        "showRange")

    CreateCheckbox(content,
        "Show Target Name",
        "Display target's name above crosshair",
        "showName")

    CreateCheckbox(content,
        "Enable Class Coloring",
        "Color player targets based on their class",
        "enableClassColors")

    CreateCheckbox(content,
        "Show Crosshair Lines",
        "Display directional lines extending from crosshair",
        "showLines")

    yOffset = yOffset - 10

    -- STYLE SETTINGS SECTION
    CreateHeader(content, "Style Settings")

    CreateDropdown(content,
        "Arrow Style",
        "Choose the arrow animation style",
        {
            ["rotating"] = "Rotating Arrows",
            ["static"] = "Static Cross",
            ["circle"] = "Circle Only",
            ["minimal"] = "Minimal"
        },
        "arrowStyle")

    CreateDropdown(content,
        "Visual Style",
        "Choose the overall visual theme",
        {
            ["default"] = "Default",
            ["minimal"] = "Minimal",
            ["bold"] = "Bold"
        },
        "visualStyle")

    CreateSlider(content,
        "Line Thickness",
        "Adjust the thickness of crosshair lines (1-10 pixels)",
        1, 10, 1,
        "lineThickness")

    CreateSlider(content,
        "Crosshair Scale",
        "Adjust the overall size of the crosshair (0.5-2.0x)",
        0.5, 2.0, 0.1,
        "crosshairScale")

    CreateSlider(content,
        "Crosshair Opacity",
        "Adjust the transparency of the crosshair (0.0-1.0)",
        0.0, 1.0, 0.1,
        "crosshairAlpha")

    yOffset = yOffset - 20

    -- Reset button
    local resetButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetButton:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOffset)
    resetButton:SetSize(150, 25)
    resetButton:SetText("Reset to Defaults")
    resetButton:SetScript("OnClick", function()
        -- Confirm dialog
        StaticPopupDialogs["CROSSHAIRSPLUS_RESET_CONFIRM"] = {
            text = "Reset all CrosshairsPlus settings to defaults?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                -- Reset to defaults
                CPlusNS.db.showEnemyPlayers = true
                CPlusNS.db.showFriendlyPlayers = false
                CPlusNS.db.showHostileNPCs = true
                CPlusNS.db.showFriendlyNPCs = false
                CPlusNS.db.showCritters = false
                CPlusNS.db.showRange = true
                CPlusNS.db.showName = true
                CPlusNS.db.enableClassColors = true
                CPlusNS.db.showLines = true
                CPlusNS.db.arrowStyle = "rotating"
                CPlusNS.db.visualStyle = "default"
                CPlusNS.db.lineThickness = 2
                CPlusNS.db.crosshairScale = 1.0
                CPlusNS.db.crosshairAlpha = 1.0

                -- Reload UI to refresh settings panel
                ReloadUI()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("CROSSHAIRSPLUS_RESET_CONFIRM")
    end)

    -- Info text at bottom
    yOffset = yOffset - 40
    local infoText = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    infoText:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOffset)
    infoText:SetWidth(520)
    infoText:SetJustifyH("LEFT")
    infoText:SetText("Tip: Use /crosshairsplus or /chp to open these settings. Changes are applied immediately and saved automatically.")
    infoText:SetTextColor(0.7, 0.7, 0.7)

    return frame
end

-- Initialize settings panel
function CPlusNS.InitializeSettings()
    print("|cff00ff00CrosshairsPlus|r: InitializeSettings called")

    -- Create the settings frame
    local success, err = pcall(function()
        settingsFrame = CreateSettingsPanel()
    end)

    if not success then
        print("|cffff0000CrosshairsPlus|r: Error creating settings panel: " .. tostring(err))
        return
    end

    print("|cff00ff00CrosshairsPlus|r: Settings frame created")

    -- Register with modern Settings API (Retail 10.0+)
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local success2, err2 = pcall(function()
            local category = Settings.RegisterCanvasLayoutCategory(settingsFrame, "CrosshairsPlus")
            Settings.RegisterAddOnCategory(category)
            CPlusNS.SettingsCategory = category
        end)

        if success2 then
            print("|cff00ff00CrosshairsPlus|r: Settings panel registered (modern API)")
        else
            print("|cffff0000CrosshairsPlus|r: Error registering settings: " .. tostring(err2))
        end
    elseif InterfaceOptions_AddCategory then
        -- Fallback for older API (pre-10.0)
        settingsFrame.name = "CrosshairsPlus"
        settingsFrame.okay = function() end
        settingsFrame.cancel = function() end
        settingsFrame.default = function() end

        InterfaceOptions_AddCategory(settingsFrame)

        print("|cff00ff00CrosshairsPlus|r: Settings panel registered (legacy API)")
    else
        print("|cffff0000CrosshairsPlus|r: Warning - Could not register settings panel (Settings=" .. tostring(Settings) .. ", InterfaceOptions_AddCategory=" .. tostring(InterfaceOptions_AddCategory) .. ")")
    end
end

-- Open settings panel
function CPlusNS.OpenSettings()
    if Settings and Settings.OpenToCategory and CPlusNS.SettingsCategory then
        Settings.OpenToCategory(CPlusNS.SettingsCategory:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(settingsFrame)
        InterfaceOptionsFrame_OpenToCategory(settingsFrame) -- Call twice (WoW quirk)
    end
end
