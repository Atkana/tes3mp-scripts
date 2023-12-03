-- kanaRevive - Release 5 - For tes3mp 0.8-alpha
-- Players enter a downed state before dying. Other players can activate them to revive them!

--[[ INSTALLATION
= GENERAL =
 Save this file as "kanaRevive.lua" in server/custom/scripts

= IN CUSTOMSCRIPTS.LUA =
 Add this line: kanaRevive = require("custom.kanaRevive")
]]

local scriptConfig = {}

scriptConfig.useBleedout = true
scriptConfig.bleedoutTime = 30

-- "cell" - Sends the message to anyone who has the cell loaded | "server" - Sends the message to everyone on the server | "none" - Sends the message to nobody else
scriptConfig.playerDownedAnnounceRadius = "server"
scriptConfig.reviveAnnounceRadius = "server"
scriptConfig.playerDiedAnnounceRadius = "server"

-- "set" - Set the stat to a fixed number () | "preserve" - keeps the value as it is | "percent" - Set the stat to be a % of its maximum
-- Note for preserve: 
scriptConfig.revivedHealthMode = "percent"
scriptConfig.revivedMagickaMode = "preserve"
scriptConfig.revivedFatigueMode = "set"
-- The following are the numbers used if the revive mode is set to "set"
scriptConfig.setModeHealth = 10 -- Obviously, don't use 0 here or they'll be dead...
scriptConfig.setModeMagicka = 0
scriptConfig.setModeFatigue = 0
-- The following are the modifiers used if the revive mode is set to "percent"
-- 0.1 represents 10%. 1 represents 100%
scriptConfig.percentModeHealth = 0.1
scriptConfig.percentModeMagicka = 0.1
scriptConfig.percentModeFatigue = 0.1

-- The following are for the custom player markers
-- Currently, if a player is downed in a separate cell, players entering the cell won't see the corpse
-- Using this option, a marker will be created that players can activate instead.
scriptConfig.useMarkers = true
scriptConfig.markerModel = "o/contain_corpse20.nif"
scriptConfig.baseObjectType = "miscellaneous"
scriptConfig.recordRefId = "kanarevivemarker"

-- Set the following to true when running a permadeath server to allow players to be downed instead of dying.
scriptConfig.allowReviveWithPermadeath = true


local lang = {
	["awaitingReviveMessage"] = "You are awaiting revival.",
	["awaitingReviveOtherMessage"] = "%name has been downed! Activate them to revive them.",
	["bleedingOutMessage"] = "You have %seconds seconds before you bleed out.",
	["giveInPrompt"] = "Type /die to give in.",
	["revivedReceiveMessage"] = "You have been revived by %name.",
	["revivedGiveMessage"] = "You have revived %name.",
	["revivedOtherMessage"] = "%receive has been revived by %give.",
	["bleedoutPlayerMessage"] = "You have died.",
	["bleedoutOtherMessage"] = "%name has bled out.",
	["defaultSuicide"] = "%name committed suicide.",
	["defaultKilledByPlayer"] = "%name was killed by player %killer.",
	["defaultKilledByOther"] = "%name was killed by %killer.",
	["defaultPermanentDeath"] = "You have died permanently.",
	["reviveMarkerName"] = "Player corpse - Use to revive!",
}

---------------------------------------------------------------------------------------
local Methods = {}

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

---------------------------------------------------------------------------------------
local reviveMarkers = {}
local pidMarkerLookup = {}

Methods.CreateReviveMarker = function(pid)
	local playerName = Players[pid].name
	local cellDescription = Players[pid].data.location.cell
	local location = {
		posX = tes3mp.GetPosX(pid),
		posY = tes3mp.GetPosY(pid),
		posZ = tes3mp.GetPosZ(pid) + 10,
		rotX = 0,
		rotY = 0,
		rotZ = tes3mp.GetRotZ(pid)
	}
	
	-- Create the marker
	local useTemporaryLoad = false
	if LoadedCells[cellDescription] == nil then
		logicHandler.LoadCell(cellDescription)
		useTemporaryLoad = true
	end
	
	local objData = { refId = scriptConfig.recordRefId, count = 1, charge = -1, enchantmentCharge = -1, soul = -1}
	local uniqueIndex = logicHandler.CreateObjectAtLocation(cellDescription, location, objData, "place")
	
	if useTemporaryLoad then
		logicHandler.UnloadCell(cellDescription)
	end
	
	reviveMarkers[uniqueIndex] = {playerName = Players[pid].name, cellDescription = cellDescription, pid = pid}
	pidMarkerLookup[pid] = uniqueIndex
	
	-- Delete the marker for the downed player, and anyone who was in the cell
	for pid, player in pairs(Players) do
		if tes3mp.GetCell(pid) == cellDescription then
			logicHandler.DeleteObjectForPlayer(pid, cellDescription, uniqueIndex)
		end
	end
	
	-- A little bit extra to maybe ensure that the player whose marker it is doesn't see it
	logicHandler.DeleteObjectForPlayer(pid, cellDescription, uniqueIndex)
