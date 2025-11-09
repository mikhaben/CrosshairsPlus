--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Settings.lua - Settings panel and configuration UI with submenu support
]]--

local AddonName, CPlusNS = ...

-- Settings frames
local mainSettingsFrame = nil
local circleSettingsFrame = nil
local lineSettingsFrame = nil
local arrowSettingsFrame = nil

-- Create main settings panel (General)
local function CreateMainSettingsPanel()
    -- Main settings frame
    local frame = CreateFrame("Frame", "CrosshairsPlusSettingsFrame", UIParent)
    frame:Hide()
    frame:SetSize(600, 700)

    -- Title
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("CrosshairsPlus - General Settings")

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
    content:SetSize(550, 600)
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

    yOffset = yOffset - 10

    -- VISUAL OPTIONS SECTION
    CreateHeader(content, "Visual Options")

    CreateCheckbox(content,
        "Enable Class Coloring",
        "Color player targets based on their class",
        "enableClassColors")

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
                CPlusNS.db.enableClassColors = true
                CPlusNS.db.showLines = true
                CPlusNS.db.arrowStyle = "arrow0"
                CPlusNS.db.circleStyle = "default"
                CPlusNS.db.lineThickness = 2
                CPlusNS.db.lineStartGap = 0
                CPlusNS.db.crosshairScale = 0.8
                CPlusNS.db.crosshairAlpha = 0.6
                CPlusNS.db.arrowDistance = 74
                CPlusNS.db.arrowSize = 24
                CPlusNS.db.arrowsRotate = true
                CPlusNS.db.arrowsRotateCounterClockwise = false
                CPlusNS.db.arrowRotationSpeed = 5.0

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
    infoText:SetText("Additional settings can be found in the submenus: Circle Options, Crosshair Lines, and Arrow Settings.")
    infoText:SetTextColor(0.7, 0.7, 0.7)

    return frame
end

-- Create circle settings submenu panel
local function CreateCircleSettingsPanel()
    local frame = CreateFrame("Frame", "CrosshairsPlusCircleSettingsFrame", UIParent)
    frame:Hide()
    frame:SetSize(600, 700)

    -- Title
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Circle Options")

    -- Subtitle
    local subtitle = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Configure the center circle appearance")
    subtitle:SetTextColor(0.5, 0.5, 0.5)

    -- Scroll frame for settings content
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -16)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 16)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(550, 400)
    scrollFrame:SetScrollChild(content)

    local yOffset = -20

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

    CreateDropdown(content,
        "Circle Style",
        "Choose the circle/core texture style",
        {
            ["default"] = "Default Circle",
            ["minimal"] = "Minimal Circle"
        },
        "circleStyle")

    CreateSlider(content,
        "Frame Scale",
        "Adjust the overall size of the crosshair (0.5-2.0x)",
        0.5, 2.0, 0.1,
        "crosshairScale")

    CreateSlider(content,
        "Frame Opacity",
        "Adjust the transparency of the crosshair (0.0-1.0)",
        0.0, 1.0, 0.1,
        "crosshairAlpha")

    return frame
end

-- Create line settings submenu panel
local function CreateLineSettingsPanel()
    local frame = CreateFrame("Frame", "CrosshairsPlusLineSettingsFrame", UIParent)
    frame:Hide()
    frame:SetSize(600, 700)

    -- Title
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Crosshair Lines")

    -- Subtitle
    local subtitle = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Configure directional crosshair lines")
    subtitle:SetTextColor(0.5, 0.5, 0.5)

    -- Scroll frame for settings content
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -16)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 16)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(550, 400)
    scrollFrame:SetScrollChild(content)

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

    local showLinesCheckbox = CreateCheckbox(content,
        "Show Crosshair Lines",
        "Display directional lines extending from crosshair",
        "showLines")

    local gapSlider = CreateSlider(content,
        "Line Start Position",
        "Adjust where lines start: negative values go toward center, positive values go outward from edge",
        -48, 100, 2,
        "lineStartGap")

    local thicknessSlider = CreateSlider(content,
        "Line Thickness",
        "Adjust the thickness of crosshair lines (1-10 pixels)",
        1, 10, 1,
        "lineThickness")

    -- Function to update sliders state based on showLines
    local function UpdateLineSlidersState()
        if CPlusNS.db.showLines then
            gapSlider:Enable()
            gapSlider.Text:SetTextColor(1, 0.82, 0)
            thicknessSlider:Enable()
            thicknessSlider.Text:SetTextColor(1, 0.82, 0)
        else
            gapSlider:Disable()
            gapSlider.Text:SetTextColor(0.5, 0.5, 0.5)
            thicknessSlider:Disable()
            thicknessSlider.Text:SetTextColor(0.5, 0.5, 0.5)
        end
    end

    -- Override checkbox OnClick to also update sliders state
    local originalOnClick = showLinesCheckbox:GetScript("OnClick")
    showLinesCheckbox:SetScript("OnClick", function(self)
        originalOnClick(self)
        UpdateLineSlidersState()
    end)

    -- Initial state
    UpdateLineSlidersState()

    return frame
