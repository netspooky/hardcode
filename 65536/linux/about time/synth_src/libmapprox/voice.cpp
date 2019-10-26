/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#include <string.h>
#include "voice.h"

using namespace Mapprox;

Voice::Voice()
{
    nna = NNA_GATE;
    priority_generator = 0;
    enabled = 1;
    reverb_send = 0;
    SetDistortionThreshold ( 15 );

    generators[0].SetEnabled ( 1 );

    for ( int g = 1; g < max_generators; g++ )
    {
        generators[g].SetEnabled ( 0 );
    }

    for ( int c = 0; c < AUDIO_CHANNELS; c++ )
    {
        delays[c].SetDelay ( ( 4*AUDIO_FREQ*8 ) / 50 );
        delays[c].SetFeedback ( 0 );
        gains[c] = 1;
    }

    for ( int i = 0; i < 256; i++ )
    {
        phoneme_map[i] = -1;
    }

    SetName ( "untitled" );

    RenderWavetables();
}

Voice::~Voice()
{}

void Voice::SetName ( const char* newname )
{
    strncpy ( name, newname, name_length );
}

const char* Voice::GetName() const
{
    return name;
}

void Voice::Generate ( sample_t* data )
{
    memset ( mixbuf, 0, sizeof ( mixbuf ) );

    for ( int g = 0; g < max_generators; g++ )
    {
        if ( generators[g].Enabled() )
        {
            generators[g].GenerateAdd ( mixbuf );
        }
    }

    for ( int s = 0; s < AUDIO_STEP_SIZE*AUDIO_CHANNELS; )
    {
        for ( int c = 0; c < AUDIO_CHANNELS; c++ )
        {
            sample_t output = mixbuf[s];
            output *= gains[c];
            output += undenormalize ( delays[c].ProcessDelay ( output ) );

            // Do distortion

            if ( output > distortion_threshold )
            {
                output = distortion_threshold - ( output - distortion_threshold );
            }
            else if ( output < -distortion_threshold )
            {
                output = -distortion_threshold + ( -distortion_threshold - output );
            }

            data[s] = output;

            s++;
        }
    }

}

void Voice::RenderWavetables()
{
    for ( int g = 0; g < max_generators; g++ )
    {
        if ( generators[g].Enabled() )
        {
            generators[g].RenderWavetable();
        }
    }
}

Generator* Voice::GetGenerator ( int gen )
{
    return &generators[gen];
}

#ifndef DEMO
void Voice::PushData ( BitBuffer& buffer )
{
    buffer.PushByte ( enabled );

    if ( !enabled )
    {
        return;
    }

    for ( int g = 0; g < max_generators; g++ )
    {
        generators[g].PushData ( buffer );
    }

    for ( int c = 0; c < AUDIO_CHANNELS; c++ )
    {
        delays[c].PushData ( buffer );
    }

    for ( int c = 0; c < AUDIO_CHANNELS; c++ )
    {
        buffer.PushFloat ( gains[c] );
    }

    buffer.PushFloat ( reverb_send );

    buffer.PushByte ( distortion_threshold_int );
}
#endif

void Voice::LoadData ( BitBuffer& buffer )
{
    enabled = buffer.FetchByte();

    if ( !enabled )
    {
        return;
    }

    for ( int g = 0; g < max_generators; g++ )
    {
        generators[g].LoadData ( buffer );
    }

    for ( int c = 0; c < AUDIO_CHANNELS; c++ )
    {
        delays[c].LoadData ( buffer );
    }

    for ( int c = 0; c < AUDIO_CHANNELS; c++ )
    {
        gains[c] = buffer.FetchFloat();
    }

    reverb_send = buffer.FetchFloat();

    SetDistortionThreshold ( buffer.FetchByte() );
}

void Voice::Panic()
{
    for ( int i = 0; i < max_generators; i++ )
    {
        generators[i].Panic();
    }
}

void Voice::SetDistortionThreshold ( int threshold )
{
    static const float thresholds[] = { 0.01, 0.02, 0.04, 0.08, 0.16, 0.32, 0.64, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 };

    distortion_threshold_int = threshold;
    distortion_threshold = thresholds[threshold];
}

void Voice::NoteOn ( int note, int velocity )
{
    int phoneme = generators[0].FindPhoneme();

    for ( int g = 0; g < max_generators; g++ )
    {
        if ( phoneme_map[note] != -1 )
        {
            generators[g].GatePhoneme ( phoneme_map[note] );
        }

        generators[g].SetNote ( phoneme, note );

        generators[g].PlayPhoneme ( phoneme, ( float ) velocity / 128.0f );
    }

    phoneme_map[note] = phoneme;
}

void Voice::NoteOff ( int note, int velocity )
{
    if ( phoneme_map[note] != -1 )
    {
        for ( int g = 0; g < max_generators; g++ )
        {
            generators[g].GatePhoneme ( phoneme_map[note] );
        }

        phoneme_map[note] = -1;
    }
}
