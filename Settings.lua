--[[
    CrosshairsPlus - Enhanced Crosshair Addon
    Settings.lua - Settings panel and configuration UI with submenu support
]]--

local AddonName, CPlusNS = ...

-- Settings frames
local mainSettingsFrame
local circleSettingsFrame
local lineSettingsFrame
local arrowSettingsFrame

-- ============================================================
-- Shared UI Helpers
-- All helpers take (parent, yOffset, ...) and return (widget, newYOffset)
-- ============================================================

local function CreateHeader(parent, yOffset, text)
    local header = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, yOffset)
    header:SetText(text)
    header:SetTextColor(1, 0.82, 0)
    return header, yOffset - 30
end

local function CreateCheckbox(parent, yOffset, text, tooltip, dbKey)
    local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, yOffset)
    checkbox.Text:SetFontObject("GameFontNormal")
    checkbox.Text:SetText(text)
    checkbox.tooltipText = tooltip
    checkbox:SetChecked(CPlusNS.db[dbKey])
    checkbox:SetScript("OnClick", function(self)
        CPlusNS.db[dbKey] = self:GetChecked()
        CPlusNS.UpdateCrosshairVisuals()
    end)
    return checkbox, yOffset - 30
end

local function CreateSlider(parent, yOffset, text, tooltip, min, max, step, dbKey)
    local slider = CreateFrame("Slider", nil, parent, "MinimalSliderTemplate")
    slider:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, yOffset)
    slider:SetWidth(400)
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetValue(CPlusNS.db[dbKey])
    slider:SetObeyStepOnDrag(true)

    slider.Text = slider:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    slider.Text:SetPoint("TOP", slider, "TOP", 0, 16)
    slider.Low = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    slider.Low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, 0)
    slider.High = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    slider.High:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, 0)

    slider.Text:SetText(text)
    slider.Low:SetText(tostring(min))
    slider.High:SetText(tostring(max))

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
    return slider, yOffset - 50
end

local function CreateDropdown(parent, yOffset, text, options, dbKey)
    local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, yOffset)
    label:SetText(text)

    yOffset = yOffset - 20

    local dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
    dropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, yOffset)
    dropdown:SetWidth(220)

    dropdown:SetupMenu(function(_, rootDescription)
        for key, displayText in pairs(options) do
            rootDescription:CreateRadio(displayText,
                function() return CPlusNS.db[dbKey] == key end,
                function()
                    CPlusNS.db[dbKey] = key
                    CPlusNS.UpdateCrosshairVisuals()
                end)
        end
    end)

    return dropdown, yOffset - 40
end

-- ============================================================
-- Panel Constructors
-- ============================================================

