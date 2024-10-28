#include <sourcemod>

public Plugin myinfo = {
	name = "[L4D2] a2s fix",
	author = "lakwsh",
	version = "1.0.2"
}

public void Patch(Address ptr, bool isWin)
{
	if(isWin) {
		StoreToAddress(ptr, 0x9090, NumberType_Int16, true);
		return;
	}
	StoreToAddress(view_as<Address>(view_as<int>(ptr)+9), 0x90909090, NumberType_Int32, true);
	StoreToAddress(view_as<Address>(view_as<int>(ptr)+13), 0x9090, NumberType_Int16);
}

public void OnPluginStart()
{
	FindConVar("sv_enableoldqueries").IntValue = 1;
	GameData hGameData = new GameData("l4d2_a2s_fix");
	if(!hGameData) SetFailState("Failed to load 'l4d2_a2s_fix.txt' gamedata.");
	Address ptr = hGameData.GetMemSig("a2s_fix");
	bool isWin = !ptr;
	if(isWin) ptr = hGameData.GetAddress("a2s_fix_w");
	if(!ptr) SetFailState("'a2s_fix' Signature broken.");
	Patch(ptr, isWin);
	CloseHandle(hGameData);
}