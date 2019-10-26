/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef __SONG_H
#define __SONG_H

#include "Generator.h"
#include "voice.h"
#include "Reverb.h"
#include "Event.h"
#include "BitBuffer.h"

namespace Mapprox
{


class Song
{
public:
    static const int max_song_length = 65536;
private:
    typedef struct
    {
        uint8_t note;
        uint8_t velocity;
        int step_no;
    } save_timed_event_t;

    save_timed_event_t note_on_events[16][max_song_length];
    save_timed_event_t note_off_events[16][max_song_length];

    int nn_event_count[16];
    int nf_event_count[16];
    int nn_event_no[16];
    int nf_event_no[16];

    int step_no;
    int record_start_step;
    int play_start_step;
public:
    Song();
    void LoadData ( BitBuffer& buffer );
    void PushData ( BitBuffer& buffer );
    void Step(int step) { step_no = step; }
    long GetTicks();
#ifndef DEMO
    void Event(int channel, event_t& event);
    void StartRecording();
    void StopRecording();
#endif
    void StartPlaying();
    void StopPlaying();
    int GetCurrentEvent(event_t& event);
};

}

#endif // __SONG_H
