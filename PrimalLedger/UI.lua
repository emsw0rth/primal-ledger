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

-- Color palette (Outland / Dark Portal theme)
local COLORS = {
    bg =            { 0.08, 0.05, 0.03, 0.92 },    -- dark brown-black
    border =        { 0.35, 0.22, 0.10, 1 },        -- dark bronze
    separator =     { 0.40, 0.30, 0.20, 1 },        -- warm brown
    separatorFaint ={ 0.30, 0.22, 0.15, 0.8 },      -- faint brown
    highlight =     { 0.80, 0.50, 0.20, 0.08 },     -- warm highlight
    accent =        { 0.85, 0.45, 0.15 },            -- orange (title, headers, links)
    accentHover =   { 1.00, 0.60, 0.20 },            -- brighter orange hover
    accentMuted =   { 0.75, 0.55, 0.30 },            -- muted orange
    textNormal =    { 0.85, 0.80, 0.70 },            -- warm off-white
    textDim =       { 0.60, 0.50, 0.35 },            -- warm gray
    textFaint =     { 0.45, 0.38, 0.28 },            -- faint warm gray
    ready =         { 0.20, 0.80, 0.20 },            -- fel green
    readyHover =    { 0.40, 1.00, 0.40 },            -- lighter fel green
    closeHover =    { 0.90, 0.40, 0.10 },            -- orange-red
    tabSelectedBg = { 0.15, 0.10, 0.05, 1 },         -- dark warm bg
    btnBg =         { 0.60, 0.15, 0.15, 0.8 },       -- red button
    btnBgHover =    { 0.80, 0.20, 0.20, 0.9 },       -- red button hover
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

    -- Backdrop - dark Outland theme
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    frame:SetBackdropColor(unpack(COLORS.bg))
    frame:SetBackdropBorderColor(unpack(COLORS.border))

    -- Header image
    local headerImage = frame:CreateTexture(nil, "ARTWORK")
    headerImage:SetHeight(60)
    headerImage:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    headerImage:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
    headerImage:SetTexture("Interface\\AddOns\\PrimalLedger\\assets\\header")
    headerImage:SetTexCoord(0, 1, 0.05, 0.95)

    -- Title bar (anchored over the header image)
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetHeight(HEADER_HEIGHT)
    titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -PADDING)
    titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -PADDING, -PADDING)

    -- Version text overlay
    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("BOTTOMRIGHT", headerImage, "BOTTOMRIGHT", -PADDING, 4)
    title:SetText("v" .. (PL.version or "1.0.0"))
    title:SetTextColor(COLORS.textDim[1], COLORS.textDim[2], COLORS.textDim[3], 0.8)

    -- Title separator line
    local titleSeparator = frame:CreateTexture(nil, "ARTWORK")
    titleSeparator:SetHeight(1)
    titleSeparator:SetPoint("TOPLEFT", headerImage, "BOTTOMLEFT", PADDING, 0)
    titleSeparator:SetPoint("TOPRIGHT", headerImage, "BOTTOMRIGHT", -PADDING, 0)
    titleSeparator:SetColorTexture(unpack(COLORS.separator))

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
    headerSeparator:SetColorTexture(unpack(COLORS.separator))

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
        tab.selectedBg:SetColorTexture(unpack(COLORS.tabSelectedBg))
        tab.selectedBg:Hide()

        -- Underline for selected state
        tab.underline = tab:CreateTexture(nil, "ARTWORK")
        tab.underline:SetHeight(2)
        tab.underline:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 0, 0)
        tab.underline:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", 0, 0)
        tab.underline:SetColorTexture(COLORS.accent[1], COLORS.accent[2], COLORS.accent[3], 1)
        tab.underline:Hide()

        tab.tabIndex = tabIndex

        tab:SetScript("OnEnter", function(self)
            if not self.isSelected then
                self.text:SetTextColor(unpack(COLORS.accentMuted))
            end
        end)

        tab:SetScript("OnLeave", function(self)
            if not self.isSelected then
                self.text:SetTextColor(unpack(COLORS.textDim))
            end
        end)

        tab:SetScript("OnClick", function(self)
            PL:SelectTab(self.tabIndex)
        end)

        -- Initial state
        tab.text:SetTextColor(unpack(COLORS.textDim))
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

    local settingsTab = CreateTab(tabBar, "Settings", 4)
    settingsTab:SetPoint("LEFT", sourcesTab, "RIGHT", 8, 0)

    frame.tabs = { overviewTab, cooldownsTab, sourcesTab, settingsTab }
    frame.tabBar = tabBar
    frame.selectedTab = 1

    -- Tab separator line
    local tabSeparator = frame:CreateTexture(nil, "ARTWORK")
    tabSeparator:SetHeight(1)
    tabSeparator:SetPoint("TOPLEFT", tabBar, "BOTTOMLEFT", 0, -2)
    tabSeparator:SetPoint("TOPRIGHT", tabBar, "BOTTOMRIGHT", 0, -2)
    tabSeparator:SetColorTexture(unpack(COLORS.separator))

    frame.tabSeparator = tabSeparator

    -- Custom close button
    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(16, 16)
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -PADDING, -PADDING)

    local closeBtnText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeBtnText:SetPoint("CENTER", closeBtn, "CENTER", 0, 0)
    closeBtnText:SetText("X")
    closeBtnText:SetTextColor(unpack(COLORS.textDim))

    closeBtn:SetScript("OnEnter", function()
        closeBtnText:SetTextColor(unpack(COLORS.closeHover))
    end)
    closeBtn:SetScript("OnLeave", function()
        closeBtnText:SetTextColor(unpack(COLORS.textDim))
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

    -- Update timer (skip settings tab - it's static content and re-rendering closes dropdowns)
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed
        if self.timeSinceUpdate >= 1 then
            self.timeSinceUpdate = 0
            if self:IsShown() and PL.mainFrame.selectedTab ~= 4 then
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
    row.highlight:SetColorTexture(unpack(COLORS.highlight))
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
            row.time:SetTextColor(unpack(COLORS.readyHover)) -- Lighter green on hover
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
            row.time:SetTextColor(unpack(COLORS.ready)) -- Back to green
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
    separator:SetColorTexture(unpack(COLORS.separatorFaint))
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
        self.mainFrame.charName:SetTextColor(unpack(COLORS.textFaint))
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

    -- Hide settings widgets when not on settings tab
    if self.mainFrame.settingsWidgets then
        for _, widget in pairs(self.mainFrame.settingsWidgets) do
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
            emptyRow.text:SetTextColor(unpack(COLORS.textFaint))
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

                    cdRow.text:SetTextColor(unpack(COLORS.textNormal))
                    cdRow.text:SetText("  " .. cd.name)

                    -- Color the time based on ready status
                    if cd.remaining == nil then
                        cdRow.time:SetTextColor(unpack(COLORS.textFaint))
                        cdRow.time:SetText("--")
                        cdRow.timeBtn.isClickable = false
                    elseif cd.remaining <= 0 then
                        cdRow.time:SetTextColor(unpack(COLORS.ready))
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
            emptyRow.text:SetTextColor(unpack(COLORS.textFaint))
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
                headerRow.text:SetTextColor(unpack(COLORS.accent)) -- Orange header
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
                linkRow.text:SetTextColor(unpack(COLORS.textNormal))
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
                sourceRow.text:SetTextColor(unpack(COLORS.textNormal))
                sourceRow.text:SetText("  Source: ")
                sourceRow.time:SetText("")
                sourceRow.timeBtn.isClickable = false

                -- Create vendor name button if not exists
                if not sourceRow.vendorBtn then
                    sourceRow.vendorBtn = CreateFrame("Button", nil, sourceRow)
                    sourceRow.vendorBtn:SetHeight(ROW_HEIGHT)
                    sourceRow.vendorBtn.text = sourceRow.vendorBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    sourceRow.vendorBtn.text:SetPoint("LEFT", sourceRow.vendorBtn, "LEFT", 0, 0)
                    sourceRow.vendorBtn.text:SetTextColor(unpack(COLORS.accentMuted))

                    sourceRow.vendorBtn:SetScript("OnEnter", function(self)
                        self.text:SetTextColor(unpack(COLORS.accentHover))
                        sourceRow.highlight:Show()
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:AddLine("Target " .. (self.vendorName or "NPC"))
                        GameTooltip:AddLine("Click to target this NPC", 0.8, 0.8, 0.8)
                        GameTooltip:Show()
                    end)
                    sourceRow.vendorBtn:SetScript("OnLeave", function(self)
                        self.text:SetTextColor(unpack(COLORS.accentMuted))
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
                    sourceRow.separatorText:SetTextColor(unpack(COLORS.textNormal))
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
                    sourceRow.tomtomBtn.text:SetTextColor(unpack(COLORS.accentMuted))
                    sourceRow.tomtomBtn:SetWidth(sourceRow.tomtomBtn.text:GetStringWidth() + 4)

                    sourceRow.tomtomBtn:SetScript("OnEnter", function(self)
                        self.text:SetTextColor(unpack(COLORS.accentHover))
                        sourceRow.highlight:Show()
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:AddLine("Add TomTom waypoint")
                        GameTooltip:AddLine("Click to set waypoint", 0.8, 0.8, 0.8)
                        GameTooltip:Show()
                    end)
                    sourceRow.tomtomBtn:SetScript("OnLeave", function(self)
                        self.text:SetTextColor(unpack(COLORS.accentMuted))
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
            emptyRow.text:SetTextColor(unpack(COLORS.textFaint))
            emptyRow.text:SetText("No source information available.")
            emptyRow.time:SetText("")
            emptyRow.timeBtn.isClickable = false
            emptyRow:Show()
        end

    -- SETTINGS TAB
    elseif selectedTab == 4 then
        -- Hide settings widgets from previous render if they exist
        if self.mainFrame.settingsWidgets then
            for _, widget in pairs(self.mainFrame.settingsWidgets) do
                widget:Hide()
            end
        end
        self.mainFrame.settingsWidgets = {}

        local yOffset = -PADDING

        -- Tracker window checkbox
        local checkBtn = self.mainFrame.settingsCheckBtn
        if not checkBtn then
            checkBtn = CreateFrame("CheckButton", "PrimalLedgerTrackerCheck", content, "UICheckButtonTemplate")
            checkBtn:SetSize(24, 24)
            self.mainFrame.settingsCheckBtn = checkBtn
        end
        checkBtn:ClearAllPoints()
        checkBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        checkBtn:SetChecked(self.db.settings.showTrackerWindow ~= false)
        checkBtn:SetScript("OnClick", function(self)
            PL.db.settings.showTrackerWindow = self:GetChecked()
            if self:GetChecked() then
                PL:ShowTrackerWindow()
            else
                PL:HideTrackerWindow()
            end
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
        checkLabel:SetText("Show cooldown tracker window")
        checkLabel:SetTextColor(unpack(COLORS.textNormal))
        checkLabel:Show()
        table.insert(self.mainFrame.settingsWidgets, checkLabel)

        -- Tracker mode dropdown
        local modeDropdown = self.mainFrame.settingsTrackerDropdown
        if not modeDropdown then
            modeDropdown = CreateFrame("Frame", "PrimalLedgerTrackerModeDropdown", content, "UIDropDownMenuTemplate")
            self.mainFrame.settingsTrackerDropdown = modeDropdown
        end
        modeDropdown:ClearAllPoints()
        modeDropdown:SetPoint("LEFT", checkLabel, "RIGHT", 0, -2)
        UIDropDownMenu_SetWidth(modeDropdown, 100)

        local currentMode = self.db.settings.trackerMode or "static"
        local modeLabels = { static = "Static", conditional = "Conditional" }
        UIDropDownMenu_SetText(modeDropdown, modeLabels[currentMode] or "Static")

        UIDropDownMenu_Initialize(modeDropdown, function(self, level)
            local info = UIDropDownMenu_CreateInfo()

            info.text = "Static"
            info.value = "static"
            info.checked = (PL.db.settings.trackerMode or "static") == "static"
            info.func = function()
                PL.db.settings.trackerMode = "static"
                UIDropDownMenu_SetText(modeDropdown, "Static")
                PL:EvaluateTrackerVisibility()
            end
            UIDropDownMenu_AddButton(info)

            info.text = "Conditional"
            info.value = "conditional"
            info.checked = PL.db.settings.trackerMode == "conditional"
            info.func = function()
                PL.db.settings.trackerMode = "conditional"
                UIDropDownMenu_SetText(modeDropdown, "Conditional")
                PL:EvaluateTrackerVisibility()
            end
            UIDropDownMenu_AddButton(info)
        end)
        modeDropdown:Show()
        table.insert(self.mainFrame.settingsWidgets, modeDropdown)

        -- Help tooltip button (?)
        local helpBtn = self.mainFrame.settingsTrackerHelp
        if not helpBtn then
            helpBtn = CreateFrame("Button", nil, content)
            helpBtn:SetSize(16, 16)
            self.mainFrame.settingsTrackerHelp = helpBtn

            local helpText = helpBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            helpText:SetPoint("CENTER", 0, 0)
            helpText:SetText("?")
            helpText:SetTextColor(unpack(COLORS.accent))
            helpBtn.text = helpText
        end
        helpBtn:ClearAllPoints()
        helpBtn:SetPoint("LEFT", modeDropdown, "RIGHT", -8, 2)
        helpBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine("Tracker Display Mode", unpack(COLORS.accent))
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Static - Show window at all times", 0.85, 0.80, 0.70)
            GameTooltip:AddLine("Conditional - Hide window when in party, raid or combat", 0.85, 0.80, 0.70)
            GameTooltip:Show()
        end)
        helpBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        helpBtn:Show()
        table.insert(self.mainFrame.settingsWidgets, helpBtn)

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
            resetBtn:SetBackdropColor(unpack(COLORS.btnBg))
            resetBtn:SetBackdropBorderColor(unpack(COLORS.border))

            local btnText = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            btnText:SetPoint("CENTER", 0, 0)
            btnText:SetText("Reset Data")
            btnText:SetTextColor(1, 1, 1)
            resetBtn.btnText = btnText

            resetBtn:SetScript("OnEnter", function(self)
                self:SetBackdropColor(unpack(COLORS.btnBgHover))
            end)
            resetBtn:SetScript("OnLeave", function(self)
                self:SetBackdropColor(unpack(COLORS.btnBg))
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

        yOffset = yOffset - 40

        -- CD Tracking button
        local trackingBtn = self.mainFrame.settingsTrackingBtn
        if not trackingBtn then
            trackingBtn = CreateFrame("Button", "PrimalLedgerTrackingBtn", content, "BackdropTemplate")
            trackingBtn:SetSize(100, 24)
            trackingBtn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
                insets = { left = 1, right = 1, top = 1, bottom = 1 }
            })
            trackingBtn:SetBackdropColor(COLORS.tabSelectedBg[1], COLORS.tabSelectedBg[2], COLORS.tabSelectedBg[3], 0.9)
            trackingBtn:SetBackdropBorderColor(unpack(COLORS.border))

            local tBtnText = trackingBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            tBtnText:SetPoint("CENTER", 0, 0)
            tBtnText:SetText("CD Tracking")
            tBtnText:SetTextColor(unpack(COLORS.textNormal))
            trackingBtn.btnText = tBtnText

            trackingBtn:SetScript("OnEnter", function(self)
                self:SetBackdropColor(COLORS.separator[1], COLORS.separator[2], COLORS.separator[3], 0.9)
                self.btnText:SetTextColor(unpack(COLORS.accentHover))
            end)
            trackingBtn:SetScript("OnLeave", function(self)
                self:SetBackdropColor(COLORS.tabSelectedBg[1], COLORS.tabSelectedBg[2], COLORS.tabSelectedBg[3], 0.9)
                self.btnText:SetTextColor(unpack(COLORS.textNormal))
            end)
            self.mainFrame.settingsTrackingBtn = trackingBtn
        end
        trackingBtn:ClearAllPoints()
        trackingBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        trackingBtn:SetScript("OnClick", function()
            PL:ShowTrackingWindow()
        end)
        trackingBtn:Show()
        table.insert(self.mainFrame.settingsWidgets, trackingBtn)

        -- Content height for settings
        content:SetHeight(math.abs(yOffset) + 40)
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
            tab.text:SetTextColor(unpack(COLORS.textNormal))
            tab.selectedBg:Show()
            tab.underline:Show()
        else
            tab.isSelected = false
            tab.text:SetTextColor(unpack(COLORS.textDim))
            tab.selectedBg:Hide()
            tab.underline:Hide()
        end
    end

    self.mainFrame.selectedTab = tabIndex

    -- Update content based on selected tab
    self:UpdateMainFrame()
end

-- Tracker window for cooldown countdowns
function PL:CreateTrackerWindow()
    if self.trackerFrame then return end

    local TRACKER_PADDING = 8
    local TRACKER_ROW_HEIGHT = 14

    local frame = CreateFrame("Frame", "PrimalLedgerTracker", UIParent, "BackdropTemplate")
    frame:SetFrameStrata("BACKGROUND")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        local point, _, _, x, y = f:GetPoint()
        PL.db.settings.trackerPosition = { point = point, x = x, y = y }
    end)

    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    frame:SetBackdropColor(0.08, 0.05, 0.03, 0.70)
    frame:SetBackdropBorderColor(0.35, 0.22, 0.10, 0.70)

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", TRACKER_PADDING, -TRACKER_PADDING)
    title:SetText("Primal Ledger")
    title:SetTextColor(unpack(COLORS.accent))

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(12, 12)
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -TRACKER_PADDING + 2, -TRACKER_PADDING + 2)

    local closeBtnText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    closeBtnText:SetPoint("CENTER", 0, 0)
    closeBtnText:SetText("X")
    closeBtnText:SetTextColor(unpack(COLORS.textDim))

    closeBtn:SetScript("OnEnter", function() closeBtnText:SetTextColor(unpack(COLORS.closeHover)) end)
    closeBtn:SetScript("OnLeave", function() closeBtnText:SetTextColor(unpack(COLORS.textDim)) end)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
        PL.trackerManuallyHidden = true
    end)

    -- Store rows for reuse
    frame.rows = {}
    frame.title = title
    frame.padding = TRACKER_PADDING
    frame.rowHeight = TRACKER_ROW_HEIGHT

    self.trackerFrame = frame

    -- Restore saved position or default to top-right
    if self.db.settings.trackerPosition then
        local pos = self.db.settings.trackerPosition
        frame:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)
    else
        frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -200, -200)
    end

    -- Update cooldown text every second
    frame:SetScript("OnUpdate", function(f, elapsed)
        f.elapsed = (f.elapsed or 0) + elapsed
        if f.elapsed < 1 then return end
        f.elapsed = 0
        PL:UpdateTrackerWindow()
    end)

    self:UpdateTrackerWindow()
