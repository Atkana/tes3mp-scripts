--bannedEquipment - Release 2 - For tes3mp v0.6.1
--Disallow select items from being equipped by players.

local Methods = {}

--[[ INSTALLATION
1) Save as bannedEquipment.lua in the scripts folder
2) Add the following line to OnPlayerEquipment in server.lua
	[ bannedEquipment.OnPlayerEquipment(pid) ]
]]
color = require("color")

--Add item ref of items in the style of the example. RefIds should be in all lowercase.
local equipBanList = {}
--equipBanList["daedric dagger"] = true

Methods.OnPlayerEquipment = function(pid)
	local changes = false
	for slotId, itemData in pairs(Players[pid].data.equipment) do
		if equipBanList[itemData.refId] then
			Players[pid].data.equipment[slotId] = nil
			Players[pid]:LoadInventory()
			Players[pid]:LoadEquipment()
			changes = true
		end
	end
	if changes then
		tes3mp.SendMessage(pid, color.Warning .. "Banned equipment has been unequipped.\n" ..color.Default, false)
		--This hack updates the player's inventory if it's open. There may be a better way of doing this.
		tes3mp.SendCell(pid)
		tes3mp.SendPos(pid)
	end
end

return Methods
