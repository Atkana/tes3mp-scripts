-- CellReset - Release 8 - For tes3mp 0.7-alpha
-- Adds automated cell resetting via server scripts.

local scriptConfig = {}
scriptConfig.resetTime = 259200 --The time in (real life) seconds that must've passed before a cell is attempted to be reset. 259200 seconds is 3 days. Set to -1 to disable automatic resetting
scriptConfig.preserveCellChanges = true --If true, the script won't reset actors that have moved into/from the cell. At the moment, MUST be true.
scriptConfig.alwaysPreservePlaced = false --If true, the script will always preserve any placed objects, even in cells that it's free to delete from

--Cells entered in the blacklist are exempt from cell resets.
scriptConfig.blacklist = {
--"Pelagiad, Ahnassi's House",
}
--Object with the UniqueIndexes entered in this list will be preserved as they were from a cell reset.
scriptConfig.preserveUniqueIndexes = {
-- "0-1234",
}

scriptConfig.checkResetTimeRank = 0 -- The staffRank required to use the /resetTime command.
scriptConfig.forceResetRank = 2 -- The staffRank required to use the /forceReset command.

scriptConfig.kickAffectedPlayersAfterForceReset = true -- If true, players that had information on a cell in their client memory will be kicked following a force reset. Should be set to true or problems will arise!

scriptConfig.logging = true --If true, script outputs basic information to the log
scriptConfig.debug = false --If true, script outputs debug information to the log

---------------------------------------------------------------------------------------
local Methods = {}

local exemptCells = {} -- Used internally to store info on fully exempt cells

