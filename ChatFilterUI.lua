-- ChatFilter UI - Using aux-inspired styling
local ChatFilterUI = {}

-- Color definitions based on aux addon style
local colors = {
    text = {enabled = {255/255, 254/255, 250/255, 1}, disabled = {147/255, 151/255, 139/255, 1}},
    label = {enabled = {216/255, 225/255, 211/255, 1}, disabled = {150/255, 148/255, 140/255, 1}},
    window = {background = {24/255, 24/255, 24/255, 0.93}, border = {30/255, 30/255, 30/255, 1}},
    panel = {background = {24/255, 24/255, 24/255, 1}, border = {255/255, 255/255, 255/255, 0.03}},
    content = {background = {42/255, 42/255, 42/255, 1}, border = {0, 0, 0, 0}},
    state = {enabled = {70/255, 140/255, 70/255, 1}, disabled = {140/255, 70/255, 70/255, 1}},
}

-- Font settings (aux uses ARIALN.TTF)
local font = "Fonts\\ARIALN.TTF"
local font_size = {
    small = 13,
    medium = 15,
    large = 18,
}

-- Helper functions for styling frames
local function set_frame_style(frame, backdrop_color, border_color, left, right, top, bottom)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8", 
        edgeFile = "Interface\\Buttons\\WHITE8X8", 
        edgeSize = 1.5, 
        tile = true, 
        insets = {left = left or 0, right = right or 0, top = top or 0, bottom = bottom or 0}
    })
    frame:SetBackdropColor(unpack(backdrop_color))
    frame:SetBackdropBorderColor(unpack(border_color))
end

local function set_window_style(frame, left, right, top, bottom)
    set_frame_style(frame, colors.window.background, colors.window.border, left, right, top, bottom)
end

local function set_panel_style(frame, left, right, top, bottom)
    set_frame_style(frame, colors.panel.background, colors.panel.border, left, right, top, bottom)
end

local function set_content_style(frame, left, right, top, bottom)
    set_frame_style(frame, colors.content.background, colors.content.border, left, right, top, bottom)
end

-- Create main frame
local function create_main_frame()
    local frame = CreateFrame("Frame", "ChatFilterFrame", UIParent)
    tinsert(UISpecialFrames, "ChatFilterFrame")
    set_window_style(frame)
    
    frame:SetWidth(500)
    frame:SetHeight(400)
    frame:SetPoint("CENTER", 0, 0)
    frame:SetToplevel(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:CreateTitleRegion():SetAllPoints()
    
    -- Content area
    frame.content = CreateFrame("Frame", nil, frame)
    frame.content:SetPoint("TOPLEFT", 4, -25)
    frame.content:SetPoint("BOTTOMRIGHT", -4, 35)
    
    frame:Hide()
    return frame
end

-- Create aux-style button
local function create_button(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width or 80)
    button:SetHeight(height or 24)
    set_content_style(button)
    
    -- Highlight texture
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetTexture(1, 1, 1, 0.2)
    
    -- Button text
    local label = button:CreateFontString()
    label:SetFont(font, font_size.large)
    label:SetAllPoints(button)
    label:SetJustifyH("CENTER")
    label:SetJustifyV("CENTER")
    label:SetTextColor(unpack(colors.text.enabled))
    button:SetFontString(label)
    button:SetText(text or "Button")
    
    -- Enable/disable functionality
    button.default_Enable = button.Enable
    function button:Enable()
        if self:IsEnabled() == 1 then return end
        self:GetFontString():SetTextColor(unpack(colors.text.enabled))
        return self:default_Enable()
    end
    
    button.default_Disable = button.Disable
    function button:Disable()
        if self:IsEnabled() == 0 then return end
        self:GetFontString():SetTextColor(unpack(colors.text.disabled))
        return self:default_Disable()
    end
    
    return button
end

-- Create aux-style editbox
local function create_editbox(parent, width, height)
    local editbox = CreateFrame("EditBox", nil, parent)
    editbox:SetAutoFocus(false)
    editbox:SetTextInsets(6, 6, 3, 3)
    editbox:SetMaxLetters(nil)
    editbox:SetWidth(width or 200)
    editbox:SetHeight(height or 24)
    editbox:SetTextColor(0, 0, 0, 0)
    set_content_style(editbox)
    
    -- Overlay text (visible text)
    local overlay = editbox:CreateFontString()
    overlay:SetPoint("LEFT", 6, 0)
    overlay:SetPoint("RIGHT", -6, 0)
    overlay:SetFont(font, font_size.medium)
    overlay:SetTextColor(unpack(colors.text.enabled))
    overlay:SetJustifyH("LEFT")
    editbox.overlay = overlay
    
    -- Focus handling
    editbox:SetScript("OnEditFocusGained", function()
        this.overlay:Hide()
        this:SetTextColor(unpack(colors.text.enabled))
        this:HighlightText()
    end)
    
    editbox:SetScript("OnEditFocusLost", function()
        this.overlay:Show()
        this:SetTextColor(0, 0, 0, 0)
        this:HighlightText(0, 0)
    end)
    
    editbox:SetScript("OnTextChanged", function()
        this.overlay:SetText(this:GetText())
    end)
    
    editbox:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)
    
    return editbox
end

-- Create aux-style label
local function create_label(parent, text, size)
    local label = parent:CreateFontString()
    label:SetFont(font, size or font_size.small)
    label:SetTextColor(unpack(colors.label.enabled))
    label:SetText(text or "Label")
    return label
