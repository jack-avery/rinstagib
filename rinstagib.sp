#pragma semicolon 1
#pragma tabsize 4
#pragma newdecls required

#include <smlib>
#include <sourcemod>
#include <tf2attributes>
#include <tf2>
#include <tf2_stocks>
#include <tf2items>
#include <sdktools>
#include <sdkhooks>
#include <morecolors>

ConVar g_Cvar_Enabled;
ConVar g_Cvar_Leaderboard;
ConVar g_Cvar_Launcher_Damage;
ConVar g_Cvar_Launcher_Radius;
ConVar g_Cvar_Launcher_FreeRJ;
ConVar g_Cvar_Launcher_Consistent;
ConVar g_Cvar_Launcher_ProjSpeed;
ConVar g_Cvar_Launcher_BazookaDeviation;
ConVar g_Cvar_Rail_Damage;
ConVar g_Cvar_Rail_GibDamage;
ConVar g_Cvar_Rail_Rateslow;
ConVar g_Cvar_Rail_Snipe_Floor;
ConVar g_Cvar_Rail_Snipe_Bonus;
ConVar g_Cvar_Rail_Speed_Floor;
ConVar g_Cvar_Rail_Speed_Horizontal;
ConVar g_Cvar_Rail_Speed_Bonus;
ConVar g_Cvar_Melee_Damage;

public Plugin myinfo = {
    name = "rinstagib",
    author = "raspy",
    description = "rinstagib gamemode.",
    version = "1.9.1",
    url = "https://jackavery.ca/tf2/#rinstagib"
};

float g_fTopDamage[MAXPLAYERS + 1];

