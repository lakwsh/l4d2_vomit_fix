#include <sourcemod>

public Plugin myinfo = {
    name = "[L4D2] vomit fix",
    author = "lakwsh",
    version = "1.1.1"
};

public void Patch(Address func, Address time) {
    StoreToAddress(time + view_as<Address>(16), 0x3d088889, NumberType_Int32);
    StoreToAddress(func, 0xB8, NumberType_Int8);
    StoreToAddress(func + view_as<Address>(1), time, NumberType_Int32);
}

public void OnPluginStart() {
    GameData hGameData = new GameData("l4d2_vomit_fix");
    if(!hGameData) SetFailState("Failed to load 'l4d2_vomit_fix.txt' gamedata.");
    Address patch1 = hGameData.GetAddress("patch1");
    Address patch2 = hGameData.GetAddress("patch2");
    Address time = hGameData.GetAddress("frametime");
    CloseHandle(hGameData);
    if(!patch1) SetFailState("'vomit_fix' Signature broken.");
    Patch(patch1, time);
    if(patch2) Patch(patch2, time);
}