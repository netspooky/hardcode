/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#include "Generator.h"
#include <stdlib.h>
#include <assert.h>
#include <math.h>

using namespace Mapprox;

const int Generator::envelope_durations[] = {
    0, 1, 2, 3, 5, 6, 13, 22, 37, 62, 105, 178, 302, 513, 872, 1482
};

Generator::Generator()
{
    float basepitch = BASE_FREQ;
    transpose_f = 0;
    transpose.octave = 0;
    transpose.semitone = 0;
    transpose.finetune = 0;
    pitch_bend = 0;

    filter_resonance = 1;
    filter_lowpass = 1;

    for ( int i=0; i<max_polyphony; i++ )
    {
        phonemes[i].pos=0;
        phonemes[i].rate = 0;
        phonemes[i].wave_no = 0;
        phonemes[i].freq = 440;
        phonemes[i].a = phonemes[i].b = phonemes[i].c = phonemes[i].d = 0;
        phonemes[i].volume = 1;

        init_envelope_status ( phonemes[i].volume_status );
        init_envelope_status ( phonemes[i].pitch_status );
        init_envelope_status ( phonemes[i].filter_status );

        init_filter ( phonemes[i].filter );
    }

    for ( int i=0; i<max_user_harmonics; i++ )
    {
        user_harmonics[i] = 0;
    }
    user_harmonics[0] = 15;

    for ( int i=0; i<8; i++ )
    {
        volume_env.duration[i] = 10;
        volume_env.value[i] = 0;
    }

    volume_env.length = 3;
    volume_env.loop_start = 0;
    volume_env.loop_end = 1;
    volume_env.loop = 1;
    volume_env.duration[0] = 1;
    volume_env.duration[1] = 6;
    volume_env.duration[2] = 1;
    volume_env.value[0] = 1;
    volume_env.value[1] = 1;
    volume_env.value[2] = 0;

    pitch_env_scale = 0.2;
    for ( int i=0; i<8; i++ )
    {
        pitch_env.duration[i] = 10;
        pitch_env.value[i] = 0;
    }

    pitch_env.length = 4;
    pitch_env.loop_start = 0;
    pitch_env.loop_end = 3;
    pitch_env.loop = 1;
    pitch_env.duration[0] = 1;
    pitch_env.duration[1] = 10;
    pitch_env.duration[2] = 11;
    pitch_env.duration[3] = 10;
    pitch_env.value[0] = 0;
    pitch_env.value[1] = 1;
    pitch_env.value[2] = -1;
    pitch_env.value[3] = 0;

    for ( int i=0; i<8; i++ )
    {
        filter_env.duration[i] = 100;
        filter_env.value[i] = 0;
    }

    filter_env.length = 3;
    filter_env.loop_start = 0;
    filter_env.loop_end = 2;
    filter_env.loop = 1;
    filter_env.duration[0] = 4;
    filter_env.duration[1] = 10;
    filter_env.duration[2] = 10;
    filter_env.value[0] = 0.5;
    filter_env.value[1] = 1;
    filter_env.value[2] = 0.5;

    for ( int i=0; i<16; i++ )
    {
        wavetable_cycle_length[i] = ( int ) ( AUDIO_FREQ / basepitch );
        wavetable_data[i] = ( sample_t* ) malloc ( sizeof ( sample_t ) * wavetable_cycle_length[i] );
        basepitch *= 2.0;
    }

    enabled = 0;

    SetBaseFunc ( GEN_SINE );
}

void Generator::init_envelope_status ( envelope_status& es )
{
    es.seg_num = 0;
    es.val = 0;
    es.rate = 0;
    es.step = 0;
    es.looping = 0;
    es.running = 0;
}

void Generator::trigger_envelope ( EnvelopeData& ed, envelope_status& es )
{
    es.seg_num = 0;
    es.val = 0;
    es.running = 1;
    es.looping = ed.loop;

    calc_envelope_segment ( ed, es );
}

void Generator::calc_envelope_segment ( EnvelopeData& ed, envelope_status& es )
{
    if ( es.looping )
    {
        if ( es.seg_num > ed.loop_end )
        {
            es.seg_num = ed.loop_start+1;
        }
    }
    else if ( es.seg_num >= ed.length )
    {
        es.running = 0;
        es.rate = 0;
        return;
    }

    es.step = 0;
    if ( ed.duration[es.seg_num] >= 0 )
    {
        es.rate = ( ed.value[es.seg_num]- es.val ) / ( envelope_durations[ed.duration[es.seg_num]] * AUDIO_STEP_SIZE );
    }
    else
    {
        es.val = ed.value[es.seg_num];
        es.rate = 0;
    }
}

