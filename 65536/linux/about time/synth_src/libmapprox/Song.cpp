/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#include "Song.h"

#include <string.h>

namespace Mapprox
{

Song::Song()
{
    record_start_step = 0;
    play_start_step = - 1;

    memset(nn_event_count, 0, sizeof(nn_event_count));
    memset(nf_event_count, 0, sizeof(nf_event_count));
    memset(note_on_events, 0, sizeof(note_on_events));
    memset(note_off_events, 0, sizeof(note_off_events));
    memset(nn_event_no, 0, sizeof(nn_event_no));
    memset(nf_event_no, 0, sizeof(nf_event_no));
}

#ifndef DEMO
void Song::StartRecording() 
{ 
    record_start_step = step_no;
    memset(nn_event_count, 0, sizeof(nn_event_count));
    memset(nf_event_count, 0, sizeof(nf_event_count));
    memset(nn_event_no, 0, sizeof(nn_event_no));
    memset(nf_event_no, 0, sizeof(nf_event_no));
}
#endif

#ifndef DEMO
void Song::StopRecording()
{ 
    record_start_step = 0; 
}
#endif

void Song::StartPlaying() 
{
    memset(nn_event_no, 0, sizeof(nn_event_no));
    memset(nf_event_no, 0, sizeof(nf_event_no));
    play_start_step = step_no;
}

void Song::StopPlaying() { 
    play_start_step = -1; 
}


#ifndef DEMO
void Song::Event(int channel, event_t &ev)
{
    if (record_start_step)
    {
        if (ev.type == event_type_note_on)
        {
            note_on_events[channel][nn_event_count[channel]].note = ev.note.note;
            note_on_events[channel][nn_event_count[channel]].velocity = ev.note.velocity;
            note_on_events[channel][nn_event_count[channel]].step_no = step_no - record_start_step;
            nn_event_count[channel]++;
        } else if (ev.type == event_type_note_off) {
            note_off_events[channel][nf_event_count[channel]].note = ev.note.note;
            note_off_events[channel][nf_event_count[channel]].velocity = ev.note.velocity;
            note_off_events[channel][nf_event_count[channel]].step_no = step_no - record_start_step;
            nf_event_count[channel]++;
        }
    }
}
#endif

int Song::GetCurrentEvent(event_t& ev)
{
    if (play_start_step >= 0)
    {
        for (int v=0; v<16; v++)
        {
            if (nf_event_count[v] && nf_event_no[v] <= nf_event_count[v])
            {
                if (note_off_events[v][nf_event_no[v]].step_no <= step_no - play_start_step)
                {
                    ev.step_no = step_no;
                    ev.type = event_type_note_off;
                    ev.channel = v;
                    ev.note.note = note_off_events[v][nf_event_no[v]].note;
                    ev.note.velocity = note_off_events[v][nf_event_no[v]].velocity;
                    nf_event_no[v]++;
                    return 1;
                }
            }
            
            if (nn_event_count[v] && nn_event_no[v] <= nn_event_count[v])
            {
                if (note_on_events[v][nn_event_no[v]].step_no <= step_no - play_start_step)
                {
                    ev.step_no = step_no;
                    ev.type = event_type_note_on;
                    ev.channel = v;
                    ev.note.note = note_on_events[v][nn_event_no[v]].note;
                    ev.note.velocity = note_on_events[v][nn_event_no[v]].velocity;
                    nn_event_no[v]++;
                    return 1;
                }
            }
            
        }
    }

    return 0;
}

#ifndef DEMO
void Song::PushData ( BitBuffer& buffer )
{
    buffer.PushData(sizeof(nn_event_count), (uint8_t*) nn_event_count);
    buffer.PushData(sizeof(nf_event_count), (uint8_t*) nf_event_count);
 
    for (int v=0; v<16; v++)
    {
        if (nn_event_count[v])
        {
            buffer.PushData(nn_event_count[v] * sizeof(save_timed_event_t), (uint8_t*) note_on_events[v]);
        }
        if (nf_event_count[v])
        {
            buffer.PushData(nf_event_count[v] * sizeof(save_timed_event_t), (uint8_t*) note_off_events[v]);
        }
    }
}
#endif

void Song::LoadData ( BitBuffer& buffer )
{ 
    buffer.FetchData(sizeof(nn_event_count), (uint8_t*) nn_event_count);
    buffer.FetchData(sizeof(nf_event_count), (uint8_t*) nf_event_count);
 
    for (int v=0; v<16; v++)
    {
        if (nn_event_count[v])
        {
            buffer.FetchData(nn_event_count[v] * sizeof(save_timed_event_t), (uint8_t*) note_on_events[v]);
        }
        if (nf_event_count[v])
        {
            buffer.FetchData(nf_event_count[v] * sizeof(save_timed_event_t), (uint8_t*) note_off_events[v]);
        }
    }
}

long Song::GetTicks()
{
    return 100000.0f * ((float)step_no) * (float)AUDIO_STEP_SIZE / (float)AUDIO_FREQ;
}

}
