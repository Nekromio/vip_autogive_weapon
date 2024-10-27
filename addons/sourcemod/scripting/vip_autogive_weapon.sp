#pragma semicolon 1
#pragma newdecls required

#include <sdktools_functions>
#include <vip_core>

Database
	hDatabase;

ConVar
	cvEnable,
	cvGiveRespawn,
	cvEnableC4,
	cvPrimary[24];

StringMap
	hTriePrimary,
	hTriePistol;

int
	iGiveWeapon[MAXPLAYERS+1];

char
	sFile[PLATFORM_MAX_PATH];

static const char g_sFeatureWeapon[][] = {"AutoGive_Weapon", "AutoGive_WeaponMenu"};

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

char sPistolListKey[][] =
{
	"glock",
	"usp",
	"p228",
	"deagle",
	"elite",
	"fiveseven"
};

char sPistolListValue[][] =
{
	"Глок",
	"USP",
	"Compact",
	"Дизирт|Дигл",
	"Беретты",
	"Five-Seven"
};

char sPrimaryListKey[][] =
{		
	"m3",			
	"xm1014",
	"mac10",						
	"ak47",			
	"m4a1",			
	"tmp",			
	"famas",			
	"mp5navy",		
	"nova",				//
	"ump45",			
	"p90",			
	"galil",			
	"awp",			
	"scout",			
	"sg550",			
	"sg552",			
	"mp5sd",			//
	"m249",			
	"aug",			
	"g3sg1",
	"flashbang",
	"hegrenade",
	"smokegrenade",
	"c4",
	"item_defuser",
	"item_nvgs",
	"item_assaultsuit"
};

char sPrimaryListValue[][] =
{
	"M3 (2-1)",
	"XM1014 (2-2)",
	"MAC10 (3-1)",
	"AK-47",
	"M4A4",
	"tmp",
	"FAMAS",
	"mp5navy (Муха)",
	"Nova",
	"ump45",
	"p90",
	"galil",
	"AWP",
	"scout",
	"sg550",
	"MAG-7",
	"sg552",
	"m249",
	"AUG",
	"G3SG1",
	"Флешка",
	"Граната",
	"Дымовая граната",
	"Бомба",
	"Щипцы",
	"Ночное видинье",
	"Бронежилет + шлем"
};

char g_sFeature[][] =
{
	"hegrenade",
	"flashbang",
	"smokegrenade"
};

char g_sFeatureC4[] = "C4";

#include "autogive/db.sp"
#include "autogive/menu.sp"

public Plugin myinfo = 
{
	name = "[ViP Core] AutoGive Weapon",
	author = "Nek.'a 2x2 | ggwp.site",
	description = "Автовыдача оружия",
	version = "1.0.0 104",
	url = "https://ggwp.site/"
};

public void OnPluginStart()
{
	cvEnable = CreateConVar("sm_autogive_enable", "1", "Включить/Выключить плагин", _, true, _, true, 1.0);
	
	cvGiveRespawn = CreateConVar("sm_autogive_respawn", "2", "0 выдавать при возрождении снаряжение и гранаты | 1 только в начале раунда | 2 каждое возраждение только снаряжение, но при старте и гранаты",
	 _, true, 0.0, true, 2.0);

	cvEnableC4 = CreateConVar("sm_autogive_enable_c4", "0", "Включить/Выключить выдачу бомбы", _, true, _, true, 1.0);

	char buffer[32], text[256], value[8];
	for(int i = 0; i < 24; i++)
	{
		FormatEx(buffer, sizeof(buffer), "sm_autogive_%s", sPrimaryListKey[i]);
		FormatEx(text, sizeof(text), "Включить/Выключить выдачу %s", sPrimaryListValue[i]);
		if(i == 14 || i == 19)	//sg550 и g3sg1
			FormatEx(value, sizeof(value), "%d", 0);
		else FormatEx(value, sizeof(value), "%d", 1);
		cvPrimary[i] = CreateConVar(buffer, value, text, _, true, _, true, 1.0);
	}
	//cvPrimary[12] = CreateConVar("sm_autogive_awp", "0", "Включить/Выключить выдачу awp", _, true, _, true, 1.0);


	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_spawn", Event_PlayerSpawn);

	RegConsoleCmd("sm_autogive", Cmd_AutoGive, "Меню автоматической выдачи оружия");

	BuildPath(Path_SM, sFile, sizeof(sFile), "logs/autogive_weapon.log");

	Custom_SQLite();

	AutoExecConfig(true, "AutoGive_Weapon", "vip");

	if(VIP_IsVIPLoaded()) VIP_OnVIPLoaded();

	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i)) OnClientPostAdminCheck(i);
}

