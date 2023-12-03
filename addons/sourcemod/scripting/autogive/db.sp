void Custom_SQLite()
{
	KeyValues hKv = new KeyValues("");
	hKv.SetString("driver", "sqlite");
	hKv.SetString("host", "localhost");
	hKv.SetString("database", "AutoGiveWeapon");
	hKv.SetString("user", "root");
	hKv.SetString("pass", "");
	
	char sError[255];
	hDatabase = SQL_ConnectCustom(hKv, sError, sizeof(sError), true);

	if(sError[0])
	{
		SetFailState("Ошибка подключения к локальной базе SQLite: %s", sError);
	}
	hKv.Close();

	First_ConnectionSQLite();
}

void First_ConnectionSQLite()
{
	SQL_LockDatabase(hDatabase);
	char sQuery[1024];
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `vip_autogive_weapon` (\
		`id` INTEGER PRIMARY KEY,\
		`steam_id` VARCHAR(32),\
		`primary_atvive_t` INTEGER(1),\
		`primary_atvive_ct` INTEGER(1),\
		`pistol_atvive_t` INTEGER(1),\
		`pistol_atvive_ct` INTEGER(1),\
		`primary_t` VARCHAR(32),\
		`primary_ct` VARCHAR(32),\
		`pistol_t` VARCHAR(32),\
		`pistol_ct` VARCHAR(32),\
		`flashbang` INTEGER(3),\
		`hegrenade` INTEGER(3),\
		`smokegrenade` INTEGER(3),\
		`c4` INTEGER(1),\
		`defuser` INTEGER(1),\
		`nvgs` INTEGER(1),\
		`assaultsuit` INTEGER(1))");

	hDatabase.Query(First_ConnectionSQLite_Callback, sQuery);

	SQL_UnlockDatabase(hDatabase);
	hDatabase.SetCharset("utf8");
}

public void First_ConnectionSQLite_Callback(Database hDb, DBResultSet results, const char[] sError, any iUserID)
{
	if (hDb == null || sError[0])
	{
		SetFailState("Ошибка подключения к базе: %s", sError);
		return;
	}
	
	//LogToFile(sFile, "Подключение к базе данных прошло успешно!");
}

public void ConnectClient_Callback(Database hDatabaseLocal, DBResultSet hResults, const char[] sError, any iUserID)
{
	if(sError[0])
	{
		LogError("ConnectClient_Callback: %s", sError); //
		return; //
	}
	
	int client = GetClientOfUserId(iUserID);
	if(client)
	{
		if(hResults.FetchRow())	// Игрок есть в базе
		{
			char sResult[512], sValue[32];
			hResults.FetchString(0, sResult, sizeof(sResult));
			SettingsInfo[client].bPrimaryActiveT = view_as<bool>(StringToInt(sResult));
			
			for(int i; i < 15; i++)
			{
				hResults.FetchString(i, sResult, sizeof(sResult));
				Format(sValue, sizeof(sValue), sResult, sValue);
				switch(i)
				{
					case 0: SettingsInfo[client].bPrimaryActiveT = view_as<bool>(StringToInt(sValue));
					case 1: SettingsInfo[client].bPrimaryActiveCT = view_as<bool>(StringToInt(sValue));
					case 2: SettingsInfo[client].bPistolActiveT = view_as<bool>(StringToInt(sValue));
					case 3: SettingsInfo[client].bPistolActiveCT = view_as<bool>(StringToInt(sValue));
					case 4: SettingsInfo[client].sPrimaryT = sValue;
					case 5: SettingsInfo[client].sPrimaryCT = sValue;
					case 6: SettingsInfo[client].sPistolT = sValue;
					case 7: SettingsInfo[client].sPistolCT = sValue;
					case 8: SettingsInfo[client].iFlash = StringToInt(sValue);
					case 9: SettingsInfo[client].iHe = StringToInt(sValue);
					case 10: SettingsInfo[client].iSmoke = StringToInt(sValue);
					case 11: SettingsInfo[client].bC4 = view_as<bool>(StringToInt(sValue));
					case 12: SettingsInfo[client].bDefuser = view_as<bool>(StringToInt(sValue));
					case 13: SettingsInfo[client].bNvgs = view_as<bool>(StringToInt(sValue));
					case 14: SettingsInfo[client].bAssaultsuit = view_as<bool>(StringToInt(sValue));
				}
				
			}
		}
		else
		{
			SettingDefault(client);

			char sQuery[512], sSteam[32];
			GetClientAuthId(client, AuthId_Steam2, sSteam, sizeof(sSteam));
			FormatEx(sQuery, sizeof(sQuery), "INSERT INTO `vip_autogive_weapon` (`steam_id`, `primary_atvive_t`, `primary_atvive_ct`, `pistol_atvive_t`, `pistol_atvive_ct`,\
			`primary_t`, `primary_ct`, `pistol_t`, `pistol_ct`, `flashbang`, `hegrenade`, `smokegrenade`, `c4`,\
			`defuser`, `nvgs`, `assaultsuit`)\
			VALUES ( '%s', '%d', '%d', '%d', '%d', '%s', '%s', '%s', '%s', '%d', '%d', '%d', '%d', '%d', '%d', '%d');",
			sSteam, SettingsInfo[client].bPrimaryActiveT, SettingsInfo[client].bPrimaryActiveCT, SettingsInfo[client].bPistolActiveT, SettingsInfo[client].bPistolActiveCT,
			SettingsInfo[client].sPrimaryT, SettingsInfo[client].sPrimaryCT, SettingsInfo[client].sPistolT, SettingsInfo[client].sPistolCT, SettingsInfo[client].iFlash,
			SettingsInfo[client].iHe, SettingsInfo[client].iSmoke, SettingsInfo[client].bC4, SettingsInfo[client].bDefuser, SettingsInfo[client].bNvgs, SettingsInfo[client].bAssaultsuit);

			hDatabase.Query(ClietnAddDB_Callback, sQuery, GetClientUserId(client));
		}
	}
}

