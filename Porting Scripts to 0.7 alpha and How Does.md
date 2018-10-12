# Porting Scripts to 0.7 (alpha) and How Does
There have been some minor changes script-compatibility-wise with the new 0.7 release, with a lot of the common required edits to 0.6.2 scripts being very straightforward. I've provided a list of the changes that I'm aware of for those interested in updating their own scripts, or looking to see if they can get old 0.6.2 scripts working on their 0.7 servers.
### server.lua has become serverCore.lua
From the perspective of installing scripts, not much has changed beyond the name of the file (well, with the exception of one thing, which I'll get to next). If the script's installation instructions say to do something to `server.lua`, do it to `serverCore.lua` instead, with the exception of...
### Chat commands have been moved to commandHandler.lua
If an installation instruction had previously said something nebulous about adding a lump of code to the "elseif chain for commands in `OnPlayerSendMessage` inside `server.lua`" (who even writes these?), it is now instead added to the "elseif chain for commands in `commandHandler.ProcessCommand` inside the file `commandHandler.lua`".
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
