#include "Filters.h"
#include <string.h>

using namespace Mapprox;
using namespace Mapprox::Filters;

/* Multi purpose buffer filter */

Delay::Delay()
{
    memset ( buffer, 0, sizeof ( buffer ) );
    feedback = 0;
    delay = 10000;
    idx = 0;
}

#ifndef DEMO
void Delay::PushData( BitBuffer& buffer)
{
    buffer.PushFloat(feedback);
    buffer.PushLong(delay);
}
#endif

void Delay::LoadData( BitBuffer& buffer )
{
    feedback = buffer.FetchFloat();
    delay = buffer.FetchLong();
}

sample_t Delay::ProcessComb ( sample_t input )
{
    sample_t output = buffer[idx];
    filterstore = ( output*damp1 ) + ( filterstore*damp2 );
    buffer[idx] = input + ( filterstore * feedback );
    if ( ++idx >= delay )
        idx = 0;

    return output;
}

sample_t Delay::ProcessDelay ( sample_t input )
{
    sample_t output = buffer[idx];
    buffer[idx] = (buffer[idx] + input) * feedback;
    if ( ++idx >= delay )
        idx = 0;

    return output;
}

sample_t Delay::ProcessAllpass ( sample_t input )
{
    sample_t bufout = buffer[idx];
    sample_t output = bufout - input;
    buffer[idx] = input + (bufout * feedback);
    if (++idx >= delay)
        idx = 0;

    return output;
}
