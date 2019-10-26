#include <windows.h>
#include <stdio.h>
#include "TinySynth.h"

// ==================================================================
// Main function
int APIENTRY WinMain (	HINSTANCE hInstance,
						HINSTANCE hPrevInstance,
						LPSTR     lpCmdLine,
						int       nCmdShow ) {
	AllocConsole ( );
	freopen ( "CONOUT$", "w", stdout );
	MMTIME mt;
	mt.wType = TIME_BYTES;
	CreateAndPlaySynth ( );
	char* text[] = {	"Stop. Put down your weapon, you have twenty seconds to comply. Start destruction sequence.\n\n",
						"Welcome to sound test.\n\n", 
						"(Some predator-like speech)\n\n", 
						"This is a whisper.\n\n" };
	int showTime[] = { 0, 14, 20, 26, 800 };
	int k = 0;
	float time = 0;
	while ( !GetAsyncKeyState ( VK_ESCAPE ) && time < PLAY_TIME - 1 ) {
		waveOutGetPosition ( g_wo, &mt, sizeof(mt) );
		time = (float)mt.u.cb / (SAMPLE_FREQUENCY*sizeof(short)*2);
		if ( time > showTime[k] - 1 )
			printf ( text[k++] );
		Sleep ( 100 );
	}
	ExitProcess ( 0 );
} // WinMain