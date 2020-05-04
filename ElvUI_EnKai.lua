local addonName, addonTable = ... 

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUI_EnKai = E:NewModule('ElvUI_EnKai', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
local EP = LibStub("LibElvUIPlugin-1.0")

local _G = _G
_G.ElvUI_EnKai = ElvUI_EnKai

if not ElvUI_EnKai_DB then
	ElvUI_EnKai_DB  = {}
end

function ElvUI_EnKai:Initialize()
	EP:RegisterPlugin(addonName, ElvUI_EnKai.InsertOptions)
	E.db.ElvUI_EnKai.TRACKINGACTIVE = false;
	
	ElvUI_EnKai.EKMap:Initialize()
	ElvUI_EnKai.EKR:Initialize()
	ElvUI_EnKai.EKAD:Initialize()
	
end

E:RegisterModule(ElvUI_EnKai:GetName())