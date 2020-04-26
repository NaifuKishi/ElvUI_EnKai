local E, L, V, P, G, _ =  unpack(ElvUI);

local DT = E:GetModule("DataTexts")
local EK = E:GetModule("ElvUI_EnKai")

local _G = _G
local GetNumSavedInstances = GetNumSavedInstances
local GetSavedInstanceInfo = GetSavedInstanceInfo

local hexColor, lastPanel, rColor, gColor, bColor ;


local function dataText_OnEvent(self, ...)

	self.text:SetFormattedText("%s", "Raid ID")
	
end

local function dataText_OnEnter(self, event, ...)

	DT:SetupTooltip(self)

	local raidList = {}
	
	local numInstances = GetNumSavedInstances()
	
	for i = 1, numInstances, 1 do 
		local name, id, reset, _ = GetSavedInstanceInfo(i)			
		DT.tooltip:AddDoubleLine(string.format("%s (%s)", name, id), SecondsToTime(reset), 1, 1, 1, rColor, gColor, bColor)
	end

	DT.tooltip:Show()
	
end

local function valueColorUpdate(hex, r, g, b)
	hexColor = hex
	rColor, gColor, bColor = r, g, b
	if lastPanel ~= nil then dataText_OnEvent(lastPanel) end 
end

E["valueColorUpdateFuncs"][valueColorUpdate] = true

DT:RegisterDatatext('Raid ID', {"PLAYER_ENTERING_WORLD"}, dataText_OnEvent, nil, nil, dataText_OnEnter)
