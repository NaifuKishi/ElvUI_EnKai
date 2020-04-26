local E, L, V, P, G, _ =  unpack(ElvUI);

local DT = E:GetModule("DataTexts")
local EK = E:GetModule("ElvUI_EnKai")

local _G = _G
local GetSpellBonusDamage = GetSpellBonusDamage

local hexColor, lastPanel, rColor, gColor, bColor ;
local spellPowerList = {["1"] = L["Physical"], ["2"] = L["Holy"], ["3"] = L["Fire"], ["4"] = L["Nature"], ["5"] = L["Frost"], ["6"] = L["Shadow"], ["7"] = L["Arcane"], ["0"] = L["Heal"] }

local function dataText_OnEvent(self, ...)

	local value = 0

	if E.db.ElvUI_EnKai.DTSPELLPOWER == 0 then
		value = GetSpellBonusHealing()
	else
		value = GetSpellBonusDamage(tonumber(E.db.ElvUI_EnKai.DTSPELLPOWER))
	end

	if value ~= nil then
		self.text:SetFormattedText("%s: " .. hexColor .. "%s", spellPowerList[tostring(E.db.ElvUI_EnKai.DTSPELLPOWER)], value)
	end

	lastPanel = self
	
end

local function spairs(t, order)
    
	local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    local i = 0
	
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
	
end

local function dataText_OnEnter(self, event, ...)
	
	DT:SetupTooltip(self)

	local spList = {}

	local physical = GetSpellBonusDamage(1)
	if physical >0 then spList[L["Physical"]] = physical end
	
	local holy = GetSpellBonusDamage(2)
	if holy >0 then spList[L["Holy"]] = holy end
	
	local fire = GetSpellBonusDamage(3)
	if fire >0 then spList[L["Fire"]] = fire end
	
	local nature = GetSpellBonusDamage(4)
	if nature >0 then spList[L["Nature"]] = nature end
	
	local frost = GetSpellBonusDamage(5)
	if frost >0 then spList[L["Frost"]] = frost end
	
	local shadow = GetSpellBonusDamage(6)
	if shadow >0 then spList[L["Shadow"]] = shadow end
	
	local arcane = GetSpellBonusDamage(7)
	if arcane >0 then spList[L["Arcane"]] = arcane end
		
	local healpwr = GetSpellBonusHealing()
	if healpwr >0 then spList[L["Heal"]] = healpwr end
	
	for slot, value in spairs(spList, function(t,a,b) return t[b] < t[a] end) do
		DT.tooltip:AddDoubleLine(slot, format("%d", value), 1, 1, 1, rColor, gColor, bColor)
	end

	DT.tooltip:Show()
end

local function valueColorUpdate(hex, r, g, b)
	hexColor = hex
	rColor, gColor, bColor = r, g, b
	if lastPanel ~= nil then dataText_OnEvent(lastPanel) end 
end

E["valueColorUpdateFuncs"][valueColorUpdate] = true

DT:RegisterDatatext('Spell Power', {"UNIT_STATS", "UNIT_AURA"}, dataText_OnEvent, nil, nil, dataText_OnEnter)