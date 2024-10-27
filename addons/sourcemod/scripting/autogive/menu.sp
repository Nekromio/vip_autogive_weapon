void CreatMenu_AutoGiveWeapon(int client)
{
	Menu hMenu = new Menu(Menu_Base);

	hMenu.SetTitle("Меню АвтоОружия");

	char sItem[256];
	FormatEx(sItem, sizeof(sItem), "Выдавать основное оружие ? [T: %s| CT: %s]", SettingsInfo[client].bPrimaryActiveT ? "√" : "×", SettingsInfo[client].bPrimaryActiveCT ? "√" : "×");
	hMenu.AddItem("item1", sItem);
	
	FormatEx(sItem, sizeof(sItem), "Выдавать пистолет ? [T: %s| CT: %s]", SettingsInfo[client].bPistolActiveT ? "√" : "×", SettingsInfo[client].bPistolActiveCT ? "√" : "×");
	hMenu.AddItem("item2", sItem);

	FormatEx(sItem, sizeof(sItem), "Основное оружие [T: %s| CT: %s]", SettingsInfo[client].sPrimaryT[0] ? SettingsInfo[client].sPrimaryT : "×", SettingsInfo[client].sPrimaryCT[0] ? SettingsInfo[client].sPrimaryCT : "×");
	hMenu.AddItem("item3", sItem);

	FormatEx(sItem, sizeof(sItem), "Пистолет [T: %s| CT: %s]", SettingsInfo[client].sPistolT[0] ? SettingsInfo[client].sPistolT : "×", SettingsInfo[client].sPistolCT ? SettingsInfo[client].sPistolCT : "×");
	hMenu.AddItem("item4", sItem);

	FormatEx(sItem, sizeof(sItem), "Гранаты [%s]", SettingsInfo[client].iHe || SettingsInfo[client].iFlash || SettingsInfo[client].iSmoke ? "√" : "×");
	hMenu.AddItem("item5", sItem);

	FormatEx(sItem, sizeof(sItem), "Вторичное снаряжение [%s]", SettingsInfo[client].bDefuser || SettingsInfo[client].bNvgs || SettingsInfo[client].bAssaultsuit ? "√" : "×");
	hMenu.AddItem("item6", sItem);

	DisplayMenu(hMenu, client, 20);

	hTriePrimary = new StringMap();
	hTriePistol = new StringMap();
	for(int i; i < sizeof(sPrimaryListKey); i++)
	{
		hTriePrimary.SetString(sPrimaryListKey[i], sPrimaryListValue[i]);
		//PrintToChatAll("[%s]/[%s]", sTrieListKey[i], sPrimaryListValue[i]);
	}

	for(int i; i < sizeof(sPistolListKey); i++)
	{
		hTriePistol.SetString(sPistolListKey[i], sPistolListValue[i]);
	}
	
	/* char sValue[32];
	hTriePrimary.GetString("mp5navy", sValue, sizeof(sValue)); */
}

public int Menu_Base(Menu hMenu, MenuAction action, int client, int iItem)
{
    switch(action)
    {
		case MenuAction_End:
        {
            delete hMenu;
        }
		case MenuAction_Select:
        {
            switch(iItem)
    		{
				case 0:
				{
					CreatMenu_PrimaryActivity(client);
				}
				case 1:
				{
					CreatMenu_PistolActivity(client);
				}
				case 2:
				{
					CreatMenu_PrimaryEdit(client);
				}
				case 3:
				{
					CreatMenu_PistolEdit(client);
				}
				case 4:
				{
					CreatMenu_GrenadeEdit(client);
				}
				case 5:
				{
					CreatMenu_SecondaryEdit(client);
				}
			}
        }
	}
	return 0;
}

void CreatMenu_PrimaryActivity(int client)
{
	Menu hMenu = new Menu(Menu_Primary);
	hMenu.SetTitle("Выдать основную пуху?");

	char sItem[256];
	FormatEx(sItem, sizeof(sItem), "Террористы [%s]", SettingsInfo[client].bPrimaryActiveT == true ? "√" : "×");
	hMenu.AddItem("item1", sItem);
	
	FormatEx(sItem, sizeof(sItem), "Спецназ [%s]", SettingsInfo[client].bPrimaryActiveCT == true ? "√" : "×");
	hMenu.AddItem("item2", sItem);

	hMenu.ExitBackButton = true;

	hMenu.Display(client, 20);
}