end

Methods.RemoveReviveMarker = function(uniqueIndex, cellDescriptionGiven)
	if uniqueIndex then
		local useTemporaryLoad = false
		
		local cellDescription
		-- The OnObjectActivate call for this function provides a cell description in case the revive marker is from an old session
		-- Use that if provided, otherwise it's safe to get it from looking up its information
		if not cellDescriptionGiven then
			cellDescription = reviveMarkers[uniqueIndex].cellDescription
		else
			cellDescription = cellDescriptionGiven
		end
		
		if LoadedCells[cellDescription] == nil then
			logicHandler.LoadCell(cellDescription)
			useTemporaryLoad = true
		end
		
		logicHandler.DeleteObjectForEveryone(cellDescription, uniqueIndex)
		LoadedCells[cellDescription]:DeleteObjectData(uniqueIndex)
		
		if useTemporaryLoad then
			logicHandler.UnloadCell(cellDescription)
		end
		
		if reviveMarkers[uniqueIndex] then
			pidMarkerLookup[reviveMarkers[uniqueIndex].pid] = nil
		end
		
		reviveMarkers[uniqueIndex] = nil
	end
end

Methods.SendMessageToAllWithCellLoaded = function(cellDescription, message, exceptionPids)
	for pid, player in pairs(Players) do
		if tableHelper.containsValue(player.cellsLoaded, cellDescription) and not tableHelper.containsValue(exceptionPids or {}, pid) then
			tes3mp.SendMessage(pid, message .. "\n")
		end
	end
end

Methods.SendMessageToAllOnServer = function(message, exceptionPids)
	for pid, player in pairs(Players) do
		if not tableHelper.containsValue(exceptionPids or {}, pid) then
			tes3mp.SendMessage(pid, message .. "\n")
		end
	end
end

Methods.IsPlayerDowned = function(pid)
	if Players[pid] ~= nil then
			return Players[pid].data.customVariables.isDowned or false
	else
			return false
	end
end

Methods.CanRevivePlayer = function(pid)
	if Players[pid] ~= nil then
		return not Players[pid].data.customVariables.cannotRevive
	else
		return false
	end
end


