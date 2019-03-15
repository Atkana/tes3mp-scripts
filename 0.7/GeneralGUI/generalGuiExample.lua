-- An example for GeneralGUI
-- Once installed, use /guitest in chat to open the sequence

--[[ INSTALLATION
= GENERAL =
a) Save this file as "generalGuiExample.lua" in mp-stuff/scripts

= IN SERVERCORE.LUA =
a) Find the line [ menuHelper = require("menuHelper") ]. Add the following BENEATH it:
	[ generalGuiExample = require("generalGuiExample") ]
	
= IN COMMANDHANDLER.LUA =
a) Find the section:
	[ else
		local message = "Not a valid command. Type /help for more info.\n" ]
	Add the following ABOVE it:
	[ elseif cmd[1] == "guitest" then generalGuiExample.OnCommand(pid) ]
]]
local Methods = {}

GeneralGUI = require("GeneralGUI")

--=============
-- ExampleStart GUI
--=============
--[[
For this GUI, we'll be creating a prompt for players to enter a number.
We'll record that number to use in the next GUI, which we'll display after something is entered into this one
Because we want a number, we won't allow the player to progress until they enter one
Because this number will be super secret, we'll have the GUI hide what they're entering, like is done when somebody is entering a password
]]

-- This is what we're using as out validator.
-- Since we only want numbers, we'll return false if the player doesn't provide one
local function firstExampleValidateInput(chainData, input)
	if not tonumber(input) then
		return false, "Please input a number"
	else
		return true
	end
end

-- This is what we'll use as our OnInput.
-- It'll be run after the player inputs something which passes the validator's tests.
local function firstExampleOnInput(chainData, input)
	-- Let's store the number that the player inputted into the chain data, so we can use it later
	chainData.inputtedNumber = tonumber(input)
	-- And let's show the next GUI in the sequence.
	-- (So far we haven't created it in the code - we'll get to it later)
	return GeneralGUI.ShowGUI(chainData.pid, "examplesecond")
end

