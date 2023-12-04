#pragma semicolon 1
#pragma newdecls required

#include <sdktools_functions>
#include <vip_core>

Database
	hDatabase;

ConVar
	cvEnable,
	cvGiveRespawn,
	cvEnableC4;

StringMap
	hTriePrimary,
	hTriePistol;

int
	iGiveWeapon[MAXPLAYERS+1];

char
	sFile[PLATFORM_MAX_PATH];

static const char g_sFeature[][] =
{
	"hegrenade",
	"flashbang",
	"smokegrenade"
};

static const char g_sFeatureWeapon[][] = {"AutoGive_Weapon", "AutoGive_WeaponMenu"};

static const char g_sFeatureC4[] = "C4";

static const char sGrenadeList[][] =
{
	"weapon_hegrenade",
	"weapon_flashbang",
	"weapon_smokegrenade"
};

enum struct WeaponSettings
{
	char sPrimaryT[32];
	char sPrimaryCT[32];
	char sPistolT[32];
	char sPistolCT[32];
	int iHe;
	int iFlash;
	int iSmoke;
	bool bC4;
	bool bDefuser;
	bool bNvgs;
	bool bAssaultsuit;
	bool bPrimaryActiveT;
	bool bPrimaryActiveCT;
	bool bPistolActiveT;
	bool bPistolActiveCT;
}

WeaponSettings SettingsInfo[MAXPLAYERS+1];

#include "autogive/db.sp"
#include "autogive/menu.sp"

public Plugin myinfo = 
{
	name = "[ViP Core] AutoGive Weapon",
	author = "Nek.'a 2x2 | ggwp.site",
	description = "Автовыдача оружия",
	version = "1.0.0 102",
	url = "https://ggwp.site/"
};

public void OnPluginStart()
{
	cvEnable = CreateConVar("sm_autogive_enable", "1", "Включить/Выключить плагин", _, true, _, true, 1.0);
	
	cvGiveRespawn = CreateConVar("sm_autogive_respawn", "2", "0 выдавать при возрождении снаряжение и гранаты | 1 только в начале раунда | 2 каждое возраждение только снаряжение, но при старте и гранаты",
	 _, true, 0.0, true, 2.0);

	cvEnableC4 = CreateConVar("sm_autogive_enable_c4", "0", "Включить/Выключить выдачу бомбы", _, true, _, true, 1.0);

	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_spawn", Event_PlayerSpawn);

	RegConsoleCmd("sm_autogive", Cmd_AutoGive, "Меню автоматической выдачи оружия");

	BuildPath(Path_SM, sFile, sizeof(sFile), "logs/autogive_weapon.log");

	Custom_SQLite();

	AutoExecConfig(true, "AutoGive_Weapon", "vip");

	if(VIP_IsVIPLoaded()) VIP_OnVIPLoaded();
}

public void OnPluginEnd()
{
	if(!CanTestFeatures() || GetFeatureStatus(FeatureType_Native, "VIP_UnregisterFeature") != FeatureStatus_Available)
	{
    	return;
	}
  
	if(VIP_IsValidFeature(g_sFeatureWeapon[0]))
		VIP_UnregisterFeature(g_sFeatureWeapon[0]);

	if(VIP_IsValidFeature(g_sFeatureWeapon[1]))
		VIP_UnregisterFeature(g_sFeatureWeapon[1]);

	for(int i = 0; i < sizeof(g_sFeature); i++)	if(VIP_IsValidFeature(g_sFeature[i]))
	{
		VIP_UnregisterFeature(g_sFeature[i]);
	}

	if(VIP_IsValidFeature(g_sFeatureC4))
	{
		VIP_UnregisterFeature(g_sFeatureC4);
	}
}

public void VIP_OnVIPLoaded()
{
	VIP_RegisterFeature(g_sFeatureWeapon[0], BOOL);
	VIP_RegisterFeature(g_sFeatureWeapon[1], _, SELECTABLE, OnItemSelect, _, OnItemDraw);

	VIP_RegisterFeature(g_sFeatureC4, BOOL, HIDE);

	for(int i = 0; i < sizeof(g_sFeature); i++)
	{
		VIP_RegisterFeature(g_sFeature[i], INT, HIDE);
	}
}