end

function PL:UpdateTrackerWindow()
    if not self.trackerFrame then return end
    local frame = self.trackerFrame

    local TRACKER_PADDING = frame.padding
    local TRACKER_ROW_HEIGHT = frame.rowHeight

    -- Gather all cooldowns across all characters
    local entries = {}
    local characters = self:GetAllCharacters()

    for _, charInfo in ipairs(characters) do
        if self:HasRelevantProfessions(charInfo.key) then
            local cooldowns = self:GetCharacterCooldowns(charInfo.key)
            for _, cd in ipairs(cooldowns) do
                table.insert(entries, {
                    charName = charInfo.data.name,
                    charClass = charInfo.data.class,
                    craftName = cd.name,
                    remaining = cd.remaining,
                })
            end
        end
    end

    -- Hide all existing rows
    for _, row in ipairs(frame.rows) do
        row:Hide()
    end

    if #entries == 0 then
        frame:SetSize(160, TRACKER_PADDING * 2 + 14)
        -- Show "No tracked cooldowns" message
        local row = frame.rows[1]
        if not row then
            row = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            frame.rows[1] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", TRACKER_PADDING, -(TRACKER_PADDING + 16))
        row:SetText("|cff" .. "998877" .. "No tracked cooldowns|r")
        row:Show()
        return
    end

    -- Build display rows
    local maxTextWidth = 0
    local contentTop = -(TRACKER_PADDING + 16)

    for i, entry in ipairs(entries) do
        local row = frame.rows[i]
        if not row then
            row = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            frame.rows[i] = row
        end

        row:ClearAllPoints()
        local yOffset = contentTop - ((i - 1) * TRACKER_ROW_HEIGHT)
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", TRACKER_PADDING, yOffset)

        local classColor = CLASS_COLORS[entry.charClass] or { r = 1, g = 1, b = 1 }
        local colorCode = string.format("|cff%02x%02x%02x",
            math.floor(classColor.r * 255),
            math.floor(classColor.g * 255),
            math.floor(classColor.b * 255))

        local timeText
        if entry.remaining == nil then
            timeText = "|cff998877Unknown|r"
        elseif entry.remaining <= 0 then
            timeText = "|cff33cc33Available|r"
        else
            timeText = "|cffddcc99" .. self:FormatTimeRemaining(entry.remaining) .. "|r"
        end

        row:SetText(colorCode .. entry.charName .. "|r |cff664d32-|r " .. entry.craftName .. ": " .. timeText)
        row:Show()

        local textWidth = row:GetStringWidth()
        if textWidth > maxTextWidth then
            maxTextWidth = textWidth
        end
    end

    -- Size the frame to fit content
    local frameWidth = maxTextWidth + (TRACKER_PADDING * 2) + 4
    local frameHeight = TRACKER_PADDING + 16 + (#entries * TRACKER_ROW_HEIGHT) + TRACKER_PADDING
    frame:SetSize(math.max(frameWidth, 160), frameHeight)
end

function PL:ShowTrackerWindow()
    if self.db.settings.showTrackerWindow == false then return end
    self.trackerManuallyHidden = false
    self:CreateTrackerWindow()
    self:EvaluateTrackerVisibility()
end

function PL:HideTrackerWindow()
    if self.trackerFrame then
        self.trackerFrame:Hide()
    end
end

function PL:ShouldTrackerBeVisible()
    if self.db.settings.showTrackerWindow == false then return false end
    if self.trackerManuallyHidden then return false end

    local mode = self.db.settings.trackerMode or "static"
    if mode == "conditional" then
        if InCombatLockdown() then return false end
        local groupCount = (GetNumGroupMembers or GetNumRaidMembers or function() return 0 end)()
        local partyCount = (GetNumSubgroupMembers or GetNumPartyMembers or function() return 0 end)()
        if groupCount > 0 or partyCount > 0 then return false end
    end

    return true
end

function PL:EvaluateTrackerVisibility()
    if not self.trackerFrame then return end
    if self:ShouldTrackerBeVisible() then
        self.trackerFrame:Show()
    else
        self.trackerFrame:Hide()
    end
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

-- CD Tracking standalone window
function PL:ShowTrackingWindow()
    if self.trackingFrame then
        self.trackingFrame:Show()
        self:UpdateTrackingWindow()
        return
    end

    local TRACK_PADDING = 12

    local frame = CreateFrame("Frame", "PrimalLedgerTrackingFrame", UIParent, "BackdropTemplate")
    frame:SetSize(250, 400)
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
    frame:SetBackdropColor(unpack(COLORS.bg))
    frame:SetBackdropBorderColor(unpack(COLORS.border))

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", TRACK_PADDING, -TRACK_PADDING)
    title:SetText("CD Tracking")
    title:SetTextColor(unpack(COLORS.accent))

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(16, 16)
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -TRACK_PADDING, -TRACK_PADDING)
    local closeBtnText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeBtnText:SetPoint("CENTER", 0, 0)
    closeBtnText:SetText("X")
    closeBtnText:SetTextColor(unpack(COLORS.textDim))
    closeBtn:SetScript("OnEnter", function() closeBtnText:SetTextColor(unpack(COLORS.closeHover)) end)
    closeBtn:SetScript("OnLeave", function() closeBtnText:SetTextColor(unpack(COLORS.textDim)) end)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Separator
    local sep = frame:CreateTexture(nil, "ARTWORK")
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", frame, "TOPLEFT", TRACK_PADDING, -(TRACK_PADDING + 20))
    sep:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -TRACK_PADDING, -(TRACK_PADDING + 20))
    sep:SetColorTexture(unpack(COLORS.separator))

    -- Scroll frame for content
    local scrollFrame = CreateFrame("ScrollFrame", "PrimalLedgerTrackingScroll", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", TRACK_PADDING, -(TRACK_PADDING + 24))
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -TRACK_PADDING - 20, TRACK_PADDING)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(scrollFrame:GetWidth())
    content:SetHeight(1)
    scrollFrame:SetScrollChild(content)

    frame.content = content
    frame.checkboxes = {}
    self.trackingFrame = frame

    self:UpdateTrackingWindow()
