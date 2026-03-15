-- PrimalLedger UI
-- Main display window

local addonName, PL = ...

-- Static popup for reset data confirmation
StaticPopupDialogs["PRIMAL_LEDGER_RESET_CONFIRM"] = {
    text = "Are you sure you want to reset all Primal Ledger data? This will remove all tracked characters and cooldowns.",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        PL:ResetData()
        PL:Print("All data has been reset.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Profession icons
local PROFESSION_ICONS = {
    alchemy = "Interface\\Icons\\Trade_Alchemy",
    blacksmithing = "Interface\\Icons\\Trade_BlackSmithing",
    enchanting = "Interface\\Icons\\Trade_Engraving",
    engineering = "Interface\\Icons\\Trade_Engineering",
    herbalism = "Interface\\Icons\\Spell_Nature_NatureTouchGrow",
    jewelcrafting = "Interface\\Icons\\INV_Misc_Gem_02",
    leatherworking = "Interface\\Icons\\Trade_LeatherWorking",
    mining = "Interface\\Icons\\Trade_Mining",
    skinning = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01",
    tailoring = "Interface\\Icons\\Trade_Tailoring",
    cooking = "Interface\\Icons\\INV_Misc_Food_15",
    fishing = "Interface\\Icons\\Trade_Fishing",
    firstAid = "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
}

-- Class colors for character names
local CLASS_COLORS = {
    WARRIOR = { r = 0.78, g = 0.61, b = 0.43 },
    PALADIN = { r = 0.96, g = 0.55, b = 0.73 },
    HUNTER = { r = 0.67, g = 0.83, b = 0.45 },
    ROGUE = { r = 1.00, g = 0.96, b = 0.41 },
    PRIEST = { r = 1.00, g = 1.00, b = 1.00 },
    SHAMAN = { r = 0.00, g = 0.44, b = 0.87 },
    MAGE = { r = 0.41, g = 0.80, b = 0.94 },
    WARLOCK = { r = 0.58, g = 0.51, b = 0.79 },
    DRUID = { r = 1.00, g = 0.49, b = 0.04 },
}

-- Frame dimensions
local FRAME_WIDTH = 300   -- Default width
local FRAME_HEIGHT = 400  -- Default height
local MIN_WIDTH = 250
local MIN_HEIGHT = 200
local ROW_HEIGHT = 16
local HEADER_HEIGHT = 24
local PADDING = 10

-- Create the main frame
function PL:CreateMainFrame()
    if self.mainFrame then return end

    -- Determine initial size (from saved settings or defaults)
    local initialWidth = FRAME_WIDTH
    local initialHeight = FRAME_HEIGHT
    if self.db.settings.frameSize then
        initialWidth = self.db.settings.frameSize.width or FRAME_WIDTH
        initialHeight = self.db.settings.frameSize.height or FRAME_HEIGHT
    end

    -- Main frame
    local frame = CreateFrame("Frame", "PrimalLedgerFrame", UIParent, "BackdropTemplate")
    frame:SetSize(initialWidth, initialHeight)
    tinsert(UISpecialFrames, "PrimalLedgerFrame") -- Close on ESC
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Save position
        local point, _, _, x, y = self:GetPoint()
        PL.db.settings.framePosition = { point = point, x = x, y = y }
    end)

    -- Modern backdrop - semi-transparent dark background with subtle border
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    -- Title bar
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetHeight(HEADER_HEIGHT)
    titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -PADDING)
    titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -PADDING, -PADDING)

    -- Title icon
    local titleIcon = titleBar:CreateTexture(nil, "ARTWORK")
    titleIcon:SetSize(20, 20)
    titleIcon:SetPoint("LEFT", titleBar, "LEFT", 0, 0)
    titleIcon:SetTexture("Interface\\AddOns\\PrimalLedger\\assets\\icon_map")
    titleIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Title text
    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", titleIcon, "RIGHT", 6, 0)
    title:SetText("Primal Ledger - v" .. (PL.version or "1.0.0"))
    title:SetTextColor(0.9, 0.9, 0.9)

    -- Title separator line
    local titleSeparator = frame:CreateTexture(nil, "ARTWORK")
    titleSeparator:SetHeight(1)
    titleSeparator:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, -4)
    titleSeparator:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, -4)
    titleSeparator:SetColorTexture(0.3, 0.3, 0.3, 1)

    -- Character info header
    local charHeader = CreateFrame("Frame", nil, frame)
    charHeader:SetHeight(ROW_HEIGHT)
    charHeader:SetPoint("TOPLEFT", titleSeparator, "BOTTOMLEFT", 0, -6)
    charHeader:SetPoint("TOPRIGHT", titleSeparator, "BOTTOMRIGHT", 0, -6)

    local charName = charHeader:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    charName:SetPoint("LEFT", charHeader, "LEFT", 0, 0)
    charName:SetJustifyH("LEFT")

    -- Create profession icon frames
    local iconSize = 16
    local iconSpacing = 4
    local professionIcons = {}
    local professionOrder = {
        "alchemy", "blacksmithing", "enchanting", "engineering", "herbalism",
        "jewelcrafting", "leatherworking", "mining", "skinning", "tailoring",
        "cooking", "fishing", "firstAid"
    }

    for i, profKey in ipairs(professionOrder) do
        local iconFrame = CreateFrame("Frame", nil, charHeader)
        iconFrame:SetSize(iconSize, iconSize)

        local icon = iconFrame:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
        icon:SetTexture(PROFESSION_ICONS[profKey])
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim icon borders

        iconFrame.icon = icon
        iconFrame.profKey = profKey
        iconFrame:Hide()

        -- Tooltip on hover
        iconFrame:EnableMouse(true)
        iconFrame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.profName or profKey)
            if self.profLevel then
                GameTooltip:AddLine("Level: " .. self.profLevel, 1, 1, 1)
            end
            GameTooltip:Show()
        end)
        iconFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        professionIcons[profKey] = iconFrame
    end

    frame.charHeader = charHeader
    frame.charName = charName
    frame.professionIcons = professionIcons
    frame.professionOrder = professionOrder

    -- Header separator line
    local headerSeparator = frame:CreateTexture(nil, "ARTWORK")
    headerSeparator:SetHeight(1)
    headerSeparator:SetPoint("TOPLEFT", charHeader, "BOTTOMLEFT", 0, -6)
    headerSeparator:SetPoint("TOPRIGHT", charHeader, "BOTTOMRIGHT", 0, -6)
    headerSeparator:SetColorTexture(0.3, 0.3, 0.3, 1)

    frame.headerSeparator = headerSeparator

    -- Tab bar
    local tabBar = CreateFrame("Frame", nil, frame)
    tabBar:SetHeight(22)
    tabBar:SetPoint("TOPLEFT", headerSeparator, "BOTTOMLEFT", 0, -4)
    tabBar:SetPoint("TOPRIGHT", headerSeparator, "BOTTOMRIGHT", 0, -4)

    -- Tab button creation helper
    local function CreateTab(parent, name, tabIndex)
        local tab = CreateFrame("Button", nil, parent)
        tab:SetHeight(20)

        tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        tab.text:SetPoint("CENTER", tab, "CENTER", 0, 0)
        tab.text:SetText(name)

        -- Background for selected state
        tab.selectedBg = tab:CreateTexture(nil, "BACKGROUND")
        tab.selectedBg:SetAllPoints()
        tab.selectedBg:SetColorTexture(0.2, 0.2, 0.2, 1)
        tab.selectedBg:Hide()

        -- Underline for selected state
        tab.underline = tab:CreateTexture(nil, "ARTWORK")
        tab.underline:SetHeight(2)
        tab.underline:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 0, 0)
        tab.underline:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", 0, 0)
        tab.underline:SetColorTexture(0.4, 0.6, 1, 1)
        tab.underline:Hide()

        tab.tabIndex = tabIndex

        tab:SetScript("OnEnter", function(self)
            if not self.isSelected then
                self.text:SetTextColor(1, 1, 1)
            end
        end)

        tab:SetScript("OnLeave", function(self)
            if not self.isSelected then
                self.text:SetTextColor(0.6, 0.6, 0.6)
            end
        end)

        tab:SetScript("OnClick", function(self)
            PL:SelectTab(self.tabIndex)
        end)

        -- Initial state
        tab.text:SetTextColor(0.6, 0.6, 0.6)
        tab:SetWidth(tab.text:GetStringWidth() + 16)

        return tab
    end

    -- Create tabs
    local overviewTab = CreateTab(tabBar, "Overview", 1)
    overviewTab:SetPoint("LEFT", tabBar, "LEFT", 0, 0)

    local cooldownsTab = CreateTab(tabBar, "Cooldowns", 2)
    cooldownsTab:SetPoint("LEFT", overviewTab, "RIGHT", 8, 0)

    local sourcesTab = CreateTab(tabBar, "Sources", 3)
    sourcesTab:SetPoint("LEFT", cooldownsTab, "RIGHT", 8, 0)

    local trackingTab = CreateTab(tabBar, "CD Tracking", 4)
    trackingTab:SetPoint("LEFT", sourcesTab, "RIGHT", 8, 0)

    local settingsTab = CreateTab(tabBar, "Settings", 5)
    settingsTab:SetPoint("LEFT", trackingTab, "RIGHT", 8, 0)

    frame.tabs = { overviewTab, cooldownsTab, sourcesTab, trackingTab, settingsTab }
    frame.tabBar = tabBar
    frame.selectedTab = 1

    -- Tab separator line
    local tabSeparator = frame:CreateTexture(nil, "ARTWORK")
    tabSeparator:SetHeight(1)
    tabSeparator:SetPoint("TOPLEFT", tabBar, "BOTTOMLEFT", 0, -2)
    tabSeparator:SetPoint("TOPRIGHT", tabBar, "BOTTOMRIGHT", 0, -2)
    tabSeparator:SetColorTexture(0.3, 0.3, 0.3, 1)

    frame.tabSeparator = tabSeparator

    -- Custom close button
    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(16, 16)
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -PADDING, -PADDING)

    local closeBtnText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeBtnText:SetPoint("CENTER", closeBtn, "CENTER", 0, 0)
    closeBtnText:SetText("X")
    closeBtnText:SetTextColor(0.6, 0.6, 0.6)

    closeBtn:SetScript("OnEnter", function()
        closeBtnText:SetTextColor(1, 0.3, 0.3)
    end)
    closeBtn:SetScript("OnLeave", function()
        closeBtnText:SetTextColor(0.6, 0.6, 0.6)
    end)
    closeBtn:SetScript("OnClick", function()
        PL:ToggleMainFrame()
    end)

    -- Resize grip
    local resizeBtn = CreateFrame("Button", nil, frame)
    resizeBtn:SetSize(16, 16)
    resizeBtn:SetPoint("BOTTOMRIGHT", -2, 2)
    resizeBtn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeBtn:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeBtn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeBtn:SetScript("OnMouseDown", function()
        frame:StartSizing("BOTTOMRIGHT")
    end)
    resizeBtn:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        -- Save new size
        PL.db.settings.frameSize = { width = frame:GetWidth(), height = frame:GetHeight() }
        -- Update content width for scroll child
        if frame.content then
            frame.content:SetWidth(frame:GetWidth() - 40)
        end
    end)

    frame.resizeBtn = resizeBtn

    -- Scroll frame for character list
    local scrollFrame = CreateFrame("ScrollFrame", "PrimalLedgerScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", tabSeparator, "BOTTOMLEFT", 0, -6)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, PADDING + 16)

    -- Content frame inside scroll frame
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(frame:GetWidth() - 40, 1) -- Height will be set dynamically
    scrollFrame:SetScrollChild(content)

    frame.scrollFrame = scrollFrame
    frame.content = content
    frame.rows = {}
    frame.separators = {}

    -- Hide by default
    frame:Hide()

    -- Restore saved position
    if self.db.settings.framePosition then
        local pos = self.db.settings.framePosition
        frame:ClearAllPoints()
        frame:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)
    end

    -- Update timer
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed
        if self.timeSinceUpdate >= 1 then
            self.timeSinceUpdate = 0
            if self:IsShown() then
                PL:UpdateMainFrame()
            end
        end
    end)

    self.mainFrame = frame

    -- Select first tab by default
    self:SelectTab(1)
