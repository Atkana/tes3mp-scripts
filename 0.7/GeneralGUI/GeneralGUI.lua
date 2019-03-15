-- GeneralGUI - Release 1 - For tes3mp 0.7-prerelease
-- Very Basic GUI API for structuring custom GUIs
-- Note that this hasn't been fully tested, and is subject to change

local GeneralGUI = {}

GeneralGUI.registered = {}
GeneralGUI.GUIids = {["CustomMessageBox"] = 2500, ["InputDialog"] = 2501, ["ListBox"] = 2502}
GeneralGUI.currentChainData = {}

GeneralGUI.OnGUIAction = function(pid, idGui, data)
	for guiType, id in pairs(GeneralGUI.GUIids) do
		if idGui == id then
			local chainData = GeneralGUI.GetChainData(pid)
			local guiInfo = GeneralGUI.registered[chainData.currentGeneralGuiId]
			
			if guiType == "CustomMessageBox" then
				local chosenIndex = tonumber(data) + 1
				
				local selectedChoiceData = chainData.currentChoiceList[chosenIndex]
				
				if selectedChoiceData.callback ~= nil then
					selectedChoiceData.callback(chainData, selectedChoiceData)
				else
					if guiInfo.OnSelectOption ~= nil then
						guiInfo.OnSelectOption(chainData, selectedChoiceData)
					else
						GeneralGUI.Error("OnSelectOption missing for " .. chainData.currentGeneralGuiId)
					end
				end
				
				return true
			elseif guiType == "InputDialog" then
				local input = tostring(data) or ""
				
				-- Perform validation check if available
				if guiInfo.ValidateInput ~= nil then
					local success, message = guiInfo.ValidateInput(chainData, input)
					if not success then
						local rejectMessage = message or "Please enter valid text."
						
						tes3mp.MessageBox(pid, -1, rejectMessage)
						return true, GeneralGUI.ReshowLast(chainData)
					end
				end
				
				if guiInfo.OnInput ~= nil then
					guiInfo.OnInput(chainData, input)
				else
					GeneralGUI.Error("OnInput missing for " .. chainData.currentGeneralGuiId)
				end
				
				return true
			elseif guiType == "ListBox" then
				local rawChoice = tonumber(data)
				
				-- Enforce required selection if GUI required
				if guiInfo.requireSelection ~= nil and guiInfo.requireSelection and rawChoice == 18446744073709551615 then
					local rejectMessage = guiInfo.requireSelectionRejectMessage or "Please make a valid selection."
					
					tes3mp.MessageBox(pid, -1, rejectMessage)
					return true, GeneralGUI.ReshowLast(chainData)
				end
				
				local chosenIndex = rawChoice + 1
				local selectedChoiceData = chainData.currentChoiceList[chosenIndex]
				
				if selectedChoiceData.callback ~= nil then
					selectedChoiceData.callback(chainData, selectedChoiceData)
				else
					if guiInfo.OnSelectOption ~= nil then
						guiInfo.OnSelectOption(chainData, selectedChoiceData)
					else
						GeneralGUI.Error("OnSelectOption missing for " .. chainData.currentGeneralGuiId)
					end
				end
				
				return true
			end
		end
	end
end

GeneralGUI.RegisterGUI = function(id, data)
	GeneralGUI.registered[string.lower(id)] = data
end

GeneralGUI.Error = function(message)
	tes3mp.LogMessage(1, "[GeneralGUI] ERROR: " .. message)
end

