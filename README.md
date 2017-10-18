# tes3mp-scripts
Collection of all my scripts for tes3mp
## Scripts

## Resources
### itemInfo
A compilation of data on the game's items and some related functions for use in server scripts. Not all items are currently implemented.

### classInfo
A compilation of data on the game's base classes and some related functions for use in server scripts. NPC classes not yet implemented.
#### Usage
Needs to be *require*d somewhere.

See the file itself for full information on/list of Methods.

**classInfo.GetPlayerClassData(pid)**

returns a table of information on the provided player's class (custom or default).

**classInfo.GetCustomClassData(pid)**

returns a table of information on the provided player's custom class. Should probably just use **classInfo.GetPlayerClassData(pid)** instead.

**classInfo.GetClassData(className)**

returns a table of information on the provided class.

**classInfo.GetGovernedAttribute(skillId)**

returns the attribute id of the attribute that governs the skill.

**classInfo.GetSpecializationName(specializationId)**

returns the name of the specialization that has the provided specialization id (e.g. 0 returns "Combat")

#### Useful Default Functions
**tes3mp.GetAttributeName(attributeId)**

**tes3mp.GetSkillName(skillId)**

**tes3mp.GetAttributeId(attributeName)**

**tes3mp.GetSkillId(skillName)**
