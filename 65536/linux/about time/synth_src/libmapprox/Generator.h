/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef __GENERATOR_H
#define __GENERATOR_H

#include "MapproxBase.h"
#include "BitBuffer.h"

namespace Mapprox
{

class Generator
{
    public:
        typedef enum { GEN_SINE, GEN_SAW, GEN_SQUARE, GEN_GAUSS, GEN_POW, GEN_NOISE } basefunc_t;
        static const int max_polyphony = 128;
        static const int max_user_harmonics = 8;

        // Envelopes.
        typedef struct
        {
            int length;
            bool loop;
            int loop_start;
            int loop_end;

            int duration[8];
            float value[8];
        }
        EnvelopeData;
        static const int envelope_durations[];

        typedef struct
        {
            int8_t octave;
            int8_t semitone;
            int8_t finetune;
        }
        transpose_t;
    private:
        sample_t* wavetable_data[16];
        int wavetable_cycle_length[16];
        int user_harmonics[max_user_harmonics];
        basefunc_t basefunc;
        transpose_t transpose;
        float transpose_f;
        float pitch_bend;
        bool enabled;
        bool using_wavetables;
        float pitch_env_scale;
        float filter_resonance;
        bool filter_lowpass;

        EnvelopeData volume_env;
        EnvelopeData pitch_env;
        EnvelopeData filter_env;

        typedef struct
        {
            int seg_num;
            int next_seg;
            float val;
            float rate;
            float step;
            bool looping;
            bool running;
        }
        envelope_status;

        void init_envelope_status ( envelope_status& es );
        void trigger_envelope ( EnvelopeData& ed, envelope_status& es );
        void step_envelope ( EnvelopeData& ed, envelope_status& es );
        void calc_envelope_segment ( EnvelopeData& ed, envelope_status& es );
        void gate_envelope ( EnvelopeData& ed, envelope_status& es );

        // Low pass filter
        typedef struct
        {
            float a1;
            float a2;
            float a3;
            float b1;
            float b2;

            sample_t in1, in2;
            sample_t out1, out2;
        }
        filter_t;

        void init_filter ( filter_t& filter );
        void set_filter ( filter_t& filter, float cutoff );
        sample_t do_filter ( filter_t& filter, sample_t v );

        // Complete set of phoneme parameters
        typedef struct
        {
            // Wave playback position
            float pos;
            float freq;
            float note;
            float rate;
            int wave_no;
            int running;
            float volume;
            // General purpose variables
            float a, b, c, d;

            envelope_status volume_status;
            envelope_status pitch_status;
            envelope_status filter_status;

            filter_t filter;
        }
        phoneme_t;

        phoneme_t phonemes[max_polyphony];

        sample_t render_saw ( float pos, float freq, phoneme_t* p );
        sample_t render_sine ( float pos, float freq, phoneme_t* p );
        sample_t render_pow ( float pos, float freq, phoneme_t* p );
        sample_t render_gauss ( float pos, float freq, phoneme_t* p );
        sample_t render_square ( float pos, float freq, phoneme_t* p );
        void push_envelope ( BitBuffer& buffer, EnvelopeData& envelope );
        void load_envelope ( BitBuffer& buffer, EnvelopeData& envelope );
        sample_t ( Mapprox::Generator::*render_function ) ( float pos, float freq, phoneme_t* p );
    public:

        Generator();
        void GenerateAdd ( sample_t* data ); // Adds data to pointer.  doesn't wipe
        void SetBaseFunc ( basefunc_t basefunc );
        void PlayPhoneme ( int phoneme, float volume );
        void GatePhoneme ( int phoneme );
        void UpdateFrequency ( int phoneme );
        void UpdateFilter ( int phoneme );
        void RenderWavetable();
        void SetNote ( int phoneme, int note );
        void SetPitchBend ( float p );
        void LoadData ( BitBuffer& buffer );
        void Panic();
        void SetEnabled ( bool en ) { enabled = en; }
        bool Enabled() { return enabled; }
        int FindPhoneme();
#ifndef DEMO
        void SetHarmonic ( int harmonic, int value );
        int GetHarmonic ( int harmonic ) { return user_harmonics[harmonic]; }
        basefunc_t GetBaseFunc ( ) { return basefunc; }
        EnvelopeData* GetVolumeEnv() { return &volume_env; }
        EnvelopeData* GetPitchEnv() { return &pitch_env; }
        EnvelopeData* GetFilterEnv() { return &filter_env; }
        float GetPitchScale() { return pitch_env_scale; }
        void SetPitchScale ( float s ) { pitch_env_scale = s; }
        transpose_t GetTranspose() { return transpose; }
        void SetTranspose ( transpose_t t );
        void PushData ( BitBuffer& buffer );
        void SetResonance( int val );
#endif
};

}

#endif // __GENERATOR_H
