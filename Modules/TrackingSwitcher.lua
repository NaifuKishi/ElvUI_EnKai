local E, L, V, P, G, _ =  unpack(ElvUI);

local EK = E:GetModule('ElvUI_EnKai')
local DT = E:GetModule('DataTexts')

local _G = _G
local GetTrackingTexture = GetTrackingTexture
local UnitAffectingCombat = UnitAffectingCombat
local ChannelInfo = ChannelInfo
local CastingInfo = CastingInfo
local CastSpellByName = CastSpellByName

local hexColor, lastPanel;

local trackingSpells = {	minerals = { id = 136025, spellName = "Find Minerals" },
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

function EK:TrackingTimer()

	if E.db.ElvUI_EnKai.TRACKING1 == "none" and E.db.ElvUI_EnKai.TRACKING2 == "none" then return end

    local curTrackingIcon = GetTrackingTexture();
	
	if E.db.ElvUI_EnKai.TRACKING1 == "none" then
		if trackingSpells[E.db.ElvUI_EnKai.TRACKING2] ~= nil then
			if trackingSpells[E.db.ElvUI_EnKai.TRACKING2].id == curTrackingIcon then return end
		end
	elseif E.db.ElvUI_EnKai.TRACKING2 == "none" then
		if trackingSpells[E.db.ElvUI_EnKai.TRACKING1] ~= nil then
			if trackingSpells[E.db.ElvUI_EnKai.TRACKING1].id == curTrackingIcon then return end
		end
	end
	
    if UnitAffectingCombat("player") == false then       	
		
		local channelName, _ = ChannelInfo();
		
		if channelName == nil then
		
			local castingName, _ = CastingInfo();
        
			if castingName == nil then
			
				local nextSpell = 'none'
			
				if trackingSpells[E.db.ElvUI_EnKai.TRACKING1] ~= nil then
				
					if curTrackingIcon ~= trackingSpells[E.db.ElvUI_EnKai.TRACKING1].id then
						nextSpell = E.db.ElvUI_EnKai.TRACKING1
					else
						nextSpell = E.db.ElvUI_EnKai.TRACKING2
					end
				else
					if curTrackingIcon ~= trackingSpells[E.db.ElvUI_EnKai.TRACKING2].id then
						nextSpell = E.db.ElvUI_EnKai.TRACKING2
					else
						nextSpell = E.db.ElvUI_EnKai.TRACKING1
					end
				end
				
				local spellName = tostring(L[trackingSpells[nextSpell].spellName])
				if trackingSpells[nextSpell] then CastSpellByName(spellName) end
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
		self.text:SetFormattedText("Tracking: " .. hexColor .. "%s", L["active"]);
	else
		self.text:SetFormattedText("Tracking: " .. "|cffc74040" .. "%s", L["disabled"]);
	end
	
	lastPanel = self;
	
end

local function dataText_OnClick(self)
	 
	 if E.db.ElvUI_EnKai.TRACKINGACTIVE then
		EK:CancelTimer(self.trackingTimer);
		E.db.ElvUI_EnKai.TRACKINGACTIVE = false;
	else
		self.trackingTimer = EK:ScheduleRepeatingTimer('TrackingTimer', getCastInterval());
		E.db.ElvUI_EnKai.TRACKINGACTIVE = true
	end
	
	dataText_OnEvent(self)
	 
end

local function valueColorUpdate(hex, r, g, b)
	hexColor = hex
	_r, _g, _b = r, g, b
	if lastPanel ~= nil then dataText_OnEvent(lastPanel) end 
end
E["valueColorUpdateFuncs"][valueColorUpdate] = true

DT:RegisterDatatext('Tracking Switcher', {"PLAYER_ENTERING_WORLD"}, dataText_OnEvent, nil, dataText_OnClick, nil)	