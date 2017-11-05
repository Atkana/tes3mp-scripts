-- flatModifiersBasic - Release 1 - For tes3mp v0.6.1

--[[ INSTALLATION
1) Save this file as "flatModifiersBasic.lua" in mp-stuff/scripts
2) Add [ flatModifiersBasic = require("flatModifiersBasic") ] to the top of server.lua
3) Add the following to OnPlayerLevel in server.lua
	[ flatModifiersBasic.OnPlayerLevel(pid) ]
4) Add the following to OnPlayerSkill in server.lua
	[ flatModifiersBasic.OnPlayerSkill(pid) ]
]]

Methods = {}

local config = {}
config.attributeIncreases = 6 -- Number of skill increases towards the stats that the script should fake. 1-4 gives 2x, 5-7 gives 3x, 8-9 gives 4x, 10+ gives 5x
config.includeLuck = false --Whether to include Luck in the calculations. By default, Morrowind doesn't allow bonuses to Luck.

local function setIncreases(pid)
	local pIncreases = Players[pid].data.attributeSkillIncreases
	for k, v in pairs(pIncreases) do
		if k ~= "Luck" or config.includeLuck then
			tes3mp.SetSkillIncrease(pid, tes3mp.GetAttributeId(k), config.attributeIncreases)
		end
	end
	tes3mp.SendSkills(pid)
	Players[pid]:SaveSkills()
end

Methods.OnPlayerLevel = function(pid)
	setIncreases(pid)
end

Methods.OnPlayerSkill = function(pid) --Conveniently, this also gets called during the player setup when they join the server
	setIncreases(pid)
end

return Methods
