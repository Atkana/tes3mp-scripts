-- salesChest - Release 2 - For tes3mp v0.6.1

--[[ INSTALLATION:
1) Save this file as "salesChest.lua" in mp-stuff/scripts
2) Add [ salesChest = require("salesChest") ] to the top of server.lua
3) Add the following to the elseif chain for commands in "OnPlayerSendMessage" inside server.lua

[	elseif cmd[1] == "saleschest" then
		salesChest.OnSalesChestCommand(pid) ]

4) Add the following to OnGUIAction in server.lua
	[ salesChest.OnContainer(pid, cellDescription) ]
5) Add the following to OnContainer in server.lua
	[ if salesChest.OnGUIAction(pid, idGui, data) then return end ]
6) Add the following beneath UpdateTime() in server.lua
	[ salesChest.LoopHack() ]
]]

local config = {}

--Main Config Options
config.considerItemWear = true -- Whether to modify the price of an item based on its current durability/uses
config.ultimateMultiplier = 1 -- After all the price calculations, the price is then multiplied by this amount. Alter this if you want to make selling via sales chest to be more/less favourable compared to regular trading. For 75%, this variable would be 0.75
--Minor Config Options
config.assignContainerTimeout = 30 --Time players have to assign a new container after selecting the option in the GUI
config.shareChests = true --If true, multiple players are allowed to use the same container as their sales chest
config.guiId = 31336 --Used internally for the GUI id. If this randomly generated number somehow conflicts with another script's, change this number.

--Release 2 additions
config.mode = "private" -- "private" or "global". In private mode, players claim their own containers to sell from. In global mode, while players can still claim their own containers, they sell items from a globally designated chest (designated by the following config options:)
-- The following must be manually entered
config.globalRefIndex = ""
config.globalCell = ""
config.globalRefId = ""

config.sellMode = "basic" --governs how the price of items are calculated, see the list below for all the options and details.
--[[ List of sellModes:
"creature" - The price isn't modified by any skill, as if they were being sold to the creature merchants
"basic" - The price of items sold is modified by the seller's mercantile skill, using the skill as a percentage (level 42 mercantile means they get 42% of the price)
"tac" - The base price of items sold begins at a flat percent (default: 50%), with the percentage increasing by a set amount (default: 0.5%) for every point in mercantile. The system is entirely lifted from the Oblivion mod "Trade and Commerce"
"advanced" - The price is modified by a simplified version of the game's price calculation formula. Attributes aren't factored into the simplified calculation, though a player's personality is used as a stand-in for disposition. Note: because this uses Morrowind's calculation formula, it includes all the jankiness that comes with it (look up the Merchant Bug)
]]
-- Config options for "tac" sell mode
config.tacBase = 0.5 --Base percent use
config.tacMercIncrease = 0.005 --The percent bonus added for each level in mercantile (0.005 is 0.5%)
config.tacPersIncrease = 0 --The percent bonus added for each point of personality
-- Config options for "advanced" sell mode
config.advTraderSkill = 50 --The effective mercantile skill that the fake trader has
config.advPersonalityMod = 1 --% to modify personality by when using it to calculate the disposition with the fake trader

Methods = {}

require("time")
itemInfo = require("itemInfo")

--[[ WorldInstance.data.customVariables.salesChest structure
containers {
	[playername key] = {
		[refIndex],
		[cell]
		[refId]
		-- The following three are used for passing data between some functions:
		[evaluation]
		[itemNum]
		[sellableNum]
	}
}

]]

local pendingAssignments = {}

-- Not sure of the implications of leaving some of my functions to be non-local, so I'll make them usable and local here:
local GetSalesChestTable, GetSalesChest, RegisterAssignmentTimer, UnassignSalesChest, ValidSalesChestCheck, UnregisterAssignmentTimer, SalesChestRegisterTimeout, AssignSalesChest, CheckChestExists, GetContainerInventory, SellChestContents, GetModifiedPrice, OnSellButton, unequipActor

--This is the special chest used by everyone when config.mode is global
local gchest = {}

-- =======
--  SELLING
-- =======

