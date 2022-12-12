local ACTIONDOUBLEWAIT = 0.4;
local MINACTIONDOUBLECLICK = 0.05;

ZenFishing = {}
ZenFishingFrame = CreateFrame("Frame");

local ZFBUTTONNAME = "ZenFishingButton";

ZenFishing.fishingSpellName = nil;

function ZenFishing:CreateZFButton()
    local btn = _G[ZFBUTTONNAME];
    if (not btn) then
        local holder = CreateFrame("Frame", nil, UIParent);
        btn = CreateFrame("Button", ZFBUTTONNAME, holder, "SecureActionButtonTemplate");
        btn.holder = holder;
        btn:EnableMouse(true);
        btn:RegisterForClicks();
        btn:Show();

        holder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0);
        holder:SetFrameStrata("LOW");
        holder:SetFrameLevel(0);
        holder:Hide();
    end
end

function ZenFishing:GetFishingProfession()
    local fishing;
    _, _, _, fishing, _, _ = GetProfessions();
    return fishing;
end

function ZenFishing:GetFishingSpellInfo()
    local fishing = self:GetFishingProfession();
    if not fishing then
        return 9, PROFESSIONS_FISHING;
    end
    local name, _, _, _, count, offset, _ = GetProfessionInfo(fishing);
    local id = nil;
    for i = 1, count do
        local _, spellId = GetSpellLink(offset + i, "spell");
        local spellName = GetSpellInfo(spellId);
        if (spellName == name) then
            id = spellId;
            break;
        end
    end
    return id, name
end

function ZenFishing:InvokeFishing()
    local holder = _G[ZFHOLDERNAME];
    local btn = _G[ZFBUTTONNAME];
    if (not btn) then
        return;
    end
    SetOverrideBindingSpell(btn, true, "BUTTON2", self.fishingSpellName);
end

function ZenFishing:ClearClickHandler()
    local btn = _G[ZFBUTTONNAME];
    if (btn) then
        ClearOverrideBindings(btn);
    end
end

function ZenFishing:CheckForDoubleClick()
    local btn = _G[ZFBUTTONNAME];
    if (not LootFrame:IsShown() and self.lastClickTime) then
        local pressTime = GetTime();
        local doubleTime = pressTime - self.lastClickTime;
        if ((doubleTime < ACTIONDOUBLEWAIT) and (doubleTime > MINACTIONDOUBLECLICK)) then
            self.lastClickTime = nil;
            return true;
        end
    end
    self.lastClickTime = GetTime();
    self:ClearClickHandler();
    return false;
end

function ZenFishing_GLOBAL_MOUSE_DOWN(...)
    if (ZenFishing:CheckForDoubleClick()) then
        if (IsMouselooking()) then
            MouselookStop();
        end
        ZenFishing:InvokeFishing();
    end
end

function ZenFishing:OnEnable()
    local id, name = self:GetFishingSpellInfo();
    self.fishingSpellName = name;
    ZenFishingFrame:RegisterEvent("GLOBAL_MOUSE_DOWN");
    ZenFishingFrame:SetScript("OnEvent", ZenFishing_GLOBAL_MOUSE_DOWN);
    print("ZenFishing is active, easy cast enabled.");
end

function ZenFishing:OnDisable()
    ZenFishingFrame:UnregisterAllEvents()
    local btn = _G[ZFBUTTONNAME];
    self:ClearClickHandler();
    print("ZenFishing on standby, easy cast disabled.");
end

ZenFishing:CreateZFButton();

SLASH_ZENFISHING1 = "/zf"
SlashCmdList.ZENFISHING = function(msg, editBox)
    ZenFishing:OnEnable();
end
SLASH_ZENFISHINGOFF1 = "/zfoff"
SlashCmdList.ZENFISHINGOFF = function(msg, editBox)
    ZenFishing:OnDisable();
end
