# 0.7 tes3mp-scripts
Collection of all my scripts for tes3mp 0.7 (or, at least, 0.7-prerelease). The information for some scripts can be found here, however larger ones may have their own separate readme in their own folder. Unless otherwise stated, you can find installation instructions at the top of each file.

## Scripts
### decorateHelp
Todo
### flatModifiers
Change the way that the attribute advancement modifiers on level up are calculated. It can be configured to give a flat bonus to all players, or a tailored bonus based on their class. Requires *classInfo*.
#### Configuration
There are a number of configuration options available to edit in the file itself.
##### General
- **config.mode** ("basic" / "class") - Determines what mode the script should run in. If set to *basic*, the players will be given a set value to their attribute advancements (as dictated by **config.basicAttributeIncreases**). If set to *class*, the players will be given tailored attribute advancements based on aspects of their class (see *class mode* for the options)
- **config.includeLuck** (true / false) - Determines whether or not to include Luck in the calculations. By default, Morrowind doesn't allow bonuses to Luck.
##### Basic Mode
- **config.basicAttributeIncreases** - The number of increases towards stats that the script should fake.
##### Class Mode
- **config.classBase** - How many advancements to use as a base
- **config.classMajorSkillBonus** - How many advancements get added to an attribute per major skill governed by it
- **config.classMinorSkillBonus** - How many advancements get added to an attribute per minor skill governed by it
- **config.classAttributeBonus** - How many advancements get added to an attribute which is one of the class' major attributes
#### Useful Information
It takes the following number of advancements to achieve these levelup multipliers:
1-4 gives 2x, 5-7 gives 3x, 8-9 gives 4x, 10+ gives 5x.

## Resources
### classInfo
A compilation of data on the game's base classes and some related functions for use in server scripts. NPC classes not yet implemented.
#### Usage
Needs to be *require*d somewhere.

See the file itself for full information on/list of Methods.
- **classInfo.GetPlayerClassData(pid)** - returns a table of information on the provided player's class (custom or default).
- **classInfo.GetCustomClassData(pid)** -returns a table of information on the provided player's custom class. Should probably just use **classInfo.GetPlayerClassData(pid)** instead.
- **classInfo.GetClassData(className)** - returns a table of information on the provided class.
- **classInfo.GetGovernedAttribute(skillId)** - returns the attribute id of the attribute that governs the skill.
- **classInfo.GetSpecializationName(specializationId)** - returns the name of the specialization that has the provided specialization id (e.g. 0 returns "Combat")

#### Useful Default Functions
- **tes3mp.GetAttributeName(attributeId)**
- **tes3mp.GetSkillName(skillId)**
- **tes3mp.GetAttributeId(attributeName)**
- **tes3mp.GetSkillId(skillName)**
