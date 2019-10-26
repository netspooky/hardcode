/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef MAPPROXAUDIO_H
#define MAPPROXAUDIO_H

#include <SDL/SDL.h>
#include <SDL/SDL_audio.h>

#include "mapprox.h"
#include "SynthContainer.h"

namespace Mapprox
{

class Audio
{
    private:
        // SDL stuff
        SDL_AudioSpec sdl_format;

        // Audio engine
        Uint8* mixbuf;
        const sample_t* rawbuf;
        int step_no;
        int rawbuf_pos;
        float ampl;

        void step_audio();
        SynthContainer* source;
    public:
        Audio();
        ~Audio();

        void SetSource ( SynthContainer* source );
        void Start();
        void Stop();
        void SetAmplification ( float ampl );

        // Callback for SDL
        void mix ( Uint8* stream, int len );
};

}

#endif