void Generator::gate_envelope ( EnvelopeData& ed, envelope_status& es )
{
    es.looping = 0;
    es.seg_num = ed.loop_end+1;
    if ( es.seg_num >= ed.length ) { es.seg_num = ed.length; }
    calc_envelope_segment ( ed, es );
}

void Generator::step_envelope ( EnvelopeData& ed, envelope_status& es )
{
    if ( es.running )
    {
        es.step++;
        if ( es.step >= envelope_durations[ed.duration[es.seg_num]] )
        {
            es.step = 0;
            es.seg_num++;

            calc_envelope_segment ( ed, es );
        }
    }
}

void Generator::init_filter ( filter_t& filter )
{
    filter.in1 = 0;
    filter.in2 = 0;
    filter.out1 = 0;
    filter.out2 = 0;
}

void Generator::set_filter ( filter_t& filter, float cutoff )
{
    if (filter_lowpass)
    {
        float c = 1.0f / tan ( M_PI * cutoff / ( float ) AUDIO_FREQ );
    
        filter.a1 = 1.0f / ( 1.0f + ( filter_resonance * c ) + ( c*c ) );
        filter.a2 = 2 * filter.a1;
        filter.a3 = filter.a1;
        filter.b1 = 2.0f * ( 1.0f - ( c*c ) ) * filter.a1;
        filter.b2 = ( 1.0f - ( filter_resonance*c ) + ( c*c ) ) * filter.a1;
    }
    /* else {
    float c = tan( M_PI * cutoff / (float) AUDIO_FREQ);

    filter.a1 = 1.0 / ( 1.0 + filter_resonance * c + c * c);
    filter.a2 = -2*filter.a1;
    filter.a3 = filter.a1;
    filter.b1 = 2.0 * ( c*c - 1.0) * filter.a1;
    filter.b2 = ( 1.0 - filter_resonance * c + c * c) * filter.a1;
    */

    filter.a1 = undenormalize(filter.a1);
    filter.a2 = undenormalize(filter.a2);
    filter.a3 = undenormalize(filter.a3);
    filter.b1 = undenormalize(filter.b1);
    filter.b2 = undenormalize(filter.b2);
}

sample_t Generator::do_filter ( filter_t& filter, sample_t in )
{
    sample_t out;

    out = ( filter.a1 * in ) + ( filter.a2 * filter.in1 ) + ( filter.a3 * filter.in2 );
    out -= ( filter.b1 * filter.out1 ) + ( filter.b2 * filter.out2 );

    filter.out2 = undenormalize(filter.out1);
    filter.out1 = undenormalize(out);

    filter.in2 = undenormalize(filter.in1);
    filter.in1 = undenormalize(in);

    return out;

}

int Generator::FindPhoneme()
{
    int phoneme = 0;

    // Find a free phoneme
    for ( int i=0; i<max_polyphony; i++ )
    {
        if ( !phonemes[i].volume_status.running )
        {
            phoneme = i;
            break;
        }
    }
    // If we didn't find one, we default to 0.
    return phoneme;
}

void Generator::PlayPhoneme ( int phoneme, float volume )
{
    if ( enabled )
    {
        trigger_envelope ( volume_env, phonemes[phoneme].volume_status );
        trigger_envelope ( pitch_env, phonemes[phoneme].pitch_status );
        trigger_envelope ( filter_env, phonemes[phoneme].filter_status );
        init_filter ( phonemes[phoneme].filter );
        phonemes[phoneme].pos = 0;
        phonemes[phoneme].volume = volume;
    }
}

void Generator::GatePhoneme ( int phoneme )
{
    if ( phonemes[phoneme].volume_status.running )
    {
        gate_envelope ( volume_env, phonemes[phoneme].volume_status );
        gate_envelope ( filter_env, phonemes[phoneme].filter_status );
        //        gate_envelope ( pitch_env, phonemes[phoneme].pitch_status );
    }
}

void Generator::GenerateAdd ( sample_t* data )
{
    for ( int phoneme=0; phoneme < max_polyphony; phoneme++ )
    {
        phoneme_t& p = phonemes[phoneme];
        if ( p.volume_status.running )
        {
            for ( sample_t* s=data; s < data + ( AUDIO_STEP_SIZE*AUDIO_CHANNELS ); )
            {
                // advance envelope
                p.volume_status.val += p.volume_status.rate;
                p.pitch_status.val += p.pitch_status.rate;
                p.filter_status.val += p.filter_status.rate;

                // Might need to remove this.
                // UpdateFrequency ( phoneme );

                int wavepos = static_cast<int> ( p.pos * wavetable_cycle_length[p.wave_no] );
                sample_t waveval_raw;
                if ( using_wavetables )
                {
                    waveval_raw = wavetable_data[p.wave_no][wavepos] * p.volume_status.val;
                }
                else
                {
                    waveval_raw = ( this->*render_function ) ( wavepos, p.pitch_status.val, &p ) * p.volume_status.val;
                }
                sample_t waveval_wet = do_filter ( p.filter, waveval_raw * p.volume);
                for ( int c=0; c<AUDIO_CHANNELS; c++ )
                {
                    * ( s++ ) += waveval_wet;
                }
                p.pos += p.rate;
                if ( p.pos >= 1 )
                    p.pos--;
            }

            step_envelope ( volume_env, p.volume_status );
            step_envelope ( pitch_env, p.pitch_status );
            step_envelope ( filter_env, p.filter_status );
            UpdateFrequency ( phoneme );
            UpdateFilter ( phoneme );
        }
    }
}