Methods.OnPlayerRevive = function(downedPid, reviverPid)
	-- Time to do all the configured stat stuff...
	local healthCurrent = tes3mp.GetHealthCurrent(downedPid)
	local healthBase = Players[downedPid].data.stats.healthBase --We'll use this value instead so we avoid that setting-to-1 bug
	local fatigueCurrent = tes3mp.GetFatigueCurrent(downedPid)
	local fatigueBase = tes3mp.GetFatigueBase(downedPid)
	local magickaCurrent = tes3mp.GetMagickaCurrent(downedPid)
	local magickaBase = tes3mp.GetMagickaBase(downedPid)
	
	local newHealth, newMagicka, newFatigue
	-- Note: We'll clamp them within bounds when everything is done
	
	-- Health
	if scriptConfig.revivedHealthMode == "set" then
		newHealth = scriptConfig.setModeHealth
	elseif scriptConfig.revivedHealthMode == "preserve" then
		-- Health can't be preserved, so set it to 1 instead
		newHealth = 1
	else -- percent
		newHealth = math.floor((healthBase * scriptConfig.percentModeHealth) + 0.5 )
	end
	
	-- Magicka
	if scriptConfig.revivedMagickaMode == "set" then
		newMagicka = scriptConfig.setModeMagicka
	elseif scriptConfig.revivedMagickaMode == "preserve" then
		-- Health can't be preserved, so set it to 1 instead
		newMagicka = magickaCurrent
	else -- percent
		newMagicka = math.floor((magickaBase * scriptConfig.percentModeMagicka) + 0.5 )
	end
	
	-- Fatigue
	if scriptConfig.revivedFatigueMode == "set" then
		newFatigue = scriptConfig.setModeFatigue
	elseif scriptConfig.revivedFatigueMode == "preserve" then
		newFatigue = fatigueCurrent
	else -- Percent
		newFatigue = math.floor((fatigueBase * scriptConfig.percentModeFatigue) + 0.5 )
	end
	
	-- Now we'll clamp these values before we move on
	newHealth = math.max(math.min(newHealth, healthBase), 1)
	newMagicka = math.max(math.min(newMagicka, magickaBase), 0)
	newFatigue = math.max(math.min(newFatigue, fatigueBase), 0)
	
	-- Inform players about the revival
	local exemptPids = {downedPid, reviverPid}
	local downedPlayerName = Players[downedPid].name
	local reviverPlayerName = Players[reviverPid].name
	local cell = Players[downedPid].data.location.cell
	local broadcastMessage = Methods.GetLangText("revivedOtherMessage", {receive = downedPlayerName, give = reviverPlayerName})
	
	-- ...Inform the player being revived
	tes3mp.SendMessage(downedPid, Methods.GetLangText("revivedReceiveMessage", {name = reviverPlayerName}) .. "\n")
	
	-- ...Inform the reviver
	tes3mp.SendMessage(reviverPid, Methods.GetLangText("revivedGiveMessage", {name = downedPlayerName}) .. "\n")
	
	-- ...Inform others (if configured)
	if scriptConfig.reviveAnnounceRadius == "cell" then
		Methods.SendMessageToAllWithCellLoaded(cell, broadcastMessage, exemptPids)
	elseif scriptConfig.reviveAnnounceRadius == "server" then
		Methods.SendMessageToAllOnServer(broadcastMessage, exemptPids)
	end
	
	-- Now finally actually revive the player
	Players[downedPid].data.customVariables.isDowned = false
	contentFixer.UnequipDeadlyItems(downedPid)
	tes3mp.Resurrect(downedPid, 0)
	
	-- Set the players stats...
	tes3mp.SetHealthCurrent(downedPid, newHealth)
	tes3mp.SetMagickaCurrent(downedPid, newMagicka)
	tes3mp.SetFatigueCurrent(downedPid, newFatigue)
	
	tes3mp.SendStatsDynamic(downedPid)
	
	-- Cleanup the player's revive marker, if created
	if scriptConfig.useMarkers then
		Methods.RemoveReviveMarker(pidMarkerLookup[downedPid])
	end
end

Methods.OnBleedoutExpire = function(pid)
	Players[pid].data.customVariables.isDowned = false
	
	-- Inform the player
	if config.playersRespawn then
		tes3mp.SendMessage(pid, Methods.GetLangText("bleedoutPlayerMessage") .. "\n")
	else
		tes3mp.SendMessage(pid, Methods.GetLangText("defaultPermanentDeath") .. "\n")
	end
	
	-- Inform others if configured
	local exemptPids = {pid}
	local pname = Players[pid].name
	local message = Methods.GetLangText("bleedoutOtherMessage", {name = pname})
	local cell = Players[pid].data.location.cell
	
	if scriptConfig.playerDiedAnnounceRadius == "cell" then
		Methods.SendMessageToAllWithCellLoaded(cell, message, exemptPids)
	elseif scriptConfig.playerDiedAnnounceRadius == "server" then
		Methods.SendMessageToAllOnServer(message, exemptPids)
	end
	
	-- Resurrect the player, if permadeath is disabled
	if config.playersRespawn then
		-- While we could just jump straight to using Resurrect, we'll faff through the proper channels...
		-- Note: Might have to instead start the regular dying timer, just to be safe
		OnDeathTimeExpiration(pid, Players[pid].accountName)
	else
		-- Set a flag permanently preventing the player from being able to be revived
		Players[pid].data.customVariables.cannotRevive = true
		
	end
	
	-- Cleanup the player's revive marker, if created
	if scriptConfig.useMarkers then
		Methods.RemoveReviveMarker(pidMarkerLookup[pid])
	end
end

