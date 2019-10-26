#ifndef REVERB_HPP
#define REVERB_HPP

#include "parameters.h"

//#include "oscillator.hpp"
#include "delay.hpp"

class Reverb
{
  public:
    Reverb(void);
    ~Reverb(void) {};

    void init(int params[], int num_params);
    void setParameter(int parameter, float value);

    void process(float &leftsample, float &rightsample);
    void setInputVolume(float input_volume) { m_input_volume = input_volume; };
    void setMix(float mix) { m_mix = mix; };
    void setPreDelayLength(float predelay_len);
    void setBandwidth(float bandwidth);
    void setDecay(float decay);
    void setDamping(float damping);
    void setRoomSize(float roomsize);

//#ifdef VSTI
    void setSamplerate(float samplerate) { m_samplerate = samplerate; };
//#endif


  private:
//#ifdef VSTI
    float m_samplerate;
//#endif
//control params
    float m_input_volume;
    float m_mix;
    float m_predelay_len;
    float m_bandwidth;
    float m_decay;
    float m_damping;
    float m_roomsize;
//gain coefficients
    float m_g1;
    float m_g2;
    float m_g3;
    float m_g4;
    float m_g5; //decay (rate of decay)
//allpass filters
    Delay m_apf1;
    Delay m_apf2;
    Delay m_apf3;
    Delay m_apf4;
    Delay m_apf5;
    Delay m_apf6;
//static delays
    Delay m_predelay;
    Delay m_delay1;
    Delay m_delay2;
    Delay m_delay3;
    Delay m_delay4;
//modulated allpass filters
    Delay m_mod_apf1;
    Delay m_mod_apf2;
//modulator oscillators for modulated allpass filters
//TODO: implement
//    Oscillator m_mod_osc1;
//    Oscillator m_mod_osc2;

//additional vars
    float m_feedback_left_tank;
    float m_feedback_right_tank;
};
#endif