end

-- Profession order for icon display
local PROFESSION_ORDER = {
    "alchemy", "blacksmithing", "enchanting", "engineering", "herbalism",
    "jewelcrafting", "leatherworking", "mining", "skinning", "tailoring",
    "cooking", "fishing", "firstAid"
}

local PROFESSION_NAMES = {
    alchemy = "Alchemy", blacksmithing = "Blacksmithing", enchanting = "Enchanting",
    engineering = "Engineering", herbalism = "Herbalism", jewelcrafting = "Jewelcrafting",
    leatherworking = "Leatherworking", mining = "Mining", skinning = "Skinning",
    tailoring = "Tailoring", cooking = "Cooking", fishing = "Fishing", firstAid = "First Aid"
}

-- Create a row for displaying cooldown info
local function CreateRow(parent, index)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -((index - 1) * ROW_HEIGHT))
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -((index - 1) * ROW_HEIGHT))

    -- Hover highlight background
    row.highlight = row:CreateTexture(nil, "BACKGROUND")
    row.highlight:SetAllPoints(row)
    row.highlight:SetColorTexture(1, 1, 1, 0.05)
    row.highlight:Hide()

    row:EnableMouse(true)
    row:SetScript("OnEnter", function(self)
        self.highlight:Show()
    end)
    row:SetScript("OnLeave", function(self)
        self.highlight:Hide()
    end)

    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.text:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.text:SetJustifyH("LEFT")

    -- Create profession icons for character header rows
    local iconSize = 14
    row.profIcons = {}
    for _, profKey in ipairs(PROFESSION_ORDER) do
        local iconFrame = CreateFrame("Frame", nil, row)
        iconFrame:SetSize(iconSize, iconSize)

        local icon = iconFrame:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
        icon:SetTexture(PROFESSION_ICONS[profKey])
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        iconFrame.icon = icon
        iconFrame.profKey = profKey
        iconFrame:Hide()

        iconFrame:EnableMouse(true)
        iconFrame:SetScript("OnEnter", function(self)
            row.highlight:Show()
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.profName or PROFESSION_NAMES[profKey])
            if self.profLevel then
                GameTooltip:AddLine("Level: " .. self.profLevel, 1, 1, 1)
            end
            GameTooltip:Show()
        end)
        iconFrame:SetScript("OnLeave", function(self)
            row.highlight:Hide()
            GameTooltip:Hide()
        end)

        row.profIcons[profKey] = iconFrame
    end

    -- Create a button for the time/status (for clickable "Ready!" text)
    row.timeBtn = CreateFrame("Button", nil, row)
    row.timeBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    row.timeBtn:SetHeight(ROW_HEIGHT)
    row.timeBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    row.time = row.timeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.time:SetPoint("RIGHT", row.timeBtn, "RIGHT", 0, 0)
    row.time:SetJustifyH("RIGHT")

    -- Highlight on hover when clickable
    row.timeBtn:SetScript("OnEnter", function(self)
        row.highlight:Show()
        if self.isClickable then
            row.time:SetTextColor(0.5, 1, 0.5) -- Lighter green on hover
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine("Ready to craft!")
            GameTooltip:AddLine("|cffffffffLeft-click:|r Open profession window", 0.8, 0.8, 0.8)
            GameTooltip:AddLine("|cffffffffRight-click:|r Select recipe", 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end
    end)

    row.timeBtn:SetScript("OnLeave", function(self)
        row.highlight:Hide()
        if self.isClickable then
            row.time:SetTextColor(0, 1, 0) -- Back to green
        end
        GameTooltip:Hide()
    end)

    return row
end

-- Create a separator line between character sections
local function CreateSeparator(parent, yOffset)
    local separator = parent:CreateTexture(nil, "ARTWORK")
    separator:SetHeight(1)
    separator:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    separator:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, yOffset)
    separator:SetColorTexture(0.25, 0.25, 0.25, 0.8)
    return separator
