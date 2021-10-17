-- kanaMOTD - Release 2 - For tes3mp 0.7-prerelease
-- Adds a MOTD message.

--[[ INSTALLATION:
1) Save this file as "kanaMOTD.lua" in scripts/custom
2) Save the json file as "kanaMOTD.json" in data/custom
3) Add [ kanaMOTD = require("custom.kanaMOTD") ] to the top of customScripts.lua
]]

local scriptConfig = {}

scriptConfig.loadFromFile = false -- If true, the script will load and use the contents of kanaMOTD.json for the message and titles
scriptConfig.showInChat = true -- If true, the message will be printed into the player's chat
scriptConfig.showMessageBox = true -- If true, the player will be shown a message box upon joining that displays the MOTD

-- The following are the string that'll be used if loadFromFile is set to false
scriptConfig.mainMessage = "This is a [#yellow]MOTD[#default] message"
scriptConfig.motdWindowTitle = "=== MOTD ==="

---------------------------------------------------------------------------------------
jsonInterface = require("jsonInterface")
require("color")
---------------------------------------------------------------------------------------
local Methods = {}

local MOTDmessage
local MOTDtitle

local lowerColors = {}

-- Used to replace specialised color dealies with the actual color code
Methods.ProcessText = function(text)
	local function replacer(wildcard)
		local lc = string.lower(wildcard)
		if lowerColors[lc] then
			-- Was a valid color code
			return lowerColors[lc]
		else
			-- Just happened to be a string that matched the color code signifier we're using
			return ("[##" .. wildcard .. "]")
		end
	end
	
	return text:gsub("%[#(%w+)%]", replacer)	
end

Methods.Load = function()
	local loadedData = jsonInterface.load("custom/kanaMOTD.json")
	MOTDmessage = loadedData.mainMessage
	MOTDtitle = loadedData.title
end

Methods.ShowMOTD = function(eventStatus, pid)
	-- If configured to load from file, refresh the message in case the file has been changed
	if scriptConfig.loadFromFile then
		Methods.Load()
	end
	
	local processedMessage = Methods.ProcessText(MOTDmessage)
	local processedTitle = Methods.ProcessText(MOTDtitle)
	
	if scriptConfig.showInChat then
		tes3mp.SendMessage(pid, color.Warning .. "MOTD: " .. color.Default .. processedMessage .. color.Default .. "\n")
	end
	
	if scriptConfig.showMessageBox then
		local boxMessage = ""
		-- Only add the title in if it isn't blank
		if processedTitle ~= "" then
			boxMessage = boxMessage .. processedTitle .. color.Default .. "\n"
		end
		-- Add the main message
		boxMessage = boxMessage .. processedMessage
		
		tes3mp.CustomMessageBox(pid, -1, boxMessage, "Ok")
	end
end

Methods.Init = function()
	-- Load in the data for the messages
	-- That either means loading from the json, or porting in the messages from the config
	if scriptConfig.loadFromFile then
		Methods.Load()
	else
		MOTDmessage = scriptConfig.mainMessage
		MOTDtitle = scriptConfig.motdWindowTitle
	end
	
	-- Setup lowercase key colors
	for key, colorCode in pairs(color) do
		lowerColors[string.lower(key)] = colorCode
	end
end

---------------------------------------------------------------------------------------

customEventHooks.registerHandler("OnServerPostInit", Methods.Init)
customEventHooks.registerHandler("OnPlayerAuthentified", Methods.ShowMOTD)

---------------------------------------------------------------------------------------
return Methods