end

-- Create aux-style checkbox
local function create_checkbox(parent)
    local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    checkbox:SetWidth(16)
    checkbox:SetHeight(16)
    set_content_style(checkbox)
    checkbox:SetNormalTexture(nil)
    checkbox:SetPushedTexture(nil)
    checkbox:GetHighlightTexture():SetAllPoints()
    checkbox:GetHighlightTexture():SetTexture(1, 1, 1, 0.2)
    checkbox:GetCheckedTexture():SetTexCoord(0.12, 0.88, 0.12, 0.88)
    return checkbox
end

-- Create minimap button with aux styling
local function create_minimap_button()
    local button = CreateFrame("Button", "ChatFilterMinimapButton", Minimap)
    button:SetWidth(32)
    button:SetHeight(32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:SetClampedToScreen(true)
    button:RegisterForDrag("LeftButton")
    button:SetMovable(true)
    
    -- Button background with aux style
    set_content_style(button, 2, 2, 2, 2)
    
    -- Icon texture
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(20)
    icon:SetHeight(20)
    icon:SetPoint("CENTER", 0, 0)
    icon:SetTexture("Interface\\Icons\\INV_Letter_18")
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    button.icon = icon
    
    -- Highlight texture
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetTexture(1, 1, 1, 0.3)
    
    -- Position on minimap
    button:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52, -52)
    
    -- Click handler
    button:SetScript("OnClick", function()
        if ChatFilterUI.mainFrame and ChatFilterUI.mainFrame:IsVisible() then
            ChatFilterUI:Hide()
        else
            ChatFilterUI:Show()
        end
    end)
    
    -- Drag functionality
    button:SetScript("OnDragStart", function()
        this:StartMoving()
    end)
    
    button:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
    end)
    
    -- Tooltip
    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT")
        GameTooltip:SetText("ChatFilter", 1, 1, 1)
        GameTooltip:AddLine("Left-click to toggle configuration", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Drag to move button", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    return button
end

-- Initialize the UI
function ChatFilterUI:Initialize()
    self.mainFrame = create_main_frame()
    
    -- Create minimap button
    self.minimapButton = create_minimap_button()
    
    -- Title
    local title = create_label(self.mainFrame, "ChatFilter Configuration", font_size.large)
    title:SetPoint("TOP", self.mainFrame, "TOP", 0, -8)
    
    -- Filter list area
    local filterListFrame = CreateFrame("Frame", nil, self.mainFrame.content)
    set_panel_style(filterListFrame)
    filterListFrame:SetPoint("TOPLEFT", 10, -10)
    filterListFrame:SetPoint("BOTTOMRIGHT", -10, 80)
    
    -- Filter list title
    local listTitle = create_label(filterListFrame, "Active Filters:", font_size.medium)
    listTitle:SetPoint("TOPLEFT", filterListFrame, "TOPLEFT", 8, -8)
    
    -- Add filter section
    local addFilterFrame = CreateFrame("Frame", nil, self.mainFrame.content)
    set_panel_style(addFilterFrame)
    addFilterFrame:SetPoint("BOTTOMLEFT", 10, 10)
    addFilterFrame:SetPoint("BOTTOMRIGHT", -10, -5)
    addFilterFrame:SetHeight(60)
    
    local addTitle = create_label(addFilterFrame, "Add New Filter:", font_size.medium)
    addTitle:SetPoint("TOPLEFT", addFilterFrame, "TOPLEFT", 8, -8)
    
    -- Pattern input
    local patternLabel = create_label(addFilterFrame, "Pattern:", font_size.small)
    patternLabel:SetPoint("TOPLEFT", addFilterFrame, "TOPLEFT", 8, -28)
    
    local patternInput = create_editbox(addFilterFrame, 200, 20)
    patternInput:SetPoint("LEFT", patternLabel, "RIGHT", 10, 0)
    
    -- Add button
    local addButton = create_button(addFilterFrame, "Add Filter", 80, 20)
    addButton:SetPoint("LEFT", patternInput, "RIGHT", 10, 0)
    
    -- Close button
    local closeButton = create_button(self.mainFrame, "Close", 60, 24)
    closeButton:SetPoint("BOTTOMRIGHT", -5, 5)
    closeButton:SetScript("OnClick", function() 
        ChatFilterUI.mainFrame:Hide() 
    end)
    
    -- Store references
    self.filterListFrame = filterListFrame
    self.patternInput = patternInput
    self.addButton = addButton
end

-- Show the UI
function ChatFilterUI:Show()
    if not self.mainFrame then
        self:Initialize()
    end
    self.mainFrame:Show()
end

-- Hide the UI
function ChatFilterUI:Hide()
    if self.mainFrame then
        self.mainFrame:Hide()
    end
end


DEFAULT_CHAT_FRAME:AddMessage("Your message here")

-- Method 2: Create your own print function
local function print(...)
    local msg = ""
    for i = 1, arg.n do
        if i > 1 then msg = msg .. "\t" end
        msg = msg .. tostring(arg[i])
    end
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

-- Now you can use print() normally
print("Hello", "World", 123)
-- Make globally accessible (WoW Classic 1.12 compatible)
print("ChatFilterUI initialized. Use /chatfilter to open the configuration.")
ChatFilterUI = ChatFilterUI