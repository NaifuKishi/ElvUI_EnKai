local E, L, V, P, G, _ =  unpack(ElvUI);

local EK = E:GetModule('ElvUI_EnKai')

local _G = _G

--Default options
P["ElvUI_EnKai"] = {
	["AutoDismount"] = true,
	["TRACKING1"] = L["none"],
	["TRACKING2"] = L["none"],
	["TRACKINGINTERVAL"] = 2,
	["TRACKINGACTIVE"] = false,
	["DTSPELLPOWER"] = 7,
	["RESTOCK"] = false,
	["RESTOCKERITEM1"] = false,
	["RESTOCKERITEM2"] = false,
	["RESTOCKERITEM3"] = false,
	["RESTOCKERITEM4"] = false,
	["RESTOCKERAMOUNT1"] = 10,
	["RESTOCKERAMOUNT2"] = 10,
	["RESTOCKERAMOUNT3"] = 10,
	["RESTOCKERAMOUNT4"] = 10,
	
}

local spellPowerList = {["1"] = L["Physical"], ["2"] = L["Holy"], ["3"] = L["Fire"], ["4"] = L["Nature"], ["5"] = L["Frost"], ["6"] = L["Shadow"], ["7"] = L["Arcane"], ["0"] = L["Heal"] }

local TRACKING_SPELLS = {
	minerals = L['Find Minerals'],
    herbs = L['Find Herbs'],
	none = L['None'];
}

local trackingIDs = {	minerals = { id = 136025, spellName = L['Find Minerals'] },
						herbs = { id = 133939, spellName = L['Find Herbs'] },
						hidden = { id = 132320, spellName = L["Track Hidden"] },
						beasts = { id = 132328, spellName = L["Track Beasts"] },
						dragonkin = { id = 134153, spellName = L["Track Dragonkin"] },
						elementals = { id = 135861, spellName = L["Track Elementals"] },
						undead = { id = 136142, spellName = L["Track Undead"] },
						demons = { id = 136217, spellName = L["Track Demons"] },
						giants = { id = 132275, spellName = L["Track Giants"] },
						humanoids = { id = 135942, spellName = L["Track Humanoids"] },
						humanoids_druid = { id = 132328, spellName = L["Track Humanoids"] },
						treasure = { id = 135725, spellName = L["Find Treasure"] }
					}

local _, PLAYER_CLASS = UnitClass("player");

if PLAYER_CLASS == 'DRUID' then
    TRACKING_SPELLS = {	minerals = L['Find Minerals'],
						herbs = L['Find Herbs'],
						humanoids_druid = L['Track Humanoids'],
					}
elseif PLAYER_CLASS == 'HUNTER' then
    TRACKING_SPELLS = {	minerals = L['Find Minerals'],
						herbs = L['Find Herbs'],
						hidden = L['Track Hidden'],
						beasts = L['Track Beasts'],
						dragonkin = L['Track Dragonkin'],
						elementals = L['Track Elementals'],
						undead = L['Track Undead'],
						giants = L['Track Giants'],
						humanoids = L['Track Humanoids'],
					}
end

local restockerArgs = {}
local restockItems

if PLAYER_CLASS == 'MAGE' then

	restockItems = {17020, 17032, 17031}

	restockerArgs = {
					type1 = {
						name = L["Arcane Powder"],
						type = "toggle",
						order = 1,
						get = function(info) return E.db.ElvUI_EnKai.RESTOCKERITEM1 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERITEM1 = value end,
					},
					amount1 = {
						name = L["Amount"],
						desc = L["Amount of Arcane Powder to buy"],
						type = "range",
						order = 2,
						min = 1, max = 100, step = 1,
						get = function(info, value) return E.db.ElvUI_EnKai.RESTOCKERAMOUNT1 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERAMOUNT1 = value end,							
					},
					type2 = {
						name = L["Rune of Portals"],
						type = "toggle",
						order = 3,
						get = function(info) return E.db.ElvUI_EnKai.RESTOCKERITEM2 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERITEM2 = value end,
					},
					amount2 = {
						name = L["Amount"],
						desc = L["Amount of Rune of Portals to buy"],
						type = "range",
						order = 4,
						min = 1, max = 100, step = 1,
						get = function(info, value) return E.db.ElvUI_EnKai.RESTOCKERAMOUNT2 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERAMOUNT2 = value end,							
					},
					type3 = {
						name = L["Rune of Teleportation"],
						type = "toggle",
						order = 5,
						get = function(info) return E.db.ElvUI_EnKai.RESTOCKERITEM3 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERITEM3 = value end,
					},
					amount3 = {
						name = L["Amount"],
						desc = L["Amount of Rune of Teleportation to buy"],
						type = "range",
						order = 6,
						min = 1, max = 100, step = 1,
						get = function(info, value) return E.db.ElvUI_EnKai.RESTOCKERAMOUNT3 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERAMOUNT3 = value end,							
					},
				}	
elseif PLAYER_CLASS == 'WARRIOR' then

	restockItems = {11284, 11285}

	restockerArgs = {
					type1 = {
						name = "Acurate Slugs",
						type = "toggle",
						order = 1,
						get = function(info) return E.db.ElvUI_EnKai.RESTOCKERITEM1 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERITEM1 = value end,
					},
					amount1 = {
						name = L["Amount"],
						desc = "Amount of Acurate Slugs to buy",
						type = "range",
						order = 2,
						min = 1, max = 200, step = 1,
						get = function(info, value) return E.db.ElvUI_EnKai.RESTOCKERAMOUNT1 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERAMOUNT1 = value end,							
					},
					type2 = {
						name = "Jagged Arrows",
						type = "toggle",
						order = 3,
						get = function(info) return E.db.ElvUI_EnKai.RESTOCKERITEM2 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERITEM2 = value end,
					},
					amount2 = {
						name = L["Amount"],
						desc = "Amount of Jagged Arrows to buy",
						type = "range",
						order = 4,
						min = 1, max = 200, step = 1,
						get = function(info, value) return E.db.ElvUI_EnKai.RESTOCKERAMOUNT2 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERAMOUNT2 = value end,							
					},					
				}	
				
