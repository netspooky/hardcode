#include "synth.hpp"
#include "common.hpp"
#include "parameters.h"
#include "poly_handler.hpp"
#include "delay.hpp"
#if defined(USE_REVERB)
#include "reverb.hpp"
#endif

#if defined(WIN32)
#include <cstdio>
#endif

#include "songdata.cpp"

#define AUDIO_FREQUENCY 44100
#define NUM_CHANNELS 7 //7 synth channels (+ 2 effect channels)

void generate_audio(int16_t* audio_buffer, unsigned buffer_length)
{
  int16_t* out = audio_buffer;
  uint32_t i,event_index,next_event_timestamp;
  int32_t k,events_left,total_events_left;
  float temp[8]; //temp samples, interleaved stereo, temp/fx1/fx2/out

  PolyHandler g_channel[NUM_CHANNELS];
  Delay g_delay;
#if defined(USE_REVERB)
  Reverb g_reverb;
#endif
  
//initializing channels with instrument parameter sets
  g_channel[2].init(syn3_channel_params, k_num_synth_params);
  g_channel[3].init(syn4_channel_params, k_num_synth_params);
  g_channel[4].init(syn5_channel_params, k_num_synth_params);
  g_channel[5].init(syn6_channel_params, k_num_synth_params);
  g_channel[6].init(syn7_channel_params, k_num_synth_params);
  g_channel[1].init(syn2_channel_params, k_num_synth_params);
  g_channel[0].init(syn1_channel_params, k_num_synth_params);
  //initializing fx channels
  g_delay.init(fx1_channel_params, FX::k_num_fx_params);
#if defined(USE_REVERB)
  g_reverb.init(fx2_channel_params, FX::k_num_fx_params);
#endif
    

  float division = static_cast<float>(g_song_data[4]);
  float tempo = static_cast<float>(g_song_data[9]);
  float srtick = ((static_cast<float>(AUDIO_FREQUENCY) / 1000000.0f) * (tempo / division));

  event_index = 0;
  total_events_left = ((sizeof(g_song_data) / sizeof(*g_song_data)) / 5);

  if ((event_index * 5)<(sizeof(g_song_data) / sizeof(*g_song_data)))
  {
    next_event_timestamp = static_cast<unsigned>(common::clrintf(static_cast<float>(g_song_data[event_index * 5]) * srtick));
  }
  for (i = 0; (i < (buffer_length / sizeof(uint16_t) / 2)); ++i)
  {
    //process control data
    if ((total_events_left > 0) && (i == next_event_timestamp))
    {
      events_left = 1;
      while (events_left > 0)
      {
        k = static_cast<int32_t>(event_index) * 5;
        unsigned eventnum = g_song_data[k + 1];
        switch (eventnum)
        {
        case k_event_num_standard_note_on:
          if (g_song_data[k + 4] > 0)
          {
            g_channel[g_song_data[k + 2]].noteOn(static_cast<int>(g_song_data[k + 3]),
                static_cast<float>(g_song_data[k + 4]) / 127.0f);
          }
          else
          {
            g_channel[g_song_data[k + 2]].noteOff(static_cast<int>(g_song_data[k + 3]));
          }
          break;

        case k_event_num_standard_pitch_bend:
          g_channel[g_song_data[k + 2]].setParameter(k_pitchbend, static_cast<float>(g_song_data[k + 4]) / 16383.0f);
          break;

        case k_event_num_custom_nrpn:
          g_channel[g_song_data[k + 2]].setParameter(static_cast<int>(g_song_data[k + 3]),
              static_cast<float>(g_song_data[k + 4]) / 16383.0f);
          break;

        case k_event_num_global_division:
          division = static_cast<float>(g_song_data[k + 4]);
          srtick = ((static_cast<float>(AUDIO_FREQUENCY) / 1000000.0f) * (tempo / division));
          break;

        case k_event_num_global_tempo:
          tempo = static_cast<float>(g_song_data[k + 4]);
          srtick = ((static_cast<float>(AUDIO_FREQUENCY) / 1000000.0f) * (tempo / division));
          for (uint8_t channel = 0; channel < NUM_CHANNELS; ++channel)
            g_channel[channel].setParameter(k_tempo, (60000.0f / tempo));
          break;

        default:
          //printf("WARNING: undefined event: %d,%d,%d,%d,%d\n",g_song_data[k],g_song_data[k+1],g_song_data[k+2],
          //  g_song_data[k+3],g_song_data[k+4]);
          break;
        }
        ++event_index;
        --events_left;
        --total_events_left;
        if ((event_index * 5)<(sizeof(g_song_data) / sizeof(*g_song_data)))
        {
          next_event_timestamp += static_cast<unsigned>(
              common::clrintf(static_cast<float>(g_song_data[(event_index)* 5]) * srtick));
          if (g_song_data[(event_index)* 5] == 0)
          {
            ++events_left;
          }
        }
      }
    }

    //process audio

#if defined(WIN32)
    memset(temp, 0, 8 * sizeof(float));
#else
    dnload_memset(temp, 0, 8 * sizeof(float));
#endif

    for(k = 0; k < NUM_CHANNELS; ++k)
      {
      if(g_channel[k].getIsActive())
      {
        g_channel[k].getSample(temp[6], temp[7]);
	if(k==0)
	  {
	    //attempt to make bd stand out a bit, possibly sounds very grating
	    temp[6] = common::rational_tanh(6.5f * temp[6]);
	    temp[7] = common::rational_tanh(6.5f * temp[7]);
            temp[6] *= 0.85f;
            temp[7] *= 0.85f;
	  }
	else if(k==3)
	{
	  temp[6] *= 2.5f * 1.2f;
	  temp[7] *= 2.5f * 1.2f;
	}
	else if (k==2)
	{
	  temp[6] *= 2.5f * 0.9f;
          temp[7] *= 2.5f * 0.9f;	  
	}
	else
	{
	  temp[6] *= 2.5f;
	  temp[7] *= 2.5f;
	}

        temp[0] += temp[6] * g_channel[k].m_out1_level;
        temp[1] += temp[7] * g_channel[k].m_out1_level;
        temp[2] += temp[6] * g_channel[k].m_out2_level;
        temp[3] += temp[7] * g_channel[k].m_out2_level;
#if defined(USE_REVERB)
        temp[4] += temp[6] * g_channel[k].m_out3_level;
        temp[5] += temp[7] * g_channel[k].m_out3_level;
#endif
      }
    }
    if(total_events_left>0)
    {
      g_delay.process(temp[2], temp[3], temp[2], temp[3]);
#if defined(USE_REVERB)
      g_reverb.process(temp[4], temp[5]);
#endif
    }
    else
    {
      break;
    }

#if defined(USE_REVERB)
    temp[0] += temp[2] + temp[4];
    temp[1] += temp[3] + temp[5];
#else
    temp[0] += temp[2];
    temp[1] += temp[3];
#endif

    #if 0
    {
      static float out_max = -FLT_MAX;
      static float out_min = FLT_MAX;
      float new_max = common::cfmaxf(common::cfmaxf(fabsf(temp[0]), fabsf(temp[1])), out_max);
      float new_min = -common::cfminf(common::cfminf(fabsf(temp[0]), fabsf(temp[1])), out_min);

      if(new_max > out_max)
      {
        printf("new output maximum; %1.3f\n", new_max);
        out_max = new_max;
      }
      if(new_min < out_min)
      {
        printf("new output minimum; %1.3f\n", new_min);
        out_min = new_min;
      }
    }
    #endif

#if defined(APPROXIMATE_TANH)
    temp[0] = common::rational_tanh(temp[0]);
    temp[1] = common::rational_tanh(temp[1]);
#else
#if defined(WIN32)
    temp[0] = tanhf(temp[0]);
    temp[1] = tanhf(temp[1]);
#else
    temp[0] = dnload_tanhf(temp[0]);
    temp[1] = dnload_tanhf(temp[1]);
#endif
#endif

    out[i * 2 + 0] = static_cast<int16_t>(temp[0] * 32760.f); //left channel;
    out[i * 2 + 1] = static_cast<int16_t>(temp[1] * 32760.f); //right channel
#if defined(USE_LD)
    if((i % ((buffer_length / sizeof(int16_t) / 2) / 100)) == 0)
    {
      unsigned blen = buffer_length / sizeof(int16_t) / 2;
      printf("|sample(%1.2f): %d / %u\n", static_cast<float>(i) / static_cast<float>(blen), i, blen);
    }
#endif
  }
}