-- Create main settings panel (General)
local function CreateMainSettingsPanel()
    local frame = CreateFrame("Frame", "CrosshairsPlusSettingsFrame", UIParent)
    frame:Hide()
    frame:SetSize(600, 700)

    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("CrosshairsPlus - General Settings")

    local version = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    version:SetText("Version " .. CPlusNS.Version)
    version:SetTextColor(0.5, 0.5, 0.5)

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -16)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 16)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(550, 600)
    scrollFrame:SetScrollChild(content)

    local yOffset = -10

    -- TARGET FILTERS SECTION
    _, yOffset = CreateHeader(content, yOffset, "Target Filters")

    _, yOffset = CreateCheckbox(content, yOffset,
        "Show on Enemy Players",
        "Display crosshair on enemy players in PvP",
        "showEnemyPlayers")

    _, yOffset = CreateCheckbox(content, yOffset,
        "Show on Friendly Players",
        "Display crosshair on friendly players",
        "showFriendlyPlayers")

    _, yOffset = CreateCheckbox(content, yOffset,
        "Show on Hostile NPCs",
        "Display crosshair on hostile creatures and NPCs",
        "showHostileNPCs")

    _, yOffset = CreateCheckbox(content, yOffset,
        "Show on Friendly NPCs",
        "Display crosshair on friendly creatures and NPCs",
        "showFriendlyNPCs")

    yOffset = yOffset - 10

    _, yOffset = CreateCheckbox(content, yOffset,
        "Enable Action Targeting",
        "Show crosshair on soft enemy targets (requires WoW's Action Targeting enabled). Hard target always takes priority.",
        "enableActionTargeting")

    yOffset = yOffset - 10

    -- VISUAL OPTIONS SECTION
    _, yOffset = CreateHeader(content, yOffset, "Visual Options")

    _, yOffset = CreateCheckbox(content, yOffset,
        "Enable Class Coloring",
        "Color player targets based on their class",
        "enableClassColors")

    yOffset = yOffset - 20

    -- Reset button
    local resetButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetButton:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOffset)
    resetButton:SetSize(150, 25)
    resetButton:SetText("Reset to Defaults")
    StaticPopupDialogs["CROSSHAIRSPLUS_RESET_CONFIRM"] = {
        text = "Reset all CrosshairsPlus settings to defaults?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            CrosshairsPlusDB = nil
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    resetButton:SetScript("OnClick", function()
        StaticPopup_Show("CROSSHAIRSPLUS_RESET_CONFIRM")
    end)

    yOffset = yOffset - 40
    local infoText = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    infoText:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOffset)
    infoText:SetWidth(520)
    infoText:SetJustifyH("LEFT")
    infoText:SetText("Additional settings can be found in the submenus: Circle Options, Crosshair Lines, and Arrow Settings.")
    infoText:SetTextColor(0.7, 0.7, 0.7)

    yOffset = yOffset - 30

    _, yOffset = CreateHeader(content, yOffset, "Slash Commands")

    local commandsText = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    commandsText:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOffset)
    commandsText:SetWidth(520)
    commandsText:SetJustifyH("LEFT")
    commandsText:SetSpacing(4)
    commandsText:SetText(
        "/chp - Open settings panel\n" ..
        "/chp debug - Toggle debug mode\n" ..
        "/chp test - Run diagnostics\n" ..
        "/chp show - Force show crosshair at screen center\n" ..
        "/chp hide - Hide crosshair"
    )
    commandsText:SetTextColor(0.7, 0.7, 0.7)

    return frame
end

