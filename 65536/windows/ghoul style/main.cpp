/*-------------------------------------------------------------------------------------

	Ghoul Style
	A old old old 64k style Intro.

	Astharoth - Estrayk. Code - Music

	Started:	Monday 14-Oct-2002

	Time Report and tasks:
		14-10-2002:  Port SND&MOD&H3D&VGS&MEM&MTH to tiny versions
		             Optimize (clean) Libctiny from Matt Pietrek
					 (6 hours)
		15-10-2002:  Spent some time correcting two bugs in the mod player.
					 Make the "window" cooperative for debug purposes.

		A brief resume of the last week... 28-10-2002 to 01-11-2002..
		Everything was coded in this week... this is a hell i need really sleep
		I'm now in the party.. i'll go to temporize a pair of effects and
		work on a demo made by the old style of party coding...

        EOF.
	



	Portions:
	Base libctiny by Matt Pietrek, Reduced and reassembled by Astharoth.
	Xsystem functions by Astharoth-Cranky-Hgh.

    Sorry for some spanish comments on the code.. 
	and sorry for my english too :)

--------------------------------------------------------------------------------------*/

//Main definitions.
//------------------
#include <windows.h>


//System Includes.
//---------------------
#include "system\xtypes.h"
#include "system\mem.h"
#include "system\vgs.h"
#include "system\snd.h"
#include "system\mod.h"
#include "system\h3d.h"
#include "system\o3d.h"
#include "system\mth.h"
#include "system\gfx.h"
#include "system\vti.h"


//Data
//---------------------------
#include "data\mod.h"
#include "data\cred01.h"
#include "data\cred02.h"
#include "data\cred03.h"
#include "data\cred04.h"
#include "data\title.h"
#include "data\bloody.h"
#include "data\ojo.h"
#include "data\lapida.h"
#include "data\tierra.h"
#include "data\nubes.h"
#include "data\gret01.h"
#include "data\gret02.h"
#include "data\gret03.h"
#include "data\gret04.h"
#include "data\gret05.h"
#include "data\gret06.h"
#include "data\url.h"


//External data
//-------------
extern BOOL EscPressed;
extern DWORD VGS_ClearColor;
extern unsigned char MOD_Row;
extern unsigned char MOD_Order;


#define NUM_PANELS 100
DWORD	hPanel;		//HAndle al objeto Panel.
float	PanelPos[NUM_PANELS][3];
DWORD	PanelRot[NUM_PANELS][3];
DWORD	hTexture;	//Handle a la textura.

Vector3 LapidasPos[2350];
DWORD Count = 0;


//Definiciones para nuestra curva.
#define KEY_POINTS	50
#define PRECISION	25
#define RES_POINTS	(KEY_POINTS-2)*PRECISION
Vector3	Key[KEY_POINTS];
Vector3	Res[RES_POINTS]; 
Vector3	ResRot[RES_POINTS]; 

//Paneles
#define MAXPANELS 100

//Genera puntos de control aleatorios.
//----------------------------------------
void MakeKey(Vector3 *Vtx,DWORD NumLineas,int Dist)
{
	DWORD ind;
	for(ind=0;ind<NumLineas;ind++)
	{
		Vtx[ind].x = (float)(-32+64*XMTH_Rnd () / 65535.0f);
		Vtx[ind].y = (float)(-32+64*XMTH_Rnd () / 65535.0f);
		Vtx[ind].z = (float)(-Dist+64*XMTH_Rnd ()/ 65535.0f);;
	}
}

void MakeKey2(Vector3 *Vtx,DWORD NumLineas,int Dist)
{
	DWORD ind;
	for(ind=0;ind<NumLineas;ind++)
	{
		Vtx[ind].x = (float)(-32+64*XMTH_Rnd () / 65535.0f) *Dist;
		Vtx[ind].y = (float)(-32+64*XMTH_Rnd () / 65535.0f) *Dist;
		Vtx[ind].z = (float)(-32+64*XMTH_Rnd ()/ 65535.0f) *Dist;;
	}
}
void MakeKey3(Vector3 *Vtx,DWORD NumLineas,int Dist)
{
	DWORD ind;
	for(ind=0;ind<NumLineas;ind++)
	{
		Vtx[ind].x = (float)(-32+64*XMTH_Rnd () / 65535.0f) *Dist;
		Vtx[ind].y = 10.0f;
		Vtx[ind].z = (float)(-32+64*XMTH_Rnd ()/ 65535.0f) *Dist;;
	}
}


DWORD LoadTexture(LPVOID Source,DWORD Width,DWORD Height,BYTE Alpha)
{
	DWORD hTexture;
	DWORD MemSize;
	LPVOID	TempGfx;
	LPVOID	TempClut;
	LPVOID	TextureGfx;
	MemSize = (Width*Height);
	TextureGfx = XMEM_GetMem(MemSize*4);
	TempGfx = XMEM_GetMem(MemSize);
	TempClut = XMEM_GetMem(768);
	XGFX_DecodePcxFile(Source,TempGfx,TempClut);
	XGFX_ConvertData(TempGfx,TempClut,TextureGfx,MemSize,Alpha);
	XMEM_FreeMem(TempClut,768);
	XMEM_FreeMem(TempGfx,MemSize);
	hTexture = XH3D_LoadTexture(TextureGfx,Width,Height);
	XMEM_FreeMem(TextureGfx,(MemSize*4));
	return hTexture;
}
DWORD LoadTextureBW(LPVOID Source,DWORD Width,DWORD Height,BYTE Alpha)
{
	DWORD hTexture;
	DWORD MemSize;
	DWORD a,b;
	LPVOID	TempGfx;
	BYTE*	TempClut,*TempClut2;
	LPVOID	TextureGfx;
	MemSize = (Width*Height);
	TextureGfx = XMEM_GetMem(MemSize*4);
	TempClut = (BYTE*)XMEM_GetMem(768);
	TempClut2 = TempClut;
	for (a=0;a != 64;a++)
	{
		*(TempClut2+0) = a; 
		*(TempClut2+1) = a;
		*(TempClut2+2) = a;
		*(TempClut2+3) = a;
		*(TempClut2+4) = a;
		*(TempClut2+5) = a;
		*(TempClut2+6) = a;
		*(TempClut2+7) = a;
		*(TempClut2+8) = a;
		*(TempClut2+9) = a;
		*(TempClut2+10) = a;
		*(TempClut2+11) = a;
		TempClut2 += 12;
	}
	XGFX_ConvertData(Source,TempClut,TextureGfx,MemSize,Alpha);
	XMEM_FreeMem(TempClut,768);
	hTexture = XH3D_LoadTexture(TextureGfx,Width,Height);
	XMEM_FreeMem(TextureGfx,(MemSize*4));
	return hTexture;
}


