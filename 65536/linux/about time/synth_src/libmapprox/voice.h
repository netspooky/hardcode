/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef MAPPROXVOICE_H
#define MAPPROXVOICE_H

#include "Generator.h"
#include "BitBuffer.h"
#include "Filters.h"
#include "Reverb.h"

namespace Mapprox
{

class Voice
{
    public:
        static const int max_generators = 4;
        static const int name_length = 16;

        typedef struct
        {
            int depth;
            int rate;
        } PhaserParams;
    private:
        typedef enum { NNA_DISABLED, NNA_CUT, NNA_GATE, NNA_PASS }
        nna_t;
        nna_t nna;
        int priority_generator;
        bool enabled;
        Generator generators[max_generators];
        char name[name_length];
        sample_t mixbuf[AUDIO_STEP_SIZE*AUDIO_CHANNELS];
        Filters::Delay delays[AUDIO_CHANNELS];
        float gains[AUDIO_CHANNELS];
        float reverb_send;
        int distortion_threshold_int;
        sample_t distortion_threshold;
        int phoneme_map[255];
    public:
        Voice();
        ~Voice();
        void tick();
        void Generate ( sample_t* data );
        bool Enabled() { return enabled; }
        void SetEnabled() { enabled = 1; }
        void RenderWavetables();
        void SetName ( const char* newname );
        const char* GetName() const;
        Generator* GetGenerator ( int gen );
        void LoadData ( BitBuffer& buffer );
        void Panic();
        void NoteOn(int note, int velocity);
        void NoteOff(int note, int velocity);
        // Effects
        void SetReverbSend ( float send ) { reverb_send = send; }
        void SetDelayAmount ( int channel, int amount ) { delays[channel].SetDelay ( amount ); }
        void SetDelayFeedback ( int channel, sample_t feedback ) { delays[channel].SetFeedback ( feedback ); }
        void SetGain ( int channel, int value ) { gains[channel] = ( float ) value * 8.0f / 16.0f; }
        void SetDistortionThreshold ( int threshold );
        float GetReverbSend() { return reverb_send; }
#ifndef DEMO
        void PushData ( BitBuffer& buffer );
        int GetDelayAmount ( int channel ) { return delays[channel].GetDelay(); }
        int GetGain ( int channel ) { return gains[channel] * 16.0f / 8.0f; }
        int GetDistortionThreshold() { return distortion_threshold_int; }
        sample_t GetDelayFeedback ( int channel ) { return delays[channel].GetFeedback(); }
#endif
};

}

#endif
