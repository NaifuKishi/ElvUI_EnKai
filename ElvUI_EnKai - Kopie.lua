local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUI_EnKai = E:NewModule('ElvUI_EnKai', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
local EP = LibStub("LibElvUIPlugin-1.0")
local DT = E:GetModule('DataTexts')
local addonName, addonTable = ... 

--Default options
P["ElvUI_EnKai"] = {
	["AutoDismount"] = true,
	["TRACKING1"] = "herbs",
	["TRACKING2"] = "minerals",
	["TRACKINGINTERVAL"] = 2,
	["TRACKINGACTIVE"] = false,
	["DTSPELLPOWER"] = 7,
}

local UI_ERROR_MESSAGES_FOR_MOUNTED = { 
    ERR_ATTACK_MOUNTED,
    ERR_NOT_WHILE_MOUNTED,
    ERR_TAXIPLAYERALREADYMOUNTED,
    SPELL_FAILED_NOT_MOUNTED
};

local UI_ERROR_MESSAGES_FOR_SHAPESHIFTED = {
    ERR_EMBLEMERROR_NOTABARDGEOSET,
    ERR_CANT_INTERACT_SHAPESHIFTED,
    ERR_MOUNT_SHAPESHIFTED,
    ERR_NO_ITEMS_WHILE_SHAPESHIFTED,
    ERR_NOT_WHILE_SHAPESHIFTED,
    ERR_TAXIPLAYERSHAPESHIFTED,
    SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED,
    SPELL_FAILED_NOT_SHAPESHIFT,
    SPELL_NOT_SHAPESHIFTED,
    SPELL_NOT_SHAPESHIFTED_NOSPACE,
};

local GHOST_WOLF_ID = 2645;
local DIRE_BEAR_FORM_ID = 9634;
local TRAVEL_FORM_ID = 783;
local CAT_FORM_ID = 768;
local BEAR_FORM_ID = 5487;
local AQUATIC_FORM_ID = 1066;

local SHAPE_SHIFT_BUFFS = {
    GHOST_WOLF_ID,
    DIRE_BEAR_FORM_ID,
    TRAVEL_FORM_ID,
    CAT_FORM_ID,
    BEAR_FORM_ID,
    AQUATIC_FORM_ID,
};

local TRACKING_SPELLS = {
	minerals = 'Find Minerals',
    herbs = 'Find Herbs',
}

local trackingIDs = {
        minerals = {
            id = 136025,
            spellName = "Find Minerals"
        },
        herbs = {
            id = 133939,
            spellName = "Find Herbs"
        },
        hidden = {
            id = 132320,
            spellName = "Track Hidden"
        },
        beasts = {
            id = 132328,
            spellName = "Track Beasts"
        },
        dragonkin = {
            id = 134153,
            spellName = "Track Dragonkin"
        },
        elementals = {
            id = 135861,
            spellName = "Track Elementals"
        },
        undead = {
            id = 136142,
            spellName = "Track Undead"
        },
        demons = {
            id = 136217,
            spellName = "Track Demons"
        },
        giants = {
            id = 132275,
            spellName = "Track Giants"
        },
        humanoids = {
            id = 135942,
            spellName = "Track Humanoids"
        },
        humanoids_druid = {
            id = 132328,
            spellName = "Track Humanoids"
        },
        treasure = {
            id = 135725,
            spellName = "Find Treasure"
        }
    }

local _, PLAYER_CLASS = UnitClass("player");

if PLAYER_CLASS == 'DRUID' then
    TRACKING_SPELLS = {
							minerals = 'Find Minerals',
							herbs = 'Find Herbs',
							humanoids_druid = 'Track Humanoids'
						}
elseif PLAYER_CLASS == 'HUNTER' then
    TRACKING_SPELLS = {
							minerals = 'Find Minerals',
							herbs = 'Find Herbs',
							hidden = 'Track Hidden',
							beasts = 'Track Beasts',
							dragonkin = 'Track Dragonkin',
							elementals = 'Track Elementals',
							undead = 'Track Undead',
							giants = 'Track Giants',
							humanoids = 'Track Humanoids',
						}
end

local _, PLAYER_RACE = UnitRace("player");

if PLAYER_RACE == 'Dwarf' then TRACKING_SPELLS['treasure'] = 'Find Treasure' end

function ElvUI_EnKai:isMountErrorMessage(msg) return tContains(UI_ERROR_MESSAGES_FOR_MOUNTED, msg); end

function ElvUI_EnKai:isShapeshiftErrorMessage(msg) return tContains(UI_ERROR_MESSAGES_FOR_SHAPESHIFTED, msg); end

function ElvUI_EnKai:cancelShapeshiftBuffs()
    
	local removedBuff = false;
    
	for i = 1, 40 do
        local buffId = select(10, UnitBuff("player", i));
        if (tContains(SHAPE_SHIFT_BUFFS, buffId)) then
            removedBuff = true;
            CancelUnitBuff("player", i);
        end
    end
	
    return removedBuff;
end

function ElvUI_EnKai:printMsg(msg) print("|cff78a1ffElvUI EnKai:|r " .. msg); end

function ElvUI_EnKai:Update()
	
	DataText_FSP_OnEvent()
	
end

function ElvUI_EnKai:InsertOptions()
	E.Options.args.ElvUI_EnKai = {
		order = 100,
		type = "group",
		childGroups = "tab",
		name = "ElvUI EnKai",
		args = {
			tools = {
				order = 10,
				type = "group",
				name = "Tools",
				args = {
					usefull = {						
						type = 'header',
						name = "Usefull tools",
						order = 1,
					},					
					DismountOption = {
						order = 2,
						type = "toggle",
						name = "Auto dismount",
						get = function(info)
							return E.db.ElvUI_EnKai.AutoDismount
						end,
						set = function(info, value)
							E.db.ElvUI_EnKai.AutoDismount = value
							ElvUI_EnKai:Update() --We changed a setting, call our Update function
						end,					
					},
					TrackingSwitchHeader = {						
						type = 'header',
						name = "Tracking Switcher",
						order = 3,
					},
					TrackingSwitcher = {					
						type = 'group',
						name = 'Tracking Switcher',
						guiInline = true,
						order = 4,
						args = {
							type1 = {
								name = "First Type",
								desc = "First type to swap between",
								type = "select",
								values = TRACKING_SPELLS,
								get = function(info)
									return E.db.ElvUI_EnKai.DTSPELLPOWER
								end,
								set = function(info, value)
									E.db.ElvUI_EnKai.DTSPELLPOWER = value
									ElvUI_EnKai:Update()
								end,
							}
						}
					}
				},
			},
			datatexts = {
				order = 20,
				type = "group",
				name = "DataTexts",
				args = {
					type1 = {
								name = "Spell Power",
								desc = "Type of spell power",
								type = "select",
								values = {["Physical"] = 1, ["Holy"] = 2, ["Fire"] = 3, ["Nature"] = 4, ["Frost"] = 5, ["Shadow"] = 6, ["Arcane"] = 7, ["Heal"] = 0 },
								get = function(info)
									return E.db.ElvUI_EnKai.TRACKING1
								end,
								set = function(info, value)
									E.db.ElvUI_EnKai.TRACKING1 = value
									--ElvUI_EnKai:Update() --We changed a setting, call our Update function
								end,
							},
				}
			},
			restocker = {
				order = 30,
				type = "group",
				name = "Restocker",
				args = {
					info = {
						order = 1,
						type = "description",
						name = "Restocks required reagents",
					},
					DismountOption = {
						order = 2,
						type = "toggle",
						name = "Restock items",
						get = function(info)
							return E.db.ElvUI_EnKai.RestockReagents
						end,
						set = function(info, value)
							E.db.ElvUI_EnKai.RestockReagents = value
							ElvUI_EnKai:Update() --We changed a setting, call our Update function
						end,
					},		
				},
			},					
		},
	}
end

function ElvUI_EnKai:addEventListeners(self)
    ElvUI_EnKai.frame:RegisterEvent("UI_ERROR_MESSAGE")
    ElvUI_EnKai.frame:RegisterEvent("TAXIMAP_OPENED")
end

function ElvUI_EnKai:onEvent(event, ...)
    local args = {...}
	
	if E.db.ElvUI_EnKai.AutoDismount == false then return end

    if event == "UI_ERROR_MESSAGE" then
        local msg = args[2];
        local isMountErrorMessage = ElvUI_EnKai:isMountErrorMessage(msg);
        local isShapeshiftErrorMessage = ElvUI_EnKai:isShapeshiftErrorMessage(msg);

        if (isMountErrorMessage) then
            UIErrorsFrame:Clear();
            Dismount();
        end

        if (isShapeshiftErrorMessage) then
            if (InCombatLockdown()) then
                ElvUI_EnKai:printMsg("Can't remove shapeshift in combat")
            else
                if (ElvUI_EnKai:cancelShapeshiftBuffs()) then
                    UIErrorsFrame:Clear();
                end
            end
        end;

        return;
    end

    if event == "TAXIMAP_OPENED" then
        ElvUI_EnKai:cancelShapeshiftBuffs();
        Dismount();
        return;
    end
end

local function Tracking_OnEvent (self)
	
	if E.db.ElvUI_EnKai.TRACKINGACTIVE == true then
		self.text:SetFormattedText("Tracking: " .. _hex .. "%s", "active");
	else
		self.text:SetFormattedText("Tracking: " .. "|cffc74040" .. "%s", "disabled");
	end
	
	_lastPanel = self;
	
end

local function DataText_FSP_OnEvent (self)

	local fsp = GetSpellBonusDamage(7)

	if fsp then
		self.text:SetFormattedText("SP: " .. _hex .. "%s", fsp)
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

local function DataText_FSP_OnEnter(self)
	
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

local function Tracking_OnClick(self)
	 
	 if E.db.ElvUI_EnKai.TRACKINGACTIVE then
		ElvUI_EnKai:CancelTimer(self.trackingTimer);
		E.db.ElvUI_EnKai.TRACKINGACTIVE = false;
	else
		self.trackingTimer = ElvUI_EnKai:ScheduleRepeatingTimer('TimerFeedback', ElvUI_EnKai:GetCastInterval());
		E.db.ElvUI_EnKai.TRACKINGACTIVE = true
	end
	
	Tracking_OnEvent(self)
	 
end

function ElvUI_EnKai:Initialize()
	--Register plugin so options are properly inserted when config is loaded
	EP:RegisterPlugin(addonName, ElvUI_EnKai.InsertOptions)
	
	ElvUI_EnKai.frame = CreateFrame('Frame', 'ElvUIEnKaiFrame', E.UIParent)
	ElvUI_EnKai.frame:SetScript("OnEvent", ElvUI_EnKai.onEvent);
    ElvUI_EnKai.addEventListeners();
	
	E.db.ElvUI_EnKai.TRACKINGACTIVE = false;
	
	DT:RegisterDatatext('Tracking Switcher', {"PLAYER_ENTERING_WORLD"}, Tracking_OnEvent, nil, Tracking_OnClick, nil)	
	
end

function ElvUI_EnKai:TimerFeedback()

    local currentTrackingIcon = GetTrackingTexture();

    if UnitAffectingCombat("player") == false then
        
		--local name, _ = ElvUI_EnKai:UnitChannelInfo("player")
		
		local ChannelName, _ = ChannelInfo();
		
		if name == nil then
		
			local CastingName, _ = CastingInfo();
        
			if CastingName == nil then
				if currentTrackingIcon ~= trackingIDs[E.db.ElvUI_EnKai.TRACKING1].id then
					CastSpellByName(trackingIDs[E.db.ElvUI_EnKai.TRACKING1].spellName);
				else
					CastSpellByName(trackingIDs[E.db.ElvUI_EnKai.TRACKING2].spellName);
				end
			end
        end
    end
end

function ElvUI_EnKai:GetCastInterval(info)
    
	if E.db.ElvUI_EnKai.TRACKINGINTERVAL == nil or E.db.ElvUI_EnKai.TRACKINGINTERVAL == '' then
        return tonumber(2)
	else
		return tonumber(E.db.ElvUI_EnKai.TRACKINGINTERVAL)
	end
	
end

local function ValueColorUpdate(hex, r, g, b)
	_hex = hex
	_r, _g, _b = r, g, b
	if _lastPanel ~= nil then Tracking_OnEvent(_lastPanel) end 
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true

E:RegisterModule(ElvUI_EnKai:GetName()) --Register the module with ElvUI. ElvUI will now call ElvUI_EnKai:Initialize() when ElvUI is ready to load our plugin.
