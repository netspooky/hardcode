
//--------------------------------------------------------------------------------------
//
//  .: Breakpoint 2009 - unofficial 1k invitation Intro :.
//
//    _________ __                 __      __  .__            
//   /   _____//  |______ ________/  |_  _/  |_|  |__   ____  
//   \_____  \\   __\__  \\_  __ \   __\ \   __\  |  \_/ __ \ 
//   /     !  \|  |  / __ \|  | \/|  |    |  | |   Y  \  ___/ 
//  /_______  /|__! (____  /__|   |__!    | _| |___|  /\___  _>
//          \/__  .      \/       !  .    !/   !    \/     \/ 
//          _|__! ____ :__ _________  ____:  ____ ___.__._
//           !  |/  _ \|  |  \_  __ \/    \_/ __ <   |  |
//           :  (  <_> )  |  /|  | \/   :  \  ___/\___  |
//       /\__|  |\____/|____/ |__|  |___!  /\___  > ____|_ _
//       \______|      !      !     !    \/     \/\/    !
//              !      .            :
//
//  This is just an unofficial breakpoint 2009 intro in only 1k
//  using DirectX9. Intro runs on 640x480 in 32 bit and you need
//  d3dx9_24.dll from the DX9 installation!! Hope ya like this
//  small intro ;)
//
//
//
//  Credits:
//  --------
//  Code, Idea, Design..:	Mr.Vain of Secretly!
//							aka Thorsten Will
//
//  Nice Fonts..........:   Microsoft Company
//
//  Amazing great packer:   Loonies & TBC
//
//--------------------------------------------------------------------------------------
//
//  This source is free, so everybody can see how things are done and how to code a 1k!
//  Best regards, Thorsten Will aka "Mr.Vain of Secretly!" 
//
//  Compile with VS2005
//
//--------------------------------------------------------------------------------------

// compiler settings

	#define WIN32_LEAN_AND_MEAN
	#define WIN32_EXTRA_LEAN

// include the basic windows header files and the Direct3D header files

	#include <windows.h>
	#include <stdlib.h>
	#include <d3d9.h>
	#include <d3dx9.h>

// include the required library files

	#pragma comment(lib, "d3d9.lib")
	#pragma comment(lib, "d3dx9.lib")

//  extern "C" int _fltused = 0;

//-------------------------------------------------------------------------------
//  S e g m e n t s
//-------------------------------------------------------------------------------

#pragma data_seg(".device")

	LPDIRECT3DDEVICE9	g_pDevice;			// the pointer to the device class
 
// ---- Rect Structure Data
#pragma data_seg(".rect")

	RECT rect = {0, 0, 640, 480};

// ---- D3DPP Structure Data
#pragma data_seg(".d3d")

	D3DPRESENT_PARAMETERS d3dpp = {							
		640, 480,							// UINT					BackBufferWidth, BackBufferHeight;
		D3DFMT_A8R8G8B8,					// D3DFORMAT			BackBufferFormat;
		0,									// UINT					BackBufferCount;	
		D3DMULTISAMPLE_NONE,				// D3DMULTISAMPLE_TYPE	MultiSampleType;
		0,									// DWORD				MultiSampleQuality;
		D3DSWAPEFFECT_FLIP,					// D3DSWAPEFFECT		SwapEffect;
		0,									// HWND					hDeviceWindow;
		0,									// BOOL					Windowed;
		0,									// BOOL					EnableAutoDepthStencil;
		D3DFMT_UNKNOWN,						// D3DFORMAT			AutoDepthStencilFormat;
		0,									// DWORD				Flags;
		0,									// UINT					FullScreen_RefreshRateInHz;
		0									// UINT					PresentationInterval;
	};

// ---- Vertex Structure 
#pragma data_seg(".bg")

	struct CUSTOMVERTEX
	{
		float x, y, z, rhw;
		int Color;
	};

// ---- Vertex Gradient-Background Data
#pragma data_seg(".bg2")

	static CUSTOMVERTEX v[4] = {  
		  0.0f,   0.0f, 0.0f, 0.0f, 0x007F00, 
		640.0f,   0.0f, 0.0f, 0.0f, 0xD57F00,
		  0.0f, 480.0f, 0.0f, 0.0f, 0x007FF0,
		640.0f, 480.0f, 0.0f, 0.0f, 0xD57FF0
	};

// ---- Message Text
#pragma data_seg(".text")

	char* TextParts[4] = {		
		"Start the journey",
		"10-13 Apr 2009",
		"Bingen am Rhein^Germany",
		"Breakpoint 2009",
	};

// ---- Some of our variables
#pragma data_seg(".vars")

	int TextObj = 0;
	int mirand;

	LPD3DXFONT g_pFont0;
	LPD3DXFONT g_pFont1;
	LPD3DXFONT g_pFont2;

// ---- Tiny Random Routine
#pragma code_seg(".rand")

	int sfrand( void )				// Modified, code based on iq's random function!
	{
		mirand = mirand*0x000000fd;
		return mirand>>16;
	}

//--------------------------------------------------------------------------------------
// E n t r y P o i n t
//--------------------------------------------------------------------------------------

#pragma code_seg(".main")

