-- decorateHelp - Release 4 - For tes3mp v0.7.0-alpha
-- Alter positions of items using a GUI

--[[ INSTALLATION:
1) Save this file as "decorateHelp.lua" in server/scripts/custom
2) Add [ decorateHelp = require("custom.decorateHelp") ] to customScripts.lua
]]

------
local config = {}

config.MainId = 31360
config.PromptId = 31361
config.ScaleMin = 0.5
config.ScaleMax = 2.0
------

Methods = {}

tableHelper = require("tableHelper")

--
local playerSelectedObject = {}
local playerCurrentMode = {}

--Returns the object's data from a loaded cell. Doesn't need to load the cell because this assumes it'll always be called in a cell that's loaded.
local function getObject(refIndex, cell)
	if refIndex == nil then
		return false
	end

	if LoadedCells[cell]:ContainsObject(refIndex) then
		return LoadedCells[cell].data.objectData[refIndex]
	else
		return false
	end	
end

local function resendPlaceToAll(refIndex, cell)
	local object = getObject(refIndex, cell)
	
	if not object then
		return false
	end
	
	local refId = object.refId
	local count = object.count or 1
	local charge = object.charge or -1
	local posX, posY, posZ = object.location.posX, object.location.posY, object.location.posZ
	local rotX, rotY, rotZ = object.location.rotX, object.location.rotY, object.location.rotZ
	local refIndex = refIndex
	local scale = object.scale or 1
	
	local inventory = object.inventory or nil
	
	local splitIndex = refIndex:split("-")
	
	for pid, pdata in pairs(Players) do
		if Players[pid]:IsLoggedIn() then
			--First, delete the original
			tes3mp.InitializeEvent(pid)
			tes3mp.SetEventCell(cell)
			tes3mp.SetObjectRefNumIndex(0)
			tes3mp.SetObjectMpNum(splitIndex[2])
			tes3mp.AddWorldObject() --?
			tes3mp.SendObjectDelete()
			
			--Now remake it
			tes3mp.InitializeEvent(pid)
			tes3mp.SetEventCell(cell)
			tes3mp.SetObjectRefId(refId)
			tes3mp.SetObjectCount(count)
			tes3mp.SetObjectCharge(charge)
			tes3mp.SetObjectPosition(posX, posY, posZ)
			tes3mp.SetObjectRotation(rotX, rotY, rotZ)
			tes3mp.SetObjectRefNumIndex(0)
			tes3mp.SetObjectMpNum(splitIndex[2])
			tes3mp.SetObjectScale(scale)
			if inventory then
				for itemIndex, item in pairs(inventory) do
					tes3mp.SetContainerItemRefId(item.refId)
					tes3mp.SetContainerItemCount(item.count)
					tes3mp.SetContainerItemCharge(item.charge)

					tes3mp.AddContainerItem()
				end
			end
			
			tes3mp.AddWorldObject()
			tes3mp.SendObjectPlace()
			tes3mp.SendObjectScale()
			if inventory then
				tes3mp.SendContainer()
			end
		end
	end
	
	-- Make sure to save a scale packet if this object has a non-default scale.
	if scale ~= 1 then
		tableHelper.insertValueIfMissing(LoadedCells[cell].data.packets.scale, refIndex)
	end
	LoadedCells[cell]:QuicksaveToDrive() --Not needed, but it's nice to do anyways
end


local function showPromptGUI(pid)
	local message = "[" .. playerCurrentMode[tes3mp.GetName(pid)] .. "] - Enter a number."
	local pname = tes3mp.GetName(pid)
	local cell = tes3mp.GetCell(pid)
	
	if playerCurrentMode[pname] == "Fine Tune Scale" then
		local object = getObject(playerSelectedObject[pname], cell)
		local scale = object.scale or 1
		tes3mp.InputDialog(pid, config.PromptId, message, "Current scale: " .. scale .. "\nMinimum value: " .. config.ScaleMin .. "\nMaximum value: " .. config.ScaleMax)
	else
		tes3mp.InputDialog(pid, config.PromptId, message, "Enter a number to add/subtract.\nPositives increase.\nNegatives decrease.")
	end