-- Create circle settings submenu panel
local function CreateCircleSettingsPanel()
    local frame = CreateFrame("Frame", "CrosshairsPlusCircleSettingsFrame", UIParent)
    frame:Hide()
    frame:SetSize(600, 700)

    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Circle Options")

    local subtitle = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Configure the center circle appearance")
    subtitle:SetTextColor(0.5, 0.5, 0.5)

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -16)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 16)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(550, 400)
    scrollFrame:SetScrollChild(content)

    local yOffset = -20

    _, yOffset = CreateDropdown(content, yOffset,
        "Circle Style",
        {
            ["default"] = "Default Circle",
            ["minimal"] = "Minimal Circle"
        },
        "circleStyle")

    yOffset = yOffset - 10

    _, yOffset = CreateSlider(content, yOffset,
        "Frame Scale",
        "Adjust the overall size of the crosshair (0.5-2.0x)",
        0.5, 2.0, 0.1,
        "crosshairScale")

    _, yOffset = CreateSlider(content, yOffset,
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

    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Crosshair Lines")

    local subtitle = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Configure directional crosshair lines")
    subtitle:SetTextColor(0.5, 0.5, 0.5)

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -16)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 16)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(550, 400)
    scrollFrame:SetScrollChild(content)

    local yOffset = -10

    local showLinesCheckbox
    showLinesCheckbox, yOffset = CreateCheckbox(content, yOffset,
        "Show Crosshair Lines",
        "Display directional lines extending from crosshair",
        "showLines")

    yOffset = yOffset - 10

    local gapSlider
    gapSlider, yOffset = CreateSlider(content, yOffset,
        "Line Start Position",
        "Adjust where lines start: negative values go toward center, positive values go outward from edge",
        -48, 100, 2,
        "lineStartGap")

    local thicknessSlider
    thicknessSlider, yOffset = CreateSlider(content, yOffset,
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

    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Arrow Settings")

    local subtitle = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Configure arrow style and rotation behavior")
    subtitle:SetTextColor(0.5, 0.5, 0.5)

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -16)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 16)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(550, 2400)
    scrollFrame:SetScrollChild(content)

    local yOffset = -10

    -- ARROW STYLE SECTION
    _, yOffset = CreateHeader(content, yOffset, "Arrow Style")

    local arrowHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    arrowHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 8, yOffset)
    arrowHeader:SetText("Select arrow style:")
    yOffset = yOffset - 30

    -- Create arrow picker with grid layout (wrap in rows)
    local arrowButtons = {}
    local iconSize = 32
    local buttonSpacing = 5
    local buttonWidth = iconSize + 30  -- icon + checkbox + spacing
    local rowHeight = iconSize + 10
    local xPos = 8

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
    _, yOffset = CreateHeader(content, yOffset, "Arrow Positioning")

    local distanceSlider
    distanceSlider, yOffset = CreateSlider(content, yOffset,
        "Distance from Center",
        "Adjust how far arrows are from the center circle (20-100 pixels)",
        20, 100, 2,
        "arrowDistance")

    local sizeSlider
    sizeSlider, yOffset = CreateSlider(content, yOffset,
        "Arrow Size",
        "Adjust the size of the arrows (16-64 pixels)",
        16, 64, 2,
        "arrowSize")

    yOffset = yOffset - 10

    -- ARROW ROTATION SECTION
    _, yOffset = CreateHeader(content, yOffset, "Arrow Rotation")

    local rotateCheckbox
    rotateCheckbox, yOffset = CreateCheckbox(content, yOffset,
        "Rotate Arrows",
        "Enable continuous rotation of arrows around the circle",
        "arrowsRotate")

    local clockwiseCheckbox
    clockwiseCheckbox, yOffset = CreateCheckbox(content, yOffset,
        "Rotate Counter-Clockwise",
        "If enabled, arrows rotate counter-clockwise; otherwise clockwise (default)",
        "arrowsRotateCounterClockwise")

    yOffset = yOffset - 10

    local rotationSlider
    rotationSlider, yOffset = CreateSlider(content, yOffset,
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

-- ============================================================
-- Settings Registration
-- ============================================================

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

    -- Register with Settings API (12.0+)
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local success2, err2 = pcall(function()
            -- Register main category
            local mainCategory = Settings.RegisterCanvasLayoutCategory(mainSettingsFrame, "CrosshairsPlus")
            mainCategory:SetName("CrosshairsPlus")
            Settings.RegisterAddOnCategory(mainCategory)
            CPlusNS.SettingsCategory = mainCategory

            -- Register subcategories
            CPlusNS.GeneralSettingsCategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, mainSettingsFrame, "General")
            CPlusNS.CircleSettingsCategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, circleSettingsFrame, "Circle Options")
            CPlusNS.LineSettingsCategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, lineSettingsFrame, "Crosshair Lines")
            CPlusNS.ArrowSettingsCategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, arrowSettingsFrame, "Arrow Settings")
        end)

        if success2 then
            if CPlusNS.db and CPlusNS.db.debugMode then
                print("|cff00ff00CrosshairsPlus|r: Settings panel registered with submenus")
            end
        else
            print("|cffff0000CrosshairsPlus|r: Error registering settings: " .. tostring(err2))
        end
    else
        print("|cffff0000CrosshairsPlus|r: Warning - Could not register settings panel (Settings=" .. tostring(Settings) .. ")")
    end
end

-- Open settings panel
function CPlusNS.OpenSettings()
    if Settings and Settings.OpenToCategory and CPlusNS.SettingsCategory then
        Settings.OpenToCategory(CPlusNS.SettingsCategory:GetID())
    end
end