-- This is what we'll use to generate our label
local function firstExampleGenerateLabel(chainData)
	-- Spoilers: Because we are able to revisit this GUI later on in the sequence,
	-- It's possible that we have an inputtedNumber in the chain data!
	-- (Normally it's *this* GUI which adds that into the chain data)
	-- So in the case that we have returned here, we add a special message
	if chainData.inputtedNumber then
		return "Last time you were here you put " .. chainData.inputtedNumber
	else
		return "" -- Otherwise we just give a blank string to use as our label
	end
end

-- Here's what a structured GUI Data looks like
local firstGUIData = {
	type = "InputDialog", --The type is InputDialog so that the GUI is an InputDialog...
	isPassword = true, --This special flag will mean we use a password dialog
	GenerateLabel = firstExampleGenerateLabel,
	note = "Enter a secret number", --Because we haven't provided a GenerateNote, this string will be used for the GUI's note
	ValidateInput = firstExampleValidateInput,
	OnInput = firstExampleOnInput
}

-- Now, we simply register the GUI
GeneralGUI.RegisterGUI("examplestart", firstGUIData)

--==============
-- ExampleSecond GUI
--==============
--[[
For this GUI, we'll be creating a series of button options for the player to choose.
The player will have buttons to:
- Go back to the first GUI and enter a new number
- Open the next GUI (a list of choices)
- Close the GUI, ending the sequence
Additionally, we'll display an extra special button if the player entered 1337 as their number previously
Because we want to mess around a bit, we'll make the text in the box change based on what the player has been doing, exploiting our knowledge that they can go back to the first GUI
]]

-- This is what we'll use to generate our label
local function secondExampleGenerateLabel(chainData)
	-- The message that we'll use will change depending on whether we've been
	-- here before in our current sequence, making reference to our changes
	local message = ""
	if not chainData.sawNumber then
		message = "You entered the number " .. chainData.inputtedNumber
	elseif chainData.inputtedNumber ~= chainData.sawNumber then
		message = "Hey, you went back and changed your number from " .. chainData.sawNumber .. " to " .. chainData.inputtedNumber .. "!"
	elseif chainData.inputtedNumber == chainData.sawNumber then
		message = "Look, don't waste my time by going back and entering the same number again..."
	end
	
	-- Here, we store that last input number that we displayed here to use later
	-- on for this very function if this is used later... Weird how time works.
	chainData.sawNumber = chainData.inputtedNumber
	return message
end

-- This is what'll be run if a player selects the "Go Back" button
local function secondGoBack(chainData)
	return GeneralGUI.ShowGUI(chainData.pid, "examplestart")
end

-- This is what'll be run if a player selects the "Choose a Thing"
local function secondSeeList(chainData)
	return GeneralGUI.ShowGUI(chainData.pid, "examplethird")
end

-- We'll use this as our OnSelectOption
-- Note that because we'll be providing callbacks for every choice bar one, this'll only
-- be called when a player selects the secret elite button (the only one without a callback)
local function secondExampleOnSelectOption(chainData, choiceData)
	-- Despite this only being called for the secret elite button, we'll do a check anyways...
	if choiceData.id == "elite" then
		tes3mp.MessageBox(chainData.pid, -1, "You are super elite!")
		GeneralGUI.EndChain(chainData.pid)
	end
end

-- We'll usre this as our GenerateChoices
local function secondExampleGenerateChoices(chainData)
	local optionOrder = {"back", "elite", "choice", "close"} -- We'll use this to determine the order the options appear in.
	local optionData = {
		back = {display = "Go back", id = "back", callback = secondGoBack},
		elite = {display = "Secret Elite button", id = "elite"},
		close = {display = "Close", id = "close", callback = GeneralGUI.CloseButton},
		choice = {display = "Choose a thing", id = "choose", callback = secondSeeList}
	}
	
	local currentIndex = 1
	
	local out = {} --This table will ultimately be our choice list
	
	-- In this example, we'll be going through each possible choice that could be presented
	-- and determining which ones to present to the player.
	for _, id in ipairs(optionOrder) do
		-- The default assumption in this instance is that we add each button
		
		-- Here we do a check to determine if we add the "elite" button
		-- It should only appear to a player if they entered "1337" as their number
		-- If they didn't then we skip adding the "elite" button
		if id == "elite" and chainData.inputtedNumber ~= 1337 then
			-- don't add secret elite button
		else
			out[currentIndex] = {display = optionData[id].display, id = optionData[id].id, callback = optionData[id].callback or nil, index = currentIndex}
			currentIndex = currentIndex + 1
		end
	end
	
	return out
end

-- Heres the data for this GUI
local secondGUIData = {
	type = "CustomMessageBox",
	GenerateLabel = secondExampleGenerateLabel,
	GenerateChoices = secondExampleGenerateChoices,
	OnSelectOption = secondExampleOnSelectOption,
}

-- Register it!
GeneralGUI.RegisterGUI("examplesecond", secondGUIData)

--=============
-- ExampleThird GUI
--=============
--[[
For this GUI, we'll be prompt players to pick the best thing from a list.
Because we want to force the players to pick an option, we'll use the correct flag, and create a message telling them off for whimping out and trying to avoid expressing an opinion!
The list of choices will always be the same, so we don't have to do anything fancy to generate them.
We'll use one callback for when players make the right choice, and then use the default fallback of OnSelectOption for all the wrong choices.
]]

-- Here's what'll happen if the player picks "Skooma" from this GUI's choices
local function thirdChooseSkooma(chainData)
	tes3mp.MessageBox(chainData.pid, -1, "The correct choice!")
	tes3mp.PlaySpeech(chainData.pid, "vo\\k\\m\\Idl_KM001.mp3")
	GeneralGUI.EndChain(chainData.pid)
end

-- Unlike in the second GUI, the sample of choices won't change
-- so we can just define a choice list here
local thirdChoices = {
	{index = 1, display = "Skooma", id = "skooma", callback = thirdChooseSkooma},
	{index = 2, display = "Fargoth", id = "fargoth"},
	{index = 3, display = "Cliff Racers", id = "racers"},
}
-- We'll use this as our GenerateChoices. All it does is return the above table
local function thirdGenerateChoices()
	return thirdChoices
end

-- We'll use this as our OnSelectOption.
-- It only gets executed if the "wrong choices" are picked, because skooma has its own callback
local function thirdOnSelect(chainData, choiceData)
	tes3mp.MessageBox(chainData.pid, -1, "BOO! " .. choiceData.display .. " is the wrong choice!")
	
	GeneralGUI.EndChain(chainData.pid)
end

-- Here's the data for this GUI
local thirdGUIData = {
	type = "ListBox",
	label = "Pick the thing which is best.", --Because there's no GenerateLabel, this'll be used for the label instead.
	GenerateChoices = thirdGenerateChoices,
	OnSelectOption = thirdOnSelect,
	requireSelection = true, --Because we want to force the player to pick from the list, we use this
	requireSelectionRejectMessage = "Pick something, fool!", --This is a special message that the player will be shown if they don't make a choice
}

-- Register it!
GeneralGUI.RegisterGUI("examplethird", thirdGUIData)


Methods.OnCommand = function(pid)
	GeneralGUI.StartChain(pid)
	GeneralGUI.ShowGUI(pid, "examplestart")
end

return Methods