public void OnPluginStart() {
    g_Cvar_Enabled = CreateConVar("ri_enabled", "1", "Enable rinstagib mode.", _, true, 0.0, true, 1.0);
    g_Cvar_Leaderboard = CreateConVar("ri_leaderboard", "1", "Enable the rinstagib damage leaderboard and announcements.", _, true, 0.0, true, 1.0);
    g_Cvar_Launcher_Damage = CreateConVar("ri_launcher_damage", "5", "Rocket launcher damage multiplier.", _, true, 0.0, true, 10.0);
    g_Cvar_Launcher_Radius = CreateConVar("ri_launcher_radius", "0.1", "Rocket launcher blast radius multiplier.", _, true, 0.0, true, 1.0);
    g_Cvar_Launcher_FreeRJ = CreateConVar("ri_launcher_freerj", "1.0", "Whether Rocket Jumping should cost no health.", _, true, 0.0, true, 1.0);
    g_Cvar_Launcher_Consistent = CreateConVar("ri_launcher_consistent", "1.0", "Whether all rocket launchers (except Beggars) should act the same.", _, true, 0.0, true, 1.0);
    g_Cvar_Launcher_ProjSpeed = CreateConVar("ri_launcher_projspeed", "1.0", "Projectile speed multiplier for all launchers if ri_launcher_consistent is 1.", _, true, 0.0, true, 3.0);
    g_Cvar_Launcher_BazookaDeviation = CreateConVar("ri_launcher_bazooka_nodeviation", "1.0", "Remove projectile deviation from the Beggars Bazooka.", _, true, 0.0, true, 1.0);
    g_Cvar_Rail_Damage = CreateConVar("ri_rail_damage", "80", "Railgun base damage.", _, true, 0.0);
    g_Cvar_Rail_GibDamage = CreateConVar("ri_rail_gibdamage", "200", "Railgun shots dealing more than this amount will gib the target. Set to 0 to disable.", _, true, 200.0);
    g_Cvar_Rail_Rateslow = CreateConVar("ri_rail_rateslow", "2", "Railgun fire rate slow. 1 = Normal shotgun speed.", _, true, 1.0, true, 10.0);
    g_Cvar_Rail_Snipe_Floor = CreateConVar("ri_rail_snipe_floor", "512", "Range at which railgun damage ramp-up begins.", _, true, 0.0);
    g_Cvar_Rail_Snipe_Bonus = CreateConVar("ri_rail_snipe_bonus", "25", "Amount to add to railgun damage for every 100 distance above ri_rail_snipe_floor.", _);
    g_Cvar_Rail_Speed_Floor = CreateConVar("ri_rail_speed_floor", "300", "Railgun speed bonus floor.", _, true, 0.0);
    g_Cvar_Rail_Speed_Horizontal = CreateConVar("ri_rail_speed_horizontal", "1", "Whether railgun speed bonus should only consider horizontal speed.", _, true, 0.0, true, 1.0);
    g_Cvar_Rail_Speed_Bonus = CreateConVar("ri_rail_speed_bonus", "20", "Amount to add to railgun damage for every 100 speed above ri_rail_speed_floor.", _);
    g_Cvar_Melee_Damage = CreateConVar("ri_melee_damage", "4", "Melee damage multiplier.", _, true, 1.0, true, 10.0);

    // apply hook to players already connected on reload
    for (int client = 1; client <= MaxClients; client++) {
        if (IsClientInGame(client)) {
            OnClientPutInServer(client);
        }
    }

    HookEvent("post_inventory_application", OnInventoryApplication, EventHookMode_Post);
    HookEvent("player_death", OnPlayerDeath);

    AutoExecConfig(true, "rinstagib");
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnClientAuthorized(int client, const char[] auth)
{
    if (!StrEqual(auth, "BOT"))
    {
        g_fTopDamage[client] = 0.0;
    }
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float& damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
    if (!g_Cvar_Enabled.BoolValue) {
        return Plugin_Continue;
    }

    // remove fall damage
    if(damagetype & DMG_FALL) {
        // have kill barriers still kill
        // 450< fall damage in one fall shouldn't usually happen
        if(damage > 450) {
            return Plugin_Continue;
        }
        return Plugin_Handled;
    }

    if (weapon == -1) {
        return Plugin_Continue;
    }

    // apply very strict railgun damage
    char wepcls[128];
    GetEntityClassname(weapon, wepcls, sizeof(wepcls));
    if(StrContains(wepcls, "tf_weapon_shotgun", false) == 0) {
        damage = g_Cvar_Rail_Damage.FloatValue;

        // measure distance & apply range multiplier
        if (g_Cvar_Rail_Snipe_Bonus.FloatValue > 0.0) {
            float pos_victim[3];
            GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos_victim);
            float pos_inflictor[3];
            GetEntPropVector(inflictor, Prop_Send, "m_vecOrigin", pos_inflictor);

            float distance = GetVectorDistance(pos_victim, pos_inflictor);
            distance = distance - g_Cvar_Rail_Snipe_Floor.FloatValue;

            if (distance > 0) {
                damage = damage + ( g_Cvar_Rail_Snipe_Bonus.FloatValue * (distance / 100) );
            }
        }

        // measure speed & apply speed multiplier
        if (g_Cvar_Rail_Speed_Bonus.FloatValue > 0.0) {
            float vel_inflictor[3];
            GetEntPropVector(inflictor, Prop_Data, "m_vecAbsVelocity", vel_inflictor);

            float speed;
            speed = SquareRoot( Pow(vel_inflictor[0], 2.0) + Pow(vel_inflictor[1], 2.0) ); // horizontal
            if (!g_Cvar_Rail_Speed_Horizontal.BoolValue) {
                speed = SquareRoot( Pow(speed, 2.0) + Pow(vel_inflictor[2], 2.0) ); // total absolute
            }

            speed = speed - g_Cvar_Rail_Speed_Floor.FloatValue;
            if (speed > 0) {
                damage = damage + ( g_Cvar_Rail_Speed_Bonus.FloatValue * (speed / 100) );
            }
        }

        // Railgun damage instances >= g_Cvar_Rail_GibDamage should gib+sfx
        int damage_type = DMG_BULLET;
        if (damage >= g_Cvar_Rail_GibDamage.FloatValue) {
            damage_type += DMG_ALWAYSGIB;
            ClientCommand(attacker, "playgamesound TFPlayer.CritPain");
            ClientCommand(victim, "playgamesound TFPlayer.CritPain");
        }

        if (g_Cvar_Leaderboard.BoolValue) {
            PerformLeaderboard(attacker, damage);
        }

        // deal damage
        SDKHooks_TakeDamage(victim,
                        attacker,
                        inflictor,
                        damage,
                        damage_type,
                        weapon,
                        damageForce,
                        damagePosition,
                        true);
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast) {
    if (!g_Cvar_Enabled.BoolValue) {
        return;
    }

    // mostly borrowed code from:
    // https://forums.alliedmods.net/showthread.php?p=2633926 by Nanochip
    // https://forums.alliedmods.net/showthread.php?t=81874 by strontiumdog/DiscoBBQ
    int damage_type = event.GetInt("damagebits");
    if (damage_type & DMG_ALWAYSGIB) {
        int client = GetClientOfUserId(event.GetInt("userid"));
        float origin[3];
        GetClientAbsOrigin(client, origin);

        int ragdoll = CreateEntityByName("tf_ragdoll");
        int team = GetClientTeam(client);
	    int class = view_as<int>(TF2_GetPlayerClass(client));

        SetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollOrigin", origin); 
        SetEntPropEnt(ragdoll, Prop_Send, "m_hPlayer", client);
        SetEntPropVector(ragdoll, Prop_Send, "m_vecForce", NULL_VECTOR);
        SetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", NULL_VECTOR);
        SetEntProp(ragdoll, Prop_Send, "m_bGib", 1);
        SetEntProp(ragdoll, Prop_Send, "m_iTeam", team);
        SetEntProp(ragdoll, Prop_Send, "m_iClass", class);

        DispatchSpawn(ragdoll);

        CreateTimer(0.1, RemoveBody, client);
        CreateTimer(15.0, RemoveGibs, ragdoll);
    }
}

public Action RemoveBody(Handle timer, any client) {
    int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
    if(IsValidEdict(ragdoll)) {
        AcceptEntityInput(ragdoll, "kill");
    }
    return Plugin_Continue;
}

public Action RemoveGibs(Handle timer, any ent) {
    if(IsValidEntity(ent)) {
        char classname[64];

        GetEdictClassname(ent, classname, sizeof(classname));

        if(StrEqual(classname, "tf_ragdoll", false)) {
            AcceptEntityInput(ent, "kill");
        }
    }

    return Plugin_Continue;
}

public void OnInventoryApplication(Event event, const char[] name, bool dontBroadcast) {
    if (!g_Cvar_Enabled.BoolValue) {
        return;
    }

    // Automatically re-enable AIA if it's disabled
    ConVar sm_aia_all = FindConVar("sm_aia_all");
    if (sm_aia_all) {
        SetConVarBool(sm_aia_all, true);
    }

    int client = GetClientOfUserId(event.GetInt("userid"));

    ////
    // PRIMARY

    // Make airshots one-shot and remove blast radius
    int pWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
    TF2Attrib_SetByName(pWeapon, "damage bonus", g_Cvar_Launcher_Damage.FloatValue);
    TF2Attrib_SetByName(pWeapon, "damage penalty", 1.0);
    TF2Attrib_SetByName(pWeapon, "mod mini-crit airborne", 1.0);
    TF2Attrib_SetByName(pWeapon, "Blast radius decreased", g_Cvar_Launcher_Radius.FloatValue);

    // Remove deviation from Beggars
    if (g_Cvar_Launcher_BazookaDeviation.BoolValue) {
        TF2Attrib_SetByName(pWeapon, "projectile spread angle penalty", 0.0);
    }

    // Make all non-beggars rocket launchers consistent (else DH/AirStrike becomes S+)
    if (g_Cvar_Launcher_Consistent.BoolValue) {
        TF2Attrib_SetByName(pWeapon, "Projectile speed increased", g_Cvar_Launcher_ProjSpeed.FloatValue); // direct hit/liblauncher
        TF2Attrib_SetByName(pWeapon, "rocketjump attackrate bonus", 1.0); // air strike
    }

    // Make rocket jumping free
    if (g_Cvar_Launcher_FreeRJ.BoolValue) {
        TF2Attrib_SetByName(pWeapon, "rocket jump damage reduction", 0.0);
    }

    ////
    // SECONDARY

    // Allow people to use their own shotguns
    int sWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);

    bool isValidShotgun = false;
    // If they have an item in TFWeaponSlot_Secondary, ensure it's a shotgun
    if (sWeapon != -1) {
        char wepcls[128];
        GetEntityClassname(sWeapon, wepcls, sizeof(wepcls));
        isValidShotgun = (StrContains(wepcls, "tf_weapon_shotgun", false) == 0);
    } else {
        // It's probably Gunboats/Mantreads
        int entity = -1;
        while((entity = FindEntityByClassname(entity, "tf_wearable")) != INVALID_ENT_REFERENCE) {
            // Remove Mantreads as it's not intended to be used
            if(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex") == 444)
            {
                AcceptEntityInput(entity, "Kill");
                break;
            }
        }
    }

    if(isValidShotgun) {
        // remove bonuses on Panic Attack/Reserve Shooter
        // setting this to 0 or 1 makes it 100% faster, 0.99 makes it 1% faster, good enough???
        TF2Attrib_SetByName(sWeapon, "single wep deploy time decreased", 0.99);
        TF2Attrib_SetByName(sWeapon, "mod mini-crit airborne", 0.0);
        Railgunify(sWeapon);
    } else {
        // Create a new shotgun and railgunify it
        Handle hWeapon = TF2Items_CreateItem(OVERRIDE_ALL | FORCE_GENERATION | PRESERVE_ATTRIBUTES);
        TF2Items_SetClassname(hWeapon, "tf_weapon_shotgun_soldier");
        TF2Items_SetItemIndex(hWeapon, 10);
        int iWeapon = TF2Items_GiveNamedItem(client, hWeapon);
        delete hWeapon;

        Railgunify(iWeapon);

        // Replace it with railgun
        TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
        EquipPlayerWeapon(client, iWeapon);
    }

    ////
    // MELEE

    // Make melee one-shot always
    int mWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
    TF2Attrib_SetByName(mWeapon, "damage bonus", g_Cvar_Melee_Damage.FloatValue);
    TF2Attrib_SetByName(mWeapon, "restore health on kill", 0.0);
}

void PerformLeaderboard(int client, float damage) {
    if (damage > g_fTopDamage[client]) {
        g_fTopDamage[client] = damage;
    }

    float top = 0.0;
    int top_c;
    for (int c; c < MAXPLAYERS+1; c++) {
        if (g_fTopDamage[c] > top) {
            top = g_fTopDamage[c];
            top_c = c;
        }
    }

    if (damage >= 200.0 && damage >= top) {
        char name[32];
        GetClientName(top_c, name, sizeof(name));
        MC_PrintToChatAll("{white}%s {crimson}just hit a railshot dealing {hotpink}%.1f{crimson}!!", name, top);
        for (int i = 0; i <= MAXPLAYERS; i++) {
            if (IsValidClient(i)) {
                ClientCommand(i, "playgamesound \"misc/killstreak.wav\"");
            }
        }
    }
}

void Railgunify(int weapon) {
    // Make railgun
    TF2Attrib_SetByName(weapon, "sniper fires tracer", 1.0);
    TF2Attrib_SetByName(weapon, "minicrits become crits", 1.0);
    TF2Attrib_SetByName(weapon, "weapon spread bonus", 0.0);
    TF2Attrib_SetByName(weapon, "projectile penetration", 1.0);
    TF2Attrib_SetByName(weapon, "fire rate penalty", g_Cvar_Rail_Rateslow.FloatValue);
}

bool IsValidClient(int client)
{
    return ((0 < client <= MaxClients) && IsClientInGame(client) && !IsClientSourceTV(client) && !IsClientReplay(client));
}