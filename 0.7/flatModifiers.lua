-- flatModifiers (Advanced) - Release 3 - For tes3mp v0.7-alpha Requires classInfo.

--[[ INSTALLATION
1) Save this file as "flatModifiers.lua" in server/scripts/custom
2) Add [ flatModifiers = require("custom.flatModifiers") ] to customScripts.lua
]]

--[[ NOTE
The values this script use are for fake level ups towards attributes, rather than the set multiplier to provide the attribute. These level ups translate as the following
	1-4 gives 2x, 5-7 gives 3x, 8-9 gives 4x, 10+ gives 5x
]]

local Methods = {}

classInfo = require("classInfo")

local config = {}

config.mode = "basic" -- "basic" or "class"
--Basic mode sets all attribute increases to a flat value (determined by config.basicAttributeIncreases)
--Class mode has attribute increases tailored to the character's class (see class mode config options section for config options)

--globally used config options
config.includeLuck = false --Whether to include Luck in the calculations. By default, Morrowind doesn't allow bonuses to Luck.

--basic mode config options
config.basicAttributeIncreases = 6 -- Number of skill increases towards the stats that the script should fake. 

--class mode config options
config.classBase = 3 -- How many skill advances every attribute has for its base
config.classMajorSkillBonus = 1.5 -- How many skill advances get added to an attribute per major skill governed by it
config.classMinorSkillBonus = 1 -- How many skill advances get added to an attribute per minor skill governed by it
config.classAttributeBonus = 3 -- How many skill advances get added to an attribute which is one of the class' major attributes

local function basicMode(pid)
	for i = 0, 7 do
		if i ~= 7 or config.includeLuck then --Avoid giving Luck (7) any bonus, unless configured to
			Players[pid].data.attributes[tes3mp.GetAttributeName(i)].skillIncrease = config.basicAttributeIncreases
		end
	end
	Players[pid]:LoadAttributes()
end

local function classMode(pid)
	local pClass = classInfo.GetPlayerClassData(pid)
	
	local changes = {}
	
	--Major attributes
	for k, v in pairs(pClass.majorAttributes) do
		changes[v] = (changes[v] or 0) + config.classAttributeBonus
	end
	
	--Major skills
	for k, v in pairs(pClass.majorSkills) do
		local governed = classInfo.GetGovernedAttribute(v)
		changes[governed] = (changes[governed] or 0) + config.classMajorSkillBonus
	end
	
	--Minor skills
	for k, v in pairs(pClass.minorSkills) do
		local governed = classInfo.GetGovernedAttribute(v)
		changes[governed] = (changes[governed] or 0) + config.classMinorSkillBonus
	end
	
	--Finally make the changes
	for i = 0, 7 do
		if i ~= 7 or config.includeLuck then --Avoid giving Luck (7) any bonus, unless configured to
			local amount = config.classBase + (changes[i] or 0)
			amount = math.min(math.floor(amount), 10)
			Players[pid].data.attributes[tes3mp.GetAttributeName(i)].skillIncrease = amount
		end
	end
	
	Players[pid]:LoadAttributes()
	tes3mp.SendSkills(pid) --Required until 0.7-prerelease bug is fixed
end

local function doTheThing(eventStatus, pid)
	if eventStatus.validCustomHandlers then
		if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
			if config.mode == "basic" then
				basicMode(pid)
			else
				classMode(pid)
			end
		end
	end
end

customEventHooks.registerHandler("OnPlayerLevel", doTheThing)

return Methods