end

-- Create arrow settings submenu panel
local function CreateArrowSettingsPanel()
    local frame = CreateFrame("Frame", "CrosshairsPlusArrowSettingsFrame", UIParent)
    frame:Hide()
    frame:SetSize(600, 700)

    -- Title
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Arrow Settings")

    -- Subtitle
    local subtitle = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Configure arrow style and rotation behavior")
    subtitle:SetTextColor(0.5, 0.5, 0.5)

    -- Scroll frame for settings content
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -16)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 16)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(550, 2400)
    scrollFrame:SetScrollChild(content)

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

    -- ARROW STYLE SECTION
    CreateHeader(content, "Arrow Style")

    local arrowHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    arrowHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 8, yOffset)
    arrowHeader:SetText("Select arrow style:")
    yOffset = yOffset - 30

    -- Create arrow picker with grid layout (wrap in rows)
    local arrowButtons = {}
    local iconSize = 32
    local buttonSpacing = 5
    local buttonWidth = iconSize + 30  -- icon + checkbox + spacing
    local buttonsPerRow = 6
    local rowHeight = iconSize + 10
    local xPos = 8
    local startYOffset = yOffset

    -- Add "None" option first
    local noneContainer = CreateFrame("Frame", nil, content)
    noneContainer:SetSize(buttonWidth, iconSize)
    noneContainer:SetPoint("TOPLEFT", content, "TOPLEFT", xPos, yOffset)

    local noneCheckbox = CreateFrame("CheckButton", nil, noneContainer, "UICheckButtonTemplate")
    noneCheckbox:SetPoint("LEFT", noneContainer, "LEFT", 0, 0)
    noneCheckbox:SetSize(24, 24)
    noneCheckbox:SetChecked(CPlusNS.db.arrowStyle == "none")

    local noneLabel = noneContainer:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    noneLabel:SetPoint("LEFT", noneCheckbox, "RIGHT", 4, 0)
    noneLabel:SetText("None")

    noneCheckbox:SetScript("OnClick", function(self)
        CPlusNS.db.arrowStyle = "none"
        CPlusNS.UpdateCrosshairVisuals()
        for _, b in ipairs(arrowButtons) do
            b.checkbox:SetChecked(b.arrowKey == CPlusNS.db.arrowStyle)
        end
    end)

    noneContainer.checkbox = noneCheckbox
    noneContainer.arrowKey = "none"
    arrowButtons[#arrowButtons + 1] = noneContainer

    xPos = xPos + buttonWidth + buttonSpacing

    -- Add ALL numbered arrow styles (0-72) in grid layout
    for i = 0, 72 do
        if xPos + buttonWidth > 530 then
            xPos = 8
            yOffset = yOffset - rowHeight
        end

        local container = CreateFrame("Frame", nil, content)
        container:SetSize(buttonWidth, iconSize)
        container:SetPoint("TOPLEFT", content, "TOPLEFT", xPos, yOffset)

        local checkbox = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
        checkbox:SetPoint("LEFT", container, "LEFT", 0, 0)
        checkbox:SetSize(24, 24)
        checkbox:SetChecked(CPlusNS.db.arrowStyle == "arrow" .. i)

        -- Arrow icon/thumbnail
        local icon = container:CreateTexture(nil, "ARTWORK")
        icon:SetSize(iconSize, iconSize)
        icon:SetPoint("LEFT", checkbox, "RIGHT", 4, 0)
        icon:SetTexture("Interface\\AddOns\\CrosshairsPlus\\Assets\\Arrow" .. i)

        checkbox:SetScript("OnClick", function(self)
            CPlusNS.db.arrowStyle = "arrow" .. i
            CPlusNS.UpdateCrosshairVisuals()
            for _, b in ipairs(arrowButtons) do
                b.checkbox:SetChecked(b.arrowKey == CPlusNS.db.arrowStyle)
            end
        end)

        container.checkbox = checkbox
        container.arrowKey = "arrow" .. i
        arrowButtons[#arrowButtons + 1] = container

        xPos = xPos + buttonWidth + buttonSpacing
    end

    yOffset = yOffset - rowHeight - 20

    -- ARROW POSITIONING SECTION
    CreateHeader(content, "Arrow Positioning")

    local distanceSlider = CreateSlider(content,
        "Distance from Center",
        "Adjust how far arrows are from the center circle (20-100 pixels)",
        20, 100, 2,
        "arrowDistance")

    local sizeSlider = CreateSlider(content,
        "Arrow Size",
        "Adjust the size of the arrows (16-64 pixels)",
        16, 64, 2,
        "arrowSize")

    yOffset = yOffset - 10

    -- ARROW ROTATION SECTION
    CreateHeader(content, "Arrow Rotation")

    local rotateCheckbox = CreateCheckbox(content,
        "Rotate Arrows",
        "Enable continuous rotation of arrows around the circle",
        "arrowsRotate")

    local clockwiseCheckbox = CreateCheckbox(content,
        "Rotate Counter-Clockwise",
        "If enabled, arrows rotate counter-clockwise; otherwise clockwise (default)",
        "arrowsRotateCounterClockwise")

    local rotationSlider = CreateSlider(content,
        "Rotation Speed",
        "Adjust the speed of arrow rotation (1.0-10.0x)",
        1.0, 10.0, 0.5,
        "arrowRotationSpeed")

    -- Function to update rotation controls state
    local function UpdateRotationControlsState()
        local hasArrows = CPlusNS.db.arrowStyle ~= "none"
        local rotationEnabled = CPlusNS.db.arrowsRotate

        if hasArrows then
            rotateCheckbox:Enable()
            rotateCheckbox.Text:SetTextColor(1, 1, 1)
            distanceSlider:Enable()
            distanceSlider.Text:SetTextColor(1, 0.82, 0)
            sizeSlider:Enable()
            sizeSlider.Text:SetTextColor(1, 0.82, 0)

            if rotationEnabled then
                clockwiseCheckbox:Enable()
                clockwiseCheckbox.Text:SetTextColor(1, 1, 1)
                rotationSlider:Enable()
                rotationSlider.Text:SetTextColor(1, 0.82, 0)
            else
                clockwiseCheckbox:Disable()
                clockwiseCheckbox.Text:SetTextColor(0.5, 0.5, 0.5)
                rotationSlider:Disable()
                rotationSlider.Text:SetTextColor(0.5, 0.5, 0.5)
            end
        else
            rotateCheckbox:Disable()
            rotateCheckbox.Text:SetTextColor(0.5, 0.5, 0.5)
            clockwiseCheckbox:Disable()
            clockwiseCheckbox.Text:SetTextColor(0.5, 0.5, 0.5)
            rotationSlider:Disable()
            rotationSlider.Text:SetTextColor(0.5, 0.5, 0.5)
            distanceSlider:Disable()
            distanceSlider.Text:SetTextColor(0.5, 0.5, 0.5)
            sizeSlider:Disable()
            sizeSlider.Text:SetTextColor(0.5, 0.5, 0.5)
        end
    end

    -- Override rotate checkbox to also update clockwise state
    local originalRotateOnClick = rotateCheckbox:GetScript("OnClick")
    rotateCheckbox:SetScript("OnClick", function(self)
        originalRotateOnClick(self)
        UpdateRotationControlsState()
    end)

    -- Update rotation controls when arrow style changes
    for _, arrowContainer in ipairs(arrowButtons) do
        local originalOnClick = arrowContainer.checkbox:GetScript("OnClick")
        arrowContainer.checkbox:SetScript("OnClick", function(self)
            originalOnClick(self)
            UpdateRotationControlsState()
        end)
    end

    -- Initial state
    UpdateRotationControlsState()

    return frame
end

-- Initialize settings panel
function CPlusNS.InitializeSettings()
    if CPlusNS.db and CPlusNS.db.debugMode then
        print("|cff00ff00CrosshairsPlus|r: InitializeSettings called")
    end

    -- Create the settings frames
    local success, err = pcall(function()
        mainSettingsFrame = CreateMainSettingsPanel()
        circleSettingsFrame = CreateCircleSettingsPanel()
        lineSettingsFrame = CreateLineSettingsPanel()
        arrowSettingsFrame = CreateArrowSettingsPanel()
    end)

    if not success then
        print("|cffff0000CrosshairsPlus|r: Error creating settings panel: " .. tostring(err))
        return
    end

    if CPlusNS.db and CPlusNS.db.debugMode then
        print("|cff00ff00CrosshairsPlus|r: Settings frames created")
    end

    -- Register with modern Settings API (Retail 10.0+)
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local success2, err2 = pcall(function()
            -- Register main category
            local mainCategory = Settings.RegisterCanvasLayoutCategory(mainSettingsFrame, "CrosshairsPlus")
            mainCategory:SetName("CrosshairsPlus")
            Settings.RegisterAddOnCategory(mainCategory)
            CPlusNS.SettingsCategory = mainCategory

            -- Try using RegisterCanvasLayoutSubcategory for subcategories
            if Settings.RegisterCanvasLayoutSubcategory then
                -- General subcategory
                local generalCategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, mainSettingsFrame, "General")
                CPlusNS.GeneralSettingsCategory = generalCategory

                -- Circle settings subcategory
                local circleCategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, circleSettingsFrame, "Circle Options")
                CPlusNS.CircleSettingsCategory = circleCategory

                -- Line settings subcategory
                local lineCategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, lineSettingsFrame, "Crosshair Lines")
                CPlusNS.LineSettingsCategory = lineCategory

                -- Arrow settings subcategory
                local arrowCategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, arrowSettingsFrame, "Arrow Settings")
                CPlusNS.ArrowSettingsCategory = arrowCategory
            else
                -- Fallback: register as separate categories with parent names
                local generalCategory = Settings.RegisterCanvasLayoutCategory(mainSettingsFrame, "General")
                generalCategory:SetName("General")
                generalCategory.parentCategoryID = mainCategory:GetID()

                local circleCategory = Settings.RegisterCanvasLayoutCategory(circleSettingsFrame, "Circle Options")
                circleCategory:SetName("Circle Options")
                circleCategory.parentCategoryID = mainCategory:GetID()

                local lineCategory = Settings.RegisterCanvasLayoutCategory(lineSettingsFrame, "Crosshair Lines")
                lineCategory:SetName("Crosshair Lines")
                lineCategory.parentCategoryID = mainCategory:GetID()

                local arrowCategory = Settings.RegisterCanvasLayoutCategory(arrowSettingsFrame, "Arrow Settings")
                arrowCategory:SetName("Arrow Settings")
                arrowCategory.parentCategoryID = mainCategory:GetID()

                CPlusNS.GeneralSettingsCategory = generalCategory
                CPlusNS.CircleSettingsCategory = circleCategory
                CPlusNS.LineSettingsCategory = lineCategory
                CPlusNS.ArrowSettingsCategory = arrowCategory
            end
        end)

        if success2 then
            if CPlusNS.db and CPlusNS.db.debugMode then
                print("|cff00ff00CrosshairsPlus|r: Settings panel registered with submenus (modern API)")
            end
        else
            print("|cffff0000CrosshairsPlus|r: Error registering settings: " .. tostring(err2))
        end
    elseif InterfaceOptions_AddCategory then
        -- Fallback for older API (pre-10.0)
        mainSettingsFrame.name = "CrosshairsPlus"
        mainSettingsFrame.okay = function() end
        mainSettingsFrame.cancel = function() end
        mainSettingsFrame.default = function() end

        circleSettingsFrame.name = "Circle Options"
        circleSettingsFrame.parent = "CrosshairsPlus"
        circleSettingsFrame.okay = function() end
        circleSettingsFrame.cancel = function() end
        circleSettingsFrame.default = function() end

        lineSettingsFrame.name = "Crosshair Lines"
        lineSettingsFrame.parent = "CrosshairsPlus"
        lineSettingsFrame.okay = function() end
        lineSettingsFrame.cancel = function() end
        lineSettingsFrame.default = function() end

        arrowSettingsFrame.name = "Arrow Settings"
        arrowSettingsFrame.parent = "CrosshairsPlus"
        arrowSettingsFrame.okay = function() end
        arrowSettingsFrame.cancel = function() end
        arrowSettingsFrame.default = function() end

        InterfaceOptions_AddCategory(mainSettingsFrame)
        InterfaceOptions_AddCategory(circleSettingsFrame)
        InterfaceOptions_AddCategory(lineSettingsFrame)
        InterfaceOptions_AddCategory(arrowSettingsFrame)

        if CPlusNS.db and CPlusNS.db.debugMode then
            print("|cff00ff00CrosshairsPlus|r: Settings panel registered with submenus (legacy API)")
        end
    else
        print("|cffff0000CrosshairsPlus|r: Warning - Could not register settings panel (Settings=" .. tostring(Settings) .. ", InterfaceOptions_AddCategory=" .. tostring(InterfaceOptions_AddCategory) .. ")")
    end
end

-- Open settings panel
function CPlusNS.OpenSettings()
    if Settings and Settings.OpenToCategory and CPlusNS.SettingsCategory then
        Settings.OpenToCategory(CPlusNS.SettingsCategory:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(mainSettingsFrame)
        InterfaceOptionsFrame_OpenToCategory(mainSettingsFrame) -- Call twice (WoW quirk)
    end
end
