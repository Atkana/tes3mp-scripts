-- itemInfo - Release 1 - For tes3mp v0.6.1
-- save as itemInfo.lua in the scripts folder

Methods = {}

tableHelper = require("tableHelper")

local itemsList = {}
-- All information gathered from the UESPwiki ( http://en.uesp.net/wiki/Main_Page )

--[[ itemsList data structure:
[A list of most/all of the possible keys and uses for item data. There might be more detailed information of uses in the respective item's template section.]
[The key used for an item is the item's id as it appears in Base Morrowind]

name
	[Items name as given ingame]

id
	[Id of item]

weight
	[Weight value of item]

health
	[For weapons and armour, the max durability]
	[For tools, the max number of uses]

value
	[Money value]

rating
	[Armor rating]

enchant
	[Enchantability value]

weaponData
	[Table with keys:]
	chopMin
		[Minimum chop damage]
	chopMax
		[Maximum chop damage]
	slashMin
		[Minimum slash damage]
	slashMax
		[Maximum slash damage]
	thrustMin
		[Minimum thrust damage]
	trustMax
		[Maximum thrust damage]
	speed
		[Weapon speed]
	reach
		[Weapon reach]

marksMin
	[Minimum damage for marksman weapons]
marksMax
	[Maximum damage for marksman weapons]
marksSpeed
	[Apparently used for throwing weapons? Just never mentioned anywhere up until Tribunal dart entries...]

lightData
	[Table of data for lights]
	light
	time
	[Colour?]

itemType
	[valid types: alchemy, apparatus, armor, book, clothing, ingredient*, light,  lockpick, misc, probe, repair item, weapon, scroll?,
	*The table I referenced for this labels them "ingrediant"s, but I'm going to assume this is a spelling error]

subtype
	[Weapons: war axe, battle axe, club, mace, warhammer, staff, dagger, shortsword, saber, broadsword, longsword, katana, claymore, dai-katana, spear, halberd, short bow, long bow, arrow, crossbow, bolt, throwing knife, throwing star, dart, tanto, wakizashi]
	[Clothing: amulet, belt, glove, pants, ring, robe, shirt, shoes, skirt]
	[Armor: cuirass, greaves, helm, pauldron, boots, gauntlet, bracer, shield, tower shield]

canBeast
	[Present and true for helmets that can be worn by beast races. Only present for helmets that can be worn by beasts]

imperialUniform
	[Present and true for armour pieces that count as imperial uniform for the uniform script]

ordinatorUniform
	[Present and true on any armor pieces that'll net you an Ordinator death warrant if you talk to and Ordinator while wearing it.]

hand
	[Number of hands to use the item. For weapons?]

normalWeapon
	[Only present and true in "Normal Weapons" http://en.uesp.net/wiki/Morrowind:Normal_Weapons Use only for the items that appear on that page]

orientation
	[For gloves, pauldrons]
	"left", "right"

material
	[Technically not an official variable. May be missing/wrong in entries]
	chitin, iron, steel, silver, dwarven, glass, ebony, daedric, nordic, orcish, dreugh, wood, bonemold, adamantium, stalhrim, corkbulb, leather, fur, cloth, bone, 

effectData
	[Table containing enchantment information/scroll spell information. Only present for base game items (not player-made ones)]
	[TODO: Determine structure]

ingredientData
	[Table containing effect data for ingredients. Separate from effectData because arbitrary design decisions.]
	[TODO: Determine structure]

baseItem
	[Present on items that use another as a base. Is the item id of the original item.]

skillId
	[For skillbooks, weapons, and armours. Uses the vanilla Morrowind skill IDs (e.g 0 = Block, 11 = Alteration) See: http://en.uesp.net/wiki/Morrowind:Skills ]
skillName
	[the string name for a skill, only included because I'm not sure if OpenMW uses the same Skill IDs as vanilla Morrowind.]

quality
	[for picks, hammers, probes, apparatus]

rank
	Potions: 0 Special, 1 Spoiled, 2 Bargain, 3 Cheap, 4 Standard, 5 Quality, 6 Exclusive
	Picks/probes: 0 Special, 1 Apprentice, 2 Journeyman, 3 Master, 4 Grandmaster, 5 Secret master
	Clothing: 0 if special, 1 if common, 2 if expensive, 3 if extravagant, 4 if exquisite
	Apparatus: 0 special, 1 apprentice, 2 journeyman, 3 master, 4 grandmaster, 5 secretmaster

skoomaRelated
	[Present and true for any items that will cause non-khajiit traders to refuse to do business (only present on moon sugar and skooma)]

Not doing (either initially, or ever):
	Equip regions - Don't want to dig through CS code.
	Effect types (for ingredients, magic items, potions) - Not sure how the effects should be presented.
	Scripts. Not easily available info
	Quests. Information on related quests.
	Harvest Probability. See it mentioned on the wiki but don't really understand how it works well enough to implement a stat for it.
]]

--[[ TODO:
Everything that isn't done...

Done:
> Potions
	> Morrowind (+EPs)
		> ALL (no effects)
> Weapons
	> Base Weapons
		> Morrowind (+EPs)
			- ALL
> Armor
	> Base Armor
		> Morrowind (+EPs)
			- ALL
	> Generic Magic Armor
		> Morrowind
			- ALL (no effects)
			
> Clothing
	> Base Clothing
		> Morrowind (+EPs)
			- ALL
> Tools
	> Lockpicks
		- ALL
	> Probes
		- ALL
	> Repair
		- ALL
	> Alchemy Apparatus
		- ALL
> Ingredients
	> Morrowind (+EPs)
		- A few high-ticket ingredients (no effects)
]]

--[[ TEMPLATES
--Template Armor
itemsList["template_armor"] = {
	name = "Template",
	id = "template_armor",
	itemType = "armor",
	subtype = "subtype", --cuirass, greaves, helm, pauldron, boots, gauntlet, bracer, shield, tower shield
	weight = 0,
	health = 0,
	value = 0,
	rating = 0,
	enchant = 0,
	skillId = 0, --Light 21, Medium 2, Heavy 3
	skillName = "skillname", -- "Lightarmor", "Mediumarmor", "Heavyarmor"
	material = "material",
	--orientation = "left", --If left/right items. "left", "right"
	--hand = 1, --If shield
	--canBeast = true, --if helmet that beasts can wear
	--imperialUniform = true, --if Imperial Uniform
	--ordinatorUniform = true, --if Ordinator death warrant item
	--baseItem = "id", -- if based off another item (for magic items)
	--effectData = {}, --if enchanted. Table empty for now.
}

--Template Clothing
itemsList["template_clothing"] = {
	name = "Template",
	id = "template_clothing",
	itemType = "clothing",
	subtype = "subtype", --amulet, belt, glove, pants, ring, robe, shirt, shoes, skirt
	weight = 0,
	value = 0,
	enchant = 0,
	rank = 0, --0 if special, 1 if common, 2 if expensive, 3 if extravagant, 4 if exquisite
}

--Temporary Potion Template
itemsList["template_potion"] = {
	name = "Template",
	id = "template_potion",
	itemType = "alchemy",
	subtype = "subtype", --potion, spoiled, beverage, special, perfume
	weight = 0,
	value = 0,
	rank = 0, --Potions: 0 Special, 1 Spoiled, 2 Bargain, 3 Cheap, 4 Standard, 5 Quality, 6 Exclusive. Potions with a single power of effect (e.g. Potion of Marking) are usually Standard (4)
	effectData = {}, --Empty, for now
	--skoomaRelated = true, --if skooma
}

--Tool Template
itemsList["template_tool"] = {
	name = "Template",
	id = "template_tool",
	itemType = "type", -- apparatus, lockpick, probe, repair item
	--subtype = "subtype", --for alchemy apparatus. alembic, calcinator, mortar, retort
	weight = 0,
	value = 0,
	--health = 0, -- Item's max uses, if applicable.
	quality = 0,
	rank = 0, -- ranks for Picks/probes/repair/apparatus: 0 special, 1 apprentice, 2 journeyman, 3 master, 4 grandmaster, 5 secretmaster
}

--Temporary Ingredient Template 
itemsList["template_ingredient"] = {
	name = "Template",
	id = "template_ingredient",
	itemType = "ingredient",
	value = 0,
	weight = 0,
	ingredientData = {}, --Empty, for now
	--skoomaRelated = true, --if moon sugar
}

]]

-- **WEAPONS**
-- *BASE WEAPONS*
-- Base Weapons (Morrowind)
-- *Axes*
--Chitin War Axe
itemsList["chitin war axe"] = {
	name = "Chitin War Axe",
	id = "chitin war axe",
	itemType = "weapon",
	subtype = "war axe",
	weight = 12.0,
	health = 640,
	value = 19,
	weaponData = {
		minChop = 1,
		maxChop = 11,
		minSlash = 1,
		maxSlash = 6,
		minThrust = 1,
		maxThrust = 2,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 2.5,
	skillId = 6,
	skillName = "Axe",
	material = "chitin",
	hand = 1,
	normalWeapon = true
}
--Iron War Axe
itemsList["iron war axe"] = {
	name = "Iron War Axe",
	id = "iron war axe",
	itemType = "weapon",
	subtype = "war axe",
	weight = 24.0,
	health = 800,
	value = 30,
	weaponData = {
		minChop = 1,
		maxChop = 18,
		minSlash = 1,
		maxSlash = 10,
		minThrust = 1,
		maxThrust = 2,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 5,
	skillId = 6,
	skillName = "Axe",
	material = "iron",
	hand = 1,
	normalWeapon = true
}
--Steel Axe
itemsList["steel axe"] = {
	name = "Steel Axe",
	id = "steel axe",
	itemType = "weapon",
	subtype = "war axe",
	weight = 24.0,
	health = 1200,
	value = 60,
	weaponData = {
		minChop = 1,
		maxChop = 18,
		minSlash = 1,
		maxSlash = 10,
		minThrust = 1,
		maxThrust = 2,
		speed = 1.0,
		reach = 1.0
	},
	enchant = 4.5,
	skillId = 6,
	skillName = "Axe",
	material = "steel",
	hand = 1,
	normalWeapon = true
}
--Steel War Axe
itemsList["steel war axe"] = {
	name = "Steel War Axe",
	id = "steel war axe",
	itemType = "weapon",
	subtype = "war axe",
	weight = 24.0,
	health = 1200,
	value = 60,
	weaponData = {
		minChop = 1,
		maxChop = 20,
		minSlash = 1,
		maxSlash = 11,
		minThrust = 1,
		maxThrust = 3,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 5,
	skillId = 6,
	skillName = "Axe",
	material = "steel",
	hand = 1,
	normalWeapon = true
}
--Silver War Axe
itemsList["silver war axe"] = {
	name = "Silver War Axe",
	id = "silver war axe",
	itemType = "weapon",
	subtype = "war axe",
	weight = 19.2,
	health = 720,
	value = 120,
	weaponData = {
		minChop = 1,
		maxChop = 20,
		minSlash = 1,
		maxSlash = 11,
		minThrust = 1,
		maxThrust = 3,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 4,
	skillId = 6,
	skillName = "Axe",
	material = "silver",
	hand = 1
}
--Dwarven War Axe
itemsList["dwarven war axe"] = {
	name = "Dwarven War Axe",
	id = "dwarven war axe",
	itemType = "weapon",
	subtype = "war axe",
	weight = 24.0,
	health = 2000,
	value = 450,
	weaponData = {
		minChop = 1,
		maxChop = 24,
		minSlash = 1,
		maxSlash = 13,
		minThrust = 1,
		maxThrust = 3,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 5,
	skillId = 6,
	skillName = "Axe",
	material = "dwarven",
	hand = 1
}
--Glass War Axe
itemsList["glass war axe"] = {
	name = "Glass War Axe",
	id = "glass war axe",
	itemType = "weapon",
	subtype = "war axe",
	weight = 14.4,
	health = 640,
	value = 12000,
	weaponData = {
		minChop = 1,
		maxChop = 33,
		minSlash = 1,
		maxSlash = 18,
		minThrust = 1,
		maxThrust = 5,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 3,
	skillId = 6,
	skillName = "Axe",
	material = "glass",
	hand = 1
}
--Ebony War Axe
itemsList["ebony war axe"] = {
	name = "Ebony War Axe",
	id = "ebony war axe",
	itemType = "weapon",
	subtype = "war axe",
	weight = 48.0,
	health = 2400,
	value = 15000,
	weaponData = {
		minChop = 1,
		maxChop = 37,
		minSlash = 1,
		maxSlash = 20,
		minThrust = 1,
		maxThrust = 5,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 10,
	skillId = 6,
	skillName = "Axe",
	material = "ebony",
	hand = 1
}
--Daedric War Axe
itemsList["daedric war axe"] = {
	name = "Daedric War Axe",
	id = "daedric war axe",
	itemType = "weapon",
	subtype = "war axe",
	weight = 72.0,
	health = 3200,
	value = 30000,
	weaponData = {
		minChop = 1,
		maxChop = 44,
		minSlash = 1,
		maxSlash = 24,
		minThrust = 1,
		maxThrust = 6,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 15,
	skillId = 6,
	skillName = "Axe",
	material = "daedric",
	hand = 1
}

--Miner's Pick
itemsList["miner's pick"] = {
	name = "Miner's Pick",
	id = "miner's pick",
	itemType = "weapon",
	subtype = "battle axe",
	weight = 20.0,
	health = 400,
	value = 8,
	weaponData = {
		minChop = 3,
		maxChop = 7,
		minSlash = 2,
		maxSlash = 3,
		minThrust = 1,
		maxThrust = 3,
		speed = 1.0,
		reach = 1.0
	},
	enchant = 1,
	skillId = 6,
	skillName = "Axe",
	--material = "iron",
	hand = 2,
	normalWeapon = true
}
--Iron Battle Axe
itemsList["iron battle axe"] = {
	name = "Iron Battle Axe",
	id = "iron battle axe",
	itemType = "weapon",
	subtype = "battle axe",
	weight = 30.0,
	health = 1200,
	value = 50,
	weaponData = {
		minChop = 1,
		maxChop = 32,
		minSlash = 1,
		maxSlash = 24,
		minThrust = 1,
		maxThrust = 3,
		speed = 1.0,
		reach = 1.0
	},
	enchant = 5.5,
	skillId = 6,
	skillName = "Axe",
	material = "iron",
	hand = 2,
	normalWeapon = true
}
--Nordic Battle Axe
itemsList["nordic battle axe"] = {
	name = "Nordic Battle Axe",
	id = "nordic battle axe",
	itemType = "weapon",
	subtype = "battle axe",
	weight = 30.0,
	health = 1200,
	value = 60,
	weaponData = {
		minChop = 1,
		maxChop = 30,
		minSlash = 1,
		maxSlash = 30,
		minThrust = 1,
		maxThrust = 4,
		speed = 1.0,
		reach = 1.0
	},
	enchant = 5.5,
	skillId = 6,
	skillName = "Axe",
	material = "nordic",
	hand = 2,
	normalWeapon = true
}
--Steel Battle Axe
itemsList["steel battle axe"] = {
	name = "Steel Battle Axe",
	id = "steel battle axe",
	itemType = "weapon",
	subtype = "battle axe",
	weight = 30.0,
	health = 1800,
	value = 100,
	weaponData = {
		minChop = 1,
		maxChop = 36,
		minSlash = 1,
		maxSlash = 27,
		minThrust = 1,
		maxThrust = 4,
		speed = 1.0,
		reach = 1.0
	},
	enchant = 5.5,
	skillId = 6,
	skillName = "Axe",
	material = "steel",
	hand = 2,
	normalWeapon = true
}
--Dwarven Battle Axe
itemsList["dwarven battle axe"] = {
	name = "Dwarven Battle Axe",
	id = "dwarven battle axe",
	itemType = "weapon",
	subtype = "battle axe",
	weight = 30.0,
	health = 3000,
	value = 750,
	weaponData = {
		minChop = 1,
		maxChop = 35,
		minSlash = 1,
		maxSlash = 33,
		minThrust = 1,
		maxThrust = 15,
		speed = 1.0,
		reach = 1.0
	},
	enchant = 5.5,
	skillId = 6,
	skillName = "Axe",
	material = "dwarven",
	hand = 2,
}
--Orcish Battle Axe
itemsList["orcish battle axe"] = {
	name = "Orcish Battle Axe",
	id = "orcish battle axe",
	itemType = "weapon",
	subtype = "battle axe",
	weight = 15.0,
	health = 2400,
	value = 2000,
	weaponData = {
		minChop = 17,
		maxChop = 28,
		minSlash = 2,
		maxSlash = 23,
		minThrust = 0,
		maxThrust = 2,
		speed = 1.0,
		reach = 1.0
	},
	enchant = 8,
	skillId = 6,
	skillName = "Axe",
	material = "orcish",
	hand = 2,
}
--Daedric Battle Axe
itemsList["daedric battle axe"] = {
	name = "Daedric Battle Axe",
	id = "daedric battle axe",
	itemType = "weapon",
	subtype = "battle axe",
	weight = 90.0,
	health = 4800,
	value = 50000,
	weaponData = {
		minChop = 1,
		maxChop = 80,
		minSlash = 1,
		maxSlash = 60,
		minThrust = 1,
		maxThrust = 8,
		speed = 1.0,
		reach = 1.0
	},
	enchant = 16.5,
	skillId = 6,
	skillName = "Axe",
	material = "daedric",
	hand = 2,
}

--Chitin Club
itemsList["chitin club"] = {
	name = "Chitin Club",
	id = "chitin club",
	itemType = "weapon",
	subtype = "club",
	weight = 6.0,
	health = 320,
	value = 6,
	weaponData = {
		minChop = 3,
		maxChop = 3,
		minSlash = 2,
		maxSlash = 2,
		minThrust = 1,
		maxThrust = 2,
		speed = 1.5,
		reach = 1.0
	},
	enchant = 2,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "chitin",
	hand = 1,
	normalWeapon = true
}
--Iron Club
itemsList["iron club"] = {
	name = "Iron Club",
	id = "iron club",
	itemType = "weapon",
	subtype = "club",
	weight = 12.0,
	health = 400,
	value = 10,
	weaponData = {
		minChop = 4,
		maxChop = 5,
		minSlash = 3,
		maxSlash = 3,
		minThrust = 1,
		maxThrust = 3,
		speed = 1.5,
		reach = 1.0
	},
	enchant = 4,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "iron",
	hand = 1,
	normalWeapon = true
}
--Steel Club
itemsList["steel club"] = {
	name = "Steel Club",
	id = "steel club",
	itemType = "weapon",
	subtype = "club",
	weight = 12.0,
	health = 600,
	value = 20,
	weaponData = {
		minChop = 4,
		maxChop = 5,
		minSlash = 3,
		maxSlash = 4,
		minThrust = 3,
		maxThrust = 4,
		speed = 1.5,
		reach = 1.0
	},
	enchant = 4,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "steel",
	hand = 1,
	normalWeapon = true
}
--Spiked Club
itemsList["spiked club"] = {
	name = "Spiked Club",
	id = "spiked club",
	itemType = "weapon",
	subtype = "club",
	weight = 12.0,
	health = 400,
	value = 18,
	weaponData = {
		minChop = 4,
		maxChop = 5,
		minSlash = 4,
		maxSlash = 4,
		minThrust = 1,
		maxThrust = 2,
		speed = 1.5,
		reach = 1.0
	},
	enchant = 4,
	skillId = 4,
	skillName = "Bluntweapon",
	--material = "steel",
	hand = 1,
	normalWeapon = true
}
--Dreugh Club
itemsList["dreugh club"] = {
	name = "Dreugh Club",
	id = "dreugh club",
	itemType = "weapon",
	subtype = "club",
	weight = 10.8,
	health = 400,
	value = 200,
	weaponData = {
		minChop = 7,
		maxChop = 8,
		minSlash = 4,
		maxSlash = 5,
		minThrust = 3,
		maxThrust = 5,
		speed = 1.5,
		reach = 1.0
	},
	enchant = 3.6,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "dreugh",
	hand = 1,
}
--Daedric Club
itemsList["daedric club"] = {
	name = "Daedric Club",
	id = "daedric club",
	itemType = "weapon",
	subtype = "club",
	weight = 36.0,
	health = 1600,
	value = 10000,
	weaponData = {
		minChop = 10,
		maxChop = 12,
		minSlash = 4,
		maxSlash = 8,
		minThrust = 4,
		maxThrust = 8,
		speed = 1.5,
		reach = 1.0
	},
	enchant = 12,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "daedric",
	hand = 1,
}
--Iron Mace
itemsList["iron mace"] = {
	name = "Iron Mace",
	id = "iron mace",
	itemType = "weapon",
	subtype = "mace",
	weight = 15.0,
	health = 1200,
	value = 24,
	weaponData = {
		minChop = 1,
		maxChop = 12,
		minSlash = 1,
		maxSlash = 12,
		minThrust = 1,
		maxThrust = 2,
		speed = 1.3,
		reach = 1.0
	},
	enchant = 5,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "iron",
	hand = 1,
	normalWeapon = true
}
--Steel Mace
itemsList["steel mace"] = {
	name = "Steel Mace",
	id = "steel mace",
	itemType = "weapon",
	subtype = "mace",
	weight = 15.0,
	health = 1800,
	value = 48,
	weaponData = {
		minChop = 3,
		maxChop = 14,
		minSlash = 3,
		maxSlash = 14,
		minThrust = 1,
		maxThrust = 2,
		speed = 1.3,
		reach = 1.0
	},
	enchant = 5,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "steel",
	hand = 1,
	normalWeapon = true
}
--Dwarven Mace
itemsList["dwarven mace"] = {
	name = "Dwarven Mace",
	id = "dwarven mace",
	itemType = "weapon",
	subtype = "mace",
	weight = 15.0,
	health = 3000,
	value = 360,
	weaponData = {
		minChop = 5,
		maxChop = 17,
		minSlash = 5,
		maxSlash = 17,
		minThrust = 1,
		maxThrust = 2,
		speed = 1.5,
		reach = 1.0
	},
	enchant = 5,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "dwarven",
	hand = 1
}
--Ebony Mace
itemsList["ebony mace"] = {
	name = "Ebony Mace",
	id = "ebony mace",
	itemType = "weapon",
	subtype = "mace",
	weight = 30.0,
	health = 3600,
	value = 12000,
	weaponData = {
		minChop = 7,
		maxChop = 26,
		minSlash = 7,
		maxSlash = 26,
		minThrust = 1,
		maxThrust = 3,
		speed = 1.5,
		reach = 1.0
	},
	enchant = 10,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "ebony",
	hand = 1
}
--Daedric Mace
itemsList["daedric mace"] = {
	name = "Daedric Mace",
	id = "daedric mace",
	itemType = "weapon",
	subtype = "mace",
	weight = 45.0,
	health = 4800,
	value = 24000,
	weaponData = {
		minChop = 3,
		maxChop = 30,
		minSlash = 3,
		maxSlash = 30,
		minThrust = 2,
		maxThrust = 4,
		speed = 1.3,
		reach = 1.0
	},
	enchant = 15,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "daedric",
	hand = 1
}

--Iron Warhammer
itemsList["iron warhammer"] = {
	name = "Iron Warhammer",
	id = "iron warhammer",
	itemType = "weapon",
	subtype = "warhammer",
	weight = 32.0,
	health = 2000,
	value = 40,
	weaponData = {
		minChop = 1,
		maxChop = 28,
		minSlash = 1,
		maxSlash = 24,
		minThrust = 1,
		maxThrust = 2,
		speed = 1.0,
		reach = 1.5
	},
	enchant = 5.5,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "iron",
	hand = 2,
	normalWeapon = true
}
--Steel Warhammer
itemsList["steel warhammer"] = {
	name = "Steel Warhammer",
	id = "steel warhammer",
	itemType = "weapon",
	subtype = "warhammer",
	weight = 32.0,
	health = 3000,
	value = 80,
	weaponData = {
		minChop = 1,
		maxChop = 32,
		minSlash = 1,
		maxSlash = 27,
		minThrust = 1,
		maxThrust = 2,
		speed = 1.0,
		reach = 1.5
	},
	enchant = 5.5,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "steel",
	hand = 2,
	normalWeapon = true
}
--Dwarven Warhammer
itemsList["dwarven warhammer"] = {
	name = "Dwarven Warhammer",
	id = "dwarven warhammer",
	itemType = "weapon",
	subtype = "warhammer",
	weight = 32.0,
	health = 5000,
	value = 600,
	weaponData = {
		minChop = 1,
		maxChop = 39,
		minSlash = 1,
		maxSlash = 33,
		minThrust = 1,
		maxThrust = 2,
		speed = 1.0,
		reach = 1.5
	},
	enchant = 5.5,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "dwarven",
	hand = 2
}
--Orc Warhammer
itemsList["orcish warhammer"] = {
	name = "Orc Warhammer",
	id = "orcish warhammer",
	itemType = "weapon",
	subtype = "warhammer",
	weight = 38.4,
	health = 4000,
	value = 1600,
	weaponData = {
		minChop = 1,
		maxChop = 42,
		minSlash = 1,
		maxSlash = 36,
		minThrust = 1,
		maxThrust = 2,
		speed = 1.0,
		reach = 1.5
	},
	enchant = 6.6,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "orcish",
	hand = 2
}
--Sixth House Bell Hammer
itemsList["6th bell hammer"] = {
	name = "Sixth House Bell Hammer",
	id = "6th bell hammer",
	itemType = "weapon",
	subtype = "warhammer",
	weight = 75.0,
	health = 4000,
	value = 5000,
	weaponData = {
		minChop = 1,
		maxChop = 50,
		minSlash = 1,
		maxSlash = 45,
		minThrust = 1,
		maxThrust = 3,
		speed = 1.0,
		reach = 1.5
	},
	enchant = 10.5,
	skillId = 4,
	skillName = "Bluntweapon",
	--material = "daedric", ?
	hand = 2
}
--Daedric Warhammer
itemsList["daedric warhammer"] = {
	name = "Daedric Warhammer",
	id = "daedric warhammer",
	itemType = "weapon",
	subtype = "warhammer",
	weight = 96.0,
	health = 8000,
	value = 30000,
	weaponData = {
		minChop = 1,
		maxChop = 70,
		minSlash = 1,
		maxSlash = 60,
		minThrust = 1,
		maxThrust = 4,
		speed = 1.0,
		reach = 1.5
	},
	enchant = 16.5,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "daedric",
	hand = 2
}

--Wooden Staff
itemsList["wooden staff"] = {
	name = "Wooden Staff",
	id = "wooden staff",
	itemType = "weapon",
	subtype = "staff",
	weight = 8.0,
	health = 300,
	value = 8,
	weaponData = {
		minChop = 2,
		maxChop = 6,
		minSlash = 3,
		maxSlash = 6,
		minThrust = 1,
		maxThrust = 5,
		speed = 1.75,
		reach = 1.8
	},
	enchant = 7,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "wood",
	hand = 2,
	normalWeapon = true
}
--Steel staff
itemsList["steel staff"] = {
	name = "Steel Staff",
	id = "steel staff",
	itemType = "weapon",
	subtype = "staff",
	weight = 8.0,
	health = 300,
	value = 28,
	weaponData = {
		minChop = 2,
		maxChop = 7,
		minSlash = 3,
		maxSlash = 7,
		minThrust = 1,
		maxThrust = 5,
		speed = 1.75,
		reach = 1.8
	},
	enchant = 7,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "steel",
	hand = 2,
	normalWeapon = true
}
--Silver staff
itemsList["silver staff"] = {
	name = "Silver Staff",
	id = "silver staff",
	itemType = "weapon",
	subtype = "staff",
	weight = 6.4,
	health = 270,
	value = 56,
	weaponData = {
		minChop = 2,
		maxChop = 7,
		minSlash = 3,
		maxSlash = 7,
		minThrust = 1,
		maxThrust = 5,
		speed = 1.75,
		reach = 1.5
	},
	enchant = 5.6,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "silver",
	hand = 2,
}
--Dreugh staff
itemsList["dreugh staff"] = {
	name = "Dreugh Staff",
	id = "dreugh staff",
	itemType = "weapon",
	subtype = "staff",
	weight = 7.2,
	health = 270,
	value = 400,
	weaponData = {
		minChop = 2,
		maxChop = 10,
		minSlash = 3,
		maxSlash = 10,
		minThrust = 1,
		maxThrust = 8,
		speed = 1.75,
		reach = 1.5
	},
	enchant = 6.3,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "dreugh",
	hand = 2,
}
--Glass staff
itemsList["glass staff"] = {
	name = "Glass Staff",
	id = "glass staff",
	itemType = "weapon",
	subtype = "staff",
	weight = 4.8,
	health = 240,
	value = 5600,
	weaponData = {
		minChop = 2,
		maxChop = 12,
		minSlash = 3,
		maxSlash = 12,
		minThrust = 1,
		maxThrust = 9,
		speed = 1.75,
		reach = 1.5
	},
	enchant = 4.2,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "glass",
	hand = 2,
}
--Ebony staff
itemsList["ebony staff"] = {
	name = "Ebony Staff",
	id = "ebony staff",
	itemType = "weapon",
	subtype = "staff",
	weight = 16.0,
	health = 900,
	value = 7000,
	weaponData = {
		minChop = 2,
		maxChop = 16,
		minSlash = 3,
		maxSlash = 16,
		minThrust = 1,
		maxThrust = 10,
		speed = 1.75,
		reach = 1.8
	},
	enchant = 90,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "ebony",
	hand = 2,
}
--Daedric staff
itemsList["daedric staff"] = {
	name = "Daedric Staff",
	id = "daedric staff",
	itemType = "weapon",
	subtype = "staff",
	weight = 24.0,
	health = 1200,
	value = 14000,
	weaponData = {
		minChop = 2,
		maxChop = 16,
		minSlash = 3,
		maxSlash = 16,
		minThrust = 1,
		maxThrust = 12,
		speed = 1.75,
		reach = 1.8
	},
	enchant = 21,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "daedric",
	hand = 2,
}

--Iron Fork
itemsList["iron fork"] = {
	name = "Iron Fork",
	id = "iron fork",
	itemType = "weapon",
	subtype = "dagger",
	weight = 1.0,
	health = 400,
	value = 1,
	weaponData = {
		minChop = 3,
		maxChop = 5,
		minSlash = 3,
		maxSlash = 5,
		minThrust = 3,
		maxThrust = 5,
		speed = 2.5,
		reach = 1.0
	},
	enchant = 10,
	skillId = 22,
	skillName = "Shortblade",
	material = "iron",
	hand = 1,
	normalWeapon = true
}
--Chitin Dagger
itemsList["chitin dagger"] = {
	name = "Chitin Dagger",
	id = "chitin dagger",
	itemType = "weapon",
	subtype = "dagger",
	weight = 1.5,
	health = 380,
	value = 6,
	weaponData = {
		minChop = 3,
		maxChop = 3,
		minSlash = 3,
		maxSlash = 3,
		minThrust = 4,
		maxThrust = 4,
		speed = 2.0,
		reach = 1.0
	},
	enchant = 1,
	skillId = 22,
	skillName = "Shortblade",
	material = "chitin",
	hand = 1,
	normalWeapon = true
}
--Iron Dagger
itemsList["iron dagger"] = {
	name = "Iron Dagger",
	id = "iron dagger",
	itemType = "weapon",
	subtype = "dagger",
	weight = 3.0,
	health = 400,
	value = 10,
	weaponData = {
		minChop = 4,
		maxChop = 5,
		minSlash = 4,
		maxSlash = 5,
		minThrust = 5,
		maxThrust = 5,
		speed = 2.5,
		reach = 1.0
	},
	enchant = 2,
	skillId = 22,
	skillName = "Shortblade",
	material = "iron",
	hand = 1,
	normalWeapon = true
}
--Chitin Shortsword
itemsList["chitin shortsword"] = {
	name = "Chitin Shortsword",
	id = "chitin shortsword",
	itemType = "weapon",
	subtype = "shortsword",
	weight = 4.0,
	health = 540,
	value = 13,
	weaponData = {
		minChop = 3,
		maxChop = 7,
		minSlash = 3,
		maxSlash = 7,
		minThrust = 4,
		maxThrust = 9,
		speed = 2.0,
		reach = 1.0
	},
	enchant = 2,
	skillId = 22,
	skillName = "Shortblade",
	material = "chitin",
	hand = 1,
	normalWeapon = true
}
--Iron tanto
itemsList["iron tanto"] = {
	name = "Iron Tanto",
	id = "iron tanto",
	itemType = "weapon",
	subtype = "tanto",
	weight = 4.0,
	health = 500,
	value = 14,
	weaponData = {
		minChop = 5,
		maxChop = 5,
		minSlash = 5,
		maxSlash = 6,
		minThrust = 6,
		maxThrust = 6,
		speed = 2.25,
		reach = 1.0
	},
	enchant = 2.2,
	skillId = 22,
	skillName = "Shortblade",
	material = "iron",
	hand = 1,
	normalWeapon = true
}
--Steel dagger
itemsList["steel dagger"] = {
	name = "Steel Dagger",
	id = "steel dagger",
	itemType = "weapon",
	subtype = "dagger",
	weight = 3.0,
	health = 450,
	value = 20,
	weaponData = {
		minChop = 4,
		maxChop = 5,
		minSlash = 4,
		maxSlash = 5,
		minThrust = 5,
		maxThrust = 5,
		speed = 2.5,
		reach = 1.0
	},
	enchant = 2,
	skillId = 22,
	skillName = "Shortblade",
	material = "steel",
	hand = 1,
	normalWeapon = true
}
--Iron shortsword
itemsList["iron shortsword"] = {
	name = "Iron Shortsword",
	id = "iron shortsword",
	itemType = "weapon",
	subtype = "shortsword",
	weight = 8.0,
	health = 600,
	value = 20,
	weaponData = {
		minChop = 4,
		maxChop = 9,
		minSlash = 4,
		maxSlash = 9,
		minThrust = 7,
		maxThrust = 11,
		speed = 2.0,
		reach = 1.0
	},
	enchant = 4,
	skillId = 22,
	skillName = "Shortblade",
	material = "iron",
	hand = 1,
	normalWeapon = true
}
--Iron Wakizashi
itemsList["iron wakizashi"] = {
	name = "Iron Wakizashi",
	id = "iron wakizashi",
	itemType = "weapon",
	subtype = "wakizashi",
	weight = 10.0,
	health = 500,
	value = 24,
	weaponData = {
		minChop = 7,
		maxChop = 12,
		minSlash = 5,
		maxSlash = 10,
		minThrust = 1,
		maxThrust = 5,
		speed = 2.25,
		reach = 1.0
	},
	enchant = 4.5,
	skillId = 22,
	skillName = "Shortblade",
	material = "iron",
	hand = 1,
	normalWeapon = true
}
--Steel Tanto
itemsList["steel tanto"] = {
	name = "Steel Tanto",
	id = "steel tanto",
	itemType = "weapon",
	subtype = "tanto",
	weight = 4.0,
	health = 600,
	value = 28,
	weaponData = {
		minChop = 5,
		maxChop = 1,
		minSlash = 5,
		maxSlash = 11,
		minThrust = 6,
		maxThrust = 11,
		speed = 2.25,
		reach = 1.0
	},
	enchant = 2.2,
	skillId = 22,
	skillName = "Shortblade",
	material = "steel",
	hand = 1,
	normalWeapon = true
}
--Imperial Shortsword
itemsList["imperial shortsword"] = {
	name = "Imperial Shortsword",
	id = "imperial shortsword",
	itemType = "weapon",
	subtype = "shortsword",
	weight = 9.0,
	health = 700,
	value = 30,
	weaponData = {
		minChop = 4,
		maxChop = 10,
		minSlash = 4,
		maxSlash = 10,
		minThrust = 6,
		maxThrust = 10,
		speed = 2.0,
		reach = 1.0
	},
	enchant = 5,
	skillId = 22,
	skillName = "Shortblade",
	--material = "steel",
	hand = 1,
	normalWeapon = true
}
--Silver Dagger
itemsList["silver dagger"] = {
	name = "Silver Dagger",
	id = "silver dagger",
	itemType = "weapon",
	subtype = "dagger",
	weight = 2.4,
	health = 400,
	value = 40,
	weaponData = {
		minChop = 4,
		maxChop = 5,
		minSlash = 4,
		maxSlash = 5,
		minThrust = 5,
		maxThrust = 5,
		speed = 2.5,
		reach = 1.0
	},
	enchant = 1.6,
	skillId = 22,
	skillName = "Shortblade",
	material = "silver",
	hand = 1
}
--Steel Shortsword
itemsList["steel shortsword"] = {
	name = "Steel Shortsword",
	id = "steel shortsword",
	itemType = "weapon",
	subtype = "shortsword",
	weight = 8.0,
	health = 750,
	value = 40,
	weaponData = {
		minChop = 5,
		maxChop = 12,
		minSlash = 5,
		maxSlash = 12,
		minThrust = 7,
		maxThrust = 12,
		speed = 2.0,
		reach = 1.0
	},
	enchant = 4,
	skillId = 22,
	skillName = "Shortblade",
	material = "steel",
	hand = 1,
	normalWeapon = true
}
--steel wakizashi
itemsList["steel wakizashi"] = {
	name = "Steel Wakizashi",
	id = "steel wakizashi",
	itemType = "weapon",
	subtype = "wakizashi",
	weight = 10.0,
	health = 600,
	value = 48,
	weaponData = {
		minChop = 8,
		maxChop = 11,
		minSlash = 7,
		maxSlash = 12,
		minThrust = 2,
		maxThrust = 7,
		speed = 2.25,
		reach = 1.0
	},
	enchant = 4.5,
	skillId = 22,
	skillName = "Shortblade",
	material = "steel",
	hand = 1,
	normalWeapon = true
}
--silver shortsword
itemsList["silver shortsword"] = {
	name = "Silver Shortsword",
	id = "silver shortsword",
	itemType = "weapon",
	subtype = "shortsword",
	weight = 6.0,
	health = 570,
	value = 80,
	weaponData = {
		minChop = 5,
		maxChop = 10,
		minSlash = 5,
		maxSlash = 10,
		minThrust = 7,
		maxThrust = 10,
		speed = 2.0,
		reach = 1.0
	},
	enchant = 3.6,
	skillId = 22,
	skillName = "Shortblade",
	material = "silver",
	hand = 1,
}
--Dwarven shortsword
itemsList["dwarven shortsword"] = {
	name = "Dwarven Shortsword",
	id = "dwarven shortsword",
	itemType = "weapon",
	subtype = "shortsword",
	weight = 8.0,
	health = 1050,
	value = 300,
	weaponData = {
		minChop = 7,
		maxChop = 14,
		minSlash = 7,
		maxSlash = 14,
		minThrust = 8,
		maxThrust = 15,
		speed = 2.0,
		reach = 1.0
	},
	enchant = 4,
	skillId = 22,
	skillName = "Shortblade",
	material = "dwarven",
	hand = 1,
}
--Glass dagger
itemsList["glass dagger"] = {
	name = "Glass Dagger",
	id = "glass dagger",
	itemType = "weapon",
	subtype = "dagger",
	weight = 1.8,
	health = 300,
	value = 4000,
	weaponData = {
		minChop = 6,
		maxChop = 15,
		minSlash = 6,
		maxSlash = 15,
		minThrust = 6,
		maxThrust = 12,
		speed = 2.5,
		reach = 1.0
	},
	enchant = 1.2,
	skillId = 22,
	skillName = "Shortblade",
	material = "glass",
	hand = 1,
}
--Daedric Dagger
itemsList["daedric dagger"] = {
	name = "Daedric Dagger",
	id = "daedric dagger",
	itemType = "weapon",
	subtype = "dagger",
	weight = 9.0,
	health = 700,
	value = 10000,
	weaponData = {
		minChop = 8,
		maxChop = 12,
		minSlash = 8,
		maxSlash = 12,
		minThrust = 8,
		maxThrust = 12,
		speed = 2.5,
		reach = 1.0
	},
	enchant = 6,
	skillId = 22,
	skillName = "Shortblade",
	material = "daedric",
	hand = 1,
}
--Ebony Shortsword
itemsList["ebony shortsword"] = {
	name = "Ebony Shortsword",
	id = "ebony shortsword",
	itemType = "weapon",
	subtype = "shortsword",
	weight = 16.0,
	health = 1200,
	value = 10000,
	weaponData = {
		minChop = 10,
		maxChop = 20,
		minSlash = 10,
		maxSlash = 22,
		minThrust = 12,
		maxThrust = 25,
		speed = 2.0,
		reach = 1.0
	},
	enchant = 8,
	skillId = 22,
	skillName = "Shortblade",
	material = "ebony",
	hand = 1,
}
--Daedric Tanto
itemsList["daedric tanto"] = {
	name = "Daedric Tanto",
	id = "daedric tanto",
	itemType = "weapon",
	subtype = "tanto",
	weight = 12.0,
	health = 1100,
	value = 14000,
	weaponData = {
		minChop = 9,
		maxChop = 20,
		minSlash = 9,
		maxSlash = 20,
		minThrust = 9,
		maxThrust = 20,
		speed = 2.25,
		reach = 1.0
	},
	enchant = 6.6,
	skillId = 22,
	skillName = "Shortblade",
	material = "daedric",
	hand = 1,
}
--Daedric Shortsword
itemsList["daedric shortsword"] = {
	name = "Daedric Shortsword",
	id = "daedric shortsword",
	itemType = "weapon",
	subtype = "shortsword",
	weight = 24.0,
	health = 1500,
	value = 20000,
	weaponData = {
		minChop = 10,
		maxChop = 26,
		minSlash = 10,
		maxSlash = 26,
		minThrust = 12,
		maxThrust = 24,
		speed = 2.0,
		reach = 1.0
	},
	enchant = 12,
	skillId = 22,
	skillName = "Shortblade",
	material = "daedric",
	hand = 1,
}
--Daedric wakizashi
itemsList["daedric wakizashi"] = {
	name = "Daedric Wakizashi",
	id = "daedric wakizashi",
	itemType = "weapon",
	subtype = "wakizashi",
	weight = 30.0,
	health = 1100,
	value = 48000,
	weaponData = {
		minChop = 10,
		maxChop = 30,
		minSlash = 10,
		maxSlash = 25,
		minThrust = 7,
		maxThrust = 11,
		speed = 2.25,
		reach = 1.0
	},
	enchant = 23.5,
	skillId = 22,
	skillName = "Shortblade",
	material = "daedric",
	hand = 1,
}

--Iron Saber
itemsList["iron saber"] = {
	name = "Iron Saber",
	id = "iron saber",
	itemType = "weapon",
	subtype = "saber",
	weight = 15.0,
	health = 700,
	value = 24,
	weaponData = {
		minChop = 5,
		maxChop = 18,
		minSlash = 4,
		maxSlash = 16,
		minThrust = 1,
		maxThrust = 4,
		speed = 1.4,
		reach = 1.0
	},
	enchant = 5.5,
	skillId = 5,
	skillName = "Longblade",
	material = "iron",
	hand = 1,
	normalWeapon = true
}
--Iron Broadsword
itemsList["iron broadsword"] = {
	name = "Iron Broadsword",
	id = "iron broadsword",
	itemType = "weapon",
	subtype = "broadsword",
	weight = 12.0,
	health = 600,
	value = 30,
	weaponData = {
		minChop = 4,
		maxChop = 12,
		minSlash = 2,
		maxSlash = 12,
		minThrust = 2,
		maxThrust = 12,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 5,
	skillId = 5,
	skillName = "Longblade",
	material = "iron",
	hand = 1,
	normalWeapon = true
}
--Iron Longsword
itemsList["iron longsword"] = {
	name = "Iron Longsword",
	id = "iron longsword",
	itemType = "weapon",
	subtype = "longsword",
	weight = 20.0,
	health = 800,
	value = 40,
	weaponData = {
		minChop = 2,
		maxChop = 13,
		minSlash = 1,
		maxSlash = 18,
		minThrust = 4,
		maxThrust = 16,
		speed = 1.35,
		reach = 1.0
	},
	enchant = 6,
	skillId = 5,
	skillName = "Longblade",
	material = "iron",
	hand = 1,
	normalWeapon = true
}
--Steel Saber
itemsList["steel saber"] = {
	name = "Steel Saber",
	id = "steel saber",
	itemType = "weapon",
	subtype = "saber",
	weight = 15.0,
	health = 1050,
	value = 48,
	weaponData = {
		minChop = 5,
		maxChop = 20,
		minSlash = 3,
		maxSlash = 18,
		minThrust = 1,
		maxThrust = 5,
		speed = 1.4,
		reach = 1.0
	},
	enchant = 5.5,
	skillId = 5,
	skillName = "Longblade",
	material = "steel",
	hand = 1,
	normalWeapon = true
}
--Steel Broadsword
itemsList["steel broadsword"] = {
	name = "Steel Broadsword",
	id = "steel broadsword",
	itemType = "weapon",
	subtype = "broadsword",
	weight = 12.0,
	health = 900,
	value = 60,
	weaponData = {
		minChop = 4,
		maxChop = 14,
		minSlash = 4,
		maxSlash = 14,
		minThrust = 2,
		maxThrust = 14,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 5,
	skillId = 5,
	skillName = "Longblade",
	material = "steel",
	hand = 1,
	normalWeapon = true
}
--Imperial Broadsword
itemsList["imperial broadsword"] = {
	name = "Imperial Broadsword",
	id = "imperial broadsword",
	itemType = "weapon",
	subtype = "broadsword",
	weight = 12.0,
	health = 600,
	value = 60,
	weaponData = {
		minChop = 6,
		maxChop = 12,
		minSlash = 6,
		maxSlash = 12,
		minThrust = 4,
		maxThrust = 12,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 7,
	skillId = 5,
	skillName = "Longblade",
	--material = "steel",
	hand = 1,
	normalWeapon = true
}
--Steel Longsword
itemsList["steel longsword"] = {
	name = "Steel Longsword",
	id = "steel longsword",
	itemType = "weapon",
	subtype = "longsword",
	weight = 20.0,
	health = 900,
	value = 80,
	weaponData = {
		minChop = 2,
		maxChop = 14,
		minSlash = 1,
		maxSlash = 20,
		minThrust = 4,
		maxThrust = 18,
		speed = 1.35,
		reach = 1.0
	},
	enchant = 6,
	skillId = 5,
	skillName = "Longblade",
	material = "steel",
	hand = 1,
	normalWeapon = true
}
--Nordic Broadsword
itemsList["nordic broadsword"] = {
	name = "Nordic Broadsword",
	id = "nordic broadsword",
	itemType = "weapon",
	subtype = "broadsword",
	weight = 15.0,
	health = 800,
	value = 955,
	weaponData = {
		minChop = 6,
		maxChop = 18,
		minSlash = 2,
		maxSlash = 18,
		minThrust = 2,
		maxThrust = 18,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 6,
	skillId = 5,
	skillName = "Longblade",
	material = "nordic",
	hand = 1,
	normalWeapon = true
}
--Steel Katana
itemsList["steel katana"] = {
	name = "Steel Katana",
	id = "steel katana",
	itemType = "weapon",
	subtype = "katana",
	weight = 18.0,
	health = 1800,
	value = 100,
	weaponData = {
		minChop = 3,
		maxChop = 20,
		minSlash = 1,
		maxSlash = 18,
		minThrust = 1,
		maxThrust = 6,
		speed = 1.5,
		reach = 1.0
	},
	enchant = 6,
	skillId = 5,
	skillName = "Longblade",
	material = "steel",
	hand = 1,
	normalWeapon = true
}
--Silver Longsword
itemsList["silver longsword"] = {
	name = "Silver Longsword",
	id = "silver longsword",
	itemType = "weapon",
	subtype = "longsword",
	weight = 16.0,
	health = 640,
	value = 160,
	weaponData = {
		minChop = 2,
		maxChop = 14,
		minSlash = 1,
		maxSlash = 20,
		minThrust = 4,
		maxThrust = 18,
		speed = 1.35,
		reach = 1.0
	},
	enchant = 4.8,
	skillId = 5,
	skillName = "Longblade",
	material = "silver",
	hand = 1
}
--Glass Longsword
itemsList["glass longsword"] = {
	name = "Glass Longsword",
	id = "glass longsword",
	itemType = "weapon",
	subtype = "longsword",
	weight = 12.0,
	health = 480,
	value = 16000,
	weaponData = {
		minChop = 2,
		maxChop = 24,
		minSlash = 1,
		maxSlash = 33,
		minThrust = 4,
		maxThrust = 30,
		speed = 1.35,
		reach = 1.0
	},
	enchant = 3.6,
	skillId = 5,
	skillName = "Longblade",
	material = "glass",
	hand = 1
}
--Ebony Broadsword
itemsList["ebony broadsword"] = {
	name = "Ebony Broadsword",
	id = "ebony broadsword",
	itemType = "weapon",
	subtype = "broadsword",
	weight = 24.0,
	health = 1800,
	value = 15000,
	weaponData = {
		minChop = 4,
		maxChop = 26,
		minSlash = 2,
		maxSlash = 26,
		minThrust = 2,
		maxThrust = 26,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 10,
	skillId = 5,
	skillName = "Longblade",
	material = "ebony",
	hand = 1
}
--Ebony Longsword
itemsList["ebony longsword"] = {
	name = "Ebony Longsword",
	id = "ebony longsword",
	itemType = "weapon",
	subtype = "longsword",
	weight = 40.0,
	health = 1600,
	value = 20000,
	weaponData = {
		minChop = 2,
		maxChop = 27,
		minSlash = 1,
		maxSlash = 37,
		minThrust = 4,
		maxThrust = 34,
		speed = 1.35,
		reach = 1.0
	},
	enchant = 12,
	skillId = 5,
	skillName = "Longblade",
	material = "ebony",
	hand = 1
}
--Daedric Longsword
itemsList["daedric longsword"] = {
	name = "Daedric Longsword",
	id = "daedric longsword",
	itemType = "weapon",
	subtype = "longsword",
	weight = 60.0,
	health = 3200,
	value = 40000,
	weaponData = {
		minChop = 2,
		maxChop = 32,
		minSlash = 1,
		maxSlash = 44,
		minThrust = 4,
		maxThrust = 40,
		speed = 1.35,
		reach = 1.0
	},
	enchant = 18,
	skillId = 5,
	skillName = "Longblade",
	material = "daedric",
	hand = 1
}
--Daedric Katana
itemsList["daedric katana"] = {
	name = "Daedric Katana",
	id = "daedric katana",
	itemType = "weapon",
	subtype = "katana",
	weight = 54.0,
	health = 4800,
	value = 50000,
	weaponData = {
		minChop = 3,
		maxChop = 44,
		minSlash = 1,
		maxSlash = 40,
		minThrust = 1,
		maxThrust = 14,
		speed = 1.5,
		reach = 1.0
	},
	enchant = 18,
	skillId = 5,
	skillName = "Longblade",
	material = "daedric",
	hand = 1
}

--Iron Claymore
itemsList["iron claymore"] = {
	name = "Iron Claymore",
	id = "iron claymore",
	itemType = "weapon",
	subtype = "claymore",
	weight = 27.0,
	health = 1400,
	value = 80,
	weaponData = {
		minChop = 1,
		maxChop = 24,
		minSlash = 1,
		maxSlash = 21,
		minThrust = 1,
		maxThrust = 14,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 7,
	skillId = 5,
	skillName = "Longblade",
	material = "iron",
	hand = 2,
	normalWeapon = true
}
--Steel Claymore
itemsList["steel claymore"] = {
	name = "Steel Claymore",
	id = "steel claymore",
	itemType = "weapon",
	subtype = "claymore",
	weight = 27.0,
	health = 2100,
	value = 160,
	weaponData = {
		minChop = 1,
		maxChop = 27,
		minSlash = 1,
		maxSlash = 23,
		minThrust = 1,
		maxThrust = 16,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 7,
	skillId = 5,
	skillName = "Longblade",
	material = "steel",
	hand = 2,
	normalWeapon = true
}
--Nordic Claymore
itemsList["nordic claymore"] = {
	name = "Nordic Claymore",
	id = "nordic claymore",
	itemType = "weapon",
	subtype = "claymore",
	weight = 30.0,
	health = 1600,
	value = 180,
	weaponData = {
		minChop = 1,
		maxChop = 30,
		minSlash = 1,
		maxSlash = 25,
		minThrust = 1,
		maxThrust = 18,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 10,
	skillId = 5,
	skillName = "Longblade",
	material = "nordic",
	hand = 2,
	normalWeapon = true
}
--Steel Dai-katana
itemsList["steel dai-katana"] = {
	name = "Steel Dai-katana",
	id = "steel dai-katana",
	itemType = "weapon",
	subtype = "dai-katana",
	weight = 20.0,
	health = 2700,
	value = 240,
	weaponData = {
		minChop = 1,
		maxChop = 27,
		minSlash = 1,
		maxSlash = 23,
		minThrust = 1,
		maxThrust = 14,
		speed = 1.35,
		reach = 1.0
	},
	enchant = 7,
	skillId = 5,
	skillName = "Longblade",
	material = "steel",
	hand = 2,
	normalWeapon = true
}
--Silver Claymore
itemsList["silver claymore"] = {
	name = "Silver Claymore",
	id = "silver claymore",
	itemType = "weapon",
	subtype = "claymore",
	weight = 21.6,
	health = 1260,
	value = 320,
	weaponData = {
		minChop = 1,
		maxChop = 27,
		minSlash = 1,
		maxSlash = 23,
		minThrust = 1,
		maxThrust = 16,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 5.6,
	skillId = 5,
	skillName = "Longblade",
	material = "silver",
	hand = 2
}
--Dwarven Claymore
itemsList["dwarven claymore"] = {
	name = "Dwarven Claymore",
	id = "dwarven claymore",
	itemType = "weapon",
	subtype = "claymore",
	weight = 27.0,
	health = 3500,
	value = 1200,
	weaponData = {
		minChop = 1,
		maxChop = 33,
		minSlash = 1,
		maxSlash = 29,
		minThrust = 1,
		maxThrust = 20,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 7,
	skillId = 5,
	skillName = "Longblade",
	material = "dwarven",
	hand = 2
}
--Glass Claymore
itemsList["glass claymore"] = {
	name = "Glass Claymore",
	id = "glass claymore",
	itemType = "weapon",
	subtype = "claymore",
	weight = 16.2,
	health = 840,
	value = 32000,
	weaponData = {
		minChop = 1,
		maxChop = 45,
		minSlash = 1,
		maxSlash = 39,
		minThrust = 1,
		maxThrust = 27,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 4.2,
	skillId = 5,
	skillName = "Longblade",
	material = "glass",
	hand = 2
}
--Daedric Claymore
itemsList["daedric claymore"] = {
	name = "Daedric Claymore",
	id = "daedric claymore",
	itemType = "weapon",
	subtype = "claymore",
	weight = 81.0,
	health = 5600,
	value = 80000,
	weaponData = {
		minChop = 1,
		maxChop = 60,
		minSlash = 1,
		maxSlash = 52,
		minThrust = 1,
		maxThrust = 36,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 21,
	skillId = 5,
	skillName = "Longblade",
	material = "daedric",
	hand = 2
}
--Daedric Dai-katana
itemsList["daedric dai-katana"] = {
	name = "Daedric Dai-katana",
	id = "daedric dai-katana",
	itemType = "weapon",
	subtype = "dai-katana",
	weight = 60.0,
	health = 7200,
	value = 120000,
	weaponData = {
		minChop = 1,
		maxChop = 60,
		minSlash = 1,
		maxSlash = 52,
		minThrust = 1,
		maxThrust = 30,
		speed = 1.35,
		reach = 1.0
	},
	enchant = 21,
	skillId = 5,
	skillName = "Longblade",
	material = "daedric",
	hand = 2
}

--Chitin Spear
itemsList["chitin spear"] = {
	name = "Chitin Spear",
	id = "chitin spear",
	itemType = "weapon",
	subtype = "spear",
	weight = 7.0,
	health = 500,
	value = 13,
	weaponData = {
		minChop = 1,
		maxChop = 2,
		minSlash = 1,
		maxSlash = 2,
		minThrust = 5,
		maxThrust = 13,
		speed = 1.0,
		reach = 1.8
	},
	enchant = 2.5,
	skillId = 7,
	skillName = "Spear",
	material = "chitin",
	hand = 2,
	normalWeapon = true
}
--Iron Spear
itemsList["iron spear"] = {
	name = "Iron Spear",
	id = "iron spear",
	itemType = "weapon",
	subtype = "spear",
	weight = 14.0,
	health = 600,
	value = 20,
	weaponData = {
		minChop = 2,
		maxChop = 4,
		minSlash = 2,
		maxSlash = 4,
		minThrust = 6,
		maxThrust = 15,
		speed = 1.0,
		reach = 1.8
	},
	enchant = 5,
	skillId = 7,
	skillName = "Spear",
	material = "iron",
	hand = 2,
	normalWeapon = true
}
--Iron Long Spear
itemsList["Iron Long Spear"] = {
	name = "Iron Spear",
	id = "Iron Long Spear",
	itemType = "weapon",
	subtype = "spear",
	weight = 14.0,
	health = 400,
	value = 20,
	weaponData = {
		minChop = 1,
		maxChop = 3,
		minSlash = 1,
		maxSlash = 3,
		minThrust = 5,
		maxThrust = 20,
		speed = 1.0,
		reach = 1.8
	},
	enchant = 5,
	skillId = 7,
	skillName = "Spear",
	material = "iron",
	hand = 2,
	normalWeapon = true --?
}
--Steel Spear
itemsList["steel spear"] = {
	name = "Steel Spear",
	id = "steel spear",
	itemType = "weapon",
	subtype = "spear",
	weight = 14.0,
	health = 1000,
	value = 40,
	weaponData = {
		minChop = 2,
		maxChop = 5,
		minSlash = 2,
		maxSlash = 5,
		minThrust = 6,
		maxThrust = 17,
		speed = 1.0,
		reach = 1.8
	},
	enchant = 5,
	skillId = 7,
	skillName = "Spear",
	material = "steel",
	hand = 2,
	normalWeapon = true
}
--Iron Halberd
itemsList["iron halberd"] = {
	name = "Iron Halberd",
	id = "iron halberd",
	itemType = "weapon",
	subtype = "halberd",
	weight = 14.0,
	health = 700,
	value = 40,
	weaponData = {
		minChop = 1,
		maxChop = 3,
		minSlash = 1,
		maxSlash = 3,
		minThrust = 5,
		maxThrust = 20,
		speed = 1.0,
		reach = 1.8
	},
	enchant = 5,
	skillId = 7,
	skillName = "Spear",
	material = "iron",
	hand = 2,
	normalWeapon = true
}
--Steel Halberd
itemsList["steel halberd"] = {
	name = "Steel Halberd",
	id = "steel halberd",
	itemType = "weapon",
	subtype = "halberd",
	weight = 14.0,
	health = 1000,
	value = 80,
	weaponData = {
		minChop = 1,
		maxChop = 4,
		minSlash = 1,
		maxSlash = 4,
		minThrust = 5,
		maxThrust = 23,
		speed = 1.0,
		reach = 1.8
	},
	enchant = 5,
	skillId = 7,
	skillName = "Spear",
	material = "steel",
	hand = 2,
	normalWeapon = true
}
--Silver Spear
itemsList["silver spear"] = {
	name = "Silver Spear",
	id = "silver spear",
	itemType = "weapon",
	subtype = "spear",
	weight = 11.2,
	health = 500,
	value = 80,
	weaponData = {
		minChop = 1,
		maxChop = 4,
		minSlash = 1,
		maxSlash = 4,
		minThrust = 5,
		maxThrust = 23,
		speed = 1.0,
		reach = 1.8
	},
	enchant = 4,
	skillId = 7,
	skillName = "Spear",
	material = "silver",
	hand = 2
}
--Dwarven Spear
itemsList["dwarven spear"] = {
	name = "Dwarven Spear",
	id = "dwarven spear",
	itemType = "weapon",
	subtype = "spear",
	weight = 14.0,
	health = 1400,
	value = 300,
	weaponData = {
		minChop = 2,
		maxChop = 5,
		minSlash = 2,
		maxSlash = 5,
		minThrust = 5,
		maxThrust = 21,
		speed = 1.0,
		reach = 1.8
	},
	enchant = 5,
	skillId = 7,
	skillName = "Spear",
	material = "dwarven",
	hand = 2
}
--Dwarven Halberd
itemsList["dwarven halberd"] = {
	name = "Dwarven Halberd",
	id = "dwarven halberd",
	itemType = "weapon",
	subtype = "halberd",
	weight = 24.0,
	health = 1000,
	value = 600,
	weaponData = {
		minChop = 3,
		maxChop = 17,
		minSlash = 1,
		maxSlash = 13,
		minThrust = 5,
		maxThrust = 28,
		speed = 1.0,
		reach = 1.8
	},
	enchant = 7,
	skillId = 7,
	skillName = "Spear",
	material = "dwarven",
	hand = 2
}
--Ebony Spear
itemsList["ebony spear"] = {
	name = "Ebony Spear",
	id = "ebony spear",
	itemType = "weapon",
	subtype = "spear",
	weight = 28.0,
	health = 1200,
	value = 10000,
	weaponData = {
		minChop = 2,
		maxChop = 8,
		minSlash = 2,
		maxSlash = 8,
		minThrust = 5,
		maxThrust = 32,
		speed = 1.0,
		reach = 1.8
	},
	enchant = 10,
	skillId = 7,
	skillName = "Spear",
	material = "ebony",
	hand = 2
}
--Glass Halberd
itemsList["glass halberd"] = {
	name = "Glass Halberd",
	id = "glass halberd",
	itemType = "weapon",
	subtype = "halberd",
	weight = 8.4,
	health = 600,
	value = 16000,
	weaponData = {
		minChop = 1,
		maxChop = 6,
		minSlash = 1,
		maxSlash = 6,
		minThrust = 5,
		maxThrust = 38,
		speed = 1.0,
		reach = 1.8
	},
	enchant = 3,
	skillId = 7,
	skillName = "Spear",
	material = "glass",
	hand = 2
}
--Daedric Spear
itemsList["daedric spear"] = {
	name = "Daedric Spear",
	id = "daedric spear",
	itemType = "weapon",
	subtype = "spear",
	weight = 42.0,
	health = 1000,
	value = 20000,
	weaponData = {
		minChop = 2,
		maxChop = 9,
		minSlash = 2,
		maxSlash = 9,
		minThrust = 6,
		maxThrust = 40,
		speed = 1.0,
		reach = 1.8
	},
	enchant = 15,
	skillId = 7,
	skillName = "Spear",
	material = "daedric",
	hand = 2
}

--Chitin Short Bow
itemsList["chitin short bow"] = {
	name = "Chitin Short Bow",
	id = "chitin short bow",
	itemType = "weapon",
	subtype = "short bow",
	weight = 2.0,
	health = 500,
	value = 20,
	marksMin = 1,
	marksMax = 10,
	enchant = 1,
	skillId = 23,
	skillName = "Marksman",
	material = "chitin",
	hand = 2,
	normalWeapon = true
}
--Short Bow
itemsList["short bow"] = {
	name = "Short Bow",
	id = "short bow",
	itemType = "weapon",
	subtype = "short bow",
	weight = 4.0,
	health = 500,
	value = 60,
	marksMin = 1,
	marksMax = 15,
	enchant = 2,
	skillId = 23,
	skillName = "Marksman",
	--material = "wood", --?
	hand = 2,
	normalWeapon = true
}
--Long Bow
itemsList["long bow"] = {
	name = "Long Bow",
	id = "long bow",
	itemType = "weapon",
	subtype = "long bow",
	weight = 8.0,
	health = 550,
	value = 50,
	marksMin = 1,
	marksMax = 20,
	enchant = 3.5,
	skillId = 23,
	skillName = "Marksman",
	--material = "wood", --?
	hand = 2,
	normalWeapon = true
}
--Steel Longbow (Note: this one is "Longbow" rather than "Long Bow")
itemsList["steel longbow"] = {
	name = "Steel Longbow",
	id = "steel longbow",
	itemType = "weapon",
	subtype = "long bow",
	weight = 8.0,
	health = 600,
	value = 100,
	marksMin = 1,
	marksMax = 25,
	enchant = 3.5,
	skillId = 23,
	skillName = "Marksman",
	material = "steel",
	hand = 2,
	normalWeapon = true
}
--Bonemold Long Bow
itemsList["bonemold long bow"] = {
	name = "Bonemold Long Bow",
	id = "bonemold long bow",
	itemType = "weapon",
	subtype = "long bow",
	weight = 7.0,
	health = 700,
	value = 250,
	marksMin = 1,
	marksMax = 30,
	enchant = 40,
	skillId = 23,
	skillName = "Marksman",
	material = "bonemold",
	hand = 2,
	normalWeapon = true
}
--Daedric Long Bow
itemsList["daedric long bow"] = {
	name = "Daedric Long Bow",
	id = "daedric long bow",
	itemType = "weapon",
	subtype = "long bow",
	weight = 24.0,
	health = 1000,
	value = 50000,
	marksMin = 2,
	marksMax = 50,
	enchant = 10.5,
	skillId = 23,
	skillName = "Marksman",
	material = "daedric",
	hand = 2
}

--Corkbulb Arrow
itemsList["corkbulb arrow"] = {
	name = "Corkbulb Arrow",
	id = "corkbulb arrow",
	itemType = "weapon",
	subtype = "arrow",
	weight = 0.1,
	value = 1,
	marksMin = 1,
	marksMax = 1,
	skillId = 23,
	skillName = "Marksman",
	material = "corkbulb", --?
	normalWeapon = true
}
--Chitin Arrow
itemsList["chitin arrow"] = {
	name = "Chitin Arrow",
	id = "chitin arrow",
	itemType = "weapon",
	subtype = "arrow",
	weight = 0.1,
	value = 1,
	marksMin = 1,
	marksMax = 2,
	skillId = 23,
	skillName = "Marksman",
	material = "chitin",
	normalWeapon = true
}
--Iron Arrow
itemsList["iron arrow"] = {
	name = "Iron Arrow",
	id = "iron arrow",
	itemType = "weapon",
	subtype = "arrow",
	weight = 0.1,
	value = 1,
	marksMin = 1,
	marksMax = 3,
	skillId = 23,
	skillName = "Marksman",
	material = "iron",
	normalWeapon = true
}
--Silver Arrow
itemsList["silver arrow"] = {
	name = "Silver Arrow",
	id = "silver arrow",
	itemType = "weapon",
	subtype = "arrow",
	weight = 0.1,
	value = 3,
	marksMin = 1,
	marksMax = 3,
	skillId = 23,
	skillName = "Marksman",
	material = "silver"
}
--Bonemold Arrow
itemsList["bonemold arrow"] = {
	name = "Bonemold Arrow",
	id = "bonemold arrow",
	itemType = "weapon",
	subtype = "arrow",
	weight = 0.15,
	value = 2,
	marksMin = 1,
	marksMax = 4,
	skillId = 23,
	skillName = "Marksman",
	material = "bonemold",
	normalWeapon = true
}
--Steel Arrow
itemsList["steel arrow"] = {
	name = "Steel Arrow",
	id = "steel arrow",
	itemType = "weapon",
	subtype = "arrow",
	weight = 0.1,
	value = 2,
	marksMin = 1,
	marksMax = 4,
	skillId = 23,
	skillName = "Marksman",
	material = "steel",
	normalWeapon = true
}
--Glass Arrow
itemsList["glass arrow"] = {
	name = "Glass Arrow",
	id = "glass arrow",
	itemType = "weapon",
	subtype = "arrow",
	weight = 0.15,
	value = 8,
	marksMin = 1,
	marksMax = 6,
	skillId = 23,
	skillName = "Marksman",
	material = "glass"
}
--Ebony Arrow
itemsList["ebony arrow"] = {
	name = "Ebony Arrow",
	id = "ebony arrow",
	itemType = "weapon",
	subtype = "arrow",
	weight = 0.2,
	value = 10,
	marksMin = 5,
	marksMax = 10,
	skillId = 23,
	skillName = "Marksman",
	material = "ebony"
}
--Daedric Arrow
itemsList["daedric arrow"] = {
	name = "Daedric Arrow",
	id = "daedric arrow",
	itemType = "weapon",
	subtype = "arrow",
	weight = 0.3,
	value = 20,
	marksMin = 10,
	marksMax = 15,
	skillId = 23,
	skillName = "Marksman",
	material = "daedric"
}

--Steel Crossbow
itemsList["steel crossbow"] = {
	name = "Steel Crossbow",
	id = "steel crossbow",
	itemType = "weapon",
	subtype = "crossbow",
	weight = 10.0,
	health = 550,
	value = 160,
	marksMin = 20,
	marksMax = 20,
	enchant = 5,
	skillId = 23,
	skillName = "Marksman",
	material = "steel",
	hand = 2,
	normalWeapon = true
}
--Dwarven Crossbow
itemsList["dwarven crossbow"] = {
	name = "Dwarven Crossbow",
	id = "dwarven crossbow",
	itemType = "weapon",
	subtype = "crossbow",
	weight = 10.0,
	health = 750,
	value = 1200,
	marksMin = 30,
	marksMax = 30,
	enchant = 5,
	skillId = 23,
	skillName = "Marksman",
	material = "dwarven",
	hand = 2
}

--Corkbulb Bolt
itemsList["corkbulb bolt"] = {
	name = "Corkbulb Bolt",
	id = "corkbulb bolt",
	itemType = "weapon",
	subtype = "bolt",
	weight = 0.1,
	value = 5,
	marksMin = 1,
	marksMax = 1,
	skillId = 23,
	skillName = "Marksman",
	material = "corkbulb", --?
	normalWeapon = true
}
--Iron Bolt
itemsList["iron bolt"] = {
	name = "Iron Bolt",
	id = "iron bolt",
	itemType = "weapon",
	subtype = "bolt",
	weight = 0.1,
	value = 1,
	marksMin = 2,
	marksMax = 3,
	skillId = 23,
	skillName = "Marksman",
	material = "iron",
	normalWeapon = true
}
--Steel Bolt
itemsList["steel bolt"] = {
	name = "Steel Bolt",
	id = "steel bolt",
	itemType = "weapon",
	subtype = "bolt",
	weight = 0.1,
	value = 2,
	marksMin = 2,
	marksMax = 4,
	skillId = 23,
	skillName = "Marksman",
	material = "steel",
	normalWeapon = true
}
--Silver Bolt
itemsList["silver bolt"] = {
	name = "Silver Bolt",
	id = "silver bolt",
	itemType = "weapon",
	subtype = "bolt",
	weight = 0.1,
	value = 8,
	marksMin = 3,
	marksMax = 3,
	skillId = 23,
	skillName = "Marksman",
	material = "silver"
}
--Bonemold Bolt
itemsList["bonemold bolt"] = {
	name = "Bonemold Bolt",
	id = "bonemold bolt",
	itemType = "weapon",
	subtype = "bolt",
	weight = 0.15,
	value = 2,
	marksMin = 3,
	marksMax = 4,
	skillId = 23,
	skillName = "Marksman",
	material = "bonemold",
	normalWeapon = true
}
--Orcish Bolt
itemsList["orcish bolt"] = {
	name = "Orcish Bolt",
	id = "orcish bolt",
	itemType = "weapon",
	subtype = "bolt",
	weight = 0.15,
	value = 4,
	marksMin = 1,
	marksMax = 6,
	skillId = 23,
	skillName = "Marksman",
	material = "orcish"
}

--Iron Throwing Knife
itemsList["iron throwing knife"] = {
	name = "Iron Throwing Knife",
	id = "iron throwing knife",
	itemType = "weapon",
	subtype = "throwing knife",
	weight = 0.3,
	value = 3,
	marksMin = 1,
	marksMax = 3,
	skillId = 23,
	skillName = "Marksman",
	material = "iron",
	normalWeapon = true,
	hand = 1
}
--Chitin Throwing Star
itemsList["chitin throwing star"] = {
	name = "Chitin Throwing Star",
	id = "chitin throwing star",
	itemType = "weapon",
	subtype = "throwing star",
	weight = 0.1,
	value = 3,
	marksMin = 2,
	marksMax = 3,
	skillId = 23,
	skillName = "Marksman",
	material = "chitin",
	normalWeapon = true,
	hand = 1
}
--Steel Throwing Knife
itemsList["steel throwing knife"] = {
	name = "Steel Throwing Knife",
	id = "steel throwing knife",
	itemType = "weapon",
	subtype = "throwing knife",
	weight = 0.3,
	value = 4,
	marksMin = 1,
	marksMax = 4,
	skillId = 23,
	skillName = "Marksman",
	material = "steel",
	normalWeapon = true,
	hand = 1
}
--Steel Dart
itemsList["steel dart"] = {
	name = "Steel Dart",
	id = "steel dart",
	itemType = "weapon",
	subtype = "dart",
	weight = 0.2,
	value = 6,
	marksMin = 2,
	marksMax = 5,
	skillId = 23,
	skillName = "Marksman",
	material = "steel",
	normalWeapon = true,
	hand = 1
}
--Steel Throwing Star
itemsList["steel throwing star"] = {
	name = "Steel Throwing Star",
	id = "steel throwing star",
	itemType = "weapon",
	subtype = "throwing star",
	weight = 0.1,
	value = 3,
	marksMin = 2,
	marksMax = 5,
	skillId = 23,
	skillName = "Marksman",
	material = "steel",
	normalWeapon = true,
	hand = 1
}
--Silver Dart
itemsList["silver dart"] = {
	name = "Silver Dart",
	id = "silver dart",
	itemType = "weapon",
	subtype = "dart",
	weight = 0.2,
	value = 6,
	marksMin = 2,
	marksMax = 5,
	skillId = 23,
	skillName = "Marksman",
	material = "silver",
	hand = 1
}
--Silver Throwing Star
itemsList["silver throwing star"] = {
	name = "Silver Throwing Star",
	id = "silver throwing star",
	itemType = "weapon",
	subtype = "throwing star",
	weight = 0.2,
	value = 16,
	marksMin = 2,
	marksMax = 5,
	skillId = 23,
	skillName = "Marksman",
	material = "silver",
	hand = 1
}
--Glass Throwing Knife
itemsList["glass throwing knife"] = {
	name = "Glass Throwing Knife",
	id = "glass throwing knife",
	itemType = "weapon",
	subtype = "throwing knife",
	weight = 0.2,
	value = 25,
	marksMin = 1,
	marksMax = 6,
	skillId = 23,
	skillName = "Marksman",
	material = "glass",
	hand = 1
}
--Glass Throwing Star
itemsList["glass throwing star"] = {
	name = "Glass Throwing Star",
	id = "glass throwing star",
	itemType = "weapon",
	subtype = "throwing star",
	weight = 0.1,
	value = 20,
	marksMin = 2,
	marksMax = 9,
	skillId = 23,
	skillName = "Marksman",
	material = "glass",
	hand = 1
}
--Ebony Dart
itemsList["ebony dart"] = {
	name = "Ebony Dart",
	id = "ebony dart",
	itemType = "weapon",
	subtype = "dart",
	weight = 0.4,
	value = 2000,
	marksMin = 2,
	marksMax = 10,
	skillId = 23,
	skillName = "Marksman",
	material = "ebony",
	hand = 1
}
--Ebony Throwing Star
itemsList["ebony throwing star"] = {
	name = "Ebony Throwing Star",
	id = "ebony throwing star",
	itemType = "weapon",
	subtype = "throwing star",
	weight = 0.2,
	value = 2000,
	marksMin = 2,
	marksMax = 10,
	skillId = 23,
	skillName = "Marksman",
	material = "ebony",
	hand = 1
}
--Daedric Dart
itemsList["daedric dart"] = {
	name = "Daedric Dart",
	id = "daedric dart",
	itemType = "weapon",
	subtype = "dart",
	weight = 0.4,
	value = 4000,
	marksMin = 2,
	marksMax = 12,
	skillId = 23,
	skillName = "Marksman",
	material = "daedric",
	hand = 1
}

-- Base Weapons - Tribunal
--Admantium Axe (Note: This is written as "Admantium" rather than "Adamantium")
itemsList["adamantium_axe"] = {
	name = "Admantium Axe",
	id = "adamantium_axe",
	itemType = "weapon",
	subtype = "battle axe",
	weight = 35.0,
	health = 3000,
	value = 5000,
	weaponData = {
		minChop = 1,
		maxChop = 60,
		minSlash = 1,
		maxSlash = 40,
		minThrust = 1,
		maxThrust = 6,
		speed = 1.0,
		reach = 1.0
	},
	enchant = 10,
	skillId = 6,
	skillName = "Axe",
	material = "adamantium",
	hand = 2,
	normalWeapon = true
}
--Adamantium Claymore
itemsList["adamantium_claymore"] = {
	name = "Adamantium Claymore",
	id = "adamantium_claymore",
	itemType = "weapon",
	subtype = "claymore",
	weight = 50.0,
	health = 4000,
	value = 10000,
	weaponData = {
		minChop = 10,
		maxChop = 40,
		minSlash = 10,
		maxSlash = 40,
		minThrust = 10,
		maxThrust = 30,
		speed = 1.0,
		reach = 1.0
	},
	enchant = 15,
	skillId = 5,
	skillName = "Longblade",
	material = "adamantium",
	hand = 2,
	normalWeapon = true
}
--Adamantium Mace
itemsList["adamantium_mace"] = {
	name = "Adamantium Mace",
	id = "adamantium_mace",
	itemType = "weapon",
	subtype = "mace",
	weight = 23.0,
	health = 2800,
	value = 1000,
	weaponData = {
		minChop = 5,
		maxChop = 20,
		minSlash = 5,
		maxSlash = 20,
		minThrust = 1,
		maxThrust = 5,
		speed = 1.0,
		reach = 1.0
	},
	enchant = 10,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "adamantium",
	hand = 1,
	normalWeapon = true
}
--Adamantium Shortsword
itemsList["adamantium_shortsword"] = {
	name = "Adamantium Shortsword",
	id = "adamantium_shortsword",
	itemType = "weapon",
	subtype = "shortsword",
	weight = 20.0,
	health = 900,
	value = 1000,
	weaponData = {
		minChop = 7,
		maxChop = 15,
		minSlash = 7,
		maxSlash = 15,
		minThrust = 7,
		maxThrust = 20,
		speed = 2.0,
		reach = 1.0
	},
	enchant = 6,
	skillId = 22,
	skillName = "Shortblade",
	material = "adamantium",
	hand = 1,
	normalWeapon = true
}
--Adamantium Spear
itemsList["adamantium_spear"] = {
	name = "Adamantium Spear",
	id = "adamantium_spear",
	itemType = "weapon",
	subtype = "spear",
	weight = 25.0,
	health = 900,
	value = 5000,
	weaponData = {
		minChop = 1,
		maxChop = 10,
		minSlash = 1,
		maxSlash = 10,
		minThrust = 10,
		maxThrust = 30,
		speed = 1.0,
		reach = 1.0
	},
	enchant = 7,
	skillId = 22,
	skillName = "Spear",
	material = "adamantium",
	hand = 2,
	normalWeapon = true
}

--Ebony Scimitar
itemsList["Ebony Scimitar"] = {
	name = "Ebony Scimitar",
	id = "Ebony Scimitar", --Note: id is actually formatted like this
	itemType = "weapon",
	subtype = "saber", --I'm not making a new subtype just for one weapon...
	weight = 40.0,
	health = 3000,
	value = 15000,
	weaponData = {
		minChop = 2,
		maxChop = 27,
		minSlash = 1,
		maxSlash = 43,
		minThrust = 3,
		maxThrust = 34,
		speed = 1.35,
		reach = 1.0
	},
	enchant = 80,
	skillId = 5,
	skillName = "Longblade",
	material = "ebony",
	hand = 1
}

--Goblin Sword
itemsList["goblin_sword"] = {
	name = "Goblin Sword",
	id = "goblin_sword",
	itemType = "weapon",
	subtype = "shortsword",
	weight = 20.0,
	health = 250,
	value = 100,
	weaponData = {
		minChop = 10,
		maxChop = 35,
		minSlash = 10,
		maxSlash = 35,
		minThrust = 10,
		maxThrust = 35,
		speed = 1.5,
		reach = 1.0
	},
	enchant = 5,
	skillId = 22,
	skillName = "Shortblade",
	--material = "goblin", --?
	hand = 1
}
--Goblin Club
itemsList["goblin_club"] = {
	name = "Goblin Club",
	id = "goblin_club",
	itemType = "weapon",
	subtype = "club",
	weight = 25.0,
	health = 500,
	value = 3000,
	weaponData = {
		minChop = 1,
		maxChop = 60,
		minSlash = 1,
		maxSlash = 60,
		minThrust = 1,
		maxThrust = 5,
		speed = 1.5,
		reach = 1.0
	},
	enchant = 10,
	skillId = 4,
	skillName = "Bluntweapon",
	--material = "goblin", --?
	hand = 1
}

--A Carved Ebony Dart
itemsList["ebony dart_db_unique"] = {
	name = "A Carved Ebony Dart",
	id = "ebony dart_db_unique",
	itemType = "weapon",
	subtype = "dart",
	weight = 0.4,
	value = 2000,
	marksMin = 2,
	marksMax = 10,
	marksSpeed = 3,
	enchant = 3,
	skillId = 23,
	skillName = "Marksman",
	material = "ebony",
	hand = 1
}
--Dwarven Dart
itemsList["centurion_projectile_dart"] = {
	name = "Dwarven Dart",
	id = "centurion_projectile_dart",
	itemType = "weapon",
	subtype = "dart",
	weight = 0.2,
	value = 10,
	marksMin = 20,
	marksMax = 50,
	marksSpeed = 1.5,
	enchant = 10,
	skillId = 23,
	skillName = "Marksman",
	material = "dwarven", --?
	hand = 1
}
--Spite Dart
itemsList["spite_dart"] = {
	name = "Spite Dart",
	id = "spite_dart",
	itemType = "weapon",
	subtype = "dart",
	weight = 0.2,
	value = 60,
	marksMin = 2,
	marksMax = 5,
	marksSpeed = 1.5,
	enchant = 1.2,
	skillId = 23,
	skillName = "Marksman",
	--material = "PUREST SPITE",
	hand = 1
}
--Spring Dart
itemsList["spring dart"] = {
	name = "Spring Dart",
	id = "spring dart", --Note: This and Fine Spring Dart use this style of formatting
	itemType = "weapon",
	subtype = "dart",
	weight = 0.2,
	value = 6,
	marksMin = 50,
	marksMax = 100,
	marksSpeed = 1.0,
	enchant = 1.5,
	skillId = 23,
	skillName = "Marksman",
	--material = "steel", --?
	hand = 1
}
--Fine Spring Dart
itemsList["fine spring dart"] = {
	name = "Fine Spring Dart",
	id = "fine spring dart",
	itemType = "weapon",
	subtype = "dart",
	weight = 0.2,
	value = 6,
	marksMin = 55,
	marksMax = 110,
	marksSpeed = 1.0,
	enchant = 1.5,
	skillId = 23,
	skillName = "Marksman",
	--material = "steel", --?
	hand = 1
}

-- Base Weapons - Bloodmoon
--Huntsman Axe
itemsList["BM huntsman axe"] = {
	name = "Huntsman Axe",
	id = "BM huntsman axe",
	itemType = "weapon",
	subtype = "war axe",
	weight = 24.0,
	health = 800,
	value = 100,
	weaponData = {
		minChop = 1,
		maxChop = 20,
		minSlash = 1,
		maxSlash = 15,
		minThrust = 1,
		maxThrust = 3,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 5,
	skillId = 6,
	skillName = "Axe",
	--material = "steel", --?
	hand = 1,
	normalWeapon = true
}
--Huntsman War Axe
itemsList["BM huntsman war axe"] = {
	name = "Huntsman War Axe",
	id = "BM huntsman war axe",
	itemType = "weapon",
	subtype = "war axe",
	weight = 32.0,
	health = 800,
	value = 125,
	weaponData = {
		minChop = 1,
		maxChop = 30,
		minSlash = 1,
		maxSlash = 20,
		minThrust = 1,
		maxThrust = 5,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 5,
	skillId = 6,
	skillName = "Axe",
	--material = "steel", --?
	hand = 1,
	normalWeapon = true
}
--Stalhrim War Axe
itemsList["BM ice war axe"] = {
	name = "Stalhrim War Axe",
	id = "BM ice war axe",
	itemType = "weapon",
	subtype = "war axe",
	weight = 35.0,
	health = 2000,
	value = 50000,
	weaponData = {
		minChop = 1,
		maxChop = 40,
		minSlash = 1,
		maxSlash = 30,
		minThrust = 1,
		maxThrust = 5,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 25,
	skillId = 6,
	skillName = "Axe",
	material = "stalhrim",
	hand = 1
}
--Nordic Silver Axe
itemsList["BM nordic silver axe"] = {
	name = "Nordic Silver Axe",
	id = "BM nordic silver axe",
	itemType = "weapon",
	subtype = "war axe",
	weight = 32.0,
	health = 2000,
	value = 1000,
	weaponData = {
		minChop = 1,
		maxChop = 35,
		minSlash = 1,
		maxSlash = 22,
		minThrust = 1,
		maxThrust = 5,
		speed = 1.25,
		reach = 1.0
	},
	enchant = 6.5,
	skillId = 6,
	skillName = "Axe",
	material = "silver", --Or nordic?
	hand = 1
}
--Nordic Silver Battleaxe
itemsList["BM nordic silver battleaxe"] = {
	name = "Nordic Silver Battleaxe",
	id = "BM nordic silver battleaxe",
	itemType = "weapon",
	subtype = "battle axe",
	weight = 30.0,
	health = 2000,
	value = 1000,
	weaponData = {
		minChop = 5,
		maxChop = 50,
		minSlash = 6,
		maxSlash = 35,
		minThrust = 1,
		maxThrust = 5,
		speed = 1.0,
		reach = 1.0
	},
	enchant = 10,
	skillId = 6,
	skillName = "Axe",
	material = "silver", --Or nordic?
	hand = 2
}

--Huntsman Bolt
itemsList["BM huntsmanbolt"] = {
	name = "Huntsman Bolt",
	id = "BM huntsmanbolt",
	itemType = "weapon",
	subtype = "bolt",
	weight = 0.1,
	value = 5,
	marksMin = 3,
	marksMax = 3,
	skillId = 23,
	skillName = "Marksman",
	--material = "steel", --?
	normalWeapon = true
}

--Stalhrim Mace
itemsList["BM ice mace"] = {
	name = "Stalhrim Mace",
	id = "BM ice mace",
	itemType = "weapon",
	subtype = "mace",
	weight = 65.0,
	health = 9000,
	value = 40000,
	weaponData = {
		minChop = 5,
		maxChop = 45,
		minSlash = 5,
		maxSlash = 45,
		minThrust = 2,
		maxThrust = 6,
		speed = 1.3,
		reach = 1.1
	},
	enchant = 20,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "stalhrim",
	hand = 1
}
--Nordic Silver Mace
itemsList["BM nordic silver mace"] = {
	name = "Nordic Silver Mace",
	id = "BM nordic silver mace",
	itemType = "weapon",
	subtype = "mace",
	weight = 30.0,
	health = 3300,
	value = 1000,
	weaponData = {
		minChop = 5,
		maxChop = 20,
		minSlash = 5,
		maxSlash = 20,
		minThrust = 1,
		maxThrust = 5,
		speed = 1.3,
		reach = 1
	},
	enchant = 7,
	skillId = 4,
	skillName = "Bluntweapon",
	material = "silver", --Or nordic?
	hand = 1
}

--Huntsman Crossbow
itemsList["BM huntsman crossbow"] = {
	name = "Huntsman Crossbow",
	id = "BM huntsman crossbow",
	itemType = "weapon",
	subtype = "crossbow",
	weight = 10.0,
	health = 650,
	value = 500,
	marksMin = 25,
	marksMax = 25,
	enchant = 10,
	skillId = 23,
	skillName = "Marksman",
	--material = "steel", --?
	hand = 2,
	normalWeapon = true
}

--Huntsman Longsword
itemsList["BM huntsman longsword"] = {
	name = "Huntsman Longsword",
	id = "BM huntsman longsword",
	itemType = "weapon",
	subtype = "longsword",
	weight = 18.0,
	health = 800,
	value = 500,
	weaponData = {
		minChop = 1,
		maxChop = 15,
		minSlash = 1,
		maxSlash = 18,
		minThrust = 1,
		maxThrust = 15,
		speed = 1.35,
		reach = 1.0
	},
	enchant = 5,
	skillId = 5,
	skillName = "Longblade",
	--material = "iron", --?
	hand = 1,
	normalWeapon = true
}
--Stalhrim Longsword
itemsList["BM ice longsword"] = {
	name = "Stalhrim Longsword",
	id = "BM ice longsword",
	itemType = "weapon",
	subtype = "longsword",
	weight = 70.0,
	health = 2500,
	value = 65000,
	weaponData = {
		minChop = 4,
		maxChop = 40,
		minSlash = 4,
		maxSlash = 55,
		minThrust = 5,
		maxThrust = 50,
		speed = 1.5,
		reach = 1.0
	},
	enchant = 8,
	skillId = 5,
	skillName = "Longblade",
	material = "stalhrim",
	hand = 1
}
--Nordic Silver Longsword
itemsList["BM nordic silver longsword"] = {
	name = "Nordic Silver Longsword",
	id = "BM nordic silver longsword",
	itemType = "weapon",
	subtype = "longsword",
	weight = 20.0,
	health = 800,
	value = 1000,
	weaponData = {
		minChop = 9,
		maxChop = 28,
		minSlash = 9,
		maxSlash = 20,
		minThrust = 9,
		maxThrust = 20,
		speed = 1.35,
		reach = 1.0
	},
	enchant = 8,
	skillId = 5,
	skillName = "Longblade",
	material = "silver", --or nordic?
	hand = 1
}
--Riekling Blade
itemsList["BM riekling sword"] = {
	name = "Riekling Blade",
	id = "BM riekling sword",
	itemType = "weapon",
	subtype = "longsword",
	weight = 20.0,
	health = 500,
	value = 250,
	weaponData = {
		minChop = 13,
		maxChop = 28,
		minSlash = 18,
		maxSlash = 30,
		minThrust = 11,
		maxThrust = 23,
		speed = 1,
		reach = 1
	},
	enchant = 3.5,
	skillId = 5,
	skillName = "Longblade",
	--material = "iron", --?
	hand = 1,
	normalWeapon = true
}
--Rusted Riekling Blade
itemsList["BM riekling sword_rusted"] = {
	name = "Rusted Riekling Blade",
	id = "BM riekling sword_rusted",
	itemType = "weapon",
	subtype = "longsword",
	weight = 20.0,
	health = 500,
	value = 150,
	weaponData = {
		minChop = 10,
		maxChop = 18,
		minSlash = 12,
		maxSlash = 20,
		minThrust = 4,
		maxThrust = 13,
		speed = 1,
		reach = 1
	},
	enchant = 3.5,
	skillId = 5,
	skillName = "Longblade",
	--material = "iron", --?
	hand = 1,
	normalWeapon = true
}

--Nordic Silver Claymore
itemsList["BM nordic silver claymore"] = {
	name = "Nordic Silver Claymore",
	id = "BM nordic silver claymore",
	itemType = "weapon",
	subtype = "longsword",
	weight = 25.0,
	health = 2000,
	value = 1000,
	weaponData = {
		minChop = 6,
		maxChop = 35,
		minSlash = 6,
		maxSlash = 30,
		minThrust = 6,
		maxThrust = 24,
		speed = 1.25,
		reach = 1
	},
	enchant = 15,
	skillId = 5,
	skillName = "Longblade",
	material = "silver", --or nordic
	hand = 2
}

--Stalhrim Dagger
itemsList["BM ice dagger"] = {
	name = "Stalhrim Dagger",
	id = "BM ice dagger",
	itemType = "weapon",
	subtype = "dagger",
	weight = 5.0,
	health = 800,
	value = 15000,
	weaponData = {
		minChop = 10,
		maxChop = 16,
		minSlash = 10,
		maxSlash = 16,
		minThrust = 10,
		maxThrust = 16,
		speed = 2.5,
		reach = 1.0
	},
	enchant = 6.5,
	skillId = 22,
	skillName = "Shortblade",
	material = "stalhrim",
	hand = 1
}
--Nordic Silver Dagger
itemsList["BM nordic silver dagger"] = {
	name = "Nordic Silver Dagger",
	id = "BM nordic silver dagger",
	itemType = "weapon",
	subtype = "dagger",
	weight = 10.0,
	health = 550,
	value = 1000,
	weaponData = {
		minChop = 5,
		maxChop = 10,
		minSlash = 5,
		maxSlash = 10,
		minThrust = 7,
		maxThrust = 15,
		speed = 2.5,
		reach = 1.0
	},
	enchant = 7,
	skillId = 22,
	skillName = "Shortblade",
	material = "silver", --or nordic
	hand = 1
}
--Nordic Silver Shortsword
itemsList["BM nordic silver shortsword"] = {
	name = "Nordic Silver Shortsword",
	id = "BM nordic silver shortsword",
	itemType = "weapon",
	subtype = "shortsword",
	weight = 15.0,
	health = 500,
	value = 1000,
	weaponData = {
		minChop = 6,
		maxChop = 12,
		minSlash = 6,
		maxSlash = 12,
		minThrust = 9,
		maxThrust = 15,
		speed = 2,
		reach = 1
	},
	enchant = 7,
	skillId = 22,
	skillName = "Shortblade",
	material = "silver", --or nordic
	hand = 1
}
--Riekling Lance
itemsList["BM riekling lance"] = {
	name = "Riekling Lance",
	id = "BM riekling lance",
	itemType = "weapon",
	subtype = "shortsword",
	weight = 10.0,
	health = 300,
	value = 100,
	weaponData = {
		minChop = 1,
		maxChop = 10,
		minSlash = 1,
		maxSlash = 15,
		minThrust = 13,
		maxThrust = 25,
		speed = 1.3,
		reach = 1
	},
	enchant = 8,
	skillId = 22,
	skillName = "Shortblade",
	--material = "iron", --?
	hand = 1
}

--Huntsman Spear
itemsList["BM huntsman spear"] = {
	name = "Huntsman Spear",
	id = "BM huntsman spear",
	itemType = "weapon",
	subtype = "spear",
	weight = 15.0,
	health = 900,
	value = 500,
	weaponData = {
		minChop = 1,
		maxChop = 7,
		minSlash = 1,
		maxSlash = 7,
		minThrust = 1,
		maxThrust = 22,
		speed = 1.0,
		reach = 1.8
	},
	enchant = 8.5,
	skillId = 7,
	skillName = "Spear",
	--material = "iron", --?
	hand = 2,
	normalWeapon = true
}

-- *GENERIC MAGIC WEAPONS*

-- *SPECIAL MAGIC WEAPONS*

-- *UNIQUE WEAPONS*

-- *WEAPON ARTIFACTS*

-- *QUEST ITEMS WEAPONS*?

-- **ARMOR**
-- *BASE ARMOR*
-- Morrowind Base Armor
-- Boiled Netch Leather Cuirass
itemsList["netch_leather_boiled_cuirass"] = {
	name = "Boiled Netch Leather Cuirass",
	id = "netch_leather_boiled_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 12,
	health = 210,
	value = 47,
	rating = 7,
	enchant = 6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather" --?
}
-- Chitin Cuirass
itemsList["chitin cuirass"] = {
	name = "Chitin Cuirass",
	id = "chitin cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 6,
	health = 300,
	value = 45,
	rating = 10,
	enchant = 10,
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin"
}
-- Glass Cuirass
itemsList["glass_cuirass"] = {
	name = "Glass Cuirass",
	id = "glass_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 18,
	health = 1500,
	value = 28000,
	rating = 50,
	enchant = 12,
	skillId = 21,
	skillName = "Lightarmor",
	material = "glass"
}
-- Imperial Newtscale Cuirass
itemsList["newtscale_cuirass"] = {
	name = "Imperial Newtscale Cuirass",
	id = "newtscale_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 9,
	health = 300,
	value = 100,
	rating = 10,
	enchant = 10,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather" --?
}
-- Imperial Studded Leather Cuiras (Note: Misspelled ingame)
itemsList["imperial_studded_cuirass"] = {
	name = "Imperial Studded Leather Cuiras",
	id = "imperial_studded_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 9,
	health = 300,
	value = 65,
	rating = 10,
	enchant = 6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather"
}
-- Netch Leather Cuirass
itemsList["netch_leather_cuirass"] = {
	name = "Netch Leather Cuirass",
	id = "netch_leather_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 12,
	health = 150,
	value = 35,
	rating = 5,
	enchant = 6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather"
}
-- Nordic Bearskin Cuirass
itemsList["fur_bearskin_cuirass"] = {
	name = "Nordic Bearskin Cuirass",
	id = "fur_bearskin_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 9,
	health = 150,
	value = 35,
	rating = 5,
	enchant = 6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather" --?
}
-- Nordic Fur Cuirass
itemsList["fur_cuirass"] = {
	name = "Nordic Fur Cuirass",
	id = "fur_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 9,
	health = 150,
	value = 35,
	rating = 5,
	enchant = 6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "fur" --?
}

-- Boiled Netch Leather Helm
itemsList["netch_leather_boiled_helm"] = {
	name = "Boiled Netch Leather Helm",
	id = "netch_leather_boiled_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 3,
	health = 70,
	value = 17,
	rating = 7,
	enchant = 7.5,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather" --?
}
-- Chitin Helm
itemsList["chitin helm"] = {
	name = "Chitin Helm",
	id = "chitin helm",
	itemType = "armor",
	subtype = "helm",
	weight = 1,
	health = 100,
	value = 19,
	rating = 10,
	enchant = 12.5,
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin"
}
-- Chitin Mask Helm
itemsList["chitin_mask_helm"] = {
	name = "Chitin Mask Helm",
	id = "chitin_mask_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 1,
	health = 100,
	value = 19,
	rating = 10,
	enchant = 12.5,
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin"
}
-- Colovian Fur Helm
itemsList["fur_colovian_helm"] = {
	name = "Colovian Fur Helm",
	id = "fur_colovian_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 2,
	health = 70,
	value = 25,
	rating = 7,
	enchant = 7.5,
	skillId = 21,
	skillName = "Lightarmor",
	material = "fur",
	canBeast = true
}
-- Glass Helm
itemsList["glass_helm"] = {
	name = "Glass Helm",
	id = "glass_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 3,
	health = 500,
	value = 12000,
	rating = 50,
	enchant = 15,
	skillId = 21,
	skillName = "Lightarmor",
	material = "glass",
	canBeast = true
}
-- Morag Tong Helm
itemsList["morag_tong_helm"] = {
	name = "Morag Tong Helm",
	id = "morag_tong_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 3,
	health = 120,
	value = 20,
	rating = 12,
	enchant = 20,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather", --?
}
-- Netch Leather Helm
itemsList["netch_leather_helm"] = {
	name = "Netch Leather Helm",
	id = "netch_leather_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 3,
	health = 50,
	value = 15,
	rating = 5,
	enchant = 7.5,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather",
	canBeast = true
}
-- Nordic Fur Helm
itemsList["fur_helm"] = {
	name = "Nordic Fur Helm",
	id = "fur_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 1.5,
	health = 50,
	value = 15,
	rating = 5,
	enchant = 7.5,
	skillId = 21,
	skillName = "Lightarmor",
	material = "fur",
	canBeast = true
}
-- Redoran Watchman's Helm
itemsList["chitin_watchman_helm"] = {
	name = "Redoran Watchman's Helm",
	id = "chitin_watchman_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 1,
	health = 110,
	value = 24,
	rating = 11,
	enchant = 12.5,
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin"
}
-- Telvanni Cephalopod Helm
itemsList["cephalopod_helm"] = {
	name = "Telvanni Cephalopod Helm",
	id = "cephalopod_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 2,
	health = 80,
	value = 50,
	rating = 8,
	enchant = 100,
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin" --?
}
-- Telvanni Dust Adept Helm
itemsList["dust_adept_helm"] = {
	name = "Telvanni Dust Adept Helm",
	id = "dust_adept_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 1.5,
	health = 50,
	value = 30,
	rating = 5,
	enchant = 25,
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin" --?
}
-- Telvanni Mole Crab Helm
itemsList["mole_crab_helm"] = {
	name = "Telvanni Mole Crab Helm",
	id = "mole_crab_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 2,
	health = 60,
	value = 19,
	rating = 6,
	enchant = 50,
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin" --?
}

-- Chitin Left Pauldron
itemsList["chitin pauldron - left"] = {
	name = "Chitin Left Pauldron",
	id = "chitin pauldron - left",
	itemType = "armor",
	subtype = "pauldron",
	weight = 2,
	health = 100,
	value = 16,
	rating = 10,
	enchant = 1,
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin",
	orientation = "left"
}
-- Chitin Right Pauldron
itemsList["chitin pauldron - right"] = {
	name = "Chitin Right Pauldron",
	id = "chitin pauldron - right",
	itemType = "armor",
	subtype = "pauldron",
	weight = 2,
	health = 100,
	value = 16,
	rating = 10,
	enchant = 1,
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin",
	orientation = "right"
}
-- Glass Left Pauldron
itemsList["glass_pauldron_left"] = {
	name = "Glass Left Pauldron",
	id = "glass_pauldron_left",
	itemType = "armor",
	subtype = "pauldron",
	weight = 3,
	health = 500,
	value = 9600,
	rating = 50,
	enchant = 1.5,
	skillId = 21,
	skillName = "Lightarmor",
	material = "glass",
	orientation = "left"
}
-- Glass Right Pauldron
itemsList["glass_pauldron_right"] = {
	name = "Glass Right Pauldron",
	id = "glass_pauldron_right",
	itemType = "armor",
	subtype = "pauldron",
	weight = 3,
	health = 500,
	value = 9600,
	rating = 50,
	enchant = 1.5,
	skillId = 21,
	skillName = "Lightarmor",
	material = "glass",
	orientation = "right"
}
-- Netch Leather Left Pauldron
itemsList["netch_leather_pauldron_left"] = {
	name = "Netch Leather Left Pauldron",
	id = "netch_leather_pauldron_left",
	itemType = "armor",
	subtype = "pauldron",
	weight = 4,
	health = 50,
	value = 12,
	rating = 5,
	enchant = 1,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather",
	orientation = "left"
}
-- Netch Leather Right Pauldron
itemsList["netch_leather_pauldron_right"] = {
	name = "Netch Leather Right Pauldron",
	id = "netch_leather_pauldron_right",
	itemType = "armor",
	subtype = "pauldron",
	weight = 4,
	health = 50,
	value = 12,
	rating = 5,
	enchant = 1,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather",
	orientation = "right"
}
-- Nordic Fur Left Pauldron
itemsList["fur_pauldron_left"] = {
	name = "Nordic Fur Left Pauldron",
	id = "fur_pauldron_left",
	itemType = "armor",
	subtype = "pauldron",
	weight = 3,
	health = 50,
	value = 12,
	rating = 5,
	enchant = 1,
	skillId = 21,
	skillName = "Lightarmor",
	material = "fur",
	orientation = "left"
}
-- Nordic Fur Right Pauldron
itemsList["fur_pauldron_right"] = {
	name = "Nordic Fur Right Pauldron",
	id = "fur_pauldron_right",
	itemType = "armor",
	subtype = "pauldron",
	weight = 3,
	health = 50,
	value = 12,
	rating = 5,
	enchant = 1,
	skillId = 21,
	skillName = "Lightarmor",
	material = "fur",
	orientation = "right"
}

-- Chitin Greaves
itemsList["chitin greaves"] = {
	name = "Chitin Greaves",
	id = "chitin greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 5.4,
	health = 100,
	value = 29,
	rating = 10,
	enchant = 1.3,
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin"
}
-- Glass Greaves
itemsList["glass_greaves"] = {
	name = "Glass Greaves",
	id = "glass_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 9,
	health = 500,
	value = 17600,
	rating = 50,
	enchant = 10,
	skillId = 21,
	skillName = "Lightarmor",
	material = "glass"
}
-- Netch Leather Greaves
itemsList["netch_leather_greaves"] = {
	name = "Netch Leather Greaves",
	id = "netch_leather_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 7,
	health = 50,
	value = 22,
	rating = 5,
	enchant = 1,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather"
}
-- Nordic Fur Greaves
itemsList["fur_greaves"] = {
	name = "Nordic Fur Greaves",
	id = "fur_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 5.4,
	health = 50,
	value = 22,
	rating = 5,
	enchant = 1,
	skillId = 21,
	skillName = "Lightarmor",
	material = "fur"
}

-- Chitin Boots
itemsList["chitin boots"] = {
	name = "Chitin Boots",
	id = "chitin boots",
	itemType = "armor",
	subtype = "boots",
	weight = 6,
	health = 100,
	value = 13,
	rating = 10,
	enchant = 4.4,
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin"
}
-- Glass Boots
itemsList["glass_boots"] = {
	name = "Glass Boots",
	id = "glass_boots",
	itemType = "armor",
	subtype = "boots",
	weight = 3,
	health = 500,
	value = 8000,
	rating = 50,
	enchant = 10,
	skillId = 21,
	skillName = "Lightarmor",
	material = "glass"
}
-- Heavy Leather Boots
itemsList["heavy_leather_boots"] = {
	name = "Heavy Leather Boots",
	id = "heavy_leather_boots",
	itemType = "armor",
	subtype = "boots",
	weight = 8,
	health = 500,
	value = 100,
	rating = 50,
	enchant = 2.6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather"
}
-- Netch Leather Boots
itemsList["netch_leather_boots"] = {
	name = "Netch Leather Boots",
	id = "netch_leather_boots",
	itemType = "armor",
	subtype = "boots",
	weight = 8,
	health = 50,
	value = 10,
	rating = 5,
	enchant = 2.6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather"
}
-- Nordic Fur Boots
itemsList["fur_boots"] = {
	name = "Nordic Fur Boots",
	id = "fur_boots",
	itemType = "armor",
	subtype = "boots",
	weight = 6,
	health = 50,
	value = 10,
	rating = 5,
	enchant = 2.6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather"
}

-- Chitin Left Gauntlet
itemsList["chitin guantlet - left"] = {
	name = "Chitin Left Gauntlet",
	id = "chitin guantlet - left", --Note: id misspelled ingame
	itemType = "armor",
	subtype = "gauntlet",
	weight = 1,
	health = 50,
	value = 9,
	rating = 10,
	enchant = 10,
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin",
	orientation = "left"
}
-- Chitin Right Gauntlet
itemsList["chitin guantlet - right"] = {
	name = "Chitin Right Gauntlet",
	id = "chitin guantlet - right", --Note: id misspelled ingame
	itemType = "armor",
	subtype = "gauntlet",
	weight = 1,
	health = 50,
	value = 9,
	rating = 10,
	enchant = 10,
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin",
	orientation = "right"
}
-- Cloth Left Bracer
itemsList["cloth bracer left"] = {
	name = "Cloth Left Bracer",
	id = "cloth bracer left", --Note: formatted in this style
	itemType = "armor",
	subtype = "bracer",
	weight = 1.5,
	health = 20,
	value = 3,
	rating = 4,
	enchant = 6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "cloth",
	orientation = "left"
}
-- Cloth Right Bracer
itemsList["cloth bracer right"] = {
	name = "Cloth Right Bracer",
	id = "cloth bracer right", --Note: formatted in this style
	itemType = "armor",
	subtype = "bracer",
	weight = 1.5,
	health = 20,
	value = 3,
	rating = 4,
	enchant = 6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "cloth",
	orientation = "right"
}
-- Left Glass Bracer
itemsList["glass_bracer_left"] = {
	name = "Left Glass Bracer",
	id = "glass_bracer_left",
	itemType = "armor",
	subtype = "bracer",
	weight = 3,
	health = 400,
	value = 4000,
	rating = 50,
	enchant = 19,
	skillId = 21,
	skillName = "Lightarmor",
	material = "glass",
	orientation = "left"
}
-- Right Glass Bracer
itemsList["glass_bracer_right"] = {
	name = "Right Glass Bracer",
	id = "glass_bracer_right",
	itemType = "armor",
	subtype = "bracer",
	weight = 3,
	health = 400,
	value = 4000,
	rating = 50,
	enchant = 19,
	skillId = 21,
	skillName = "Lightarmor",
	material = "glass",
	orientation = "right"
}
-- Left Leather Bracer
itemsList["left leather bracer"] = {
	name = "Left Leather Bracer",
	id = "left leather bracer", --Formatted this way
	itemType = "armor",
	subtype = "bracer",
	weight = 1.5,
	health = 20,
	value = 5,
	rating = 5,
	enchant = 6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather",
	orientation = "left"
}
-- Right Leather Bracer
itemsList["right leather bracer"] = {
	name = "Right Leather Bracer",
	id = "right leather bracer", --Formatted this way
	itemType = "armor",
	subtype = "bracer",
	weight = 1.5,
	health = 25, --Different health rating to left version
	value = 5,
	rating = 5,
	enchant = 6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather",
	orientation = "right"
}
-- Nordic Fur Left Bracer
itemsList["fur_bracer_left"] = {
	name = "Nordic Fur Left Bracer",
	id = "fur_bracer_left",
	itemType = "armor",
	subtype = "bracer",
	weight = 1.5,
	health = 25,
	value = 5,
	rating = 5,
	enchant = 6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "fur",
	orientation = "left"
}
-- Nordic Fur Right Bracer
itemsList["fur_bracer_right"] = {
	name = "Nordic Fur Right Bracer",
	id = "fur_bracer_right",
	itemType = "armor",
	subtype = "bracer",
	weight = 1.5,
	health = 25,
	value = 5,
	rating = 5,
	enchant = 6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "fur",
	orientation = "right"
}
-- Netch Leather Left Gauntlet
itemsList["netch_leather_gauntlet_left"] = {
	name = "Netch Leather Left Gauntlet",
	id = "netch_leather_gauntlet_left",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 3,
	health = 25,
	value = 7,
	rating = 5,
	enchant = 6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather",
	orientation = "left"
}
-- Netch Leather Right Gauntlet
itemsList["netch_leather_gauntlet_right"] = {
	name = "Netch Leather Right Gauntlet",
	id = "netch_leather_gauntlet_right",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 3,
	health = 25,
	value = 7,
	rating = 5,
	enchant = 6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather",
	orientation = "right"
}
-- Nordic Fur Left Gauntlet
itemsList["fur_gauntlet_left"] = {
	name = "Nordic Fur Left Gauntlet",
	id = "fur_gauntlet_left",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 1.5,
	health = 25,
	value = 7,
	rating = 5,
	enchant = 6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "fur",
	orientation = "left"
}
-- Nordic Fur Right Gauntlet
itemsList["fur_gauntlet_right"] = {
	name = "Nordic Fur Right Gauntlet",
	id = "fur_gauntlet_right",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 1.5,
	health = 25,
	value = 7,
	rating = 5,
	enchant = 6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "fur",
	orientation = "right"
}

-- Chitin Shield
itemsList["chitin_shield"] = {
	name = "Chitin Shield",
	id = "chitin_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 4,
	health = 200,
	value = 22,
	rating = 10,
	enchant = 25,
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin",
	hand = 1,
}
-- Glass Shield
itemsList["glass_shield"] = {
	name = "Glass Shield",
	id = "glass_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 9,
	health = 1000,
	value = 13600,
	rating = 50,
	enchant = 30,
	skillId = 21,
	skillName = "Lightarmor",
	material = "glass",
	hand = 1
}
-- Netch Leather Shield
itemsList["netch_leather_shield"] = {
	name = "Netch Leather Shield",
	id = "netch_leather_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 6,
	health = 100,
	value = 17,
	rating = 5,
	enchant = 15,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather",
	hand = 1
}
-- Nordic Leather Shield
itemsList["nordic_leather_shield"] = {
	name = "Nordic Leather Shield",
	id = "nordic_leather_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 4.5,
	health = 100,
	value = 25,
	rating = 5,
	enchant = 15,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather",
	hand = 1
}
-- Chitin Tower Shield
itemsList["chitin_towershield"] = {
	name = "Chitin Tower Shield",
	id = "chitin_towershield",
	itemType = "armor",
	subtype = "tower shield",
	weight = 6,
	health = 240,
	value = 32,
	rating = 12,
	enchant = 37.5,
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin",
	hand = 1
}
-- Glass Tower Shield
itemsList["glass_towershield"] = {
	name = "Glass Tower Shield",
	id = "glass_towershield",
	itemType = "armor",
	subtype = "tower shield",
	weight = 9,
	health = 1100,
	value = 20000,
	rating = 55,
	enchant = 45,
	skillId = 21,
	skillName = "Lightarmor",
	material = "glass",
	hand = 1
}
-- Netch Leather Tower Shield
itemsList["netch_leather_towershield"] = {
	name = "Netch Leather Tower Shield",
	id = "netch_leather_towershield",
	itemType = "armor",
	subtype = "tower shield",
	weight = 9,
	health = 100,
	value = 25,
	rating = 5,
	enchant = 22.5,
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather",
	hand = 1
}

-- Nordic Ringmail Cuirass
itemsList["nordic_ringmail_cuirass"] = {
	name = "Nordic Ringmail Cuirass",
	id = "nordic_ringmail_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 21,
	health = 300,
	value = 80,
	rating = 10,
	enchant = 14,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "nordic" --?
}
-- Imperial Chain Cuirass
itemsList["imperial_chain_cuirass"] = {
	name = "Imperial Chain Cuirass",
	id = "imperial_chain_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 21,
	health = 300,
	value = 90,
	rating = 12,
	enchant = 14,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "iron", --?
	imperialUniform = true
}
-- Bonemold Cuirass
itemsList["bonemold_cuirass"] = {
	name = "Bonemold Cuirass",
	id = "bonemold_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 24,
	health = 480,
	value = 350,
	rating = 16,
	enchant = 16,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold"
}
-- Armun-An Bonemold Cuirass
itemsList["bonemold_armun-an_cuirass"] = {
	name = "Armun-An Bonemold Cuirass",
	id = "bonemold_armun-an_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 24,
	health = 480,
	value = 350,
	rating = 16,
	enchant = 16,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold"
}
-- Gah-Julan Bonemold Cuirass
itemsList["bonemold_gah-julan_cuirass"] = {
	name = "Gah-Julan Bonemold Cuirass",
	id = "bonemold_gah-julan_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 24,
	health = 510,
	value = 360,
	rating = 17,
	enchant = 16,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold"
}
-- Imperial Dragonscale Cuirass
itemsList["dragonscale_cuirass"] = {
	name = "Imperial Dragonscale Cuirass",
	id = "dragonscale_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 24,
	health = 600,
	value = 340,
	rating = 20,
	enchant = 16,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "leather" --?
}
-- Orcish Cuirass
itemsList["orcish_cuirass"] = {
	name = "Orcish Cuirass",
	id = "orcish_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 26.5,
	health = 900,
	value = 2800,
	rating = 30,
	enchant = 24,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "orcish"
}
-- Dreugh Cuirass
itemsList["dreugh_cuirass"] = {
	name = "Dreugh Cuirass",
	id = "dreugh_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 27,
	health = 1200,
	value = 5250,
	rating = 40,
	enchant = 18,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "dreugh"
}
-- Indoril Cuirass
itemsList["indoril cuirass"] = {
	name = "Indoril Cuirass",
	id = "indoril cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 27,
	health = 1350,
	value = 7000,
	rating = 45,
	enchant = 18,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "indoril",
	ordinatorUniform = true
}

-- Bonemold Helm
itemsList["bonemold_helm"] = {
	name = "Bonemold Helm",
	id = "bonemold_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 4,
	health = 180,
	value = 150,
	rating = 18,
	enchant = 20,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold"
}
-- Redoran Founder's Helm
itemsList["bonemold_founders_helm"] = {
	name = "Redoran Founder's Helm",
	id = "bonemold_founders_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 4.4,
	health = 180,
	value = 150,
	rating = 18,
	enchant = 20,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold"
}
-- Dreugh Helm
itemsList["dreugh_helm"] = {
	name = "Dreugh Helm",
	id = "dreugh_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 4.5,
	health = 400,
	value = 2250,
	rating = 40,
	enchant = 22.5,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "dreugh",
	canBeast = true
}
-- Imperial Chain Coif
itemsList["imperial_chain_coif_helm"] = {
	name = "Imperial Chain Coif",
	id = "imperial_chain_coif_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 3.5,
	health = 100,
	value = 35,
	rating = 10,
	enchant = 17.5,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "iron", --?
	canBeast = true
}
-- Imperial Dragonscale Helm
itemsList["dragonscale_helm"] = {
	name = "Imperial Dragonscale Helm",
	id = "dragonscale_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 4,
	health = 200,
	value = 130,
	rating = 20,
	enchant = 20,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "leather", --?
	canBeast = true
}
-- Indoril Helmet
itemsList["indoril helmet"] = {
	name = "Indoril Helmet",
	id = "indoril helmet",
	itemType = "armor",
	subtype = "helm",
	weight = 4.5,
	health = 450,
	value = 3000,
	rating = 45,
	enchant = 22.5,
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "gold", --?
	ordinatorUniform = true
}
-- Orcish Helm
itemsList["orcish_helm"] = {
	name = "Orcish Helm",
	id = "orcish_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 4.4,
	health = 300,
	value = 1200,
	rating = 30,
	enchant = 30,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "orcish",
}
-- Gondolier's Helm
itemsList["gondolier_helm"] = {
	name = "Gondolier's Helm",
	id = "gondolier_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 4,
	health = 100,
	value = 10,
	rating = 1,
	enchant = 10,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "chitin", --?
}
-- Native Armun-An Bonemold Helm
itemsList["bonemold_armun-an_helm"] = {
	name = "Native Armun-An Bonemold Helm",
	id = "bonemold_armun-an_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 4,
	health = 180,
	value = 150,
	rating = 18,
	enchant = 20,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold"
}
-- Native Chuzei Bonemold Helm
itemsList["bonemold_chuzei_helm"] = {
	name = "Native Chuzei Bonemold Helm",
	id = "bonemold_chuzei_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 4,
	health = 170,
	value = 175,
	rating = 17,
	enchant = 20,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold"
}
-- Native Gah-Julan Bonemold Helm
itemsList["bonemold_gah-julan_helm"] = {
	name = "Native Gah-Julan Bonemold Helm",
	id = "bonemold_gah-julan_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 4,
	health = 160,
	value = 165,
	rating = 16,
	enchant = 20,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold"
}
-- Redoran Master Helm
itemsList["redoran_master_helm"] = {
	name = "Redoran Master Helm",
	id = "redoran_master_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 4.5,
	health = 450,
	value = 3000,
	rating = 45,
	enchant = 22.5,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold"
}

-- Bonemold L Pauldron
itemsList["bonemold_pauldron_l"] = {
	name = "Bonemold L Pauldron",
	id = "bonemold_pauldron_l",
	itemType = "armor",
	subtype = "pauldron",
	weight = 8,
	health = 150,
	value = 120,
	rating = 15,
	enchant = 1.6,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	orientation = "left"
}
-- Bonemold R Pauldron
itemsList["bonemold_pauldron_r"] = {
	name = "Bonemold R Pauldron",
	id = "bonemold_pauldron_r",
	itemType = "armor",
	subtype = "pauldron",
	weight = 8,
	health = 150,
	value = 120,
	rating = 15,
	enchant = 1.6,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	orientation = "right"
}
-- Armun-An Bonemold L Pauldron
itemsList["bonemold_armun-an_pauldron_l"] = {
	name = "Armun-An Bonemold L Pauldron",
	id = "bonemold_armun-an_pauldron_l",
	itemType = "armor",
	subtype = "pauldron",
	weight = 8,
	health = 150,
	value = 120,
	rating = 15,
	enchant = 1.6,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	orientation = "left"
}
-- Armun-An Bonemold R Pauldron
itemsList["bonemold_armun-an_pauldron_r"] = {
	name = "Armun-An Bonemold R Pauldron",
	id = "bonemold_armun-an_pauldron_r",
	itemType = "armor",
	subtype = "pauldron",
	weight = 8,
	health = 150,
	value = 120,
	rating = 15,
	enchant = 1.6,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	orientation = "right"
}
-- Gah-Julan Bonemold L Pauldron
itemsList["bonemold_gah-julan_pauldron_l"] = {
	name = "Gah-Julan Bonemold L Pauldron",
	id = "bonemold_gah-julan_pauldron_l",
	itemType = "armor",
	subtype = "pauldron",
	weight = 8,
	health = 170,
	value = 140,
	rating = 17,
	enchant = 1.6,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	orientation = "left"
}
-- Gah-Julan Bonemold r Pauldron
itemsList["bonemold_gah-julan_pauldron_r"] = {
	name = "Gah-Julan Bonemold R Pauldron",
	id = "bonemold_gah-julan_pauldron_r",
	itemType = "armor",
	subtype = "pauldron",
	weight = 8,
	health = 170,
	value = 140,
	rating = 17,
	enchant = 1.6,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	orientation = "right"
}
-- Indoril Left Pauldron
itemsList["indoril pauldron left"] = {
	name = "Indoril Left Pauldron",
	id = "indoril pauldron left",
	itemType = "armor",
	subtype = "pauldron",
	weight = 9,
	health = 450,
	value = 2400,
	rating = 45,
	enchant = 1,
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "gold", --?
	orientation = "left"
}
-- Indoril Right Pauldron
itemsList["indoril pauldron right"] = {
	name = "Indoril Right Pauldron",
	id = "indoril pauldron right",
	itemType = "armor",
	subtype = "pauldron",
	weight = 9,
	health = 450,
	value = 2400,
	rating = 45,
	enchant = 1,
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "gold", --?
	orientation = "right"
}
-- Orcish Left Pauldron
itemsList["orcish_pauldron_left"] = {
	name = "Orcish Left Pauldron",
	id = "orcish_pauldron_left",
	itemType = "armor",
	subtype = "pauldron",
	weight = 8,
	health = 300,
	value = 960,
	rating = 30,
	enchant = 2.4,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "orcish",
	orientation = "left"
}
-- Orcish Right Pauldron
itemsList["orcish_pauldron_right"] = {
	name = "Orcish Right Pauldron",
	id = "orcish_pauldron_right",
	itemType = "armor",
	subtype = "pauldron",
	weight = 8,
	health = 300,
	value = 960,
	rating = 30,
	enchant = 2.4,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "orcish",
	orientation = "right"
}

-- Bonemold Greaves
itemsList["bonemold_greaves"] = {
	name = "Bonemold Greaves",
	id = "bonemold_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 13.4,
	health = 150,
	value = 220,
	rating = 15,
	enchant = 2,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold"
}
-- Imperial Chain Greaves
itemsList["imperial_chain_greaves"] = {
	name = "Imperial Chain Greaves",
	id = "imperial_chain_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 10,
	health = 200,
	value = 50,
	rating = 20,
	enchant = 7,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "iron" --?
}
-- Orcish Greaves
itemsList["orcish_greaves"] = {
	name = "Orcish Greaves",
	id = "orcish_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 13.45,
	health = 300,
	value = 1760,
	rating = 30,
	enchant = 3,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "orcish"
}

-- Bonemold Boots
itemsList["bonemold_boots"] = {
	name = "Bonemold Boots",
	id = "bonemold_boots",
	itemType = "armor",
	subtype = "boots",
	weight = 16,
	health = 160,
	value = 100,
	rating = 15,
	enchant = 7,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold"
}
-- Indoril Boots
itemsList["indoril boots"] = {
	name = "Indoril Boots",
	id = "indoril boots",
	itemType = "armor",
	subtype = "boots",
	weight = 18,
	health = 450,
	value = 2000,
	rating = 45,
	enchant = 2.6,
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "gold" --?
}
-- Orcish Boots
itemsList["orcish_boots"] = {
	name = "Orcish Boots",
	id = "orcish_boots",
	itemType = "armor",
	subtype = "boots",
	weight = 17,
	health = 300,
	value = 800,
	rating = 30,
	enchant = 10.5,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "orcish"
}

-- Bonemold Left Bracer
itemsList["bonemold_bracer_left"] = {
	name = "Bonemold Left Bracer",
	id = "bonemold_bracer_left",
	itemType = "armor",
	subtype = "bracer",
	weight = 4,
	health = 75,
	value = 50,
	rating = 15,
	enchant = 16,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	orientation = "left"
}
-- Bonemold Right Bracer
itemsList["bonemold_bracer_right"] = {
	name = "Bonemold Right Bracer",
	id = "bonemold_bracer_right",
	itemType = "armor",
	subtype = "bracer",
	weight = 4,
	health = 75,
	value = 50,
	rating = 15,
	enchant = 16,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	orientation = "right"
}
-- Indoril Left Gauntlet
itemsList["indoril left gauntlet"] = {
	name = "Indoril Left Gauntlet",
	id = "indoril left gauntlet",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 4.5,
	health = 225,
	value = 1400,
	rating = 45,
	enchant = 6,
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "gold", --?
	orientation = "left"
}
-- Indoril Right Gauntlet
itemsList["indoril right gauntlet"] = {
	name = "Indoril Right Gauntlet",
	id = "indoril right gauntlet",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 4.5,
	health = 225,
	value = 1400,
	rating = 45,
	enchant = 6,
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "gold", --?
	orientation = "right"
}
-- Orcish Left Bracer
itemsList["orcish_bracer_left"] = {
	name = "Orcish Left Bracer",
	id = "orcish_bracer_left",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 4.4,
	health = 150,
	value = 400,
	rating = 30,
	enchant = 24,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "orcish",
	orientation = "left"
}
-- Orcish Right Bracer
itemsList["orcish_bracer_right"] = {
	name = "Orcish Right Bracer",
	id = "orcish_bracer_right",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 4.4,
	health = 150,
	value = 400,
	rating = 30,
	enchant = 24,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "orcish",
	orientation = "right"
}

-- Bonemold Shield
itemsList["bonemold_shield"] = {
	name = "Bonemold Shield",
	id = "bonemold_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 10,
	health = 300,
	value = 170,
	rating = 15,
	enchant = 40,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	hand = 1,
}
-- Dreugh Shield
itemsList["dreugh_shield"] = {
	name = "Dreugh Shield",
	id = "dreugh_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 13.5,
	health = 800,
	value = 2550,
	rating = 40,
	enchant = 45,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "dreugh",
	hand = 1,
}
-- Indoril Shield
itemsList["indoril shield"] = {
	name = "Indoril Shield",
	id = "indoril shield",
	itemType = "armor",
	subtype = "shield",
	weight = 13.5,
	health = 900,
	value = 2000,
	rating = 45,
	enchant = 45,
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "gold", --?
	hand = 1,
}
-- Bonemold Tower Shield
itemsList["bonemold_towershield"] = {
	name = "Bonemold Tower Shield",
	id = "bonemold_towershield",
	itemType = "armor",
	subtype = "tower shield",
	weight = 13,
	health = 340,
	value = 250,
	rating = 17,
	enchant = 60,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	hand = 1,
}
-- Dragonscale Tower Shield
itemsList["dragonscale_towershield"] = {
	name = "Dragonscale Tower Shield",
	id = "dragonscale_towershield",
	itemType = "armor",
	subtype = "tower shield",
	weight = 12,
	health = 440,
	value = 230,
	rating = 22,
	enchant = 60,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "leather", --?
	hand = 1,
}
-- Orcish Tower Shield
itemsList["orcish_towershield"] = {
	name = "Orcish Tower Shield",
	id = "orcish_towershield",
	itemType = "armor",
	subtype = "tower shield",
	weight = 13.4,
	health = 640,
	value = 200,
	rating = 22,
	enchant = 90,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "orcish",
	hand = 1,
}
-- Hlaalu Guard Shield
itemsList["bonemold_tshield_hlaaluguard"] = {
	name = "Hlaalu Guard Shield",
	id = "bonemold_tshield_hlaaluguard",
	itemType = "armor",
	subtype = "tower shield",
	weight = 13,
	health = 340,
	value = 250,
	rating = 17,
	enchant = 60,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	hand = 1,
}
-- Redoran Guard Shield
itemsList["bonemold_tshield_redoranguard"] = {
	name = "Redoran Guard Shield",
	id = "bonemold_tshield_redoranguard",
	itemType = "armor",
	subtype = "tower shield",
	weight = 13,
	health = 340,
	value = 250,
	rating = 17,
	enchant = 60,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	hand = 1,
}
-- Telvanni Guard Shield
itemsList["bonemold_tshield_telvanniguard"] = {
	name = "Telvanni Guard Shield",
	id = "bonemold_tshield_telvanniguard",
	itemType = "armor",
	subtype = "tower shield",
	weight = 13,
	health = 340,
	value = 250,
	rating = 17,
	enchant = 60,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	hand = 1,
}

-- Iron Cuirass
itemsList["iron_cuirass"] = {
	name = "Iron Cuirass",
	id = "iron_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 30,
	health = 200,
	value = 70,
	rating = 10,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron"
}
-- Steel Cuirass
itemsList["steel_cuirass"] = {
	name = "Steel Cuirass",
	id = "steel_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 30,
	health = 450,
	value = 150,
	rating = 15,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel"
}
-- Nordic Iron Cuirass
itemsList["nordic_iron_cuirass"] = {
	name = "Nordic Iron Cuirass",
	id = "nordic_iron_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 35,
	health = 480,
	value = 130,
	rating = 16,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron" --or nordic
}
-- Imperial Steel Cuirass
itemsList["imperial cuirass_armor"] = {
	name = "Imperial Steel Cuirass",
	id = "imperial cuirass_armor",
	itemType = "armor",
	subtype = "cuirass",
	weight = 29,
	health = 460,
	value = 150,
	rating = 16,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel",
	imperialUniform = true
}
-- Nordic Trollbone Cuirass
itemsList["trollbone_cuirass"] = {
	name = "Nordic Trollbone Cuirass",
	id = "trollbone_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 32,
	health = 540,
	value = 165,
	rating = 18,
	enchant = 16,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "bone" --?
}
-- Imperial Silver Cuirass
itemsList["silver_cuirass"] = {
	name = "Imperial Silver Cuirass",
	id = "silver_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 30,
	health = 540,
	value = 280,
	rating = 18,
	enchant = 16,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "silver"
}
-- Imperial Templar Knight Cuirass
itemsList["templar_cuirass"] = {
	name = "Imperial Templar Knight Cuirass",
	id = "templar_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 30,
	health = 540,
	value = 175,
	rating = 18,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "gold", --?
	imperialUniform = true
}
-- Duke's Guard Silver Cuirass
itemsList["silver_dukesguard_cuirass"] = {
	name = "Duke's Guard Silver Cuirass",
	id = "silver_dukesguard_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 30,
	health = 600,
	value = 350,
	rating = 20,
	enchant = 16,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "silver",
	imperialUniform = true
}
-- Dwemer Cuirass
itemsList["dwemer_cuirass"] = {
	name = "Dwemer Cuirass",
	id = "dwemer_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 30,
	health = 600,
	value = 1050,
	rating = 20,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "dwarven"
}
-- Ebony Cuirass
itemsList["ebony_cuirass"] = {
	name = "Ebony Cuirass",
	id = "ebony_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 60,
	health = 1800,
	value = 35000,
	rating = 60,
	enchant = 40,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "ebony"
}
-- Daedric Cuirass
itemsList["daedric_cuirass"] = {
	name = "Daedric Cuirass",
	id = "daedric_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 90,
	health = 2400,
	value = 70000,
	rating = 80,
	enchant = 60,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "daedric"
}

-- Dwemer Helm
itemsList["dwemer_helm"] = {
	name = "Dwemer Helm",
	id = "dwemer_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 5,
	health = 200,
	value = 450,
	rating = 20,
	enchant = 25,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "dwarven"
}
-- Ebony Closed Helm
itemsList["ebony_closed_helm"] = {
	name = "Ebony Closed Helm",
	id = "ebony_closed_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 10,
	health = 600,
	value = 15000,
	rating = 60,
	enchant = 50,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "ebony"
}
-- Imperial Silver Helm
itemsList["silver_helm"] = {
	name = "Imperial Silver Helm",
	id = "silver_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 5,
	health = 170,
	value = 120,
	rating = 17,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "silver",
	canBeast = true
}
-- Imperial Steel Helmet
itemsList["imperial helmet armor"] = {
	name = "Imperial Steel Helmet",
	id = "imperial helmet armor",
	itemType = "armor",
	subtype = "helm",
	weight = 5,
	health = 160,
	value = 70,
	rating = 16,
	enchant = 25,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel",
	canBeast = true
}
-- Iron Helmet
itemsList["iron_helmet"] = {
	name = "Iron Helmet",
	id = "iron_helmet",
	itemType = "armor",
	subtype = "helm",
	weight = 5,
	health = 100,
	value = 30,
	rating = 10,
	enchant = 2.5,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron"
}
-- Steel Helm
itemsList["steel_helm"] = {
	name = "Steel Helm",
	id = "steel_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 5,
	health = 150,
	value = 60,
	rating = 15,
	enchant = 25,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel"
}
-- Imperial Templar Helmet
itemsList["templar_helmet_armor"] = {
	name = "Imperial Templar Helmet",
	id = "templar_helmet_armor",
	itemType = "armor",
	subtype = "helm",
	weight = 5,
	health = 180,
	value = 75,
	rating = 18,
	enchant = 25,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "steel", --?
	canBeast = true
}
-- Daedric Face of God
itemsList["daedric_god_helm"] = {
	name = "Daedric Face of God",
	id = "daedric_god_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 15,
	health = 800,
	value = 15000,
	rating = 80,
	enchant = 75,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "daedric"
}
-- Daedric Face of Inspiration
itemsList["daedric_fountain_helm"] = {
	name = "Daedric Face of Inspiration",
	id = "daedric_fountain_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 15,
	health = 650,
	value = 13000,
	rating = 65,
	enchant = 75,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "daedric"
}
-- Daedric Face of Terror
itemsList["daedric_terrifying_helm"] = {
	name = "Daedric Face of Terror",
	id = "daedric_terrifying_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 15,
	health = 750,
	value = 14000,
	rating = 75,
	enchant = 75,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "daedric"
}
-- Nordic Iron Helm
itemsList["nordic_iron_helm"] = {
	name = "Nordic Iron Helm",
	id = "nordic_iron_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 8,
	health = 160,
	value = 50,
	rating = 16,
	enchant = 25,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron" --or nordic
}
-- Nordic Trollbone Helm
itemsList["trollbone_helm"] = {
	name = "Nordic Trollbone Helm",
	id = "trollbone_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 8,
	health = 180,
	value = 65,
	rating = 18,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "bone", --or nordic
	canBeast = true
}

-- Dwemer Left Pauldron
itemsList["dwemer_pauldron_left"] = {
	name = "Dwemer Left Pauldron",
	id = "dwemer_pauldron_left",
	itemType = "armor",
	subtype = "pauldron",
	weight = 10,
	health = 200,
	value = 360,
	rating = 20,
	enchant = 4,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "dwarven",
	orientation = "left"
}
-- Dwemer Right Pauldron
itemsList["dwemer_pauldron_right"] = {
	name = "Dwemer Right Pauldron",
	id = "dwemer_pauldron_right",
	itemType = "armor",
	subtype = "pauldron",
	weight = 10,
	health = 200,
	value = 360,
	rating = 20,
	enchant = 4,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "dwarven",
	orientation = "right"
}
-- Daedric Left Pauldron
itemsList["daedric_pauldron_left"] = {
	name = "Daedric Left Pauldron",
	id = "daedric_pauldron_left",
	itemType = "armor",
	subtype = "pauldron",
	weight = 30,
	health = 800,
	value = 24000,
	rating = 80,
	enchant = 6,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "daedric",
	orientation = "left"
}
-- Daedric Right Pauldron
itemsList["daedric_pauldron_right"] = {
	name = "Daedric Right Pauldron",
	id = "daedric_pauldron_right",
	itemType = "armor",
	subtype = "pauldron",
	weight = 30,
	health = 800,
	value = 24000,
	rating = 80,
	enchant = 6,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "daedric",
	orientation = "right"
}
-- Ebony Left Pauldron
itemsList["ebony_pauldron_left"] = {
	name = "Ebony Left Pauldron",
	id = "ebony_pauldron_left",
	itemType = "armor",
	subtype = "pauldron",
	weight = 20,
	health = 600,
	value = 12000,
	rating = 60,
	enchant = 4,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "ebony",
	orientation = "left"
}
-- Ebony Right Pauldron
itemsList["ebony_pauldron_right"] = {
	name = "Ebony Right Pauldron",
	id = "ebony_pauldron_right",
	itemType = "armor",
	subtype = "pauldron",
	weight = 20,
	health = 600,
	value = 12000,
	rating = 60,
	enchant = 4,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "ebony",
	orientation = "right"
}
-- Imperial Chain Left Pauldron
itemsList["imperial_chain_pauldron_left"] = {
	name = "Imperial Chain Left Pauldron",
	id = "imperial_chain_pauldron_left",
	itemType = "armor",
	subtype = "pauldron",
	weight = 10,
	health = 200,
	value = 28,
	rating = 20,
	enchant = 7,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron", --?
	orientation = "left"
}
-- Imperial Chain Right Pauldron
itemsList["imperial_chain_pauldron_right"] = {
	name = "Imperial Chain Right Pauldron",
	id = "imperial_chain_pauldron_right",
	itemType = "armor",
	subtype = "pauldron",
	weight = 10,
	health = 200,
	value = 28,
	rating = 20,
	enchant = 7,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron", --?
	orientation = "right"
}
-- Imperial Steel Left Pauldron
itemsList["imperial left pauldron"] = {
	name = "Imperial Steel Left Pauldron",
	id = "imperial left pauldron",
	itemType = "armor",
	subtype = "pauldron",
	weight = 10,
	health = 160,
	value = 53,
	rating = 16,
	enchant = 2,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel",
	orientation = "left"
}
-- Imperial Steel Right Pauldron
itemsList["imperial right pauldron"] = {
	name = "Imperial Steel Right Pauldron",
	id = "imperial right pauldron",
	itemType = "armor",
	subtype = "pauldron",
	weight = 10,
	health = 160,
	value = 53,
	rating = 16,
	enchant = 2,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel",
	orientation = "right"
}
-- Imperial Templar Left Pauldron
itemsList["templar_pauldron_left"] = {
	name = "Imperial Templar Left Pauldron",
	id = "templar_pauldron_left",
	itemType = "armor",
	subtype = "pauldron",
	weight = 10,
	health = 180,
	value = 60,
	rating = 18,
	enchant = 2,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "gold", --?
	orientation = "left"
}
-- Imperial Templar Right Pauldron
itemsList["templar_pauldron_right"] = {
	name = "Imperial Templar Right Pauldron",
	id = "templar_pauldron_right",
	itemType = "armor",
	subtype = "pauldron",
	weight = 10,
	health = 180,
	value = 60,
	rating = 18,
	enchant = 2,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "gold", --?
	orientation = "right"
}
-- Iron Left Pauldron
itemsList["iron_pauldron_left"] = {
	name = "Iron Left Pauldron",
	id = "iron_pauldron_left",
	itemType = "armor",
	subtype = "pauldron",
	weight = 10,
	health = 100,
	value = 24,
	rating = 10,
	enchant = 2,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron",
	orientation = "left"
}
-- Iron Right Pauldron
itemsList["iron_pauldron_right"] = {
	name = "Iron Right Pauldron",
	id = "iron_pauldron_right",
	itemType = "armor",
	subtype = "pauldron",
	weight = 10,
	health = 100,
	value = 24,
	rating = 10,
	enchant = 2,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron",
	orientation = "right"
}
-- Steel Left Pauldron
itemsList["steel_pauldron_left"] = {
	name = "Steel Left Pauldron",
	id = "steel_pauldron_left",
	itemType = "armor",
	subtype = "pauldron",
	weight = 10,
	health = 150,
	value = 48,
	rating = 15,
	enchant = 2,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel",
	orientation = "left"
}
-- Steel Right Pauldron
itemsList["steel_pauldron_right"] = {
	name = "Steel Right Pauldron",
	id = "steel_pauldron_right",
	itemType = "armor",
	subtype = "pauldron",
	weight = 10,
	health = 150,
	value = 48,
	rating = 15,
	enchant = 2,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel",
	orientation = "right"
}

-- Daedric Greaves
itemsList["daedric_greaves"] = {
	name = "Daedric Greaves",
	id = "daedric_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 54,
	health = 800,
	value = 44000,
	rating = 80,
	enchant = 7.5,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "daedric",
}
-- Dwemer Greaves
itemsList["dwemer_greaves"] = {
	name = "Dwemer Greaves",
	id = "dwemer_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 18,
	health = 200,
	value = 660,
	rating = 20,
	enchant = 2.5,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "dwemer",
}
-- Ebony Greaves
itemsList["ebony_greaves"] = {
	name = "Ebony Greaves",
	id = "ebony_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 36,
	health = 600,
	value = 22000,
	rating = 60,
	enchant = 5,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "ebony",
}
-- Imperial Steel Greaves
itemsList["imperial_greaves"] = {
	name = "Imperial Steel Greaves",
	id = "imperial_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 17,
	health = 170,
	value = 98,
	rating = 16,
	enchant = 2.5,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel",
}
--Imperial Templar Greaves
itemsList["templar_greaves"] = {
	name = "Imperial Templar Greaves",
	id = "templar_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 18,
	health = 180,
	value = 110,
	rating = 18,
	enchant = 2.5,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "steel", --?
}
-- Iron Greaves
itemsList["iron_greaves"] = {
	name = "Iron Greaves",
	id = "iron_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 18,
	health = 100,
	value = 44,
	rating = 10,
	enchant = 2.5,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron",
}
-- Steel Greaves
itemsList["steel_greaves"] = {
	name = "Steel Greaves",
	id = "steel_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 18,
	health = 150,
	value = 88,
	rating = 15,
	enchant = 2.5,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel",
}

-- Daedric Boots
itemsList["daedric_boots"] = {
	name = "Daedric Boots",
	id = "daedric_boots",
	itemType = "armor",
	subtype = "boots",
	weight = 60,
	health = 800,
	value = 20000,
	rating = 80,
	enchant = 26.3,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "daedric"
}
-- Dwemer Boots
itemsList["dwemer_boots"] = {
	name = "Dwemer Boots",
	id = "dwemer_boots",
	itemType = "armor",
	subtype = "boots",
	weight = 20,
	health = 200,
	value = 300,
	rating = 20,
	enchant = 8.8,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "dwarven"
}
-- Ebony Boots
itemsList["ebony_boots"] = {
	name = "Ebony Boots",
	id = "ebony_boots",
	itemType = "armor",
	subtype = "boots",
	weight = 40,
	health = 600,
	value = 10000,
	rating = 60,
	enchant = 17.5,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "ebony"
}
-- Imperial Steel Boots
itemsList["imperial boots"] = {
	name = "Imperial Steel Boots",
	id = "imperial boots",
	itemType = "armor",
	subtype = "boots",
	weight = 19,
	health = 170,
	value = 50,
	rating = 16,
	enchant = 8.8,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel"
}
-- Imperial Templar Boots
itemsList["templar boots"] = {
	name = "Imperial Templar Boots",
	id = "templar boots",
	itemType = "armor",
	subtype = "boots",
	weight = 20,
	health = 180,
	value = 50,
	rating = 18,
	enchant = 8.8,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "steel" --?
}
-- Iron Boots
itemsList["iron boots"] = {
	name = "Iron Boots",
	id = "iron boots",
	itemType = "armor",
	subtype = "boots",
	weight = 19,
	health = 170,
	value = 50,
	rating = 10,
	enchant = 2.6,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron"
}
-- Steel Boots
itemsList["steel_boots"] = {
	name = "Steel Boots",
	id = "steel_boots",
	itemType = "armor",
	subtype = "boots",
	weight = 20,
	health = 150,
	value = 40,
	rating = 15,
	enchant = 8.8,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel"
}

-- Dwemer Left Bracer
itemsList["dwemer_bracer_left"] = {
	name = "Dwemer Left Bracer",
	id = "dwemer_bracer_left",
	itemType = "armor",
	subtype = "bracer",
	weight = 5,
	health = 100,
	value = 150,
	rating = 20,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "dwarven",
	orientation = "left",
}
-- Dwemer Right Bracer
itemsList["dwemer_bracer_right"] = {
	name = "Dwemer Right Bracer",
	id = "dwemer_bracer_right",
	itemType = "armor",
	subtype = "bracer",
	weight = 5,
	health = 100,
	value = 150,
	rating = 20,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "dwarven",
	orientation = "right",
}
-- Ebony Left Bracer
itemsList["ebony_bracer_left"] = {
	name = "Ebony Left Bracer",
	id = "ebony_bracer_left",
	itemType = "armor",
	subtype = "bracer",
	weight = 10,
	health = 300,
	value = 5000,
	rating = 60,
	enchant = 40,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "ebony",
	orientation = "left",
}
-- Ebony Right Bracer
itemsList["ebony_bracer_right"] = {
	name = "Ebony Right Bracer",
	id = "ebony_bracer_right",
	itemType = "armor",
	subtype = "bracer",
	weight = 10,
	health = 300,
	value = 5000,
	rating = 60,
	enchant = 40,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "ebony",
	orientation = "right",
}
-- Iron Left Bracer
itemsList["iron_bracer_left"] = {
	name = "Iron Left Bracer",
	id = "iron_bracer_left",
	itemType = "armor",
	subtype = "bracer",
	weight = 5,
	health = 50,
	value = 10,
	rating = 10,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron",
	orientation = "left",
}
-- Iron Right Bracer
itemsList["iron_bracer_right"] = {
	name = "Iron Right Bracer",
	id = "iron_bracer_right",
	itemType = "armor",
	subtype = "bracer",
	weight = 5,
	health = 50,
	value = 10,
	rating = 10,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron",
	orientation = "right",
}
-- Imperial Templar Left Bracer
itemsList["templar bracer left"] = {
	name = "Imperial Templar Left Bracer",
	id = "templar bracer left",
	itemType = "armor",
	subtype = "bracer",
	weight = 5,
	health = 90,
	value = 25,
	rating = 18,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "iron",
	orientation = "left",
}
-- Imperial Templar Right Bracer
itemsList["templar bracer right"] = {
	name = "Imperial Templar Right Bracer",
	id = "templar bracer right",
	itemType = "armor",
	subtype = "bracer",
	weight = 5,
	health = 90,
	value = 25,
	rating = 18,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "iron",
	orientation = "right",
}
-- Iron Left Gauntlet
itemsList["iron_gauntlet_left"] = {
	name = "Iron Left Gauntlet",
	id = "iron_gauntlet_left",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 7,
	health = 50,
	value = 14,
	rating = 10,
	enchant = 2.5,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron",
	orientation = "left",
}
-- Iron Right Gauntlet
itemsList["iron_gauntlet_right"] = {
	name = "Iron Right Gauntlet",
	id = "iron_gauntlet_right",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 7,
	health = 50,
	value = 14,
	rating = 10,
	enchant = 1, --Different enchant value than left
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron",
	orientation = "right",
}
-- Daedric Left Gauntlet
itemsList["daedric_gauntlet_left"] = {
	name = "Daedric Left Gauntlet",
	id = "daedric_gauntlet_left",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 15,
	health = 400,
	value = 14000,
	rating = 80,
	enchant = 60,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "daedric",
	orientation = "left",
}
-- Daedric Right Gauntlet
itemsList["daedric_gauntlet_right"] = {
	name = "Daedric Right Gauntlet",
	id = "daedric_gauntlet_rightt",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 15,
	health = 400,
	value = 14000,
	rating = 80,
	enchant = 60,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "daedric",
	orientation = "right",
}
-- Imperial Steel Left Gauntlet
itemsList["imperial left gauntlet"] = {
	name = "Imperial Steel Left Gauntlet",
	id = "imperial left gauntlet",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 5,
	health = 80,
	value = 33,
	rating = 16,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel",
	orientation = "left",
}
-- Imperial Steel Right Gauntlet
itemsList["imperial right gauntlet"] = {
	name = "Imperial Steel Right Gauntlet",
	id = "imperial right gauntlet",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 5,
	health = 80,
	value = 33,
	rating = 16,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel",
	orientation = "right",
}
-- Steel Left Gauntlet
itemsList["steel_gauntlet_left"] = {
	name = "Steel Left Gauntlet",
	id = "steel_gauntlet_left",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 5,
	health = 75,
	value = 28,
	rating = 15,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel",
	orientation = "left",
}
-- Steel Right Gauntlet
itemsList["steel_gauntlet_right"] = {
	name = "Steel Right Gauntlet",
	id = "steel_gauntlet_right",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 5,
	health = 75,
	value = 28,
	rating = 15,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel",
	orientation = "right",
}

--Daedric Shield
itemsList["daedric_shield"] = {
	name = "Daedric Shield",
	id = "daedric_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 45,
	health = 1600,
	value = 34000,
	rating = 80,
	enchant = 150,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "daedric",
	hand = 1,
}
--Dwemer Shield
itemsList["dwemer_shield"] = {
	name = "Dwemer Shield",
	id = "dwemer_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 15,
	health = 400,
	value = 510,
	rating = 20,
	enchant = 50,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "dwarven",
	hand = 1,
}
--Ebony Shield
itemsList["ebony_shield"] = {
	name = "Ebony Shield",
	id = "ebony_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 30,
	health = 1200,
	value = 17000,
	rating = 60,
	enchant = 100,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "ebony",
	hand = 1,
}
--Iron Shield
itemsList["iron_shield"] = {
	name = "Iron Shield",
	id = "iron_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 15,
	health = 200,
	value = 34,
	rating = 10,
	enchant = 50,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron",
	hand = 1,
}
-- Nordic Trollbone Shield
itemsList["trollbone_shield"] = {
	name = "Nordic Trollbone Shield",
	id = "trollbone_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 16,
	health = 360,
	value = 78,
	rating = 18,
	enchant = 40,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "bone",
	hand = 1,
}
-- Steel Shield
itemsList["steel_shield"] = {
	name = "Steel Shield",
	id = "steel_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 15,
	health = 300,
	value = 68,
	rating = 15,
	enchant = 50,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel",
	hand = 1,
}
-- Daedric Tower Shield
itemsList["daedric_towershield"] = {
	name = "Daedric Tower Shield",
	id = "daedric_towershield",
	itemType = "armor",
	subtype = "tower shield",
	weight = 45,
	health = 1600,
	value = 50000,
	rating = 80,
	enchant = 225,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "daedric",
	hand = 1,
}
-- Ebony Tower Shield
itemsList["ebony_towershield"] = {
	name = "Ebony Tower Shield",
	id = "ebony_towershield",
	itemType = "armor",
	subtype = "tower shield",
	weight = 30,
	health = 1200,
	value = 25000,
	rating = 60,
	enchant = 150,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "ebony",
	hand = 1,
}
-- Imperial Shield
itemsList["imperial shield"] = {
	name = "Imperial Shield",
	id = "imperial shield",
	itemType = "armor",
	subtype = "tower shield", --?
	weight = 14,
	health = 320,
	value = 78,
	rating = 16,
	enchant = 50,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron", --?
	hand = 1,
}
-- Iron Tower Shield
itemsList["iron_towershield"] = {
	name = "Iron Tower Shield",
	id = "iron_towershield",
	itemType = "armor",
	subtype = "tower shield",
	weight = 18,
	health = 240,
	value = 50,
	rating = 12,
	enchant = 75,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron",
	hand = 1,
}
-- Steel Tower Shield
itemsList["steel_towershield"] = {
	name = "Steel Tower Shield",
	id = "steel_towershield",
	itemType = "armor",
	subtype = "tower shield",
	weight = 20,
	health = 360,
	value = 100,
	rating = 18,
	enchant = 75,
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel",
	hand = 1,
}

--Tribunal Base Armor
--Dark Brotherhood Helm
itemsList["DarkBrotherhood Helm"] = {
	name = "Dark Brotherhood Helm",
	id = "DarkBrotherhood Helm",
	itemType = "armor",
	subtype = "helm",
	weight = 1,
	health = 300,
	value = 200,
	rating = 30,
	enchant = 17.5,
	skillId = 21,
	skillName = "Lightarmor", 
	--material = "material",
}
--Dark Brotherhood Cuirass
itemsList["DarkBrotherhood Cuirass"] = {
	name = "Dark Brotherhood Cuirass",
	id = "DarkBrotherhood Cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 6,
	health = 300,
	value = 1000,
	rating = 30,
	enchant = 10,
	skillId = 21,
	skillName = "Lightarmor", 
	--material = "material",
}
--Dark Brotherhood Left Pauldron
itemsList["DarkBrotherhood pauldron_L"] = {
	name = "Dark Brotherhood Left Pauldron",
	id = "DarkBrotherhood pauldron_L",
	itemType = "armor",
	subtype = "pauldron",
	weight = 1,
	health = 250,
	value = 500,
	rating = 30,
	enchant = 1.2,
	skillId = 21,
	skillName = "Lightarmor", 
	--material = "material",
	oreintation = "left"
}
--Dark Brotherhood Right Pauldron
itemsList["DarkBrotherhood pauldron_R"] = {
	name = "Dark Brotherhood Right Pauldron",
	id = "DarkBrotherhood pauldron_R",
	itemType = "armor",
	subtype = "pauldron",
	weight = 1,
	health = 250,
	value = 500,
	rating = 30,
	enchant = 1.2,
	skillId = 21,
	skillName = "Lightarmor", 
	--material = "material",
	oreintation = "right"
}
--Dark Brotherhood Greaves
itemsList["DarkBrotherhood greaves"] = {
	name = "Dark Brotherhood Greaves",
	id = "DarkBrotherhood greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 3,
	health = 250,
	value = 100,
	rating = 30,
	enchant = 5,
	skillId = 21,
	skillName = "Lightarmor", 
	--material = "material",
}
--Dark Brotherhood Boots
itemsList["DarkBrotherhood Boots"] = {
	name = "Dark Brotherhood Boots",
	id = "DarkBrotherhood Boots",
	itemType = "armor",
	subtype = "boots",
	weight = 2,
	health = 200,
	value = 500,
	rating = 30,
	enchant = 3,
	skillId = 21,
	skillName = "Lightarmor", 
	--material = "material",
}
--Dark Brotherhood Left Gauntlet
itemsList["DarkBrotherhood gauntlet_L"] = {
	name = "Dark Brotherhood Left Gauntlet",
	id = "DarkBrotherhood gauntlet_L",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 1,
	health = 100,
	value = 200,
	rating = 30,
	enchant = 10,
	skillId = 21,
	skillName = "Lightarmor",
	--material = "material",
	orientation = "left"
}
--Dark Brotherhood Right Gauntlet
itemsList["DarkBrotherhood gauntlet_R"] = {
	name = "Dark Brotherhood Right Gauntlet",
	id = "DarkBrotherhood gauntlet_R",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 1,
	health = 100,
	value = 200,
	rating = 30,
	enchant = 10,
	skillId = 21,
	skillName = "Lightarmor",
	--material = "material",
	orientation = "right"
}
--Goblin Buckler
itemsList["goblin_shield"] = {
	name = "Goblin Buckler",
	id = "goblin_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 5,
	health = 500,
	value = 1000,
	rating = 20,
	enchant = 10,
	skillId = 21,
	skillName = "Lightarmor", 
	hand = 1,
	--material = "material",
}

--Adamantium Helm
itemsList["adamantium_helm"] = {
	name = "Adamantium Helm",
	id = "adamantium_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 4,
	health = 900,
	value = 5000,
	rating = 70,
	enchant = 50,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "adamantium",
	canBeast = true,
}
--Adamantium Helm 2
itemsList["addamantium_helm"] = {
	name = "Adamantium Helm",
	id = "addamantium_helm", --Typo'd dupe version exists ingame
	itemType = "armor",
	subtype = "helm",
	weight = 4,
	health = 900,
	value = 5000,
	rating = 70,
	enchant = 50,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "adamantium",
	canBeast = true,
}
--Adamantium Cuirass
itemsList["adamantium_cuirass"] = {
	name = "Adamantium Cuirass",
	id = "adamantium_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 25,
	health = 900,
	value = 10000,
	rating = 40,
	enchant = 30,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "adamantium",
}
--Adamantium Left Pauldron
itemsList["adamantium_pauldron_left"] = {
	name = "Adamantium Left Pauldron",
	id = "adamantium_pauldron_left",
	itemType = "armor",
	subtype = "pauldron",
	weight = 7,
	health = 400,
	value = 800,
	rating = 40,
	enchant = 3,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "adamantium",
	orientation = "left",
}
--Adamantium Right Pauldron
itemsList["adamantium_pauldron_right"] = {
	name = "Adamantium Right Pauldron",
	id = "adamantium_pauldron_right",
	itemType = "armor",
	subtype = "pauldron",
	weight = 7,
	health = 400,
	value = 800,
	rating = 40,
	enchant = 10, --Has different enchant than left version
	skillId = 2,
	skillName = "Mediumarmor",
	material = "adamantium",
	orientation = "right",
}
--Adamantium Greaves
itemsList["adamantium_greaves"] = {
	name = "Adamantium Greaves",
	id = "adamantium_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 13,
	health = 400,
	value = 10000,
	rating = 40,
	enchant = 3,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "adamantium",
}
--Adamantium Boots
itemsList["adamantium boots"] = {
	name = "Adamantium Boots",
	id = "adamantium boots",
	itemType = "armor",
	subtype = "boots",
	weight = 15,
	health = 400,
	value = 7000,
	rating = 40,
	enchant = 10,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "adamantium",
}
--Adamantium Left Bracer
itemsList["adamantium_bracer_left"] = {
	name = "Adamantium Left Bracer",
	id = "adamantium_bracer_left",
	itemType = "armor",
	subtype = "bracer",
	weight = 4,
	health = 200,
	value = 1000,
	rating = 40,
	enchant = 10,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "adamantium",
	orientation = "left"
}
--Adamantium Right Bracer
itemsList["adamantium_bracer_right"] = {
	name = "Adamantium Right Bracer",
	id = "adamantium_bracer_right",
	itemType = "armor",
	subtype = "bracer",
	weight = 4,
	health = 200,
	value = 1000,
	rating = 40,
	enchant = 10,
	skillId = 2,
	skillName = "Mediumarmor",
	material = "adamantium",
	orientation = "right"
}

--Royal Guard Helm
itemsList["Helsethguard_Helmet"] = {
	name = "Royal Guard Helm",
	id = "Helsethguard_Helmet",
	itemType = "armor",
	subtype = "helm",
	weight = 4,
	health = 550,
	value = 550,
	rating = 55,
	enchant = 30,
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "material",
}
--Royal Guard Cuirass
itemsList["Helsethguard_cuirass"] = {
	name = "Royal Guard Cuirass",
	id = "Helsethguard_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 27,
	health = 1500,
	value = 8000,
	rating = 55,
	enchant = 25,
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "material",
}
--Royal Guard Left Pauldron
itemsList["Helsethguard_pauldron_left"] = {
	name = "Royal Guard Left Pauldron",
	id = "Helsethguard_pauldron_left",
	itemType = "armor",
	subtype = "pauldron",
	weight = 9,
	health = 550,
	value = 3000,
	rating = 55,
	enchant = 3,
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "material",
	orientation = "left",
}
--Royal Guard Right Pauldron
itemsList["Helsethguard_pauldron_right"] = {
	name = "Royal Guard Right Pauldron",
	id = "Helsethguard_pauldron_right",
	itemType = "armor",
	subtype = "pauldron",
	weight = 9,
	health = 550,
	value = 3000,
	rating = 55,
	enchant = 3,
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "material",
	orientation = "right",
}
--Royal Guard Greaves
itemsList["Helsethguard_greaves"] = {
	name = "Royal Guard Greaves",
	id = "Helsethguard_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 12,
	health = 300,
	value = 2000,
	rating = 40,
	enchant = 4,
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "material",
}
--Royal Guard Boots
itemsList["Helsethguard_boots"] = {
	name = "Royal Guard Boots",
	id = "Helsethguard_boots",
	itemType = "armor",
	subtype = "boots",
	weight = 18,
	health = 500,
	value = 2500,
	rating = 50,
	enchant = 15,
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "material",
}
--Royal Guard Left Gauntlet
itemsList["Helsethguard_gauntlet_left"] = {
	name = "Royal Guard Left Gauntlet",
	id = "Helsethguard_gauntlet_left",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 4,
	health = 225,
	value = 2000,
	rating = 55,
	enchant = 12,
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "material",
	orientation = "left",
}
--Royal Guard Right Gauntlet
itemsList["Helsethguard_gauntlet_right"] = {
	name = "Royal Guard Right Gauntlet",
	id = "Helsethguard_gauntlet_right",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 4,
	health = 225,
	value = 2000,
	rating = 55,
	enchant = 12,
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "material",
	orientation = "right",
}

--Her Hand's Helmet
itemsList["Indoril_MH_Guard_helmet"] = {
	name = "Her Hand's Helmet",
	id = "Indoril_MH_Guard_helmet",
	itemType = "armor",
	subtype = "helm",
	weight = 15,
	health = 700,
	value = 12000,
	rating = 75,
	enchant = 65,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "material",
	ordinatorUniform = true,
}
--Her Hand's Cuirass
itemsList["Indoril_MH_Guard_Cuirass"] = {
	name = "Her Hand's Cuirass",
	id = "Indoril_MH_Guard_Cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 90,
	health = 2800,
	value = 50000,
	rating = 70,
	enchant = 55,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "material",
	ordinatorUniform = true,
}
--Her Hand's Left Pauldron
itemsList["Indoril_MH_Guard_Pauldron_L"] = {
	name = "Her Hand's Left Pauldron",
	id = "Indoril_MH_Guard_Pauldron_L",
	itemType = "armor",
	subtype = "pauldron",
	weight = 30,
	health = 700,
	value = 20000,
	rating = 70,
	enchant = 5,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "material",
	orientation = "left",
}
--Her Hand's Right Pauldron
itemsList["Indoril_MH_Guard_Pauldron_R"] = {
	name = "Her Hand's Right Pauldron",
	id = "Indoril_MH_Guard_Pauldron_R",
	itemType = "armor",
	subtype = "pauldron",
	weight = 30,
	health = 700,
	value = 20000,
	rating = 70,
	enchant = 5,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "material",
	orientation = "right",
}
--Her Hand's Greaves
itemsList["Indoril_MH_Guard_Greaves"] = {
	name = "Her Hand's Greaves",
	id = "Indoril_MH_Guard_Greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 45,
	health = 700,
	value = 33000,
	rating = 70,
	enchant = 6,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "material",
}
--Her Hand's Boots
itemsList["Indoril_MH_Guard_boots"] = {
	name = "Her Hand's Boots",
	id = "Indoril_MH_Guard_boots",
	itemType = "armor",
	subtype = "boots",
	weight = 60,
	health = 700,
	value = 15000,
	rating = 70,
	enchant = 20,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "material",
}
--Her Hand's Left Gauntlet
itemsList["Indoril_MH_Guard_gauntlet_L"] = {
	name = "Her Hand's Left Gauntlet",
	id = "Indoril_MH_Guard_gauntlet_L",
	itemType = "armor",
	subtype = "boots",
	weight = 15,
	health = 300,
	value = 13000,
	rating = 70,
	enchant = 50,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "material",
	orientation = "left"
}
--Her Hand's Right Gauntlet
itemsList["Indoril_MH_Guard_gauntlet_R"] = {
	name = "Her Hand's Right Gauntlet",
	id = "Indoril_MH_Guard_gauntlet_R",
	itemType = "armor",
	subtype = "boots",
	weight = 15,
	health = 300,
	value = 13000,
	rating = 70,
	enchant = 50,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "material",
	orientation = "right"
}
--Her Hand's Shield
itemsList["Indoril_MH_Guard_shield"] = {
	name = "Her Hand's Shield",
	id = "Indoril_MH_Guard_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 17,
	health = 320,
	value = 2500,
	rating = 55,
	enchant = 50,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "material",
	hand = 1,
}
--Dwemer Battle Shield
itemsList["dwemer_shield_battle_unique"] = {
	name = "Dwemer Battle Shield",
	id = "dwemer_shield_battle_unique",
	itemType = "armor",
	subtype = "shield",
	weight = 15,
	health = 400,
	value = 510,
	rating = 20,
	enchant = 50,
	skillId = 3,
	skillName = "Heavyarmor",
	--material = "material",
	hand = 1,
}

--Bloodmoon Base Armor
--Wolf Boots
itemsList["BM wolf boots"] = {
	name = "Wolf Boots",
	id = "BM wolf boots",
	itemType = "armor",
	subtype = "boots",
	weight = 4,
	health = 105,
	value = 50,
	rating = 15,
	enchant = 2,
	skillId = 21,
	skillName = "Lightarmor",
	material = "fur",
}
--Wolf Cuirass
itemsList["BM wolf cuirass"] = {
	name = "Wolf Cuirass",
	id = "BM wolf cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 9,
	health = 325,
	value = 150,
	rating = 15,
	enchant = 6,
	skillId = 21,
	skillName = "Lightarmor",
	material = "fur",
}
--Wolf Greaves
itemsList["BM wolf greaves"] = {
	name = "Wolf Greaves",
	id = "BM wolf greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 7,
	health = 220,
	value = 120,
	rating = 15,
	enchant = 4.5,
	skillId = 21,
	skillName = "Lightarmor",
	material = "fur",
}
--Wolf Helmet
itemsList["BM Wolf Helmet"] = {
	name = "Wolf Helmet",
	id = "BM Wolf Helmet",
	itemType = "armor",
	subtype = "helm",
	weight = 2,
	health = 100,
	value = 40,
	rating = 15,
	enchant = 2,
	skillId = 21,
	skillName = "Lightarmor",
	material = "fur",
	canBeast = true,
}
--Wolf Left Gauntlet
itemsList["BM wolf left gauntlet"] = {
	name = "Wolf Left Gauntlet",
	id = "BM wolf left gauntlet",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 1.5,
	health = 80,
	value = 40,
	rating = 15,
	enchant = 2,
	skillId = 1,
	skillName = "Lightarmor",
	material = "fur",
	orientation = "left"
}
--Wolf Right Gauntlet
itemsList["BM wolf right gauntlet"] = {
	name = "Wolf Right Gauntlet",
	id = "BM wolf right gauntlet",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 1.5,
	health = 80,
	value = 40,
	rating = 15,
	enchant = 2,
	skillId = 1,
	skillName = "Lightarmor",
	material = "fur",
	orientation = "right"
}
--Wolf Left Pauldron
itemsList["BM Wolf Left Pauldron"] = {
	name = "Wolf Left Pauldron",
	id = "BM Wolf Left Pauldron",
	itemType = "armor",
	subtype = "pauldron",
	weight = 2.4,
	health = 100,
	value = 60,
	rating = 15,
	enchant = 1.6,
	skillId = 1,
	skillName = "Lightarmor",
	material = "fur",
	orientation = "left"
}
--Wolf Right Pauldron
itemsList["BM Wolf right pauldron"] = {
	name = "Wolf Right Pauldron",
	id = "BM Wolf right pauldron",
	itemType = "armor",
	subtype = "pauldron",
	weight = 2.4,
	health = 100,
	value = 60,
	rating = 15,
	enchant = 1.6,
	skillId = 1,
	skillName = "Lightarmor",
	material = "fur",
	orientation = "right"
}
--Wolf Shield
itemsList["BM wolf shield"] = {
	name = "Wolf Shield",
	id = "BM wolf shield",
	itemType = "armor",
	subtype = "shield",
	weight = 8,
	health = 100,
	value = 100,
	rating = 15,
	enchant = 5,
	skillId = 21,
	skillName = "Lightarmor",
	material = "fur",
	hand = 1,
}
--Riekling Shield
itemsList["BM_Ice minion_Shield1"] = {
	name = "Riekling Shield",
	id = "BM_Ice minion_Shield1",
	itemType = "armor",
	subtype = "shield",
	weight = 2,
	health = 200,
	value = 50,
	rating = 12,
	enchant = 8,
	skillId = 21,
	skillName = "Lightarmor",
	material = "fur", --?
	hand = 1,
}

--Bear Boots
itemsList["BM bear boots"] = {
	name = "Bear Boots",
	id = "BM bear boots",
	itemType = "armor",
	subtype = "boots",
	weight = 14,
	health = 105,
	value = 50,
	rating = 15,
	enchant = 2,
	skillId = 2, 
	skillName = "Mediumarmor",
	material = "fur",
}
--Bear Cuirass
itemsList["BM bear cuirass"] = {
	name = "Bear Cuirass",
	id = "BM bear cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 25,
	health = 325,
	value = 150,
	rating = 15,
	enchant = 6,
	skillId = 2, 
	skillName = "Mediumarmor",
	material = "fur",
}
--Bear Greaves
itemsList["BM bear greaves"] = {
	name = "Bear Greaves",
	id = "BM bear greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 10,
	health = 220,
	value = 120,
	rating = 15,
	enchant = 4.5,
	skillId = 2, 
	skillName = "Mediumarmor",
	material = "fur",
}
--Bear Helmet
itemsList["BM Bear Helmet"] = {
	name = "Bear Helmet",
	id = "BM Bear Helmet",
	itemType = "armor",
	subtype = "helm",
	weight = 4,
	health = 100,
	value = 40,
	rating = 15,
	enchant = 2,
	skillId = 2, 
	skillName = "Mediumarmor",
	material = "fur",
	canBeast = true,
}
--Bear Left Gauntlet
itemsList["bm bear left gauntlet"] = {
	name = "Bear Left Gauntlet",
	id = "bm bear left gauntlet",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 4,
	health = 80,
	value = 40,
	rating = 15,
	enchant = 1,
	skillId = 2, 
	skillName = "Mediumarmor",
	material = "fur",
	orientation = "left",
}
--Bear Right Gauntlet
itemsList["BM bear right gauntlet"] = {
	name = "Bear Right Gauntlet",
	id = "BM bear right gauntlet",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 4,
	health = 80,
	value = 40,
	rating = 15,
	enchant = 1,
	skillId = 2, 
	skillName = "Mediumarmor",
	material = "fur",
	orientation = "right",
}
--Bear Shield
itemsList["BM bear shield"] = {
	name = "Bear Shield",
	id = "BM bear shield",
	itemType = "armor",
	subtype = "shield",
	weight = 10,
	health = 150,
	value = 100,
	rating = 15,
	enchant = 2,
	skillId = 2, 
	skillName = "Mediumarmor",
	material = "fur",
	hand = 1,
}

--Ice Armor Boots
itemsList["BM_Ice_Boots"] = {
	name = "Ice Armor Boots",
	id = "BM_Ice_Boots",
	itemType = "armor",
	subtype = "boots",
	weight = 17,
	health = 200,
	value = 5000,
	rating = 50,
	enchant = 10,
	skillId = 2, 
	skillName = "Mediumarmor",
	material = "stalhrim",
}
--Ice Armor Cuirass
itemsList["BM_Ice_cuirass"] = {
	name = "Ice Armor Cuirass",
	id = "BM_Ice_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 27,
	health = 1000,
	value = 5000,
	rating = 50,
	enchant = 18,
	skillId = 2, 
	skillName = "Mediumarmor",
	material = "stalhrim",
}
--Ice Armor Greaves
itemsList["BM_Ice_greaves"] = {
	name = "Ice Armor Greaves",
	id = "BM_Ice_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 12,
	health = 600,
	value = 1000,
	rating = 50,
	enchant = 10,
	skillId = 2, 
	skillName = "Mediumarmor",
	material = "stalhrim",
}
--Ice Armor Helmet
itemsList["BM_Ice_helmet"] = {
	name = "Ice Armor Helmet",
	id = "BM_Ice_helmet",
	itemType = "armor",
	subtype = "helm",
	weight = 4,
	health = 500,
	value = 2000,
	rating = 50,
	enchant = 17.5,
	skillId = 2, 
	skillName = "Mediumarmor",
	material = "stalhrim",
	canBeast = true,
}
--Ice Armor Left Gauntlet
itemsList["BM_Ice_gauntletL"] = {
	name = "Ice Armor Left Gauntlet",
	id = "BM_Ice_gauntletL",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 4,
	health = 300,
	value = 1000,
	rating = 50,
	enchant = 10,
	skillId = 2, 
	skillName = "Mediumarmor",
	material = "stalhrim",
	orientation = "left"
}
--Ice Armor Right Gauntlet
itemsList["BM_Ice_gauntletR"] = {
	name = "Ice Armor Right Gauntlet",
	id = "BM_Ice_gauntletR",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 4,
	health = 300,
	value = 1000,
	rating = 50,
	enchant = 10,
	skillId = 2, 
	skillName = "Mediumarmor",
	material = "stalhrim",
	orientation = "right"
}
--Ice Armor Left Pauldron
itemsList["BM_Ice_PauldronL"] = {
	name = "Ice Armor Left Pauldron",
	id = "BM_Ice_PauldronL",
	itemType = "armor",
	subtype = "pauldron",
	weight = 8,
	health = 550,
	value = 12000,
	rating = 50,
	enchant = 1.8,
	skillId = 2, 
	skillName = "Mediumarmor",
	material = "stalhrim",
	orientation = "left",
}
--Ice Armor Right Pauldron
itemsList["BM_Ice_PauldronR"] = {
	name = "Ice Armor Right Pauldron",
	id = "BM_Ice_PauldronR",
	itemType = "armor",
	subtype = "pauldron",
	weight = 8,
	health = 550,
	value = 12000,
	rating = 50,
	enchant = 1.8,
	skillId = 2, 
	skillName = "Mediumarmor",
	material = "stalhrim",
	orientation = "right",
}
--Ice Shield
itemsList["BM_Ice_Shield"] = {
	name = "Ice shield",
	id = "BM_Ice_Shield",
	itemType = "armor",
	subtype = "shield", --or tower shield?
	weight = 13,
	health = 400,
	value = 1000,
	rating = 50,
	enchant = 40,
	skillId = 2, 
	skillName = "Mediumarmor",
	material = "stalhrim",
	hand = 1,
}

--Nordic Mail Boots
itemsList["BM_NordicMail_Boots"] = {
	name = "Nordic Mail Boots",
	id = "BM_NordicMail_Boots",
	itemType = "armor",
	subtype = "boots",
	weight = 20,
	health = 500,
	value = 5000,
	rating = 66,
	enchant = 8.5,
	skillId = 3, 
	skillName = "Heavyarmor",
	material = "nordic", --?
}
--Nordic Mail Cuirass
itemsList["BM_NordicMail_cuirass"] = {
	name = "Nordic Mail Cuirass",
	id = "BM_NordicMail_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 30,
	health = 1000,
	value = 5000,
	rating = 66,
	enchant = 30,
	skillId = 3, 
	skillName = "Heavyarmor",
	material = "nordic", --?
}
--Nordic Mail Greaves
itemsList["BM_NordicMail_greaves"] = {
	name = "Nordic Mail Greaves",
	id = "BM_NordicMail_greaves",
	itemType = "armor",
	subtype = "greaves",
	weight = 18,
	health = 300,
	value = 2000,
	rating = 66,
	enchant = 8,
	skillId = 3, 
	skillName = "Heavyarmor",
	material = "nordic", --?
}
--Nordic Mail Helmet
itemsList["BM_NordicMail_Helmet"] = {
	name = "Nordic Mail Helmet",
	id = "BM_NordicMail_Helmet",
	itemType = "armor",
	subtype = "helm",
	weight = 8,
	health = 350,
	value = 1000,
	rating = 66,
	enchant = 20,
	skillId = 3, 
	skillName = "Heavyarmor",
	material = "nordic", --?
	canBeast = true,
}
--Nordic Mail Left Gauntlet
itemsList["BM_NordicMail_gauntletL"] = {
	name = "Nordic Mail Left Gauntlet",
	id = "BM_NordicMail_gauntletL",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 8,
	health = 100,
	value = 1000,
	rating = 66,
	enchant = 10,
	skillId = 3, 
	skillName = "Heavyarmor",
	material = "nordic", --?
	orientation = "left",
}
--Nordic Mail Right Gauntlet
itemsList["BM_NordicMail_gauntletR"] = {
	name = "Nordic Mail Right Gauntlet",
	id = "BM_NordicMail_gauntletR",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 8,
	health = 100,
	value = 1000,
	rating = 66,
	enchant = 10,
	skillId = 3, 
	skillName = "Heavyarmor",
	material = "nordic", --?
	orientation = "right",
}
--Nordic Mail Left Pauldron
itemsList["BM_NordicMail_PauldronL"] = {
	name = "Nordic Mail Left Pauldron",
	id = "BM_NordicMail_PauldronL",
	itemType = "armor",
	subtype = "pauldron",
	weight = 10,
	health = 100,
	value = 1000,
	rating = 66,
	enchant = 10,
	skillId = 3, 
	skillName = "Heavyarmor",
	material = "nordic", --?
	orientation = "left",
}
--Nordic Mail Right Pauldron
itemsList["BM_NordicMail_PauldronR"] = {
	name = "Nordic Mail Right Pauldron",
	id = "BM_NordicMail_PauldronR",
	itemType = "armor",
	subtype = "pauldron",
	weight = 10,
	health = 100,
	value = 1000,
	rating = 66,
	enchant = 10,
	skillId = 3, 
	skillName = "Heavyarmor",
	material = "nordic", --?
	orientation = "right",
}
--Nordic Mail Shield
itemsList["BM_NordicMail_Shield"] = {
	name = "Nordic Mail Shield",
	id = "BM_NordicMail_Shield",
	itemType = "armor",
	subtype = "shield", --or tower shield?
	weight = 20,
	health = 500,
	value = 1000,
	rating = 66,
	enchant = 10,
	skillId = 3, 
	skillName = "Heavyarmor",
	material = "nordic", --?
	hand = 1,
}
-- *GENERIC MAGIC ARMOR*
--Morrowind Generic Magic Armor
--Cuirass
--Chest of Fire
itemsList["chest of fire"] = {
	name = "Chest of Fire",
	id = "chest of fire",
	itemType = "armor",
	subtype = "cuirass",
	weight = 6,
	health = 300,
	value = 80,
	rating = 10,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin",
	baseItem = "chitin cuirass",
	effectData = {},
}
--Heart Wall
itemsList["heart wall"] = {
	name = "Heart Wall",
	id = "heart wall",
	itemType = "armor",
	subtype = "cuirass",
	weight = 24,
	health = 510,
	value = 100,
	rating = 17,
	--enchant = 0, --already enchanted
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	baseItem = "	bonemold_gah-julan_cuirass",
	effectData = {},
}
--Merisan Cuirass
itemsList["merisan_cuirass"] = {
	name = "Merisan Cuirass",
	id = "merisan_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 12,
	health = 150,
	value = 55,
	rating = 10,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather",
	baseItem = "netch_leather_cuirass",
	effectData = {},
}
--The Chiding Cuirass
itemsList["the_chiding_cuirass"] = {
	name = "The Chiding Cuirass",
	id = "the_chiding_cuirass",
	itemType = "armor",
	subtype = "cuirass",
	weight = 6,
	health = 300,
	value = 280,
	rating = 10,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin",
	baseItem = "chitin cuirass",
	effectData = {},
}
--Gauntlets
--Bonemold Brace of Horny Fist
itemsList["lbonemold brace of horny fist"] = {
	name = "Bonemold Brace of Horny Fist",
	id = "lbonemold brace of horny fist",
	itemType = "armor",
	subtype = "bracer",
	weight = 4,
	health = 75,
	value = 30,
	rating = 15,
	--enchant = 0, --already enchanted
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	baseItem = "bonemold_bracer_left",
	effectData = {},
	orientation = "left",
}
--Bonemold Bracer of Horny Fist
itemsList["rbonemold bracer of horny fist"] = {
	name = "Bonemold Bracer of Horny Fist",
	id = "rbonemold bracer of horny fist",
	itemType = "armor",
	subtype = "bracer",
	weight = 4,
	health = 75,
	value = 30,
	rating = 15,
	--enchant = 0, --already enchanted
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	baseItem = "bonemold_bracer_right",
	effectData = {},
	orientation = "right",
}
--Left Cloth Horny Fist Bracer
itemsList["left cloth horny fist bracer"] = {
	name = "Left Cloth Horny Fist Bracer",
	id = "left cloth horny fist bracer",
	itemType = "armor",
	subtype = "bracer",
	weight = 1.5,
	health = 20,
	value = 7,
	rating = 4,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "cloth",
	baseItem = "cloth bracer left",
	effectData = {},
	orientation = "left",
}
--Right Cloth Horny Fist Bracer
itemsList["right cloth horny fist bracer"] = {
	name = "Right Cloth Horny Fist Bracer",
	id = "right cloth horny fist bracer",
	itemType = "armor",
	subtype = "bracer",
	weight = 1.5,
	health = 20,
	value = 7,
	rating = 4,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "cloth",
	baseItem = "cloth bracer right",
	effectData = {},
	orientation = "right",
}
--Left Gauntlet of the Horny Fist
itemsList["left gauntlet of the horny fist"] = {
	name = "Left Gauntlet of the Horny Fist",
	id = "left gauntlet of the horny fist",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 1,
	health = 50,
	value = 15,
	rating = 10,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin",
	baseItem = "chitin guantlet - left",
	effectData = {},
	orientation = "left",
}
--Right Gauntlet of Horny Fist
itemsList["right gauntlet of horny fist"] = {
	name = "Right Gauntlet of Horny Fist",
	id = "right gauntlet of horny fist",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 1,
	health = 50,
	value = 15,
	rating = 10,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin",
	baseItem = "chitin guantlet - right",
	effectData = {},
	orientation = "right",
}
--Left Glove of the Horny Fist
itemsList["left_horny_fist_gauntlet"] = {
	name = "Left Glove of the Horny Fist",
	id = "left_horny_fist_gauntlet",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 3,
	health = 25,
	value = 10,
	rating = 5,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather",
	baseItem = "netch_leather_gauntlet_left",
	effectData = {},
	orientation = "left",
}
--Right Glove of the Horny Fist
itemsList["right horny fist gauntlet"] = {
	name = "Right Glove of the Horny Fist",
	id = "right horny fist gauntlet",
	itemType = "armor",
	subtype = "gauntlet",
	weight = 3,
	health = 25,
	value = 10,
	rating = 5,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather",
	baseItem = "netch_leather_gauntlet_right",
	effectData = {},
	orientation = "right",
}
--Slave's Left Bracer
itemsList["slave_bracer_left"] = {
	name = "Slave's Left Bracer",
	id = "slave_bracer_left",
	itemType = "armor",
	subtype = "bracer",
	weight = 5,
	health = 25,
	value = 5,
	rating = 5,
	--enchant = 0, --already enchanted
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron", --?
	--baseItem = "id", --No base item according to wiki?
	effectData = {},
	orientation = "left",
}
--Slave's Right Bracer
itemsList["slave_bracer_right"] = {
	name = "Slave's Right Bracer",
	id = "slave_bracer_right",
	itemType = "armor",
	subtype = "bracer",
	weight = 5,
	health = 25,
	value = 5,
	rating = 5,
	--enchant = 0, --already enchanted
	skillId = 3,
	skillName = "Heavyarmor",
	material = "iron", --?
	--baseItem = "id", --No base item according to wiki?
	effectData = {},
	orientation = "right",
}

--Helmets
--Demon Cephalopod
itemsList["demon cephalopod"] = {
	name = "Demon Cephalopod",
	id = "demon cephalopod",
	itemType = "armor",
	subtype = "helm",
	weight = 2,
	health = 80,
	value = 1500,
	rating = 8,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin", --?
	baseItem = "cephalopod_helm",
	effectData = {},
}
--Demon Helm
itemsList["demon helm"] = {
	name = "Demon Helm",
	id = "demon helm",
	itemType = "armor",
	subtype = "helm",
	weight = 1.5,
	health = 50,
	value = 800,
	rating = 5,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin", --?
	baseItem = "dust_adept_helm",
	effectData = {},
}
--Demon Mole Crab
itemsList["demon mole crab"] = {
	name = "Demon Mole Crab",
	id = "demon mole crab",
	itemType = "armor",
	subtype = "helm",
	weight = 2,
	health = 60,
	value = 900,
	rating = 6,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin", --?
	baseItem = "mole_crab_helm",
	effectData = {},
}
--Devil Cephalopod Helm
itemsList["devil cephalopod helm"] = {
	name = "Devil Cephalopod Helm",
	id = "devil cephalopod helm",
	itemType = "armor",
	subtype = "helm",
	weight = 2,
	health = 80,
	value = 1700,
	rating = 8,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin", --?
	baseItem = "cephalopod_helm",
	effectData = {},
}
--Devil Helm
itemsList["devil helm"] = {
	name = "Devil Helm",
	id = "devil helm",
	itemType = "armor",
	subtype = "helm",
	weight = 1.5,
	health = 50,
	value = 1000,
	rating = 5,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin", --?
	baseItem = "dust_adept_helm",
	effectData = {},
}
--Devil Mole Crab Helm
itemsList["devil mole crab helm"] = {
	name = "Devil Mole Crab Helm",
	id = "devil mole crab helm",
	itemType = "armor",
	subtype = "helm",
	weight = 2,
	health = 50,
	value = 1200,
	rating = 6,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin", --?
	baseItem = "mole_crab_helm",
	effectData = {},
}
--Fiend Helm
itemsList["fiend helm"] = {
	name = "Fiend Helm",
	id = "fiend helm",
	itemType = "armor",
	subtype = "helm",
	weight = 1.5,
	health = 50,
	value = 6000,
	rating = 5,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin", --?
	baseItem = "dust_adept_helm",
	effectData = {},
}
--Helm of Holy Fire
itemsList["helm of holy fire"] = {
	name = "Helm of Holy Fire",
	id = "helm of holy fire",
	itemType = "armor",
	subtype = "helm",
	weight = 4.5,
	health = 400,
	value = 7050,
	rating = 40,
	--enchant = 0, --already enchanted
	skillId = 2,
	skillName = "Mediumarmor",
	material = "dreugh",
	baseItem = "dreugh_helm",
	effectData = {},
	canBeast = true,
}
--Helm of Wounding
itemsList["helm of wounding"] = {
	name = "Helm of Wounding",
	id = "helm of wounding",
	itemType = "armor",
	subtype = "helm",
	weight = 5,
	health = 200,
	value = 500,
	rating = 20,
	--enchant = 0, --already enchanted
	skillId = 3,
	skillName = "Heavyarmor",
	material = "dwarven",
	baseItem = "dwemer_helm",
	effectData = {},
}
--Merisan Helm
itemsList["merisan helm"] = {
	name = "Merisan Helm",
	id = "merisan helm",
	itemType = "armor",
	subtype = "helm",
	weight = 1,
	health = 100,
	value = 45,
	rating = 10,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin",
	baseItem = "chitin helm",
	effectData = {},
}
--Storm Helm
itemsList["storm helm"] = {
	name = "Storm Helm",
	id = "storm helm",
	itemType = "armor",
	subtype = "helm",
	weight = 4,
	health = 160,
	value = 215,
	rating = 16,
	--enchant = 0, --already enchanted
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	baseItem = "bonemold_gah-julan_helm",
	effectData = {},
}
--Velothian Helm
itemsList["velothian_helm"] = {
	name = "Velothian Helm",
	id = "velothian_helm",
	itemType = "armor",
	subtype = "helm",
	weight = 1,
	health = 100,
	value = 75,
	rating = 10,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin",
	baseItem = "chitin helm",
	effectData = {},
}

--Shields
--Blessed Shield
itemsList["blessed_shield"] = {
	name = "Blessed Shield",
	id = "blessed_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 15,
	health = 300,
	value = 130,
	rating = 15,
	--enchant = 0, --already enchanted
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel",
	hand = 1,
	baseItem = "steel_shield",
	effectData = {},
}
--Blessed Tower Shield
itemsList["blessed_tower_shield"] = {
	name = "Blessed Tower Shield",
	id = "blessed_tower_shield",
	itemType = "armor",
	subtype = "tower shield",
	weight = 15,
	health = 300,
	value = 130,
	rating = 15,
	--enchant = 0, --already enchanted
	skillId = 3,
	skillName = "Heavyarmor",
	material = "steel",
	hand = 1,
	baseItem = "steel_towershield",
	effectData = {},
}
--Feather Shield
itemsList["feather_shield"] = {
	name = "Feather Shield",
	id = "feather_shield",
	itemType = "armor",
	subtype = "tower shield",
	weight = 6,
	health = 240,
	value = 120,
	rating = 12,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "iron", --?
	hand = 1,
	baseItem = "imperial shield",
	effectData = {},
}
--Holy Shield
itemsList["holy_shield"] = {
	name = "Holy Shield",
	id = "holy_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 12,
	health = 300,
	value = 220,
	rating = 15,
	--enchant = 0, --already enchanted
	skillId = 2,
	skillName = "Mediumarmor",
	material = "bonemold",
	hand = 1,
	baseItem = "bonemold_shield",
	effectData = {},
}
--Holy Tower Shield
itemsList["holy_tower_shield"] = {
	name = "Holy Tower Shield",
	id = "holy_tower_shield",
	itemType = "armor",
	subtype = "tower shield",
	weight = 15,
	health = 340,
	value = 3100,
	rating = 17,
	--enchant = 0, --already enchanted
	skillId = 3,
	skillName = "Heavyarmor",
	material = "bonemold",
	hand = 1,
	baseItem = "bonemold_towershield",
	effectData = {},
}
--Shield of Light
itemsList["shield_of_light"] = {
	name = "Shield of Light",
	id = "shield_of_light",
	itemType = "armor",
	subtype = "tower shield",
	weight = 6,
	health = 100,
	value = 85,
	rating = 5,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "iron", --?
	hand = 1,
	baseItem = "imperial shield",
	effectData = {},
}
--Shield of Wounds
itemsList["shield of wounds"] = {
	name = "Shield of Wounds",
	id = "shield of wounds",
	itemType = "armor",
	subtype = "shield",
	weight = 15,
	health = 400,
	value = 620,
	rating = 20,
	--enchant = 0, --already enchanted
	skillId = 3,
	skillName = "Heavyarmor",
	material = "dwarven",
	hand = 1,
	baseItem = "dwemer_shield",
	effectData = {},
}
--Spirit of Indoril
itemsList["spirit of indoril"] = {
	name = "Spirit of Indoril",
	id = "spirit of indoril",
	itemType = "armor",
	subtype = "shield",
	weight = 13.5,
	health = 900,
	value = 5400,
	rating = 45,
	--enchant = 0, --already enchanted
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "gold", --?
	hand = 1,
	baseItem = "indoril shield",
	effectData = {},
}
--Succour of Indoril
itemsList["succour of indoril"] = {
	name = "Succour of Indoril",
	id = "succour of indoril",
	itemType = "armor",
	subtype = "shield",
	weight = 13.5,
	health = 900,
	value = 4200,
	rating = 45,
	--enchant = 0, --already enchanted
	skillId = 2,
	skillName = "Mediumarmor",
	--material = "gold", --?
	hand = 1,
	baseItem = "indoril shield",
	effectData = {},
}
--Velothian Shield
itemsList["velothian shield"] = {
	name = "Velothian Shield",
	id = "velothian shield",
	itemType = "armor",
	subtype = "shield",
	weight = 4,
	health = 200,
	value = 85,
	rating = 10,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin",
	hand = 1,
	baseItem = "chitin_shield",
	effectData = {},
}
--Velothi's Shield
itemsList["velothis_shield"] = {
	name = "Velothi's Shield",
	id = "velothis_shield",
	itemType = "armor",
	subtype = "tower shield",
	weight = 4,
	health = 200,
	value = 85,
	rating = 10,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "iron", --?
	hand = 1,
	baseItem = "imperial shield",
	effectData = {},
}
--Veloth's Shield
itemsList["veloths_shield"] = {
	name = "Veloth's Shield",
	id = "veloths_shield",
	itemType = "armor",
	subtype = "shield",
	weight = 4,
	health = 200,
	value = 85,
	rating = 10,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "chitin",
	hand = 1,
	baseItem = "chitin_shield",
	effectData = {},
}
--Veloth's Tower Shield
itemsList["veloths_tower_shield"] = {
	name = "Veloth's Tower Shield",
	id = "veloths_tower_shield",
	itemType = "armor",
	subtype = "tower shield",
	weight = 9,
	health = 100,
	value = 150,
	rating = 12,
	--enchant = 0, --already enchanted
	skillId = 21,
	skillName = "Lightarmor",
	material = "leather",
	hand = 1,
	baseItem = "netch_leather_towershield",
	effectData = {},
}

-- **CLOTHING**
-- Morrowind Base Clothing
-- Common Amulet (1)
itemsList["common_amulet_01"] = {
	name = "Common Amulet",
	id = "common_amulet_01",
	itemType = "clothing",
	subtype = "amulet",
	weight = 1,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Amulet (2)
itemsList["common_amulet_02"] = {
	name = "Common Amulet",
	id = "common_amulet_02",
	itemType = "clothing",
	subtype = "amulet",
	weight = 1,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Amulet (3)
itemsList["common_amulet_03"] = {
	name = "Common Amulet",
	id = "common_amulet_03",
	itemType = "clothing",
	subtype = "amulet",
	weight = 1,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Amulet (4)
itemsList["common_amulet_04"] = {
	name = "Common Amulet",
	id = "common_amulet_04",
	itemType = "clothing",
	subtype = "amulet",
	weight = 1,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Amulet (5)
itemsList["common_amulet_05"] = {
	name = "Common Amulet",
	id = "common_amulet_05",
	itemType = "clothing",
	subtype = "amulet",
	weight = 1,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Expensive Amulet (1)
itemsList["expensive_amulet_01"] = {
	name = "Expensive Amulet",
	id = "expensive_amulet_01",
	itemType = "clothing",
	subtype = "amulet",
	weight = 1,
	value = 30,
	enchant = 15,
	rank = 2,
}
-- Expensive Amulet (2)
itemsList["expensive_amulet_02"] = {
	name = "Expensive Amulet",
	id = "expensive_amulet_02",
	itemType = "clothing",
	subtype = "amulet",
	weight = 1,
	value = 30,
	enchant = 15,
	rank = 2,
}
-- Expensive Amulet (3)
itemsList["expensive_amulet_03"] = {
	name = "Expensive Amulet",
	id = "expensive_amulet_03",
	itemType = "clothing",
	subtype = "amulet",
	weight = 1,
	value = 30,
	enchant = 15,
	rank = 2,
}
-- Extravagant Sapphire Amulet
itemsList["extravagant_amulet_01"] = {
	name = "Extravagant Sapphire Amulet",
	id = "extravagant_amulet_01",
	itemType = "clothing",
	subtype = "amulet",
	weight = 1,
	value = 120,
	enchant = 60,
	rank = 3,
}
-- Extravagant Ruby Amulet
itemsList["extravagant_amulet_02"] = {
	name = "Extravagant Ruby Amulet",
	id = "extravagant_amulet_02",
	itemType = "clothing",
	subtype = "amulet",
	weight = 1,
	value = 120,
	enchant = 60,
	rank = 3,
}
-- Exquisite Amulet
itemsList["exquisite_amulet_01"] = {
	name = "Exquisite Amulet",
	id = "exquisite_amulet_01",
	itemType = "clothing",
	subtype = "amulet",
	weight = 1,
	value = 240,
	enchant = 120,
	rank = 4,
}

-- Common Belt (1)
itemsList["common_belt_01"] = {
	name = "Common Belt",
	id = "common_belt_01",
	itemType = "clothing",
	subtype = "belt",
	weight = 1,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Belt (2)
itemsList["common_belt_02"] = {
	name = "Common Belt",
	id = "common_belt_02",
	itemType = "clothing",
	subtype = "belt",
	weight = 1,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Belt (3)
itemsList["common_belt_03"] = {
	name = "Common Belt",
	id = "common_belt_03",
	itemType = "clothing",
	subtype = "belt",
	weight = 1,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Belt (4)
itemsList["common_belt_04"] = {
	name = "Common Belt",
	id = "common_belt_04",
	itemType = "clothing",
	subtype = "belt",
	weight = 1,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Belt (5)
itemsList["common_belt_05"] = {
	name = "Common Belt",
	id = "common_belt_05",
	itemType = "clothing",
	subtype = "belt",
	weight = 1,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Expensive Belt (1)
itemsList["expensive_belt_01"] = {
	name = "Expensive Belt",
	id = "expensive_belt_01",
	itemType = "clothing",
	subtype = "belt",
	weight = 1,
	value = 10,
	enchant = 5,
	rank = 2,
}
-- Expensive Belt (2)
itemsList["expensive_belt_02"] = {
	name = "Expensive Belt",
	id = "expensive_belt_02",
	itemType = "clothing",
	subtype = "belt",
	weight = 1,
	value = 10,
	enchant = 5,
	rank = 2,
}
-- Expensive Belt (3)
itemsList["expensive_belt_03"] = {
	name = "Expensive Belt",
	id = "expensive_belt_03",
	itemType = "clothing",
	subtype = "belt",
	weight = 1,
	value = 10,
	enchant = 5,
	rank = 2,
}
-- Extravagant Belt (1)
itemsList["extravagant_belt_01"] = {
	name = "Extravagant Belt",
	id = "extravagant_belt_01",
	itemType = "clothing",
	subtype = "belt",
	weight = 1,
	value = 40,
	enchant = 20,
	rank = 3,
}
-- Extravagant Belt (2)
itemsList["extravagant_belt_02"] = {
	name = "Extravagant Belt",
	id = "extravagant_belt_02",
	itemType = "clothing",
	subtype = "belt",
	weight = 1,
	value = 40,
	enchant = 20,
	rank = 3,
}
-- Exquisite Belt
itemsList["exquisite_belt_01"] = {
	name = "Exquisite Belt",
	id = "exquisite_belt_01",
	itemType = "clothing",
	subtype = "belt",
	weight = 1,
	value = 80,
	enchant = 40,
	rank = 4,
}
-- Imperial Belt
itemsList["imperial belt"] = {
	name = "Imperial Belt",
	id = "imperial belt",
	itemType = "clothing",
	subtype = "belt",
	weight = 2,
	value = 2,
	enchant = 0.5,
	rank = 0,
}
-- Imperial Templar Belt
itemsList["templar belt"] = {
	name = "Imperial Templar Belt",
	id = "templar belt",
	itemType = "clothing",
	subtype = "belt",
	weight = 2,
	value = 4,
	enchant = 10,
	rank = 0,
}
-- Indoril Belt
itemsList["indoril_belt"] = {
	name = "Indoril Belt",
	id = "indoril_belt",
	itemType = "clothing",
	subtype = "belt",
	weight = 2,
	value = 5,
	enchant = 0.5,
	rank = 0,
}

-- Common Left Glove
itemsList["common_glove_left_01"] = {
	name = "Common Left Glove",
	id = "common_glove_left_01",
	itemType = "clothing",
	subtype = "glove",
	weight = 1,
	value = 2,
	enchant = 1,
	rank = 1,
	orientation = "left",
}
-- Common Right Glove
itemsList["common_glove_right_01"] = {
	name = "Common Right Glove",
	id = "common_glove_right_01",
	itemType = "clothing",
	subtype = "glove",
	weight = 1,
	value = 2,
	enchant = 1,
	rank = 1,
	orientation = "right",
}
-- Expensive Left Glove
itemsList["expensive_glove_left_01"] = {
	name = "Expensive Left Glove",
	id = "expensive_glove_left_01",
	itemType = "clothing",
	subtype = "glove",
	weight = 1,
	value = 10,
	enchant = 5,
	rank = 2,
	orientation = "left",
}
-- Expensive right Glove
itemsList["expensive_glove_right_01"] = {
	name = "Expensive Right Glove",
	id = "expensive_glove_right_01",
	itemType = "clothing",
	subtype = "glove",
	weight = 1,
	value = 10,
	enchant = 5,
	rank = 2,
	orientation = "right",
}
-- Extravagant Left Glove
itemsList["extravagant_glove_left_01"] = {
	name = "Extravagant Left Glove",
	id = "extravagant_glove_left_01",
	itemType = "clothing",
	subtype = "glove",
	weight = 1,
	value = 40,
	enchant = 20,
	rank = 3,
	orientation = "left",
}
-- Extravagant Right Glove
itemsList["extravagant_glove_right_01"] = {
	name = "Extravagant Right Glove",
	id = "extravagant_glove_right_01",
	itemType = "clothing",
	subtype = "glove",
	weight = 1,
	value = 40,
	enchant = 20,
	rank = 3,
	orientation = "right",
}

-- Common Pants 1
itemsList["common_pants_01"] = {
	name = "Common Pants",
	id = "common_pants_01",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Pants 1a
itemsList["common_pants_01_a"] = {
	name = "Common Pants",
	id = "common_pants_01_a",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Pants 1e
itemsList["common_pants_01_e"] = {
	name = "Common Pants",
	id = "common_pants_01_e",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Pants 1u
itemsList["common_pants_01_u"] = {
	name = "Common Pants",
	id = "common_pants_01_u",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Pants 1z
itemsList["common_pants_01_z"] = {
	name = "Common Pants",
	id = "common_pants_01_z",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Pants 2
itemsList["common_pants_02"] = {
	name = "Common Pants",
	id = "common_pants_02",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Pants 3
itemsList["common_pants_03"] = {
	name = "Common Pants",
	id = "common_pants_03",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Pants 3b
itemsList["common_pants_03_b"] = {
	name = "Common Pants",
	id = "common_pants_03_b",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Pants 3c
itemsList["common_pants_03_c"] = {
	name = "Common Pants",
	id = "common_pants_03_c",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Pants 4
itemsList["common_pants_04"] = {
	name = "Common Pants",
	id = "common_pants_04",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Pants 4b
itemsList["common_pants_04_b"] = {
	name = "Common Pants",
	id = "common_pants_04_b",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Pants 5
itemsList["common_pants_05"] = {
	name = "Common Pants",
	id = "common_pants_05",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Expensive Pants 1
itemsList["expensive_pants_01"] = {
	name = "Expensive Pants",
	id = "expensive_pants_01",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Expensive Pants 1a
itemsList["expensive_pants_01_a"] = {
	name = "Expensive Pants",
	id = "expensive_pants_01_a",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Expensive Pants 1e
itemsList["expensive_pants_01_e"] = {
	name = "Expensive Pants",
	id = "expensive_pants_01_e",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Expensive Pants 1u
itemsList["expensive_pants_01_u"] = {
	name = "Expensive Pants",
	id = "expensive_pants_01_u",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Expensive Pants 1z
itemsList["expensive_pants_01_z"] = {
	name = "Expensive Pants",
	id = "expensive_pants_01_z",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Expensive Pants 2
itemsList["expensive_pants_02"] = {
	name = "Expensive Pants",
	id = "expensive_pants_02",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Expensive Pants 3
itemsList["expensive_pants_03"] = {
	name = "Expensive Pants",
	id = "expensive_pants_03",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Extravagant Pants 1
itemsList["extravagant_pants_01"] = {
	name = "Extravagant Pants",
	id = "extravagant_pants_01",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 60,
	enchant = 30,
	rank = 3,
}
-- Extravagant Pants 2
itemsList["extravagant_pants_02"] = {
	name = "Extravagant Pants",
	id = "extravagant_pants_02",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 60,
	enchant = 30,
	rank = 3,
}
-- Exquisite Pants 1
itemsList["exquisite_pants_01"] = {
	name = "Exquisite Pants",
	id = "exquisite_pants_01",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 120,
	enchant = 60,
	rank = 4,
}

-- Common Ring 1
itemsList["common_ring_01"] = {
	name = "Common Ring",
	id = "common_ring_01",
	itemType = "clothing",
	subtype = "ring",
	weight = 0.1,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Ring 2
itemsList["common_ring_02"] = {
	name = "Common Ring",
	id = "common_ring_02",
	itemType = "clothing",
	subtype = "ring",
	weight = 0.1,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Ring 3
itemsList["common_ring_03"] = {
	name = "Common Ring",
	id = "common_ring_03",
	itemType = "clothing",
	subtype = "ring",
	weight = 0.1,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Ring 4
itemsList["common_ring_04"] = {
	name = "Common Ring",
	id = "common_ring_04",
	itemType = "clothing",
	subtype = "ring",
	weight = 0.1,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Ring 5
itemsList["common_ring_05"] = {
	name = "Common Ring",
	id = "common_ring_05",
	itemType = "clothing",
	subtype = "ring",
	weight = 0.1,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Expensive Ring 1
itemsList["expensive_ring_01"] = {
	name = "Expensive Ring",
	id = "expensive_ring_01",
	itemType = "clothing",
	subtype = "ring",
	weight = 0.1,
	value = 30,
	enchant = 15,
	rank = 2,
}
-- Expensive Ring 2
itemsList["expensive_ring_02"] = {
	name = "Expensive Ring",
	id = "expensive_ring_02",
	itemType = "clothing",
	subtype = "ring",
	weight = 0.1,
	value = 30,
	enchant = 15,
	rank = 2,
}
-- Expensive Ring 3
itemsList["expensive_ring_03"] = {
	name = "Expensive Ring",
	id = "expensive_ring_03",
	itemType = "clothing",
	subtype = "ring",
	weight = 0.1,
	value = 30,
	enchant = 15,
	rank = 2,
}
-- Extravagant Ring 1
itemsList["extravagant_ring_01"] = {
	name = "Extravagant Ring",
	id = "extravagant_ring_01",
	itemType = "clothing",
	subtype = "ring",
	weight = 0.1,
	value = 120,
	enchant = 60,
	rank = 3,
}
-- Extravagant Ring 2
itemsList["extravagant_ring_02"] = {
	name = "Extravagant Ring",
	id = "extravagant_ring_02",
	itemType = "clothing",
	subtype = "ring",
	weight = 0.1,
	value = 120,
	enchant = 60,
	rank = 3,
}
-- Exquisite Ring 1
itemsList["exquisite_ring_01"] = {
	name = "Exquisite Ring",
	id = "exquisite_ring_01",
	itemType = "clothing",
	subtype = "ring",
	weight = 0.1,
	value = 240,
	enchant = 120,
	rank = 4,
}
-- Exquisite Ring 2
itemsList["exquisite_ring_02"] = {
	name = "Exquisite Ring",
	id = "exquisite_ring_02",
	itemType = "clothing",
	subtype = "ring",
	weight = 0.1,
	value = 240,
	enchant = 120,
	rank = 4,
}

-- Common Robe 1
itemsList["common_robe_01"] = {
	name = "Common Robe",
	id = "common_robe_01",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Robe 02
itemsList["common_robe_02"] = {
	name = "Common Robe",
	id = "common_robe_02",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Robe 2h
itemsList["common_robe_02_h"] = {
	name = "Common Robe",
	id = "common_robe_02_h",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Robe 2hh
itemsList["common_robe_02_hh"] = {
	name = "Common Robe",
	id = "common_robe_02_hh",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Robe 2r
itemsList["common_robe_02_r"] = {
	name = "Common Robe",
	id = "common_robe_02_r",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Robe 2rr
itemsList["common_robe_02_rr"] = {
	name = "Common Robe",
	id = "common_robe_02_rr",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Robe 2t
itemsList["common_robe_02_t"] = {
	name = "Common Robe",
	id = "common_robe_02_t",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Robe 2tt
itemsList["common_robe_02_tt"] = {
	name = "Common Robe",
	id = "common_robe_02_tt",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Robe 3
itemsList["common_robe_03"] = {
	name = "Common Robe",
	id = "common_robe_03",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Robe 3a
itemsList["common_robe_03_a"] = {
	name = "Common Robe",
	id = "common_robe_03_a",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Robe 3b
itemsList["common_robe_03_b"] = {
	name = "Common Robe",
	id = "common_robe_03_b",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Robe 4
itemsList["common_robe_04"] = {
	name = "Common Robe",
	id = "common_robe_04",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Robe 5
itemsList["common_robe_05"] = {
	name = "Common Robe",
	id = "common_robe_05",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Robe 5a
itemsList["common_robe_05_a"] = {
	name = "Common Robe",
	id = "common_robe_05_a",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Robe 5b
itemsList["common_robe_05_b"] = {
	name = "Common Robe",
	id = "common_robe_05_b",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Robe 5c
itemsList["common_robe_05_c"] = {
	name = "Common Robe",
	id = "common_robe_05_c",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Expensive Robe 1
itemsList["expensive_robe_01"] = {
	name = "Expensive Robe",
	id = "expensive_robe_01",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 10,
	enchant = 5,
	rank = 2,
}
-- Expensive Robe 2
itemsList["expensive_robe_02"] = {
	name = "Expensive Robe",
	id = "expensive_robe_02",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 10,
	enchant = 5,
	rank = 2,
}
-- Expensive Robe 2a
itemsList["expensive_robe_02_a"] = {
	name = "Expensive Robe",
	id = "expensive_robe_02_a",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 10,
	enchant = 5,
	rank = 2,
}
-- Expensive Robe 3
itemsList["expensive_robe_03"] = {
	name = "Expensive Robe",
	id = "expensive_robe_03",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 10,
	enchant = 5,
	rank = 2,
}
-- Extravagant Robe 1
itemsList["extravagant_robe_01"] = {
	name = "Extravagant Robe",
	id = "extravagant_robe_01",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 40,
	enchant = 20,
	rank = 3,
}
-- Extravagant Robe 1a
itemsList["extravagant_robe_01_a"] = {
	name = "Extravagant Robe",
	id = "extravagant_robe_01_a",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 40,
	enchant = 20,
	rank = 3,
}
-- Extravagant Robe 1b
itemsList["extravagant_robe_01_b"] = {
	name = "Extravagant Robe",
	id = "extravagant_robe_01_b",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 40,
	enchant = 20,
	rank = 3,
}
-- Extravagant Robe 1c
itemsList["extravagant_robe_01_c"] = {
	name = "Extravagant Robe",
	id = "extravagant_robe_01_c",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 40,
	enchant = 20,
	rank = 3,
}
-- Extravagant Robe 1h
itemsList["extravagant_robe_01_h"] = {
	name = "Extravagant Robe",
	id = "extravagant_robe_01_h",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 40,
	enchant = 20,
	rank = 3,
}
-- Extravagant Robe 1r
itemsList["extravagant_robe_01_r"] = {
	name = "Extravagant Robe",
	id = "extravagant_robe_01_r",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 40,
	enchant = 20,
	rank = 3,
}
-- Extravagant Robe 1t
itemsList["extravagant_robe_01_t"] = {
	name = "Extravagant Robe",
	id = "extravagant_robe_01_t",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 40,
	enchant = 20,
	rank = 3,
}
-- Extravagant Robe 2
itemsList["extravagant_robe_02"] = {
	name = "Extravagant Robe",
	id = "extravagant_robe_02",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 40,
	enchant = 20,
	rank = 3,
}
-- Exquisite Robe 1
itemsList["exquisite_robe_01"] = {
	name = "Exquisite Robe",
	id = "exquisite_robe_01",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 80,
	enchant = 40,
	rank = 4,
}

-- Common Shirt 1
itemsList["common_shirt_01"] = {
	name = "Common Shirt",
	id = "common_shirt_01",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 1a
itemsList["common_shirt_01_a"] = {
	name = "Common Shirt",
	id = "common_shirt_01_a",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 1e
itemsList["common_shirt_01_e"] = {
	name = "Common Shirt",
	id = "common_shirt_01_e",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 1u
itemsList["common_shirt_01_u"] = {
	name = "Common Shirt",
	id = "common_shirt_01_u",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 1z
itemsList["common_shirt_01_z"] = {
	name = "Common Shirt",
	id = "common_shirt_01_z",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 2
itemsList["common_shirt_02"] = {
	name = "Common Shirt",
	id = "common_shirt_02",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 2h
itemsList["common_shirt_02_h"] = {
	name = "Common Shirt",
	id = "common_shirt_02_h",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 2hh
itemsList["common_shirt_02_hh"] = {
	name = "Common Shirt",
	id = "common_shirt_02_hh",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 2r
itemsList["common_shirt_02_r"] = {
	name = "Common Shirt",
	id = "common_shirt_02_r",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 2rr
itemsList["common_shirt_02_rr"] = {
	name = "Common Shirt",
	id = "common_shirt_02_rr",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 2t
itemsList["common_shirt_02_t"] = {
	name = "Common Shirt",
	id = "common_shirt_02_t",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 2tt
itemsList["common_shirt_02_tt"] = {
	name = "Common Shirt",
	id = "common_shirt_02_tt",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 3
itemsList["common_shirt_03"] = {
	name = "Common Shirt",
	id = "common_shirt_03",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 3b
itemsList["common_shirt_03_b"] = {
	name = "Common Shirt",
	id = "common_shirt_03_b",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 3c
itemsList["common_shirt_03_c"] = {
	name = "Common Shirt",
	id = "common_shirt_03_c",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 4
itemsList["common_shirt_04"] = {
	name = "Common Shirt",
	id = "common_shirt_04",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 4a
itemsList["common_shirt_04_a"] = {
	name = "Common Shirt",
	id = "common_shirt_04_a",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 4b
itemsList["common_shirt_04_b"] = {
	name = "Common Shirt",
	id = "common_shirt_04_b",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 4c
itemsList["common_shirt_04_c"] = {
	name = "Common Shirt",
	id = "common_shirt_04_c",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 5
itemsList["common_shirt_05"] = {
	name = "Common Shirt",
	id = "common_shirt_05",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt Gondolier
itemsList["common_shirt_gondolier"] = {
	name = "Gondolier Shirt",
	id = "common_shirt_gondolier",
	itemType = "clothing",
	subtype = "shirt",
	weight = 6,
	value = 6,
	enchant = 10,
	rank = 0,
}
-- Expensive Shirt 1
itemsList["expensive_shirt_01"] = {
	name = "Expensive Shirt",
	id = "expensive_shirt_01",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Expensive Shirt 1a
itemsList["expensive_shirt_01_a"] = {
	name = "Expensive Shirt",
	id = "expensive_shirt_01_a",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Expensive Shirt 1e
itemsList["expensive_shirt_01_e"] = {
	name = "Expensive Shirt",
	id = "expensive_shirt_01_e",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Expensive Shirt 1u
itemsList["expensive_shirt_01_u"] = {
	name = "Expensive Shirt",
	id = "expensive_shirt_01_u",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Expensive Shirt 1z
itemsList["expensive_shirt_01_z"] = {
	name = "Expensive Shirt",
	id = "expensive_shirt_01_z",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Expensive Shirt 2
itemsList["expensive_shirt_02"] = {
	name = "Expensive Shirt",
	id = "expensive_shirt_02",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Expensive Shirt 3
itemsList["expensive_shirt_03"] = {
	name = "Expensive Shirt",
	id = "expensive_shirt_03",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Extravagant Shirt 1
itemsList["extravagant_shirt_01"] = {
	name = "Extravagant Shirt",
	id = "extravagant_shirt_01",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 60,
	enchant = 30,
	rank = 3,
}
-- Extravagant Shirt 1h
itemsList["extravagant_shirt_01_h"] = {
	name = "Extravagant Shirt",
	id = "extravagant_shirt_01_h",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 60,
	enchant = 30,
	rank = 3,
}
-- Extravagant Shirt 1r
itemsList["extravagant_shirt_01_r"] = {
	name = "Extravagant Shirt",
	id = "extravagant_shirt_01_r",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 60,
	enchant = 30,
	rank = 3,
}
-- Extravagant Shirt 1t
itemsList["extravagant_shirt_01_t"] = {
	name = "Extravagant Shirt",
	id = "extravagant_shirt_01_t",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 60,
	enchant = 30,
	rank = 3,
}
-- Extravagant Shirt 2
itemsList["extravagant_shirt_02"] = {
	name = "Extravagant Shirt",
	id = "extravagant_shirt_02",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 60,
	enchant = 30,
	rank = 3,
}
-- Exquisite Shirt 1
itemsList["exquisite_shirt_01"] = {
	name = "Exquisite Shirt",
	id = "exquisite_shirt_01",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 120,
	enchant = 60,
	rank = 4,
}

-- Common Shoes 1
itemsList["common_shoes_01"] = {
	name = "Common Shoes",
	id = "common_shoes_01",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Shoes 2
itemsList["common_shoes_02"] = {
	name = "Common Shoes",
	id = "common_shoes_02",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Shoes 3
itemsList["common_shoes_03"] = {
	name = "Common Shoes",
	id = "common_shoes_03",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Shoes 4
itemsList["common_shoes_04"] = {
	name = "Common Shoes",
	id = "common_shoes_04",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common Shoes 5
itemsList["common_shoes_05"] = {
	name = "Common Shoes",
	id = "common_shoes_05",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Expensive Shoes 1
itemsList["expensive_shoes_01"] = {
	name = "Expensive Shoes",
	id = "expensive_shoes_01",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 10,
	enchant = 5,
	rank = 2,
}
-- Expensive Shoes 2
itemsList["expensive_shoes_02"] = {
	name = "Expensive Shoes",
	id = "expensive_shoes_02",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 10,
	enchant = 5,
	rank = 2,
}
-- Expensive Shoes 3
itemsList["expensive_shoes_03"] = {
	name = "Expensive Shoes",
	id = "expensive_shoes_03",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 10,
	enchant = 5,
	rank = 2,
}
-- Extravagant Shoes 1
itemsList["extravagant_shoes_01"] = {
	name = "Extravagant Shoes",
	id = "extravagant_shoes_01",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 40,
	enchant = 20,
	rank = 3,
}
-- Extravagant Shoes 2
itemsList["extravagant_shoes_02"] = {
	name = "Extravagant Shoes",
	id = "extravagant_shoes_02",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 40,
	enchant = 20,
	rank = 3,
}
-- Exquisite Shoes 1
itemsList["exquisite_shoes_01"] = {
	name = "Exquisite Shoes",
	id = "exquisite_shoes_01",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 80,
	enchant = 40,
	rank = 4,
}

-- Common Skirt 1
itemsList["common_skirt_01"] = {
	name = "Common Skirt",
	id = "common_skirt_01",
	itemType = "clothing",
	subtype = "skirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Skirt 2
itemsList["common_skirt_02"] = {
	name = "Common Skirt",
	id = "common_skirt_02",
	itemType = "clothing",
	subtype = "skirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Skirt 3
itemsList["common_skirt_03"] = {
	name = "Common Skirt",
	id = "common_skirt_03",
	itemType = "clothing",
	subtype = "skirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Skirt 4c
itemsList["common_skirt_04_c"] = {
	name = "Common Skirt",
	id = "common_skirt_04_c",
	itemType = "clothing",
	subtype = "skirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Skirt 5
itemsList["common_skirt_05"] = {
	name = "Common Skirt",
	id = "common_skirt_05",
	itemType = "clothing",
	subtype = "skirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Expensive Skirt 1
itemsList["expensive_skirt_01"] = {
	name = "Expensive Skirt",
	id = "expensive_skirt_01",
	itemType = "clothing",
	subtype = "skirt",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Expensive Skirt 2
itemsList["expensive_skirt_02"] = {
	name = "Expensive Skirt",
	id = "expensive_skirt_02",
	itemType = "clothing",
	subtype = "skirt",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Expensive Skirt 3
itemsList["expensive_skirt_03"] = {
	name = "Expensive Skirt",
	id = "expensive_skirt_03",
	itemType = "clothing",
	subtype = "skirt",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Extravagant Skirt 1
itemsList["extravagant_skirt_01"] = {
	name = "Extravagant Skirt",
	id = "extravagant_skirt_01",
	itemType = "clothing",
	subtype = "skirt",
	weight = 2,
	value = 60,
	enchant = 30,
	rank = 3,
}
-- Extravagant Skirt 2
itemsList["extravagant_skirt_02"] = {
	name = "Extravagant Skirt",
	id = "extravagant_skirt_02",
	itemType = "clothing",
	subtype = "skirt",
	weight = 2,
	value = 60,
	enchant = 30,
	rank = 3,
}
-- Exquisite Skirt 1
itemsList["exquisite_skirt_01"] = {
	name = "Exquisite Skirt",
	id = "exquisite_skirt_01",
	itemType = "clothing",
	subtype = "skirt",
	weight = 2,
	value = 120,
	enchant = 60,
	rank = 4,
}
-- Imperial Skirt
itemsList["imperial skirt_clothing"] = {
	name = "Imperial Skirt",
	id = "imperial skirt_clothing",
	itemType = "clothing",
	subtype = "skirt",
	weight = 2,
	value = 4,
	enchant = 0.5,
	rank = 0,
}
-- Imperial Templar Skirt
itemsList["templar skirt obj"] = {
	name = "Imperial Templar Skirt",
	id = "templar skirt obj",
	itemType = "clothing",
	subtype = "skirt",
	weight = 2.5,
	value = 6,
	enchant = 0.5,
	rank = 0,
}

-- Tribunal Base Clothing
-- Common Pants 6
itemsList["common_pants_06"] = {
	name = "Common Pants",
	id = "common_pants_06",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Pants 6
itemsList["common_pants_07"] = {
	name = "Common Pants",
	id = "common_pants_07",
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Expensive Pants
itemsList["Expensive_pants_Mournhold"] = {
	name = "Expensive Pants",
	id = "Expensive_pants_Mournhold", --Note: This and Tribunal expensive shirt and shoes use this formatting. Expensive skirt doesn't
	itemType = "clothing",
	subtype = "pants",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}
-- Common Shirt 6
itemsList["common_shirt_06"] = {
	name = "Common Shirt",
	id = "common_shirt_06",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Shirt 7
itemsList["common_shirt_07"] = {
	name = "Common Shirt",
	id = "common_shirt_07",
	itemType = "clothing",
	subtype = "shirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Expensive Shirt
itemsList["Expensive_shirt_Mournhold"] = {
	name = "Expensive Shirt",
	id = "Expensive_shirt_Mournhold",
	itemType = "clothing",
	subtype = "shirt",
	weight = 1,
	value = 1,
	enchant = 10,
	rank = 2,
}
-- Common shoes 6
itemsList["common_shoes_06"] = {
	name = "Common Shoes",
	id = "common_shoes_06",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Common shoes 7
itemsList["common_shoes_07"] = {
	name = "Common Shoes",
	id = "common_shoes_07",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- Expensive Shoes
itemsList["Expensive_shoes_Mournhold"] = {
	name = "Expensive Shoes",
	id = "Expensive_shoes_Mournhold",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 10,
	enchant = 5,
	rank = 2,
}
-- Common Skirt 6
itemsList["common_skirt_06"] = {
	name = "Common Skirt",
	id = "common_skirt_06",
	itemType = "clothing",
	subtype = "skirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Common Skirt 7
itemsList["common_skirt_07"] = {
	name = "Common Skirt",
	id = "common_skirt_07",
	itemType = "clothing",
	subtype = "skirt",
	weight = 2,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- Expensive Skirt
itemsList["expensive_skirt_Mournhold"] = {
	name = "Expensive Skirt",
	id = "expensive_skirt_Mournhold",
	itemType = "clothing",
	subtype = "skirt",
	weight = 2,
	value = 15,
	enchant = 7.5,
	rank = 2,
}

--Bloodmoon Base Clothing
-- Left Glove 1
itemsList["BM_Nordic01_gloveL"] = {
	name = "Left Glove",
	id = "BM_Nordic01_gloveL",
	itemType = "clothing",
	subtype = "glove",
	weight = 1,
	value = 4,
	enchant = 2,
	rank = 0,
	orientation = "left",
}
-- Right Glove 1
itemsList["BM_Nordic01_gloveR"] = {
	name = "Right Glove",
	id = "BM_Nordic01_gloveR",
	itemType = "clothing",
	subtype = "glove",
	weight = 1,
	value = 4,
	enchant = 2,
	rank = 0,
	orientation = "right",
}
-- Left Glove2
itemsList["BM_Nordic02_gloveL"] = {
	name = "Left Glove",
	id = "BM_Nordic02_gloveL",
	itemType = "clothing",
	subtype = "glove",
	weight = 1,
	value = 4,
	enchant = 2,
	rank = 0,
	orientation = "left",
}
-- Right Glove2
itemsList["BM_Nordic02_gloveR"] = {
	name = "Right Glove",
	id = "BM_Nordic02_gloveR",
	itemType = "clothing",
	subtype = "glove",
	weight = 1,
	value = 4,
	enchant = 2,
	rank = 0,
	orientation = "right",
}
-- Left Wool Glove 1
itemsList["BM_Wool01_gloveL"] = {
	name = "Left Glove",
	id = "BM_Wool01_gloveL",
	itemType = "clothing",
	subtype = "glove",
	weight = 1,
	value = 4,
	enchant = 1,
	rank = 0,
	orientation = "left",
}
-- Right Wool Glove 1
itemsList["BM_Wool01_gloveR"] = {
	name = "Right Glove",
	id = "BM_Wool01_gloveR",
	itemType = "clothing",
	subtype = "glove",
	weight = 1,
	value = 4,
	enchant = 1,
	rank = 0,
	orientation = "right",
}
-- Left Wool Glove 2
itemsList["BM_Wool02_gloveL"] = {
	name = "Left Glove",
	id = "BM_Wool02_gloveL",
	itemType = "clothing",
	subtype = "glove",
	weight = 1,
	value = 4,
	enchant = 1,
	rank = 0,
	orientation = "left",
}
-- Right Wool Glove 2
itemsList["BM_Wool02_gloveR"] = {
	name = "Right Glove",
	id = "BM_Wool02_gloveR",
	itemType = "clothing",
	subtype = "glove",
	weight = 1,
	value = 4,
	enchant = 1,
	rank = 0,
	orientation = "right",
}
-- BM Common Pants 1
itemsList["BM_Nordic01_pants"] = {
	name = "Common Pants",
	id = "BM_Nordic01_pants",
	itemType = "clothing",
	subtype = "pants",
	weight = 3,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- BM Common Pants 2
itemsList["BM_Nordic02_pants"] = {
	name = "Common Pants",
	id = "BM_Nordic02_pants",
	itemType = "clothing",
	subtype = "pants",
	weight = 3,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- BM Common Pants 3
itemsList["BM_Wool01_pants"] = {
	name = "Common Pants",
	id = "BM_Wool01_pants",
	itemType = "clothing",
	subtype = "pants",
	weight = 3,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- BM Common Pants 4
itemsList["BM_Wool02_pants"] = {
	name = "Common Pants",
	id = "BM_Wool02_pants",
	itemType = "clothing",
	subtype = "pants",
	weight = 3,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- BM Common Robe 1
itemsList["BM_Nordic01_Robe"] = {
	name = "Common Robe",
	id = "BM_Nordic01_Robe",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 20,
	enchant = 5,
	rank = 1,
}
-- BM Common Robe 2
itemsList["BM_Wool01_Robe"] = {
	name = "Common Robe",
	id = "BM_Wool01_Robe",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 20,
	enchant = 5,
	rank = 1,
}
-- Glenmoril Witch Robe
itemsList["common_robe_unique"] = {
	name = "Glenmoril Witch Robe",
	id = "common_robe_unique",
	itemType = "clothing",
	subtype = "robe",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- BM Common Shirt 1
itemsList["BM_Nordic01_shirt"] = {
	name = "Common Shirt",
	id = "BM_Nordic01_shirt",
	itemType = "clothing",
	subtype = "shirt",
	weight = 3,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- BM Common Shirt 2
itemsList["BM_Nordic02_shirt"] = {
	name = "Common Shirt",
	id = "BM_Nordic02_shirt",
	itemType = "clothing",
	subtype = "shirt",
	weight = 3,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- BM Common Shirt 3
itemsList["BM_Wool01_shirt"] = {
	name = "Common Shirt",
	id = "BM_Wool01_shirt",
	itemType = "clothing",
	subtype = "shirt",
	weight = 3,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- BM Common Shirt 4
itemsList["BM_Wool02_shirt"] = {
	name = "Common Shirt",
	id = "BM_Wool02_shirt",
	itemType = "clothing",
	subtype = "shirt",
	weight = 3,
	value = 4,
	enchant = 2,
	rank = 1,
}
-- BM Common Shoes 1
itemsList["BM_Nordic01_shoes"] = {
	name = "Common Shoes",
	id = "BM_Nordic01_shoes",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- BM Common Shoes 2
itemsList["BM_Nordic02_shoes"] = {
	name = "Common Shoes",
	id = "BM_Nordic02_shoes",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- BM Common Shoes 3
itemsList["BM_Wool01_shoes"] = {
	name = "Common Shoes",
	id = "BM_Wool01_shoes",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}
-- BM Common Shoes 4
itemsList["BM_Wool02_shoes"] = {
	name = "Common Shoes",
	id = "BM_Wool02_shoes",
	itemType = "clothing",
	subtype = "shoes",
	weight = 3,
	value = 2,
	enchant = 1,
	rank = 1,
}

--**POTIONS**
--Morrowind Potions
--Potion of Burden
itemsList["p_burden_b"] = {
	name = "Bargain Potion of Burden",
	id = "p_burden_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_burden_c"] = {
	name = "Cheap Potion of Burden",
	id = "p_burden_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_burden_s"] = {
	name = "Standard Potion of Burden",
	id = "p_burden_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_burden_q"] = {
	name = "Quality Potion of Burden",
	id = "p_burden_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_burden_e"] = {
	name = "Exclusive Potion of Burden",
	id = "p_burden_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Feather
itemsList["p_feather_b"] = {
	name = "Bargain Potion of Feather",
	id = "p_feather_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_feather_c"] = {
	name = "Cheap Potion of Feather",
	id = "p_feather_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
--No standard feather, apparently
itemsList["p_feather_q"] = {
	name = "Quality Potion of Feather",
	id = "p_feather_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_feather_e"] = {
	name = "Exclusive Potion of Feather",
	id = "p_feather_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Fire Shield
itemsList["p_fire_shield_b"] = {
	name = "Bargain Potion of Fire Shield",
	id = "p_fire_shield_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_fire_shield_c"] = {
	name = "Cheap Potion of Fire Shield",
	id = "p_fire_shield_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_fire_shield_s"] = {
	name = "Standard Potion of Fire Shield",
	id = "p_fire_shield_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_fire_shield_q"] = {
	name = "Quality Potion of Fire Shield",
	id = "p_fire_shield_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_fire_shield_e"] = {
	name = "Exclusive Potion of Fire Shield",
	id = "p_fire_shield_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Frost Shield
itemsList["p_frost_shield_b"] = {
	name = "Bargain Potion of Frost Shield",
	id = "p_frost_shield_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_frost_shield_c"] = {
	name = "Cheap Potion of Frost Shield",
	id = "p_frost_shield_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_frost_shield_s"] = {
	name = "Standard Potion of Frost Shield",
	id = "p_frost_shield_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_frost_shield_q"] = {
	name = "Quality Frost Shield",
	id = "p_frost_shield_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_frost_shield_e"] = {
	name = "Exclusive Frost Shield",
	id = "p_frost_shield_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 6,
	effectData = {},
}
--Potion of Jump
itemsList["p_jump_b"] = {
	name = "Bargain Potion of Jump",
	id = "p_jump_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_jump_c"] = {
	name = "Cheap Potion of Jump",
	id = "p_jump_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_jump_s"] = {
	name = "Standard Potion of Jump",
	id = "p_jump_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_jump_q"] = {
	name = "Quality Potion of Jump",
	id = "p_jump_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_jump_e"] = {
	name = "Exclusive Potion of Jump",
	id = "p_jump_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Levitation
itemsList["p_levitation_b"] = {
	name = "Bargain Rising Force Potion",
	id = "p_levitation_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_levitation_c"] = {
	name = "Cheap Rising Force Potion",
	id = "p_levitation_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_levitation_s"] = {
	name = "Standard Rising Force Potion",
	id = "p_levitation_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["P_Levitation_Q"] = {
	name = "Quality Rising Force Potion",
	id = "P_Levitation_Q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_levitation_e"] = {
	name = "Exclusive Rising Force Potion",
	id = "p_levitation_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Lightning Shield
itemsList["p_lightning shield_b"] = {
	name = "Bargain Lightning Shield",
	id = "p_lightning shield_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_lightning shield_c"] = {
	name = "Cheap Lightning Shield",
	id = "p_lightning shield_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_lightning shield_s"] = {
	name = "Standard Lightning Shield",
	id = "p_lightning shield_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_lightning shield_q"] = {
	name = "Quality Lightning Shield",
	id = "p_lightning shield_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_lightning shield_e"] = {
	name = "Exclusive Lightning Shield",
	id = "p_lightning shield_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Slowfall
itemsList["p_slowfall_s"] = {
	name = "Potion of Slowfalling",
	id = "p_slowfall_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 35,
	rank = 4,
	effectData = {},
}
--Potion of Swift Swim
itemsList["p_swift_swim_b"] = {
	name = "Bargain Potion of Swift Swim",
	id = "p_swift_swim_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_swift_swim_c"] = {
	name = "Cheap Potion of Swift Swim",
	id = "p_swift_swim_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_swift_swim_q"] = {
	name = "Quality Potion of Swift Swim",
	id = "p_swift_swim_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_swift_swim_e"] = {
	name = "Exclusive Potion of Swift Swim",
	id = "p_swift_swim_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Water Breathing
itemsList["p_water_breathing_s"] = {
	name = "Potion of Water Breathing",
	id = "p_water_breathing_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 35,
	rank = 4,
	effectData = {},
}
--Potion of Water Walking
itemsList["p_water_walking_s"] = {
	name = "Potion of Water Walking",
	id = "p_water_walking_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 35,
	rank = 4,
	effectData = {},
}
--Potion of Chameleon/Potion of Shadow
itemsList["p_chameleon_b"] = {
	name = "Bargain Potion of Shadow",
	id = "p_chameleon_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_chameleon_c"] = {
	name = "Cheap Potion of Shadow",
	id = "p_chameleon_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_chameleon_s"] = {
	name = "Standard Potion of Shadow",
	id = "p_chameleon_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_chameleon_q"] = {
	name = "Quality Potion of Shadow",
	id = "p_chameleon_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_chameleon_e"] = {
	name = "Exclusive Potion of Shadow",
	id = "p_chameleon_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Invisibility
itemsList["p_invisibility_b"] = {
	name = "Bargain Potion of Invisibility",
	id = "p_invisibility_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_invisibility_c"] = {
	name = "Cheap Potion of Invisibility",
	id = "p_invisibility_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_invisibility_s"] = {
	name = "Standard Potion of Invisibility",
	id = "p_invisibility_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_invisibility_q"] = {
	name = "Quality Potion of Invisibility",
	id = "p_invisibility_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_invisibility_e"] = {
	name = "Exclusive Invisibility",
	id = "p_invisibility_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Light
itemsList["p_light_b"] = {
	name = "Bargain Potion of Light",
	id = "p_light_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_light_c"] = {
	name = "Cheap Potion of Light",
	id = "p_light_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_light_s"] = {
	name = "Standard Potion of Light",
	id = "p_light_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_light_q"] = {
	name = "Quality Potion of Light",
	id = "p_light_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_light_e"] = {
	name = "Exclusive Potion of Light",
	id = "p_light_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Night Eye/Potion of Night-Eye
itemsList["p_night-eye_b"] = {
	name = "Bargain Potion of Night-Eye",
	id = "p_night-eye_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_night-eye_c"] = {
	name = "Cheap Potion of Night-Eye",
	id = "p_night-eye_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_night-eye_s"] = {
	name = "Standard Potion of Night-Eye",
	id = "p_night-eye_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_night-eye_q"] = {
	name = "Quality Potion of Night-Eye",
	id = "p_night-eye_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_night-eye_e"] = {
	name = "Exclusive Potion of Night-Eye",
	id = "p_night-eye_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Paralyze
itemsList["p_paralyze_b"] = {
	name = "Bargain Potion of Paralyze",
	id = "p_paralyze_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_paralyze_c"] = {
	name = "Cheap Potion of Paralyze",
	id = "p_paralyze_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_paralyze_s"] = {
	name = "Standard Potion of Paralyze",
	id = "p_paralyze_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_paralyze_q"] = {
	name = "Quality Potion of Paralyze",
	id = "p_paralyze_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_paralyze_e"] = {
	name = "Exclusive Potion of Paralyze",
	id = "p_paralyze_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Silence
itemsList["p_silence_b"] = {
	name = "Bargain Potion of Silence",
	id = "p_silence_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_silence_c"] = {
	name = "Cheap Potion of Silence",
	id = "p_silence_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_silence_s"] = {
	name = "Standard Potion of Silence",
	id = "p_silence_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_silence_q"] = {
	name = "Quality Potion of Silence",
	id = "p_silence_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_silence_e"] = {
	name = "Exclusive Potion of Silence",
	id = "p_silence_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Almsivi Intervention/Potion of Fool's Luck
itemsList["p_almsivi_intervention_s"] = {
	name = "Potion of Fool's Luck",
	id = "p_almsivi_intervention_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
--Potion of Detect Animal/Potion of Detect Creatures
itemsList["p_detect_creatures_s"] = {
	name = "Potion of Detect Creatures",
	id = "p_detect_creatures_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 35,
	rank = 4,
	effectData = {},
}
--Potion of Detect Enchantment/Potion of Detect Enchantments
itemsList["p_detect_enchantment_s"] = {
	name = "Potion of Detect Enchantments",
	id = "p_detect_enchantment_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 35,
	rank = 4,
	effectData = {},
}
--Potion of Detect Key
itemsList["p_detect_key_s"] = {
	name = "Potion of Detect Key",
	id = "p_detect_key_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 35,
	rank = 4,
	effectData = {},
}
--Potion of Dispel
itemsList["p_dispel_s"] = {
	name = "Potion of Dispel",
	id = "p_dispel_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 35,
	rank = 4,
	effectData = {},
}
--Potion of Marking/Potion of Mark
itemsList["p_mark_s"] = {
	name = "Potion of Marking",
	id = "p_mark_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 35,
	rank = 4,
	effectData = {},
}
--Potion of Recall
itemsList["p_recall_s"] = {
	name = "Potion of Recall",
	id = "p_recall_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 35,
	rank = 4,
	effectData = {},
}
--Potion of Reflection/Potion of Reflect
itemsList["p_reflection_b"] = {
	name = "Bargain Potion of Reflection",
	id = "p_reflection_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_reflection_c"] = {
	name = "Cheap Potion of Reflection",
	id = "p_reflection_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_reflection_s"] = {
	name = "Standard Potion of Reflection",
	id = "p_reflection_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_reflection_q"] = {
	name = "Quality Potion of Reflection",
	id = "p_reflection_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_reflection_e"] = {
	name = "Exclusive Potion of Reflection",
	id = "p_reflection_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Spell Absorption
itemsList["p_spell_absorption_b"] = {
	name = "Bargain Spell Absorption",
	id = "p_spell_absorption_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_spell_absorption_c"] = {
	name = "Cheap Spell Absorption",
	id = "p_spell_absorption_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_spell_absorption_s"] = {
	name = "Standard Spell Absorption",
	id = "p_spell_absorption_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_spell_absorption_q"] = {
	name = "Quality Spell Absorption",
	id = "p_spell_absorption_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_spell_absorption_e"] = {
	name = "Exclusive Spell Absorption",
	id = "p_spell_absorption_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Telekinesis
itemsList["p_telekinesis_s"] = {
	name = "Potion of Telekinesis",
	id = "p_telekinesis_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 35,
	rank = 4,
	effectData = {},
}
--Potion of Cure Blight Disease
itemsList["p_cure_blight_s"] = {
	name = "Potion of Cure Blight Disease",
	id = "p_cure_blight_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 30,
	rank = 4,
	effectData = {},
}
--Potion of Cure Common Disease
itemsList["p_cure_common_s"] = {
	name = "Potion of Cure Common Disease",
	id = "p_cure_common_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 20,
	rank = 4,
	effectData = {},
}
--Potion of Cure Paralyzation
itemsList["p_cure_paralyzation_s"] = {
	name = "Potion of Cure Paralyzation",
	id = "p_cure_paralyzation_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 20,
	rank = 4,
	effectData = {},
}
--Potion of Cure Poison
itemsList["p_cure_poison_s"] = {
	name = "Potion of Cure Poison",
	id = "p_cure_poison_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 20,
	rank = 4,
	effectData = {},
}
--Potion of Fortify Attack
itemsList["p_fortify_attack_e"] = {
	name = "Exclusive Fortify Attack",
	id = "p_fortify_attack_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Skipping Fortify Attributes for now

--Potion of Fortify Fatigue
itemsList["p_fortify_fatigue_b"] = {
	name = "Bargain Fortify Fatigue",
	id = "p_fortify_fatigue_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_fortify_fatigue_c"] = {
	name = "Cheap Fortify Fatigue",
	id = "p_fortify_fatigue_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_fortify_fatigue_s"] = {
	name = "Standard Fortify Fatigue Potion",
	id = "p_fortify_fatigue_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_fortify_fatigue_q"] = {
	name = "Quality Fortify Fatigue",
	id = "p_fortify_fatigue_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_fortify_fatigue_e"] = {
	name = "Exclusive Fortify Fatigue",
	id = "p_fortify_fatigue_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Fortify Health
itemsList["p_fortify_health_b"] = {
	name = "Bargain Fortify Health Potion",
	id = "p_fortify_health_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_fortify_health_c"] = {
	name = "Cheap Potion of Fortify Health",
	id = "p_fortify_health_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_fortify_health_s"] = {
	name = "Standard Fortify Health Potion",
	id = "p_fortify_health_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_fortify_health_q"] = {
	name = "Quality Fortify Health",
	id = "p_fortify_health_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_fortify_health_e"] = {
	name = "Exclusive Fortify Health",
	id = "p_fortify_health_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Fortify Magicka
itemsList["p_fortify_magicka_b"] = {
	name = "Bargain Fortify Magicka",
	id = "p_fortify_magicka_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_fortify_magicka_c"] = {
	name = "Cheap Potion of Fortify Magicka",
	id = "p_fortify_magicka_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_fortify_magicka_s"] = {
	name = "Standard Fortify Magicka Potion",
	id = "p_fortify_magicka_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_fortify_magicka_q"] = {
	name = "Quality Fortify Magicka",
	id = "p_fortify_magicka_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_fortify_magicka_e"] = {
	name = "Exclusive Fortify Magicka",
	id = "p_fortify_magicka_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Disease Resistance/Potion of Resist Common Disease
itemsList["p_disease_resistance_b"] = {
	name = "Bargain Disease Resistance",
	id = "p_disease_resistance_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_disease_resistance_c"] = {
	name = "Cheap Disease Resistance",
	id = "p_disease_resistance_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_disease_resistance_s"] = {
	name = "Standard Disease Resistance",
	id = "p_disease_resistance_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_disease_resistance_q"] = {
	name = "Quality Disease Resistance",
	id = "p_disease_resistance_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_disease_resistance_e"] = {
	name = "Exclusive Disease Resistance",
	id = "p_disease_resistance_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Fire Resistance/Potion of Resist Fire
itemsList["p_fire_resistance_b"] = {
	name = "Bargain Fire Resistance",
	id = "p_fire_resistance_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_fire_resistance_c"] = {
	name = "Cheap Fire Resistance",
	id = "p_fire_resistance_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_fire_resistance_s"] = {
	name = "Standard Fire Resistance",
	id = "p_fire_resistance_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_fire_resistance_q"] = {
	name = "Quality Fire Resistance",
	id = "p_fire_resistance_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_fire_resistance_e"] = {
	name = "Exclusive Fire Resistance",
	id = "p_fire_resistance_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Frost Resistance/Potion of Resist Frost
itemsList["p_frost_resistance_b"] = {
	name = "Bargain Frost Resistance",
	id = "p_frost_resistance_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_frost_resistance_c"] = {
	name = "Cheap Frost Resistance",
	id = "p_frost_resistance_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_frost_resistance_s"] = {
	name = "Standard Resist Frost Potion",
	id = "p_frost_resistance_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_frost_resistance_q"] = {
	name = "Quality Frost Resistance",
	id = "p_frost_resistance_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_frost_resistance_e"] = {
	name = "Exclusive Frost Resistance",
	id = "p_frost_resistance_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Magicka Resistance/Potion of Resist Magicka
itemsList["p_magicka_resistance_b"] = {
	name = "Bargain Magicka Resistance",
	id = "p_magicka_resistance_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_magicka_resistance_c"] = {
	name = "Cheap Magicka Resistance",
	id = "p_magicka_resistance_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_magicka_resistance_s"] = {
	name = "Standard Magicka Resistance",
	id = "p_magicka_resistance_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_magicka_resistance_q"] = {
	name = "Quality Magicka Resistance",
	id = "p_magicka_resistance_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_magicka_resistance_e"] = {
	name = "Exclusive Magicka Resistance",
	id = "p_magicka_resistance_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Poison Resistance/Potion of Resist Poison
itemsList["p_poison_resistance_b"] = {
	name = "Bargain Poison Resistance",
	id = "p_poison_resistance_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_poison_resistance_c"] = {
	name = "Cheap Poison Resistance",
	id = "p_poison_resistance_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_poison_resistance_s"] = {
	name = "Standard Poison Resistance",
	id = "p_poison_resistance_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_poison_resistance_q"] = {
	name = "Quality Poison Resistance",
	id = "p_poison_resistance_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_poison_resistance_e"] = {
	name = "Exclusive Poison Resistance",
	id = "p_poison_resistance_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Shock Resistance/Potion of Resist Shock
itemsList["p_shock_resistance_b"] = {
	name = "Bargain Shock Resistance",
	id = "p_shock_resistance_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_shock_resistance_c"] = {
	name = "Cheap Shock Resistance",
	id = "p_shock_resistance_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_shock_resistance_s"] = {
	name = "Standard Shock Resistance",
	id = "p_shock_resistance_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_shock_resistance_q"] = {
	name = "Quality Shock Resistance",
	id = "p_shock_resistance_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_shock_resistance_e"] = {
	name = "Exclusive Shock Resistance",
	id = "p_shock_resistance_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Restore Fatigue
itemsList["p_restore_fatigue_b"] = {
	name = "Bargain Restore Fatigue",
	id = "p_restore_fatigue_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_restore_fatigue_c"] = {
	name = "Cheap Restore Fatigue",
	id = "p_restore_fatigue_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_restore_fatigue_s"] = {
	name = "Standard Restore Fatigue",
	id = "p_restore_fatigue_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_restore_fatigue_q"] = {
	name = "Quality Restore Fatigue",
	id = "p_restore_fatigue_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_restore_fatigue_e"] = {
	name = "Exclusive Restore Fatigue",
	id = "p_restore_fatigue_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Restore Health
itemsList["p_restore_health_b"] = {
	name = "Bargain Restore Health",
	id = "p_restore_health_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_restore_health_c"] = {
	name = "Cheap Restore Health",
	id = "p_restore_health_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_restore_health_s"] = {
	name = "Standard Restore Health Potion",
	id = "p_restore_health_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_restore_health_q"] = {
	name = "Quality Restore Health",
	id = "p_restore_health_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_restore_health_e"] = {
	name = "Exclusive Restore Health",
	id = "p_restore_health_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Restore Magicka
itemsList["p_restore_magicka_b"] = {
	name = "Bargain Restore Magicka",
	id = "p_restore_magicka_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_restore_magicka_c"] = {
	name = "Cheap Restore Magicka",
	id = "p_restore_magicka_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_restore_magicka_s"] = {
	name = "Standard Restore Magicka Potion",
	id = "p_restore_magicka_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_restore_magicka_q"] = {
	name = "Quality Restore Magicka",
	id = "p_restore_magicka_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_restore_magicka_e"] = {
	name = "Exclusive Restore Magicka",
	id = "p_restore_magicka_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Restore Agility
itemsList["p_restore_agility_b"] = {
	name = "Bargain Restore Agility",
	id = "p_restore_agility_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_restore_agility_c"] = {
	name = "Cheap Restore Agility",
	id = "p_restore_agility_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_restore_agility_s"] = {
	name = "Standard Restore Agility",
	id = "p_restore_agility_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_restore_agility_q"] = {
	name = "Quality Restore Agility",
	id = "p_restore_agility_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_restore_agility_e"] = {
	name = "Exclusive Restore Agility",
	id = "p_restore_agility_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Restore Endurance
itemsList["p_restore_endurance_b"] = {
	name = "Bargain Restore Endurance",
	id = "p_restore_endurance_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_restore_endurance_c"] = {
	name = "Cheap Restore Endurance",
	id = "p_restore_endurance_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_restore_endurance_s"] = {
	name = "Standard Restore Endurance",
	id = "p_restore_endurance_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_restore_endurance_q"] = {
	name = "Quality Restore Endurance",
	id = "p_restore_endurance_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_restore_endurance_e"] = {
	name = "Exclusive Restore Endurance",
	id = "p_restore_endurance_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Restore Intelligence
itemsList["p_restore_intelligence_b"] = {
	name = "Bargain Restore Intelligence",
	id = "p_restore_intelligence_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_restore_intelligence_c"] = {
	name = "Cheap Restore Intelligence",
	id = "p_restore_intelligence_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_restore_intelligence_s"] = {
	name = "Standard Restore Intelligence",
	id = "p_restore_intelligence_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_restore_intelligence_q"] = {
	name = "Quality Restore Intelligence",
	id = "p_restore_intelligence_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_restore_intelligence_e"] = {
	name = "Exclusive Restore Intelligence",
	id = "p_restore_intelligence_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Restore Luck
itemsList["p_restore_luck_b"] = {
	name = "Bargain Restore Luck",
	id = "p_restore_luck_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_restore_luck_c"] = {
	name = "Cheap Restore Luck",
	id = "p_restore_luck_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_restore_luck_s"] = {
	name = "Standard Restore Luck",
	id = "p_restore_luck_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_restore_luck_q"] = {
	name = "Quality Restore Luck",
	id = "p_restore_luck_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_restore_luck_e"] = {
	name = "Exclusive Restore Luck",
	id = "p_restore_luck_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Restore Personality
itemsList["p_restore_personality_b"] = {
	name = "Bargain Restore Personality",
	id = "p_restore_personality_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_restore_personality_c"] = {
	name = "Cheap Restore Personality",
	id = "p_restore_personality_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_restore_personality_s"] = {
	name = "Standard Restore Personality",
	id = "p_restore_personality_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_restore_personality_q"] = {
	name = "Quality Restore Personality",
	id = "p_restore_personality_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_restore_personality_e"] = {
	name = "Exclusive Restore Personality",
	id = "p_restore_personality_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Restore Speed
itemsList["p_restore_speed_b"] = {
	name = "Bargain Restore Speed",
	id = "p_restore_speed_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_restore_speed_c"] = {
	name = "Cheap Restore Speed",
	id = "p_restore_speed_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_restore_speed_s"] = {
	name = "Standard Restore Speed",
	id = "p_restore_speed_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_restore_speed_q"] = {
	name = "Quality Restore Speed",
	id = "p_restore_speed_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_restore_speed_e"] = {
	name = "Exclusive Restore Speed",
	id = "p_restore_speed_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Restore Strength
itemsList["p_restore_strength_b"] = {
	name = "Bargain Restore Strength",
	id = "p_restore_strength_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_restore_strength_c"] = {
	name = "Cheap Restore Strength",
	id = "p_restore_strength_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_restore_strength_s"] = {
	name = "Standard Restore Strength",
	id = "p_restore_strength_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_restore_strength_q"] = {
	name = "Quality Restore Strength",
	id = "p_restore_strength_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_restore_strength_e"] = {
	name = "Exclusive Restore Strength",
	id = "p_restore_strength_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Restore Willpower
itemsList["p_restore_willpower_b"] = {
	name = "Bargain Restore Willpower",
	id = "p_restore_willpower_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_restore_willpower_c"] = {
	name = "Cheap Restore Willpower",
	id = "p_restore_willpower_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_restore_willpower_s"] = {
	name = "Standard Restore Willpower",
	id = "p_restore_willpower_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_restore_willpower_q"] = {
	name = "Quality Restore Willpower",
	id = "p_restore_willpower_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_restore_willpower_e"] = {
	name = "Exclusive Restore Willpower",
	id = "p_restore_willpower_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Fortify Agility
itemsList["p_fortify_agility_b"] = {
	name = "Bargain Fortify Agility",
	id = "p_fortify_agility_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_fortify_agility_c"] = {
	name = "Cheap Fortify Agility",
	id = "p_fortify_agility_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_fortify_agility_s"] = {
	name = "Standard Fortify Agility Potion",
	id = "p_fortify_agility_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_fortify_agility_q"] = {
	name = "Quality Fortify Agility",
	id = "p_fortify_agility_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_fortify_agility_e"] = {
	name = "Exclusive Fortify Agility",
	id = "p_fortify_agility_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Fortify Endurance
itemsList["p_fortify_endurance_b"] = {
	name = "Bargain Fortify Endurance",
	id = "p_fortify_endurance_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_fortify_endurance_c"] = {
	name = "Cheap Fortify Endurance",
	id = "p_fortify_endurance_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_fortify_endurance_s"] = {
	name = "Standard Fortify Endurance",
	id = "p_fortify_endurance_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_fortify_endurance_q"] = {
	name = "Quality Fortify Endurance",
	id = "p_fortify_endurance_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_fortify_endurance_e"] = {
	name = "Exclusive Fortify Endurance",
	id = "p_fortify_endurance_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Fortify Intelligence
itemsList["p_fortify_intelligence_b"] = {
	name = "Bargain Fortify Intelligence",
	id = "p_fortify_intelligence_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_fortify_intelligence_c"] = {
	name = "Cheap Fortify Intelligence",
	id = "p_fortify_intelligence_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_fortify_intelligence_s"] = {
	name = "Standard Fortify Intelligence",
	id = "p_fortify_intelligence_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_fortify_intelligence_q"] = {
	name = "Quality Fortify Intelligence",
	id = "p_fortify_intelligence_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_fortify_intelligence_e"] = {
	name = "Exclusive Fortify Intelligence",
	id = "p_fortify_intelligence_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Fortify Luck
itemsList["p_fortify_luck_b"] = {
	name = "Bargain Potion of Fortify Luck",
	id = "p_fortify_luck_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_fortify_luck_c"] = {
	name = "Cheap Potion of Fortify Luck",
	id = "p_fortify_luck_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_fortify_luck_s"] = {
	name = "Standard Fortify Luck Potion",
	id = "p_fortify_luck_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_fortify_luck_q"] = {
	name = "Quality Potion of Fortify Luck",
	id = "p_fortify_luck_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_fortify_luck_e"] = {
	name = "Exclusive Fortify Luck",
	id = "p_fortify_luck_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Fortify Personality
itemsList["p_fortify_personality_b"] = {
	name = "Bargain Fortify Personality",
	id = "p_fortify_personality_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_fortify_personality_c"] = {
	name = "Cheap Fortify Personality",
	id = "p_fortify_personality_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_fortify_personality_s"] = {
	name = "Standard Fortify Personality",
	id = "p_fortify_personality_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_fortify_personality_q"] = {
	name = "Quality Fortify Personality",
	id = "p_fortify_personality_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_fortify_personality_e"] = {
	name = "Exclusive Fortify Personality",
	id = "p_fortify_personality_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Fortify Speed
itemsList["p_fortify_speed_b"] = {
	name = "Bargain Potion of Fortify Speed",
	id = "p_fortify_speed_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_fortify_speed_c"] = {
	name = "Cheap Potion of Fortify Speed",
	id = "p_fortify_speed_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_fortify_speed_s"] = {
	name = "Standard Fortify Speed",
	id = "p_fortify_speed_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_fortify_speed_q"] = {
	name = "Quality Potion of Fortify Speed",
	id = "p_fortify_speed_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_fortify_speed_e"] = {
	name = "Exclusive Potion of Fortify Speed",
	id = "p_fortify_speed_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Fortify Strength
itemsList["p_fortify_strength_b"] = {
	name = "Bargain Fortify Strength",
	id = "p_fortify_strength_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_fortify_strength_c"] = {
	name = "Cheap Fortify Strength",
	id = "p_fortify_strength_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_fortify_strength_s"] = {
	name = "Standard Fortify Strength",
	id = "p_fortify_strength_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_fortify_strength_q"] = {
	name = "Quality Fortify Strength",
	id = "p_fortify_strength_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_fortify_strength_e"] = {
	name = "Exclusive Fortify Strength",
	id = "p_fortify_strength_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}
--Potion of Fortify Willpower
itemsList["p_fortify_willpower_b"] = {
	name = "Bargain Fortify Willpower",
	id = "p_fortify_willpower_b",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1.5,
	value = 5,
	rank = 2,
	effectData = {},
}
itemsList["p_fortify_willpower_c"] = {
	name = "Cheap Fortify Willpower",
	id = "p_fortify_willpower_c",
	itemType = "alchemy",
	subtype = "potion",
	weight = 1,
	value = 15,
	rank = 3,
	effectData = {},
}
itemsList["p_fortify_willpower_s"] = {
	name = "Standard Fortify Willpower",
	id = "p_fortify_willpower_s",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.75,
	value = 35,
	rank = 4,
	effectData = {},
}
itemsList["p_fortify_willpower_q"] = {
	name = "Quality Fortify Willpower",
	id = "p_fortify_willpower_q",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.5,
	value = 80,
	rank = 5,
	effectData = {},
}
itemsList["p_fortify_willpower_e"] = {
	name = "Exclusive Fortify Willpower",
	id = "p_fortify_willpower_e",
	itemType = "alchemy",
	subtype = "potion",
	weight = 0.25,
	value = 175,
	rank = 6,
	effectData = {},
}


--Spoiled Potions
--Spoiled Cure Disease Potion 1
itemsList["p_drain_luck_q"] = {
	name = "Spoiled Cure Disease Potion",
	id = "p_drain_luck_q",
	itemType = "alchemy",
	subtype = "spoiled",
	weight = 1,
	value = 10,
	rank = 1,
	effectData = {},
}
--Spoiled Cure Disease Potion 2
itemsList["p_drain_strength_q"] = {
	name = "Spoiled Cure Disease Potion",
	id = "p_drain_strength_q",
	itemType = "alchemy",
	subtype = "spoiled",
	weight = 1,
	value = 10,
	rank = 1,
	effectData = {},
}
--Spoiled Cure Disease Potion 3
itemsList["p_drain willpower_q"] = {
	name = "Spoiled Cure Disease Potion",
	id = "p_drain willpower_q",
	itemType = "alchemy",
	subtype = "spoiled",
	weight = 1,
	value = 10,
	rank = 1,
	effectData = {},
}
--Spoiled Cure Poison Potion 1
itemsList["p_drain_magicka_q"] = {
	name = "Spoiled Cure Poison Potion",
	id = "p_drain_magicka_q",
	itemType = "alchemy",
	subtype = "spoiled",
	weight = 1,
	value = 10,
	rank = 1,
	effectData = {},
}
--Spoiled Cure Poison Potion 2
itemsList["p_drain_speed_q"] = {
	name = "Spoiled Cure Poison Potion",
	id = "p_drain_speed_q",
	itemType = "alchemy",
	subtype = "spoiled",
	weight = 1,
	value = 10,
	rank = 1,
	effectData = {},
}
--Spoiled SlowFall Potion 1
itemsList["p_drain_agility_q"] = {
	name = "Spoiled SlowFall Potion",
	id = "p_drain_agility_q",
	itemType = "alchemy",
	subtype = "spoiled",
	weight = 1,
	value = 10,
	rank = 1,
	effectData = {},
}
--Spoiled SlowFall Potion 2
itemsList["p_drain_endurance_q"] = {
	name = "Spoiled SlowFall Potion",
	id = "p_drain_endurance_q",
	itemType = "alchemy",
	subtype = "spoiled",
	weight = 1,
	value = 10,
	rank = 1,
	effectData = {},
}
--Spoiled Potion of Swift Swim 1
itemsList["p_drain_intelligence_q"] = {
	name = "Spoiled Potion of Swift Swim",
	id = "p_drain_intelligence_q",
	itemType = "alchemy",
	subtype = "spoiled",
	weight = 1,
	value = 10,
	rank = 1,
	effectData = {},
}
--Spoiled Potion of Swift Swim 2
itemsList["p_drain_personality_q"] = {
	name = "Spoiled Potion of Swift Swim",
	id = "p_drain_personality_q",
	itemType = "alchemy",
	subtype = "spoiled",
	weight = 1,
	value = 10,
	rank = 1,
	effectData = {},
}



--Beverages
--Ancient Dagoth Brandy
itemsList["potion_ancient_brandy"] = {
	name = "Ancient Dagoth Brandy",
	id = "potion_ancient_brandy",
	itemType = "alchemy",
	subtype = "beverage",
	weight = 0.5,
	value = 1500,
	rank = 0,
	effectData = {},
}
--Cyrodiilic Brandy
itemsList["potion_cyro_brandy_01"] = {
	name = "Cyrodiilic Brandy",
	id = "potion_cyro_brandy_01",
	itemType = "alchemy",
	subtype = "beverage",
	weight = 1,
	value = 100,
	rank = 0,
	effectData = {},
}
--Flin
itemsList["Potion_Cyro_Whiskey_01"] = {
	name = "Flin",
	id = "Potion_Cyro_Whiskey_01",
	itemType = "alchemy",
	subtype = "beverage",
	weight = 1,
	value = 100,
	rank = 0,
	effectData = {},
}
--Greef
itemsList["potion_comberry_brandy_01"] = {
	name = "Greed",
	id = "potion_comberry_brandy_01",
	itemType = "alchemy",
	subtype = "beverage",
	weight = 5,
	value = 30,
	rank = 0,
	effectData = {},
}
--Mazte
itemsList["Potion_Local_Brew_01"] = {
	name = "Mazte",
	id = "Potion_Local_Brew_01",
	itemType = "alchemy",
	subtype = "beverage",
	weight = 5,
	value = 10,
	rank = 0,
	effectData = {},
}
--Shein
itemsList["potion_comberry_wine_01"] = {
	name = "Shein",
	id = "potion_comberry_wine_01",
	itemType = "alchemy",
	subtype = "beverage",
	weight = 3,
	value = 10,
	rank = 0,
	effectData = {},
}
--Skooma
itemsList["potion_skooma_01"] = {
	name = "Skooma",
	id = "potion_skooma_01",
	itemType = "alchemy",
	subtype = "beverage",
	weight = 1,
	value = 500,
	rank = 0,
	effectData = {},
	skoomaRelated = true
}
--Sujamma
itemsList["potion_local_liquor_01"] = {
	name = "Sujamma",
	id = "potion_local_liquor_01",
	itemType = "alchemy",
	subtype = "beverage",
	weight = 3,
	value = 30,
	rank = 0,
	effectData = {},
}
--Vintage Brandy
itemsList["p_vintagecomberrybrandy1"] = {
	name = "Vintage Brandy",
	id = "p_vintagecomberrybrandy1",
	itemType = "alchemy",
	subtype = "beverage",
	weight = 1,
	value = 500,
	rank = 0,
	effectData = {},
}

--Special
--Trebonius' Potion of Curing
itemsList["p_cure_common_unique"] = {
	name = "Trebonius' Potion of Curing",
	id = "p_cure_common_unique",
	itemType = "alchemy",
	subtype = "special",
	weight = 1,
	value = 100,
	rank = 0,
	effectData = {},
}
--Potion of Heroism
itemsList["p_heroism_s"] = {
	name = "Potion of Heroism",
	id = "p_heroism_s",
	itemType = "alchemy",
	subtype = "special",
	weight = 0.5,
	value = 1456,
	rank = 0,
	effectData = {},
}
--Love Potion
itemsList["p_lovepotion_unique"] = {
	name = "Love Potion",
	id = "p_lovepotion_unique",
	itemType = "alchemy",
	subtype = "special",
	weight = 1.5,
	value = 35,
	rank = 0,
	effectData = {},
}
--Blood of the Quarra Masters
itemsList["p_quarrablood_UNIQUE"] = {
	name = "Blood of the Quarra Masters",
	id = "p_quarrablood_UNIQUE",
	itemType = "alchemy",
	subtype = "special",
	weight = 0.5,
	value = 5000,
	rank = 0,
	effectData = {},
}
--Sinyaramen's Potion
itemsList["p_sinyaramen_UNIQUE"] = {
	name = "Sinyaramen's Potion",
	id = "p_sinyaramen_UNIQUE",
	itemType = "alchemy",
	subtype = "special",
	weight = 0.5,
	value = 1502,
	rank = 0,
	effectData = {},
}

--Perfumes
--Telvanni Bug Musk
itemsList["potion_t_bug_musk_01"] = {
	name = "Telvanni Bug Musk",
	id = "potion_t_bug_musk_01",
	itemType = "alchemy",
	subtype = "perfume",
	weight = 1.5,
	value = 100,
	rank = 0,
	effectData = {},
}

--Tribunal Potions
--Wiki doesn't use the same categories for these...
--Elixir of the Imperfect
itemsList["p_Imperfect_Elixir"] = {
	name = "Elixir of the Imperfect",
	id = "p_Imperfect_Elixir",
	itemType = "alchemy",
	subtype = "special",
	weight = 1,
	value = 661,
	rank = 0,
	effectData = {},
}
--Hulking Fabricant Elixir
itemsList["hulking_fabricant_elixir"] = {
	name = "Hulking Fabricant Elixir",
	id = "hulking_fabricant_elixir",
	itemType = "alchemy",
	subtype = "special",
	weight = 5,
	value = 100,
	rank = 0,
	effectData = {},
}
--Pyroil Tar
itemsList["pyroil_tar_unique"] = {
	name = "Pyroil Tar",
	id = "pyroil_tar_unique",
	itemType = "alchemy",
	subtype = "special",
	weight = 1,
	value = 100,
	rank = 0,
	effectData = {},
}
--Spoiled Dwemer Oil
itemsList["p_dwemer_lubricant00"] = {
	name = "Spoiled Dwemer Oil",
	id = "p_dwemer_lubricant00",
	itemType = "alchemy",
	subtype = "special",
	weight = 2,
	value = 200,
	rank = 0,
	effectData = {},
}
--Verminous Fabricant Elixir
itemsList["verminous_fabricant_elixir"] = {
	name = "Verminous Fabricant Elixir",
	id = "verminous_fabricant_elixir",
	itemType = "alchemy",
	subtype = "special",
	weight = 5,
	value = 100,
	rank = 0,
	effectData = {},
}

--Bloodmoon potions
--Beverages
--Nord Mead
itemsList["potion_nord_mead"] = {
	name = "Nord Mead",
	id = "potion_nord_mead",
	itemType = "alchemy",
	subtype = "beverage",
	weight = 1,
	value = 80,
	rank = 0,
	effectData = {},
}

--**TOOLS**
--*LOCKPICKS*
--Morrowind Lockpicks
--Apprentice's Lockpick
itemsList["pick_apprentice_01"] = {
	name = "Apprentice's Lockpick",
	id = "pick_apprentice_01",
	itemType = "lockpick",
	weight = 0.25,
	value = 10,
	health = 25,
	quality = 1,
	rank = 1,
}
--Journeyman's Lockpick
itemsList["pick_journeyman_01"] = {
	name = "Journeyman's Lockpick",
	id = "pick_journeyman_01",
	itemType = "lockpick",
	weight = 0.25,
	value = 50,
	health = 25,
	quality = 1.1,
	rank = 2,
}
--Master's Lockpick
itemsList["pick_master"] = {
	name = "Master's Lockpick",
	id = "pick_master",
	itemType = "lockpick",
	weight = 0.25,
	value = 100,
	health = 25,
	quality = 1.3,
	rank = 3,
}
--Grandmaster's Pick
itemsList["pick_grandmaster"] = {
	name = "Grandmaster's Pick",
	id = "pick_grandmaster",
	itemType = "lockpick",
	weight = 0.25,
	value = 200,
	health = 25,
	quality = 1.4,
	rank = 4,
}
--Secret Master's Lockpick
itemsList["pick_secretmaster"] = {
	name = "Secret Master's Lockpick",
	id = "pick_secretmaster",
	itemType = "lockpick",
	weight = 0.25,
	value = 500,
	health = 25,
	quality = 1.5,
	rank = 5,
}
--The Skeleton Key
itemsList["skeleton_key"] = {
	name = "The Skeleton Key",
	id = "skeleton_key",
	itemType = "lockpick",
	weight = 0.5,
	value = 1000,
	health = 50,
	quality = 5,
	rank = 0,
}

-- *PROBES*
--Morrowind Probes
--Bent Probe
itemsList["probe_bent"] = {
	name = "Bent Probe",
	id = "probe_bent",
	itemType = "probe",
	weight = 0.25,
	value = 2,
	health = 5,
	quality = 0.25,
	rank = 0,
}
--Apprentice's Probe
itemsList["probe_apprentice_01"] = {
	name = "Apprentice's Probe",
	id = "probe_apprentice_01",
	itemType = "probe",
	weight = 1,
	value = 10,
	health = 25,
	quality = 0.5,
	rank = 1,
}
--Journeyman's Probe
itemsList["probe_journeyman_01"] = {
	name = "Journeyman's Probe",
	id = "probe_journeyman_01",
	itemType = "probe",
	weight = 0.25,
	value = 50,
	health = 25,
	quality = 0.75,
	rank = 2,
}
--Master's Probe
itemsList["probe_master"] = {
	name = "Master's Probe",
	id = "probe_master",
	itemType = "probe",
	weight = 0.25,
	value = 100,
	health = 25,
	quality = 1,
	rank = 3,
}
--Grandmaster's Probe
itemsList["probe_grandmaster"] = {
	name = "Grandmaster's Probe",
	id = "probe_grandmaster",
	itemType = "probe",
	weight = 0.25,
	value = 200,
	health = 25,
	quality = 1.25,
	rank = 4,
}
--Secret Master's Probe
itemsList["probe_secretmaster"] = {
	name = "Secret Master's Probe",
	id = "probe_secretmaster",
	itemType = "probe",
	weight = 0.25,
	value = 500,
	health = 25,
	quality = 1.5,
	rank = 5,
}

-- *REPAIR TOOLS*
-- Morrowind repair tools
--Repair Prongs
itemsList["repair_prongs"] = {
	name = "Repair Prongs",
	id = "repair_prongs",
	itemType = "repair item",
	weight = 2.5,
	value = 6,
	health = 25,
	quality = 0.5,
	rank = 0,
}
--Apprentice's Armorer's Hammer
itemsList["hammer_repair"] = {
	name = "Apprentice's Armorer's Hammer",
	id = "hammer_repair",
	itemType = "repair item",
	weight = 4,
	value = 10,
	health = 20,
	quality = 0.8,
	rank = 1,
}
--Journeyman's Armorer's Hammer
itemsList["repair_journeyman_01"] = {
	name = "Journeyman's Armorer's Hammer",
	id = "repair_journeyman_01",
	itemType = "repair item",
	weight = 3,
	value = 20,
	health = 20,
	quality = 1,
	rank = 2,
}
--Master's Armorer's Hammer
itemsList["repair_master_01"] = {
	name = "Master's Armorer's Hammer",
	id = "repair_master_01",
	itemType = "repair item",
	weight = 2,
	value = 50,
	health = 10,
	quality = 1.3,
	rank = 3,
}
--GrandMaster's Armorer's Hammer
itemsList["repair_grandmaster_01"] = {
	name = "GrandMaster's Armorer's Hammer",
	id = "repair_grandmaster_01",
	itemType = "repair item",
	weight = 1,
	value = 100,
	health = 10,
	quality = 1.7,
	rank = 4,
}
--Sirollus Saccus' Hammer
itemsList["repair_secretmaster_01"] = {
	name = "Sirollus Saccus' Hammer",
	id = "repair_secretmaster_01",
	itemType = "repair item",
	weight = 1,
	value = 200,
	health = 10,
	quality = 2,
	rank = 5,
}

-- *ALCHEMY APPARATUS*
--Morrowind Apparatus
--Apprentice's Alembic
itemsList["apparatus_a_alembic_01"] = {
	name = "Apprentice's Alembic",
	id = "apparatus_a_alembic_01",
	itemType = "apparatus", 
	subtype = "alembic",
	weight = 10,
	value = 50,
	quality = 0.5,
	rank = 1,
}
--Apprentice's Calcinator
itemsList["apparatus_a_calcinator_01"] = {
	name = "Apprentice's Calcinator",
	id = "apparatus_a_calcinator_01",
	itemType = "apparatus", 
	subtype = "calcinator",
	weight = 25,
	value = 10,
	quality = 0.5,
	rank = 1,
}
--Apprentice's Mortar and Pestle
itemsList["apparatus_a_mortar_01"] = {
	name = "Apprentice's Mortar and Pestle",
	id = "apparatus_a_mortar_01",
	itemType = "apparatus", 
	subtype = "mortar",
	weight = 5,
	value = 100,
	quality = 0.5,
	rank = 1,
}
--Apprentice's Retort
itemsList["apparatus_a_retort_01"] = {
	name = "Apprentice's Retort",
	id = "apparatus_a_retort_01",
	itemType = "apparatus", 
	subtype = "retort",
	weight = 8,
	value = 20,
	quality = 0.5,
	rank = 1,
}
--Journeyman's Alembic
itemsList["apparatus_j_alembic_01"] = {
	name = "Journeyman's Alembic",
	id = "apparatus_j_alembic_01",
	itemType = "apparatus", 
	subtype = "alembic",
	weight = 7,
	value = 200,
	quality = 1,
	rank = 2,
}
--Journeyman's Calcinator
itemsList["apparatus_j_calcinator_01"] = {
	name = "Journeyman's Calcinator",
	id = "apparatus_j_calcinator_01",
	itemType = "apparatus", 
	subtype = "calcinator",
	weight = 18,
	value = 40,
	quality = 1,
	rank = 2,
}
--Journeyman's Mortar and Pestle
itemsList["apparatus_j_mortar_01"] = {
	name = "Journeyman's Mortar and Pestle",
	id = "apparatus_j_mortar_01",
	itemType = "apparatus", 
	subtype = "mortar",
	weight = 4,
	value = 400,
	quality = 1,
	rank = 2,
}
--Journeyman's Retort
itemsList["apparatus_j_retort_01"] = {
	name = "Journeyman's Retort",
	id = "apparatus_j_retort_01",
	itemType = "apparatus", 
	subtype = "retort",
	weight = 6,
	value = 80,
	quality = 1,
	rank = 2,
}
--Master's Alembic
itemsList["apparatus_m_alembic_01"] = {
	name = "Master's Alembic",
	id = "apparatus_m_alembic_01",
	itemType = "apparatus", 
	subtype = "alembic",
	weight = 5,
	value = 1200,
	quality = 1.2,
	rank = 3,
}
--Master's Calcinator
itemsList["apparatus_m_calcinator_01"] = {
	name = "Master's Calcinator",
	id = "apparatus_m_calcinator_01",
	itemType = "apparatus", 
	subtype = "calcinator",
	weight = 13,
	value = 240,
	quality = 1.2,
	rank = 3,
}
--Master's Mortar and Pestle
itemsList["apparatus_m_mortar_01"] = {
	name = "Master's Mortar and Pestle",
	id = "apparatus_m_mortar_01",
	itemType = "apparatus", 
	subtype = "mortar",
	weight = 3,
	value = 2400,
	quality = 1.2,
	rank = 3,
}
--Master's Retort
itemsList["apparatus_m_retort_01"] = {
	name = "Master's Retort",
	id = "apparatus_m_retort_01",
	itemType = "apparatus", 
	subtype = "retort",
	weight = 4,
	value = 480,
	quality = 1.2,
	rank = 3,
}
--Grandmaster's Alembic
itemsList["apparatus_g_alembic_01"] = {
	name = "Grandmaster's Alembic",
	id = "apparatus_g_alembic_01",
	itemType = "apparatus", 
	subtype = "alembic",
	weight = 3,
	value = 4000,
	quality = 1.5,
	rank = 4,
}
--Grandmaster's Calcinator
itemsList["apparatus_g_calcinator_01"] = {
	name = "Grandmaster's Calcinator",
	id = "apparatus_g_calcinator_01",
	itemType = "apparatus", 
	subtype = "calcinator",
	weight = 8,
	value = 4000,
	quality = 1.5,
	rank = 4,
}
--Grandmaster's Mortar and Pestle
itemsList["apparatus_g_mortar_01"] = {
	name = "Grandmaster's Mortar and Pestle",
	id = "apparatus_g_mortar_01",
	itemType = "apparatus", 
	subtype = "mortar",
	weight = 2,
	value = 4000,
	quality = 1.5,
	rank = 4,
}
--Grandmaster's Retort
itemsList["apparatus_g_retort_01"] = {
	name = "Grandmaster's Retort",
	id = "apparatus_g_retort_01",
	itemType = "apparatus", 
	subtype = "retort",
	weight = 3,
	value = 1600,
	quality = 1.5,
	rank = 4,
}
--SecretMaster's Alembic
itemsList["apparatus_sm_alembic_01"] = {
	name = "SecretMaster's Alembic",
	id = "apparatus_sm_alembic_01",
	itemType = "apparatus", 
	subtype = "alembic",
	weight = 3,
	value = 1600,
	quality = 2,
	rank = 5,
}
--SecretMaster's Calcinator
itemsList["apparatus_sm_calcinator_01"] = {
	name = "SecretMaster's Calcinator",
	id = "apparatus_sm_calcinator_01",
	itemType = "apparatus", 
	subtype = "calcinator",
	weight = 6,
	value = 3200,
	quality = 2,
	rank = 5,
}
--SecretMaster's Mortar and Pestl
itemsList["apparatus_sm_mortar_01"] = {
	name = "SecretMaster's Mortar and Pestl", --Note: Misspelled ingame
	id = "apparatus_sm_mortar_01",
	itemType = "apparatus", 
	subtype = "mortar",
	weight = 1,
	value = 6000,
	quality = 2,
	rank = 5,
}
--SecretMaster's Retort
itemsList["apparatus_sm_retort_01"] = {
	name = "SecretMaster's Retort",
	id = "apparatus_sm_retort_01",
	itemType = "apparatus", 
	subtype = "retort",
	weight = 2,
	value = 1000,
	quality = 2,
	rank = 5,
}
--Good Skooma Pipe
itemsList["apparatus_a_spipe_01"] = {
	name = "Good Skooma Pipe",
	id = "apparatus_a_spipe_01",
	itemType = "apparatus", 
	subtype = "alembic",
	weight = 2,
	value = 50,
	quality = 0.15,
	rank = 0,
}
--Tsiya's Skooma Pipe
itemsList["apparatus_a_spipe_tsiya"] = {
	name = "Tsiya's Skooma Pipe",
	id = "apparatus_a_spipe_tsiya",
	itemType = "apparatus", 
	subtype = "alembic",
	weight = 2,
	value = 30,
	quality = 0.15,
	rank = 0,
}
-- **INGREDIENTS**
-- Morrowind Ingredients
-- Some high-ticket items (perhaps stretching the definition of "high-ticket")
--Ash Salts
itemsList["ingred_ash_salts_01"] = {
	name = "Ash Salts",
	id = "ingred_ash_salts_01",
	itemType = "ingredient",
	value = 25,
	weight = 0.1,
	ingredientData = {},
}
--Corprus Weepings
itemsList["ingred_corprus_weepings_01"] = {
	name = "Corprus Weepings",
	id = "ingred_corprus_weepings_01",
	itemType = "ingredient",
	value = 50,
	weight = 0.1,
	ingredientData = {},
}
--Daedra Skin
itemsList["ingred_daedra_skin_01"] = {
	name = "Daedra Skin",
	id = "ingred_daedra_skin_01",
	itemType = "ingredient",
	value = 200,
	weight = 0.2,
	ingredientData = {},
}
--Daedra's Heart
itemsList["ingred_daedras_heart_01"] = {
	name = "Daedra's Heart",
	id = "ingred_daedras_heart_01",
	itemType = "ingredient",
	value = 200,
	weight = 1,
	ingredientData = {},
}
--Diamond
itemsList["ingred_diamond_01"] = {
	name = "Diamond",
	id = "ingred_diamond_01",
	itemType = "ingredient",
	value = 250,
	weight = 0.2,
	ingredientData = {},
}
--Dreugh Wax
itemsList["ingred_dreugh_wax_01"] = {
	name = "Dreugh Wax",
	id = "ingred_dreugh_wax_01",
	itemType = "ingredient",
	value = 100,
	weight = 0.2,
	ingredientData = {},
}
--Emerald
itemsList["ingred_emerald_01"] = {
	name = "Emerald",
	id = "ingred_emerald_01",
	itemType = "ingredient",
	value = 150,
	weight = 0.2,
	ingredientData = {},
}
--Fire Salts
itemsList["ingred_fire_salts_01"] = {
	name = "Fire Salts",
	id = "ingred_fire_salts_01",
	itemType = "ingredient",
	value = 100,
	weight = 0.1,
	ingredientData = {},
}
--Frost Salts
itemsList["ingred_frost_salts_01"] = {
	name = "Frost Salts",
	id = "ingred_frost_salts_01",
	itemType = "ingredient",
	value = 75,
	weight = 0.1,
	ingredientData = {},
}
--Ghoul Heart
itemsList["ingred_ghoul_heart_01"] = {
	name = "Ghoul Heart",
	id = "ingred_ghoul_heart_01",
	itemType = "ingredient",
	value = 150,
	weight = 0.5,
	ingredientData = {},
}
--Hackle-Lo Leaf
itemsList["ingred_hackle-lo_leaf_01"] = {
	name = "Hackle-Lo Leaf",
	id = "ingred_hackle-lo_leaf_01",
	itemType = "ingredient",
	value = 30,
	weight = 0.1,
	ingredientData = {},
}
--Moon Sugar
itemsList["ingred_moon_sugar_01"] = {
	name = "Moon Sugar",
	id = "ingred_moon_sugar_01",
	itemType = "ingredient",
	value = 50,
	weight = 0.1,
	ingredientData = {},
	skoomaRelated = true,
}
--Pearl
itemsList["ingred_pearl_01"] = {
	name = "Pearl",
	id = "ingred_pearl_01",
	itemType = "ingredient",
	value = 100,
	weight = 0.2,
	ingredientData = {},
}
--Raw Ebony
itemsList["ingred_raw_ebony_01"] = {
	name = "Raw Ebony",
	id = "ingred_raw_ebony_01",
	itemType = "ingredient",
	value = 200,
	weight = 10,
	ingredientData = {},
}
--Raw Glass
itemsList["ingred_raw_glass_01"] = {
	name = "Raw Glass",
	id = "ingred_raw_glass_01",
	itemType = "ingredient",
	value = 200,
	weight = 2,
	ingredientData = {},
}
--Ruby
itemsList["ingred_ruby_01"] = {
	name = "Ruby",
	id = "ingred_ruby_01",
	itemType = "ingredient",
	value = 200,
	weight = 0.2,
	ingredientData = {},
}
--Scrap Metal
itemsList["ingred_scrap_metal_01"] = {
	name = "Scrap Metal",
	id = "ingred_scrap_metal_01",
	itemType = "ingredient",
	value = 20,
	weight = 10,
	ingredientData = {},
}
--Shalk Resin
itemsList["ingred_shalk_resin_01"] = {
	name = "Shalk Resin",
	id = "ingred_shalk_resin_01",
	itemType = "ingredient",
	value = 50,
	weight = 0.1,
	ingredientData = {},
}
--Sload Soap
itemsList["ingred_sload_soap_01"] = {
	name = "Sload Soap",
	id = "ingred_sload_soap_01",
	itemType = "ingredient",
	value = 50,
	weight = 0.1,
	ingredientData = {},
}
--Vampire Dust
itemsList["ingred_vampire_dust_01"] = {
	name = "Vampire Dust",
	id = "ingred_vampire_dust_01",
	itemType = "ingredient",
	value = 500,
	weight = 0.1,
	ingredientData = {},
}
--Void Salts
itemsList["ingred_void_salts_01"] = {
	name = "Void Salts",
	id = "ingred_void_salts_01",
	itemType = "ingredient",
	value = 100,
	weight = 0.1,
	ingredientData = {},
}

--Tribunal Ingredients
-- High-ticket
--Adamantium Ore
itemsList["ingred_adamantium_ore_01"] = {
	name = "Adamantium Ore",
	id = "ingred_adamantium_ore_01",
	itemType = "ingredient",
	value = 300,
	weight = 50,
	ingredientData = {},
}

--Bloodmoon Ingredients
-- High-ticket
--Heartwood
itemsList["ingred_heartwood_01"] = {
	name = "Heartwood",
	id = "ingred_heartwood_01",
	itemType = "ingredient",
	value = 200,
	weight = 1,
	ingredientData = {},
}
--Raw Stalhrim
itemsList["ingred_raw_Stalhrim_01"] = {
	name = "Raw Stalhrim",
	id = "ingred_raw_Stalhrim_01",
	itemType = "ingredient",
	value = 300,
	weight = 5,
	ingredientData = {},
}


-- HACKNESS
--Because tes3mp stores all item ids as lowercase, rather than matching the capitalisation of the original game and I filled out most of the information without knowing that, we need to duplicate all entries that contain capitalisation into an all lowercase entry
do
	local hacked = 0
	local additions = {}
	for k, v in pairs(itemsList) do
		if k ~= string.lower(k) then
			additions[string.lower(k)] = v
			hacked = hacked + 1
		end
	end
	tableHelper.merge(itemsList, additions)
	tes3mp.LogMessage(1,"itemInfo hacked " .. hacked .. " entries into duplicate lowercase ones.")
end

-- USABILITY

--For adding new entries to the list. data should be structured in the same manner as the normal items.
Methods.RegisterItem = function(data)
	itemsList[data.id] = data
end

-- GENERAL

--returns the item data entry
Methods.GetItemData = function(itid)
	return itemsList[itid]
end

--returns gold value of item
Methods.GetItemValue = function(itid)
	return itemsList[itid].value
end

--returns weight of item
Methods.GetItemWeight = function(itid)
	return itemsList[itid].weight
end

--returns name of item
Methods.GetItemName = function(itid)
	return itemsList[itid].name
end

--returns type of item
Methods.GetItemType = function(itid)
	return itemsList[itid].itemType
end

--returns subtype of item
Methods.GetItemType = function(itid)
	return itemsList[itid].subtype
end

--returns material of item
Methods.GetItemMaterial = function(itid)
	return itemsList[itid].material
end

--returns gold value divided by weight
Methods.GetItemGoldPerWeight = function(itid)
	return (itemsList[itid].value / itemsList[itid].weight)
	--Might have problems if weight is zero?
end

--returns maximum durability for weapons/armor
Methods.GetMaxDurability = function(itid)
	return itemsList[itid].health
end

--returns starting number of uses for tools. Technically identical to GetMaxDurability
Methods.GetMaxUses = function(itid)
	return itemsList[itid].health
end

--returns skill name of skill associated with the item (weapon skill for weapons, armour skill for armour, boosted skill for skillbooks)
Methods.GetItemSkillName = function(itid)
	return tes3mp.getSkillName(itemsList[itid].skillId)
end

Methods.GetItemSkillId = function(itid)
	return itemsList[itid].skillId
end

--returns item's rank
Methods.GetRankNumber = function(itid)
	return temsList[itid].rank
end

--Returns a formatted name based on the item type and rank
Methods.GetRankName = function(itid)
	local clothing = {[0] = "special", [1] = "common", [2] = "expensive", [3] = "extravagant", [4] = "exquisite"}
	local tools = {[0] = "special", [1] = "apprentice", [2] = "journeyman", [3] = "master", [4] = "grandmaster", [5] = "secret master"}
	local potions = {[0] = "special", [1] = "spoiled", [2] = "bargain", [3] = "cheap", [4] = "standard", [5] = "quality", [6] = "exclusive"}
	
	local item = itemsList[itid]
	
	if item.itemType == "alchemy" then
		return potions[item.rank]
	elseif item.itemType == "clothing" then
		return clothing[item.rank]
	else
		return tools[item.rank]
	end
end

--returns orientation ("left" or "right")
Methods.GetItemOrientation = function(itid)
	return itemsList[itid].orientation
end

--returns true if moon sugar or skooma
Methods.IsSkoomaRelated = function(itid)
	return itemsList[itid].skoomaRelated
end

-- WEAPONS
Methods.IsNormalWeapon = function(itid)
	return itemsList[itid].normalWeapon
	--Would need to be expanded if accounting for player's custom enchantments.
end

local function GetBestMaxDamage(itid)
	local item = itemsList[itid]
	local best = false
	if item.itemType == "weapon" then
		if item.skillId == 23 then --Marksman weapon
			best = "ranged"
		else
			best = "chop"
			if item.weaponData.slashMax > item.weaponData.chopMax then
				best = "slash"
			end
			if item.weaponData.thrustMax > item.weaponData.slashMax then
				best = "thrust"
			end
		end
	end
	return best
end

--Wrapper for GetBestMaxDamage
Methods.GetBestAttack = function(itid)
	return GetBestMaxDamage(itid)
end

--Returns the attack style with the best max damage. If the best is tied, will return the latest one.
--Results are either: "chop", "slash", "thrust", "ranged", or false
Methods.GetBestMaxDamage = function(itid)
	return GetBestMaxDamage(itid)
end

--Returns the attack style with the best min damage. If the best is tied, will return the latest one.
--Results are either: "chop", "slash", "thrust", "ranged", or false
Methods.GetBestMinDamage = function(itid)
	local item = itemsList[itid]
	local best = false
	if item.itemType == "weapon" then
		if item.skillId == 23 then --Marksman weapon
			best = "ranged"
		else
			best = "chop"
			if item.weaponData.slashMin > item.weaponData.chopMin then
				best = "slash"
			end
			if item.weaponData.thrustMin > item.weaponData.slashMin then
				best = "thrust"
			end
		end
	end
	return best
end

--returns a weapon's reach value
Methods.GetWeaponReach = function(itid)
	return itemsList[itid].weaponData.reach
end

--returns a weapon's speed value
Methods.GetWeaponSpeed = function(itid)
	return itemsList[itid].weaponData.speed or itemsList[itid].marksSpeed
end


-- ARMOR
-- returns true if the item isn't restricted for Beast Races
Methods.CanBeastsWear = function(itid)
	local item = itemsList[itid]
	if item.subtype == "shoes" or item.subtype == "boots" then
		return false
	elseif item.subtype == "helm" and item.canBeast ~= true then
		return false
	else
		return true
	end
end

-- returns "light", "medium", or "heavy", or false based on item's armor type. Mostly exists for some nicer formatting
Methods.GetArmorType = function(itid)
	local item = itemsList[itid]
	if item.itemType ~= "armor" then
		return false
	else
		if item.skillId == "Heavyarmor" then
			return "heavy"
		elseif item.skillId == "Mediumarmor" then
			return "medium"
		else
			return "light"
		end
	end
end

--returns armour rating
Methods.GetArmorRating = function(itid)
	return itemsList[itid].rating
end

return Methods