end

-- Update the main frame content
function PL:UpdateMainFrame()
    if not self.mainFrame then return end

    local content = self.mainFrame.content
    local characters = self:GetAllCharacters()
    local currentCharKey = self:GetCharacterKey()
    local rowIndex = 0
    local charCount = 0

    -- Update character header
    local currentCharData = self.db.characters[currentCharKey]
    if currentCharData then
        local classColor = CLASS_COLORS[currentCharData.class] or { r = 1, g = 1, b = 1 }
        self.mainFrame.charName:SetText(currentCharData.name)
        self.mainFrame.charName:SetTextColor(classColor.r, classColor.g, classColor.b)

        -- Display profession icons
        local iconSize = 16
        local iconSpacing = 4
        local lastIcon = nil
        local iconCount = 0

        local profNames = {
            alchemy = "Alchemy", blacksmithing = "Blacksmithing", enchanting = "Enchanting",
            engineering = "Engineering", herbalism = "Herbalism", jewelcrafting = "Jewelcrafting",
            leatherworking = "Leatherworking", mining = "Mining", skinning = "Skinning",
            tailoring = "Tailoring", cooking = "Cooking", fishing = "Fishing", firstAid = "First Aid"
        }

        -- Hide all icons first
        for _, iconFrame in pairs(self.mainFrame.professionIcons) do
            iconFrame:Hide()
        end

        -- Show and position icons for known professions
        if currentCharData.professions then
            local p = currentCharData.professions
            for _, profKey in ipairs(self.mainFrame.professionOrder) do
                local value = p[profKey]
                if value and value ~= false and (type(value) ~= "number" or value > 0) then
                    local iconFrame = self.mainFrame.professionIcons[profKey]
                    iconFrame.profName = profNames[profKey]
                    iconFrame.profLevel = type(value) == "number" and value or nil

                    if lastIcon then
                        iconFrame:SetPoint("LEFT", lastIcon, "RIGHT", iconSpacing, 0)
                    else
                        iconFrame:SetPoint("LEFT", self.mainFrame.charName, "RIGHT", 8, 0)
                    end

                    iconFrame:Show()
                    lastIcon = iconFrame
                    iconCount = iconCount + 1
                end
            end
        end
    else
        self.mainFrame.charName:SetText("Unknown")
        self.mainFrame.charName:SetTextColor(0.5, 0.5, 0.5)
        -- Hide all icons
        for _, iconFrame in pairs(self.mainFrame.professionIcons) do
            iconFrame:Hide()
        end
    end

    -- Adjust minimum width based on header content
    local iconCount = 0
    for _, iconFrame in pairs(self.mainFrame.professionIcons) do
        if iconFrame:IsShown() then
            iconCount = iconCount + 1
        end
    end
    local headerWidth = self.mainFrame.charName:GetStringWidth() + (iconCount * 20) + PADDING * 3 + 16
    local minWidth = math.max(MIN_WIDTH, headerWidth)
    self.mainFrame:SetResizeBounds(minWidth, MIN_HEIGHT)

    -- If current width is less than new minimum, resize the frame
    if self.mainFrame:GetWidth() < minWidth then
        self.mainFrame:SetWidth(minWidth)
        if self.mainFrame.content then
            self.mainFrame.content:SetWidth(minWidth - 40)
        end
    end

    -- Clear existing rows
    for _, row in pairs(self.mainFrame.rows) do
        row:Hide()
        if row.timeBtn then
            row.timeBtn.isClickable = false
            row.timeBtn:SetScript("OnClick", nil)
        end
        -- Hide profession icons
        if row.profIcons then
            for _, iconFrame in pairs(row.profIcons) do
                iconFrame:Hide()
            end
        end
        -- Hide TomTom button and vendor button
        if row.tomtomBtn then
            row.tomtomBtn:Hide()
        end
        if row.vendorBtn then
            row.vendorBtn:Hide()
        end
        if row.separatorText then
            row.separatorText:Hide()
        end
        -- Clear item link scripts
        row:SetScript("OnMouseUp", nil)
        row:SetScript("OnEnter", function(self) self.highlight:Show() end)
        row:SetScript("OnLeave", function(self) self.highlight:Hide() end)
    end

    -- Clear existing separators
    for _, sep in pairs(self.mainFrame.separators) do
        sep:Hide()
    end

    -- Hide settings/tracking widgets when not on their tabs
    if self.mainFrame.settingsWidgets then
        for _, widget in pairs(self.mainFrame.settingsWidgets) do
            widget:Hide()
        end
    end
    if self.mainFrame.trackingWidgets then
        for _, widget in pairs(self.mainFrame.trackingWidgets) do
            widget:Hide()
        end
    end

    local selectedTab = self.mainFrame.selectedTab or 1

    -- OVERVIEW TAB: Show all characters with their professions
    if selectedTab == 1 then
        for _, charInfo in ipairs(characters) do
            local charKey = charInfo.key
            local charData = charInfo.data
            charCount = charCount + 1

            -- Add separator before character (except first one)
            if charCount > 1 then
                local sepIndex = charCount - 1
                local separator = self.mainFrame.separators[sepIndex]
                if not separator then
                    separator = CreateSeparator(content, -(rowIndex * ROW_HEIGHT) - 2)
                    self.mainFrame.separators[sepIndex] = separator
                else
                    separator:ClearAllPoints()
                    separator:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(rowIndex * ROW_HEIGHT) - 2)
                    separator:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -(rowIndex * ROW_HEIGHT) - 2)
                end
                separator:Show()

                -- Add extra spacing for separator
                rowIndex = rowIndex + 0.5
            end

            -- Character row
            rowIndex = rowIndex + 1
            local charRow = self.mainFrame.rows[rowIndex]
            if not charRow then
                charRow = CreateRow(content, rowIndex)
                self.mainFrame.rows[rowIndex] = charRow
            end

            -- Update row position
            charRow:ClearAllPoints()
            charRow:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((rowIndex - 1) * ROW_HEIGHT))
            charRow:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -((rowIndex - 1) * ROW_HEIGHT))

            -- Set character name with class color
            local classColor = CLASS_COLORS[charData.class] or { r = 1, g = 1, b = 1 }
            charRow.text:SetTextColor(classColor.r, classColor.g, classColor.b)
            charRow.text:SetText(charData.name)

            -- Show profession icons
            local cp = charData.professions or {}
            local iconSpacing = 3
            local lastIcon = nil

            for _, profKey in ipairs(PROFESSION_ORDER) do
                local value = cp[profKey]
                if value and value ~= false and (type(value) ~= "number" or value > 0) then
                    local iconFrame = charRow.profIcons[profKey]
                    iconFrame.profName = PROFESSION_NAMES[profKey]
                    iconFrame.profLevel = type(value) == "number" and value or nil

                    iconFrame:ClearAllPoints()
                    if lastIcon then
                        iconFrame:SetPoint("LEFT", lastIcon, "RIGHT", iconSpacing, 0)
                    else
                        iconFrame:SetPoint("LEFT", charRow.text, "RIGHT", 6, 0)
                    end

                    iconFrame:Show()
                    lastIcon = iconFrame
                end
            end

            charRow.time:SetText("")
            charRow.timeBtn.isClickable = false
            charRow:Show()
        end

        -- Show message if no characters
        if rowIndex == 0 then
            rowIndex = 1
            local emptyRow = self.mainFrame.rows[1]
            if not emptyRow then
                emptyRow = CreateRow(content, 1)
                self.mainFrame.rows[1] = emptyRow
            end
            emptyRow.text:SetTextColor(0.5, 0.5, 0.5)
            emptyRow.text:SetText("No characters found.")
            emptyRow.time:SetText("")
            emptyRow.timeBtn.isClickable = false
            emptyRow:Show()
        end

    -- COOLDOWNS TAB: Show characters with cooldowns (no profession icons)
    elseif selectedTab == 2 then
        for _, charInfo in ipairs(characters) do
            local charKey = charInfo.key
            local charData = charInfo.data
            local isCurrentChar = (charKey == currentCharKey)

            if self:HasRelevantProfessions(charKey) then
                charCount = charCount + 1

                -- Add separator before character (except first one)
                if charCount > 1 then
                    local sepIndex = charCount - 1
                    local separator = self.mainFrame.separators[sepIndex]
                    if not separator then
                        separator = CreateSeparator(content, -(rowIndex * ROW_HEIGHT) - 2)
                        self.mainFrame.separators[sepIndex] = separator
                    else
                        separator:ClearAllPoints()
                        separator:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(rowIndex * ROW_HEIGHT) - 2)
                        separator:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -(rowIndex * ROW_HEIGHT) - 2)
                    end
                    separator:Show()

                    -- Add extra spacing for separator
                    rowIndex = rowIndex + 0.5
                end

                -- Character header row
                rowIndex = rowIndex + 1
                local headerRow = self.mainFrame.rows[rowIndex]
                if not headerRow then
                    headerRow = CreateRow(content, rowIndex)
                    self.mainFrame.rows[rowIndex] = headerRow
                end

                -- Update row position
                headerRow:ClearAllPoints()
                headerRow:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((rowIndex - 1) * ROW_HEIGHT))
                headerRow:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -((rowIndex - 1) * ROW_HEIGHT))

                -- Set character name with class color
                local classColor = CLASS_COLORS[charData.class] or { r = 1, g = 1, b = 1 }
                headerRow.text:SetTextColor(classColor.r, classColor.g, classColor.b)
                headerRow.text:SetText(charData.name)

                headerRow.time:SetText("")
                headerRow.timeBtn.isClickable = false
                headerRow:Show()

                -- Cooldown rows
                local cooldowns = self:GetCharacterCooldowns(charKey)
                for _, cd in ipairs(cooldowns) do
                    rowIndex = rowIndex + 1
                    local cdRow = self.mainFrame.rows[rowIndex]
                    if not cdRow then
                        cdRow = CreateRow(content, rowIndex)
                        self.mainFrame.rows[rowIndex] = cdRow
                    end

                    -- Update row position
                    cdRow:ClearAllPoints()
                    cdRow:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((rowIndex - 1) * ROW_HEIGHT))
                    cdRow:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -((rowIndex - 1) * ROW_HEIGHT))

                    cdRow.text:SetTextColor(0.7, 0.7, 0.7)
                    cdRow.text:SetText("  " .. cd.name)

                    -- Color the time based on ready status
                    if cd.remaining == nil then
                        cdRow.time:SetTextColor(0.4, 0.4, 0.4)
                        cdRow.time:SetText("--")
                        cdRow.timeBtn.isClickable = false
                    elseif cd.remaining <= 0 then
                        cdRow.time:SetTextColor(0, 1, 0)
                        cdRow.time:SetText("Ready!")

                        -- Make clickable only for current character
                        if isCurrentChar then
                            cdRow.timeBtn.isClickable = true
                            local cdType = cd.type
                            cdRow.timeBtn:SetScript("OnClick", function(self, button)
                                if button == "LeftButton" then
                                    PL:OpenCraftingSpell(cdType)
                                elseif button == "RightButton" then
                                    PL:SelectCraftingSpell(cdType)
                                end
                            end)
                        else
                            cdRow.timeBtn.isClickable = false
                        end
                    else
                        cdRow.time:SetTextColor(1, 0.82, 0)
                        cdRow.time:SetText(cd.formattedTime)
                        cdRow.timeBtn.isClickable = false
                    end

                    -- Adjust button width to fit text
                    cdRow.timeBtn:SetWidth(cdRow.time:GetStringWidth() + 4)

                    cdRow:Show()
                end
            end
        end

        -- Show message if no characters with cooldowns
        if rowIndex == 0 then
            rowIndex = 1
            local emptyRow = self.mainFrame.rows[1]
            if not emptyRow then
                emptyRow = CreateRow(content, 1)
                self.mainFrame.rows[1] = emptyRow
            end
            emptyRow.text:SetTextColor(0.5, 0.5, 0.5)
            emptyRow.text:SetText("No characters with Tailoring or Alchemy found.")
            emptyRow.time:SetText("")
            emptyRow.timeBtn.isClickable = false
            emptyRow:Show()
        end

    -- SOURCES TAB: Show craft source information
    elseif selectedTab == 3 then
        local sources = self.COOLDOWN_SOURCES or {}
        local sourceOrder = { "primalMooncloth", "shadowcloth", "spellcloth" }

        for _, cdType in ipairs(sourceOrder) do
            local source = sources[cdType]
            if source then
                local craftName = self.COOLDOWN_NAMES[cdType]

                -- Craft name header
                rowIndex = rowIndex + 1
                local headerRow = self.mainFrame.rows[rowIndex]
                if not headerRow then
                    headerRow = CreateRow(content, rowIndex)
                    self.mainFrame.rows[rowIndex] = headerRow
                end
                headerRow:ClearAllPoints()
                headerRow:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((rowIndex - 1) * ROW_HEIGHT))
                headerRow:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -((rowIndex - 1) * ROW_HEIGHT))
                headerRow.text:SetTextColor(1, 0.82, 0) -- Gold color for headers
                headerRow.text:SetText(craftName)
                headerRow.time:SetText("")
                headerRow.timeBtn.isClickable = false
                headerRow:Show()

                -- Link row (clickable item link)
                rowIndex = rowIndex + 1
                local linkRow = self.mainFrame.rows[rowIndex]
                if not linkRow then
                    linkRow = CreateRow(content, rowIndex)
                    self.mainFrame.rows[rowIndex] = linkRow
                end
                linkRow:ClearAllPoints()
                linkRow:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((rowIndex - 1) * ROW_HEIGHT))
                linkRow:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -((rowIndex - 1) * ROW_HEIGHT))

                -- Create item link (blue color for rare items)
                local itemLink = "|cff0070dd|Hitem:" .. source.pattern.itemId .. "::::::::70:::::|h[" .. source.pattern.name .. "]|h|r"
                linkRow.text:SetTextColor(0.7, 0.7, 0.7)
                linkRow.text:SetText("  Link: " .. itemLink)
                linkRow.time:SetText("")
                linkRow.timeBtn.isClickable = false

                -- Make the row clickable to show item tooltip and allow shift-click to link
                linkRow.itemLink = itemLink
                linkRow.itemId = source.pattern.itemId
                linkRow:SetScript("OnMouseUp", function(self, button)
                    if button == "LeftButton" and IsShiftKeyDown() and ChatFrame1EditBox:IsShown() then
                        ChatFrame1EditBox:Insert(self.itemLink)
                    end
                end)
                linkRow:SetScript("OnEnter", function(self)
                    self.highlight:Show()
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetHyperlink("item:" .. self.itemId)
                    GameTooltip:Show()
                end)
                linkRow:SetScript("OnLeave", function(self)
                    self.highlight:Hide()
                    GameTooltip:Hide()
                end)
                linkRow:Show()

                -- Source row (vendor name with TomTom link)
                rowIndex = rowIndex + 1
                local sourceRow = self.mainFrame.rows[rowIndex]
                if not sourceRow then
                    sourceRow = CreateRow(content, rowIndex)
                    self.mainFrame.rows[rowIndex] = sourceRow
                end
                sourceRow:ClearAllPoints()
                sourceRow:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((rowIndex - 1) * ROW_HEIGHT))
                sourceRow:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -((rowIndex - 1) * ROW_HEIGHT))
                sourceRow.text:SetTextColor(0.7, 0.7, 0.7)
                sourceRow.text:SetText("  Source: ")
                sourceRow.time:SetText("")
                sourceRow.timeBtn.isClickable = false

                -- Create vendor name button if not exists
                if not sourceRow.vendorBtn then
                    sourceRow.vendorBtn = CreateFrame("Button", nil, sourceRow)
                    sourceRow.vendorBtn:SetHeight(ROW_HEIGHT)
                    sourceRow.vendorBtn.text = sourceRow.vendorBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    sourceRow.vendorBtn.text:SetPoint("LEFT", sourceRow.vendorBtn, "LEFT", 0, 0)
                    sourceRow.vendorBtn.text:SetTextColor(0.4, 0.6, 1) -- Blue color for link

                    sourceRow.vendorBtn:SetScript("OnEnter", function(self)
                        self.text:SetTextColor(0.6, 0.8, 1) -- Lighter blue on hover
                        sourceRow.highlight:Show()
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:AddLine("Target " .. (self.vendorName or "NPC"))
                        GameTooltip:AddLine("Click to target this NPC", 0.8, 0.8, 0.8)
                        GameTooltip:Show()
                    end)
                    sourceRow.vendorBtn:SetScript("OnLeave", function(self)
                        self.text:SetTextColor(0.4, 0.6, 1)
                        sourceRow.highlight:Hide()
                        GameTooltip:Hide()
                    end)
                end

                -- Set vendor name and position
                sourceRow.vendorBtn.text:SetText(source.vendor.name)
                sourceRow.vendorBtn:SetWidth(sourceRow.vendorBtn.text:GetStringWidth() + 4)
                sourceRow.vendorBtn:SetPoint("LEFT", sourceRow.text, "RIGHT", 0, 0)
                sourceRow.vendorBtn.vendorName = source.vendor.name
                sourceRow.vendorBtn:SetScript("OnClick", function(self)
                    if self.vendorName then
                        TargetUnit(self.vendorName)
                    end
                end)
                sourceRow.vendorBtn:Show()

                -- Create separator text if not exists
                if not sourceRow.separatorText then
                    sourceRow.separatorText = sourceRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    sourceRow.separatorText:SetTextColor(0.7, 0.7, 0.7)
                    sourceRow.separatorText:SetText(" - ")
                end
                sourceRow.separatorText:SetPoint("LEFT", sourceRow.vendorBtn, "RIGHT", 0, 0)
                sourceRow.separatorText:Show()

                -- Create TomTom link button if not exists
                if not sourceRow.tomtomBtn then
                    sourceRow.tomtomBtn = CreateFrame("Button", nil, sourceRow)
                    sourceRow.tomtomBtn:SetHeight(ROW_HEIGHT)
                    sourceRow.tomtomBtn.text = sourceRow.tomtomBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    sourceRow.tomtomBtn.text:SetPoint("LEFT", sourceRow.tomtomBtn, "LEFT", 0, 0)
                    sourceRow.tomtomBtn.text:SetText("TomTom")
                    sourceRow.tomtomBtn.text:SetTextColor(0.4, 0.6, 1) -- Blue color for link
                    sourceRow.tomtomBtn:SetWidth(sourceRow.tomtomBtn.text:GetStringWidth() + 4)

                    sourceRow.tomtomBtn:SetScript("OnEnter", function(self)
                        self.text:SetTextColor(0.6, 0.8, 1) -- Lighter blue on hover
                        sourceRow.highlight:Show()
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:AddLine("Add TomTom waypoint")
                        GameTooltip:AddLine("Click to set waypoint", 0.8, 0.8, 0.8)
                        GameTooltip:Show()
                    end)
                    sourceRow.tomtomBtn:SetScript("OnLeave", function(self)
                        self.text:SetTextColor(0.4, 0.6, 1)
                        sourceRow.highlight:Hide()
                        GameTooltip:Hide()
                    end)
                end

                -- Position TomTom button after separator
                sourceRow.tomtomBtn:SetPoint("LEFT", sourceRow.separatorText, "RIGHT", 0, 0)
                sourceRow.tomtomBtn.tomtomCommand = source.vendor.tomtom
                sourceRow.tomtomBtn:SetScript("OnClick", function(self)
                    if self.tomtomCommand then
                        -- Execute the TomTom command
                        DEFAULT_CHAT_FRAME.editBox:SetText(self.tomtomCommand)
                        ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox)
                    end
                end)
                sourceRow.tomtomBtn:Show()
                sourceRow:Show()

                -- Add spacing separator between crafts
                rowIndex = rowIndex + 0.5
            end
        end

        -- Show message if no sources defined
        if rowIndex == 0 then
            rowIndex = 1
            local emptyRow = self.mainFrame.rows[1]
            if not emptyRow then
                emptyRow = CreateRow(content, 1)
                self.mainFrame.rows[1] = emptyRow
            end
            emptyRow.text:SetTextColor(0.5, 0.5, 0.5)
            emptyRow.text:SetText("No source information available.")
            emptyRow.time:SetText("")
            emptyRow.timeBtn.isClickable = false
            emptyRow:Show()
        end

    -- CD TRACKING TAB
    elseif selectedTab == 4 then
        -- Hide tracking widgets from previous render if they exist
        if self.mainFrame.trackingWidgets then
            for _, widget in pairs(self.mainFrame.trackingWidgets) do
                widget:Hide()
            end
        end
        self.mainFrame.trackingWidgets = {}

        local yOffset = -4

        -- Tailoring header
        local tailoringHeader = self.mainFrame.trackingTailoringHeader
        if not tailoringHeader then
            tailoringHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            self.mainFrame.trackingTailoringHeader = tailoringHeader
        end
        tailoringHeader:ClearAllPoints()
        tailoringHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        tailoringHeader:SetText("Tailoring")
        tailoringHeader:SetTextColor(0.9, 0.8, 0.5)
        tailoringHeader:Show()
        table.insert(self.mainFrame.trackingWidgets, tailoringHeader)

        yOffset = yOffset - 20

        -- Tailoring cooldown checkboxes
        for _, cdType in ipairs(self.PROFESSION_COOLDOWNS.tailoring) do
            local cbKey = "trackingCb_" .. cdType
            local cb = self.mainFrame[cbKey]
            if not cb then
                cb = CreateFrame("CheckButton", "PrimalLedgerTrack_" .. cdType, content, "UICheckButtonTemplate")
                cb:SetSize(24, 24)
                self.mainFrame[cbKey] = cb
            end
            cb:ClearAllPoints()
            cb:SetPoint("TOPLEFT", content, "TOPLEFT", 4, yOffset)
            cb:SetChecked(self:IsCooldownEnabled(cdType))
            local capturedType = cdType
            cb:SetScript("OnClick", function(self)
                if self:GetChecked() then
                    PL.db.settings.disabledCooldowns[capturedType] = nil
                else
                    PL.db.settings.disabledCooldowns[capturedType] = true
                end
            end)
            cb:Show()
            table.insert(self.mainFrame.trackingWidgets, cb)

            local labelKey = "trackingLabel_" .. cdType
            local label = self.mainFrame[labelKey]
            if not label then
                label = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                self.mainFrame[labelKey] = label
            end
            label:ClearAllPoints()
            label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
            label:SetText(self.COOLDOWN_NAMES[cdType])
            label:SetTextColor(0.9, 0.9, 0.9)
            label:Show()
            table.insert(self.mainFrame.trackingWidgets, label)

            yOffset = yOffset - 24
        end

        yOffset = yOffset - 8

        -- Alchemy header
        local alchemyHeader = self.mainFrame.trackingAlchemyHeader
        if not alchemyHeader then
            alchemyHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            self.mainFrame.trackingAlchemyHeader = alchemyHeader
        end
        alchemyHeader:ClearAllPoints()
        alchemyHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        alchemyHeader:SetText("Alchemy")
        alchemyHeader:SetTextColor(0.9, 0.8, 0.5)
        alchemyHeader:Show()
        table.insert(self.mainFrame.trackingWidgets, alchemyHeader)

        yOffset = yOffset - 20

        -- Alchemy cooldown checkboxes
        for _, cdType in ipairs(self.PROFESSION_COOLDOWNS.alchemy) do
            local cbKey = "trackingCb_" .. cdType
            local cb = self.mainFrame[cbKey]
            if not cb then
                cb = CreateFrame("CheckButton", "PrimalLedgerTrack_" .. cdType, content, "UICheckButtonTemplate")
                cb:SetSize(24, 24)
                self.mainFrame[cbKey] = cb
            end
            cb:ClearAllPoints()
            cb:SetPoint("TOPLEFT", content, "TOPLEFT", 4, yOffset)
            cb:SetChecked(self:IsCooldownEnabled(cdType))
            local capturedType = cdType
            cb:SetScript("OnClick", function(self)
                if self:GetChecked() then
                    PL.db.settings.disabledCooldowns[capturedType] = nil
                else
                    PL.db.settings.disabledCooldowns[capturedType] = true
                end
            end)
            cb:Show()
            table.insert(self.mainFrame.trackingWidgets, cb)

            local labelKey = "trackingLabel_" .. cdType
            local label = self.mainFrame[labelKey]
            if not label then
                label = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                self.mainFrame[labelKey] = label
            end
            label:ClearAllPoints()
            label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
            label:SetText(self.COOLDOWN_NAMES[cdType])
            label:SetTextColor(0.9, 0.9, 0.9)
            label:Show()
            table.insert(self.mainFrame.trackingWidgets, label)

            yOffset = yOffset - 24
        end

        -- Content height for tracking tab
        content:SetHeight(math.abs(yOffset) + 10)

    -- SETTINGS TAB
    elseif selectedTab == 5 then
        -- Hide settings widgets from previous render if they exist
        if self.mainFrame.settingsWidgets then
            for _, widget in pairs(self.mainFrame.settingsWidgets) do
                widget:Hide()
            end
        end
        self.mainFrame.settingsWidgets = {}

        local yOffset = -PADDING

        -- Notification checkbox
        local checkBtn = self.mainFrame.settingsCheckBtn
        if not checkBtn then
            checkBtn = CreateFrame("CheckButton", "PrimalLedgerNotifCheck", content, "UICheckButtonTemplate")
            checkBtn:SetSize(24, 24)
            self.mainFrame.settingsCheckBtn = checkBtn
        end
        checkBtn:ClearAllPoints()
        checkBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        checkBtn:SetChecked(self.db.settings.showNotifications ~= false)
        checkBtn:SetScript("OnClick", function(self)
            PL.db.settings.showNotifications = self:GetChecked()
        end)
        checkBtn:Show()
        table.insert(self.mainFrame.settingsWidgets, checkBtn)

        local checkLabel = self.mainFrame.settingsCheckLabel
        if not checkLabel then
            checkLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            self.mainFrame.settingsCheckLabel = checkLabel
        end
        checkLabel:ClearAllPoints()
        checkLabel:SetPoint("LEFT", checkBtn, "RIGHT", 4, 0)
        checkLabel:SetText("Show \"Craft available\" reminder on login")
        checkLabel:SetTextColor(0.9, 0.9, 0.9)
        checkLabel:Show()
        table.insert(self.mainFrame.settingsWidgets, checkLabel)

        yOffset = yOffset - 40

        -- Reset Data button
        local resetBtn = self.mainFrame.settingsResetBtn
        if not resetBtn then
            resetBtn = CreateFrame("Button", "PrimalLedgerResetBtn", content, "BackdropTemplate")
            resetBtn:SetSize(100, 24)
            resetBtn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
                insets = { left = 1, right = 1, top = 1, bottom = 1 }
            })
            resetBtn:SetBackdropColor(0.6, 0.15, 0.15, 0.8)
            resetBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

            local btnText = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            btnText:SetPoint("CENTER", 0, 0)
            btnText:SetText("Reset Data")
            btnText:SetTextColor(1, 1, 1)
            resetBtn.btnText = btnText

            resetBtn:SetScript("OnEnter", function(self)
                self:SetBackdropColor(0.8, 0.2, 0.2, 0.9)
            end)
            resetBtn:SetScript("OnLeave", function(self)
                self:SetBackdropColor(0.6, 0.15, 0.15, 0.8)
            end)
            self.mainFrame.settingsResetBtn = resetBtn
        end
        resetBtn:ClearAllPoints()
        resetBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        resetBtn:SetScript("OnClick", function()
            StaticPopup_Show("PRIMAL_LEDGER_RESET_CONFIRM")
        end)
        resetBtn:Show()
        table.insert(self.mainFrame.settingsWidgets, resetBtn)

        -- Content height for settings
        content:SetHeight(100)
    end

    -- Update content height
    if selectedTab <= 3 then
        content:SetHeight(rowIndex * ROW_HEIGHT + 10)
    end
