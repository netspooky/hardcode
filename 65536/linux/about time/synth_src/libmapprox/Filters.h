/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef __REVERB_H
#define __REVERB_H

#include "MapproxBase.h"
#include "BitBuffer.h"

namespace Mapprox
{

namespace Filters
{
class Delay
{
    public:
        static const int max_delay = AUDIO_FREQ * 5;
    private:
        float feedback;
        float filterstore;
        float damp1;
        float damp2;

        int delay;
        int idx;
        sample_t buffer[max_delay];
    public:
        Delay();
        void SetDamp ( float damp ) { damp1 = damp; damp2 = 1-damp; }
        void SetDelay ( int d ) { delay = d; }
        void SetFeedback ( float f ) { feedback = f; }
#ifndef DEMO
        int GetDelay() { return delay; }
        float GetFeedback() { return feedback; }
        void PushData( BitBuffer& buffer );
#endif
        void LoadData( BitBuffer& buffer );

        sample_t ProcessComb ( sample_t input );
        sample_t ProcessDelay ( sample_t input );
        sample_t ProcessAllpass ( sample_t intput );
};


}

}


#endif // __REVERB_H
