#include "reverb.hpp"
#include "parameters.h"
#include "common.hpp"
/*
dattorro plate reverb gain and decay values (from Will Pirkle's Designing Audio Effect Plug-Ins in C++, table 11.2)
values are for 44.1k samplerates

APF dx / delay(samples) / g(index) / g(value)
1,  210,      1, 0.75
2,  158,      1, 0.75
3,  561,      2, 0.625
4,  410,      2, 0.625
9,  3931,     3, 0.5
10, 2664,     3, 0.5

Fixed Delay dx / delay(samples)
7,  6241
8,  6590
11, 4641 (possibly 4681?)
12, 5505

Mod APF dx / delay(samples) / g(index) / g(value)
5,  1343+-12, 4, 0.7
6,  995 +-12, 4, 0.7
*/
#define PREDELAY_LEN 221.0f / 44100.0f

#define APF1_LEN 210.0f / 44100.0f
#define APF2_LEN 158.0f / 44100.0f
#define APF3_LEN 561.0f / 44100.0f
#define APF4_LEN 410.0f / 44100.0f
#define APF5_LEN 3931.0f / 44100.0f
#define APF6_LEN 2664.0f / 44100.0f

#define DELAY1_LEN 6241.0f / 44100.0f
#define DELAY2_LEN 6590.0f / 44100.0f
#define DELAY3_LEN 4641.0f / 44100.0f
#define DELAY4_LEN 5505.0f / 44100.0f

#define MODAPF1_LEN 1343.0f / 44100.0f
#define MODAPF2_LEN 995.0f / 44100.0f

Reverb::Reverb(void)
{
  m_samplerate = 44100.0f;
//control params
  m_input_volume=1.0f;
  m_predelay_len=(44100.0f / 441.0f);
  m_bandwidth = 0.9995f;
  m_decay = 0.5f;
  m_damping = 0.0005f;
  m_roomsize = 0.5f;
//gain coefficients
  m_g1 = 0.75f; //Decorrelates incoming signal (input diffusion 1)
  m_g2 = 0.625f; //(input diffusion 2)
  m_g3 = 0.5f; //Decorrelates tank signals; decay diffusion 2 = decay + 0.15, floor = 0.25, ceiling = 0.50 (decay diffusion 2)
  m_g4 = 0.7f; //Controls density of tail (decay diffusion 1)
  m_g5 = m_decay;
//allpass filters
  m_apf1.setMode(k_delay_mode_apf);
  m_apf2.setMode(k_delay_mode_apf);
  m_apf3.setMode(k_delay_mode_apf);
  m_apf4.setMode(k_delay_mode_apf);
  m_apf5.setMode(k_delay_mode_apf);
  m_apf6.setMode(k_delay_mode_apf);
  m_apf1.setDelayTime(common::clrintf(APF1_LEN * m_samplerate));
  m_apf2.setDelayTime(common::clrintf(APF2_LEN * m_samplerate));
  m_apf3.setDelayTime(common::clrintf(APF3_LEN * m_samplerate));
  m_apf4.setDelayTime(common::clrintf(APF4_LEN * m_samplerate));
  m_apf5.setDelayTime(common::clrintf(APF5_LEN * m_samplerate * m_roomsize));
  m_apf6.setDelayTime(common::clrintf(APF6_LEN * m_samplerate * m_roomsize));
  m_apf1.setFeedback(m_g1);
  m_apf2.setFeedback(m_g1);
  m_apf3.setFeedback(m_g2);
  m_apf4.setFeedback(m_g2);
  m_apf5.setFeedback(m_g4);
  m_apf6.setFeedback(m_g4);
//static delays
  m_predelay.setMode(k_delay_mode_mono);
  m_predelay.setTrueMono(true);
  m_predelay.setLowpassCutoff(m_bandwidth);
  m_delay1.setMode(k_delay_mode_mono);
  m_delay1.setTrueMono(true);
  m_delay2.setMode(k_delay_mode_mono);
  m_delay2.setTrueMono(true);
  m_delay3.setMode(k_delay_mode_mono);
  m_delay3.setTrueMono(true);
  m_delay4.setMode(k_delay_mode_mono);
  m_delay4.setTrueMono(true);
  m_predelay.setDelayTime(common::clrintf(PREDELAY_LEN * m_samplerate));
  m_delay1.setDelayTime(common::clrintf(DELAY1_LEN * m_samplerate * m_roomsize));
  m_delay2.setDelayTime(common::clrintf(DELAY2_LEN * m_samplerate * m_roomsize));
  m_delay3.setDelayTime(common::clrintf(DELAY3_LEN * m_samplerate * m_roomsize));
  m_delay4.setDelayTime(common::clrintf(DELAY4_LEN * m_samplerate * m_roomsize));
//modulated allpass filters
  m_mod_apf1.setMode(k_delay_mode_apf);
  m_mod_apf2.setMode(k_delay_mode_apf);
  m_mod_apf1.setDelayTime(common::clrintf(MODAPF1_LEN * m_samplerate * m_roomsize));
  m_mod_apf2.setDelayTime(common::clrintf(MODAPF2_LEN * m_samplerate * m_roomsize));
  m_mod_apf1.setFeedback(-m_g3);
  m_mod_apf2.setFeedback(-m_g3);

  m_feedback_left_tank = 0.0f;
  m_feedback_right_tank = 0.0f;
}