end

local function onEnterPrompt(pid, data)
	local cell = tes3mp.GetCell(pid)
	local pname = tes3mp.GetName(pid)
	local mode = playerCurrentMode[pname]
	local data = tonumber(data) or 0
	
	local object = getObject(playerSelectedObject[pname], cell)
	
	if not object then
		--The object no longer exists, so we should bail out now
		return false
	end
	
	local scale = object.scale or 1
	
	if mode == "Rotate X" then
		local curDegrees = math.deg(object.location.rotX)
		local newDegrees = (curDegrees + data) % 360
		object.location.rotX = math.rad(newDegrees)
	elseif mode == "Rotate Y" then
		local curDegrees = math.deg(object.location.rotY)
		local newDegrees = (curDegrees + data) % 360
		object.location.rotY = math.rad(newDegrees)
	elseif mode == "Rotate Z" then
		local curDegrees = math.deg(object.location.rotZ)
		local newDegrees = (curDegrees + data) % 360
		object.location.rotZ = math.rad(newDegrees)
	elseif mode == "Fine Tune North" then
		object.location.posY = object.location.posY + data
	elseif mode == "Fine Tune East" then
		object.location.posX = object.location.posX + data
	elseif mode == "Fine Tune Height" then
		object.location.posZ = object.location.posZ + data
	elseif mode == "Raise" then
		object.location.posZ = object.location.posZ + 10
	elseif mode == "Lower" then
		object.location.posZ = object.location.posZ - 10
	elseif mode == "Move East" then
		object.location.posX = object.location.posX + 10
	elseif mode == "Move West" then
		object.location.posX = object.location.posX - 10
	elseif mode == "Move North" then
		object.location.posY = object.location.posY + 10
	elseif mode == "Move South" then
		object.location.posY = object.location.posY - 10
	elseif mode == "Scale Up" then
		if scale + 0.1 <= config.ScaleMax then 
			object.scale = scale + 0.1
		end
	elseif mode == "Scale Down" then
		if scale - 0.1 >= config.ScaleMin then
			object.scale = scale - 0.1
		end
	elseif mode == "Fine Tune Scale" then
		if data <= config.ScaleMax and data >= config.ScaleMin then
			object.scale = data
		end
	elseif mode == "return" then
		object.location.posY = object.location.posY		
		return
	end
	
	resendPlaceToAll(playerSelectedObject[pname], cell)
end

local function showMainGUI(pid)
	--Determine if the player has an item
	local currentItem = "None" --default
	local selected = playerSelectedObject[tes3mp.GetName(pid)]
	local object = getObject(selected, tes3mp.GetCell(pid))
	
	if selected and object then --If they have an entry and it isn't gone
		currentItem = object.refId .. " (" .. selected .. ")"
	end
	
	local message = "Select an option. Your current item is: " .. currentItem
	tes3mp.CustomMessageBox(pid, config.MainId, message, "Select Furniture;Fine Tune North;Fine Tune East;Fine Tune Height;Rotate X;Rotate Y;Rotate Z;Raise;Lower;Move East;Move West;Move North;Move South;Scale Up;Scale Down;Fine Tune Scale;Exit")
end

local function setSelectedObject(pid, refIndex)
	playerSelectedObject[tes3mp.GetName(pid)] = refIndex
end

Methods.SetSelectedObject = function(pid, refIndex)
	setSelectedObject(pid, refIndex)
end

Methods.OnObjectPlace = function(pid, cellDescription)
	--Get the last event, which should hopefully be the place packet
	tes3mp.ReadLastEvent()
	
	--Get the refIndex of the first item in the object place packet (in theory, there should only by one)
	local refIndex = tes3mp.GetObjectRefNumIndex(0) .. "-" .. tes3mp.GetObjectMpNum(0)
	
	--Record that item as the last one the player interacted with in this cell
	setSelectedObject(pid, refIndex)
end

