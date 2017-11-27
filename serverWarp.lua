local Methods = {}

--[[ INSTALLATION:
1) Save this file as "serverWarp.lua" in mp-stuff/scripts
2) Add [ serverWarp = require("serverWarp") ] to the top of server.lua
3) Add the following to the elseif chain for commands in "OnPlayerSendMessage" inside server.lua

[	elseif cmd[1] == "warp" and cmd[2] ~=nil then
		serverWarp.OnWarpCommand(pid, tableHelper.concatenateFromIndex(cmd, 2))
	elseif (cmd[1] == "setwarp" or cmd[1] == "setpublicwarp") and cmd[2] ~= nil then
		serverWarp.OnSetWarpCommand(pid, tableHelper.concatenateFromIndex(cmd, 2), (cmd[1] == "setpublicwarp"))
	elseif (cmd[1] == "removewarp" or cmd[1] == "removepublicwarp") and cmd[2] ~= nil then
		serverWarp.OnRemoveWarpCommand(pid, tableHelper.concatenateFromIndex(cmd, 2), (cmd[1] == "removepublicwarp"))
	elseif cmd[1] == "warplist" then
		serverWarp.OnWarpListCommand(pid)
	elseif cmd[1] == "forcewarp" and cmd[2] ~= nil and cmd[3] ~= nil then
		serverWarp.OnForcePlayerCommand(pid, cmd[2], tableHelper.concatenateFromIndex(cmd, 3))
	elseif cmd[1] == "jailwarp" and cmd[2] ~= nil and cmd[3] ~= nil then
		serverWarp.OnJailPlayerCommand(pid, cmd[2], tableHelper.concatenateFromIndex(cmd, 3))
	elseif cmd[1] == "allowwarp" and cmd[2] ~= nil and cmd[3] ~= nil then
		serverWarp.OnSetCanWarpCommand(pid, cmd[2], cmd[3]) ]

]]

