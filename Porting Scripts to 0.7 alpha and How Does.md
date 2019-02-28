# Porting Scripts to 0.7 (alpha) and How Does
There have been some minor changes script-compatibility-wise with the new 0.7 release, with a lot of the common required edits to 0.6.2 scripts being very straightforward. I've provided a list of the changes that I'm aware of for those interested in updating their own scripts, or looking to see if they can get old 0.6.2 scripts working on their 0.7 servers.
### server.lua has become serverCore.lua
From the perspective of installing scripts, not much has changed beyond the name of the file (well, with the exception of one thing, which I'll get to next). If the script's installation instructions say to do something to `server.lua`, do it to `serverCore.lua` instead, with the exception of...
### Chat commands have been moved to commandHandler.lua
If an installation instruction had previously said something nebulous about adding a lump of code to the "elseif chain for commands in `OnPlayerSendMessage` inside `server.lua`" (who even writes these?), it is now instead added to the "elseif chain for commands in `commandHandler.ProcessCommand` inside the file `commandHandler.lua`".
### actionTypes.lua has become enumerations.lua
I'm not aware of many scipts that previously used actionTypes, but porting them to the new version is simple. There a couple of easy ways to do so, with one of them being to run a find and replace, changing any instance of `actionTypes` into `enumerations`.
### The player setting "admin" is now "staffRank"
The name used internally (and in player save files) that marks what level of admin privilege a player character has has changed from `admin` to `staffRank`. In the niche cases that a scripter has written their script to make a direct reference to that variable, instead of using the special functions for checking a player's ranks (oops, my bad :P), you'll have to make edits in the code. You should be safe by just replacing any instance of `data.settings.admin` with `data.settings.staffRank`.

For any interested scripters reading, the aforementioned special functions in 0.7 are part of the player class - `IsModerator()`, `IsAdmin()`, `IsServerOwner()`, and `IsServerStaff()`. Also: when the game loads a player save file from a previous version, it'll automatically update it to using the term `staffRank`, in case you were wondering :P
### InputDialog now requires an extra argument
The way `InputDialog`s work (the thing that pops up and asks you to enter some text) have changed, and any code that used it previously needs updating. Thankfully, the edit is very straightforward:
* Search through the code for any instance of `tes3mp.InputDialog` (if there aren't any, then you don't need to bother doing this)
* For each instance, add `,""` directly before the closing bracket (the `)`). For example, if the line was originally `tes3mp.InputDialog(pid, guiId, message)`, it'll become `tes3mp.InputDialog(pid, guiId, message,"")`

For scripters: The new - fourth - argument is a string that'll be displayed beneath the text input area - like how the warning about server owners being able to read your passwords appears when you make a new account (I believe). If you don't want anything displayed, passing an empty string should suffice.
### os.getenv("MOD_DIR") becomes tes3mp.GetModDir()
Regarding [this commit](https://github.com/TES3MP/CoreScripts/commit/c43f42b7d35f026e1f9b5e91a742d84f1b0d23cd) you have to change `os.getenv("MOD_DIR")` to `tes3mp.GetModDir()`. This is most common in places where jsonInterface is loading files and needs a path to your `/data/` folder.
### myMod has split into logicHandler and eventHandler
Previously, `myMod` was responsible for some logic-based stuff, as well as processing events. Now, the logic-based stuff is in `logicHandler.lua` and the event processing stuff is in `eventHandler.lua`. There probably aren't many scripts that were originally using myMod's event-processing functions themselves, beyond perhaps requiring alterations to them as part of installing the script. If a script *does* require edits to any of those parts, you can try making those edits to `eventHandler.lua`. Be aware that the instructions that the script gives are most likely to be explicitly for the version the script was written for, and doing those same edits for this version might break things.  

If the script itself was *only* using the functions that are part of `logicHandler`, there's a cheesy edit you can make to the script that might be all that's needed to get it running:
* Search the script for a mention of `require("myMod")`, if there is one, delete it (be sure to delete the whole line, in the case it's something like `myMod = require("myMod")`
* In it's place (if it was there) or near the top of the file (if it wasn't), add the line `local myMod = require("logicHandler")`  

With these changes, the script *might* work, provided that a) the script was only using `myMod` for the things that ended up in `logicHandler`, and b) the way the `logicHandler` functions that the script uses haven't changed in... uh, function, significantly between versions. If either of these things aren't true then things might break.  
If you're a scripter looking for actual non-hacky advice on porting your script:
* Get rid any `require`s for `myMod`
* Require either or both of `logicHandler` and `eventHandler` as you would have `myMod`
* Go through and update all your calls to `myMod` to use the correct script
* Test/Read through the functions to see if anything's changed between versions, and edit your script appropriately

Note that it's entirely possible that following this advice may break things, and it was all written by somebody who hasn't actually used 0.7, nor tried the changes they're suggesting. If you've got edits to make/suggestions of things to add, send me a message, or just make a pull request adding the changes - this is github, after all ;P
