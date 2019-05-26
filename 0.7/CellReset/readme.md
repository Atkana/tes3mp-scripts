# CellReset
Cell Reset is a script for periodically resetting the game's cells to their default states, in a manner that tries to avoid all the potential problems other methods might cause (for example, manually deleting a cell's `.json` entry can lead to problems!). The server owner can configure how often these happen, as well as provide a list of cells that they don't want to be affected.

*Currently written for a version of 0.7-alpha*

## Usage
By default, the script is supposed to work automatically, resetting the state of any cell as it's loaded after 3 IRL days (time can be configured) have passed since its last reset (or first loaded if it hasn't been reset at all). With some configuration, the automatic resetting can be disabled, and instead left to other scripts, or admins to handle via the `/forceReset` command. Here are the commands added by Cell Reset:
- `/resetTime Cellname` - Reports how much more time is left on the given cell's reset timer. If no cell name is provided, it'll use the command user's current cell instead.
- `/forceReset Cellname` - Forcibly resets the given cell (or the command user's current cell if none is provided). **Only use if you know what you're doing** - all the regular checks are bypassed when using this command, so this will wipe cells listed as being exempt from resetting, for example. By default, anyone who had that cell loaded in their client memory will be kicked from the server when the command is used (see *configuration* and *Known Issues/Limitations*)

## Configuration
Configuration can be done from within the file itself. Here is a list of all the current config options:
- **scriptConfig.resetTime** - The time in (real life) seconds that must've passed before a cell is attempted to be reset. 259200 seconds is 3 days. Set to -1 to disable automatic resetting.
- **scriptConfig.preserveCellChanges** - If true, the script won't reset actors that that have moved into/from the cell. At the moment, MUST be true.
- **scriptConfig.alwaysPreservePlaced** - If true, the script will always preserve any placed objects, even in cells that it's free to delete from. Note that *place*d is a tes3mp technical term, referring to any object that's been physically placed in the world by a player/script (and didn't start there). Items put inside containers *aren't* considered *place*d objects.
- **scriptConfig.blacklist** - The blacklist contains a list of every cell that you want to be immune to automatic cell resets. Note that this doesn't protect them from being reset via the `/forcereset` command, because that bypasses such checks.
- **scriptConfig.checkResetTimeRank** - The `staffRank` required by a player to use the `/resetTime` command.
- **scriptConfig.forceResetRank** - The `staffRank` required by a player to use the `/forceReset` command.
- **scriptConfig.kickAffectedPlayersAfterForceReset** - If true, players that had information on a cell in their client memory will be kicked following a force reset. Should be set to true or problems will arise!
- **scriptConfig.logging** - If true, the script outputs basic information to the log. No real reason why you'd want to disable it.
- **scriptConfig.debug** - If true, the script outputs additional debug information to the log.

## Installation
### Save the Script
Save the file as `CellReset.lua` inside your `server/scripts/custom` folder.
### Edits to `customScripts.lua`
- CellReset = require("custom.CellReset")

## Script Methods
There are a number of functions made available for other scripts to utilise. See the file for more information on what each of them do.

## Known Issues/Limitations
I've done my best to make sure that everything works as it should, but problems can get past testing. If you run into any problems while running it, please do get in touch and I'll try my best to fix it.
### Limitations
Because of the way tes3mp works, there are limitations to when a cell can be reset. The main limiting factor is Client Memory: If a player (or somebody else) has ever entered a cell during the player's current session, their client will hold information about every change that was made. Without making some edits to the server scripts (and adding the requirement that this script must've *always* been running on the server since the start), there isn't a way to "undo" the things that client has received. (I'm struggling to articulate exactly how everything works on a technical level, so rather than sit around trying to do that, I'd rather skip this and actually finish releasing this script :P. Maybe something mentioned [in this guide](https://github.com/Atkana/tes3mp-scripts/blob/master/Unofficial%20Guide%20to%20tes3mp.md) will help? I don't remember.)

Additionally, the information about actors changing to or from cells is always preserved between resets. Because this script allows for staggered resets, as well as some cells to be entirely reserved, it can't guarantee its okay to reset that actor (otherwise we might end up with multiple actor objects that share the exact same ID!). Technically, the script could potentially work around that obstacle, but the implementation would have to bake-in the assumption that this script is the ultimate and only authority for cell resetting running on the server, and I'd rather avoid that.

## What are the problems with other methods?
Unless you're deleting most of your server data - all your cell `.json`s, and all your `recordstore` entries - and doing so all in one go, you'll run into problems (albeit very niche). At the moment these are namely related to *cell changes* and *record links*.
### Cell Changes
When a data file actor changes cells, a note is made in the cell they left from telling them what cell they moved to, and a note is made in the new cell telling them where they originally came from. If you aren't deleting every cell file altogether at the same time, you might run into an instance where you've reset the cell that the actor has left from, but preserved the cell the actor moved to. In this case, there will be two actors with the same `uniqueIndex`, which can cause a lot of wonkiness. If you are manually deleting cell files, make sure all the ones that you preserve don't contain actors with `cellChangeFrom` information about cells that you deleted.
### Record Links
When a custom-made item is placed inside a cell, a link is created between that custom item's information in `recordstore` and the cell. If the item is removed from a cell, that link is then removed, and at the time of unlinking a check is made - if that link was the last one to that item, then the information on that item is deleted from the `recordstore`. If the cell file is simply deleted, the links inside `recordstore` are still recorded for that cell, and so without the unlinking, items that no longer have any existing instances can still exist inside `recordstore`, causing some unnecessary save bloating (although this is unlikely to be that big of a problem). If you do manually delete a cell file, you need to also manually update all the information in each respective `recordstore` entry (which is a faff, trust me :P).
