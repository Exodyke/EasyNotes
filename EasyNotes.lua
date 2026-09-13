local frame = CreateFrame("Frame", "EasyNotesFrame", UIParent)
frame:SetSize(400, 480)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG")
frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
})
frame:SetBackdropColor(0, 0, 0, 1)
frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()
tinsert(UISpecialFrames, "EasyNotesFrame")

local border = CreateFrame("Frame", nil, frame)
border:SetPoint("TOPLEFT", 8, -32)
border:SetPoint("BOTTOMRIGHT", -8, 40)
border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
border:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

local scrollFrame = CreateFrame("ScrollFrame", "EasyNotesScroll", frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", border, "TOPLEFT", 5, -5)
scrollFrame:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -25, 5)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(350, 1)
scrollFrame:SetScrollChild(content)

local editBox = CreateFrame("EditBox", nil, content)
editBox:SetMultiLine(true); editBox:SetMaxLetters(99999); editBox:SetWidth(350); editBox:SetPoint("TOPLEFT")
editBox:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE"); editBox:SetAutoFocus(false)

local clickShield = CreateFrame("Button", nil, border)
clickShield:SetAllPoints()
clickShield:SetScript("OnClick", function() editBox:SetFocus() end)
clickShield:SetFrameLevel(border:GetFrameLevel() + 1)
editBox:SetFrameLevel(clickShield:GetFrameLevel() + 1)

local clock = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
clock:SetPoint("TOPLEFT", 10, -7)
clock:SetTextColor(1, 1, 1, 1)

local autoSaveTxt = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
autoSaveTxt:SetPoint("LEFT", clock, "RIGHT", 10, 0)
autoSaveTxt:SetTextColor(0, 1, 0, 1)
autoSaveTxt:SetText("Автосохранение")
autoSaveTxt:SetAlpha(0)

local function ToggleEasyNotes()
    if frame:IsShown() then
        PlaySound("igQuestLogClose")
        frame:Hide()
    else
        PlaySound("igQuestLogOpen") 
        frame:Show()
    end
end

frame:SetScript("OnHide", function()
    PlaySound("igQuestLogClose")
end)

