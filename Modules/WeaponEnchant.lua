local E, L, V, P, G, _ =  unpack(ElvUI);

local _G = _G

local frame = CreateFrame('Frame', 'ElvUI_EnKai_Poison_Frame', E.UIParent)
frame.events = {}
frame:SetScript("OnEvent", function(self,event,...)

	frame.events[event](self,event,...)

end)

function f.events.UNIT_INVENTORY_CHANGED(self,event,unit,...)
	
	-- if unit ~= "player" then return end
	
	-- local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo()
	
	-- PoisonerTimer_MainhandText:SetText((mainHandCharges and mainHandCharges>0 and mainHandCharges) or "")
	-- PoisonerTimer_OffhandText:SetText((offHandCharges and offHandCharges>0 and offHandCharges) or "")
	
	-- if mainHandCharges and mainHandCharges > 0 and mainHandCharges <= chargeThreshold then
		-- if (not Poisoner_MinWarning1) then
			-- local stacks = string.format(STACKS,mainHandCharges)
			-- if (POISONER_CONFIG.Timer.Output.Audio == 1) then
				-- PoisonerSound_PlaySound("expiring")
			-- end
			-- if (POISONER_CONFIG.Timer.Output.Chat == 1) then
				-- PoisonerTimer_Print("Poisoner_ExpirationWarning", DEFAULT_CHAT_FRAME, INVTYPE_WEAPONMAINHAND, stacks, "", 33)
			-- end
			-- if (POISONER_CONFIG.Timer.Output.ErrorFrame == 1) then
				-- PoisonerTimer_Print("Poisoner_ExpirationWarning", UIErrorsFrame, INVTYPE_WEAPONMAINHAND, stacks, "", 33)
			-- end
			-- if (POISONER_CONFIG.Timer.Output.Aura == 1) then
				-- PoisonerTimer_UpdateIconFrame(PoisonerTimer_Mainhand, PoisonerTimer_MainhandIcon, 16, 0.5, mainHandCharges)
			-- end
			-- Poisoner_MinWarning1 = true
		-- end
	-- elseif offHandCharges and offHandCharges > 0 and offHandCharges <= chargeThreshold then
		-- if (not Poisoner_MinWarning2) then
			-- local stacks = string.format(STACKS,offHandCharges)
			-- if (POISONER_CONFIG.Timer.Output.Audio == 1) then
				-- PoisonerSound_PlaySound("expiring")
			-- end
			-- if (POISONER_CONFIG.Timer.Output.Chat == 1) then
				-- PoisonerTimer_Print("Poisoner_ExpirationWarning", DEFAULT_CHAT_FRAME, INVTYPE_WEAPONOFFHAND, stacks, "", 33)
			-- end
			-- if (POISONER_CONFIG.Timer.Output.ErrorFrame == 1) then
				-- PoisonerTimer_Print("Poisoner_ExpirationWarning", UIErrorsFrame, INVTYPE_WEAPONOFFHAND, stacks, "", 34)
			-- end
			-- if (POISONER_CONFIG.Timer.Output.Aura == 1) then
				-- PoisonerTimer_UpdateIconFrame(PoisonerTimer_Offhand, PoisonerTimer_OffhandIcon, 17, 0.5, offHandCharges)
			-- end
		-- end
		-- Poisoner_MinWarning2 = true
	end
	
end

function f.events.PLAYER_EQUIPMENT_CHANGED(self,event,slotId)
	-- if not slotIdsToCheck[slotId] then
		-- return
	-- end
		
	-- local id = GetInventoryItemID("player",slotId)
	
	-- local itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(id or 0)
	-- local isWeapon = itemClassID == 2
	
	-- if slotId == 16 then
		-- isfishing = isWeapon and itemSubClassID == fishingPoleSubId
		-- mainHand_isWeapon = isWeapon
	-- else
		-- offHand_isWeapon = isWeapon
	-- end
	
end

function f.events.PLAYER_LOGIN(self,event)
	-- for k,v in pairs(slotIdsToCheck) do
		-- f.events.PLAYER_EQUIPMENT_CHANGED(self,event,k)
	-- end
end

for k,v in pairs(frame.events) do
	frame:RegisterEvent(k)
end