#ifndef DEMO
void Generator::SetHarmonic ( int harmonic, int value )
{
    assert ( harmonic >= 0 && harmonic <= 7 );
    assert ( value >= 0 && value <= 15 );

    user_harmonics[harmonic] = value;
}
#endif

void Generator::SetBaseFunc ( basefunc_t b )
{
    basefunc = b;

    switch ( basefunc )
    {
        case GEN_SINE:
            render_function = &Mapprox::Generator::render_sine;
            using_wavetables = true;
            break;
        case GEN_SAW:
            render_function = &Mapprox::Generator::render_saw;
            using_wavetables = true;
            break;
        case GEN_POW:
            render_function = &Mapprox::Generator::render_pow;
            using_wavetables = true;
            break;
        case GEN_SQUARE:
            render_function = &Mapprox::Generator::render_square;
            using_wavetables = true;
            break;
        case GEN_GAUSS:
            render_function = &Mapprox::Generator::render_gauss;
            using_wavetables = false;
            for ( int p=0; p<max_polyphony; p++ )
            {
                phonemes[p].a=0;
                phonemes[p].b=0;
                phonemes[p].c=1;
                phonemes[p].d=0;
            }
            break;
        case GEN_NOISE:
            break;
    }
}

void Generator::RenderWavetable()
{
    if ( !using_wavetables )
    {
        return;
    }

    float freq = BASE_FREQ;

    for ( int i=0; i<16; i++ )
    {
        float pos = 0;
        float rate = freq * 2 * M_PI / AUDIO_FREQ;

        for ( int sample_no=0; sample_no<wavetable_cycle_length[i]; sample_no++ )
        {
            wavetable_data[i][sample_no] = ( ( sample_t ) user_harmonics[0] / 16.0f ) * ( this->*render_function ) ( pos, freq, NULL );
            for ( int harmonic=1; harmonic<max_user_harmonics; harmonic++ )
            {
                if ( user_harmonics[harmonic] > 0 )
                {
                    wavetable_data[i][sample_no] += ( ( sample_t ) user_harmonics[harmonic] / 16.0f ) * ( this->*render_function ) ( pos* ( harmonic+1 ), freq* ( harmonic+1 ), NULL );
                }
            }
            pos += rate;
            wavetable_data[i][sample_no] *= 0.05;
            wavetable_data[i][sample_no] = undenormalize(wavetable_data[i][sample_no]);
        }

        freq *= 2;
    }
}

sample_t Generator::render_saw ( float pos, float freq, phoneme_t* p )
{
    sample_t output = 0;

    for ( float scale=1; freq * scale < AUDIO_FREQ/2; scale++ )
    {
        output += sinf ( pos*scale ) / scale*1.6;
    }

    return output;
}

sample_t Generator::render_square( float pos, float freq, phoneme_t* p)
{
    sample_t output = 0;

    output = (render_saw(pos, freq, p) - render_saw(pos + M_PI/2, freq, p));

    return output;
}

sample_t Generator::render_sine ( float pos, float freq, phoneme_t* p )
{
    return sinf ( pos );
}

sample_t Generator::render_pow ( float pos, float freq, phoneme_t* p )
{
    const float scale = log ( 2 ) / ( 2.0f * M_PI );
    float wavpos = fmod ( ( pos * scale ), ( scale * 2.0f * M_PI ) );

    return pow ( M_E, wavpos ) - 1;
}

sample_t Generator::render_gauss ( float pos, float freq, phoneme_t* p )
{
    // a - startval
    // b - endval
    // c - lastpos
    // d = gradient

    if ( pos <= p->c )
    {
        p->a = p->b;
        p->b = ( float ) random() / ( ( float ) RAND_MAX*20.0f );
        p->d = ( p->b - p->a );
    }

    p->c = pos;

    return p->a + ( p->d * p->pos );
}

void Generator::SetNote ( int phoneme, int note_num )
{
    phonemes[phoneme].note = note_num;

    UpdateFrequency ( phoneme );
}