Methods.SetPlayerDowned = function(pid, timeRemaining)
	-- Set the variables
	Players[pid].data.customVariables.isDowned = true
	-- If the player logged out while bleeding out, they will have a non-standard number of seconds left
	local secondsLeft
	if not timeRemaining then
		secondsLeft = scriptConfig.bleedoutTime
		Players[pid].data.customVariables.bleedoutTicks = 0
	else
		secondsLeft = timeRemaining
		Players[pid].data.customVariables.bleedoutTicks = scriptConfig.bleedoutTime - secondsLeft
	end
	
	-- Send the first basic messages
	-- ... To the player
	tes3mp.SendMessage(pid, Methods.GetLangText("awaitingReviveMessage") .. "\n")
	
	-- ... And the others (if configured)
	local downedPlayerName = Players[pid].name
	local exemptPids = {pid}
	local cell = Players[pid].data.location.cell
	
	local downBroadcastMessage = Methods.GetLangText("awaitingReviveOtherMessage", {name = downedPlayerName})
	
	if scriptConfig.playerDownedAnnounceRadius == "cell" then
		Methods.SendMessageToAllWithCellLoaded(cell, downBroadcastMessage, exemptPids)
	elseif scriptConfig.playerDownedAnnounceRadius == "server" then
		Methods.SendMessageToAllOnServer(downBroadcastMessage, exemptPids)
	end
	
	-- Do all the bleedout-related things, provided we're configured to do that
	if scriptConfig.useBleedout then
		-- Tell the player that they're bleeding out, and how many seconds they have left
		tes3mp.SendMessage(pid, Methods.GetLangText("bleedingOutMessage", {seconds = secondsLeft}) .. "\n")
		
		-- Start their bleedout timer
		local timerId = tes3mp.CreateTimerEx("BleedoutTick", time.seconds(1), "i", pid)
		Players[pid].data.customVariables["bleedoutTimerId"] = timerId
		tes3mp.StartTimer(timerId)
	end
	
	-- Create a marker, if configured
	if scriptConfig.useMarkers then
		Methods.CreateReviveMarker(pid)
	end
	
	-- Tell the player the command prompt to die
	tes3mp.SendMessage(pid, Methods.GetLangText("giveInPrompt") .. "\n")
end

-- We use this to set a player to the downed state when they die, with a special case for if the player has logged back in after being downed (using a flag set during in Methods.OnPlayerLogin to know)
-- And also obviously we only want to set the player downed if they aren't already
Methods.TrySetPlayerDowned = function(pid)
	if Players[pid].data.customVariables.cannotRevive == true then
		-- Do nothing
	elseif Players[pid].data.customVariables.loggedOutDowned == true then
		local remaining = scriptConfig.bleedoutTime - Players[pid].data.customVariables.bleedoutTicks
		-- Clear the logout flag
		Players[pid].data.customVariables.loggedOutDowned = nil
		
		Methods.SetPlayerDowned(pid, remaining)
	elseif not Methods.IsPlayerDowned(pid) then
		Methods.SetPlayerDowned(pid)
	end
end

customEventHooks.registerValidator("OnPlayerDeath", function(eventStatus, pid)
	-- Here we replicate some of the tesmp default logic that we're blocking
	local message
	if tes3mp.DoesPlayerHavePlayerKiller(pid) and tes3mp.GetPlayerKillerPid(pid) ~= pid then
		local killerPid = tes3mp.GetPlayerKillerPid(pid)
		message = Methods.GetLangText("defaultKilledByPlayer", {name = logicHandler.GetChatName(pid), killer = logicHandler.GetChatName(killerPid)})
	elseif tes3mp.GetPlayerKillerName(pid) ~= "" then
		message = Methods.GetLangText("defaultKilledByOther", {name = logicHandler.GetChatName(pid), killer = tes3mp.GetPlayerKillerName(pid)})
	else
		message = Methods.GetLangText("defaultSuicide", {name = logicHandler.GetChatName(pid)})
	end
	
	tes3mp.SendMessage(pid, message .. "\n", true)
	
	if config.playersRespawn or scriptConfig.allowReviveWithPermadeath then
		Methods.TrySetPlayerDowned(pid)
	else
		tes3mp.SendMessage(pid, Methods.GetLangText("defaultPermanentDeath") .. "\n", false)
		return customEventHooks.makeEventStatus(false, true)
	end

	return customEventHooks.makeEventStatus(false, false)
end)

-------------
Methods.OnDieCommand = function(pid)
	-- Only do anything if the player is actually downed
	if Methods.IsPlayerDowned(pid) then
		return Methods.OnBleedoutExpire(pid)
	end
end

customCommandHooks.registerCommand("die", Methods.OnDieCommand)

