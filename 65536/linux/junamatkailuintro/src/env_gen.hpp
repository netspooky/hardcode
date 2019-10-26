#ifndef ENV_GEN_HPP
#define ENV_GEN_HPP

#include "parameters.h"

enum envelope_state
{
  s_off, s_attack, s_decay, s_sustain, s_release
};

class EnvGen
{
  public:
    EnvGen(void);
    ~EnvGen(void) {};

#ifdef VSTI
    void setSamplerate(float samplerate) { m_samplerate = samplerate; };
#endif
    void setLength(float length) { m_length = length * static_cast<float>(g_env_length_stage_max); };
    void setAttack(float attack) { m_attack = attack; };
    void setDecay(float decay) { m_decay = decay; };
    void setSustain(float sustain) { m_sustain = sustain; };
    void setRelease(float release) { m_release = release; };
    void setADSR(float attack, float decay, float sustain, float release)
    {
      m_attack = attack;
      m_decay = decay;
      m_sustain = sustain;
      m_release = release;
    };
    void trigger(void);
    void stop(void);
    float getSample(void);

    void reset(void);
    bool isActive(void);

  private:
#ifdef VSTI
    float m_samplerate;
#endif
    float m_length; // envelope length (attack, decay and release parts)
    float m_step; // steps to increment envelope value for each sample, is calculated in reset()
    //asdr parameter values range from 0.0f to 1.0f
    float m_attack;
    float m_decay;
    float m_sustain;
    float m_release;
    int m_state;
    float m_value;

};

#endif
