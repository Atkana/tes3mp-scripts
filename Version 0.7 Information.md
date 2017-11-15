# Public Information on tes3mp's 0.7 release
(That I know of since starting this list ;P)
### The things what are listed on the future versions page
[See here](http://steamcommunity.com/groups/mwmulti#announcements/detail/1441567597399546240) for the announcement.
* Synchronizing, saving and loading custom spells, player-made potions and enchantments, and player-filled soul gems
* Solving at least half of all remaining quest problems
* Fixing all remaining spell-related problems
* Fixing throwing weapon sync
* Making NPCs react identically to all players
* Removing the most notable item duplication methods
* Adding weather sync
* Fixing the most frequent reasons for client and server crashes
### New Lua API
tes3mp will be getting a new lua API for version 0.7. You can get a current look at the indevelopment documentation [here](http://docs.tes3mp.com/en/latest/index.html). It's possible to start creating scripts using the new API now, and I'm sure somebody who knows how to do that will send a pull request changing this text with an explaination as to how... right? :P

### Packet Validation
>Atkana: Random tangent: Is packet validation coming in *NEXT VERSION*? Don't know if that's the correct term... It's like, with *CURRENT VERSION* if you load a room that's had a lot of items placed in it, sometimes you only get some/none of the placement information (or slightly more serious stuff like player's whole inventories getting eaten when they change cells). I vaguely remember there might've been mention of something along those lines? Maybe I oughta start a list of 0.7 info :P

>David C.: Koncord said he was working on it. I believe the previous assumption was that RakNet wouldn't drop packets so easily.