void InitPaneles()
{
	hPanel = XO3D_CreatePlane(22.0f,22.0f);

	//Vamos a generar algo decente con los paneles... :)
	DWORD Oa = 0;
	DWORD InDepth = 0;
	for (int i = 0; i != NUM_PANELS; i++)
	{
		InDepth += 32;
		PanelPos[i][0] = (XMTH_GetCosinus(Oa)*(50*XMTH_GetCosinus(InDepth)));
		PanelPos[i][2] = (XMTH_GetSinus(Oa)*(50*XMTH_GetCosinus(InDepth)));
		PanelPos[i][1] = (i-(NUM_PANELS/2))*2;
		Oa += 64;
		PanelRot[i][0] = 384;
		PanelRot[i][1] = Oa; 
		PanelRot[i][2] = 128;
	}
	//Generamos puntos aleatorios.
	MakeKey(Key,KEY_POINTS,48);
	//Generamos una spline a partir de esos puntos.
	XMTH_MakeBspline(Key,KEY_POINTS,Res,PRECISION);

}

inline float VELTUNEL(void) {
	return ((float)XMTH_RndDWord() / 50000.0f) + 2.5f;
}


void DoPaneles()
{
	DWORD i;
	for (i = 0; i != NUM_PANELS; i++)
	{
		XO3D_SetObjectAngles(hPanel,PanelRot[i][0],PanelRot[i][1],PanelRot[i][2]);
		XO3D_SetObjectPosition(hPanel,PanelPos[i][0],PanelPos[i][1],PanelPos[i][2]);
		XO3D_DrawAllObject(hPanel,TRN_ROTATE | TRN_TRANSLATE);
	}
}

DWORD Index = 0;
void PanelesTimer()
{
	Index++;
	if (Index > (KEY_POINTS-2)*PRECISION)
		Index = 0;

}

DWORD g,h,i;
void CuboTimer()
{
	g+=4;h+=8;i+=16;
}


DWORD jos = 0;
float NinaYPos = 0.0f;
void NinaTimer()
{
	if (MOD_Row >=59)
	{
		NinaYPos -= 2.2f;
	}
	if ( (MOD_Row == 8) || (MOD_Row == 16) ||
		 (MOD_Row == 24) || (MOD_Row == 32) ||
		 (MOD_Row == 40) || (MOD_Row == 48) )
		if (jos < 20)
			jos++;
	if ( (MOD_Row == 9) || (MOD_Row == 17) ||
		 (MOD_Row == 25) || (MOD_Row == 33) ||
		 (MOD_Row == 41) || (MOD_Row == 49) )
		if (jos > 0)
			jos--;
}

Vector3	hPosTunel[MAXPANELS];
DWORD	TunelAngle[MAXPANELS];
DWORD	a;
float	hVelTunel[MAXPANELS];
CRITICAL_SECTION cs;
void TunelTimer()
{
	EnterCriticalSection(&cs);
	for (a = 0; a != MAXPANELS; a++)
	{
		hPosTunel[a].z -= hVelTunel[a]+2;

		if (hPosTunel[a].z < -80)
		{
			TunelAngle[a] = XMTH_RndDWord();
			hPosTunel[a].z = 250.0f;
			hVelTunel[a] = VELTUNEL()*2; 
			hPosTunel[a].x = 26.0f * XMTH_GetCosinus(TunelAngle[a]);
			hPosTunel[a].y = 26.0f * XMTH_GetSinus(TunelAngle[a]);
			TunelAngle[a] = 384-TunelAngle[a];
		}
	}
	if ( (MOD_Row == 0) || (MOD_Row == 6) ||
		 (MOD_Row == 16) || (MOD_Row == 22) ||
		 (MOD_Row == 30) || (MOD_Row == 38) ||
		 (MOD_Row == 48) || (MOD_Row == 54) )
		Index+=5;
	Index++;
	if (Index > (KEY_POINTS-2)*PRECISION)
		Index = 0;
	LeaveCriticalSection(&cs);
}

void FincasTimer()
{
	Index++;
	if (Index > (KEY_POINTS-2)*PRECISION)
		Index = 0;
	if ( (MOD_Row == 0) || (MOD_Row == 6) ||
		 (MOD_Row == 16) || (MOD_Row == 22) ||
		 (MOD_Row == 30) || (MOD_Row == 38) ||
		 (MOD_Row == 48) || (MOD_Row == 54) )
		Index+=5;
}


#define XEDIFICIOS 20
#define YEDIFICIOS 20
#define SPACING (200.0f+(XMTH_Rnd()/1000))
Vector3 BuildingPos[XEDIFICIOS*YEDIFICIOS];
DWORD Counter = 0;
Vector3 LineDest[200];
Vector3 LineDest2[200];


