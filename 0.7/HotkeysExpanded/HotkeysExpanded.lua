-- HotkeysExpanded - Release 1 - For tes3mp 0.7-prerelease

--[[ INSTALLATION
1) Save file as "HotkeysExpanded.lua" in mp-stuff/scripts
2) In serverCore add [ HotkeysExpanded = require("HotkeysExpanded") ] directly beneath the line "menuHelper = require("menuHelper")"
3) In serverCore add this to the end of OnServerPostInit
	[	HotkeysExpanded.OnServerPostInit()	]
4) In serverCore add this to the end of OnGUIAction
	[	if HotkeysExpanded.OnGUIAction(pid, idGui, data) then return end	]
5) In serverCore add this to the end of OnPlayerQuickKeys
	[	HotkeysExpanded.OnPlayerQuickKeys(pid)	]
6) In commandHandler, add this to the elseif block of ProcessCommand
[	elseif (cmd[1] == "hotkey" or cmd[1] == "hotkeys" or cmd[1] == "hex") then
		HotkeysExpanded.OnCommand(pid)	]
7) In eventHandler add this directly above the line "tes3mp.SendItemUse(pid)" in OnPlayerItemUse
	[	if HotkeysExpanded.OnPlayerItemUse(pid, itemRefId) then return end	]

]]

--[[ TODO:
- Remove references to old features? (saveOutfit, runFunction)
- Make separate create/use rank permissions?
- Method of deleting items
]]

--[[ NOTES:
- The items can't be activated using quick keys at the moment due to a tes3mp bug
- Two items with the same name will combine in the inventory, potentially losing access to some of it's data.
	For example, if a player holding $custom_book_1 (named "[HEx] Equip Outfit: fancy") were to pick up a different hotkey item for an outfit of the same name (so in this example a $custom_book_10 named "[HEx] Equip Outfit: fancy"), the item would stack with the $custom_book_1 in the inventory, changing into one. The player would then no longer be able to access the outfit stored in the $custom_book_10

]]

local scriptConfig = {}
-- Ranks - The staff ranks required to be able to use each feature
-- NOTE: This only governs who can /create/ the items. Permissions aren't checked when using the items!
scriptConfig.rankOutfits = 0 --The staffRank required to use Equip Outfit
scriptConfig.rankRunFunction = 3 --The staffRank required to use Run Set Function
scriptConfig.rankMessageChat = 0 --The staffRank required to use Message Chat
scriptConfig.rankPlaySound = 3 --The staffRank required to use Play Sound
scriptConfig.rankBarSwitch = 0 --The staffRank required to use Hotkey Bar Switch
scriptConfig.rankUseCommand = 0 --The staffRank required to even use the command to open the GUI

scriptConfig.commandItemBaseId = "sc_paper plain" --The default item that every command item is based off
scriptConfig.totallyVitalFeatureEnabled = true -- Items created by this script *might* have stupid easter eggs as their text. Players are unlikely to see them, and ultimately it just leads to taking up more memory space. Set to false to disable.

scriptConfig.logging = true --If enabled, sends basic log messages to the server log
scriptConfig.debug = false --If enabled, sends debug log messages to the server log
-- GUI IDs
-- IDs used internally by the script. You'll only every have to change them should they clash with another script's
scriptConfig.GUIMain = 407000
scriptConfig.GUISaveOutfitPrompt = 407001 --Spooky phantom GUI. WooOOOoo
scriptConfig.GUIEquipOutfitPrompt = 407002
scriptConfig.GUIChatMessagePrompt = 407003
scriptConfig.GUIPlaySoundPrompt = 407004
scriptConfig.GUIHotkeyBarPrompt = 407005
scriptConfig.GUIFunctionSetStageAPrompt = 407006
scriptConfig.GUIFunctionSetStageBPrompt = 407007


