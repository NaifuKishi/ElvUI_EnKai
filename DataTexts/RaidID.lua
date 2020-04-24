local E, L, V, P, G, _ =  unpack(ElvUI);

local DT = E:GetModule("DataTexts")
local EK = E:GetModule("ElvUI_EnKai")

local _G = _G
local GetNumSavedInstances = GetNumSavedInstances
local GetSavedInstanceInfo = GetSavedInstanceInfo

local _hex, _lastPanel, _r, _g, _b ;


local function onEvent(self, ...)

	self.text:SetFormattedText("%s", "Raid ID")
	
end

local function OnEnter(self, event, ...)

	DT:SetupTooltip(self)

	local raidList = {}
	
	local numInstances = GetNumSavedInstances()
	
	for i = 1, numInstances, 1 do 
		local name, id, reset, _ = GetSavedInstanceInfo(i)			
		DT.tooltip:AddDoubleLine(string.format("%s (%s)", name, id), SecondsToTime(reset), 1, 1, 1, r, g, b)
	end

	DT.tooltip:Show()
	
end

local function ValueColorUpdate(hex, r, g, b)
	_hex = hex
	_r, _g, _b = r, g, b
	if _lastPanel ~= nil then onEvent(_lastPanel) end 
end

E["valueColorUpdateFuncs"][ValueColorUpdate] = true

DT:RegisterDatatext('Raid ID', {"PLAYER_ENTERING_WORLD"}, onEvent, nil, nil, OnEnter)
