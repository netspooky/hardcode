#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include <windows.h>
#include <Mmsystem.h>
#include <math.h>



//#include "deepfloweroptimized2.h"

#define USING_4KLANG
//#define USING_MIDI

#define DT 0.043f

#ifdef _DEBUG
 //#define MONITOR_WINDOW
 #define KEY_INPUT
 #define FILEREAD
 #define RESTART_ENABLED
 //#define SYSTEM_TIMER
#endif
 #define FULLSCREEN
//#define USING_DIRECTX11
#define USING_OPENGL

#ifdef FULLSCREEN
 #define XRES 1280
 #define YRES 720
#else
 #define XRES 800
 #define YRES 600
#endif

#ifdef FILEREAD
 #include "file.h"
#endif

HDC hDC;

#ifdef USING_4KLANG
#include "4klang.h"
#endif

#ifdef USING_OPENGL
#include "opengl.h"
//#include "scene.h"
#endif

#ifdef USING_DIRECTX11
#include "dx11.h"
#endif

float t = 0;
float dt;// = 0.01f;////

#ifdef USING_4KLANG
	//static HDC		     hDC;
	static SAMPLE_TYPE	lpSoundBuffer[MAX_SAMPLES*2];  
	static HWAVEOUT	hWaveOut;
	#define WAVE_FORMAT_IEEE_FLOAT 0x0003

	static WAVEFORMATEX WaveFMT =
	{
	#ifdef FLOAT_32BIT	
		WAVE_FORMAT_IEEE_FLOAT,
	#else
		WAVE_FORMAT_PCM,
	#endif		
		2, // channels
		SAMPLE_RATE, // samples per sec
		SAMPLE_RATE*sizeof(SAMPLE_TYPE)*2, // bytes per sec
		sizeof(SAMPLE_TYPE)*2, // block alignment;
		sizeof(SAMPLE_TYPE)*8, // bits per sample
		0 // extension not needed
	};

	static WAVEHDR WaveHDR = 
	{
		(LPSTR)lpSoundBuffer, 
		MAX_SAMPLES*sizeof(SAMPLE_TYPE)*2,			// MAX_SAMPLES*sizeof(float)*2(stereo)
		0, 
		0, 
		0, 
		0, 
		0, 
		0
	};

	static MMTIME MMTime = 
	{ 
		TIME_SAMPLES,
		0
	};
#endif

#ifdef USING_MIDI

HMIDIOUT midiout;

void midi_shortmsg(DWORD raw)
{
	midiOutShortMsg(midiout, raw);
}

#endif


#include "logo.h"


#ifdef MONITOR_WINDOW
	HWND monitor_hwnd = 0;
	void UpdateMonitorWindow(int t, char txt2[])
	{
		char txt[] = "..........";
		txt[6] = '0' + (t % 10);
		txt[5] = '0' + (t % 100) / 10;
		txt[4] = '0' + (char)((t % 1000) / 100);
		txt[2] = '0' + (char)((t % 10000) / 1000);
		txt[1] = '0' + (char)((t % 100000) / 10000);
		txt[0] = '0' + (char)((t % 1000000) / 100000);
		SetWindowText(monitor_hwnd, txt);
		UpdateWindow(monitor_hwnd);
		InvalidateRect(monitor_hwnd, 0, TRUE);
	}
	void UpdateMonitorWindow(char txt[])
	{
		SetWindowText(monitor_hwnd, txt);
		UpdateWindow(monitor_hwnd);
		InvalidateRect(monitor_hwnd, 0, TRUE);
	}
#endif


#ifdef KEY_INPUT
	template <int VKEY> struct KeyToggle
	{
		static const int vkey = VKEY;
		bool mem;
		bool toggled;
		bool down;

		KeyToggle() : mem(false), toggled(false), down(false)
		{}

		bool operator()()
		{
			bool value = false;
			if (down = GetAsyncKeyState(VKEY) != 0)
			{
				if (mem == false)
				{
					toggled = !toggled;
					value = true;
				}
				mem = true;
			}
			else
				mem = false;

			return value;
		}
	};
#endif

#ifdef _DEBUG
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
//extern "C" __declspec(noreturn) void WinMainCRTStartup()
#else
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)

