# kanaRevive
Players enter a downed state instead of dying. Other players can activate them to revive them before they bleedout.

*Currently written for a version of 0.7-aplha*

## Usage
When a player is killed, instead of dying, they enter a "downed" state - with a countdown until they die properly commencing (time, and whether there is a countdown are configurable). If another player activates them, the player is instantly revived, with their health, magicka, and fatigue being set to a value based on configuration options. While downed, the player has access to the `/die` command, which they can use to instantly trigger their death. If a player logs out during their bleedout countdown, they will resume from the point they left off when they next log in.

## Configuration
Configuration is done from within the file itself, by altering the `scriptConfig` values.
### Bleedout Options
There are two options for governing how bleedout works:
- `useBleedout` - If set to `true`, then a countdown will begin once a player is downed. If the timer runs out before the player is revived, they die properly. If set to `false`, the countdown doesn't begin, and the players will remain downed indefinitely until they're either revived, or they use the `/die` command.
- `bleedoutTime` - This determines the time (in seconds) that a player has before their countdown runs out. Obviously only relevant if `useBleedout` is set to `true`.
- `allowReviveWithPermadeath` - An option for permadeath servers to allow players to enter a downed state before dying. Set to `true` to enable this.
### Broadcast Options
Announcements are made into chat whenever: a player enters the downed state, a player is revived, a player who was downed dies. The "range" that these messages can be heard by other players can be set to three values:
- `"server"` - The message is broadcast to everyone on the server.
- `"cell"` - The message is broadcast to everyone who has the cell it happened in loaded.
- `"none"` - The message isn't broadcast.

Each announcement type can be edited independently. The configuration options for these announcement types are:
- `playerDownedAnnounceRadius` - Governs messages about a player entering the downed state.
- `reviveAnnounceRadius` - Governs messages about a player being revived.
- `playerDiedAnnounceRadius` - Governs messages about a player who was downed dying (bleeding out).

*(Note that players involved in the events receive their own special messages, rather than the general broadcast).*
### Stat Options
The value that each of a player's main stats (health, magicka, and fatigue) are set to after being revived can be handled in multiple ways. The mode that each stat uses can be edited by changing the configuration options `revivedHealthMode`, `revivedMagickaMode`, and `revivedFatigueMode` for health, magicka, and fatigue respectively. The valid modes are:
- `"set"` - The stat is set to a particular value. What value this will be is governed by the configuration options `setModeHealth`, `setModeMagicka`, and `setModeFatigue`.
- `"preserve"` - The stat will remain as it was.
- `"percent"` - The stat is set to be a percent of the player's maximum value for that stat. What percent modifier is used is governed by the configuration options `percentModeHealth`, `percentModeMagicka`, and `percentModeFatigue`. Note that the values used are multipliers - `0.1` represents 10%, `1` represents 100%

*(Note that the script will automatically ensure that the stat values are clamped within the stat's normal bounds, and that the value used for health will, at minimum, be 1).*
### Revive Marker Options
To overcome some current problems, a special activatable object can also be made spawned for any player who wasn't in the cell when the player was downed.
- `useMarkers` - If set to `true`, then a special marker object will also be spawned when a player is downed. Anyone who activates either the object or the downed player will revive them.
- `markerModel` - The model to use as the revive marker. By default, it's a spoopy skellington.
- `baseObjectType` - The record type of the revive marker. Honestly won't ever need changing from its default value of `"miscellaneous"`
- `recordRefId` - The ID used for the revive marker's permanent record. Won't need changing.

### Language Support
Almost every piece of text that's presented to the player can easily be changed by configuring the `lang` section. Keep the keys as they are, and edit their strings to read anything you want. Note that words beginning with `%` are special wildcards (? I think that's the term) and shouldn't be translated (i.e. `%name` should stay as `%name`) - the script will automatically replace any instance of them with special text.

For example: `revivedReceiveMessage` determines the message that a player receives when they are revived by somebody. In this case, `%name` is used as a placeholder for the name of the player. So if the player who revived you was called `N'wah`, then the message `You have been revived by %name.` would become `You have been revived by N'wah.`

## Installation
### General
- Save `kanaRevive.lua` into `server/scripts`
### Edits to `customScripts.lua`
- Add this line: `kanaRevive = require("custom.kanaRevive")`

## Known Issues
A script like this is awkward to test on my own, so there is the possibility that bugs might've slipped through my testing. Contact me if you find anything!
- Not an issue per se, but worthy of mention: Reviving a player is instant. I could've added some time delay faff, but I preferred not to :P. It's possible that I *could* change that in the future if there was enough demand for it.
- Sometimes, if another player is downed in a different cell, it's possible that when you enter the cell, you won't be able to see the player's body. If `useMarkers` is enabled, then a special activatable object will be spawned alongside their body - you can activate either the special object or the player to revive them.
- It's possible that through niche circumstances, a revive marker might remain even when not linked to a player. Simply using the marker will clear it away harmlessly.
