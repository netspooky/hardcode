//pollitty dirtygardenista koska oon mielikuvitukseton paska
#include "synth.hpp"
#include "common.hpp"
#include "parameters.h"
#include "poly_handler.hpp"
#include <float.h>

#if defined(USE_OVERSAMPLING)
#include "BandLimit.h"
#endif

#include "songdata.cpp"

//prints for debugging
//#include <stdio.h>

#define AUDIO_FREQUENCY 44100
#define NUM_CHANNELS 10

void synth::generate_audio(int16_t* audio_buffer, unsigned buffer_length)
{
  int16_t* out = audio_buffer;
  uint32_t i,j,k;
  float out_l=0.0f;
  float out_r=0.0f;
#if defined(USE_OVERSAMPLING)
  float temp[8];
#else
  float temp_l=0.0f;
  float temp_r=0.0f;
#endif

  PolyHandler g_channel[10];

  g_channel[0].init(pad_channel_params,k_num_synth_params);
  g_channel[1].init(fx_channel_params,k_num_synth_params);
  g_channel[2].init(hh_channel_params,k_num_synth_params);
  g_channel[3].init(sd_channel_params,k_num_synth_params);
  g_channel[4].init(bd2_channel_params,k_num_synth_params);
  g_channel[5].init(jyrina_channel_params,k_num_synth_params);
  g_channel[6].init(hhdelay_channel_params,k_num_synth_params);
  g_channel[7].init(jyrinadelay_channel_params,k_num_synth_params);
  g_channel[8].init(sustbass_channel_params,k_num_synth_params);
  g_channel[9].init(bass_channel_params,k_num_synth_params);

#if defined(USE_OVERSAMPLING)
  CHalfBandFilter halfbandfilter1_l(10,true);
  CHalfBandFilter halfbandfilter1_r(10,true);
  CHalfBandFilter halfbandfilter2_l(10,true);
  CHalfBandFilter halfbandfilter2_r(10,true);
  for(i=0;i<NUM_CHANNELS;i++)
    g_channel[i].setParameter(k_samplerate,AUDIO_FREQUENCY*4.0f);
#endif

  //	float division = static_cast<float>(g_song_data[4]);
  //	float tempo = static_cast<float>(g_song_data[9]);
  float division=955.5f; // supposed to be 960 but for some reason drifts a lot
  float tempo=500000.0f;
  //not sure if accurate, could drift/jitter
  uint32_t srtick = static_cast<uint32_t>((AUDIO_FREQUENCY/1000000.0f)*(tempo/division));
  //	for(i=0;i<INTRO_LENGTH;i+=2)
  for(i = 0; (i < (buffer_length / sizeof(int16_t) / 2)); ++i)
  {
    unsigned ee = sizeof(g_song_data_outer) / sizeof(*g_song_data_outer) / 2;

    for(j = 0; (j < ee); ++j)
    {
      const uint8_t *inner = g_song_data_inner + j * 3;
      const uint16_t *outer = g_song_data_outer + j * 2;

      //            printf("Sample %ld -> timecode %ld x srtick %ld = %ld\n",i,g_song_data[j],srtick,g_song_data[j]*srtick);
      
      if((outer[0] * OUTER_SONG_DATA_DIVISOR * srtick) == i)
      {
        switch(inner[0])
        {
          case k_event_num_standard_note_on:
            //					printf("channel %d note on",g_song_data[j+2]);
            if(0 < outer[1])
            {
              g_channel[inner[1]].noteOn(inner[2], static_cast<float>(outer[1]) * (1.0f / 127.0f));
            }
            else
            {
              g_channel[inner[1]].noteOff(inner[2]);
            }
            break;

            //noteoff msgs not used
          //case k_event_num_standard_note_off:
            //g_channel[inner[1]].noteOff(inner[2]);
            //break;

          case k_event_num_standard_pitch_bend:
            g_channel[inner[1]].setParameter(k_pitchbend, static_cast<float>(outer[1]) * (1.0f / 16383.0f));
            break;

            //probably not gonna use this so should strip
            //					case k_event_num_standard_control_code:
            //						break;

          case k_event_num_custom_nrpn:
            g_channel[inner[1]].setParameter(inner[2], static_cast<float>(outer[1]) * (1.0f / 16383.0f));
            break;

          default:
            break;
        }
      }
    }

    out_l=0.0f;
    out_r=0.0f;
#if defined(USE_OVERSAMPLING)
    // processing samples with 4x oversampling
    for(k=0;k<NUM_CHANNELS;k++)
    {
      if(g_channel[k].getIsActive()==true)
      {
        for(j=0;j<4;j++)
        {
          g_channel[k].getSample(temp_l,temp_r);
          temp[2*j]+=temp_l;
          temp[2*j+1]+=temp_r;
        }
      }
    }
    for(j=0;j<4;j++)
    {
      temp[2*j] = halfbandfilter1_l.process(temp[2*j]);
      temp[2*j+1] = halfbandfilter1_r.process(temp[2*j+1]);
    }
    temp[2]=halfbandfilter2_l.process(temp[2]);
    temp[6]=halfbandfilter2_l.process(temp[6]);
    temp[3]=halfbandfilter2_r.process(temp[3]);
    temp[7]=halfbandfilter2_r.process(temp[7]);
    out_l=temp[6];
    out_r=temp[7];
#else
    // to avoid overflowing or wrapping or just plain nasty clipping,
    // running through tanh for tamer clipping.
    // will still probably alias like balls if coming in hot.
    for(k=0;k<NUM_CHANNELS;k++)
    {
      if(g_channel[k].getIsActive())
      {
        //levelit saattaa olla vituillaa. rationalTanh-kutsujen kertoimia voi laskea jos sarottaa liikaa
        g_channel[k].getSample(temp_l, temp_r);
        out_l += (0.9f-(0.015f*(float)k))*ctanhf(0.69f*temp_l);
        out_r += (0.9f-(0.015f*(float)k))*ctanhf(0.69f*temp_r);
      }
    }
#endif

    // Scaling of 0.9f was too low. Rescales so that output maximum just caps and rounds into 0.999f.
    //out_l=common::rationalTanh(0.9f * out_l);
    //out_r=common::rationalTanh(0.9f * out_r);
    out_l = ctanhf(5.9f * out_l);
    out_r = ctanhf(5.9f * out_r);

#if 0
    {
      static float out_max = -FLT_MAX;
      static float out_min = FLT_MAX;
      float new_max = fmaxf(fmaxf(fabsf(out_l), fabsf(out_r)), out_max);
      float new_min = fminf(fminf(fabsf(out_l), fabsf(out_r)), out_min);

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

    // master out, 32700 leaves some headroom so its not red hot
    out[i * 2 + 0] = static_cast<int16_t>(out_l * 32760.f); //left channel;
    out[i * 2 + 1] = static_cast<int16_t>(out_r * 32760.f); //right channel
  }
}

