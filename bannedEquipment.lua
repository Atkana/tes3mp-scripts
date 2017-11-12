--bannedEquipment - Release 1 - For tes3mp v0.6.1
--Disallow select items from being equipped by players.

Methods = {}

--[[ INSTALLATION
1) Save as bannedEquipment.lua in the scripts folder
2) Add the following line to OnPlayerEquipment in server.lua
	[ bannedEquipment.OnPlayerEquipment(pid) ]
]]

--Add item ref of items in the style of the example. RefIds should be in all lowercase.
local equipBanList = {}
--equipBanList["daedric dagger"] = true

Methods.OnPlayerEquipment = function(pid)
	for slotId, itemData in pairs(Players[pid].data.equipment) do
		if equipBanList[itemData.refId] then
			Players[pid].data.equipment[slotId] = nil
			Players[pid]:LoadInventory()
			Players[pid]:LoadEquipment()
		end
	end
	--This hack updates the player's inventory if it's open. There may be a better way of doing this.
	tes3mp.SendCell(pid)
	tes3mp.SendPos(pid)
end

return Methods
