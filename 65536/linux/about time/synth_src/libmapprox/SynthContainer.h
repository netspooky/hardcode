/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#ifndef MAPPROXSYNTHCONTAINER_H
#define MAPPROXSYNTHCONTAINER_H

#include "Song.h"
#include "Reverb.h"
#include "voice.h"
#include "Event.h"
#include "MidiListener.h"

namespace Mapprox
{

/**
 @author MeteoriK <giles@spacepigs.com>
*/

class SynthContainer
{
public:
    static const int max_voices = 16;
private:
    Song* song;
    int step_no;
#ifndef DEMO
    MidiListener* midi_listener;
#endif
    Reverb reverbs[AUDIO_CHANNELS];
    Voice voices[max_voices];
    sample_t mixbuf[AUDIO_CHANNELS * AUDIO_STEP_SIZE];
    sample_t wetbuf[AUDIO_CHANNELS * AUDIO_STEP_SIZE];
    sample_t voicemixbuf[AUDIO_CHANNELS * AUDIO_STEP_SIZE];
public:
    SynthContainer();
    ~SynthContainer();
    void Step(int step);
    int GetStepNo() { return step_no; }
    long GetTicks() { return song->GetTicks(); }
    sample_t* GetOutputStream() { return mixbuf; }
    void PlaySong() { song->StartPlaying(); }
    void Stop();
    void LoadData(BitBuffer& buffer);

#ifndef DEMO
    Voice* GetVoice ( int voice ) { return &voices[voice]; }
    void PushData(BitBuffer& buffer);
    void RecordSong() { song->StartRecording(); }
#endif
};

}

#endif