--Return modified base price for if damaged (if weapon or armour), or used (if hammer, pick, probe, etc.), as well as based on the player's merch skill
function GetModifiedPrice(item, merchSkill, personality)
	local price = 0 --Start at base price
	local idata = itemInfo.GetItemData(item.refId)
	
	if item == "gold_001" then --We don't want to sell gold
		return 0
	end
	
	if idata then
		price = itemInfo.GetItemValue(item.refId)
	end
	--There's no value to an item without data, or a cost of 0
	if price == 0 then
		return 0
	end
	
	--Damage/Usage Calculation
	if config.considerItemWear then
		if item.charge ~= -1 then -- -1 represents either something that doesn't take damage, or is completely undamaged/used. Weirdly,
			if idata then --technically don't need to test this since we wouldn't be this far in if it was nil, but oh well
				local itype = itemInfo.GetItemType(item.refId)
				if itype == "repair item" or "probe" or "lockpick" or "armor" or "weapon" then
					local maxdur = itemInfo.GetMaxDurability(item.refId)
					local curdur = item.charge
					local damPercent
					
					--Make sure to only apply this to items that actually use durability (some weapons don't)
					if maxdur then
						if curdur ~= 0 then
							price = price * (curdur/maxdur)
						else
							--The price of a completely damaged item is 0
							return 0
						end
					end					
				end
			end
		end
	end
	
	--New Merchant skill calculation
	if config.sellMode == "creature" then
		--Do nothing
	elseif config.sellMode == "tac" then
		local mod = math.min(config.tacBase + (config.tacMercIncrease * merchSkill) + (config.tacPersIncrease * personality), 1) --Capped at 1 (100%)
		
		price = price * mod		
	elseif config.sellMode == "advanced" then
		-- Extrapolated from https://wiki.openmw.org/index.php?title=Research:Trading_and_Services#Barter_function
		local pcTerm = (personality * config.advPersonalityMod) - 50 + merchSkill
		local npcTerm = config.advTraderSkill
		
		local buyTerm = 0.01 * (100 - 0.5 * (pcTerm - npcTerm))
		local sellTerm = 0.01 * (50 - 0.5 * (npcTerm - pcTerm))
		
		local mod = math.min(buyTerm,sellTerm)
		
		price = price * mod
	else -- Assume we're using the basic mode
		price = price * (math.min(merchSkill,100)/100)
	end
	
	--Multiply by the ultimate multiplier as outlined in the configs
	price = price * config.ultimateMultiplier
	--Price is rounded down before being returned
	price = math.floor(price)
	return price	
end

--Following doesn't currently work properly in this version of tes3mp
--[[
function unequipActor(pid, refIndex, cellDescription)

    tes3mp.InitializeActorList(pid)
    tes3mp.SetActorListCell(cellDescription)

    local splitIndex = refIndex:split("-")
    tes3mp.SetActorRefNumIndex(splitIndex[1])
    tes3mp.SetActorMpNum(splitIndex[2])

    for itemIndex = 0, tes3mp.GetEquipmentSize() - 1 do
        tes3mp.UnequipActorItem(itemIndex)
    end

    tes3mp.AddActor()
    tes3mp.SendActorEquipment()

end
]]

function GetContainerInventory(chest)
	if LoadedCells[chest.cell] == nil then
		myMod.LoadCell(chest.cell)
	end
	local ref = LoadedCells[chest.cell].data.objectData[chest.refIndex]	
	
	--Following functionality broken:
	--[[
	--If the container is an actor, remove the equipment and send the changes to everyone
	if ref.equipment ~= nil then
		for k, v in pairs(Players) do
			unequipActor(k, chest.refIndex, chest.cell)
		end
	end
	]]
	
	if ref.inventory ~= nil then
		return ref.inventory
	end
end

--Function to sell the chest contents and price up the chest contents rolled into one.
function SellChestContents(chest, priceOnly, merchSkill, personality)
	inv = GetContainerInventory(chest)
	local itemNum = 0
	local sellNum = 0
	local price = 0
	
	for index, item in pairs(inv) do
		local iprice = GetModifiedPrice(item, merchSkill, personality)
		itemNum = itemNum + (1 * item.count)
		
		--Only sell items that'll fetch a non-zero price
		if iprice > 0 then
			sellNum = sellNum + (1 * item.count)
			price = price + (iprice * item.count)
			
			if priceOnly then
				--Do nothing
			else
				--Sell the item (remove it from the chest)
				inv[index] = nil
			end
		end
	end
	
	if priceOnly then
		return itemNum, sellNum, price
	else
		--Cleanup all the empty entries caused from selling the items:
		 tableHelper.cleanNils(inv)
		 --Send container updates to all players
		 for k, v in pairs(Players) do
			LoadedCells[chest.cell]:SendContainers(k) --Sell should in theory still be loaded from the GetContainerInventory() call earlier
		 end
		return price
	end	
end

OnSellButton = function(pid)
	local pmerch = tes3mp.GetSkillBase(pid, 24)
	local ppers = tes3mp.GetAttributeBase(pid, 6)
	local chest
	
	
	if config.mode == "global" then
		local gExistsCheck = CheckChestExists(gchest)
		if gExistsCheck then
			chest = gchest
		else
			tes3mp.MessageBox(pid, -1, "The global container doesn't exist anymore.")
			return false
		end		
	else
		--Make sure they actually have a sales chest
		if GetSalesChest(pid) then --Player currently has a chest recorded
			chest = GetSalesChest(pid)
			--Make sure that container still exists
			local existsCheck = CheckChestExists(chest, pid)
			if existsCheck == false then
				chest = nil
			end
		end
		
		if chest == nil then
			tes3mp.MessageBox(pid, -1, "You need to assign a container before you can sell its contents!")
			return false
		end
	end
	
	--Do checks to make sure the situation hasn't changed since the player opened the GUI. May be buggy if more than one player is doing this while global is enabled
	 local checkItemNum, checkSellableNum, checkEvaluation = SellChestContents(chest, true, pmerch, ppers)
	
	if (checkItemNum ~= chest.itemNum) or (checkSellableNum ~= chest.sellableNum) or (checkEvaluation ~= chest.evaluation) then
		tes3mp.MessageBox(pid, -1, "The contents of your container have changed, please try again.")
		return false
	end
	
	if chest.evaluation <= 0 then
		--Nothing to sell
		return false
	end
	
	--If we've gotten here, we're free to go
	local money = SellChestContents(chest, false, pmerch, ppers)
	--Add money to player inventory
	local goldLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, "gold_001", -1)
	
	if goldLoc then
		Players[pid].data.inventory[goldLoc].count = Players[pid].data.inventory[goldLoc].count + money
	else
		table.insert(Players[pid].data.inventory, {refId = "gold_001", count = money, charge = -1})
	end
	Players[pid]:LoadInventory()
	Players[pid]:LoadEquipment()
	tes3mp.MessageBox(pid, -1, "Success! " .. money .. " gold has been added to your inventory.")
