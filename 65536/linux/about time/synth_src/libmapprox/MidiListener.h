/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef MAPPROXMIDILISTENER_H
#define MAPPROXMIDILISTENER_H

#include <alsa/asoundlib.h>

#include "Event.h"

namespace Mapprox 
{

#ifndef DEMO
    
class MidiListener
{
    snd_seq_t *seq_handle;
public:
    MidiListener();
    ~MidiListener();

    int GetEvent(event_t& ne);
};

#endif

}

#endif

