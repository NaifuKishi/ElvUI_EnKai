local E, L, V, P, G, _ =  unpack(ElvUI);
local DT = E:GetModule('DataTexts')

local _G = _G
local UnitBuff = UnitBuff
local CancelUnitBuff = CancelUnitBuff
local Dismount = Dismount
local InCombatLockdown = InCombatLockdown

local frame

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

local function isMountErrorMessage(msg) return tContains(UI_ERROR_MESSAGES_FOR_MOUNTED, msg); end

local function isShapeshiftErrorMessage(msg) return tContains(UI_ERROR_MESSAGES_FOR_SHAPESHIFTED, msg); end

local function cancelShapeshiftBuffs()
    
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

local function printMsg(msg) print("|cff78a1ffElvUI EnKai:|r " .. msg); end

local function onEvent(self, event, ...)

    local args = {...}
	
	if E.db.ElvUI_EnKai.AutoDismount == false then return end

    if event == "UI_ERROR_MESSAGE" then
	
        local msg = args[2];
        local isMountErrorMessage = isMountErrorMessage(msg);
        local isShapeshiftErrorMessage = isShapeshiftErrorMessage(msg);

        if (isMountErrorMessage) then
            UIErrorsFrame:Clear();
            Dismount();
        end

        if (isShapeshiftErrorMessage) then
            if (InCombatLockdown()) then
                printMsg("Can't remove shapeshift in combat")
            else
                if (cancelShapeshiftBuffs()) then
                    UIErrorsFrame:Clear();
                end
            end
        end;

        return;
    end

    if event == "TAXIMAP_OPENED" then
        cancelShapeshiftBuffs();
        Dismount();
        return;
    end
end

frame = CreateFrame('Frame', 'ElvUI_EnKai_AutoDismount_Frame', E.UIParent)
frame:SetScript("OnEvent", onEvent);
frame:RegisterEvent("UI_ERROR_MESSAGE")
frame:RegisterEvent("TAXIMAP_OPENED")