public int Menu_Primary(Menu hMenu, MenuAction action, int client, int iItem)
{
    switch(action)
    {
		case MenuAction_End:
        {
            delete hMenu;
        }
		case MenuAction_Cancel:
        {
            if(iItem == MenuCancel_ExitBack)
            {
				CreatMenu_AutoGiveWeapon(client);
            }
        }
		case MenuAction_Select:
        {
            switch(iItem)
    		{
				case 0:
				{
					if(SettingsInfo[client].bPrimaryActiveT)
						SettingsInfo[client].bPrimaryActiveT = false;
					else
						SettingsInfo[client].bPrimaryActiveT = true;

					CreatMenu_PrimaryActivity(client);
				}
				case 1:
				{
					if(SettingsInfo[client].bPrimaryActiveCT)
						SettingsInfo[client].bPrimaryActiveCT = false;
					else
						SettingsInfo[client].bPrimaryActiveCT = true;

					CreatMenu_PrimaryActivity(client);
				}
			}
        }
	
	}
	return 0;
}

void CreatMenu_PistolActivity(int client)
{
	Menu hMenu = new Menu(Menu_Pistol);
	hMenu.SetTitle("Выдать пистолет?");

	char sItem[256];
	FormatEx(sItem, sizeof(sItem), "Террористы [%s]", SettingsInfo[client].bPistolActiveT == true ? "√" : "×");
	hMenu.AddItem("item1", sItem);
	
	FormatEx(sItem, sizeof(sItem), "Спецназ [%s]", SettingsInfo[client].bPistolActiveCT == true ? "√" : "×");
	hMenu.AddItem("item2", sItem);

	hMenu.ExitBackButton = true;

	DisplayMenu(hMenu, client, 20);
}

public int Menu_Pistol(Menu hMenu, MenuAction action, int client, int iItem)
{
    switch(action)
    {
		case MenuAction_End:
        {
            delete hMenu;
        }
		case MenuAction_Cancel:    // Меню было отменено
        {
            if(iItem == MenuCancel_ExitBack)    // Если игрок нажал кнопку "Назад"
            {
				CreatMenu_AutoGiveWeapon(client);
            }
        }
		case MenuAction_Select:
        {
            switch(iItem)
    		{
				case 0:
				{
					if(SettingsInfo[client].bPistolActiveT)
						SettingsInfo[client].bPistolActiveT = false;
					else
						SettingsInfo[client].bPistolActiveT = true;

					CreatMenu_PistolActivity(client);
				}
				case 1:
				{
					if(SettingsInfo[client].bPistolActiveCT)
						SettingsInfo[client].bPistolActiveCT = false;
					else
						SettingsInfo[client].bPistolActiveCT = true;

					CreatMenu_PistolActivity(client);
				}
			}
        }
	
	}
	return 0;
}

void CreatMenu_PrimaryEdit(int client)
{
	Menu hMenu = new Menu(Menu_PrimaryEdit);
	hMenu.SetTitle("Выбор основного");

	char sItem[256];
	FormatEx(sItem, sizeof(sItem), "Терры [%s]", SettingsInfo[client].sPrimaryT[0] ? SettingsInfo[client].sPrimaryT : "×");
	hMenu.AddItem("item1", sItem);

	FormatEx(sItem, sizeof(sItem), "Спецназ [%s]", SettingsInfo[client].sPrimaryCT[0] ? SettingsInfo[client].sPrimaryCT : "×");
	hMenu.AddItem("item1", sItem);

	hMenu.ExitBackButton = true;

	DisplayMenu(hMenu, client, 20);
}

public int Menu_PrimaryEdit(Menu hMenu, MenuAction action, int client, int iItem)
{
    switch(action)
    {
		case MenuAction_End:
        {
            delete hMenu;
        }
		case MenuAction_Cancel:
        {
            if(iItem == MenuCancel_ExitBack)
            {
				CreatMenu_AutoGiveWeapon(client);
            }
        }
		case MenuAction_Select:
        {
			switch(iItem)
			{
				case 0: CreatMenu_PrimaryEditT(client);
				case 1: CreatMenu_PrimaryEditCT(client);
			}
        }
	}
	return 0;
}

