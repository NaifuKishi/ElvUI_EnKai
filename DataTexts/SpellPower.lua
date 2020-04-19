local E, L, V, P, G, _ =  unpack(ElvUI);

local DT = E:GetModule("DataTexts")
local EK = E:GetModule("ElvUI_EnKai")

local _G = _G
local GetSpellBonusDamage = GetSpellBonusDamage

local _hex, _lastPanel, _r, _g, _b ;
local spellPowerList = {["1"] = "Physical", ["2"] = "Holy", ["3"] = "Fire", ["4"] = "Nature", ["5"] = "Frost", ["6"] = "Shadow", ["7"] = "Arcane", ["0"] = "Heal" }

local function onEvent(self, ...)

	local value = 0

	if E.db.ElvUI_EnKai.DTSPELLPOWER == 0 then
		value = GetSpellBonusHealing()
	else
		value = GetSpellBonusDamage(tonumber(E.db.ElvUI_EnKai.DTSPELLPOWER))
	end

	if value ~= nil then
		self.text:SetFormattedText("%s: " .. _hex .. "%s", spellPowerList[tostring(E.db.ElvUI_EnKai.DTSPELLPOWER)], value)
	end

	lastPanel = self
	
end

local function spairs(t, order)
    
	local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
	
end

local function OnEnter(self, event, ...)
	
	DT:SetupTooltip(self)

	local spList = {}

	local _physical = GetSpellBonusDamage(1)
	if _physical >0 then spList["Physical"] = _physical end
	
	local _holy = GetSpellBonusDamage(2)
	if _holy >0 then spList["Holy"] = _holy end
	
	local _fire = GetSpellBonusDamage(3)
	if _fire >0 then spList["Fire"] = _fire end
	
	local _nature = GetSpellBonusDamage(4)
	if _nature >0 then spList["Nature"] = _nature end
	
	local _frost = GetSpellBonusDamage(5)
	if _frost >0 then spList["Frost"] = _frost end
	
	local _shadow = GetSpellBonusDamage(6)
	if _shadow >0 then spList["Shadow"] = _shadow end
	
	local _arcane = GetSpellBonusDamage(7)
	if _arcane >0 then spList["Arcane"] = _arcane end
		
	local _healpwr = GetSpellBonusHealing()
	if _healpwr >0 then spList["Heal"] = _healpwr end
	
	for slot, value in spairs(spList, function(t,a,b) return t[b] < t[a] end) do
		DT.tooltip:AddDoubleLine(slot, format("%d", value), 1, 1, 1, r, g, b)
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex, r, g, b)
	_hex = hex
	_r, _g, _b = r, g, b
	if _lastPanel ~= nil then onEvent(_lastPanel) end 
end

E["valueColorUpdateFuncs"][ValueColorUpdate] = true

DT:RegisterDatatext('Spell Power', {"UNIT_STATS", "UNIT_AURA"}, onEvent, nil, nil, OnEnter)