Methods.OnPlayerLogin = function(pid)
	-- Check if a player logged out while downed
	-- If they did, set the flags up for them to resume bleeding out when their death event triggers
	if Players[pid].data.customVariables.isDowned then
		Players[pid]:SetHealthCurrent(0) -- Just to ensure they're always dead
		Players[pid].data.customVariables.loggedOutDowned = true
		-- The rest of setting up / resuming is left to the death event
	end
end

customEventHooks.registerHandler("OnPlayerFinishLogin", function (eventStatus, pid)
Methods.OnPlayerLogin(pid)
end)

Methods.OnObjectActivate = function(pid, cellDescription)
	-- A lot of this code is copied from eventHandler.OnObjectActivate
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		if LoadedCells[cellDescription] ~= nil then
			tes3mp.ReadReceivedObjectList()
			
			for index = 0, tes3mp.GetObjectListSize() - 1 do
				local objectPid
				local activatorPid
				local objectUniqueIndex
				local objectRefId
				
				-- Detect if the object being activated is a player
				if tes3mp.IsObjectPlayer(index) then
					objectPid = tes3mp.GetObjectPid(index)
				else
					objectUniqueIndex = tes3mp.GetObjectRefNum(index) .. "-" .. tes3mp.GetObjectMpNum(index)
					objectRefId = tes3mp.GetObjectRefId(index)
				end
				
				-- Detect if the object was activated by a player
				if tes3mp.DoesObjectHavePlayerActivating(index) then
					activatorPid = tes3mp.GetObjectActivatingPid(index)
				end
				
				-- If a player was activating a player...
				if objectPid and activatorPid then
					-- Check if the target player is currently downed
					if Methods.IsPlayerDowned(objectPid) then
						-- Revive them!
						Methods.OnPlayerRevive(objectPid, activatorPid)
					end
				elseif objectRefId == scriptConfig.recordRefId then
					-- The player activated a revive marker!
					if reviveMarkers[objectUniqueIndex] and Methods.IsPlayerDowned(reviveMarkers[objectUniqueIndex].pid) then
						Methods.OnPlayerRevive(reviveMarkers[objectUniqueIndex].pid, activatorPid)
					end
					
					-- It's possible that markers might be left over from previous sessions, so we'll always make sure to delete one that's activated
					Methods.RemoveReviveMarker(objectUniqueIndex, cellDescription)
				end
			end
		end
	end
end

customEventHooks.registerHandler("OnObjectActivate", function(eventStatus, pid, cellDescription, objects, players)
Methods.OnObjectActivate(pid, cellDescription)
end)	

Methods.OnServerPostInit = function()
	-- Detect if this script's permanent record has been created on this server yet
	-- If it hasn't, create it
	if RecordStores[scriptConfig.baseObjectType].data.permanentRecords[scriptConfig.recordRefId] == nil then
		local data = {model = scriptConfig.markerModel, name = Methods.GetLangText("reviveMarkerName"), script = "nopickup"}
		
		RecordStores[scriptConfig.baseObjectType].data.permanentRecords[scriptConfig.recordRefId] = data
		
		RecordStores[scriptConfig.baseObjectType]:Save()
	end
end

customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
Methods.OnServerPostInit()
end)

Methods.OnPlayerDisconnect = function(pid)
	-- Remove the revive markers of players who disconnect
	if Methods.IsPlayerDowned(pid) and scriptConfig.useMarkers then
		Methods.RemoveReviveMarker(pidMarkerLookup[pid])
	end
end

customEventHooks.registerValidator("OnPlayerDisconnect", function(eventStatus, pid)
Methods.OnPlayerDisconnect(pid)
end)

-------------
function BleedoutTick(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local cvars = Players[pid].data.customVariables
		
		-- Check if the player is still supposed to be bleeding out
		if cvars.isDowned ~= nil and cvars.isDowned == true then
			-- Increment timer
			cvars.bleedoutTicks = (cvars.bleedoutTicks or 0) + 1
			
			if scriptConfig.useBleedout and cvars.bleedoutTicks >= scriptConfig.bleedoutTime then
				-- Player has exceeded bleedout time!
				return Methods.OnBleedoutExpire(pid)
			else
				-- Queue up another tick countdown
				local timerId = cvars.bleedoutTimerId
				return tes3mp.RestartTimer(timerId, time.seconds(1))
			end
		else
			-- The player is no longer bleeding out, so we don't need to do anything
			return
		end
	end
end
-------------
return Methods
