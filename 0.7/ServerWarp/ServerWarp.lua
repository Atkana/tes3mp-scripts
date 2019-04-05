local ServerWarp = {}

--[[=Notes=
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
config.setWarpRank = 1 --Also used to determine if they can remove their own warps
config.setPublicWarpRank = 2
config.useWarpRank = 0 --Don't differentiate between Public and Private warps for simplicity
config.removePublicWarpRank = 2
config.forcePlayerRank = 1
config.forceJailPlayerRank = 1 --Players also require the permissions to forcePlayer to use this command.
config.setAllowWarp = 1

ServerWarp.OnSetWarpCommand = function(pid, args)
   local command
   local isPublic
   local warpName = nil

   local i = 0
   for _, arg in pairs(args) do
      if i == 0 then command = arg end
      if i == 1 then warpName = arg end
      i = i + 1
   end

   if warpName == nil then
      tes3mp.SendMessage(pid, "Please provide a warp name.\n", false)
      return
   end

   if command == "warpsetpublic" then
      isPublic = true
   else
      isPublic = false
   end

   local rank = Players[pid].data.settings.staffRank

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
      ServerWarp.AddPublicWarp(warpName, newWarp)
   else
      ServerWarp.AddPrivateWarp(pid, warpName, newWarp)
   end

   tes3mp.SendMessage(pid, "Warp added.\n", false)
   return true
end

ServerWarp.OnRemoveWarpCommand = function(pid, args)
   local command
   local isPublic
   local _warpName = nil

   local i = 0
   for _, arg in pairs(args) do
      if i == 0 then command = arg end
      if i == 1 then _warpName = arg end
      i = i + 1
   end

   if _warpName == nil then
      tes3mp.SendMessage(pid, "Please provide the target warp name.\n", false)
      return
   end

   if command == "warpremovepublic" then
      isPublic = true
   else
      isPublic = false
   end

   local rank = Players[pid].data.settings.staffRank
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
      list = ServerWarp.GetPublicWarps()
   else
      list = ServerWarp.GetPrivateWarps(pid)
   end

   --If the Warp exists, remove it, otherwise error
   --(This should probably be in its own function...)
   local warpName = string.lower(_warpName)
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

ServerWarp.OnWarpCommand = function(pid, args)
   local warpName

   local i = 0
   for _, arg in pairs(args) do
      if i == 1 then warpName = arg end
      i = i + 1
   end

   local rank = Players[pid].data.settings.staffRank

   --Check the player can warp
   if ServerWarp.isWarpEnabled(pid) == false then
      tes3mp.SendMessage(pid, "You can't Warp at this time.\n", false)
      return false
      --Check their rank
   elseif rank < config.useWarpRank then
      tes3mp.SendMessage(pid, "Your rank is too low to use Warps.\n", false)
      return false
   end

   local foundWarp = ServerWarp.FindWarp(warpName, pid, false) --Prioritises private warps over public ones

   if foundWarp then
      ServerWarp.WarpPlayer(pid, foundWarp)
      tes3mp.SendMessage(pid, "You have Warped to " .. warpName ..".\n", false)
      return true
   else
      tes3mp.SendMessage(pid, "Couldn't find a Warp with that name.\n", false)
      return false
   end
end

ServerWarp.OnWarpListCommand = function(pid)
   local pubWarps = ServerWarp.GetPublicWarps()
   local privWarps = ServerWarp.GetPrivateWarps(pid)

   --Public warps list
   local message = "Public Warps:\n"
   for k, _ in pairs(pubWarps) do
      message = message .. "> " .. k .. "\n"
   end
   --Private warps list
   message = message .. "Your Warps:\n"
   for k, _ in pairs(privWarps) do
      message = message .. "> " .. k .. "\n"
   end

   tes3mp.SendMessage(pid, message, false)
end

ServerWarp.OnForcePlayerCommand = function (pid, args)
   local targetId = nil
   local warpName = nil
   local cantWarp = nil

   local i = 0
   for _, arg in pairs(args) do
      if i == 1 then targetId = arg end
      if i == 2 then warpName = arg end
      if i == 3 then cantWarp = arg end
      i = i + 1
   end

   if targetId == nil or warpName == nil or cantWarp == nil then
      tes3mp.SendMessage(pid, "Please provide the target id and warp name.\n", false)
      return
   end

   local rank = Players[pid].data.settings.staffRank

   if rank < config.forcePlayerRank then
      tes3mp.SendMessage(pid, "Your rank is too low to force Warp players.\n", false)
      return false
   end

   local foundWarp = ServerWarp.FindWarp(warpName, nil, true)

   if foundWarp then
      ServerWarp.WarpPlayer(targetId, foundWarp)

      --Only gets cantWarp when called through the OnJailPlayerCommand
      if cantWarp then
         ServerWarp.SetCanWarp(targetId, 0)
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
ServerWarp.OnJailPlayerCommand = function(pid, args)
   local targetId = nil
   local warpName = nil

   local i = 0
   for _, arg in pairs(args) do
      if i == 1 then targetId = arg end
      if i == 2 then warpName = arg end
      i = i + 1
   end

   if targetId == nil or warpName == nil then
      tes3mp.SendMessage(pid, "Please provide the target id and warp name.\n", false)
      return
   end

   local rank = Players[pid].data.settings.staffRank

   if rank < config.forceJailPlayerRank then
      tes3mp.SendMessage(pid, "Your rank is too low to jail players.\n", false)
      return false
   end

   return ServerWarp.OnForcePlayerCommand(pid, targetId, warpName, true)
end

ServerWarp.OnSetCanWarpCommand = function(pid, args)
    local targetId = nil
    local value = nil

    local i = 0
    for _, arg in pairs(args) do
       if i == 1 then targetId = arg end
       if i == 2 then value = arg end
       i = i + 1
    end

   if targetId == nil or value == nil then
      tes3mp.SendMessage(pid, "Please specify the warp name to set.\n", false)
      return false
   end

   --DEBUG
   tes3mp.SendMessage(pid, "targetId: " .. targetId .. " value: " .. value .. "\n", false)
   local rank = Players[pid].data.settings.staffRank

   if rank < config.setAllowWarp then
      tes3mp.SendMessage(pid, "Your rank is too low to change a player's warp privileges.\n", false)
      return false
   end

   ServerWarp.SetCanWarp(targetId, value)
end

ServerWarp.SetCanWarp = function(_pid, _val)
   --Make sure the arguments are valid
   local pid = tonumber(_pid)
   local val = tonumber(_val)
   --Use 0 to disable, 1 to enable
   Players[pid].data.customVariables.canServerWarp = val
   Players[pid]:Save()
end

ServerWarp.isWarpEnabled = function(pid)
   if tonumber(Players[pid].data.customVariables.canServerWarp) == 0 then
      return false
   else
      return true
   end
end

ServerWarp.GetPublicWarps = function()
   --If there are no public warps, create the table
   if WorldInstance.data.customVariables.serverWarp == nil then
      WorldInstance.data.customVariables.serverWarp = {}
      WorldInstance:Save()
   end

   return WorldInstance.data.customVariables.serverWarp
end

ServerWarp.GetPrivateWarps = function(pid)
   --If there are no private warps, create the table
   if Players[pid].data.customVariables.serverWarp == nil then
      Players[pid].data.customVariables.serverWarp = {}
      Players[pid]:Save()
   end

   return Players[pid].data.customVariables.serverWarp
end

ServerWarp.AddPublicWarp = function(warpName, data)
   local warps = ServerWarp.GetPublicWarps()
   warps[string.lower(warpName)] = data
   WorldInstance:Save()
end

ServerWarp.AddPrivateWarp = function(pid, warpName, data)
   if not warpName then
      return false
   end
   local warps = ServerWarp.GetPrivateWarps(pid)
   warps[string.lower(warpName)] = data
   Players[pid]:Save()
end

ServerWarp.FindWarp = function(_warpName, pid, prioritisePublic)
   local pubWarps = ServerWarp.GetPublicWarps()
   local privWarps

   if not _warpName then
      return false
   end

   local warpName = string.lower(_warpName)

   if not warpName then
      return
   end

   local pubCheck = ServerWarp.SearchWarps(pubWarps, warpName)
   local privCheck

   if pid then
      privWarps = ServerWarp.GetPrivateWarps(pid)
      privCheck = ServerWarp.SearchWarps(privWarps, warpName)
   end

   if prioritisePublic then
      return pubCheck or privCheck or false
   else
      return privCheck or pubCheck or false
   end
end

ServerWarp.WarpPlayer = function(pid, warpData)
   tes3mp.SetCell(pid, warpData.cell)
   tes3mp.SendCell(pid)

   tes3mp.SetPos(pid, warpData.posX, warpData.posY, warpData.posZ)
   tes3mp.SetRot(pid, warpData.rotX, warpData.rotZ)
   tes3mp.SendPos(pid)
end

ServerWarp.SearchWarps = function (warps, warpName)
   --should never get to here without first being turned into lowercase, but we'll do it here again just in case
   warpName = string.lower(warpName)
   for k,v in pairs(warps) do
      if k == warpName then
         return v
      end
   end

   return false
end

customCommandHooks.registerCommand("warp", ServerWarp.OnWarpCommand)
customCommandHooks.registerCommand("warpallow", ServerWarp.OnSetCanWarpCommand)
customCommandHooks.registerCommand("warpforce", ServerWarp.OnForcePlayerCommand)
customCommandHooks.registerCommand("warpjail", ServerWarp.OnJailPlayerCommand)
customCommandHooks.registerCommand("warplist", ServerWarp.OnWarpListCommand)
customCommandHooks.registerCommand("warpset", ServerWarp.OnSetWarpCommand)
customCommandHooks.registerCommand("warpsetpublic", ServerWarp.OnSetWarpCommand)
customCommandHooks.registerCommand("warpremove", ServerWarp.OnRemoveWarpCommand)
customCommandHooks.registerCommand("warpremovepublic", ServerWarp.OnRemoveWarpCommand)