end

-- Toggle main frame visibility
-- Select a tab
function PL:SelectTab(tabIndex)
    if not self.mainFrame or not self.mainFrame.tabs then return end

    -- Update tab appearances
    for i, tab in ipairs(self.mainFrame.tabs) do
        if i == tabIndex then
            tab.isSelected = true
            tab.text:SetTextColor(1, 1, 1)
            tab.selectedBg:Show()
            tab.underline:Show()
        else
            tab.isSelected = false
            tab.text:SetTextColor(0.6, 0.6, 0.6)
            tab.selectedBg:Hide()
            tab.underline:Hide()
        end
    end

    self.mainFrame.selectedTab = tabIndex

    -- Update content based on selected tab
    self:UpdateMainFrame()
end

-- Notification window for ready cooldowns on login
function PL:ShowNotificationWindow()
    if self.db.settings.showNotifications == false then return end

    local readyCooldowns = self:GetAllReadyCooldowns()
    if #readyCooldowns == 0 then return end

    -- Remove existing notification if shown
    if self.notificationFrame then
        self.notificationFrame:Hide()
        self.notificationFrame = nil
    end

    local NOTIF_PADDING = 10
    local NOTIF_ROW_HEIGHT = 16
    local NOTIF_HEADER_HEIGHT = 20

    local frame = CreateFrame("Frame", "PrimalLedgerNotification", UIParent, "BackdropTemplate")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.92)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", NOTIF_PADDING, -NOTIF_PADDING)
    title:SetText("Primal Ledger")
    title:SetTextColor(0.9, 0.9, 0.9)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(14, 14)
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -NOTIF_PADDING, -NOTIF_PADDING)

    local closeBtnText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    closeBtnText:SetPoint("CENTER", 0, 0)
    closeBtnText:SetText("X")
    closeBtnText:SetTextColor(0.6, 0.6, 0.6)

    closeBtn:SetScript("OnEnter", function() closeBtnText:SetTextColor(1, 0.3, 0.3) end)
    closeBtn:SetScript("OnLeave", function() closeBtnText:SetTextColor(0.6, 0.6, 0.6) end)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Separator
    local sep = frame:CreateTexture(nil, "ARTWORK")
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", frame, "TOPLEFT", NOTIF_PADDING, -(NOTIF_PADDING + NOTIF_HEADER_HEIGHT))
    sep:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -NOTIF_PADDING, -(NOTIF_PADDING + NOTIF_HEADER_HEIGHT))
    sep:SetColorTexture(0.3, 0.3, 0.3, 1)

    -- Build rows
    local maxTextWidth = 0
    local contentTop = -(NOTIF_PADDING + NOTIF_HEADER_HEIGHT + 6)

    for i, entry in ipairs(readyCooldowns) do
        local row = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        local yOffset = contentTop - ((i - 1) * NOTIF_ROW_HEIGHT)
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", NOTIF_PADDING, yOffset)

        local classColor = CLASS_COLORS[entry.charClass] or { r = 1, g = 1, b = 1 }
        local colorCode = string.format("|cff%02x%02x%02x",
            math.floor(classColor.r * 255),
            math.floor(classColor.g * 255),
            math.floor(classColor.b * 255))

        row:SetText(colorCode .. entry.charName .. "|r  |cff888888|||r  |cff00ff00" .. entry.craftName .. " available!|r")

        local textWidth = row:GetStringWidth()
        if textWidth > maxTextWidth then
            maxTextWidth = textWidth
        end
    end

    -- Size the frame to fit content
    local frameWidth = maxTextWidth + (NOTIF_PADDING * 2) + 10
    local frameHeight = NOTIF_PADDING + NOTIF_HEADER_HEIGHT + 6 + (#readyCooldowns * NOTIF_ROW_HEIGHT) + NOTIF_PADDING
    frame:SetSize(math.max(frameWidth, 200), frameHeight)
    frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -200, -200)

    self.notificationFrame = frame
