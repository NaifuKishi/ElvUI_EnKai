local E, L, V, P, G, _ =  unpack(ElvUI);
local DT = E:GetModule('DataTexts')

local _G = _G
local UnitBuff = UnitBuff
local CancelUnitBuff = CancelUnitBuff
local Dismount = Dismount
local InCombatLockdown = InCombatLockdown

local autodismountFrame

local errorMsgMountedList = { 
    ERR_ATTACK_MOUNTED,
    ERR_NOT_WHILE_MOUNTED,
    ERR_TAXIPLAYERALREADYMOUNTED,
    SPELL_FAILED_NOT_MOUNTED
};

local errorMsgShapeshiftList = {
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

local shapeShiftBuffList = {
    2645, -- ghost wolf
    9634, -- dire worlf
    783, -- travel form
    768, -- cat form
    5487, -- bear form
    1066, -- aquatic form
};

local function isMountErrorMessage(errMsg) return tContains(errorMsgMountedList, errMsg) end

local function isShapeshiftErrorMessage(errMsg) return tContains(errorMsgShapeshiftList, errMsg) end

local function cancelShapeshiftBuffs()
    
	local removedBuff = false;
    
	for i = 1, 40 do
        local buffId = select(10, UnitBuff("player", i));
        if (tContains(shapeShiftBuffList, buffId)) then
            removedBuff = true;
            CancelUnitBuff("player", i);
        end
    end
	
    return removedBuff;
	
end

local function printMsg(msg) print("|cff78a1ffElvUI EnKai:|r " .. msg) end

local function autodismount_OnEvent(self, event, ...)

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
                printMsg(L["Can't remove shapeshift in combat"])
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

autodismountFrame = CreateFrame('Frame', 'ElvUI_EnKai_AutoDismountFrame', E.UIParent)
autodismountFrame:SetScript("OnEvent", autodismount_OnEvent);
autodismountFrame:RegisterEvent("UI_ERROR_MESSAGE")
autodismountFrame:RegisterEvent("TAXIMAP_OPENED")