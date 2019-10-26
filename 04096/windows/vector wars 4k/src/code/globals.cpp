#include "stableheaders.hpp"

#include "globals.hpp"

//////////////////////////////////////////////////////////////////////////
// BSS
//////////////////////////////////////////////////////////////////////////
#pragma  bss_seg(".bss_globals")

DWORD g_timeMs;		// the last retrieved system time in milliseconds
float g_timeDelta;	// the last delta time between two frames

//////////////////////////////////////////////////////////////////////////
// DATA
//////////////////////////////////////////////////////////////////////////
#pragma data_seg(".data_globals")

D3DPRESENT_PARAMETERS screen_params =
{
	0,							// BackBufferWidth (will be set during runtime)
	0,							// BackBufferHeight  (will be set during runtime)
	D3DFMT_A8R8G8B8,			// BackBufferFormat
	1,							// BackBufferCount 
	D3DMULTISAMPLE_NONE,		// MultiSampleType
	0,							// MultiSampleQuality 
	D3DSWAPEFFECT_DISCARD,		// SwapEffect 
	0,							// hDeviceWindow
#ifdef FULLSCREEN
    0,							// Windowed (not)
#else
	1,							// Windowed 
#endif
	1,							// EnableAutoDepthStencil 
	D3DFMT_D24S8,				// AutoDepthStencilFormat 
	0,							// Flags 
	D3DPRESENT_RATE_DEFAULT,	// FullScreen_RefreshRateInHz 
	D3DPRESENT_INTERVAL_DEFAULT	// PresentationInterval 
};
