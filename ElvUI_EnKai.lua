local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUI_EnKai = E:NewModule('ElvUI_EnKai', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
local EP = LibStub("LibElvUIPlugin-1.0")
local DT = E:GetModule('DataTexts')
local addonName, addonTable = ... 


if not EnKaiDataPerCharDB then
	print ('^new savedvariables')
	EnKaiDataPerCharDB = {}
end
	
function ElvUI_EnKai:Initialize()
	EP:RegisterPlugin(addonName, ElvUI_EnKai.InsertOptions)
	E.db.ElvUI_EnKai.TRACKINGACTIVE = false;
end

E:RegisterModule(ElvUI_EnKai:GetName())
