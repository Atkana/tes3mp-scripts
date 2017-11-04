Here's a random assortment of my acquired knowledge in regards to tes3mp scripting. It might not be very coherent or useful, but maybe somebody might learn from it.

## Version 0.6.1
### Gotcha - Getting The Character's Name
When logging in as a character, the login dialog doesn't care about capitalization (for example, my character's login is "N'wah", but I could enter "n'WaH" and the game will still accept it). At this point, the game sets *the name that was entered* as the player's name for the purpose of getting the name via `tes3mp.GetName(pid)` or `Players[pid].name` and *not* the character's login name (retrieved via `Players[pid].data.login.name`). If you're storing any data using the player's name, you should make sure to use the player's *login name*, since the *player's name* (capitalization-wise) can vary by login.

### Gotcha - Detecting An Object
If you're using Cell:ContainsObject(refIndex) to detect if an object exists in that cell, and that object is a data file object, then you also need to check that the object doesn't have a delete packet associated with it.
So for example:
```
if LoadedCells[cell]:ContainsObject(refIndex) and not tableHelper.containsValue(LoadedCells[cell].data.packets.delete, refIndex) then
	--Whatever
end
```
### Gotcha - Player Naked After LoadInventory()
You have to use LoadEquipment() after LoadInventory(), or the player will be naked.
```
Players[pid]:LoadInventory()
Players[pid]:LoadEquipment()
```

### Temporarily Loading Cells
(The following code is basically lifted from cell's base.lua)
```
local temporaryLoadedCells = {}
if LoadedCells[cell] == nil then
	myMod.LoadCell(cell)
	table.insert(temporaryLoadedCells, cell)
end

--Then later when finished
for arrayIndex, cell in pairs(temporaryLoadedCells) do
	myMod.UnloadCell(cell)
end
```

### Detecting If Item Was Spawned/Placed
(Example lifted from cell's base.lua)
```
local wasPlacedHere = tableHelper.containsValue(LoadedCells[cell].data.packets.place, refIndex) or tableHelper.containsValue(LoadedCells[cell].data.packets.spawn, refIndex)

LoadedCells[cell]:DeleteObjectData(refIndex)

if wasPlacedHere == false then
	table.insert(self.data.packets.delete, refIndex)
	LoadedCells[cell]:InitializeObjectData(refIndex, refId)
end
```
### Deleting Items
Blah
```
local splitIndex = refIndex:split("-")
	
for k, v in pairs(Players) do
	tes3mp.InitializeEvent(v.pid)
	tes3mp.SetEventCell(cell)
	tes3mp.SetObjectRefNumIndex(splitIndex[1])
	tes3mp.SetObjectMpNum(splitIndex[2])
	tes3mp.AddWorldObject() -- Add actor to packet
	tes3mp.SendObjectDelete() -- Send Delete
end
```
This will only remove the object from the server. There are additional steps to remove it, depending on if the object is a data file object, or a spawned object (see: Detecting If Item Was Spawned/Placed).

(Both these examples assume the cell is loaded) For spawned objects:
```
LoadedCells[cell]:DeleteObjectData(refIndex)
```
If the object is a data file object:
```
table.insert(LoadedCells[cell].data.packets.delete, refIndex)
```
After either of them, you should probably also then save the cell
```
LoadedCells[cell]:Save()
```
### David C - Example Of How To Properly Spawn A Rat
```
local mpNum = WorldInstance:GetCurrentMpNum() + 1
local cell = tes3mp.GetCell(pid)
local location = {
	posX = tes3mp.GetPosX(pid), posY = tes3mp.GetPosY(pid), posZ = tes3mp.GetPosZ(pid),
	rotX = tes3mp.GetRotX(pid), rotY = 0, rotZ = tes3mp.GetRotZ(pid)
}
local refId = "rat"
local refIndex =  0 .. "-" .. mpNum

WorldInstance:SetCurrentMpNum(mpNum)
tes3mp.SetCurrentMpNum(mpNum)

LoadedCells[cell]:InitializeObjectData(refIndex, refId)
LoadedCells[cell].data.objectData[refIndex].location = location
table.insert(LoadedCells[cell].data.packets.spawn, refIndex)
table.insert(LoadedCells[cell].data.packets.actorList, refIndex)
LoadedCells[cell]:Save()

for onlinePid, player in pairs(Players) do
	if player:IsLoggedIn() then
		tes3mp.InitializeEvent(onlinePid)
		tes3mp.SetEventCell(cell)
		tes3mp.SetObjectRefId(refId)
		tes3mp.SetObjectRefNumIndex(0)
		tes3mp.SetObjectMpNum(mpNum)
		tes3mp.SetObjectPosition(location.posX, location.posY, location.posZ)
		tes3mp.SetObjectRotation(location.rotX, location.rotY, location.rotZ)
		tes3mp.AddWorldObject()
		tes3mp.SendObjectSpawn()
	end
end
```
### David C, On Objects
There are two important tables in a Cell's data.
One is the packets table, where you just put in an object's refIndex to note that a particular object has a certain packet attached.
The other is the objectData table, where the actual information required to send packets is recorded...
For instance, if you're going to spawn an object, the objectData needs to contain the object's location.

The JSON cell data is completely disconnected from the server's memory.
i.e. If you do something like tes3mp.SetObjectPosition(), it has exactly no effect whatsoever on what is recorded in the cell data.
That's why you need to both:
1) Send a packet for the players who are on the server right now
and
2) Save the object in the cell's JSON data for future players
As for statsDynamic, that gets populated by an authority player sending stats packets about an actor that already exists.
i.e. You don't need to put that in when spawning a rat. The Lua scripts will fill it in after the rat is spawned and they get the first packet from a player about the rat's stats.

## Version 0.7\*
### Calling the functions of other scripts
Quick example of how to format your script/mod/plugin/whatever the hell they're called in 0.7 (hence referred to as a scriptamajig):
```
function GetValue()
	-- Whatever
end
```
Then somewhere after all the functions you want to give access to are declared (actually, not sure if it *has* to be after them if they're global...), ideally at the very bottom of the script: 
```
Data["MyAmazingMod"] = {}
Data.MyAmazingMod["GetValue"] = GetValue
```
Obviously change "MyAmazingMod" to your scriptamajig's name (technically you could change it to anything, but it's good practice to use your scriptamajig's name). Then in the other scriptamajig, you can call the function via:
```
Data.MyAmazingMod.GetValue()
```
