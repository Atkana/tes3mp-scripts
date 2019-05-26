# kanaBank
Provides access to personal storage for players to utilise via command, or by activating pre-designating "bankers".

*Currently written for a version of 0.7-alpha*

## Usage
Banks provide a personal storage for every player, which can be accessed in a variety of ways depending on configuration. Those that meet the `useBankCommandRank` rank requirement can use the `/bank` to open their bank storage, and those that meet the `openOtherPlayersBankRank` rank can use `/bank PlayerName` to open the banks of others... Otherwise (or in addition to), players that meet the rank of `useBankerRank` can access their bank storage by activating a banker object (this is useful, if you want to restrict where players will be able to access the storage). What object counts as a banker object is defined by the server owner via configuration, or outside scripts utilising the provided methods.

## Configuration
Configuration is done from within the file itself, by altering the `scriptConfig` values.
### Rank Options
The required `staffRank` to use each of the script's features
- `useBankerRank` - The rank required for a player to open their bank by activating a banker.
- `useBankCommandRank` - The rank required for a player to open their bank via the `/bank` command.
- `openOtherPlayersBankRank` - The rank required for a player to open another player's bank via the `/bank PlayerName` command.
### Bankers
Define what objects act as bankers.
- `bankerRefIds` - Objects with `refId`s inserted here will be treated as bankers. Note that this applies to *all* instances that have that `refId` - if you want to apply it to one specific instance, use the next option.
- `bankerUniqueIndexes` - Objects with their `uniqueIndex` inserted here will be treated as bankers.

*Note: Objects defined as bankers will have their default activation behaviour disabled, even if the player who attempts to activate one doesn't meet the `useBankerRank`.*
### Protection
If these are enabled, the script will attempt to prevent its objects from being deleted. Note that having them disabled doesn't guarantee attempts to delete them will always be successful - other things might also block its deletion.
- `denyBankerDelete` - If true, any object designated as a banker will be protected from permanent deletion.
- `denyBankStorageDelete` - If true, any object which is being used as a player's storage will be protected from permanent deletion.
### Internal Stuff
There are some options that are mostly used for internal things and shouldn't require any editing.
- `baseObjectRefId` - The `refId` of the object that's used by this script's special storage containers. By default, a dead rat is used, since it's a non-despawning, infinite weight, undeletable container. This could be changed to be a regular sort of container (like a chest), if you wanted to enforce some sort of weight limit.
- `baseObjectRecordType` - The object type for the object defined by `baseObjectRecordType`. You would only have to change this if you changed the `baseObjectRefId` to an object of a different type.
- `storageCell` - The cell that the bank storage containers get placed in. The script uses an unreachable test cell by default, so no player should have access to it. The cell defined here is always loaded by the server. Do note that since this cell holds all of the player's bank storage containers *you should never delete this cell's data*. If you're using an automatic cell resetter, make sure that this cell is exempt from resets (if the script detects that Atkana's `CellReset` is being run on the server, it'll register the cell as exempt for that script automatically).
- `recordRefId` - The id used for this script's special permanent record entry. There should be no reason why this would ever need changing, but if you do, ensure it doesn't contain any capitals.
### More Internal Stuff
- `logging` - Whether the script should output normal information into the server log.
- `debug` - Whether the script should output debug information into the server log.
### Language Support
Almost every piece of text that's presented to the player can easily be changed by configuring the `lang` section. Keep the keys as they are, and edit their strings to read anything you want. Note that words beginning with `%` are special wildcards and shouldn't be translated (i.e. `%name` should stay as `%name`) - the script will automatically replace any instance of them with special text.

## Installation
### General
- Save `kanaBank.lua` into `server/scripts/custom`
### Edits to `customScripts.lua`
- kanaBank = require("custom.kanaBank")
