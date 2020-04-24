local E, L, V, P, G, _ =  unpack(ElvUI);

local DT = E:GetModule("DataTexts")
local EK = E:GetModule("ElvUI_EnKai")

local _G = _G
local GetSpellBonusDamage = GetSpellBonusDamage

local _hex, _lastPanel, _r, _g, _b ;

local spellsToTrack = {15846, 17187, 17559, 18560, 17560, 17561, 17562, 17563, 17564, 17565, 17566, 19566}
local playerName, realm = GetUnitName("player")

local name, _ = UnitName("player");

local function setCooldown(cooldownName, cdTime, duration)

	if not cdTime then cdTime = GetTime() end
	
	if not ElvUI_EnKai_DB[playerName] then ElvUI_EnKai_DB[playerName]  = {} end
    
    ElvUI_EnKai_DB[playerName][cooldownName] = { start = cdTime, duration = duration }

end

local function onEvent(self, ...)

	local text = L["Trade cooldown"]
	local hasCD = false
	
	for k, v in pairs(spellsToTrack) do
        local startTime, duration, enabled = GetSpellCooldown(v)
		
        if (startTime > (2^31 + 2^30) / 1000) then startTime = startTime - 2^32 / 1000 end

        if startTime ~=0 then
			local name = GetSpellInfo (v)
            setCooldown(name, startTime, duration)
			text = string.format("%s: " .. "|cffc74040" .. "%s", name, "CD")
			hasCD = true
        end
    end
	
	if ElvUI_EnKai_DB[playerName] ~= nil then
		
		for k, v in pairs (ElvUI_EnKai_DB[playerName]) do
			if v.start then
				
				local duration = v.duration or 0
				local timeleft = duration - (GetTime() - v.start)
									
				if timeleft < 0 then
					if not hasCD then  
						text = string.format("%s: " .. _hex .. "%s", k, L["ready"]);
						hasCD = true
					end
					
					ElvUI_EnKai_DB[playerName][k] = {}
				end
			elseif not hasCD then  
				text = string.format("%s: " .. _hex .. "%s", k, L["ready"]);
				hasCD = true
			end
		end
	end
	
	self.text:SetFormattedText("%s", text)
	
end

local function OnEnter(self, event, ...)

	DT:SetupTooltip(self)

	local spList = {}
	local firstPlayer = true

	for playerName, vvalues in pairs (ElvUI_EnKai_DB) do
	
		if not firstPlayer then DT.tooltip:AddLine("", 1, 1, 1) end
	
		DT.tooltip:AddLine(playerName, 1, 1, 1)
	
		for k, v in pairs (ElvUI_EnKai_DB[playerName]) do		
			if v.start then
				local duration = v.duration or 0
				local remaining = duration - (GetTime() - v.start)
				DT.tooltip:AddDoubleLine(k, SecondsToTime(remaining), 1, 1, 1, r, g, b)
			else
				DT.tooltip:AddDoubleLine(k, "ready", 1, 1, 1, r, g, b)
			end
		end
		
		firstPlayer = false
	end

	DT.tooltip:Show()
	
end

local function ValueColorUpdate(hex, r, g, b)
	_hex = hex
	_r, _g, _b = r, g, b
	if _lastPanel ~= nil then onEvent(_lastPanel) end 
end

E["valueColorUpdateFuncs"][ValueColorUpdate] = true

DT:RegisterDatatext('Trade Cooldown', {"PLAYER_ENTERING_WORLD", "TRADE_SKILL_UPDATE"}, onEvent, nil, nil, OnEnter)