elseif PLAYER_CLASS == "ROGUE" then

	restockItems = {5140, 11284, 11285, 15327}

	restockerArgs = {
					type1 = {
						name = L["Flash Powder"],
						type = "toggle",
						order = 1,
						get = function(info) return E.db.ElvUI_EnKai.RESTOCKERITEM1 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERITEM1 = value end,
					},
					amount1 = {
						name = L["Amount"],
						desc = L["Amount of Flash Powder to buy"],
						type = "range",
						order = 2,
						min = 1, max = 200, step = 1,
						get = function(info, value) return E.db.ElvUI_EnKai.RESTOCKERAMOUNT1 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERAMOUNT1 = value end,							
					},
					type2 = {
						name = "Acurate Slugs",
						type = "toggle",
						order = 3,
						get = function(info) return E.db.ElvUI_EnKai.RESTOCKERITEM2 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERITEM2 = value end,
					},
					amount2 = {
						name = L["Amount"],
						desc = "Amount of Acurate Slugs to buy",
						type = "range",
						order = 4,
						min = 1, max = 200, step = 1,
						get = function(info, value) return E.db.ElvUI_EnKai.RESTOCKERAMOUNT2 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERAMOUNT2 = value end,							
					},
					type3 = {
						name = "Jagged Arrows",
						type = "toggle",
						order = 5,
						get = function(info) return E.db.ElvUI_EnKai.RESTOCKERITEM3 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERITEM3 = value end,
					},
					amount3 = {
						name = L["Amount"],
						desc = "Amount of Jagged Arrows to buy",
						type = "range",
						order = 6,
						min = 1, max = 200, step = 1,
						get = function(info, value) return E.db.ElvUI_EnKai.RESTOCKERAMOUNT3 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERAMOUNT3= value end,							
					},
					type4 = {
						name = "Wicked Throwing Dagger",
						type = "toggle",
						order = 7,
						get = function(info) return E.db.ElvUI_EnKai.RESTOCKERITEM4 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERITEM4 = value end,
					},
					amount4 = {
						name = L["Amount"],
						desc = "Amount of Wicked Throwing Daggers to buy",
						type = "range",
						order = 8,
						min = 1, max = 200, step = 1,
						get = function(info, value) return E.db.ElvUI_EnKai.RESTOCKERAMOUNT4 end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCKERAMOUNT4 = value end,							
					},						
				}	
				
else
	P["ElvUI_EnKai"]["RESTOCK"] = false
	restockerArgs = {	info = {
							order = 1,
							type = "description",
							name = L["There are no items to restock for this class"],
						}
					}

end

local _, PLAYER_RACE = UnitRace("player");

if PLAYER_RACE == 'Dwarf' then TRACKING_SPELLS['treasure'] = L['Find Treasure'] end

TRACKING_SPELLS['none'] = L["None"]

function EK:InsertOptions()
	E.Options.args.ElvUI_EnKai = {
		order = 100,
		type = "group",
		childGroups = "tab",
		name = "EnKai",
		args = {
			tools = {
				order = 10,
				type = "group",
				name = L["Tools"],
				args = {
					usefull = {						
						type = 'header',
						name = L["Usefull tools"],
						order = 1,
					},					
					DismountOption = {
						order = 2,
						type = "toggle",
						name = L["Auto dismount"],
						get = function(info) return E.db.ElvUI_EnKai.AutoDismount end,
						set = function(info, value) E.db.ElvUI_EnKai.AutoDismount = value end,					
					},
					TrackingSwitchHeader = {						
						type = 'header',
						name = L["Tracking Switcher"],
						order = 3,
					},
					TrackingSwitcher = {
						name = L["Tracking Switcher"],
						type = 'group',
						guiInline = true,
						order = 4,
						args = {
							type1 = {
								name = L["First Type"],
								desc = L["First type to swap between"],
								type = "select",
								values = TRACKING_SPELLS,
								get = function(info)
									return E.db.ElvUI_EnKai.TRACKING1
								end,
								set = function(info, value) E.db.ElvUI_EnKai.TRACKING1 = value end,
							},
							type2 = {
								name = L["Second Type"],
								desc = L["Second type to swap between"],
								type = "select",
								values = TRACKING_SPELLS,
								get = function(info) return E.db.ElvUI_EnKai.TRACKING2 end,
								set = function(info, value) E.db.ElvUI_EnKai.TRACKING2 = value end,
							},
							interval = {
								name = L["Tracking interval"],
								desc = L["Sets interval to switch"],
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
								name = L["Spell Power"],
								desc = L["Type of spell power"],
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
				name = L["Restocker"],
				args = {
					info = {
						order = 1,
						type = "description",
						name = L["Restocks required reagents"],
					},
					enabled = {
						order = 2,
						type = "toggle",
						name = L["Restock items"],
						get = function(info) return E.db.ElvUI_EnKai.RESTOCK end,
						set = function(info, value) E.db.ElvUI_EnKai.RESTOCK = value end,
					},
					items = {
						type = 'group',
						name = L['Class Items'],
						guiInline = true,
						order = 3,
						args = restockerArgs,
					}
				},
			},					
		},
	}
end

EK:Restocker_Init(restockItems)