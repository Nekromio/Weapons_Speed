#pragma semicolon 1
#pragma newdecls required

#include <sdkhooks>
	
KeyValues hKeyValues;

int
	iWeaponActive[MAXPLAYERS+1];

public Plugin myinfo = 
{
	name = "Weapons Speed",
	author = "Nek.'a 2x2 | ggwp.site",
	description = "Скорость с оружием",
	version = "1.4.1",
	url = "https://ggwp.site/"
}

public void OnPluginStart() 
{
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);

	char sPath[PLATFORM_MAX_PATH]; Handle hFile;
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/weapon_speed.ini");
	
	if(!FileExists(sPath))
	{
		hFile = OpenFile(sPath, "w");
		CloseHandle(hFile);
	} 
	
	hKeyValues = new KeyValues("weapon_speed");
	
	if(!hKeyValues.ImportFromFile(sPath))
		SetFailState("Не могу прочитать файл \"%s\"", sPath);
	
	hKeyValues.JumpToKey("Settings", true);
	
	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i)) OnClientPutInServer(i);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponSwitch, OnWeapon);
}

Action OnWeapon(int client, int weapon)
{
	iWeaponActive[client] = weapon;
	WeaponActive(client, iWeaponActive[client]);
	return Plugin_Changed;
}

void Event_PlayerSpawn(Event hEvent, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	if(IsClientInGame(client))
		WeaponActive(client, iWeaponActive[client]);
}

Action WeaponActive(int client, int weapon)
{
	char sClassName[64];
	GetEdictClassname(weapon, sClassName, sizeof(sClassName));

	if(strncmp(sClassName, "weapon_", 7))
		return Plugin_Continue;
	
	if(hKeyValues.JumpToKey(sClassName[7], false))
	{
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", hKeyValues.GetFloat("weapon_speed", 1.0));
		hKeyValues.GoBack();
	}
	else 
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	return Plugin_Changed;
}