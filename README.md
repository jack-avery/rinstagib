# 💥 rINSTAGIB ⚡

SourcePawn source code used for **rINSTAGIB** ([frag compilation](https://www.youtube.com/watch?v=_DH_TAh-4yY)) ([old trailer video](https://www.youtube.com/watch?v=6GSMJ-zzzig))

### Please note that `rinstagib.sp` only handles fall damage and weapons. Having the rInstagib gamemode requires additional plugins.

Servers running this gamemode and general discussion available [in the Discord](https://discord.gg/V5Z29SXtsY)

> By default this plugin is configured to **punish "camp"-y playstyles**.<br/>
If you want a server automatically set up with rInstagib for you, see [our Ansible playbooks](https://github.com/jack-avery/rinstagib-server)

Enjoy the gamemode? [Buy me a coffee ☕](https://ko-fi.com/raspy)!

## Direct Dependencies
#### Plugins that rinstagib.sp depends on to run

* [tf2attributes](https://github.com/FlaminSarge/tf2attributes)
* [tf2items.inc](https://github.com/asherkin/TF2Items/blob/master/pawn/tf2items.inc)
* [morecolors.inc](https://forums.alliedmods.net/showthread.php?t=185016)


## Required Plugins
#### Plugins that the rinstagib gamemode depends on for the intended experience

* [Class Restrictions For Humans](https://forums.alliedmods.net/showthread.php?p=2518202)<br/>
-- This gamemode is intended to be played with only the Soldier class available.

* [Advanced Infinite Ammo](https://forums.alliedmods.net/showthread.php?t=190562)<br/>
-- The plugin will attempt to enable Advanced Infinite Ammo on each player spawn.

* [tf-bhop](https://github.com/Mikusch/tf-bhop)<br/>
-- Automatic hops allows easy maintenance of velocity and speeds up gameplay.

* [SOAP-TF2DM](https://github.com/sapphonie/SOAP-TF2DM)<br/>
-- Instant respawn & respawn positions closer to the fight reduces downtime.

## Recommended Plugins
#### While not required, these are nice to have

* [tf2centerprojectiles](https://github.com/rtldg/tf2centerprojectiles)
* [Quake Sounds v3](https://forums.alliedmods.net/showthread.php?t=224316)
* [Unrestricted FOV](https://forums.alliedmods.net/showthread.php?p=1936180)
* [speedo](https://github.com/JoinedSenses/TF2-Speedometer)
* [ChillyDM](https://github.com/pepperkick/ChillyDM)

If you're planning to have Free-For-All DM enabled (`mp_friendlyfire 1`), ChillyDM makes it a lot better

## Recommended configuration

```
// General:
tf_weapon_criticals 0        // No randomness
tf_use_fixed_weaponspreads 1 // No randomness
sv_airaccelerate 150         // High turn speed
sv_gravity 700               // A little floatiness is nice
sm_aia_extrastuff 0          // The Beggars is weird with AIA ExtraStuff

// For Free-For-All:
tf_spawn_glows_duration 0    // No FFA respawn walls
soap_teamspawnrandom⁠ 1       // Use both sides' spawns for FFA DM
```