end

function PL:ToggleMainFrame()
    if not self.mainFrame then
        self:CreateMainFrame()
    end

    if self.mainFrame:IsShown() then
        self.mainFrame:Hide()
    else
        -- Refresh current character's known crafts
        local charKey = self:GetCharacterKey()
        self:DetectKnownCrafts(charKey)

        self:UpdateMainFrame()
        self.mainFrame:Show()
    end
end

-- Export button on the TradeSkill frame
function PL:CreateExportButton()
    if self.exportBtn then return end

    -- TradeSkillFrame must exist
    if not TradeSkillFrame then return end

    local btn = CreateFrame("Button", "PrimalLedgerExportBtn", TradeSkillFrame, "BackdropTemplate")
    btn:SetSize(60, 22)
    btn:SetPoint("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -60, -4)
    btn:SetFrameStrata("HIGH")
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    btn:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btnText:SetPoint("CENTER", 0, 0)
    btnText:SetText("Export")
    btnText:SetTextColor(0.9, 0.9, 0.9)

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.25, 0.25, 0.25, 0.9)
        btnText:SetTextColor(1, 1, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
        btnText:SetTextColor(0.9, 0.9, 0.9)
    end)
    btn:SetScript("OnClick", function()
        PL:ShowExportWindow("tradeskill")
    end)

    self.exportBtn = btn
