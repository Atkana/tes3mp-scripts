# ServerWarp

Adds a `/warp` series of commands for ... warping.

## Usage

Command list:

* `/warplist`
    * Prints a list of all public warps and your own private warps into chat
* `/warp <warp name>`
    * Requires permission: useWarpRank
    * Warp yourself to a warp with the provided name. It first checks your personal warp list and if it can't find a warp by that name it then checks the public warp list. You can't use this command if your warp privilege has been disabled.
* `/warpset <warp name>`
    * Requires permission: setWarpRank
    * Records your current position as a personal warp point with the provided name
* `/warpsetpublic <warp name>`
    * Requires permission: setPublicWarpRank
    * Records your current position as a public warp point with the provided name
* `/warpremove <warp name>`
    * Requires permission: setWarpRank
    * Removes the named warp from your personal warp list
* `/warpremovepublic <warp name>`
    * Requires permission: removePublicWarpRank
    * Removes the named warp from the public warp list
* `/warpforce <target player's id> <warp name (of a public warp)>`
    * Requires permission: forcePlayerRank
    * Forcibly teleports the player with the provided id to a public warp with the given name
* `/warpjail <target player's id> <warp name (of a public warp)>`
    * Requires permission: forcePlayerRank AND forceJailPlayerRank
    * As with /forcewarp, but also disables the player's warp privileges
* `/warpallow <player id> <0/1 to disable/enable>`
    * Requires permission: setAllowWarp
    * Sets the targeted player's warp privileges. Set to 0 to disable them from using the /warp command, set to 1 to enable them again.
    * Example usage:

            /warpforce 1 the forum