end

function PL:UpdateTrackingWindow()
    if not self.trackingFrame then return end

    local content = self.trackingFrame.content
    local TRACK_PADDING = 12

    -- Clear old checkboxes
    if self.trackingFrame.checkboxes then
        for _, widget in pairs(self.trackingFrame.checkboxes) do
            widget:Hide()
        end
    end
    self.trackingFrame.checkboxes = {}

    local yOffset = 0

    -- Helper to create a profession section
    local function CreateSection(profName, profKey)
        local header = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        header:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        header:SetText(profName)
        header:SetTextColor(unpack(COLORS.accent))
        header:Show()
        table.insert(self.trackingFrame.checkboxes, header)

        yOffset = yOffset - 20

        for _, cdType in ipairs(self.PROFESSION_COOLDOWNS[profKey]) do
            local cb = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
            cb:SetSize(24, 24)
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
            table.insert(self.trackingFrame.checkboxes, cb)

            local label = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
            label:SetText(self.COOLDOWN_NAMES[cdType])
            label:SetTextColor(unpack(COLORS.textNormal))
            label:Show()
            table.insert(self.trackingFrame.checkboxes, label)

            yOffset = yOffset - 24
        end

        yOffset = yOffset - 8
    end

    CreateSection("Tailoring", "tailoring")
    CreateSection("Alchemy", "alchemy")

    content:SetHeight(math.abs(yOffset) + 10)
