/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#include <string.h>

#include "SynthContainer.h"

namespace Mapprox 
{

SynthContainer::SynthContainer()
{
#ifndef DEMO
    midi_listener = new MidiListener();
#endif
    song = new Song();
}


SynthContainer::~SynthContainer()
{
}


void SynthContainer::Step ( int step )
{
    memset ( mixbuf, 0, sizeof ( mixbuf ) );
    memset ( wetbuf, 0, sizeof ( wetbuf ) );

    event_t ev;

    song->Step(step_no);

#ifndef DEMO
    int channel;

    while( (channel = midi_listener->GetEvent(ev)) != -1 )
    {
        switch (ev.type)
        {
            case event_type_note_on:
                voices[ev.channel].NoteOn(ev.note.note, ev.note.velocity);
                break;
            case event_type_note_off:
                voices[ev.channel].NoteOff(ev.note.note, ev.note.velocity);
                break;
        };
        song->Event(channel, ev);
    }
#endif

    while (song->GetCurrentEvent(ev))
    {
        switch(ev.type)
        {
            case event_type_note_on:
                voices[ev.channel].NoteOn(ev.note.note, ev.note.velocity);
                break;
            case event_type_note_off:
                voices[ev.channel].NoteOff(ev.note.note, ev.note.velocity);
                break;
        };

    }

    for ( int voice=0; voice<max_voices; voice++ )
    {
        voices[voice].Generate ( voicemixbuf );

        for ( int s=0; s<AUDIO_STEP_SIZE * AUDIO_CHANNELS; )
        {
            for ( int c=0; c<AUDIO_CHANNELS; c++ )
            {
                sample_t dry = voicemixbuf[s];
                mixbuf[s] += dry;
                wetbuf[s] += dry * voices[voice].GetReverbSend();
                s++;
            }
        }
    }

    for ( int s=0; s<AUDIO_STEP_SIZE * AUDIO_CHANNELS; )
    {
        for ( int c=0; c<AUDIO_CHANNELS; c++ )
        {
            mixbuf[s] += reverbs[c].Process(wetbuf[s]);
            s++;
        }
    }
    
    step_no = step;
}

void SynthContainer::Stop()
{
#ifndef DEMO 
    song->StopRecording();
#endif
     song->StopPlaying(); 
}

void SynthContainer::LoadData(BitBuffer& buffer)
{ 
    song->LoadData(buffer);
    for (int v=0; v<max_voices; v++)
    {
        voices[v].LoadData(buffer);
    }
}
   
#ifndef DEMO 
void SynthContainer::PushData(BitBuffer& buffer) 
{
     song->PushData(buffer); 
     for (int v=0; v<max_voices; v++)
     {
         voices[v].PushData(buffer);
     }
}
#endif

}
