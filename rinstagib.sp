#pragma semicolon 1
#pragma tabsize 4
#pragma newdecls required

#include <sourcemod>
#include <tf2attributes>
#include <tf2>
#include <tf2_stocks>
#include <tf2items>
#include <sdktools>
#include <sdkhooks>

ConVar g_Cvar_Enabled;
ConVar g_Cvar_Launcher_Damage;
ConVar g_Cvar_Launcher_Radius;
ConVar g_Cvar_Launcher_FreeRJ;
ConVar g_Cvar_Launcher_Dumb;
ConVar g_Cvar_Rail_Damage;
ConVar g_Cvar_Rail_Rateslow;
ConVar g_Cvar_Rail_Snipe_Floor;
ConVar g_Cvar_Rail_Snipe_Bonus;
ConVar g_Cvar_Rail_Speed_Floor;
ConVar g_Cvar_Rail_Speed_Horizontal;
ConVar g_Cvar_Rail_Speed_Bonus;
ConVar g_Cvar_Melee_Damage;

public Plugin myinfo =
{
    name = "rinstagib",
    author = "raspy",
    description = "rinstagib gamemode.",
    version = "1.7.0",
    url = "https://jackavery.ca/tf2/#rinstagib"
};

public void OnPluginStart()
{
    g_Cvar_Enabled = CreateConVar("ri_enabled", "1", "Enable ras instagib mode.", _, true, 0.0, true, 1.0);
    g_Cvar_Launcher_Damage = CreateConVar("ri_launcher_damage", "1.8", "Rocket launcher damage multiplier.", _, true, 0.0, true, 10.0);
    g_Cvar_Launcher_Radius = CreateConVar("ri_launcher_radius", "0.1", "Rocket launcher blast radius percentage.", _, true, 0.0, true, 1.0);
    g_Cvar_Launcher_FreeRJ = CreateConVar("ri_launcher_freerj", "1.0", "Whether Rocket Jumping should cost no health.", _, true, 0.0, true, 1.0);
    g_Cvar_Launcher_Dumb = CreateConVar("ri_launcher_dumb", "1.0", "Remove projectile speed/firerate boosts from applicable rocket launchers.", _, true, 0.0, true, 1.0);
    g_Cvar_Rail_Damage = CreateConVar("ri_rail_damage", "80", "Railgun base damage.", _, true, 0.0, true, 200.0);
    g_Cvar_Rail_Rateslow = CreateConVar("ri_rail_rateslow", "2", "Railgun fire rate penalty.", _, true, 1.0, true, 10.0);
    g_Cvar_Rail_Snipe_Floor = CreateConVar("ri_rail_snipe_floor", "512", "Range at which railgun damage ramp-up begins.", _, true, 0.0, true, 5192.0);
    g_Cvar_Rail_Snipe_Bonus = CreateConVar("ri_rail_snipe_bonus", "25", "Extra railgun damage to deal for every 100 distance above ri_rail_snipe_floor.", _, true, 0.0, true, 5192.0);
    g_Cvar_Rail_Speed_Floor = CreateConVar("ri_rail_speed_floor", "300", "Railgun speed bonus floor. Set to -1 to disable.", _, true, 0.0, true, 5192.0);
    g_Cvar_Rail_Speed_Horizontal = CreateConVar("ri_rail_speed_horizontal", "1", "Whether railgun speed bonus should only consider horizontal speed.", _, true, 0.0, true, 1.0);
    g_Cvar_Rail_Speed_Bonus = CreateConVar("ri_rail_speed_bonus", "20", "Extra railgun damage to deal for every 100 speed above ri_rail_speed_floor.", _, true, 0.0, true, 5192.0);
    g_Cvar_Melee_Damage = CreateConVar("ri_melee_damage", "4", "Melee damage multiplier.", _, true, 0.0, true, 10.0);

    // apply hook to players already connected on reload
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsClientInGame(client)) {
            OnClientPutInServer(client);
        }
    }

    HookEvent("post_inventory_application", OnInventoryApplication, EventHookMode_Post);

    AutoExecConfig(true, "rinstagib");
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float& damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
    if (!GetConVarBool(g_Cvar_Enabled))
    {
        return Plugin_Continue;
    }

    // remove fall damage
    if(damagetype & DMG_FALL)
    {
        // have kill barriers still kill
        // 450< fall damage in one fall shouldn't usually happen
        if(damage > 450)
        {
            return Plugin_Continue;
        }
        return Plugin_Handled;
    }

    // apply very strict railgun damage
    char wepcls[128];
    GetEntityClassname(weapon, wepcls, sizeof(wepcls));
    if(StrContains(wepcls, "tf_weapon_shotgun", false) == 0)
    {
        damage = g_Cvar_Rail_Damage.FloatValue;

        // measure distance & apply range multiplier
        if (g_Cvar_Rail_Snipe_Bonus.FloatValue <= 1.0)
        {
            float pos_victim[3];
            GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos_victim);
            float pos_inflictor[3];
            GetEntPropVector(inflictor, Prop_Send, "m_vecOrigin", pos_inflictor);

            float distance = GetVectorDistance(pos_victim, pos_inflictor);
            distance = distance - g_Cvar_Rail_Snipe_Floor.FloatValue;

            if (distance > 0)
            {
                damage = damage + ( g_Cvar_Rail_Snipe_Bonus.FloatValue * (distance / 100) );
            }
        }

        // measure speed & apply speed multiplier
        if (g_Cvar_Rail_Speed_Bonus.FloatValue <= 0.0)
        {
            float vel_inflictor[3];
            GetEntPropVector(inflictor, Prop_Data, "m_vecAbsVelocity", vel_inflictor);

            float speed;
            speed = SquareRoot( Pow(vel_inflictor[0], 2.0) + Pow(vel_inflictor[1], 2.0) ); // horizontal
            if (!g_Cvar_Rail_Speed_Horizontal.BoolValue)
            {
                speed = SquareRoot( Pow(speed, 2.0) + Pow(vel_inflictor[2], 2.0) ); // total absolute
            }

            speed = speed - g_Cvar_Rail_Speed_Floor.FloatValue;
            if (speed > 0)
            {
                damage = damage + ( g_Cvar_Rail_Speed_Bonus.FloatValue * (speed / 100) );
            }
        }

        // deal damage
        SDKHooks_TakeDamage(victim,
                        attacker,
                        inflictor,
                        damage,
                        DMG_ALWAYSGIB,
                        weapon,
                        damageForce,
                        damagePosition,
                        true);
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