end

-- Helper: create a styled button on a profession frame
local function CreateProfFrameExportButton(parent, globalName, onClick)
    local btn = CreateFrame("Button", globalName, parent, "BackdropTemplate")
    btn:SetSize(60, 22)
    btn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -60, -4)
    btn:SetFrameStrata("HIGH")
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    btn:SetBackdropColor(COLORS.bg[1], COLORS.bg[2], COLORS.bg[3], 0.9)
    btn:SetBackdropBorderColor(unpack(COLORS.border))

    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btnText:SetPoint("CENTER", 0, 0)
    btnText:SetText("Export")
    btnText:SetTextColor(unpack(COLORS.textNormal))

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(COLORS.tabSelectedBg[1], COLORS.tabSelectedBg[2], COLORS.tabSelectedBg[3], 0.9)
        btnText:SetTextColor(unpack(COLORS.accentHover))
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(COLORS.bg[1], COLORS.bg[2], COLORS.bg[3], 0.9)
        btnText:SetTextColor(unpack(COLORS.textNormal))
    end)
    btn:SetScript("OnClick", onClick)
    return btn
end

-- Export button on the TradeSkill frame
function PL:CreateExportButton()
    if self.exportBtn then return end
    if not TradeSkillFrame then return end
    self.exportBtn = CreateProfFrameExportButton(TradeSkillFrame, "PrimalLedgerExportBtn", function()
        PL:ShowExportSelectionWindow("tradeskill")
    end)