end

-- ========
-- INTERFACE
-- ========

Methods.OnSalesChestCommand = function(pid)
	local pname = tes3mp.GetName(pid)
	local message = ""
	local pchest
	local pmerch = tes3mp.GetSkillBase(pid, 24)
	local ppers = tes3mp.GetAttributeBase(pid, 6)

	if GetSalesChest(pid) then --Player currently has a chest recorded
		pchest = GetSalesChest(pid)
		--Make sure that container still exists
		local existsCheck = CheckChestExists(pchest, pid)
		if existsCheck == false then
			pchest = nil
		end
	end
	
	if config.mode == "global" then
		gchest.refIndex = config.globalRefIndex
		gchest.cell = config.globalCell
		gchest.refId = config.globalRefId
		
		message = message .. "Global mode is enabled on this server, this means that while you can still assign yourself a private container, only the globally-assigned sales chest can be used for selling.\n"
		
		local gExistsCheck = CheckChestExists(gchest)
		if gExistsCheck then
			gchest.itemNum, gchest.sellableNum, gchest.evaluation = SellChestContents(gchest, true, pmerch, ppers)
			message = message .. "The global sales chest:\n" .. "Name: " .. gchest.refId .. "\nLocated in :" .. gchest.cell .. "\n" .. gchest.sellableNum .. "/" .. gchest.itemNum .. " of the items contained within can be sold for a total of " .. gchest.evaluation .. " gold.\n\n"
		else
			message = message .. "The global sales chest is either missing or invalid. Contact your server operator.\n"
		end
	end
	
	--If the player sales chest is valid and still exists then they get a custom message.
	if pchest then
		pchest.itemNum, pchest.sellableNum, pchest.evaluation = SellChestContents(pchest, true, pmerch, ppers)
		WorldInstance:Save() --Save the evaluations
		message = message .. ("Your current sales chest:\n" .. "Name: " .. pchest.refId .. "\nLocated in: " .. pchest.cell .. "\n" .. pchest.sellableNum .. "/" .. pchest.itemNum .. " of the items contained within can be sold for a total of " .. pchest.evaluation .. " gold.")
	else
		message = message .. "You don't have a personal container"
	end
	tes3mp.CustomMessageBox(pid, config.guiId, message, 'Sell Items;Assign Container;Close')
end

Methods.OnGUIAction = function(pid, idGui, data)
	if idGui == config.guiId then
		if tonumber(data) == 0 then -- Sell Button
			OnSellButton(pid)
			return true
		elseif tonumber(data) == 1 then -- Assign new
			--TODO
			RegisterAssignmentTimer(pid)
			return true
		elseif tonumber(data) == 2 then --Close
			--Don't think I have to do anything here?
			return true
		end
	end
	return false
end

-- =============
-- REGISTER SYSTEM
-- =============

