# kanaStartingItems
Grant newly created characters some configurable starting items based on their race, class, skills, favored armor, and birthsign.

*Currently written for a version of 0.7-alpha*

## Usage
The script works automatically whenever a new character is created. By configuring the script you can govern extra items that a new player is given based off of their:
- Race
- Class - Note that only non-custom classes are supported by this script.
- High Skills - A stand-in for major skills, since scripts can't know the major skills for non-custom classes without being dependant on more scripts. What's considered a "high skill" is set by the `highSkillThreshold` configuration option (*see: Configuration*). Note that if a skill is high enough to be considered a "high skill", it doesn't *also* count as being a "low skill" for the purposes of being given "low skill" items.
- Low Skills - A stand-in for minor skills. As with "high skills" it has its own configuration option (`lowSkillThreshold`).
- Birthsign
- Best armor skill - The script determines which of the player's skills out of Heavy armor, Medium armor, Light armor, and unarmored is their best armor skill. If there are multiple skills tied at the same value, then the "best armor skill" is chosen arbitrarily.

Additionally, there is another configuration option for adding items to all players, regardless of criteria (so for example, you could give players 200 gold to start off with).

## Configuration
Configuration is done from within the file itself, by altering the `scriptConfig` values.
### General Options
- **highSkillThreshold** - Any skills with a level higher than this are considered "high skills". By default this value is set to `30`, which is the base amount that is added by a major skill.
- **lowSkillThreshold** - Any skills with a level higher than this (but lower than the `highSkillThreshold`) are considered "low skills". By default this value is set to `15`, which is the base amount that is added by a minor skill.
- **informPlayers** - If `true`, any player who generates a character and receives extra items because of this script will be given a notification message in chat. This is useful to let players know that they've got new items, as well as eliminate some confusion if they notice that they have some abnormal starting items.
- **message** - This is the message that players will receive in chat provided that `informPlayers` is set to `true`
### Item Configuration
The configuration options `raceItems` (what races get), `classItems` (what classes get), `highSkillItems` (what characters with a high skill get), `lowSkillItems` (what classes with a low skill get), `armorItems` (what each armor specialist gets), `birthsignItems` (what characters of a birthsign get), and `generalItems` (what *all* characters get) all govern the items that players receive. You'll need some knowledge of how lua tables work to make the edits, though you might be able to intuit what to do from the examples given. You don't have to keep the example entries (in fact, you'll probably want to remove them) - they're mostly there just to serve as examples, as well as being what I used when testing, rather than being properly thought out suggestions.

Items are listed inside a table, with each entry being a table containing the item's `refId` and `count` (how many) under their respective keys. With the exception of `generalItems`, each of the options requires entries to be within tables under certain keys. The keys you use for each are:
- **raceItems** - The race's ID. E.g. `Dark Elf` for dark elves, `Orc` for orcs.
- **classItems** - The class ID. E.g. `thief` for a thief
- **highSkillItems** and **lowSkillItems** and **armorItems** - The ID of the skill as it would appear in a player's `json`. E.g. `Handtohand` for hand-to-hand, `Mediumarmor` for medium armor
- **birthsignItems** - The birthsign's ID. E.g. `Wombburned` for The Atronach, `Mooncalf` for The Lover

*(You may notice that the examples don't follow the exact capitalization for each ID type - this is fine, since the script doesn't care about capitalization)*

## Installation
### Save the Script
Save the file as `kanaStartingItems.lua` inside your `server/scripts/custom` folder.
### Edits to `customScripts.lua`
- Add `kanaStartingItems = require("custom.kanaStartingItems")`

## Script Methods
There are Methods available for other scripts to add items to each of the categories. Check out the file itself to see what's available.