void CreatMenu_PrimaryEditT(int client)
{
	Menu hMenu = new Menu(Menu_PrimaryT);
	hMenu.SetTitle("Выбор основной пухи T");

	char sItem[256];

	for(int i; i < 20; i++)
	{
		FormatEx(sItem, sizeof(sItem), "Терры [%s]", sPrimaryListValue[i]);

		if(cvPrimary[i].BoolValue)
			hMenu.AddItem("item1", sItem);
		else
			hMenu.AddItem("item1", sItem, ITEMDRAW_DISABLED);
	}

	hMenu.ExitBackButton = true;

	DisplayMenu(hMenu, client, 20);
}

public int Menu_PrimaryT(Menu hMenu, MenuAction action, int client, int iItem)
{
    switch(action)
    {
		case MenuAction_End:
        {
            delete hMenu;
        }
		case MenuAction_Cancel:
        {
            if(iItem == MenuCancel_ExitBack)
            {
				CreatMenu_AutoGiveWeapon(client);
            }
        }
		case MenuAction_Select:
        {
			char sBuffer[32];
			FormatEx(sBuffer, sizeof(sBuffer), sPrimaryListKey[iItem]);
			SettingsInfo[client].sPrimaryT = sBuffer;
			CreatMenu_PrimaryEdit(client);
        }
	}
	return 0;
}

void CreatMenu_PrimaryEditCT(int client)
{
	Menu hMenu = new Menu(Menu_PrimaryCT);
	hMenu.SetTitle("Выбор основноЙ пухи CT");

	char sItem[256];

	for(int i; i < 20; i++)
	{
		FormatEx(sItem, sizeof(sItem), "Спецназ [%s]", sPrimaryListValue[i]);
		hMenu.AddItem("item1", sItem);
	}

	hMenu.ExitBackButton = true;

	DisplayMenu(hMenu, client, 20);
}

public int Menu_PrimaryCT(Menu hMenu, MenuAction action, int client, int iItem)
{
    switch(action)
    {
		case MenuAction_End:
        {
            delete hMenu;
        }
		case MenuAction_Cancel:
        {
            if(iItem == MenuCancel_ExitBack)
            {
				CreatMenu_AutoGiveWeapon(client);
            }
        }
		case MenuAction_Select:
        {
			char sBuffer[32];
			FormatEx(sBuffer, sizeof(sBuffer), sPrimaryListKey[iItem]);
			SettingsInfo[client].sPrimaryCT = sBuffer;
			CreatMenu_PrimaryEdit(client);
        }
	}
	return 0;
}

void CreatMenu_PistolEdit(int client)
{
	Menu hMenu = new Menu(Menu_PistolEdit);
	hMenu.SetTitle("Выбор пистолетов");

	char sItem[256];
	FormatEx(sItem, sizeof(sItem), "Терры [%s]", SettingsInfo[client].sPistolT[0] ? SettingsInfo[client].sPistolT : "×");
	hMenu.AddItem("item1", sItem);

	FormatEx(sItem, sizeof(sItem), "Спецназ [%s]", SettingsInfo[client].sPistolCT[0] ? SettingsInfo[client].sPistolCT : "×");
	hMenu.AddItem("item1", sItem);

	hMenu.ExitBackButton = true;

	DisplayMenu(hMenu, client, 20);
}

public int Menu_PistolEdit(Menu hMenu, MenuAction action, int client, int iItem)
{
    switch(action)
    {
		case MenuAction_End:
        {
            delete hMenu;
        }
		case MenuAction_Cancel:
        {
            if(iItem == MenuCancel_ExitBack)
            {
				CreatMenu_AutoGiveWeapon(client);
            }
        }
		case MenuAction_Select:
        {
			switch(iItem)
			{
				case 0: CreatMenu_PistolEditT(client);
				case 1: CreatMenu_PistolEditCT(client);
			}
        }
	
	}
	return 0;
}