public void OnPluginEnd()
{
	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i) && VIP_IsClientVIP(i)) SaveSettings(i);

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
	if(!cvEnable.BoolValue || IsFakeClient(client))
		return;

	char sQuery[512], sSteam[32];
	GetClientAuthId(client, AuthId_Steam2, sSteam, sizeof(sSteam), true);

	FormatEx(sQuery, sizeof(sQuery), "SELECT `primary_atvive_t`, `primary_atvive_ct`, `pistol_atvive_t`, `pistol_atvive_ct`,\
	`primary_t`, `primary_ct`, `pistol_t`, `pistol_ct`, `flashbang`, `hegrenade`, `smokegrenade`, `c4`,\
	`defuser`, `nvgs`, `assaultsuit` FROM `vip_autogive_weapon` WHERE `steam_id` = '%s'", sSteam);
	hDatabase.Query(ConnectClient_Callback, sQuery, GetClientUserId(client));
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
	if (CheckWepon(client, 0))
		return;

	//Команда
	int team = GetClientTeam(client) - 2;

	if (team < 0)
		return;

	// Проверка доступности оружия для соответствующей команды
	if ((team == 0 && !SettingsInfo[client].bPrimaryActiveT) || 
	    (team == 1 && !SettingsInfo[client].bPrimaryActiveCT))
		return;

	char sBuffer[32];
	
	// Выбираем оружие в зависимости от команды
	char selectedWeapon[32];
	strcopy(selectedWeapon, sizeof(selectedWeapon), team == 0 ? SettingsInfo[client].sPrimaryT : SettingsInfo[client].sPrimaryCT);

	for (int i = 0; i < sizeof(sPrimaryListKey); i++)
	{
		if (!strcmp(sPrimaryListKey[i], selectedWeapon))
		{
			// Проверяем, разрешено ли оружие
			if (!cvPrimary[i].BoolValue || !selectedWeapon[0])
				return;

			RemoveSlot(client, 0);
			FormatEx(sBuffer, sizeof(sBuffer), "weapon_%s", selectedWeapon);
			GivePlayerItem(client, sBuffer);
		}
	}
}

void GiveWeaponPistol(int client)
{
	if(CheckWepon(client, 1))
		return;

	//Команда
	int team = GetClientTeam(client) - 2;

	if (team < 0)
		return;

	// Проверка доступности оружия для соответствующей команды
	if ((team == 0 && !SettingsInfo[client].bPistolActiveT) || 
	    (team == 1 && !SettingsInfo[client].bPistolActiveCT))
		return;

	char sBuffer[32];

	// Выбираем оружие в зависимости от команды
	char selectedWeapon[32];
	strcopy(selectedWeapon, sizeof(selectedWeapon), team == 0 ? SettingsInfo[client].sPistolT : SettingsInfo[client].sPistolCT);

	if (!selectedWeapon[0])
		return;

	RemoveSlot(client, 1);
	FormatEx(sBuffer, sizeof(sBuffer), "weapon_%s", selectedWeapon);
	GivePlayerItem(client, sBuffer);
}

void RemoveSlot(int client, int index)
{
	int slot = GetPlayerWeaponSlot(client, index);

	if(slot != -1)
		RemovePlayerItem(client, slot);
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

bool CheckWepon(int client, int index)
{
	char sWeapon[16];
	int slot = GetPlayerWeaponSlot(client, index);

	if(slot == -1)
		return false;

	GetEntityClassname(slot, sWeapon, sizeof(sWeapon));

	if(index)
	{
		if(GetClientTeam(client) == 3)
		{
			if(!strcmp(sWeapon, "") || !strcmp(sWeapon, "weapon_usp"))
			{
				return false;
			}
		}
		if(GetClientTeam(client) == 2)
		{
			if(!strcmp(sWeapon, "") || !strcmp(sWeapon, "weapon_glock"))
			{
				return false;
			}
		}
		return true;
	}

	if(!index && !strcmp(sWeapon, ""))
	{
		return false;
	}

	return true;
}