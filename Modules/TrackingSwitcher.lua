local E, L, V, P, G, _ =  unpack(ElvUI);

local EK = E:GetModule('ElvUI_EnKai')
local DT = E:GetModule('DataTexts')

local _G = _G
local GetTrackingTexture = GetTrackingTexture
local UnitAffectingCombat = UnitAffectingCombat
local ChannelInfo = ChannelInfo
local CastingInfo = CastingInfo
local CastSpellByName = CastSpellByName

local _hex, _lastPanel;

local trackingIDs = {	minerals = { id = 136025, spellName = "Find Minerals" },
						herbs = { id = 133939, spellName = "Find Herbs" },
						hidden = { id = 132320, spellName = "Track Hidden" },
						beasts = { id = 132328, spellName = "Track Beasts" },
						dragonkin = { id = 134153, spellName = "Track Dragonkin" },
						elementals = { id = 135861, spellName = "Track Elementals" },
						undead = { id = 136142, spellName = "Track Undead" },
						demons = { id = 136217, spellName = "Track Demons" },
						giants = { id = 132275, spellName = "Track Giants" },
						humanoids = { id = 135942, spellName = "Track Humanoids" },
						humanoids_druid = { id = 132328, spellName = "Track Humanoids" },
						treasure = { id = 135725, spellName = "Find Treasure" }
					}

function EK:TimerFeedback()

    local currentTrackingIcon = GetTrackingTexture();

    if UnitAffectingCombat("player") == false then
        
		local ChannelName, _ = ChannelInfo();
		
		if name == nil then
		
			local CastingName, _ = CastingInfo();
        
			if CastingName == nil then
			
				local nextSpell = "none"
			
				if currentTrackingIcon ~= trackingIDs[E.db.ElvUI_EnKai.TRACKING1].id then
					nextSpell = E.db.ElvUI_EnKai.TRACKING1
				else
					nextSpell = E.db.ElvUI_EnKai.TRACKING2
				end
				
				if nextSpell ~= 'none' then CastSpellByName(trackingIDs[nextSpell].spellName) end		
			end
        end
    end
end

local function getCastInterval(info)
    
	if E.db.ElvUI_EnKai.TRACKINGINTERVAL == nil or E.db.ElvUI_EnKai.TRACKINGINTERVAL == '' then
        return tonumber(2)
	else
		return tonumber(E.db.ElvUI_EnKai.TRACKINGINTERVAL)
	end
	
end

local function dataText_OnEvent (self)
	
	if E.db.ElvUI_EnKai.TRACKINGACTIVE == true then
		self.text:SetFormattedText("Tracking: " .. _hex .. "%s", "active");
	else
		self.text:SetFormattedText("Tracking: " .. "|cffc74040" .. "%s", "disabled");
	end
	
	_lastPanel = self;
	
end

local function dataText_OnClick(self)
	 
	 if E.db.ElvUI_EnKai.TRACKINGACTIVE then
		EK:CancelTimer(self.trackingTimer);
		E.db.ElvUI_EnKai.TRACKINGACTIVE = false;
	else
		self.trackingTimer = EK:ScheduleRepeatingTimer('TimerFeedback', getCastInterval());
		E.db.ElvUI_EnKai.TRACKINGACTIVE = true
	end
	
	dataText_OnEvent(self)
	 
end

local function ValueColorUpdate(hex, r, g, b)
	_hex = hex
	_r, _g, _b = r, g, b
	if _lastPanel ~= nil then Tracking_OnEvent(_lastPanel) end 
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true

DT:RegisterDatatext('Tracking Switcher', {"PLAYER_ENTERING_WORLD"}, dataText_OnEvent, nil, dataText_OnClick, nil)	