void Generator::SetPitchBend ( float p )
{
    pitch_bend = p;
}

void Generator::UpdateFilter ( int phoneme )
{
    set_filter ( phonemes[phoneme].filter, phonemes[phoneme].filter_status.val * 8000 + 10 );
}

void Generator::UpdateFrequency ( int phoneme )
{
    float freq = __builtin_powf ( 2.0,
                                  (
                                      ( float ) phonemes[phoneme].note + transpose_f +
                                      ( phonemes[phoneme].pitch_status.val * pitch_env_scale ) +
                                      60.376316562295926
                                  ) / 12.0 );

    phonemes[phoneme].freq = freq;
    phonemes[phoneme].wave_no = 15;
    while ( wavetable_cycle_length[phonemes[phoneme].wave_no] < ( AUDIO_FREQ *2 / freq ) )
    {
        phonemes[phoneme].wave_no--;
        if ( phonemes[phoneme].wave_no == 0 )
            break;
    }

    phonemes[phoneme].rate = freq / AUDIO_FREQ;

    assert ( phonemes[phoneme].rate < 1.0 );
}

#ifndef DEMO
void Generator::SetTranspose ( transpose_t t )
{
    transpose = t;
    transpose_f = t.octave * 12 + t.semitone;
    transpose_f += ( float ) t.finetune / 16.0f;
}
#endif

#ifndef DEMO
void Generator::SetResonance ( int val )
{
    filter_resonance = (val + 1) * (val + 1);
}
#endif

#ifndef DEMO
void Generator::PushData ( BitBuffer& buffer )
{
    buffer.PushByte ( enabled );
    if ( !enabled )
    {
        return;
    }

    buffer.PushByte ( basefunc );

    for ( int h=0; h<max_user_harmonics; h+=2 )
    {
        buffer.PushTwoNibbles(user_harmonics[h], user_harmonics[h+1]);
    }

    buffer.PushByte ( transpose.octave );
    buffer.PushByte ( transpose.semitone );
    buffer.PushByte ( transpose.finetune );

    push_envelope ( buffer, volume_env );
    push_envelope ( buffer, pitch_env );
    push_envelope ( buffer, filter_env );

    buffer.PushFloat ( pitch_env_scale );
    buffer.PushFloat ( filter_resonance );
}
#endif

void Generator::LoadData ( BitBuffer& buffer )
{
    enabled = buffer.FetchByte();
    if ( !enabled )
    {
        return;
    }

    SetBaseFunc ( ( Generator::basefunc_t ) buffer.FetchByte() );

    for ( int h=0; h<max_user_harmonics; h+=2 )
    {
        buffer.FetchTwoNibbles(user_harmonics[h], user_harmonics[h+1]);
    }

    transpose.octave = buffer.FetchByte();
    transpose.semitone = buffer.FetchByte();
    transpose.finetune = buffer.FetchByte();

    load_envelope ( buffer, volume_env );
    load_envelope ( buffer, pitch_env );
    load_envelope ( buffer, filter_env );

    pitch_env_scale = buffer.FetchFloat ();
    filter_resonance = buffer.FetchFloat ();

    RenderWavetable();
}

void Generator::push_envelope ( BitBuffer& buffer, EnvelopeData& envelope )
{
    buffer.PushTwoNibbles(envelope.length, envelope.loop);
    buffer.PushTwoNibbles(envelope.loop_start, envelope.loop_end);

    for ( int i=0; i<=envelope.length; i+=2 )
    {
        buffer.PushTwoNibbles ( envelope.duration[i], envelope.duration[i+1] );
        buffer.PushByte ( static_cast<uint8_t> ( envelope.value[i] * 127.0f + 128.0f ) );
        buffer.PushByte ( static_cast<uint8_t> ( envelope.value[i+1] * 127.0f + 128.0f ) );
    }
}

void Generator::load_envelope ( BitBuffer& buffer, EnvelopeData& envelope )
{
    int loop;
    buffer.FetchTwoNibbles(envelope.length,  loop);
    envelope.loop = loop;
    buffer.FetchTwoNibbles(envelope.loop_start, envelope.loop_end);

    for ( int i=0; i<=envelope.length; i+=2 )
    {
        buffer.FetchTwoNibbles(envelope.duration[i], envelope.duration[i+1]);
        envelope.value[i] = ( ( float ) buffer.FetchByte() - 128.0f ) / 127.0f;
        envelope.value[i+1] = ( ( float ) buffer.FetchByte() - 128.0f ) / 127.0f;
    }
}


void Generator::Panic()
{
    for ( int i=0; i<max_polyphony; i++ )
    {
        phonemes[i].volume_status.running = 0;
    }
}
