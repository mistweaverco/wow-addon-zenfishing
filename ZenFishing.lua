local ACTIONDOUBLEWAIT = 0.4
local MINACTIONDOUBLECLICK = 0.05

ZenFishing = {}
ZenFishingFrame = CreateFrame("Frame")

local ZFBUTTONNAME = "ZenFishingButton"

ZenFishing.isEnabled = false
ZenFishing.fishingSpellName = nil

function ZenFishing:CreateZFButton()
  local btn = _G[ZFBUTTONNAME]
  if not btn then
    local holder = CreateFrame("Frame", nil, UIParent)
    btn = CreateFrame("Button", ZFBUTTONNAME, holder, "SecureActionButtonTemplate")
    btn.holder = holder
    btn:EnableMouse(true)
    btn:RegisterForClicks()
    btn:Show()

    holder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
    holder:SetFrameStrata("LOW")
    holder:SetFrameLevel(0)
    holder:Hide()
  end
end

function ZenFishing:GetFishingProfession()
  local fishing
  _, _, _, fishing, _ = GetProfessions()
  if not fishing then
    print("\124cnEPIC_PURPLE_COLOR:ZenFishing: \124cnPURE_RED_COLOR:You haven't learned fishing yet")
  else
    return fishing
  end
end

function ZenFishing:GetFishingSpellInfo()
  local fishing = self:GetFishingProfession()
  if fishing then
    local name = GetProfessionInfo(fishing)
    local id = nil
    local spellId = C_Spell.GetSpellIDForSpellIdentifier(name)
    local spellName = C_Spell.GetSpellName(spellId)
    if spellName == name then
      id = spellId
    end
    return id, name
  end
end

function ZenFishing:InvokeFishing()
  local holder = _G[ZFHOLDERNAME]
  local btn = _G[ZFBUTTONNAME]
  if not btn then
    return
  end
  SetOverrideBindingSpell(btn, true, "BUTTON2", self.fishingSpellName)
end

function ZenFishing:ClearClickHandler()
  local btn = _G[ZFBUTTONNAME]
  if btn then
    ClearOverrideBindings(btn)
  end
end

function ZenFishing:CheckForDoubleClick()
  local btn = _G[ZFBUTTONNAME]
  if not LootFrame:IsShown() and self.lastClickTime then
    local pressTime = GetTime()
    local doubleTime = pressTime - self.lastClickTime
    if (doubleTime < ACTIONDOUBLEWAIT) and (doubleTime > MINACTIONDOUBLECLICK) then
      self.lastClickTime = nil
      return true
    end
  end
  self.lastClickTime = GetTime()
  self:ClearClickHandler()
  return false
end

function ZenFishing_GLOBAL_MOUSE_DOWN(...)
  if ZenFishing:CheckForDoubleClick() then
    if IsMouselooking() then
      MouselookStop()
    end
    ZenFishing:InvokeFishing()
  end
end

function ZenFishing:OnEnable()
  local fishing = self:GetFishingProfession()
  if fishing then
    ZenFishing.isEnabled = true
    local id, name = self:GetFishingSpellInfo()
    self.fishingSpellName = name
    ZenFishingFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")
    ZenFishingFrame:SetScript("OnEvent", ZenFishing_GLOBAL_MOUSE_DOWN)
    print("\124cnEPIC_PURPLE_COLOR:ZenFishing: \124cnPURE_GREEN_COLOR:Easy Cast Enabled")
  end
end

function ZenFishing:OnDisable()
  ZenFishing.isEnabled = false
  ZenFishingFrame:UnregisterAllEvents()
  local btn = _G[ZFBUTTONNAME]
  self:ClearClickHandler()
  print("\124cnEPIC_PURPLE_COLOR:ZenFishing: \124cnPURE_RED_COLOR:Easy Cast Disabled")
end

ZenFishing:CreateZFButton()

SLASH_ZENFISHING1 = "/zf"
SlashCmdList.ZENFISHING = function(msg, editBox)
  if ZenFishing.isEnabled then
    ZenFishing:OnDisable()
  else
    ZenFishing:OnEnable()
  end
end
