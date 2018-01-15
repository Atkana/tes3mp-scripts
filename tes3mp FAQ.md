***Foreword:** The following is a copy of the [tes3mp FAQ](https://steamcommunity.com/groups/mwmulti/discussions/1/353916184342480541/) (Last updated: 29 Nov, 2017) as written by [David C.](https://github.com/davidcernat). The only reason I've made this copy is so I can link to specific FAQ questions, since the Steam forums don't support anchors (though Steam guides do?). I'm in no way affiliated with the people who actually make tes3mp, blah, blah, blah.*

# Frequently Asked Questions
### What is this group about?
In theory, it's about everything related to playing Morrowind in multiplayer. In practice, it's about playing Morrowind in multiplayer through [TES3MP](https://github.com/TES3MP/openmw-tes3mp) which is based on [OpenMW](https://github.com/OpenMW/openmw)

The admin team of our Steam group also happens to be the development team of TES3MP.

### Where can I donate to TES3MP?
You can donate to me on my own recently started [Patreon page](https://www.patreon.com/davidcernat).

You can donate to my fellow developer Stanislav on his [Patreon page](https://www.patreon.com/Koncord).

### How do I use TES3MP if I'm on 64-bit Windows?
It's quite easy. Follow the guide [here](http://steamcommunity.com/groups/mwmulti/discussions/2/353915309331818721/).

### Is TES3MP a multiplayer mod?
No. Multiplayer mods are modifications to closed source original games that almost always have severe limitations in what they can achieve. There have been many examples of them and most have never gotten very far at all.

TES3MP is the multiplayer branch of an open source recreation of Morrowind's engine called OpenMW, done from the ground up and using none of Morrowind's original engine code. As a result, we can add any features we want to it, and we will be adding a lot of ambitious ones as time goes by that would never be possible or even imaginable in a multiplayer mod.

### When I open up *tes3mp-browser.exe*, why do I not see any servers show up?
Either the master server is down, or you have entered the wrong address and port for the master server in your *tes3mp-client-server.cfg*

The address of our default master server is *master.tes3mp.com* and its port is 25560

### How do I join a server manually?
If you do not wish to use the server browser, or have problems with it, you can always do a direct IP connection by simply editing the following lines in *tes3mp-client-default.cfg*:
```
destinationAddress = localhost
port = 25565
password =
```
Replace "localhost" with the IP of the server, put in the correct port, the correct password (if there is one) and then run *tes3mp.exe* to connect.

### How do I play LAN?
When doing a direct connection as described in the answer above, simply set your destinationAddress to the server's local IP instead of its external, public IP.

You can also prevent the server from appearing in the server browser by disabling the connection to the master server in tes3mp-server-default.cfg. Turn this:
```
[MasterServer]
address = master.tes3mp.com
enabled = true
```
Into:
```
[MasterServer]
address = master.tes3mp.com
enabled = false
```

### When I run TES3MP, why does it say I'm missing vcruntime140.dll and msvcp140.dll ?
You are missing the Visual C++ Redistributable for Visual Studio 2015 and need to install it. Get it from [here.](https://www.microsoft.com/en-us/download/details.aspx?id=48145)

### When I try to connect to a server, why am I prevented and told that my load order is "Bloodmoon.esm, Morrowind.esm and Tribunal.esm"?
*openmw-launcher.exe* sometimes loads your .esm files in the wrong order. Try going to its Data Files tab and dragging the files around so they're in the correct order.

If that doesn't work for you, use a text editor to open up the OpenMW configuration file found here:
```
C:\Users\Username\Documents\My Games\OpenMW\openmw.cfg
```
Scroll down to its bottom and set the order manually like this:
```
content=Morrowind.esm
content=Tribunal.esm
content=Bloodmoon.esm
```

### Certain Morrowind mods require you to register .bsa files. How do I do that for TES3MP?
Use a text editor to open up the OpenMW configuration file found here:
```
C:\Users\Username\Documents\My Games\OpenMW\openmw.cfg
```
Near the top will be all your registered .bsa files, in the following pattern:
```
fallback-archive=Morrowind.bsa
fallback-archive=Tribunal.bsa
fallback-archive=Bloodmoon.bsa
```
Simply add the ones you want to those.

### When I start TES3MP, I get an error about a missing .bsa archive. How do I fix it?
Go to your list of registered .bsa archives as instructed in the answer above, then remove the line of the missing one.

### How do I host a server myself?
Simply start up *tes3mp-server.exe*. Other players will be able to find your server using *tes3mp-browser.exe* as long as your server is set to communicate with the master server and as long as your server port (25565 by default) is forwarded correctly.

### Why does my server appear as having a ping of 999 in the server browser?
The port set for your server in *tes3mp-server-default.cfg* (25565 by default) isn't forwarded correctly. You'll need to open up your router's configuration pages in your browser, go to the port forwarding section and forward the port to your local IP. When asked to choose a protocol from TCP, UDP and both, pick either UDP or both.

This is a general computer problem, not something specifically related to TES3MP, and such you should find a guide – perhaps for your specific router – elsewhere on the internet, like on [www.portforward.com](https://portforward.com/)

That being said, TES3MP's default port of 25565 is also used by Minecraft, and port forwarding guides written by the Minecraft community are just as applicable to TES3MP.

After port forwarding, you may also want to ensure the TES3MP server is not blocked by your firewall.

### I've forwarded my port and other people can join my server through the server browser, but it still shows up as having a ping of 999 for me and my connect button is greyed out in the server browser. How can I join it?
There seems to be a bug with the server browser where your own server will mistakenly have that ping. Nonetheless, you can always join yourself by running *tes3mp.exe* with "localhost" as your destinationAddress in your *tes3mp-client-default.cfg*

### How do I configure my server?
To change your basic server options – such as the name of the server or the port used for it – simply edit your *tes3mp-server-default.cfg* file.

For more advanced settings, read [this guide](http://steamcommunity.com/groups/mwmulti/discussions/1/133258593388999187/).

### Where do I find client and server log files?
Open up this folder:
```
C:\Users\Username\Documents\My Games\OpenMW
```
Client log files start with tes3mp-client and server log files start with *tes3mp-server*.

### How are plugins handled?
Servers have a file named pluginlist.json that lets them enforce a list of plugins in a certain order with specific checksums. That means players all need to enable the same plugins in openmw-launcher.exe as the server that they want to join.

### How do I set up the plugins for my server?
Open up your *mp-stuff\data\pluginlist.json* and add the plugins you want, in the order you want them and with their corresponding accepted checksums.

For instance, this will only accept the English GOTY editions of Morrowind, Tribunal and Bloodmoon:
```
    "0": {"Morrowind.esm": ["0x7B6AF5B9"]},
    "1": {"Tribunal.esm": ["0xF481F334"]},
    "2": {"Bloodmoon.esm": ["0x43DD2132"]}
```
By default, pluginlist.json also accepts the Russian GOTY edition of Morrowind as a second set of checksums because of its compatibility with the English edition:
```
    "0": {"Morrowind.esm": ["0x7B6AF5B9", "0x34282D67"]},
    "1": {"Tribunal.esm": ["0xF481F334", "0x211329EF"]},
    "2": {"Bloodmoon.esm": ["0x43DD2132", "0x9EB62F26"]}
```
If you like, you can also not put in any checksums at all:
```
    "0": {"Morrowind.esm": []},
    "1": {"Tribunal.esm": []},
    "2": {"Bloodmoon.esm": []}
```
However, this will make it possible for anyone to join your server with pretty much any files named like that, which is why you should use checksums unless playing with trusted people.

### How do I get the checksums for the plugins I want to use on the server?
The easiest way to do this that doesn't rely on any other software is to simply enable all the plugins you want in *openmw-launcher.exe*, connect to a server and get rejected from it.

Afterwards, find your latest client log file here:
```
C:\Users\Username\Documents\My Games\OpenMW
```
Open it up and it will contain the checksums you need near the top:
```
idx: 0    checksum: 7B6AF5B9  file: C:\Games\Morrowind\Data Files\Morrowind.esm
idx: 1  checksum: F481F334  file: C:\Games\Morrowind\Data Files\Tribunal.esm
idx: 2  checksum: 43DD2132  file: C:\Games\Morrowind\Data Files\Bloodmoon.esm
```
Simply copy-paste the checksums into your pluginlist.json, add an "0x" in front of them and you're good to go.

If, after doing that, your server crashes upon starting, you've probably put in a wrong character somewhere. Take a close look to make sure your pluginlist.json additions fit the pattern correctly.

### My server crashes whenever a certain player joins it. What is going on?
It's possible that the data of the cell the player spawns in has somehow gotten corrupted. You should post about it on our forums or ask about it on our Discord so we can try to fix it for you and ensure it doesn't happen for others in the future.

### I don't have Morrowind installed in its English edition. Can I play with other people?
If you have the French or German editions of Morrowind installed, you will not be able to join the vast majority of servers.

The French and German editions are not compatible with other languages because they contain hardcoded translations of interior cell names and dialogue topics. You can still host a server with them as long as you put in their checksums in your mp-stuff\data\pluginlist.json, but you shouldn't try to combine them with other editions unless you want to experience severe issues.

The Russian edition contains localization files providing a softcoded translation that is compatible with the English edition.

We have not been able to try any other language editions. Feel free to provide us as much information as you can on them.

### I have the English edition of Morrowind, but don't have the same checksums for Morrowind, Tribunal or Bloodmoon as those used by servers. What is going on?
Servers use the checksums of the English GOTY edition by default.

If you are using the original CD version of Morrowind or one of its expansions, ensure that you have installed the latest official patches for them.

If you are using the Steam version of Morrowind's GOTY edition, try verifying the integrity of your game files.

### How do I use TES3MP if I'm on Linux?
We do not currently release binaries for Linux, because of how many different Linux distributions there are and because of how often our code changes.

To use TES3MP on Linux, you'll have to build it yourself. Luckily, it's rather easy compared to building it on anything else. Simply use Grim Kriegor's [Linux build script](http://steamcommunity.com/groups/mwmulti/discussions/2/353915309331802029/).

### Why am I having problems joining a Linux server with my Windows client, or joining a Windows server with my Linux client?
In order to be compatible, the client and server need to be built using the exact same version of the code, or they will refuse to connect to each other.

Why do they have to refuse? Because there is a very good chance that otherwise some data packets will not match between the two, thus leading to freezes or crashes.

If you do a Linux build using the same code that was used for the Windows release, they will work together fine. Simply look at when the last Windows release was posted and revert your local code repository to that date.

### How do I use TES3MP if I'm on 32-bit Windows or OSX?
Alas, we do not currently have much help to offer for those situations, seeing as none of our developers have yet compiled TES3MP for either, and we haven't heard from anyone who has.

### How playable is TES3MP as of now?
With my recent addition of NPC and quest sync, TES3MP has become reasonably playable as long as you don't log out during certain 
portions of questlines and accept certain limitations.

The [announcement for the latest version](http://steamcommunity.com/groups/mwmulti#announcements/detail/1441567597386587897) summarizes all remaining problems.

### Does TES3MP receive the improvements that OpenMW does?
TES3MP's code repository takes in all of OpenMW's changes on an almost daily basis, which means that every TES3MP release is based on the most recent OpenMW code as it existed at the time.

### Is TES3MP a part of OpenMW?
TES3MP is currently regarded as more of a sister project to OpenMW, though we are open to the idea of merging with OpenMW in the future should their developers desire it. We also have a [subforum on the OpenMW website](https://forum.openmw.org/viewforum.php?f=44&sid=f17e20c7a99f9a5b16ca2c78734d511d) and we have been featured in their [news announcements](https://openmw.org/2017/openmw-multiplayer-here/).

### How large is the TES3MP team?
After experimenting with OpenMW in the summer of 2015, Stanislav started adding multiplayer functionality to it in December of 2015. That was the birth of TES3MP, and he worked on it alone until the 8th of July 2016, when he first released its code on GitHub.

That same day I created this group. After compiling TES3MP for Linux and writing a guide about it, I was invited by Stanislav to join TES3MP officially as a developer, and I've been fixing problems and adding features ever since. My main contributions so far are the massive features of NPC sync, quest sync, world sync and state saving/loading.

### How functional is the AI?
AI works quite well now. There are a few situations where NPCs react differently to the client on whose their AI is running, by only greeting that particular player, by only following that player during quests, or by only trying to arrest that one player in the case of guards. However, the game is very playable even with those quirks, and they will be fixed for version 0.7.0

### How many people will be able to play on a server at the same time?
There is no clear limit, but the server currently starts crashing after a few dozen due to the increased frequency of packets with invalid data.

### How do I enable distant terrain?
Follow the instructions in this [OpenMW news post.](https://openmw.org/2017/distant-terrain/)

### Can I make it so players don't share quests on my server?
In theory, yes, by changing a line in your server's *config.lua* from this:
```
config.shareJournal = true
```
Into this:
```
config.shareJournal = false
```
However, Morrowind's quest logic and NPC dialogue is built around the existence of a single player. As a result, the vast majority of questlines will break very quickly if their states are not shared across players.

The ability to disable journal sharing is more appropriate for new worlds or areas built specifically around multiplayer.