void Reverb::init(int params[], int num_params)
{
  int i;
//setting all instrument parameters as defined in the input array
  for(i = 0; i<num_params; i++)
    setParameter(i,static_cast<float>(params[i])/65535.0f);
}

void Reverb::setParameter(int parameter, float value)
{
#if !defined(ASSUME_SAFE_RANGES)
  value = common::cclampf(value, 0.0f, 1.0f);
#endif
  switch(parameter)
  {
    case FX::k_reverb_mix:
      setMix(value);
      break;

    case FX::k_reverb_predelay:
      setPreDelayLength(value);
      break;

    case FX::k_reverb_bandwidth:
      setBandwidth(value);
      break;

    case FX::k_reverb_damping:
      setDamping(value);
      break;

    case FX::k_reverb_decay:
      setDecay(value);
      break;

    case FX::k_reverb_roomsize:
      setRoomSize(value);
      break;

    default:
      break;
  }
}

void Reverb::setDecay(float decay)
{
  m_decay = decay;
  m_g5 = m_decay;
}

void Reverb::setPreDelayLength(float predelay_len)
{
  m_predelay_len = predelay_len;
  m_predelay.setDelayTime(m_predelay_len);
}

void Reverb::setDamping(float damping)
{
  m_damping = damping;
  m_delay1.setLowpassCutoff(m_damping);
  m_delay3.setLowpassCutoff(m_damping);
}

void Reverb::setRoomSize(float roomsize)
{
  m_roomsize = roomsize;
  m_mod_apf1.setDelayTime(common::clrintf(MODAPF1_LEN * m_samplerate * m_roomsize));
  m_mod_apf2.setDelayTime(common::clrintf(MODAPF2_LEN * m_samplerate * m_roomsize));
  m_apf5.setDelayTime(common::clrintf(APF5_LEN * m_samplerate * m_roomsize));
  m_apf6.setDelayTime(common::clrintf(APF6_LEN * m_samplerate * m_roomsize));
}

void Reverb::setBandwidth(float bandwidth)
{
  m_bandwidth = bandwidth;
  m_predelay.setLowpassCutoff(m_bandwidth);
}

void Reverb::process(float &leftsample, float &rightsample)
{
  common::add_dc(leftsample);
  common::add_dc(rightsample);

  //mixing to mono as dattorro's plate reverb design in mono in / stereo out
  float temp = m_input_volume * (leftsample+rightsample) / 2.0f;
  //predelay and input diffusion stage
  m_predelay.process(temp);
  m_apf1.process(temp);
  m_apf2.process(temp);
  m_apf3.process(temp);
  m_apf4.process(temp);

  //feed input to both tanks
  m_feedback_right_tank += temp;
  m_feedback_left_tank += temp;

  //process left tank
  float left_tank = m_feedback_right_tank;
  m_mod_apf1.process(left_tank);
  m_delay1.process(left_tank);
  left_tank *= m_g5;
  m_apf5.process(left_tank);
  m_delay2.process(left_tank);

  //process left tank
  float right_tank = m_feedback_left_tank;
  m_mod_apf2.process(right_tank);
  m_delay3.process(right_tank);
  right_tank *= m_g5;
  m_apf6.process(right_tank);
  m_delay4.process(right_tank);

  //decay and set to be fed back to the other tank
  m_feedback_left_tank = left_tank * m_g5;
  m_feedback_right_tank = right_tank * m_g5;

  //combine outputs from taps
  //TODO: define samplerate independent tap sample numbers 
  float left_out = m_delay1.getSampleDelayedBy(394)
                  +m_delay1.getSampleDelayedBy(4401)
                  -m_apf6.getSampleDelayedBy(277)
                  +m_delay2.getSampleDelayedBy(2954)
                  -m_delay3.getSampleDelayedBy(2945)
                  -m_apf5.getSampleDelayedBy(2831)
                  -m_delay4.getSampleDelayedBy(1578);

  float right_out = m_delay3.getSampleDelayedBy(522)
                   +m_delay3.getSampleDelayedBy(5368)
                   -m_apf5.getSampleDelayedBy(496)
                   +m_delay4.getSampleDelayedBy(3956)
                   -m_delay1.getSampleDelayedBy(3124)
                   -m_apf6.getSampleDelayedBy(1817)
                   -m_delay2.getSampleDelayedBy(179);

  leftsample = ((1.0f - m_mix) * leftsample) + (m_mix * left_out);
  rightsample = ((1.0f - m_mix) * rightsample) + (m_mix * right_out);
}