//Main entry point.
//---------------------------------------------------------------------------------------------
int APIENTRY WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,LPSTR lpCmdLine,int nCmdShow)
{
	InitializeCriticalSection(&cs);
	//System initialization
	XMEM_InitHeap(MEGABYTE*40);
	XVGS_StartGraphics(hInstance,nCmdShow);
	XSND_InitSound();
	XMOD_Init();
	XMOD_LoadMemoryMod((char*)mod);
	XH3D_Init();
	XMTH_Init();
	XO3D_InitCache(10000);

	
	DWORD hTexture01 = LoadTexture(cred01,64,32,0xff);
	DWORD hTexture02 = LoadTexture(cred02,64,32,0xff);
	DWORD hTexture03 = LoadTexture(cred03,64,32,0xff);
	DWORD hTexture04 = LoadTexture(cred04,64,32,0xff);
	DWORD hTitle = LoadTexture(title,64,32,0xff);
	DWORD hBloody = LoadTexture(bloody,128,64,0xff);
	DWORD hBloody2 = LoadTexture(bloody,128,64,0x60);
	DWORD hNiebla = LoadTextureBW(bloody,64,64,0x0);

	XH3D_SetZBufferState(FALSE);
	XH3D_SetCullingState(false,false);
	
	InitPaneles();
	XO3D_SetMaterialColored(hPanel,0,STP_NONE,0,0,0);	


	XMOD_PlayMusic();

	XVTI_TimerRoutine(PanelesTimer);
	while(!EscPressed)
	{
		DoPaneles();
		if ((MOD_Row == 32) && (MOD_Order == 0))
			XO3D_SetMaterialTextured(hPanel,0,STP_GLENZ,hTexture01,NULL);
		if ((MOD_Row == 32) && (MOD_Order == 1))
			XO3D_SetMaterialTextured(hPanel,0,STP_GLENZ,hTexture02,NULL);
		if ((MOD_Row == 32) && (MOD_Order == 2))
			XO3D_SetMaterialTextured(hPanel,0,STP_GLENZ,hTexture03,NULL);
		if ((MOD_Row == 32) && (MOD_Order == 3))
			XO3D_SetMaterialTextured(hPanel,0,STP_GLENZ,hTexture04,NULL);
		if ((MOD_Row == 0) && (MOD_Order == 4))
			break;
		XVGS_RenderScene();
		Vector3 Camara;
		Vector3 ViewAt={0.0f,0.0f,1.0f};
		Camara.x = Res[Index].x;
		Camara.y = Res[Index].y;
		Camara.z = Res[Index].z;
		ViewAt.x = 0 - Camara.x;
		ViewAt.y = -1.0f - Camara.y;
		ViewAt.z = 40.0f - Camara.z;
		if (MOD_Row == 32)
		{
			float dist1 = XMTH_Rnd() & 127;
			float dist2 = XMTH_Rnd() & 127;
			XH3D_SetProyectionParams(1.0f,3000.0f,dist1,dist2);
		}
		else
			XH3D_SetProyectionParams(1.0f,3000.0f,45.0f,45.0f);
		XH3D_SetCameraPosition(&Camara,&ViewAt,NULL);
	}
	
	VGS_ClearColor = 0xffffff;
	XVGS_RenderScene();
	XVGS_RenderScene();
	XVGS_RenderScene();
	XVGS_RenderScene();
	Sleep(100);
	DWORD hFondo = XO3D_CreatePlane(3050.0f,3050.0f);
	DWORD hPanel2 = XO3D_CreatePlane(20.0f,20.0f);
	DWORD hTv = XO3D_CreatePlane(110.0f,110.0f);
	DWORD hTv2 = XO3D_CreatePlane(110.0f,110.0f);
	XO3D_SetMaterialTextured(hTv,0,STP_ALPHATEXT,hNiebla,NULL);
	XO3D_SetMaterialTextured(hTv2,0,STP_ALPHATEXT,hNiebla,NULL);
	XO3D_SetMaterialTextured(hFondo,0,STP_NONE,hBloody,NULL);
	XO3D_SetMaterialTextured(hPanel,0,STP_GLENZ,hTitle,NULL);
	XO3D_SetMaterialTextured(hPanel2,0,STP_ALPHATEXT,hBloody2,NULL);
	MakeKey(Key,KEY_POINTS,128);
	//Generamos una spline a partir de esos puntos.
	XMTH_MakeBspline(Key,KEY_POINTS,Res,PRECISION);
	VGS_ClearColor = 0;


	//Generamos un segmento.
	for (a = 0; a != MAXPANELS; a++)
	{
		TunelAngle[a] = XMTH_RndDWord();
		hPosTunel[a].z = XMTH_RndDWord() & 255;
		hVelTunel[a] = VELTUNEL();
		hPosTunel[a].x = 26.0f * XMTH_GetCosinus(TunelAngle[a]);
		hPosTunel[a].y = 26.0f * XMTH_GetSinus(TunelAngle[a]);
		TunelAngle[a] = 384-TunelAngle[a];
//		hAngTunel[
	}
	XH3D_SetZBufferState(FALSE);
	DWORD AlphaNiebla = 0;
	BOOL ToAlpha = FALSE;
	XVTI_TimerRoutine(TunelTimer);
	while(!EscPressed)
	{
		XO3D_SetObjectPosition(hFondo,1000.0f,800.0f,800.0f);
		XO3D_SetObjectAngles(hFondo,128,0,384);
		XO3D_DrawAllObject(hFondo,TRN_TRANSLATE | TRN_ROTATE);
		XO3D_SetObjectPosition(hPanel,0.0f,0.0f,-50.0f);
		XO3D_SetObjectAngles(hPanel,128,0,384);
		XO3D_DrawAllObject(hPanel,TRN_TRANSLATE | TRN_ROTATE);
		EnterCriticalSection(&cs);
		for (a = 0; a != MAXPANELS; a++)
		{
			XO3D_SetObjectAngles(hPanel2,TunelAngle[a],128,384); //
			XO3D_SetObjectPosition(hPanel2,hPosTunel[a].x,hPosTunel[a].y,hPosTunel[a].z);
			XO3D_DrawAllObject(hPanel2,TRN_TRANSLATE | TRN_ROTATE);
		}
		LeaveCriticalSection(&cs);
		if ((MOD_Order >= 5) && (MOD_Row >=57))
			ToAlpha = TRUE;
		if (ToAlpha)
		{
			XO3D_CopyObject(hTv,hTv2);
			XO3D_SetObjectPosition(hTv2,0.0f,0.0f,0.0f);
			XO3D_SetObjectAngles(hTv2,128,0,384);
			float u,v;
			u = (XMTH_Rnd() & 255);
			u /= 128;
			v = (XMTH_Rnd() & 255);
			v /= 128;
			XO3D_ModifyMappingRandom(hTv2,u,v);
			XO3D_DrawAllObject(hTv2,TRN_TRANSLATE | TRN_ROTATE);		
			XH3D_SetAlphaLevelTexture(hNiebla,AlphaNiebla);
			if (AlphaNiebla < 0xff)
				AlphaNiebla+=8;
			else
				AlphaNiebla = 0xff;
		}
		XVGS_RenderScene();
		Vector3 Camara;
		Vector3 ViewAt={0.0f,0.0f,1.0f};
		Camara.x = Res[Index].x;
		Camara.y = Res[Index].y;
		Camara.z = Res[Index].z;
		ViewAt.x = 0 - Camara.x;
		ViewAt.y = -1.0f - Camara.y;
		ViewAt.z = 40.0f - Camara.z;
		if ( ((MOD_Order == 8) && (MOD_Row >=24) && (MOD_Row <= 26)) ||
			((MOD_Order == 9) && (MOD_Row >=24) && (MOD_Row <= 26)) ||
			((MOD_Order == 9) && (MOD_Row >=28) && (MOD_Row <= 30)) ||
			 ((MOD_Order == 8) && (MOD_Row >=28) && (MOD_Row <= 30)) )
		{
			float dist1 = XMTH_Rnd() & 127;
			float dist2 = XMTH_Rnd() & 127;
			XH3D_SetProyectionParams(1.0f,3000.0f,dist1,dist2);
		}
		else
			XH3D_SetProyectionParams(1.0f,3000.0f,45.0f,45.0f);
		XH3D_SetCameraPosition(&Camara,&ViewAt,NULL);
		if ( (MOD_Order >= 6) && (MOD_Row >=14)) 
			break;
	}


	float xedi,yedi;
	for (yedi = -SPACING*(YEDIFICIOS/2); yedi < SPACING*(YEDIFICIOS/2); yedi += SPACING )
	{
		for (xedi = -SPACING*(XEDIFICIOS/2); xedi < SPACING*(XEDIFICIOS/2); xedi += SPACING )
		{
			
			BuildingPos[Counter].x = xedi;
			BuildingPos[Counter].z = yedi+500.0f;
			BuildingPos[Counter].y = -80.0f;
			Counter++;
		}
	}
	XH3D_SetZBufferState(TRUE);
	XH3D_SetCullingState(true,true);
	XH3D_SetFog(0x700000,120.0f,800.0f);
	XH3D_EnableFog();

	XH3D_SetProyectionParams(1.0f,2000.0f,80.0f,80.0f);

	MakeKey2(Key,KEY_POINTS,10);
	Key[0].x = 0.0f;
	Key[0].y = 0.0f;
	Key[0].z = 130.0f;
	Key[1].x = 0.0f;
	Key[1].y = 0.0f;
	Key[1].z = 120.0f;
	Key[2].x = 0.0f;
	Key[2].y = 0.0f;
	Key[2].z = 110.0f;
	Key[3].x = 0.0f;
	Key[3].y = 0.0f;
	Key[3].z = 100.0f;


	//Generamos una spline a partir de esos puntos.
	XMTH_MakeBspline(Key,KEY_POINTS,Res,PRECISION);
	
	DWORD hOjo = LoadTexture(ojo,32,32,0xff);

	DWORD hFinca[100];
	for (Index = 0; Index !=100; Index++)
	{
		hFinca[Index] = XO3D_CreateCube(30.0f+((XMTH_Rnd()/5000)-6),30.0f+((XMTH_Rnd()/5000)-6),200.0f+(XMTH_Rnd()/1000));
		XO3D_SetMaterialTextured(hFinca[Index],0,STP_NONE,hOjo,NULL);
	}
	Index = 0;
	//XO3D_RecalcNormals(hFinca,TRUE);
	//XO3D_SetMaterialColored(hFinca,0,STP_NONE,0xFFFFF,0xFFFFFF,0xFFFFFF);

	AlphaNiebla = 0xff;
	Vector3 Camara;
	Vector3 ViewAt;
	Camara.x = Res[Index].x;
	Camara.y = Res[Index].y;
	Camara.z = Res[Index].z;
	ViewAt.x = Res[Index].x-Res[Index+1].x;
	ViewAt.y = Res[Index].y-Res[Index+1].y;
	ViewAt.z = Res[Index].z-Res[Index+1].z;
	XH3D_SetCameraPosition(&Camara,&ViewAt,NULL);
	XVTI_TimerRoutine(FincasTimer);
	while(!EscPressed)
	{
		
		//Renderizamos la escena.
		for (Counter = 0; Counter != XEDIFICIOS*YEDIFICIOS; Counter++)
		{
			DWORD pol = ( XMTH_Rnd() / 660);
			XO3D_SetObjectAngles(hFinca[pol],0,384,0);
			XO3D_SetObjectPosition (hFinca[pol],BuildingPos[Counter].x,BuildingPos[Counter].y,BuildingPos[Counter].z);
			XO3D_DrawAllObject(hFinca[pol], TRN_ROTATE | TRN_TRANSLATE);
		}

		XO3D_CopyObject(hTv,hTv2);
		XO3D_SetObjectPosition(hTv2,0.0f,0.0f,70.0f);
		XO3D_SetObjectAngles(hTv2,128,0,384);
		float u,v;
		u = (XMTH_Rnd() & 255);
		u /= 128;
		v = (XMTH_Rnd() & 255);
		v /= 128;
		XO3D_ModifyMappingRandom(hTv2,u,v);
		XO3D_DrawAllObject(hTv2,TRN_TRANSLATE | TRN_ROTATE);		
		XH3D_SetAlphaLevelTexture(hNiebla,AlphaNiebla);
		if (AlphaNiebla > 0x3f)
		{
			AlphaNiebla-=8;
			Vector3 Camara;
			Vector3 ViewAt;
			Camara.x = Res[Index].x;
			Camara.y = Res[Index].y;
			Camara.z = Res[Index].z;
			ViewAt.x = Res[Index].x-Res[Index+1].x;
			ViewAt.y = Res[Index].y-Res[Index+1].y;
			ViewAt.z = Res[Index].z-Res[Index+1].z;
			XH3D_SetCameraPosition(&Camara,&ViewAt,NULL);
		}
		else
		{
			AlphaNiebla = 0x3f;
			Vector3 Camara;
			Vector3 ViewAt;
			Camara.x = Res[Index].x;
			Camara.y = Res[Index].y;
			Camara.z = Res[Index].z;
			ViewAt.x = Res[Index].x-Res[Index+1].x;
			ViewAt.y = Res[Index].y-Res[Index+1].y;
			ViewAt.z = Res[Index].z-Res[Index+1].z;
			XH3D_SetCameraPosition(&Camara,&ViewAt,NULL);
		}
		if ( ((MOD_Order == 8) && (MOD_Row >=24) && (MOD_Row <= 26)) ||
			((MOD_Order == 9) && (MOD_Row >=24) && (MOD_Row <= 26)) ||
			((MOD_Order == 9) && (MOD_Row >=28) && (MOD_Row <= 30)) ||
			 ((MOD_Order == 8) && (MOD_Row >=28) && (MOD_Row <= 30)) )
		{
			float dist1 = XMTH_Rnd() & 255;
			float dist2 = XMTH_Rnd() & 255;
			XH3D_SetProyectionParams(1.0f,3000.0f,dist1,dist2);
		}
		else
			XH3D_SetProyectionParams(1.0f,3000.0f,80.0f,80.0f);
		if ((MOD_Order == 8) && (MOD_Row >=30))
			break;
		XVGS_RenderScene();
	}

	DWORD hCubo = XO3D_CreateCube(20.0f,20.0f,20.0f);
	DWORD hCubo2 = XO3D_CreateCube(20.0f,20.0f,20.0f);
	XO3D_SetMaterialTextured(hCubo,0,STP_GLENZ,hOjo,NULL);
	Camara.x = 0.0f;
	Camara.y = 0.0f;
	Camara.z = 40.0f;
	ViewAt.x = 0.0f;
	ViewAt.y = 0.0f;
	ViewAt.z = 1.0f;
	XH3D_SetCameraPosition(&Camara,&ViewAt,NULL);
	XH3D_SetCullingState(false,true);
	DWORD j,k,l;
	XVTI_TimerRoutine(CuboTimer);
	while(!EscPressed)
	{
		float ScaleFactor;
		j = g; k = h; l = i;
		for (DWORD p=0; p != 3; p++)
		{	
			
			ScaleFactor = p;
			ScaleFactor += (XMTH_Rnd() / 65536);
			XO3D_CopyObject(hCubo,hCubo2);
			XO3D_ScaleObject(hCubo2,ScaleFactor);
			XO3D_SetObjectAngles(hCubo2,j,k,l);
			XO3D_SetObjectPosition (hCubo2,0.0f,0.0f,0.0f);
			XO3D_DrawAllObject(hCubo2, TRN_ROTATE);
			j++;k+=2;l+=4;
		}
		if ( (MOD_Row == 0) || (MOD_Row == 6) ||
			 (MOD_Row == 16) || (MOD_Row == 22) ||
			 (MOD_Row == 30) || (MOD_Row == 38) ||
			 (MOD_Row == 48) || (MOD_Row == 54) )
			Index+=5;
		if ( ((MOD_Order == 8) && (MOD_Row >=24) && (MOD_Row <= 26)) ||
			((MOD_Order == 9) && (MOD_Row >=24) && (MOD_Row <= 26)) ||
			((MOD_Order == 9) && (MOD_Row >=28) && (MOD_Row <= 30)) ||
			 ((MOD_Order == 8) && (MOD_Row >=28) && (MOD_Row <= 30)) )
		{
			float dist1 = XMTH_Rnd() & 255;
			float dist2 = XMTH_Rnd() & 255;
			XH3D_SetProyectionParams(1.0f,3000.0f,dist1,dist2);
		}
		else
			XH3D_SetProyectionParams(1.0f,3000.0f,80.0f,80.0f);
		if ((MOD_Order == 9) && (MOD_Row >=30))
			break;
		XVGS_RenderScene();
	}
	XH3D_SetCullingState(true,true);
	//XVTI_EndTimer();
	XVTI_TimerRoutine(FincasTimer);
	while(!EscPressed)
	{
		
		//Renderizamos la escena.
		for (Counter = 0; Counter != XEDIFICIOS*YEDIFICIOS; Counter++)
		{
			DWORD pol = ( XMTH_Rnd() / 660);
			XO3D_SetObjectAngles(hFinca[pol],0,384,0);
			XO3D_SetObjectPosition (hFinca[pol],BuildingPos[Counter].x,BuildingPos[Counter].y,BuildingPos[Counter].z);
			XO3D_DrawAllObject(hFinca[pol], TRN_ROTATE);
		}

		XO3D_CopyObject(hTv,hTv2);
		XO3D_SetObjectPosition(hTv2,0.0f,0.0f,70.0f);
		XO3D_SetObjectAngles(hTv2,128,0,384);
		float u,v;
		u = (XMTH_Rnd() & 255);
		u /= 128;
		v = (XMTH_Rnd() & 255);
		v /= 128;
		XO3D_ModifyMappingRandom(hTv2,u,v);
		XO3D_DrawAllObject(hTv2,TRN_TRANSLATE | TRN_ROTATE);		
		XH3D_SetAlphaLevelTexture(hNiebla,AlphaNiebla);
		if (AlphaNiebla > 0x3f)
		{
			AlphaNiebla-=8;
			Vector3 Camara;
			Vector3 ViewAt;
			Camara.x = Res[Index].x;
			Camara.y = Res[Index].y;
			Camara.z = Res[Index].z;
			ViewAt.x = Res[Index].x-Res[Index+1].x;
			ViewAt.y = Res[Index].y-Res[Index+1].y;
			ViewAt.z = Res[Index].z-Res[Index+1].z;
			XH3D_SetCameraPosition(&Camara,&ViewAt,NULL);
		}
		else
		{
			AlphaNiebla = 0x3f;
			Vector3 Camara;
			Vector3 ViewAt;
			Camara.x = Res[Index].x;
			Camara.y = Res[Index].y;
			Camara.z = Res[Index].z;
			ViewAt.x = Res[Index].x-Res[Index+1].x;
			ViewAt.y = Res[Index].y-Res[Index+1].y;
			ViewAt.z = Res[Index].z-Res[Index+1].z;
			XH3D_SetCameraPosition(&Camara,&ViewAt,NULL);
		}
		if ( ((MOD_Order == 8) && (MOD_Row >=24) && (MOD_Row <= 26)) ||
			((MOD_Order == 9) && (MOD_Row >=24) && (MOD_Row <= 26)) ||
			((MOD_Order == 9) && (MOD_Row >=28) && (MOD_Row <= 30)) ||
			 ((MOD_Order == 8) && (MOD_Row >=28) && (MOD_Row <= 30)) )
		{
			float dist1 = XMTH_Rnd() & 255;
			float dist2 = XMTH_Rnd() & 255;
			XH3D_SetProyectionParams(1.0f,3000.0f,dist1,dist2);
		}
		else
			XH3D_SetProyectionParams(1.0f,3000.0f,80.0f,80.0f);
		if (MOD_Order == 10)
			break;
		XVGS_RenderScene();
	}

	DWORD hNina = XO3D_CreatePlane(50.0f,50.0f);
	XO3D_SetMaterialTextured(hNina,0,STP_ALPHATEXT,hBloody2,NULL);
	Camara.x = 0.0f;
	Camara.y = 0.0f;
	Camara.z = 28.0f;
	ViewAt.x = 0.0f;
	ViewAt.y = 0.0f;
	ViewAt.z = 1.0f;
	XH3D_SetCameraPosition(&Camara,&ViewAt,NULL);
	XH3D_SetCullingState(false,true);
	XVTI_TimerRoutine(NinaTimer);
	while(!EscPressed)
	{
		XO3D_SetObjectPosition(hPanel,0.0f,NinaYPos,0.0f);
		XO3D_SetObjectAngles(hPanel,128,256,384);
		XO3D_DrawAllObject(hPanel,TRN_TRANSLATE | TRN_ROTATE);
		
		XO3D_SetObjectPosition(hNina,0.0f,NinaYPos,0.0f);
		XO3D_SetObjectAngles(hNina,128,0,384);
		XO3D_DrawAllObject(hNina,TRN_TRANSLATE | TRN_ROTATE);
		for (DWORD ji = 1; ji < jos; ji++)
		{
			XO3D_SetObjectPosition(hNina,0.0f,NinaYPos,ji);
			XO3D_SetObjectAngles(hNina,128,0,384);
			XO3D_DrawAllObject(hNina,TRN_TRANSLATE | TRN_ROTATE);
		}
		XVGS_RenderScene();
		if (MOD_Order == 11)
			break;
	}
	//XVTI_EndTimer();
	
	XH3D_DisableFog();
	

//	Vector3 Camara,ViewAt;	
	/*
	XH3D_SetFog(0x200000,800.0f,1000.0f);
	XH3D_EnableFog();
	XH3D_SetAmbientLight(0x9090A0);
	XH3D_SetLightEngine(TRUE);
	*/
	Camara.x = 20.0f;
	Camara.y = 10.0f;
	Camara.z = -40.0f;
	ViewAt.x = 0.0f;
	ViewAt.y = 0.0f;
	ViewAt.z = 40.0f;
	XH3D_SetProyectionParams(1.0f,2000.0f,75.0f,75.0f);
	XH3D_SetCameraPosition(&Camara,&ViewAt,NULL);
	XH3D_SetCullingState(true,true);
	XH3D_SetZBufferState(TRUE);
	DWORD hPiedra = LoadTexture(lapida,32,32,0xff);
	DWORD hSuelo = LoadTextureBW(tierra,32,32,0xff);
	DWORD hNubes = LoadTextureBW(nubes,32,32,0xff);
	DWORD hCruz01 = XO3D_CreateCube(2.0f,2.0f,10.0f);
	XO3D_RecalcNormals(hCruz01,TRUE);
	DWORD hCruz02 = XO3D_CreateCube(2.0f,2.0f,2.0f);
	XO3D_RecalcNormals(hCruz02,TRUE);
	DWORD hLapida = XO3D_CreateCube(7.0f,20.0f,0.5f);
	XO3D_RecalcNormals(hLapida,TRUE);
	DWORD hTerreno = XO3D_CreatePlane(4500.0f,4500.0f);
	XO3D_RecalcNormals(hTerreno,TRUE);
	DWORD hCielo = XO3D_CreateCube(1000.0f,1500.0f,1000.0f);
	XO3D_RecalcNormals(hCielo,TRUE);

	//Greetings.
	DWORD hGreetPanel = XO3D_CreatePlane(30.0f,30.0f);
	DWORD hGreet01 = LoadTexture(gret01,64,32,0xff);
	DWORD hGreet02 = LoadTexture(gret02,64,32,0xff);
	DWORD hGreet03 = LoadTexture(gret03,64,32,0xff);
	DWORD hGreet04 = LoadTexture(gret04,64,32,0xff);
	DWORD hGreet05 = LoadTexture(gret05,64,32,0xff);
	DWORD hGreet06 = LoadTexture(gret06,64,32,0xff);
	XO3D_SetMaterialTextured(hGreetPanel,0,STP_GLENZ,hGreet01,NULL);
	XO3D_InvertCulling(hGreetPanel);

	XO3D_InvertCulling(hTerreno);

	XO3D_ScaleMapping(hTerreno,18.0f);
	XO3D_ScaleMapping(hCielo,2.0f);
	XO3D_SetMaterialTextured(hTerreno,0,STP_NONE,hSuelo,NULL);
	XO3D_SetMaterialTextured(hCielo,0,STP_NONE,hNubes,NULL);
	XO3D_SetMaterialTextured(hCruz01,0,STP_NONE,hPiedra,NULL);
	XO3D_SetMaterialTextured(hCruz02,0,STP_NONE,hPiedra,NULL);
	XO3D_SetMaterialTextured(hLapida,0,STP_NONE,hPiedra,NULL);
	float lapx,lapy;
	for (lapy = -500; lapy != 500; lapy+=100)
	{
		for (lapx = -500; lapx != 500; lapx+=50)
		{
			
			LapidasPos[Count].x = lapx;
			LapidasPos[Count].y = 0.0f;
			LapidasPos[Count].z = lapy;
			Count++;
		}
	}
	MakeKey3(Key,KEY_POINTS,10);
	//Generamos una spline a partir de esos puntos.
	XMTH_MakeBspline(Key,KEY_POINTS,Res,PRECISION);
	Vector3 BolaPos;
	LINESTRUCT OurLine;
	//OurLine.ColorV1 = 0xff0000;
	//OurLine.ColorV2 = 0xff0000;
	OurLine.Tipo = PS_TEXTURADO;
	OurLine.Subtipo = STP_GLENZ;
	OurLine.hTexture = hBloody;
	for (DWORD n = 0; n != 200; n++)
	{
		DWORD Angle;
		Angle = XMTH_Rnd() & 511;
		LineDest[n].x = XMTH_GetCosinus(Angle);
		LineDest[n].y = XMTH_GetSinus(Angle);
		LineDest[n].z = XMTH_GetSinus(Angle);
	}
	BOOL Greet = FALSE;
	while(!EscPressed)
	{	
		if  ( (MOD_Row == 0) || (MOD_Row == 1) ||
			(MOD_Row == 6) || (MOD_Row == 7) ||
			(MOD_Row == 16) || (MOD_Row == 17) ||
			(MOD_Row == 22) || (MOD_Row == 23) ||
			(MOD_Row == 30) || (MOD_Row == 31) ||
			(MOD_Row == 32) || (MOD_Row == 33) ||
			(MOD_Row == 38) || (MOD_Row == 37) ||
			(MOD_Row == 48) || (MOD_Row == 49) ||
			(MOD_Row == 54) || (MOD_Row == 55) )
		{
			float RandNoise;
			Camara.x = 0.0f;
			Camara.y = 20.0f;
			Camara.z = -30.0f;
			RandNoise = 32768 - XMTH_Rnd();
			RandNoise /= 65536;
			RandNoise *=6;
			Camara.x += RandNoise;
			RandNoise = 32768 - XMTH_Rnd();
			RandNoise /= 65536;
			RandNoise *=6;
			Camara.y += RandNoise;
			ViewAt.x = 0.0f;
			ViewAt.y = 0.0f;
			ViewAt.z = 1.0f;
			XH3D_SetCameraPosition(&Camara,&ViewAt,NULL);
			Greet = TRUE;
		}
		else
		{
			Camara.x = Res[Index].x;
			Camara.y = Res[Index].y;
			Camara.z = Res[Index].z;
			ViewAt.x = Res[Index].x-Res[Index+1].x;
			ViewAt.y = Res[Index].y-Res[Index+1].y;
			ViewAt.z = Res[Index].z-Res[Index+1].z;
			XH3D_SetCameraPosition(&Camara,&ViewAt,NULL);
			Index++;
			if (Index > (KEY_POINTS-2)*PRECISION)
				Index = 0;
			Greet = FALSE;
		}
		if ( ((MOD_Row >=24) && (MOD_Row <= 26)) ||
  			 ((MOD_Row >=28) && (MOD_Row <= 30)) )
		{
			float dist1 = XMTH_Rnd() & 255;
			float dist2 = XMTH_Rnd() & 255;
			XH3D_SetProyectionParams(1.0f,3000.0f,dist1,dist2);
		}
		else
			XH3D_SetProyectionParams(1.0f,3000.0f,75.0f,75.0f);

		XO3D_SetObjectPosition(hCielo,0.0f,-11.0f,0.0f);
		XO3D_SetObjectAngles(hCielo,0,0,0);
		XO3D_DrawAllObject(hCielo,TRN_TRANSLATE);

		XO3D_SetObjectPosition(hTerreno,0.0f,-11.0f,0.0f);
		XO3D_SetObjectAngles(hTerreno,0,0,0);
		XO3D_DrawAllObject(hTerreno,TRN_ROTATE | TRN_TRANSLATE);
		
		for (DWORD p = 0; p != Count; p++)
		{
			XO3D_SetObjectPosition(hCruz01,LapidasPos[p].x,LapidasPos[p].y,LapidasPos[p].z);
			XO3D_SetObjectAngles(hCruz01,0,0,0);
			XO3D_DrawAllObject(hCruz01,TRN_ROTATE | TRN_TRANSLATE);
			XO3D_SetObjectPosition(hCruz02,LapidasPos[p].x+3.0f,LapidasPos[p].y+3.0f,LapidasPos[p].z);
			XO3D_SetObjectAngles(hCruz02,0,0,0);
			XO3D_DrawAllObject(hCruz02,TRN_ROTATE | TRN_TRANSLATE);
			XO3D_SetObjectPosition(hCruz02,LapidasPos[p].x-3.0f,LapidasPos[p].y+3.0f,LapidasPos[p].z);
			XO3D_SetObjectAngles(hCruz02,0,0,0);
			XO3D_DrawAllObject(hCruz02,TRN_ROTATE | TRN_TRANSLATE);
			XO3D_SetObjectPosition(hLapida,LapidasPos[p].x,LapidasPos[p].y-10.0f,LapidasPos[p].z-25.0f);
			XO3D_SetObjectAngles(hLapida,0,0,0);
			XO3D_DrawAllObject(hLapida,TRN_ROTATE | TRN_TRANSLATE);
		}
		if (Greet)
		{
			XO3D_SetObjectPosition(hGreetPanel,0.0f,7.0f,-10.0f);
			XO3D_SetObjectAngles(hGreetPanel,85,0,384);
			XO3D_DrawAllObject(hGreetPanel,TRN_TRANSLATE | TRN_ROTATE);
		}
		BolaPos.x = Res[Index+3].x;
		BolaPos.y = Res[Index+1].y;
		BolaPos.z = Res[Index+5].z;
		XMTH_SetTranslation(0.0f,0.0f,0.0f);
		XMTH_SetAngles(0,0,0);
		XMTH_CalcRotationMatrix();
		XMTH_RotateCords(LineDest,LineDest2,200);
		for (DWORD n = 0; n != 200; n++)
		{
			OurLine.x1 = BolaPos.x;
			OurLine.y1 = BolaPos.y;
			OurLine.z1 = BolaPos.z;
			OurLine.x2 = BolaPos.x+(LineDest2[n].x*(5.0f+(XMTH_Rnd() & 3)));
			OurLine.y2 = BolaPos.y+(LineDest2[n].y*(5.0f+(XMTH_Rnd() & 3)));
			OurLine.z2 = BolaPos.z+(LineDest2[n].z*(5.0f+(XMTH_Rnd() & 3)));
			XH3D_DrawLine(&OurLine);
		}
		BolaPos.x = Res[Index+1].x;
		BolaPos.y = Res[Index+4].y;
		BolaPos.z = Res[Index+2].z;
		XMTH_SetTranslation(0.0f,0.0f,0.0f);
		XMTH_SetAngles(0,0,0);
		XMTH_CalcRotationMatrix();
		XMTH_RotateCords(LineDest,LineDest2,200);
		for (n = 0; n != 200; n++)
		{
			OurLine.x1 = BolaPos.x;
			OurLine.y1 = BolaPos.y;
			OurLine.z1 = BolaPos.z;
			OurLine.x2 = BolaPos.x+(LineDest2[n].x*(5.0f+(XMTH_Rnd() & 3)));
			OurLine.y2 = BolaPos.y+(LineDest2[n].y*(5.0f+(XMTH_Rnd() & 3)));
			OurLine.z2 = BolaPos.z+(LineDest2[n].z*(5.0f+(XMTH_Rnd() & 3)));
			XH3D_DrawLine(&OurLine);
		}
		if (MOD_Order == 12)
		{
			if ( (MOD_Row == 0) || (MOD_Row == 6) || (MOD_Row == 16))
				XO3D_SetMaterialTextured(hGreetPanel,0,STP_GLENZ,hGreet01,NULL);
			if ( (MOD_Row == 22) || (MOD_Row == 30) || (MOD_Row == 32))
				XO3D_SetMaterialTextured(hGreetPanel,0,STP_GLENZ,hGreet02,NULL);
			if ( (MOD_Row == 38) || (MOD_Row == 48) || (MOD_Row == 54))
				XO3D_SetMaterialTextured(hGreetPanel,0,STP_GLENZ,hGreet03,NULL);
		}
		if (MOD_Order == 13)
		{
			if ( (MOD_Row == 0) || (MOD_Row == 6) || (MOD_Row == 16))
				XO3D_SetMaterialTextured(hGreetPanel,0,STP_GLENZ,hGreet04,NULL);
			if ( (MOD_Row == 22) || (MOD_Row == 30) || (MOD_Row == 32))
				XO3D_SetMaterialTextured(hGreetPanel,0,STP_GLENZ,hGreet05,NULL);
			if ( (MOD_Row == 38) || (MOD_Row == 48) || (MOD_Row == 54))
				XO3D_SetMaterialTextured(hGreetPanel,0,STP_GLENZ,hGreet06,NULL);
		}
		XVGS_RenderScene();
		if (MOD_Order == 14)
			break;
	}
	
//	Vector3 Camara,ViewAt;
	XH3D_SetCullingState(false,true);
	XH3D_SetZBufferState(FALSE);
	XH3D_DisableFog();
	VGS_ClearColor = 0x0000;
	DWORD hPanelFondo = XO3D_CreatePlane(200.0f,200.0f);
	DWORD hEnd = XO3D_CreatePlane(30.0f,40.0f);
	DWORD hFind = LoadTexture(url,128,32,0x80);
	DWORD hJojos = LoadTexture(ojo,32,32,0x80);
	XO3D_SetMaterialTextured(hEnd,0,STP_GLENZ,hFind,NULL);
	XO3D_SetMaterialTextured(hPanelFondo,0,STP_ALPHATEXT,hJojos,NULL);
	while(!EscPressed)
	{
		Camara.z = -40.0f;
		if (MOD_Order == 14)
		{
			if ( (MOD_Row == 0)	|| (MOD_Row == 14) || (MOD_Row == 16) ||
				 (MOD_Row == 30)	|| (MOD_Row == 32) || (MOD_Row == 46) ||
				 (MOD_Row == 48) )
					Camara.z = -30.0f;

		}
		if (MOD_Order == 15)
		{
			if ( (MOD_Row == 0)	|| (MOD_Row == 14) || (MOD_Row == 16) ||
				 (MOD_Row == 30)	|| (MOD_Row == 32) )
					Camara.z = -30.0f;
		}
		Camara.x = 0.0f;
		Camara.y = 0.0f;
		ViewAt.x = 0.0f;
		ViewAt.y = 0.0f;
		ViewAt.z = 1.0f;
		XH3D_SetProyectionParams(1.0f,2000.0f,75.0f,75.0f);
		XH3D_SetCameraPosition(&Camara,&ViewAt,NULL);
		XO3D_SetObjectPosition(hPanelFondo,0.0f,0.0f,90.0f);
		XO3D_SetObjectAngles(hPanelFondo,128,0,384);
		XO3D_DrawAllObject(hPanelFondo,TRN_TRANSLATE | TRN_ROTATE);
		XO3D_SetObjectPosition(hEnd,0.0f,0.0f,0.0f);
		XO3D_SetObjectAngles(hEnd,128,0,384);
		XO3D_DrawAllObject(hEnd,TRN_TRANSLATE | TRN_ROTATE);
		XVGS_RenderScene();
		if ( (MOD_Order == 15 ) && (MOD_Row == 62))
			break;
	}
	XVTI_EndTimer();
	XMOD_StopMusic();
	//System finalization

/*

PD: Despues de la guarreria de codigo que me he marcado en plan
rapido para presentar algo... pffff .. xD cualquiera se pone
a liberar recursos aqui!! .. asi que paro la musica y
cuando caiga el proceso ya se limpiara todo... si DirectX en
debug se os queja diciendo que hemos dejado las cosas malitas..
i sorry... cosas de la edad xD

*/
	XSND_DeinitSound();
	DeleteCriticalSection(&cs);
	return 0;
}