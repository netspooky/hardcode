/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef MAPPROXREVERB_H
#define MAPPROXREVERB_H

#include "Filters.h"

namespace Mapprox
{

class Reverb
{
    private:
        static const int comb_filters = 8;
        static const int allpass_filters = 4;

        static const float comb_init[comb_filters];
        static const float allpass_init[allpass_filters];

        Filters::Delay allpasses[allpass_filters];
        Filters::Delay combs[comb_filters];

        float amount;
    public:
        Reverb();
        sample_t Process ( sample_t input );
        void SetAmount ( float a );

};

}

#endif
