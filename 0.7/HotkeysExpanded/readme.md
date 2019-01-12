# Hotkeys Expanded
Hotkeys Expanded utilises the custom item system to add some new, mostly tes3mp-related functions for use for players via quick keys. These include: equipping sets of items, sending messages (or commands) in chat, playing specific sounds, switching quick key bars, and running script functions with set parameters.
## Usage
Typing `/hotkey`, `/hotkeys`, `/hex` in chat will open the main menu for this script, provided the user has permission to do so (see *configuration*). From this menu, the player can go through the steps for creating items for any of the special functions that they have permission to create (again, see *configuration*) by following the instructions.
## Configuration
The following are the more important of the config options:
- **scriptConfig.rank\*** - The `staffRank` required by a player to create items of each function type. The comments in the file explain what each does. Note that this only governs who can *make* what, not whether or not a player can *use* one of these items (there are no checks for that).
- **scriptConfig.commandItemBaseId** - The refId of the item that all HEx items are based off. By default it's `"sc_paper plain"` - a sheet of paper. The script assumes that this will always be a book item, and so should only be changed to an item of that type.
- **scriptConfig.totallyVitalFeatureEnabled** (true/false) - Whether or not the script should add some easter egg text when it creates an item. When everything is fully functioning, it's unlikely players will ever see these messages, and so all this ultimately leads to is taking up some unnecessary extra memory space.
## Language Configuration
Almost every piece of text that's presented to the player (with the exception of easter egg text because ???) can easily be changed by configuring the `lang` section. Keep the keys as they are, and edit their strings to read anything you want. Note that words beginning with `%` are special wildcards (? I think that's the term) and shouldn't be translated (i.e. `%name` should stay as `%name`) - the script will automatically replace any instance of them with special text.

For example: `equipOutfitItemName` determines what name to give to a HEx item that's used for equipping an outfit. In this case, `%name` is used as a placeholder for the name of the outfit. So were a player to create a HEx item for an outfit they named `armor`, `[HEx] Equip Outfit: %name` would become `[HEx] Equip Outfit: armor`
## Script Methods
There are a lot of Methods exposed for other scripts to use if they want to, but the 2 main ones specifically designed to be utilised by other scripts are:
- **HotkeysExpanded.RegisterScriptFunction(id, func)** - Use this to register a function to be utilised via this script's *Run Function* feature. `id` should be a unique identifier for your function - it's what you need to enter into the run function dialog, as well what's needed if you want to unregister the function. `func` is the function that'll be run when a *Run Function* item is used. When run, it'll be fed the player's arg string as its first argument.
- **HotkeysExpanded.UnregisterScriptFunction(id)** - Use to unregister the function of the given `id`, should that be needed.

## Known Issues
- As of the time of writing, there's a bug in v0.7-prerelease which prevents this script's items from being used via quick keys. They can still be used regularly, however.
- Two items with the same name will combine in the inventory, potentially losing a script item (only possible/a problem for Equip Outfit items).
- When switching to a new quick key bar using a Switch Bar item, the player will see a phantom quick key in their quick key bar. This isn't actually saved in their quick key bar, and will disappear on reconnect/when overwritten. 
- Not an issue per se, but at present there isn't any way to delete created HEx items.
