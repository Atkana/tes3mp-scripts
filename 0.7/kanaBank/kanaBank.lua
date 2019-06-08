-- kanaBank - Release 3 - For tes3mp 0.7-alpha
-- Implements a banking system for players to utilise

--[[ INSTALLATION
= GENERAL =
a) Save this file as "kanaBank.lua" in server/scripts/custom

= IN customScripts.LUA =
a) kanaBank = require("custom.kanaBank")
]]

local scriptConfig = {}

scriptConfig.useBankerRank = 0 -- The staffRank required to use a bank via bankers
scriptConfig.useBankCommandRank = 0 -- The staffRank required to use the /bank command
scriptConfig.openOtherPlayersBankRank = 1 -- The staffRank required to use the /bank playername command

-- Any object that's identified as a "banker" will open a player's bank on activation
-- Provided the player meets the useBankerRank requirement. This /should/ override the default activation
scriptConfig.bankerRefIds = {"m'aiq",}
scriptConfig.bankerUniqueIndexes = {}

-- Setting the following to true will have the script block any attempts at deleting a banker/bank storage item respectively
-- Note that having them false doesn't guarantee attempts will always be successful - other things might also block its deletion.
scriptConfig.denyBankerDelete = true
scriptConfig.denyBankStorageDelete = true

scriptConfig.baseObjectRefId = "dead rat"
scriptConfig.baseObjectRecordType = "creature"
scriptConfig.storageCell = "Clutter Warehouse - Everything Must Go!" -- The cell that will contain all the player's bank containers. Use a cell that can't be visited (like a debug cell). If running a cell resetting script, ensure the provided cell is exempt from resetting (if using Atkana's CellReset, this'll automatically be registered)!

scriptConfig.logging = true
scriptConfig.debug = false

scriptConfig.recordRefId = "kanabankcontainer" -- Used internally for this script's base permanent record id. There should be no reason you'd need to change it

local lang = {
	["openOtherPlayerBankFailNoRank"] = "You don't have the required staff rank to open other player's banks.",
	["openOtherPlayerBankFailNoPlayer"] = "Couldn't find a bank for the player %name.",
	["useBankCommandFailNoRank"] = "You don't have the required staff rank to use the /bank command.",
	["useBankerFailNoRank"] = "You don't have the required staff rank to use bankers.",
	
	["baseBankContainerDisplayName"] = "Bank Storage",
	["yourStorageName" ] = "Your Bank Storage",
	["otherPlayerStorageName"] = "%name's Bank Storage",
}

---------------------------------------------------------------------------------------

local Methods = {}

local scriptData = {links = {}}
local scriptTemp = {bankerRefIds = {}, bankerUniqueIndexes = {}}

Methods.GetLangText = function(key, data)
	local function replacer(wildcard)
		if data[wildcard] then
			return data[wildcard]
		else
			return ""
		end
	end
	
	local text = lang[key] or ""
	text = text:gsub("%%(%w+)", replacer)
	
	return text
end

Methods.Save = function()
	jsonInterface.save("custom/kanaBank.json", scriptData)
end

