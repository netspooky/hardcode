/*
	This file is part of "otopoto / Collapse & Gatitos".

    "otopoto / Collapse & Gatitos" is free software: you can redistribute
	it and/or modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation, either version 3 of the
	License, or (at your option) any later version.

    "otopoto / Collapse & Gatitos" is distributed in the hope that it will
	be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
	of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with "otopoto / Collapse & Gatitos".  If not, see 
	<http://www.gnu.org/licenses/>.
*/

#include "defines.h"
#include "port.h"
#include "synth.h"

/*
 *
 */
void init4K		(void);
void renderIntro(void);
void play		(void *stream, int len);

/*
 * Needed if we don't use the default CRT
 */
#ifndef _DEBUG
	extern "C" int _fltused = 1;
#endif


#pragma data_seg ("data_1")
	//----------------------------------------------------------------------------------
	// OpenGL data
	//----------------------------------------------------------------------------------
	static PIXELFORMATDESCRIPTOR pfd = {
		0,										// Size of this structure
		0,                                      // Version of this structure    
		PFD_SUPPORT_OPENGL |					// Support OpenGL calls in window
		PFD_DOUBLEBUFFER,                       // Double buffered
		0,										// RGBA Color mode
		32,                                     // Want 24bit color 
		0,0,0,0,0,0,                            // Not used to select mode
		0,0,                                    // Not used to select mode
		0,0,0,0,0,                              // Not used to select mode
		32};                                    // Size of depth buffer

	//----------------------------------------------------------------------------------
	// DirectSound data
	//----------------------------------------------------------------------------------
	static WAVEFORMATEX	format		= { WAVE_FORMAT_PCM, 1, (int)SAMPLE_RATE, (int)SAMPLE_RATE*2, 2, 16 };
	static DSBUFFERDESC	bufferDesc	= { sizeof(DSBUFFERDESC),  DSBCAPS_GETCURRENTPOSITION2 | DSBCAPS_GLOBALFOCUS,
										BUFFER_SIZE, NULL, &format };
#ifdef FULLSCREEN
	//----------------------------------------------------------------------------------
	// Fullscreen data
	//----------------------------------------------------------------------------------
	#ifdef FULLSCREEN_FORCE_BPP	
		static DEVMODE		dmScreenSettings = { "", 0, 0, sizeof(DEVMODE), 0, DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT,
												0,0,0,
												0,0,0,
												0,0,0,
												0,0,0,
												0,"",0,
												32,xres,yres };
	#else
		static DEVMODE		dmScreenSettings = { "", 0, 0, sizeof(DEVMODE), 0, DM_PELSWIDTH|DM_PELSHEIGHT,
												0,0,0,
												0,0,0,
												0,0,0,
												0,0,0,
												0,"",0,
												0,xres,yres };
	#endif
#endif
#pragma data_seg ()

//----------------------------------------------------------------------------------
// Unitialized data
//----------------------------------------------------------------------------------
#pragma bss_seg ("data_zero")
	LPDIRECTSOUND		m_pDS=0;
	LPDIRECTSOUNDBUFFER	m_pBuffer=0;
	HDC					hDC=0;
#pragma bss_seg ()

//----------------------------------------------------------------------------------
// Synth execution (should run on it's own thread)
//----------------------------------------------------------------------------------
#ifndef NO_MUSIC

	#pragma code_seg ("code_SynthUpdate")
	DWORD WINAPI SynthUpdate (void* ptr)
	{
		DWORD	m_writePos=0;

		for(;;)
		{
			DWORD	l1=0,l2,writeLen;
			void	*p1,*p2;
		
			m_pBuffer->GetCurrentPosition(&l1,NULL);
			
			writeLen = (l1 - m_writePos)%BUFFER_SIZE;
		
			// Lock buffers to update them
			m_pBuffer->Lock (m_writePos,writeLen,&p1,&l1,&p2,&l2,0);
			
			if (l1>0)
				play(p1,l1);

			if (l2>0)
				play(p2,l2);
			
			m_pBuffer->Unlock(p1,l1,p2,l2);
			m_writePos = (m_writePos+writeLen)%BUFFER_SIZE;

			Sleep (1);
		}
	}
#endif



/* 
 *
 * ENTRY POINT
 *
 */
#pragma code_seg ("code_WinMain")

#ifdef _DEBUG
	int __stdcall WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
#else
	extern "C" __declspec(noreturn) void _cdecl WinMainCRTStartup()
#endif
{
	/*
	 * OpenGL/window init
	 */
	#ifdef FULLSCREEN
		ChangeDisplaySettings	(&dmScreenSettings,CDS_FULLSCREEN);		
	#endif
	
	HWND hWnd = CreateWindow("edit","",WS_POPUP|WS_VISIBLE, 0,0, xres, yres,0,0,0,0);

	#ifdef FULLSCREEN
		ShowCursor				(FALSE);
	#endif

	hDC = GetDC	(hWnd);
	SetPixelFormat (hDC, ChoosePixelFormat(hDC, &pfd), &pfd);
	wglMakeCurrent (hDC,wglCreateContext(hDC));

	/*
	 * 4K init
	 */
	init4K ();

	/*
	 * Sound init
	 */
#ifdef NO_MUSIC
	u32 time0 = GetTickCount();
#else
	::DirectSoundCreate			(0, &m_pDS, 0);
	m_pDS->SetCooperativeLevel	(hWnd, DSSCL_PRIORITY);
	m_pDS->CreateSoundBuffer	(&bufferDesc, &m_pBuffer, NULL);
	m_pBuffer->Play				(NULL, NULL, DSBPLAY_LOOPING);

#ifdef SYNTH_CPU_HUNGRY
	SetThreadPriority(CreateThread(0,0,SynthUpdate,0,0,0),THREAD_PRIORITY_TIME_CRITICAL); 
#else
	CreateThread(0,0,threadRout,0,0,0);
#endif

#endif

	/*
	 * Main loop
	 */
	while(!GetAsyncKeyState(VK_ESCAPE))
	{
#ifdef NO_MUSIC
		current_time = ((GetTickCount() - time0))/1000.0f;
#endif
		renderIntro ();
		SwapBuffers(hDC);
	}

	APP_EXIT_4K(0);
}
