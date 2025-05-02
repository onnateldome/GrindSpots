-- Create the main frame
local GrindSpotsFrame = CreateFrame("Frame", "GrindSpotsFrame", UIParent)
GrindSpotsFrame:SetWidth(400)
GrindSpotsFrame:SetHeight(150)
GrindSpotsFrame:SetPoint("TOP", UIParent, "TOP", 0, -10)
GrindSpotsFrame:SetMovable(true)
GrindSpotsFrame:EnableMouse(true)
GrindSpotsFrame:RegisterForDrag("LeftButton")
GrindSpotsFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
GrindSpotsFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- Set a simple background color using a texture
local bgTexture = GrindSpotsFrame:CreateTexture(nil, "BACKGROUND")
bgTexture:SetAllPoints(GrindSpotsFrame)
bgTexture:SetTexture(0, 0, 0, 0.5) -- RGBA: black with 50% opacity

-- Create a FontString for displaying text
local GrindSpotsText = GrindSpotsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindSpotsText:SetPoint("TOPLEFT", 10, -40)
GrindSpotsText:SetPoint("BOTTOMRIGHT", -10, 10)
GrindSpotsText:SetJustifyH("LEFT")
GrindSpotsText:SetJustifyV("TOP")

-- Table to store tabs
local tabs = {}
local selectedTabIndex = nil

-- Function to update grind spot information for the selected tab
local function UpdateGrindSpotsInfo(spots)
    local lines = {}

   if spots and next(spots) then
        table.insert(lines, string.format("Grind Spot Information:\n"))

        -- Loop through each matching grind spot and display its details
        for _, spot in ipairs(spots) do
            local line = string.format(
                    "Levels: [%d - %d]\n" ..
    "Zone: %s\n" ..
    "Location: %s\n" ..
    "Mobs: %s\n" ..
    "XP: %s\n" ..
    "Notes: %s",
                spot.minLevel or 0,
                spot.maxLevel or 0,
                spot.zone or "N/A",
                spot.location or "N/A",
                spot.mobs or "N/A",
                spot.xp or "N/A",
                spot.notes or "N/A"
            )
            table.insert(lines, line)
        end

        GrindSpotsText:SetText(table.concat(lines, "\n"))
    else
        GrindSpotsText:SetText("No grind spots found for this level range.")
    end
end

-- Function to create tabs for each unique level range
local function CreateTabs()
    -- First, find all unique level ranges based on matching spots
    local playerLevel = UnitLevel("player")
    local levelRanges = {}

    -- Group grind spots by their min and max level
    for _, spot in ipairs(GrindSpotsData) do
        if playerLevel >= spot.minLevel and playerLevel <= spot.maxLevel then
            local levelRange = string.format("%d - %d", spot.minLevel, spot.maxLevel)
            
            if not levelRanges[levelRange] then
                levelRanges[levelRange] = {}
            end
            table.insert(levelRanges[levelRange], spot)
        end
    end

    -- Now create a tab for each unique level range
    local tabIndex = 1
    for levelRange, spots in pairs(levelRanges) do
        -- Create a tab for the level range
        local tabButton = CreateFrame("Button", nil, GrindSpotsFrame, "OptionsButtonTemplate")
        tabButton:SetWidth(80)
        tabButton:SetHeight(20)
        tabButton:SetPoint("TOPLEFT", GrindSpotsFrame, "TOPLEFT", (tabIndex - 1) * 90 + 10, -10)
        tabButton:SetText(levelRange)

        -- Store the grind spot data for the level range in the button
        tabButton.spots = spots  -- Store the matching spots directly on the button

        -- On click, update the selected tab and display the relevant info for the selected level range
        tabButton:SetScript("OnClick", function()
            -- When a tab is clicked, we directly use the stored spots data
            UpdateGrindSpotsInfo(tabButton.spots)

            -- Update the tab button colors to highlight the selected tab
            for i, tab in ipairs(tabs) do
                if tab == tabButton then
                    tabButton:SetBackdropColor(0.5, 0.5, 1)  -- Highlight selected tab
                else
                    tab:SetBackdropColor(0.2, 0.2, 0.2)  -- Default tab color
                end
            end
        end)

        -- Store the tab reference for later
        tabs[tabIndex] = tabButton
        tabIndex = tabIndex + 1
    end
    tabs[1]:Click()
end


-- Event handling
GrindSpotsFrame:RegisterEvent("PLAYER_LOGIN")
GrindSpotsFrame:RegisterEvent("PLAYER_XP_UPDATE")
GrindSpotsFrame:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" or event == "PLAYER_XP_UPDATE" then
        CreateTabs()
    end
end)


-- Toggle Button
local toggleButton = CreateFrame("Button", nil, GrindSpotsFrame, "UIPanelButtonTemplate")
toggleButton:SetWidth(20)
toggleButton:SetHeight(20)
toggleButton:SetPoint("TOPRIGHT", GrindSpotsFrame, "TOPRIGHT", -5, -5)
toggleButton:SetText("-")

-- Toggle logic
local isCollapsed = false
toggleButton:SetScript("OnClick", function()
    if isCollapsed then
        toggleButton:SetText("-")
        GrindSpotsFrame:SetHeight(150)
    else
        GrindSpotsFrame:SetHeight(40)
        toggleButton:SetText("+")
    end
    isCollapsed = not isCollapsed
end)