-- salesChest - Release 1 - For tes3mp v0.6.1

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
config.creatureMerchants = false --If true, items will sell for 100% of their base price, otherwise the price will be modified by their mercantile skill, using the skill as a percentage (level 42 mercantile means they get 42% of the price)
config.considerItemWear = true -- Whether to modify the price of an item based on its current durability/uses
config.ultimateMultiplier = 1 -- After all the price calculations, the price is then multiplied by this amount. Alter this if you want to make selling via sales chest to be more/less favourable compared to regular trading. For 75%, this variable would be 0.75
--Minor Config Options
config.assignContainerTimeout = 30 --Time players have to assign a new container after selecting the option in the GUI
config.shareChests = true --If true, multiple players are allowed to use the same container as their sales chest
config.guiId = 31337 --Used internally for the GUI id. If this randomly generated number somehow conflicts with another script's, change this number.

--HACK config options
config.globalRefIndex = "a refIndex"
config.globalCell = "a cell description"
config.globalRefId = "a refId"

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

-- =======
--  SELLING
-- =======

--Return modified base price for if damaged (if weapon or armour), or used (if hammer, pick, probe, etc.), as well as based on the player's merch skill
function GetModifiedPrice(item, merchSkill)
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
	
	--Merchant skill calculation
	if config.creatureMerchants then --Finished
		--Do nothing
	else --Consider the player's merchant skills
		--Until I can think up a decent calculation, the player's merchant skill will simply represent the % of the price they can get
		price = price * (math.min(merchSkill,100)/100) --math min to cap merchSkill at 100, though I don't see why it would ever be over that
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
function SellChestContents(chest, priceOnly, merchSkill)
	inv = GetContainerInventory(chest)
	local itemNum = 0
	local sellNum = 0
	local price = 0
	
	for index, item in pairs(inv) do
		local iprice = GetModifiedPrice(item, merchSkill)
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
	local pchest
	
	--Make sure they actually have a sales chest
	if GetSalesChest(pid) then --Player currently has a chest recorded
		pchest = GetSalesChest(pid)
		--Make sure that container still exists
		local existsCheck = CheckChestExists(pchest, pid)
		if existsCheck == false then
			pchest = nil
		end
	end
	
	if pchest == nil then
		tes3mp.MessageBox(pid, -1, "You need to assign a container before you can sell its contents!")
		return false
	end
	
	--Do checks to make sure the situation hasn't changed since the player opened the GUI
	local checkItemNum, checkSellableNum, checkEvaluation = SellChestContents(pchest, true, pmerch)
	
	if (checkItemNum ~= pchest.itemNum) or (checkSellableNum ~= pchest.sellableNum) or (checkEvaluation ~= pchest.evaluation) then
		tes3mp.MessageBox(pid, -1, "The contents of your container have changed, please try again.")
		return false
	end
	
	if pchest.evaluation <= 0 then
		--Nothing to sell
		return false
	end
	
	--If we've gotten here, we're free to go
	local money = SellChestContents(pchest, false, pmerch)
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
	local message
	local pchest
	local pmerch = tes3mp.GetSkillBase(pid, 24)

	if GetSalesChest(pid) then --Player currently has a chest recorded
		pchest = GetSalesChest(pid)
		--Make sure that container still exists
		local existsCheck = CheckChestExists(pchest, pid)
		if existsCheck == false then
			pchest = nil
		end
	end
	
	--HACK
	if pchest == nil then
		AssignSalesChest(pid, config.globalRefIndex, config.globalRefId, config.globalCell)
	end
	
	--If the player sales chest is valid and still exists then they get a custom message.
	if pchest then
		pchest.itemNum, pchest.sellableNum, pchest.evaluation = SellChestContents(pchest, true, pmerch)
		WorldInstance:Save() --Save the evaluations
		message = ("Your current sales chest:\n" .. "Name: " .. pchest.refId .. "\nLocated in: " .. pchest.cell .. "\n" .. pchest.sellableNum .. "/" .. pchest.itemNum .. " of the items contained within can be sold for a total of " .. pchest.evaluation .. " gold.")
		--TEMP
		GetContainerInventory(pchest)
	else
		message = "You don't have a container"
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
			--RegisterAssignmentTimer(pid)
			-- HACK: Do nothing
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
		--Clear out the player's sales chest data
		UnassignSalesChest(pid)
		return false
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