local lang = {
	-- Hotkey Item Names
	["equipOutfitItemName"] = "[HEx] Equip Outfit: %name",
	["runFunctionItemName"] = "[HEx] Run Function: %name",
	["runSetFunctionItemName"] = "[HEx] Run Function: %name (%text)",
	["sendChatMessageItemName"] = "[HEx] Send Chat Message: '%text'",
	["runChatCommandItemName"] = "[HEx] Run Chat Command: '%text'",
	["playSoundItemName"] = "[HEx] Play Sound: %text",
	["switchHotkeyBarItemName"] = "[HEx] Switch to Quick Key Bar: %name",
	-- Main GUI information
	["mainGUIMessage"] = "Welcome to Hotkeys Expanded (yes, I know they're called \"quick keys\"). Using this menu, you can create special items that, when used, will perform special effects. Here's a list of all the sorts of items you can create and what they do...",
	["equipOutfitInfo"] = "Equip what you were wearing at time of creation.",
	["chatMessageInfo"] = "Send a message to chat. You can use this to send chat commands also.",
	["playSoundInfo"] = "Play a given sound file (uses the sound file's path).",
	["switchBarInfo"] = "Swap to a different quick key bar of the given name.",
	["runFunctionSetInfo"] = "Run a registered script function with set arguments.",
	-- Buttons for the Main menu
	["equipOutfitButton"] = "Equip Outfit",
	["saveOutfitButton"] = "Save Current Outfit", --*Notices bulge in table*
	["runFunctionButton"] = "Run Function", --OwO, what's this?
	["runFunctionSetButton"] = "Run Function (Set args)",
	["chatMessageButton"] = "Chat Message",
	["playSoundButton"] = "Play Sound",
	["switchBarButton"] = "Switch Quick Key Bar",
	-- Prompt GUI messages. These can't be too long or they'll pan off the page
	["equipOutfitPromptMessage"] = "Enter a name for your current outfit",
	["chatMessagePromptMessage"] = "Enter some text you want to post to chat with this item. If it begins with /, it'll perform a chat command instead",
	["playSoundPromptMessage"] = "Enter the path of the sound you want to play with this item. Example: Vo\\Misc\\Dagoth Ur Welcome C.mp3",
	["switchBarPromptMessage"] = "Enter the name of the quick key bar you want to switch to with this item",
	["runFunctionSetPromptMessageA"] = "Enter the key of the script function you want this item to execute",
	["runFunctionSetPromptMessageB"] = "Enter the arg string for the script function you want this item to execute",
	-- Hotkey Item use confirmations
	["notifyEquipOutfitSuccess"] = "You put on your %name outfit",
	["notifyEquipOutfitMissing"] = "You put on your %name outfit, though some/all of the items are missing",
	["notifyEquipOutfitFail"] = "You don't have an outfit called %name",
	["notifySwitchBarSuccess"] = "You've swapped to your %name quick keys",
	["notifyRunFunctionSetSuccess"] = "Ran function %name with args: %text",
	["notifyRunFunctionSetFail"] = "There is no registered script function called %name!",
	-- Hotkey Creation confirmations
	["saveOutfitSuccess"] = "Successfully saved current outfit as '%name'",
	["notifyEquipOutfitCreationSuccess"] = "An item for equipping your '%name' outfit has been added to your inventory",
	["notifyChatMessageCreationSuccess"] = "An item for saying '%text' has been added to your inventory",
	["notifyPlaySoundCreationSuccess"] = "An item for playing the sound '%text' has been added to your inventory",
	["notifySwitchBarCreationSuccess"] = "An item for swapping to your '%name' bar has been added to your inventory",
	["notifyRunFunctionSetCreationSuccess"] = "An item for executing '%name' with args '%text' has been added to your inventory",
	-- Hotkey Creation errors (I don't think any of these are used any more)
	["errorInvalidName"] = "Please enter a valid name",
	["errorInvalidString"] = "Please enter a valid string",
	-- Misc
	["noCommandPermission"] = "You don't have permission to use that command",
}

----------------------------------------------------------------------------------
jsonInterface = require("jsonInterface")
tableHelper = require("tableHelper")
logicHandler = require("logicHandler")
require("color")
require("config")

math.randomseed(os.time()) math.random() math.random() math.random()

local Methods = {}
local scriptData = {players = {}, items = {}}
local registeredFunctions = {} --Stores all functions registered by other scripts (using HotkeysExpanded.RegisterScriptFunction(key, function))

-------------------
local function doLog(text)
	if scriptConfig.logging then
		tes3mp.LogMessage(1, "[HotkeysExpanded] " .. text)
	end
end

local function dbg(text)
	if scriptConfig.debug then
		tes3mp.LogMessage(1, "[HotkeysExpanded - DEBUG] " .. text)
	end
end

local function msg(pid, text, textColor)
	local message = (textColor or "") .. text .. "\n" .. color.Default

	tes3mp.SendMessage(pid, message, false)
end

Methods.Save = function()
	jsonInterface.save("HotkeysExpanded.json", scriptData)
end

Methods.Load = function()
	scriptData = jsonInterface.load("HotkeysExpanded.json")
end

local function getName(pid)
	return string.lower(Players[pid].accountName)
end

Methods.OnServerPostInit = function()
	local file = io.open(tes3mp.GetModDir() .. "/HotkeysExpanded.json", "r")
	if file ~= nil then
		io.close()
		Methods.Load()
	else
		Methods.Save()
	end
end

-------------------
Methods.GetScriptItemData = function(itemName)
	return scriptData.items[itemName]
end

--Used to create a new entry in the script's player data
Methods.CreatePlayerData = function(pname)
	local player = logicHandler.GetPlayerByName(pname)
	
	local newPlayer = {
		outfits = {},
		hotkeyBars = {},
		currentHotkeyBar = "default"
	}
	
	--Add the player's current hotkey bar information to the data table, under "default"
	newPlayer.hotkeyBars["default"] = tableHelper.shallowCopy(player.data.quickKeys)
	
	--Save the new player data
	scriptData.players[pname] = newPlayer
	Methods.Save()
	
	doLog("Created player data for new player - " .. pname)
	
	return scriptData.players[pname]
end

Methods.GetScriptPlayerData = function(pname)
	if scriptData.players[pname] ~= nil then
		--Player has existing data
		return scriptData.players[pname]
	else
		--Player doesn't have any data. Automatically create a new entry and return it.
		return Methods.CreatePlayerData(pname)
	end
end

Methods.IsHotkeysExpandedItem = function(itemId)
	if scriptData.items[itemId] then
		return true, scriptData.items[itemId]
	else
		return false
	end
end

-- Use the following to register a function from you script for use with this script's RunFunction feature
-- key is a unique text identifier for your specific function, func is the function that will be run.
-- The script will send the player's arg string as the first argument when running the provided function
-- Functions must be registered every time the server is started
Methods.RegisterScriptFunction = function(key, func)
	registeredFunctions[string.lower(key)] = func
end

-- Use the following to unregister a function.
-- key is the identifier you provided when registering
Methods.UnregisterScriptFunction = function(key)
	registeredFunctions[string.lower(key)] = nil
end

Methods.GetLangText = function(key, data)
	local function replacer(wildcard)
		if data[wildcard] then
			return data[wildcard]
		else
			return "(MISSING WILDCARD)"
		end
	end
	
	local text = lang[key] or "(MISSING TEXT)"
	text = text:gsub("%%(%w+)", replacer)
	
	return text
end

-------------------
-- Because at the moment, using quick keys will read the hotkey item, and there's nothing to prevent players dropping the items and reading them, there's a chance that players will see the item's text.
local easterEggText = {"WOE UPON YOU", "Missing: Engraved Ring of Healing. If found, return to Fargoth.<BR><BR>No reward offered.", "[Engraved in the book is an exceptionally designed image of a Dunmer and cliffracers. The Dunmer is surrounded by the cliffracers. The Dunmer looks terrified.]", "New NPC singles in your area!", "[Depicted on the page is a doodle of a mudcrab drunk on sujamma.]", "[The pages are filled with a worrying number of pictures depicting cliffracers being killed in an impressive variety of ways.]", '[The book contains diagrams and instructions concerning the "optimal placement" of pillows when constructing pillow forts.]', "Ahnassi best waifu.", "TeamFOSS woz here."}
local bookStartString = '<DIV ALIGN="LEFT"><FONT COLOR="000000" SIZE="3" FACE="Magic Cards"><BR>'
local function getEasterEggText()
	return bookStartString .. easterEggText[math.random(1, #easterEggText)] .. "<BR><BR>"
end

local function giveItemToOnlinePlayer(pid, itemData)
	if not itemData.refId then return false end
	local isGenerated = logicHandler.IsGeneratedRecord(itemData.refId)
	
	dbg("giveItemToOnlinePlayer - refId = " .. tostring(itemData.refId))
	dbg("giveItemToOnlinePlayer - isGenerated = " .. tostring(isGenerated))
	
	local item = {
		refId = itemData.refId,
		count = itemData.count or 1,
		charge = itemData.charge or -1,
		enchantmentCharge = itemData.enchantmentCharge or -1,
		soul = itemData.soul or "",
	}
	inventoryHelper.addItem(Players[pid].data.inventory, item.refId, item.count, item.charge, item.enchantmentCharge, item.soul)
	
	if isGenerated then
		local recordType = string.match(itemData.refId, "_(%a+)_")
		dbg("giveItemToOnlinePlayer - recordType = " .. tostring(recordType))
		
		Players[pid]:AddLinkToRecord(recordType, itemData.refId)
		
		-- Exchange records with players in cell
		local currentCellDescription = tes3mp.GetCell(pid)
		
		if LoadedCells[currentCellDescription] ~= nil then
			logicHandler.ExchangeGeneratedRecords(pid, LoadedCells[currentCellDescription].visitors)
		end
	end
	
	Players[pid]:Save()
	Players[pid]:LoadItemChanges({item}, enumerations.inventory.ADD)
end

-- Certain records require specific values entered when not creating from a baseId
-- This provides some defaults that the function will automatically fall back to, rather than erroring out.
-- See config.requiredRecordSettings for more details
local requiredRecordDefaults = {
	armor = {name = "Unnamed armor", model = "a\\A_Iron_Cuirass_GND.nif"},
	book = {name = "Unnamed book", model = "m\\Text_Note_01.nif"},
	clothing = {name = "Unnamed clothing", model = "c\\C_M_Shirt_GND_common01.nif"},
	creature = {name = "Unnamed creature", model = "r\\Rust rat.NIF"},
	enchantment = {},
	miscellaneous = {name = "Unnamed misc item", model = "m\\Misc_Com_Pillow_01.NIF"},
	npc = {name = "Unnamed NPC", race = "Dark Elf", class = "acrobat"},
	potion = {name = "Unnamed potion", model = "m\\Misc_Potion_Cheap_01.nif"},
	spell = {name = "Unnamed spell"},
	weapon = {name = "Unnamed weapon", model = "w\\W_CLUB_IRON.nif"},
}

-- Most of this is just copypastad from the commandHandler implementation
local function CreateRecord(recordType, data, creatorPid)
	-- Check is valid recordType
	if not config.validRecordSettings[recordType] then
		-- Not an official recordType. Abort
		return false
	end
	
	-- baseId related checks
	if data.baseId == nil then
		-- Special exception: Don't allow creatures to be made if lacking baseId
		if recordType == "creature" then
			return false
		end
		
		-- If required data is missing, get it from our defaults table
		for _, requiredSetting in pairs(config.requiredRecordSettings[recordType]) do
            if data[requiredSetting] == nil then
                data[requiredSetting] = requiredRecordDefaults[recordType][requiredSetting]
            end
        end
	end
	
	local id = data.id
	local isGenerated = id == nil or logicHandler.IsGeneratedRecord(id)
	
	local enchantmentStore
	local hasGeneratedEnchantment = tableHelper.containsValue(config.enchantableRecordTypes, recordType) and
        data.enchantmentId ~= nil and logicHandler.IsGeneratedRecord(data.enchantmentId)
		
	if hasGeneratedEnchantment then
        -- Ensure the generated enchantment used by this record actually exists
        if isGenerated then
            enchantmentStore = RecordStores["enchantment"]

            if enchantmentStore.data.generatedRecords[data.enchantmentId] == nil then
				-- Enchantment record doesn't exist!
                return false
            end
        -- Permanent records should only use other permanent records as enchantments, so
        -- go no further if that is not the case
        else
            return false
        end
    end
	
	local recordStore = RecordStores[recordType]
	
	if id == nil then
		id = recordStore:GenerateRecordId()
		isGenerated = true
	end
	
	-- Don't need to retain the id data that's inside data anymore
	-- It'll get in the way when we use data as the record's information
	data.id = nil
	
	-- Special-case defaults:	
	-- An NPC with no baseId won't have stats if autoCalc isn't enabled
	if recordType == "npc" and data.baseId == nil and data.autoCalc == nil then
		data.autoCalc = 1
	end
	
	-- Ensure books without skillId data are set to not be skillbooks
	if recordType == "book" and data.skillId == nil then
		data.skillId = -1
	end
	
	-- Actually generate + store the item
	if isGenerated then
		recordStore.data.generatedRecords[id] = data
		-- This record will be sent to everyone on the server below, so track it
        -- as having already been received by players
        for _, player in pairs(Players) do
            if not tableHelper.containsValue(Players[creatorPid].generatedRecordsReceived, id) then
                table.insert(player.generatedRecordsReceived, id)
            end
        end

        -- Is this an enchantable record using an enchantment from a generated record?
        -- If so, add a link to this record for that enchantment record
        if hasGeneratedEnchantment then
            enchantmentStore:AddLinkToRecord(data.enchantmentId, id, recordType)
            enchantmentStore:Save()
        end
	else
		recordStore.data.permanentRecords[id] = data
	end
	
	recordStore:Save()
	
	tes3mp.ClearRecords()
	tes3mp.SetRecordType(enumerations.recordType[string.upper(recordType)])
	
	if recordType == "armor" then packetBuilder.AddArmorRecord(id, data)
    elseif recordType == "book" then packetBuilder.AddBookRecord(id, data)
    elseif recordType == "clothing" then packetBuilder.AddClothingRecord(id, data)
    elseif recordType == "creature" then packetBuilder.AddCreatureRecord(id, data)
    elseif recordType == "enchantment" then packetBuilder.AddEnchantmentRecord(id, data)
    elseif recordType == "miscellaneous" then packetBuilder.AddMiscellaneousRecord(id, data)
    elseif recordType == "npc" then packetBuilder.AddNpcRecord(id, data)
    elseif recordType == "potion" then packetBuilder.AddPotionRecord(id, data)
    elseif recordType == "spell" then packetBuilder.AddSpellRecord(id, data)
    elseif recordType == "weapon" then packetBuilder.AddWeaponRecord(id, data) end

    tes3mp.SendRecordDynamic(creatorPid, true, false)
	
	return id
end


Methods.CreateCommandItem = function(pid, commandType, hexItemData)
	-- STAGE 1 - Create the item record
	local recordData = {}
	-- For now, the only thing that varies for each command is the name of the item
	local name
	
	if commandType == "equipOutfit" then
		name = Methods.GetLangText("equipOutfitItemName", {name = hexItemData.name})
	elseif commandType == "runFunction" then
		name = Methods.GetLangText("runFunctionItemName", {name = hexItemData.name})
	elseif commandType == "runFunctionSet" then
		name = Methods.GetLangText("runSetFunctionItemName", {name = hexItemData.name, text = hexItemData.text})
	elseif commandType == "chatMessage" then
		name = Methods.GetLangText("sendChatMessageItemName", {text = hexItemData.text})
	elseif commandType == "playSound" then
		name = Methods.GetLangText("playSoundItemName", {text = hexItemData.text})
	elseif commandType == "switchBar" then
		name = Methods.GetLangText("switchHotkeyBarItemName", {name = hexItemData.name})
	end
	
	recordData.baseId = scriptConfig.commandItemBaseId
	recordData.name = name
	recordData.value = 0
	recordData.weight = 0
	recordData.scrollState = false --We do this so the game treats this as a book, and thus is unenchantable
	-- Add dumb easter egg text if enabled.
	if scriptConfig.totallyVitalFeatureEnabled then
		recordData.text = getEasterEggText()
	end
	
	local itemId = CreateRecord("book", recordData, pid)
	
	-- STAGE 2 - Give the item to the player
	local itemData = {}
	
	itemData.refId = itemId
	--That's literally all we actually need
	
	giveItemToOnlinePlayer(pid, itemData)
		
	-- STAGE 3 - Add the item to this script's record of items, as well as its purpose
	scriptData.items[itemId] = {
		commandType = commandType,
		name = hexItemData.name or nil,
		text = hexItemData.text or nil
	}
	
	doLog("Created new Hotkey item of type '" .. commandType .. "' for player " .. getName(pid))
	
	Methods.Save()
	return itemId
end

-- Appends the outfit data to an existing hotkey item. Uses the online player's equipment for the outfit.
Methods.SavePlayerOutfitForItem = function(pid, itemId, outfitName)
	local idata = Methods.GetScriptItemData(itemId)
	
	-- Go through player's current equipment and save the refId of each item keyed under its slot ID
	local outfit = {}
	for slotId, data in pairs(Players[pid].data.equipment) do
		outfit[slotId] = data.refId
	end
	
	-- Save the outfit to the item's info
	idata.outfit = outfit
	Methods.Save()
	
	doLog("Saved outfit named '" .. idata.name .. "' to item '" .. itemId .. "' using player '" .. getName(pid) .. "'s' current equipment")
end

Methods.HotkeyEquipOutfit = function(pid, hotkeyItemId)
	local idata = Methods.GetScriptItemData(hotkeyItemId)
	
	local foundAll = true
	local newEquipment = {} -- This is the table we'll replace the players data.equipment with
	
	-- Technically this is an inefficient way of doing this, but it's easier to make sense of :P
	for slotId, itemId in pairs(idata.outfit) do
		-- Try to find a valid equipable in the player's inventory
		-- IE the item exists and isn't broken
		local found = false
		
		for index, itemData in ipairs(Players[pid].data.inventory) do
			-- Check if the item matches the one in the outfit
			if itemData.refId == itemId then
				-- Check the item isn't broken
				if itemData.charge == -1 or itemData.charge > 0 then
					-- We found a valid item!
					newEquipment[tonumber(slotId)] = {
						enchantmentCharge = itemData.enchantmentCharge,
						count = 1,
						refId = itemData.refId,
						charge = itemData.charge
					}
					
					found = true
					break
				end
			end
		end
		
		-- If we didn't find an item, then we need to record that
		if not found then
			foundAll = false
		end
	end
	
	doLog("Equipping outfit '" .. idata.name .. "' for " .. getName(pid))
	Players[pid].data.equipment = newEquipment
	Players[pid]:LoadEquipment()
	
	-- Do notifications in here?
	local message
	if foundAll == false then
		message = Methods.GetLangText("notifyEquipOutfitMissing", {name = idata.name})
	else
		message = Methods.GetLangText("notifyEquipOutfitSuccess", {name = idata.name})
	end
	
	msg(pid, message, color.Warning)
end

Methods.HotkeySendChat = function(pid, text)
	eventHandler.OnPlayerSendMessage(pid, text)
	doLog(getName(pid) .. " sent message " .. text)
end

Methods.HotkeyPlaySound = function(pid, path)
	tes3mp.PlaySpeech(pid, path)
	doLog(getName(pid) .. " played sound " .. path)
end

Methods.HotkeySwitchBar = function(pid, name)
	local playerScriptData = Methods.GetScriptPlayerData(getName(pid))
	local barName = string.lower(name)
	
	-- If the player doesn't have a hotkey bar with that name, create one
	if playerScriptData.hotkeyBars[barName] == nil then
		playerScriptData.hotkeyBars[barName] = {}
	end
	
	-- Create a new table that we'll use to replace the player's quickKey data with later
	local newQuickKeys = tableHelper.shallowCopy(playerScriptData.hotkeyBars[barName])
	
	-- Unassign all the player's current quick key entries
	-- Otherwise when the player opens their quick keys, they'll see empty slots as containing what their previous bar had in that slot
	-- Even with doing this, the first filled slot still has that problem for some reason...
	-- TODO: Find out why
	if Players[pid].data.quickKeys ~= nil then
		tes3mp.ClearQuickKeyChanges(pid)
		
		for slot, currentQuickKey in pairs(Players[pid].data.quickKeys) do
			tes3mp.AddQuickKey(pid, slot, 3, currentQuickKey.itemId) -- Argument 3 is UNASSIGNED
		end
		
		tes3mp.SendQuickKeyChanges(pid)
	end
	
	-- Use the hotkey bar data to replace the player's current quickkeys
	Players[pid].data.quickKeys = newQuickKeys
	Players[pid]:Save() --Don't know if this is actually required
	
	-- Set the player's current hotkey bar to this new one
	playerScriptData.currentHotkeyBar = barName
	
	Methods.Save()
	Players[pid]:LoadQuickKeys()
	
	msg(pid, Methods.GetLangText("notifySwitchBarSuccess", {name = barName}) , color.Warning)
	doLog(getName(pid) .. " switched to their '" .. barName .. "' quick key bar")
end

Methods.HotkeyRunFunctionSet = function(pid, funcName, funcArgs)
	local funcName = string.lower(funcName)
	
	if not registeredFunctions[funcName] then
		doLog(getName(pid) .. " attempted to execute non-registered function: " .. funcName)
		msg(pid, Methods.GetLangText("notifyRunFunctionSetFail", {name = funcName, text = funcArgs}))
		return false
	end
	
	registeredFunctions[funcName](funcArgs)
	doLog(getName(pid) .. " executed registered function '" .. funcName .. "' with set args: " .. funcArgs)
	
	msg(pid, Methods.GetLangText("notifyRunFunctionSetSuccess", {name = funcName, text = funcArgs}))
end

Methods.OnPlayerItemUse = function(pid, refId)
	if Methods.IsHotkeysExpandedItem(refId) then
		local pname = getName(pid)
		local itemData = scriptData.items[refId]
		
		if itemData.commandType == "equipOutfit" then
			Methods.HotkeyEquipOutfit(pid, refId)
		elseif itemData.commandType == "chatMessage" then
			Methods.HotkeySendChat(pid, itemData.text)
		elseif itemData.commandType == "playSound" then
			Methods.HotkeyPlaySound(pid, itemData.text)
		elseif itemData.commandType == "switchBar" then
			Methods.HotkeySwitchBar(pid, itemData.name)
		elseif itemData.commandType == "runFunctionSet" then
			Methods.HotkeyRunFunctionSet(pid, itemData.name, itemData.text)
		end
		return true --By returning true, we cancel the standard item use execution
	end
end

Methods.OnPlayerQuickKeys = function(pid)
	local playerScriptData = Methods.GetScriptPlayerData(getName(pid))
	
	playerScriptData.hotkeyBars[playerScriptData.currentHotkeyBar] = tableHelper.shallowCopy(Players[pid].data.quickKeys)
	
	Methods.Save()
	doLog("Recording changes to " .. getName(pid) .. "'s quick key bar '" .. playerScriptData.currentHotkeyBar .. "'")
end


-- =========
-- GUI SECTION
-- =========
-- OKAY, this is the last script I do before actually sorting out a system for GUIs
-- Seriously don't use this to learn from, it's a cumbersome mess of redundancies :P

local mainOptionOrder = {"equipOutfit", "switchBar", "chatMessage", "playSound", "runFunctionSet"}

local playerMainOptions = {} --Contains list of all options last presented to the player for the Main GUI. Used by onMainSelection. Set by showMain.
local playerSetFunctionName = {} --Used to save the name of the function while a player creates a runFunctionSet item. Used by x. Set by onFunctionSetStageAEnter

-- Use to check what option player is allowed to use (and so, what options they're given when opening the main menu)
-- Insert extra checks here if you want to alter permission beyond staffRank-related checks
Methods.PlayernameHasPermission = function(pname, optionType)
	local player = logicHandler.GetPlayerByName(pname)
	local pRank = player.data.settings.staffRank
	
	--If there's no player by that name (for whatever reason), abort
	if not player then return false end
	
	if optionType == "equipOutfit" or optionType == "saveOutfit" then
		--Outfits
		if pRank >= scriptConfig.rankOutfits then
			return true
		else
			return false
		end
	elseif optionType == "runFunction" or optionType == "runFunctionSet" then
		--Run Function
		if pRank >= scriptConfig.rankRunFunction then
			return true
		else
			return false
		end
	elseif optionType == "chatMessage" then
		--Chat Message
		if pRank >= scriptConfig.rankMessageChat then
			return true
		else
			return false
		end
	elseif optionType == "playSound" then
		--Play Sound
		if pRank >= scriptConfig.rankPlaySound then
			return true
		else
			return false
		end
	elseif optionType == "switchBar" then
		--Switch Hotkey Bar
		if pRank >= scriptConfig.rankBarSwitch then
			return true
		else
			return false
		end
	elseif optionType == "useCommand" then
		--Open the Main GUI via command
		if pRank >= scriptConfig.rankUseCommand then
			return true
		else
			return false
		end
	else
		--Should never get here
		return false
	end
end

-- FUNCTION SET
-- Stage B
local function onFunctionSetStageBEnter(pid, data)
	local pname = getName(pid)
	
	--Abort if player doesn't have permission
	if not Methods.PlayernameHasPermission(pname, "runFunctionSet") then return false end
	
	-- TODO: Sanity checks?
	-- Create the command item
	local infoTab = {name = playerSetFunctionName[pname], text = data}
	
	Methods.CreateCommandItem(pid, "runFunctionSet", infoTab)
	msg(pid, Methods.GetLangText("notifyRunFunctionSetCreationSuccess", infoTab), color.Warning)
end

local function showFunctionSetStageB(pid)
	local message = Methods.GetLangText("runFunctionSetPromptMessageB")
	
	return tes3mp.InputDialog(pid, scriptConfig.GUIFunctionSetStageBPrompt, "", message)
end

-- Stage A
local function onFunctionSetStageAEnter(pid, data)
	local pname = getName(pid)
	
	--Abort if player doesn't have permission
	if not Methods.PlayernameHasPermission(pname, "runFunctionSet") then return false end
	
	-- Store the function name for later
	playerSetFunctionName[pname] = string.lower(data)
	
	-- Onto the next stage
	return showFunctionSetStageB(pid)
end

local function showFunctionSetStageA(pid)
	local message = Methods.GetLangText("runFunctionSetPromptMessageA")
	
	return tes3mp.InputDialog(pid, scriptConfig.GUIFunctionSetStageAPrompt, "", message)
end

-- SWITCH BAR
local function onSwitchBarEnter(pid, data)
	local pname = getName(pid)
	
	--Abort if player doesn't have permission
	if not Methods.PlayernameHasPermission(pname, "switchBar") then return false end
	-- Ensure it is a string
	local barName = tostring(data)
	
	-- Create the command item
	Methods.CreateCommandItem(pid, "switchBar", {name = string.lower(barName)})
	msg(pid, Methods.GetLangText("notifySwitchBarCreationSuccess", {name = barName}), color.Warning)
end

local function showSwitchBar(pid)
	local message = Methods.GetLangText("switchBarPromptMessage")
	
	return tes3mp.InputDialog(pid, scriptConfig.GUIHotkeyBarPrompt, "", message)
end

-- PLAY SOUND
local function onPlaySoundEnter(pid, data)
	local pname = getName(pid)
	
	--Abort if player doesn't have permission
	if not Methods.PlayernameHasPermission(pname, "playSound") then return false end
	-- Ensure it is a string
	local soundPath = tostring(data)
	
	-- Create the command item
	Methods.CreateCommandItem(pid, "playSound", {text = soundPath})
	msg(pid, Methods.GetLangText("notifyPlaySoundCreationSuccess", {text = soundPath}), color.Warning)
end

local function showPlaySound(pid)
	local message = Methods.GetLangText("playSoundPromptMessage")
	
	return tes3mp.InputDialog(pid, scriptConfig.GUIPlaySoundPrompt, "", message)
end

-- CHAT MESSAGE
local function onChatMessageEnter(pid, data)
	local pname = getName(pid)
	
	--Abort if player doesn't have permission
	if not Methods.PlayernameHasPermission(pname, "chatMessage") then return false end
	-- Ensure it is a string
	local chatString = tostring(data)
	
	-- Create the command item
	Methods.CreateCommandItem(pid, "chatMessage", {text = chatString})
	msg(pid, Methods.GetLangText("notifyChatMessageCreationSuccess", {text = chatString}), color.Warning)
end

local function showChatMessage(pid)
	local message = Methods.GetLangText("chatMessagePromptMessage")
	
	return tes3mp.InputDialog(pid, scriptConfig.GUIChatMessagePrompt, "", message)
end

-- EQUIP OUTFIT
local function onEquipOutfitEnter(pid, data)
	local pname = getName(pid)
	
	--Abort if player doesn't have permission
	if not Methods.PlayernameHasPermission(pname, "equipOutfit") then return false end
	
	-- Ensure it is a string in lowercase
	local outfitName = string.lower(tostring(data))
	
	-- Create the command item
	local itemId = Methods.CreateCommandItem(pid, "equipOutfit", {name = outfitName})
	-- Save the player's outfit to the item
	Methods.SavePlayerOutfitForItem(pid, itemId, outfitName)
	
	--Notify the player
	msg(pid, Methods.GetLangText("notifyEquipOutfitCreationSuccess", {name = outfitName}), color.Warning)
end

local function showEquipOutfit(pid)
	local message = Methods.GetLangText("equipOutfitPromptMessage")
	
	return tes3mp.InputDialog(pid, scriptConfig.GUIEquipOutfitPrompt, "", message)
end

-- MAIN
local function onMainSelection(pid, buttonIndex)
	local choiceIndex = buttonIndex + 1 --Offset because buttonIndex starts at 0
	
	if playerMainOptions[choiceIndex] == "close" then
		-- Player selected Close
		dbg(pid .. " selected close from Main menu")
		return
	elseif playerMainOptions[choiceIndex] == "equipOutfit" then
		-- Player selected Equip Outfit
		dbg(pid .. " selected equipOutfit from Main menu")
		return showEquipOutfit(pid)
	elseif playerMainOptions[choiceIndex] == "chatMessage" then
		-- Player selected chat message
		dbg(pid .. " selected chatMessage from Main menu")
		return showChatMessage(pid)
	elseif playerMainOptions[choiceIndex] == "playSound" then
		-- Player selected play sound
		dbg(pid .. " selected playSound from Main menu")
		return showPlaySound(pid)
	elseif playerMainOptions[choiceIndex] == "switchBar" then
		-- Player selected play sound
		dbg(pid .. " selected switchBar from Main menu")
		return showSwitchBar(pid)
	elseif playerMainOptions[choiceIndex] == "runFunctionSet" then
		-- Player selected play sound
		dbg(pid .. " selected runFunctionSet from Main menu")
		return showFunctionSetStageA(pid)
	end
end

local function showMain(pid)
	local pname = getName(pid)
	
	-- Determine which options the player can utilise, and add them as options
	local options = {}
	local buttons = ""
	
	-- Loop through all the options and check each to see if the player has permission to use it
	-- The mainOptionOrder table (declared elsewhere) lists each option in the order they should appear
	for index, optionId in ipairs(mainOptionOrder) do
		if Methods.PlayernameHasPermission(pname, optionId) then
			-- Player has permission
			-- Add optionId to options table. We'll use the table later to determine what button the player pressed
			table.insert(options, optionId)
			-- Add the button to the button list. The text for each button is stored in lang. The key is the optionId followed by "Button"
			buttons = buttons .. (Methods.GetLangText(optionId .. "Button")) .. ";"
		end
	end
	
	--Add the "Close" option to the end.
	table.insert(options, "close")
	buttons = buttons .. "Close"
	
	-- Set the message
	-- Start with the main information
	local message = Methods.GetLangText("mainGUIMessage") .. "\n\n"
	-- Add on the information for each option that the player has available
	for _, optionId in ipairs(options) do
		if optionId ~= "close" then
			-- The lang key for each option is just the optionId with "Info" added onto the end
			message = message .. color.Yellow .. Methods.GetLangText(optionId .. "Button") .. " - " .. color.White .. Methods.GetLangText(optionId .. "Info") .. "\n"
		end
	end
	
	-- Store the options that the player has
	playerMainOptions = options
	
	-- Show the GUI
	return tes3mp.CustomMessageBox(pid, scriptConfig.GUIMain, message, buttons)
end

Methods.OnGUIAction = function(pid, idGui, data)
	if idGui == scriptConfig.GUIMain then --Main
		onMainSelection(pid, tonumber(data))
		return true
	elseif idGui == scriptConfig.GUIEquipOutfitPrompt then --Equip Outfit
		onEquipOutfitEnter(pid, data)
		return true
	elseif idGui == scriptConfig.GUIChatMessagePrompt then --Chat message
		onChatMessageEnter(pid, data)
		return true
	elseif idGui == scriptConfig.GUIPlaySoundPrompt then -- Play Sound
		onPlaySoundEnter(pid, data)
		return true
	elseif idGui == scriptConfig.GUIHotkeyBarPrompt then -- Change Hotkey Bar
		onSwitchBarEnter(pid, data)
		return true
	elseif idGui == scriptConfig.GUIFunctionSetStageAPrompt then -- Run Set Function, Stage 1
		onFunctionSetStageAEnter(pid, data)
		return true
	elseif idGui == scriptConfig.GUIFunctionSetStageBPrompt then -- Run Set Function, Stage 2
		onFunctionSetStageBEnter(pid, data)
		return true
	end
end

Methods.OnCommand = function(pid)
	if Methods.PlayernameHasPermission(getName(pid), "useCommand") then
		return showMain(pid)
	else
		msg(pid, Methods.GetLangText("noCommandPermission"), color.Warning)
		return false
	end
end

-------------------

return Methods