#endif
{
#ifdef USING_4KLANG
	CreateThread(0, 0, (LPTHREAD_START_ROUTINE)_4klang_render, lpSoundBuffer + EMPTY_WAIT, 0, 0);
	waveOutOpen			( &hWaveOut, WAVE_MAPPER, &WaveFMT, NULL, 0, CALLBACK_NULL );
	waveOutPrepareHeader( hWaveOut, &WaveHDR, sizeof(WaveHDR) );
	waveOutWrite		( hWaveOut, &WaveHDR, sizeof(WaveHDR) );
#endif

#ifdef USING_OPENGL
	InitGraphics(hDC = GetDC(CreateWindow("edit","edit",WS_POPUP|WS_VISIBLE, 0,0, XRES, YRES,0,0,0,0)));
#endif

#ifdef USING_DIRECTX11
	HWND hwnd = CreateWindow("STATIC","STATIC",WS_POPUP|WS_VISIBLE, 0,0, XRES, YRES,0,0,0,0);
	hDC = GetDC(hwnd);
	InitGraphics(hwnd);
#endif

	ShowCursor(FALSE);
	

#ifdef MONITOR_WINDOW
	monitor_hwnd = CreateWindowEx(WS_EX_TOPMOST,"EDIT","EDIT",WS_BORDER|WS_VISIBLE, -200,0, 200, 40,0,0,0,0);
#endif

#ifdef KEY_INPUT
	KeyToggle<VK_F8> mute_key;
	KeyToggle<VK_F9> pause_key;
	KeyToggle<VK_F12> restart_key;
	KeyToggle<VK_F6> reload_key;
	KeyToggle<VK_F4> ff_key;
#endif


#ifdef USING_MIDI
	midiOutOpen(&midiout, 0, 0, 0, 0);

	//midiOutShortMsg(midiout, 0x457EC1);
	//midiOutShortMsg(midiout, 0x452091);
	//midiOutShortMsg(midiout, 0x742591);

#endif
	InitLogo();

#ifdef SYSTEM_TIMER
	DWORD time1 = timeGetTime();
	//DWORD sys_t = 0;
#else
	//float ot = 0;
#endif

	do
	{
#ifdef SYSTEM_TIMER
		DWORD time2 = timeGetTime();
		DWORD dtime = time2 - time1;
		time1 = time2;
		dt = 0.001f * (float)dtime;
		t += dt;
#else
		waveOutGetPosition(hWaveOut, &MMTime, sizeof(MMTIME));
		t = ((float)MMTime.u.ms)*0.000027f - 6.9f;
		
		//dt = t - ot;
		//ot = t;
#endif

#ifdef KEY_INPUT
		//CHECK_TOGGLE(VK_F9);
		pause_key();
		if (pause_key.toggled)
		{
			PeekMessage(NULL,0,0,0,PM_REMOVE);
#ifdef MONITOR_WINDOW
			UpdateMonitorWindow("<SLEEP>");
#endif
			Sleep(80);
			continue;
		}

		if (restart_key())
		{
			t = 0;
#ifdef USING_4KLANG
	waveOutReset(hWaveOut);
	//waveOutOpen			( &hWaveOut, WAVE_MAPPER, &WaveFMT, NULL, 0, CALLBACK_NULL );
	//waveOutPrepareHeader( hWaveOut, &WaveHDR, sizeof(WaveHDR) );
	waveOutWrite		( hWaveOut, &WaveHDR, sizeof(WaveHDR) );
#endif
			RestartLogo();
			ReloadLogo();
			RND = 0;
		}

		if (reload_key())
			ReloadLogo();

#ifdef USING_MIDI
		if (mute_key())
			midiOutReset(midiout);
#endif

		ff_key();
		if (ff_key.down)
		{
			t += dt * 4.5f;
			dt *= 5.5f;
		}

#endif

#ifdef MONITOR_WINDOW
		UpdateMonitorWindow(sys_t, "A");
#endif

		RunLogo();


#ifdef SYSTEM_TIMER
	} while(!GetAsyncKeyState(VK_ESCAPE));
#else
	} while(!GetAsyncKeyState(VK_ESCAPE) && (MMTime.u.sample < MAX_SAMPLES));
#endif
	ExitProcess(0);
}
