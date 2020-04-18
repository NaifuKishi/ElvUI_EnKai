local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUI_EnKai = E:NewModule('ElvUI_EnKai', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
local EP = LibStub("LibElvUIPlugin-1.0")
local DT = E:GetModule('DataTexts')
local addonName, addonTable = ... 

--Default options
P["ElvUI_EnKai"] = {
	["AutoDismount"] = true,
	["TRACKING1"] = "none",
	["TRACKING2"] = "none",
	["TRACKINGINTERVAL"] = 2,
	["TRACKINGACTIVE"] = false,
	["DTSPELLPOWER"] = 7,
	["RESTOCK"] = false,
	["RESTOCKERITEM1"] = false,
	["RESTOCKERITEM1"] = false,
	["RESTOCKERITEM1"] = false,
	["RESTOCKERAMOUNT1"] = 10,
	["RESTOCKERAMOUNT2"] = 10,
	["RESTOCKERAMOUNT3"] = 10,
	
}

local spellPowerList = {["7"] = "Arcane", ["3"] = "Fire", ["5"] = "Frost", ["0"] = "Heal", ["2"] = "Holy", ["4"] = "Nature", ["1"] = "Physical", ["6"] = "Shadow" }

local TRACKING_SPELLS = {
	minerals = 'Find Minerals',
    herbs = 'Find Herbs',
	none = 'None';
}

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

local _, PLAYER_CLASS = UnitClass("player");

if PLAYER_CLASS == 'DRUID' then
    TRACKING_SPELLS = {	minerals = 'Find Minerals',
						herbs = 'Find Herbs',
						humanoids_druid = 'Track Humanoids',
					}
elseif PLAYER_CLASS == 'HUNTER' then
    TRACKING_SPELLS = {	minerals = 'Find Minerals',
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

local restockerArgs = {}
local restockItems

if PLAYER_CLASS == 'MAGE' then

	restockItems = {17020, 17032, 17031}

	restockerArgs = {
					type1 = {
						name = "Arcane Powder",
						type = "toggle",
						order = 1,
						get = function(info) return E.db.ElvUI_EnKai.RESTOCKERITEM1 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERITEM1 = value end,
					},
					amount1 = {
						name = "Amount",
						desc = "Amount of Arcane Powder to buy",
						type = "range",
						order = 2,
						min = 1, max = 100, step = 1,
						get = function(info, value) return E.db.ElvUI_EnKai.RESTOCKERAMOUNT1 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERAMOUNT1 = value end,							
					},
					type2 = {
						name = "Rune of Portals",
						type = "toggle",
						order = 3,
						get = function(info) return E.db.ElvUI_EnKai.RESTOCKERITEM2 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERITEM2 = value end,
					},
					amount2 = {
						name = "Amount",
						desc = "Amount of Rune of Portals to buy",
						type = "range",
						order = 4,
						min = 1, max = 100, step = 1,
						get = function(info, value) return E.db.ElvUI_EnKai.RESTOCKERAMOUNT2 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERAMOUNT2 = value end,							
					},
					type3 = {
						name = "Rune of Teleportation",
						type = "toggle",
						order = 5,
						get = function(info) return E.db.ElvUI_EnKai.RESTOCKERITEM3 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERITEM3 = value end,
					},
					amount3 = {
						name = "Amount",
						desc = "Amount of Rune of Teleportation to buy",
						type = "range",
						order = 6,
						min = 1, max = 100, step = 1,
						get = function(info, value) return E.db.ElvUI_EnKai.RESTOCKERAMOUNT3 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERAMOUNT3 = value end,							
					},
				}	
else
	P["ElvUI_EnKai"]["RESTOCK"] = false
	restockerArgs = {	info = {
							order = 1,
							type = "description",
							name = "There are no items to restock for this class",
						}
					}

end

local _, PLAYER_RACE = UnitRace("player");

if PLAYER_RACE == 'Dwarf' then TRACKING_SPELLS['treasure'] = 'Find Treasure' end

TRACKING_SPELLS['none'] = "None"

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
						get = function(info) return E.db.ElvUI_EnKai.AutoDismount end,
						set = function(info, value) E.db.ElvUI_EnKai.AutoDismount = value end,					
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
									return E.db.ElvUI_EnKai.TRACKING1
								end,
								set = function(info, value) E.db.ElvUI_EnKai.TRACKING1 = value end,
							},
							type2 = {
								name = "Second Type",
								desc = "Second type to swap between",
								type = "select",
								values = TRACKING_SPELLS,
								get = function(info) return E.db.ElvUI_EnKai.TRACKING2 end,
								set = function(info, value) E.db.ElvUI_EnKai.TRACKING2 = value end,
							},
							interval = {
								name = "Tracking interval",
								desc = "Sets interval to switch",
								type = "range",
								min = 2, max = 60, step = 1,
								get = function(info, value) return E.db.ElvUI_EnKai.TRACKINGINTERVAL end,
								set = function(info, value) E.db.ElvUI_EnKai.TRACKINGINTERVAL = value end,							
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
								values = spellPowerList,
								get = function(info)
									return tostring(E.db.ElvUI_EnKai.DTSPELLPOWER)
								end,
								set = function(info, value)
									E.db.ElvUI_EnKai.DTSPELLPOWER = tonumber(value)
									E:StaticPopup_Show('CONFIG_RL')
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
					enabled = {
						order = 2,
						type = "toggle",
						name = "Restock items",
						get = function(info) return E.db.ElvUI_EnKai.RESTOCK end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCK = value end,
					},
					items = {
						type = 'group',
						name = 'Class Items',
						guiInline = true,
						order = 3,
						args = restockerArgs,
					}
				},
			},					
		},
	}
end

function ElvUI_EnKai:Initialize()
	EP:RegisterPlugin(addonName, ElvUI_EnKai.InsertOptions)
	E.db.ElvUI_EnKai.TRACKINGACTIVE = false;
	ElvUI_EnKai:Restocker_Init(restockItems)
end

E:RegisterModule(ElvUI_EnKai:GetName())