Methods.Load = function()
	local loadedData = jsonInterface.load("custom/kanaBank.json")
	
	if loadedData then
		scriptData = loadedData
	else
		-- There wasn't a json saved for this script, so we'll make one
		-- (We'll be using the default scriptData as is)
		Methods.Save()
	end
end

local function doLog(message)
	if scriptConfig.logging then
		tes3mp.LogMessage(1, "[kanaBank] - " .. message)
	end
end

local function doDebug(message)
	if scriptConfig.debug then
		tes3mp.LogMessage(1, "[kanaBank DEBUG] - " .. message)
	end
end

---------------------------------------------------------------------------------------
local function getName(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		return Players[pid].accountName
	end
end

-- Quick lazy function to message player so I don't have to type out the whole function + remember to add a newline to the end :P
local function msg(pid, message)
	tes3mp.SendMessage(pid, message .. "\n")
end

-- Technically I could just always do logicHandler.LoadCell(scriptConfig.storageCell) and it'd accomplish the same thing...
local function ensureCellLoaded()
	if LoadedCells[scriptConfig.storageCell] == nil then
		logicHandler.LoadCell(scriptConfig.storageCell)
	end
end

-- Temporarily changes the name of all instances of an object of the given refId for a player
-- The refId to change need not be an actual custom record! Any refId works fine.
-- Need to provide the recordType of the record
Methods.RenameRecordForPid = function(pid, newName, refId, recordType)
	tes3mp.ClearRecords()
	tes3mp.SetRecordType(enumerations.recordType[string.upper(recordType)])
	
	packetBuilder.AddRecordByType(refId, {baseId = refId, name = newName}, recordType)

	tes3mp.SendRecordDynamic(pid, false, false)
end

Methods.RegisterBankerRefId = function(refId)
	scriptTemp.bankerRefIds[refId] = true
	doDebug("Registered banker refId: " .. refId)
end

Methods.RegisterBankerUniqueIndex = function(uniqueIndex)
	scriptTemp.bankerUniqueIndexes[uniqueIndex] = true
	doDebug("Registered banker uniqueIndex: " .. uniqueIndex)
end

Methods.IsAllowedDeleteUniqueIndex = function(uniqueIndex)
	-- Check to protect bankers if configured
	if scriptConfig.denyBankerDelete then
		if Methods.IsBankerUniqueIndex(uniqueIndex) then
			return false
		end
	end
	
	-- Check to protect bank storage if configured
	if scriptConfig.denyBankStorageDelete then
		if Methods.IsBankStorageUniqueIndex(uniqueIndex) then
			return false
		end
	end
	
	-- If we get here, we're fine
	return true
end

Methods.IsAllowedDeleteRefId = function(refId)
	-- Check to protect bankers if configured
	if scriptConfig.denyBankerDelete then
		if Methods.IsBankerRefId(refId) then
			return false
		end
	end
	
	-- If we get here, we're fine
	return true
end

-- Returns true if provided uniqueIndex belongs to a banker
Methods.IsBankerUniqueIndex = function(uniqueIndex)
	return scriptTemp.bankerUniqueIndexes[uniqueIndex] or false
end

-- Returns true if provided refId belongs to a banker
Methods.IsBankerRefId = function(refId)
	return scriptTemp.bankerRefIds[refId] or false
end

-- Returns true if provided uniqueIndex belongs to a player's bank storage
Methods.IsBankStorageUniqueIndex = function(uniqueIndex)
	for playerName, storageUniqueIndex in pairs(scriptData.links) do
		if storageUniqueIndex == uniqueIndex then
			return true
		end
	end
	
	-- If we get here, we haven't found anything, so it's not a bank storage for anyone
	return false
end

Methods.GetPlayerContainerUniqueIndex = function(playerName)
	return scriptData.links[string.lower(playerName)] or false
end

Methods.DoesPlayerHaveContainer = function(playerName)
	local uniqueIndex = Methods.GetPlayerContainerUniqueIndex(playerName)
	
	if uniqueIndex then
		-- Check to make sure that the object still exists
		ensureCellLoaded()
		
		if LoadedCells[scriptConfig.storageCell]:ContainsObject(uniqueIndex) then
			return true
		else
			-- Somehow, the player's storage has been deleted.
			-- We should remove the links
			Methods.RemovePlayerContainerLink(playerName)
			return false
		end
	else --There's no recorded link for that player
		return false	
	end
end

Methods.AddPlayerContainerLink = function(playerName, uniqueIndex)
	scriptData.links[string.lower(playerName)] = uniqueIndex
	Methods.Save()
	
	doDebug("Added new link to container " .. uniqueIndex .. " for " .. playerName)
end

Methods.RemovePlayerContainerLink = function(playerName)
	scriptData.links[string.lower(playerName)] = nil
	Methods.Save()
	
	doDebug("Removed existing link to container for " .. playerName)
end

Methods.CreateContainerForPlayer = function(playerName)
	-- Make sure the cell is loaded
	ensureCellLoaded()
	
	-- Spawn the object
	-- Determine if "place" or "spawn" packet should be used
	local packetType
	if scriptConfig.baseObjectRecordType == "creature" or scriptConfig.baseObjectRecordType == "npc" then
		packetType = "spawn"
	else
		packetType = "place"
	end
	
	-- Just make a dummy location because we don't care about where it'll be
	local location = {posX = 0, posY = 0, posZ = 0, rotX = 0, rotY = 0, rotZ = 0}
	
	local uniqueIndex = logicHandler.CreateObjectAtLocation(scriptConfig.storageCell, location, scriptConfig.recordRefId, packetType)
	
	doLog("Created a bank container with uniqueIndex " .. uniqueIndex .. " for player " .. playerName)
	
	-- Add container data
	LoadedCells[scriptConfig.storageCell].data.objectData[uniqueIndex].inventory = {}
	tableHelper.insertValueIfMissing(LoadedCells[scriptConfig.storageCell].data.packets.container, uniqueIndex)
	
	LoadedCells[scriptConfig.storageCell]:Save()
	
	-- Add a link in the script's data
	Methods.AddPlayerContainerLink(playerName, uniqueIndex)
	
	return uniqueIndex
end

-- Use to load the data of all custom records contained in a provided inventory
Methods.LoadInventoryGeneratedRecords = function(pid, inventory)
	local storeTypes = {}
	
	for index, item in ipairs(inventory) do
		if logicHandler.IsGeneratedRecord(item.refId) then
			local recordType = string.match(item.refId, "_(%a+)_")
			
			if not storeTypes[recordType] then storeTypes[recordType] = {} end
			
			table.insert(storeTypes[recordType], item.refId)
		end
	end
	
	-- If there were items found, load them from each relevant store
	if not tableHelper.isEmpty(storeTypes) then
		for storeType, refIdList in pairs(storeTypes) do
			local recordStore = RecordStores[storeType]

			if recordStore ~= nil then
				recordStore:LoadGeneratedRecords(pid, recordStore.data.generatedRecords, refIdList)
			end
		end
	end
end

Methods.OpenNamedPlayersContainerForPid = function(pid, targetPlayerName)
	local playerName = getName(pid)
	
	if not Methods.DoesPlayerHaveContainer(targetPlayerName) then
		-- Target player doesn't have a container!
		return false
	end
	
	local targetUniqueIndex = Methods.GetPlayerContainerUniqueIndex(targetPlayerName)
	
	-- Work out the relationships between players
	if string.lower(playerName) == string.lower(targetPlayerName) then
		-- The player is opening their own container
		-- Rename the storage to reflect that it's theirs
		Methods.RenameRecordForPid(pid, Methods.GetLangText("yourStorageName"),scriptConfig.recordRefId, scriptConfig.baseObjectRecordType)
	else
		-- The player is opening somebody else's container
		-- Rename the storage to reflect that it's someone else's
		Methods.RenameRecordForPid(pid, Methods.GetLangText("otherPlayerStorageName", {name = targetPlayerName}),scriptConfig.recordRefId, scriptConfig.baseObjectRecordType)
	end
	
	-- Ensure cell is loaded
	ensureCellLoaded()
	
	-- Ensure the player has the container's data loaded
	local oData = LoadedCells[scriptConfig.storageCell].data.objectData

	if scriptConfig.baseObjectRecordType == "creature" or scriptConfig.baseObjectRecordType == "npc" then
		 LoadedCells[scriptConfig.storageCell]:LoadObjectsSpawned(pid, oData, {targetUniqueIndex})
	else
		LoadedCells[scriptConfig.storageCell]:LoadObjectsPlaced(pid, oData, {targetUniqueIndex})
	end
	
	-- Ensure player has all generated records associated with the inventory
	Methods.LoadInventoryGeneratedRecords(pid, oData[targetUniqueIndex].inventory)
	-- Load container info
	LoadedCells[scriptConfig.storageCell]:LoadContainers(pid, oData, {targetUniqueIndex})
	
	-- Activate the container to open up its contents!
	logicHandler.ActivateObjectForPlayer(pid, scriptConfig.storageCell, targetUniqueIndex)
	
	doLog(playerName .. " opened the bank container of " .. targetPlayerName .. ".")
end

---------------------------------------------------------------------------------------
Methods.OnBankCommand = function(pid, cmd)
	local playerRank = Players[pid].data.settings.staffRank
	
	if not cmd[2] then -- Regular bank command was used
		if playerRank >= scriptConfig.useBankCommandRank then
			local playerName = getName(pid)
			
			-- Check whether or not the player has a container
			if not Methods.DoesPlayerHaveContainer(playerName) then
				-- Since they don't, create one!
				Methods.CreateContainerForPlayer(playerName)
			end
			
			-- Open the player's container for them
			Methods.OpenNamedPlayersContainerForPid(pid, playerName)
			return true
		else -- Player doesn't have the rank to use the command
			msg(pid, Methods.GetLangText("useBankCommandFailNoRank"))
			return false
		end
	else -- The player provided more data (i.e. the playername of the bank they want to open)
		-- Do rank check before continuing
		if playerRank >= scriptConfig.openOtherPlayersBankRank then
			local targetPlayerName
			local givenName = tableHelper.concatenateFromIndex(cmd, 2)
			
			if tonumber(givenName) then -- Might've entered a pid
				if Players[pid] ~= nil then
					targetPlayerName = getName(pid)
				else
					-- Use the number as a name...
					targetPlayerName = givenName
				end
			else
				targetPlayerName = givenName
			end
			
			-- Check if there's actually data for that player's bank
			if not Methods.DoesPlayerHaveContainer(targetPlayerName) then
				msg(pid, Methods.GetLangText("openOtherPlayerBankFailNoPlayer", {name = targetPlayerName}))
				return false
			end
			
			-- Open the bank container for them
			Methods.OpenNamedPlayersContainerForPid(pid, targetPlayerName)
			return true
		else -- Player doesn't have the required rank
			msg(pid, Methods.GetLangText("openOtherPlayerBankFailNoRank"))
			return false
		end
	end
end

-- Validator for activations. Used to prevent default behaviour for players activating bankers.
Methods.ActivationCheck = function(eventStatus, pid, cellDescription, objects, players)
	for _,object in pairs(objects) do
		-- Only bothered about the activation if:
		-- > The object is an object (not a player)
		-- > A player is the one doing the activation
		if object.pid == nil and object.activatingPid ~= nil then
			local refId = object.refid
			local uniqueIndex = object.uniqueIndex

			-- Check whether or not this is a banker
			if Methods.IsBankerUniqueIndex(uniqueIndex) or Methods.IsBankerRefId(refId) then
				 -- Prevent the activation of the banker object, regardless of whether or not the player can actually use the banker
				return customEventHooks.makeEventStatus(false, nil)
			end
		end
		-- Was either not a banker, or not a player doing the activation. Either way, we don't care about it.
		return customEventHooks.makeEventStatus(nil,nil)
	end
end

Methods.OnObjectActivate = function(eventStatus, pid, cellDescription, objects, players)
    if eventStatus.validCustomHandlers ~= false then
        for _,object in pairs(objects) do
            if object.pid == nil and object.activatingPid ~= nil then
				local refId = object.refId
				local uniqueIndex = object.uniqueIndex
				local pid = object.activatingPid
				
				local playerRank = Players[pid].data.settings.staffRank
				local playerName = getName(pid)

				if Methods.IsBankerUniqueIndex(uniqueIndex) or Methods.IsBankerRefId(refId) then
					if not (playerRank >= scriptConfig.useBankerRank) then
						-- The player doesn't have the required rank to use bankers
						doLog(playerName .. " activated a banker, but doesn't have a sufficient rank to use it.")
						msg(pid, Methods.GetLangText("useBankerFailNoRank"))
					else
						doLog(playerName .. " activated a banker, accessed their bank.")
						-- The player can use bankers
						-- Check whether or not the player has a container
						if not Methods.DoesPlayerHaveContainer(playerName) then
							-- Since they don't, create one!
							Methods.CreateContainerForPlayer(playerName)
						end

						-- Open the player's container for them
						Methods.OpenNamedPlayersContainerForPid(pid, playerName)
						doLog(playerName .. " opened their bank via the banker " .. refId .. " " .. uniqueIndex .. ".")
					end
				end
			end
        end
    end
end

-- Returning true signals we want to block deletion
Methods.DeletionCheck = function(eventStatus, pid, cellDescription, objects)
	for _,object in pairs(objects) do
        local refId = object.refId
        local uniqueIndex = object.uniqueIndex
        
        if not Methods.IsAllowedDeleteRefId(refId) or not Methods.IsAllowedDeleteUniqueIndex(uniqueIndex) then
            -- The object is protected by this script!
            doDebug("Prevented deletion of object " .. refId .. " " .. uniqueIndex)
            return customEventHooks.makeEventStatus(false,false)
        end
    end
    
    return customEventHooks.makeEventStatus(nil,nil)
end

Methods.OnServerPostInit = function(eventStatus)
	-- Load data
	Methods.Load()
	
	-- Detect if this script's permanent record has been created on this server yet
	-- If it hasn't, create it
	if RecordStores[scriptConfig.baseObjectRecordType].data.permanentRecords[scriptConfig.recordRefId] == nil then
		local data = {baseId = "dead rat", name = Methods.GetLangText("baseBankContainerDisplayName")}
		
		RecordStores[scriptConfig.baseObjectRecordType].data.permanentRecords[scriptConfig.recordRefId] = data
		
		RecordStores[scriptConfig.baseObjectRecordType]:Save()
		doLog("Created permanent record entry for the script's base object.")
	end
	
	-- Port the banker info from the config into scriptTemp
	local bankerRefs = 0
	local bankerIndexes = 0
	
	for index, refId in ipairs(scriptConfig.bankerRefIds) do
		scriptTemp.bankerRefIds[refId] = true
		bankerRefs = bankerRefs + 1
	end
	
	for index, uniqueIndex in ipairs(scriptConfig.bankerUniqueIndexes) do
		scriptTemp.bankerUniqueIndexes[uniqueIndex] = true
		bankerIndexes = bankerIndexes + 1
	end
	
	if bankerRefs > 0 then
		doLog("Imported " .. bankerRefs .. " banker refIds from scriptConfig.")
	end
	
	if bankerIndexes > 0 then
		doLog("Imported " .. bankerIndexes .. " banker uniqueIndexes from scriptConfig.")
	end
	
	-- If CellReset is being used, register the storage cell as an exempt cell
	if CellReset then
		CellReset.RegisterFullyExemptCell(scriptConfig.storageCell, "kanaBank")
		doLog("Ensured storage cell is exempt from CellReset resets.")
	end
end

customEventHooks.registerValidator("OnObjectActivate",Methods.ActivationCheck)
customEventHooks.registerValidator("OnObjectDelete",Methods.DeletionCheck)
customEventHooks.registerHandler("OnServerPostInit",Methods.OnServerPostInit)
customEventHooks.registerHandler("OnObjectActivate",Methods.OnObjectActivate)
customCommandHooks.registerCommand("bank",Methods.OnBankCommand)
-------------
return Methods