end

-- Export button for the Craft frame (Enchanting)
function PL:CreateCraftExportButton()
    if self.craftExportBtn then return end

    if not CraftFrame then return end

    local btn = CreateFrame("Button", "PrimalLedgerCraftExportBtn", CraftFrame, "BackdropTemplate")
    btn:SetSize(60, 22)
    btn:SetPoint("TOPRIGHT", CraftFrame, "TOPRIGHT", -60, -4)
    btn:SetFrameStrata("HIGH")
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    btn:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btnText:SetPoint("CENTER", 0, 0)
    btnText:SetText("Export")
    btnText:SetTextColor(0.9, 0.9, 0.9)

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.25, 0.25, 0.25, 0.9)
        btnText:SetTextColor(1, 1, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
        btnText:SetTextColor(0.9, 0.9, 0.9)
    end)
    btn:SetScript("OnClick", function()
        PL:ShowExportWindow("craft")
    end)

    self.craftExportBtn = btn
end

-- Build export text from the TradeSkill window
function PL:BuildTradeSkillExportText()
    local numSkills = GetNumTradeSkills()
    if not numSkills or numSkills == 0 then return nil end

    local tradeskillName = GetTradeSkillLine()
    if not tradeskillName then return nil end

    local playerName = UnitName("player")
    local lines = {}

    table.insert(lines, "**" .. playerName .. " - " .. tradeskillName .. "**")
    table.insert(lines, "```")

    local currentHeader = nil
    for i = 1, numSkills do
        local name, skillType = GetTradeSkillInfo(i)
        if name then
            if skillType == "header" then
                if currentHeader then
                    table.insert(lines, "")
                end
                currentHeader = name
                table.insert(lines, "[ " .. name .. " ]")
            elseif skillType ~= "subheader" then
                table.insert(lines, "  " .. name)
            end
        end
    end

    table.insert(lines, "```")

    return table.concat(lines, "\n")