public bool OnItemSelect(int client, const char[] sFeatureName)
{
	CreatMenu_AutoGiveWeapon(client);

	return false;
}

public int OnItemDraw(int iClient, const char[] sFeatureName, int iStyle)
{
	switch(VIP_GetClientFeatureStatus(iClient, g_sFeatureWeapon[0]))
	{
		case ENABLED: return ITEMDRAW_DEFAULT;
		case DISABLED: return ITEMDRAW_DISABLED;
		case NO_ACCESS: return ITEMDRAW_RAWLINE;
	}

	return iStyle;
}

void Event_RoundEnd(Event hEvent, const char[] name, bool dontBroadcast)
{
	if(!cvEnable.BoolValue)
		return;

	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i))
	{
		iGiveWeapon[i] = cvGiveRespawn.IntValue;
	}
}

void Event_PlayerSpawn(Event hEvent, const char[] name, bool dontBroadcast)
{
	if(!cvEnable.BoolValue)
		return;

	int client;

	if(!(client = GetClientOfUserId(GetEventInt(hEvent, "userid"))) || !IsClientInGame(client) || IsFakeClient(client)
	|| !VIP_IsClientVIP(client) || !VIP_IsClientFeatureUse(client, g_sFeatureWeapon[0]))
	return;

	if(iGiveWeapon[client] == -1)
		return;

	if(iGiveWeapon[client] != 3)
		iGiveWeapon[client] = cvGiveRespawn.IntValue;

	if(!iGiveWeapon[client])
	{
		GiveWeaponPrimary(client);
		GiveWeaponPistol(client);
		GiveGrenade(client);
		GeveSecondary(client);
	}

	if(iGiveWeapon[client] == 1)
	{
		GiveWeaponPrimary(client);
		GiveWeaponPistol(client);
		GiveGrenade(client);
		GeveSecondary(client);

		iGiveWeapon[client] = -1;
	}

	if(iGiveWeapon[client] == 2 || iGiveWeapon[client] == 3)
	{
		GiveWeaponPrimary(client);
		GiveWeaponPistol(client);
		GeveSecondary(client);

		if(iGiveWeapon[client] == 2)
			GiveGrenade(client);

		iGiveWeapon[client] = 3;
	}
}

public void OnClientDisconnect(int client)
{
	SaveSettings(client);
}

Action Cmd_AutoGive(int client, any arg)
{
	if(!cvEnable.BoolValue || !client || IsFakeClient(client))
		return Plugin_Continue;
	
	if(!VIP_IsClientVIP(client) || !VIP_IsClientFeatureUse(client, g_sFeatureWeapon[0]))
		return Plugin_Continue;

	CreatMenu_AutoGiveWeapon(client);
		
	return Plugin_Handled;
}

public void OnClientPostAdminCheck(int client)
{
	if(!cvEnable.BoolValue || !IsFakeClient(client))
	{
		char sQuery[512], sSteam[32];
		GetClientAuthId(client, AuthId_Steam2, sSteam, sizeof(sSteam), true);
		FormatEx(sQuery, sizeof(sQuery), "SELECT `primary_atvive_t`, `primary_atvive_ct`, `pistol_atvive_t`, `pistol_atvive_ct`,\
		`primary_t`, `primary_ct`, `pistol_t`, `pistol_ct`, `flashbang`, `hegrenade`, `smokegrenade`, `c4`,\
		`defuser`, `nvgs`, `assaultsuit` FROM `vip_autogive_weapon` WHERE `steam_id` = '%s'", sSteam);
		hDatabase.Query(ConnectClient_Callback, sQuery, GetClientUserId(client));
	}
}

void SettingDefault(int client)
{
	SettingsInfo[client].bPrimaryActiveT = true;
	SettingsInfo[client].bPrimaryActiveCT = true;
	SettingsInfo[client].bPistolActiveT = true;
	SettingsInfo[client].bPistolActiveCT = true;
	SettingsInfo[client].sPrimaryT = "m4a1";
	SettingsInfo[client].sPrimaryCT = "ak47";
	SettingsInfo[client].sPistolT = "deagle";
	SettingsInfo[client].sPistolCT = "deagle";
	SettingsInfo[client].iFlash = 2;
	SettingsInfo[client].iHe = 1;
	SettingsInfo[client].iSmoke = 1;
	SettingsInfo[client].bC4 = false;
	SettingsInfo[client].bDefuser = true;
	SettingsInfo[client].bNvgs = false;
	SettingsInfo[client].bAssaultsuit = true;
}