void CreatMenu_PistolEditT(int client)
{
	Menu hMenu = new Menu(Menu_PistolT);
	hMenu.SetTitle("Выбор пистолета T");

	char sItem[256];

	for(int i; i < sizeof(sPistolListValue); i++)
	{
		FormatEx(sItem, sizeof(sItem), "Терры [%s]", sPistolListValue[i]);
		hMenu.AddItem("item1", sItem);
	}

	hMenu.ExitBackButton = true;

	DisplayMenu(hMenu, client, 20);
}

public int Menu_PistolT(Menu hMenu, MenuAction action, int client, int iItem)
{
    switch(action)
    {
		case MenuAction_End:
        {
            delete hMenu;
        }
		case MenuAction_Cancel:
        {
            if(iItem == MenuCancel_ExitBack)
            {
				CreatMenu_AutoGiveWeapon(client);
            }
        }
		case MenuAction_Select:
        {
			char sBuffer[32];
			FormatEx(sBuffer, sizeof(sBuffer), sPistolListKey[iItem]);
			SettingsInfo[client].sPistolT = sBuffer;
			CreatMenu_PistolEdit(client);
        }
	}
	return 0;
}

void CreatMenu_PistolEditCT(int client)
{
	Menu hMenu = new Menu(Menu_PistolCT);
	hMenu.SetTitle("Выбор пистолета CT");

	char sItem[256];

	for(int i; i < sizeof(sPistolListValue); i++)
	{
		FormatEx(sItem, sizeof(sItem), "Спецназ [%s]", sPistolListValue[i]);
		hMenu.AddItem("item1", sItem);
	}

	hMenu.ExitBackButton = true;

	DisplayMenu(hMenu, client, 20);
}

public int Menu_PistolCT(Menu hMenu, MenuAction action, int client, int iItem)
{
    switch(action)
    {
		case MenuAction_End:
        {
            delete hMenu;
        }
		case MenuAction_Cancel:
        {
            if(iItem == MenuCancel_ExitBack)
            {
				CreatMenu_AutoGiveWeapon(client);
            }
        }
		case MenuAction_Select:
        {
			char sBuffer[32];
			FormatEx(sBuffer, sizeof(sBuffer), sPistolListKey[iItem]);
			SettingsInfo[client].sPistolCT = sBuffer;
			CreatMenu_PistolEdit(client);
        }
	}
	return 0;
}

void CreatMenu_GrenadeEdit(int client)
{
	Menu hMenu = new Menu(Menu_GrenadeEdit);
	hMenu.SetTitle("Выбор кол-во гранат");

	char sItem[256];
	if(SettingsInfo[client].iHe)
		FormatEx(sItem, sizeof(sItem), "Гранаты [%d]", SettingsInfo[client].iHe);
	else	FormatEx(sItem, sizeof(sItem), "Гранаты [×]");
	hMenu.AddItem("item1", sItem);

	if(SettingsInfo[client].iFlash)
		FormatEx(sItem, sizeof(sItem), "Флешки [%d]", SettingsInfo[client].iFlash);
	else	FormatEx(sItem, sizeof(sItem), "Флешки [×]");
	hMenu.AddItem("item1", sItem);

	if(SettingsInfo[client].iSmoke)
		FormatEx(sItem, sizeof(sItem), "Дым [%d]", SettingsInfo[client].iSmoke);
	else	FormatEx(sItem, sizeof(sItem), "Дым [×]");
	hMenu.AddItem("item1", sItem);

	hMenu.ExitBackButton = true;

	DisplayMenu(hMenu, client, 20);
}

public int Menu_GrenadeEdit(Menu hMenu, MenuAction action, int client, int iItem)
{
    switch(action)
    {
		case MenuAction_End:
        {
            delete hMenu;
        }
		case MenuAction_Cancel:
        {
            if(iItem == MenuCancel_ExitBack)
            {
				CreatMenu_AutoGiveWeapon(client);
            }
        }
		case MenuAction_Select:
        {
			switch(iItem)
			{
				case 0:
				{
					SettingsInfo[client].iHe++;
					if(SettingsInfo[client].iHe > VIP_GetClientFeatureInt(client, g_sFeature[0]))
						SettingsInfo[client].iHe = 0;
				}
				case 1:
				{
					SettingsInfo[client].iFlash++;
					if(SettingsInfo[client].iFlash > VIP_GetClientFeatureInt(client, g_sFeature[1]))
						SettingsInfo[client].iFlash = 0;
				}
				case 2:
				{
					SettingsInfo[client].iSmoke++;
					if(SettingsInfo[client].iSmoke > VIP_GetClientFeatureInt(client, g_sFeature[2]))
						SettingsInfo[client].iSmoke = 0;
				}
			}
			CreatMenu_GrenadeEdit(client);
        }
	}
	return 0;
}

