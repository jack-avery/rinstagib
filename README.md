# 💥 RAS INSTAGIB ⚡

SourcePawn source code used for **RAS INSTAGIB** ([trailer video](https://www.youtube.com/watch?v=6GSMJ-zzzig))

### Please note that `rinstagib.sp` **only handles fall damage, mp_friendlyfire, and weapons**. Having the rInstagib gamemode requires additional plugins.

Servers running this gamemode and general discussion available [in the Discord](https://discord.gg/V5Z29SXtsY)

> If you want true INSTAGIB ACTION you can use [the convars](https://github.com/jack-avery/rinstagib/blob/main/rinstagib.sp#L37) or modify `tf/cfg/rinstagib.cfg`<br/>
If you want a server automatically set up with rInstagib for you, see [the Ansible playbook](https://github.com/jack-avery/rinstagib-server)

## Direct Dependencies
#### Plugins that rinstagib.sp depends on to run

* [tf2attributes](https://github.com/FlaminSarge/tf2attributes)
* [tf2items](https://github.com/asherkin/TF2Items)

## Required Plugins
#### Plugins that the rinstagib gamemode depends on for the intended experience

* [Class Restrictions For Humans](https://forums.alliedmods.net/showthread.php?p=2518202)
> This plugin is intended to be played with only the Soldier class available.

* [Advanced Infinite Ammo](https://forums.alliedmods.net/showthread.php?t=190562)
> The plugin will attempt to enable Advanced Infinite Ammo on each player spawn.

* [tf-bhop](https://github.com/Mikusch/tf-bhop)
* [SOAP-TF2DM](https://github.com/sapphonie/SOAP-TF2DM)

## Recommended Plugins
#### While not required, these are nice to have

* [tf2centerprojectiles](https://github.com/rtldg/tf2centerprojectiles)
* [Quake Sounds v3](https://forums.alliedmods.net/showthread.php?t=224316)
* [Unrestricted FOV](https://forums.alliedmods.net/showthread.php?p=1936180)

## Recommended configuration

**Ensure your `server.cfg` (or any other configs that run) does not set `mp_friendlyfire`.<br/> `rinstagib.smx` will manage the ConVar.**

```
tf_weapon_criticals 0                   // No randomness
tf_use_fixed_weaponspreads 1            // No randomness
sv_alltalk 1                            // FFADM
sv_airaccelerate 150                    // High turn speed
sv_gravity 700                          // Bit floaty
sv_turbophysics 1                       // Causes Pass Time Jack jank if disabled
tf_spawn_glows_duration 0               // No FFA walls
tf_preround_push_from_damage_enable 1   // Jump in spawn for Pass Time
tf_avoidteammates_pushaway 0            // Allies don't collide
```