Methods.OnGUIAction = function(pid, idGui, data)
	local pname = tes3mp.GetName(pid)
	
	if idGui == config.MainId then
		if tonumber(data) == 0 then --View Furniture Emporium
			playerCurrentMode[pname] = "Select Furniture"
			kanaFurniture.OnCommand(pid)
			return true
		elseif tonumber(data) == 1 then --Move North
			playerCurrentMode[pname] = "Fine Tune North"
			showPromptGUI(pid)
			return true
		elseif tonumber(data) == 2 then --Move East
			playerCurrentMode[pname] = "Fine Tune East"
			showPromptGUI(pid)
			return true
		elseif tonumber(data) == 3 then --Move Up
			playerCurrentMode[pname] = "Fine Tune Height"
			showPromptGUI(pid)
			return true
		elseif tonumber(data) == 4 then --Rotate X
			playerCurrentMode[pname] = "Rotate X"
			showPromptGUI(pid)
			return true
		elseif tonumber(data) == 5 then --Rotate Y
			playerCurrentMode[pname] = "Rotate Y"
			showPromptGUI(pid)
			return true
		elseif tonumber(data) == 6 then --Rotate Z
			playerCurrentMode[pname] = "Rotate Z"
			showPromptGUI(pid)
			return true
		elseif tonumber(data) == 7 then --,Ascend
			playerCurrentMode[pname] = "Raise"
			onEnterPrompt(pid, 0)			
			return true, showMainGUI(pid)
		elseif tonumber(data) == 8 then --Descend
			playerCurrentMode[pname] = "Lower"
			onEnterPrompt(pid, 0)			
			return true, showMainGUI(pid)
		elseif tonumber(data) == 9 then --East
			playerCurrentMode[pname] = "Move East"
			onEnterPrompt(pid, 0)			
			return true, showMainGUI(pid)	
		elseif tonumber(data) == 10 then --West
			playerCurrentMode[pname] = "Move West"
			onEnterPrompt(pid, 0)			
			return true, showMainGUI(pid)
		elseif tonumber(data) == 11 then --North
			playerCurrentMode[pname] = "Move North"
			onEnterPrompt(pid, 0)			
			return true, showMainGUI(pid)
		elseif tonumber(data) == 12 then --South
			playerCurrentMode[pname] = "Move South"
			onEnterPrompt(pid, 0)
			return true, showMainGUI(pid)
		elseif tonumber(data) == 13 then -- Scale up by 0.1
			playerCurrentMode[pname] = "Scale Up"
			onEnterPrompt(pid, 0)
			return true, showMainGUI(pid)
		elseif tonumber(data) == 14 then -- Scale down by 0.1
			playerCurrentMode[pname] = "Scale Down"
			onEnterPrompt(pid, 0)
			return true, showMainGUI(pid)
		elseif tonumber(data) == 15 then -- Scale
			playerCurrentMode[pname] = "Fine Tune Scale"
			showPromptGUI(pid)
			return true
		elseif tonumber(data) == 16 then --Close
			--Do nothing
			return true
		end
	elseif idGui == config.PromptId then
		if data ~= nil and data ~= "" and tonumber(data) then
			onEnterPrompt(pid, data)
		end
		
		playerCurrentMode[tes3mp.GetName(pid)] = nil
		return true, showMainGUI(pid)
	end
end

Methods.OnPlayerCellChange = function(pid)
	playerSelectedObject[tes3mp.GetName(pid)] = nil
end

Methods.OnCommand = function(pid)
	showMainGUI(pid)
end

customCommandHooks.registerCommand("decorator", function(pid, cmd) decorateHelp.OnCommand(pid) end)
customCommandHooks.registerCommand("decorate", function(pid, cmd) decorateHelp.OnCommand(pid) end)
customCommandHooks.registerCommand("dh", function(pid, cmd) decorateHelp.OnCommand(pid) end)

customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	decorateHelp.OnGUIAction(pid, idGui, data)
end)

customEventHooks.registerHandler("OnObjectPlace", function(eventStatus, pid, cellDescription, objects)
	decorateHelp.OnObjectPlace(pid, cellDescription)
end)

customEventHooks.registerHandler("OnPlayerCellChange", function(eventStatus, pid, previousCellDescription, currentCellDescription)
	decorateHelp.OnPlayerCellChange(pid)
end)

return Methods
