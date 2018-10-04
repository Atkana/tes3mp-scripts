-- CellReset - Release 1 - For tes3mp 0.6.2
-- Adds automated cell resetting via server scripts.

--[[ INSTALLATION:
1) Save file as "CellReset.lua" in mp-stuff/scripts
2) Add [ CellReset = require("CellReset") ] to the top of server.lua
3) Add the following before "myMod.OnCellLoad(pid, cellDescription)" in OnCellLoad in server.lua
	[ CellReset.TryResetCell(cellDescription) ]
4) Add the following to OnServerPostInit in server.lua
	[ CellReset.Init() ]
]]

local config = {}
config.resetTime = 259200 --The time in (real life) seconds that must've passed before a cell is attempted to be reset. 259200 seconds is 3 days.
config.preserveCellChanges = true --If true, the script won't reset actors that have moved into/from the cell. At the moment, MUST be true.

--Cells entered in the blacklist are exempt from cell resets.
config.blacklist = {
--"Pelagiad, Ahnassi's House",
}

config.logging = true --If true, script outputs basic information to the log
config.debug = true --If true, script outputs debug information to the log

--[[ SCRIPT NOTES
	
How this script determines cell resetting:
1) When a player attempts to load a cell, the script checks for the last time the cell was reset. If the time since the cell was last reset exceeds the time set in the configs, it continues to the next step... (note: if the cell hasn't been loaded while this script has been installed, it won't have information about the last reset. The script adds a fake reset time set to the current time if this occurs, which means it'll always fail the first check)
2) The script checks to see if the cell is on its list of exempt cells. Server owners can manually add to this list with the blacklist config, and other scripts can add to the list automatically using the CellReset.RegisterExemptCell function. If the cell isn't on the exemption list, it continues to the next step...
3) The script checks if there are any players currently in the cell. The cell won't be reset if there are players already inside it. If there are no players inside the cell, it continues to the next step...
4) The script determines whether it should reset the cell the "easy way" or the "complicated way". If ANY online player logged in before the last player to be in the cell left it, the "complicated way" is used. Otherwise, the "easy way" is used, which simply involves jumping to step 5 :P
	4a) (The complicated way) Not yet implemented. If having to do this way, cell reset aborts.
5) The script checks for any cell data that needs to be preserved after the reset. If the preserveCellChanges config option is set to true, this'll include the information about actors who have left/entered the cell. Afterwards, the cell's data will be wiped, excluding anything that was set to be preserved, and the cell will be reset!

Current Limits:
> Can't reset cell if anybody in the server has been online since a player has been in the cell. Requires somewhat complicated undoing of packets that I'll have to work on.
> Must have preserveCellChanges config enabled. Meaning that data file actors won't be returned to their original cells on cell reset.

--Notes on base tes3mp carp:
> When players login, they're given an initTimestamp set to os.time()
> If data file actor is moved to different cell:
	- The game ports their object data to the new cell, including associated packets
	- In the original cell the game stores a "cellChangeTo" packet for the object. The object data for the actor in the original cell is used solely for storing the object's new cell: keyed under "cellChangeTo", the cellDescription of the cell the actor was moved to is stored.
> If a data file actor that has been moved from its starting cell is deleted (e.g. they were killed and their body disposed of):
	- In the cell the actor was moved into, the game deletes all data related to the actor object (object data, any associated packets, including cellChangeFrom)
	- In the original cell, the cellChangeFrom packet is removed. The actor's objectData is replaced with a table solely containing the actor's refId under the respective key. A delete packet is stored for the object.
	
TODO:
> Implement complicated way
> Implement system for detailing specific reset instructions.
> Maybe add option for ingame time instead of IRL time
]]
---------------------------------------------------------------------------------------
local Methods = {}

local exemptCells = {}