void CreatMenu_SecondaryEdit(int client)
{
	Menu hMenu = new Menu(Menu_Secondary);
	hMenu.SetTitle("Выбор вторичного");

	char sItem[256], sBuffer[8];
	
	int count;
	if(VIP_IsClientVIP(client) && VIP_IsClientFeatureUse(client, g_sFeatureC4))
		count = 23;
	else
		count = 24;
	for(int i = count; i < sizeof(sPrimaryListKey); i++)
	{
		switch(i)
		{
			case 23:
			{
				if(cvEnableC4.BoolValue)
				{
					FormatEx(sItem, sizeof(sItem), "[%s] -> [%s]", sPrimaryListValue[i], SettingsInfo[client].bC4 ? "√" : "×");
				}
				else
				{
					FormatEx(sItem, sizeof(sItem), "[%s] -> [%s] (%s)", sPrimaryListValue[i], SettingsInfo[client].bC4 ? "√" : "×", "Заблокировано");
				}
			}
			case 24: FormatEx(sItem, sizeof(sItem), "[%s] -> [%s]", sPrimaryListValue[i], SettingsInfo[client].bDefuser ? "√" : "×");
			case 25: FormatEx(sItem, sizeof(sItem), "[%s] -> [%s]", sPrimaryListValue[i], SettingsInfo[client].bNvgs ? "√" : "×");
			case 26: FormatEx(sItem, sizeof(sItem), "[%s] -> [%s]", sPrimaryListValue[i], SettingsInfo[client].bAssaultsuit ? "√" : "×");
		}	

		if(i == 23 && VIP_IsClientVIP(client) && VIP_IsClientFeatureUse(client, g_sFeatureC4))
		{
			if(!cvEnableC4.BoolValue)
			{
				hMenu.AddItem(sBuffer, sItem, ITEMDRAW_DISABLED);
			}
			else
			{
				hMenu.AddItem(sBuffer, sItem);
			}
		}
		else if(i != 23)
			hMenu.AddItem(sBuffer, sItem);
	}

	hMenu.ExitBackButton = true;

	DisplayMenu(hMenu, client, 20);
}

public int Menu_Secondary(Menu hMenu, MenuAction action, int client, int iItem)
{
    switch(action)
    {
		case MenuAction_End:
        {
            delete hMenu;
        }
		case MenuAction_Cancel:
        {
            if(iItem == MenuCancel_ExitBack)
            {
				CreatMenu_AutoGiveWeapon(client);
            }
        }
		case MenuAction_Select:
        {
			bool bSet = VIP_IsClientVIP(client) && VIP_IsClientFeatureUse(client, g_sFeatureC4);
			switch(iItem)
			{
				case 0:
				{
					if(bSet)
						CheckCvar(SettingsInfo[client].bC4);
					else
						CheckCvar(SettingsInfo[client].bDefuser);
				}
				case 1:
				{

					if(bSet)
						CheckCvar(SettingsInfo[client].bDefuser);
					else
						CheckCvar(SettingsInfo[client].bNvgs);
				}
				case 2:
				{
					if(bSet)
						CheckCvar(SettingsInfo[client].bNvgs);
					else
						CheckCvar(SettingsInfo[client].bAssaultsuit);
				}
				case 3:
				{
					if(bSet)
						CheckCvar(SettingsInfo[client].bAssaultsuit);
				}
			}
			CreatMenu_SecondaryEdit(client);
        }
	}
	return 0;
}

void CheckCvar(bool &bSetting)
{
	if(bSetting)
		bSetting = false;
	else
		bSetting = true;
}