end

-- Export button for the Craft frame (Enchanting)
function PL:CreateCraftExportButton()
    if self.craftExportBtn then return end
    if not CraftFrame then return end
    self.craftExportBtn = CreateProfFrameExportButton(CraftFrame, "PrimalLedgerCraftExportBtn", function()
        PL:ShowExportSelectionWindow("craft")
    end)
end

-- Gather crafts from the currently open profession window
-- Returns: professionName, list of { index, name, header (string or nil) }
function PL:GetOpenProfessionCrafts(source)
    local crafts = {}

    if source == "craft" then
        local numCrafts = GetNumCrafts()
        if not numCrafts or numCrafts == 0 then return nil, nil end
        local profName = GetCraftDisplaySkillLine()
        if not profName then return nil, nil end

        local currentHeader = nil
        for i = 1, numCrafts do
            local name, _, craftType = GetCraftInfo(i)
            if name then
                if craftType == "header" then
                    currentHeader = name
                elseif craftType ~= "subheader" then
                    table.insert(crafts, { index = i, name = name, header = currentHeader })
                end
            end
        end
        return profName, crafts
    else
        local numSkills = GetNumTradeSkills()
        if not numSkills or numSkills == 0 then return nil, nil end
        local profName = GetTradeSkillLine()
        if not profName then return nil, nil end

        local currentHeader = nil
        for i = 1, numSkills do
            local name, skillType = GetTradeSkillInfo(i)
            if name then
                if skillType == "header" then
                    currentHeader = name
                elseif skillType ~= "subheader" then
                    table.insert(crafts, { index = i, name = name, header = currentHeader })
                end
            end
        end
        return profName, crafts
    end
