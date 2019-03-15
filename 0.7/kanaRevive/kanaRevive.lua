-- kanaRevive - Release 2 - For tes3mp 0.7-prerelease
-- Players enter a downed state before dying. Other players can activate them to revive them!

--[[ INSTALLATION
= GENERAL =
a) Save this file as "kanaRevive.lua" in mp-stuff/scripts

= IN SERVERCORE.LUA =
a) Find the line [ menuHelper = require("menuHelper") ]. Add the following BENEATH it:
	[ kanaRevive = require("kanaRevive") ]
b) Find the line [ eventHandler.OnObjectActivate(pid, cellDescription) ]. Add the following BENEATH it:
	[ kanaRevive.OnObjectActivate(pid, cellDescription) ]

= IN EVENTHANDLER.LUA =
a) Find the line [ Players[pid]:Message("You have successfully logged in.\n" .. config.chatWindowInstructions) ] . Add the following BENEATH it:
	[ kanaRevive.OnPlayerLogin(pid) ]

= IN COMMANDHANDLER.LUA =
a) Find the section:
	[ else
		local message = "Not a valid command. Type /help for more info.\n" ]
	Add the following ABOVE it:
	[ elseif cmd[1] == "die" then
		kanaRevive.OnDieCommand(pid) ]

= IN PLAYER/BASE.LUA =
a) Find the section:
	[ self.resurrectTimerId = tes3mp.CreateTimerEx("OnDeathTimeExpiration",
            time.seconds(config.deathTime), "i", self.pid)
        tes3mp.StartTimer(self.resurrectTimerId) ]
	REPLACE it with the following:
	[ kanaRevive.TrySetPlayerDowned(self.pid) ]
b) If you're running a permadeath server, but want players to have the opportunity to revive, locate (and possibly edit) the line
	[ tes3mp.SendMessage(self.pid, "You have died permanently.", false) ]
	Add the following ABOVE/BELOW it:
	[ kanaRevive.TrySetPlayerDowned(self.pid) ]
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
	return Players[pid].data.customVariables.isDowned or false
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
end

Methods.OnBleedoutExpire = function(pid)
	Players[pid].data.customVariables.isDowned = false
	
	-- Inform the player
	tes3mp.SendMessage(pid, Methods.GetLangText("bleedoutPlayerMessage") .. "\n")
	
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
		OnDeathTimeExpiration(pid)
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
	
	-- Tell the player the command prompt to die
	tes3mp.SendMessage(pid, Methods.GetLangText("giveInPrompt") .. "\n")
end

-- Used by the edits for regular dying.
-- Because the death event fires after login happens, we need to check to see if the player has already resumed a bleedout state (otherwise the death event overwrites it and restarts the counter)
Methods.TrySetPlayerDowned = function(pid)
	if not Methods.IsPlayerDowned(pid) then
		return Methods.SetPlayerDowned(pid)
	end
end

-------------
Methods.OnDieCommand = function(pid)
	-- Only do anything if the player is actually downed
	if Methods.IsPlayerDowned(pid) then
		return Methods.OnBleedoutExpire(pid)
	end
end

Methods.OnPlayerLogin = function(pid)
	-- If the player logged out while bleeding out, trigger them being downed again
	if Players[pid].data.customVariables.isDowned then
		local remaining = scriptConfig.bleedoutTime - Players[pid].data.customVariables.bleedoutTicks
		
		return Methods.SetPlayerDowned(pid, remaining)
	end
end

Methods.OnObjectActivate = function(pid, cellDescription)
	-- A lot of this code is copied from eventHandler.OnObjectActivate
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		if LoadedCells[cellDescription] ~= nil then
			tes3mp.ReadReceivedObjectList()
			
			for index = 0, tes3mp.GetObjectListSize() - 1 do
				local objectPid
				local activatorPid
				
				-- Detect if the object being activated is a player
				if tes3mp.IsObjectPlayer(index) then
					objectPid = tes3mp.GetObjectPid(index)
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
				end
			end
		end
	end
end

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
