#include "stdafx.h"

#include "view.hpp"
#include "scene.hpp"

using namespace std;
using namespace tofu;

#define KEEP_FPS

//#ifdef _MSC_VER
#if 0
int WINAPI wWinMain(HINSTANCE /*hInstance*/, HINSTANCE /*hPrevInstance*/, PWSTR /*pCmdLine*/, int /*nCmdShow*/)
#else
int main()
//int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
#endif
{	
#if 0
	//’x‚¢‚Ì‚Åx87Žg‚¤‚Ì‚ÍŽ«‚ß‚½.
	unsigned short fpuCtrlWrd = 0x7f;
	__asm
	{
		fldcw fpuCtrlWrd;
	}
#endif

	HWND hwnd =
		CreateWindowEx
		(
			WS_EX_APPWINDOW|WS_EX_WINDOWEDGE, "edit", "FromPlane2ColorDebug",
			WS_VISIBLE|WS_CAPTION|WS_CLIPSIBLINGS|WS_CLIPCHILDREN, 
			0, 0, WIDTH, HEIGHT, 0, 0, 0, 0
		);

    HDC hdc = GetDC( hwnd );

	uint frameCount = 0;//NUM_FPS*80;
	uint renderCount = 0;
	uint lastSampleFrameCount = 0;
	DWORD lastSampleTime = timeGetTime();

	DWORD t0 = timeGetTime();

	bool is_pause = false;
	bool is_step_once = false;
	bool done = false;
	while (!done)
	{
        MSG msg; 

		if(GetAsyncKeyState('O'))
		{
			is_pause = false;
		}
		if(GetAsyncKeyState('P'))
		{
			is_pause = true;
		}

		if(GetAsyncKeyState('I'))
		{
			if(!is_step_once)
			{
				is_pause = false;
			}
			is_step_once = true;
		}else
		{
			is_step_once = false;
		}

		if(GetAsyncKeyState('K'))
		{
			++frameCount;
			is_pause = true;
		}else if(GetAsyncKeyState('J'))
		{
			if(frameCount > 0)
				--frameCount;

			is_pause = true;
		}

		if(GetAsyncKeyState('L'))
		{
			frameCount += 4;
			is_pause = true;
		}else if(GetAsyncKeyState('H'))
		{
			if(frameCount > 4)
				frameCount-=4;

			is_pause = true;
		}


		if(!is_pause)
		{
			frameCount++;
		}

		++renderCount;
		frame(frameCount);

		if(is_step_once)
		{
			is_pause = true;
		}

		while( PeekMessage( &msg,0,0,0,PM_REMOVE ) ) 
		{
			done |= (GetAsyncKeyState(VK_ESCAPE)!=0);
			DispatchMessage( &msg );
		}

		StretchDIBits
		(
			hdc,
			0, 0, WIDTH, HEIGHT,	//Destination rectangle.
			0, 0, WIDTH, HEIGHT,	//Source rectangle.
			buffer, &bmi, DIB_RGB_COLORS,SRCCOPY
		);
#ifdef KEEP_FPS
		do
		{
			Sleep(1);	// give some time to other processes
		}while(timeGetTime() - t0 < (1000/NUM_FPS));
		t0 = timeGetTime();
#endif

		DWORD t = timeGetTime();
		DWORD samplingDelta = t - lastSampleTime;
		if(samplingDelta > 5000)
		{
			cout << "Avg msec per frame:" <<
				float(samplingDelta)/(renderCount-lastSampleFrameCount)<<endl;
			lastSampleFrameCount = renderCount;
			lastSampleTime = t;
		}
	}

	return 0;
}