end

-- Step 1: Show selection window with checkboxes for each craft
function PL:ShowExportSelectionWindow(source)
    local profName, crafts = self:GetOpenProfessionCrafts(source)
    if not profName or not crafts or #crafts == 0 then
        self:Print("No profession window open.")
        return
    end

    -- Hide text window if open
    if self.exportTextFrame then self.exportTextFrame:Hide() end

    local EXP_PADDING = 10

    -- Reuse or create selection frame
    if not self.exportSelFrame then
        local frame = CreateFrame("Frame", "PrimalLedgerExportSelFrame", UIParent, "BackdropTemplate")
        frame:SetSize(350, 420)
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
        frame:SetBackdropColor(unpack(COLORS.bg))
        frame:SetBackdropBorderColor(unpack(COLORS.border))

        -- Title
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", EXP_PADDING, -EXP_PADDING)
        frame.title:SetTextColor(unpack(COLORS.accent))

        -- Close button
        local closeBtn = CreateFrame("Button", nil, frame)
        closeBtn:SetSize(16, 16)
        closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -EXP_PADDING, -EXP_PADDING)
        local closeBtnText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        closeBtnText:SetPoint("CENTER", 0, 0)
        closeBtnText:SetText("X")
        closeBtnText:SetTextColor(unpack(COLORS.textDim))
        closeBtn:SetScript("OnEnter", function() closeBtnText:SetTextColor(unpack(COLORS.closeHover)) end)
        closeBtn:SetScript("OnLeave", function() closeBtnText:SetTextColor(unpack(COLORS.textDim)) end)
        closeBtn:SetScript("OnClick", function() frame:Hide() end)

        -- Separator
        local sep = frame:CreateTexture(nil, "ARTWORK")
        sep:SetHeight(1)
        sep:SetPoint("TOPLEFT", frame, "TOPLEFT", EXP_PADDING, -(EXP_PADDING + 20))
        sep:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -EXP_PADDING, -(EXP_PADDING + 20))
        sep:SetColorTexture(unpack(COLORS.separator))

        -- Scroll frame
        local scrollFrame = CreateFrame("ScrollFrame", "PrimalLedgerExportSelScroll", frame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", EXP_PADDING, -(EXP_PADDING + 24))
        scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -EXP_PADDING - 20, EXP_PADDING + 30)

        local content = CreateFrame("Frame", nil, scrollFrame)
        content:SetWidth(scrollFrame:GetWidth())
        content:SetHeight(1)
        scrollFrame:SetScrollChild(content)

        frame.scrollFrame = scrollFrame
        frame.content = content

        -- Export button (bottom-right, static)
        local exportBtn = CreateFrame("Button", nil, frame, "BackdropTemplate")
        exportBtn:SetSize(80, 24)
        exportBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -EXP_PADDING, EXP_PADDING)
        exportBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })
        exportBtn:SetBackdropColor(COLORS.tabSelectedBg[1], COLORS.tabSelectedBg[2], COLORS.tabSelectedBg[3], 0.9)
        exportBtn:SetBackdropBorderColor(unpack(COLORS.border))

        local eBtnText = exportBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        eBtnText:SetPoint("CENTER", 0, 0)
        eBtnText:SetText("Export")
        eBtnText:SetTextColor(unpack(COLORS.textNormal))

        exportBtn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(COLORS.separator[1], COLORS.separator[2], COLORS.separator[3], 0.9)
            eBtnText:SetTextColor(unpack(COLORS.accentHover))
        end)
        exportBtn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(COLORS.tabSelectedBg[1], COLORS.tabSelectedBg[2], COLORS.tabSelectedBg[3], 0.9)
            eBtnText:SetTextColor(unpack(COLORS.textNormal))
        end)
        exportBtn:SetScript("OnClick", function()
            PL:ExportSelectedCrafts()
        end)

        frame.widgets = {}
        self.exportSelFrame = frame
    end

    local frame = self.exportSelFrame
    local content = frame.content

    -- Clear old widgets
    for _, widget in pairs(frame.widgets) do
        widget:Hide()
    end
    frame.widgets = {}
    frame.craftCheckboxes = {}

    frame.title:SetText("Export - " .. profName)
    frame.profName = profName

    local yOffset = 0
    local lastHeader = nil

    for _, craft in ipairs(crafts) do
        -- Show header if new category
        if craft.header and craft.header ~= lastHeader then
            if lastHeader then
                yOffset = yOffset - 4
            end
            local header = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            header:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
            header:SetText(craft.header)
            header:SetTextColor(unpack(COLORS.accent))
            header:Show()
            table.insert(frame.widgets, header)
            lastHeader = craft.header
            yOffset = yOffset - 18
        end

        local cb = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        cb:SetSize(24, 24)
        cb:SetPoint("TOPLEFT", content, "TOPLEFT", 4, yOffset)
        cb:SetChecked(true)
        cb:Show()
        table.insert(frame.widgets, cb)

        local label = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        label:SetText(craft.name)
        label:SetTextColor(unpack(COLORS.textNormal))
        label:Show()
        table.insert(frame.widgets, label)

        table.insert(frame.craftCheckboxes, { cb = cb, name = craft.name, header = craft.header })

        yOffset = yOffset - 24
    end

    content:SetHeight(math.abs(yOffset) + 10)
    frame:Show()
