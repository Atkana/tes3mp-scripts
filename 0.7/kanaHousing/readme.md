# kanaHousing
My own take on player housing, inspired by mupf's realEstate.
## Features
* Players can buy and manage their own houses through a GUI.
* Locking - Players can lock their houses, preventing others from entering. The owner, co-owners, and admins may enter the locked house whereas others will be turned away. Includes the ability to designate cells as important for travelling through (if entering it is required for a quest, for example), which allows regular members to enter while the cell is locked, so you don't have to worry so much about what places you designate as houses.
* Owners can warp to any of their owned houses, though this feature can be disabled in the configs.
* House owners can add co-owners, who can place or remove items in the house as well as pass through when the house is locked.
* Admin GUI for creating, defining, and managing houses while in game.
* While not strictly enforced, the script will report any players taking items from other player's houses in the server log, though it's not too difficult to expand what's already there if you want to do something with those dirty thieves. The script also differentiates between players taking regular items, and them taking items marked in the cell's data as quest items (the latter is okay).
* Support for cell resets - Any doors associated with a house will automatically unlock if they should ever be locked, players can be allowed to pass through cells associated with quests, and the foundation has been laid for a server script to use to allow targeted resetting
* Support for kanaFurniture. Owners and Co-owners are automatically given permission to place furniture in their houses.
## Usage
### Commands
* `/houseinfo` - Use while in a house to view information on the house, as well as purchase it, if available.
* `/house` - Used by players to view a list of all available houses on the server, as well as manage the settings of the houses that they own.
* `/adminhouse` - Used by admins to edit and create new houses.

### Editing the files
Some features, such as the reset info and a house's doors require manually editing the script's data file (found in data/kanaHousing.json). The structures of the script's data is outlined in the comments of the script's `createNewHouse` and `createNewCell`, if you wish to know how it all works. The following is an example of the script's data configured to include the single house: Chun-Ook, the boat in Ebonheart. It was chosen because it features two locked exterior doors, one "regular" cell (the cabin); one cell that requires passing through for a quest as well as an interior locked door (the upper deck); and one cell that requires passing through, contains quest items that'd need resetting (if you wish for multiple players to do the quest), and contains owned containers (the lower deck).
```
{
  "cells":{
    "Chun-Ook, Upper Level":{
      "house":"Ebonheart, Chun-Ook",
      "ownedContainers":false,
      "name":"Chun-Ook, Upper Level",
      "requiredAccess":true,
      "resetInfo":[],
      "requiresResets":false
    },
    "Chun-Ook, Lower Level":{
      "house":"Ebonheart, Chun-Ook",
      "ownedContainers":true,
      "name":"Chun-Ook, Lower Level",
      "requiredAccess":true,
      "resetInfo":[{
          "instruction":"refill",
          "refId":"crate_01_limeware_uniqu",
          "refIndex":"297593-0"
        }],
      "requiresResets":true
    },
    "Chun-Ook, Cabin":{
      "house":"Ebonheart, Chun-Ook",
      "ownedContainers":false,
      "name":"Chun-Ook, Cabin",
      "requiredAccess":false,
      "resetInfo":[],
      "requiresResets":false
    }
  },
  "owners":[],
  "houses":{
    "Ebonheart, Chun-Ook":{
      "name":"Ebonheart, Chun-Ook",
      "cells":{
        "Chun-Ook, Upper Level":true,
        "Chun-Ook, Lower Level":true,
        "Chun-Ook, Cabin":true
      },
      "price":5000,
      "outside":{
        "pos":{
          "y":-102871.0859375,
          "x":20961.751953125,
          "z":106.32440185547
        },
        "cell":"2, -13"
      },
      "doors":{
        "2, -13":[{
            "refIndex":"294940-0",
            "refId":"ex_de_ship_cabindoor"
          },{
            "refIndex":"297456-0",
            "refId":"ex_de_ship_trapdoor"
          }],
        "Chun-Ook, Upper Level":[{
            "refIndex":"297541-0",
            "refId":"in_de_shipdoor_toplevel"
          }]
      },
      "inside":{
        "pos":{
          "y":-269.77154541016,
          "x":-113.86807250977,
          "z":-172.68469238281
        },
        "cell":"Chun-Ook, Cabin"
      }
    }
  }
}
```


### Scripts
There are a number of functions exposed for other scripts to use, which can be found towards the bottom of the script (more can be easily added) - I will probably try to write up what they are and what they do here eventually.

## Installation
### General
- Save `kanaHousing.lua` into `server/scripts/custom`
### Edits to `customScripts.lua`
- kanaHousing = require("custom.kanaHousing")

If you have kanaFurniture installed, uncomment (remove the -- at the beginning) the line `kanaFurniture = require("custom.kanaFurniture")` that is after this installation info box in the `lua` file. Requires kanaFurniture release 3 or later.

## Known Issues
I don't know of any issues and have tried to test everything to make sure it works, but it's possible that something slipped through the net and made it into the release. If you run into any problems, feel free to contact me so I can get things fixed! You're most likely to find me lurking in the [tes3mp Discord channel](https://discord.gg/ECJk293).
