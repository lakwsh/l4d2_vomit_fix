#pragma semicolon 1
#pragma newdecls required
#pragma tabsize 4

#include <sourcemod>

public Plugin myinfo =
{
	name = "[L4D2] vomit fix",
	author = "lakwsh, xiaolinRM",
	description = "Fixes abnormal Boomer vomit range at server tick rates other than 30.",
	version = "1.2.1",
	url = "https://github.com/lakwsh/l4d2_vomit_fix"
};

bool g_bEnabled;
Address g_iAddr1;
Address g_iAddr2;
int g_iInst1;
int g_iInst2;
int g_iInst3;
int g_iInst4;
any g_iValue;

ConVar z_vomit_drag;
ConVar z_vomit_velocity;
ConVar z_vomit_velocityfadestart;
ConVar z_vomit_velocityfadeend;

public void OnPluginStart()
{
	GameData hGameData = new GameData("l4d2_vomit_fix");
	if (!hGameData) SetFailState("Failed to load 'l4d2_vomit_fix.txt' gamedata.");

	g_iAddr1 = hGameData.GetMemSig("vomit_fix1");
	if (!g_iAddr1) SetFailState("Failed to load 'vomit_fix1' signature.");
	g_iInst1 = hGameData.GetOffset("vomit_inst1");
	if (g_iInst1 == -1) SetFailState("Failed to load 'vomit_inst1' offset.");
	g_iValue = LoadFromAddress(g_iAddr1 + view_as<Address>(1), NumberType_Int32);
	g_iInst2 = hGameData.GetOffset("vomit_inst2");
	g_iAddr2 = hGameData.GetMemSig("vomit_fix2");
	g_iInst3 = hGameData.GetOffset("vomit_inst3");
	g_iInst4 = hGameData.GetOffset("vomit_inst4");
	delete hGameData;

	EnablePatch(g_iAddr1, g_iInst1, g_iInst2);
	EnablePatch(g_iAddr2, g_iInst3, g_iInst4);
	g_bEnabled = true;

	z_vomit_drag = FindConVar("z_vomit_drag");
	z_vomit_velocity = FindConVar("z_vomit_velocity");
	z_vomit_velocityfadestart = FindConVar("z_vomit_velocityfadestart");
	z_vomit_velocityfadeend = FindConVar("z_vomit_velocityfadeend");
	SetConVar();
}

public void OnPluginEnd()
{
	if (!g_bEnabled) return;
	DisablePatch(g_iAddr1, g_iInst1, g_iInst2);
	DisablePatch(g_iAddr2, g_iInst3, g_iInst4);
	z_vomit_drag.RestoreDefault();
	z_vomit_velocity.RestoreDefault();
}

public void OnConfigsExecuted()
{
	SetConVar();
}

void EnablePatch(Address address, int inst1, int inst2)
{
	if (!address || inst1 == -1) return;
	// mov eax, pGlobals => mov eax, 1/30
	StoreToAddress(address, 0xB8, NumberType_Int8);
	StoreToAddress(address + view_as<Address>(1), 0x3D088889, NumberType_Int32);
	// movss xmm0, [eax+10h] => movd xmm0, eax
	StoreToAddress(address + view_as<Address>(inst1), 0xC06E0F66, NumberType_Int32);
	StoreToAddress(address + view_as<Address>(inst1 + 4), 0x90, NumberType_Int8);
	if (inst2 == -1) return;
	StoreToAddress(address + view_as<Address>(inst2), 0xC06E0F66, NumberType_Int32);
	StoreToAddress(address + view_as<Address>(inst2 + 4), 0x90, NumberType_Int8);
}

void DisablePatch(Address address, int inst1, int inst2)
{
	if (!address || inst1 == -1) return;
	StoreToAddress(address, 0xA1, NumberType_Int8);
	StoreToAddress(address + view_as<Address>(1), g_iValue, NumberType_Int32);
	StoreToAddress(address + view_as<Address>(inst1), 0x40100FF3, NumberType_Int32);
	StoreToAddress(address + view_as<Address>(inst1 + 4), 0x10, NumberType_Int8);
	if (inst2 == -1) return;
	StoreToAddress(address + view_as<Address>(inst2), 0x40100FF3, NumberType_Int32);
	StoreToAddress(address + view_as<Address>(inst2 + 4), 0x10, NumberType_Int8);
}

void SetConVar()
{
	float frametime = GetTickInterval();
	float fadetime = z_vomit_velocityfadestart.FloatValue + z_vomit_velocityfadeend.FloatValue;
	// Formula: z_vomit_drag = (tickrate/30)*(0.89/(1-0.89))/(1+(tickrate/30)*(0.89/(1-0.89)))
	z_vomit_drag.FloatValue = 0.89 / (0.89 + 3.3 * frametime);
	// Formula: z_vomit_velocity = 1700*tickrate*(30*(z_vomit_velocityfadestart+z_vomit_velocityfadeend)-1)/(30*(tickrate*(z_vomit_velocityfadestart+z_vomit_velocityfadeend)-1))
	z_vomit_velocity.FloatValue = 1700.0 * (30.0 * fadetime - 1.0) / (30.0 * (fadetime - frametime));
}
