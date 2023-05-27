# 💥 RAS INSTAGIB ⚡

SourcePawn source code used for **RAS INSTAGIB** ([trailer video](https://www.youtube.com/watch?v=6GSMJ-zzzig))

Servers running this gamemode and general discussion available [in the Discord](https://discord.gg/V5Z29SXtsY)

If you want true INSTAGIB ACTION you can can configure [the convars](https://github.com/jack-avery/rinstagib/blob/main/rinstagib.sp#L37)

## Dependencies

* [tf2attributes](https://github.com/FlaminSarge/tf2attributes)
* [tf2items](https://github.com/asherkin/TF2Items)

## Recommended Plugins

### [Class Restrictions For Humans](https://forums.alliedmods.net/showthread.php?p=2518202)
> This plugin is intended to be played with only the Soldier class available.

### [Advanced Infinite Ammo](https://forums.alliedmods.net/showthread.php?t=190562)
> The plugin will attempt to enable Advanced Infinite Ammo on each player spawn.

* [tf-bhop](https://github.com/Mikusch/tf-bhop)
* [tf2centerprojectiles](https://github.com/rtldg/tf2centerprojectiles)
* [Quake Sounds v3](https://forums.alliedmods.net/showthread.php?t=224316)
* [SOAP-TF2DM](https://github.com/sapphonie/SOAP-TF2DM)
* [Unrestricted FOV](https://forums.alliedmods.net/showthread.php?p=1936180)

## Recommended configuration

The plugin will attempt to enable **Friendly Fire** on all modes ***other than Pass Time*** unless `ri_deathmatch` is set to `0`.

```
tf_weapon_criticals 0
tf_use_fixed_weaponspreads 1
sv_alltalk 1
sv_airaccelerate 150
sv_gravity 600
tf_spawn_glows_duration 0
tf_preround_push_from_damage_enable 1
tf_avoidteammates_pushaway 0
```