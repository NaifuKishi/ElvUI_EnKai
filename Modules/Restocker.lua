local E, L, V, P, G, _ =  unpack(ElvUI);

local EK = E:GetModule('ElvUI_EnKai')

local _G = _G

local GetMerchantNumItems = GetMerchantNumItems
local GetMerchantItemInfo = GetMerchantItemInfo
local GetMerchantItemLink = GetMerchantItemLink
local GetItemInfo = GetItemInfo
local BuyMerchantItem = BuyMerchantItem
local GetTime = GetTime
local CreateFrame = CreateFrame

local restockerFrame, restockItems
local lastTimeRestocked = GetTime()

local function restocker_OnEvent(self, event, ...)

	if E.db.ElvUI_EnKai.RESTOCK == false then return end

    if event == "MERCHANT_SHOW" then
	
		if GetTime() - lastTimeRestocked < 1 then return end -- If vendor repoened within 1 second then return (only activate addon once per second)
        lastTimeRestocked = GetTime()
		
		local toBuyTable = {}		
		
		for i = 0, #restockItems, 1 do
			if E.db.ElvUI_EnKai["RESTOCKERITEM" .. tostring(i)] == true then
				local itemName, _, _, _, _, _, _, itemStackCount = GetItemInfo(restockItems[i])
								
				local amountInBags = GetItemCount(itemName, false)
				
				local amountNeeded =  E.db.ElvUI_EnKai["RESTOCKERAMOUNT" .. tostring(i)] - amountInBags
    
				if amountNeeded > 0 then
					if not toBuyTable[itemName] then
						toBuyTable[itemName] = { needed = amountNeeded, itemID = restockItems[i], stackCount = itemStackCount }
					end
				end
			end
		end
		
		for i = 0, GetMerchantNumItems() do
			local itemName, _, _, _, numAvailable = GetMerchantItemInfo(i)

			if toBuyTable[itemName] then
				if toBuyTable[itemName].needed > numAvailable and numAvailable > 0 then
					BuyMerchantItem(i, numAvailable)
				else
					for j = toBuyTable[itemName].needed, 1, -toBuyTable[itemName].stackCount do
						if j > toBuyTable[itemName].stackCount then
							BuyMerchantItem(i, toBuyTable[itemName].stackCount)
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
	restockerFrame = CreateFrame('Frame', 'ElvUI_EnKai_RestockerFrame', E.UIParent)
	restockerFrame:SetScript("OnEvent", restocker_OnEvent);
	restockerFrame:RegisterEvent("MERCHANT_SHOW")

end