local function isValidPlayer(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		return true
	else
		return false
	end
end

local function doLog(message)
	if scriptConfig.logging then
		tes3mp.LogMessage(1, "[CellReset] - " .. message)
	end
end

local function doDebug(message)
	if scriptConfig.debug then
		tes3mp.LogMessage(1, "[CellReset - DEBUG] - " .. message)
	end
end

---------------------------------------------------------------------------------------
-- Use to register a cell to be fully exempt from resets. cellDescription is the cell, scriptId is a unique identifier for the script which will be used should the exemption need to be removed (via UnregisterFullyExemptCell).
Methods.RegisterFullyExemptCell = function(cellDescription, scriptId)
	if exemptCells[cellDescription] == nil then
		exemptCells[cellDescription] = {}
	end
	
	exemptCells[cellDescription][scriptId] = true
	doDebug(cellDescription .. " registered as exempt cell for " .. scriptId)
end

-- Use to unregister a cell from being fully exempt from resets. cellDescription is the cell, scriptId is the id provided when the script registered it.
Methods.UnregisterFullyExemptCell = function(cellDescription, scriptId)
	exemptCells[cellDescription][scriptId] = nil
	
	if tableHelper.isEmpty(exemptCells[cellDescription]) then
		exemptCells[cellDescription] = nil
		doDebug(scriptId .. " removed its claim on cell '" .. cellDescription .. "'. Cell is no longer exempt from resets")
	else
		doDebug(scriptId .. " removed its claim on cell '" .. cellDescription .. "', however it is still an exempt cell due to other script's claims")
	end
end

-- Returns true if the given cell is listed as being fully exempt from resets
Methods.IsCellFullyExempt = function(cellDescription)
	--Check the script's cell exemptions to see if the cell is listed there.
	if exemptCells[cellDescription] ~= nil then
		return true
	end
	
	--kanaHousing hack. TODO: Check if cell has specialised reset data
	if kanaHousing then
		local cellData = kanaHousing.GetCellData(cellDescription)
		if cellData and (cellData.house ~= nil) then
			--The cell belongs to a kanaHousing home
			doDebug("Cell belongs to a kanaHousing home")
			return true
		end
	end
	
	--If we get here, it's fine to reset the cell
	return false
end

-- Checks to see if any online player has information from the given cell loaded in their client memory. If there are, returns true, along with an indexed table containing the pids of all those affected. Otherwise returns false. 
Methods.HasOnlinePlayerLoadedCellInSession = function(cellToCheck)
	local cell
	local useTempLoad = false
	
	if type(cellToCheck) == "table" then --Was given the cell itself
		cell = cellToCheck
	else --Was given cell description
		--Load cell if not already loaded.
		if LoadedCells[cellToCheck] == nil then
			logicHandler.LoadCell(cellToCheck)
			useTempLoad = true
		end
		cell = LoadedCells[cellToCheck]
	end
	
	local cellDescription = cell.description
	
	-- Determine whether there are any players online that have loaded this cell this session.
	local affectedPlayers = {}
	local aPlayerHasLoaded = false
	
	-- Check if there are literally people in the cell right now
	if not tableHelper.isEmpty(cell.visitors) then
		doDebug("HasOnlinePlayerLoadedCellInSession - There are players in the cell \"" .. cellDescription .. "\" right now.")
		aPlayerHasLoaded = true
		for index, pid in ipairs(cell.visitors) do
			tableHelper.insertValueIfMissing(affectedPlayers, pid)
		end
	end
	
	-- Get the most recent visit time from the cell
	-- Quickly check if there even have been any visitors to the cell...
	if tableHelper.isEmpty(cell.data.lastVisit) then
		--Nobody has visited, so there can't have previously been anyone in the cell
		--Do nothing
		doDebug("HasOnlinePlayerLoadedCellInSession - There are no lastVisit entries for cell \"" .. cellDescription .. "\"")
	else
		--Get most recent visit time
		local mostRecent = -1
		for playerName, time in pairs(cell.data.lastVisit) do
			if time > mostRecent then
				mostRecent = time
			end
		end
		
		--Now, go through all online players to see who logged after that time...
		for pid, player in pairs(Players) do
			if isValidPlayer(pid) then
				if player.initTimestamp <= mostRecent then
					--Unfortunately, the player was logged in before somebody had been in the cell
					--Add the player to the list of players who have to be targeted
					tableHelper.insertValueIfMissing(affectedPlayers, pid)

					aPlayerHasLoaded = true
				end
			end
		end
	end
	
	if useTempLoad then
		logicHandler.UnloadCell(cell.description)
	end
	
	if aPlayerHasLoaded then
		doDebug("Check revealed that there ARE online players with cell \"" .. cellDescription .. "\" loaded.")
		return true, affectedPlayers
	else
		doDebug("Check revealed that there AREN'T online players with cell \"" .. cellDescription .. "\" loaded.")
		return false
	end
end

-- Performs a check to see whether the cell is clear for resetting via the automatic method. Returns true if all criteria is met. Otherwise, returns false, followed by a table containing the reasons for rejection (each valid rejection type = true (see function for each of them))
Methods.CheckCellReset = function(cellDescription)
	doDebug("Checking if cell '" .. cellDescription .. "' can be reset")
	
	local useTempLoad = false
	if LoadedCells[cellDescription] == nil then
		logicHandler.LoadCell(cellDescription)
		useTempLoad = true
	end
	
	local cell = LoadedCells[cellDescription]
	
	--Check if cell reset needs to be done
	if not cell.data.lastReset then
		--The cell has never been visited when this script was running. For now we'll create a new entry saying that the cell was last reset right now
		doDebug("Creating lastReset time for cell '" .. cellDescription .. "' with missing value")
		cell.data.lastReset = os.time()
		cell:Save()
	end
	
	local denyReasons = {} --We'll use this table to contain all the reasons that it shouldn't be reset
	
	if scriptConfig.resetTime < 0 then
		doDebug("Automatic resetting is disabled")
		denyReasons.automaticDisabled = true
	end
	
	if os.time() - cell.data.lastReset < scriptConfig.resetTime then --Enough time hasn't passed between resets
		doDebug("Not enough time has passed in cell '" .. cellDescription .. "' to require cell reset")
		denyReasons.time = true
	end
	
	--Make sure that the cell isn't exempt from cell resets
	if Methods.IsCellFullyExempt(cellDescription) then
		doDebug("Cell '" .. cellDescription .. "' is exempt from cell resets")
		denyReasons.fullyExempt = true
	end
	
	--Check that no online player has the cell's info loaded in their client memory
	local playerHasLoaded, affectedPlayers = Methods.HasOnlinePlayerLoadedCellInSession(cellDescription)
	if playerHasLoaded then
		doDebug("A player has loaded the cell during their current session - reset can't be performed until they've disconnected.")
		denyReasons.clientMemory = true
	end
	
	--Check if the cell is empty of players. Resets will only be done in empty cells.
	-- This one should never actually be of importance, but whatever :P
	if cell:GetVisitorCount() > 0 then
		doDebug("Players present in cell - resets can only occur in empty cells.")
		denyReasons.visitors = true
	end
	
	-- Unload cell if was temporarily loaded
	if useTempLoad then
		logicHandler.UnloadCell(cellDescription)
	end
	
	-- If there was any deny reason, we should return false
	if not tableHelper.isEmpty(denyReasons) then
		return false, denyReasons
	end
	
	doDebug("Don't find any reason to abort, returning true")
	--If we get here, then that means there are no problems!
	return true
end

--Used to reset given cell. This function is used internally to reset cells, assuming all relevant checks have already been made. If you want to properly utilise this script's resetting abilities, use TryResetCell (or your own checks) instead, so important checks aren't bypassed.
Methods.ResetCell = function(cellToReset, uniqueIndexesToPreserve)
	local cell
	local cellDescription
	local useTempLoad = false
	
	if type(cellToReset) == "table" then --Was given the cell itself
		cell = cellToReset
		cellDescription = cell.data.entry.description
	else --Was given cell description
		cellDescription = cellToReset
		-- Ensure cell is loaded
		if LoadedCells[cellDescription] == nil then
			logicHandler.LoadCell(cellDescription)
			useTempLoad = true		
		end
		cell = LoadedCells[cellDescription]
	end
	
	local oldCellData = cell.data
	
	--Create the new blank entry for the cell
	local newCellData = {}
	
	--Somewhat future-proof this by getting the keys for what should be part of a cell from the oldCellData ;P
	-- So currently, this should create packets, entry, lastVisit, recordLinks, and objectData entries to our newCellData
	for key, value in pairs(oldCellData) do
		-- Only make a new table if the original was actually a table!
		if type(value) == "table" then
			newCellData[key] = {}
		end
	end
	
	-- Do the same, but for packets
	for packetKey, moreUselessInfo in pairs(oldCellData.packets) do
		newCellData.packets[packetKey] = {}
	end
	
	-- Now to focus on preserving data as commanded...
	
	-- The following is an indexed list containing the uniqueIndex of all objects we have to preserve ALL information about
	local uniqueIndexesToPreserve = uniqueIndexesToPreserve or {}
	
	-- Here, we'll add any object that has place information about it to the preserve list
	-- Provided we've been configured to...
	if scriptConfig.alwaysPreservePlaced then
		for index, uniqueIndex in pairs(oldCellData.packets.place) do
			tableHelper.insertValueIfMissing(uniqueIndexesToPreserve, uniqueIndex)
		end
	end
	
	-- If the script has been configured to care about CellChange packets, we'll need to preserve that information
	-- We could add those objects to the uniqueIndexesToPreserve list, but since we know how cellChangeTo works, we can jump straight to storing the data and hardcode this instead
	if scriptConfig.preserveCellChanges then
		doDebug("Checking cell for any cellChange* data")
		local wasCellChangeData = false --Used later for logging purposes. 
		
		if not tableHelper.isEmpty(oldCellData.packets.cellChangeTo) then
			for index, uniqueIndex in pairs(oldCellData.packets.cellChangeTo) do
				-- Literally just copy the objectData for the object over
				newCellData.objectData[uniqueIndex] = oldCellData.objectData[uniqueIndex]
			end
			
			-- Also just copy the whole old cellChangeTo table too
			newCellData.packets.cellChangeTo = oldCellData.packets.cellChangeTo
			
			wasCellChangeData = true
		end
		
		--Check if the cell has cellChangeFrom data
		if not tableHelper.isEmpty(oldCellData.packets.cellChangeFrom) then
			-- Copy the old cellChangeFrom table to the new one
			newCellData.packets.cellChangeFrom = oldCellData.packets.cellChangeFrom
			
			-- Because we'll need to preserve all the packets and information related to the uniqueIndexes listed here
			-- And we'll already be doing that later for entries in uniqueIndexesToPreserve, we'll just add them to the list
			for index, uniqueIndex in pairs(newCellData.packets.cellChangeFrom) do
				tableHelper.insertValueIfMissing(uniqueIndexesToPreserve, uniqueIndex)
			end
			
			wasCellChangeData = true
		end
		
		if wasCellChangeData then
			doDebug("Detected cell change data in cell `" .. cellDescription .. "', preserving...")
		end
	end
	
	-- Main preservation begins here
	-- Loop through each packet type from the oldCellData
	-- If a uniqueIndex in the uniqueIndexesToPreserve appears there, add it to the new entry for that packet
	doDebug("Beginning packet preservation")
	for packetKey, uniqueIndexList in pairs(oldCellData.packets) do
		for index, uniqueIndex in pairs(uniqueIndexList) do
			-- Check if the uniqueIndex is one listed in the uniqueIndexesToPreserve table
			if tableHelper.containsValue(uniqueIndexesToPreserve, uniqueIndex) then
				-- Add the uniqueIndex to the new cell data's packet entry
				tableHelper.insertValueIfMissing(newCellData.packets[packetKey], uniqueIndex)
			end
		end
	end
	
	-- Do the same with object data
	-- The following is used to store the name of every generatedRecord from the old cell that won't be in the new cell
	-- local removedRecords = {}
	doDebug("Beginning object data preservation")
	for uniqueIndex, data in pairs(oldCellData.objectData) do
		local wasPreserved = false
		local wasGeneratedRecord = false
	
		-- Check if the uniqueIndex is one listed in the uniqueIndexesToPreserve table
		if tableHelper.containsValue(uniqueIndexesToPreserve, uniqueIndex) then
			-- Add the object's objectData to the new cell data
			if newCellData.objectData[uniqueIndex] == nil then
				newCellData.objectData[uniqueIndex] = data
			end
			
			wasPreserved = true
		end
		
		-- NOTE: I changed my mind on how this should be implemented, but am preserving the code I wrote in case I change my mind and go back to this method
		--[[
		-- Because customRecords are evil and tricksy, we have to do some extra stuff concerning them
		if data.refId ~= nil and logicHandler.IsGeneratedRecord(data.refId) then
			wasGeneratedRecord = true
		end
		
		if wasGeneratedRecord then
			if wasPreserved then
				-- If the generated record was preserved, then we need to make an entry for it in the new cell's recordLinks
				local recordType = string.match(data.refId, "_(%a+)_")
				-- Create the table for this recordType if it doesn't exist
				if newCellData.recordLinks[recordType] == nil then
					newCellData.recordLinks[recordType] = {}
				end
				
				-- If an entry for this record doesn't exist in that table, create one
				if newCellData.recordLinks[recordType][data.refId] == nil then
					newCellData.recordLinks[recordType][data.refId] = {}
				end
				
				-- Add this object's uniqueIndex to that entries table if it isn't already in there
				tableHelper.insertValueIfMissing(newCellData.recordLinks[recordType][data.refId], uniqueIndex)
			else
				-- The generated record DID exist in this cell, but no longer does
				-- Remove the object from the OLD cell's data to see if there are any remaining instances of this object still around
				local recordType = string.match(data.refId, "_(%a+)_")
				
				for index = 1, #oldCellData.recordLinks[recordType][data.refId] do
					if oldCellData.recordLinks[recordType][data.refId][index] == uniqueIndex then
						table.remove(index)
						break
					end
				end
				
				-- Check to see if there are still instances of this recordType
				-- If there aren't, add this generatedRecord to the list of removed records
				if tableHelper.isEmpty(oldCellData.recordLinks[recordType][data.refId]) then
					
				end
			end
		end
		]]
	end
	
	-- RECORDLINK STUFF
	doDebug("Checking to do recordlink preservation")
	-- We need to know which custom items have been removed by this reset so we can remove its links	
	if not tableHelper.isEmpty(oldCellData.recordLinks) then
		doDebug("Processing custom record data for " .. cellDescription .. "...")
	end
	
	-- Start by looping through all the recordType entries in the OLD cell data
	for recordType, recordEntries in pairs(oldCellData.recordLinks) do
		local removedLinksForType = false
		local preservedCustomData = false
		
		-- Then loop through each recordId entry for each type...
		for recordId, uniqueIndexList in pairs(recordEntries) do
			-- THEN loop through all the uniqueIndexes associated with that recordId...
			for index = 1, #uniqueIndexList do
				-- Remove every entry that isn't on the uniqueIndexesToPreserve list
				if not tableHelper.containsValue(uniqueIndexesToPreserve, uniqueIndexList[index]) then
					uniqueIndexList[index] = nil
				end
				
				tableHelper.cleanNils(uniqueIndexList)
				-- Check to see if there are any entries left in the table
				if tableHelper.isEmpty(uniqueIndexList) then
					-- There are no entries for this record linked to the cell anymore, remove the links from recordstore
					logicHandler.GetRecordStoreByRecordId(recordId):RemoveLinkToCell(recordId, cell)
					-- (We do this because if the cell was the last instance of that item, then the RecordStore code will delete its data about the item)
					removedLinksForType = true
				else
					-- There are still some entries for this record remaining, as such, we should add this information to the new cells data
					
					if newCellData.recordLinks[recordType] == nil then newCellData.recordLinks[recordType] = {} end
					
					newCellData.recordLinks[recordType][recordId] = uniqueIndexList
					preservedCustomData = true
				end
			end
		end
		
		if removedLinksForType then
			doDebug("...Removed links to removed items from recordType: " .. recordType)
		end
		
		if preservedCustomData then
			doDebug("...Retained relevant information on preserved objects for recordType: " .. recordType)
		end
	end
	
	-- Make some final hardcoded changes to finish off the new data
	newCellData.entry.creationTime = os.time()
	newCellData.entry.description = cellDescription
	-- Record the current time as the last time this cell was reset
	newCellData.lastReset = os.time()
	
	-- Save the changes
	cell.data = newCellData
	cell:Save()
	
	-- Unload cell if was temporarily loaded
	if useTempLoad then
		logicHandler.UnloadCell(cellDescription)
	end
	
	doLog("Successfully reset cell '" .. cellDescription .. "'")
	return true
end

-- Used when attempting to automatically reset a cell. If it fails to meet all the requirements, it'll cancel its attempt. Run every time a player loads a cell.
Methods.TryResetCell = function(cellDescription, preserveIndexesList)
	doDebug("TryResetCell called for cell '" .. cellDescription .. "'...")
	
	-- Add the configured defaults to the list of uniqueIndexes to preserve
	local preserveIndexesList = tableHelper.shallowCopy(preserveIndexesList or {}) -- Duplicate the table because otherwise we'd be altering the original
	for index, uniqueIndex in ipairs(scriptConfig.preserveUniqueIndexes) do
		table.insert(preserveIndexesList, uniqueIndex)
	end
	
	if Methods.CheckCellReset(cellDescription) then
		doLog("Check passed for cell '" .. cellDescription .. "'. Resetting cell.")
		Methods.ResetCell(cellDescription, preserveIndexesList or {})
		return true
	else
		doDebug("TryResetCell aborted for cell '" .. cellDescription .. "'")
		return false
	end
end

-- Because we need to try and reset the cell before it's actually loaded by the player, we need to do this during the validator checks
Methods.OnCellLoadValidator = function(eventStatus, pid, cellDescription)
	if eventStatus.validDefaultHandler ~= false then
		Methods.TryResetCell(cellDescription)	
	end
	return customEventHooks.makeEventStatus(nil,nil)
end

-- Run by the /resetTime command
Methods.OnTimePromptCommand = function(pid, cmd)
	local useTempLoad = false
	local cell
	
	-- Check to see if timers are actually used on this server
	if scriptConfig.resetTime < 0 then
		tes3mp.SendMessage(pid, "Automatic resetting is disabled on this server.\n")
		return false
	end
	
	-- Permission check
	if Players[pid].data.settings.staffRank < scriptConfig.checkResetTimeRank then
		tes3mp.SendMessage(pid, "You don't have the required staff rank to use that command.\n")
		return false
	end
	
	if cmd[2] == nil then
		-- The player isn't asking about a specific cell
		-- So we'll default to the one that they're in
		cell = LoadedCells[Players[pid].data.location.cell]
	else
		-- The player has provided a cell name
		local cellDescription = tableHelper.concatenateFromIndex(cmd, 2)
		
		-- Check to see if the cell exists
		-- First, by seeing if it's already loaded
		if LoadedCells[cellDescription] ~= nil then
			cell = LoadedCells[cellDescription]
		else
			-- Do a little faffing about to figure out if that's an actual cell
			-- Technically this way is inefficient, but it's easier to understand :P
			
			-- Temp load it up as a cell instance
			LoadedCells[cellDescription] = Cell(cellDescription)
			
			-- Check to see if there's any saved data concerning the cell
			if not LoadedCells[cellDescription]:HasEntry() then
				-- The cell data doesn't exist (might be typo, might not have been created)
				tes3mp.SendMessage(pid, "Couldn't find any info on the cell \"" .. cellDescription .. "\". This could mean you made a typo, or the cell has never been generated for the server.\n")
				return false
			else
				-- Temporarily load the cell
				useTempLoad = true
				LoadedCells[cellDescription] = nil -- Unassign so it can be reassigned. As I said, faff :b
				
				logicHandler.LoadCell(cellDescription)
				cell = LoadedCells[cellDescription]
			end
		end
	end
	
	-- Make sure the cell actually has a last reset before continuing
	if cell.data.lastReset == nil then
		-- The cell doesn't have lastReset data
		tes3mp.SendMessage(pid, "The cell \"" .. cell.description .. "\" has never been loaded while this script was running, so its timer hasn't started.\n")
	else
		local timeSinceReset = os.time() - cell.data.lastReset
		local timeToGo = scriptConfig.resetTime - timeSinceReset
		
		if timeToGo <= 0 then
			tes3mp.SendMessage(pid, "The timer for the cell \"" .. cell.description .. "\" is up.\n")
		else
			local days = math.floor(timeToGo / 86400)
			local hours = math.floor((timeToGo % 86400) / 3600)
			local minutes = math.floor((timeToGo % 3600) / 60)
			local seconds = math.floor(timeToGo % 60)
			
			tes3mp.SendMessage(pid, "Time remaining before reset attempt for \"" .. cell.description .. "\": " .. days .. " Days | " .. hours .. " Hours | " .. minutes .. " Minutes | " .. seconds .. " Seconds.\n")
		end
	end
	
	if useTempLoad then
		logicHandler.UnloadCell(cell.description)
	end
end

-- Run by the /forceReset command. Contains much the same code as OnTimePromptCommand
Methods.OnForceResetCommand = function(pid, cmd)
	local useTempLoad = false
	local cell
	
	-- Permission check
	if Players[pid].data.settings.staffRank < scriptConfig.forceResetRank then
		tes3mp.SendMessage(pid, "You don't have the required staff rank to use that command.\n")
		return false
	end
	
	-- Copy pasta from OnTimePromptCommand
	if cmd[2] == nil then
		-- The player isn't asking about a specific cell
		-- So we'll default to the one that they're in
		cell = LoadedCells[Players[pid].data.location.cell]
	else
		-- The player has provided a cell name
		local cellDescription = tableHelper.concatenateFromIndex(cmd, 2)
		
		-- Check to see if the cell exists
		-- First, by seeing if it's already loaded
		if LoadedCells[cellDescription] ~= nil then
			cell = LoadedCells[cellDescription]
		else
			-- Do a little faffing about to figure out if that's an actual cell
			-- Technically this way is inefficient, but it's easier to understand :P
			
			-- Temp load it up as a cell instance
			LoadedCells[cellDescription] = Cell(cellDescription)
			
			-- Check to see if there's any saved data concerning the cell
			if not LoadedCells[cellDescription]:HasEntry() then
				-- The cell data doesn't exist (might be typo, might not have been created)
				tes3mp.SendMessage(pid, "Couldn't find any info on the cell \"" .. cellDescription .. "\". This could mean you made a typo, or the cell has never been generated for the server.\n")
				return false
			else
				-- Temporarily load the cell
				useTempLoad = true
				LoadedCells[cellDescription] = nil -- Unassign so it can be reassigned. As I said, faff :b
				
				logicHandler.LoadCell(cellDescription)
				cell = LoadedCells[cellDescription]
			end
		end
	end
	-- /copyPasta
	
	doLog(Players[pid].accountName .. " is forcibly resetting the cell \"" .. cell.description .. "\"")
	
	-- Find any players that might be affected by this
	local hasPlayers, playersList = Methods.HasOnlinePlayerLoadedCellInSession(cell)
	
	-- Perform the risky force reset
	Methods.ResetCell(cell)
	
	-- Inform the command user that the cell has been reset
	local commandUserMessage = "The cell \"" .. cell.description .. "\" has been forcibly reset."
	if hasPlayers then
		if scriptConfig.kickAffectedPlayersAfterForceReset then
			commandUserMessage = commandUserMessage .. " The following players have been kicked: "
			for index = 1, #playersList do
				local player = Players[playersList[index]]
				commandUserMessage = commandUserMessage .. player.accountName
				if playersList[index+1] ~= nil then
					commandUserMessage = commandUserMessage .. ", "
				end
				
				-- Message the kicked players before kicking them
				tes3mp.SendMessage(player.pid, color.Red  .. "You have been kicked by the server to reset a cell that you had loaded.\n" .. color.Default)
				doLog(player.accountName .. " was kicked so a cell could be forcibly reset")
				player:Kick()
			end
		else
			commandUserMessage = commandUserMessage .. color.Red .. " There will be problems from the following players: "
			for index = 1, #playersList do
				local player = Players[playersList[index]]
				commandUserMessage = commandUserMessage .. player.accountName
				if playersList[index+1] ~= nil then
					commandUserMessage = commandUserMessage .. ", "
				end
			end
		end
		
		commandUserMessage = commandUserMessage .. "."
	end
	
	-- Actually send the message
	tes3mp.SendMessage(pid, commandUserMessage .. color.Default .. "\n")
	
	-- Unload cell if was temporarily loaded
	if useTempLoad then
		logicHandler.UnloadCell(cellDescription)
	end
end

Methods.Init = function(eventStatus)
	local count = 0
	
	for index, cellDescription in pairs(scriptConfig.blacklist) do
		Methods.RegisterFullyExemptCell(cellDescription, "CellReset")
		count = count + 1
	end
	
	if count >= 1 then
		doLog("Added " .. count .. " cells from CellReset blacklist to exemptions list.")
	end
end

customEventHooks.registerValidator("OnCellLoad",Methods.OnCellLoadValidator)
customEventHooks.registerHandler("OnServerPostInit",Methods.Init)
customCommandHooks.registerCommand("resettime",Methods.OnTimePromptCommand)
customCommandHooks.registerCommand("forcereset",Methods.OnForceResetCommand)

return Methods