frame:SetScript("OnUpdate", function(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    if self.timer > 1 then clock:SetText(date("%d.%m.%Y %H:%M:%S")) self.timer = 0 end
    
    if autoSaveTxt:GetAlpha() > 0 then
        local alpha = max(0, autoSaveTxt:GetAlpha() - (elapsed / 5))
        autoSaveTxt:SetAlpha(alpha)
        local r = 0.5 * (1 - alpha); local g = 1 * alpha + 0.5 * (1 - alpha); local b = 0.5 * (1 - alpha)
        frame:SetBackdropBorderColor(r, g, b, 1)
    end

    self.autoSaveTimer = (self.autoSaveTimer or 0) + elapsed
    if self.autoSaveTimer > 60 then
        if editBox then 
            EasyNotesDB = editBox:GetText()
            frame:SetBackdropBorderColor(0, 1, 0, 1)
            autoSaveTxt:SetAlpha(1)
        end
        self.autoSaveTimer = 0
    end
end)

editBox:SetScript("OnEscapePressed", function(self) 
    EasyNotesDB = self:GetText(); 
    self:ClearFocus(); 
    PlaySound("igMainMenuOptionCheckBoxOn") 
end)

editBox:SetScript("OnCursorChanged", function(self, x, y, w, h)
    local scrollHeight = scrollFrame:GetHeight()
    local cursorOffset = -y
    local currentScroll = scrollFrame:GetVerticalScroll()
    if cursorOffset < currentScroll then scrollFrame:SetVerticalScroll(cursorOffset)
    elseif cursorOffset + h > currentScroll + scrollHeight then scrollFrame:SetVerticalScroll(cursorOffset + h - scrollHeight) end
end)
editBox:SetScript("OnTextChanged", function(self) content:SetHeight(self:GetHeight() + 50) end)

local searchBorder = CreateFrame("Frame", nil, frame)
searchBorder:SetSize(384, 24); searchBorder:SetPoint("BOTTOM", 0, 10)
searchBorder:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
searchBorder:SetBackdropColor(0.1, 0.1, 0.1, 1); searchBorder:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

local searchBox = CreateFrame("EditBox", nil, searchBorder)
searchBox:SetPoint("TOPLEFT", 5, 0); searchBox:SetPoint("BOTTOMRIGHT", -25, 0)
searchBox:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE"); searchBox:SetAutoFocus(false)
searchBox:SetText("Поиск в блокноте"); searchBox:SetTextColor(0.6, 0.6, 0.6)

local clearSearch = CreateFrame("Button", nil, searchBorder)
clearSearch:SetSize(16, 16); clearSearch:SetPoint("RIGHT", -4, 0)
clearSearch:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"}); clearSearch:SetBackdropColor(0.3, 0.3, 0.3, 1)
local clearTxt = clearSearch:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
clearTxt:SetPoint("CENTER", 0, 0); clearTxt:SetText("x"); clearTxt:SetTextColor(0.8, 0.8, 0.8)
clearSearch:SetScript("OnClick", function() searchBox:SetText(""); searchBox:SetTextColor(1, 1, 1); searchBox:ClearFocus(); PlaySound("igMainMenuOptionCheckBoxOn") end)

searchBox:SetScript("OnEditFocusGained", function(self) if self:GetText() == "Поиск в блокноте" then self:SetText("") self:SetTextColor(1, 1, 1) end end)
searchBox:SetScript("OnEditFocusLost", function(self) if self:GetText() == "" then self:SetText("Поиск в блокноте") self:SetTextColor(0.6, 0.6, 0.6) end end)
searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
searchBox:SetScript("OnEnterPressed", function(self)
    local q = self:GetText():lower(); local t = editBox:GetText():lower()
    if q ~= "" and q ~= "Поиск в блокноте" then
        local p = t:find(q, 1, true)
        if p then editBox:SetFocus(); editBox:SetCursorPosition(p - 1); PlaySound("igQuestLogOpen") else print("|cffff0000EasyNotes: Not found|r") end
    end
    self:ClearFocus()
end)

local close = CreateFrame("Button", nil, frame)
close:SetSize(20, 20); close:SetPoint("TOPRIGHT", -5, -5)
close:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"}); close:SetBackdropColor(0.4, 0.4, 0.4, 1)
close:SetScript("OnClick", ToggleEasyNotes)

local save = CreateFrame("Button", nil, frame)
save:SetSize(20, 20); save:SetPoint("RIGHT", close, "LEFT", -5, 0)
save:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"}); save:SetBackdropColor(0, 0.6, 0, 1)
save:SetScript("OnClick", function() EasyNotesDB = editBox:GetText(); editBox:ClearFocus(); PlaySound("igMainMenuOptionCheckBoxOn"); print("|cff00ff00EasyNotes: Сохранено!|r") end)

local separator = CreateFrame("Button", nil, frame)
separator:SetSize(20, 20); separator:SetPoint("RIGHT", save, "LEFT", -5, 0)
separator:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"}); separator:SetBackdropColor(0, 0.8, 1, 1)
separator:SetScript("OnClick", function()
    PlaySound("igMainMenuOptionCheckBoxOn")
    if IsControlKeyDown() then
        scrollFrame:SetVerticalScroll(scrollFrame:GetVerticalScrollRange())
    else
        editBox:SetText(editBox:GetText() .. "\n|cff00ccff---------------------------------------------------------|r\n")
        editBox:SetCursorPosition(string.len(editBox:GetText())); editBox:SetFocus()
        C_Timer.After(0.1, function() scrollFrame:SetVerticalScroll(scrollFrame:GetVerticalScrollRange()) end)
    end
end)


local launcher = CreateFrame("Button", "EasyNotesLauncher", UIParent)
launcher:SetSize(38, 38)
launcher:SetNormalTexture("Interface\\Icons\\INV_Misc_Book_09")
launcher:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
launcher:SetHitRectInsets(0, 0, 0, 0)
launcher:SetMovable(true)
launcher:EnableMouse(true)
launcher:RegisterForDrag("LeftButton")
launcher:RegisterForClicks("LeftButtonUp", "RightButtonUp")

launcher:RegisterEvent("PLAYER_LOGIN")
launcher:SetScript("OnEvent", function(self, event)

    if not EasyNotesSettings then EasyNotesSettings = { x = 0, y = 0, locked = false } end
    
    self:ClearAllPoints()
    self:SetPoint("CENTER", UIParent, "CENTER", EasyNotesSettings.x, EasyNotesSettings.y)
    
    if EasyNotesDB then editBox:SetText(EasyNotesDB) end
    
    self:SetAlpha(EasyNotesSettings.locked and 0.8 or 1)
end)

launcher:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        ToggleEasyNotes()
    elseif button == "RightButton" then
        EasyNotesSettings.locked = not EasyNotesSettings.locked
        self:SetAlpha(EasyNotesSettings.locked and 0.8 or 1)
        PlaySound("igMainMenuOptionCheckBoxOn")
        print(EasyNotesSettings.locked and "|cffff0000EasyNotes: Заблокировано|r" or "|cff00ff00EasyNotes: Разблокировано (можно двигать ЛКМ)|r")
    end
end)