public void OnInventoryApplication(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_Cvar_Enabled.BoolValue)
    {
        return;
    }

    // Automatically re-enable AIA if it's disabled
    ConVar sm_aia_all = FindConVar("sm_aia_all");
    if (sm_aia_all)
    {
        SetConVarBool(sm_aia_all, true);
    }

    int client = GetClientOfUserId(event.GetInt("userid"));

    ////
    // PRIMARY

    // Make airshots one-shot and remove blast radius
    int pWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
    TF2Attrib_SetByName(pWeapon, "damage bonus", g_Cvar_Launcher_Damage.FloatValue);
    TF2Attrib_SetByName(pWeapon, "mod mini-crit airborne", 1.0);
    TF2Attrib_SetByName(pWeapon, "Blast radius decreased", g_Cvar_Launcher_Radius.FloatValue);

    // Remove unfair buffs from weapons
    if (g_Cvar_Launcher_Dumb.BoolValue)
    {
        TF2Attrib_SetByName(pWeapon, "Projectile speed increased", 1.0); // direct hit/liblauncher
        TF2Attrib_SetByName(pWeapon, "rocketjump attackrate bonus", 1.0); // air strike
    }

    // Make rocket jumping free
    if (g_Cvar_Launcher_FreeRJ.BoolValue)
    {
        TF2Attrib_SetByName(pWeapon, "rocket jump damage reduction", 0.0);
    }

    ////
    // SECONDARY

    // Allow people to use their own shotguns
    int sWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
    char wepcls[128];
    GetEntityClassname(sWeapon, wepcls, sizeof(wepcls));
    if(StrContains(wepcls, "tf_weapon_shotgun", false) == 0) {
        // Clear attributes and rebuild to enforce consistency
        TF2Attrib_RemoveAll(sWeapon);
        Railgunify(sWeapon);
    } else {
        // Create weapon
        Handle hWeapon = TF2Items_CreateItem(OVERRIDE_ALL | FORCE_GENERATION | PRESERVE_ATTRIBUTES);
        TF2Items_SetClassname(hWeapon, "tf_weapon_shotgun_soldier");
        TF2Items_SetItemIndex(hWeapon, 10);
        int iWeapon = TF2Items_GiveNamedItem(client, hWeapon);
        delete hWeapon;

        Railgunify(iWeapon);

        // Replace secondary with railgun
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

void Railgunify(int weapon) {
    // Make railgun
    TF2Attrib_SetByName(weapon, "sniper fires tracer", 1.0);
    TF2Attrib_SetByName(weapon, "minicrits become crits", 1.0);
    TF2Attrib_SetByName(weapon, "weapon spread bonus", 0.0);
    TF2Attrib_SetByName(weapon, "projectile penetration", 1.0);
    TF2Attrib_SetByName(weapon, "fire rate penalty", g_Cvar_Rail_Rateslow.FloatValue);
}
