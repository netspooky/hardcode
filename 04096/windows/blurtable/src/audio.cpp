#include <windows.h>
#include <mmsystem.h>

#include "audio.h"
#include "tool.h"
#include "define.h"



//-----------------------------------------------------------------------------
// music
//-----------------------------------------------------------------------------
float music(float t)
{
    //Variables
    float intro,techno,bass;

    //Intro
    if(t<6)
    {
	    intro =  cos(t *t * sin(50*PI*t));
    }
    else if(t<12)
    {
	    intro =  cos(t *(6-(t-6)) * sin(50*PI*(6-(t-6))));
    }
    else
    {
        intro=0;
        float tmp = ( 4-clamp(t*10,0,4) );
        techno = cos(tmp *tmp * sin(5*PI*tmp));
    }
    bass = (sin(4.0f * PI * t * (1.0f + (1.0f + cos(100.0f * PI * t + sin(t) * 15.0f)) / 32.0f))) ;

    return (intro+techno+bass)/2;
}

//-----------------------------------------------------------------------------
// InitMusic
//-----------------------------------------------------------------------------
void InitMusic()
{
    wavdata_t* wav;
	short*			ptr;
	float			time=0.0f;

	wav = (wavdata_t*) GlobalAlloc(GPTR, (44 + DURATION * SAMPLERATE * 2));
	(*wav).riffid = 'FFIR';
	(*wav).riffsize = DURATION * SAMPLERATE * 2 + 36;
	(*wav).waveid = 'EVAW';
	(*wav).chunkid = ' tmf';
	(*wav).chunksize = 16;
	(*wav).format = 1;
	(*wav).channels = 1;
	(*wav).samplerate = SAMPLERATE;
	(*wav).bytespersec = SAMPLERATE * 2;
	(*wav).blockalign = 2;
	(*wav).bitspersample = 16;
	(*wav).dataid = 'atad';
	(*wav).datasize = DURATION * SAMPLERATE * 2;

	ptr = &((*wav).data);
	float invsamplerate		= 1.0f / (float)SAMPLERATE;

	//mk music
	for(int i=0; i<DURATION * SAMPLERATE; i++) {
		ptr[i] = (short)((	music(time))   * 32000.f);
		time+= invsamplerate;
	}

    //play
    PlaySound((char*)wav, 0, SND_MEMORY | SND_ASYNC);

}


