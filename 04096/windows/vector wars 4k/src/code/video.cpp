#include "stableheaders.hpp"
#include "video.hpp"

#include "globals.hpp"
#include "helpers.hpp"

/////////////////////////////////////////////////////////////////////////////////
// BSS
/////////////////////////////////////////////////////////////////////////////////
#pragma bss_seg(".bss_video")

LPDIRECT3D9			g_pD3D;			// pointer to the one global direct3d9 instance
LPDIRECT3DDEVICE9	g_pD3DDevice;	// pointer to the one global device instance
LPD3DXMATRIXSTACK	g_pMatrixStack;	// pointer to the matrix stack instance
LPD3DXFONT			g_pFontText;	// pointer to the font instance

RECT				g_desktopRect;	// the desktop rectangle

/////////////////////////////////////////////////////////////////////////////////
// DATA
/////////////////////////////////////////////////////////////////////////////////
#pragma data_seg(".data_video")

// font descriptor
D3DXFONT_DESC g_fontText =
{
		35,								// Height
		0,								// Width
		FW_DONTCARE,					// Weight
		0,								// MipLevels, 0 = autogen mipmaps
		FALSE,							// Italic
		ANSI_CHARSET,					// CharSet
		OUT_DEFAULT_PRECIS,				// OutputPrecision
		ANTIALIASED_QUALITY,			// Quality
		DEFAULT_PITCH | FF_DONTCARE,	// PitchAndFamily
		"Trebuchet MS",					// pFaceName
};

char g_windowName[] = "EDIT"; // name of the window class to create

//////////////////////////////////////////////////////////////////////////
// CODE
//////////////////////////////////////////////////////////////////////////
#pragma code_seg(".init")

////////////////////////////////////////////////////////////////////////////////
//
//	Video_Init()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Sets up the rendering services.

*/
void Video_Init()
{
	// we need the desktop rectangle since we want the game to run in desktop resolution
	GetWindowRect(GetDesktopWindow(), &g_desktopRect);
	
	screen_params.BackBufferWidth = SCREEN_WIDTH;
	screen_params.BackBufferHeight = SCREEN_HEIGHT;

	// create the window
	#ifdef FULLSCREEN
		screen_params.hDeviceWindow = CreateWindowEx
		(
			0, g_windowName, g_windowName,
			WS_VISIBLE | WS_POPUP | WS_MAXIMIZE,0,0,
			SCREEN_WIDTH,SCREEN_WIDTH,
			0,0,0,0
		);
	#else
		screen_params.hDeviceWindow = CreateWindowEx
		(
			WS_EX_APPWINDOW, g_windowName, g_windowName,
			WS_VISIBLE | WS_POPUP,0,0,
			SCREEN_WIDTH,SCREEN_HEIGHT,
			0,0,0,0
		);
	#endif
	
	// create d3d object
	g_pD3D = Direct3DCreate9(D3D_SDK_VERSION);

	// create 3d3 device
    D3D_VERIFY(g_pD3D->CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, screen_params.hDeviceWindow, 
									D3DCREATE_HARDWARE_VERTEXPROCESSING | D3DCREATE_PUREDEVICE, 
									&screen_params, &g_pD3DDevice), "Create Device Failed");


	// create a matrix stack
	D3D_VERIFY(D3DXCreateMatrixStack(0, &g_pMatrixStack), "D3DXCreateMatrixStack failed");

	// create the font
	D3D_VERIFY(D3DXCreateFontIndirect
	(
		g_pD3DDevice,		   // D3D device
		&g_fontText,
		&g_pFontText
	), "D3DXCreateFont failed");
}

////////////////////////////////////////////////////////////////////////////////
//
//	Video_BeginScene()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Starts rendering.
		
	\remarks
	
		Call this before any rendering for the current frame is done.

*/
void Video_BeginScene()
{
	g_pD3DDevice->BeginScene();	
	g_pD3DDevice->Clear(0, NULL, D3DCLEAR_TARGET | D3DCLEAR_ZBUFFER, COLOR_CLEAR, 1.0f, 0);
}


////////////////////////////////////////////////////////////////////////////////
//
//	Video_EndScene()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Finalizes rendering.

	\remarks

		Call this after the last graphics command for the current frame has
		been issued.

*/
void Video_EndScene()
{
	g_pD3DDevice->EndScene();
	g_pD3DDevice->Present(NULL,NULL,NULL,NULL);
}
