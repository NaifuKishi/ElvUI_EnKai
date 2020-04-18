local E, L, V, P, G, _ =  unpack(ElvUI);

local EK = E:GetModule('ElvUI_EnKai')

local _G = _G

local GetMerchantNumItems = GetMerchantNumItems
local GetMerchantItemInfo = GetMerchantItemInfo
local GetMerchantItemLink = GetMerchantItemLink
local GetItemInfo = GetItemInfo
local BuyMerchantItem = BuyMerchantItem

local frame
local restockItems
local lastTimeRestocked = GetTime()

local function onEvent(self, event, ...)

    local args = {...}
	
	if E.db.ElvUI_EnKai.RESTOCK == false then return end

    if event == "MERCHANT_SHOW" then
	
		if GetTime() - lastTimeRestocked < 1 then return end -- If vendor repoened within 1 second then return (only activate addon once per second)
        lastTimeRestocked = GetTime()
		
		local buyTable = {}		
		
		for i = 0, #restockItems, 1 do
			if E.db.ElvUI_EnKai["RESTOCKERITEM" .. tostring(i)] == true then
				local itemName, _, _, _, _, _, _, itemStackCount = GetItemInfo(restockItems[i])
				--if itemInfo then buyTable[itemName] = itemStackCount end
								
				local numInBags = GetItemCount(itemName, false)
				
				local numNeeded =  E.db.ElvUI_EnKai["RESTOCKERAMOUNT" .. tostring(i)] - numInBags
    
				if numNeeded > 0 then
					if not buyTable[itemName] then
						buyTable[itemName] = { needed = numNeeded, itemID = restockItems[i], stackCount = itemStackCount }
						--buyTable[item.itemName]["itemLink"] = item.itemLink
					end
				end
			end
		end
		
		for i = 0, GetMerchantNumItems() do
			local itemName, _, _, _, numAvailable = GetMerchantItemInfo(i)

			if buyTable[itemName] then
				if buyTable[itemName].needed > numAvailable and numAvailable > 0 then
					BuyMerchantItem(i, numAvailable)
				else
					for j = buyTable[itemName].needed, 1, -buyTable[itemName].stackCount do
						if j > buyTable[itemName].stackCount then
							BuyMerchantItem(i, buyTable[itemName].stackCount)
						else
							BuyMerchantItem(i, j)
						end
					end
				end
			end
		end
		
        return
    end

end


function EK:Restocker_Init(classItems)

	restockItems = classItems

	frame = CreateFrame('Frame', 'ElvUI_EnKai_AutoDismount_Frame', E.UIParent)
	frame:SetScript("OnEvent", onEvent);
	
	
--events:RegisterEvent("MERCHANT_SHOW");
--events:RegisterEvent("MERCHANT_CLOSED");
--events:RegisterEvent("BANKFRAME_OPENED");
--events:RegisterEvent("BANKFRAME_CLOSED");
--events:RegisterEvent("GET_ITEM_INFO_RECEIVED");
--events:RegisterEvent("PLAYER_LOGOUT");
--events:RegisterEvent("PLAYER_ENTERING_WORLD");
--events:RegisterEvent("UI_ERROR_MESSAGE");

	
	frame:RegisterEvent("MERCHANT_SHOW")

end