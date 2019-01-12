-- classInfo - Release 2 - For tes3mp v0.7-prerelease (literally hasn't changed since 0.6.1 :P)
-- save as classInfo.lua in the scripts folder

--[[ INFO
SPECIALIZATIONS: 0 Combat | 1 Magic | 2 Stealth
ATTRIBUTES: 0 Strength | 1 Intelligence | 2 Willpower | 3 Agility | 4 Speed | 5 Endurance | 6 Personality
SKILLS: 
	0 Block | 1 Armorer | 2 MediumArmor | 3 HeavyArmor | 4 BluntWeapon | 5 LongBlade | 6 Axe | 7 Spear | 8 Athletics 
	9 Enchant | 10 Destruction | 11 Alteration | 12 Illusion | 13 Conjuration | 14 Mysticism | 15 Restoration | 16 Alchemy | 17 Unarmored
	18 Security | 19 Sneak | 20 Acrobatics | 21 LightArmor | 22 ShortBlade | 23 Marksman | 24 Mercantile | 25 Speechcraft | 26 HandToHand
]]

--[[ STRUCTURE/TEMPLATE
classList["lowercasename"] = {
	name = "Name",
	specialization = specializationNum,
	majorAttributes = {attributeid, attributeid},
	majorSkills = {skillid, skillid, skillid, skillid, skillid},
	minorSkills = {skillid, skillid, skillid, skillid, skillid},
	description = "description",
}
]]

local Methods = {}

local classList = {}

classList["acrobat"] = {
	name = "Acrobat",
	specialization = 2,
	majorAttributes = {3, 5},
	majorSkills = {20, 8, 23, 19, 17},
	minorSkills = {25, 11, 7, 26, 21},
	description = "Acrobat is a polite euphemism for agile burglars and second-story men. These thieves avoid detection by stealth, and rely on mobility and cunning to avoid capture.",
}
classList["agent"] = {
	name = "Agent",
	specialization = 2,
	majorAttributes = {6, 3},
	majorSkills = {25, 19, 20, 21, 22},
	minorSkills = {24, 13, 0, 17, 12},
	description = "Agents are operatives skilled in deception and avoidance, but trained in self-defense and the use of deadly force. Self-reliant and independent, agents devote themselves to personal goals, or to various patrons or causes.",
}
classList["archer"] = {
	name = "Archer",
	specialization = 0,
	majorAttributes = {3, 0},
	majorSkills = {23, 5, 0, 8, 21},
	minorSkills = {17, 7, 15, 19, 2},
	description = "Archers are fighters specializing in long-range combat and rapid movement. Opponents are kept at distance by ranged weapons and swift maneuver, and engaged in melee with sword and shield after the enemy is wounded and weary.",
}
classList["assassin"] = {
	name = "Assassin",
	specialization = 2,
	majorAttributes = {4, 1},
	majorSkills = {19, 23, 21, 22, 20},
	minorSkills = {18, 5, 16, 0, 8},
	description = "Assassins are killers who rely on stealth and mobility to approach victims undetected. Execution is with ranged weapons or with short blades for close work. Assassins include ruthless murderers and principled agents of noble causes.",
}
classList["barbarian"] = {
	name = "Barbarian",
	specialization = 0,
	majorAttributes = {0, 4},
	majorSkills = {6, 2, 4, 8, 0},
	minorSkills = {20, 21, 1, 23, 17},
	description = "Barbarians are the proud, savage warrior elite of the plains nomads, mountain tribes, and sea reavers. They tend to be brutal and direct, lacking civilized graces, but they glory in heroic feats, and excel in fierce, frenzied single combat.",
}
classList["bard"] = {
	name = "Bard",
	specialization = 2,
	majorAttributes = {6, 1},
	majorSkills = {25, 8, 20, 5, 0},
	minorSkills = {24, 12, 2, 9, 18},
	description = "Bards are loremasters and storytellers. They crave adventure for the wisdom and insight to be gained, and must depend on sword, shield, spell and enchantment to preserve them from the perils of their educational experiences.",
}
classList["battlemage"] = {
	name = "Battlemage",
	specialization = 1,
	majorAttributes = {1, 0},
	majorSkills = {11, 10, 13, 6, 3},
	minorSkills = {14, 5, 23, 9, 16},
	description = "Battlemages are wizard-warriors, trained in both lethal spellcasting and heavily armored combat. They sacrifice mobility and versatility for the ability to supplement melee and ranged attacks with elemental damage and summoned creatures.",
}
classList["crusader"] = {
	name = "Crusader",
	specialization = 0,
	majorAttributes = {3, 0},
	majorSkills = {4, 5, 10, 3, 0},
	minorSkills = {15, 1, 26, 2, 16},
	description = "Any heavily armored warrior with spellcasting powers and a good cause may call himself a Crusader. Crusaders do well by doing good. They hunt monsters and villains, making themselves rich by plunder as they rid the world of evil.",
}
classList["healer"] = {
	name = "Healer",
	specialization = 1,
	majorAttributes = {2, 6},
	majorSkills = {15, 14, 11, 26, 25},
	minorSkills = {12, 16, 17, 21, 4},
	description = "Healers are spellcasters who swear solemn oaths to heal the afflicted and cure the diseased. When threatened, they defend themselves with reason and disabling attacks and magic, relying on deadly force only in extremity.",
}
classList["knight"] = {
	name = "Knight",
	specialization = 0,
	majorAttributes = {0, 6},
	majorSkills = {5, 6, 25, 3, 0},
	minorSkills = {15, 24, 2, 9, 1},
	description = "Of noble birth, or distinguished in battle or tourney, knights are civilized warriors, schooled in letters and courtesy, governed by the codes of chivalry. In addition to the arts of war, knights study the lore of healing and enchantment.",
}
classList["mage"] = {
	name = "Mage",
	specialization = 1,
	majorAttributes = {1, 2},
	majorSkills = {14, 10, 11, 12, 15},
	minorSkills = {9, 16, 17, 22, 13},
	description = "Most mages claim to study magic for its intellectual rewards, but they also often profit from its practical applications. Varying widely in temperament and motivation, mages share but one thing in common - an avid love of spellcasting.",
}
classList["monk"] = {
	name = "Monk",
	specialization = 2,
	majorAttributes = {3, 2},
	majorSkills = {26, 17, 8, 20, 19},
	minorSkills = {0, 23, 21, 15, 4},
	description = "Monks are students of the ancient martial arts of hand-to-hand combat and unarmored self defense. Monks avoid detection by stealth, mobility, and Agility, and are skilled with a variety of ranged and close-combat weapons.",
}
classList["nightblade"] = {
	name = "Nightblade",
	specialization = 1,
	majorAttributes = {2, 4},
	majorSkills = {14, 12, 11, 19, 22},
	minorSkills = {21, 17, 10, 23, 18},
	description = "Nightblades are spellcasters who use their magics to enhance mobility, concealment, and stealthy close combat. They have a sinister reputation, since many nightblades are thieves, enforcers, assassins, or covert agents.",
}
classList["pilgrim"] = {
	name = "Pilgrim",
	specialization = 2,
	majorAttributes = {6, 5},
	majorSkills = {25, 24, 23, 15, 2},
	minorSkills = {12, 26, 22, 0, 16},
	description = "Pilgrims are travellers, seekers of truth and enlightenment. They fortify themselves for road and wilderness with arms, armor, and magic, and through wide experience of the world, they become shrewd in commerce and persuasion.",
}
classList["rogue"] = {
	name = "Rogue",
	specialization = 0,
	majorAttributes = {4, 6},
	majorSkills = {22, 24, 6, 21, 26},
	minorSkills = {0, 2, 25, 8, 5},
	description = "Rogues are adventurers and opportunists with a gift for getting in and out of trouble. Relying variously on charm and dash, blades and business sense, they thrive on conflict and misfortune, trusting to their luck and cunning to survive.",
}
classList["scout"] = {
	name = "Scout",
	specialization = 0,
	majorAttributes = {4, 5},
	majorSkills = {19, 5, 2, 8, 0},
	minorSkills = {23, 16, 11, 21, 17},
	description = "Scouts rely on stealth to survey routes and opponents, using ranged weapons and skirmish tactics when forced to fight. By contrast with barbarians, in combat scouts tend to be cautious and methodical, rather than impulsive.",
}
classList["sorcerer"] = {
	name = "Sorcerer",
	specialization = 1,
	majorAttributes = {1, 5},
	majorSkills = {9, 13, 14, 10, 11},
	minorSkills = {12, 2, 3, 23, 22},
	description = "Though spellcasters by vocation, sorcerers rely most on summonings and enchantments. They are greedy for magic scrolls, rings, armor and weapons, and commanding undead and Daedric servants gratifies their egos.",
}
classList["spellsword"] = {
	name = "Spellsword",
	specialization = 1,
	majorAttributes = {2, 5},
	majorSkills = {0, 15, 5, 10, 11},
	minorSkills = {4, 9, 16, 2, 6},
	description = "Spellswords are spellcasting specialists trained to support Imperial troops in skirmish and in battle. Veteran spellswords are prized as mercenaries, and well-suited for careers as adventurers and soldiers-of-fortune.",
}
classList["thief"] = {
	name = "Thief",
	specialization = 2,
	majorAttributes = {4, 3},
	majorSkills = {18, 19, 20, 21, 22},
	minorSkills = {23, 25, 26, 24, 8},
	description = "Thieves are pickpockets and pilferers. Unlike robbers, who kill and loot, thieves typically choose stealth and subterfuge over violence, and often entertain romantic notions of their charm and cleverness in their acquisitive activities.",
}
classList["warrior"] = {
	name = "Warrior",
	specialization = 0,
	majorAttributes = {0, 5},
	majorSkills = {5, 2, 3, 8, 0},
	minorSkills = {1, 7, 23, 6, 4},
	description = "Warriors are the professional men-at-arms, soldiers, mercenaries, and adventurers of the Empire, trained with various weapons and armor styles, conditioned by long marches, and hardened by ambush, skirmish, and battle.",
}
classList["witchhunter"] = {
	name = "Witchhunter",
	specialization = 1,
	majorAttributes = {1, 3},
	majorSkills = {13, 9, 16, 21, 23},
	minorSkills = {17, 0, 4, 19, 14},
	description = "Witchhunters are dedicated to rooting out and destroying the perverted practices of dark cults and profane sorcery. They train for martial, magical, and stealthy war against vampires, witches, warlocks, and necromancers.",
}

local governedAttributes = {
--Skill id = attribute id
[0] = 3, 	-- Block = Agility
[1] = 0, 	-- Armorer = Strength
[2] = 5, 	-- Medium Armor = Endurance
[3] = 5, 	-- Heavy Armor = Endurance
[4] = 0, 	-- Blunt Weapon = Strength
[5] = 0, 	-- Long Blade = Strength
[6] = 0, 	-- Axe = Strength
[7] = 5, 	-- Spear = Endurance
[8] = 4, 	-- Athletics = Speed
[9] = 1, 	-- Enchant = Intelligence
[10] = 2, 	-- Destruction = Willpower
[11] = 2, 	-- Alteration = Willpower
[12] = 6, 	-- Illusion = Personality
[13] = 1, 	-- Conjuration = Intelligence
[14] = 2, 	-- Mysticism = Willpower
[15] = 2, 	-- Restoration = Willpower
[16] = 1, 	-- Alchemy = Intelligence
[17] = 4, 	-- Unarmored = Speed
[18] = 1, 	-- Security = Intelligence
[19] = 3, 	-- Sneak = Agility
[20] = 0, 	-- Acrobatics = Strength
[21] = 3, 	-- Light Armor = Agility
[22] = 4, 	-- Short Blade = Speed
[23] = 3, 	-- Marksman = Agility
[24] = 6,	-- Mercantile = Personality
[25] = 6,	-- Speechcraft = Personality
[26] = 4, 	-- Hand-to-hand = Speed
}


-- ==FUNCTIONS==
local function makeCustom(pid)
	local pClass = Players[pid].data.customClass
	local out = {}
	
	out.name = pClass.name
	out.description = pClass.description
	out.specialization = pClass.specialization
	
	local attributes = {}
	table.insert(attributes, tes3mp.GetClassMajorAttribute(pid, 0))
	table.insert(attributes, tes3mp.GetClassMajorAttribute(pid, 1))
	
	local major = {}
	table.insert(major, tes3mp.GetClassMajorSkill(pid, 0))
	table.insert(major, tes3mp.GetClassMajorSkill(pid, 1))
	table.insert(major, tes3mp.GetClassMajorSkill(pid, 2))
	table.insert(major, tes3mp.GetClassMajorSkill(pid, 3))
	table.insert(major, tes3mp.GetClassMajorSkill(pid, 4))
	
	local minor = {}
	table.insert(minor, tes3mp.GetClassMinorSkill(pid, 0))
	table.insert(minor, tes3mp.GetClassMinorSkill(pid, 1))
	table.insert(minor, tes3mp.GetClassMinorSkill(pid, 2))
	table.insert(minor, tes3mp.GetClassMinorSkill(pid, 3))
	table.insert(minor, tes3mp.GetClassMinorSkill(pid, 4))
	
	out.majorAttributes = attributes
	out.majorSkills = major
	out.minorSkills = minor
	
	return out
end

local function getDefaultClass(classId)
	return classList[classId]
end

local function addClass(classData)
	classList[string.lower(classData.name)] = classData
end

local function getPlayerClass(pid)
	if tes3mp.IsClassDefault(pid) == 1 then
		return getDefaultClass(Players[pid].data.character.class)
	else
		return makeCustom(pid)
	end
end

local function getGovernedAttribute(skillId)
	return governedAttributes[skillId]
end

local specializations = {[0] = "Combat", [1] = "Magic", [2] = "Stealth"}
local function getSpecializationName(specializationId)
	return specializations[specializationId]
end

-- ==METHODS==
--[[ Useful methods from the base mod:
tes3mp.GetAttributeName(attributeId)
tes3mp.GetSkillName(skillId)

tes3mp.GetAttributeId(attributeName)
tes3mp.GetSkillId(skillName)
]]

-- METHODS THAT TAKE PIDS
-- Use to get the data on a player's class (custom or default), given their pid.
Methods.GetPlayerClassData = function(pid)
	return getPlayerClass(pid)
end

--Use to make a table of class information based off a player's custom class that's compatible with this script's methods. Usually done automatically if you use GetPlayerClassData on a player with a custom class.
Methods.GetCustomClassData = function(pid)
	return makeCustom(pid)
end

-- METHODS THAT TAKE CLASS DATA
-- Most of these don't necessarily need to be used since they can just be accessed straight from the class data
Methods.GetClassName = function(classData)
	return classData.name
end
Methods.GetClassSpecialization = function(classData)
	return classData.specialization
end
Methods.GetClassDescription = function(classData)
	return classData.description
end
Methods.GetClassMajorAttributes = function(classData)
	return classData.majorAttributes
end
Methods.GetClassMajorSkills = function(classData)
	return classData.majorSkills
end
Methods.GetClassMinorSkills = function(classData)
	return classData.minorSkills
end

-- METHODS THAT TAKE OTHER STUFF
-- Use to get the data on a default class given the class name
Methods.GetClassData = function(className)
	return getDefaultClass(string.lower(className))
end

-- Use to remotely add new class information to the classInfo table. The data should be a table formatted as the classes are in this script. A lowercase version of the name entry will be used as the key. It's unadvised to add players' custom classes to the list, as the custom names can overwrite existing entries. Additions to the classInfo table aren't saved and have to be redone every server launch.
Methods.AddClass = function(classData)
	addClass(classData)
end

Methods.GetSpecializationName = function(specializationId)
	return getSpecializationName(specializationId)
end

-- Takes a provided Skill ID and returns the Attribute ID of the attribute the skill is governed by. Not technically anything to do with classes - consider it a bonus function :P
Methods.GetGovernedAttribute = function(skillId)
	return getGovernedAttribute(skillId)
end


return Methods