void GiveWeaponPrimary(int client)
{
	if(!SettingsInfo[client].bPrimaryActiveT && !SettingsInfo[client].bPrimaryActiveCT)
		return;

	int slot = GetPlayerWeaponSlot(client, 0);

	if(slot != -1)
		RemovePlayerItem(client, slot);

	char sBuffer[32];

	if(SettingsInfo[client].bPrimaryActiveT && GetClientTeam(client) == 2)
	{
		FormatEx(sBuffer, sizeof(sBuffer), "weapon_%s", SettingsInfo[client].sPrimaryT);
		GivePlayerItem(client, sBuffer);
	}
		
	else if(SettingsInfo[client].bPrimaryActiveCT && GetClientTeam(client) == 3)
	{
		FormatEx(sBuffer, sizeof(sBuffer), "weapon_%s", SettingsInfo[client].sPrimaryCT);
		GivePlayerItem(client, sBuffer);
	}
}

void GiveWeaponPistol(int client)
{
	if(!SettingsInfo[client].bPistolActiveT && !SettingsInfo[client].bPistolActiveCT)
		return;

	int slot = GetPlayerWeaponSlot(client, 1);

	if(slot != -1)
		RemovePlayerItem(client, slot);

	char sBuffer[32];

	if(SettingsInfo[client].bPistolActiveT && GetClientTeam(client) == 2)
	{
		FormatEx(sBuffer, sizeof(sBuffer), "weapon_%s", SettingsInfo[client].sPistolT);
		GivePlayerItem(client, sBuffer);
	}
		
	else if(SettingsInfo[client].bPistolActiveCT && GetClientTeam(client) == 3)
	{
		FormatEx(sBuffer, sizeof(sBuffer), "weapon_%s", SettingsInfo[client].sPistolCT);
		GivePlayerItem(client, sBuffer);
	}
}

void GiveGrenade(int client)
{
	for(int i = 0; i < sizeof(g_sFeature); i++) if(VIP_IsClientFeatureUse(client, g_sFeature[i]))
	{
		switch(i)
		{
			case 0:
			{
				if(SettingsInfo[client].iHe)
					SetGrenade(client, i+11, SettingsInfo[client].iHe);
			}
			case 1:
			{
				if(SettingsInfo[client].iFlash)
					SetGrenade(client, i+11, SettingsInfo[client].iFlash);
			}
			case 2:
			{
				if(SettingsInfo[client].iSmoke)
					SetGrenade(client, i+11, SettingsInfo[client].iSmoke);
			}
		}
	}
}

void SetGrenade(int client, int index, int count)
{
	if(GetEntProp(client, Prop_Send, "m_iAmmo", _, index) < 1)
		GivePlayerItem(client, sGrenadeList[index-11]);
	if(!(GetEntProp(client, Prop_Send, "m_iAmmo", _, index) >= count))
		SetEntProp(client, Prop_Send, "m_iAmmo", count, _, index);
}

void GeveSecondary(int client)
{
	if(SettingsInfo[client].bAssaultsuit)
	{
		SetEntProp(client, Prop_Send, "m_ArmorValue", 100);
		SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
	}
	
	if(GetClientTeam(client) == 3 && SettingsInfo[client].bDefuser)// && GetEntProp(client, Prop_Send, "m_bHasDefuser") == 0)
	{
		SetEntProp(client, Prop_Send, "m_bHasDefuser", true);
		//GivePlayerItem(client, "item_defuser");
	}

	if(SettingsInfo[client].bNvgs)// && GetEntProp(client, Prop_Send, "item_nvgs")  == 0)
		GivePlayerItem(client, "item_nvgs");

	if(cvEnableC4.BoolValue && GetClientTeam(client) == 2 && SettingsInfo[client].bC4 && VIP_IsClientVIP(client) && VIP_IsClientFeatureUse(client, g_sFeatureC4))
	{
		int slot = GetPlayerWeaponSlot(client, 4);
		if(slot == -1)
			GivePlayerItem(client, "weapon_c4");
	}
		
}