local function isValidPlayer(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		return true
	else
		return false
	end
end

local function doLog(message)
	if config.logging then
		tes3mp.LogMessage(1, "[CellReset] - " .. message)
	end
end

local function doDebug(message)
	if config.debug then
		tes3mp.LogMessage(1, "[CellReset - DEBUG] - " .. message)
	end
end

Methods.IsAllowedCellReset = function(cellDescription)
	--Check the script's cell exemptions to see if the cell is listed there.
	if exemptCells[cellDescription] ~= nil then
		return false
	end
	
	--kanaHousing hack. TODO: Check if cell has specialised reset data
	if kanaHousing then
		local cellData = kanaHousing.GetCellData(cellDescription)
		if cellData and (cellData.house ~= nil) then
			--The cell belongs to a kanaHousing home
			doDebug("Cell belongs to a kanaHousing home")
			return false
		end
	end
	
	--If we get here, it's fine to reset the cell
	return true
end

--Used to check if any players logged in before the last player to be in the cell left it. Returns true if nobody online meets that criteria. Returns false, alongside a table of the affected players (actual players, rather than pids) if it does meet the criteria
Methods.CanDoEasyWay = function(cellToCheck)
	local cell
	
	if type(cellToCheck) == "table" then --Was given the cell itself
		cell = cellToCheck
	else --Was given cell description
		--Load cell if not already loaded. Ideally should be temporary:
		if LoadedCells[cellToCheck] == nil then
			myMod.LoadCell(cellToCheck)
		end
		cell = LoadedCells[cellToCheck]
	end
	
	--In order to determine who might need to get the cell reset the complicated way, we need to check if they've been online since another player has been in the cell.
	local affectedPlayers = {}
	local easyWay = true
	--Get the most recent visit time from the cell
	-- Quickly check if there even have been any visitors to the cell...
	if tableHelper.isEmpty(cell.data.lastVisit) then
		--Nobody has visited, so there can't have been anyone in the cell
		--Do nothing
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
					--Unfortunately, the player was logged in before somebody had been in the cell, so they need some specialised cell resetting
					--Add the player to the list of players who have to be targeted
					table.insert(affectedPlayers, player)
					--Now we have to do this the complicated way...
					easyWay = false
				end
			end
		end
	end
	
	if easyWay then
		return true
	else
		return false, affectedPlayers
	end
end

--Used to reset given cell. This function is used internally to reset cells, assuming all relevant checks have already been made. If you want to properly utilise this script's resetting abilities, use TryResetCell instead, so important checks aren't bypassed.
Methods.ResetCell = function(cellToReset)
	local cell
	local cellDescription
	
	if type(cellToReset) == "table" then --Was given the cell itself
		cell = cellToReset
		cellDescription = cell.data.entry.description
	else --Was given cell description
		cellDescription = cellToReset
		cell = LoadedCells[cellDescription]
	end
	
	--Record data that needs to be preserved
	local preserve = {objectData = {}, packets = {}, lastVisit = {}}
	
	if config.preserveCellChanges == true then
		doDebug("Checking cell for any cellChange* data")
		local wasCellChangeData = false --Used later for logging purposes.
		
		--Check if the cell has cellChangeTo data
		if not tableHelper.isEmpty(cell.data.packets.cellChangeTo) then
			--Record every object that has changed from this cell to a different one
			for index, uniqueIndex in pairs(cell.data.packets.cellChangeTo) do
				doDebug(uniqueIndex .. " has cellChangeTo data")
				preserve.objectData[uniqueIndex] = cell.data.objectData[uniqueIndex]
			end
			--Store the cell's cellChangeTo packets for preservation
			preserve.packets.cellChangeTo = cell.data.packets.cellChangeTo
			
			wasCellChangeData = true
		end
		
		--Check if the cell has cellChangeFrom data
		if not tableHelper.isEmpty(cell.data.packets.cellChangeFrom) then
			--Record all information pertaining to an object that has come from a different cell
			for index, uniqueIndex in pairs(cell.data.packets.cellChangeFrom) do
				doDebug(uniqueIndex .. " has cellChangeFrom data")
				--Store the object's objectData
				preserve.objectData[uniqueIndex] = cell.data.objectData[uniqueIndex]
				--Loop through all the packets to see which ones contain data concerning this object. For each packet that does, add that information to the preserve table
				for packetKey, data in pairs(cell.data.packets) do
					if tableHelper.containsValue(data, uniqueIndex) then
						--If we don't have a table for this packet type in preserve already, create one
						if preserve.packets[packetKey] == nil then
							preserve.packets[packetKey] = {}
						end
						doDebug(uniqueIndex .. " had packet '" .. packetKey .. "' associated with it")
						--Add the object's uniqueIndex into the packet type's preserve table
						table.insert(preserve.packets[packetKey], uniqueIndex)
					end
				end				
			end
			
			wasCellChangeData = true
		end
		
		if wasCellChangeData then
			doLog("Detected cell change data in cell `" .. cellDescription .. "', preserving...")
		end
	end
	
	--Reset all the cell's data to a base state, preserving anything that should be preserved
	--This probably works
	cell.data = {
        entry = {
            description = cellDescription
        },
		--Technically, both preserve.lastVisit and preserve.objectData will always exist, but keeping the or condition for consistency :P
        lastVisit = preserve.lastVisit or {}, 
        objectData = preserve.objectData or {}, 
        packets = {
            delete = preserve.packets.delete or{},
            place = preserve.packets.place or {},
            spawn = preserve.packets.spawn or {},
            lock = preserve.packets.lock or {},
            trap = preserve.packets.trap or {},
            scale = preserve.packets.scale or {},
            state = preserve.packets.state or {},
            doorState = preserve.packets.doorState or {},
            container = preserve.packets.container or {},
            equipment = preserve.packets.equipment or {},
            actorList = preserve.packets.actorList or {},
            position = preserve.packets.position or {},
            statsDynamic = preserve.packets.statsDynamic or {},
            cellChangeTo = preserve.packets.cellChangeTo or {},
            cellChangeFrom = preserve.packets.cellChangeFrom or {},
        }
    };
	
	cell.data.lastReset = os.time()
	cell:Save()
	
	doLog("Successfully reset cell '" .. cellDescription .. "'")
	return true
end

Methods.CheckCellReset = function(cellDescription)
	doDebug("Checking if cell '" .. cellDescription .. "' can be reset")

	myMod.LoadCell(cellDescription)
	local cell = LoadedCells[cellDescription]
	doDebug("Ensured cell is loaded")
	
	--Check if cell reset needs to be done
	if not cell.data.lastReset then
		--The cell has never been visited when this script was running. For now we'll create a new entry saying that the cell was last reset right now
		doDebug("Creating lastReset time for cell '" .. cellDescription .. "' with missing value")
		cell.data.lastReset = os.time()
		cell:Save()
	end
	
	if os.time() - cell.data.lastReset < config.resetTime then --Enough time hasn't passed between resets
		doDebug("Not enough time has passed in cell '" .. cellDescription .. "' to require cell reset")
		return false
	end
	
	--Make sure that the cell isn't exempt from cell resets
	if not Methods.IsAllowedCellReset(cellDescription) then
		doDebug("Cell '" .. cellDescription .. "' is exempt from cell resets")
		return false
	end
	
	--Check if the cell is empty of players. Resets will only be done in empty cells.
	if cell:GetVisitorCount() > 0 then
		doDebug("Players present in cell - resets can only occur in empty cells. Aborting.")
		return false
	end
	
	--Decide if we're supposed to be doing this the easy way, or the complicated way
	--(please be easy way)
	local easyWay, affectedPlayers = Methods.CanDoEasyWay(cell)
	--If having to do this the complicated way, all affected players need to have the information they have on the cell removed.
	if not easyWay then
		--TEMP
		doDebug("Can't do easy way. Aborting reset")
		return false
	end
	
	doDebug("Don't find any reason to abort, returning true")
	--If we get here, then that means there are no problems!
	return true
end

Methods.TryResetCell = function(cellDescription)
	doDebug("TryResetCell called for cell '" .. cellDescription .. "'...")
	if Methods.CheckCellReset(cellDescription) then
		doLog("Check passed for cell '" .. cellDescription .. "'. Resetting cell.")
		Methods.ResetCell(cellDescription)
		return true
	else
		doDebug("TryResetCell aborted for cell '" .. cellDescription .. "'")
		return false
	end
end

Methods.RegisterExemptCell = function(cellDescription, scriptId)
	if exemptCells[cellDescription] == nil then
		exemptCells[cellDescription] = {}
	end
	
	exemptCells[cellDescription][scriptId] = true
	doDebug(cellDescription .. " registered as exempt cell for " .. scriptId)
end

Methods.UnregisterExemptCell = function(cellDescription, scriptId)
	exemptCells[cellDescription][scriptId] = nil
	
	if tableHelper.isEmpty(exemptCells[cellDescription]) then
		exemptCells[cellDescription] = nil
		doDebug(scriptId .. " removed its claim on cell '" .. cellDescription .. "'. Cell is no longer exempt from resets")
	else
		doDebug(scriptId .. " removed its claim on cell '" .. cellDescription .. "', however it is still an exempt cell due to other script's claims")
	end
end

Methods.Init = function()
	local count = 0
	
	for index, cellDescription in pairs(config.blacklist) do
		Methods.RegisterExemptCell(cellDescription, "CellReset")
		count = count + 1
	end
	
	if count >= 1 then
		doLog("Added " .. count .. " cells from CellReset blacklist to exemptions list.")
	end
end

return Methods