launcher:SetScript("OnDragStart", function(self)
    if not EasyNotesSettings.locked then
        self:StartMoving()
    end
end)

launcher:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    
    local parentX, parentY = UIParent:GetCenter()
    local selfX, selfY = self:GetCenter()
    
    if selfX and selfY then
        EasyNotesSettings.x = selfX - parentX
        EasyNotesSettings.y = selfY - parentY
    end
end)

launcher:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Мои Заметки")
    GameTooltip:AddLine("ЛКМ: Открыть/Закрыть", 1, 1, 1)
    GameTooltip:AddLine(EasyNotesSettings.locked and "|cffff0000ПКМ: Разблокировать|r" or "|cff00ff00ПКМ: Заблокировать|r", 0.8, 0.8, 0.8)
    GameTooltip:Show()
end)
launcher:SetScript("OnLeave", function() GameTooltip:Hide() end)

local function InsertItemLink(link)
    if editBox:HasFocus() then
        editBox:Insert(link)
        return true
    end
end

hooksecurefunc("ChatEdit_InsertLink", function(link)
    if editBox:HasFocus() then
        editBox:Insert(link)
        return true
    elseif frame:IsShown() then
        editBox:SetFocus()
        editBox:Insert(link)
        return true
    end
end)

editBox:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" and not IsShiftKeyDown() then
        local text = self:GetText()
        local cursor = self:GetCursorPosition()
        if not text or text == "" then return end

        local startPos = 1
        while true do
            local s, e, fullLink = text:find("(|H.-|h.-|h)", startPos)
            if not s then break end
            
            if cursor >= (s - 1) and cursor <= e then
                local linkData = fullLink:match("|H(.-)|h")
                if linkData then
                    GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
                    GameTooltip:SetHyperlink(linkData)
                    GameTooltip:Show()
                    SetItemRef(linkData, fullLink, button)
                    return 
                end
            end
            startPos = e + 1
        end
    end
end)

local function InsertColoredLink(link)
    if not frame:IsShown() then return false end
    
    local content = link
    if link:find("player:") then
        local name = link:match("player:([^:]+)")
        if name then
            local _, class = UnitClass(name)
            if class then
                local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
                content = string.format("|c%s|Hplayer:%s|h[%s]|h|r", color.colorStr, name, name)
            else
                content = string.format("|Hplayer:%s|h[%s]|h|r", name, name)
            end
        end
    end
    
    editBox:SetFocus()
    editBox:Insert(content)
    return true
end

hooksecurefunc("ChatFrame_OnHyperlinkShow", function(chatFrame, link, text, button)
    if IsShiftKeyDown() then
        InsertColoredLink(link)
    end
end)

local original_HandleModifiedItemClick = HandleModifiedItemClick
function HandleModifiedItemClick(link)
    if IsShiftKeyDown() and frame:IsShown() then
        if InsertColoredLink(link) then return true end
    end
    return original_HandleModifiedItemClick(link)
end