void WinMainCRTStartup()
{ 
    // ---- Open Window and Create Interface/Device
	HWND hWnd = ( CreateWindowEx(WS_EX_TOPMOST,"edit",0,0,0,0,0,0,0,0,0,0) );	// "static" == more compatible?
	LPDIRECT3D9	g_pD3D = Direct3DCreate9( D3D_SDK_VERSION );					// the pointer to our Direct3D interface 
	g_pD3D->CreateDevice( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, hWnd, D3DCREATE_SOFTWARE_VERTEXPROCESSING, &d3dpp, &g_pDevice );

	ShowCursor(FALSE);	

    // ---- Create needed Fonts

	int s=-400;
	D3DXCreateFont( g_pDevice,								// D3D device
					s,										// Height      Value = -(300 * 96)/72
					0,										// Width
					FW_DONTCARE,							// Weight
					0,										// MipLevels, 0 = autogen mipmaps
					FALSE,									// Italic
					DEFAULT_CHARSET,						// CharSet
					OUT_DEFAULT_PRECIS,						// OutputPrecision
					DEFAULT_QUALITY,						// Quality == DEFAULT_QUALITY
					DEFAULT_PITCH,// | FF_DONTCARE,			// PitchAndFamily
					"webdings",								// pFaceName
					&g_pFont0);								// ppFont 

    s=-45;
	D3DXCreateFont( g_pDevice,								// D3D device
					s,										// Height      Value = -(34 * 96)/72
					0,										// Width
					FW_DONTCARE,							// Weight
					0,										// MipLevels, 0 = autogen mipmaps
					FALSE,									// Italic
					DEFAULT_CHARSET,						// CharSet
					OUT_DEFAULT_PRECIS,						// OutputPrecision
					DEFAULT_QUALITY,						// Quality == DEFAULT_QUALITY
					DEFAULT_PITCH,// | FF_DONTCARE,			// PitchAndFamily
					"webdings",								// pFaceName
					&g_pFont1);								// ppFont 

    s=-26;
	D3DXCreateFont( g_pDevice,								// D3D device
					s,										// Height      Value = -(20 * 96)/72
					0,										// Width
					FW_DONTCARE,							// Weight
					0,										// MipLevels, 0 = autogen mipmaps
					FALSE,									// Italic
					0,										// CharSet
					OUT_DEFAULT_PRECIS,						// OUT_DEFAULT_PRECIS  OutputPrecision
					DEFAULT_QUALITY,						// Quality == DEFAULT_QUALITY
					DEFAULT_PITCH,// | FF_DONTCARE,			// PitchAndFamily
					"impact",								// pFaceName
					&g_pFont2);								// ppFont 

	// ---- Init timer
	int time,starttime=GetTickCount();

	//-------------------------------------------------------------------------------
	//   M a i n l o o p 
	//-------------------------------------------------------------------------------

	do
	{
//		g_pDevice->Clear( 0, NULL, D3DCLEAR_TARGET, 0xFF808080, 1.0f, 0 );			
		g_pDevice->BeginScene();

		// ---- Draw our gradient Background ----
		g_pDevice->SetFVF( D3DFVF_DIFFUSE | D3DFVF_XYZRHW ); // WOW try leaving this line out for a freaky effect!
	    g_pDevice->DrawPrimitiveUP( D3DPT_TRIANGLESTRIP, 2, &v, sizeof(CUSTOMVERTEX) );

		// ---- Draw Particles (using DrawText seems to suxx, fps slow down like hell == unenjoyable)
		time=(GetTickCount()-starttime);
		TextObj=(time>>14)&3;			// change this to make text change faster/slower
		time=time/38;					// change this to make scrolling faster/slower
		
		mirand =1;
        
		for (int i=0; i<1023; i++) 
		{
			rect.left= (((sfrand() + (sfrand()&3) * time) & 1023)-400);	// Very cool optimizing tip by mentor! Thanks! <3
			rect.top = (((sfrand() + (sfrand()&3) * time) & 1023));     // No more need of array and struct! :D
			g_pFont1->DrawText(NULL, "n   n n   n  n", -1, &rect, DT_LEFT , 0x08ffffff);
		}

		if(time>1215) time=1215;				// change this to set when landscape stops scrolling...

		// ---- Draw our Scene with Text ----
		
		rect.top  = -50;
		rect.left = (-time<<1)+680;
		g_pFont0->DrawText(NULL, "j", -1, &rect, DT_LEFT, 0x88000000);		// D3DCOLOR_XRGB( 0, 0, 0)	airplane (saves some bytes!)
//		g_pFont[0]->DrawText(NULL, "j", -1, &rect, DT_LEFT, 0xff523317);	// D3DCOLOR_XRGB(85,49,23)	airplane
		
		rect.top = -30;
		rect.left  = (-time>>1)+910;
		g_pFont0->DrawText(NULL, "Ö", -1, &rect, DT_LEFT, 0xff000000);		// D3DCOLOR_XRGB(0,0,0) 	sun  
		
		rect.top = 150;
		rect.left  = -time;
		g_pFont0->DrawText(NULL, "CKMSQ", -1, &rect, DT_LEFT, 0xff000000);	// D3DCOLOR_XRGB(0,0,0)		landscape

		rect.left  = rect.top = 20;
		g_pFont2->DrawText(NULL, TextParts[TextObj], -1, &rect, DT_LEFT, 0xffFFFFFF);	// D3DCOLOR_XRGB(255,255,255)	MessageText
		
		// -------- End the scene --------

		g_pDevice->EndScene();
		g_pDevice->Present( NULL, NULL, NULL, NULL );

	} while ( !GetAsyncKeyState(VK_ESCAPE) );
	ExitProcess(0);
}



