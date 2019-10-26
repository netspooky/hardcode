/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#include "Reverb.h"

namespace Mapprox
{
const float Reverb::comb_init[comb_filters] =
{
    0.02530612244897959184,
    0.02693877551020408163,
    0.02895691609977324263,
    0.03074829931972789116,
    0.03224489795918367347,
    0.03380952380952380952,
    0.03530612244897959184,
    0.03666666666666666667
};

const float Reverb::allpass_init[allpass_filters] =
{
    0.01260770975056689342,
    0.01,
    0.007732426303854875283,
    0.005102040816326530612
};

Reverb::Reverb()
{
    for ( int i=0; i<comb_filters; i++ )
    {
        combs[i].SetDelay ( comb_init[i] * ( float ) AUDIO_FREQ );
        combs[i].SetFeedback ( 0.95 );
        combs[i].SetDamp ( 0.5 );
    }

    for ( int i=0; i<allpass_filters; i++ )
    {
        allpasses[i].SetDelay ( allpass_init[i] * ( float ) AUDIO_FREQ );
        allpasses[i].SetFeedback ( 0.5 );
    }
}

sample_t Reverb::Process ( sample_t input )
{
    sample_t echo = 0;
    input = input * 0.015;

    for ( int c=0; c<comb_filters; c++ )
    {
        echo += combs[c].ProcessComb ( input );
    }

    for ( int a=0; a<allpass_filters; a++ )
    {
        echo = allpasses[a].ProcessAllpass ( echo );
    }

    return echo;
}


}
