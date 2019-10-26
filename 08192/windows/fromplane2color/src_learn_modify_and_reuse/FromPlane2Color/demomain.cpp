#define WIN32_LEAN_AND_MEAN
#include "stdafx.h"

#include "view.hpp"
#include "scene.hpp"

#ifdef __cplusplus
extern "C" { 
#endif
	int _fltused=1; 
//	void _cdecl _check_commonlanguageruntime_version(){}
#ifdef __cplusplus
}
#endif

void WinMainCRTStartup()
{
#ifdef ISFULLSCREEN
	if
	(
		ChangeDisplaySettings
		(
			&screenSettings,CDS_FULLSCREEN
		)
		!=DISP_CHANGE_SUCCESSFUL
	)
		return;
	ShowCursor( 0 );
#endif

	HDC hdc =
		GetDC
		(
			CreateWindowEx
			(
				WS_EX_TOPMOST,
				"static", 0,
				WS_VISIBLE|WS_POPUP|WS_CLIPSIBLINGS|WS_CLIPCHILDREN,
				0, 0, WIDTH, HEIGHT,
				0, 0, 0, 0
			)
		);

	int frameCount = 0;

	DWORD to = timeGetTime();
#if 0
	MSG	msg;
	while(TRUE)
	{
		if(PeekMessage(&msg,NULL,0,0,PM_REMOVE))
		{
			if((msg.message==WM_CHAR)&&(msg.wParam==0x1B))
				break;//ESC
			DispatchMessage(&msg);
		}else{
			OnIdle();
			SwapBuffers(kbhDC);
		}
	}
	
	ExitProcess(0);
	return	;
#else
loop:
	frame(frameCount);
	StretchDIBits
	(
		hdc,
		0, 0, WIDTH, HEIGHT,	//Destination rectangle.
		0, 0, WIDTH, HEIGHT,	//Source rectangle.
		buffer, &bmi, DIB_RGB_COLORS,SRCCOPY
	);
	++frameCount;
	do
	{
		if(GetAsyncKeyState(VK_ESCAPE)/* || frameCount > 120*60*/)
			ExitProcess(0);

		Sleep(1);
	}while(timeGetTime() - to < (1000/NUM_FPS));
	to = timeGetTime();
	goto loop;
#endif
}
