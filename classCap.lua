-- classCap - Release 1 - For tes3mp v0.6.1. Requires classInfo
-- Caps Major, Minor, and Misc skills to certain amounts based on class. 
-- Not fully tested

--[[ INSTALLATION
1) Save this file as "classCap.lua" in mp-stuff/scripts
2) Add [ classCap = require("classCap") ] to the top of server.lua
3) Add the following to OnPlayerSkill in server.lua
	[ classCap.OnPlayerSkill(pid) ]
]]

local Methods = {}

classInfo = require("classInfo")

local config = {}

--Skill levels to cap the skills at per category
config.MajorCap = 100
config.MinorCap = 75
config.MiscCap = 50

config.disableLevelProgress = true -- Whether to remove the levelup progress that comes from levelling a major or minor skill. 
config.disableAttributeGain = true -- Whether to remove the attribute bonus that would come from increasing the skill.
-- Note: Since the script will always assume that skills were naturally levelled rather than being set by a script, it'll always detract the difference from the player's level progress/attribute gains.


--Go through class' major and minor skills. If the skill id doesn't appear, that means it's a misc skill
local function isMisc(skillId, majors, minors)
	--Check major skills
	for index, skill in pairs(majors) do
		if skill == skillId then
			return false
		end
	end
	
	--Check minor skills
	for index, skill in pairs(minors) do
		if skill == skillId then
			return false
		end
	end
	
	--It wasn't a major or a minor skill, therefore it's a misc skill
	return true	
end

local function doTheThing(pid)
	local pClass = classInfo.GetPlayerClassData(pid)
	
	local changes = {}
	
	for index, skill in pairs(pClass.majorSkills) do
		local slevel = tes3mp.GetSkillBase(pid, skill)
		if slevel > config.MajorCap then
			tes3mp.SetSkillBase(pid, skill, config.MajorCap)
			table.insert(changes, tes3mp.GetSkillName(skill))
			
			if config.disableLevelProgress then
				local penalty = slevel - config.MajorCap
				tes3mp.SetLevelProgress(pid, math.max((tes3mp.GetLevelProgress(pid) - penalty), 0)) --Set the player's level progress to their current minus the penalty, or 0 if it goes beneath that
			end
			
			if config.disableAttributeGain then
				local penalty = slevel - config.MajorCap
				local attribute = classInfo.GetGovernedAttribute(skill)
				
				tes3mp.SetSkillIncrease(pid, attribute, math.max((tes3mp.GetSkillIncrease(pid, attribute) - penalty), 0))
			end
		end
	end
	
	for index, skill in pairs(pClass.minorSkills) do
		local slevel = tes3mp.GetSkillBase(pid, skill)
		if slevel > config.MinorCap then
			tes3mp.SetSkillBase(pid, skill, config.MinorCap)
			table.insert(changes, tes3mp.GetSkillName(skill))
			
			if config.disableLevelProgress then
				local penalty = slevel - config.MinorCap
				tes3mp.SetLevelProgress(pid, math.max((tes3mp.GetLevelProgress(pid) - penalty), 0)) --Set the player's level progress to their current minus the penalty, or 0 if it goes beneath that
			end
			
			if config.disableAttributeGain then
				local penalty = slevel - config.MinorCap
				local attribute = classInfo.GetGovernedAttribute(skill)
				
				tes3mp.SetSkillIncrease(pid, attribute, math.max((tes3mp.GetSkillIncrease(pid, attribute) - penalty), 0)) 
			end
		end
	end
	
	--Class info doesn't have a way of detecting misc skills at the moment, so we'll just do something a little bit hacky :P
	--We go through every skill id...
	for skill = 0, 26 do
		--...and check that it isn't a major or minor skill...
		if isMisc(skill, pClass.majorSkills, pClass.minorSkills) then
			--... if it isn't, then we treat it as a misc skill
			local slevel = tes3mp.GetSkillBase(pid, skill)
			if slevel > config.MiscCap then
				tes3mp.SetSkillBase(pid, skill, config.MiscCap)
				table.insert(changes, tes3mp.GetSkillName(skill))
				
				if config.disableAttributeGain then
					local penalty = slevel - config.MiscCap
					local attribute = classInfo.GetGovernedAttribute(skill)
					
					tes3mp.SetSkillIncrease(pid, attribute, math.max((tes3mp.GetSkillIncrease(pid, attribute) - penalty), 0))
				end
			end
		end
	end
	
	--Only do anything if there were changes made
	if #changes > 0 then
		--Do some nonsense to make a pretty message
		local message = "You've hit the cap for your "
		
		for i=1, #changes do
			--Add the skill name to the list
			message = message .. changes[i]
			
			if changes[i+1] ~= nil and changes[i+2] == nil then -- If the next entry exists but the one after it doesn't, that means this is the penultimate entry
				message = message .. " and "
			elseif changes[i+1] == nil then --There's no entry after this one.
				--Do nothing
			else --It's none of the above, so just stick a comma on the end
				message = message .. ", "
			end
		end
		
		if #changes > 1 then
			message = message .. " skills.\n"
		else
			message = message .. " skill.\n"
		end
		
		tes3mp.SendMessage(pid, color.Warning .. message .. color.Default, false)

		Players[pid]:SaveSkills()
		Players[pid]:LoadSkills()
	end
end

Methods.OnPlayerSkill = function(pid)
	--On player skill gets called when the player joins the server but isn't actually logged in.
	if Players[pid]:IsLoggedIn() then
		doTheThing(pid)
	end
end

return Methods