--[[ USAGE:
Command list:
/warplist
	Prints a list of all public warps and your own private warps into chat
/warp [ warp name ]
	Requires permission: useWarpRank
	Warp yourself to a warp with the provided name. It first checks your personal warp list and if it can't find a warp by that name it then checks the public warp list. You can't use this command if your warp privilege has been disabled.
/setwarp [ warp name ]
	Requires permission: setWarpRank
	Records your current position as a personal warp point with the provided name
/setpublicwarp [ warp name ]
	Requires permission: setPublicWarpRank
	Records your current position as a public warp point with the provided name
/removewarp [ warp name ]
	Requires permission: setWarpRank
	Removes the named warp from your personal warp list
/removepublicwarp [ warp name ]
	Requires permission: removePublicWarpRank
	Removes the named warp from the public warp list
/forcewarp [ target player's id ] [ warp name (of a public warp) ]
	Requires permission: forcePlayerRank
	Forcibly teleports the player with the provided id to a public warp with the given name
/jailwarp [ target player's id ] [ warp name (of a public warp) ]
	Requires permission: forcePlayerRank AND forceJailPlayerRank
	As with /forcewarp, but also disables the player's warp privileges
/allowwarp [ player id ] [ 0/1 to disable/enable ]
	Requires permission: setAllowWarp
	Sets the targeted player's warp privileges. Set to 0 to disable them from using the /warp command, set to 1 to enable them again.
Example usage:
/forcewarp 1 the forum

Every single method in this script can be used via custom scripts. Knock yourself out.
]]

--[[ DEVELOPMENT:
Version 1
For TES3MP v0.6.1
=TODO=
- More features?
=Notes=
Warpdata structure:
	cell
	posX
	posY
	posZ
	rotX
	rotZ
]]


local config = {}
--The minimum rank required to perform any of the actions. 0 is a regular player, 1 is a moderator and 2 is an admin.
config.setWarpRank = 0 --Also used to determine if they can remove their own warps
config.setPublicWarpRank = 1
config.useWarpRank = 0 --Don't differentiate between Public and Private warps for simplicity
config.removePublicWarpRank = 1
config.forcePlayerRank = 1
config.forceJailPlayerRank = 1 --Players also require the permissions to forcePlayer to use this command.
config.setAllowWarp = 1


Methods.OnSetWarpCommand = function(pid, warpName, isPublic)
	local rank = Players[pid].data.settings.admin
	
	--Check player has the correct rank
	if isPublic and (rank < config.setPublicWarpRank) then
		tes3mp.SendMessage(pid, "Your rank is too low to set Public Warps.\n", false)
		return false
	elseif rank < config.setWarpRank then
		tes3mp.SendMessage(pid, "Your rank is too low to set Warps.\n", false)
		return false
	end
	
	local newWarp = {}
	
	newWarp.cell = tes3mp.GetCell(pid) 
	newWarp.posX = tes3mp.GetPosX(pid) 
	newWarp.posY = tes3mp.GetPosY(pid) 
	newWarp.posZ = tes3mp.GetPosZ(pid) 
	newWarp.rotX = tes3mp.GetRotX(pid) 
	newWarp.rotZ = tes3mp.GetRotZ(pid) 
	
	--Note: Will overwrite existing warps of the same name
	if isPublic then
		Methods.AddPublicWarp(warpName, newWarp)
	else
		Methods.AddPrivateWarp(pid, warpName, newWarp)
	end
	
	tes3mp.SendMessage(pid, "Warp added.\n", false)
	return true
end

Methods.OnRemoveWarpCommand = function(pid, warpName, isPublic)
	local rank = Players[pid].data.settings.admin
	--Check player permissions
	if isPublic and (rank < config.removePublicWarpRank) then
		tes3mp.SendMessage(pid, "Your rank is too low to remove Public Warps.\n", false)
		return false
	--Doesn't have a unique config entry - if the player can set private warps, they're allowed to delete them
	elseif rank < config.setWarpRank then
		tes3mp.SendMessage(pid, "Your rank is too low to remove Warps.\n", false)
		return false
	end
	
	--Find the Warp to remove
	local list
	
	if isPublic then
		list = Methods.GetPublicWarps()
	else
		list = Methods.GetPrivateWarps(pid)
	end
	
	--If the Warp exists, remove it, otherwise error
	--(This should probably be in its own function...)
	local warpName = string.lower(warpName)
	if list[warpName] ~= nil then
		list[warpName] = nil
		if isPublic then
			WorldInstance:Save()
			tes3mp.SendMessage(pid, "Removed Public Warp by the name '" .. warpName .. "'.\n", false)
		else
			Players[pid]:Save()
			tes3mp.SendMessage(pid, "Removed Warp by the name '" .. warpName .. "'.\n", false)
		end
		return true
	else
		tes3mp.SendMessage(pid, "Couldn't find a Warp by the name '" .. warpName .. "'.\n", false)
		return false
	end
end

Methods.OnWarpCommand = function(pid, warpName)
	local rank = Players[pid].data.settings.admin
	
	--Check the player can warp
	if Methods.isWarpEnabled(pid) == false then
		tes3mp.SendMessage(pid, "You can't Warp at this time.\n", false)
		return false
	--Check their rank
	elseif rank < config.useWarpRank then
		tes3mp.SendMessage(pid, "Your rank is too low to use Warps.\n", false)
		return false
	end
	
	local foundWarp = Methods.FindWarp(warpName, pid, false) --Prioritises private warps over public ones
	
	if foundWarp then
		Methods.WarpPlayer(pid, foundWarp)
		tes3mp.SendMessage(pid, "You have Warped to " .. warpName ..".\n", false)
		return true
	else
		tes3mp.SendMessage(pid, "Couldn't find a Warp with that name.\n", false)
		return false
	end
end

Methods.OnWarpListCommand = function(pid)
	local pubWarps = Methods.GetPublicWarps()
	local privWarps = Methods.GetPrivateWarps(pid)
	
	--Public warps list
	local message = "Public Warps:\n"
	for k, v in pairs(pubWarps) do
		message = message .. "> " .. k .. "\n"
	end
	--Private warps list
	message = message .. "Your Warps:\n"
	for k, v in pairs(privWarps) do
		message = message .. "> " .. k .. "\n"
	end
	
	tes3mp.SendMessage(pid, message, false)
end

Methods.OnForcePlayerCommand = function (pid, targetId, warpName, cantWarp)
	local rank = Players[pid].data.settings.admin
	
	if rank < config.forcePlayerRank then
		tes3mp.SendMessage(pid, "Your rank is too low to force Warp players.\n", false)
		return false
	end
	
	local foundWarp = Methods.FindWarp(warpName, nil, true)
	
	if foundWarp then
		Methods.WarpPlayer(targetId, foundWarp)
		
		--Only gets cantWarp when called through the OnJailPlayerCommand
		if cantWarp then
			Methods.SetCanWarp(targetId, 0)
		end
		
		tes3mp.SendMessage(pid, "Warped " .. --[[Players[targetId].name]] "player" .. " to " .. warpName .. ".\n", false)
		tes3mp.SendMessage(targetId, "You were warped to " .. warpName .. " by " .. Players[pid].name .. ".\n", false)
		
		return true
	else
		tes3mp.SendMessage(pid, "Couldn't find the Warp.\n", false)
		return false
	end
	
	
end

--Basically uses existing commands to teleport a player to a specific warp and disable their ability to warp.
Methods.OnJailPlayerCommand = function(pid, targetId, warpName)
	local rank = Players[pid].data.settings.admin
	
	if rank < config.forceJailPlayerRank then
		tes3mp.SendMessage(pid, "Your rank is too low to jail players.\n", false)
		return false
	end
	
	return Methods.OnForcePlayerCommand(pid, targetId, warpName, true)
end

Methods.OnSetCanWarpCommand = function(pid, targetId, value)
	--DEBUG
	tes3mp.SendMessage(pid, "targetId: " .. targetId .. " value: " .. value .. "\n", false)
	local rank = Players[pid].data.settings.admin
	
	if rank < config.setAllowWarp then
		tes3mp.SendMessage(pid, "Your rank is too low to change a player's warp privileges.\n", false)
		return false
	end
	
	Methods.SetCanWarp(targetId, value)
end

Methods.SetCanWarp = function(pid, val)
	--Make sure the arguments are valid
	local pid = tonumber(pid)
	local val = tonumber(val)
	--Use 0 to disable, 1 to enable
	Players[pid].data.customVariables.canServerWarp = val
	Players[pid]:Save()
end

Methods.isWarpEnabled = function(pid)
	if tonumber(Players[pid].data.customVariables.canServerWarp) == 0 then
		return false
	else
		return true
	end
end

Methods.GetPublicWarps = function()
	--If there are no public warps, create the table
	if WorldInstance.data.customVariables.serverWarp == nil then
		WorldInstance.data.customVariables.serverWarp = {}
		WorldInstance:Save()
	end
	
	return WorldInstance.data.customVariables.serverWarp
end

Methods.GetPrivateWarps = function(pid)
	--If there are no private warps, create the table
	if Players[pid].data.customVariables.serverWarp == nil then
		Players[pid].data.customVariables.serverWarp = {}
		Players[pid]:Save()
	end
	
	return Players[pid].data.customVariables.serverWarp
end

Methods.AddPublicWarp = function(warpName, data)
	local warps = Methods.GetPublicWarps()
	local warpName = string.lower(warpName)
	
	warps[warpName] = data
	WorldInstance:Save()
end

Methods.AddPrivateWarp = function(pid, warpName, data)
	local warps = Methods.GetPrivateWarps(pid)
	local warpName = string.lower(warpName)
	
	warps[warpName] = data
	Players[pid]:Save()
end

Methods.FindWarp = function(warpName, pid, prioritisePublic)
	local pubWarps = Methods.GetPublicWarps()
	local privWarps
	
	local warpName = string.lower(warpName)
	
	local pubCheck = Methods.SearchWarps(pubWarps, warpName)
	local privCheck
	
	if pid then
		privWarps = Methods.GetPrivateWarps(pid)
		privCheck = Methods.SearchWarps(privWarps, warpName)
	end
	
	if prioritisePublic then
		return pubCheck or privCheck or false
	else
		return privCheck or pubCheck or false
	end
end

Methods.WarpPlayer = function(pid, warpData)
	tes3mp.SetCell(pid, warpData.cell)
	tes3mp.SendCell(pid)
	
	tes3mp.SetPos(pid, warpData.posX, warpData.posY, warpData.posZ)
	tes3mp.SetRot(pid, warpData.rotX, warpData.rotZ)
	tes3mp.SendPos(pid)
end

Methods.SearchWarps = function (warps, warpName)
	warpName = string.lower(warpName) --should never get to here without first being turned into lowercase, but we'll do it here again just in case
	for k,v in pairs(warps) do
		if k == warpName then
			return v
		end
	end
	
	return false
end


return Methods