Methods.OnContainer = function(pid, cellDescription)
	tes3mp.ReadLastEvent()
	local action = tes3mp.GetEventAction()
	local pname
	
	if Players[pid] ~= nil then
		pname = tes3mp.GetName(pid)
	else
		return
	end
	
	if pendingAssignments[pname] ~= nil then --The register system is waiting for this player
		if action == actionTypes.container.ADD then
			--Get the container's data
			local refIndex = tes3mp.GetObjectRefNumIndex(0) .. "-" .. tes3mp.GetObjectMpNum(0)
			local refId = tes3mp.GetObjectRefId(0)
			
			--Check the container is valid for the player to use
			local check, reason = ValidSalesChestCheck(pid, refIndex)
			if check then
				AssignSalesChest(pid, refIndex, refId, cellDescription)
				tes3mp.MessageBox(pid, -1, "Assigned " .. refId .. " in " .. cellDescription .. " as your sales chest.")
			else --returned false
				tes3mp.MessageBox(pid, -1, "Couldn't assign that container: " .. reason)
			end
			UnregisterAssignmentTimer(pname)
		end
	end
end

CheckChestExists = function(chest, pid)
	if LoadedCells[chest.cell] == nil then
		myMod.LoadCell(chest.cell)
	end
	if LoadedCells[chest.cell]:ContainsObject(chest.refIndex) and not tableHelper.containsValue(LoadedCells[chest.cell].data.packets.delete, chest.refIndex)
	then
		return true
	else
		if pid == nil then -- CheckChestExists was called to check if a global chest exists
			return false
		else
			--Clear out the player's sales chest data
			UnassignSalesChest(pid)
			return false
		end
	end
end

--Assuming all the checks are okay, link the chest to the player
AssignSalesChest = function(pid, refIndex, refId, cellDescription)
	local pname = tes3mp.GetName(pid)
	local chests = GetSalesChestTable()
	
	local data = {}
	data.refIndex = refIndex
	data.refId = refId
	data.cell = cellDescription
	
	chests[pname] = data
	WorldInstance:Save()
end


function GetSalesChestTable()
	--If there's no data, create it
	if WorldInstance.data.customVariables.salesChest == nil then
		WorldInstance.data.customVariables.salesChest = {}
		WorldInstance.data.customVariables.salesChest.containers = {}
		WorldInstance:Save()
	end
	
	return WorldInstance.data.customVariables.salesChest.containers
end


function GetSalesChest(pid)
	local pname = tes3mp.GetName(pid)
	local chests = GetSalesChestTable()
	
	if chests[pname] and chests[pname].refIndex ~= nil then
		return chests[pname]
	else
		return false
	end
end


function RegisterAssignmentTimer(pid)
	local pname = tes3mp.GetName(pid)
	
	--Unregister player's current saleschest
	UnassignSalesChest(pid)
	
	if pendingAssignments[pname] == nil then
		--Create an entry for the player
		pendingAssignments[pname] = {}
		pendingAssignments[pname].pid = pid
		pendingAssignments[pname].pname = pname
	end
	--Start/Reset the countdown timer
	pendingAssignments[pname].time = config.assignContainerTimeout
	tes3mp.LogMessage(1,("Began sales chest registration timer for ".. pname))
	
	-- Inform the player
	tes3mp.MessageBox(pid, -1, "The next container you place an item in will be registered as your sales chest.\n You have " .. config.assignContainerTimeout .. " seconds to assign a container.\nNOTE: Using corpses which equip items as your sales chest is currently buggy - avoid using them.")
end


function UnassignSalesChest(pid)
	local pname = tes3mp.GetName(pid)
	local chestTab = GetSalesChestTable()
	
	chestTab[pname] = {}
	WorldInstance:Save()
	tes3mp.LogMessage(1,("Unassigned sales chest for ".. pname))
end


function ValidSalesChestCheck(pid, refIndex)
	local pname = tes3mp.GetName(pid)
	--Check the chest is an allowed container
	--TODO
	--Check the chest isn't already being used by another player (if that's set as disallowed in the config)
	if config.shareChests == false then
		local chests = GetSalesChestTable()
		for k, v in pairs(chests) do
			if v.refIndex == refIndex and k ~= pname then --The player shouldn't ever have an entry in the table if they're looking to assign one, but we may as well check anyway
				return false, "Another player is already using this container."
			end
		end
	end
	return true
end


function UnregisterAssignmentTimer(pname)
	pendingAssignments[pname] = nil
	--tes3mp.LogMessage(1,("Timer unregistered for ".. pname))
end


function SalesChestRegisterTimeout(pid, pname)
	if Players[pid] ~= nil and Players[pid].name == pname then
		tes3mp.MessageBox(pid, -1, "You took too long to assign a container.")
	else
		--Don't message
	end	
	UnregisterAssignmentTimer(pname)
	tes3mp.LogMessage(1,("Sales chest assignment timer expired for ".. pname))
end

-- I give up trying to work out how those blasted timers work - now it's time for hacking all the way!
Methods.LoopHack = function()
	for k, v in pairs(pendingAssignments) do
		v.time = v.time - 1
		if v.time <= 0 then --Timer's up
			SalesChestRegisterTimeout(v.pid, v.pname)
		end
	end
end

return Methods
