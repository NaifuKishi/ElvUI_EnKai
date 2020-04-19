local E, L, V, P, G, _ =  unpack(ElvUI);

local DT = E:GetModule("DataTexts")
local EK = E:GetModule("ElvUI_EnKai")

local _G = _G
local GetSpellBonusDamage = GetSpellBonusDamage

local _hex, _lastPanel, _r, _g, _b ;
local hasCD = false

local function onEvent(self, ...)

	local text = "Trade cooldown"
	
	if EnKaiDataPerCharDB.tradeCD ~= nil then
		for skillName, cd in pairs(EnKaiDataPerCharDB.tradeCD) do
			if cd - time() > 0 then
				self.text:SetFormattedText("%s: " .. "|cffc74040" .. "%s", skillName, "CD")
				hasCD = true
				return
			--else
				--text = string.format("%s: " .. _hex .. "%s", skillName, "ready");			
			end
		end
	else
		EnKaiDataPerCharDB.tradeCD = {}
	end		
	
	-- get trade cooldowns
	
--	if text == nil then

		local name, rank, maxRank = GetTradeSkillLine()
		
		if name == "Tailoring" or name == "Alchemy" then
			if rank == 300 then
				local numSkills = GetNumTradeSkills()
				for i = 1, numSkills, 1 do
					local skillName, _ = GetTradeSkillInfo(i)
					
					if skillName == "Mooncloth" or skillName == "Transmute: Arcanite" then
					
						if skillName == "Transmute: Arcanite" then skillName = "Arcanite" end
					
						local cd = GetTradeSkillCooldown(i)
						if cd then
							local skillName, _ = GetTradeSkillInfo(i)
							local days = math.floor(cd / (60 * 60 * 24))
							local hours = math.floor(cd / ( 60 * 60))
							local minutes = math.floor(cd / 60)
							
							EnKaiDataPerCharDB.tradeCD[skillName] = cd + time()
							
							text = string.format("%s: " .. "|cffc74040" .. "%s", skillName, "CD");
							hasCD = true
						else
							EnKaiDataPerCharDB.tradeCD[skillName] = time()
							text = string.format("%s: " .. _hex .. "%s", skillName, "ready");
						end
					end
				end
			end
		end
--	end
	
	self.text:SetFormattedText("%s", text)
	
end

local function OnEnter(self, event, ...)

	if not hasCD then return end
	
	DT:SetupTooltip(self)

	local spList = {}

	for skillName, cd in pairs(EnKaiDataPerCharDB.tradeCD) do
		if cd - time() > 0 then
			DT.tooltip:AddDoubleLine(skillName, format("%s", SecondsToTime(cd - time())), 1, 1, 1, r, g, b)
		end
	end

	

	DT.tooltip:Show()
	
end

local function ValueColorUpdate(hex, r, g, b)
	_hex = hex
	_r, _g, _b = r, g, b
	if _lastPanel ~= nil then onEvent(_lastPanel) end 
end

E["valueColorUpdateFuncs"][ValueColorUpdate] = true

DT:RegisterDatatext('Trade Cooldown', {"TRADE_SKILL_SHOW", "TRADE_SKILL_UPDATE"}, onEvent, nil, nil, OnEnter)