public void ClietnAddDB_Callback(Database hDatabaseLocal, DBResultSet hResults, const char[] sError, any iUserID)
{
	if(sError[0])
	{
		LogError("ClietnAddDB_Callback: %s", sError); //
		return; //
	}
	//LogToFile(sFile, "Игрок [%N] успешно добавлен в базу данных!", GetClientOfUserId(iUserID));
}

void SaveSettings(int client)
{
	char sQuery[512], sSteam[32];
	GetClientAuthId(client, AuthId_Steam2, sSteam, sizeof(sSteam));
	FormatEx(sQuery, sizeof(sQuery), "UPDATE `vip_autogive_weapon` SET \
	`primary_atvive_t` = '%d', `primary_atvive_ct` = '%d', `pistol_atvive_t` = '%d', `pistol_atvive_ct` = '%d',\
	`primary_t` = '%s', `primary_ct` = '%s', `pistol_t` = '%s', `pistol_ct` = '%s', `flashbang` = '%d', `hegrenade` = '%d', `smokegrenade` = '%d', `c4` = '%d',\
	`defuser` = '%d', `nvgs` = '%d', `assaultsuit` = '%d'\
	WHERE `steam_id` = '%s';", SettingsInfo[client].bPrimaryActiveT, SettingsInfo[client].bPrimaryActiveCT, SettingsInfo[client].bPistolActiveT, SettingsInfo[client].bPistolActiveCT,
	SettingsInfo[client].sPrimaryT, SettingsInfo[client].sPrimaryCT, SettingsInfo[client].sPistolT, SettingsInfo[client].sPistolCT, SettingsInfo[client].iFlash,
	SettingsInfo[client].iHe, SettingsInfo[client].iSmoke, SettingsInfo[client].bC4, SettingsInfo[client].bDefuser, SettingsInfo[client].bNvgs, SettingsInfo[client].bAssaultsuit,
	sSteam);
	hDatabase.Query(SaveSettings_Callback, sQuery);
}

public void SaveSettings_Callback(Database hDatabaseLocal, DBResultSet hResults, const char[] sError, any iUserID)
{
	if(sError[0])
	{
		LogError("SaveSettings_Callback: %s", sError); //
		return; //
	}
}