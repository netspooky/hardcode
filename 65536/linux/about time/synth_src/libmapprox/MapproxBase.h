/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef __MAPPROX_H
#define __MAPPROX_H

#include <stdint.h>

namespace Mapprox
{

    typedef float sample_t;

    const int AUDIO_CHANNELS = 2;
    const int AUDIO_FREQ = 48000;
    const int AUDIO_SPS_PER_FRAME = 1024; // Must be >= STEP_SIZE
    const int AUDIO_STEP_SIZE = 32; // Don't mess with this - you'll fuck up the timing
    const float BASE_FREQ = 55; // A very low A

    const float FILTER_CUTOFF_MAX = 24000.0f;

    typedef enum
    {
        NOTE_C, NOTE_Db, NOTE_D, NOTE_Eb, NOTE_E, NOTE_F, NOTE_Gb, NOTE_G, NOTE_Ab, NOTE_A, NOTE_Bb, NOTE_B
    } note_t;

    static inline float undenormalize ( volatile float f )
    {
        f += 9.8607615E-32f;
        return f - 9.8607615E-32f;
    }

}

#endif // __MAPPROX_H