end

-- Build export text from the Craft window (Enchanting)
function PL:BuildCraftExportText()
    local numCrafts = GetNumCrafts()
    if not numCrafts or numCrafts == 0 then return nil end

    local craftName = GetCraftDisplaySkillLine()
    if not craftName then return nil end

    local playerName = UnitName("player")
    local lines = {}

    table.insert(lines, "**" .. playerName .. " - " .. craftName .. "**")
    table.insert(lines, "```")

    local currentHeader = nil
    for i = 1, numCrafts do
        local name, _, craftType = GetCraftInfo(i)
        if name then
            if craftType == "header" then
                if currentHeader then
                    table.insert(lines, "")
                end
                currentHeader = name
                table.insert(lines, "[ " .. name .. " ]")
            elseif craftType ~= "subheader" then
                table.insert(lines, "  " .. name)
            end
        end
    end

    table.insert(lines, "```")

    return table.concat(lines, "\n")
end

-- Show export window with copyable text
function PL:ShowExportWindow(source)
    local exportText
    if source == "craft" then
        exportText = self:BuildCraftExportText()
    else
        exportText = self:BuildTradeSkillExportText()
    end
    if not exportText then
        self:Print("No profession window open.")
        return
    end

    -- Reuse or create frame
    if self.exportFrame then
        self.exportFrame:Show()
    else
        local frame = CreateFrame("Frame", "PrimalLedgerExportFrame", UIParent, "BackdropTemplate")
        frame:SetSize(400, 350)
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        frame:SetFrameStrata("DIALOG")
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:SetClampedToScreen(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

        frame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })
        frame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
        frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

        -- Title
        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
        title:SetText("Export Crafts")
        title:SetTextColor(0.9, 0.9, 0.9)

        -- Close button
        local closeBtn = CreateFrame("Button", nil, frame)
        closeBtn:SetSize(16, 16)
        closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)
        local closeBtnText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        closeBtnText:SetPoint("CENTER", 0, 0)
        closeBtnText:SetText("X")
        closeBtnText:SetTextColor(0.6, 0.6, 0.6)
        closeBtn:SetScript("OnEnter", function() closeBtnText:SetTextColor(1, 0.3, 0.3) end)
        closeBtn:SetScript("OnLeave", function() closeBtnText:SetTextColor(0.6, 0.6, 0.6) end)
        closeBtn:SetScript("OnClick", function() frame:Hide() end)

        -- Hint text
        local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        hint:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
        hint:SetText("Press Ctrl+A to select all, then Ctrl+C to copy")
        hint:SetTextColor(0.5, 0.5, 0.5)

        -- Scroll frame for the edit box
        local scrollFrame = CreateFrame("ScrollFrame", "PrimalLedgerExportScroll", frame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -48)
        scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)

        local editBox = CreateFrame("EditBox", "PrimalLedgerExportEditBox", scrollFrame)
        editBox:SetMultiLine(true)
        editBox:SetAutoFocus(false)
        editBox:SetFontObject(GameFontHighlightSmall)
        editBox:SetWidth(scrollFrame:GetWidth())
        editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        -- Prevent editing the text
        editBox:SetScript("OnChar", function(self) self:SetText(PL.exportFrame.currentText or "") end)
        editBox:SetScript("OnTextChanged", function(self, userInput)
            if userInput then
                self:SetText(PL.exportFrame.currentText or "")
            end
        end)

        scrollFrame:SetScrollChild(editBox)

        frame.editBox = editBox
        self.exportFrame = frame
    end

    self.exportFrame.currentText = exportText
    self.exportFrame.editBox:SetText(exportText)
    self.exportFrame.editBox:SetWidth(self.exportFrame:GetWidth() - 40)
    self.exportFrame.editBox:HighlightText()
    self.exportFrame.editBox:SetFocus()
end
