#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

#include <sourcemod>

public Plugin myinfo =
{
	name = "[L4D2] a2s fix",
	author = "lakwsh, xiaolinRM",
	description = "Fixes an issue where players who have not passed Steam validation are missing from A2S information.",
	version = "1.1.0",
	url = "https://github.com/lakwsh/l4d2_vomit_fix"
}

bool g_bEnabled;
Address g_iAddress;
any g_iValue;

ConVar sv_enableoldqueries;

public void OnPluginStart()
{
	GameData hGameData = new GameData("l4d2_a2s_fix");
	if (!hGameData) SetFailState("Failed to load 'l4d2_a2s_fix.txt' gamedata.");

	g_iAddress = hGameData.GetMemSig("a2s_fix");
	if (!g_iAddress) SetFailState("Failed to load 'a2s_fix' signature.");
	g_iValue = LoadFromAddress(g_iAddress, NumberType_Int16);
	switch (hGameData.GetOffset("type"))
	{
		case -1: SetFailState("Failed to load 'type' offset.");
		case 0: StoreToAddress(g_iAddress, 0x9090, NumberType_Int16);
		case 1: StoreToAddress(g_iAddress, 0xEB, NumberType_Int8);
		case 2: StoreToAddress(g_iAddress, 0x04EB, NumberType_Int16);
		case 3: StoreToAddress(g_iAddress, 0xE990, NumberType_Int16);
		default: SetFailState("Invalid 'type' offset.");
	}
	delete hGameData;
	g_bEnabled = true;

	sv_enableoldqueries = FindConVar("sv_enableoldqueries");
	sv_enableoldqueries.BoolValue = true;
}

public void OnPluginEnd()
{
	if (!g_bEnabled) return;
	StoreToAddress(g_iAddress, g_iValue, NumberType_Int16);
	sv_enableoldqueries.RestoreDefault();
}

public void OnConfigsExecuted()
{
	sv_enableoldqueries.BoolValue = true;
}
