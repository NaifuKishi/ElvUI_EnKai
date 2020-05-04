local E, L, V, P, G, _ =  unpack(ElvUI);

local EnKai = _G.ElvUI_EnKai
local EKR = EnKai:NewModule('EnKai_Reputation', 'AceEvent-3.0')
EnKai.EKR = EKR

local GetWatchedFactionInfo = GetWatchedFactionInfo
local GetNumFactions = GetNumFactions
local GetFactionInfo = GetFactionInfo
local IsFactionInactive = IsFactionInactive
local SetWatchedFactionIndex = SetWatchedFactionIndex

local incpat = string.gsub(string.gsub(FACTION_STANDING_INCREASED, "(%%s)", "(.+)"), "(%%d)", "(.+)")
local changedpat = string.gsub(string.gsub(FACTION_STANDING_CHANGED, "(%%s)", "(.+)"), "(%%d)", "(.+)")
local decpat = string.gsub(string.gsub(FACTION_STANDING_DECREASED, "(%%s)", "(.+)"), "(%%d)", "(.+)")

function EKR:ChangeWatchedReputation (event, msg)
	
	if E.db.ElvUI_EnKai.WatchReputation == false then return end
	
	local _, _, faction, amount = string.find(msg, incpat)
	
	if not faction then _, _, faction, amount = string.find(msg, changedpat) or string.find(msg, decpat) end
	
	if faction then
		local active = GetWatchedFactionInfo()
		
		for factionIndex = 1, GetNumFactions() do
			local name = GetFactionInfo(factionIndex)
			
			if name == faction and name ~= active then
				local inactive = IsFactionInactive(factionIndex) or SetWatchedFactionIndex(factionIndex)
				break
			end
		end
	end
end

function EKR:Initialize()
	
	self:RegisterEvent('CHAT_MSG_COMBAT_FACTION_CHANGE', 'ChangeWatchedReputation')

end