/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#include "Audio.h"

using namespace Mapprox;

void __audio_mix_callback(void* audio_class, Uint8* stream, int len)
{
    Audio* a = (Audio*) audio_class;
    a->mix(stream, len);
}

Audio::Audio()
{
    step_no = 0;
    rawbuf_pos = 0;
    ampl = 10000.0f;
    mixbuf = (Uint8*) calloc(AUDIO_STEP_SIZE * AUDIO_CHANNELS, sizeof(int16_t));

    sdl_format.freq = AUDIO_FREQ;
    sdl_format.format = AUDIO_S16SYS;
    sdl_format.channels = AUDIO_CHANNELS;
    sdl_format.samples = AUDIO_SPS_PER_FRAME;
    sdl_format.callback = __audio_mix_callback;
    sdl_format.userdata = this;

    SDL_AudioSpec obtained;

    if (SDL_OpenAudio(&sdl_format, &obtained) < 0) {
#ifdef DEBUG
        cout << "Failed to open audio: " << SDL_GetError() << endl;
        exit(1);
#endif
    } else {
#ifdef DEBUG
        cout << "Freq: " << obtained.freq << endl;
        cout << "Channels: " << (int) obtained.channels << endl;
        cout << "Samples: " << obtained.size << endl;
        cout << "Size: " << obtained.size << endl;
        cout << "Silence: " << (int) obtained.silence << endl;
#endif
    }
}


Audio::~Audio()
{
}

void Audio::SetAmplification(float ampl)
{
    ampl = ampl;
}

void Audio::SetSource(SynthContainer* synthcontainer)
{
    source = synthcontainer;
}

void Audio::mix(Uint8* stream, int len)
{
    int16_t* renderpos = (int16_t*) stream;
    int16_t* renderend = (int16_t*) (stream + len);

    while (renderpos < renderend) {
        if (rawbuf_pos >= (AUDIO_CHANNELS * AUDIO_STEP_SIZE)) {
            step_audio();
            rawbuf_pos = 0;
        }

        for (int c=0; c < AUDIO_CHANNELS; c++) {
//            if ((ampl * rawbuf[rawbuf_pos]) >= 32767 || ampl * rawbuf[rawbuf_pos] <= -32767) {
//                ampl = 32767.0f / rawbuf[rawbuf_pos];
//                if (ampl < 0) { ampl = -ampl; }
//                if (ampl < 100) { ampl = 100; }
//            }
            *(renderpos++) = (int16_t) (ampl * rawbuf[rawbuf_pos++]);
        }
    }
}

void Audio::step_audio()
{
    source->Step(step_no++);
    rawbuf = source->GetOutputStream();
}

void Audio::Start()
{
    step_audio();
    SDL_PauseAudio(0);
}

void Audio::Stop()
{
    SDL_PauseAudio(1);
}