end

-- Step 2: Build text from selected crafts and show text window
function PL:ExportSelectedCrafts()
    if not self.exportSelFrame or not self.exportSelFrame.craftCheckboxes then return end

    local playerName = UnitName("player")
    local profName = self.exportSelFrame.profName or "Unknown"
    local lines = {}

    table.insert(lines, "**" .. playerName .. " - " .. profName .. "**")
    table.insert(lines, "```")

    local lastHeader = nil
    for _, entry in ipairs(self.exportSelFrame.craftCheckboxes) do
        if entry.cb:GetChecked() then
            if entry.header and entry.header ~= lastHeader then
                if lastHeader then
                    table.insert(lines, "")
                end
                table.insert(lines, "[ " .. entry.header .. " ]")
                lastHeader = entry.header
            end
            table.insert(lines, "  " .. entry.name)
        end
    end

    table.insert(lines, "```")

    local exportText = table.concat(lines, "\n")

    -- Hide selection window
    self.exportSelFrame:Hide()

    -- Show text window
    self:ShowExportTextWindow(exportText)
end

-- Show the final copyable export text window
function PL:ShowExportTextWindow(exportText)
    if not self.exportTextFrame then
        local frame = CreateFrame("Frame", "PrimalLedgerExportTextFrame", UIParent, "BackdropTemplate")
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
        frame:SetBackdropColor(unpack(COLORS.bg))
        frame:SetBackdropBorderColor(unpack(COLORS.border))

        -- Title
        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
        title:SetText("Export Crafts")
        title:SetTextColor(unpack(COLORS.accent))

        -- Close button
        local closeBtn = CreateFrame("Button", nil, frame)
        closeBtn:SetSize(16, 16)
        closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)
        local closeBtnText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        closeBtnText:SetPoint("CENTER", 0, 0)
        closeBtnText:SetText("X")
        closeBtnText:SetTextColor(unpack(COLORS.textDim))
        closeBtn:SetScript("OnEnter", function() closeBtnText:SetTextColor(unpack(COLORS.closeHover)) end)
        closeBtn:SetScript("OnLeave", function() closeBtnText:SetTextColor(unpack(COLORS.textDim)) end)
        closeBtn:SetScript("OnClick", function() frame:Hide() end)

        -- Hint text
        local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        hint:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
        hint:SetText("Press Ctrl+A to select all, then Ctrl+C to copy")
        hint:SetTextColor(unpack(COLORS.textFaint))

        -- Scroll frame for the edit box
        local scrollFrame = CreateFrame("ScrollFrame", "PrimalLedgerExportTextScroll", frame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -48)
        scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)

        local editBox = CreateFrame("EditBox", "PrimalLedgerExportTextEditBox", scrollFrame)
        editBox:SetMultiLine(true)
        editBox:SetAutoFocus(false)
        editBox:SetFontObject(GameFontHighlightSmall)
        editBox:SetWidth(scrollFrame:GetWidth())
        editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        editBox:SetScript("OnChar", function(self) self:SetText(PL.exportTextFrame.currentText or "") end)
        editBox:SetScript("OnTextChanged", function(self, userInput)
            if userInput then
                self:SetText(PL.exportTextFrame.currentText or "")
            end
        end)

        scrollFrame:SetScrollChild(editBox)

        frame.editBox = editBox
        self.exportTextFrame = frame
    end

    self.exportTextFrame.currentText = exportText
    self.exportTextFrame.editBox:SetText(exportText)
    self.exportTextFrame.editBox:SetWidth(self.exportTextFrame:GetWidth() - 40)
    self.exportTextFrame:Show()
    self.exportTextFrame.editBox:HighlightText()
    self.exportTextFrame.editBox:SetFocus()
end
