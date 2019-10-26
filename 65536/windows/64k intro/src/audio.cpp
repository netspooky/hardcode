////////////////////////////////////////////////////////////////////////////////
// include
#include "everything.h"

///////////////////////////////////////////////////////////////////////////////
// miniFMOD xm player
#pragma comment(lib, "another/minifmod_std.lib")
#pragma comment(lib, "another/winmm.lib")
#pragma comment(lib, "msacm32.lib")

///////////////////////////////////////////////////////////////////////////////
// miniFMOD
cAudio::cAudio()
{
	useSound=false;
}

cAudio::~cAudio()
{
}

void
cAudio::init(char* n)
{
	fmodInit(44100);
	mod=fmodLoad(&intromusic);
	
	if(!mod){
		return;
	}
}

void
cAudio::play(void)
{
	fmodPlay(mod, 80);		// vol
}

void
cAudio::statusUpdate(void)
{
	ord=fmodGetOrder(mod);
	row=fmodGetRow(mod);
	tick=row%32? false : true;
	playtime = (float)fmodGetTime(mod)/1000.0f;
}

void
cAudio::stop(void)
{
	fmodStop(mod);
}