-- Start a new chain. Should be called before ShowGUI when starting a new sequence of GUIs (even if there's only one)
GeneralGUI.StartChain = function(pid)
	-- Use pid or name?
	GeneralGUI.currentChainData[pid] = {["pid"] = pid}
end

GeneralGUI.GetChainData = function(pid)
	return GeneralGUI.currentChainData[pid] --Or create if missing?
end

-- Empty chain data
GeneralGUI.EndChain = function(pid)
	GeneralGUI.currentChainData[pid] = nil
end

-- Generic function that you can use as the callback for your close buttons.
GeneralGUI.CloseButton = function(chainData)
	GeneralGUI.EndChain(chainData.pid)
end

-- Re-show the current GUI (technically, the last one that was open)
GeneralGUI.ReshowLast = function(chainData)
	GeneralGUI.ShowGUI(chainData.pid, chainData.currentGeneralGuiId)
end

GeneralGUI.ShowGUI = function(pid, id)
	local id = string.lower(id)
	if not GeneralGUI.registered[id] then
		-- Not found. Abort
		GeneralGUI.Error("Attempted to show non-registered GUI " .. id)
		return false
	end
	local guiInfo = GeneralGUI.registered[id]
	local chainData = GeneralGUI.GetChainData(pid)
	
	-- Abort if chain data is missing
	if chainData == nil then
		GeneralGUI.Error("Attempted to load " .. id .. " without chain data!")
		return false
	end
	
	chainData.currentGeneralGuiId = id
	
	if guiInfo.type == "CustomMessageBox" then -- Custom Message Box
		-- Label
		local label
		if guiInfo.GenerateLabel ~= nil then
			label = guiInfo.GenerateLabel(chainData)
		elseif guiInfo.label ~= nil then
			label = guiInfo.label
		else
			label = ""
		end
		
		-- Buttons
		local buttonDataList
		if guiInfo.GenerateChoices ~= nil then
			buttonDataList = guiInfo.GenerateChoices(chainData)
		else -- Create default if GUI info is lacking Generate function
			buttonDataList = {{index = 1, display = "Close", id = "close", callback = GeneralGUI.CloseButton}}
		end
		
		local buttonString = ""
		for index = 1, #buttonDataList do
			buttonString = buttonString .. buttonDataList[index].display
			if buttonDataList[index+1] ~= nil then
				buttonString = buttonString .. ";"
			end
		end
		
		chainData.currentChoiceList = buttonDataList
		
		-- Display GUI
		return tes3mp.CustomMessageBox(pid, GeneralGUI.GUIids.CustomMessageBox, label, buttonString)
	elseif guiInfo.type == "ListBox" then -- List Box
		-- Label
		local label
		if guiInfo.GenerateLabel ~= nil then
			label = guiInfo.GenerateLabel(chainData)
		elseif guiInfo.label ~= nil then
			label = guiInfo.label
		else
			label = ""
		end
		
		-- Choices
		local choiceDataList
		if guiInfo.GenerateChoices ~= nil then
			choiceDataList = guiInfo.GenerateChoices(chainData)
		else -- Create default if GUI info is lacking Generate function
			choiceDataList = {{index = 1, display = "*Close*", id = "close", callback = GeneralGUI.CloseButton}}
		end
		
		local choiceString = ""
		for index = 1, #choiceDataList do
			choiceString = choiceString .. choiceDataList[index].display
			if choiceDataList[index+1] ~= nil then
				choiceString = choiceString .. "\n"
			end
		end
		
		chainData.currentChoiceList = choiceDataList
		
		-- Display GUI
		return tes3mp.ListBox(pid, GeneralGUI.GUIids.ListBox, label, choiceString)
	elseif guiInfo.type == "InputDialog" then -- Input Dialog
		-- Label
		local label
		if guiInfo.GenerateLabel ~= nil then
			label = guiInfo.GenerateLabel(chainData)
		elseif guiInfo.label ~= nil then
			label = guiInfo.label
		else
			label = ""
		end
		
		-- Note
		local note
		if guiInfo.GenerateNote ~= nil then
			note = guiInfo.GenerateNote(chainData)
		elseif guiInfo.note ~= nil then
			note = guiInfo.note
		else
			note = ""
		end
		
		-- Display GUI
		if guiInfo.isPassword then
			return tes3mp.PasswordDialog(pid, GeneralGUI.GUIids.InputDialog, label, note)
		else
			return tes3mp.InputDialog(pid, GeneralGUI.GUIids.InputDialog, label, note)
		end
	end
end

-------------
return GeneralGUI
