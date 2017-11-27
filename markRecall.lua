local Methods = {}

--[[ INSTALLATION:
1) Save this file as "markRecall.lua" in mp-stuff/scripts
2) Add [ markRecall = require("markRecall") ] to the top of server.lua
3) Add the following to the elseif chain for commands in "OnPlayerSendMessage" inside server.lua

[ elseif (cmd[1] == "mark") then
	markRecall.OnMarkCommand(pid)
elseif (cmd[1] == "recall") then
	markRecall.OnRecallCommand(pid) ]

]]

--[[ USAGE:
Type "/mark" into chat to save your current position
Type "/recall" into chat to return to that position

See the config section for how you can configure these functions

You can use [ markRecall.SetCanRecall(pid, [0/1]) ] in your own scripts to disable/enable a player's ability to recall, and [ markRecall.isRecallEnabled(pid) ] for a boolean result that reports if the player has or hasn't had their recall abilities disabled in this way.
]]

--[[ DEVELOPMENT:
Version 3
For TES3MP v0.6.1
=TODO=
- Additional option to allow players with any means (Amulet of Recall, Potion of Marking, etc.) to use the commands
	- And then also have potions consumed/charges used if using the command
- Option to pay money to recall?
=Changelog=
Version 3:
	- For some reason, if isRecallEnabled was Methods.isRecallEnabled, the server would crash whenever it was called... even though it's almost exactly the same in serverWarp, which works fine. For now I've change isRecallEnabled to be a regular function, which means other scripts can't access it anymore. This change might be temporary, or it might be permanent (seeing as I can't find ANY reason why it shouldn't work... :<)
]]

--CONFIG
local config = {}

--If requireSpells is true, the player is required to have the spells in their spellbook if they want to be able to use the respective commands
config.requireSpells = false

--Any cell listed in blacklistCells won't allow for a player to place a Mark in them. See the commented out line below for an example of how to add a cell to the blacklist.
config.blacklistCells = {}
-- config.blacklistCells["Balmora, Hlaalo Manor"] = true

--/CONFIG

Methods.OnMarkCommand = function(pid)
	--Check the player has the mark spell if it's required
	if config.requireSpells and (hasSpell(pid, "mark") == false) then
		tes3mp.SendMessage(pid, "You don't know the Mark spell.\n", false)
		return false
	--Check player is in a non-blacklisted cell
	elseif config.blacklistCells[tes3mp.GetCell(pid)] then
		tes3mp.SendMessage(pid, "You're not allowed to set a Mark in this location.\n", false)
		return false
	end
	
	Players[pid].data.customVariables.markSpot = {}

	local ms = Players[pid].data.customVariables.markSpot
	
	ms.posX = tes3mp.GetPosX(pid) 
	ms.posY = tes3mp.GetPosY(pid) 
	ms.posZ = tes3mp.GetPosZ(pid) 
	ms.cell = tes3mp.GetCell(pid) 
	ms.rotX = tes3mp.GetRotX(pid) 
	ms.rotZ = tes3mp.GetRotZ(pid) 
	
	Players[pid]:Save()
	
	tes3mp.SendMessage(pid, "Mark location set.\n", false)
end

Methods.OnRecallCommand = function(pid)
	--Check the player has a Mark spot
	if Players[pid].data.customVariables.markSpot == nil then
		tes3mp.SendMessage(pid, "You don't have a Marked spot. Use /mark to set one.\n", false)
		return false
	--Check the player has the recall spell if it's required
	elseif config.requireSpells and (hasSpell(pid, "recall") == false) then
		tes3mp.SendMessage(pid, "You don't know the Recall spell.\n", false)
		return false
	--Check if the player's ability to recall isn't disabled by another script
	elseif isRecallEnabled(pid) == false then
		tes3mp.SendMessage(pid, "You can't Recall at this time.\n", false)
		return false
	end

	local ms = Players[pid].data.customVariables.markSpot
	--Following basically copied from myMod.lua Teleport script
	tes3mp.SetCell(pid, ms.cell)
	tes3mp.SendCell(pid)
	
	tes3mp.SetPos(pid, ms.posX, ms.posY, ms.posZ)
	tes3mp.SetRot(pid, ms.rotX, ms.rotZ)
	tes3mp.SendPos(pid)
	
	tes3mp.SendMessage(pid, "You have Recalled.\n", false)
end

Methods.SetCanRecall = function(pid, val)
	--Use 0 to disable, 1 to enable
	Players[pid].data.customVariables.canRecall = val
	Players[pid]:Save()
end

function isRecallEnabled(pid)
	if tonumber(Players[pid].data.customVariables.canRecall) == 0 then
		return false
	else
		return true
	end
end

function hasSpell(pid, spell)
	local has = false
	for k,v in pairs(Players[pid].data.spellbook) do
		if v.spellId == spell then
			has = true
			break
		end	
	end
	return has
end

return Methods
