# tes3mp-scripts
Collection of all my scripts for tes3mp. **Important note:** Many of these scripts are for v0.6, and only exist here so that links don't break. For scripts created for versions beyond v0.6, look in the appropriately named folders.
## Scripts
### flatModifiers
[Steam Disucssion](http://steamcommunity.com/groups/mwmulti/discussions/0/3182216552768549150/) - Change the way that the attribute advancement modifiers on level up are calculated.

### markRecall
[Steam Discussion](https://steamcommunity.com/groups/mwmulti/discussions/0/1488861734096173445/) - A patch that adds the functionality of marking and recalling via server command, useful until the spells get fixed.

### salesChest
[Steam Discussion](https://steamcommunity.com/groups/mwmulti/discussions/0/1483232961046461458/) - Players can claim containers and sell its contents.

### serverWarp
[Steam Discussion](https://steamcommunity.com/groups/mwmulti/discussions/0/1488861734099531437/) - Adds the ability to save locations and later warp to them.

## Resources
### itemInfo
[Steam Discussion](https://steamcommunity.com/groups/mwmulti/discussions/0/1483232961046419094/) - A compilation of data on the game's items and some related functions for use in server scripts. Not all items are currently implemented.

### classInfo
[Steam Discussion](https://steamcommunity.com/groups/mwmulti/discussions/0/1483233503861870523/) - A compilation of data on the game's base classes and some related functions for use in server scripts. NPC classes not yet implemented.
#### Usage
Needs to be *require*d somewhere.

See the file itself for full information on/list of Methods.

**classInfo.GetPlayerClassData(pid)** - returns a table of information on the provided player's class (custom or default).

**classInfo.GetCustomClassData(pid)** -returns a table of information on the provided player's custom class. Should probably just use **classInfo.GetPlayerClassData(pid)** instead.

**classInfo.GetClassData(className)** - returns a table of information on the provided class.

**classInfo.GetGovernedAttribute(skillId)** - returns the attribute id of the attribute that governs the skill.

**classInfo.GetSpecializationName(specializationId)** - returns the name of the specialization that has the provided specialization id (e.g. 0 returns "Combat")

#### Useful Default Functions
**tes3mp.GetAttributeName(attributeId)**

**tes3mp.GetSkillName(skillId)**

**tes3mp.GetAttributeId(attributeName)**

**tes3mp.GetSkillId(skillName)**

## Legacy Scripts
### salesChestGlobalHack
Just a quick hack of sales chest to add the global mode, before I actually added it in a less-hacky manner to the main script. Don't use this one. I don't even know why it's still here :P

### flatModifiersBasic
[Steam Discussion](https://steamcommunity.com/groups/mwmulti/discussions/0/1483233503861929448/) - Original version of flatModifiers, which wasn't dependant on classInfo.
