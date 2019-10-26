#include "poly_handler.hpp"
#include "common.hpp"

void PolyHandler::init(int params[], int num_params)
{
  int i;
  m_num_active_voices = 0;
  m_volume = 1.0f;
  m_pan = 0.5f;
  m_out1_level = 1.0;
  m_out2_level = 1.0;
  m_out3_level = 1.0;
  m_out4_level = 1.0;
  /*
#ifdef VSTI
  m_delay.setSamplerate(SAMPLERATE);
#endif
  */

//setting all available notes/voices to inactive
  for(i = 0; i<NUM_VOICES; i++)
    m_notes[i] = -1;

//setting all instrument parameters as defined in the input array
  for(i = 0; i<num_params; i++)
    setParameter(i,static_cast<float>(params[i])/65535.0f);
}

//----------------------------------------------------------------------------
bool PolyHandler::getIsActive()
{
  if(m_num_active_voices>0)
    return true;
  else
    return false;
}

//----------------------------------------------------------------------------
void PolyHandler::getSample(float &leftsample, float &rightsample)
{
  int i;
  float retval = 0.0f;
  m_num_active_voices = 0;

  for(i=0; i<NUM_VOICES; i++)
  {
    //Only get samples for active voices.
    if(m_voices[i].getIsActive())
    {
      retval += m_voices[i].getSample();
      m_num_active_voices++;
    }
    else
      m_notes[i] = -1;
  }

//handle channel panning and process delay
  leftsample = retval * m_volume * sqrtf(1.0f - m_pan);
  rightsample = retval * m_volume * sqrtf(m_pan);
}

//----------------------------------------------------------------------------
void PolyHandler::noteOn(int note, float velocity)
{
  int i;
  m_num_active_voices++;

  //This should never happen, but just in case...
  if(velocity == 0.0f)
  {
    return;
  }

  for(i=0; i<NUM_VOICES; i++)
  {
    //If we're already playing this note, don't try and play it again.
    //TODO: implement retriggering, might be useful
    if(m_notes[i] == note)
    {
      m_voices[i].noteOn(note, velocity);
      return;
    }
  }

  for(i=0; i<NUM_VOICES; i++)
  {
    //If the current voice is not already playing, assign it the new note.
    if(!m_voices[i].getIsActive())
    {
      m_voices[i].noteOn(note, velocity);
      m_notes[i] = note;
      break;
    }
    //TODO: implement note stealing cases, ignoring for now
  }
}

//----------------------------------------------------------------------------
void PolyHandler::noteOff(int note)
{
  int i;

  for(i=0; i<NUM_VOICES; i++)
  {
    if(m_notes[i] == note)
    {
      m_voices[i].noteOff();
      //Note that voices[i] will still be active here (envelope release).
      break;
    }
  }
}

//----------------------------------------------------------------------------
void PolyHandler::allNotesOff()
{
  int i;

  for(i=0; i<NUM_VOICES; i++)
  {
    m_voices[i].noteOff();
    m_notes[i] = -1;
    //Note that voices[i] will still be active here (envelope release).
  }
}

//----------------------------------------------------------------------------
void PolyHandler::setParameter(int parameter, float value)
{
//handle channel volume and panning related parameters here and pass the rest to each voice for handling
  switch(parameter)
  {
    case k_volume:
      m_volume = value;
      break;

    case k_pan:
      m_pan = value;
      break;

    case k_out1_level:
      m_out1_level = value;
      break;

    case k_out2_level:
      m_out2_level = value;
      break;

    case k_out3_level:
      m_out3_level = value;
      break;

    case k_out4_level:
      m_out4_level = value;
      break;

    case k_samplerate:
    case k_tempo:
      break;

      //normalize parameter values to 0-1 range
    default:
#if !defined(ASSUME_SAFE_RANGES)
      value = common::cclampf(value, 0.0f, 1.0f);
#endif
      break;
  }
  //feed through to all voices
  for(int i=0; i<NUM_VOICES; i++)
  {
    m_voices[i].setParameter(parameter, value);
  }
}

