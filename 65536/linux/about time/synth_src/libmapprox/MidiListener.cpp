/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#include "MidiListener.h"

#include <unistd.h>

namespace Mapprox
{

#ifndef DEMO

MidiListener::MidiListener()
{
    if ( snd_seq_open ( &seq_handle, "default", SND_SEQ_OPEN_INPUT, 0 ) < 0 )
    {
#ifdef DEBUG
        cerr << "Error opening ALSA sequencer." << endl;
        exit ( 1 );
#endif
    }

    snd_seq_set_client_name ( seq_handle, "Mapprox" );

    if ( snd_seq_create_simple_port ( seq_handle, "Mapprox",
                                      SND_SEQ_PORT_CAP_WRITE | SND_SEQ_PORT_CAP_SUBS_WRITE,
                                      SND_SEQ_PORT_TYPE_APPLICATION ) < 0 )
    {
#ifdef DEBUG
        cerr << "Error creating sequencer port." << endl;
        exit ( 1 );
#endif
    }
}


MidiListener::~MidiListener()
{
    snd_seq_close ( seq_handle );
}

int MidiListener::GetEvent ( event_t& event )
{
    snd_seq_event_t* ev;
    int rval = -1;

    if (snd_seq_event_input_pending(seq_handle, 1))
    {
        snd_seq_event_input ( seq_handle, &ev );

        switch ( ev->type )
        {
            case SND_SEQ_EVENT_CONTROLLER:
                break;
            case SND_SEQ_EVENT_PITCHBEND:
                break;
            case SND_SEQ_EVENT_NOTEON:
                rval = ev->data.note.channel;
                event.type = event_type_note_on;
                event.channel = ev->data.note.channel;
                event.note.note = ev->data.note.note;
                event.note.velocity = ev->data.note.velocity;
                break;
            case SND_SEQ_EVENT_NOTEOFF:
                rval = ev->data.note.channel;
                event.type = event_type_note_off;
                event.channel = ev->data.note.channel;
                event.note.note = ev->data.note.note;
                event.note.velocity = ev->data.note.velocity;
                break;
        }

        snd_seq_free_event ( ev );
    }
    
    return rval;
}

#endif

}

