#include "env_gen.hpp"
#include "common.hpp"

EnvGen::EnvGen(void)
{
  //initializing with something to avoid confusion
  setLength(0.1f);
  setADSR(0.0f,0.0f,0.8f,0.05f);
  reset();
}

void EnvGen::trigger(void)
{
  m_value = 0.0f;
  m_step = 1.0f/((0.001f+(0.999f*m_attack))*(SAMPLERATE*m_length));
  m_state = s_attack;
}

void EnvGen::stop(void)
{
  if(m_state == s_attack)
  {
    //still in the middle of attack, probably shouldn't jump to sustain vol
  }
  else
  {
    m_value = m_sustain;
  }
  m_step = 1.0f/((0.001f+(0.999f*m_release))*(SAMPLERATE*m_length));
  m_state = s_release;
}

bool EnvGen::isActive(void)
{
  if(m_state == s_off)
    return false;
  return true;
}

float EnvGen::getSample(void)
{
  switch(m_state)
  {
    case s_off:
      m_value = 0.0f;
      break;

    case s_attack:
      m_value += m_step;
      if(m_value > 1.0f)
      {
        m_value = 1.0f;
        m_step = 1.0f/((0.001f+(0.999f*m_decay))*(SAMPLERATE*m_length));
        m_state = s_decay;
      }
      break;

    case s_decay:
      m_value -= m_step;
      if(m_value < m_sustain)
      {
        m_value = m_sustain;
        m_state = s_sustain;
      }
      break;

    case s_sustain:
      break;

    case s_release:
      m_value -= m_step;
      if(m_value < 0.01f)
      {
        m_value = 0.0f;
        m_state = s_off;
      }
      break;
  }

  return m_value;
}

void EnvGen::reset(void)
{
  m_value = 0.0f;
  m_state = s_off;
  m_step = 1.0f/((0.001f+(0.999f*m_attack))*(SAMPLERATE*m_length));
}

